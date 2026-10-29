## Outcome

`knw_db_latency()` measures a connection's round trip as the median of 20 `SELECT 1` queries, and
`knw_db_latency_check()` stops a run over 20 ms with the round trip and what a remote link cost #92's comparison,
unless `remote = TRUE`. `0310`, a grading `0320` and every `STAGE` of `0330` call it at connect with
`REMOTE=TRUE` as the override, and log the round trip and whether the override acted. A refused run writes its log or
ledger to a file of its own (`<date>_evidence_build_refused.csv`, `<date>_tune_refused.txt`,
`<date>_compare_refused.txt`), because 0320, 0325 and 0330 read the newest `*_evidence_build_ledger.csv` and 0325
lists every `_tune_run*.txt`: the plan's review had asked for 0310 to write its normal ledger on a refusal, which would
have made a refused run's partial ledger the one every downstream run reads. `knw_compare_rules()` now logs and
returns each key's minutes by stage, and `0330` adds the grade read and the writes, so a key's stage lines account for
its "compared in" minutes. `/code-check branch` ran four rounds and ended on an enumeration
(`review-enumeration.md`): round 1 found the refused-log overwrite, round 3 that the latency test could not tell a
median from a sum, and round 4 that round 3's fix still could not tell it from a min. `Sys.sleep()` overshoots by
100 ms or more on this machine, so the test now runs on a fake clock behind an internal `.knw_now()`. NEWS lands at
merge.

## Measurement

The live round trip from the machine this branch was built on: 1.4 ms (median of 5), on a localhost connection, so
the check passes there. The plan expected about 100 ms from a remote link, so the live "from the remote link it stops"
check was not run; the mocked tests are its evidence. The cost table in `R/db_latency.R` was checked against its logs
by round 1 (host 115.2 / 47.8 / 14.0 min, remote link 164.3 / 104.8 / 196.9 min).

## Evidence

`scripts/logs/habitat/2026102[67]_compare*` (the cost table's source).

## Owed


- The acceptance line "on the host the check passes and logs its round trip" needs a run on the host; if no host
      session is reachable from here, report the command for Al to run:
      `cd <repo> && Rscript -e 'pkgload::load_all(quiet=TRUE); knw_db_latency_check(DBI::dbConnect(RPostgres::Postgres()))$line'`.
- A stage that proves chatty from the next remote `0330` log is a follow-up issue (the issue says so).
- Pre-existing, not in scope (review 7): a key whose comparison fails mid-way loses its stage lines, because
      `0330`:228 returns `log = character()` on error and `knw_compare_rules()` keeps `log` in its own frame. A
      follow-up could carry the partial log on the condition; file it if the next run needs it.

Closed by: PR (opened from this branch)
