# Task: Write receipts for the evidence build and the published visit tables, with access_check's rounding declared (#160)

## Problem

#154 gave crate receipts to the grade tables (`0320`) and the sets `knw_publish()` writes (`0325`). The evidence
build (`0310`) and the published visit set (`0299`, `knowledge/fdis/v<n>`) still have none. The rule the provenance
track began from has never been written down: the visit tables must match exactly, while `access_check`'s km may
differ by a rounding (9.5e-11 km in the first rebuild, 6.0e-11 km in #158's second database). And a grade receipt names
the evidence by the three tables' sha256, so an evidence rebuild that came out equivalent but not byte-identical counts
as another recipe for every grade downstream. The issue has no comments.

## Decided at the gate (Al, 2026-11-06)

- **A grade receipt names the evidence as one input, `evidence`**: the evidence receipt's `recipe_id` where one exists,
  otherwise `version_id = evidence_md5` (the form `0325`'s sets already use). `grade.yaml`'s inputs become
  `[link_build, flow, evidence]`. Receipts written before this keep their three-table shape. A rebuild compared against
  them already reads `different` on the recipe, because knowledge's commit is part of every recipe.
- **`visits_link` is declared exact now.** Until #161 lands, a rebuild reads `different`, and that is true. #161's body
  gains a line saying its fix is what turns the evidence verdict `identical`.
- **The evidence receipt is archived with its evidence build**: `knw_archive_plan()` stores it under `evidence/<id>/`
  where one exists. A build without one archives under the id it has now.
- (Agent, on the evidence; stated here, not asked.) **`access_check`'s km gets a rounding of `1.0e-6` km (1 mm).**
  Each value is a sum over up to millions of segments that a database may take in another order; the measured moves
  were 9.5e-11 and 6.0e-11 km (the plan review corrected an earlier "one ulp" reading, which held only for the
  pre-#120 province-wide table). 1e-6 is the tolerance #158's hand comparison used, and is far below anything a
  reader could see. It stays provisional, as
  #154's declarations are.
- (Agent.) Every other table `0310` writes (`bcfishobs_fdis_match`, `workbook_sites`, `workbook_species`) is
  fingerprinted exact as well. All of them came back value-identical in #158. A part that names no table would compare
  `different` whenever its bytes moved; `workbook_sites`' bytes did move while its values held.
- (Agent.) `0299` writes its receipt through `knw_publish(receipt =)` and drops its own copy of the manifest and upload
  code. The receipt covers v3 only: v2 is published and frozen, and its tables differ from v3's. `PULL`, the
  `access_check` guard and the README upload stay in `0299`.
- **Declined:** naming the evidence by `recipe_id` in `0325`'s published sets. `0325` reads grade tables, not the
  evidence directory, and the issue scopes the change to grade receipts. `0325` keeps naming it by `version_id = evidence_md5`.

## Phase 1: Declarations and one table reader

- [x] `inst/receipt/evidence.yaml`, with output `evidence`:
  - config files: `inst/method/settings.csv` and `inst/sql/ch_dist_profile.sql` (the walk).
  - settings: `species`, `q_grid`, `sources`, `snap_limit_m`, `snap_limit_code_m` (the placement limits from
    0230's reconcile.csv) and `parent` (which parent source was used, or `none`).
  - inputs:
    - `link_build` (the run uid) and `flow` (the table comment);
    - `link_configs` (the installed link's version and commit, which decide range and pooling);
    - `fdis_export` (sha256 of `data/fdis/MANIFEST.md5`) and `fdis_sites`, `fdis_catch`, `fdis_fish` (sha256 of 0230's
      rds files);
    - `fdis_species_codes`, `fdis_size_breaks`, `fiss_evidence` and `fiss_workbooks` (sha256 of the tracked data
      files; the five workbooks through a manifest text);
    - `hydrologic_zones` (sha256 of the downloaded zip) and `bcfishobs` (`none`: read live from the database).
  - seed: false.
  - tables: all seven exact, except `access_check` with `km: 1.0e-6`.
  - summary: `visits` (rows of visits_link) and `access_km` (`1.0e-3`).
- [x] `inst/receipt/fdis.yaml`, the published visit set v3: settings `[version]`, inputs `[evidence, fdis_export]`,
  every one of its 11 tables fingerprinted, with `access_check.km` at `1.0e-6`, and summary `rows`.
- [x] `inst/receipt/grade.yaml`: the inputs become `[link_build, flow, evidence]`, and the header says why.
- [x] `R/receipt.R`: a shared `.knw_receipt_csv_tables(sources, keys)` that reads each fingerprinted CSV as text
  (`na.strings = ""`) and converts to numbers only the columns the declaration gives a tolerance. `knw_publish()`'s
  `.knw_publish_receipt()` switches to it, which is the only change to `0325`'s receipts (they declare no table
  tolerance, so they are unaffected).
- [x] `tests/testthat/test-receipt.R`: the list of declarations, the config-file loop and the tolerance pins grow to
  cover `evidence` and `fdis`. The existing within/past test holds each new rounding, and a helper test shows a
  tolerance column read as a number and every other column kept as text.

## Phase 2: The evidence receipt, written by 0310

- [x] `R/evidence_receipt.R`: `knw_evidence_receipt_write(evidence_dir, recipe, knowledge)` (exported, with a runnable
  example) writes `evidence_receipt.json` in the evidence directory. Its parts are the seven tables, each named by its
  table. It checks that every declared table exists, writes no host (`publish = TRUE`) and reads the tables through
  `.knw_receipt_csv_tables()`.
- [x] `scripts/0310`:
  - at the start: `.knw_receipt_crate_check()` and `.knw_git_state()`, run before minutes of work;
  - before writing: unlink any receipt left by an earlier pass, so a pass that stops leaves no stale one;
  - after the tables and before the ledger: write the receipt, then add a ledger row naming its `recipe_id`;
  - the header's OUTPUT and DESIGN notes say so.
- [x] `tests/testthat/test-evidence_receipt.R`: fixture tables round-trip, a missing table is refused, and an
  `access_check` km moved by 1e-9 between two receipts is `equivalent` while one moved by 1e-3 is `different`.

## Phase 3: Grade receipts name the evidence by its recipe

- [x] `.knw_receipt_evidence()` keeps its md5 check against the record. It then returns
  `evidence = list(recipe_id = …)` when `evidence_receipt.json` is present and its parts' sha256 for the three visit
  tables match the files', and `list(version_id = evidence_md5)` when there is no receipt. A receipt present that
  describes other tables is refused, never passed over. The context keeps `evidence_md5`.
- [x] `knw_grade_receipt_write()`'s docs, plus `tests/testthat/test-grade_receipt.R`: one test for each of the three
  cases above, and the existing input assertions updated.

## Phase 4: 0299 publishes through knw_publish(receipt =)

- [x] `scripts/0299`: keep `PULL`, the `access_check` guard, the clean-tree rule for `PUBLISH` and the README upload.
  The manifest, the Parquet check and the upload move to `knw_publish()`. For v3 it passes
  `receipt = list(output = "fdis", recipe = …, summary = …)`, whose recipe names the evidence by its receipt's
  `recipe_id`, read from `data/fdis/derived/evidence_receipt.json`. v3 refuses to publish without that receipt; v2 is
  published with no receipt.
- [x] `tests/testthat/test-publish.R`: a fixture set held to `fdis.yaml` writes `receipt.json`. `access_check` km
  read as a number is `equivalent` within 1e-6.

## Phase 5: The archive keeps the evidence receipt

- [x] `R/archive.R`: `knw_archive_plan()` adds `evidence_receipt.json` to the evidence files and the MANIFEST where it
  exists. A restore brings it back through the index, as it does the other files.
- [x] `tests/testthat/test-archive.R`: the receipt is archived and restored when present, and a build without one
  keeps its row count (11) and its id.

## Phase 6: Documentation and the owed issue line

- [x] `CLAUDE.md`'s receipt paragraph (under "A run's record travels with its table"): the evidence build's receipt
  and its declaration, the grade's `evidence` input, `0299`'s receipt, and that the archive keeps the evidence receipt.
- [ ] `research/run_archive.md`, "The receipt says whether a rebuild came out the same": the rounding and why it is
  1e-6, `visits_link` exact pending #161, and phase 7's verdict.
- [x] #161's body gets a task: its fix is what makes the evidence receipt's `visits_link` compare `identical`.

## Phase 7: Verify on the database's host

- [ ] On the host that holds the published build (m4 or m1), with the branch checked out and `pg_stat_activity`
  quiet: run two `0310` builds into tagged directories (`EVIDENCE_DIR=data/fdis/derived_receipt_a` and `_b`), so the
  default directory and its ledger are untouched. The walks are cached, so the second run is the faster one. Then
  compare: `crate::crt_receipt_compare(a, b, tables = <both re-read>, keys = knw_receipt_keys("evidence"))`. Expected:
  the same recipe, with `identical` or `equivalent` (`access_check`), and `different` only if #161's tie fires on
  `visits_link`.
- [ ] Write a grade receipt in a scratch directory against build `a` and check that its `evidence` input is build
  `a`'s `recipe_id`.
- [ ] Commit the log under `scripts/logs/habitat/evidence_receipt_160/`, and the verdict in research and the archive
  README.

## Owed at the end (reported, done after merge)

- [ ] #161's fix turns the evidence receipt's `visits_link` verdict `identical`: rerun the phase 7 comparison once it lands (written into #161's body in phase 6)

## Validation

- [ ] Tests pass (`devtools::test()`), including `test-vignette-data.R`, untouched
- [ ] `lintr::lint_package()`, `devtools::document()`, and `pkgdown::check_pkgdown()` for the new export
- [ ] `/code-check` clean, once over the branch with `/code-check branch`
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:

- **Declarations:** each declared rounding holds a value moved within it and refuses one moved past it, and every
  declared value is pinned (`test-receipt.R`).
- **Writer and guards:** each refusal is pinned by a test that also runs with its guard removed, and is seen to
  go red then.
- **End to end:** phase 7's two real builds and the verdict of their comparison.

