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
- Next: Phase 2
