#!/usr/bin/env python3
"""
data-raw/zotero_library_triage.py
---------------------------------------------------------------------------
Record, for each item the five satellite group libraries hold, whether the central
NewGraphEnvironment group library (group 4733734) already has it, and what was decided
for each one it does not (#13).

WHY: the central library is the single source (CLAUDE.md, "One Zotero library is the
source"). Five other group libraries are dormant, and before they can be retired every
item in them that the central library lacks has to be merged into it or let go. #13's
first count matched titles only, which reads case, punctuation and subtitle drift as
"missing"; this script matches on the strongest evidence first:
  pdf_md5       a live PDF of the item has the same bytes (storageHash) as a live
                central PDF, the item's own or a standalone one
  doi           the same DOI (case and any https://doi.org/ prefix ignored)
  title         the same title, lower case with everything but letters and digits removed
  title_prefix  the same title before its first colon, or its first 60 such characters
A row it matches is `present`. A row it does not match keeps whatever verdict and reason
the file already holds for it (group_id + item_key), so a decision made by hand survives a
re-run: `present` (under another title; library9_key names the copy), `merge` (copy it
into the central library) or `discard` (let it go with the library). A row no longer in
the libraries drops out.

The tracked file carries Zotero ids only. A satellite library's name, and the titles of
its items, can name a client or a project, which nothing tracked here may (CLAUDE.md, "One
discipline"); --titles prints them to the terminal for the review, and nowhere else.

INPUT   ~/Zotero/zotero.sqlite, read through 0270's guarded copy (db()), so a commit still
        in zotero.sqlite-wal is seen (#127)
        data/zotero_library_triage.csv, for the verdicts already decided, if it exists
OUTPUT  data/zotero_library_triage.csv: group_id, item_key, item_type, pdfs, match_kind,
        library9_key, verdict, reason; one row per live top-level item (notes and
        annotations aside), sorted by group_id and item_key
        a count per library, match kind and verdict on stdout
        --check writes nothing and exits 1 when the file differs from what a run would write
---------------------------------------------------------------------------
"""
import argparse, csv, importlib.util, io, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
# 0270 loads 0153, which reads a Web API key when it loads and exits without one. This script
# makes no Web API call, so a placeholder stands in where no key is set (any call would be refused).
os.environ.setdefault("ZOTERO_API_KEY", "none: data-raw/zotero_library_triage.py reads only the local database")
_spec = importlib.util.spec_from_file_location("z0270", os.path.join(ROOT, "scripts", "0270-habitat-collection-build.py"))
z = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(z)          # 0270 has a __main__ guard; this only defines helpers

CENTRAL = 4733734
OUT = os.path.join(ROOT, "data", "zotero_library_triage.csv")
COLS = ["group_id", "item_key", "item_type", "pdfs", "match_kind", "library9_key", "verdict", "reason"]
VERDICTS = {"present", "merge", "discard"}


def norm(s):
    return re.sub(r"[^a-z0-9]", "", (s or "").lower())


def prefix(s):
    return norm((s or "").split(":")[0])[:60]


def doi(s):
    s = (s or "").strip().lower()
    return re.sub(r"^(https?://(dx\.)?doi\.org/|doi:\s*)", "", s)


def items(con, lib):
    """Live top-level items of one library: key, type, title, DOI and the md5 of each live PDF.

    A standalone attachment is its own row, and its own file is its PDF."""
    rows = con.execute("""
        SELECT i.itemID, i.key, t.typeName,
          (SELECT v.value FROM itemData d JOIN itemDataValues v ON v.valueID = d.valueID
             JOIN fields f ON f.fieldID = d.fieldID WHERE d.itemID = i.itemID AND f.fieldName = 'title'),
          (SELECT v.value FROM itemData d JOIN itemDataValues v ON v.valueID = d.valueID
             JOIN fields f ON f.fieldID = d.fieldID WHERE d.itemID = i.itemID AND f.fieldName = 'DOI')
        FROM items i
        JOIN itemTypes t ON t.itemTypeID = i.itemTypeID
        LEFT JOIN itemAttachments self ON self.itemID = i.itemID
        LEFT JOIN deletedItems di ON di.itemID = i.itemID
        WHERE i.libraryID = ? AND di.itemID IS NULL
          AND t.typeName NOT IN ('note', 'annotation')
          AND (t.typeName <> 'attachment' OR self.parentItemID IS NULL)
        ORDER BY i.key""", (lib,)).fetchall()
    pdf = {}
    for item_id, h in con.execute("""
        SELECT COALESCE(ia.parentItemID, ia.itemID), ia.storageHash
        FROM itemAttachments ia
        JOIN items a ON a.itemID = ia.itemID
        LEFT JOIN deletedItems da ON da.itemID = ia.itemID
        WHERE a.libraryID = ? AND da.itemID IS NULL
          AND ia.contentType = 'application/pdf' AND ia.storageHash IS NOT NULL""", (lib,)):
        pdf.setdefault(item_id, set()).add(h)
    return [dict(key=k, type=t, title=ti, doi=doi(d), pdf=sorted(pdf.get(i, ())))
            for i, k, t, ti, d in rows]


def index(central):
    """Lookups into the central library: each kind of evidence -> the sorted keys holding it."""
    idx = {"pdf_md5": {}, "doi": {}, "title": {}, "title_prefix": {}}
    for it in central:
        for h in it["pdf"]:
            idx["pdf_md5"].setdefault(h, set()).add(it["key"])
        if it["doi"]:
            idx["doi"].setdefault(it["doi"], set()).add(it["key"])
        if norm(it["title"]):
            idx["title"].setdefault(norm(it["title"]), set()).add(it["key"])
        if prefix(it["title"]):
            idx["title_prefix"].setdefault(prefix(it["title"]), set()).add(it["key"])
    return idx


def match(it, idx):
    """The strongest evidence that the central library holds this item, and the copy it names."""
    tries = [("pdf_md5", h) for h in it["pdf"]] + [("doi", it["doi"]), ("title", norm(it["title"])),
                                                   ("title_prefix", prefix(it["title"]))]
    for kind, value in tries:
        if value and value in idx[kind]:
            return kind, sorted(idx[kind][value])[0]
    return "none", ""


def render(rows):
    buf = io.StringIO()
    w = csv.DictWriter(buf, fieldnames=COLS, lineterminator="\n")
    w.writeheader()
    w.writerows(rows)
    return buf.getvalue()


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[3])
    ap.add_argument("--titles", action="store_true", help="print each unmatched item's title (terminal only)")
    ap.add_argument("--check", action="store_true", help="write nothing; exit 1 if the file is out of date")
    args = ap.parse_args()

    prior = {}
    if os.path.exists(OUT):
        with open(OUT, newline="") as f:
            for r in csv.DictReader(f):
                prior[(r["group_id"], r["item_key"])] = r

    con = z.db()
    libs = con.execute("SELECT groupID, libraryID FROM groups ORDER BY groupID").fetchall()
    lib_of = dict(libs)
    if CENTRAL not in lib_of:
        sys.exit(f"group {CENTRAL} is not in this Zotero database")
    idx = index(items(con, lib_of[CENTRAL]))

    rows, titles = [], []
    for gid, lib in libs:
        if gid == CENTRAL:
            continue
        for it in items(con, lib):
            kind, k9 = match(it, idx)
            old = prior.get((str(gid), it["key"]), {})
            if kind != "none":
                verdict, reason = "present", f"matched by {kind}"
            else:
                verdict, reason = old.get("verdict", ""), old.get("reason", "")
                if old.get("library9_key"):
                    k9 = old["library9_key"]
                titles.append((gid, it["key"], it["type"], len(it["pdf"]), it["title"] or ""))
            if verdict and verdict not in VERDICTS:
                sys.exit(f"{gid} {it['key']}: verdict '{verdict}' is not one of {sorted(VERDICTS)}")
            rows.append(dict(group_id=gid, item_key=it["key"], item_type=it["type"], pdfs=len(it["pdf"]),
                             match_kind=kind, library9_key=k9, verdict=verdict, reason=reason))
    rows.sort(key=lambda r: (int(r["group_id"]), r["item_key"]))

    out = render(rows)
    counts = {}
    for r in rows:
        k = (r["group_id"], r["match_kind"], r["verdict"] or "undecided")
        counts[k] = counts.get(k, 0) + 1
    for (gid, kind, verdict), n in sorted(counts.items()):
        print(f"{gid}\t{kind}\t{verdict}\t{n}")
    print(f"{len(rows)} items in {len(libs) - 1} libraries; "
          f"{sum(r['match_kind'] == 'none' for r in rows)} unmatched, "
          f"{sum(not r['verdict'] for r in rows)} undecided")
    if args.titles:
        for gid, key, typ, n, title in titles:
            print(f"  {gid} {key} {typ} pdfs={n}  {title}")

    current = open(OUT).read() if os.path.exists(OUT) else ""
    if args.check:
        if current != out:
            sys.exit(f"{os.path.relpath(OUT, ROOT)} is out of date: run without --check")
        print(f"{os.path.relpath(OUT, ROOT)} is current")
        return
    if current != out:
        with open(OUT, "w") as f:
            f.write(out)
        print(f"wrote {os.path.relpath(OUT, ROOT)}")
    else:
        print(f"{os.path.relpath(OUT, ROOT)} unchanged")


if __name__ == "__main__":
    main()
