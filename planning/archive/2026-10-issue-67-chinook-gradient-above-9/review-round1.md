# Code-check round 1: branch 67 (0322, knw_tune_run grid_args, chinook article)

Reviewer: subagent, 2026-10-18. Read in full: review.diff, R/tune_run.R, R/tune_grid.R, R/tune_score.R,
R/compare_rules.R, R/grade_species.R, scripts/0322 (beside 0320 and 0330), data-raw/vignette_chinook.R,
vignettes/chinook_rearing.Rmd, tests/testthat/test-tune_run.R, test-vignette-data.R; the grad_ext outputs and both
20261018 logs.

What I checked and found sound:
- test-tune_run.R passes in a temp copy (NOT_CRAN=true: 19 expectations, 0 failed). With the new
  `|| !identical(sc$rules$rule, grid$rule)` removed from the copy, the cache test fails (1 failed), so the guard is pinned.
- The rule counts: 13 size tests x 43 exceptions = 559 per gradient; 5 x 559 = 2795, 8 x 559 = 4472, 11 x 559 = 6149,
  which matches the log and the tune table.
- The regression in the log: all 2795 of 0320's rules are in the new grid, and their dev_heldout agrees within 9.1e-13.
- The md5s in inst/vignette-data/chinook_rearing.rds match all 11 sources on disk, the two grad_ext csvs included.
  The rds's grad_ext table is the same as data/tune/grad_ext/CH_rear_by_grad.csv.
- Every number in the article's two new passages agrees with by_grad.csv: best at 15 %; the 9 % rule is 19.7 behind
  with SE 22.1; region rules at every limit from 7 % to 30 %.
- .gitignore: `**/` also matches zero directories, so the old top-level patterns still hold (`git check-ignore` on
  data/tune/CH_rear_score.rds, the grad_ext rds files, and data/compare/grad_ext/*_grades.rds and *_segments.rds).
  The csvs stay tracked.
- No dplyr data-masking collisions (`g`, `v1`, `cand`, `edge_stream` are not columns of the frames they are used in).
  NA exc_q joins as NA in the `ties` join. `clusterMap` argument order matches `run_one`'s formals.
- 0325, 0330 and knw_thresholds_table() list data/tune and data/compare non-recursively, and 0325's log glob is
  `_tune_run.*`, so nothing that publishes reads grad_ext/ or the 0322 logs.

## Findings

- **[bug, minor]** scripts/0322-tune-grad-extend.R:380-382 with :398. The extended grid's recommended rule
  (`mad>=0.75|g<=0.15|Q1@D1000`, candidate `rec_g15`) is graded with `main$curve`, which is 0320's curve. That
  curve's distance term is distance to a **Q3** river (R/tune_curve.R:55,159; the curve object's `q` = 3).
  knw_grade_species() walks to the candidate's own `exc_q`, here **Q1** (R/grade_species.R:124), so Q1 distances go
  into a curve fitted on Q3 distances. A Q1 river is never farther away than a Q3 river, so the distances run short
  and the grades run high. Every graded-km and km-by-grade-class column of `CH_rear_rec_g15_compare.csv` is wrong
  on that count, beyond the "provisional" caveat the header gives for gradients above 9 %. The g11, g13, g15 and g30
  candidates carry v1's Q3 exception and are not affected. The exception itself (`knw_dist` in knw_compare_rules) is
  right to use the Q1 walk. Fix: either do not report graded km for a candidate whose `exc_q` differs from
  `main$curve$q` (say so in the log), or say in the header and the log that rec's graded km is not comparable.

- **[fragile]** scripts/0322-tune-grad-extend.R:395-396 and :420. Both resume caches are keyed by candidate name only:
  `<key>_<k>_grades.rds` skips grading and `<key>_<k>_segments.rds` skips the comparison. The name `rec_g<pct>`
  carries the recommended rule's gradient but not the rule. A rescore that moves the recommendation to another rule at
  the same gradient (another exception or floor), or a new evidence build or link run, would silently reuse grades and
  segments made for the old rule. The beside-v1 table and the logged totals would then describe the old rule under
  the new rule's label. 0320 guards its grade cache with the rule and run_uid stored in the file (0320:179-186);
  0322 stores neither. Fix: save `rule` (and `run_uid`) with the grades and segments, and keep a cached file only
  when both match.

- **[fragile]** scripts/0322-tune-grad-extend.R:440 and :462. These two `stop()`s (regenerated default differs from
  0330's; segments do not match CH_rear_v1's one to one) come after hours of grading and comparison, and neither
  writes `log_lines` first. Line 430 does write them before its own stop. If either check fires, the log of the whole
  compare stage (grade counts, walk minutes, per-candidate totals) is lost and only console output remains. Fix: call
  `writeLines(log_lines, path_log)` before each of those stops, as line 430 does.

- **[fragile]** vignettes/chinook_rearing.Rmd:51-53 against :490-491. The chunk comment says the stopifnot guards the
  sentences on steeper limits, but it does not guard "Steeper limits ... fit as well or slightly better". That needs
  each limit above 9 % to have a best rule at least as good as the 9 % one: `all(ge$ddev_best[ge$grad_max >
  rec$grad_max] <= ge_rec$ddev_best)`. It holds today (11.6, 15.6, 0, 5.3, 10.7 and 7.3 against 19.7), but a rerun
  that breaks it would knit without complaint. Fix: add that condition to the stopifnot.

- **[fragile, doc]** scripts/README.md:60-61 and CLAUDE.md:60-61 still describe 0322 as "extended to 15 %" and as
  setting "the 11, 13 and 15 % rules" beside default. The script now runs to 30 % and compares 11, 13, 15 and 30 %
  plus the recommended rule (`rec_g15`), and its own header says so. A reader following the README would expect
  outputs the run does not make.

## Observation (not a code defect; no action required by this diff)

- data/tune/grad_ext/CH_rear_summary.csv: `dev_curve` = 2442.7 for the curve fitted at the extended pick
  (`...g<=0.15|Q1@D1000`). That is worse than the no-rule model (about 1382, 0320's dev_null on the same folds) and
  far worse than the grid's best (1131.0). 0320's curve at the 9 % pick scored 1323.6. The extended run's
  `CH_rear_curve.rds` is therefore not a usable grading curve. The compare stage rightly does not read it, but the
  header calls it "written for the record" without saying it fits badly. It may be worth a line in the log or the
  research file before anyone reaches for it.
