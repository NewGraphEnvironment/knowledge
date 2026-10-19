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

| reference | value | grade-weighted km, all | stream | stream km < 0.2 | stream km ≥ 0.8 | river/lake km ≥ 0.8 |
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
written by 0320 and checked by each consumer) would change code the running regrade uses; filed as a follow-up.

## Errors Encountered

| Error | Resolution |
|-------|------------|
