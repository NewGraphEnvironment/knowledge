"""Drop #35's repeated-survey copies from the FDIS visit tables built before #35.

fresh_default was being rewritten by a provincial link run (2026-10-17), so 0290, 0294 and 0296
could not be rebuilt against the schema they were built on. Each gives a visit its own row,
independent of other visits, so removing the copies 0230 now drops equals a rebuild. Lines are
kept as written; `dup_of` (the second column of ch_mad_visits and ch_rule_visits, ids only) is
removed, and walks are kept for the starts that still have a visit.

Two changes 0230 makes to a kept copy are applied as a rebuild would:
- where it moved a dropped copy's habitat to the copy kept (`habitat_carried`), the kept row's
  habitat columns are taken from the new fdis_sites.csv;
- it pools the copies' 50k watershed codes, so a kept copy's ws50 flag can change. One that now
  fails leaves the table. One that now passes, where only a dropped twin was in the table, takes
  the twin's row (same placement and catch), with every column that the table copies verbatim
  from fdis_sites.csv set to the kept copy's value.
Any other difference between the old fdis_sites.csv (less the dropped copies) and the new one
stops the run.

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
twins = {}
for r in rmap:
    if r["status"] == "dropped":
        twins.setdefault(r["kept_site_visit"], []).append(r["site_visit"])
cols_habitat = ["habitat_rows", "habitat_conflict", "gradient_pct", "gradient2_pct", "channel_width_m",
                "wetted_width_m", "n_cw_measures", "water_temp_c", "bed_dominant", "grad_sentinel",
                "cw_sentinel", "has_habitat", "cw_comparable"]
cols_ws50 = ["flag_ws50_mismatch", "ws50_checked"]


def read_sites(path):
    with open(path, newline="") as f:
        return {r["site_visit"]: r for r in csv.DictReader(f)}


sites_new = read_sites("data/fdis/derived/fdis_sites.csv")
sites_old = read_sites(f"{src}/fdis_sites.csv")
assert not dropped & set(sites_new), "a dropped copy is still in fdis_sites.csv"
assert set(sites_old) - dropped == set(sites_new), "fdis_sites.csv is not the old table less the dropped copies"
ws50_now_fails, ws50_now_passes = set(), set()
for sv, new in sites_new.items():
    diff = [c for c in new if new[c] != sites_old[sv][c]]
    allowed = (cols_habitat if sv in carried else []) + (cols_ws50 if sv in twins else [])
    assert set(diff) <= set(allowed), f"{sv}: fdis_sites.csv differs in {diff}"
    if "flag_ws50_mismatch" in diff:
        (ws50_now_fails if new["flag_ws50_mismatch"] == "TRUE" else ws50_now_passes).add(sv)
log = [f"#35 repeat filter: {len(dropped)} copies dropped by 0230 (data/fdis_repeat_surveys.csv); "
       f"ws50 flag changed on {len(ws50_now_fails)} kept copies to fail, {len(ws50_now_passes)} to pass."]


def rows(path):
    with open(path, newline="") as f:
        lines = f.read().splitlines(keepends=True)
    parsed = list(csv.reader(io.StringIO("".join(lines))))
    assert len(parsed) == len(lines), f"{path}: a field spans lines"
    return lines, parsed


def as_line(rec):
    buf = io.StringIO()
    csv.writer(buf, lineterminator="\n").writerow(rec)
    return buf.getvalue()


starts = set()
for tb in ["bt_use_visits", "ch_mad_visits", "ch_rule_visits"]:
    lines, parsed = rows(f"{src}/{tb}.csv")
    head, body = parsed[0], parsed[1:]
    assert head[0] == "site_visit"
    drop_col = len(head) > 1 and head[1] == "dup_of"
    # columns the table copies verbatim from fdis_sites.csv, judged on every old row
    verbatim = [i for i, c in enumerate(head) if c != "site_visit" and c in next(iter(sites_old.values()))
                and all(r[i] == sites_old[r[0]][c] for r in body)]
    present = {r[0] for r in body}
    old_rows = {r[0]: r for r in body}
    n = {"carried": 0, "fails": 0, "passes": 0, "shared_later_drop": 0}
    extra = []
    for k in sorted(ws50_now_passes - present):
        donors = [d for d in twins[k] if d in old_rows]
        if not donors:
            # neither copy was in the table. Every twin passed the flag drops a copy can differ on
            # (0230's enumeration), so it left at a later step on placement or catch, which the kept
            # copy shares: a rebuild leaves it out too
            for d in twins[k]:
                o = sites_old[d]
                assert all(o[c] == "FALSE" for c in ["flag_not_placed", "flag_far_snap", "flag_ws50_mismatch",
                                                      "flag_junk_date"]) and o["catch_status"] != "unknown", \
                    f"{tb}: {k}'s twin {d} left at a step the kept copy may not share"
            n["shared_later_drop"] += 1
            continue
        rec = list(old_rows[donors[0]])
        rec[0] = k
        for i in verbatim:
            rec[i] = sites_new[k][head[i]]
        extra.append((as_line(rec), rec))
        n["passes"] += 1
    out = []
    for line, rec in list(zip(lines, parsed)) + extra:
        if rec is not head:
            if rec[0] in dropped:
                continue
            if rec[0] in ws50_now_fails:
                n["fails"] += 1
                continue
            assert rec[0] in sites_new, f"{tb}: {rec[0]} is not in fdis_sites.csv"
            if rec[0] in carried:
                for c in cols_habitat:
                    if c in head:
                        rec[head.index(c)] = sites_new[rec[0]][c]
                line = as_line(rec)
                n["carried"] += 1
        if drop_col:
            first, second, rest = line.split(",", 2)
            assert rec[1] == second, f"{tb}: dup_of is quoted on {rec[0]}"
            line = first + "," + rest
        out.append(line)
        if tb == "ch_rule_visits" and rec is not head:
            starts.add((rec[head.index("blue_line_key")], rec[head.index("downstream_route_measure")]))
    with open(f"{dst}/{tb}.csv", "w", newline="") as f:
        f.writelines(out)
    n_in, n_out = len(lines) - 1, len(out) - 1
    log.append(f"{tb}: {n_in} -> {n_out} rows" + ("; dup_of removed" if drop_col else "")
               + f"; habitat carried on {n['carried']}; ws50 now fails {n['fails']}, now passes {n['passes']}"
               + f" (and {n['shared_later_drop']} whose twin left at a later step both copies share)")

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
