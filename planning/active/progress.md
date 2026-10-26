# Progress — CI: unpin the runners and add timeouts after duckdb 2.0.0's binary gap (#94)

## Session 2026-10-26

- Plan-mode exploration — phases approved by user (timeouts 30 / 15 chosen at the gate)
- Created branch `94-ci-unpin-the-runners-and-add-timeouts-af` off main
- Scaffolded PWF baseline from issue #94 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) folded in: b7e393b; `planning/active/review-plan.md`
- Phase 1: both workflows on `ubuntu-latest` with job `timeout-minutes` 30 / 15. `/code-check`, three rounds
  (`review-round{1,2,3}.md`): round 1 Clean; round 2 two verification gaps (label mid-migration, citation job not run
  by the PR); round 3 a timeout kill reports `cancelled` (verified on drift and fly). No code change from any round;
  the plan and findings carry each. Ended at round 3: it named the mechanism (a guard that fails toward pass) and
  enumerated where it reaches in the two files (the two `timeout-minutes` lines), and no round found a defect inside
  a fix.
- Pushed, opened PR #97; dispatched the citation workflow on the branch (run 40406671489); PR pkgdown run 40406663722.
- soul#541's body gained the "a timeout reads as `cancelled`" bullet (`--log-failed` empty on both drift and fly runs).
- Cancelled main's stuck runs 40400891471 and 40404388481 on Al's word (22:05Z).
- Citation dispatch 40406671489: green on `ubuntu-26.04`, pushed nothing (branch still 6092dc9).
- PR pkgdown 40406663722: killed by the 30-min timeout on 26.04; the logs show every package built from CRAN source
  on both images (findings). Escalated to Al: the plan's premise is disproven.
