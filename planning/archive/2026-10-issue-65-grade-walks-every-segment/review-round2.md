# Code-check round 2: #65 staged diff (diff2.patch)

## Checklist read

- code-check-python.md: index read in full; nothing in the diff is Python.
- code-check.md: index read in full. Read the prose of every H3 under `## Mechanisms`, all 14, with the
  table rows skipped. None of the 26 sections under "Rules that stand alone", "Security" or
  "Spreadsheets and PDFs" was read past its index line, because the diff has no shell, CI, credentials,
  URLs or YAML.
- code-check-r.md: read in full "Read-back shape must match write-back shape", "Tests that silently do not
  run", "testthat counts an uncaught error under `error`", "`$` on a list partial-matches", "`paste()` with a
  zero-length argument", "Under `R CMD check`, tests run from a temp dir", "`match()` treats NA as a matchable
  VALUE", "`tolerance` in testthat is RELATIVE", "Postgres row order is never fixed", "Rscript reads a script
  as it runs", "A `pkg::` call in a test", "A `function(...)` mock hides arguments" and "`ifelse()` with an
  all-NA test". The other 98 headings were not read past their index line.
- code-check-shell.md: index only, 0 sections read. The diff has no shell.
- code-check-spatial.md: index only, 0 sections read. The diff calls no spatial tool. The FWA edge-type
  entries were checked against their index lines.

## Clean

No issues found.

## What was verified (for the record)

- **The walk set is a superset of the old one.** The old `cand` was `accessible & edge in
  c(1000,1100,2000,2300) & !is.na(gradient) & 0 <= gradient <= grad_max & !size_ok`. The new one is
  `accessible %in% TRUE & !is.na(gradient)`. `knw_link_segments()` builds `accessible` as `... %in% TRUE & g`,
  so it is never NA. Every old start is therefore a new start, at the same `q` and with `src = "pick"`.
  The walk is per start (`ch_dist_profile`, with no state across starts), so a segment the old code walked
  keeps the same `dist_m`.
- **The tuned verdicts cannot move for the published picks.** I parsed link's `configs/default/rules.yaml`
  the way `.knw_fresh_branches()` does: compare's `edge_stream` is `1000,1100,2000,2300` for every species
  and stage, the same as the old grade default. The MAD size test in compare (`knw_size >= size_min`, where
  `knw_size` is the grades' `size`) is the old `size_ok`. That leaves the newly walked segments inside
  `sb & grad_ok`, and every one of them passes the size test, so the new distance cannot reach `ex`. A
  newly walked segment outside the stream branch or the gradient maximum is shut out by `sb` or `grad_ok`.
  The picks without an exception have `ex = "FALSE"` and `ex_ok` FALSE: BT_rear, CO, GR, RB, ST and WCT
  (data/thresholds.csv). Neither direction of the change reasons can move:
  - **Gained** (`stream & g_tun & !size_tun & ex_ok`): these rows were old candidates.
  - **Lost** (`g_def & !ex_ok`): `g_def` is a subset of `g_tun` for both exception picks. CH_rear is
    0.0549 against 0.09, and BT_spawn is 0.0549 against 0.0549. So plan-review item 8, a lost reason moving
    to "gradient: tuned maximum lower", cannot arise. 0322's candidates are all steeper than 0.0549 too.
- **Restore the bug.** In a temp copy, `tests/testthat/test-grade_species.R` was run three ways:

  | `R/grade_species.R` | result |
  |---|---|
  | as staged | 18 expectations, 0 failed, 0 errors |
  | HEAD's | 9 failed across all 3 blocks |
  | round 1's `size > 0` walk set | 3 failed in block 1 |

  `tools:::.check_packages_used_in_tests()` printed nothing. The mocks' formals match the real
  `knw_link_walks()` signature.
- **Consumers.**
  - `data-raw/vignette_chinook.R:142` greps `^CH_rear grades:`. The new regrade notice is
    `CH_rear: grades on file ...`, so it does not match. The `segments=`, `accessible=`, `graded=` and
    `no_size=` regexes each still hit the right field first.
  - 0330 reads explicit `col_select` columns.
  - 0325 `transmute`s explicit columns.
  - `knw_compare_rules()` reads only `size`, `dist_m`, `grade` and `grade_class`.
  - The walk SQL never returns NA `status`, so the `walk_*` sums cannot be NA.
- **On-disk state.** No `data/tune/*_grades.csv` carries `dist_status` today (all were written
  2026-10-17), so 0320's gate regrades every species. The round-1 version of the code, which wrote
  `dist_status` with the narrowed walk set, left no table that the gate would wrongly keep.

## Notes (not defects)

- `scripts/0322-tune-grad-extend.R:23-25` says "The grades on file were made before #65 ...". The same diff's
  `done_rule()` forces those grades to be regraded on the next run. After that run the sentence describes
  files that no longer exist, so reword it to past tense or drop it once the rerun lands.
- 0325 republishes `knowledge/habitat_grade/v1` with values that change because the walk set changed.
  Whether a corrected grade is still v1 is a publishing decision for the plan. It is not a code defect in
  this diff.
