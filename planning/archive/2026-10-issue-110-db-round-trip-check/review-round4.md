# Code-check round 4 (#110): review of the round-3 test fix, and the mechanism behind rounds 1 and 3

Reviewed at 4c808ea, diff `branch.diff` (planning/ excluded). Nothing in the repository was edited except this file;
probes ran on a `git archive HEAD` copy in the session scratchpad. No database was written to, and no `scripts/03*.R` was run.

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped). Other headings: none read in full
  (index only); 26 not read.
- code-check-r.md: read 18 sections: `on.exit()` at a script's top level; Tests that silently do not run; testthat counts
  an uncaught error under `error`; A `skip_if_not()` skips only its own block; `expect_gt()` takes no `info`; `$` on a
  list partial-matches; Under `R CMD check`, tests run against the INSTALLED package; `tryCatch(warning = )` DISCARDS the
  value; Do not abort inside a handler for a C++ warning; `match()` treats NA as a value (it ran on in the same read);
  `tolerance` in testthat is RELATIVE; `[[` on a named ATOMIC vector; A `pkg::` call in a test; A `function(...)` mock
  hides arguments; `expect_message(regexp = "...$")`; `load_all()` refuses an installed dependency below the floor;
  `tryCatch()` nests its handlers; `fs::file_move()` (it ran on in the same read). Did not read about 100 others.
- code-check-shell.md: no sections read. The diff has no shell code. Index only.
- code-check-spatial.md: no sections read. The diff has no spatial code. Index only.

## Findings

- **[fragile] tests/testthat/test-db_latency.R:14-24**: the round-3 fix pins four of the five things its title claims.
  The title says "the median of all n, not a sum, mean, max or the first". Mutating `stats::median(ms)` in
  `R/db_latency.R` (copy of HEAD, `testthat::test_file()`, failed and error counted):

  | variant of the return value | "median wall time" block | "one slow query" block |
  |---|---|---|
  | `stats::median(ms)` (HEAD) | pass | pass |
  | `sum(ms)` | pass | **fail** |
  | `mean(ms)` | pass | **fail** |
  | `max(ms)` | pass | **fail** |
  | `ms[1]` | pass | **fail** |
  | `min(ms)` | pass | pass |
  | `stats::median(ms[-1])` (drop the first query as a warm-up) | pass | pass |
  | `stats::median(ms[2:3])` | pass | pass |

  The four regressions the title lists all go red. "The median of all n" does not hold. `min` passes, and so does a
  median that drops the first query as a warm-up. The roxygen rules that warm-up out ("with no warm-up, which is the
  path the host's 1.6 ms ... were measured on"). The cause is round 3's mechanism (below) one level down: the two fast
  calls both sleep 0, so the median, the min and any statistic of the fast pair all give the same value.
  This is not a production defect. Production's median code is correct, and either surviving variant would still refuse
  a remote link. It is a test claim the test does not back.

  A cheap fix that does not add flakiness: drop "the median of all n" from the title, so it claims only what it pins
  (not a sum, mean, max or the first query). The obvious way to pin it fully, three distinct sleeps, is not safe here.
  I tried `c(0.3, 0, 0.06)` with `45 < ms < 100`. It catches `min` and `median(ms[2:3])`, but it **failed on the correct
  median**, because `Sys.sleep()` overshoots heavily on this machine:

  | requested | measured (10 runs, load average about 4.7) |
  |---|---|
  | 0.03 s | 159 to 179 ms |
  | 0.06 s | 153 to 210 ms |
  | 0.2 s | 303 to 350 ms |
  | `Sys.sleep(0)` | 0.0 to 0.1 ms |

  So any fixture that needs two non-zero sleeps to be ordered or bounded is flaky. Pinning `min` or a warm-up drop would
  need a fake clock, not sleeps.

### The questions asked about the fix

- **Flaky under load?** Low risk, and measured, not guessed. The bound reads only the fast calls, and they never sleep.
  Over 20,000 runs of one fast call (`Sys.sleep(0)` plus `data.frame(x = 1L)`) under load average about 4.7, the times
  were: median 0.035 ms, 99.99th percentile 1.25 ms, maximum 10.5 ms. To fail, one of the two fast calls has to stall
  for more than 50 ms. The likeliest cause is a full GC landing inside that call. A full `gc()` with the package loaded
  took 33 to 38 ms here, so a runner about 1.5 times slower could cross 50 ms, but only if a full collection falls in
  those microseconds. The slow call's overshoot does not matter, because the median ignores it. Side note: the comment's
  "a sum or max is ~200 ms, a mean ~67" reads about 350 and 117 here. The direction holds, so every mutant still fails.
- **Does `calls` index past the sleep vector if `n` changes?** Raising `n` takes `c(0.2, 0, 0)[4]`, which is `NA`, and
  `Sys.sleep(NA)` errors with "invalid 'time' value". The block then errors, loudly. Lowering `n` to 2 gives a median of
  about 100 ms and `calls == 2L`, which fails both assertions. Neither direction fails silently.
- **Red for each regression it claims?** Yes for sum, mean, max and the first query (table above). No for "the median
  of all n" (the finding).

## Mechanism behind rounds 1 and 3

**Two states the code must tell apart were given one representation, because the run assumed its cases are uniform.**
- Round 1: a refused run and a real run of the same day shared one log path, as if there were one run per day per name.
- Round 3: the fixture gave every query the same time, as if every query costs the same. With equal inputs, a median, a
  sum (scaled), a max, a mean and the first query cannot be told apart by any assertion.

In code-check.md's terms this is "A proxy is not the property" ("If two values produce identical observations, the
assertion is about something else") and "A guard's scope ..." (a guard that reads a coarser grain than its property).
In a fixture it shows up as "A fixture that cannot reach the failure mode".

Every place in this diff the mechanism reaches:

1. **The fast pair in the round-3 fix** (test-db_latency.R:18): `c(0.2, 0, 0)`. Two equal values make the median, the
   min and a statistic of the fast pair one observation. This is the finding above, proved by mutation.
2. **The first latency block** (test-db_latency.R:3-12): every call sleeps 0.03 s, so it pins only the level, not which
   statistic is taken. Block 2 now covers that, except for item 1.
3. **Refused-log names** in 0320:146 and 0330:159: keyed by date alone, without the run's own suffix. `path_log` carries
   SPECIES, `-dev` and the gradient in 0320, and STAGE in 0330. So a refused `STAGE=gpkg` run and a refused full 0330 run
   on one day share `<date>_compare_refused.txt`, as do two refused grading passes over different SPECIES. This is the
   accepted "two refused runs on one day overwrite" class, listed so it is known that the suffix is dropped too. No
   reader globs these names: 0320, 0325, 0330 and `vignette_method.R` read `_evidence_build_ledger\.csv$`, and 0325 and
   `vignette_chinook.R` read `_tune_run.*\.txt$`. None matches a `_refused` file (checked by grep).
4. **0310's refused ledger** (0310:109): also keyed by date alone. Same accepted class.
5. **0310's `db_remote_override` row** (0310:113): `as.integer(over && remote)` is 0 in two cases: under the limit with
   REMOTE=TRUE, and under the limit without it. Harmless, because no override acted in either case. A refused run is
   still distinct: its ledger is a separate file, and its `db_round_trip_ms` is `NA` with the message. The partition
   check (0310:324) sums only `drop`/`kept`, so the new `info` rows cannot break it.
6. **The log line under the limit** (`knw_db_latency_check()`): with REMOTE=TRUE and with REMOTE unset, the line is
   identical by design. The "fast connection" block pins that.
7. **The stage timer test** (test-compare_rules.R:87-100): checked, and it does tell the cases apart. A `tick()` that
   returned minutes since the start, instead of since the last tick, would make `sum(x)` about 0.17/60 against
   `total()` about 0.07/60 (in minutes), and `expect_equal` fails. Labels are distinct literals, so `[[<-` cannot
   collapse two stages.

## Other items checked, no issue

- 0310's handler calls `add()`, which assigns the global ledger with `<<-` from inside the handler: correct. It catches
  any error from the check, a failed `SELECT 1` included, and records it as refused. That is right: the run stops either way.
- Each `tryCatch()` has one handler, so the "nested handlers" trap does not apply. `stop()` inside the handler is the
  intended raise.
- `knw_compare_rules()`'s new `timing` element: no caller iterates the result's names. 0330 and 0322 read `$log`,
  `$compare` and so on by name.
- Mocking `DBI::dbGetQuery` with `.package = "DBI"` works through `DBI::` (the probe's mutants went red through it).
  DBI and chk are in Imports, and testthat is at least 3.2.0.
- Public-text discipline: no host names, ports or private links in the diff.

## Verdict

One fragile finding: the round-3 test does not back its title's claim "the median of all n". The cheap remedy is to
narrow the title. Pinning it fully needs a fake clock, not sleeps, because `Sys.sleep()` overshoots by 100 to 150 ms on
this machine. Nothing else is wrong.
