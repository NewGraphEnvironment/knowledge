# Task: Write the shared provenance receipt for published tables and grades through crate, with declared tolerances (#154)

knowledge already has the pieces: `knw_build_record()` reads a build's identity at connect,
`<key>_grades_record.csv` holds each grade table's md5, size, rows, run and ledger, `knw_publish()`
writes a manifest with per-file sha256, and the bucket archive keeps version ids in
`data/archive_index.csv` (#119). A rebuild of the same build's evidence once gave three
byte-identical tables and a fourth differing at 9.5e-11 km. It passed only because the build
record fingerprints the three tables that matter and ignores the fourth. That is right, and it is
written nowhere as a rule.

## Decided at the gate (Al, 2026-11-05)

- **crate:** PR #44 is merging now (merged 2026-11-06, v0.12.0); knowledge pins a floor at the release that ships
  the receipt functions with `file =`.
- **Tolerances:** declare now from what is known, revise once #158 records its per-output verdicts (owed below).
- **Grade receipt layout:** add a `file =` argument to `crt_receipt_write()` in crate (default `receipt.json`), so a
  grade table's receipt is `data/tune/<key>_grades_receipt.json`, tracked beside its record. Since #44 is merging,
  this is a follow-up crate PR, and knowledge's floor is the release that carries it.
- **Beside, not instead:** `manifest.json` and `<key>_grades_record.csv` stay, with every reader of them
  (0325, 0335, 0336, both article bundles, tests). Retiring them is a later issue.
- **No backfill:** the promoted grade tables (on the database host) get receipts at the next retune and promotion.
  Writing them now would put new tracked files in `data/tune/` without a promotion.

## Phase 1: crate's `file =` argument (crate repo)

- [x] File a crate issue (NewGraphEnvironment/crate#47): `crt_receipt_write(file = "receipt.json")`, for producers whose outputs share a directory
      (knowledge's grade tables, 7 promoted today, flat in `data/tune/`); `crt_receipt_read()` already takes a path
- [ ] Branch in `~/Projects/repo/crate` off main once #44 has merged: the argument (a bare filename ending `.json`,
      no path separators, refused where it resolves to a file the receipt hashes), a test and the docs (NEWS is the
      release step's); `/code-check`, open the PR. Merging and releasing it needs your word
- [ ] Until it is released, knowledge's branch builds against it through `Remotes: NewGraphEnvironment/crate@<branch>`;
      knowledge's PR does not merge until the floor is a release

## Phase 2: the dependency and the declarations

- [ ] `DESCRIPTION`: `crate (>= <release with file =>)` in Imports, `NewGraphEnvironment/crate` in Remotes (the
      branch until released); `jsonvalidate` in Suggests (crate's validator needs it)
- [ ] `.gitattributes`: `eol=lf` for the files a receipt hashes as config (`inst/method/*.csv`, `inst/sql/*.sql`),
      since crate hashes their bytes as checked out
- [ ] `inst/receipt/{grade,thresholds,habitat_grade}.yaml`, read by `crt_receipt_keys()`: each output's recipe
      inputs, settings, config files, fingerprinted tables, summary values, tolerances and register overrides:
  - `grade`: inputs `link_build` (run uid as `version_id`), `flow` (the table comment as `version_id`),
    `visits_link`, `visits_species`, `walks` (sha256); config files `inst/method/settings.csv` and
    `inst/sql/ch_dist_profile.sql` (the walk); settings: the key and the run's resolved `spec` (fit, prior, folds,
    min groups, d_floor, extra, gradient); `seed: true`. A small fingerprinted `pick` table (rule, reference edges,
    walk river size, the gate's verdict and number); the grade table itself is not fingerprinted (0.7 to 5.6 GB;
    canonical JSON of that many rows does not fit in memory); summary `rows`, `graded_rows`, `km_graded`,
    `grade_sum`, with a km/sum rounding (crate's tolerances are absolute); register sets
    `result.parts.*.{bytes,sha256}` to `warn`, so a rebuild that sums in another order is judged on the pick and the
    summaries and its moved bytes are listed. link enters as its build (`link_build`), not `recipe.code`: the ledger
    has no dirty flag for it (review B2)
  - `thresholds`: `thresholds` and `thresholds_groups` fingerprinted, exact
  - `habitat_grade`: summary values per published set (rows, km, grade sum), parts warned, as for `grade`
  - both published sets: inputs `link_build`, `flow`, `evidence` (the grades' `evidence_md5` as `version_id`: 0325
    holds no evidence files), setting `tune_run`
- [ ] `R/receipt.R`: `knw_receipt_keys(output)` (reads the installed declaration) and the shared pieces each writer
      needs: knowledge's full commit and dirty flag (`.knw_git_state()`, 0320's dirty scope), named config files, a
      non-finite setting as a string, the evidence tables' sha256 checked against the recorded md5s
- [ ] `tests/testthat/test-receipt.R`: every declaration parses and names its output; every config file it declares
      is installed

## Phase 3: the grade table's receipt

- [ ] `knw_grade_receipt_write()` (`R/grade_receipt.R`, one function one file): from the grade table as written, its
      record, the evidence directory and the run's spec, writes `<key>_grades_receipt.json` through
      `crt_receipt_write(file =, keys = knw_receipt_keys("grade"), publish = TRUE)`; refuses a table, evidence or
      walk that is not the record's; carries the record's `grades_md5` in its context
- [ ] `scripts/0320-tune-run.R`: the full commit read at the start beside `knowledge_commit`; the written grades
      frame built once and passed to the receipt after the record; the receipt in `caches` and in the unfit unlink;
      the keep path keeps a receipt naming the checked record's md5 and writes one from the table's two columns
      when missing (review G1, G2)
- [ ] Promotion (`knw_tune_promote()`) moves it with the key's files (its `^<key>_` pattern takes it) and checks a
      present receipt names the record's `grades_md5`; the archive takes it when present, appended last
      (`.knw_archive_tune_files()`, review G5), so the archived copy is the reference a rebuild is compared against,
      and `PULL=TRUE 0336` restores it
- [ ] Tests on the grade-record fixture: written, `crt_receipt_validate()` passes, compared with itself `identical`,
      a summary moved within its rounding `equivalent`, past it `different`; promotion and archive carry the file

## Phase 4: the published sets' receipts

- [ ] `knw_publish()` gains `recipe` and `keys` (default `NULL`: no receipt, callers and the example unchanged):
      writes `receipt.json` beside `manifest.json` with the tables fingerprinted as declared, `publish = TRUE` (no
      host), and uploads it before the manifest, its `aws` calls routed through `.knw_aws()` so the order is
      testable (review G7)
- [ ] `scripts/0325-publish.R` passes each set's recipe from the provenance it already builds (`prov`, `prov_grade`)
- [ ] `tests/testthat/test-publish.R`: the receipt is written, its fingerprints match `crt_table_fingerprint()` of
      the source tables, and the upload order puts it before the manifest

## Phase 5: the register test, docs

- [ ] `test-receipt.R`: knowledge's own register overrides and tolerances, per declaration: each override names a
      field of crate's register, and for each tolerance a receipt pair moved within it is `equivalent` and past it
      `different`, so a declaration change that no test exercises fails (crate tests every field of its own
      register; review S1)
- [ ] `CLAUDE.md` ("A run's record travels with its table") and `research/run_archive.md`: what each receipt
      holds, which tolerances are declared and why, that they are provisional until #158, that a revision makes
      earlier receipts compare `different` unless a `keys` override softens the tolerance fields, and that for a
      grade `identical` means the pick and summaries agree, its bytes listed when they move
- [ ] File the follow-up for the outputs this branch does not cover (review S2): 0310's evidence build (the
      9.5e-11 km `access_check` case) and 0299's published visit tables; name it in the PR
- [ ] `NEWS.md`; `lintr`, `devtools::document()`, `pkgdown::check_pkgdown()` for the new exports

## Owed at the end (reported, done after merge)

- [ ] Revise the declared tolerances from #158's per-output verdicts (identical becomes exact; equivalent gets the
      rounding it was held to), and put that task in #158's body as well
- [ ] The first grade receipts reach `data/tune/` with the next retune's promotion (no backfill)
- [ ] The first published-set receipts reach the bucket with the next `PUBLISH=TRUE 0325`
- [ ] The database host needs crate at the floor (with `file =`) installed before the next 0320

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How it is proved: fixtures run every writer and comparison in `devtools::test()`; mutation checks (restore a
missing declaration row, a tolerance, the upload order) show each new guard fails. 0320's grading and 0325 need the
database host and its grade tables, so the writers run end to end only at the next retune there. This branch says so
rather than claiming a run.
