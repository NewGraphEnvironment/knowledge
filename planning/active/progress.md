# Progress — Thermal requirements by species and life stage (#38)

## Session 2026-10-06

- Plan-mode exploration; two forks decided at the gate (air_temperature variable; window metrics for degree-days)
- Created branch `38-thermal-requirements-by-species-and-life` off main
- Scaffolded PWF baseline from issue #38 with approved phases
- Next: start Phase 1
- Phases 1–2: `metric` column, `degree_days` and `air_temperature` variables, unit `degC-day`; 56 rows
  migrated (14 to air: 12 valued, 2 qualitative). Tests green; `0280` green (510 rows, 48/48 coverage), log `20261006_literature_verify*`.
  Schema and migration committed together, because the schema alone makes the committed CSV unreadable.
- `/code-check` on Phases 1–2: round 1 found rows 242/245 (Sheer on Weiss) still `temperature` though
  air; round 2 found the planning counts stale after that fix and a metric accepted on value-less rows.
  Ended by enumeration: 36 variable × kind × metric cases against the documented rule, 0 disagree; every
  count in findings/progress re-derived from the table. Plan review filed in `review-plan.md`.
- Phase 3: `0270 --collection` and member `pdf`; default dry run byte-identical to main; temperature dry
  run found `SW2RXUJC`; live run 29 added, both memo PDFs uploaded (log
  `20261006_temperature_collection_build.txt`). The memo `/f/` links now serve an empty page; the PDFs were
  printed from `/analyses/fish-passage-22b/` and `/analyses/skeena-stream-temp-25/` (headless Chrome) into
  the gitignored `data/rag/pdf/`. Bear 2005/2007: no open copy (Unpaywall and Semantic Scholar: closed; 2005
  report only on ResearchGate). `temperature` store build started (37 keyed PDFs).
- Phase 4 started: `none` rows may carry `bound`; 0280 THERMAL grid (5 species × 10 cells; 12/50 met
  before drafting). Two drafters (tc: WCT, BT; ps: CH, CO, ST) on `drafter-brief.md`.
- `temperature` store: 37 documents, 7,377 chunks; pushed, manifest now holds six stores; a verified connect to a fresh dir downloads and checks it (`20261006_temperature_store_{build,push}.txt`). `habitat_modelling` rebuild started.
- `habitat_modelling` rebuilt (220 documents) and pushed; verified connect.
- Phase 4: drafters wrote 163 rows (tc 49 after the parent dropped Sauter's BT "cessation"; ps 114).
  Meaning audit round 1: tc 6 findings, ps 13 findings over 22 rows plus one missed value; all applied
  (one adult pre-spawn row dropped, the Hicks 9.9 C incubation row added). Round 2 re-checked every fix
  and swept all rows for the four classes: one defect inside a round-1 fix (Sauter Table 4 is observed
  temperatures, so `dist`, not `expert`), DAT that Sauter calls assumed now `unstated`, more `lab`, the
  Hagen & Weber stress onset filed to match Lusardi's, Hagen & Weber 2019 added to the collection.
  Ended by enumeration: every same-source, same-page group with mixed kind or metric is mixed by its own
  sentences; value-only cells recomputed. Code: code-check round 2 found the grid relied on qual rows having
  no value; the reader now refuses one; the four invariants `meets()` relies on are all enforced.
  Gate: 674 rows, thermal 50/50, coverage 48/48.
