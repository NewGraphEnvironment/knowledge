# Progress — Check the database's round trip before a database-bound run, and time 0330 by stage (#110)

## Session 2026-10-28

- Plan-mode exploration — phases approved by user (parked)
- Created branch `110-check-the-database-s-round-trip-before-a` off main
- Scaffolded PWF baseline from issue #110 with approved phases
- Next: parked 2026-10-28; resume with the command below, then "start Phase 1"

### Resume

```bash
cd /Users/airvine/Projects/repo/knowledge && git fetch -q origin && git checkout 110-check-the-database-s-round-trip-before-a && git pull --ff-only && git merge origin/main
```

## Session 2026-10-28 (resumed)

- Phase 1: `knw_db_latency()` and `knw_db_latency_check()` with tests; restore-the-bug (`limit_ms = Inf`) turns the
  stop expectation red. Live from this machine: 1.4 ms (median of 5), on a localhost connection, so the plan's
  "from the remote link it stops" live check cannot be run here; the mocked test is its evidence.
- Phase 2: the check wired into 0310, 0320 (grading runs only) and 0330 (every STAGE); a refused 0310 writes
  `<date>_evidence_build_refused.csv` (findings, "Review finding 1 corrected").
- Phase 3: `.knw_timer()`; `knw_compare_rules()` logs scratch setup, classify/overlay/connect (its existing line),
  segment read, summaries, outside check and scratch drop, and returns `timing`; 0330's `run_one()` adds the grade
  table read (first) and the writes (last), so a key's stage lines account for its "compared in" minutes. A mutated
  timer (no advance of `last`) turns the sum-to-total expectation red.
