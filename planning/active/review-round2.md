# Code-check round 2 (#145): branch 3140693...HEAD, with round 1's fixes (a950b3d, 3e8fcda)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped).
- code-check-r.md: read in full "testthat counts an uncaught error under `error`, not `failed`", "A database driver's
  value is not a base R type", "A value compared as `::text` in SQL has PostgreSQL's spelling", "Postgres row order is
  never fixed unless the query fixes it", "Rscript reads a script as it runs", "`system2(stdout = TRUE)` warns on a
  non-zero exit", "A `function(...)` mock hides arguments" (7). Checked against the index line only: `ifelse()` with an
  all-NA test, `match()` treats NA, `$` partial matching, `paste()` zero-length, `on.exit()` at top level, `tryCatch()`
  nesting. About 100 other sections not read.
- code-check-shell.md, code-check-spatial.md: index only. The diff has no shell, sed or spatial code beyond
  `system2("git", ...)`, which the R heading covers. 0 sections read in full.

## Clean

No issues found.

## Checked and holding

- Round 1 fix (2), 0300's refusal at release. I drove a scratch copy of `scripts/0300-link-settle-wait.R` with `poll()`
  stubbed to three equal complete polls and `shas()` stubbed to raise `.knw_build_log_runs()`'s late-run message. It
  exited 3 and left only `<date>_link_settle-zz_test_refused.csv`, whose last row is `refused` with the message in
  `note` and whose earlier rows have an empty `note`. The polling file was removed. 0310's default pattern
  (`_link_settle\.csv$`) does not match the `_refused` name, and a `SETTLE=` pointing at it stops on its status. If
  the deleted polling file lets a plain `0310` fall back to an older day's released log, `knw_build_record()`'s run
  check refuses it, so nothing is built on the wrong run.
- Round 1 fix (1), the stamp in `pick_network_compare.R`. It now sees an untracked `R/` file and the script itself.
  The regenerated `20261104_pick_network_compare.txt` names a950b3d, which holds the script. The sibling stamps under
  `--untracked-files=no` (`tune_anchor_check.R`, `0320`, `0325`, `0299`) are not on this branch and cover files that
  were already tracked.
- Round 1 fix (3): "The full network on the same flows and range", above, is in "## The province run", which comes
  after that section. "The next section" (end of the section before it) does name the section that follows.
- `.knw_build_log_runs()`:
  - The no-`log`-rows case gives `lab = logical(0)` and `log_run_uid ""`, then reads every row (0 rows, tokens NA).
  - NULL run ids in `log_recompute` or `log` never enter `kept`.
  - The array literal is built only from ids the regex admits.
  - `params = NULL` with an empty clause is RPostgres's default.
  - `rec$log` matches exactly, so no partial-match hazard (`rec` also holds `log_run_uid`).
  - No caller serializes `rec` whole (0320 reads `$tokens`, 0330 `$discharge_load`, 0336 `$run_uid`/`$discharge_load`/
    `$walk_md5`, the others `$line`), so the new list-valued `log` field reaches no writer.
  - `minimal_network_check.R` parses only the schema prefix of the line, which the set-aside suffix does not touch.
- test-build_record.R on a scratch copy with `PGHOST=invalid.invalid`: 6 blocks, 0 failed, 0 errors, and the live
  block skipped.
- Prose:
  - The segment-start row (44.2 / 6.6 %, 305 / 466 m) matches `20261103_segment_gradient_check-derived_default_20261103.txt`.
  - The province totals (access within 1.5 km; stored rearing +0.52 to +1.75 %, SK -0.11 %; spawning -0.01 to
    -2.78 %) match `20261103_minimal_network_check.txt`.
  - Every pick, the parts moved and each region distance in the table and bullets match
    `20261104_pick_network_compare.txt`.
  - Each key's `<key>_tune.csv` has one row per rule (checked on `data/tune/`), so `place()`'s `match()` is unambiguous.
  - "0310 calls no fresh function" holds: the fresh mentions in the package functions it calls are documentation only.
  - "the main fold seed, which is also the seed a full run picks on" matches 0320's header.

## Considered and not reported

- `0300` still dies with its last row `polling` when `poll()` itself errors mid-wait (database unreachable). That is
  older than this branch, and round 1's finding was about the new `shas()` refusal. A database error inside `shas()`
  at release is now labelled `refused`, with the error in `note`. That is a terminal row either way.
- `0320`'s `fail()` and `0330`'s handler record a `knw_build_record()` refusal under the run's normal log name, not a
  `_refused` one. This is also older than this branch, which only adds new reasons to refuse on that path. Neither
  writes tables, and both stop.
- The fallback (none of `log_recompute`'s runs in `log`, one run in `log`) cannot tell link's proof layout from a
  `log` that holds only a stale run. This is the design the plan chose, and every probed schema reads as expected.
