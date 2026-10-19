# Code-check round 2 (#67): branch diff vs main

Reviewed: R/tune_run.R, tests/testthat/test-tune_run.R, DESCRIPTION, .gitignore, scripts/0322-tune-grad-extend.R
(against 0320 and 0330), data-raw/vignette_chinook.R, vignettes/chinook_rearing.Rmd, and the functions they call
(tune_grid, tune_score, tune_curve, compare_rules, grade_species). Round 1's five fixes were reviewed too.

## Findings

- **[fragile]** scripts/0322-tune-grad-extend.R:358 — the score stage's regression check (the 2,795 shared rules
  must score as 0320 scored them) only `say()`s "REGRESSION FAILED" and carries on. By then `CH_rear_tune.csv`,
  `_summary.csv`, `_by_grad.csv` etc. are already written, and `data-raw/vignette_chinook.R` reads `by_grad` and
  `summary` without looking at the log, so a failed regression would reach the article with nothing stopping it.
  This is a guard that fails toward pass. The committed run passed (2795 of 2795 equal, largest difference 9.1e-13),
  so no number is wrong today. Fix: `writeLines(log_lines, path_log); stop(...)` on failure, as the compare
  stage's late guards now do.
- **[fragile, comment only]** scripts/0322-tune-grad-extend.R:8-9 — the header says "nothing downstream reads it
  (0325 and 0330 list data/tune/ and data/compare/ non-recursively)". `data-raw/vignette_chinook.R:114-120` now reads
  `data/tune/grad_ext/CH_rear_{by_grad,summary}.csv`, and their md5s are in the article's `meta$md5`, so the claim
  is false. A rerun of 0322's score stage needs a vignette-data rerun. `test-vignette-data.R` catches a stale copy,
  so this is a wrong statement, not a silent failure.

## Checked and found sound (no action)

- Cache key (round-1 fix 2, `knw_tune_run`): `sc$rules$rule` comes from `tibble::as_tibble(grid)`, so its order
  matches `grid$rule`. Both new tests pass in a temp copy with `NOT_CRAN=true` (19 expectations, 0 failed or errored).
- Compare-stage resume (`done_rule`): a candidate counts as done only when its compare csv and segments rds exist and
  the csv's `tuned_rule` equals the candidate's rule. Grades are always recomputed for `todo`. The running frozen
  copy's outputs would be produced the same way. Its diff against the current script only adds logging, guards and
  this resume check.
- Q-mismatch log (round-1 fix 1): `main$curve$q` is `num 3` and the tune csv's `exc_q` is double, so `identical()`
  is TRUE for the Q3 candidates and FALSE only for `rec_g15` (Q1), as intended.
- Article: rendered in a temp copy (citation chunk stubbed). Every number in the two new passages matches
  `grad_ext/CH_rear_by_grad.csv` and both summaries: best at 15 %; the recommended rule 19.7 behind with SE 22.1;
  region rules at every limit from 7 % to 30 %; nested selection 1,389.4 against 1,347.0 on the extended grid and
  1,234.5 on the main one. Each claim has a matching `stopifnot` term, and all of them hold.
- The vignette rds md5s match every tracked source, including the two grad_ext csvs.
- The 0322 header's "236 visits and 2 CH catches" above 15 % is right: I recomputed it on the modelled population
  (4,490 visits, 215 detections).
- No dplyr verb in 0322 has a column that shadows a local (`v1`, `cand`, `k`, `g`, `wsg`, `smoke`). `summarise()`
  calls do not reuse a summarised column. The new `.gitignore` patterns ignore no tracked file and cover the
  grad_ext rds outputs.
