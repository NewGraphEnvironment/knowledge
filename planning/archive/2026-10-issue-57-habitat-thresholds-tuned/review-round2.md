# Code-check round 2 — knowledge#57 branch (`57-tune-habitat-thresholds-for-every-specie` against merge-base 3e88647)

Reviewed 2026-10-17 (started 21:55 UTC, written 22:25 UTC) read-only on the working tree. Read: the full
branch diff, round 1's report and fix diff (`cd16d85`), every changed `R/`, `scripts/` and `tests/` file in
full, the merge-base `0296`–`0299` scripts, fresh 0.39.0's `frs_habitat_predicates()` output,
`.frs_run_connectivity()` and `frs_habitat_overlay()` source, link `configs/default` at the run's SHA
(`a17e9177`; `rules.yaml` and the thresholds CSV are byte-identical to the `../link` checkout), the
committed `data/tune/*` and `data/fdis/derived/*` tables, the running `0330` job's state in Postgres and
in `ps`, and the whole checklist (7,797 lines). Probes ran against copies, read-only SQL, and
`pkgload::load_all()` of the working tree.

## Findings

- **[bug]** `R/compare_rules.R:395-418` (`.knw_fresh_branches()`), reached from `:87` and `:101-110` —
  it misreads CO's rearing rules, and the first misreading **kills the comparison run**. Two defects, one
  helper:
  1. CO's `W` and `L` rear rules carry no `wetland_ha_min` / `lake_ha_min` (link's `rules.yaml`: any
     wetland, any lake). `min(c(NULL, NULL))` is `Inf` with a warning (swallowed on the socket worker), so
     `wb_sql` reads `… WHERE area_ha >= Inf`, and PostgreSQL parses the bare word as an identifier.
     Measured: `knowledge:::.knw_fresh_branches(params$CO, "rear")` returns `wetland_ha_min = Inf,
     lake_ha_min = Inf` (two warnings), and the SQL fails `ERROR: column "inf" does not exist`. So
     `knw_compare_rules()` for `CO_rear` dies at `DBI::dbExecute(conn, wb_sql)` (`:130`), before
     `CREATE SCHEMA`. This is the `code-check-r.md` rule "`sprintf("%g", x)` writes `Inf` … as bare words".
  2. CO's third rear rule (`edge_types_explicit: [1050, 1150]`, `thresholds: false`, no
     `waterbody_type`) is read as *the* stream rule because the loop treats every rule with no
     `waterbody_type` as the stream rule and the last one wins: `edge_stream` comes back `1050, 1150`. Even
     with (1) fixed, the tuned CO rule (`mad>=0.03|g<=0.04|none`) would be applied to the 6,869 km of
     accessible 1050/1150 edges in CO's 100 groups (which fresh's `default` admits unconditionally; 161 km
     of them fail the tuned gradient alone) and **not** to the 95,114 km of accessible 1000/1100/2000/2300
     edges it was scored on, which would instead get fresh's own width ≥ 1.5 m test at gradient 0.04.
     The `is_default_rule` assertion cannot see either: CO's pick is not `default`.

  Every other fitted species × stage reads correctly (BT rear W 1 / L 10, CH W 1 / L 100, GR L 40, RB and
  WCT W 1 / L 10, ST W 1 / L 60; every `edge_stream` 1000/1100/2000/2300). Round 1 checked the floors for
  BT/CH/ST/GR and did not run CO. Fix: a rule with no floor means floor 0 (omit the `area_ha` filter, or
  render `Inf` as `'Infinity'::float8`); pick the stream rule as the no-`waterbody_type` rule whose
  `thresholds` is not `FALSE` (or the first), not the last; and pin `.knw_fresh_branches()` over every
  species in `rules.yaml` in a test, since nothing exercises it today.

- **[bug]** `R/compare_rules.R:108-110` (`sb`, the stream-branch test) and `:118-119` — the port ignores
  the spawn stream rule's `in_waterbody: false`. fresh's compiled BT spawn predicate is
  `(s.edge_type IN (1000, 1100, 2000, 2300) AND s.waterbody_key IS NULL AND s.gradient BETWEEN 0 AND
  0.0549 AND s.channel_width BETWEEN 2 AND 9999) OR (river …)`; the port's `sb` excludes only river
  polygons (for the spawn stage `tmp_knw_wb` holds `R` alone), so the tuned test
  `grad_ok AND (size_ok OR exception)` runs on stream-edge segments inside any wetland or lake, which
  `default` never admits. Measured on BT's 158 groups: 99,580 accessible stream-edge segments with a
  non-river `waterbody_key` (16,073 km, 16,073 of them in wetlands), 15,661 km inside the 0.0549 gradient;
  on the MAD floor alone the tuned rule (`mad>=0.75|g<=0.0549|Q3@D2000`) admits 2,341 of them (454 km),
  and the Q3-within-2000 m exception admits an unmeasured share of the remaining 15,207 km (wetlands sit
  beside rivers). All of it lands in `BT_spawn`'s `gained_km` under reasons "size: tuned passes, width
  fails or NULL" and "exception", while `default`'s side is fresh's own (correct) predicate, so the
  comparison is asymmetric by construction. The scoring population is not affected (1 BT-rear visit sits
  in a sub-floor waterbody, none caught BT). Not inside a round-1 fix. Fix: when the stage's stream rule
  carries `in_waterbody = FALSE`, add `s.waterbody_key IS NULL` to `sb`, read from the rule the way
  `edge_types_explicit` is; the rear stream rules carry no such flag, so the rear stages are unchanged.

- **[bug]** `scripts/0330-compare.R:120-126` — the run started 21:33 UTC (pid 42047) will abort at
  collection with no output, the same shape as round 1's finding 1. `parLapplyLB` returns worker errors
  as `try-error`s and `checkForRemoteErrors()` raises once every chunk is back, so one failed job discards
  the other seven, and `log_lines` is never written (`20261017_compare.out` holds the first four lines).
  Two of the eight jobs have already exited: at 22:12 UTC six sessions were active, five aged 38:49–38:41
  (`bt_rear`, `ch_rear`, `bt_spawn`, `gr_rear`, `st_rear`) and one aged 7:41 (`wct_rear`). Jobs are
  dispatched largest first (RB 210, BT 158 ×2, CH 125, CO 100, GR 82, ST 79, WCT 16; `dynamicNChunks`
  gives one job per chunk), so ST's session 8 s younger than the others is the worker CO freed by the
  `Inf` error above, and WCT's is the worker RB freed at ~22:05 UTC, 31.7 min in, with 210 groups to do.
  RB's cause is not visible from outside the master: it ran on the worker now holding 10.5 GB RSS, the
  machine's swap read 7,374 of 8,192 MB with 190 MB of free pages, and `run_one()` reads the whole
  10.3 M-row `RB_rear_grades.csv` into each worker before `knw_compare_rules()` copies it again for
  `dbWriteTable()`. The database did not crash-recover (the other sessions survived), so it was a client-side
  error. Fix: wrap the body of `run_one()` in `tryCatch(…, error = function(e) list(key = job$key,
  error = conditionMessage(e)))` and write each job's tables as it finishes, so a failure costs one job;
  `makeCluster(outfile = <log>)` so a worker's error and the `.knw_fresh_branches()` warnings are kept;
  and read only the grade columns the comparison needs (`id_segment, watershed_group_code, size,
  dist_m, grade, grade_class`) with `col_select`.

- **[fragile, inside round-1 fix 4]** `R/compare_rules.R:146,203` against `R/link_segments.R:61-64` and
  `R/link_place.R:74-81` — one gate written three ways. Compare now gates on `coalesce(access_<sp> > 0,
  FALSE)` alone; `knw_link_segments()` (the grades) and `knw_link_place()` (the visits) gate on
  `accessible_stored & access > 0`. They differ in the `(habitat_accessible = FALSE, access > 0)` cell,
  which `data/fdis/derived/access_check.csv` measures on this run: BT 1,035 segments / 222 km, RB 759 /
  175 km, CH 710 / 174 km, CO 676 / 167 km, GR 752 / 147 km, ST 515 / 124 km, WCT 163 / 35 km. On those
  segments the comparison can set rearing or spawning under both regenerated rules (so they count in
  `accessible_km`, `default_km`, `tuned_km`), their grade is `NA` by gate rather than by missing inputs
  (so they inflate `graded_na_km`, whose roxygen says "size or gradient is missing"), and they are left
  out of `knw_grade()`'s reference quantile while compare treats them as accessible. About 0.04 % of
  accessible km, so no headline moves; the fix is one predicate — CLAUDE.md names `access_<sp> > 0` —
  used in all three functions, or a note in `compare`'s roxygen that `graded_na_km` includes them.

- **[fragile]** `scripts/0320-tune-run.R:170` — the grade cache is keyed on file existence alone:
  `if (file.exists(<key>_grades.csv)) next`, whatever pick and curve the current run holds, while the
  `_score.rds` cache at least checks `visits_in`. A rebuilt evidence set that moves a species' pick
  would leave the old grades under the new pick for `0325` (publishes them under the new `rule_id`) and
  `0330` (joins `size`/`dist_m` walked for the old exception). Measured today: all eight tables carry
  the `rule` and `run_uid` their `_curve.rds` holds, so nothing is wrong now. The CSV already carries
  `rule` and `run_uid`; compare them to `r$pick$rule` and the ledger's `run_uid` before keeping the file.

- **[minor]** `scripts/0330-compare.R:18-19,158` — the header says the map groups are "the three
  criteria groups 0298 fixed (small-stream-heavy, interior, coastal)" and the code comment "most order
  1-2 stream, and the two largest changes either way"; the code picks the largest gained share, the
  largest lost share and the largest `default_km`. Maps only; no number is affected.

## Round-1 fixes re-checked

1. Scratch keyed on the job key: the live run holds `knw_cmp_bt_rear` and `knw_cmp_bt_spawn` side by
   side; every other scratch object (`tmp_knw_wb`, `tmp_knw_loc`, fresh's `pg_temp.frs_clusters_*`) is
   session-temporary. Holds.
2. `dev_null = dev_best - ddev_null`: on every fitted summary `dev_null` now equals `honest_dev_null`
   (BT rear 6031.25, BT spawn 449.20, CH 1382.52, CO 4024.59, GR 848.41, RB 12617.38, ST 722.57, WCT
   1329.87), which is `sum(null)` by construction. Holds.
3. `in_uhc`: the `EXISTS` matches 0298's (`u.<flag> = 1`, `t.m BETWEEN` the reach), on the species'
   rows only, keyed on the stage's column, and the counts message adds the excluded locations back.
   Holds.
4. Access gate: holds for what it set out to do (compare and grades now agree on the 2 %/17–27 % cell);
   the residual three-way disagreement is the fragile finding above.
5. `tune_logs`: the manifest now carries all three logs
   (`20261017_tune_run-bt_ch_co_st.txt`, `-ko_pk_sk_cm.txt`, `20261017_tune_run.txt`). Holds.
6. Hive round-trip: `raw[sel, ]` and `df[sel, ]` index the same file order; the per-part check reuses
   `.knw_values_differ_df()`; `sel` cannot carry `NA` for the two key columns. Holds.
7. `capped` is counted over all of `d` and `dropped` over the two real drops; the test pins both. Holds.

## Checked and found consistent

- Every `streams` row in each species' groups has a habitat row (CH 5,757,827 = 5,757,827; BT, CO, GR,
  RB, ST, WCT likewise), so the outside check's placement on `fresh_default.streams` cannot miss `seg`.
- No stream-edge segment (1000/1100/2000/2300) in CH's groups sits in a river polygon, so the port's
  stream-branch exclusion of `R` changes nothing against 0298 there.
- The scoring population keeps no visit 0294/0297 dropped: `flow_missing` 0 in the ledger and
  `mad_pick` NA on 0 visits in every species' population; `barrier_dnstr_<sp> %in% FALSE` drops the
  no-code visits as `natural_barrier_dnstr %in% FALSE` did.
- All eight `_grades.csv` carry the pick their `_curve.rds` holds (same `rule`, same `run_uid`).
- `.knw_values_differ_df()`, `knw_publish()`'s republish check (part order follows `list.files()`),
  `knw_thresholds_table()`, `knw_tune_grid()` (2,795 CH rules; the species' own default joins the
  ladder, which is where CO's `mad>=0.03` and BT's `g<=0.1049` come from), `knw_tune_score()`'s folds,
  selection, pick, bootstrap and nested selection against 0297, and `knw_rule_in()`'s exception test.
- The species-code `blocks_absence_of` extension (AF/SP block every species, AO/SA every salmon with
  KO, CRS/CT/RB-CT/CT-RB block RB and WCT, KO↔SK, TR blocks RB/ST/WCT/char) is coherent with
  `knw_fdis_species()`'s group-or-species rule.
- link's `configs/default` at the run SHA `a17e9177` is byte-identical to the checkout the probes read.
