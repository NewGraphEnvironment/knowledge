# Progress — One-SE region: state it as a heuristic, publish 1.96 beside it, and give the article references (#79)

## Session 2026-10-20

- Plan-mode exploration — phases approved by user; Al: "go all phases to pr"
- Created branch `79-one-se-region-state-it-as-a-heuristic-pu` off main
- Scaffolded PWF baseline from issue #79 with approved phases
- Next: start Phase 1
- Plan review (Plan agent) delivered; written to `planning/active/review-plan.md` and folded in
- `ZOTERO_API_KEY` is unset in the shell and in R: Phase 1 (Zotero writes) waits on it; the other phases go first
- Phase 2: `knw_tune_repick()`; at 1 SE it returns every table's `recommended`, at 1.96 the issue's column; three
  planted bugs each fail its tests. `knw_thresholds_table()` gains `rule_196`/`holds_196` (and `d_floor`, and a
  guard that the one-SE replay is the recommended rule; three more planted bugs each caught). 0325 rerun locally
  (no upload): `thresholds.csv` equals main's with the two columns removed. Expected red until Phase 5 rebuilds the
  bundle: `test-vignette-data.R`'s CH-rows md5 (the header gained two columns)
- Phase 3: the one-SE wording in four research files; `habitat_thresholds_tuned.md` gains "At 1.96 SE" (table from `knw_tune_repick()`), `chinook_rearing_tuned.md` its #57 paragraph's 1.96 pick
