# Progress — Rebuild the evidence and retune on the republished flows, with the walk ending at the river's bank (#73)

## Session 2026-10-22

- Plan-mode exploration — phases approved by user (folds in #68 and #80; #81's run-time pieces; #72's record)
- Created branch `73-rebuild-the-evidence-and-retune-on-the-r` off main
- Scaffolded PWF baseline from issue #73 with approved phases
- Plan review (Plan agent, background) folded in: `review-plan.md`; two defects in Phase 1's first draft fixed from it
- Phase 1 done: the walk ends at the bank and counts hop gaps; checked against fresh 0.42.0 on BULK (`bank` 0 of 2,460)
- Phases 2–5 committed: ladder and flow-start picks, grade provenance, the comparison under three structures against
  link 0.67.0's default, the evidence rebuilt (0310, species tables, local v3 Parquet)
- 0320 SPECIES=CH,CO (8 workers, 67.6 min), then the curve defect: a held-out group's intercept refit ran away
  (`84c3c78`), its helper exported to the workers (`44d0822`), and the rescoring (6 workers, 91.2 min) moved 2,269 CH
  rules and the CH pick (`ca771ca`)
- 0330 SPECIES=CH,CO stopped once the CH pick moved (CO written); 0330 now composes per-species runs; CH rerun alone
- Phase 6 write-up: `coho_rearing_tuned.md` rewritten prior-first; `chinook_rearing_tuned.md`'s head rewritten with
  #54's record kept below; CH and CO rows of `habitat_thresholds_tuned.md`; `research/README.md`
- Next: CH's comparison section when 0330 lands; BT (0320 running beside it), then GR, RB, ST, WCT
