# Findings — Place FDIS sites with candidate snapping and the 1:50k code, not nearest-then-reject (#91)

## Issue context

## Problem

`scripts/0230` places each FDIS visit by snapping its UTM point to the nearest Freshwater Atlas stream
(`fwa_indexpoint()`, 500 m search) and then rejects doubtful placements: 5,242 visits (10 % of 51,587) because the
nearest stream is 100–500 m away, and 1,088 because the FDIS 1:50k watershed code disagrees with the stream the point
landed on. The 100 m limit was inherited from the one-species builds with no recorded reason or sensitivity test.

Where the 1:50k code can check a placement (it names a tributary on 12,285 of the 50,024 placed visits), disagreement
rises with distance: 8 % within 25 m, 18 % at 25–50, 28 % at 50–100, 34 % at 100–200 and 57 % at 200–500 m. So distance
predicts a wrong stream, but two-thirds of the 100–200 m snaps agree with their code: the cut throws away many good
placements, and a near snap to the wrong stream is rejected rather than moved to the right one.

## Measured (2026-10-26)

A probe on the 50,550 sites with coordinates, from a scratch script (not committed; item 1 reruns it from a
committed one):

- fresh 0.42.0's `frs_point_snap()` snaps the whole set in one lateral query (NewGraphEnvironment/fresh#247, since
  0.40.0): 6.3 s nearest only, 12.7 s with five candidates, against 125.9 s for `0230`'s `fwa_indexpoint()` lateral.
  `link::lnk_points_snap()` runs the same query on a table and is to be wrapped or retired in favour of fresh's
  (NewGraphEnvironment/link#314), so this issue uses fresh's.
- **The candidate population differs.** fresh refuses placeholder (`999.*`), unmapped (null local code) and subsurface
  (edge type 1425) segments and admits 6010 connectors; `fwa_indexpoint()` refuses only 6010. Nearest-only picks differ
  in stream on 1,551 of the 49,922 visits both place: under `fwa_indexpoint()`, 1,474 of them sit on an unmapped
  tributary and 174 on a placeholder (some both), 1 lands on a 6010 connector under fresh, and 29 are ties. Another 102
  visits `fwa_indexpoint()` places have no fresh candidate within 500 m. On the 48,238 visits both put on the same
  segment the measures differ by under 1 m (fresh rounds to the metre).
- **fresh's candidates are segments, not streams.** `fwa_indexpoint()` returns the nearest segment per distinct stream;
  fresh's five nearest can be five pieces of one stream: of 36,177 visits with five candidates, 6,401 had all five on one
  stream, 17,322 on two and 26,199 on three or more. The 1:50k pick needs one candidate per stream, so reduce to that
  before `frs_candidates_pick()` or raise `num_features`.
- fresh's default tolerance is 100 m: pass the search radius explicitly.

## From reading fresh (2026-10-27)

- `fresh::frs_candidates_pick()` keeps one row per key (`DISTINCT ON (col_key)`, here the visit), not one per stream.
  The per-stream reduction this issue needs is not in fresh. If it is needed, it belongs there, because link needs it too
  when it retires `lnk_points_snap()` (NewGraphEnvironment/link#314): a fresh issue, linked from here.
- `fresh::frs_point_snap()` takes a `blue_line_key` hint: "a point with a hint snaps only to that stream". Translating
  each visit's FDIS 1:50k code to `blue_line_key` through `fwa_streams_20k_50k` and snapping with the hint, falling back
  to nearest where there is no code, may replace candidates-then-pick altogether. The probe (item 1) measures how often
  one 1:50k code maps to more than one key; file the fresh issue only if the hint route fails.

## Proposed

1. **Probe first**, from a committed script: rerun the comparison above, then find what `knw_link_place()` does today
   with the 1,474 visits on unmapped tributaries and the 102 with no fresh candidate (if link's segments follow the
   same rule, they are already dropped or moved at the link step, and placement changes less than the counts suggest).
   Then what nearest-then-reject keeps against what candidate snapping would keep, and where the two put a visit on
   different streams.
2. **Snap with candidates.** `0230` moves to `fresh::frs_point_snap()` with several candidates per visit
   (`num_features`), reduced to one per stream, then `fresh::frs_candidates_pick()` prefers a candidate on a stream the visit's 1:50k code names
   (through `fwa_streams_20k_50k`), falling back to the nearest within a stated limit. The fresh function also excludes
   placeholder, unmapped and subsurface lines.
3. **The limit by measurement**, with the sensitivity reported (how the evidence and a key's pick move with it).
4. **The ledger** counts kept, moved and dropped, and why.
5. **`0310` for the retune** (from #87): it still hardcodes `schema <- "fresh_default"` and walks the visits uncached.
   Give it `SCHEMA` as `0320` and `0330` take it (one retune names the schema its evidence was built on), and
   `cache = "knw.walk_cache"` on its `knw_link_walks()` call, so the visit walks are kept like the grade's.

Placement changes the evidence, so it ends in a full retune (evidence, score, grade, compare), run with #92's gradient
change so one retune covers both, and written up with #90's generated reports.

Once `0230` uses fresh's snap, the `fwa_indexpoint()` changes in NewGraphEnvironment/fwapg PR #43 no longer affect
placement.

## Depends on

#87 (a retune in hours, not days); the methodology article (#93) is drafted first, so the fixes it surfaces join
this retune. Related: NewGraphEnvironment/link#314 (link's own `lnk_points_snap()`,
to be wrapped or retired in favour of `fresh::frs_point_snap()`, so the network has one snap).

## Plan-mode exploration (2026-10-27, read-only; the plan's Context restates the conclusions)

### Code as it stands

- `scripts/0230-fdis-load.R:415-474`: points written to a temporary table, `fwa_indexpoint(geom, 500, 1)` lateral,
  stream attributes joined by `linear_feature_id` from `fwa_stream_networks_sp`, `_channel_width`, `_discharge`; the
  1:50k check joins `fwa_streams_20k_50k` on (`watershed_code_50k`, `blue_line_key`) over every checkable code of the
  visit (codes pooled across repeat copies, #35); flags `flag_not_placed`, `flag_far_snap` (> `snap_flag_m` = 100),
  `flag_ws50_mismatch` (checked, known, no hit). Constants `snap_tol_m` = 500, `snap_flag_m` = 100 at lines 54-55.
- `R/fdis_quality.R`: drops in order `not_placed`, `far_snap`, `ws50_mismatch`, `junk_date`,
  `effort_sentinel_or_none`, `catch_unknown`; asserts the ledger partitions the input.
- `scripts/0310-evidence-build.R:56`: `schema <- "fresh_default"` hardcoded; `:100-102` a hand-rolled check of
  `<schema>.log_recompute`'s `run_uid` against the newest settle log; `:111` binds only `kind == "drop"` rows of the
  quality ledger; `:171` `knw_link_walks(pg, starts, q_grid, sources, workers)` with no `cache`; `v` is
  `knw_fdis_quality()$kept` (every `sites` column) joined to `knw_link_place()$placed`, written as `visits_link.csv`
  less `geom`.
- `R/link_place.R`: window `[m - 1, m + start_window_m]` for a segment start, else the containing segment.
- `R/link_walks.R`: the cache keys on (`blue_line_key`, `downstream_route_measure`, `src`, `load_md5`, `walk_md5`).
- `R/settings_register.R:55`: a `script:` row's value is the default of a bare `Sys.getenv(var, default)`;
  `tests/testthat/test-settings-register.R` holds `fn:`, `script:` and `code:` rows to the code.
- `inst/method/settings.csv` rows that point at `0230`: `snap_search` (`script:...:snap_tol_m`), `snap_limit`
  (`script:...:snap_flag_m;code:vignettes/chinook_rearing.Rmd:stream lay within {value} m and`), `ws50_code_length`,
  `ws50_code_zeros` (both `code:` on `0230`'s literals); `pipeline.csv` step 2 names `fwapg::fwa_indexpoint`.
- `data-raw/vignette_method.R`: reads the newest evidence ledger, `reconcile.csv`, the derived tables and
  `fdis_sites.csv`; stops unless the derived tables' md5s equal the grade tables' `evidence_md5` (`:87`); its worked
  example ranks raw `fwa_stream_networks_sp` within `snap_search` with no fresh guards and stops unless the nearest
  is the placed stream (`:261-286`); its tracked sources (pinned in `method.rds`) include `settings.csv`,
  `pipeline.csv` and the ledger (`:380-387`).
- `tests/testthat/test-vignette-data.R`: "every tracked source … unchanged" skips only where `data/` is absent
  (`data/` is tracked, so never on a clone); "every ignored source … unchanged" skips where the ignored build is
  absent.
- `.github/workflows/`: `pkgdown.yaml` and `update-citation-cff.yaml` only; no workflow runs the tests (#98 open).
- `scripts/0240-fdis-evidence.R:134-144`: the `fdis_sites.csv` column list (carries `distance_to_stream`,
  `gnis_name`, `flag_*`, `ws50_checked`); `:159-166` `data/fdis_evidence.csv` (tracked) carries `flag_far_snap` and
  `flag_ws50_mismatch` and binds by row with `data/fiss_evidence.csv`, whose `0250` keeps `fwa_indexpoint()` at 500 m
  and a 100 m `flag_far_snap` of its own (`0250:56-57, 294`).
- `scripts/0320-tune-run.R:76`: `schema <- Sys.getenv("SCHEMA", "fresh_default")`; `:134-150` reads link's
  `default` and `default_tuned` thresholds at the ledger's `run_link_sha` (two SHAs possible); `:190`
  `knw_tune_run(vl, vs, walks, thr, species, spawner, workers, cache_dir, thresholds_extra, smoke = FALSE, extra,
  evidence_id)`; `DEV=1` writes under `data/tune/dev/` (ignored), main seed only, no grades.
- fresh 0.43.0 installed (the issue measured 0.42.0; `frs_point_snap()`'s bulk form and `col_blk` arrived in
  0.40.0). `frs_point_snap.R:392-470`: the lateral `WHERE ST_DWithin(s.geom, p.geom, tol) AND localcode_ltree IS NOT
  NULL AND NOT wscode_ltree <@ '999' AND edge_type NOT IN (1425) [AND (p.hint IS NULL OR s.blue_line_key = p.hint)]
  ORDER BY s.geom <-> p.geom, linear_feature_id LIMIT num_features`; measure
  `CEIL(GREATEST(ds, FLOOR(LEAST(us, located))))`; an `sf` input's CRS gives the SRID; `col_id` must be unique and
  non-missing; data frames and `sf` go to the database as a temporary table (one session per call).
  `frs_candidates_pick()` is `DISTINCT ON (col_key)` with a caller-written score, filter and `ORDER BY`, writing a
  real table (`DROP` + `CREATE TABLE`).
- link: `lnk_pipeline_prepare.R:836-838` keeps only `localcode_ltree IS NOT NULL AND wscode_ltree <@ '999' IS FALSE`
  lines when it builds its streams; `lnk_points_snap.R:97` excludes unmapped lines on snap and 1425 by default.

### Database (read-only, 2026-10-27, through `~/.Renviron`'s `PG*`)

- `whse_basemapping.fwa_streams_20k_50k`: columns `stream_20k_50k_id`, `watershed_group_id_20k`,
  `linear_feature_id_20k`, `blue_line_key_20k`, `watershed_key_20k`, `fwa_watershed_code_20k`,
  `watershed_group_code_20k`, `blue_line_key_50k`, `watershed_key_50k`, `watershed_code_50k`,
  `watershed_group_code_50k`, `match_type`. 293,445 distinct non-null `watershed_code_50k`; 86,762 map to more than
  one `blue_line_key_20k`; median 1, 90th percentile 2, 1,248 over five, 185 over twenty, max 422.
- `fresh_default.log_recompute`: run `20261023_074321-24d85e8c`; `fresh_default_20261017.log_recompute`: run
  `20261017_004619-3f4c713b` (the only settle log, `scripts/logs/habitat/20261017_link_settle.csv`, is this run's).
- `fresh_default_20261017.streams`: 0 unmapped lines, 0 placeholder (`999`) lines, 0 edge 6010, 353 edge 1425
  (the plan review's count).
- `discharge.fwa_v1_segment_monthly` comment: "wet_db_load(): discharge/fwa/v1/segment_monthly, scenario historical
  last loaded from … (built 2026-10-19T06:08:31Z, wet 94deeb5)".
- `knw.walk_cache`: 4,459,402 walks (the grade's segment-end starts; `0310` never wrote to it).

### What follows for the design

- The 1,474 unmapped and 174 placeholder picks under `fwa_indexpoint()` cannot reach link's segments: they are
  today's `no_link_segment` drops (1,491 in the 2026-10-22 ledger). fresh snaps those visits to the next mapped
  stream, so some of the 1,491 come back as placed visits.
- The hint route (one hinted row per visit × key of its checkable codes, plus a nearest row) replaces
  candidates-then-pick: it needs no per-stream reduction and cannot miss the coded stream when one is within the
  search. The pick is a pure function of the two snap results and two limits.
- `0310` can only pass its settle gate on `fresh_default_20261017`.
- The register files are tracked sources of the methodology bundle, so any register change fails
  `test-vignette-data.R` on every clone until `data-raw/vignette_method.R` is rerun, which needs the grades to match
  the evidence: the retune. No workflow runs tests, so GitHub shows nothing.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `psql` in the agent shell: `connection to server on socket "/tmp/.s.PGSQL.5432" failed` (no `PG*` in the shell) | R reads `~/.Renviron`, so the probe ran through `Rscript -e` with `DBI`; `cat()` of an `integer64` count prints a denormal double, so cast with `as.numeric()` or read it through `print()` |
