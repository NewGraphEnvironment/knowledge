# Code-check round 1 — knowledge#57 branch (`57-tune-habitat-thresholds-for-every-specie` against merge-base 3e88647)

Reviewed 2026-10-17 (UTC afternoon) read-only on the working tree. Read: the full diff (6,827 lines), every
changed R/, scripts/ and tests/ file, the merge-base reference scripts (`0290`, `0294`, `0296`, `0297`,
`0298`), fresh's `frs_habitat_predicates()` source and its compiled CH/BT predicates, flooded's
`fl_valley_join()` source, link's `configs/default` thresholds and `rules.yaml`, the committed
`data/tune/*_summary.csv`, the running `0330` job's state in Postgres, and the full checklist.

## Findings

- **[bug]** `scripts/0330-compare.R:109-111` — the scratch schema is keyed on species only
  (`scratch = paste0("knw_cmp_", tolower(job$species_code))`) while jobs are species × stage and run in
  parallel on socket workers. `BT_rear` and `BT_spawn` are both fitted (both have `_curve.rds` and
  `_grades.csv`), both have 158 groups, so `jobs[order(-groups)]` puts them first and `parLapplyLB` dispatches
  both in the first batch, to two workers, sharing schema `knw_cmp_bt`. Inside `knw_compare_rules()` each job
  does `dbWriteTable(... "grades", overwrite = TRUE)` (the two stages' grade tables differ: different pick,
  different `dist_m`, different `grade`), `DROP TABLE IF EXISTS <scratch>.streams` per group, overwrites
  `habitat_default`/`habitat_tuned`, and `on.exit(DROP SCHEMA ... CASCADE)` — so the two jobs clobber each
  other's `streams`/`grades`/`habitat_*` tables, and whichever exits first drops the schema under the other.
  Evidence from the run in flight (started 13:59 PDT, master pid 35214, 6 workers): at ~14:35 PDT
  `information_schema.schemata` held `knw_cmp_ch`, `knw_cmp_gr`, `knw_cmp_rb`, `knw_cmp_st`, each with
  `grades,habitat_default,habitat_tuned,streams,uhc`, and **no `knw_cmp_bt`**, while `pg_stat_activity` showed
  active queries on exactly those four. RB (160 groups) is still running, so two 158-group BT jobs cannot
  have finished; they died (one's schema drop or table overwrite broke the other). `parLapplyLB` surfaces a
  worker error only when it collects, so the whole script will abort after the other six jobs finish and
  write none of `compare.csv`/`change.csv`/`checks.csv`/`floodplain.csv` (today's `data/compare/` holds only
  `catalog/` and `maps/`). Fix: key the scratch on the job key (`paste0("knw_cmp_", tolower(job$key))`).

- **[bug]** `scripts/0320-tune-run.R:135` — `dev_null = best$dev_heldout + best$ddev_null - best$ddev_best`
  has the sign inverted. `ddev_null` is defined in `knw_tune_score()` as `tot - sum(null)`, so the no-rule
  deviance is `dev_heldout - ddev_null`; `ddev_best` is 0 for the best rule. The written column is
  `2*dev_best - null`. Measured on the committed summaries: `CH_rear_summary.csv` has `dev_best` 1150.66,
  `dev_null` **918.81**, `honest_dev_null` 1382.52; recomputed from `CH_rear_tune.csv`
  (`dev_heldout - ddev_null` on the best row) = 1382.52. `BT_rear`: `dev_null` 5553.34 written against
  `dev_best` 5792.29; correct 6031.25 (= `honest_dev_null`, since the null model involves no selection).
  Every fitted summary therefore claims the no-rule model beats every rule. The `research/*_tuned.md` files
  quote the nested-selection (`honest_dev_*`) figures, which are right, and `knw_thresholds_table()` does not
  read `dev_null`, so the published thresholds are unaffected; the eight `*_summary.csv` files and the
  `*_tune_run*.txt` logs carry the wrong number.

- **[bug]** `R/compare_rules.R:663-722` — the bcfishobs "outside check" is documented as "by
  `lnk_habitat_validate()`'s conventions (0298)" but drops one of 0298's filters: 0298 (merge-base
  `scripts/0298-ch-rule-compare.R:356-367`) placed each location and then excluded any inside a user-habitat
  overlay reach (`in_uhc`, "captured by construction"). The port places with the same DISTINCT ON but keeps
  overlay locations. Those segments are rearing under both rules by construction (the overlay is applied to
  both), so `n_detect`, `lift`, `lift_lo/hi` for `default` and `tuned` in `checks.csv` are inflated relative
  to the reference, and the check no longer measures what the roxygen says. Input that shows it: any group
  with rows in link's `overrides/user_habitat_classification.csv` for the species (the uhc table is already
  written to `<scratch>.uhc` in this function, so the filter is one `EXISTS` away).

- **[fragile]** `R/compare_rules.R:497-531, 575-594` against `R/link_segments.R:836-839` and
  `R/grade_species.R:1320-1323` — two access gates in one comparison. `knw_compare_rules()` gates on the
  habitat table's `h.accessible` (needed to reproduce link's stored flags, as 0298 did), but the `grades`
  table it joins was built by `knw_grade_species()` on `knw_link_segments()`, which re-gates on
  `streams_access.access_<sp> > 0` (CLAUDE.md's rule). Consequences on the segments where the two disagree
  (link#349: ~2 % of habitat-accessible segments for most species, 17–27 % for RB): `knw_dist` is NULL
  because they were never walked, so the tuned rule's exception (`coalesce(s.knw_dist <= D, FALSE)`) can
  never admit them while its size test can — the comparison applies a slightly different tuned rule on those
  segments than the one scored; and `grade` is NA there by `grade_species`'s `ifelse(accessible, ...)`, so
  they land in `graded_na_km` rather than any class. Bounded: the exception species are CH (Q3@D1000) and
  BT spawn (Q3@D2000), both ~2 %; RB's pick has no exception. Worth stating in the output or walking the
  union of the two gates.

- **[fragile]** `scripts/0325-publish.R:51` — `tune_log = sort(list.files("scripts/logs/habitat",
  "_tune_run\\.txt$"), decreasing = TRUE)[1]`. The tuning logs are written by `0320` as
  `<date>_tune_run-<species>.txt` whenever `SPECIES=` is set (`scripts/0320-tune-run.R:58-60`), which is how
  this run was done (`20261017_tune_run-bt_ch_co_st.txt`, `-rb_gr_wct.txt`, `-ko_pk_sk_cm.txt`). The regex
  matches none, so `prov$tune_log` is `NA` and both published manifests read `"tune_log": null`
  (`data/publish/thresholds_v1/manifest.json:14`, `data/publish/habitat_grade_v1/manifest.json:14`). The
  provenance the header promises is absent from the set that will be uploaded. Use `_tune_run.*\\.txt$` or
  record all matching logs.

- **[fragile]** `R/publish.R:140-163` — the roxygen says each table is "compared column by column with an
  all-character read of its CSV", but the Hive branch (`hive`) `next`s before `.knw_values_differ()` runs, so
  `habitat_grade` (5.7 M rows per species × stage, the largest published table) is the one table the
  round-trip check never sees. Not a wrong number today (arrow's inference on these columns is sound), but
  the guard's scope is narrower than its claim.

- **[minor]** `R/tune_curve.R:2622-2626` — `dropped$no_walk = sum(is.na(m))` is reported as a drop, but a
  visit with no walk takes `dist_cap_m` (`ifelse(is.finite(dist), dist, dist_cap_m)` is `dist_cap_m` for
  `NA`) and `ok` keeps it, so those rows are fitted, not dropped. `knw_grade()` does the same deliberately
  and documents it; here the `dropped` element misdescribes what happened. Nothing downstream writes
  `dropped`, so no output is wrong; it only matters if the count is ever read as a drop.

## Checked and found consistent with the reference scripts

- `knw_fdis_quality()` reproduces 0290/0294's six drops in order, NA flags dropped as before.
- `knw_fdis_species()` BT presence/blocking matches 0290's `presence_codes()`/`blocking_codes()` in both
  pooling states; the test fixture exercises SLV, AO, SP and the group-level `char` block.
- `knw_link_flow()`, `knw_link_regulated()`, `knw_link_barrier_dnstr()` are 0294's SQL verbatim;
  `knw_link_width()` is 0296's width model and `cw_deploy` rule verbatim; `knw_link_place()` is 0290's
  placement and overlap check (window 5 m, overlap 0.01 m).
- `knw_rule_in()`, `knw_tune_grid()` (2,795 CH rules, default of zero departures), `.tune_fold_of_wsg()`,
  `.tune_score_one()`, `.tune_sel()`, `.tune_pick()` (d_floor 200), the bootstrap, nested selection and extra
  seeds match 0297 line for line; the population filters match 0297's (stream edges, not in R/W≥1 ha/L≥100 ha,
  area 10–10,000 m², barrier `%in% FALSE`). The lake floor is 100 ha for every species while link's rules use
  10–200 ha per species, but the visits that could differ (stream-edge visits in a 10–100 ha lake) number 0 in
  `visits_link.csv`, so no population changes.
- `knw_compare_rules()`'s tuned predicate: fresh's compiled rear predicate puts no waterbody exclusion on
  the stream rule, the river rule carries its own `channel_width [0, 9999]`, and `.knw_fresh_branches()`
  reads each species' own W/L floors from `rules.yaml` (BT 10 ha, CH 100 ha, ST 60, GR 40), so the
  stream-branch substitution and the "river test stays default's" claim hold. The `is_default_rule`
  assertion is exercised live on GR (its pick equals `default`).
- `flooded::fl_valley_join()`'s `nearest$seg` is a row index into the `segments` passed (after dropping
  empty geometries; `fresh_default.streams` has 0 empty geometries and 0 NULL `stream_order`), so
  `knw_floodplain_ha()` and 0330's floodplain raster index it correctly.
- `discharge.fwa_v1_segment_monthly` has 0 segments with more than one picked annual row, so
  `knw_link_segments()`'s `LEFT JOIN ... AND q.pick` cannot fan out; `CH_rear_grades.csv` has 0 duplicate
  `(id_segment, watershed_group_code)`.
- `inst/sql/ch_dist_profile.sql` differs from `scripts/sql/ch_dist_profile.sql` only in the header line,
  which `test-link_place.R` pins.
