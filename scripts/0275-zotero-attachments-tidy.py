#!/usr/bin/env python3
"""
scripts/0275-zotero-attachments-tidy.py
---------------------------------------------------------------------------
Put the group library's attachments right, one decided row at a time, so each
item carries the one document it cites (#126) and the sturgeon items carry what
their sources say (#151).

WHY: a Zotero item with several PDFs is read by whichever one Zotero ranks first:
cred's citation audit takes the URL-matched or oldest PDF, which for
finsconsultingltd_2001Reconnaissance1 is a map sheet, and a store holds the
report and its appendices as separate documents. Each row of the verdicts file
records what was decided for one item, and this script carries it out through
the Web API. The verdicts are the record: re-running it changes nothing that is
already as decided.

ACTIONS (data/zotero_attachment_verdicts.csv, applied in file order)
  merge        `attachments` in reading order -> one PDF named `file` on `item`
               (each part downloaded and checked against its md5, joined with
               qpdf --deterministic-id), then the parts trashed
  keep         the first of `attachments` stays, the rest are trashed
  split        the one attachment in `attachments` moves to a new item made from
               `fields` (JSON: itemType, title, creators "Last, First; ...",
               creatorType when not author, date and any other field), in `item`'s
               collections
  relabel      PATCH `fields` (JSON) onto the one attachment in `attachments`
  patch        PATCH `fields` (JSON) onto `item`
  replace      upload the local file `file` (path from the repo root) to `item`,
               then trash the one attachment in `attachments`
  merge-items  `item` takes the place of `attachments` (an item or a standalone
               attachment): it joins that one's collections, records
               dc:replaces, and the other is trashed

DONE means the end state holds, not that the row ran: a merge is done when every
part is trashed and `item` has one live attachment named `file`, so a re-run
after a crash between upload and trash finishes the row rather than uploading
again. A trashed attachment with a file on the server stays recoverable from the
Zotero trash until the trash is emptied.

INPUT   data/zotero_attachment_verdicts.csv
        ZOTERO_API_KEY, or the file ZOTERO_API_KEY_FILE names (0153's api_key()); group 4733734
        qpdf on PATH for merge
OUTPUT  Zotero writes only; one status line per row, and the attachment keys
        added and trashed (for finding the stores to update, 0150 ACTION=update).
        --dry-run does every read and no write.
---------------------------------------------------------------------------
"""
import argparse, csv, hashlib, importlib.util, json, os, subprocess, sys, tempfile, urllib.parse, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("z0153", os.path.join(HERE, "0153-reports-to-zotero.py"))
z = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(z)          # 0153 has a __main__ guard; this only defines helpers

ROOT = os.path.normpath(os.path.join(HERE, ".."))
ACTIONS = {"merge", "keep", "split", "relabel", "patch", "replace", "merge-items"}
URI = f"http://zotero.org/groups/{z.GROUP}/items/"
added, trashed = [], []


def get(key):
    st, bd = z.api("GET", f"{z.BASE}/items/{key}?format=json&include=data")
    if st != 200:
        raise RuntimeError(f"GET {key} -> {st} {bd[:200]!r}")
    return json.loads(bd)["data"]


def children(key):
    st, bd = z.api("GET", f"{z.BASE}/items/{key}/children?format=json&include=data&limit=100")
    if st != 200:
        raise RuntimeError(f"GET {key}/children -> {st} {bd[:200]!r}")
    return [c["data"] for c in json.loads(bd) if c["data"]["itemType"] == "attachment"]


def patch(key, fields):
    d = get(key)
    st, bd = z.api("PATCH", f"{z.BASE}/items/{key}", data=fields,
                   headers={"Content-Type": "application/json", "If-Unmodified-Since-Version": str(d["version"])})
    if st != 204:
        raise RuntimeError(f"PATCH {key} -> {st} {bd[:200]!r}")


def trash(key):
    if not get(key).get("deleted"):
        patch(key, {"deleted": 1})
        trashed.append(key)


def live(key):
    return not get(key).get("deleted")


def download(att):
    """The attachment's file, checked against the md5 the server holds for it."""
    d = get(att)
    if not d.get("md5"):
        raise RuntimeError(f"{att} has no file on the server")
    req = urllib.request.Request(f"{z.BASE}/items/{att}/file", headers={"Zotero-API-Key": z.API})
    data = urllib.request.urlopen(req, timeout=900).read()
    if hashlib.md5(data).hexdigest() != d["md5"]:
        raise RuntimeError(f"{att}: the download's md5 is not the server's")
    return data


def upload(item, data, fname):
    st = z.upload(item, data, fname)
    if st not in ("uploaded", "exists"):
        raise RuntimeError(f"upload of {fname} to {item}: {st}")
    new = [c["key"] for c in children(item) if c.get("filename") == fname and not c.get("deleted")]
    added.extend(new)
    return st


def creators(s, role="author"):
    out = []
    for name in filter(None, (x.strip() for x in s.split(";"))):
        if "," in name:
            last, first = (p.strip() for p in name.split(",", 1))
            out.append({"creatorType": role, "lastName": last, "firstName": first})
        else:
            out.append({"creatorType": role, "name": name})
    return out


def do_merge(row, parts, dry):
    named = [c for c in children(row["item"]) if c.get("filename") == row["file"] and not c.get("deleted")]
    left = [a for a in parts if live(a)]
    if len(named) == 1 and not left:
        return "done"
    if len(named) > 1:
        raise RuntimeError(f"{len(named)} live attachments named {row['file']}: trash all but one by hand")
    if dry:
        return (f"would merge {len(parts)} parts into {row['file']}" if not named
                else f"would trash {len(left)} parts (merged file present)")
    if not named:
        with tempfile.TemporaryDirectory() as td:
            paths = []
            for i, a in enumerate(parts):
                p = os.path.join(td, f"{i:02d}.pdf")
                with open(p, "wb") as f:
                    f.write(download(a))
                paths.append(p)
            out = os.path.join(td, "merged.pdf")
            subprocess.run(["qpdf", "--deterministic-id", "--empty", "--pages", *paths, "--", out], check=True)
            with open(out, "rb") as f:
                upload(row["item"], f.read(), row["file"])
    for a in left:
        trash(a)
    return f"merged {len(parts)} parts into {row['file']}"


def do_keep(row, atts, dry):
    gone = [a for a in atts[1:] if live(a)]
    if not live(atts[0]):
        raise RuntimeError(f"the copy to keep, {atts[0]}, is in the trash")
    if not gone:
        return "done"
    if dry:
        return f"would keep {atts[0]} and trash {', '.join(gone)}"
    for a in gone:
        trash(a)
    return f"kept {atts[0]}, trashed {', '.join(gone)}"


def do_split(row, atts, fields, dry):
    att = get(atts[0])
    if att.get("parentItem") and att["parentItem"] != row["item"]:
        return "done"
    if dry:
        return f"would move {atts[0]} to a new {fields.get('itemType')} '{fields.get('title', '')[:50]}'"
    parent = get(row["item"])
    marker = f"Split from {row['item']}, attachment {atts[0]} (0275, #126)"
    body = dict(fields)
    body["creators"] = creators(body.get("creators", ""), body.pop("creatorType", "author"))
    body["collections"] = parent.get("collections", [])
    body["extra"] = "\n".join(filter(None, [body.get("extra", ""), marker]))
    # a new item from an earlier run that stopped before the move
    st, bd = z.api("GET", f"{z.BASE}/items?q={urllib.parse.quote(fields['title'][:60])}&format=json&include=data")
    found = [h["key"] for h in json.loads(bd)
             if st == 200 and marker in h["data"].get("extra", "") and not h["data"].get("deleted")]
    if found:
        new = found[0]
    else:
        st, bd = z.api("POST", f"{z.BASE}/items", data=[body],
                       headers={"Content-Type": "application/json", "Zotero-Write-Token": z.tok()})
        try:
            new = json.loads(bd)["successful"]["0"]["key"]
        except Exception:
            raise RuntimeError(f"creating the item for {atts[0]} -> {st} {bd[:300]!r}")
    patch(atts[0], {"parentItem": new})
    return f"moved {atts[0]} to new item {new}"


def do_relabel(row, atts, fields, dry):
    att = get(atts[0])
    if all(att.get(k) == v for k, v in fields.items()):
        return "done"
    if dry:
        return f"would set {fields} on {atts[0]}"
    patch(atts[0], fields)
    return f"set {fields} on {atts[0]}"


def do_patch(row, fields, dry):
    item = get(row["item"])
    if all(item.get(k) == v for k, v in fields.items()):
        return "done"
    if dry:
        return "would set " + "; ".join(f"{k}: {item.get(k)!r} -> {v!r}" for k, v in fields.items())
    patch(row["item"], fields)
    return f"set {', '.join(fields)}"


def do_replace(row, atts, dry):
    named = [c for c in children(row["item"]) if c.get("filename") == os.path.basename(row["file"])
             and not c.get("deleted")]
    if named and not live(atts[0]):
        return "done"
    path = os.path.join(ROOT, row["file"])
    if not named and not os.path.isfile(path):
        raise RuntimeError(f"{row['file']} is not here to upload")
    if dry:
        return f"would upload {row['file']} and trash {atts[0]}" if not named else f"would trash {atts[0]}"
    if not named:
        with open(path, "rb") as f:
            upload(row["item"], f.read(), os.path.basename(row["file"]))
    trash(atts[0])
    return f"replaced {atts[0]} with {os.path.basename(row['file'])}"


def do_merge_items(row, atts, dry):
    keep, other = get(row["item"]), get(atts[0])
    rel = keep.get("relations", {}) or {}
    replaces = rel.get("dc:replaces", [])
    replaces = [replaces] if isinstance(replaces, str) else list(replaces)
    colls = sorted(set(keep.get("collections", [])) | set(other.get("collections", [])))
    need_rel, need_coll = URI + atts[0] not in replaces, colls != sorted(keep.get("collections", []))
    if not need_rel and not need_coll and other.get("deleted"):
        return "done"
    if dry:
        return (f"would add {row['item']} to {sorted(set(colls) - set(keep.get('collections', [])))}, record "
                f"dc:replaces {atts[0]} and trash it")
    if need_rel or need_coll:
        patch(row["item"], {"collections": colls,
                            "relations": {**rel, "dc:replaces": sorted(set(replaces) | {URI + atts[0]})}})
    trash(atts[0])
    return f"{row['item']} replaces {atts[0]}"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--verdicts", default=os.path.join(ROOT, "data", "zotero_attachment_verdicts.csv"))
    p.add_argument("--only", help="comma-separated item keys: act on these rows alone")
    p.add_argument("--dry-run", action="store_true")
    a = p.parse_args()
    with open(a.verdicts, newline="", encoding="utf-8") as f:
        rows = list(csv.DictReader(f))
    bad = [r["item"] for r in rows if r["action"] not in ACTIONS]
    if bad:
        sys.exit(f"unknown action on rows for {', '.join(bad)}")
    only = set(a.only.split(",")) if a.only else None
    todo, failed = 0, 0
    for r in rows:
        if only and r["item"] not in only:
            continue
        atts = [x for x in r["attachments"].split(";") if x]
        fields = json.loads(r["fields"]) if r["fields"].strip() else {}
        try:
            act = r["action"]
            st = (do_merge(r, atts, a.dry_run) if act == "merge" else
                  do_keep(r, atts, a.dry_run) if act == "keep" else
                  do_split(r, atts, fields, a.dry_run) if act == "split" else
                  do_relabel(r, atts, fields, a.dry_run) if act == "relabel" else
                  do_patch(r, fields, a.dry_run) if act == "patch" else
                  do_replace(r, atts, a.dry_run) if act == "replace" else
                  do_merge_items(r, atts, a.dry_run))
        except Exception as e:
            st, failed = f"FAILED: {e}", failed + 1
        todo += st != "done"
        print(f"{r['item']} {r['citation_key']:<50} {r['action']:<11} {st}", flush=True)
    print(f"\n{len(rows) if not only else len(only)} rows; {todo} not done{' (dry run)' if a.dry_run else ''}; "
          f"{failed} failed")
    if added or trashed:
        print("attachments added:   " + " ".join(added))
        print("attachments trashed: " + " ".join(trashed))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
