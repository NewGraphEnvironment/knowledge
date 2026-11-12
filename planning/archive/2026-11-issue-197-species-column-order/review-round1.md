# Code-check round 1 (#197), branch against origin/main

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, with the `|` table rows skipped. I read none of its 24 standalone headings, because none names a tool or shape this diff uses.
- code-check-r.md: I read 6 headings: "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent"; "Postgres row order is never fixed unless the query fixes it, so a pick, a float sum and a presence check can each depend on it"; "Under `R CMD check`, tests run from a temp dir against the INSTALLED package"; "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared"; "An `information_schema` lookup by the literal table name misses what Postgres resolves"; "`paste()` with a zero-length argument returns length ONE, not zero". I did not read the other 115.
- code-check-shell.md: none of its 71 headings. The diff contains no shell.
- code-check-spatial.md: none of its 94 headings. The diff contains no spatial code.

## What I checked and found sound

- `.knw_place_species()` matches the old code on every input. It sorts with radix, so the order does not depend on the session's collation. An empty catalog still returns `character(0)` and still reaches the `stop()`. The `for (sp in sp_hab)` loop overwrites the `sp` list only after `sp_access` and `sp_hab` have been taken from it.
- The new unit test starts from an unsorted order (PK, BT, WCT, GR), so it would go red if the sort were removed. `withr` is in DESCRIPTION. `knowledge:::` resolves under `R CMD check`.
- In `scripts/0310`, every other column between placement and `write_csv()` comes from a fixed select list or from the config's `species`. Two databases on one build therefore get one column order for `visits_link` and `workbook_sites`.
- The published ledger (`scripts/logs/habitat/20261103_evidence_build_ledger.csv`) lists both species groups unsorted (`BT;CH;CM;CO;PK;SK;ST;WCT;GR;KO;RB`). The claim "That order is not the published build's" holds.
- The comment in `inst/receipt/evidence.yaml` is not hashed into any receipt: `.knw_receipt_config_files()` takes `settings` and `walk`.

## Findings

- **[severity: bug (false prose)]** research/database_builds.md:263-265 and research/run_archive.md:138-141. Both files say the next evidence build's two tables, and `visits_link`'s md5, "differ from the published build's once, with the same values", and pin that one-time difference on #197's column order. For `visits_link` the logs say otherwise:
  - The published build has no `segment_fwa_gradient`. Its ledger has no `segment_fwa_gradient_missing` row, while the #165 host ledger has one, and current code (58fe4bb8, #120) adds the column. `scripts/logs/habitat/database_second/20261106_database_compare-evidence.csv` shows the same: a current build set beside the published one reads "added by the current code: segment_fwa_gradient".
  - database_builds.md says, a few lines above the new text, that #161's fix "reaches the visits at the next `0310`": about 630 parent-flow lines move on either database. That comparison also had `mad_pick` differing on 3 visits.

  So the next build's `visits_link` does not hold "the same values" as the published one: it has an extra column, and values may differ on the tied visits. Its md5 would move away from the published build's even without #197. The sentence gives a reader the wrong idea of what the next `evidence_md5` change means, and of which differences they can ignore. The cross-database half ("then agree across databases") is supported by #165's pair; the claim about the published build is not.
  - **Rule:** code-check.md "The probe is broken before the world is"

- **[severity: fragile (false comment)]** tests/testthat/test-link_place.R:20. The comment says the fixture rows are "in the order one database gave them on #165". No ledger supports that. Both #165 ledgers, and every other ledger, list access as `BT;CH;CM;CO;PK;SK;ST;WCT;GR;KO;RB`, with BT before PK. The fixture puts PK first, keeps 4 of the 11 access species, and trims each table's columns. The test is still valid, since any unsorted order exercises the sort. The provenance claim is false, though, and a reader would take the fixture as a replay of the real catalog order.
  - **Rule:** none

/Users/airvine/Projects/repo/knowledge-receipt/planning/active/review-round1.md
