# Progress — Backlog move 6 (#175)

## Session 2026-11-19

- Plan-mode exploration — phases approved by user (gate: per-pass tables join v3; #23 cut and split; re-archive the published evidence with fish.rds)
- Created branch `175-backlog-move-6-where-records-sit-the-sit` off origin/main; claimed #175 in-flight
- Scaffolded PWF baseline from issue #175 with approved phases
- Next: start Phase 1
- Phase 1: `knw_fdis_passes()` (R/fdis_passes.R, 30 test expectations), modelled on the private consumer's pass reader (pass status fish / nfc / no_record; raw codes kept; the visit rule per pass). `0230` writes passes.rds and pass_catch.rds after the repeat drop and stops if the passes' count, time or area disagree with the visit table; `0240` writes them as CSV; v3 gains the two tables (0299, fdis.yaml, test-receipt 13); data/fdis_README.md describes v3. Real-build check runs with Phase 2's rerun.
