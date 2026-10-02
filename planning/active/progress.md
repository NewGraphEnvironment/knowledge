# Progress — Habitat weights, not only cutoffs: what BT use by gradient, elevation, size and effort should mean (#28)

## Session 2026-10-02

- Plan-mode exploration — phases approved by user
- Created branch `28-habitat-weights-bt-use` off main
- Scaffolded PWF baseline from issue #28 with approved phases
- Next: start Phase 1

- Phase 1: `scripts/0290-bt-use-build.R` built. 15,883 visits kept of 53,018 (2,250 with BT; 3,988 held out); the ledger partitions the input. Three random visits' segment gradients were checked by hand against their schema.
- Installed link is 0.50.0, without `lnk_species_pooling()`. The run used link 0.55.0 from the local checkout (`4df1ffc`, one commit past the v0.55.0 tag), installed into a session scratch library (`R_LIBS`). The user library is untouched.
- Plan review (`review-plan.md`) and code-check rounds 1–2 (`review-p1-round*.md`) folded into 0290. Round 2 found a defect inside round 1's placement fix, so the loop was ended by enumerating placement and presence/absence over every kept visit (findings.md).
- Phase 3: five literature rows added; the 0280 gate passes on all 486 rows. `elevation` was not added to the vocabulary.
- First two 0291 runs were stopped unread: one on the pre-review design, one on the visit table round 2 corrected.
