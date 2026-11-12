# Code check, round 1: #195 branch (0bb1670a...HEAD, R tests man)

## Checklist read

- code-check-python.md: index only. The diff has no Python, so no heading applies.
- code-check-r.md: index read. Headings checked against the diff: "A `function(...)` mock hides arguments the real callee no longer accepts" (test-receipt.R:160 mocks `crt_receipt_write`; it is unchanged and tests only the `file =` formal check), "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "Tests that silently do not run". The other ~110 headings name tools or shapes this diff does not use, so I did not read them.
- code-check-shell.md: index only. No shell in the diff.
- code-check-spatial.md: index only. No spatial code in the diff.
- code-check.md: read the prose of the `## Mechanisms` H3s, table rows skipped. The four that bear on this diff: "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output". "A fix lands in one of two callers that share a harness" was checked by index line against every `crt_receipt_write()` caller. None of the `## Rules that stand alone` headings applies.

## What was checked

- **Does the read-back read the file that was written?** Yes. crate 0.16.0 writes to `file.path(dir, file)` (`crt_receipt_write.R:113`, through a temp file and `file.rename()`). The evidence writer reads `file.path(evidence_dir, .knw_evidence_receipt_file)`, which is the same `dir` and `file`. The grade writer reads `file.path(dirname(grades_path), .knw_grade_receipt_name(grades_path))`, which is the same pair. The path names a file, never a directory, so `crt_receipt_read()`'s directory branch (it appends `receipt.json`) is never taken. In test-receipt.R, `receipt_from()` returns `file.path(dir, "receipt.json")`, which matches crate's default `file =`. `crt_receipt_compare()` accepts a path on both crate tags (`is.character(a)` → read).
- **Can the write succeed and the read-back throw?** `crt_receipt_read()` checks four things: the file exists, it is not empty, it parses as JSON, and `output$receipt_version` is `receipt_version()`. All four hold for a file the same loaded crate has just renamed into place. That leaves an I/O failure between the rename and the read. In 0310 that would land in the existing `tryCatch`, which writes the refused ledger and stops, with a valid receipt left beside the tables. This is not reachable in practice, so I am not reporting it.
- **Does any caller depend on the 0.15 return's form?** No:
  - 0310 reads `rcp$recipe$recipe_id`, a string either way.
  - data-raw/evidence_receipt_compare.R reads `gr$recipe$inputs$evidence` (through `unlist()`) and compares `$recipe_id` with another read-back receipt.
  - The tests read `$result$summary$visits` (2L when read back), `$access_km`, `$recipe$recipe_id` and `$recipe$inputs$evidence`, the last as a named list.
  - 0320's `write_receipt()` and the archive and promote helpers discard the value.
  - `.knw_publish_receipt()`'s value is discarded at R/publish.R:135.
  - data-raw/database_receipts.R already returns the path.
  - The read-back form is the one crate's compare documents as canonical: NULL where the in-memory list held NA.
- **Ran it:** in a detached worktree of HEAD on crate 0.16.0 with `NOT_CRAN=true`, five test files all passed with 0 failed, 0 errors and 0 skipped:

  | file | passed |
  |---|---|
  | test-receipt.R | 93 |
  | test-evidence_receipt.R | 29 |
  | test-grade_receipt.R | 50 |
  | test-archive.R | 125 |
  | test-tune_promote.R | 145 |

  The worktree was removed afterwards.

## Clean
No issues found.
