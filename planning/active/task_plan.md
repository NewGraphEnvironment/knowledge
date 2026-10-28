# Task: Check the database's round trip before a database-bound run, and time 0330 by stage (#110)

`CLAUDE.md` says to run the grade and the comparison on the database's own host, and nothing checks it. #92 ran `0330`
from a machine on a remote link and paid for it (`scripts/logs/habitat/20261026_compare*.txt` on the host,
`scripts/logs/habitat/20261027_compare.txt` from the remote link; different runs, so the ratios are approximate):

| part of `0330` | host | remote link | slower by | what it is |
|---|---|---|---|---|
| classify, overlay and connect | 115 min | 164 min | ×1.4 | SQL the database runs itself |
| the rest of the comparison | 48 min | 105 min | ×2.2 | not broken out in the log |
| GeoPackages | 14 min | 197 min | ×14 | 10 million segments' geometry over the link |

Round trips are mostly already paid for: since #87 a grade walks 500 segments per query, 12 to 18 ms per walk from the
remote link against about 3 ms on the host and 116 ms one query per walk (`research/database_builds.md`). What is left
is the database's own work, which a second machine cannot add cores to, and volume, which batching does not reduce. A
second machine adds speed to a database-bound step only with its own database holding the same build. Scoring is
CPU-bound and runs well from either.

## Decided at the gate

Parked on 2026-10-28 (Al: `park`). Plan review (`planning/active/review-plan.md`, same day): no blockers; findings
1–6, 8 and 9 folded into the phases below, marked "review N". The approval covered the baseline only; the run-to-PR mandate starts at the resume
instruction. Mechanism decisions (agent, 2026-10-28; the issue fixes the behaviour):

- Two exported functions in `R/db_latency.R`: `knw_db_latency(conn, n = 20)` (median round trip of `n` `SELECT 1`
  queries, ms) and `knw_db_latency_check(conn, remote = FALSE, limit_ms = 20, n = 20)`, which measures, and over the
  limit stops with the round trip and the expected cost unless `remote`; it returns `list(ms, limit_ms, remote, over,
  line)` for the log. The issue's cost table is an internal constant the message and the roxygen share, labelled with
  the date and the logs it came from (no host names).
- Stage timing: an internal `.knw_timer()` returning a `tick(label)` closure; `knw_compare_rules()` records one
  elapsed minute per stage and writes one `say()` line per stage, and returns `timing` (named numeric) beside `log`.
  `run_one()` in `0330` adds the writes' line. `gpkg_one()` already carries its own.
- `REMOTE` is read as `Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")`, as `DEV` is.
- `inst/method/settings.csv` gets no row: the 20 ms limit shapes whether a run proceeds, not a result.

What exploration found that shapes the breakdown:

- All three scripts already connect through a local `pg()` and call `knw_build_record(conn, schema, run_uid)` at first
  connect, before any work (`0310`:99-100, `0320`:134-137 inside `if (!dev)`, `0330`:152-158). The check slots in
  right there, one site per script. `0330`'s site is before the `STAGE` branches, so one call covers `""`, `maps` and
  `gpkg`. `0320`'s site is already skipped by `DEV=1`; `GRADIENT=fwa_gradient` sets `main_only` but still connects for
  the build record, so the check gates on `!main_only`, not `!dev`.
- `knw_build_record()` (`R/build_record.R`) is the pattern for a `conn`-taking helper, and
  `tests/testthat/test-build_record.R` the pattern for its test: `local_mocked_bindings(dbGetQuery = ..., .package =
  "DBI")` with `conn = NULL`, plus a live test behind `skip_if_no_pg()` (`helper-pg.R`).
- `0320` and `0330` log through `say()`/`fail()` into `log_lines` written to `path_log`; `0310` through the ledger
  (`add("info", step, n, note)`), so each script records the measurement in its own form.
- The stages of one key live in `knw_compare_rules()` (`R/compare_rules.R`): scratch setup (`uhc`, `grades` written,
  :195-206), classify/overlay/connect (already timed, :211-252), the segment read (one `dbGetQuery`, :263-282), the
  summaries in R (`compare`, `change`, the FDIS-visit checks, :290-415), the outside check (two queries, :416-489),
  the scratch drop. `0330`'s `run_one()` then writes four files per key (:195-228) and `gpkg_one()` is already timed
  per key. The catalog reads are `STAGE=maps` only, outside the per-key loop. `cmp$log` lines are appended under the
  key's line in the log (`0330`:328), which is where the stage lines land.

## Phase 1: the check, as package code with tests

- [x] `R/db_latency.R`: `knw_db_latency()` and `knw_db_latency_check()` with roxygen (`\dontrun` example, as
      `knw_build_record()`), exported; the cost table constant with its provenance line. `knw_db_latency()` times
      `DBI::dbGetQuery(conn, "SELECT 1")` with no `immediate = TRUE`, the path the 1.6 / 104 ms figures were measured
      on, no warm-up, and its roxygen says so (review 5); `knw_db_latency_check()` calls `knw_db_latency()`
      unqualified so the test's mock takes (review 4).
- [x] `tests/testthat/test-db_latency.R`: `dbGetQuery` mocked to sleep 30 ms with `n = 3` → `knw_db_latency()` > 20; mocked
      `knw_db_latency` at 105 → `knw_db_latency_check()` stops naming `105 ms`, the limit and the estimate;
      `remote = TRUE` returns `over = TRUE` and a `line` naming the override; a fast mock passes with `over = FALSE`;
      a live test behind `skip_if_no_pg()` reporting the round trip.
- [x] `_pkgdown.yml`: both functions after `knw_build_record` under "Evidence on link's segments", with a clause in
      that section's `desc` (review 9); `devtools::document()` then `pkgdown::check_pkgdown()`.

## Phase 2: wire the three scripts

- [x] `0310`: `remote <- Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")` beside `schema`; after `conn <- pg()`
      (:99), `knw_db_latency_check(conn, remote = remote)`; ledger rows `db_round_trip_ms` (n = ms, note = the line)
      and `db_remote_override` (n = 0/1). 0310 has no `fail()` and writes its ledger only at :316, so the check's
      stop writes the ledger first (review 1), as 0320's `fail()` does. Header `RUN:` names `REMOTE=TRUE`.
- [x] `0320`: `remote <- ...` beside `dev` (:85); inside the first connect (:134), gated `if (!main_only)` rather than `if (!dev)` for the check only
      (the build record stays as is); a failure goes through `fail()` so the log is written first; `say()` the line.
      Header names `REMOTE=TRUE` and that `DEV=1` and `GRADIENT=` skip it.
- [x] `0330`: `remote <- ...` beside `gpkg` (:72); after `conn <- pg()` (:152), before the build record; a failure writes the log as the build-record
      failure does; `say()` the line. Header names `REMOTE=TRUE`; `STAGE=gpkg` and `STAGE=maps` covered by the same site.
- [x] `scripts/README.md`: the `0310`, `0320`, `0330` entries name the check and the override in a clause each.

## Phase 3: a timing line per stage in 0330

- [x] `R/compare_rules.R`: `.knw_timer()` started at :195 (after the local file and parameter reads, which cost no
      database time); ticks after scratch setup, classify/overlay/connect, the segment read, the summaries (from the
      flag join at :283), the outside check; one `say("<stage>: %.1f min")` per stage, except that the existing
      classify line (:249-252, which carries the walk seconds) is that stage's line and the tick replaces its `t0`,
      so no stage carries two timings (review 3, 8); `timing` returned.
- [x] `0330` `run_one()`: time the four writes and append their line; the key's `log` carries the stage lines as
      now (nothing else in the log moves, so `STAGE=maps`/`gpkg` readers are unaffected).
- [x] `tests/testthat/test-compare_rules.R`: `.knw_timer()` ticks are non-negative, named in order, and sum to
      the total within a tolerance (two `Sys.time()` reads; review 6); the worker-function test (:79, "calls no name of this package") still passes, since the timer
      lives in `knw_compare_rules()`, not `.knw_compare_bin()`.

## Phase 4: documentation

- [x] `CLAUDE.md` "Run the comparison on the database's own host" paragraph: names `knw_db_latency_check()`, the
      20 ms limit, `REMOTE=TRUE`, and that every run logs the round trip.
- [x] `research/database_builds.md` "The answer": one sentence that the check now enforces it (Verified date bumped).
- [ ] NEWS entry lands at merge (`/gh-pr-merge`), not on the branch.

## Owed at the end (reported, done after merge)

- [ ] The acceptance line "on the host the check passes and logs its round trip" needs a run on the host; if no host
      session is reachable from here, report the command for Al to run:
      `cd <repo> && Rscript -e 'pkgload::load_all(quiet=TRUE); knw_db_latency_check(DBI::dbConnect(RPostgres::Postgres()))$line'`.
- [ ] A stage that proves chatty from the next remote `0330` log is a follow-up issue (the issue says so).
- [ ] Pre-existing, not in scope (review 7): a key whose comparison fails mid-way loses its stage lines, because
      `0330`:228 returns `log = character()` on error and `knw_compare_rules()` keeps `log` in its own frame. A
      follow-up could carry the partial log on the condition; file it if the next run needs it.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (each commit, or once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification, per change:

- `Rscript -e 'devtools::test()' 2>&1 | grep -E "(FAIL|ERROR|PASS)" | tail -5`; `lintr::lint_package()`;
  `devtools::document()`; `pkgdown::check_pkgdown()`.
- Mutation: with the limit mocked at 105 ms and `remote = FALSE`, the check must stop (restore-the-bug: set
  `limit_ms = Inf` in the test and watch the expectation go red once, then revert).
- Live, from this machine (on the remote link per `CLAUDE.md`'s numbers): `knw_db_latency(conn)` reports ~100 ms and
  `knw_db_latency_check(conn)` stops; with `remote = TRUE` it returns the line. That is the "from the remote link it
  stops" acceptance. No full `0330` run: the stage lines are proved by a `SPECIES=WCT` `0330` only if Al wants one
  (WCT_rear is 4.5–7 min); otherwise by the unit test on the timer and a read of the code path.
- `/code-check branch` before the PR.
