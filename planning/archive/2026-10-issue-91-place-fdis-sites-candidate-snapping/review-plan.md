# Plan review — #91 (Plan agent, 2026-10-27, spawned 16:03:57Z, returned after 8 min)

The reviewer read the plan, the issue body, `0230`, `R/fdis_quality.R`, `0310`, `R/link_place.R`, `R/link_walks.R`,
`R/build_record.R`, `R/settings_register.R` and its test, the registers, `0240`, `data-raw/vignette_method.R`,
`test-vignette-data.R`, `0320`, `R/tune_run.R`, and fresh's `frs_point_snap.R` and `utils.R` guards; it ran
read-only database counts. Its findings are below as returned, then the disposition of each.

## Findings as returned

### Blocker
- **A second test fails and there is no CI to be green.** `inst/method/settings.csv` and `pipeline.csv` are in
  `method.rds`'s *tracked* md5 list (`data-raw/vignette_method.R:380-387, 399`), so Phase 2's register edits fail
  `test-vignette-data.R:97-107` ("every tracked source … unchanged"), not only the ignored-source test the plan names.
  Its skip is `dir.exists(root/data)` (`:16`) and `data/` is tracked (278 files, e.g. `data/bowr/`), and
  `.github/workflows/` holds only `pkgdown.yaml` and `update-citation-cff.yaml`: no workflow runs tests. The bundle
  cannot be refreshed on this branch once `0230` reruns (`vignette_method.R:87` evidence md5, `:179` and `:232`
  reconcile/`fdis_sites` vs the newest ledger). Change: name both failing tests in Validation and the PR, drop "CI is
  green", and keep the `vignette_method.R` rerun in #92's tasks.

### Gap
- **Probe misses subsurface 1425.** `fresh_default_20261017.streams` holds 353 edge_type 1425 segments (queried);
  `fwa_indexpoint()` snaps to them and link places them today; fresh's guard (`fresh/R/utils.R:749-758`) and the
  plan's `exclude_edge_types = c(1425L, 6010L)` move those visits. Add a `subsurface` class to Phase 1 and a reconcile
  row.
- **Quality `info` rows never reach the evidence ledger.** `0310:111` binds only `kind == "drop"` from `q$ledger`.
  Bind `drop` and `info`.
- **Register parser and `Sys.getenv()`.** `.knw_where_value()` unwraps only a bare `Sys.getenv(var, default)`
  (`R/settings_register.R:55`); `Sys.getenv()` returns character, so `as.numeric(Sys.getenv("SNAP_LIMIT", 100))`
  falls to `eval(rhs, baseenv())` and reads the live variable. Write `snap_limit <- Sys.getenv("SNAP_LIMIT", 100)`
  (numeric literal, as `0330:71`'s `tuned_as`) and coerce at use, or extend the parser. Three places must agree:
  script default, `fn:knw_fdis_place` default, register value.
- **Worked example asserts nearest == placed.** `vignette_method.R:261-268` ranks raw `fwa_stream_networks_sp` with
  no fresh guards and `:284-286` stops when the nearest is not the placed stream: a moved example fails by design, and
  a confirmed-nearest one fails wherever the raw nearest is an unmapped/999/1425 line. Phase 5 needs the guards in
  `near()` and a per-example assertion.
- **fresh version gate.** `col_blk` and the one-query snap arrived in fresh 0.40.0 (`fresh/NEWS.md:14-21`);
  `DESCRIPTION` lists `fresh` in Suggests unpinned. Add a `packageVersion("fresh") >= "0.40.0"` stop in `0230` as
  `0310:70-72` does for link.
- **Tracked tables rewritten twice.** `data/fdis_evidence.csv` (`0240:166`) and `data/fdis_repeat_surveys.csv`
  (`0230:547`) are tracked; the SNAP_LIMIT=500 run writes an `fdis_evidence.csv` with `flag_far_snap` all FALSE. Say
  that Phase 4's outputs are committed and the 500 m ones are not.
- **Sensitivity inputs unnamed.** `knw_tune_run()` also needs `species_tbl`, `walks`, `thresholds` at the ledger's
  `run_link_sha` (two SHAs, read as `0320:134-150`), `thresholds_extra` = default_tuned (else the grid lacks
  `is_link_tuned` and differs from 0320's), `species = c("CH","BT")`, `stages = "rear"`. Cost is small (DEV logs: 22
  keys in 0.7 min). `knw_fdis_place()` must also accept integer64 ids: `0230:416`'s connection has no
  `bigint = "numeric"` and `frs_point_snap()` returns via `sf::st_read` (`fresh/R/frs_db_query.R:23`).

### Ordering
- **Ledger overwrite.** `0310` writes `<yyyymmdd>_evidence_build_ledger.csv` (`0310:66-67`); Phase 3's 500 m run
  and Phase 4's final run on one day overwrite each other, and the ledger is tracked. Copy or suffix the 500 m ledger
  before Phase 4, or the sensitivity loses its provenance.
- **Phase 4's cache hits assume wet's load is unchanged** between Phases 3 and 4 (key `load_md5`,
  `R/link_walks.R:34-39, 248`); a wet reload (as on 2026-10-19) makes the rerun cold. State it.

### Assumption
- **"Whole-metre measures miss the cache" is not why the first run is cold.** `0310` never passed `cache` (no visit
  walk was ever written); `knw.walk_cache` holds 3.6 M starts, 1.9 M whole-metre, all from grade segment ends. Whole
  metres may even *gain* hits where a visit lands on a link break. Reword to "0310 never cached its walks"; the
  hit/miss ledger row settles it.
- **"Confirmed" is weaker than "the coded stream".** With "the nearest key wins among hits", a multi-key code (30 %
  map to >1 key) can confirm a different 20k tributary than the one coded. Have the probe report confirmed picks by
  keys-per-code and define confirmed that way in the write-up.
- **The gate rule keeps a confirmed pick to 500 m with an unconfirmed stream 20 m away.** The issue's
  disagreement-by-distance table is about *nearest* snaps, so it does not support that band for moved picks. The
  `confirmed ∈ {200, 500}` cells should report moved picks by move distance so the gate has a number.
- **Floored measures vs `knw_link_place()`'s window** `[m-1, m+5]` (`R/link_place.R:98, 115-117`): a point floored
  below a link break lands on the downstream segment. `segment_starts_in_window` (`0310:153`) before/after is the
  check; name it in Phase 4's ledger item.

### Scope
- `data/fdis_evidence.csv` binds by row with `data/fiss_evidence.csv` (`0240:164-165`); `0250` keeps
  `fwa_indexpoint()` and a 100 m `flag_far_snap` (`0250:56-57, 294`): one column, two meanings. Note it in `0240`'s
  header or #92.

### Confirmed (no change needed)
- `frs_point_snap(col_blk=)`: per-row lateral with `(p.hint IS NULL OR s.blue_line_key = p.hint)`
  (`frs_point_snap.R:407-410`), so same-point/different-hint rows are independent; id must be unique and non-missing
  (`:283`); `sf` EPSG:3005 accepted (`:248`); returns `distance_to_stream`, `linear_feature_id`, whole-metre measure
  (`:434-437, 451-459`).
- `0310` gate on `SCHEMA=fresh_default_20261017` passes: its `log_recompute` run is `20261017_004619-3f4c713b`, the
  settle log's; `knw_build_record()`'s `string_agg … ORDER BY` is identical for one run and keeps the refusal
  (`R/build_record.R:34-45`).
- `visits_link.csv` carries every `sites` column but `geom` (`0310:112, 295`), so `distance_to_stream`,
  `snap_confirmed`, `snap_method` ride through; downstream of `knw_fdis_quality()` is a pure row filter (only `aoi` at
  `0310:117` depends on the set, by group, negligible).
- Moving the chinook `code:` pointer to the note is consistent: the register test and `vignette_method.R:149` iterate
  `where` only (`test-settings-register.R:58`).

## Disposition (folded into `task_plan.md` before the baseline)

Verified before acting: `.github/workflows/` holds the two files named and neither runs tests; #98 ("Add R CMD
check workflow") is open; `vignette_method.R:380-387` lists `f_pipeline`, `f_settings` and the ledger among the
sources whose tracked md5s the bundle pins. Both parts of the blocker hold.

| finding | where it landed |
|---|---|
| Blocker: second red test, no test CI | Context bullet "Two tests go red…", gate decision 1, Validation |
| subsurface 1425 | Phase 1 class; exclusion set read off the counts; reconcile row `sites_snap_subsurface_excluded` |
| `info` rows not ledgered | Phase 3, `0310` binds drops and info |
| `Sys.getenv()` form | Context bullet on the register parser; Phase 2's constants |
| worked example asserts nearest == placed | Phase 5, `vignette_method.R` |
| fresh version gate | Phase 1 (the probe) and Phase 2 (`0230`) |
| tracked tables rewritten by the 500 m run | Phase 2's run restores `fdis_repeat_surveys.csv` and skips `0240`; Phase 4's outputs are the ones committed |
| sensitivity inputs; integer64 ids | Phase 4's call named in full; Phase 2's `knw_fdis_place()` only compares ids |
| ledger overwrite | Phase 3: the 500 m ledger copied aside under `scripts/logs/fdis/` |
| wet load between runs | Phase 4's rerun bullet |
| cache cold for the wrong reason | Context bullet reworded: `0310` never cached its walks |
| "confirmed" with multi-key codes | Context bullet: confirmed = any 20k stream the code names (today's `any(hit)`); probe reports by keys-per-code; Phase 5 defines it |
| confirmed-limit band unsupported | Gate decision 2 and Phase 4: moved picks by move distance and the nearest's distance |
| floored measures vs the window | Context bullet; `segment_starts_in_window` in Phase 4's ledger item (already there) |
| Scope: `fdis_evidence.csv` vs `fiss_evidence.csv` | Phase 2's `0240` header note; "Not inside" names `0250` |
