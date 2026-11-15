# Code check, round 2 (#197, branch against origin/main)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of every H3 under `## Mechanisms` (14), table rows and evidence blocks skipped; no standalone rules read (none matched a tool or shape in this diff).
- code-check-r.md: by heading. Read: "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared" (withr checked in Suggests), "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent", "Zero-length, empty, and unset" (mechanism, for the empty catalog case), "Postgres row order is never fixed unless the query fixes it". About 120 headings not read (none names a tool or shape the diff uses).
- code-check-shell.md: no heading read (the diff has no shell).
- code-check-spatial.md: no heading read (the diff has no spatial code).

## What was checked

- `.knw_place_species()` against the old inline code: same sets; `unique()` now after `toupper()` (harmless); radix sort is locale-free; an empty `cols` gives `character(0)` and reaches the `stop()`.
- The order flows to every species column in `placed`: `access_<sp>` (from `sp_access`), the habitat selects (from `sp_hab`), and the `_stored` copies (re-gating loop over `sp_hab`). The live test's `^[a-z]+_rearing_stored$` cannot match `<sp>_lake_rearing_stored` or `<sp>_wetland_rearing_stored`, and every `sp_hab` species gets a `<sp>_rearing` column because the SQL selects it unconditionally, so the assertion is sound.
- The unit test would fail against the old code (unsorted helper gives PK;BT;WCT;GR in the first order); `withr` is in Suggests.
- 0310: both calls (visits at 253, workbook sites at 438) go through the helper; the ledger rows `species_with_access`/`species_with_habitat` have no reader other than 0310 itself.
- Prose claims against the artifacts:
  - "its ledger lists both species groups in catalog order": `scripts/logs/habitat/20261103_evidence_build_ledger.csv` has both as BT;CH;CM;CO;PK;SK;ST;WCT;GR;KO;RB, not the sorted order. Holds.
  - "`segment_fwa_gradient` column #120 added": `data-raw/database_compare.R` header and `database_second/20261106_database_compare-evidence.csv` ("added by the current code: segment_fwa_gradient"); 0310:321 still writes it. Holds.
  - "the parent flows #161's fix moves": `database_second/20261106_link_flow_tie_check.csv` lists 632 lines whose flow differs host-old vs host-new; 4 visits in `data/fdis/derived_receipt_a/visits_link.csv` sit on those lines, so the published build's `visits_link` is expected to move there. Supported (whether `mad_pick` itself moves on those 4 depends on which flow source they pick, but the md5 claim rests on `segment_fwa_gradient` alone).
  - run_archive table row "bytes differ only in `evidence_md5`, through `visits_link`'s column order": `receipt_165/20261112_evidence_receipt_compare.txt` shows visits_species and walks byte-identical and visits_link differing in bytes but agreeing re-read; the host and second ledgers differ only in the habitat list's order. Holds.
  - evidence.yaml: comment only, consistent with run_archive.md ("crate sorts a table's columns by name before hashing").

## Clean

No issues found.
