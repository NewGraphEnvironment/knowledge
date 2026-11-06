# Progress — knw_link_flow() picks a parent flow by distance alone (#161)

## Session 2026-11-06

- Plan-mode exploration — phases approved by user (tie rule: lower linear_feature_id; dam snap included)
- Created branch `161-knw-link-flow-picks-a-parent-flow-by-dis` off origin/main
- Scaffolded PWF baseline from issue #161 with approved phases
- Next: start Phase 1
- Phase 1: SQL moved to `.knw_link_flow_sql()`; `tests/testthat/test-link_flow.R` (fixture, live flow, live dam snap) fails on the old ORDER BY, each as expected (findings)
- Phase 2: ORDER BY gains the id in both lookups, roxygen says so; the three tests pass on m1
- Phase 3: two-database check; new code identical on both (0 rows, md5 equal), old differs on 614 tied lines and 2 dams; no slowdown (findings)
- Phase 4: research/database_builds.md and CLAUDE.md say #161 is fixed from 0.4.32; #161 body ticked with the decision; NEWS left to the release commit
- Code-check round 2: one finding (prose said the fix reaches grades only with a new build; grading reads the parent flow live). Fixed in research and CLAUDE.md
- Code-check branch: round 1 clean; round 2 one finding (fixed, 6a60545); round 3 clean with the mechanism's consumers enumerated (live: knw_link_segments via grading; stored: every 0310 output). Loop ended on a clean round 3 with no inside-a-fix finding. Round 3's loose "records nothing" tightened to "does not compare the knowledge commit"
- The final script, run once on the second database with the new code: 2,831 parent lines, 1,800 tied (1,799 exactly), flow md5 edb4e53c… and dams md5 25bf5a6a…, equal to the committed runs
- Full suite before review: 0 failed, 4 skipped, 383 tests
