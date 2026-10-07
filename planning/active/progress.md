# Progress — Evidence vocabulary has no groundwater / upwelling variable (#36)

## Session 2026-10-07

- Plan-mode exploration — phases approved by user
- Created branch `36-evidence-vocabulary-has-no-groundwater` off main
- Scaffolded PWF baseline from issue #36 with approved phases
- Next: start Phase 1

## Session 2026-10-07 (cont.)

- Phase 1: `groundwater` in the vocabulary, qualitative only (`fits$groundwater = character(0)`); test; roxygen; NEWS + 0.3.1. Mutation (`groundwater = "m/s"`) turns both unit assertions red. `devtools::check()` 0/0/0.
- Plan review (Plan agent) → `review-plan.md`. Applied: the mutation wording (B1), "upwelling measure" not "flux" (G1), independence notes (G2), the two Metolius statements (G5), appending rows (O1), data-row numbering (A1). Not applied: G4 (a parameter guard on groundwater rows); none carries one, and the acceptance check covers it.
- Code-check rounds 1 and 2: Clean (`review-round1.md`, `review-round2.md`). The second agent covered round 3's scope too (docs and the roxygen claim for every kind).
- Phase 2: 12 groundwater rows appended (data rows 675-686). Meaning audit by an independent agent: 4 errors, 3 candidates, 3 firm-ups. Round 2 on the fixes found 2 errors inside them. The loop ended by enumerating every cross-reference claim (`findings.md`). Gate: 686 rows, 1-674 unchanged; log `scripts/logs/habitat/20261007_literature_verify*.csv`.
- Agents for this task: 5 (plan review, code-check x2, meaning audit x2). The second meaning audit found the two errors inside fixes.
