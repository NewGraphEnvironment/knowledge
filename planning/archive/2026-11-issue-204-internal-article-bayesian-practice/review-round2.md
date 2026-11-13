# Code review, round 2 (#204)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check-r.md: by heading. Read: "Tests that silently do not run"; "A `skip_if_not()` skips only its own `test_that()` block"; "Under `R CMD check`, tests run from a temp dir against the INSTALLED package". Every other heading's index line was checked against the diff; none of the remaining ~140 named a tool or shape this diff uses closely enough to need its full section.
- code-check-shell.md: by heading; no section read in full (the diff has no shell code). All ~100 not read.
- code-check-spatial.md: by heading; no section read in full (the diff has no spatial code). All not read.
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows skipped), read in full for "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "A guard's scope, escape hatches, and remedies", "Restore the bug and prove the guard fires" and "Zero-length, empty, and unset are three different things", and skimmed for the rest. Under "Rules that stand alone", every heading checked by its index line; none read in full.

## Findings

- **[severity: fragile]** tests/testthat/test-pkgdown-navbar.R:7-8 — the test that "holds the menu to the sections" (CLAUDE.md, `_pkgdown.yml`'s comment) runs in no CI job. `_pkgdown.yml` is in `.Rbuildignore` (`^_pkgdown\.yml$`), and under R CMD check the tests run from `<pkg>.Rcheck/tests/testthat`, so `test_path("..", "..", "_pkgdown.yml")` never exists there and `skip_if_not(file.exists(f))` always skips. The pkgdown workflow, which does have the source checkout, runs no tests. And pkgdown does not fail when the hand-written menu leaves out an article in a navbar section: it builds the article and lists it in the index, but not in the navbar. So an article added to a section without a menu edit, or a renamed section title, goes stale silently unless someone runs `devtools::test()` on a source tree. It passes locally (10 expectations, 0 failures, measured now), so this is about where the guard runs, not what it checks. The repo already accepts local-only tests for ignored `data/`, but `_pkgdown.yml` is tracked and present in the pkgdown job's checkout. A one-line step there (`Rscript -e 'testthat::test_file("tests/testthat/test-pkgdown-navbar.R")'`, checking failures and errors) would let the guard fire in CI. Otherwise, the CLAUDE.md sentence should say it is checked locally only.
  - **Rule:** code-check-r.md "Tests that silently do not run" ; code-check-r.md "Under `R CMD check`, tests run from a temp dir against the INSTALLED package"

## Checked and not a finding

- **Round 1's fix (40557588).** `identical(val("prior_sd"), "2.5")`, `identical(val("se_region"), "1")` and `identical(val("folds"), "5")` were mutation-tested on the source bundle with the article's load chunk. They fail on a missing key (`character(0)`) and on a duplicated key (length 2). The other guards also fire when mutated: no `scope` stops at `nrow(sc) > 0`; one flipped `grade_withheld` stops at the caption-sign `identical()`; no withheld key stops at `length(withheld) >= 1`; an NA group count stops at `all(sc$groups_both < sc$groups)`. The caption-sign `identical()` over `curved[abs(margin) > 1e-3, ]` could pass on an empty subset, but `abs(closest$margin) >= 0.05` with `nrow(closest) == 1` guarantees at least one row.
- **vignette_method.R scope guard.** An empty `scope` passes it (`anyNA` FALSE, `any()` FALSE, `identical(logical(0), logical(0))` TRUE), which is the logical(0) shape. But the article's `stopifnot(nrow(sc) > 0, ...)` and the test's `all(<stability keys> %in% s$key)` both catch it, because `stability` has 6 rows. Not silent end to end. Statuses in the 22 summaries are `fitted`, `underpowered`, `no_response`, `no_stream_rule` and `not_modelled`; the filter keeps the 7 published keys.
- **test-vignette-data.R scope test.** It has no `nrow > 0` of its own, but the stability-membership expectation fails on an empty scope while `stability` is non-empty. It passes now.
- **bayesian_alignment_check.R.** Run on a scratch copy of the article (MD set to the copy, so no log is written; `git status` stayed clean): 5 quotes, PASS. Mutations in the copy all FAIL, each through the near-mark check against `\[@`:
  - a curly-quoted passage with a pandoc citation;
  - a straight-quoted passage with a two-key citation `[@a, p. N; @b]`;
  - a straight-quoted passage with a pageless `[@key]`.

  The open/close pairing check, the m[3] to m[7] group renumbering, the `n_quotes[basename()]` lookup (NA, so skipped, for any other file) and the fence and front-matter blanking (it stops on an unclosed fence, and keeps line numbers) all read correctly. Masking inline code with `x` instead of spaces can only add quote marks (a `'` before inline code now opens a word), so it fails toward fail.
- **_pkgdown.yml / navbar test logic.** `$text` and `$href` do not partial-match any other key. The `internal` assertion and the per-section `setequal` both fire on a missing or extra article.
- **The bib** holds exactly the three keys the article cites.
