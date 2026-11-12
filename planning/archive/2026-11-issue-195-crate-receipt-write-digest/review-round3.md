# Code check, round 3: #195 branch (0bb1670a...HEAD, R tests man)

Angle: whether the branch's claims hold, and whether the guards catch a regression.

## Checklist read

- code-check-python.md: index only. The diff has no Python.
- code-check-r.md: index read. Full sections read:
  - "A `function(...)` mock hides arguments the real callee no longer accepts", because test-receipt.R:160 mocks `crt_receipt_write`.
  - "Under `R CMD check`, tests run from a temp dir against the INSTALLED package".
  - "Tests that silently do not run".
  - The other headings name tools or shapes the diff does not use, so I did not read them (about 120).
- code-check-shell.md: index only. The diff has no shell.
- code-check-spatial.md: index only. The diff has no spatial code.
- code-check.md: I read the prose of every H3 under `## Mechanisms`, skipping table rows. Those that bear on this diff:
  - "Verification that reads its own output"
  - "Restore the bug and prove the guard fires"
  - "A fix lands in one of two callers that share a harness"
  - "Serialization loses meaning silently"
  - "A fixture that cannot reach the failure mode"

  No heading under `## Rules that stand alone` applies.

## Claim 1: the value is the same on crate 0.15 and 0.16, and no caller depended on NA

- **What 0.15.1 returned.** At v0.15.1, `crt_receipt_write()` returned `invisible(receipt)`, the in-memory list from `receipt_build()`. That list differs from the file in four ways:
  - It holds `NA` where the file holds `null`.
  - Its keys are in the caller's order, not JCS order.
  - `I()` arrays are atomic vectors, not unnamed lists.
  - Its numbers are R doubles or integers as computed, not as `jsonlite::read_json()` parses them.
- **What 0.16.0 returns.** The SHA-256 of the bytes written.
- **Same value on both tags.** `crt_receipt_read.R` and `receipt_write_file()`'s serialization are unchanged between the tags. `git diff v0.15.1 v0.16.0 --stat -- R` touches only:
  - `crt_receipt_write.R`: the return value and the mapping version, which only `crt_receipt_migrate()` reads.
  - comments in `crt_receipt_compare.R`.
  - the mapping path in `crt_receipt_migrate.R`.
  - the new `crt_receipt_stac.R`.

  So the bytes on disk and the value read back are the same on both tags, and the claim holds.
- **Every field read from a writer's value.** No caller reads one whose form changed in a way that changes a result:

  | caller | field | note |
  |---|---|---|
  | scripts/0310:501 | `rcp$recipe$recipe_id` | the same string in memory and on disk |
  | data-raw/evidence_receipt_compare.R:53-54 | `unlist(gr$recipe$inputs$evidence)` and `$recipe_id` | strings |
  | test-evidence_receipt.R:36,40,41 | | `visits` is `2L` on both. `access_km` is read with `expect_equal`. |
  | test-grade_receipt.R:144 | `expect_identical(r$recipe$inputs$evidence, list(recipe_id = ...))` | a one-key named list on both |
  | test-grade_receipt.R:147 | | already reads from the file |
  | test-grade_receipt.R:178 | | already reads from the file |
  | test-archive.R:522 | | discards the value |

- **The `null` fields.** No caller reads any of them: `output$schema`, `output$scope`, `recipe$seed`, `context$session` and `context$lockfile_sha256`.

## Claim 2: the same mechanism, a caller trusting a dependency's return value

These are the remaining crate calls whose return a caller reads, in R/, scripts/, data-raw/ and tests/:

- **`crt_receipt_keys()`** (R/receipt.R:28): file unchanged between the tags.
- **`crt_receipt_read()`** (R/archive.R:222, R/tune_promote.R:159, R/evidence_receipt.R:113, scripts/0320:630, data-raw/evidence_receipt_compare.R:17-18): unchanged.
- **`crt_receipt_compare()`** (data-raw/database_receipts.R:89, data-raw/evidence_receipt_compare.R:22,25, tests): only comments changed.
- **`crt_table_fingerprint()`** (test-publish.R:75) and **`crt_receipt_validate()`** (test-grade_receipt.R:42): unchanged.
- **The other `crt_receipt_write()` callers**: none reads the return.
  - R/publish.R:205: discarded at :135, and nothing else calls `.knw_publish_receipt()`.
  - data-raw/database_receipts.R:80: returns the path.
  - test-archive.R:206,228 and test-tune_promote.R:471: values unused.
- **`crt_receipt_migrate()`**: knowledge does not call it.

None is broken under 0.16.0.

## Claim 3: would a test go red if the read-back were removed or read the wrong file?

Yes. I mutated a detached worktree of HEAD on crate 0.16.0, ran it with `NOT_CRAN=true`, and removed the worktree afterwards. The baseline was 0 failures in all three files:

| mutation | test-evidence_receipt | test-grade_receipt | test-archive |
|---|---|---|---|
| evidence writer returns `crt_receipt_write()`'s value | 3 of 6 fail | 2 of 9 fail | 0 of 22 fail |
| evidence writer reads `evidence_dir` (dir only, so `receipt.json`) | 3 of 6 fail | 4 of 9 fail | 1 of 22 fail |
| grade writer reads `dirname(grades_path)` | 0 of 6 fail | 6 of 9 fail | 0 of 22 fail |

The test helper `receipt_from()` returning the digest again would also go red: `crt_receipt_compare()` reads a character argument as a path, and no file exists at a digest.

One note that is not a finding. test-evidence_receipt.R:36 used to check crate's in-memory `recipe_id` against the file. It now compares the file with itself ("Verification that reads its own output"). That property belongs to crate and crate tests it, so nothing in knowledge is left unguarded.

## Clean
No issues found.
