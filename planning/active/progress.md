# Progress — The grade reads segments that pass the size test at the 50 km distance cap (#65)

## Session 2026-10-19

- Plan-mode exploration — phases approved by user (the issue body's parked plan, verified at `78a427d`; three checks added: rule verdicts unchanged, the vignette's tuning-log path, the vignette's "Lost" example)
- Created branch `65-the-grade-reads-segments-that-pass-the-s` off main
- Scaffolded PWF baseline from issue #65 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) and code-check rounds 1-3 on Phase 1: the plan review and round 1 found the same
  blocker independently (the walk set dropped missing sizes the exception reads); round 1 also hardened 0322's
  reuse gate; rounds 2 and 3 clean, round 3 enumerating every consumer of `dist_m` on each axis. No defect was
  found inside a fix. Reviews: `review-plan.md`, `review-round{1,2,3}.md`.
- Phase 1 done: `knw_grade_species()` walks every accessible segment with a gradient to the pick's `exc_q`
  (else `curve$q`), with `dist_status` and walk counts; 0320 regrades tables without `dist_status`; tests pass,
  and red against both the old size filter (8 failures) and round 1's defect (3).
- First CH regrade (`scripts/logs/habitat/20261019_tune_run-ch.txt`, committed): 856,244 walks in 11.1 min;
  the reference rose 0.146 → 0.516 because river and lake segments set it. Asked Al with the measurement; he
  chose the stream branch. The run for the other seven keys was stopped two minutes in (nothing written).
- Reference change committed (`9f35e8e`) after three review rounds (round 2 found a defect inside round 1's
  fix, so round 3 enumerated 48 places; `review-ref-round*.md`). Follow-up: knowledge#72 (grade provenance).
- Full regrade started 2026-10-19 ~21:24 UTC from a frozen copy of 0320 (`20261019_tune_run.txt`), all keys,
  CH included. Next: when it exits, check `git status`/`git diff data/tune`, then 0325, the full 0330 (about
  5 h on #57's run), the invariant check (scratch `check_rules_unchanged.R`: every non-grade compare column
  equal to origin/main's), `data-raw/vignette_chinook.R`, `devtools::test()`, then Phase 3's numbers.
