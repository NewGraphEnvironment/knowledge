# Code-check round 1: branch 91-place-fdis-sites-with-candidate-snapping

## Checklist read

- `code-check-python.md` (7,237 bytes): in full.
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms` (tables skipped). The other 23 headings (Rules that stand alone, Security, Spreadsheets and PDFs) not read.
- `code-check-r.md`: read 12 of 111 headings: "Postgres row order is never fixed…", "`sprintf("%g", x)` writes `Inf`…", "A database driver's value is not a base R type", "`ifelse()` with an all-NA test…", "`match()` treats NA as a matchable VALUE", "Rscript reads a script as it runs", "A `data-raw/` script must load the source tree", "`on.exit()` at a script's top level never fires", "`system2(stdout = TRUE)` warns…", "Inside a dplyr verb, a column named like a local variable wins", "`paste()` with a zero-length argument…", "`summarise()` and `mutate()` evaluate in order". 99 not read.
- `code-check-spatial.md`: read 2 of 93 headings: "FWA main flow is not edge type 1000 alone", "FWA `upstream_route_measure` misses the next segment's start". 91 not read.
- `code-check-shell.md`: 0 of 67 read. The diff has no shell code.

## How this was checked

- Ran `test-fdis_place.R`, `test-fdis_quality.R` and `test-settings-register.R` in a `git archive HEAD` copy: 0 failed, 0 errors (25, 13 and 261 passing).
- Read fresh 0.43.0's `frs_point_snap()`. A hinted point is constrained by `(p.hint IS NULL OR s.blue_line_key = p.hint)`, and candidates are ordered `geom <-> geom, linear_feature_id`, which is a unique key. `fwa_streams_20k_50k` has no NULL `blue_line_key_20k` (0 of 2,156,444 rows, read-only query), so no hinted row reaches the snap unconstrained.
- Checked the research numbers against `scripts/logs/fdis/20261027_*`, both evidence ledgers and the local `data/fdis/derived/visits_link.csv`. That file is the 10-27 build: `sites.rds` md5 8410465… matches the ledger. Most numbers reproduce. The exceptions are below.

## Findings

- **[bug] (prose)** `research/fdis_export.md:187-190`: "neither key's pick ever fell outside another cell's one-SE region" and CH rearing's pick "staying inside every region" are false against `scripts/logs/fdis/20261027_snap_limit_sensitivity.csv`. CH rearing's pick at 200/200 (`mad>=0.75|g<=0.13|Q3@D1000`) is not in the 500/500 cell's 51-rule region. I checked every pick against every cell's region, and this is the only miss. The decision is unaffected, because the pre-registered rule compares only the five pairs in the `pairs` table, and all five are FALSE. The sentence quantifies over all cells, though, so it should say "between the pairs the rule compares" or name the exception.

- **[bug] (prose)** `research/fdis_export.md:206`: "Of the kept visits, 10,247 are confirmed by their code and 754 were moved" sits under the table whose kept row is 45,523. The 10,247 and 754 come from `knw_fdis_quality()`'s `info` rows, which count the visits kept before 0310's `no_link_segment` drop (178). Among the 45,523 rows of `visits_link.csv`, 10,210 are confirmed and 748 were moved. The same off-by-a-step reading is invited by 0310's ledger, where `kept_snap_confirmed` and `kept_snap_moved` sit just before `no_link_segment` and look like counts of `visits_kept`.

- **[bug] (prose)** `research/fdis_export.md:149-151` says "link's segments carry none of the first three kinds" (unmapped, placeholder, subsurface flow), "so a visit `fwa_indexpoint()` put on one could never be placed on link's segments". That is false for subsurface flow:
  - `fresh_default_20261017.streams` holds 353 segments with `edge_type = 1425` (read-only query).
  - The probe's own table (`20261027_snap_candidate_check.txt`, "Old-snap visits that link cannot place") shows link placed all 5 old picks on 1425 lines (`subsurface 1425  5  5  0`).

  The `0230` header (`scripts/0230-fdis-load.R:40-41`, "a visit whose nearest line is one of those reaches the next stream link can place it on") carries the same implication.

- **[bug] (prose)** `research/habitat_thresholds_tuned.md:60`: "never lands on an unmapped, placeholder, subsurface or connector line" is false for connectors. `snap_edges_excluded` is `c(1425L, 6010L)`, so only 6010 connectors are excluded. 1400, 1410 and 1450 are also connector edge types (fresh's `edge_types.csv` classes them `connector`), and they stay candidates. In the current `sites.rds`, 1,932 placed picks sit on them: 1400: 205, 1410: 136, 1450: 1,591. `fdis_export.md` qualifies this correctly ("connectors (6010)"). The `0230` header (line 40, "drops subsurface flow and connectors") and the `snap_edges_excluded` register note leave out the code, so they can be read the same wrong way.

- **[fragile]** `scripts/0230-fdis-load.R:67-68,470,518-523`: the limits that set `flag_far_snap` come from `SNAP_LIMIT` and `SNAP_LIMIT_CODE` when those are set. The resolved values are written nowhere: not to `reconcile.csv`, not to the log message, not to `fdis_sites.csv`, and not to 0310's ledger. A shell left with `SNAP_LIMIT=500` exported from the sensitivity run would build the published evidence at 500 m.
  - Nothing downstream can tell; only the `sites.rds` md5 differs.
  - The settings-register test still passes, because it reads the `Sys.getenv()` default.
  - `data-raw/vignette_method.R` would print "more than 200 m" from the register for a 500 m build.

  This is the "a run's record travels with its table" rule. Fix: `add("snap_limit", …)` and `add("snap_limit_code", …)` (or the values in the message), so that readers can compare them.

- **[fragile]** `data-raw/snap_candidate_check.R:11,68-69`: the probe treats `data/fdis/build/sites.rds` as the `fwa_indexpoint()` placement and never checks that it is. After this branch's `0230` run, the stored file is the new placement. A rerun would then classify the new snap against itself and overwrite that day's `_snap_candidate_check.{txt,csv.gz}`; only a printed "NOT reproduced" would mark it. A guard would close this: refuse when `sites.rds` has a `snap_method` column, or when its md5 is not `98d4d6dd…`.

No defects found in `R/fdis_place.R`, `R/fdis_quality.R`, the 0230 snap wiring (hint join, `hid` round trip, attribute query, band partition), 0240's `bigint` and `format()` change, 0310's `SCHEMA` gate and walk cache, or the register rows.
