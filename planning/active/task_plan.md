# Task: Backlog move 14: Window flow follow-ups (#233)

**If we do it:** we learn whether chinook rearing picks its streams better by late-summer flow than by MAD, and what low flow looks like inside each life-stage window at the gauges, from one set of window-flow outputs. **If we never do:** the rule stays on MAD although #105's Phase 1 found a window reading moves 6.2 % of scored visits, and the window flows stay 30-year means that cannot say how low a stream gets.

## Context

Move 14 batches #226 (#105's Phase 2) and #227 (the rest of #42). Phase 1 (2026-11-18,
`research/chinook_window_flow.md`) found that reading late-summer flow instead of MAD moves 6.2 % of the 4,858
scored chinook rearing visits to the other side of the published rule (`mad>=0.75|g<=0.09|Q3@D1000`, run
`20261103_0838`), which passed the stop rule set beforehand. This plan scores the rule on window flow beside
MAD, so we learn whether a window picks chinook streams better, without grading, comparing or publishing
anything.

What the exploration found that shapes the plan:

- The scorer already takes a reading: `knw_tune_run(cols = c(mad = <column>), src = <walk source>)`
  (`R/tune_run.R:108`), and `knw_rule_in()` looks walks up by `src|qmin` (`R/rule_in.R:63`). A window column
  on the visits and window-walk rows under their own `src` label are all a reading needs. No scorer change.
- `0320` writes candidates for promotion and takes no reading, and its only no-grade mode (`DEV=1`) drops the
  bootstrap, nested selection and extra seeds #226 asks to read. `scripts/0322-tune-grad-extend.R` is the
  pattern for one key scored with every check outside the candidate path.
- The published walk (`inst/sql/ch_dist_profile.sql:68`) reads `q.month = 0`. Its md5 is on every grade record
  and receipt, and `0325`, `0330` and `knw_grade_receipt` refuse a table walked by another md5.
- `wet::wet_flow_window()` on the monthly basis is a day-weighted mean of the months, so a window flow in SQL
  is a weighted sum of months, and the weights can be taken from wet itself.
- This checkout's `data/fdis/derived` is the published evidence (its three md5s are the `CH_rear` summary's),
  and the database on this host holds the published build and the flow load the grade record names.
- wet has moved since #227 was written: its monthly-bias issue (`wet#6`) is closed with results by region and
  season, and departures at ungauged sites are its donor method (`wet#118`, shipped at four chinook streams).
- Installed wet is 0.4.33 against 0.4.39 released.

## Decided at the gate (Al, 2026-11-21)

1. **A separate window walk.** New `inst/sql/ch_dist_profile_window.sql`; the published walk stays
   byte-identical, so no grade table's walk md5 moves and nothing regrades.
2. **Augment the published evidence.** A `data-raw/` script copies the published tables into ignored
   `data/fdis/derived_window/` and adds the window column and window walks. `0310` is not touched and not run;
   it learns the column later, only if a window wins.
3. **#226 only.** #227 stays its own issue for its own `/planning-init`; its body is updated now with what is
   wet's and what is left for knowledge, and batch 21 of `planning/backlog.md` records the split.
4. **The verdict rule is set before any scoring**, written into `research/chinook_window_flow.md` and
   committed first: a window reading beats MAD only if (a) its recommended rule's held-out deviance is lower
   than the MAD reading's recommended rule's by more than one SE of their paired difference over the 45
   groups, (b) it is lower on at least 3 of the 4 extra fold seeds (55 to 58), and (c) it is still lower with
   the lower Fraser (LFRA) left out. Every other check is listed with its direction whatever the verdict.

Mine, stated so they can be overruled (mechanism, not scope):

- The four readings are scored by `knw_tune_run()` at `0320`'s settings from a script of their own, as `0322`
  does, not by `0320` itself (#226 says "scored by `0320`").
- The windows and basis are Phase 1's: rearing 08-01 to 09-30 on the stream, spawning 08-15 to 09-15 on the
  river, wet's monthly flow on the pick source, from the database's load.
- "Add the window to the walk cache's key" is met through the walk's source label (`pick@0815-0915`), which is
  in the cache's primary key, and the window walk's own md5; window rows go to their own table
  (`knw.walk_cache_window`), so the published cache holds only published walks.
- Tracked per reading: summary, seeds, nested picks, groups, smoke and the region's rules. The full grid
  (1.3 MB a reading) stays in the ignored score cache; the MAD control's is the published table.
- **wet 0.4.33 to 0.4.39 before any run** (approving the plan approves the upgrade).

## Phase 1: The rule on record, and the batch split

- [ ] `research/chinook_window_flow.md`: a "Phase 2" section with the four readings (MAD/MAD as control,
      window on the stream, window on the river, both), that all four score the same rows, and the verdict
      rule of decision 4, exact; header status updated. Committed before any scoring; the scoring script
      refuses otherwise and logs the commit it read (Phase 1's guard).
- [ ] #227's body: `wet#6` is closed with its results (monthly error by region and season), carrying
      departures to ungauged segments is wet's donor method (`wet#118`), what is left for knowledge (window
      means, 7-day minimums and departures by year at gauges; then threshold flags on segments), and that it
      was split from move 14. #233's body: the split and the gate decisions. `planning/backlog.md` batch 21:
      #227 left for the next `/backlog-sweep`.
- [ ] Upgrade wet to 0.4.39 (`pak::pak("NewGraphEnvironment/wet")`); the versions go in each run record.

## Phase 2: Window flow at a segment (package)

- [ ] Tests first, `tests/testthat/test-link_flow.R`, on its fixture tables: the window flow equals
      `wet::wet_flow_window()` on the same months; a segment with no flow of its own reads its parent's months
      on the parent's pick source; no pick gives `NA`; a segment without months 1 to 12 on one pick source
      refuses.
- [ ] `knw_link_flow_window(conn, linear_feature_id, windows)` in `R/link_flow.R`: the segment MAD came from
      (own or `parent_lfid`, from `.knw_link_flow_sql()`), its 12 months on the pick source, then
      `wet::wet_flow_window()`. Returns `linear_feature_id`, the MAD read again (for the caller's equality
      check) and one column per window, `flow_<mmdd>_<mmdd>`.
- [ ] `.knw_window_weights(window)`: the 12 month weights of a window, taken from `wet::wet_flow_window()` on
      unit series, so R and the SQL walk share wet's arithmetic. Test: weights sum to 1; 08-15 to 09-15 is
      17/32 and 15/32.
- [ ] roxygen, `_pkgdown.yml` reference entry, `devtools::document()`, `pkgdown::check_pkgdown()`.

## Phase 3: The window walk (package)

- [ ] `inst/sql/ch_dist_profile_window.sql`: the published walk with two more arguments (`months integer[]`,
      `weights float8[]`), function `pg_temp.ch_dist_profile_window`, and the flow read replaced by the
      weighted sum of the months on the source, taken only where every month is present. The changed region
      is marked (`-- window flow: begin` / `end`). `large_mad` carries the river's window flow.
- [ ] Test without a database (runs on CI): the two SQL files are the same text outside the header comment,
      the signature and the marked region; and `knw_walk_md5()` is the md5 every tracked
      `data/tune/*_grades_record.csv` names.
- [ ] `knw_link_walks(window = NULL)` in `R/link_walks.R`: with a window it installs the window walk, passes
      the weights, and returns `src` as `<source>@<mmdd>-<mmdd>`; a cache row is keyed on that label and
      `knw_walk_md5(window = TRUE)`. Without a window nothing changes (the published path's SQL text and
      cache key are the same strings as before).
- [ ] Tests on the database (`tests/testthat/test-link_walks.R`, skipped without one): the window walk given
      month 0 at weight 1 returns the published walk's rows on the test starts; at 08-15 to 09-15 each found
      river's `large_mad` is `wet::wet_flow_window()`'s value for that segment and reaches its `qmin`; a cold
      then warm cache; a second window reads none of the first window's rows.
- [ ] Restore the bug: with the marked region put back to `q.month = 0`, the window tests must fail.

## Phase 4: The evidence with a window (database, on its host)

- [ ] `data-raw/chinook_window_evidence.R`: refuses unless it, `R/` and `inst/sql/` are committed; reads
      `data/fdis/derived` and stops unless its md5s are the `CH_rear` summary's; stops unless the flow load is
      the grade record's; `knw_db_latency_check()`; logs `pg_stat_activity`. Adds `flow_0801_0930` to every
      visit through `knw_link_flow_window()`, walks every start on `pick` for 08-15 to 09-15 on the ladder
      1, 3, 5, 10, 20, 30, 50 m³/s, adds the lake and regulated target flags as `0310` does, and appends those
      rows to the walks.
- [ ] Assertions in the script: MAD read again equals `mad_pick` at every visit; the window column is present
      exactly where `mad_pick` is; the published rows of all three tables are unchanged (same row count, and
      the original columns identical to the source).
- [ ] Checks against Phase 1, printed: the median window share of MAD at the scored visits is
      `ch_rear_run.csv`'s `med_rear_visit`, and each group's median is `ch_rear_ratio_by_group.csv`'s; how many
      visits' nearest window river differs between the exact walk and Phase 1's ladder approximation.
- [ ] Run it: `data/fdis/derived_window/{visits_link,visits_species,walks}.csv` and `window_run.csv` (source
      md5s, flow load, both walk md5s, weights, versions, commit); log
      `scripts/logs/flow_window/<date>_chinook_window_evidence.txt`.

## Phase 5: Score the four readings (no database)

- [ ] `data-raw/chinook_window_tune.R`, on `0322`'s pattern: `knw_tune_run()` for `CH` rearing at its defaults
      (seed 54, 5 folds, 200 bootstrap resamples, seeds 55 to 58, `d_floor` 200, `segment_gradient`), link's
      thresholds at the published ledger's commit from `LINK_REPO`, the readings as `cols[["mad"]]` and `src`.
      `STAGE=smoke` runs the smoke gates for all four and stops on any failure (#84); `STAGE=score` scores.
- [ ] The control must reproduce the published run: every rule's held-out deviance in
      `data/tune/CH_rear_tune.csv` (to its 6 decimals), the pick, the recommended rule, the region and the
      summary's seed and nested-selection values. The script stops otherwise.
- [ ] The paired comparison: one `knw_tune_score()` over each reading's recommended and best rules together
      (a `rule_in` that reads each rule's own column and source), which gives each rule's deviance behind the
      best and the SE of that difference on the same groups and folds; again on seeds 55 to 58.
- [ ] LFRA left out: each reading rescored without the lower Fraser's visits (main seed), and the same paired
      comparison.
- [ ] Outputs, `data/tune/flow_window/` only: `ch_rear_tune_run.csv`; per reading
      `<reading>/CH_rear_{summary,seeds,honest,groups,smoke,region}.csv`; `ch_rear_readings.csv` (the paired
      comparison by seed, with and without LFRA). Confirm nothing that publishes lists `data/tune/` below its
      top level.
- [ ] Run the smoke stage, read it, then score; log `scripts/logs/flow_window/<date>_chinook_window_tune.txt`.

## Phase 6: Read it and write it up

- [ ] `research/chinook_window_flow.md`, revised in place: the plain-language walk first (what the rule reads
      now, what was asked, how it was judged, what came back), a table of the four readings, then every check
      with its direction (held-out score, the nested folds' picks, the seeds, the bootstrap shares by exact
      rule and by reading, with and without LFRA, the curve's deviance), the verdict by the rule, the caveats;
      header (`Verified`, `Produced by`, `Status`) and "What next" brought up to date.
- [ ] If a window beats MAD: file the follow-ups, each naming move 14 (windows that move by group with timing;
      link reading a window flow; the column in `0310`). If not: say so in `research/chinook_stream_size.md`
      and the limits of `vignettes/tuning-method.Rmd`. Either way #226's body carries the result.
- [ ] `CLAUDE.md` (the `data/tune/flow_window/` and `data/flow_window/` lines), `scripts/README.md`,
      `research/README.md` row.

## Owed at the end (reported, done after merge)

- [ ] Grading, comparing or publishing any window rule: each waits on Al's word.
- [ ] #227 under its own `/planning-init`.

## Validation

- [ ] Tests pass (`devtools::test()`; the database tests run here, with `NOT_CRAN=true`)
- [ ] `lintr::lint_package()` adds no lint; `devtools::document()`; `pkgdown::check_pkgdown()`
- [ ] `/code-check branch` clean
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:

- **The published walk is untouched:** `git diff origin/main -- inst/sql/ch_dist_profile.sql` is empty, and
  the CI test holds `knw_walk_md5()` to the tracked grade records.
- **The window walk is the published walk but for the flow it reads:** the text test, and equality with the
  published walk at month 0 on the database.
- **The window flow is wet's:** fixture test against `wet::wet_flow_window()`, and Phase 1's medians
  reproduced on the real evidence.
- **The readings differ only in the window:** the control reproduces the published table rule by rule, and
  the augmented tables keep the published rows and columns unchanged.
- **The verdict was not chosen after the fact:** the rule's commit precedes the scoring log's, which names it.
- **Nothing published moved:** `git status` shows no change under `data/tune/` outside `flow_window/`, none to
  `data/thresholds*.csv`, `inst/vignette-data/` or `data/compare/`.

