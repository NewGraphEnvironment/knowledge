# Findings — The grade reads segments that pass the size test at the 50 km distance cap (#65)

## Issue context

**If done:** a segment's grade reads the curve at the segment's own distance to a river whenever the curve was fitted on distance, so a large stream beside a river grades like the visits the curve learned from, and `knowledge/habitat_grade/v1` is corrected before its first publication. **If never:** every segment that passes its species' size test is graded as if 50 km from any river, which understates it wherever a river is close, and every graded-km and graded-ha figure built on the grade (the comparison's, the floodplain's) carries that bias.

## Problem

`knw_tune_curve()` fits one surface, `te(log size, log distance to the pick's river)`, on visits that each carry their real walk distance. `knw_grade_species()` then walks only the segments the pick's exception could admit (accessible, stream branch, inside the gradient maximum, failing the size test) and gives every other segment `dist_m = NA`, which `knw_grade()` reads as the 50 km cap. Its roxygen says this is deliberate ("a segment passing the size test is graded on its size"), but on a joint surface the size effect depends on distance, so the cap is not neutral.

Reproduced from `data/tune/CH_rear_curve.rds`, gradient 3 %, reference rate 0.1457 (found while auditing #62's article):

| MAD (m³/s) | rate 100 m from a 3 m³/s river | rate at the 50 km cap | grade at 100 m | grade at the cap |
|---|---|---|---|---|
| 0.3 | 0.114 | 0.011 | 0.78 | 0.07 |
| 0.8 | 0.110 | 0.020 | 0.75 | 0.13 |
| 2 | 0.108 | 0.032 | 0.74 | 0.22 |

A 0.3 m³/s stream 100 m from a river is walked (it fails the 0.75 floor) and grades 0.78; a 0.8 m³/s stream at the same spot is not walked and grades 0.13. In the CH run 373,133 of 856,244 accessible segments were walked, so about 480,000 were graded at the cap.

Reach (settled 2026-10-19 in plan mode):
- **All eight fitted species × stage**, not only the two with an exception. `curve_dist_in_model` is TRUE for every fitted curve (`data/tune/*_summary.csv`): a pick with no exception fits distance to a `q_default = 10` m³/s river (`R/tune_curve.R:55`), and `knw_grade_species()` walks nothing for it, so every one of its segments sits at the cap (BT rearing, CO, GR, RB, ST, WCT: `walked=0` in the #57 logs). BT spawning walked 682,254 of 2.68 M accessible; CH rearing 373,133 of 856,244.
- `data/compare/*` graded km and km by grade class, `floodplain.csv` graded ha, the maps' grade and floodplain panels, and the 95th-percentile reference rate, which is taken over the capped grades.
- The thresholds themselves (`thresholds/v1`) do not depend on the grade and are unaffected.

## Decisions

- **Walk every gradable accessible segment**: accessible, size present and > 0, gradient present (`knw_grade()`'s own test), any edge type and any gradient. The curve reads distance for all of them, so a river-polygon segment takes its true distance (0 m where its downstream neighbour is already ≥ q; `inst/sql/ch_dist_profile.sql` starts strictly below the start measure) and a steep segment its own. About 9.3 M walks over the eight keys (BT's 2.66 M twice, at q 10 and q 3); CH's measured rate is 373 k walks in 6.0 min on 8 workers, so about 2.5 h in all.
- **`habitat_grade/v1` stays v1.** `s3://fresh-bc/knowledge/` holds only `fdis/`: #57 built thresholds/v1 and habitat_grade/v1 locally and left `PUBLISH=TRUE` open, so no consumer has read a capped v1 (link#346 is open). The corrected table is the first v1 published; the research file's revision and this issue record that #57's local build was capped. (The body first said v2.)
- A walk whose status is `none` (the sea before any river of q), `no_parent` or `too_many_hops` keeps `dist_m = NA` and so the cap, which is how `knw_tune_curve()` censored those visits (`R/tune_curve.R:64`). The grades table says which (`dist_status`).

## Plan

### Phase 1: walk every gradable accessible segment (`R/grade_species.R`, `R/grade.R`, `scripts/0320`)

- [ ] `knw_grade_species()` walks every accessible segment with a size > 0 and a gradient to the first river of `curve$q` (the pick's `exc_q`, or `q_default` when it has none) on the curve's source; the `pick$exc_q` gate, the edge-type filter, the gradient filter and the size-test filter go. `starts` are the unique `(blue_line_key, downstream_route_measure)` of that set.
- [ ] The grades carry `dist_status` (`found`, `none`, `no_parent`, `too_many_hops`, or `no_walk` for a segment outside the walk set); `dist_m` stays `NA` except where found. `counts` gains `walk_found`, `walk_none`, `walk_other` beside `walked`.
- [ ] Roxygen: `knw_grade_species()` describes the walk set as above (not "stream-branch segments"; wetland lines and river polygons are in it) and what the cap now means; `knw_grade()` L14-15 says a capped distance is far from a river of at least the curve's `q` (or the walk found none), not "far from any river".
- [ ] `tests/testthat/test-grade_species.R`: with `local_mocked_bindings()` on `knw_link_segments` (a small frame: accessible and not, with and without size, with and without gradient, edge types 1000/1250/2000, gradients above and below the pick's maximum, sizes above and below `size_min`) and `knw_link_walks` (records the `starts` and `q_grid` it was given; returns `found` for some, `none` for one), assert: every accessible gradable segment is a start and nothing else is; `q_grid` is `curve$q`; a size-passing segment near a river carries its distance; the `none` segment has `dist_m = NA` and `dist_status = "none"`; an inaccessible segment has `NA` grade. Restore-the-bug check: with the old `!size_ok` filter put back, the "size-passing segment is a start" assertion must fail.
- [ ] `scripts/0320-tune-run.R`: the keep-on-file check (L179-187) also requires `dist_status` in the table's header, so #57's capped tables are regraded under the same rule and `run_uid`; the spec comment (L25-28) and the OUTPUT line say the walk covers every graded segment.
- [ ] `/code-check` on the diff; commit.

### Phase 2: regrade, publish locally, compare

- [ ] CH first and alone: `SPECIES=CH Rscript scripts/0320-tune-run.R` (the scored grid is cached in `CH_rear_score.rds`, so only the grade runs). Record in `findings.md`: walk minutes against 6.0, `walked`/`walk_found`/`walk_none`, the reference rate against 0.1457, and the grade-class km shares against 76 % under 0.2 and 7 % at 0.8–1.
- [ ] The other seven keys (`SPECIES=BT,CO,GR,RB,ST,WCT`), on the 16-core host with `WORKERS=14` or locally; `PGCONNECT_TIMEOUT` set (#57's grading hang). BT walks twice (q 10 for rearing, q 3 for spawning); if the measured CH rate makes that unreasonable, share one walk at `q_grid = c(3, 10)` per species inside 0320 and say so.
- [ ] `Rscript scripts/0325-publish.R` (local; `PUBLISH` stays open as #57 left it). The `habitat_grade` description says the distance is walked for every graded segment. Assert `git diff --stat data/thresholds.csv data/thresholds_groups.csv` is empty.
- [ ] `Rscript scripts/0330-compare.R` for every species (full run, not `STAGE=maps`: the grade is read per segment), then `Rscript data-raw/vignette_chinook.R`, then `devtools::test()`.
- [ ] Commit the tune, compare and vignette-data outputs with the log paths in `progress.md`; the archive README's `Measurement` carries the before/after reference rates and graded km per key.

### Phase 3: revise the record

- [ ] `research/habitat_thresholds_tuned.md`: the Grade bullet of the method (every graded segment at its own walked distance to the curve's river; the cap is a walk that found none); the Grades table; the "What each rule changes" km table; the floodplain table and its paragraph (drop "provisional"); the Limits list if any limit moved; `Verified` date in the header; a dated revision note saying #57's grades were capped.
- [ ] `research/chinook_rearing_tuned.md` L34-39: graded km and graded ha under the corrected grade; drop "provisional until #65".
- [ ] `data-raw/vignette_chinook.R` L19-22 and `vignettes/chinook_rearing.Rmd`: the comment and any sentence that says the distance is measured only on exception candidates; the examples table's distance column now reads for the kept-by-both example. Render before and after, strip to text, diff: only the prose meant to change differs.
- [ ] `scripts/README.md` 0320 line; `NEWS.md` entry under the next version (the grade walks every graded segment; v1 corrected before publication; the two roxygen fixes).
- [ ] `/code-check branch`; `/planning-archive`; `/gh-pr-push`.

## Validation

- [ ] Tests pass (`devtools::test()`, including `test-vignette-data.R` after the vignette data rerun)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

## Not in scope

- Uploading thresholds/v1 and habitat_grade/v1 to the bucket (`PUBLISH=TRUE`), which #57 left open and which waits on #56's bucket policy.
- The floodplain catalog's missing groups (floodplains#123) and the gradient ladder for every species (#68).

## Reviews (2026-10-19)

Plan review: `review-plan.md`, each finding with its verdict. Code-check round 1: `review-round1.md`.

- **Both found the same blocker independently.** The parked plan's walk set ("size > 0 and a gradient")
  dropped segments the old set walked: the old `!size_ok` was TRUE for a missing size. `knw_compare_rules()`
  reads `knw_dist` as the exception's distance, so those segments would have left the tuned rule. Round 1
  measured it on the current `*_segments.rds`: 638 CH segments (172.7 km, 324 gained) and 2,700 BT spawning
  segments (957.4 km, 2,156 gained) in the tuned flag have a missing or zero size. Fixed: walk every
  accessible segment with a gradient; the test now fails if either the old size filter or the gradable-only
  filter returns (8 and 3 failures).
- **The walk goes to the pick's own `exc_q`**, else the curve's `q`. For 0320's picks they are the same
  (`R/tune_curve.R:55`); `0322` grades candidates on 0320's curve whose exception names another river.
- **The basis of "rule verdicts identical".** The tuned rule is `stream AND gradient ok AND (size ok OR
  knw_dist <= exc_d)` (`R/compare_rules.R:128-131`); the walk set is now a superset of the old, from the
  same starts, river and source, so every old distance is reproduced and a new one lands only where the
  stream or gradient test already fails. One exception: a lost segment between the tuned and default
  gradient maxima (tuned lower) now carries a distance, so its reason can move from "size …, no exception"
  to "gradient: tuned maximum lower" (`R/compare_rules.R:290-292`). Where no tuned maximum is below
  default's, change tables come back identical. Measured in `data/thresholds.csv`: CO (0.04 against 0.0549)
  and WCT (0.04 against 0.0849) are the only keys with a lower tuned maximum, and neither has an exception
  (`ex_ok` is FALSE whenever `exc_q` is NA); CH (0.09 / 0.0549) and BT spawning (0.0549 / 0.0549) are the
  two with one. So every change table must come back identical; the scratch check over every tracked
  `data/compare` csv tests it.

## First CH regrade (2026-10-19, all-accessible reference; superseded)

`scripts/logs/habitat/20261019_tune_run-ch.txt`: score cache hit (0.1 min); the fit line identical to
20261017's; walked 856,244 (every accessible segment has a gradient), found 809,412, none 46,831, other 1;
walks 11.1 min on 8 workers (77 k/min, against 62 k/min for #57's 373 k candidates); reference 0.5156 against
0.1457. Tracked `data/tune` files unchanged; new `CH_rear_{seeds,honest}.csv`.

By branch (accessible, graded): stream (1000/1100/2000/2300) 478,597 segments, 147,668 km, median distance
6.8 km, 95th-percentile rate 0.139; river and lake edges 275,772 segments, 60,627 km, median distance 0.7 mm
(34 % exactly 0), 95th percentile 0.880; other edges 98,062 segments, 16,165 km, 0.258.

| reference | value | grade-weighted km, all | stream | stream km < 0.2 | stream km ≥ 0.8 | off-branch km ≥ 0.8 |
|---|---|---|---|---|---|---|
| #57's (capped walks) | 0.146 | 61,889 | 20,348 | 81.3 % | 6.2 % | 48.0 % |
| every accessible segment | 0.516 | 32,965 | 6,756 | 92.1 % | 0.4 % | 20.4 % |
| stream branch only | 0.139 | 63,058 | 21,091 | 80.9 % | 6.9 % | 49.0 % |

(The #57 row applies its reference to the new rates, so it isolates the reference.) Asked Al, who chose the
stream branch. The run for the other seven keys, started on the old reference, was stopped two minutes in
(no grade table written) and rerun after the change.

## Reviews of the reference change (2026-10-19)

`review-ref-round{1,2,3}.md`. Round 1: the published description named the old population; a same-day CH rerun
would overwrite the superseded log (committed instead, and the rerun is a full pass with its own log name); 0322
could reuse candidate grades made on the old reference. Round 2 found a defect inside round 1's fix (the new
description said "the rule's river", but six of eight rules have none) and that 0325 and 0330 consumed grade
tables without checking how they were made; both now stop on a table without `ref_population`. So only an
enumeration could end the loop: round 3 named the mechanism (nothing that makes a grade records how it was
made; descriptions are prose restated from the CH case; guards read a stand-in) and enumerated 48 places that
state or rely on it. Its wrong statements were fixed (research "pick's size", "most read 1"; NEWS; 0322 header;
`ref_edge` roxygen), 0330's maps-only mode now refuses segments older than their grade table, the vignette data
script reads the full run's log and refuses an unmarked grade table, and the six species research files joined
Phase 3.

Accepted, not fixed here: `ref_population` is a literal 0320 and 0322 write, so it vouches for `ref_edge`'s
default rather than for the call, which agrees with the curve's `edge_stream` because the two defaults are the
same list. Recording provenance where the grade is made (`knw_grade_species()` returning `ref_edge` and `q`,
written by 0320 and checked by each consumer) would change code the running regrade uses; filed as knowledge#72.

## Full regrade (2026-10-19, stream-branch reference)

`scripts/logs/habitat/20261019_tune_run.{txt,out}`, 197.7 min, all keys from a frozen copy of 0320 at `9f35e8e`.
Every accessible segment walked (all have a gradient); tracked `data/tune` files unchanged; new
`<key>_{seeds,honest}.csv` committed. Grade summaries: `grades_summary_{before,after}.csv` (`grade_summary.R`).

| key | walks (min) | found / none / other | reference before → after | grade-weighted km before → after | km < 0.2 | km 0.8–1 |
|---|---|---|---|---|---|---|
| BT rear | 51.7 | 2,647,784 / 33,782 / 17 | 0.180 → 0.226 | 175,327 → 151,418 | 54 → 63 % | 9 → 10 % |
| BT spawn | 44.6 | 2,665,023 / 16,543 / 17 | 0.239 → 0.210 | 375,213 → 392,475 | 0.1 → 0.2 % | 21 → 23 % |
| CH rear | 16.1 | 809,412 / 46,831 / 1 | 0.146 → 0.139 | 36,149 → 63,059 | 76 → 67 % | 7 → 21 % |
| CO rear | 8.5 | 484,753 / 130,548 / 1 | 0.514 → 0.512 | 66,893 → 70,905 | 20 → 22 % | 14 → 22 % |
| GR rear | 13.7 | 841,456 / 14,641 / 16 | 0.034 → 0.034 | 83,850 → 72,867 | 5 → 25 % | 24 → 25 % |
| RB rear | 37.0 | 2,135,004 / 215,878 / 1 | 0.411 → 0.445 | 134,596 → 121,816 | 24 → 27 % | 21 → 15 % |
| ST rear | 9.5 | 566,649 / 154,119 / 0 | 0.236 → 0.201 | 44,545 → 32,290 | 61 → 76 % | 14 → 14 % |
| WCT rear | 2.2 | 166,124 / 1,335 / 0 | 0.429 → 0.473 | 16,871 → 18,671 | 15 → 6 % | 47 → 52 % |

Graded km is unchanged for every key (the gradable set does not depend on the walk). Walk rates 52–65 k/min on
8 workers. CH's grades under the first regrade's all-accessible reference are superseded.

## The flows moved under the run (2026-10-19)

BT's grade table had 4 more segments with no flow than #57's (no_size 33,988 → 33,992), so the 17 October
`*_segments.rds` (copied aside before the comparison overwrote them) were joined to the new grade tables: 73–81 %
of accessible stream-branch segments of every MAD-ruled key carry a different flow (new/old 0.94–1.04 between the
5th and 95th percentiles); width keys do not move. Cause: `discharge.fwa_v1_segment_monthly` was reloaded at
16:40 UTC on 2026-10-19 (`pg_stat_user_tables`: 102.8 M rows deleted, 205.6 M inserted; analyzed 16:40 and
17:19 UTC), its comment "built 2026-10-19T06:08:31Z, wet 94deeb5": NewGraphEnvironment/wet#103 (routed PCIC
1951–2012 → 1981–2010), merged 17:42 UTC. Every run on this branch started after it (the first CH regrade at
20:56 UTC), so the branch's grades are on one flow build.

Floor crossings on accessible stream-branch segments, 17 October flow against today's:

| key (floor) | km now passing | km now failing |
|---|---|---|
| BT rear (0.35) | 222 | 252 |
| BT spawn (0.75) | 191 | 213 |
| CH rear (0.75) | 104 | 62 |
| CO rear (0.03) | 132 | 150 |
| ST rear (1.0) | 89 | 20 |

Asked Al; he chose to proceed on the new flows (#73 retunes on them).

## Comparison and the article (2026-10-20)

`scripts/logs/habitat/20261019_compare.{txt,out}`: 262.6 min. `check_rule_changes_explained.R` against the
17 October segments: **PASS**. `default` moved nowhere; the tuned rule moved only for MAD-ruled keys, every
stream-branch verdict explained (`rule_changes_explained.csv`):

| key | tuned km, #57 → #65 | moved by size | moved by exception distance | cascade |
|---|---|---|---|---|
| BT rear | 156,141 → 156,091 | 1,299 segments (424 km) | | |
| BT spawn | 99,786 → 99,555 | 765 (261 km) | 803 (229 km) | |
| CH rear | 88,607 → 88,641 | 378 (130 km) | 286 (79 km) | 9 (1 km) |
| CO rear | 77,612 → 77,603 | 463 (156 km) | | 4 (0.1 km) |
| ST rear | 45,214 → 45,274 | 346 (100 km) | | |
| GR, RB, WCT | unchanged | | | |

Every figure the research quotes, before and after: `compare_before_after.txt` (`compare_before_after.R`; its
#57 column reproduces the published order-1 figures 15,699, 6,952, 4,634 and 1,085). GR's checks differ in the
14th significant digit (summation order). The article's rendered text differs from the #57 render only in the
examples table's caption and distance column (the kept-by-both example reads 0 m: its 3.6 m³/s stream is itself a
river of the size) and in figures the flow republish moved (CH tuned 88,607 → 88,641, the exception 9,666 →
9,665). `devtools::test()`: 173 tests, 569 expectations, 0 failed.

## Branch review round 1 (2026-10-20)

`review-branch-round1.md`. Three false statements, all fixed: NEWS said every rule's km was unchanged (the flow
republish moved the flow rules by under 0.3 %); the research Limits said "about half" of off-branch km grades
0.8+, from the table above, whose last column was labelled river/lake but measured every off-branch edge type
(re-measured: CH river-polygon edges 1250/1350/1450, 42,181 km, 76.7 % at 0.8+, 69.3 % at 1; all off-branch
76,792 km, 49.0 %); "under 1 % (CO, GR)" (GR moved 0.0344 → 0.0338, −1.7 %). And 0325 read the discharge load at
publish time while calling it the load the grade read: renamed `discharge_load_at_publish`, #72 extended.

## Errors Encountered

| Error | Resolution |
|-------|------------|
