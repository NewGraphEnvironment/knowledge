# Code-check round 5 (#173), branch at bd3789b4 against eac16623

## Checklist read

- code-check-python.md: read in full (no Python in the diff).
- code-check-r.md, by heading: curl user-agent on canada.ca; a database driver's value; Postgres row order;
  `sprintf("%g")` in SQL; `clusterApply()` NULL for no tasks; `c(name = x)`; `[[` on a named atomic vector;
  `data.frame()` scalar against zero length; `ifelse()` with an all-NA test; a `function(...)` mock; testthat
  failed/error counting; `tolerance` is relative.
- code-check-spatial.md, by heading: GeoPackage is a SQLite database (layer_styles registration); the same leak in
  R/OGR; `st_intersection()`/`st_difference()` GEOMETRYCOLLECTION; projected-bbox to lat/lon; a name is not a key;
  a GDAL failure partway through `st_read()`.
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows skipped).
- code-check-shell.md: no heading applies (no shell in the diff).

## Enumerated

Round 4's fix (scripts/0330-compare.R, the `if (promoted)` block and `write_gpkgs()`):

- `run` as the literal "promoted": read only by `path_log` (`<date>_compare-promoted[-sp]-gpkg.txt` in
  data/compare/gpkg/) and the refused-log path derived from it. The floodplain stage (`tune_run = run`) cannot run in
  promoted mode, because `promoted` requires `STAGE=gpkg`, and the "Candidate run" line is non-promoted only.
  `git check-ignore` confirms the log, GeoPackages, catalog and segments paths are ignored. Clean.
- A key with no summary: `run_of[[k]]` is reached only behind `k %in% names(run_of)`, so the named-atomic `[[` error
  cannot fire; an NA `tune_run` writes as NULL in the `run` table (probed). Clean.
- `run_info` as a named list to socket workers: built in the main process, indexed with exact `[[key]]` on the worker;
  `do.call(parLapplyLB/lapply, ...)` argument names do not partially match `cl`/`X`/`fun`. Probed a GeoPackage with
  segments written over two appends, the `run` table and the styles: `layer_styles` and `run` are both registered as
  `attributes` in gpkg_contents and listed by GDAL, rule_class the default style. Clean.
- `run_of` keys come from `<key>_summary.csv` basenames, the same spelling as the `jobs` keys from `<key>_curve.rds`.
  On the tracked data/tune every fitted summary names one run (20261104_0543); unfitted ones are NA and drop out of the
  log line. The log line lists every summary's run, not just the keys written: a description only, no failure.
- Other values assumed one across keys in promoted mode: `run_uid` (one ledger, `knw_run_ledger()` refuses two),
  `run_grad`, the evidence md5 and `sum_dirs` all stop on more than one; a by-key promotion goes only onto the kept
  keys' build, so they hold. The per-key stale check reads each key's own grade table. Fail-loud throughout.

Elsewhere:

- `.knw_segment_water()` over the whole province (fresh_default on the local database, read-only):
  fwa_waterbodies 538,743 rows, 538,743 distinct keys (the duplicate stop cannot fire); types only L, R, W, X; of the
  keys the streams carry, each sits in exactly the polygon table its type names (0 keys in two tables), so the
  coalesce order cannot give a waterbody another type's area. `ORDER BY w.waterbody_key` is unique. Clean.
- `gpkg_one()` per group: `ifelse(is.na(waterbody_key), ...)` never has an NA test; a group with no waterbody gives a
  0-row lookup whose `[i]` is a typed NA; `water`/`water_ha` keep one type across groups. Clean.
- `rule_class`/`grade_class` values against the registry: grade labels come from `cut()` in R/grade.R as
  "0-0.2" ... "0.8-1", the same as inst/gq/compare.csv; the per-stage flag columns (`rearing_*`, `spawning_*`) match
  R/compare_rules.R. Clean.
- floodplain.csv gains tune_run, config_sha, tuned_rule; `.knw_rows_merge()` refuses a header change unless every
  tracked key is promoted. That refusal is the existing guard (fail-loud). `tuned_rule` and `config_sha` are
  constant per key in the tracked compare.csv. Clean.
- knw_tune_promote() without `fig_dir`: no caller passes it (0335, tests, examples). `arch_of()` lost the fig place
  and nothing moves into research/fig any more. Clean.
- `.compare_cols()` uses `system.file(mustWork = TRUE)`: the main process under load_all (pkgload shim) and the
  installed package (inst/gq is not build-ignored); workers get `rule_labels` as an argument. Clean.
- `grid::`/`grDevices::` in R/compare_map.R: `tools:::.check_packages_used(dir = ".")` reports nothing undeclared
  (both are base packages). Clean.
- Article `map_h` against knw_compare_map()'s window: both are the outline's bbox plus 2 km a side (4,000 m added
  per axis). The figure is not distorted. Clean.
- vignette_context.R: queries ordered on unique keys; the geonames host is not canada.ca. It is BULK by design
  (accepted). Clean.
- Tests on a scratch worktree (NOT_CRAN=true, test_file): test-compare_map 89 passed, test-env_flag 17,
  test-tune_promote 145, test-vignette-data 247 passed and 3 skipped; 0 failed, 0 errors.

## Clean

No issues found.
