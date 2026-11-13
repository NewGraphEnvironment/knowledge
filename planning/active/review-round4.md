# Code-check round 4: #173, branch against eac16623

## Checklist read

- code-check-python.md: read in full. Nothing in this diff is Python.
- code-check.md: read the prose of the H3s under `## Mechanisms`, skipping the tables: A guard that fails toward pass;
  A fixture that cannot reach the failure mode; A proxy is not the property. Read the index lines of the rest.
- code-check-r.md, by heading: socket workers (`clusterApply()` / `parLapplyLB`); `system.file()` and `load_all()`;
  DBI driver types; `match()` and NA; `ifelse()` with NA; Postgres row order; `tryCatch()` nesting; testthat counts.
- code-check-spatial.md, by heading: GeoPackage writes (the SQLite leaks, `layer_styles`); `st_difference()`
  collections; tmap and terra plotting; reading with `sf`.
- code-check-shell.md: `curl -o` and HTTP status. The diff has no shell beyond its docs.

I ran the probes in a detached worktree of HEAD (ac8d5c11) and removed it afterwards. The four changed test files
pass, each with 0 failed and 0 error:

| test file | passed | skipped |
|---|---|---|
| `test-compare_map.R` | 89 | 0 |
| `test-env_flag.R` | 17 | 0 |
| `test-tune_promote.R` | 145 | 0 |
| `test-vignette-data.R` | 247 | 3 |

The database queries were read-only, against the local fwapg. Its `fresh_default.log_recompute` names one run,
`20261103_163715-269b585a`, the published build.

## Enumerated

| # | place | what it assumes | measured | verdict |
|---|---|---|---|---|
| 1 | Round 3's fix: `gpkg_one()` handles waterbody keys that `fwa_waterbodies` lacks (scripts/0330-compare.R:400-427) | Such a key no longer stops the key, and its segments get `water` NA | Orphan keys across every group of `fresh_default.streams`: CHWK 1 segment (1 key), REVL 15 (8), SHUL 1 (1). 17 in all, as the comment says. Then I ran the shipped `gpkg_one` on a socket worker (`parLapplyLB`) on the published geometry of BULK, CHWK, REVL and SHUL, with a BT segments table built from `streams_habitat_bt`. It wrote the GeoPackage and logged "17 with a waterbody key fwa_waterbodies lacks". `water` is NA on exactly CHWK 1, REVL 15 and SHUL 1. `water_ha` is NA on 75,754 segments: the 75,737 stream lines plus the 17 orphans, so every lake, river and wetland segment has an area. The file holds the `run` layer and two `layer_styles` rows (rule_class as the default, then grade_class). | holds |
| 2 | `waterbody_key = 0` in streams (an orphan that the comment would not count) | none present | `fresh_default.streams`: 0 rows with key 0, 4,067,238 NULL, 5,546,370 in all | holds |
| 3 | `id_segment` unique within a group (the join in `gpkg_one()`) | unique | 5,546,370 rows, 5,546,370 distinct (group, id_segment) | holds |
| 4 | `fwa_waterbodies.waterbody_type` (`.knw_segment_water()`) | L, R, W or X, never NULL | L 302,274, R 19,719, W 216,382, X 368; no NULL group | holds |
| 5 | GeoPackage fields across groups appended in turn (`st_write(append = )`) | Types stay stable from group to group | `water` is character in every branch (including the zero-row `wb` case), and `water_ha` is numeric (`as.numeric`). The four-group probe wrote 95,968 segments with 11 fields. | holds |
| 6 | Grade class labels in `inst/gq/compare.csv` | These are the only labels a grade table holds | `R/grade.R:74` builds them from `classes`, with `"not graded"` filled for accessible segments in `gpkg_one()` | holds |
| 7 | `STAGE=gpkg` on the promoted run: mtime of segments against grades | Promotion keeps the dates | `knw_tune_promote()` renames, or copies with the dates kept (R/tune_promote.R:392-) | holds |
| 8 | **`STAGE=gpkg` on the promoted run: one `tune_run` across data/tune's summaries** (scripts/0330-compare.R:120-128, 443) | data/tune holds a single tuning run | Today, yes: the 7 fitted keys all name `20261104_0543`. But `knw_tune_promote()` allows a by-key promotion from another run onto the same build: its agreement fields (R/tune_promote.R:204-205) leave out `tune_run`, and `R/archive.R` tracks `tune_run` per key. After such a promotion, `STAGE=gpkg` on data/tune stops. | **fails: finding 1** |
| 9 | Floodplain rows gain `tune_run`, `config_sha`, `tuned_rule` (STAGE=floodplain) | The run's header can merge into the tracked table | The tracked `floodplain.csv` holds 7 keys (BT_rear, BT_spawn, CH_rear, CO_rear, GR_rear, ST_rear, WCT_rear) under the old header. `.knw_rows_merge()` takes a changed header only when every tracked key is promoted, and refuses otherwise during planning, before anything moves. No other reader of `floodplain.csv` exists (grep over R/, scripts/, data-raw/, vignettes/, tests/). | holds (safe refusal) |
| 10 | Promotion no longer takes `fig_dir` | No caller passes it | grep finds no `fig_dir` in scripts/, data-raw/ or R/ besides the doc. An archive's leftover `fig/` is noted, not moved. | holds |
| 11 | Context bundle (`data-raw/vignette_context.R`) and map arguments | BULK, the map group | `data-raw/vignette_chinook.R:54` fixes `wsg <- "BULK"`, so `map_group` is always BULK. The README figure, the article and the test hold `ctx$meta$map_group` to the bundle's. The composed-map arguments are used only for that group. | holds (accepted design) |
| 12 | `.knw_env_flag("GPKG")` | The documented `GPKG=FALSE` still reads as off | `FALSE` and `0` read as off; a misspelling stops the run | holds |
| 13 | scripts/0330-compare.R:110 comment | 0335 copies into `research/fig/` | Stale wording (0335 no longer promotes figures). Comment only, no effect on behaviour. | note, not a finding |

## Findings

- **[severity: fragile]** scripts/0330-compare.R:120-128 (and :443): `STAGE=gpkg` with `TUNE_DIR=data/tune` takes the
  run name from every summary in data/tune. It stops unless exactly one `tune_run` is present: "data/tune's summaries
  name 2 tuning runs ..., not one".
  - The repo supports promoting keys alone onto the kept keys' build. `knw_tune_promote()`'s agreement fields are
    evidence_md5, run_uid, curve_grad, evidence_ledger, ref_edge, discharge_load, walk_md5, config_sha and
    tuned_structure. `tune_run` is not among them, and `R/archive.R` records it per key. So promoting one key from a
    later run leaves data/tune with two runs on one build.
  - From then on, the promoted comparison cannot reach QGIS. That route is the reason `STAGE=gpkg` takes data/tune,
    since `GPKG` is now off by default. The only way out would be another whole-run promotion.
  - The one-run premise was measured on the state in hand (7 fitted keys, one run; round 3 row 13). It was never checked
    against the states promotion permits.
  - Each GeoPackage is per key, and `gpkg_one()` already receives `key`. The run can come from that key's own summary,
    which would carry the correct run per key into the `run` table and drop the population-wide requirement. The log
    name would then need some name other than the single `run`.
  - **Rule:** code-check.md "A fixture that cannot reach the failure mode"
