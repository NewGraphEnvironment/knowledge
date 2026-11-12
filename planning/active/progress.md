# Progress — Receipt writers break under crate 0.16.0: crt_receipt_write() now returns a digest, not the receipt (#195)

## Session 2026-11-11

- Plan-mode exploration — phases approved by user
- Created branch `195-receipt-writers-break-under-crate-0-16-0` off origin/main
- Scaffolded PWF baseline from issue #195 with approved phases
- Next: start Phase 1
- Phase 1: installed crate 0.16.0 (was 0.15.1); before the fix `test-evidence_receipt.R`, `test-grade_receipt.R` and
  `test-receipt.R` each had 3 failing tests (9, as on CI run 43033793129)
- Phase 2: both writers return `crt_receipt_read()` of the file just written; `receipt_from()` returns the path. The
  three files plus `test-archive.R`, `test-tune_promote.R`, `test-publish.R` pass (0 failed of 6, 9, 11, 22, 32, 6).
  Guard: with each writer's read-back line removed in-process (namespace and `package:knowledge` both patched; patching
  the namespace alone left the attached exports unchanged and read 0 failures), the same 3 + 3 tests fail again
- Phase 3: no caller read a field that can be null; verdict per caller in findings.md
