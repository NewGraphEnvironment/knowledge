# Task: Receipt writers break under crate 0.16.0: crt_receipt_write() now returns a digest, not the receipt (#195)

crate 0.16.0 (released 2026-11-11 13:32 UTC) makes a breaking change: `crt_receipt_write()` returns the SHA-256 of the
bytes it wrote, invisibly, rather than the receipt (crate's NEWS for 0.16.0, `NewGraphEnvironment/crate#60`). knowledge
pins `crate (>= 0.15.0)` with no upper bound, so CI installed 0.16.0 and failed: `checking examples ... ERROR` and
`[ FAIL 9 | WARN 0 | SKIP 30 | PASS 1876 ]`, all 9 in `test-evidence_receipt.R`, `test-grade_receipt.R` and
`test-receipt.R` (run 43033793129). This machine had crate 0.15.1 at plan time.

## Callers of the return value (exploration, 2026-11-11)

| writer | callers that read its value |
|---|---|
| `knw_evidence_receipt_write()` (`R/evidence_receipt.R:66`) | `scripts/0310-evidence-build.R:501` (`rcp$recipe$recipe_id`); `test-evidence_receipt.R`; `test-grade_receipt.R` (`ev_r$recipe$recipe_id`) |
| `knw_grade_receipt_write()` (`R/grade_receipt.R:100`) | `test-grade_receipt.R`; `data-raw/evidence_receipt_compare.R:53`; `scripts/0320` ignores it |
| `.knw_publish_receipt()` (`R/publish.R:205`) | none: `knw_publish()` discards it |
| `crt_receipt_write()` direct in tests | `test-receipt.R:56` `receipt_from()` into `crt_receipt_compare()`; `test-tune_promote.R:471`, `test-archive.R:206,228`, `data-raw/database_receipts.R:80` ignore it |

## Decided at the gate

Approved by Al at the plan gate, 2026-11-11:
- Keep the floor at `crate (>= 0.15.0)`, no version branch: the writers read the file back with `crt_receipt_read()`,
  which behaves the same on 0.15 and 0.16, so machines still on 0.15.1 keep working.
- The digest is not kept: no caller wants it today.
- `.knw_publish_receipt()` is left as is: nothing reads its value.

## Phase 1: Reproduce on crate 0.16.0
- [ ] Install crate 0.16.0 (`pak::pak("NewGraphEnvironment/crate@v0.16.0")`); run the three receipt test files and
      confirm the 9 failures and the example error before any change

## Phase 2: Writers return the receipt as read back
- [ ] `knw_evidence_receipt_write()` and `knw_grade_receipt_write()`: write, then `invisible(crate::crt_receipt_read(<path>))`
      of the file just written
- [ ] roxygen `@return`: the receipt as read back from the file written, invisibly; `devtools::document()`
- [ ] `tests/testthat/test-receipt.R` `receipt_from()`: return the receipt's path, not `crt_receipt_write()`'s value

## Phase 3: The NA-to-null difference
- [ ] Check each caller and test that read a field of the returned list for one 0.15 gave as `NA` (a `null` in the file,
      now `NULL`): `0310:501`, `data-raw/evidence_receipt_compare.R`, the `expect_*` on `r$…` in the two receipt tests.
      Fix any that depended on the `NA`; record the verdict per caller in findings.md

## Phase 4: Check and release
- [ ] `devtools::test()` and `devtools::check()` pass on crate 0.16.0 (examples included); lintr per file unchanged
- [ ] NEWS entry (0.4.36): writers read their receipt back, works with crate 0.15 and 0.16
- [ ] `/code-check branch`, `/planning-archive`, `/gh-pr-push`

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: Phase 1's failing run is the before; after Phase 2 the same three files and full `devtools::check()` pass
on 0.16.0. Guard check: with the read-back reverted in one writer, its test file fails again (restore the bug). CI's
R-CMD-check on the PR is the final proof, since CI installs 0.16.0.
