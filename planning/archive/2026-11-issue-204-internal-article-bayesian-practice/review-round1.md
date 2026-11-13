# Review round 1 (#204, branch against main at eac16623)

## Checklist read

- code-check-python.md: index read; no Python in the diff, so no section applies (full text not studied line by line).
- code-check-r.md: read "Tests that silently do not run"; "Under `R CMD check`, tests run from a temp dir against the
  INSTALLED package"; "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is
  undeclared" (ran `tools:::.check_packages_used_in_tests` on the branch: empty, a pass). Index-only for the rest.
- code-check-shell.md, code-check-spatial.md: index only (no shell or spatial code in the diff).
- code-check.md: read "A guard that fails toward pass" and "Restore the bug and prove the guard fires"; the other
  Mechanisms by their index lines.

## What was run (read-only; anything writing in a detached worktree, since removed)

- `test-pkgdown-navbar.R`: 10 expectations, 0 failed. `test-vignette-data.R`: 20 tests, 0 failed, 3 skipped (the
  ignored-source checks, no `data/` in a worktree).
- The article's chunks under `load_all()`: every `stopifnot()` passes on the committed `method.rds`; under-half keys
  BT spawning, chinook, steelhead, WCT rearing; withheld BT spawning, coho, WCT rearing; closest call BT spawning,
  margin -0.56 (withheld, prints 0.6). Summaries' `dev_curve` is `r$curve$heldout` (0320:468), so the table's last
  column and caption match the gate in `R/tune_run.R:292`.
- Quote check regex: `[@a, p. 1; @b, p. 2]` after a quote does not match the strict form, and the near-check (`\[@`
  added to `pg`) then flags it, so a quote cannot slip out of the checked form silently.

## Findings

- **[fragile]** vignettes/tuning-bayesian-practice.Rmd:57 — `val("prior_sd") == "2.5"`, `val("se_region") == "1"` and
  `val("folds") == "5"` guard prose that hard-codes the same values ("scale 2.5" at lines 131 and 191, "One standard
  error" at 129, "four folds ... the fifth" at 181-182). `val()` returns `character(0)` for a key the register no
  longer has, `character(0) == "2.5"` is `logical(0)`, and `stopifnot(logical(0))` passes (reproduced). So a renamed
  or removed register key builds the article with the inline values printing empty ("a standard deviation of  on the
  scorer's ... scale") and the hard-coded numbers unchecked. The chunk's own comment (lines 48-49) guards `scope`
  against exactly this and misses it here. Fix: `identical(val("prior_sd"), "2.5")` (and likewise), or assert
  `length(val(k)) == 1` for each key.
  - **Rule:** code-check.md "A guard that fails toward pass"

Nothing else found: the scope builder refuses missing counts, flags or half a gate; `curve_failed` keys never enter
`scope` (status filter), so the "no curve" branch is unreachable but harmless; the navbar test skips under
`R CMD check` (`_pkgdown.yml` is in `.Rbuildignore`) and `yaml` is declared in Suggests; the Rmd blanking keeps line
numbers and refuses an unclosed fence; log naming writes only for the default or the article path.
