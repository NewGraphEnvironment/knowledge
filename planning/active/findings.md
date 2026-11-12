# Findings — Receipt writers break under crate 0.16.0: crt_receipt_write() now returns a digest, not the receipt (#195)

## Issue context

**What changes if we do it:** CI goes green again on every branch and on `main`, and the evidence, grade and publish receipts are written and read back as before. **If we never do:** every R-CMD-check run fails at the examples and in 9 tests, so no change to the package can be checked or released.

## Problem

crate 0.16.0 (released 2026-11-11 13:32 UTC) makes a breaking change: `crt_receipt_write()` returns the SHA-256 of the bytes it wrote, invisibly, rather than the receipt (crate's NEWS for 0.16.0, `NewGraphEnvironment/crate#60`). knowledge pins `crate (>= 0.15.0)` with no upper bound, so CI installed 0.16.0 and failed. The last green run on this code used crate 0.15.1.

Three writers return `crt_receipt_write()`'s value, and their callers read fields of it as a list:
- `knw_evidence_receipt_write()` (`R/evidence_receipt.R`)
- the grade receipt writer (`R/grade_receipt.R`)
- `knw_publish()`'s receipt (`R/publish.R`)

Under 0.16.0 the value is a character digest, so `r$result` fails with `$ operator is invalid for atomic vectors`.

Measured on R-CMD-check run 43033793129 (2026-11-12): `checking examples ... ERROR` and `[ FAIL 9 | WARN 0 | SKIP 30 | PASS 1876 ]`, all 9 in `test-evidence_receipt.R`, `test-grade_receipt.R` and `test-receipt.R`.

## Plan

- [ ] Make each writer return what callers expect: `crt_receipt_read()` of the file it just wrote. crate says that returns exactly what was written. Keep the digest where a caller wants it.
- [ ] Raise the floor to `crate (>= 0.16.0)`, or handle both return types, decided at the plan gate
- [ ] Read every caller of the three writers and the `crt_receipt_write()` calls in `tests/` and `data-raw/database_receipts.R` for a use of the return value
- [ ] Check whether a receipt read back differs from the list 0.15 returned (`NA` where the file holds `null`), and whether any comparison or test depended on the `NA`
- [ ] `devtools::check()` passes against crate 0.16.0


