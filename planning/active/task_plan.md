# Task: Chinook rearing: retune the gradient maximum above 9 %, the steepest tried (#67)

The recommended chinook rearing rule (`CH_rear_v1` in `data/thresholds.csv`: MAD ≥ 0.75 m³/s, gradient ≤ 9 %, and either the flow floor or a ≥ 3 m³/s river within 1 km downstream) takes the steepest gradient maximum the tuning tried. `knw_tune_grid()`'s default `grid_grad` is `c(0.03, 0.04, 0.0549, 0.07, 0.09)`, so we cannot tell whether a steeper limit would score as well or better.

The gradient is also the least settled part of the rule (`data/ch_rule_tune.csv`, `scripts/0320-tune-run.R`):

| Gradient max | Best score on the 4 other seeds (55–58) | Recommended in the 200 bootstrap draws |
|---|---|---|
| 5.49 % (`default`) | 0 of 4 | 26 % |
| 7 % | 3 of 4 | 34 % |
| 9 % | 1 of 4 | 41 % |

On the main seed, 7 % scores 1.6 deviance behind 9 % against a standard error of 14.2.

**Decision for now:** keep 9 %. It is the main run's pick, and it leaves more streams in as habitat.

Phases are the plan approved at the plan gate on 2026-10-18 and parked in the issue body.
Decision taken there: this issue measures and records; `CH_rear_v1` stays at 9 % here either way.

## Phase 1: `knw_tune_run()` takes a grid, and its cache is keyed on the grid
- [x] `R/tune_run.R`: add `grid_args = list()` (passed to `knw_tune_grid()` with `do.call`), documented; the cache
      read also requires `identical(sc$rules$rule, grid$rule)`, else it rescores
- [x] `tests/testthat/test-tune_run.R`: `grid_args = list(grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15))`
      gives 4,472 rules; a cache written on the 5-gradient grid is refused by an 8-gradient run (restore the bug,
      prove the guard fires: with the grid check removed the stale cache is read)
- [x] `devtools::document()`, `lintr::lint_package()`, `devtools::test()`; commit

## Phase 2: the extended scoring run
- [x] `scripts/0322-tune-grad-extend.R` (header in `0320`'s shape: WHY, INPUT, OUTPUT, RUN): CH rearing only, the
      same evidence build, link thresholds at the ledger's `link_sha`, seeds, bootstrap and `d_floor` as `0320`,
      with `grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15)`; `cache_dir = "data/tune/grad_ext"`;
      writes `data/tune/grad_ext/CH_rear_{tune,seeds,honest,groups,summary}.csv` (tracked) and `_score.rds`,
      `_curve.rds` (ignored: two `.gitignore` lines); log `scripts/logs/habitat/<date>_tune_grad_extend.txt` with
      the region, best per gradient, nested selection, more seeds, and the bootstrap recommended and region shares
      by gradient
- [x] Run it in the background (`WORKERS=8`), the start time from `date -u`; wait for the exit, then read the log
      and the tables
- [x] Regression check in the script's log: the 2,795 rules shared with `data/tune/CH_rear_tune.csv` have identical
      `dev_heldout` (same folds, same seed); report whether the best, the region's membership and the recommended
      rule moved
- [x] Commit the tables and the log
- [x] Added 2026-10-19 after the run: the best rule sat at 15 %, the top of the extended ladder, so the ladder is
      extended again to 20, 25 and 30 % (same script, same seeds) to find where the score stops improving; the 15 %
      run's log is kept as `scripts/logs/habitat/20261018_tune_grad_extend-to15.txt` and its tables in git history

## Phase 3: the steeper rules beside the recommended one on link's segments
- [x] Same script, `STAGE=compare` (reads the Phase 2 tables): for each steeper gradient (11, 13, 15 %), the
      recommended rule's other parts with that gradient; `knw_grade_species()` at that rule on all 125 CH groups
      (the main run's `CH_rear_curve.rds` for the rate, so graded km is provisional as under #65), then
      `knw_compare_rules()` against `default`; `data/compare/grad_ext/CH_rear_g<pct>_{compare,change,checks}.csv`
      (tracked) and `_segments.rds` (ignored)
- [x] (As built: joined on `id_segment` and `watershed_group_code`, because `id_segment` repeats across groups;
      candidates 11, 13, 15, 30 % and the extended best, beside `CH_rear_v1`, the rule 0330 compared.)
      From the segments joined to `data/compare/CH_rear_segments.rds` by `id_segment`: km each rule adds and
      removes beside the recommended rule, by reason (stream segments in the new gradient band passing the size
      test; the exception in the band; river-polygon segments in the band; connectivity), and FDIS detection on
      the added km
- [x] Run (background), log `scripts/logs/habitat/<date>_tune_grad_extend-compare.txt`; commit

## Phase 4: the research record
- [x] `research/chinook_rearing_tuned.md`: a section "The gradient maximum above 9 % (#67)" under the
      province-wide paragraph: the extended region, best per gradient with deviance and SE, picks on the main
      reading and the four seeds, bootstrap shares by gradient, the km table beside the recommended rule, the
      river-polygon km, and the decision (`CH_rear_v1` stays at 9 %: the reason; or the follow-up issue filed);
      the `**Verified:**` line and the Gradient limit bullet updated
- [x] `research/habitat_thresholds_tuned.md`: the sentence on CH's gradient moving up to 9 % gains the pointer;
      `research/README.md` row for `chinook_rearing_tuned.md`
- [x] `scripts/README.md` run order (0322 line); `CLAUDE.md` layout bullet for `data/tune/grad_ext/` and
      `data/compare/grad_ext/`; `NEWS.md` entry (no version bump: `/gh-pr-merge`'s)
- [x] Every quantified claim in the new text checked against the tables (audit per row); commit

## Phase 5: the article stops saying nothing steeper was tried
- [x] `data-raw/vignette_chinook.R`: read `data/tune/grad_ext/CH_rear_tune.csv` (md5-tracked) and save its best
      rule per gradient (`dev_heldout`, `ddev_best`, `se_diff`, `in_region`, `boot_rec_share`) as `x$grad_ext`;
      rerun the script
- [x] `vignettes/chinook_rearing.Rmd`: the two sentences (near lines 297 and 477) computed from `x$grad_ext`
      (which steeper limits were scored, whether any entered the region, where the best sits), nothing typed; the
      "least settled part" paragraph stays
- [x] `tests/testthat/test-vignette-data.R` passes on the new md5s; `pkgdown::build_article("chinook_rearing")`
      renders locally and the two passages read correctly; commit

## Phase 6: close out
- [x] If a steeper rule is the main reading's recommended rule: file the follow-up issue (extend the ladder for
      every species, retune, republish `thresholds`), link it from the research section and this body
- [ ] Edit this body: the findings as spec, the research section linked
- [ ] `/code-check branch`; `/planning-archive`; `/gh-pr-push`

## Validation

- [x] Tests pass
- [x] `/code-check` clean (each commit, or once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion
- [x] `devtools::test()` green, including the vignette-data md5 tests after the data script rerun
- [x] `lintr::lint_package()` clean on the touched files
- [x] The Phase 2 log's regression line: 2,795 shared rules identical in `dev_heldout`
- [x] The article's two gradient passages render from `x$grad_ext` with no literal numbers
