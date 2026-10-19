# Progress — Chinook rearing: retune the gradient maximum above 9 %, the steepest tried (#67)

## Session 2026-10-18

- Phases taken from the plan approved on 2026-10-18 and parked in the issue body; its code references
  re-checked on main `d172079` (`R/tune_run.R` cache check on `visits_in` only, `knw_tune_grid()` default
  ladder, the two article passages at lines 297 and 477, the 0320 log and the 0310 build present)
- Created branch `67-chinook-rearing-retune-the-gradient-maxi` off main
- Scaffolded PWF baseline from issue #67 with the approved phases
- Phase 1: `knw_tune_run(grid_args =)` passes a grid to `knw_tune_grid()`, and the score cache is read back
  only when its rules equal the grid's, in order. Tests: the 8-gradient ladder is 4,472 rules and reaches the
  scorer; a cache written on a 26-rule grid is read for that grid and refused for a 52-rule one. With the grid
  check removed (in a copy), the refusal test fails. testthat floor raised to 3.2.0 for `local_mocked_bindings()`.
  Suite: 533 pass.
- Plan review returned (`review-plan.md`); its findings folded into 0322 before the run (join on two keys,
  unrounded regression by rule, input md5 check, per-gradient table, recursive ignore rules, default-km check).
- Phase 2: 0322 scored the 15 % ladder, 05:57-06:10 UTC; the best moved to 15 %, the ladder's top. Committed the
  tables and log as the record; extending to 30 % next.
- Phase 2 extended: the 30 % ladder, 06:12-06:35 UTC; 15 % stays best, interior. Committed.
- Phase 3 started 06:36 UTC: five comparisons on all 125 CH groups (BULK smoke run passed first).
- Phase 5 while it runs: the article reads `data/tune/grad_ext/CH_rear_{by_grad,summary}.csv` (md5-tracked) as
  `x$grad_ext`; its two passages on the gradient limit are computed from it, guarded by a `stopifnot()` on the
  premises they state. The article data's tests pass (35); the article renders against the source tree (the
  package is not installed here, so `pkgdown::build_article()` cannot `library(knowledge)`; rendered with
  `rmarkdown::render()` after `load_all()`).
