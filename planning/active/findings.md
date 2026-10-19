# Findings — Chinook rearing: retune the gradient maximum above 9 %, the steepest tried (#67)

## Issue context

## Problem

The recommended chinook rearing rule (`CH_rear_v1` in `data/thresholds.csv`: MAD ≥ 0.75 m³/s, gradient ≤ 9 %, and either the flow floor or a ≥ 3 m³/s river within 1 km downstream) takes the steepest gradient maximum the tuning tried. `knw_tune_grid()`'s default `grid_grad` is `c(0.03, 0.04, 0.0549, 0.07, 0.09)`, so we cannot tell whether a steeper limit would score as well or better.

The gradient is also the least settled part of the rule (`data/ch_rule_tune.csv`, `scripts/0320-tune-run.R`):

| Gradient max | Best score on the 4 other seeds (55–58) | Recommended in the 200 bootstrap draws |
|---|---|---|
| 5.49 % (`default`) | 0 of 4 | 26 % |
| 7 % | 3 of 4 | 34 % |
| 9 % | 1 of 4 | 41 % |

On the main seed, 7 % scores 1.6 deviance behind 9 % against a standard error of 14.2.

**Decision for now:** keep 9 %. It is the main run's pick, and it leaves more streams in as habitat.

## Proposed

- Re-run the CH rearing tune with `grid_grad` extended above 9 % (for example 0.11, 0.13 and 0.15), on the same evidence version, link run and seeds.
- Report whether any steeper rule enters the region, how the bootstrap and seed shares move, and the km each would add beside the recommended rule (`0298`'s side by side).
- Keep the river-polygon caveat in view: link applies the stream gradient maximum to river polygons too, the tuning scores no river-polygon visit, and 0 of 156 river-polygon visits above 5.49 % caught CH (`research/chinook_rearing_tuned.md`).

## Done when

- The extended grid's region, picks and shares are in `research/chinook_rearing_tuned.md`.
- Either `CH_rear_v1` stays at 9 % with the reason recorded, or a new rule version is written to `thresholds.csv` and the article (`vignettes/chinook_rearing.Rmd`) is regenerated from it.


## Plan (drafted 2026-10-18, parked here for `/planning-init 67`)

Drafted in plan mode and approved on 2026-10-18; the session was cleared before the branch was cut, so the next
`/planning-init 67` takes its phases from here rather than re-exploring.

**Decision taken at the plan gate (2026-10-18): this issue measures and records.** Every species is tuned on one
shared gradient ladder (`knw_tune_grid()`), so a CH-only `v2` would break that. If a steeper rule becomes the main
reading's recommended rule, this issue records it and files a follow-up to extend the ladder for every species
and republish; `CH_rear_v1` stays at 9 % here either way, with the reason recorded. Whatever the result, the
article must change: `vignettes/chinook_rearing.Rmd` says twice (near lines 297 and 477) that 9 % is the steepest
limit tried and nothing steeper was.

### What exploration found

- `knw_tune_run()` (`R/tune_run.R`) calls `knw_tune_grid(thr, stage)` with the defaults; `scripts/0320` cannot pass
  a grid. Its scored-grid cache (`<cache_dir>/<key>_score.rds`) is reused whenever `visits_in` matches, **so a run
  with a different grid would silently read the 2,795-rule grid back**. The cache check must also compare the
  grid's rules.
- `knw_tune_score()` already handles any grid: region (one SE of the best), pick (fewest departures, ties to lower
  score), recommended (`d_floor`), 200-resample bootstrap shares, nested selection, seeds 55–58. All 23 region
  rules have 3 departures, so a steeper rule with a lower score would become the pick.
- Main reading now (`data/tune/CH_rear_tune.csv`, 2,795 rules, 559 per gradient): best per gradient is
  `mad>=0.75|g<=0.09|Q3@D1000` (deviance 1150.66); 7 % +1.56 (SE 14.2), 5.49 % +47.2, 4 % +87.3, 3 % +123.3.
  `data/tune/CH_rear_{seeds,honest}.csv` do not exist (the run predates #62's writer); the seeds and
  nested-selection tables are in the log `scripts/logs/habitat/20261017_tune_run-bt_ch_co_st.txt` and the
  ignored `CH_rear_score.rds`.
- A rerun needs `0310`'s build (`data/fdis/derived/{visits_link,visits_species,walks}.csv`,
  `data/fdis/build/fish.rds`), the ledger `scripts/logs/habitat/20261017_evidence_build_ledger.csv` (link run
  `20261017_004619-3f4c713b`), the link repository at the build's `link_sha`, and the fwapg database (`PG*`).
  `0320`'s scoring of 22 species × stage took 104 min on 14 workers; CH alone on an 8-gradient grid
  (≈ 4,472 rules, five seeds) is an hour or two in the background.
- The comparison on link's segments: `knw_compare_rules()` takes one tuned rule and the **grade table**, whose
  `dist_m` is walked by `knw_grade_species()` only for segments with `gradient <= pick$grad_max` that fail the
  size test. For an 11 % rule, segments in the 9–11 % band have no walk, so the exception's gains there would be
  undercounted. Each steeper candidate therefore needs `knw_grade_species()` at that rule (≈ 8 min for CH's 125
  groups) before its compare. `0330`'s compare stage was 7 min for all species on 6 workers.
  `data/compare/CH_rear_segments.rds` (ignored) holds per-segment flags under the recommended rule, so km added
  beside the recommended rule, by reason (gradient band, exception, river-polygon branch), is a join on
  `id_segment`.
- River-polygon caveat to keep: link applies the gradient maximum to river polygons; the scoring sees no
  river-polygon visit; 0 of 156 river-polygon visits above 5.49 % caught CH (`research/chinook_rearing_tuned.md`,
  Limits, Gradient). The compare's `change` table has a river-polygon reason, so the km a steeper maximum adds on
  river polygons is reportable.
- Article data: `data-raw/vignette_chinook.R` copies tables and records md5s; `tests/testthat/test-vignette-data.R`
  fails when a tracked source moves. Adding the extended grid's table as a tracked source keeps the article's new
  sentences computed, not typed. The script reads the database for the BULK geometry.
- `.gitignore` ignores `data/tune/*_score.rds` and `*_curve.rds` at the top level only; a subdirectory needs its
  own lines. `knw_thresholds_table()` lists `data/tune/*_summary.csv` non-recursively, so a subdirectory cannot
  leak into `0325`'s thresholds table.
- Script naming: run-order number plus `noun-verb`, so `scripts/0322-tune-grad-extend.R`, between `0320` and
  `0325` in `scripts/README.md`.

### Phase 1: `knw_tune_run()` takes a grid, and its cache is keyed on the grid
- [ ] `R/tune_run.R`: add `grid_args = list()` (passed to `knw_tune_grid()` with `do.call`), documented; the cache
      read also requires `identical(sc$rules$rule, grid$rule)`, else it rescores
- [ ] `tests/testthat/test-tune_run.R`: `grid_args = list(grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15))`
      gives 4,472 rules; a cache written on the 5-gradient grid is refused by an 8-gradient run (restore the bug,
      prove the guard fires: with the grid check removed the stale cache is read)
- [ ] `devtools::document()`, `lintr::lint_package()`, `devtools::test()`; commit

### Phase 2: the extended scoring run
- [ ] `scripts/0322-tune-grad-extend.R` (header in `0320`'s shape: WHY, INPUT, OUTPUT, RUN): CH rearing only, the
      same evidence build, link thresholds at the ledger's `link_sha`, seeds, bootstrap and `d_floor` as `0320`,
      with `grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15)`; `cache_dir = "data/tune/grad_ext"`;
      writes `data/tune/grad_ext/CH_rear_{tune,seeds,honest,groups,summary}.csv` (tracked) and `_score.rds`,
      `_curve.rds` (ignored: two `.gitignore` lines); log `scripts/logs/habitat/<date>_tune_grad_extend.txt` with
      the region, best per gradient, nested selection, more seeds, and the bootstrap recommended and region shares
      by gradient
- [ ] Run it in the background (`WORKERS=8`), the start time from `date -u`; wait for the exit, then read the log
      and the tables
- [ ] Regression check in the script's log: the 2,795 rules shared with `data/tune/CH_rear_tune.csv` have identical
      `dev_heldout` (same folds, same seed); report whether the best, the region's membership and the recommended
      rule moved
- [ ] Commit the tables and the log

### Phase 3: the steeper rules beside the recommended one on link's segments
- [ ] Same script, `STAGE=compare` (reads the Phase 2 tables): for each steeper gradient (11, 13, 15 %), the
      recommended rule's other parts with that gradient; `knw_grade_species()` at that rule on all 125 CH groups
      (the main run's `CH_rear_curve.rds` for the rate, so graded km is provisional as under #65), then
      `knw_compare_rules()` against `default`; `data/compare/grad_ext/CH_rear_g<pct>_{compare,change,checks}.csv`
      (tracked) and `_segments.rds` (ignored)
- [ ] From the segments joined to `data/compare/CH_rear_segments.rds` by `id_segment`: km each rule adds and
      removes beside the recommended rule, by reason (stream segments in the new gradient band passing the size
      test; the exception in the band; river-polygon segments in the band; connectivity), and FDIS detection on
      the added km
- [ ] Run (background), log `scripts/logs/habitat/<date>_tune_grad_extend-compare.txt`; commit

### Phase 4: the research record
- [ ] `research/chinook_rearing_tuned.md`: a section "The gradient maximum above 9 % (#67)" under the
      province-wide paragraph: the extended region, best per gradient with deviance and SE, picks on the main
      reading and the four seeds, bootstrap shares by gradient, the km table beside the recommended rule, the
      river-polygon km, and the decision (`CH_rear_v1` stays at 9 %: the reason; or the follow-up issue filed);
      the `**Verified:**` line and the Gradient limit bullet updated
- [ ] `research/habitat_thresholds_tuned.md`: the sentence on CH's gradient moving up to 9 % gains the pointer;
      `research/README.md` row for `chinook_rearing_tuned.md`
- [ ] `scripts/README.md` run order (0322 line); `CLAUDE.md` layout bullet for `data/tune/grad_ext/` and
      `data/compare/grad_ext/`; `NEWS.md` entry (no version bump: `/gh-pr-merge`'s)
- [ ] Every quantified claim in the new text checked against the tables (audit per row); commit

### Phase 5: the article stops saying nothing steeper was tried
- [ ] `data-raw/vignette_chinook.R`: read `data/tune/grad_ext/CH_rear_tune.csv` (md5-tracked) and save its best
      rule per gradient (`dev_heldout`, `ddev_best`, `se_diff`, `in_region`, `boot_rec_share`) as `x$grad_ext`;
      rerun the script
- [ ] `vignettes/chinook_rearing.Rmd`: the two sentences (near lines 297 and 477) computed from `x$grad_ext`
      (which steeper limits were scored, whether any entered the region, where the best sits), nothing typed; the
      "least settled part" paragraph stays
- [ ] `tests/testthat/test-vignette-data.R` passes on the new md5s; `pkgdown::build_article("chinook_rearing")`
      renders locally and the two passages read correctly; commit

### Phase 6: close out
- [ ] If a steeper rule is the main reading's recommended rule: file the follow-up issue (extend the ladder for
      every species, retune, republish `thresholds`), link it from the research section and this body
- [ ] Edit this body: the findings as spec, the research section linked
- [ ] `/code-check branch`; `/planning-archive`; `/gh-pr-push`

### Validation
- `devtools::test()` green, including the vignette-data md5 tests after the data script rerun
- `lintr::lint_package()` clean on the touched files
- The Phase 2 log's regression line: 2,795 shared rules identical in `dev_heldout`
- The article's two gradient passages render from `x$grad_ext` with no literal numbers

## Errors Encountered

| Error | Resolution |
|-------|------------|

## Phase 1: what the grid and the cache depend on (2026-10-19)

- `knw_tune_score()` returns `rules` in grid order (`res <- tibble::as_tibble(grid)`), so the cache can be keyed
  on `identical(sc$rules$rule, grid$rule)`.
- Folds come from `.tune_fold_of_wsg(d, resp, seed, folds)` and the bootstrap from `seed_boot` over groups: neither
  depends on the grid, and held-out deviance is computed per unique membership pattern. So a rule shared by two
  grids should get the same `dev_heldout`; `ddev_best`, region and picks can move only if the best moves.
- Pre-existing, not changed: in `knw_tune_run()`, a species absent from `thresholds` takes the
  `knw_tune_grid(thr[0, ], stage)` branch, which stops ("thresholds must be one species' row") instead of
  recording `no_stream_rule`. Every species in link's table has a row, so it has not bitten.

## Phase 2: the ladder to 15 % (2026-10-19, `scripts/logs/habitat/20261018_tune_grad_extend-to15.txt`)

- 4,472 rules, 13.6 min on 8 workers. Regression: all 2,795 rules shared with 0320's grid equal in `dev_heldout`
  (largest difference 9.1e-13, against 0320's unrounded scores from another host).
- The best, the pick and the recommended rule are all `mad>=0.75|g<=0.15|Q1@D1000` (held-out deviance 1131.00).
  The 9 % rule (`CH_rear_v1`) is +19.66 (SE 22.14), still in the region; the region grows from 23 to 51 rules,
  gradient 7-15 %. Best per gradient: 7 % +21.2 (SE 29.0), 9 % +19.7 (22.1), 11 % +11.6 (16.5), 13 % +15.6 (34.1).
- Bootstrap recommended share by gradient: 15 % 55 %, 11 % 21 %, 5.49 % 12.5 %, 13 % 7.5 %, 7 % 3.5 %, 9 % 0 %.
- The four other seeds all recommend a 15 % rule (two with Q3@D1000, one Q1@D1000 at 0.5 m3/s, one Q3@D2000).
- Of the 559 rule shapes, 483-495 score better at 11, 13 or 15 % than at 9 %; none tie.
- Visits behind it (scoring population, 4,490 visits, 215 CH): 214 visits with 9 CH at 9-11 %, 127 with 3 at
  11-13 %, 56 with 5 at 13-15 %; above 15 % 236 visits with 2 CH. The 15 % result rests on 17 catches above 9 %.
- The best sits at the top of the ladder again, so the issue's question is not answered by this run.

## Phase 2: the ladder to 30 % (2026-10-19, `scripts/logs/habitat/20261018_tune_grad_extend.txt`)

- 6,149 rules (11 gradients), 22.4 min on 8 workers; regression as before (2,795 shared rules within 9.1e-13).
- The best stays `mad>=0.75|g<=0.15|Q1@D1000`, so 15 % is interior now. Best per gradient behind it: 20 % +5.3
  (SE 4.6), 25 % +10.7 (SE 5.2), 30 % +7.3 (SE 9.9); every gradient from 7 % to 30 % has rules in the region
  (91 rules). Below 7 % none does.
- Bootstrap recommended share by gradient: 15 % 43 %, 30 % 17.5 %, 11 % 17 %, 5.49 % 11.5 %, 13 % 7 %, 7 % 3 %,
  20 % 0.5 %, 4 % 0.5 %, 9 % 0 %. The four other seeds recommend 15 %. Nested selection picks 11 %, 15 % (three
  folds) and 30 %.
- Reading: the records place the gradient maximum at 7 % or above and cannot rank the values from 7 % to 30 %;
  15 % is best by a few deviance units. A steeper limit scores at least as well as 9 % for most rule shapes
  (392-495 of 559 at each gradient).
- Compare candidates (Phase 3): CH_rear_v1's parts at 11, 13, 15 and 30 %, and the extended recommended rule.
  Smoke run on BULK (4.2 min): regenerated default equals 0330's to 5e-12 km; beside CH_rear_v1 the 11/13/15 %
  rules add 29/42/44 km and the recommended rule (Q 1 m3/s) 289 km, removing none.

## Nested selection on the 30 % ladder (2026-10-19)

Summed over folds (`data/tune/grad_ext/CH_rear_honest.csv` against `data/tune/CH_rear_summary.csv`): the extended
ladder's choices 1,389.4, 0320's 1,234.5, `default` 1,347.0, no rule 1,382.5. Folds 1 (11 % pick, 299.6 vs 201.7)
and 4 (30 % pick, 333.9 vs 233.9) carry the loss. The steeper limits' edge on the main reading does not carry to
groups the choice has not seen; this is the main reason `CH_rear_v1` keeps 9 %, beside the shared ladder.
The extended run's own curve has held-out deviance 2,442.7, worse than no rule (round-1 review).

## Code-check round 1 (`review-round1.md`)

1. `rec_g15` (Q 1 m3/s) is graded with 0320's curve, which reads distance to a Q 3 river: its graded km is wrong;
   its habitat km is right (the exception uses its own walk). [fixed: 0322 logs it and its graded km is not reported]
2. Resume caches keyed by candidate name only. [fixed: a candidate is done when its compare csv carries the rule;
   otherwise graded afresh; a moved link run is caught by the default-km check]
3. Two late `stop()`s lost the log. [fixed: log written first]
4. The article's "fit as well or slightly better" was unguarded. [fixed: stopifnot]
5. scripts/README.md and CLAUDE.md said 15 %. [fixed]

## Code-check round 2 (`review-round2.md`)

No wrong numbers; round 1's fixes hold. 1. A failed regression only logged, after the tables were written, and the
article reads two of them. [fixed: log, remove the tables, stop] 2. The header said nothing reads the outputs; the
article does. [fixed] Neither finding sits inside a round 1 fix.
