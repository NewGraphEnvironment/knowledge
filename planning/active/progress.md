# Progress — Backlog move 7 (#176)

## Session 2026-11-20

- Plan-mode exploration — phases approved by user (batch 11 only; batch 12 and #245 split off; #2 and #1 deferred to the batch 12 issue)
- Created branch `176-backlog-move-7-fiss-workbooks-a-tested-p` off origin/main
- Claimed #176 (in-flight)
- Scaffolded PWF baseline from issue #176 with approved phases
- Next: start Phase 0
- Phase 0: filed #248 (batch 12: #17, #2, #1, gate questions open); #245's body says it was split from #176 and follows this merge; #17, #2 and #1 name #248 in their bodies; #176 retitled and rewritten to carry batch 11; `planning/backlog.md` drops batches 12 and 27 with a hand-edit Verified line
- Plan review spawned 2026-11-20T22:03:20Z (background)
- Phase 1: five layouts measured (findings); template terms read (all rights reserved: fixtures copy labels and banners only, noted on #76); gradient cells are `0.0%`-formatted in both editions; FDIS build is the published one; baseline `0220` on all five groups reproduces every tracked CSV and every GeoPackage's content, so the baseline is the refactor's reference (`scripts/logs/fiss/` gets the refactor's run logs)
- Plan review returned (no blockers, 14 findings): written to `review-plan.md`, corrections folded into the plan (5f360a34)
- Phase 2: `knw_fiss_*` in `R/fiss_parse.R` and `R/fiss_nfc.R`, six fixtures, 82 assertions over two test files (51b9e7c5); refactored `0220` byte-identical to the baseline on all five groups; eight restored bugs each turn the tests red; `scripts/README.md` updated
