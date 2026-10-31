#!/usr/bin/env python3
"""
scripts/0270-habitat-collection-build.py
---------------------------------------------------------------------------
Build a group-library collection under Fisheries (habitat_modelling by default,
--collection for another; --parent for a collection under another parent, such as
the species collections under species) from a curated key list, so the ragnar store of the same
name (0150 ACTION=build) can be rebuilt from the group library alone, on any
machine synced to it.

WHY: the habitat-modelling literature (where the bcfishpass thresholds come
from) sat in a PERSONAL collection. Every item there has a group-library copy,
but 24 of 35 of those copies had no PDF attached: the PDFs were in the personal
library or in two retired group libraries. 0150 builds from the group library
and needs the PDF on the group item itself. So this script, for each member:
  1. resolves the citation key to its group item (from the local zotero.sqlite);
  2. copies the item into the group when only another library has it
     (metadata from the local database; no citation key is set, BBT derives it);
  3. adds the item to the collection;
  4. uploads the local PDF when the group item has none.

Live state (collection membership, attachments, whether a copy already exists)
is read from the Web API, not the local database: the local file only sees a
write after Zotero syncs, so it cannot make a re-run idempotent.

A second input adds works the group library does not hold at all
(data/habitat_modelling_additions.csv). A row with a DOI takes its metadata from
CrossRef, with the abstract the publisher deposited there (tags stripped; none is
ever written by hand); a grey-literature row carries it. `pdf` is `none` for a work
whose PDF cannot be had, which 0280 then checks against that abstract, or a URL (the body must start
with %PDF), a path from the repo root (a PDF only a browser could fetch, kept in the
ignored data/rag/pdf/), or `zotero:<attachment key>`, a standalone group PDF with no parent
item, which gets a parent of its own. The standalone is left untouched: making
it a child would drop it from its collections (a child cannot be a member), and
the upload of the same bytes is deduplicated by md5.

A member row may name a `pdf` (a URL, or a path relative to the repo root) for an
item that has no PDF anywhere in the local libraries, such as a web page printed to
PDF. It is read only when the group item has no stored PDF, so a re-run on a
machine without the file is a no-op once the upload has landed.

INPUT   data/<collection>_members.csv   (citation_key, source, optional pdf)
        data/<collection>_additions.csv (metadata or DOI, pdf, why), if it exists
        ~/Zotero/zotero.sqlite, via a checked copy (key -> item, local PDF paths)
        ZOTERO_API_KEY environment variable, as in 0153; group 4733734
OUTPUT  Zotero writes only; one status line per member and a summary.
        --dry-run does every read and no write.
---------------------------------------------------------------------------
"""
import argparse, csv, html, importlib.util, json, os, re, sqlite3, sys, urllib.parse

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("z0153", os.path.join(HERE, "0153-reports-to-zotero.py"))
z = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(z)          # 0153 has a __main__ guard; this only defines helpers

COLLECTION = "habitat_modelling"     # the collection name and the tag on created items; --collection
PARENT = "TRXPJHQE"                  # Fisheries, group library; --parent (species is 9U54XAND)
ZDIR = os.path.expanduser("~/Zotero")
# Fields the Web API must not receive on a copy: identity, sync state, and the
# citation key (BBT derives it; a hand-set key breaks the key formula).
SKIP_FIELDS = {"citationKey"}


def db(live=os.path.join(ZDIR, "zotero.sqlite"), tries=6, wait=15):
    """A consistent snapshot of the local Zotero database.

    Reads go to a copy, never the live file: under its old rollback journal Zotero
    held an exclusive lock, so a normal read-only connection blocked, and an
    `immutable=1` read of the live file saw pages mid-write while a sync was in
    progress ("database disk image is malformed" on every member, measured right
    after this script's own writes started a sync). Zotero 10 runs it in WAL mode
    (a plain read-only connection did not block on 2026-10-31), where a commit sits
    in zotero.sqlite-wal until a checkpoint folds it into the main file, so the copy
    takes the -wal with the main file: the main file alone opens, passes quick_check
    and silently misses those commits (#127, data-raw/zotero_copy_check.R). The -shm is not copied; SQLite rebuilds it. Each
    try clears the copy's -wal first, so one left by an earlier try never sits beside
    a newer main file. Keep the copy only when nothing wrote meanwhile: both files'
    mtime and size and the header's journal mode are unchanged across the copy, no
    rollback-journal transaction is open (the journal is absent or its header zeroed,
    before and after), and the copy opens and passes quick_check. The header change
    counter is no guard: in Zotero's exclusive locking mode SQLite did not bump it per
    commit (measured: five commits, counter unchanged), and in WAL mode it need not.
    """
    import atexit, shutil, tempfile, time
    wal = live + "-wal"
    journal = live + "-journal"
    tmpdir = tempfile.mkdtemp(prefix="zotero_snap_")
    atexit.register(shutil.rmtree, tmpdir, True)
    tmp = os.path.join(tmpdir, "zotero.sqlite")

    def stat(path):
        try:
            st = os.stat(path)
            return st.st_mtime_ns, st.st_size
        except FileNotFoundError:
            return None

    def state():
        try:
            with open(journal, "rb") as f:
                open_txn = f.read(8).strip(b"\0") != b""
        except FileNotFoundError:
            open_txn = False
        with open(live, "rb") as f:
            mode = f.read(20)[18:20]
        return stat(live), stat(wal), mode, open_txn
    for i in range(tries):
        before = state()
        for p in (tmp + "-wal", tmp + "-shm"):
            if os.path.exists(p):
                os.remove(p)
        shutil.copyfile(live, tmp)
        try:
            shutil.copyfile(wal, tmp + "-wal")
        except FileNotFoundError:
            pass                                  # no -wal: rollback mode, or WAL fully checkpointed
        after = state()
        if before == after and not before[3]:
            con = None
            try:
                con = sqlite3.connect(tmp)
                if con.execute("PRAGMA quick_check").fetchone()[0] == "ok":
                    return con
            except sqlite3.DatabaseError:
                pass
            if con is not None:
                con.close()
        time.sleep(wait)
    sys.exit(f"no consistent copy of zotero.sqlite after {tries} tries; is Zotero mid-sync?")


def local_items(con, key):
    """-> [(libraryID, itemID, itemKey)] for every non-deleted item carrying the citation key."""
    return con.execute("""
        SELECT i.libraryID, i.itemID, i.key FROM items i
        JOIN itemData id ON id.itemID = i.itemID JOIN itemDataValues v ON v.valueID = id.valueID
        JOIN fields f ON f.fieldID = id.fieldID
        LEFT JOIN deletedItems d ON d.itemID = i.itemID
        WHERE f.fieldName = 'citationKey' AND v.value = ? AND d.itemID IS NULL""", (key,)).fetchall()


def base_attachment_path():
    """Zotero's base directory for `attachments:` relative links, from the profile prefs."""
    import glob, re
    for prefs in glob.glob(os.path.expanduser("~/Library/Application Support/Zotero/Profiles/*/prefs.js")):
        m = re.search(r'user_pref\("extensions\.zotero\.baseAttachmentPath", "(.*?)"\);', open(prefs).read())
        if m:
            return m.group(1)
    return None


def local_pdf(con, item_ids):
    """Path of the first local PDF file attached to any of the items, or None.

    Stored files (`storage:`) live under ~/Zotero/storage/<attachment key>/; linked files
    are absolute, `attachments:` relative to the base attachment path, or absolute Windows
    paths from the old machine, rebased onto the base path. A file not found is skipped.
    """
    base = base_attachment_path()
    for iid in item_ids:
        for path, akey in con.execute("""
                SELECT ia.path, a.key FROM itemAttachments ia JOIN items a ON a.itemID = ia.itemID
                LEFT JOIN deletedItems d ON d.itemID = a.itemID
                WHERE ia.parentItemID = ? AND ia.contentType = 'application/pdf' AND d.itemID IS NULL""",
                (iid,)):
            if not path:
                continue
            if path.startswith("storage:"):
                p = os.path.join(ZDIR, "storage", akey, path[len("storage:"):])
            elif path.startswith("attachments:"):
                if not base:
                    continue
                p = os.path.join(base, path[len("attachments:"):])
            elif base and "\\storage\\" in path.lower():
                # A link recorded on the old Windows machine (D:\...\storage\<Author>\<file>).
                # The linked-file tree was carried over under the base attachment path, so
                # rebase the part after `storage\` (152 of 158 such PDFs resolve that way).
                rel = path[path.lower().index("\\storage\\") + len("\\storage\\"):]
                p = os.path.join(base, *rel.split("\\"))
            else:
                p = path
            if os.path.isfile(p):
                return p
    return None


def title_of(con, item_id):
    r = con.execute("""SELECT v.value FROM itemData id JOIN itemDataValues v ON v.valueID = id.valueID
        JOIN fields f ON f.fieldID = id.fieldID WHERE f.fieldName = 'title' AND id.itemID = ?""",
                    (item_id,)).fetchone()
    return r[0] if r else ""


def same_work(a, b):
    """Titles equal once case and punctuation are dropped. Citation keys are not unique
    across libraries (the same key names different papers in two libraries), so a PDF
    is only taken from an item whose title matches the item it is uploaded to."""
    # plain() on both sides: a stored title may carry CrossRef markup ("<i>Oncorhynchus</i>")
    # that a title made from CrossRef now drops, and the tag letters are alphanumeric.
    n = lambda t: "".join(ch for ch in plain(t).lower() if ch.isalnum())
    return bool(n(a)) and n(a) == n(b)


def item_json(con, item_id, coll):
    """Web API JSON for a copy of a local item, from its fields and creators."""
    itype = con.execute("SELECT t.typeName FROM items i JOIN itemTypes t ON t.itemTypeID = i.itemTypeID "
                        "WHERE i.itemID = ?", (item_id,)).fetchone()[0]
    out = {"itemType": itype, "collections": [coll], "tags": [{"tag": COLLECTION}]}
    for name, value in con.execute("""
            SELECT f.fieldName, v.value FROM itemData id JOIN fields f ON f.fieldID = id.fieldID
            JOIN itemDataValues v ON v.valueID = id.valueID WHERE id.itemID = ?""", (item_id,)):
        if name not in SKIP_FIELDS:
            out[name] = value
    if "extra" in out:                # never carry a hand-set key through Extra either
        out["extra"] = "\n".join(l for l in out["extra"].splitlines()
                                 if not l.lower().startswith("citation key:")) or None
        if out["extra"] is None:
            del out["extra"]
    out["creators"] = []
    for ctype, first, last, mode in con.execute("""
            SELECT ct.creatorType, c.firstName, c.lastName, c.fieldMode FROM itemCreators ic
            JOIN creators c ON c.creatorID = ic.creatorID JOIN creatorTypes ct ON ct.creatorTypeID = ic.creatorTypeID
            WHERE ic.itemID = ? ORDER BY ic.orderIndex""", (item_id,)):
        out["creators"].append({"creatorType": ctype, "name": last} if mode == 1 else
                               {"creatorType": ctype, "firstName": first or "", "lastName": last or ""})
    return out


def get_json(url):
    st, bd = z.api("GET", url)
    if st != 200:     # raise, not sys.exit: the per-member handler must catch it
        raise RuntimeError(f"GET {url} -> {st} {bd[:200]!r}")
    return json.loads(bd)


def find_collection(dry):
    for c in get_json(f"{z.BASE}/collections/{PARENT}/collections?limit=100"):
        if c["data"]["name"] == COLLECTION:
            return c["key"], "exists"
    # Not under PARENT. A collection of that name elsewhere in the group is almost always the
    # one meant with --parent forgotten (species/grayling run without --parent 9U54XAND), and
    # creating a second one would fill it from the same members file.
    elsewhere, start = [], 0
    while True:
        page = get_json(f"{z.BASE}/collections?limit=100&start={start}")
        elsewhere += [f"{c['key']} (under {c['data'].get('parentCollection') or 'top level'})"
                      for c in page if c["data"]["name"] == COLLECTION and not c["data"].get("deleted")]
        if len(page) < 100:
            break
        start += 100
    if elsewhere:
        sys.exit(f"no collection {COLLECTION} under {PARENT}, but the group has {', '.join(elsewhere)}: "
                 "pass --parent with that parent's key")
    if dry:
        return None, "would create"
    st, bd = z.api("POST", f"{z.BASE}/collections",
                   data=[{"name": COLLECTION, "parentCollection": PARENT}],
                   headers={"Content-Type": "application/json", "Zotero-Write-Token": z.tok()})
    try:
        return json.loads(bd)["successful"]["0"]["key"], "created"
    except Exception:
        sys.exit(f"collection create failed: {st} {bd[:200]!r}")


def has_pdf(item_key):
    """True when the group item has an imported PDF attachment whose file is stored."""
    for ch in get_json(f"{z.BASE}/items/{item_key}/children?limit=100"):
        d = ch["data"]
        # md5 is set only once a file is stored: an attachment row left by an upload
        # that failed after its first step has none, and must not count as a PDF.
        if (d.get("itemType") == "attachment" and d.get("contentType") == "application/pdf"
                and d.get("linkMode") in ("imported_file", "imported_url") and d.get("md5")):
            return True
    return False


def _year(date):
    m = re.search(r"(1[89]|20)[0-9]{2}", date or "")
    return m.group(0) if m else None


def _first_last(creators):
    for c in creators or []:
        name = c.get("lastName") or c.get("name")
        if name:
            return name.strip().lower()
    return None


def group_copy(item):
    """Key of a group item that is this work (a previous run's copy), or None.

    Same normalized title, and the same first creator and year wherever both sides
    have them: titles like "Bull trout Salvelinus confluentus" recur across works.
    An item with no title never matches."""
    title = (item.get("title") or "").strip()
    if not title:
        return None
    # Words only: the search matches each word as a substring, and a plain title's "(Oncorhynchus"
    # is not one of "( <i>Oncorhynchus", a markup title's.
    q = urllib.parse.quote(" ".join(re.sub(r"[^\w]+", " ", title[:120]).split()))
    start = 0
    while True:
        page = get_json(f"{z.BASE}/items/top?q={q}&qmode=titleCreatorYear&limit=100&start={start}")
        for it in page:
            d = it["data"]
            if not same_work(d.get("title", ""), title):
                continue
            a, b = _first_last(d.get("creators")), _first_last(item.get("creators"))
            if a and b and a != b:
                continue
            ya, yb = _year(d.get("date")), _year(item.get("date"))
            if ya and yb and ya != yb:
                continue
            return it["key"]
        if len(page) < 100:
            return None
        start += 100


def ensure(gkey, coll, dry, find_pdf, required=False):
    """Make gkey a member of coll and give it a stored PDF. `find_pdf()` returns a local
    path, (name, bytes), or None, and is only called when the item has no PDF. With
    `required`, a PDF the input named but that cannot be found is a failure. -> steps."""
    steps = []
    it = get_json(f"{z.BASE}/items/{gkey}")
    colls = it["data"].get("collections", [])
    if coll and coll in colls:
        steps.append("member")
    elif dry:
        steps.append("would add")
    else:
        st, bd = z.api("PATCH", f"{z.BASE}/items/{gkey}", data={"collections": colls + [coll]},
                       headers={"Content-Type": "application/json",
                                "If-Unmodified-Since-Version": str(it["version"])})
        steps.append("added" if st == 204 else f"ADD-FAIL {st} {bd[:160]!r}")
    if has_pdf(gkey):
        steps.append("pdf present")
        return steps
    found = find_pdf()
    if not found:
        steps.append("PDF-MISSING: named in the input, not found" if required else "no-pdf: none local")
        return steps
    name, data = found if isinstance(found, tuple) else (os.path.basename(found), None)
    if data is None:
        with open(found, "rb") as f:
            data = f.read()
    # upload() types the attachment from the file name and has_pdf() counts only
    # application/pdf, so a non-PDF, or a PDF named without the suffix, would be
    # uploaded again on every run.
    if not data.startswith(b"%PDF"):
        steps.append(f"PDF-FAIL not a PDF: {name}")
        return steps
    if not name.lower().endswith(".pdf"):
        name += ".pdf"
    if dry:
        steps.append(f"would upload {name}")
        return steps
    res = z.upload(gkey, data, name)
    steps.append(f"pdf {res}" if res in ("uploaded", "exists") else f"PDF-FAIL {res}")
    return steps


INLINE = r"</?(?:jats:)?(?:sup|sub|i|b|italic|bold|sc|scp|u|em|strong)\b[^>]*>"


def plain(x):
    """CrossRef markup as plain text: inline tags (italic, super- and subscript) dropped
    without a gap, so "m<sup>2</sup>" stays "m2" and a gate never reads its exponent as a
    value; other tags become a space; entities decoded; whitespace collapsed."""
    x = re.sub(INLINE, "", x or "")
    return re.sub(r"\s+", " ", html.unescape(re.sub(r"<[^>]+>", " ", x))).strip()


def crossref_abstract(m):
    """The abstract CrossRef holds, as plain text, without a leading "Abstract" title.
    "" when there is none."""
    return plain(re.sub(r"<jats:title>.*?</jats:title>", " ", m.get("abstract") or "", flags=re.S))


def crossref_item(doi):
    """Journal-article JSON from CrossRef, with the deposited abstract (none is written by hand)."""
    m = json.loads(z.fetch(f"https://api.crossref.org/works/{urllib.parse.quote(doi)}"))["message"]
    parts = m.get("issued", {}).get("date-parts", [[None]])[0]
    return {"abstractNote": crossref_abstract(m),
        "itemType": "journalArticle", "title": re.sub(r"\( ", "(", re.sub(r" \)", ")", plain(m["title"][0]))),
        "creators": [{"creatorType": "author", "firstName": a.get("given", ""), "lastName": a.get("family", "")}
                     for a in m.get("author", [])],
        "date": "-".join(str(p).zfill(2) if i else str(p) for i, p in enumerate(parts) if p),
        "publicationTitle": (m.get("container-title") or [""])[0], "volume": m.get("volume", ""),
        "issue": m.get("issue", ""), "pages": m.get("page", "").replace("-", "\u2013"),
        "DOI": doi, "url": f"https://doi.org/{doi}"}


def addition_item(row):
    """Web API JSON for an additions row (CrossRef when it has a DOI)."""
    if row["DOI"]:
        return crossref_item(row["DOI"])
    # university and thesisType are a thesis's fields where a report has institution and reportType,
    # and bookTitle, pages, series and seriesNumber a book section's; an additions file without
    # those columns simply never sets them.
    item = {k: row[k] for k in ("itemType", "title", "date", "institution", "reportNumber", "reportType",
                                "university", "thesisType", "place", "url", "bookTitle", "pages",
                                "series", "seriesNumber") if row.get(k)}
    item["creators"] = []
    for c in filter(None, (x.strip() for x in row["creators"].split(";"))):
        last, _, first = c.partition(",")
        item["creators"].append({"creatorType": "author", "lastName": last.strip(), "firstName": first.strip()})
    return item


def addition_pdf(row):
    """(filename, bytes) for an additions or member row, or None. A URL must return a real
    PDF; a path that is not a URL or `zotero:` key is read relative to the repo root."""
    src = row["pdf"]
    if src.startswith("zotero:"):
        akey = src[len("zotero:"):]
        d = os.path.join(ZDIR, "storage", akey)
        files = [f for f in os.listdir(d) if f.lower().endswith(".pdf")] if os.path.isdir(d) else []
        if len(files) != 1:
            return None
        with open(os.path.join(d, files[0]), "rb") as f:
            return files[0], f.read()
    if not re.match(r"https?://", src):
        p = os.path.join(HERE, "..", src)
        if not os.path.isfile(p):
            return None
        with open(p, "rb") as f:
            return os.path.basename(p), f.read()
    data = z.fetch(src, timeout=180)
    if not data.startswith(b"%PDF"):
        raise ValueError(f"not a PDF: {src}")
    return urllib.parse.unquote(src.rsplit("/", 1)[-1])[:120], data


def do_addition(row, coll, dry):
    item = addition_item(row)
    item.update({"collections": [coll], "tags": [{"tag": COLLECTION}]})
    steps = []
    gkey = group_copy(item)
    if gkey:
        steps.append("exists")
    elif dry:
        return [f"would create {item['itemType']}"], f"- | would create {item['itemType']}: {item['title'][:60]}"
    else:
        st, bd = z.api("POST", f"{z.BASE}/items", data=[item],
                       headers={"Content-Type": "application/json", "Zotero-Write-Token": z.tok()})
        try:
            gkey = json.loads(bd)["successful"]["0"]["key"]
            steps.append("created")
        except Exception:
            return [f"CREATE-FAIL {st}"], f"- | CREATE-FAIL {st} {bd[:160]!r}"
    if row["pdf"].strip().lower() == "none":
        # Abstract only: no PDF to find, and 0280 has nothing to check a row against
        # unless the item carries its abstract.
        steps += ensure(gkey, coll, dry, lambda: None)
        if steps[-1].startswith("no-pdf"):
            i = len(steps) - 1
            # 0280 reads the group item's own abstract, and an item that already existed was
            # never given CrossRef's; a stored abstract also outlives a fix to plain(). So bring
            # the group item to CrossRef's current form. (gkey is set: a dry run returns before
            # create.)
            held = get_json(f"{z.BASE}/items/{gkey}")["data"]
            have, want = held.get("abstractNote") or "", item.get("abstractNote") or ""
            if want and have != want:
                if dry:
                    steps.append("would set abstract")
                    have = want
                else:
                    st, bd = z.api("PATCH", f"{z.BASE}/items/{gkey}", data={"abstractNote": want},
                                   headers={"Content-Type": "application/json",
                                            "If-Unmodified-Since-Version": str(held["version"])})
                    steps.append("abstract set" if st == 204 else f"ABSTRACT-FAIL {st} {bd[:160]!r}")
                    if st == 204:
                        have = want
            steps[i] = ("no-pdf: abstract only" if have.strip()
                        else "ABSTRACT-MISSING: pdf none and the item has no abstract")
    else:
        steps += ensure(gkey, coll, dry, lambda: addition_pdf(row), required=True)
    return steps, f"{gkey} | " + ", ".join(steps)


def main():
    global COLLECTION, PARENT
    p = argparse.ArgumentParser()
    p.add_argument("--collection", default=COLLECTION)
    p.add_argument("--parent", default=PARENT, help="key of the collection it sits under (default Fisheries)")
    p.add_argument("--members", help="default data/<collection>_members.csv")
    p.add_argument("--additions", help="default data/<collection>_additions.csv, when it exists")
    p.add_argument("--dry-run", action="store_true")
    a = p.parse_args()
    COLLECTION, PARENT = a.collection, a.parent
    data_dir = os.path.join(HERE, "..", "data")
    if not a.members:
        a.members = os.path.join(data_dir, f"{COLLECTION}_members.csv")
    if not a.additions:
        default = os.path.join(data_dir, f"{COLLECTION}_additions.csv")
        a.additions = default if os.path.exists(default) else None
    dry = a.dry_run
    con = db()
    group_lib = con.execute("SELECT libraryID FROM groups WHERE groupID = ?", (int(z.GROUP),)).fetchone()[0]
    coll, how = find_collection(dry)
    print(f"collection {COLLECTION} ({coll or '-'}) under {PARENT}: {how}", flush=True)

    tally = {}
    members = list(csv.DictReader(open(a.members, newline="", encoding="utf-8")))
    for m in members:
        key = m["citation_key"].strip()
        try:
            steps, status = do_member(con, key, group_lib, coll, dry, (m.get("pdf") or "").strip())
        except Exception as e:                      # one member must not abort the batch
            steps, status = [f"ERROR {type(e).__name__}"], f"ERROR {type(e).__name__}: {e}"
        print(f"  {key}: {status}", flush=True)
        for step in (steps or [status]):
            word = step.split(" ")[0].split(":")[0]
            tally[word] = tally.get(word, 0) + 1
    adds = list(csv.DictReader(open(a.additions, newline="", encoding="utf-8"))) if a.additions else []
    for row in adds:
        label = row["DOI"] or row["title"][:60]
        try:
            steps, status = do_addition(row, coll, dry)
        except Exception as e:
            steps, status = [f"ERROR {type(e).__name__}"], f"ERROR {type(e).__name__}: {e}"
        print(f"  + {label}: {status}", flush=True)
        for step in steps:
            word = step.split(" ")[0].split(":")[0]
            tally[word] = tally.get(word, 0) + 1
    print(f"\n{len(members)} members, {len(adds)} additions | "
          + " | ".join(f"{k} {v}" for k, v in sorted(tally.items())))
    # Upper-case steps are failures (a write that did not land, a key that does not
    # resolve). `no-pdf` is a state, not a failure: the store simply lacks that item.
    bad = [k for k in tally if k.isupper()]
    if bad:
        sys.exit(f"problems: {', '.join(bad)}")


def do_member(con, key, group_lib, coll, dry, pdf=""):
    """Bring one member into the collection; `pdf` is the row's own PDF source, used
    when no local library holds one. -> (steps, printed status)."""
    hits = local_items(con, key)
    group = [h for h in hits if h[0] == group_lib]
    steps, gkey = [], None
    if len(group) > 1:
        status = f"AMBIGUOUS: {len(group)} group items carry this key ({', '.join(h[2] for h in group)})"
    elif not hits:
        status = "MISSING: key in no local library"
    else:
        if group:
            gkey = group[0][2]
        else:
            src = hits[0]
            body = item_json(con, src[1], coll)
            gkey = group_copy(body)
            if gkey:
                steps.append("copy exists")
            elif dry:
                steps.append(f"would copy from library {src[0]}")
            else:
                st, bd = z.api("POST", f"{z.BASE}/items", data=[body],
                               headers={"Content-Type": "application/json", "Zotero-Write-Token": z.tok()})
                try:
                    gkey = json.loads(bd)["successful"]["0"]["key"]
                    steps.append(f"copied from library {src[0]}")
                except Exception:
                    steps.append(f"COPY-FAIL {st} {bd[:160]!r}")
        if gkey:
            want = title_of(con, group[0][1]) if group else title_of(con, hits[0][1])
            local = lambda: local_pdf(con, [h[1] for h in hits if same_work(title_of(con, h[1]), want)])
            find = (lambda: local() or addition_pdf({"pdf": pdf})) if pdf else local
            steps += ensure(gkey, coll, dry, find, required=bool(pdf))
        status = f"{gkey or '-'} | " + ", ".join(steps)
    return steps, status


if __name__ == "__main__":
    main()
