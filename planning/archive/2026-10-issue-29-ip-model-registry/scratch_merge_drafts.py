#!/usr/bin/env python3
"""merge_drafts.py FAM[,FAM...] OUTDIR [--into-repo]
Merge planning/active/draft-<fam>-{tags,evidence,registry}.csv onto the committed tables.
Writes OUTDIR/evidence.csv and OUTDIR/registry.csv. Refuses a tag on a row already tagged differently,
a tag on a 'none' row, and draft headers that differ from the committed ones."""
import csv, io, os, sys
REPO = "/Users/airvine/Projects/repo/knowledge"
fams, out = sys.argv[1].split(","), sys.argv[2]
def read(p):
    with open(p, encoding="utf-8", newline="") as f:
        r = list(csv.reader(f))
    return r[0], r[1:]
eh, ev = read(f"{REPO}/data/literature_evidence.csv")
rh, rg = read(f"{REPO}/data/ip_model_registry.csv")
mi, ki = eh.index("model_id"), eh.index("kind")
for fam in fams:
    base = f"{REPO}/planning/active/draft-{fam}"
    if os.path.exists(base + "-tags.csv"):
        th, tags = read(base + "-tags.csv")
        assert th == ["data_row", "model_id"], f"{fam} tags header {th}"
        for dr, mid in tags:
            row = ev[int(dr) - 1]
            if row[ki] == "none": sys.exit(f"{fam}: data_row {dr} is a none row")
            if row[mi] and row[mi] != mid: sys.exit(f"{fam}: data_row {dr} already tagged {row[mi]}")
            row[mi] = mid
    for name, head, rows in (("evidence", eh, ev), ("registry", rh, rg)):
        p = f"{base}-{name}.csv"
        if os.path.exists(p):
            h, new = read(p)
            if h != head: sys.exit(f"{fam} {name} header differs from the committed one")
            rows.extend(r for r in new if any(c.strip() for c in r))
os.makedirs(out, exist_ok=True)
for name, head, rows in (("evidence", eh, ev), ("registry", rh, rg)):
    with open(os.path.join(out, name + ".csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f, lineterminator="\n"); w.writerow(head); w.writerows(rows)
print(f"evidence {len(ev)} rows, registry {len(rg)} rows -> {out}")
