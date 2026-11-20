## Outcome

Backlog move 7 (#176), cut at its gate (Al, 2026-11-20) to batch 11. Batch 12 (#17, #2, #1) moved to #248, carrying
its two gate questions open, and batch 27's #245 was left for the next sweep to place. Three things landed:

- **#7.** The Fish Data Submission workbook parser left `scripts/0220` for the package:
  - `knw_fiss_parse_step()`, `knw_fiss_read_step()`, `knw_fiss_match_sheet()`, `knw_fiss_select()`,
    `knw_fiss_columns()` and `knw_fiss_utm_zone()` in `R/fiss_parse.R`;
  - `knw_fiss_nfc()`, the Step 2 no-fish roll-up, in `R/fiss_nfc.R`;
  - tests on six synthetic workbooks, one per layout measured over the five groups;
  - `0220` is now the driver over them.
- **#10.** PINE was re-fetched onto the keyed fetch-log schema.
- **#34.** `0250` reads the workbook site gradient in percent.

What was learned:

- **There are five workbook layouts, not the three #7 named.** Its "row 26 (2016+)" is the pre-2012 edition. Every
  V2.0 banner from 2012 to 2022 shares one layout, with Step 1 to 4 headers at rows 31, 23, 18 and 20.
- **The template's gradient cell is percent-formatted.** All 25 reports carrying a gradient store a fraction: 24 in
  `0.0%` cells, and one typed into General cells.
- **The template carries no licence.** The province's copyright page reserves all rights. Al kept the fixtures as
  built (labels and banner lines only, values made up), with a line in `inst/NOTICE.md`; #76 keeps the question.
- **The review caught what defaults put into artifacts.** Round 1 found gradient checks that passed by default.
  Round 2 found openxlsx writing the session's login into the fixtures as their author. Round 3 found the review
  record quoting it. The unpushed branch was rewritten twice, so no commit holds the login (`findings.md` has the SHA
  maps).

## Measurement

- **Baseline.** The unchanged `0220`, rerun on the five groups (COTR 736 sites, LNTH 1,427, UNTH 989, UPCE 7,023,
  PINE 1,610):
  - reproduced every tracked CSV byte for byte;
  - wrote each GeoPackage with identical content;
  - wrote each reconcile differing only in the two rows that name the database that ran.
- **Refactor.** All 45 non-GeoPackage outputs came out byte-identical to the baseline, on the first refactored code
  and again on the final code.
- **Guards.** Eight bugs the script had fixed were restored in turn, and each turned the fixture tests red: 1 to 5
  tests each.
- **PINE.** The re-fetch brought back all 77 files, 44 read directly and 33 converted, July's split. PINE's site,
  step-2 and step-3 tables came out byte-identical. Its parse log moved only in `path` (308 rows), and its reconcile
  now checks URL sets.
- **#34.**
  - The unchanged `0250` reproduced its four tables. The fix moved only `gradient_pct`, on 31 rows, each ×100.
  - The median ratio to `fwa_gradient_pct` is 0.925 over 16 sites, inside the 0.25–4 band stated before the run.
  - A copy reading every gradient in percent stops on both new reconcile rows.
- **Test suite.** 453 tests, 0 failed. `R CMD check`: 0 errors, 0 warnings, and 1 note, the over-wide example lines
  in other files.

## Evidence

`scripts/logs/fiss/20261120_*`. The layout, format and enumeration measurements are in `findings.md`, and the review
rounds in `review-round*.md` and `review-verdict.md`.

## Owed

- The next `/backlog-sweep` places the batch 12 issue and #245, which `/compact-prep` names.

Closed by: PR (opened by `/gh-pr-push` from branch `176-backlog-move-7-fiss-workbooks-a-tested-p`)
