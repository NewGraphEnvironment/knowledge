# Code-check round 3 (#67)

Reviewed: the review diff (HEAD fa38406), with R/tune_run.R, tests/testthat/test-tune_run.R, scripts/0322-tune-grad-extend.R,
data-raw/vignette_chinook.R, vignettes/chinook_rearing.Rmd, the called R/ files and the grad_ext outputs and log.
`NOT_CRAN=true` test-tune_run.R in a temp copy: 4 blocks, 19 expectations, 0 failed. No DB, no 0322 run, nothing in the
working tree edited apart from this file.

## The mechanism

Each of the earlier rounds' seven findings has the same shape. One artefact vouches for another, and the code takes the
two as agreeing without checking them where the second is used:

- a cache key's rule string vouches for the grid row;
- compare.csv vouches for segments.rds;
- change.csv's rule vouches for 0320's curve;
- the prose vouches for the stopifnot;
- a written table vouches for the check that should have gated it.

The fix each time was to check the pair. The places below are where this diff still has a pair that is not checked.

## Findings

- **[fragile] R/tune_run.R:127** — the cache key compares rule strings, but a rule string does not carry what the
  scoring reads from the grid. `is_default` and `departures` come from link's default thresholds row, and the pick and
  the recommended rule depend on them. That row is not in the string.
  - Probe, on the test sim: move CH `rear_channel_width_min` from 1.5 to 2. Because 2 is already on `grid_width`, the
    rule strings stay identical. The cache is then read back with default `width>=1.5|g<=0.0549|none` and the old
    `departures`, where the new grid's default is `width>=2|…`, so its pick and recommended rule are another grid's.
  - Inside 0320/0322 the thresholds are pinned to the ledger's link sha, so this is latent there. But the function is
    exported and its doc promises the cache is checked against "the grid".
  - Fix: compare the cached `sc$rules[names(grid)]` with `grid` (every column), not `$rule` alone.

- **[bug] scripts/0322-tune-grad-extend.R:298–365** — the round-2 fix removes the tables only when the regression runs
  and fails, not when it cannot run. Six tables are written (lines 298–336), two of which the article reads (`_summary`,
  `_by_grad`), before the regression at 351.
  - `data/tune/CH_rear_score.rds` is an ignored 0320 cache. It is absent on any other clone or host (the comment at 349
    says 0320 ran elsewhere), and the score stage's INPUT header does not list it.
  - When it is missing, `readRDS` errors at 351. The tables stay, the regression never ran, and no log is written.
  - `data-raw/vignette_chinook.R` checks the grad_ext tables against no 0322 log, so it would build the article from
    them.
  - Any other error between 298 and 365 does the same (`by_grad`, `ties`, the seeds `say()`).
  - The `stop()` at 296, which fires after the score, also leaves without `writeLines(log_lines, path_log)`.
  - Fix: read 0320's score and run the regression on `rules` before the first `write_csv`, so that every way out before
    the writes leaves nothing behind.

- **[fragile] scripts/0322-tune-grad-extend.R:394–395** — 0320's curve is used as the CH_rear_v1 curve without a check.
  - `main$pick$rule` is only logged. The v1 check at 379 ties 0330's change.csv to 0320's tune.csv, not to the
    curve.rds that grades every candidate.
  - In the same way, `base` (0330's `CH_rear_segments.rds`, line 478) is assumed to be v1's segments. Only the
    candidates' regenerated default is checked against 0330's compare.csv. `base$rearing_tuned` km per group is never
    checked against 0330's `tuned_km`.
  - Both agree today: `pick$rule` is `mad>=0.75|g<=0.09|Q3@D1000`.
  - Fix: `stop` unless `identical(main$pick$rule, v1_rule)`, and unless base's rearing_tuned km per group equals 0330's
    `tuned_km`.

- **[fragile] scripts/0322-tune-grad-extend.R:404–408 with 438–441** — the resume marker is written first, and the
  payload it vouches for last.
  - `done_rule()` treats compare.csv (which carries the rule) plus the presence of segments.rds (which carries none)
    as done.
  - `run_one()` writes compare.csv first and segments.rds last.
  - The key `rec_g<pct>` can name a different rule after a rescore. If a worker dies or errors between the two writes,
    the next run finds a new-rule compare.csv beside an old-rule segments.rds and skips the key. `beside_v1.csv` then
    sets the old rule's segments under the new rule's name.
  - Fix: write segments.rds (and change/checks) first and compare.csv last, so that the marker is written last.

- **[fragile] vignettes/chinook_rearing.Rmd:53–57 vs 499–500 (and 317)** — the guard does not cover the claim that
  "`grad(rec$grad_max)` is one choice among limits from `min(ge_reg)` to `max(ge_reg)`".
  - The claim needs 9 % in `ge_reg`.
  - The stopifnot checks that every limit at or above `min(ge_reg)` has region rules. It does not check that
    `min(ge_reg) <= rec$grad_max`, or that `ge_rec$in_region > 0`.
  - A rerun in which 9 % drops out of the region (`min(ge_reg)` = 11 %) passes every guard and prints a false sentence.
  - It holds today (`in_region` = 1 at 0.09, the recommended rule; `min(ge_reg)` = 0.07).
  - Fix: add `ge_rec$in_region > 0` to the stopifnot.

Checked and not flagged:
- the regression's 2,795/2,795 match;
- `identical(exc_q, curve$q)` (both double);
- the gitignore globs (`**/` matches zero directories; the grad_ext rds files are ignored and the csv files tracked);
- 0325, 0330 and `thresholds_table` list `data/tune` and `data/compare` non-recursively, and 0325's log glob
  `_tune_run` does not match `_tune_grad_extend`;
- the vignette md5 sources include both grad_ext files;
- `pct()` names, the candidate filter on NA `exc_q`, and the join keys.

/Users/airvine/Projects/repo/knowledge/planning/active/review-round3.md
