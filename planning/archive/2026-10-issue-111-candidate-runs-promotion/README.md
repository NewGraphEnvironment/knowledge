# #111: iterate on scores privately; promote a run on the operator's word

## Outcome

Retuning no longer touches the tracked tables. `DEV=1 0320` is the loop after a change upstream: minutes, no database,
ending in a pick report (`knw_tune_pick_report()`, `data/tune/dev/pick_report.csv`). A full `0320` writes
`data/tune/candidate/<run>/` and `0330 TUNE_DIR=` writes `data/compare/candidate/<run>/`, both ignored. On Al's word,
`scripts/0335-promote.R` (`knw_tune_promote()`) moves a candidate in, whole or by key, archives what it replaces as a
candidate (`replaced_<stamp>`, promoting which undoes it), and reruns `0325` and the article bundles. Summaries now
record their candidate run and evidence ledger, which `0325`, `0330` and the methodology bundle read through
`knw_run_ledger()`, so a build checked and not promoted no longer breaks them. What was learned is in the review: five
rounds, four of them finding defects inside the previous fix, all one mechanism. Presence, sort order or file age had
been taken as provenance in a directory that resumed runs accumulate into. It ended when provenance moved to the
writers: a pass clears what it rewrites and writes large files whole, so the promotion can trust what a run holds.
`findings.md`'s last sections list every write into a run directory with how it lands. Not done: a full run (by the
gate decision), and `0335`'s chain into the bundle scripts, which needs a real promotion.

## Measurement

- `DEV=1 0320` on #92's evidence: 22 keys scored in 7.7 min on 14 workers, no database; 8 of 8 keep the published
  pick. CH rearing came from the 2026-10-27 dev score cache, the other seven were scored fresh. `git status` differed
  only by the branch's own edits. This set CLAUDE.md's claim that the loop takes minutes, against #92's ~10 h chain.
- Promotion round trip on the published run (APFS clones, no extra disk): whole run, 359 files moved in 1 s, all 542
  tracked and ignored files byte-identical after; CH alone from the archive, the same; `0325` (local) 7.3 min,
  thresholds tables unchanged. A copy-based promotion would have written ~48 GB, which is why it moves files.
- A dry run of a promotion of a clone of the published run passes every check after round 5.
- Tests: 1617 passed, 0 failed, 1 skip already there (2026-10-28 19:42 UTC).

## Evidence

`planning/archive/2026-10-issue-111-candidate-runs-promotion/review-*.md` (the plan review and five code-check rounds).
The DEV run's log stayed in the ignored `data/tune/dev/20261028_tune_run-dev.txt`, as the branch intends.

Closed by: the PR for branch `111-iterate-on-scores-privately-promote-a-ru`
