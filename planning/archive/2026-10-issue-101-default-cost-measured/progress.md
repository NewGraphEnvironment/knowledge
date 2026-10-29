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
- 22:18 UTC the link pretest exited; found #112's branch and its measurement running on the host (findings, "Collision
  with #112's branch"). Measurement held; asked Al which work survives
- Al: "#112 first, #101 reads it". Branch pushed and parked until #112 merges; resume with Phase 4 of task_plan.md

### Resume

```bash
cd <repo root> && git fetch -q origin && git checkout 101-cache-link-s-default-flags-in-the-compar && git pull --ff-only && git merge origin/main
```

## Session 2026-10-29 (UTC)

- #112 merged as PR #116 at 00:13 UTC; the waiter saw it at 00:21.
- Merged origin/main (e81a4d5): took #112's `R/compare_rules.R`, re-added `.knw_bin_minutes()` on its `setup_s`,
  `walk_s` and `rule_s`, the near-river line and the bins line; retired `data-raw/compare_stage_time.R` and
  `.knw_stage_minutes()`. `test-compare_rules.R` passes; lint counts equal main's (13 and 4).
- Checked the near-river claim at link configs 102762da with fresh 0.44.0 (a scratch script building every species'
  predicates): only CH rearing's `default` reads the table, on both models; no tuned base or other-stage predicate of
  a rearing key does.
- From #112's logs (`-2` BT, `-3` CH, `-4` WCT; every-structure runs less the dropped structures): `default`'s share
  CH 74 % with the walk, BT 60 %, WCT 51 %; the `door` alone runs agree within 4 points. Projected onto #87's host
  minutes less #112's drop (89 of 115; round 1 of the review corrected 85, which gave CO and ST #92's two-rule drop):
  ~52-56 min saved, full `0330` ~2.5 h -> ~1.6 h, an estimate.
- Wrote `research/database_builds.md`'s new section; edited #101's body (measured, parked, design) and #112's Outcome.
- Next: full test suite, `/code-check branch`, archive, PR.
