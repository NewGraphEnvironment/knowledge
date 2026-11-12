## Outcome

crate 0.16.0 changed `crt_receipt_write()` to return the SHA-256 of the bytes written rather than the receipt
(crate#60), and knowledge's two receipt writers passed that value on, so every caller reading `$recipe` or `$result` of
it failed: R CMD check broke at the examples and in 9 tests. `knw_evidence_receipt_write()` and
`knw_grade_receipt_write()` now return `crt_receipt_read()` of the file each just wrote, and the receipt test's fixture
returns the receipt's path. The read-back does not depend on what `crt_receipt_write()` returns, so the
`crate (>= 0.15.0)` floor stays and machines still on 0.15.1 need no upgrade. `.knw_publish_receipt()` was left alone:
nothing reads its value. No caller read one of the fields that 0.15's in-memory list held as `NA` and the file holds
as `null` (verdict per caller in `findings.md`).

## Measurement

- Before: on crate 0.16.0 `test-evidence_receipt.R`, `test-grade_receipt.R` and `test-receipt.R` each failed 3 tests
  (9, as on CI run 43033793129).
- After: 0 failures in those three files on crate 0.16.0 and on 0.15.1 (scratch library). `devtools::check()` on
  0.16.0 gave 0 errors, 0 warnings and 1 NOTE (Rd example lines over 100 characters, which this branch did not touch).
  Code-check round 2's R CMD check of the built tarball reported FAIL 0, PASS 1992.
- Guard: removing either read-back turns the same 3 + 3 tests red. Round 3 also mutated the read to the directory
  alone (`receipt.json`) and to the grade table's directory: each turns tests red.
- One wrong turn: the first mutation patched only the namespace and read 0 failures. Under `load_all()` the attached
  `package:knowledge` env holds its own copies of exports, and the tests call those, so both have to be patched.

Closed by: PR (this branch), Fixes #195
