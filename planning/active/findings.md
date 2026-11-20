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

## Phase 1 measurements (2026-11-20, on m1, local fwapg)

**Layouts.** Over the five groups' parse logs there are five workbook layouts, not the three #7 names:

| layout | workbooks | Step 1 header | Steps 2 / 3 / 4 header | names |
|---|---|---|---|---|
| V2.0 template (banners 2012, 2016, 2018, 2019, 2020, 2022) | 150 | 31 | 23 / 18 / 20 | `Species`, `Sampling Method`, `Haul # /Pass #`, `Survey Date`, `Alias (Local Name)`, `Waterbody (ID) Identifier` |
| pre-2012, row 1 is the step name | 80 | 26 | 6 / 6 / 6 | `Species Code`, `Method` (Step 3) or `Sampling Method` (Step 2), `Haul or Pass`, `Date (yyyy/mm/day)` |
| pre-2012, Step 1 "(Locational Info)" | 2 (LNTH) | 17 | 6 / 6 / 6 | as above, Step 2 `Method` |
| per-fish workbook ("Reference", "Fish collection") | 5 | none matches | Step 2 sheet at 4, read as Step 3 | `Species Code`, `Length (mm)` |
| tissue data, reach summaries, other tables | 10 | none matches | none | |

#7's "row 26 (2016+ editions)" is wrong: the header-26 layout is the pre-2012 edition, and every V2.0 banner from
2012 to 2022 shares one layout and one label set. The banner of row 1 differs by sheet within one workbook (Step 2's
reads "Fish  Data Submission Spreadsheet Template V. 2.0, ..." where Steps 1, 3 and 4 read "-V 2.0, ...").

**The template's terms.** The current template is a zip on the province's "Submit fish data" page, with no licence of
its own; the site's copyright page reserves all rights and asks for written permission to reproduce. The fixtures
therefore copy only what the parser keys on, the column labels and the edition banner line, and nothing else of the
template (instructions, pick lists, formatting, macros); every data value is synthetic. Noted on #76.

**#34, the gradient cell's format.** Every filled `Average Gradient (%)` cell read carries the number format `0.0%`:
two pre-2012 workbooks (LNTH 11293, COTR 16428, converted with soffice) and three V2.0 (COTR 62266, 50588, 50944). A
percent-formatted cell stores 2.5 % as 0.025, so `0250` multiplies by 100.

**The FDIS build `0250` reads** is the published one: `fish.rds` 8cf27351, `catch.rds` a31fd7bb, `sites.rds` 39f751b1
(move 6's archive README).

**Baseline.** Today's `0220`, run unchanged on the five groups (m1's local fwapg, idle), reproduces every tracked CSV
byte for byte; each GeoPackage holds identical rows, attributes, geometry and CRS (its bytes differ by the write
stamp); each reconcile differs only in `enumerate_db_source`'s expected column and `clip_polygon_source`, which name
the database that ran. Group totals: COTR 736 sites (394 no fish), LNTH 1,427 (207), UNTH 989 (181), UPCE 7,023 (419),
PINE 1,610 (209). The baseline outputs are the refactor's reference; the tracked files were restored so no content-free
change is committed.

## Phase 2: the refactor's proof (2026-11-20)

- **Byte-identical.** The refactored `0220` (the driver over `knw_fiss_parse_step()` and `knw_fiss_nfc()`), run on the
  five groups against the same database, wrote all 45 non-GeoPackage outputs byte-identical to the baseline run,
  reconciles included; every GeoPackage holds identical rows, attributes, geometry and CRS. Logs:
  `scripts/logs/fiss/20261120_fiss_parse_<wsg>.log`. The tracked files were restored afterwards (no content moved).
- **Guards fire.** Each bug the script had fixed, restored in turn, turns the fixture tests red:

  | restored bug | tests red |
  |---|---|
  | `species_code` variant removed | 5 |
  | `"11U"` read as a plain number | 1 |
  | variant renamed over a canonical name already present | 2 |
  | a blank count read as zero | 2 |
  | no Step 3 fallback to a per-fish Step 2 sheet | 2 |
  | no reference-number filter | 1 |
  | `date_yyyy_mm_day` variant removed | 2 |
  | zero-catch codes not read as no fish | 3 |

- **Tests asserted wrongly once:** the first janitor-names test expected `width_m` from the V2.0 Step 2, which has no
  plain `Width (m)` column (the pre-2012 edition does). The test now pins that difference.
- **janitor's micro-sign warning** fires on every `µS/cm` label; it writes "m" for "µ", the name the column list
  reads (`conductivity_m_s_cm`), so `knw_fiss_read_step()` muffles that one warning.

## #34: every report's gradient format

All 25 reports that carry a workbook gradient were read (the 10 `.xls` converted with soffice into the scratchpad,
read with tidyxl): 24 store it in cells formatted `0.0%`; one, report 48876 (11 values, max 0.05), stores it in
`General` cells.
