## Checklist read

- code-check-python.md: in full. Nothing in the diff is Python.
- code-check-r.md (by heading): read 3. These were "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, ...", "A `function(...)` mock hides arguments the real callee no longer accepts" and "Read-back shape must match write-back shape". I did not read the other ~118.
- code-check-shell.md (by heading): read 1, "Assert capabilities, not versions — a tool upgrade can remove one silently". I did not read the other ~100.
- code-check-spatial.md (by heading): read none. Nothing in the diff is spatial; ~120 headings skipped.
- code-check.md (by heading): read the prose of all 14 Mechanisms H3s, without their table rows. I did not read the Rules-that-stand-alone, Security, or Spreadsheets and PDFs headings (~25).

## Findings

- **[severity: bug]** scripts/0320-tune-run.R:630-641, with R/grade_receipt.R:100. The kept-path receipt now names the commit the record names, but the rest of its recipe is still this pass's.
  - `.knw_receipt_config_files(c("settings", "walk"))` hashes `inst/method/settings.csv` as it is in the current tree. It never takes the `knowledge` argument into account.
  - The walk SQL is safe here: `knw_grade_receipt_write()` refuses unless `knw_walk_md5()` equals the record's `walk_md5`, so its bytes match the grading pass.
  - Nothing holds `settings.csv` to the recorded commit. This is the file that moves with code changes. Its last 8 commits include four review-round prose edits on #91 and #92, and `test-settings-register.R` makes every change to a value land there too.
  - Where the fix applies is exactly where this happens: a candidate resumed with `RUN=` after a code change. That receipt pairs `recipe.code = <old commit>` with the new `settings.csv` sha256. Its `recipe_id` then belongs to a recipe that never existed, so neither a rebuild at the old commit nor one at the new commit comes back identical.
  - The settings (`fit`, `folds`, `d_floor`, `extra`, `min_wsg`, seed) also come from this pass's `r$score$spec` and `min_wsg`. The keep check compares none of them.
  - Evidence is fine: the keep check requires `evidence_md5` to equal the run's, and the receipt re-checks it against the record.
  - Fix: hash `settings.csv` as it stood at the resolved commit (`git show <commit>:inst/method/settings.csv` into a temp file, passed as `c("inst/method/settings.csv" = tmp)`). Alternatively, write no receipt (as for an unresolvable commit) when `git diff --quiet <commit> -- inst/method/settings.csv` reports a difference.
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "Written data outlives the fix"

- **[severity: fragile]** scripts/0320-tune-run.R:234. Round 1's capability check now refuses runs that write no receipt.
  - `.knw_receipt_crate_check()` runs unconditionally at the start. `DEV=1` and `GRADIENT=fwa_gradient` both quit before grading (`if (main_only) ... quit()`, ~line 552), so they never write a receipt.
  - `DEV=1 0320` is the routine step after any upstream change, and CLAUDE.md says it runs on any machine with no database. On a machine whose crate came from crate's `main` (0.12.1, passes the `>= 0.12.0` floor, no `file =`), that run worked before this fix and now stops.
  - Fix: gate it as the grading is gated, `if (!main_only) .knw_receipt_crate_check()`. `knw_grade_receipt_write()` keeps its own check.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** scripts/0325-publish.R:125-128. The recipe's `tune_run` setting describes the tracked records, not the grade tables published.
  - `tune_run` is read from each table's tracked `<key>_grades_record.csv`. 0325 never holds a table to its record: no `knw_grade_record_check()`, not even the free size compare.
  - The grade tables are ignored. CLAUDE.md records a host whose `data/` held another promotion's files than the tracked records (2026-10-28).
  - 0325's existing checks compare rule, run_uid, evidence and gradient with the thresholds table. Two runs on one build agree on all of those, for example a regrade after a prior or gate change, which 0325 checks only by presence.
  - In that case `habitat_grade`'s receipt names the records' tuning run while its parts and summaries are the other run's grades. Before this branch 0325 never read records, so a mismatch had no effect on what it published.
  - Fix: compare each table's size with its record's `grades_bytes` before building `recipe_pub`, or run the md5 check with the others, ahead of any write.
  - **Rule:** code-check.md "One fact derived twice"

- **[severity: fragile]** R/archive.R:140-145. The archive stores a grade receipt without checking it describes the table.
  - Promotion (`R/tune_promote.R`) and 0320's keep path both refuse or rewrite a receipt whose `context$run$grades_md5` is not the record's. `knw_archive_plan()` stores whatever `<key>_grades_receipt.json` is present.
  - A candidate can hold a stale one. 0320's fresh path writes the table and record, then the receipt; if the receipt write stops (e.g. `.knw_receipt_evidence()` finds the evidence moved), the earlier pass's receipt survives because `caches` keeps it.
  - Archiving that candidate (0336 archives unpromoted runs) files the stale receipt in the same batch as the new record. `knw_archive_pull()` restores it as the key's receipt, or refuses ("is here with another md5") where a checkout holds the right one.
  - Fix: read the receipt with `crate::crt_receipt_read()` and refuse when its `grades_md5` is not `rec$grades_md5`, as promotion does.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"

## Checked and found sound (no finding)

- Fix (3): `.knw_git()` reads `attr(out, "status")` and stops. `.knw_git_state()` turns a failed `rev-parse` into "not a git checkout", and a failed `status` now raises instead of reading clean.
- Fix (2):
  - `.knw_git_state_at()` refuses NA, `"NA"` (what a failed `git1` writes), a malformed string and an ambiguous or absent short SHA. Each falls to "no receipt" plus `unlink(grcp)`.
  - The dirty flag follows "+dirty" in both directions. A clean record against a dirty current tree, and the reverse, are both resolved through `.knw_git_state_at()`, not `knowledge_git`.
  - Version from `DESCRIPTION` at the commit: crate's `receipt_code` accepts `version`.
- Fix (1): the mock in test-receipt.R replaces crate's namespace binding, which `crate::crt_receipt_write` resolves to. testthat >= 3.2.0 is declared.
- Promotion of a pre-receipt run, and of a `replaced_*` archive: the receipt check sits inside the record branch. A run without receipts is promoted as before. A tracked receipt the run no longer brings goes through `removed`.
- `knw_publish()`: on an identical republish it still uploads, and `receipt.json` goes up before the manifest. A receipt write stopping in `.knw_publish_receipt()` happens after the manifest is written locally but before any upload of that set.
