# Findings — Write receipts for the evidence build and the published visit tables (#160)

## Issue context

**If we do it:** the evidence build `0310` writes and the visit tables `0299` publishes each carry a receipt in crate's shape, as the grade tables and the published sets do since #154. The rule the whole provenance track started from is then written down as a declaration: the visit tables must match exactly, while `access_check`'s km may differ by a rounding. **If we never do:** that rule stays where it is today, implicit in which tables `knw_build_record()` and the grade records fingerprint. A grade receipt names the evidence by its tables' sha256, so a rebuilt evidence build that came out equivalent but not byte-identical reads as another recipe for every grade downstream.

## Problem

#154 gave receipts to the two writers its issue named: each grade table (`knw_grade_receipt_write()`, from `0320`) and each set `knw_publish()` writes (from `0325`). Two outputs knowledge makes and publishes have none:

- **The evidence build** (`0310`: `visits_link`, `visits_species`, `walks`, and `access_check`). This is the motivating case. One rebuild of the same build's evidence gave three byte-identical tables and a fourth, `access_check`, differing at 9.5e-11 km per value, because the database summed in another order. A grade receipt names each visit table by its sha256 (`recipe.inputs`). An evidence receipt would let those inputs name the build's `recipe_id`, so an equivalent rebuild of the evidence would not make every grade downstream `different`.
- **The published visit tables** (`knowledge/fdis/v<n>`, written by `scripts/0299-fdis-publish.R` with its own manifest code, not `knw_publish()`).

## Proposed

- [ ] `inst/receipt/evidence.yaml`: the three visit tables exact, `access_check`'s km at a rounding started from the 9.5e-11 km precedent and from #158's measurements of the second database's evidence build. #158 measured (2026-11-06, `scripts/logs/habitat/database_second/20261106_database_compare-evidence.csv`): `visits_species`, `walks` and the bcfishobs and workbook tables identical; `access_check` equivalent at 6.0e-11 km per value; `visits_link` identical but `mad_pick` on 3 visits, which #161's unordered parent-flow tie moves by up to 0.0029 m³/s, so `visits_link` can be declared exact only once #161 lands. The recipe is link's build (its run uid), the flow load, the placement settings, and the FDIS export's version.
- [ ] `0310` writes the evidence build's receipt beside its ledger, in the evidence directory.
- [ ] The grade receipts' evidence inputs name that receipt's `recipe_id` where one exists, and fall back to the tables' sha256 for a build without one.
- [ ] `0299` writes the published visit set's receipt beside its manifest, through `knw_publish(receipt =)` or the same crate call.
- [ ] Tests on the same pattern as `test-receipt.R`: every declared rounding holds a value moved within it and refuses one moved past it, and the declared values are pinned.

Relates to #154, #158, NewGraphEnvironment/crate#43


