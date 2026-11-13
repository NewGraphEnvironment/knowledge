# Progress — Backlog move 4: Comparison maps out of the run, and one generated research page per key (#173)

## Session 2026-11-12

- Plan-mode exploration — phases approved by user (three gate questions answered: remove the 97 compare PNGs, split
  the other 6 fitted keys into a new issue, #90's move of the old chinook page)
- Created branch `173-backlog-move-4-comparison-maps-out-of-th` off origin/main; claimed move #173 (`in-flight`)
- Scaffolded PWF baseline from issue #173 with approved phases
- Next: start Phase 0

## Session 2026-11-13

- Phase 0: gq 0.16.1 → 0.21.0. gq cannot write a QML for a custom registry layer: filed gq#115; Al chose to build it
  in gq first
- Plan review (`review-plan.md`): three blockers (no QML source; neither on-demand stage reads the promoted run and the
  floodplain table is #65's; documented `GPKG=FALSE` calls), and batch 6 alone is a full PR. Both blockers checked
  and confirmed. Al cut the PR to batch 6; batch 7 goes to a split-off issue. `task_plan.md` rewritten to that scope
  with the review's gaps folded in
- Next: Phase 1, the GPKG helper
