# Plan review — #38 (Plan agent, 2026-10-06, read-only; written here by the parent)

Reviewed with Phases 1–2 staged. Migration checked column by column against HEAD: 510 rows, 19 → 20
columns, variable changed on the 12 air rows only, 3 notes appended.

| id | class | finding | disposition |
|---|---|---|---|
| B1 | Blocker | a `none` row cannot carry `bound` (`need` check fires), so it cannot meet a max/min grid cell | Phase 4: let `none` rows carry `bound`, test it |
| B2 | Blocker | grid cell definition unspecified (range vs max/min, optimum, qual, air, which window per stage, unstated) | Phase 4: cell rules written into 0280 before rows |
| G1 | Gap | 0270 cannot attach a loose local PDF | done: optional `pdf` column on members (URL or repo path) |
| G2 | Gap | tag hard-coded twice, docstring and defaults too | done in the 0270 refactor |
| G3 | Gap | `habitat_modelling` store is built from `temperature` among others; memos are members there | Phase 3: rebuild and push `habitat_modelling` too |
| G4 | Gap | `0150 ACTION=query` broken (cred crd_search); draft with `ragnar::ragnar_retrieve()` | Phase 4 |
| G5 | Gap | sources mostly WCT; most degree-day cells would be `none` | Phase 4: `none` notes say what was searched (the store + named PDFs), never "no value exists" |
| G6 | Gap | NEWS/DESCRIPTION, scripts/README columns and coverage text, CLAUDE.md conventions, a drafter brief schema | Phase 5 |
| G7 | Gap | base temperature only free text | done: a cited `degree_days` row needs a note |
| G8 | Gap | value_in_quote passes en-dash ranges and thousands commas; "1 000" fails closed; no °F unit | recorded; °F not added (affine, value check cannot rescale) |
| O1 | Ordering | 0270 default dry run must be compared before memo uploads | done: identical to main |
| O2 | Ordering | `--collection temperature` must find `SW2RXUJC`, not create | done: "exists" |
| O3 | Ordering | issue body still says all 56 rows get a metric | Phase 5 issue edit: qual rows blank, `mwat`, `7dec`, air rows |
| A1 | Assumption | Weiss rows may be air | confirmed for 242 and 245 (code-check round 1), moved |
| A2 | Assumption | Coleman & Fausch studied Colorado River cutthroat, not WCT; Bear's rainbow trout is not ST | Phase 4 convention: species_code is the species studied; CRCT values are not WCT rows (named in research file as the transfer source) |
| A3 | Assumption | Bear 2005 thesis may be open; CTmax metric | Bear 2005 only on ResearchGate: flagged to user; CTmax would be `unstated`… decide if a row arises |
| A4 | Assumption | no column-position readers; registry link key excludes variable | confirmed |
| A5 | Assumption | research files cite evidence rows by number | Phase 4 appends only |
| S1 | Scope | overwinter size merged into rearing growing_season | Phase 4: an `overwintering` × growing_season cell |
| S2 | Scope | ~45 cells; budget two meaning-audit rounds | Phase 4 |
| AC1 | Acceptance | fixture checkbox overstated; no test of degC-day on temperature | done: wording fixed, test added |
| AC2 | Acceptance | grid in exit condition and printed; metric in gate log | Phase 4 |
| AC3 | Acceptance | Phase 3 pass/fail checks | Phase 3 checkboxes below |
