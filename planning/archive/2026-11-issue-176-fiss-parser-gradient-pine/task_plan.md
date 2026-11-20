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
- **The template's terms** (Al, 2026-11-20, asked mid-run after the plan review's finding 12): the province's
  copyright page reserves all rights and the template's page carries no licence. Keep the fixtures as built
  (labels and banner lines only, values made up), with a line in `inst/NOTICE.md` saying what was copied; #76 keeps
  the licence question.

## Phase 0: Split the move

- [x] File the batch 12 issue (#248): "If we do it / If we never do" from #17, members #17 #2 #1, the two open gate questions,
      and "split from #176 (move 7)". Batch 12's Touches go into its body.
- [x] Edit #245's body: split from #176 at its gate; it reads this PR's `knw_fiss_*` parser, so it follows this merge.
- [x] Edit #176's body: carries batch 11, with batch 12 split to the new issue and batch 27 to #245.
- [x] `planning/backlog.md`:
  - move 7's row reads batch 11 (3 issues);
  - the sections for batches 12 and 27 are removed;
  - a `Verified` line says why.

## Phase 1: Measure before moving code

- [x] Per edition, measure the header row and banner of each step sheet from the five parse logs. Header rows seen
      today are 4, 6, 17, 18, 20, 23, 26 and 31, more than #7 lists. Write the fixture set in `findings.md`.
- [x] Find the provincial template:
  - where the current edition can be downloaded;
  - the 2016+ label rows taken from it;
  - for older editions (2012, the header-17 layout, the step-name banner), the label rows read from workbook headers,
    which are template text.
  Record each edition's source.
- [x] Read the template's terms from its catalogue page. Then either add an `inst/NOTICE.md` row, or file a note on
      #76 if the terms are unconfirmed.
- [x] #34: read the number format of the gradient cell in a few workbooks per edition. Convert a copy with soffice into
      the scratchpad and read the style with tidyxl. Confirm it is a percent format and record the editions.
- [x] Reference outputs before any code change: the md5 of every `data/<wsg>/fiss_*` file for the five groups and of
      `data/fiss_*.csv`, written to the scratchpad.
- [x] Check that `data/fdis/build/{sites,fish}.rds` are the published build's (against the run ledger's md5s), since
      `0250` reads them. Find a reachable fwapg for `0220`'s clip and `0250`'s placement, and read `pg_stat_activity`.

## Phase 2: #7, graduate the parser into the package

- [x] Add `R/fiss_parse.R` with these exports, each with `chk` checks and a runnable example on an `inst/testdata/fiss/`
      fixture:
  - `knw_fiss_match_sheet(sheets, step)`;
  - `knw_fiss_read_step(path, sheet)`, which returns status, header_row, banner, rows_raw and data;
  - `knw_fiss_select(df, step)`;
  - `knw_fiss_parse_step(path, report_id, step)`, carrying the seven named statuses and the Step 3 fallback for the
    fish layout;
  - `knw_fiss_utm_zone(x)`.
  `wanted_cols`, `variant_map` and `step_pat` become internal package objects, readable through
  `knw_fiss_columns()`. `knw_fiss_select()` and `knw_fiss_parse_step()` take `cols = knw_fiss_columns()$wanted`, so
  a consumer such as #245 can read a column the driver does not (review finding 10). A site-table function is out
  of scope.
- [x] Add `R/fiss_nfc.R`, `knw_fiss_nfc(step2, zero_catch_codes)`: the Step 2 roll-up to a site, covering `submitted` vs
      `derived`, blank counts never read as zero, `nfc_conflict`, and `NA` when there is no Step 2 record. Codes are
      passed in, because `data/` does not ship.
- [x] `DESCRIPTION`: `readxl` and `janitor` go into Imports. The column names depend on `make_clean_names()`'s exact
      output.
- [x] Add `data-raw/fiss_fixtures.R`. It writes a small xlsx per layout with openxlsx, and converts the `.xls` ones with
      `soffice --convert-to xls`, so both readxl backends are tested. Output goes to `inst/testdata/fiss/`. The layouts
      are the ones Phase 1 measured (the plan review's finding 7 corrected the list first drafted here):
  - `template_v2.xls`: the V2.0 template, Step 1/2/3/4 at rows 31/23/18/20, both banner spellings, a `"11U"` zone,
    blank entry rows, the three no-fish cases, a percent-formatted gradient;
  - `pre2012_step_banner.xls`: Step 1 at row 26 and the others at 6, the edition's variant names, an NFC beside a
    catch, and a Step 4 of key-only rows (`no_rows` by the payload filter);
  - `pre2012_header17.xlsx`: Step 1 at row 17, a Step 2 naming both `Species` and `Species Code`, a Step 3 with no
    `REFERENCE NUMBER` (`no_header`), an empty Step 4 (`empty_sheet`);
  - `individual_fish.xls`: a per-fish sheet Step 2 sets aside (`fish_layout`) and Step 3 reads;
  - `tissue.xls`: no sheet matches (`no_sheet_match`);
  - review finding 9: a sheet whose rows carry no reference number (`no_rows` by the reference-number filter).
- [x] Add `tests/testthat/test-fiss_parse.R` and `test-fiss_nfc.R`. They assert counts and exact values, never
      `all(grepl())`, numbers after `as.numeric()` (review finding 8). A test runs `janitor::make_clean_names()`
      over each layout's labels and expects the wanted names (finding 13). Prove the guards fire: restore each bug the script has fixed (the `species_code` variant, the
      `"11U"` zone, the duplicate canonical column, blank counts read as zero) and watch the test go red.
- [x] `scripts/0220` becomes a thin driver: it calls the package, and keeps the reconcile, placement, clip and writes.
      Update the `scripts/README.md` entry.
- [x] Rerun `0220` for COTR, LNTH, UNTH, UPCE and PINE, still on PINE's old layout. Every output must be byte-identical
      to the baseline run's (Phase 1), the `.gpkg` compared as content; then restore every file whose content did not
      change. Logs go to `scripts/logs/fiss/`, checked for home paths.

## Phase 3: #10, re-fetch PINE

- [x] Move `data/pine/fiss_xls/` into the scratchpad (never a sibling under `data/pine/`, which `.gitignore` does not
      cover: review finding 11), then run `WSG_TARGET=PINE FISS_FETCH=TRUE Rscript scripts/0210-fiss-xls-fetch.R`
      (77 files), then `0220` for PINE. Log both.
- [x] Read the reconcile: `manifest_urls_vs_fetch_log_urls` should replace the count-only check. The site, step2 and
      step3 tables must be byte-identical. The parse log should differ only in `path` (converted names gain the idx too); the
      fetch log gains `idx` and `xls_url` and reorders its columns; the reconcile moves in three rows (the check renamed to
      `_urls`, the `workbooks_with_no_step` note's file names, `clip_polygon_source`). Anything else, a 4xx from ACAT
      above all, stops the phase and is reported. Rollback: `git checkout` the PINE outputs and move the old folder
      back.

## Phase 4: #34, percent gradients in `0250`

- [x] Read the gradient cell's number format in every report that carries one (25; review finding 6).
- [x] Run `0250` unchanged first and diff its four tables against the tracked ones, so any drift (the database's
      placement, #91's `sites.rds`) is seen apart from #34 (finding 2).
- [x] `0250`: `gradient_pct = 100 * num(average_gradient_percent)`. A raw value above 1 cannot be a percent-formatted
      cell, so it becomes NA and is counted in the reconcile. A plausibility row compares the median ratio to
      `fwa_gradient_pct` against a band stated before the rerun.
- [x] Rerun `0250`. Diff its four tables against the unchanged run: only `gradient_pct` and the reconcile's new rows may
      move. If any other column or file moves (for
      example a placement tie on this database), stop and report it.
- [x] Record the consequence. `fiss_evidence` is a recipe input of the evidence receipt (`inst/receipt/evidence.yaml`),
      so a later `0310` rebuild compares as recipe-`different` against the published build. `knw_fiss_visits()` does not
      read `gradient_pct`, so the derived tables do not change. Grep for any reader that refuses when the tracked file's
      sha moves, and say what was found.
- [x] Update the gradient's readers: `scripts/0293`'s heading and `research/bt_spawning.md` (finding 3). `scripts/README.md`
      says the per-group tables keep the raw fraction under `average_gradient_percent`, and #248's body carries
      converting it before those layers are published (finding 4).

## Owed at the end (reported, done after merge)

- [ ] The next `/backlog-sweep` places the batch 12 issue and #245, which `/compact-prep` names.

## Validation

- [x] Tests pass (`devtools::test()`), `lintr` per file against `origin/main`, and `devtools::document()`.
      `pkgdown::check_pkgdown()` passes with the new exports in the reference index.
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [x] `/planning-archive` on completion

How each change is proved:

- **#7:** five groups byte-identical before and after, plus fixture tests that each go red against their restored bug.
- **#10:** PINE's site tables are unchanged, and its reconcile holds the URL-set check.
- **#34:** the CSV diff moves only `gradient_pct`, and the new values sit in the range of FWA's.

