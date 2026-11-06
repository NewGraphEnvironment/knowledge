# Task: Write the shared provenance receipt for published tables and grades through crate, with declared tolerances (#154)

knowledge already has the pieces: `knw_build_record()` reads a build's identity at connect,
`<key>_grades_record.csv` holds each grade table's md5, size, rows, run and ledger, `knw_publish()`
writes a manifest with per-file sha256, and the bucket archive keeps version ids in
`data/archive_index.csv` (#119). A rebuild of the same build's evidence once gave three
byte-identical tables and a fourth differing at 9.5e-11 km. It passed only because the build
record fingerprints the three tables that matter and ignores the fourth. That is right, and it is
written nowhere as a rule.

## Decided at the gate (Al, 2026-11-05)

- **crate:** PR #44 is merging now; knowledge pins a floor at the release that ships the receipt functions.
- **Tolerances:** declare now from what is known, revise once #158 records its per-output verdicts (owed below).
- **Grade receipt layout:** add a `file =` argument to `crt_receipt_write()` in crate (default `receipt.json`), so a
  grade table's receipt is `data/tune/<key>_grades_receipt.json`, tracked beside its record. Since #44 is merging,
  this is a follow-up crate PR, and knowledge's floor is the release that carries it.
- **Beside, not instead:** `manifest.json` and `<key>_grades_record.csv` stay, with every reader of them
  (0325, 0335, 0336, both article bundles, tests). Retiring them is a later issue.
- **No backfill:** the promoted grade tables (on the database host) get receipts at the next retune and promotion.
  Writing them now would put new tracked files in `data/tune/` without a promotion.

## Phase 1: crate's `file =` argument (crate repo)

- [ ] File a crate issue: `crt_receipt_write(file = "receipt.json")`, for producers whose outputs share a directory
      (knowledge's 22 grade tables in `data/tune/`); `crt_receipt_read()` already takes a path
- [ ] Branch in `~/Projects/repo/crate` off main once #44 has merged: the argument (a bare filename ending `.json`,
      no path separators), a test, the docs and NEWS; open the PR. Merging and releasing it needs your word
- [ ] Until it is released, knowledge's branch builds against it through `Remotes: NewGraphEnvironment/crate@<branch>`;
      knowledge's PR does not merge until the floor is a release

## Phase 2: the dependency and the declarations

- [ ] `DESCRIPTION`: `crate (>= <release with file =>)` in Imports, `NewGraphEnvironment/crate` in Remotes; install it
      (the installed copy here is 0.8.0)
- [ ] `.gitattributes`: `eol=lf` for the files a receipt hashes as config (`inst/method/*.csv`, `inst/sql/*.sql`,
      `inst/receipt/*.yaml`), since crate hashes their bytes as checked out
- [ ] `inst/receipt/{grade,thresholds,habitat_grade}.yaml`, read by `crt_receipt_keys()`: each output's recipe
      inputs, settings, config files, fingerprinted tables, summary values, tolerances and register overrides:
  - `grade`: inputs `link_build` (run uid as `version_id`), `flow` (the table comment as `version_id`),
    `visits_link`, `visits_species`, `walks` (sha256); config files `inst/method/settings.csv` and
    `inst/sql/ch_dist_profile.sql` (the walk); settings: the run's resolved `spec` (fit, prior, folds, min groups,
    d_floor, extra, gradient) and the pick (`rule`, `ref_edge`, `q_walk`); `seed: true`. No fingerprinted table
    (0.7 to 5.6 GB; canonical JSON of that many rows does not fit in memory); summary `rows`, `graded_rows`,
    `km_graded`, `grade_sum`, with a km/sum rounding; register softens `result.parts.*.{bytes,sha256}` to `record`,
    so a rebuild that sums in another order is judged on the summaries, the invariant the refit must hold
  - `thresholds`: `thresholds` and `thresholds_groups` fingerprinted, exact
  - `habitat_grade`: summary values per published set (rows, km, grade sum), parts recorded, as for `grade`
- [ ] `R/receipt.R`: `knw_receipt_keys(output)` (reads the installed declaration) and the shared pieces each writer
      needs: `recipe$code` for knowledge (full commit, version, dirty) and link (version, commit), toolchain left to
      crate
- [ ] `tests/testthat/test-receipt.R`: every declaration parses; each declared setting has its row in
      `inst/method/settings.csv` or is a run argument named in the declaration

## Phase 3: the grade table's receipt

- [ ] `knw_grade_receipt_write()` (beside `knw_grade_record_write()` in `R/grade_record.R`): from the grade table,
      the build record, the evidence directory and the run's spec, writes `<key>_grades_receipt.json` through
      `crt_receipt_write(file =, keys = knw_receipt_keys("grade"))`
- [ ] `scripts/0320-tune-run.R`: `write_record()` writes the receipt after the record (same inputs it already holds:
      `rec`, `discharge_load`, `ledger_path`, `knowledge_commit`, `link_sha`, the fold seed)
- [ ] Promotion (`knw_tune_promote()`) moves it with the key's files (check its per-key pattern takes it; add it if
      not); the archive takes it (`.knw_archive_tune_files()`), so the archived copy is the reference a rebuild is
      compared against, and `PULL=TRUE 0336` restores it
- [ ] Tests on the grade-record fixture: written, `crt_receipt_validate()` passes, compared with itself `identical`,
      a summary moved within its rounding `equivalent`, past it `different`; promotion and archive carry the file

## Phase 4: the published sets' receipts

- [ ] `knw_publish()` gains `recipe` and `keys`: writes `receipt.json` beside `manifest.json` with the tables
      fingerprinted as declared, `publish = TRUE` (no host), and uploads it before the manifest
- [ ] `scripts/0325-publish.R` passes each set's recipe from the provenance it already builds (`prov`, `prov_grade`)
- [ ] `tests/testthat/test-publish.R`: the receipt is written, its fingerprints match `crt_table_fingerprint()` of
      the source tables, and the upload order puts it before the manifest

## Phase 5: the register test, docs

- [ ] `test-receipt.R`: for every receipt field, two receipts differing only there, compared with
      `crt_receipt_compare(keys =)`; the verdict and action each must give are a table in the test, so a field with
      no row fails (the settings register's pattern, applied to receipt fields)
- [ ] `CLAUDE.md` ("A run's record travels with its table") and `research/run_archive.md`: what each receipt
      holds, which tolerances are declared and why, that they are provisional until #158
- [ ] `NEWS.md`; `lintr`, `devtools::document()`, `pkgdown::check_pkgdown()` for the new exports

## Owed at the end (reported, done after merge)

- [ ] Revise the declared tolerances from #158's per-output verdicts (identical becomes exact; equivalent gets the
      rounding it was held to), and put that task in #158's body as well
- [ ] The first grade receipts reach `data/tune/` with the next retune's promotion (no backfill)
- [ ] The first published-set receipts reach the bucket with the next `PUBLISH=TRUE 0325`

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How it is proved: fixtures run every writer and comparison in `devtools::test()`; mutation checks (restore a
missing declaration row, a tolerance, the upload order) show each new guard fails. 0320's grading and 0325 need the
database host and its grade tables, so the writers run end to end only at the next retune there. This branch says so
rather than claiming a run.
