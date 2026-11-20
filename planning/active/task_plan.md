# Task: Backlog move 7: FISS workbooks: a tested parser, percent gradients, the no-fish layer for report repos, and the workbook source beside bcfishobs (#176)

**If we do it:** the workbook parser is tested `knw_fiss_*` code, site gradients read in percent, PINE joins the keyed schema, and the no-fish-captured layer and its coverage reach report repos by manifest. **If we never do:** the parser stays a 500-line script, `gradient_pct` reads 2.5 % as 0.025 %, and the layer stays a per-group file copied by hand.

## Context

Move 7 holds three batches and seven issues. At the gate (Al, 2026-11-20) this PR keeps **batch 11** (#7, #34, #10) and
splits the other two off.

- #7: the FISS workbook parser is 610 lines of `scripts/0220-fiss-xls-parse-nfc.R`, and its only test is rerunning
  five groups.
- #34: `0250` writes `gradient_pct` as a fraction. Measured today, the workbook values peak at 0.21–0.43 in every group
  (COTR 187 values, LNTH 39, UNTH 39, UPCE 102, PINE 102), while `fwa_gradient_pct` has a median of 2.43.
- #10: PINE's fetch log predates `idx` and `xls_url`, so its reconcile compares counts only.

The plan does them in one order, so the FISS outputs are regenerated once and diffed once:

1. Graduate the parser and prove all five groups' outputs come out byte-identical.
2. Re-fetch PINE and prove its site tables are unchanged.
3. Fix the gradient in `0250` and regenerate.

## Decided at the gate (Al, 2026-11-20)

- **Batch 11 only.** Batch 12 (#17, #2, #1) moves to a new issue that names them as members, in the shape of #211, with
  its two gate questions still open there: does #17's SHA stamp make #2 unnecessary, and is #1 still wanted (deferred,
  Al). #245 (batch 27) stays its own issue, and its body says it was split from move 7 and still asks "one PR or two".
  Both leave `planning/backlog.md` (the move 7 row and the sections for batches 12 and 27), so the next `/backlog-sweep`
  places them after this PR merges. The #176 body says what it now carries.
- **Fixtures come from the provincial template** (decided in the umbrella body). The labels and banners are the
  template's text, and every data value is synthetic. No submission row is copied.

## Phase 0: Split the move

- [ ] File the batch 12 issue: "If we do it / If we never do" from #17, members #17 #2 #1, the two open gate questions,
      and "split from #176 (move 7)". Batch 12's Touches go into its body.
- [ ] Edit #245's body: split from #176 at its gate; it reads this PR's `knw_fiss_*` parser, so it follows this merge.
- [ ] Edit #176's body: carries batch 11, with batch 12 split to the new issue and batch 27 to #245.
- [ ] `planning/backlog.md`:
  - move 7's row reads batch 11 (3 issues);
  - the sections for batches 12 and 27 are removed;
  - a `Verified` line says why.

## Phase 1: Measure before moving code

- [ ] Per edition, measure the header row and banner of each step sheet from the five parse logs. Header rows seen
      today are 4, 6, 17, 18, 20, 23, 26 and 31, more than #7 lists. Write the fixture set in `findings.md`.
- [ ] Find the provincial template:
  - where the current edition can be downloaded;
  - the 2016+ label rows taken from it;
  - for older editions (2012, the header-17 layout, the step-name banner), the label rows read from workbook headers,
    which are template text.
  Record each edition's source.
- [ ] Read the template's terms from its catalogue page. Then either add an `inst/NOTICE.md` row, or file a note on
      #76 if the terms are unconfirmed.
- [ ] #34: read the number format of the gradient cell in a few workbooks per edition. Convert a copy with soffice into
      the scratchpad and read the style with tidyxl. Confirm it is a percent format and record the editions.
- [ ] Reference outputs before any code change: the md5 of every `data/<wsg>/fiss_*` file for the five groups and of
      `data/fiss_*.csv`, written to the scratchpad.
- [ ] Check that `data/fdis/build/{sites,fish}.rds` are the published build's (against the run ledger's md5s), since
      `0250` reads them. Find a reachable fwapg for `0220`'s clip and `0250`'s placement, and read `pg_stat_activity`.

## Phase 2: #7, graduate the parser into the package

- [ ] Add `R/fiss_parse.R` with these exports, each with `chk` checks and a runnable example on an `inst/testdata/fiss/`
      fixture:
  - `knw_fiss_match_sheet(sheets, step)`;
  - `knw_fiss_read_step(path, sheet)`, which returns status, header_row, banner, rows_raw and data;
  - `knw_fiss_select(df, step)`;
  - `knw_fiss_parse_step(path, report_id, step)`, carrying the seven named statuses and the Step 3 fallback for the
    fish layout;
  - `knw_fiss_utm_zone(x)`.
  `wanted_cols`, `variant_map` and `step_pat` become internal package objects, readable through
  `knw_fiss_columns()`.
- [ ] Add `R/fiss_nfc.R`, `knw_fiss_nfc(step2, zero_catch_codes)`: the Step 2 roll-up to a site, covering `submitted` vs
      `derived`, blank counts never read as zero, `nfc_conflict`, and `NA` when there is no Step 2 record. Codes are
      passed in, because `data/` does not ship.
- [ ] `DESCRIPTION`: `readxl` and `janitor` go into Imports. The column names depend on `make_clean_names()`'s exact
      output.
- [ ] Add `data-raw/fiss_fixtures.R`. It writes a small xlsx per layout with openxlsx, and converts the `.xls` ones with
      `soffice --convert-to xls`, so both readxl backends are tested. Output goes to `inst/testdata/fiss/`. The layouts:
  - the 2012 edition (header 31);
  - one 2016+ edition (header 26);
  - the header-17 layout;
  - a step-name banner;
  - a tissue workbook (`no_sheet_match`);
  - a Step 2 sheet in fish layout;
  - a sheet with no `REFERENCE NUMBER` row (`no_header`);
  - template blank rows that have to filter to `no_rows`;
  - a `"11U"` zone.
- [ ] Add `tests/testthat/test-fiss_parse.R` and `test-fiss_nfc.R`. They assert counts and exact values, never
      `all(grepl())`. Prove the guards fire: restore each bug the script has fixed (the `species_code` variant, the
      `"11U"` zone, the duplicate canonical column, blank counts read as zero) and watch the test go red.
- [ ] `scripts/0220` becomes a thin driver: it calls the package, and keeps the reconcile, placement, clip and writes.
      Update the `scripts/README.md` entry.
- [ ] Rerun `0220` for COTR, LNTH, UNTH, UPCE and PINE, still on PINE's old layout. Every output must be byte-identical
      to Phase 1's md5s, the `.gpkg` read as content. Logs go to `scripts/logs/fiss/`.

## Phase 3: #10, re-fetch PINE

- [ ] Move `data/pine/fiss_xls/` aside, then run `WSG_TARGET=PINE FISS_FETCH=TRUE Rscript scripts/0210-fiss-xls-fetch.R`
      (77 files), then `0220` for PINE. Log both.
- [ ] Read the reconcile: `manifest_urls_vs_fetch_log_urls` should replace the count-only check. The site, step2 and
      step3 tables must be byte-identical. The parse log should differ only in `path`, and the fetch log gains `idx` and
      `xls_url`. Anything else stops the phase, and I report it.

## Phase 4: #34, percent gradients in `0250`

- [ ] `0250`: `gradient_pct = 100 * num(average_gradient_percent)`. It refuses (`stop()`) when any raw value exceeds 1,
      because mixed units cannot be told apart. A plausibility check against `fwa_gradient_pct` (a median ratio within
      a stated band) is logged in the reconcile.
- [ ] Rerun `0250`. Diff `data/fiss_evidence.csv`: only `gradient_pct` may move. If any other column or file moves (for
      example a placement tie on this database), stop and report it.
- [ ] Record the consequence. `fiss_evidence` is a recipe input of the evidence receipt (`inst/receipt/evidence.yaml`),
      so a later `0310` rebuild compares as recipe-`different` against the published build. `knw_fiss_visits()` does not
      read `gradient_pct`, so the derived tables do not change. Grep for any reader that refuses when the tracked file's
      sha moves, and say what was found.
- [ ] Update `research/fdis_export.md` where it describes the workbook gradient.

## Owed at the end (reported, done after merge)

- [ ] The next `/backlog-sweep` places the batch 12 issue and #245, which `/compact-prep` names.

## Validation

- [ ] Tests pass (`devtools::test()`), `lintr` per file against `origin/main`, and `devtools::document()`.
      `pkgdown::check_pkgdown()` passes with the new exports in the reference index.
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:

- **#7:** five groups byte-identical before and after, plus fixture tests that each go red against their restored bug.
- **#10:** PINE's site tables are unchanged, and its reconcile holds the URL-set check.
- **#34:** the CSV diff moves only `gradient_pct`, and the new values sit in the range of FWA's.

