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
