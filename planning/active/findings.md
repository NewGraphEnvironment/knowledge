# Findings: Write the shared provenance receipt for published tables and grades through crate, with declared tolerances (#154)

## Issue context

**If we do it:** each table knowledge publishes, and each grade table, carries one `receipt.json`
written by crate's writer, and a rebuild of the evidence answers identical, equivalent or different
against the archived copy, with the tolerance declared beside the code that makes the table. **If we
never do:** `knw_build_record()`, the grade records and the publish manifests each keep their own
fields, and the choice of which tables must match exactly and which may differ in a rounding stays
an unwritten habit.

## Problem

knowledge already has the pieces: `knw_build_record()` reads a build's identity at connect,
`<key>_grades_record.csv` holds each grade table's md5, size, rows, run and ledger, `knw_publish()`
writes a manifest with per-file sha256, and the bucket archive keeps version ids in
`data/archive_index.csv` (#119). A rebuild of the same build's evidence once gave three
byte-identical tables and a fourth differing at 9.5e-11 km. It passed only because the build
record fingerprints the three tables that matter and ignores the fourth. That is right, and it is
written nowhere as a rule.

## Proposed

- [ ] `knw_publish()` and the grade-record writer call `crate::crt_receipt_write()` (NewGraphEnvironment/crate#43),
      handing it `recipe.inputs` from the build record (the link run, the flow table's load, the
      walk md5), `recipe.config` from the method settings plus resolved arguments, the fit's `seed`,
      and `result.parts` from today's sha256. crate computes the ids and fingerprints.
- [ ] Tolerances declared beside each table's writer, in the form `crt_receipt_keys()` reads: exact
      for the visit tables, a rounding for km sums, and for a tuned grade the invariant that must
      hold across refits.
- [ ] `inst/method/settings.csv`'s register pattern becomes the receipt fields' register: the
      comparison reads it, and a test builds two receipts differing in one field each.
- [ ] Archived copies (#119) are the reference copies a rebuild is compared against.
- [ ] Add `crate` to `Imports`, at a floor of the release that ships `crt_receipt_write()`.
- [ ] Start the tolerances from #158's measurements: it reruns the published retune on a second database and
      records, per output, identical or equivalent and by how much. A table it finds identical is declared
      exact; one it finds equivalent gets the rounding it was held to.

Relates to #119, #2, NewGraphEnvironment/crate#43, #158


(No comments on the issue at 2026-11-05.)

## Plan-mode exploration (2026-11-05)

- **crate#43 / crate PR #44** (branch `43-a-shared-provenance-receipt-a-language-n`): CI green, mergeable, merging
  as of the gate; latest release v0.11.0; installed here 0.8.0. `crt_receipt_write(dir, output, recipe, result,
  context, keys, lockfile, publish)` always writes `file.path(dir, "receipt.json")`, and `receipt_parts()` refuses a
  part outside `dir` (`..` or absolute). So the flat `data/tune/<key>_grades.csv` layout cannot carry one receipt per
  key without a `file =` argument (the gate chose to add one in crate).
- `crt_table_fingerprint()` canonicalises every cell to RFC 8785 JSON in memory: unusable on a 0.7-5.6 GB grade
  table, so grade receipts carry parts (sha256) and summary values, not a fingerprint.
- crate's default register (`inst/extdata/receipt/register.csv`) refuses on `result.parts.*.sha256` unless the
  part names a fingerprinted table whose fingerprint agrees; a declaration's `register:` may soften fields outside
  the recipe. So the grade declaration softens parts to `record` and judges on summaries.
- `crt_receipt_write()`'s `recipe$inputs` kinds: `recipe_id`, `version_id`, `sha256`, `none`. The link run uid and
  the flow table comment fit `version_id`; the evidence tables need their sha256 (only md5 is recorded today).
- `recipe$code` needs a full 40-character commit and a `dirty` flag per repo.
- knowledge writers: `knw_grade_record_write()` (`R/grade_record.R`), called by `scripts/0320-tune-run.R`'s
  `write_record()` (~line 562); `knw_publish()` (`R/publish.R`), called twice by `scripts/0325-publish.R`
  (thresholds_v1, habitat_grade_v1 hive-partitioned). Promotion `knw_tune_promote()` plans per-key files by pattern
  (`R/tune_promote.R` `plan_dir`); the archive's per-key files are `.knw_archive_tune_files()` (`R/archive.R`).
- `inst/method/settings.csv`: 69 rows, `where` kinds `fn`, `script`, `code`, `ext`, `record`
  (`R/settings_register.R`); no `.gitattributes` in the repo.
- #158 (rerun of the published retune on a second database) is open with no verdicts recorded, so tolerances are
  declared from the 9.5e-11 km precedent and revised after it (owed).

## Errors Encountered

| Error | Resolution |
|-------|------------|
