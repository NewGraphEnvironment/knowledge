# Code-check round 1: branch 92-score-rules-on-the-gradient-link-applies (base 3f9cf4a, HEAD 77cf24b)

## Checklist read

- code-check-python.md: in full (7,237 bytes). The diff has no Python.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped). Headings from the index only for
  the 17 "Rules that stand alone", 6 Security and 3 Spreadsheets/PDFs sections, none of which this diff touches.
  0 Mechanisms sections unread.
- code-check-r.md, sections read: "`$` on a list partial-matches", "`[[` on a named ATOMIC vector with an absent key is
  an error", "`expect_false(identical(x, y))` cannot fail when the two are different types", "A `function(...)` mock
  hides arguments", "`sprintf("%g", x)` writes `Inf` and `NA` into SQL", "A `data-raw/` script must load the source
  tree", "Postgres row order is never fixed". Index lines only for the other ~100 headings (about 103 not read in
  full).
- code-check-shell.md: index only. The diff has no shell scripts (0 of ~95 read in full).
- code-check-spatial.md: index only. The only spatial SQL (`near()` in vignette_method.R) predates the branch (0 of ~90
  read in full).

## Scope of the checks

- Every reader of a grade table or summary was checked for whether it compares `curve_grad`'s value or only its
  presence: 0320's keep-check (`.knw_grade_grad_ok(head1, r$curve$cols[["grad"]])`), 0325 `stale` (value) and
  `mispick` (value against the thresholds row), 0330 (value, and against the curve rds's `cols`), vignette_chinook.R
  (value, and summary against grade table), vignette_method.R (value on grade tables; `record:` and an explicit check on
  summaries; the value and evidence on the sensitivity summaries), and `knw_grade_species()` (value). All compare the
  value.
- Score cache in R/tune_run.R: a cache with no spec is rescored unless `cols[["grad"]]` is `fwa_gradient`. A cache with
  a spec but no `grad` fails the `.tune_spec_norm` compare, because the names differ, and is rescored. Neither path
  reads a pre-#92 score as a segment-gradient one. GRADIENT=fwa_gradient caches go to data/tune/grad_fwa/, so the two
  runs never share a cache file.
- 0320 `main_only`: seeds and honest csv writes, the summary's stability fields, the nested and seeds log blocks, and
  grading are all gated. `boot_rec_share` is only read under `!main_only`. A sensitivity log has no "<key> grades:"
  line, so vignette_chinook.R's log pick skips it. All readers list data/tune non-recursively.
- Tests run in a throwaway worktree with NOT_CRAN=true and the branch's code: test-settings-register (10), rule_in (3),
  thresholds_table (13), grade_species (6), tune_run (7), tune_curve (5). All passed: 0 failed, 0 errors, 0 skipped.
- chinook_rearing.Rmd: every `stopifnot` in `load` was replayed against the current data/tune/CH_rear_tune.csv and
  data/tune/grad_ext/CH_rear_by_grad.csv. All hold: region all MAD with exception, departures 3, rec n_in 1448 < 2571,
  detections 198 > 178, the 1.96 pick keeps 0.75 and the exception at 5.49 %, ge_best 15 % > 11 %, boot_mad 0.995,
  boot_grad 0.465. The recommended rule is the best scorer (ddev_best 0). The fitted surface from the new curve still
  supports the prose: 10.2–11.4 % at 100 m whatever the flow, and 0.27–2.87 % at 10 km rising with flow.
  `all_row$change_pct < 0` can only be checked once 0330 has rewritten the comparison; the one on disk is #73's
  (`tuned_rule` g<=0.13), as expected.
- habitat_thresholds.Rmd step 8 guard against data/tune/CH_rear_summary.csv: 3 of 4 seeds, all 4 in region,
  boot 0.095, honest 1326.8 < 1468.6. It holds.
- research/habitat_thresholds_tuned.md "Which gradient is scored" and CLAUDE.md's "86 % … 10 %" were checked against
  scripts/logs/habitat/20261027_segment_gradient_check.txt. Every number matches: 29,335; 86.2/10.2; 113/305 m;
  CH 80.7/44.6; BT 94.2/37.8; 13.5 % zero at ≤10 m; 0.015 vs 0.0017; 0.0083 both; flips 7.81–12.06 % at default's
  cut-offs; 9,997,708 segments; ratios 0.986–1.027; 15 % class 0.941.
- inst/method/settings.csv: `gradient_col`'s `script:`/`fn:`/`record:` pointers and the two new `code:` pointers into
  chinook_rearing.Rmd resolve (the register test passes, and each pattern matches exactly one line).
- The new thresholds-table `tuned_rule` refusal is scoped to keys with a pair. A comparison with no `tuned_rule` column
  fails closed.

## Findings

- **[fragile: published claim]** inst/method/pipeline.csv:8 (step 7, `issue` = 92) and :3 (step 2, `issue` = 91);
  vignettes/habitat_thresholds.Rmd:136-139. The methodology article's `detail()` renders a step's `issue` as
  "Open work: #N". #91 is already CLOSED (checked with `gh issue view 91`), and #92 is this branch's issue, so once the
  PR closes it, step 7 also lists a closed issue as open work. The plan's "pipeline.csv steps 5, 7 and 9 (review G6)"
  task is ticked, but row 7 still names 92. Fix: point the step at the open follow-up (#70, fixed-window gradients,
  which the Limits already cite), or clear it. Do the same for step 2.

- **[fragile: unguarded prose]** vignettes/habitat_thresholds.Rmd:347-353 (Limits). The new bullet makes directional
  claims from `x$segment_at_site` with no guard: "link's segments are shortest where fish were caught", "So the slope
  is less certain at the sites with fish". Its "still a close call for N of M" sentence, from
  `x$gradient_sensitivity`, has no guard either. The setup chunk guards every other result sentence with `stopifnot`,
  as the repo's vignette convention requires. Add, for example,
  `stopifnot(sg$at_site_fish > sg$at_site_zero, sg$len_fish < sg$len_zero, sum(gs$pick_in_atlas_region) > nrow(gs) / 2)`.
  The current data hold (86 % vs 10 %; 113 vs 305 m; 6 of 7 keys from data/tune/grad_fwa), so the build would fail
  only if a rerun reversed them.

- **[doc contradicts code]** R/tune_run.R:56-57, which is also man/knw_tune_run.Rd and the pkgdown reference. The
  `cache_dir` doc still says "a cache written before the record is read back with a message naming the settings it is
  taken as". Since this branch, a cache with no `spec` is rescored under the default `cols` (`segment_gradient`). It is
  read back with the message only when `cols[["grad"]]` is `fwa_gradient` (R/tune_run.R:238-245). A cache with a spec
  but no `grad` is also rescored. Say that a cache from before the record counts as scored on `fwa_gradient`, and is
  read back only for that gradient.

- **[claim overstated]** CLAUDE.md:349-351. The branch adds `data-raw/vignette_method.R` to the readers that "each
  compare those fields with the run's own values and refuse a table that does not match". "Those fields" are `rule`,
  `run_uid`, `walk`, `ref_edge`, `discharge_load`, `curve_prior_sd`, `grade_withheld`, `null_heldout_curve`,
  `evidence_md5` and `curve_grad`. vignette_method.R:86-99 compares only `curve_grad` and `evidence_md5` (against the
  derived tables) on the grade tables, and checks that `discharge_load` has one value. It does not compare `rule`,
  `run_uid`, `walk`/`walk_md5`, `ref_edge` or the gate fields, and it does not check that a comparison's `tuned_rule`
  is the pick. Nothing the methodology article prints reads those fields, so no output is wrong today. The sentence
  sits in the section that warns "every reader compares it, not its presence", so narrow it to what vignette_method.R
  compares.

No bugs found in the code paths themselves: the gradient record, the cache rescoring, the `main_only` gating and the
readers' refusals behave as described.
