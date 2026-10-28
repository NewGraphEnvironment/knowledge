# Code-check round 3, #110 (branch 110-check-the-database-s-round-trip-before-a, HEAD 3043680)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md: read in full the sections "`on.exit()` at a script's top level never fires", "Tests that silently do not
  run", "testthat counts an uncaught error under `error`, not `failed`", "`expect_gt()` and friends take no `info`
  argument", "`$` on a list partial-matches", "A database driver's value is not a base R type", "Inserting a helper between
  a roxygen block and its function rebinds `@export`", "Under `R CMD check`, tests run from a temp dir against the INSTALLED
  package", "`tryCatch(warning = )` DISCARDS the value", "`tolerance` in testthat is RELATIVE", "`[[` on a named ATOMIC
  vector with an absent key", "Postgres row order is never fixed", "`sprintf(\"%g\", x)` writes `Inf` and `NA` into SQL",
  "An `information_schema` lookup by the literal table name", "Rscript reads a script as it runs", "A `pkg::` call in a
  test passes `devtools::test()`", "`c(name = x)` keeps `x`'s own name", "A `function(...)` mock hides arguments",
  "`tryCatch()` nests its handlers" (19 sections); the other 92 not read (no tool or shape in the diff).
- code-check-shell.md: index only; no shell, sed, git or gh code in the diff (0 sections read, all not read).
- code-check-spatial.md: index only; no spatial code in the diff (0 sections read, all not read).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables and evidence blocks skipped); no "Rules that stand
  alone" sections read.

## What was checked (all against HEAD 3043680, mutations in a `git archive HEAD` copy under the scratchpad)

Mutation table (`testthat::test_file()` from the copy, `NOT_CRAN=true`, failed/error counted):

| mutation | test-db_latency.R / test-compare_rules.R |
|---|---|
| none (baseline) | 0 failed, 0 error (live block ran: 1.3 ms) |
| `if (over && !remote)` -> `if (FALSE)` (guard removed) | 3 failed |
| `if (over && !remote)` -> `if (over)` (`remote` ignored) | 1 error |
| `over <- ms > limit_ms` -> `ms > 200` | 5 failed |
| `over <- ms > limit_ms` -> `ms >= 1.6` | 1 error |
| `* 1000` -> `* 1` (seconds, not ms) | 1 failed |
| timer: `last <<- now` deleted (double-counting) | 1 failed |
| timer: tick records minutes since start | 1 failed |
| `stats::median(ms)` -> `sum(ms)` | **0 failed, 0 error** |
| `stats::median(ms)` -> `max(ms)` | **0 failed, 0 error** |
| `seq_len(n)` -> `seq_len(1)` (`n` ignored) | **0 failed, 0 error** |

- RPostgres 1.4.10 / DBI 1.3.0: `DBI::dbGetQuery()` with no params goes through `dbSendQuery(immediate = FALSE)`, the
  prepared path; the roxygen and plan say the 1.6 / 104 ms figures were taken on that same path (not re-measurable here,
  the archive scripts are not in the repo), so the 20 ms limit is compared like with like. Not a finding.
- `n` validation: `chk_whole_number()` + `chk_gte(n, 1)` run inside `knw_db_latency()` before
  `sprintf("%d", as.integer(n))` in the check, so the integer conversion never sees a fractional or NA `n`.
- sprintf/say formats: every new `%d` gets an integer (`nrow(seg)`, `as.integer(n)`), every `%.1f`/`%g` a double; condition
  messages and `lat$line` go through `"%s"` or `message()`/`stop()`/`paste`, never as a format; no `%` in a format comes
  from data.
- `run_one()`'s `t0` is local (set at its first line), so "Grade table read" is that key's read, not time since script start.
- `knw_compare_rules()`: no early `return()` between the ticks; each tick measures from the previous one, so stages cannot
  double-count; `timing` is read by no consumer; `data-raw/compare_parallel_check.R` and `0322` compare tables by name only.
- Docs against code: CLAUDE.md, research/database_builds.md, scripts/README.md, the 0310/0320/0330 headers and the roxygen
  all say what runs (0310 always; 0320 only when `!main_only`, i.e. not DEV=1 and not GRADIENT=fwa_gradient; 0330 before
  the STAGE branches, so every STAGE; override `REMOTE=TRUE`, also `1`/`true`; the line and the override are logged/ledgered).
  The `.knw_timer()` comment says `total()` is "the minutes since the start"; it is the minutes to the last tick. Only the
  test calls it, so nothing is wrong today.
- Observation, not a finding (design choice): 0320's check runs at connect, before the CPU-bound scoring, so the
  "score on a remote machine, grade on the host" pattern of #73 now needs `REMOTE=TRUE` on the remote machine, which also
  lets that run go on to grade remotely. scripts/README.md still says "scoring runs on any machine with the build", which
  remains true with `REMOTE=TRUE`.
- test-settings-register.R and test-data-dir.R pass on the copy; `tools:::.check_packages_used_in_tests()` reports nothing.
- Public-text scan of the diff: no hosts, ports, logins, paths or private links.

## Findings

- **[severity: fragile]** tests/testthat/test-db_latency.R:3-11 — the block named "the round trip is the median wall time
  of the queries" cannot tell a median from a sum, a max or a single query: the mock sleeps the same 30 ms on every call
  and the assertions are only `ms > 20` and `ms < 1000`. Replacing `stats::median(ms)` with `sum(ms)` or `max(ms)`, or
  `seq_len(n)` with `seq_len(1)`, in R/db_latency.R:44-49 leaves the file at 0 failed, 0 error (table above). It matters
  because the median is what keeps the guard from refusing a run on the host: a `sum()` regression gives
  20 x 1.6 ms = 32 ms on the host, over the 20 ms limit, so every 0310, grading 0320 and 0330 on the host would stop, and a
  `mean`/`max` regression lets one slow query (the first on a fresh connection, a checkpoint) refuse a host run. The
  `line` would still say "median of 20". A mock whose sleeps differ per call (e.g. 0.2, 0, 0 s in call order with `n = 3`: the median is
  about 0, while a mean, sum, max or first-call-only result is about 67 ms or more; or count the calls) would pin both the median and `n`.
