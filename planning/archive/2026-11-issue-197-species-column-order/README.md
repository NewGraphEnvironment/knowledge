## Outcome

`knw_link_place()` read the species it places from `information_schema.columns` unordered, so the species columns of
the evidence build's `visits_link.csv` and `workbook_sites.csv` came out in each database's catalog order: on #165 two
databases holding one build wrote the same values with different bytes, and `visits_link`'s md5, the first of every
grade's `evidence_md5`, differed. `.knw_place_species()` now sorts both species lists by name (radix), and a test feeds
the catalog rows in three orders. What was learned: the access list was never sorted in any ledger either (it follows
`streams_access`'s column order, which drifted once without a database switch), so the next evidence build moves both
column blocks once on every database; and the next build's `visits_link` differs from the published build's in content
too (#120's `segment_fwa_gradient`, #161's parent flows), which the first draft of the research prose missed.
`research/database_builds.md`, `research/run_archive.md` and `inst/receipt/evidence.yaml` say so.

## Measurement

- Ledgers (`scripts/logs/habitat/*evidence_build_ledger*.csv`, 15 read): `species_with_access` is unsorted in all of
  them (`…;WCT;KO;RB;GR` 2026-10-17 to 10-27, `…;WCT;GR;KO;RB` from 11-03); `species_with_habitat` is sorted on some
  databases and in catalog order on others (the published `20261103` build: unsorted). Sorted, both read
  `BT;CH;CM;CO;GR;KO;PK;RB;SK;ST;WCT`.
- Guard proof: with the helper replaced in the loaded namespace by an unsorted copy, the new test failed 5 times and
  the live placement test (it ran against a database here) once; `R/link_place.R`'s md5 unchanged across the run.
- Full suite on the branch: FAIL 0, SKIP 3, PASS 2298 (2.1 min).
- Branch review: three rounds; round 3 found a defect inside round 1's fix, so the loop ended on an enumeration of
  the 12 claims the branch adds (`review-enumeration.md`), all true.

## Evidence

`scripts/logs/habitat/*evidence_build_ledger*` (the species rows); `scripts/logs/habitat/receipt_165/` (the #165 pair
the issue measured).

## Owed

- `planning/backlog.md`'s provenance track: note #197 done in its PR (as #165's was, a `[skip ci]` commit after
  the merge)

Closed by: PR (to be opened from branch `197-order-the-species-columns-knw-link-place`)
