# Code check, round 2: #195 branch (0bb1670a...HEAD, R tests man), checking the package as CI checks it

## Checklist read

- code-check-python.md: read in full. The diff has no Python, so no rule applies.
- code-check-r.md: read in full under 8 headings, about 113 not read. The 8:
  - "Under `R CMD check`, tests run from a temp dir against the INSTALLED package"
  - "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared"
  - "Tests that silently do not run"
  - "A `function(...)` mock hides arguments the real callee no longer accepts"
  - "Two repos pinning the same remote at different tags is an unsolvable install"
  - "Reproducibility"
  - "Inserting a helper between a roxygen block and its function rebinds `@export`"
  - "pak Behavior"
- code-check-shell.md: index only. No shell in the diff.
- code-check-spatial.md: index only. No spatial code in the diff.
- code-check.md: read the prose of all 14 H3s under `## Mechanisms`, table rows skipped. None of the `## Rules that stand alone` headings applies.

## What was checked (round 1's ground not repeated)

- **The man/ pages match roxygen.** I ran `devtools::document()` in a detached worktree of HEAD (5fa66202) on crate 0.16.0. It printed no Writing or Deleting lines, and `git status` was clean afterwards. So `man/knw_evidence_receipt_write.Rd`, `man/knw_grade_receipt_write.Rd` and NAMESPACE are exactly what roxygen writes from the source. The new `\link[crate:crt_receipt_read]` target is present in crate's `man/` at v0.15.0, v0.15.1, v0.16.0 and origin/main, and `crt_receipt_read` is exported at all four. So the floor `crate (>= 0.15.0)` has both functions the writers now call.
- **The package passes R CMD check installed, from a temp directory.** I ran `R CMD build` from the worktree, then `NOT_CRAN=true R CMD check --no-manual --ignore-vignettes` on the tarball (knowledge 0.4.35, crate 0.16.0, R 4.5.2): Status OK.
  - The examples ran against the installed package. The evidence example printed `r$result$summary$visits` as `2` and a 64-hex `r$recipe$recipe_id`; the grade example printed `r$result$summary$km_graded` as `0.42`.
  - Tests: FAIL 0, WARN 0, SKIP 22, PASS 1992. Every skip is a source-tree or database guard unrelated to receipts (`data/`, `scripts/`, "not a checkout", a missing schema). No test in test-evidence_receipt.R or test-grade_receipt.R skipped, and none of test-receipt.R's comparison tests did.
  - The tarball carries no `.git`, `planning/` or `data/`.
- **`receipt_from()` now returns a path, and the files outlive it.** The temp directory comes from `withr::local_tempdir()`, forced as a promise, so it is tied to the caller's frame (`compare_of()` or the `test_that` block). The receipt file therefore still exists when `crt_receipt_compare()` reads it there. The passing comparison tests under check confirm this.
- **No caller was missed.** I grepped R/, scripts/, data-raw/, vignettes/, inst/ and tests/ for `crt_receipt_write` and for the two writers. Callers that use the value:
  - 0310: `rcp$recipe$recipe_id`
  - data-raw/evidence_receipt_compare.R: `gr$recipe$inputs$evidence`
  - the tests

  Callers that discard it:
  - `R/publish.R:205` (`.knw_publish_receipt()`, as accepted)
  - 0320's `write_receipt()`
  - test-archive.R:206 and :228
  - test-tune_promote.R:471

  `data-raw/database_receipts.R:80` already returns `file.path(dd, "receipt.json")`. Nothing in vignettes/ or inst/ calls either function.
- **crate's main past v0.16.0 changes no code.** `git log v0.16.0..origin/main` (fetched) holds two commits: a CITATION.cff auto-update and a script in a planning archive (`mutate.py`). There are no R/ or NAMESPACE changes, and crate has no open PRs. One open issue, `crate#62` (form v1.1.0), would change `crt_receipt_read()`, but it is designed to keep reading v1.0.0 receipts and nothing has landed yet. It is not a defect of this branch.

The worktree was removed afterwards (`git worktree remove --force`). The check's build directory is in the session scratchpad.

## Clean
No issues found.
