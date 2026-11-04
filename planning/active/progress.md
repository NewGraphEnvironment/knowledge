# Progress — Anchoring check: report the pick from each starting point beside the best-scoring rule (#141)

## Session 2026-11-03

- Plan-mode exploration — phases approved by user
- Created branch `141-anchoring-check-report-the-pick-from-eac` off origin/main
- Scaffolded PWF baseline from issue #141 with approved phases
- Next: start Phase 1
- Phase 1: `knw_tune_anchor()` with 36 expectations over eight tests; two mutations (ties read from the first best only; an exception compared by presence only) each turn tests red (3 and 2 failures), run in a copy.
- Phase 2: `0320` binds the anchor into each summary (guarded: its rule names must equal the summary's own; a mismatch stops with a plain `stop()`, not `fail()`, so no log lands under the name 0335 promotes) and into `pick_report.csv`, with an `anchoring (#141)` block in the log. Proved without the database by running the same expressions on all 15 tune tables (8 published, 7 in candidate `20261103_0838`): the guard holds on each, and the text-read and typed tables give identical rows.
