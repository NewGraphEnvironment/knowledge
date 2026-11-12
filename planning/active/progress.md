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
