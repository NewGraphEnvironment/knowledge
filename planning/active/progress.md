# Progress — Revise the receipt declarations from #158's verdicts, and test knowledge's grade receipt on a second database's regrade (#165)

## Session 2026-11-11

- Plan-mode exploration — phases approved by user
- Created branch `165-revise-the-receipt-declarations-from-158` off origin/main
- Scaffolded PWF baseline from issue #165 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) folded in: `review-plan.md`; freeze on the second's worktree until both receipts were written
- Phase 1: both databases hold the published build; crate raised to 0.16.0 on the host; worktree `knowledge-165` there
- Phase 2: `0310` on each database (06:27-06:46 UTC): one `recipe_id`, `equivalent` (access_check 5.3e-11 km); column
  order of the species groups differs by database, filed #197
- Phase 3: `0320 SPECIES=CH` on each (06:47-07:04 UTC): grade receipts `identical`, tables equal but `evidence_md5`;
  order bound computed over the published tables
- Phase 5 probe: crate 0.16.0 fingerprints an IDate as its Date (findings)
- Phase 4: declarations revised (habitat_grade's totals 1e-3 -> 1e-2; the rest unchanged, now on measurement); research, CLAUDE.md and the pin test updated
- Full suite: 2290 passed, 0 failed, 3 skipped; the three new data-raw scripts wrapped to 120 columns, outputs unchanged on rerun
- Code-check rounds 1-2: fdis provisional for its six unmeasured tables; scopes and the rebuild list corrected; thresholds and habitat_grade say a cross-database rebuild reads different on its recipe until #197 (its body extended)
- Code-check round 3 (enumeration of 63 claims): published sets' recipes name the tuning run, so #197 never reaches them (round 2's fix corrected, #197 body too); #145 not #154; fdis_sites is 0240's; grade sizes 0.3-2.5 GB everywhere (about 11 GB a run); timings from the logs
