# Progress — Iterate on scores privately; promote a run (#111)

## Session 2026-10-28

- Plan-mode exploration — phases approved by Al (then "go all phases to pr")
- Created branch `111-iterate-on-scores-privately-promote-a-ru` off main
- Scaffolded PWF baseline from issue #111 with approved phases
- Next: start Phase 1
- Phase 1: `knw_tune_pick_report()`; DEV=1 0320 writes `data/tune/dev/pick_report.csv` and its log in `data/tune/dev/`
- `DEV=1 0320` here on #92's evidence (2026-10-28 18:07-18:15 UTC): 22 keys scored in 7.7 min on 14 workers, no
  database; 8 of 8 keep the published pick; `git status` before and after differ only by this branch's source edits.
  CH rearing was read from the 2026-10-27 dev score cache; the other seven keys were scored fresh.
- Phase 2: full 0320 writes `data/tune/candidate/<run>/`; 0330 needs `TUNE_DIR=` and writes
  `data/compare/candidate/<run>/`; test that `knw_thresholds_table()` never reads a candidate (red when made recursive)
- Phase 3: `knw_tune_promote()`, `scripts/0335-promote.R`; fixture tests per refusal, archive and undo, mutation checks
- Plan review (Plan agent, spawned 18:06 UTC) folded in: see task_plan.md
- Promotion moves a key's files rather than copying them (the tracked tune and compare trees are ~48 GB with the
  GeoPackages); logs are copied
- Round trip on the real run (2026-10-28 18:24-18:35 UTC): a candidate of APFS clones of every tracked and ignored
  file of data/tune, data/tune/grad_fwa, data/compare, data/compare/gpkg, research/fig/compare_*.png and the 20261027
  logs; `RUN=roundtrip BUNDLES=FALSE 0335` (359 files, 1 s) left all 542 files byte-identical (md5), then
  `SPECIES=CH` from the archive it made (48 files) the same; `0325` (local, 7.3 min) wrote `data/thresholds.csv` and
  `data/thresholds_groups.csv` unchanged. Candidate, archives and promotion logs removed after.
- Phase 4: CLAUDE.md (bundles rerun by a promotion; candidates; the pick report; promotion on Al's word) and the run order
- `/code-check branch`, five rounds (18:38-19:40 UTC; one plan review and five reviewers in all, past the usual five):
  7, 3, 4, 5 and 4 findings, all fixed (commits 60f8638, 87ddb28, 85daf7d, 69adead, 6b29116). Rounds 2 to 5 each found
  a defect inside the previous fix; the mechanism was presence, sort order or file age taken as provenance in a
  candidate a resumed run accumulates into. Ended by moving provenance to the writers (clear before rewrite, write
  whole) and enumerating every write into a run directory (findings.md, last section).
- Full suite after round 5: 1617 passed, 0 failed, 1 skip already there.
