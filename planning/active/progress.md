# Progress — Backlog move 1: evidence builds and tests (#170)

## Session 2026-11-09

- Plan-mode exploration — phases approved by user
- Created branch `170-backlog-move-1-evidence-builds-and-tests` off origin/main
- Scaffolded PWF baseline from issue #170 with approved phases
- Next: start Phase 1
- #142: `test-link_place.R` skips when the BULK query returns no row. On `PGSERVICE=fresh_local` the live test passes (5
  expectations); a scratch copy querying group `ZZZZ` reports SKIP with the reason, and the same copy without the skip
  reports an error.
- #136 (log): `minimal_network_check.R` appends as each step reports. A scratch copy reading an `access_check.csv`
  without `watershed_group_code` exits 1 with steps 1, 2 and the refusal in its log; a full run on
  `derived_zz415_default`/`derived_zz415_minimal` writes a log byte-identical to the old script's (119 lines).
