# Plan review — #110 (Plan agent, 2026-10-28, before the parked baseline commit)

No blockers. Verified by the session before folding: 0310 has no `fail()` (finding 1); `_pkgdown.yml` has no "Build"
title, `knw_build_record` sits under "Evidence on link's segments" (finding 9).

## Confirmed

- 0330's `conn <- pg()` (:152) is unconditional; `STAGE` branches start at :270, so one site covers every stage. The
  other connections (gpkg_one :242, STAGE=maps :399, each compare bin's `connector()`) take the same path.
- 0320: `main_only` defined at :93; first connect at :134 inside `if (!dev)`, so `GRADIENT=fwa_gradient` connects and
  `if (!main_only)` skips the check; main_only quits at :310-314 before the grade connect.
- 0310: one site at :99; the later connect (:233) and the socket-worker walks (:217) share the path.
- Same-package mock works when `knw_db_latency_check()` calls `knw_db_latency()` unqualified (R/build_record.R:38 and
  test-build_record.R:8 are the proven pair); `.package = "DBI"` reaches a `DBI::dbGetQuery()` call.
- test-compare_rules.R:83 inspects `all.names(body(.knw_compare_bin))` only; a timer inside `knw_compare_rules()`
  cannot trip it.
- Consumers of the return value (0330:207-231, 0322:297-304, data-raw/compare_parallel_check.R:112-122) take named
  elements; no test pins `names(cmp)`. "compared in" and "Classify, overlay" are parsed nowhere under data-raw/ or
  scripts/ (0298's are its own).
- Acceptance: all four issue lines covered (CLAUDE.md paragraph is :412-423; README entries :50, :62, :83).

## Findings (folded into task_plan.md where marked)

1. Gap, 0310: the ledger is written only at :316, so a check that stops leaves no ledger; "every run logs the
   measurement" holds for 0310 only on success. → folded: write the ledger before stopping.
2. Gap: no script defines `remote`. → folded: a `remote <- ...` line per script in Phase 2.
3. Acceptance/mechanism: the classify stage already has a timed line (:249-252, with walk seconds). → folded: the
   tick replaces `t0` and the existing line is the stage's line; no second line.
4. Assumption: unqualified `knw_db_latency()` call; `DBI::` prefix on `dbGetQuery`. → folded into Phase 1.
5. Assumption on what is timed: `DBI::dbGetQuery(conn, "SELECT 1")` without `immediate = TRUE`, the path the 1.6 /
   104 ms figures were measured on (#73 findings:446, #87 review-round4:18-21); no warm-up; roxygen says so. → folded.
6. Test design: ticks sum to the total within a tolerance; the slow mock uses a small `n`. → folded.
7. Scope, pre-existing: a key that fails mid-way loses its stage lines (0330:228 returns `log = character()`). Not in
   scope; a follow-up could carry a partial log on the condition. Noted under Owed.
8. Stage boundaries confirmed; the timer starts at :195 (after the local file reads) and the summaries stage begins
   at :283 (the flag join is R work). → folded.
9. pkgdown: add the names after `knw_build_record` (:44) and a clause to that section's `desc`. → folded.
10. Ordering fine; `document()` before `check_pkgdown()`.
11. Acceptance coverage complete.
