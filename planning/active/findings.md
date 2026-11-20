# Findings — Backlog move 7 (#176)

## Issue context

**If we do it:** the workbook parser is tested `knw_fiss_*` code, site gradients read in percent, PINE joins the keyed schema, and the no-fish-captured layer and its coverage reach report repos by manifest. **If we never do:** the parser stays a 500-line script, `gradient_pct` reads 2.5 % as 0.025 %, and the layer stays a per-group file copied by hand.

### Batch 11. Parser, gradient and PINE
- **Why here:** one regeneration of the FISS outputs: graduate the parser, fix the gradient in `0250`, re-fetch PINE through it, diff once.
- **Touches:** `R/fiss.R` (new), `tests/testthat/test-fiss.R` and fixtures, `scripts/0220`, `scripts/0250`, `data/pine/`, `data/fiss_evidence.csv`.
- **Decided at the gate:** fixture workbooks built from the provincial template.

| issue | title |
|---|---|
| #7 | Graduate the FISS .xls parser into the package as tested knw_fiss_* functions |
| #34 | FISS workbook site gradient is read as a fraction, not a percent |
| #10 | Re-fetch PINE so its fetch log carries idx and xls_url |

### Batch 12. Layers for report repos
- **Why here:** #17 rolls up batch 11's outputs; #2 and #1 are the other two things report repos would consume.
- **Touches:** `data/nfc.gpkg`, `data/nfc_coverage.gpkg`, an S3 sync, `R/` (a snapshot helper if kept), a planning-method vignette.
- **Decided at the gate:** whether #17's SHA stamped in the GeoPackage makes #2 unnecessary; whether #1 is still wanted.

| issue | title |
|---|---|
| #17 | Cross-group NFC roll-up plus a coverage layer, synced so rtj can load it by manifest |
| #2 | Snapshot consumer: pull a layer at a recorded knowledge SHA into a report repo |
| #1 | Planning-method vignette for reports to port as an appendix |

### Batch 27. FDIS age classes and the workbook source (added 2026-11-20)
- **Why here:** split from #23 at move 6's gate; the workbook half reads batch 11's tested `knw_fiss_*` parser and the same regeneration of the FISS outputs, so it follows batch 11.
- **Touches:** `scripts/0230-fdis-load.R`, `R/fdis_passes.R`, `scripts/0250-fiss-evidence.R`, `data/fiss_evidence.csv`, a new workbook-against-bcfishobs check.
- **Decide at the gate:** one PR or two (the age classes touch the FDIS load, the workbook source the FISS scripts).

| issue | title |
|---|---|
| #245 | FDIS counts by age class, and the Fish Data Submission workbooks as a second source beside bcfishobs |


---

Backlog: `planning/backlog.md`, move 7. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.






## Measured at the gate (2026-11-20)

- Workbook `average_gradient_percent` per group (`fiss_sites_<wsg>_all.csv`): COTR 187 values, max 0.43, median 0.085; LNTH 39, max 0.21, median 0.025; UNTH 39, max 0.325, median 0.04; UPCE 102, max 0.4, median 0.12; PINE 102, max 0.4, median 0.115. Every group reads as a fraction. In `data/fiss_evidence.csv`, 16 sites carry a gradient (median 0.025), against a median `fwa_gradient_pct` of 2.43.
- Parse-log header rows across the five groups: 4, 6, 17, 18, 20, 23, 26 and 31 (NA on 83 rows). Statuses: ok 605, no_rows 298, no_sheet_match 53, no_header 30, fish_layout 2.
- `0310` reads `data/fiss_evidence.csv` and every `fiss_step2_fishcoll_*.csv`, and hashes both into the evidence receipt as recipe inputs (`fiss_evidence`, `fiss_workbooks`; `inst/receipt/evidence.yaml`). `knw_fiss_visits()` does not read `gradient_pct`.
- Local workbook caches (ignored): COTR 31, LNTH 56, PINE 78, UNTH 38, UPCE 49 files. soffice, readxl, janitor, openxlsx and tidyxl are installed; writexl is not.

## Errors Encountered

| Error | Resolution |
|-------|------------|
