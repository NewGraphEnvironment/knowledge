#!/usr/bin/env python3
"""
scripts/0153-reports-to-zotero.py
---------------------------------------------------------------------------
File harvested EcoCat reports into their watershed-group Zotero collection,
with ALL of the report's documents attached.

WHY THIS EXISTS (pipeline step, not a one-off):
  The rag store holds extracted TEXT; the PDFs live in an ephemeral harvest dir.
  Zotero is the durable, synced, canonical home for the corpus and is what
  0150-store.R (ACTION=build) rebuilds from. A group that is harvested and
  ingested but never filed cannot be rebuilt -- it silently disappears on the
  next rebuild or on another machine. Run this after 0152 (ingest), always.

WHY ALL DOCUMENTS (not just the first PDF):
  An EcoCat report is usually several documents: main report + appendices +
  maps + data files (3-19 seen; report 163 has 19). The harvest grabs only the
  first PDF, so appendices/maps/XLS were being dropped -- including the FPCI
  form spreadsheets that carry per-site "no fish captured" comments
  and the 1:20k inventory map sheets. This files every document EcoCat serves
  for the report, so the record is complete even where the rag only has one
  document's text.

IDEMPOTENT: a report already present in the target collection (matched on
`EcoCat reportId:` in Extra / reportId= in url) is skipped. Zotero's S3 layer
dedups attachments by md5, so re-runs are cheap.

INPUT   REPORTS=COTR:48,FRAN:80,...  -- or --  --from-store data/rag/fraser.duckdb
        (--from-store reads `EXTENT__reportId.pdf` origins straight out of a
         ragnar store, which is how we recover ids after a harvest dir is gone)
        ZOTERO_API_KEY environment variable (write access to the group) ; group 4733734
OUTPUT  items + attachments in Zotero; a per-report status line; nothing local.
---------------------------------------------------------------------------
"""
import argparse, hashlib, json, os, re, sys, time, urllib.error, urllib.parse, urllib.request

GROUP = "4733734"
BASE = f"https://api.zotero.org/groups/{GROUP}"
ACAT = "https://a100.gov.bc.ca"
UA = {"User-Agent": "Mozilla/5.0"}

# watershed group code -> Zotero collection key (all under Fisheries > regions)
COLLECTIONS = {
    "BOWR": "KVAZMDU9", "MCGR": "8PE924W9", "COTR": "TD384BBA", "WILL": "6MAEDJJK",
    "UFRA": "9GE8WK2K", "TABR": "E8SC2MAW", "FRAN": "JVPHQ8KK", "LCHL": "UKKDUN7W",
    "NECR": "977GE58E",
}
DOC_RE = re.compile(r'/pub/acat/documents/r\d+/[^"\']+?\.(?:pdf|zip|xls|xlsx|doc|docx|csv|txt)', re.I)
API = os.environ.get("ZOTERO_API_KEY", "").strip()
if not API:
    sys.exit("ZOTERO_API_KEY is unset or empty: set it to a Zotero Web API key with write access to the group")

# ---- document selection policy -------------------------------------------
# An EcoCat report is 3-19 documents (main report + appendices + scanned 1:20k map
# sheets + data files). Attaching everything is several GB across a corpus this size
# and the scanned appendix parts (23-43 MB each) dominate that, so by default we take:
#   * ALL data files  (.xls/.xlsx/.zip/.csv/.doc/.docx) -- small, and the highest-value
#     material: FPCI form spreadsheets carry per-site "no fish captured" comments,
#     .zip are shapefiles
#   * the MAIN report PDF only -- prefer a filename saying report/final, else the first
#     non-appendix PDF; appendix/attachment/map/plate PDFs are skipped
#   * hard size guard: skip any single file over MAX_MB
# Skipped documents are listed in the item's Extra with the EcoCat link, so nothing is
# lost silently -- they can always be pulled from the report page.
DATA_EXT = re.compile(r"\.(xls|xlsx|zip|csv|doc|docx)$", re.I)
SUPPORTING = re.compile(r"(appendix|attach|map|plate|figure|photo|overview)", re.I)
MAX_MB = float(os.environ.get("MAX_MB", "25"))


def select_docs(docs, all_docs=False):
    """-> (chosen, skipped). See policy above."""
    if all_docs:
        return list(docs), []
    data = [d for d in docs if DATA_EXT.search(d)]
    pdfs = [d for d in docs if d.lower().endswith(".pdf")]
    main = [p for p in pdfs if re.search(r"(report|final)", p.rsplit("/", 1)[-1], re.I) and not SUPPORTING.search(p.rsplit("/", 1)[-1])]
    if not main:
        main = [p for p in pdfs if not SUPPORTING.search(p.rsplit("/", 1)[-1])]
    if not main:
        main = pdfs[:1]
    chosen = ([main[0]] if main else []) + data
    return chosen, [d for d in docs if d not in chosen]


def api(method, url, data=None, headers=None, raw=False, tries=6):
    """One Web API call -> (status, body).

    A 429 or 503 is retried after the server's Retry-After (the API sends one with
    each; 10 s when absent): the request was not processed, so a retried POST
    creates nothing twice. A Backoff header on a success asks for a pause before
    the next request, so it is honoured before returning (a 69-row dry run of
    0270 hit 429 on 25 titles in a row without it, 2026-11-01).
    """
    h = {"Zotero-API-Key": API}
    if headers:
        h.update(headers)
    body = data if raw else (json.dumps(data).encode() if data is not None else None)
    for i in range(tries):
        try:
            r = urllib.request.urlopen(urllib.request.Request(url, data=body, headers=h, method=method))
            st, bd, wait = r.status, r.read(), r.headers.get("Backoff")
        except urllib.error.HTTPError as e:
            st, bd = e.code, e.read()
            if st in (429, 503) and i < tries - 1:
                time.sleep(float(e.headers.get("Retry-After") or 10))
                continue
            wait = e.headers.get("Backoff")
        if wait:
            time.sleep(float(wait))
        return st, bd


def tok():
    return hashlib.md5(os.urandom(16)).hexdigest()[:32]


def fetch(url, timeout=90):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout).read()


def report_page(rid):
    """Return (title, author, year, [doc urls]) for an EcoCat report.

    Page structure (verified against several reports):
      title  -> a heading reading "Report:  <the actual title>"
      fields -> "<Label>:</B>&nbsp; <value><BR>" pairs (Author, Date Published, ...)
    Do NOT fall back to <title>, which is the site-wide "Aquatic Report Catalogue".
    """
    import html as _h
    raw = fetch(f"{ACAT}/pub/acat/public/viewReport.do?reportId={rid}", timeout=60).decode("utf8", "ignore")
    docs = sorted(set(ACAT + m for m in DOC_RE.findall(raw)))

    def field(label):
        m = re.search(label + r"\s*:\s*</B>\s*(?:&nbsp;)*\s*([^<]{2,300})", raw, re.I)
        return re.sub(r"\s+", " ", _h.unescape(m.group(1))).strip() if m else ""

    title = ""
    for m in re.finditer(r"<(H[1-4])[^>]*>(.*?)</\1>", raw, re.I | re.S):
        txt = re.sub(r"\s+", " ", _h.unescape(re.sub(r"<[^>]+>", "", m.group(2)))).strip()
        if re.match(r"^Report\s*:", txt, re.I):
            title = re.sub(r"^Report\s*:\s*", "", txt, flags=re.I).strip()
            break
    if not title:
        title = f"EcoCat report {rid}"
    y = re.search(r"\b(19|20)\d{2}\b", field("Date Published") or field("Publication Date"))
    return title[:400], field("Author")[:300], (y.group(0) if y else ""), docs


def existing_report_ids(coll_key):
    """reportIds already filed in this collection WITH at least one attachment.

    Presence alone is not enough: a run interrupted mid-upload leaves an item with
    no (or partial) files, and skipping on presence would strand it incomplete
    forever. Items with zero attachments are reported so they can be re-filed.
    """
    ids, empty, start = set(), set(), 0
    while True:
        st, bd = api("GET", f"{BASE}/collections/{coll_key}/items/top?limit=100&start={start}")
        items = json.loads(bd)
        if not items:
            break
        for it in items:
            blob = " ".join(str(it["data"].get(k, "")) for k in ("url", "extra", "title"))
            found = re.findall(r"reportId[=:]\s*(\d+)", blob)
            if not found:
                continue
            n = it.get("meta", {}).get("numChildren", 0)
            (ids if n else empty).update(found)
        start += 100
        if len(items) < 100:
            break
    if empty:
        print(f"    note: {len(empty)} filed item(s) have NO attachments (will re-file): {','.join(sorted(empty))}")
    return ids - empty


def attach(parent_key, url, fname, exempt_size=False):
    """Create an attachment item under parent and upload the file (4-step S3).

    Never raises: EcoCat serves the occasional dead document link (404) and a
    single bad file must not abort a batch of hundreds of reports.

    `exempt_size` bypasses MAX_MB — used for the MAIN report, which must always
    be attached. The size guard exists to keep scanned appendix/map bulk out of
    the shared library, not to drop the report itself (52364's report is 32 MB,
    and capping it left the item with no attachment at all).
    """
    try:
        data = fetch(url)
    except Exception as e:
        return f"fetch-fail({getattr(e, 'code', type(e).__name__)})"
    if len(data) < 512:
        return "tiny/failed"
    if not exempt_size and len(data) > MAX_MB * 1048576:
        return f"skip-{len(data)//1048576}MB"
    return upload(parent_key, data, fname)


def upload(parent_key, data, fname):
    """Create an imported-file attachment under parent and upload `data` (4-step S3).

    Shared with 0270, which uploads PDFs from the local Zotero storage rather than
    from a URL. Returns a status string and never raises on an HTTP failure.
    """
    ctype = ("application/pdf" if fname.lower().endswith(".pdf") else "application/octet-stream")
    st, bd = api("POST", f"{BASE}/items",
                 data=[{"itemType": "attachment", "parentItem": parent_key, "linkMode": "imported_file",
                        "title": fname, "contentType": ctype, "filename": fname}],
                 headers={"Content-Type": "application/json", "Zotero-Write-Token": tok()})
    try:
        att = json.loads(bd)["successful"]["0"]["key"]
    except Exception:
        return f"att-fail {st}"
    md5 = hashlib.md5(data).hexdigest()
    body = f"md5={md5}&filename={urllib.parse.quote(fname)}&filesize={len(data)}&mtime={int(time.time()*1000)}".encode()
    st, bd = api("POST", f"{BASE}/items/{att}/file", data=body, raw=True,
                 headers={"Content-Type": "application/x-www-form-urlencoded", "If-None-Match": "*"})
    try:
        a = json.loads(bd)
    except Exception:
        return f"auth-fail {st}"
    if a.get("exists") == 1:
        return "exists"
    s3 = a["prefix"].encode() + data + a["suffix"].encode()
    try:
        urllib.request.urlopen(urllib.request.Request(a["url"], data=s3, headers={"Content-Type": a["contentType"]}, method="POST"), timeout=600)
    except urllib.error.HTTPError as e:
        return f"s3-{e.code}"
    st, _ = api("POST", f"{BASE}/items/{att}/file", data=f"upload={a['uploadKey']}".encode(), raw=True,
                headers={"Content-Type": "application/x-www-form-urlencoded", "If-None-Match": "*"})
    return "uploaded" if st == 204 else f"register-{st}"


def file_report(code, rid, coll, all_docs=False):
    try:
        title, author, year, docs = report_page(rid)
    except Exception as e:
        return f"{code} {rid}: page-fail {e}"
    if not docs:
        return f"{code} {rid}: no documents (record-only)"
    chosen, skipped = select_docs(docs, all_docs)
    view = f"{ACAT}/pub/acat/public/viewReport.do?reportId={rid}"
    extra = f"EcoCat reportId: {rid}\nacat_report_url: {view}"
    if skipped:
        extra += ("\nNot attached (%d of %d docs — fetch from the EcoCat link above): %s"
                  % (len(skipped), len(docs), ", ".join(s.rsplit("/", 1)[-1][:40] for s in skipped)))
    item = {"itemType": "report", "title": title, "date": year, "url": view,
            "institution": author, "extra": extra, "collections": [coll],
            "tags": [{"tag": code}, {"tag": "ecocat-harvest"}, {"tag": "fish-passage"}]}
    if author:
        item["creators"] = [{"creatorType": "author", "name": author}]
    st, bd = api("POST", f"{BASE}/items", data=[item],
                 headers={"Content-Type": "application/json", "Zotero-Write-Token": tok()})
    try:
        key = json.loads(bd)["successful"]["0"]["key"]
    except Exception:
        return f"{code} {rid}: create-fail {st} {bd[:100]}"
    res = []
    for i, u in enumerate(chosen):
        # chosen[0] is the main report when a PDF was picked -> never size-capped
        main_pdf = (i == 0 and u.lower().endswith(".pdf"))
        res.append(attach(key, u, urllib.parse.unquote(u.rsplit("/", 1)[-1])[:120], exempt_size=main_pdf))
    ok = sum(1 for r in res if r in ("uploaded", "exists"))
    return (f"{code} {rid}: {key} | {ok}/{len(chosen)} attached, {len(skipped)} skipped "
            f"[{','.join(sorted(set(res))) or '-'}] | {title[:46]}")


def _store_origins(path):
    """Read `origin` out of a ragnar store. Prefers python duckdb; falls back to
    Rscript (the repo is R-centric and R's duckdb is always present here)."""
    try:
        import duckdb
        con = duckdb.connect(path, read_only=True)
        rows = [r[0] for r in con.execute("SELECT origin FROM documents").fetchall()]
        con.close()
        return rows
    except ImportError:
        import subprocess
        r = subprocess.run(["Rscript", "-e", (
            "suppressMessages(library(DBI));"
            f"s<-dbConnect(duckdb::duckdb(),'{path}',read_only=TRUE);"
            "cat(dbGetQuery(s,'SELECT origin FROM documents')$origin,sep='\\n');"
            "dbDisconnect(s,shutdown=TRUE)")], capture_output=True, text=True)
        if r.returncode != 0:
            sys.exit(f"could not read store: {r.stderr[-400:]}")
        return [l for l in r.stdout.splitlines() if l.strip()]


def ids_from_store(path, codes):
    rows = [(o,) for o in _store_origins(path)]
    out = {}
    for (o,) in rows:
        m = re.match(r"^([A-Za-z]+)__(\d+)\.pdf$", os.path.basename(o))
        if m and (not codes or m.group(1).upper() in codes) and m.group(1).upper() in COLLECTIONS:
            out.setdefault(m.group(1).upper(), set()).add(m.group(2))
    return out


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--from-store")
    p.add_argument("--codes", default="")
    p.add_argument("--reports", default="")           # CODE:id,id;CODE:id
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--all-docs", action="store_true", help="attach every document (ignores the selection policy)")
    a = p.parse_args()
    codes = {c.strip().upper() for c in a.codes.split(",") if c.strip()}

    targets = {}
    if a.from_store:
        targets = ids_from_store(a.from_store, codes)
    for chunk in filter(None, a.reports.split(";")):
        c, ids = chunk.split(":", 1)
        targets.setdefault(c.strip().upper(), set()).update(i.strip() for i in ids.split(",") if i.strip())

    grand = 0
    for code, ids in sorted(targets.items()):
        coll = COLLECTIONS[code]
        have = existing_report_ids(coll)
        todo = sorted(ids - have, key=int)
        print(f"\n=== {code} ({coll}): {len(ids)} in store | {len(ids & have)} already filed | {len(todo)} to file ===", flush=True)
        if a.dry_run:
            print("   ", ",".join(todo)); continue
        for rid in todo:
            try:
                print("  " + file_report(code, rid, coll, a.all_docs), flush=True)
            except Exception as e:                      # never abort the batch
                print(f"  {code} {rid}: ERROR {type(e).__name__} {e}", flush=True)
            grand += 1
    print(f"\nfiled {grand} report(s)")
