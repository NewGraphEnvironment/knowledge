# Plan review — #195 (Plan agent, 2026-11-12, code read only)

Verdict: sound, no blocker; Phase 2 covers all 9 failing tests and both examples.

- **A1/A2 (Assumption):** read back the exact file each writer names (`.knw_grade_receipt_name()`,
  `.knw_evidence_receipt_file`): `crt_receipt_read(<dir>)` reads `<dir>/receipt.json`. Already so in 7e4652c5.
- **A3:** `receipt_from()` returns `file.path(dir, "receipt.json")`, as `data-raw/database_receipts.R:86` does. Done.
- **A4:** the plan's "this machine had crate 0.15.1" was true at plan time; Phase 1 installed 0.16.0.
- **Gap (caller table):** add `evidence_receipt_of()` (`test-archive.R:516`, value ignored) and `evidence_receipt_fx()`
  (`test-grade_receipt.R:131`, value used at :144-151, :168-178). Neither changes the fix: both pass.
- **Check 2 (read-back vs 0.15 list):** no assertion depends on the difference; JSON `2` reads back as `2L`; compare
  handles NA/NULL and integer/double itself. Matches Phase 3's verdict.
- **Check 4:** nothing else in crate 0.16.0 touches knowledge (`git diff v0.15.1 v0.16.0 -- R/`: compare and migrate
  changes are docs only; `crt_receipt_stac()` and mapping v1.1.0 are new; register stays v1.0.0).
- **Acceptance gap:** keeping the floor at 0.15.0 rested on reasoning. Taken: the three receipt test files run against
  crate 0.15.1 in a scratch library, 0 failures (progress.md).
- **Ordering/Scope:** NEWS and the version bump are `/gh-pr-merge`'s release commit (`aa0a3d58` "Release v0.4.35"
  touched only DESCRIPTION and NEWS; #182's fix `2c338004` carried no NEWS). Taken: the NEWS step is dropped from the
  branch and its line goes to `/gh-pr-merge`.
- **Scope (minor):** findings.md's issue-context copy lists `knw_publish()` among writers whose callers read the value;
  it is the issue body verbatim, corrected in the note below it.
