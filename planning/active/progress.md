# Progress — Backlog move 6 (#175)

## Session 2026-11-19

- Plan-mode exploration — phases approved by user (gate: per-pass tables join v3; #23 cut and split; re-archive the published evidence with fish.rds)
- Created branch `175-backlog-move-6-where-records-sit-the-sit` off origin/main; claimed #175 in-flight
- Scaffolded PWF baseline from issue #175 with approved phases
- Next: start Phase 1
- Phase 1: `knw_fdis_passes()` (R/fdis_passes.R, 30 test expectations), modelled on the private consumer's pass reader (pass status fish / nfc / no_record; raw codes kept; the visit rule per pass). `0230` writes passes.rds and pass_catch.rds after the repeat drop and stops if the passes' count, time or area disagree with the visit table; `0240` writes them as CSV; v3 gains the two tables (0299, fdis.yaml, test-receipt 13); data/fdis_README.md describes v3. Real-build check runs with Phase 2's rerun.
- Phase 2 code: fish.rds in `.knw_archive_evidence_files`, held to the ledger's `md5_fish` (0fc41e38). 0230/0240 rerun on m1: fish and catch identical, sites.rds not (findings). Plan review landed (review-175.md, 17 findings, folded; item 17 put to Al: span stays in the checks). Split issue #245 filed; #23 rewritten to the cut scope.
- Phase 2 done: the seven published grade tables (`PULL=TRUE GRADES=TRUE` into a scratch worktree) recompress to their archived object md5s (CH_rear against its published row, 1b9a486d), so the put re-sent none. Archived the published evidence with fish.rds: evidence `7fa6ad14813d34fbb85c13a49c096b8e`, batch `20261120T040634Z-6cd2c6ba`, 36 index rows (28 tune rows on the published versions, 8 evidence objects, 210 MB) (ecd68e5a). A pull into a second empty worktree restored fish.rds at 8cf27351, and every key resolved to the one build.
