# Progress — Backlog move 5: Chinook flow windows and timing (#174)

## Session 2026-11-17

- Plan-mode exploration — phases approved by user (gate answers: NuSEDS to bucket Parquet read through crate; #105 stop rule 5 % visits and 5 % CH; #42 table ignored Parquet)
- Created branch `174-backlog-move-5-chinook-flow-windows-and` off origin/main (e9455d02); claimed #174 (in-flight)
- Scaffolded PWF baseline from issue #174 with approved phases
- Next: start Phase 1
- #31: page 24 of the Wet'suwet'en title document gives only "early to mid-August"; Gottesfeld and Rabnett 2007 (printed p. 328) give Skeena entry and Moricetown arrival but no end of the Bulkley run. Note rewritten: no end, consumers needing a window drop the row.
- Plan review (Plan agent) folded: `planning/active/review-plan.md`. Main changes: crate step matches crate#74 (one variant, the PR carries crate#41's read-as-character fix; the file is Latin-1, so variants declare an encoding); stop rule made exact before its commit; #105 guards (population 7,823/235/111/45, MAD baseline through `knw_rule_in()`, flow load equal to the grade record's); #42 narrowed to the daily-basis mean (7-day minimum goes with dry years); `PUBLISH=TRUE` gate on the NuSEDS upload; Phase 2 runs while the crate PR waits.
- The review found the baseline named a project repository; the two local commits were rebuilt before any push so no revision carries it.
- crate: issue NewGraphEnvironment/crate#74 filed; branch `nuseds-schema` in a crate worktree has the registration, the #41 read fix, the encoding support, fixture and tests (2820 passing; both new guards fail on a restored defect).
