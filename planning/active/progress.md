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
