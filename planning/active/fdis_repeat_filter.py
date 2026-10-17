"""Drop #35's repeated-survey copies from the FDIS visit tables built before #35.

fresh_default was being rewritten by a provincial link run (2026-10-17), so 0290, 0294 and 0296
could not be rebuilt against the schema they were built on. Each gives a visit its own row,
independent of other visits, so removing the copies 0230 now drops equals a rebuild. Lines are
kept as written; `dup_of` (the second column of ch_mad_visits and ch_rule_visits, ids only) is
removed, and walks are kept for the starts that still have a visit. Where 0230 moved a dropped
copy's habitat to the copy kept (`habitat_carried`), the kept row's habitat columns are taken from
the new fdis_sites.csv, as a rebuild would.

usage: python3 -I fdis_repeat_filter.py <dir with the pre-#35 tables> <log path>
(run from the repo root; writes data/fdis/derived/*.csv)
"""
import csv
import io
import sys

src, log_path = sys.argv[1], sys.argv[2]
dst = "data/fdis/derived"
with open("data/fdis_repeat_surveys.csv", newline="") as f:
    rmap = list(csv.DictReader(f))
dropped = {r["site_visit"] for r in rmap if r["status"] == "dropped"}
carried = {r["kept_site_visit"] for r in rmap if r["habitat_carried"] == "TRUE"}
cols_habitat = ["habitat_rows", "habitat_conflict", "gradient_pct", "gradient2_pct", "channel_width_m",
                "wetted_width_m", "n_cw_measures", "water_temp_c", "bed_dominant", "grad_sentinel",
                "cw_sentinel", "has_habitat"]
with open("data/fdis/derived/fdis_sites.csv", newline="") as f:
    sites_new = {r["site_visit"]: r for r in csv.DictReader(f)}
kept_all = set(sites_new)
assert not dropped & kept_all, "a dropped copy is still in fdis_sites.csv"
log = [f"#35 repeat filter: {len(dropped)} copies dropped by 0230 (data/fdis_repeat_surveys.csv)."]


def rows(path):
    with open(path, newline="") as f:
        lines = f.read().splitlines(keepends=True)
    parsed = list(csv.reader(io.StringIO("".join(lines))))
    assert len(parsed) == len(lines), f"{path}: a field spans lines"
    return lines, parsed


starts = set()
n_carried = {}
for tb in ["bt_use_visits", "ch_mad_visits", "ch_rule_visits"]:
    lines, parsed = rows(f"{src}/{tb}.csv")
    head = parsed[0]
    assert head[0] == "site_visit"
    drop_col = len(head) > 1 and head[1] == "dup_of"
    out = []
    for line, rec in zip(lines, parsed):
        if rec[0] in dropped:
            continue
        assert rec is head or rec[0] in kept_all, f"{tb}: {rec[0]} is not in fdis_sites.csv"
        if rec is not head and rec[0] in carried:
            for c in cols_habitat:
                if c in head:
                    rec[head.index(c)] = sites_new[rec[0]][c]
            buf = io.StringIO()
            csv.writer(buf, lineterminator="\n").writerow(rec)
            line = buf.getvalue()
            n_carried[tb] = n_carried.get(tb, 0) + 1
        if drop_col:
            first, _, rest = line.split(",", 2)
            assert rec[1] == _ , f"{tb}: dup_of is quoted on {rec[0]}"
            line = first + "," + rest
        out.append(line)
        if tb == "ch_rule_visits" and rec is not head:
            starts.add((rec[head.index("blue_line_key")], rec[head.index("downstream_route_measure")]))
    with open(f"{dst}/{tb}.csv", "w", newline="") as f:
        f.writelines(out)
    n_in, n_out = len(lines) - 1, len(out) - 1
    log.append(f"{tb}: {n_in} -> {n_out} rows ({n_in - n_out} dropped)" + ("; dup_of removed" if drop_col else "")
               + f"; habitat carried on {n_carried.get(tb, 0)}")

lines, parsed = rows(f"{src}/ch_rule_walks.csv")
head = parsed[0]
ib, im = head.index("blue_line_key"), head.index("downstream_route_measure")
out = [lines[0]] + [ln for ln, r in zip(lines[1:], parsed[1:]) if (r[ib], r[im]) in starts]
with open(f"{dst}/ch_rule_walks.csv", "w", newline="") as f:
    f.writelines(out)
log.append(f"ch_rule_walks: {len(lines) - 1} -> {len(out) - 1} rows (starts with no remaining visit dropped)")
with open(log_path, "w") as f:
    f.write("\n".join(log) + "\n")
print("\n".join(log))
