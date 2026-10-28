# Review round 1 (#110, branch diff, planning/ excluded)

## Checklist read

- code-check-python.md (7,237 B): in full.
- code-check.md (330,698 B): the prose of all 14 H3s under `## Mechanisms` (table rows and evidence blocks skipped). I read none of the 32 H3s under "Rules that stand alone", Security or Spreadsheets and PDFs. Their index lines name nothing this diff uses.
- code-check-r.md (178,405 B), 15 of 111 H3s:
  - "`on.exit()` at a script's top level never fires"
  - "Tests that silently do not run"
  - "testthat counts an uncaught error under `error`, not `failed`"
  - "A `skip_if_not()` skips only its own `test_that()` block"
  - "`expect_gt()` and friends take no `info` argument"
  - "A database driver's value is not a base R type"
  - "Inserting a helper between a roxygen block and its function rebinds `@export`"
  - "Under `R CMD check`, tests run from a temp dir against the INSTALLED package"
  - "`tryCatch(warning = )` DISCARDS the value"
  - "`tolerance` in testthat is RELATIVE"
  - "`[[` on a named ATOMIC vector with an absent key is an error"
  - "Rscript reads a script as it runs"
  - "A `pkg::` call in a test … undeclared"
  - "A `function(...)` mock hides arguments"
  - "`tryCatch()` nests its handlers"

  The other 96 I did not read.
- code-check-shell.md (125,440 B): 0 of 67 H3s. The diff has no shell code.
- code-check-spatial.md (155,517 B): 0 of 93 H3s. The diff has no spatial code.

## What I ran (in a `git archive HEAD` copy under the scratchpad, never the checkout)

- `test_file()` on `test-db_latency.R`: 4 blocks, 0 failed, 0 error, 15 passed. The live block ran: `SELECT 1` only.
- `test_file()` on `test-compare_rules.R`: 6 blocks, 0 failed, 0 error, 35 passed.
- `test_file()` on `test-settings-register.R`: 0 failed, 272 passed.
- `roxygen2::roxygenise()` in the copy: `man/` and `NAMESPACE` are byte-identical to the branch's.
- `tools:::.check_packages_used_in_tests()`: empty. `pkgdown::check_pkgdown()`: no problems.
- Checked `.knw_remote_cost` against the logs it cites. Host: classify 115.2 min, rest 163.0 − 115.2 = 47.8 min, GeoPackages 14.0 min (`20261026_compare.txt`, `-gpkg.txt`). Remote: classify 164.3 min, rest 269.1 − 164.3 = 104.8 min, GeoPackages 196.9 min (`20261027_compare.txt`). Every value matches the table.
- Every reader of the evidence ledger (0320, 0325, 0330, `vignette_method.R`, `snap_limit_sensitivity.R`, `segment_gradient_check.R`) lists `_evidence_build_ledger\.csv$`, so `_evidence_build_refused.csv` is never picked up. The new info rows do not enter 0310's drop/kept partition sum, nor `vignette_method.R`'s `ln()` lookups.
- `knw_compare_rules()` callers: 0330 and 0322. Neither iterates the returned list's elements, so the added `timing` element and log lines break nothing. The timer's ticks cover `scratch_setup` through `scratch_drop` with no early return between them. The untimed remainder is the local preamble and the CH_rear wetland sum, which take seconds.

## Findings

- **[severity: fragile]** `scripts/0330-compare.R:156-159` and `scripts/0320-tune-run.R:142-143` (through `fail()`, line 112): when the round-trip check refuses a run, it writes `log_lines` to `path_log`. That is the same `<date>_compare[-stage].txt` or `<date>_tune_run[...].txt` a completed run of the same mode on the same day wrote, so the refusal replaces that log with a few header lines. Example: a remote run started earlier today with `REMOTE=TRUE`, then the same command repeated without it. An uncommitted run log, the kind `.knw_remote_cost` cites as evidence, is lost. The pattern is not new: the `knw_build_record()` refusal at 0330:162-166 does the same. But that one fires only on a schema built by another run, while the latency check fires on every run off the host that does not set `REMOTE`. 0310 avoided this for its ledger with `_refused.csv`; 0320 and 0330 could do the same, or write the refusal under a `-refused` suffix. This is minor: it needs a same-day, same-mode rerun.

Nothing else found. The guard fails toward stopping: any `REMOTE` value other than `1`/`TRUE`/`true` refuses, and a query error inside the check stops the run. In 0310 the handler's `add()`/`<<-` and `write_csv(ledger)` resolve to the global ledger. 0320's check is reached only when neither `DEV=1` nor `GRADIENT=fwa_gradient` is set (`main_only` is defined at line 96, before its use).
