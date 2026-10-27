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
- `.github/workflows/`: `pkgdown.yaml` and `update-citation-cff.yaml` only; no workflow runs the tests yet (#98, an open PR adding R CMD check).
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

## Phase 1: the probe (2026-10-27, `data-raw/snap_candidate_check.R`)

Run 2026-10-27T17:09Z on fresh 0.43.0, schema `fresh_default_20261017`, from a machine on a remote link to the
database (about 170 ms a round trip); 2.1 min. Log: `scripts/logs/fdis/20261027_snap_candidate_check.{txt,csv.gz}`.
The old snap is the placement `0230` stored on 2026-10-17 (`sites.rds`), not a rerun of `fwa_indexpoint()`.

- **Today's path reproduced:** `knw_fdis_quality()` then `knw_link_place()` on the stored placement keeps 42,043 and
  drops 1,491 as `no_link_segment`, the 2026-10-22 ledger's number.
- **Classes** (first match; they partition the 50,550 visits with coordinates), with link placement under each snap:

  | class | n | link places, old snap | link places, new nearest |
  |---|---|---|---|
  | same_segment | 48,241 | 47,848 | 48,050 |
  | old_unmapped | 1,347 | 0 | 1,347 |
  | neither | 526 | 0 | 0 |
  | old_placeholder | 174 | 0 | 165 |
  | same_stream | 131 | 107 | 131 |
  | old_only (no fresh candidate in 500 m) | 102 | 2 | 0 |
  | tie | 29 | 29 | 29 |
  | other | 0 | | |

  On one segment the two measures differ by at most 1.000 m (fresh's whole metre). link places 202 more
  same-segment visits under the new measure than the old: the floored metre lands differently at link's breaks.
  Of the old snap's 2,038 link misses, 224 are placeholder picks and 1,421 unmapped ones (not placeholder), and 393
  other. The placeholder picks are the 174 `old_placeholder` and 50 of the 102 `old_only` (fresh has no mapped
  stream within 500 m); the unmapped ones are 1,347 `old_unmapped`, 50 `old_only` and 24 `same_stream` (an
  unmapped segment of a mapped line).
- **Exclusion set:** with no edge type excluded, the nearest line is subsurface (1425) for 13 visits and a connector
  (6010) for 3. link's streams carry 1425 and lack 6010; the old snap's five 1425 picks all reach a link segment.
  The counts are small either way, so the default stands on fresh's convention plus the connector:
  `exclude_edge_types = c(1425L, 6010L)`.
- **Unmapped and placeholder visits re-snap to a mapped stream a median 135–151 m away, but not to a worse one.**
  Where the 1:50k code checks them (186), the new nearest agrees with the code by distance band as often as an
  ordinary same-segment snap does: 0.917 against 0.925 within 25 m, 0.879 against 0.833 at 25–50, 0.707 against
  0.732 at 50–100, 0.629 against 0.672 at 100–200, 0.458 against 0.439 at 200–500 (from the csv.gz). So the
  distance limit governs them like any other visit and no rule of their own is needed. At the provisional limits
  (100 m unconfirmed, 500 m confirmed) 510 of the 1,521 come back (160 confirmed, 350 unconfirmed).
- **The hint route covers the codes; no fresh issue is filed.** Every one of the 12,285 visits with coordinates and a
  checkable code has exactly one code. 10,889 have a code `fwa_streams_20k_50k` knows (1,396 codes map to no key:
  unchecked, as today). Keys per code on these visits: 1 for 4,045, 2 for 3,039, 3–5 for 2,222, 6–20 for 1,195,
  over 20 for 388. 58,269 hinted rows snapped in 8.5 s. Routes: 10,433 confirmed, 456 no hit within 500 m (a drop),
  39,055 unconfirmed, 606 not placed.
- **Confirmed picks by keys** (the union over the visit's codes; "confirmed" means on some stream the code names):
  1 key 3,868 (301 moved), 2 keys 2,925 (187), 3–5 keys 2,113 (155), over 5 keys 1,527 (144). 787 moved in all.
- **Moved picks: the move against the nearest.** 179 move within 25 m; 56 visits 0–25 m from their nearest stream
  move 200–500 m to the coded one, which is where the confirmed limit matters (Phase 4).
- **The issue's check under the new nearest snap** (checkable, placed): disagreement 7.5 % within 25 m, 16.6 % at
  25–50, 27.1 % at 50–100, 33.2 % at 100–200, 55.8 % at 200–500, against the issue's 8/18/28/34/57 on the old snap.
  Under the rule at the gate (the widest band whose disagreement stays under one in three) 100–200 m is at
  33.2 %, just under one in three, so the unconfirmed limit is 200 m before the region check; Phase 4 settles it.
- **Preview at 100/500** (before link): `far_snap` 5,242 → 5,524, `ws50_mismatch` 1,088 → 456, not placed
  1,563 → 1,643, kept 42,043 → 42,286; link then places the unmapped and placeholder visits it could not before.
- **0230 differs from the probe in one input:** the probe takes codes from `fish.rds`, which lacks the codes 0230
  pools from dropped repeat copies; 0230 itself has them.
- fresh#266 (open) proposes a new tie rule (the segment starting at the shared vertex). Ties are 29 visits here
  and both rules put them on one stream; a change there moves a visit between two segments of its stream.

## Phase 4: the limits and the evidence before and after (2026-10-27)

`data-raw/snap_limit_sensitivity.R` (24.8 min, 14 workers; `scripts/logs/fdis/20261027_snap_limit_sensitivity.{txt,csv}`,
the 500 m build's ledger copied beside them): code-checked disagreement by the nearest stream's distance is 7.5 %,
16.6 %, 27.1 %, 33.2 % (126 of 379) and 55.8 % in the five bands, so the rule's unconfirmed limit is 200 m, the
100–200 m band clearing one in three by 0.1 point. In none of the five pairs the rule compares did a key's region move, so
neither limit stepped down. (Across all 36 ordered pairs of cells, one pick falls outside another's region: CH's at
200/200 is outside the 500/500 cell's; review round 1 caught an earlier sentence here that said none did.) The regions are wide, 51 to 244 rules, so the
region check is weak: CH rearing's pick is `mad>=0.75|g<=0.15|Q3@D1000` at 200/500 and `mad>=0.15|g<=0.3|Q3@D2000`
at 100/500, each inside the other's region. BT rearing's pick is `mad>=0.1|g<=0.25|none` in all six cells.
Chosen: `snap_limit` 200 m, `snap_limit_code` 500 m.

The evidence ledger before (2026-10-22, `fwa_indexpoint()`, 100 m, today's schema) and after (2026-10-27, final):

| step | before | after |
|---|---|---|
| visits in | 51,587 | 51,587 |
| not placed | 1,563 | 1,665 |
| far snap | 5,242 | 1,941 |
| 1:50k code mismatch | 1,088 | 377 |
| junk date | 23 | 23 |
| no effort | 1,353 | 1,593 |
| unknown catch | 275 | 287 |
| no link segment | 1,491 | 178 |
| kept | 40,552 | 45,523 |
| kept, confirmed by the code | | 10,247 |
| kept, moved to a named stream | | 754 |
| segment start within the window | 19,255 | 22,877 |
| walk starts | 34,192 | 36,925 |
| walk cache hits / misses | (uncached) | 110,775 / 0 |

`0230` (`scripts/logs/fdis/20261027_fdis_load.log`): placed 49,922, unconfirmed 39,483, confirmed 10,439, moved 785,
far 1,941 (every unconfirmed pick beyond 200 m), code with no named stream in reach 434, 16 visits whose nearest
line is subsurface or a connector. The 500 m build's `0310` walked 113,658 start-and-source pairs cold in 6.4 min
from the remote link and cached them; the final run read all 110,775 it needed in 0.7 min. wet's flow load was the
2026-10-19 one throughout.

## Phase 4's rule, fixed before the run (2026-10-27)

"A key's region moves" between two limits means either limit's pick lies outside the other limit's one-SE region
on the main fold seed. The unconfirmed limit starts at the widest band whose code-checked disagreement (a checkable
visit whose nearest stream its code does not name) stays under one in three, then steps down one cell for as long
as CH or BT rearing's region moves between it and the next smaller cell; the confirmed limit is 500 m unless a
region moves between 200 and 500 m at the chosen unconfirmed limit. Written into `data-raw/snap_limit_sensitivity.R`
and committed before it ran.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `psql` in the agent shell: `connection to server on socket "/tmp/.s.PGSQL.5432" failed` (no `PG*` in the shell) | R reads `~/.Renviron`, so the probe ran through `Rscript -e` with `DBI`; `cat()` of an `integer64` count prints a denormal double, so cast with `as.numeric()` or read it through `print()` |
| `0310`: `'wet_catalog' is not an exported object from 'namespace:wet'` (this machine's `wet` was a 2026-10-01 dev build; the 2026-10-22 build ran elsewhere) | installed `wet` v0.4.23 (`pak`, `upgrade = FALSE`: `fresh` 0.43.0 and `link` 0.66.0 unchanged); link's species pooling md5 is the same at 0.66.0, 0.67.0 and main and is ledgered |
