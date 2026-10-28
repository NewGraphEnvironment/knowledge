# Code-check round 2: branch 92-score-rules-on-the-gradient-link-applies (base 3f9cf4a, HEAD 365771d)

## Checklist read

- code-check-python.md: in full (7,237 bytes). The diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped). The 17
  "Rules that stand alone", 6 Security and 3 Spreadsheets/PDFs sections from the index only; none applies to this diff.
- code-check-r.md, sections read in full (17): "A `data-raw/` script must load the source tree", "`$` on a list
  partial-matches", "`nzchar(NA)` is TRUE", "`paste()` with a zero-length argument", "`identical()` on two reader
  results", "Under `R CMD check`, tests run from a temp dir", "CSV whitespace", "`match()` treats NA as a matchable
  VALUE", "`expect_message(expr, regexp)` checks only the FIRST condition", "`expect_false(identical(x, y))` cannot
  fail", "`[[` on a named ATOMIC vector", "`data.frame()` recycles a scalar", "Inside a dplyr verb, a column named like
  a local variable wins", "testthat 3e `expect_message()` returns the condition", "`c(name = x)` keeps `x`'s own name",
  "A `function(...)` mock hides arguments", "`ifelse()` with an all-NA test". The other 94 from the index only.
- code-check-shell.md: index only. The diff has no shell scripts (0 of ~95 read in full).
- code-check-spatial.md: index only. The only SQL the branch adds (`segment_gradient_check.R`) is a plain count over
  `<schema>.streams`; no spatial call is new (0 of ~90 read in full).

## Scope of the checks

- Round-1 fixes re-read against the code. `R/tune_run.R:56-58` (and `man/knw_tune_run.Rd`) now matches the cache
  branches at :236-251. `inst/method/pipeline.csv` step 7 points at #70 (OPEN), step 2 is cleared; #91 is CLOSED and #92
  OPEN (`gh issue view`). The only consumers of pipeline.csv's `issue` column are the article's `detail()` and
  `test-settings-register.R` (which reads `step` only).
- Tests rerun at HEAD 365771d in a throwaway worktree, `NOT_CRAN=true`: test-settings-register (272 passed),
  thresholds_table (55), grade_species (41), rule_in (12); 0 failed, 0 errors, 0 skipped.
- Every reader of a grade table was enumerated by grep (`_grades`): 0320 keep-check, 0325, 0330, vignette_chinook.R,
  vignette_method.R, and data-raw/compare_parallel_check.R (unchanged; a parallel-vs-serial equality check). The field
  each one compares by value, and the ones it checks by presence only, are listed in finding 1.
- Every caller of `knw_rule_in`/`knw_tune_curve`/`knw_tune_run` with the new `segment_gradient` default: 0320 passes
  `cols_run`; 0322 and snap_limit_sensitivity.R pin `fwa_gradient`; no frozen script (0291-0298) calls them.
  `segment_gradient` comes from `R/link_place.R:105` (`s.gradient`), the column the grade reads.
- The comparison-rule refusal: every `data/compare/<key>_compare.csv` on disk carries one `tuned_rule` and no NA, so
  `identical(unique(cmp$tuned_rule), rec$rule)` cannot refuse a current table for a second value. On today's tables
  BT_spawn, CO_rear and ST_rear now pick a near-river pair against comparisons of their old picks, so 0325 will refuse
  until 0330 has rerun, as intended.
- The 0320 summary's `curve_grad` is set only inside the `!is.null(r$curve)` branch, so a failed curve cannot write a
  NULL column. 0330's `curves[[k]]$curve$cols[["grad"]]` reads the rds's exact `curve` element (0320:302), and a
  pre-#92 rds yields NULL, which fails closed.
- The sensitivity replayed on today's tables (vignette_method.R's logic): 6 of 7 fitted keys' picks are close calls on
  the Atlas gradient (CO_rear is not); evidence md5s match; `curve_grad` is `fwa_gradient`/`segment_gradient` as
  required. The data/tune/grad_fwa csvs are tracked. The chinook article's guards replayed on data/tune/CH_rear_*: all
  hold (rec `mad>=0.75|g<=0.11|Q3@D1000`, ddev 0, n_in 1448 < 2571, detections 198 > 178, region 164 rules at 7-30 %,
  departures all 3).

## Findings

- **[fragile: published claim, round-1 fix one axis over]** CLAUDE.md:349-352; R/grade_species.R:146-147.
  Round 1 narrowed `data-raw/vignette_method.R` out of "each compare those fields with the run's own values". The same
  sentence still says it of `0325`, `0330` and `vignette_chinook.R`, in the section headed "every reader compares it,
  not its presence". The code does not do this:
  - 0325 (`scripts/0325-publish.R:74-79`) checks `grade_withheld` and `null_heldout_curve` by presence only. It never
    looks at `curve_prior_sd`. It holds `ref_edge` only to agree across the tables (:108).
  - 0330 (`scripts/0330-compare.R:188`) checks `curve_prior_sd`, `grade_withheld` and `null_heldout_curve` by presence
    only, although the curve rds it holds carries `curve$prior_sd`, `null_heldout_curve` and `grade_withheld` to
    compare against. It does not read `ref_edge`.
  - vignette_chinook.R (:89) checks the same three fields by presence only. It never compares `run_uid`, `ref_edge` or
    `discharge_load`.

  The new comment at R/grade_species.R:146-147 makes the same kind of claim: "every reader of a grade table holds it to
  this ..., as it does the walk, the flow load and the evidence". vignette_method.R does not check the walk.
  vignette_chinook.R does not check the flow load. data-raw/compare_parallel_check.R checks none of them.
  Consequence: no output is wrong today. The gap is the one #73's review warned about, though. If 0320 stops between
  rewriting `<key>_curve.rds` with a new prior and regrading, 0330 and 0325 read the old grade table as current,
  because rule, run, evidence and gradient all still match. Either narrow the sentence and the comment to what each
  reader compares, or have 0330 compare `h$curve_prior_sd` with `format(curves[[k]]$curve$prior_sd)` (and
  `null_heldout_curve`/`grade_withheld` with the rds's values).

- **[fragile: guard fails toward pass]** vignettes/habitat_thresholds.Rmd:89-92 (the Limits guard round 1 asked for)
  and :350-356. `gs` and `sg` are `x$gradient_sensitivity` and `x$segment_at_site`. On a `method.rds` without them,
  which is the bundle installed now, both are NULL. Every comparison is then `logical(0)`
  (`sum(NULL) > nrow(NULL) / 2` is `0 > numeric(0)`), and `stopifnot()` passes. Measured on the current
  inst/vignette-data/method.rds: the guard returns PASSED and the Limits prose renders "  % of stream-line sites…" and
  "0 of  species and stages". A build of the article before vignette_method.R is rerun (this branch's state) is green
  with empty numbers. Add `!is.null(sg), !is.null(gs), nrow(gs) > 0` (or `length(sg$at_site_fish) == 1`) ahead of the
  directional checks.

- **[published claim contradicted by link's code]** vignettes/habitat_thresholds.Rmd:174-175 (step 3: "A site where
  fish were caught is one of those observations, so it usually starts a segment of its own") and
  vignettes/chinook_rearing.Rmd:136-138 ("link cuts a stream where fish were caught"). link breaks at observations that
  are "WSG- and species-filtered" (link `R/lnk_pipeline_break.R:23,36`). The repo's own CLAUDE.md:213-214 and
  research/habitat_thresholds_tuned.md:96 say "a visit that caught a modelled species". So a site that caught only
  species link does not model is not one of those observations. Step 3's "usually" is also unguarded: the Limits
  guard checks only `at_site_fish > at_site_zero`, not `at_site_fish > 0.5`. The chinook sentence "a site with
  chinook usually starts a short segment of its own" (80.7 % in the log) has no guard and no data in the chinook bundle.
  Say "a site where link's species were caught", and guard "usually" (`sg$at_site_fish > 0.5`). For chinook, either
  carry the measured share in the bundle or drop "usually".

No bugs found in the code paths: the gradient record, the cache rescoring, the `main_only` gating, the
comparison-rule refusal and the readers' gradient refusals behave as described.
