# Plan review (#36), Plan agent, 2026-10-07

Returned as reply text (the Plan agent cannot write files); recorded here by the parent, with dispositions.

| id | finding | disposition |
|---|---|---|
| B1 | "Drop the `fits` entry" cannot go red: an absent variable already gets `NULL`, and `u %in% NULL` is FALSE, the same as `character(0)`. | Applied. The mutation that ran gives groundwater a unit (`"m/s"`), and both assertions go red. The plan text is corrected. The `.knw_unit_fits()` refactor with a setequal test was not taken. |
| G1 | A future number would more likely be a vertical hydraulic gradient (dimensionless, `ratio`) than a flux. Also, "no source gives one" is only true of the #33 sources. | Applied. Code comment, Rd and NEWS now say "upwelling measure"; the Rd says "no source read so far". |
| G2 | Shared ancestry: the 2010 rule hyporheic row and Hagen & Sary p. 4 both cite Baxter & Hauer 2000; the two incubation rows may be one Baxter study. | Applied to the row notes (679; 682/683 already said so). |
| G3 | Sibling fields: the source decides, not the sibling (Hagen & Sary scale differs between its rows; a Metolius rearing sibling?). | Scale was chosen per row (676 reach: alluvial sections). Metolius stays spawning, since its original is spawning and rearing is covered elsewhere (data row 112). |
| G4 | Nothing stops a groundwater row carrying a `parameter`, which 0280's COVERAGE would count. | Not guarded. No groundwater row has one, and the PR acceptance check confirms it. |
| G5 | Metolius p. 28 (spawning at Heising Spring) and p. 6 (Crooked River) are left out. | Applied: data rows 684 and 685. The 2015 p. 6 "Redds are often constructed ..." line stays in a note (same claim as p. 5). |
| G6 | `bt_spawning.md` header rows and gate path; `scripts/README.md` columns paragraph. | Applied in Phase 3. |
| O1 | Append, never insert: docs cite data-row numbers. | Already the case. |
| A1 | The plan's row numbers were file lines. | Corrected in `findings.md`. |
| A2 | Duplicate key+quote across variables is normal (211 rows). | Noted. |
| A3 | Incubation rows are `qual`, not `lab` or `expert`. | Already the case. |
| Acceptance | 0280 statuses of rows 1-674 must match the 2026-10-06 log. | Checked: 674 compared, 0 changed. |
