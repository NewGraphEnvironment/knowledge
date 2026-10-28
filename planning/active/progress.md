# Progress — Cache link's default flags in the comparison (#101)

## Session 2026-10-28

- Plan-mode exploration — phases approved by Al; at the gate Al narrowed the work to the measurement (no cache until
  link's reworked stream layers are out), then "go all phases to pr"
- Created branch `101-cache-link-s-default-flags-in-the-compar` off main
- Scaffolded PWF baseline from issue #101 with approved phases
- Next: start Phase 1
- Phase 1: `.knw_compare_bin()` times the scratch copy, the near-river walk and the default check (shared) and each
  rule's classify, overlay, connect and read; `.knw_stage_minutes()` sums the bins; `knw_compare_rules()` logs a line
  per rule and which rules' predicates read the near-river table, and returns `stage_minutes`. The share is of every
  timed worker-minute, shared steps included, not of the three stages alone (the shared steps are part of what a cache
  hit could or could not spare). test-compare_rules.R 42 pass
- Plan review (Plan agent, 21:50-21:53 UTC) in `review-plan.md`; every finding probed: the identity blocker confirmed
  (local curves are the 2026-10-25 picks, fresh 0.44.0 here), GR's duplicate stale under #92, the projection moved to
  per-bin minutes (`.knw_bin_minutes()`, `bin_minutes`), the worker's names prefixed `bin_`
- Phase 2: `data-raw/compare_stage_time.R` written. A link pretest from another session (`pretest_run.sh` on
  `fresh_default`, started ~21:34 UTC) holds the database, so the measurement waits for it to exit
