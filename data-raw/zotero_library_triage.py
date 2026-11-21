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
  title_prefix  the same title before its first colon, or its first 60 such characters,
                where that prefix is at least 20 characters (a shorter one joins unrelated
                works: `1`, `http`)
decided_by says who decided each row, so a re-run never has to guess it. A `script` row is
rewritten in full every run: `present`, "matched by <kind>" where it matches, undecided
where it does not (so a verdict never outlives its evidence); the script refuses a `script`
row whose verdict or reason someone edited. To decide a row, set decided_by to `hand` and
write the verdict and reason: a `hand` row keeps them on every run, matched or not, so a
wrong match can be overridden. Hand verdicts: `present` (under another title; library9_key
must name the copy, a live central item), `merge` (copy it into the central library) or
`discard` (let it go with the library); on a hand `merge` or `discard` row library9_key is
the script's current match, for reference. A row no longer in the libraries drops out.

`present` says the central library holds a record of the work, not that it holds the
satellite's file. central_file says that, over every stored file of the item (any type):
`same` (every one has a central file with the same bytes), `part` (some do, some do not),
`other` (none does, and a central item the row matched or names holds a file with other
bytes), `none` (none
does, and the central copy holds no file) or blank (the item holds no file). Anything but
`same` and blank is a file retiring the library would delete: carried over, or decided the
same document, first.

The tracked file carries Zotero ids only. A satellite library's name, and the titles of
its items, can name a client or a project, which nothing tracked here may (CLAUDE.md, "One
discipline"); --titles prints them to the terminal for the review, and nowhere else.

INPUT   ~/Zotero/zotero.sqlite, read through 0270's guarded copy (db()), so a commit still
        in zotero.sqlite-wal is seen (#127)
        data/zotero_library_triage.csv, for the verdicts already decided, if it exists
OUTPUT  data/zotero_library_triage.csv: group_id, item_key, item_type, pdfs, match_kind,
        library9_key, central_file, decided_by, verdict, reason; one row per live top-level item (notes and
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
# An exported empty key reads to 0153 as no key, so test the value, not whether it is set.
if not os.environ.get("ZOTERO_API_KEY", "").strip():
    os.environ["ZOTERO_API_KEY"] = "none: data-raw/zotero_library_triage.py reads only the local database"
_spec = importlib.util.spec_from_file_location("z0270", os.path.join(ROOT, "scripts", "0270-habitat-collection-build.py"))
z = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(z)          # 0270 has a __main__ guard; this only defines helpers

CENTRAL = 4733734
OUT = os.path.join(ROOT, "data", "zotero_library_triage.csv")
COLS = ["group_id", "item_key", "item_type", "pdfs", "match_kind", "library9_key", "central_file", "decided_by",
        "verdict", "reason"]
AUTO = re.compile(r"matched by (pdf_md5|doi|title|title_prefix)")
PREFIX_MIN = 20
VERDICTS = {"present", "merge", "discard"}


def norm(s):
    return re.sub(r"[^a-z0-9]", "", (s or "").lower())


def prefix(s):
    p = norm((s or "").split(":")[0])[:60]
    return p if len(p) >= PREFIX_MIN else ""


def doi(s):
    s = (s or "").strip().lower()
    return re.sub(r"^(https?://(dx\.)?doi\.org/|doi:\s*)", "", s)


def items(con, lib):
    """Live top-level items of one library: key, type, title, DOI, the md5 of each live PDF, and
    the md5 of each live stored file of any type.

    A standalone attachment is its own row, and its own file is its PDF (or its file)."""
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
    pdf, files = {}, {}
    for item_id, h, ctype in con.execute("""
        SELECT COALESCE(ia.parentItemID, ia.itemID), ia.storageHash, ia.contentType
        FROM itemAttachments ia
        JOIN items a ON a.itemID = ia.itemID
        LEFT JOIN deletedItems da ON da.itemID = ia.itemID
        WHERE a.libraryID = ? AND da.itemID IS NULL AND ia.storageHash IS NOT NULL""", (lib,)):
        files.setdefault(item_id, set()).add(h)
        if ctype == "application/pdf":
            pdf.setdefault(item_id, set()).add(h)
    return [dict(key=k, type=t, title=ti, doi=doi(d), pdf=sorted(pdf.get(i, ())), files=sorted(files.get(i, ())))
            for i, k, t, ti, d in rows]


def index(central):
    """Lookups into the central library: each kind of evidence -> the sorted keys holding it."""
    idx = {"pdf_md5": {}, "doi": {}, "title": {}, "title_prefix": {},
           "keys": set(), "files": set(), "with_file": set()}
    for it in central:
        idx["keys"].add(it["key"])
        idx["files"].update(it["files"])
        if it["files"]:
            idx["with_file"].add(it["key"])
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
    """The strongest evidence that the central library holds this item, the copy it names and
    every central item holding that evidence (duplicates in the central library share it).

    The copy named is one holding a file where any does, then the first key in order, so the
    choice does not rest on key order alone."""
    tries = [("pdf_md5", h) for h in it["pdf"]] + [("doi", it["doi"]), ("title", norm(it["title"])),
                                                   ("title_prefix", prefix(it["title"]))]
    for kind, value in tries:
        if value and value in idx[kind]:
            cands = sorted(idx[kind][value], key=lambda k: (k not in idx["with_file"], k))
            return kind, cands[0], cands
    return "none", "", []


def central_file(it, cands, idx):
    """Whether the central library holds this item's file: same, part, other, none, or blank (no
    file). `other` and `none` are judged over every central item the row names or matched."""
    if not it["files"]:
        return ""
    held = [h in idx["files"] for h in it["files"]]
    if all(held):
        return "same"
    if any(held):
        return "part"
    return "other" if any(k in idx["with_file"] for k in cands) else "none"


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
                k = (r["group_id"], r["item_key"])
                # Two rows for one item (a merge conflict kept both sides) would let the last one win
                # and drop the other's decision; refuse.
                if k in prior:
                    sys.exit(f"{' '.join(k)} has two rows in {os.path.relpath(OUT, ROOT)}; keep one")
                prior[k] = r

    con = z.db()
    libs = con.execute("SELECT groupID, libraryID FROM groups ORDER BY groupID").fetchall()
    lib_of = dict(libs)
    if CENTRAL not in lib_of:
        sys.exit(f"group {CENTRAL} is not in this Zotero database")
    # A satellite group this database lacks (not synced here, or left) would drop every row and hand
    # verdict of it from the file; refuse instead.
    gone = sorted({g for g, _ in prior} - {str(g) for g in lib_of})
    if gone:
        sys.exit(f"group(s) {', '.join(gone)} hold rows in {os.path.relpath(OUT, ROOT)} but are not in this "
                 "Zotero database: sync them here, or remove their rows by hand if they are retired")
    idx = index(items(con, lib_of[CENTRAL]))

    rows, titles = [], []
    for gid, lib in libs:
        if gid == CENTRAL:
            continue
        for it in items(con, lib):
            kind, k9, cands = match(it, idx)
            old = prior.get((str(gid), it["key"]), {})
            who = old.get("decided_by", "script") or "script"
            if who not in ("script", "hand"):
                sys.exit(f"{gid} {it['key']}: decided_by '{who}' is not script or hand")
            if who == "hand":
                verdict, reason = old.get("verdict", ""), old.get("reason", "")
                if not verdict:
                    sys.exit(f"{gid} {it['key']}: a hand row has no verdict; write one, or set decided_by to "
                             "script to let the script decide it")
                if verdict == "present":
                    k9 = old.get("library9_key", "")
                    if not k9:
                        sys.exit(f"{gid} {it['key']}: a hand `present` names no library9_key")
                    if k9 not in idx["keys"]:
                        sys.exit(f"{gid} {it['key']}: library9_key {k9} is not a live item of the central "
                                 "library; decide the row again")
                    cands = sorted(set(cands) | {k9})
            else:
                # A script row as the script writes it: the automatic pair, or undecided. Anything
                # else is an edit made without marking the row as decided by hand.
                ov, orr = old.get("verdict", ""), old.get("reason", "")
                if old and not ((ov, orr) == ("", "") or (ov == "present" and AUTO.fullmatch(orr))):
                    sys.exit(f"{gid} {it['key']}: a script row's verdict or reason was edited "
                             f"('{ov}', '{orr}'); set decided_by to hand to keep it")
                verdict, reason = ("present", f"matched by {kind}") if kind != "none" else ("", "")
            if kind == "none":
                titles.append((gid, it["key"], it["type"], len(it["pdf"]), it["title"] or ""))
            if verdict and verdict not in VERDICTS:
                sys.exit(f"{gid} {it['key']}: verdict '{verdict}' is not one of {sorted(VERDICTS)}")
            rows.append(dict(group_id=gid, item_key=it["key"], item_type=it["type"], pdfs=len(it["pdf"]),
                             match_kind=kind, library9_key=k9, central_file=central_file(it, cands, idx),
                             decided_by=who, verdict=verdict, reason=reason))
    rows.sort(key=lambda r: (int(r["group_id"]), r["item_key"]))

    out = render(rows)
    counts = {}
    for r in rows:
        k = (r["group_id"], r["match_kind"], r["verdict"] or "undecided")
        counts[k] = counts.get(k, 0) + 1
    for (gid, kind, verdict), n in sorted(counts.items()):
        print(f"{gid}\t{kind}\t{verdict}\t{n}")
    print(f"{sum(r['verdict'] == 'present' and r['central_file'] not in ('same', '') for r in rows)} `present` "
          "items hold a file the central library has no copy of (central_file part, other or none)")
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
