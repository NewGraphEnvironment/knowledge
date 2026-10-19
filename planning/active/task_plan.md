# Task: The grade reads segments that pass the size test at the 50 km distance cap (#65)

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

## Decided at the gate

Settled by Al on 2026-10-19 in plan mode (issue body), re-approved with this plan the same day.

- Walk every gradable accessible segment: accessible, size present and > 0, gradient present (`knw_grade()`'s
  own test, `R/grade.R:48`), any edge type, any gradient. About 9.3 M walks, roughly 2.5 h on 8 workers.
- `habitat_grade/v1` stays v1: nothing under `s3://fresh-bc/knowledge/` but `fdis/`, so no consumer read the capped one.
- A walk whose status is `none`, `no_parent` or `too_many_hops` keeps `dist_m = NA` (the cap), as
  `knw_tune_curve()` censors visits (`R/tune_curve.R:64`); the table records which in `dist_status`.

## What verification added to the parked plan

1. **The rule verdicts cannot move, so prove they did not.** `knw_compare_rules()` builds the tuned rule as
   `stream branch AND gradient ok AND (size ok OR knw_dist <= exc_d)` (`R/compare_rules.R:128-131`), and the
   change reasons gate the exception the same way (L283-289). A distance on a non-stream, steep or
   size-passing segment cannot change a verdict, and a candidate's distance comes from the same start, `q`
   and source as before. So `default` km, tuned km, lost, gained and every change reason must come back
   identical; only graded km, km by class, graded ha and the reference rate may move. This becomes a check.
2. **`data-raw/vignette_chinook.R:48` hard-codes the tuning log** (`20261017_tune_run-bt_ch_co_st.txt`) and
   reads the CH grades line from it (L142-154). After the CH regrade it must point at the new CH log, whose
   first line names the same evidence ledger.
3. **The vignette's "Lost" example** selects on `is.na(dist_m) | dist_m > exc_d` (`vignettes/chinook_rearing.Rmd:410`).
   Steep or off-branch segments now carry distances, so the chosen example can change. Check the examples
   table and its prose after the rerun.

`curve$q` exists (`R/tune_curve.R:163`), so the walk reads it directly. `0320` passes no `src`, so grading and
fitting both use `pick`.

## Phase 1: walk every gradable accessible segment (`R/grade_species.R`, `R/grade.R`, `scripts/0320`)

- [x] `knw_grade_species()` walks every accessible segment with a gradient, whatever its size (corrected 2026-10-19 by the plan review and code-check round 1: the old set walked missing and zero sizes, and the comparison's exception reads their distance), to the first river of the pick's `exc_q`, or `curve$q` when it has none (corrected: `0322` grades candidates whose `exc_q` differs from the curve's), on the curve's source; the `pick$exc_q` gate, the edge-type filter, the gradient filter and the size-test filter go. `starts` are the unique `(blue_line_key, downstream_route_measure)` of that set.
- [x] The grades carry `dist_status` (`found`, `none`, `no_parent`, `too_many_hops`, or `no_walk` for a segment outside the walk set); `dist_m` stays `NA` except where found. `counts` gains `walk_found`, `walk_none`, `walk_other` beside `walked`.
- [x] Roxygen: `knw_grade_species()` describes the walk set as above (not "stream-branch segments"; wetland lines and river polygons are in it) and what the cap now means; `knw_grade()` L14-15 says a capped distance is far from a river of at least the curve's `q` (or the walk found none), not "far from any river". `devtools::document()`.
- [x] `tests/testthat/test-grade_species.R`: with `local_mocked_bindings()` on `knw_link_segments` (a small frame: accessible and not, with and without size, with and without gradient, edge types 1000/1250/2000, gradients above and below the pick's maximum, sizes above and below `size_min`) and `knw_link_walks` (records the `starts` and `q_grid` it was given; returns `found` for some, `none` for one), assert: every accessible gradable segment is a start and nothing else is; `q_grid` is `curve$q`; a size-passing segment near a river carries its distance; the `none` segment has `dist_m = NA` and `dist_status = "none"`; an inaccessible segment has `NA` grade. Restore-the-bug check: with the old `!size_ok` filter put back, the "size-passing segment is a start" assertion must fail.
- [x] `scripts/0320-tune-run.R`: the keep-on-file check (L179-187) also requires `dist_status` in the table's header, so #57's capped tables are regraded under the same rule and `run_uid`; the spec comment (L25-28) and the OUTPUT line say the walk covers every graded segment.
- [x] `/code-check` on the diff; commit.

## Phase 2: regrade, publish locally, compare

- [ ] CH first and alone: `SPECIES=CH Rscript scripts/0320-tune-run.R` (the scored grid is cached in `CH_rear_score.rds`, so only the grade runs). Record in `findings.md`: walk minutes against 6.0, `walked`/`walk_found`/`walk_none`, the reference rate against 0.1457, and the grade-class km shares against 76 % under 0.2 and 7 % at 0.8–1.
- [ ] The other seven keys (`SPECIES=BT,CO,GR,RB,ST,WCT`), on the 16-core host with `WORKERS=14` or locally; `PGCONNECT_TIMEOUT` set (#57's grading hang). BT walks twice (q 10 for rearing, q 3 for spawning); if the measured CH rate makes that unreasonable, share one walk at `q_grid = c(3, 10)` per species inside 0320 and say so.
- [ ] Assert the tracked `data/tune/` files (tune, summary, curves, groups) are unchanged by the regrade: `git diff --stat data/tune` is empty; confirm the "Scored" log line shows the score cache was hit; `git status --short data/tune` for the new `<key>_{seeds,honest}.csv` that the vignette data pins (plan review #4), committed.
- [ ] `Rscript scripts/0325-publish.R` (local; `PUBLISH` stays open as #57 left it). The `habitat_grade` description says the distance is walked for every graded segment. Assert `git diff --stat data/thresholds.csv data/thresholds_groups.csv` is empty.
- [ ] `Rscript scripts/0330-compare.R` for every species (full run, not `STAGE=maps`: the grade is read per segment). Assert the rule columns did not move: in every `*_compare.csv` the default, tuned, lost and gained km are identical to `origin/main`'s, and every `*_change.csv` is identical apart from grade columns; only graded km, km by class, `floodplain.csv` graded ha and ha by class differ.
- [ ] Point `data-raw/vignette_chinook.R`'s `path_log` at the new CH tuning log, run it, then `devtools::test()`.
- [ ] Commit the tune, compare and vignette-data outputs with the log paths in `progress.md`; the archive README's `Measurement` carries the before/after reference rates and graded km per key.

## Phase 3: revise the record

- [ ] `research/habitat_thresholds_tuned.md`: the Grade bullet of the method (every graded segment at its own walked distance to the curve's river; the cap is a walk that found none); the Grades table; the "What each rule changes" km table; the floodplain table and its paragraph (drop "provisional", L29 and L188); the Limits list if any limit moved; `Verified` date in the header; a dated revision note saying #57's grades were capped.
- [ ] `research/chinook_rearing_tuned.md` L34-39: graded km and graded ha under the corrected grade; drop "provisional until #65".
- [ ] `data-raw/vignette_chinook.R` L19-22 and `vignettes/chinook_rearing.Rmd`: the comment and any sentence that says the distance is measured only on exception candidates; the examples table's distance column now reads for the kept-by-both example, and the "Lost" example may change (L410). Render before and after, strip to text, diff: only the prose meant to change differs.
- [ ] `scripts/README.md` 0320 line; `NEWS.md` entry under the next version (the grade walks every graded segment; v1 corrected before publication; the two roxygen fixes).
- [ ] `/code-check branch`; `/planning-archive`; `/gh-pr-push`.

## Owed at the end (reported, done after merge)

None. Upload (`PUBLISH=TRUE`) stays out of scope, below.

## Validation

- [ ] Tests pass (`devtools::test()`, including `test-vignette-data.R` after the vignette data rerun)
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- The walk set: the mocked unit test, and the restore-the-bug run that must turn it red.
- The regrade: the log's `walked`, `walk_found` and `walk_none` per key against accessible gradable counts.
- No side effects: `data/tune` tracked files, `thresholds*.csv` and every rule column of `data/compare` unchanged.
- The article: a text diff of the rendered page before and after, limited to the intended sentences.

## Not in scope

- Uploading thresholds/v1 and habitat_grade/v1 to the bucket (`PUBLISH=TRUE`), which #57 left open and which waits on #56's bucket policy.
- The floodplain catalog's missing groups (floodplains#123) and the gradient ladder for every species (#68).

