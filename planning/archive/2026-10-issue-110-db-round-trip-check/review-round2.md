# Code-check round 2, #110 (branch 110-check-the-database-s-round-trip-before-a, HEAD 3043680)

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check-r.md: read the sections "`on.exit()` at a script's top level never fires", "Tests that silently do not run",
  "testthat counts an uncaught error under `error`, not `failed`", "A `skip_if_not()` skips only its own `test_that()` block",
  "`expect_gt()` and friends take no `info` argument", "`$` on a list partial-matches", "Under `R CMD check`, tests run from a
  temp dir against the INSTALLED package", "`tolerance` in testthat is RELATIVE", "`[[` on a named ATOMIC vector with an absent
  key", "Rscript reads a script as it runs", "A `pkg::` call in a test passes `devtools::test()`...", "A `function(...)` mock
  hides arguments", "`expect_message(regexp = \"...$\")` never matches", "`load_all()` refuses an installed dependency...",
  "`tryCatch()` nests its handlers" (15 sections); the other ~90 not read (no tool or shape in the diff).
- code-check-shell.md: index only; no shell, sed, git or gh code in the diff (0 sections read).
- code-check-spatial.md: index only; no spatial code in the diff (0 sections read).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (tables and evidence blocks skipped); no "Rules that stand
  alone" sections read.

## What was checked

- The round-1 fix (refused 0310/0320/0330 runs write `<date>_evidence_build_refused.csv`, `<date>_tune_refused.txt`,
  `<date>_compare_refused.txt`): every reader's glob in scripts/, data-raw/, R/, tests/ and vignettes/ was enumerated
  (`_evidence_build_ledger\.csv$` in 0320, 0325, 0330, vignette_method.R, snap_limit_sensitivity.R,
  segment_gradient_check.R; `_tune_run.*\.txt$` in 0325 and vignette_chinook.R); none matches a refused name. No reader
  globs `_compare*.txt`. The refused paths are written by the handler only; `path_ledger` / `path_log` are not touched on
  the latency refusal in any of the three scripts.
- 0310 handler: `add()` assigns the global `ledger` via `<<-`, so the refused ledger carries the settle rows plus the two
  new rows; the new success rows are `kind = "info"` and do not enter the drop/kept partition sum (line 324). Readers read
  the ledger as character and look up fixed `step` names, so a fractional `n` (the round trip) breaks nothing.
- 0320: the check runs only when `!dev && !main_only`, matching the header, README and CLAUDE.md; grading is gated on the
  same `main_only` (line 325).
- 0330: the check sits before the `STAGE` branches (line 287), so every STAGE runs it, as documented.
- `knw_compare_rules()`: `t0` removed with no remaining use; `tm$tick("classify_overlay_connect")` measures from the
  scratch_setup tick, which is where the old `t0` was taken; the timer is not used in `.knw_compare_bin()` (the
  no-package-names test still passes). The extra `timing` element and log lines are not compared by any consumer
  (0322 and data-raw/compare_parallel_check.R read tables by name).
- No collision of the new top-level names `remote`, `lat` in the three scripts.
- Ran tests/testthat/test-db_latency.R and test-compare_rules.R from a `git archive HEAD` copy: 0 failed, 0 errors, 0 skipped
  (the live round-trip test connected and ran a read-only `SELECT 1`).
- Public-text scan of the diff for hosts, ports, paths, logins: none.

## Clean
No issues found.
