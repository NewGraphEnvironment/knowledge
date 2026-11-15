# Code-check round 3 (#204): guard enumeration

## Checklist read

- code-check-python.md: read in full. Nothing in it applies, because the diff has no Python.
- code-check-r.md, read by heading: "Tests that silently do not run", "testthat counts an uncaught error under `error`, not `failed`", "A `skip_if_not()` skips only its own `test_that()` block", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "A `data-raw/` script must load the source tree, not the installed package", "Moving prose into a code chunk hides it from tools that scan the document", "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "`nzchar(NA)` is TRUE", "`paste()` with a zero-length argument returns length ONE", "`match()` treats NA as a matchable VALUE", "`expect_gt()` and friends take no `info` argument", "`expect_false(identical(x, y))` cannot fail when the two are different types".
- code-check.md: the prose of every H3 under `## Mechanisms`, with the table rows and evidence blocks skipped.
- code-check-shell.md and code-check-spatial.md: no heading applies. The workflow step is R run under `shell: Rscript {0}`, with no bash logic.

## Mechanism behind rounds 1 and 2

Both defects were guards whose verdict was taken where they were written: a local render with a populated bundle, and a local `devtools::test()` where `_pkgdown.yml` exists. Neither verdict was taken where the guard actually runs.

- **Round 1:** in the article's load chunk, `stopifnot(val(k) == "x")` gets `logical(0)` when the bundle lacks the row, and `stopifnot()` reads that as TRUE.
- **Round 2:** in `test-pkgdown-navbar.R`, the premise file is absent under R CMD check, the only automated runner at the time. The test skips there, and the suite reads green.

In both, "the guard could not be evaluated" folds into "pass", as an empty vector or a skip. Rules: code-check.md "A guard that fails toward pass" ("Branch on empty explicitly"; a loop over an empty list), and code-check-r.md "Tests that silently do not run".

**Round 3 finds the same class one axis over.** The new scope test does run in CI, but its expected set is narrower than the set its name claims. So it cannot fail for the one member outside that set.

## Findings

- **[severity: fragile]** tests/testthat/test-vignette-data.R:162 (test "the methodology bundle's scope covers every published key, with its groups and gate")
  - **What is wrong:** the test checks that `scope` covers every published key by comparing it with `x$stability`, which holds only the *fitted* keys (`data-raw/vignette_method.R`: `fitted[, ...]`). The published set also holds the underpowered key, WCT rearing.
  - **Measured:** removing the `WCT_rear` row from `scope` passes three guards:
    - this test;
    - every `stopifnot()` in the article's load chunk (mutation B11 below);
    - `vignette_method.R`'s scope check.
  - **Why it matters:** WCT rearing is in both lists the article computes its words from. Its share is 6/14, so it is in `under_half`, and its gate flag is TRUE, so it is in `withheld`. A bundle missing it renders a shorter table and a sentence ("It withholds …") that silently drops a key, with every guard green. The same thing would happen if `vignette_method.R`'s filter were narrowed to `status == "fitted"`.
  - **Remedy:** hold the keys to an independent list that already ships in the bundle and carries the underpowered key. `x$site_gradient$limits$key` is built from `data/thresholds.csv`, and `setequal(x$site_gradient$limits$key, x$scope$key)` is TRUE today (7 keys). Use `expect_setequal(s$key, x$site_gradient$limits$key)`, which runs under R CMD check. Caveat: that list holds only keys with a published gradient limit, which today is all seven.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies" ("Pin scope against its source of truth"). Also code-check.md "One fact derived twice": an expected set must come from a producer the subject cannot influence, and `stability` and `scope` are both cut from the same `summ` by status.

No other findings.

## Guard enumeration

Where it runs:
- **local render:** `rmarkdown::render` or `devtools::build_rmd`, reading the installed bundle;
- **CI pkgdown:** `pkgdown.yaml`, which installs `local::.`;
- **R CMD check:** the shared flows workflow. It builds vignettes under the r-lib default, which I did not confirm for the flows copy;
- **manual:** a person runs the script.

**Measured** means a mutation probe was run in a detached worktree (since removed).

### Article load chunk: `vignettes/tuning-bayesian-practice.Rmd:50-57`

Runs in: local render, CI pkgdown and R CMD check.

| # | guard | defect it is for | fails on its defect? |
|---|---|---|---|
| 1 | `nrow(sc) > 0` | bundle without `scope` | **Yes, measured** (B1 scope NULL; B10 zero rows) |
| 2 | `all(sc$groups_both < sc$groups)` | a key dropping no group | **Yes, measured** (B7). NA also fails. |
| 3 | `length(under_half) >= 2` | prose names a list that has emptied | **Yes, measured** (B8) |
| 4 | `length(withheld) >= 1` | "It withholds …" with nobody withheld | **Yes, measured** (B6) |
| 5 | `any(!is.na(sc$margin) & !sc$grade_withheld)` | no key published | **Yes, measured** (B12) |
| 6 | `nrow(closest) == 1` | no curved key | Yes: 0 rows when `curved` is empty. Only reachable together with 1 and 5. |
| 7 | `abs(closest$margin) < 1` | closest call no longer close | **Yes, measured** (B13) |
| 8 | `abs(closest$margin) >= 0.05` | printed `%.1f` reads "0.0" | **Yes, measured** (B5) |
| 9 | `with(curved[abs(margin) > 1e-3, ], identical(grade_withheld, margin <= 0))` | caption's sign against the run's flag | **Yes, measured** (B2 flag flipped; B9 flag NA) |
| 10 | `identical(val("prior_sd"), "2.5")` | hard-coded "2.5" in the prose and the glance table | **Yes, measured** (B3) |
| 11 | `identical(val("se_region"), "1")` | hard-coded "One standard error" | **Yes, measured** (B4b row removed) |
| 12 | `identical(val("folds"), "5")` | hard-coded "four folds … the fifth" | **Yes, measured** (B4 duplicate row) |

Notes on the article chunk:
- Every arm stays TRUE on the shipped bundle (B0 passes).
- Guard 9 rests on rounding: the summary's deviances are rounded to 1e-4, and rounding is monotone. So a non-zero rounded margin carries the true sign, and the 1e-3 cut-off only drops margins that rounded to zero.
- None of guards 1-12 fires when a published key's row is missing (B11). See the finding.

### `tests/testthat/test-vignette-data.R`, new block (lines 158-166)

Runs in: R CMD check (no skip; it reads the installed bundle) and local `devtools::test()`.

| # | guard | defect it is for | fails on its defect? |
|---|---|---|---|
| 13 | `expect_false(is.null(s))` | bundle without `scope` | Yes. It is the only arm here that fires for NULL, because the arms after it are vacuous on NULL. |
| 14 | `expect_true(all(stability keys %in% s$key))` | a published key missing | **Partly**: fitted keys only. The underpowered `WCT_rear` cannot be caught (see the finding). |
| 15 | `expect_true(all(s$status %in% c("fitted","underpowered")))` | another status leaking in | Yes, when `s` is non-NULL |
| 16 | `expect_false(anyNA(s[c("groups","groups_both","grade_withheld")]))` | NA counts or flag | Yes. A missing column errors instead, which counts as an error. |
| 17 | `expect_true(all(s$groups_both <= s$groups))` | impossible counts | Yes. It is looser than guard 2 (`<=` against `<`), which is right for the bundle. |

### `tests/testthat/test-pkgdown-navbar.R`

Runs in: CI pkgdown (the new step) and local `devtools::test()`. Under R CMD check it skips at line 8.

| # | guard | defect it is for | fails on its defect? |
|---|---|---|---|
| 18 | `skip_if_not_installed("yaml")`, line 6 | — (a skip) | Turned into a failure by the step: **measured** (M3) |
| 19 | `skip_if_not(file.exists(f))`, line 8 | — (a skip) | Turned into a failure by the step. Under R CMD check it skips by design. |
| 20 | `expect_false(is.null(menu))`, line 11 | menu removed or renamed | Yes |
| 21 | `expect_gt(length(shown), 0)`, line 15 | no navbar sections | Yes |
| 22 | `expect_identical(<titles without navbar>, "internal")`, line 17 | a new section without a navbar title; internal renamed | Yes |
| 23 | `expect_setequal(hrefs, articles of navbar sections)`, line 18 | article added, removed or linked wrongly; internal article in the menu | **Yes, measured** (M1 entry dropped; M2 internal added) |
| 24 | `expect_false(is.na(at))`, line 21 | section's navbar title renamed or missing in the menu | Yes |
| 25 | `expect_setequal(hrefs[at:end], section contents)`, line 25 | article under the wrong heading | Yes |

Notes on the navbar test:
- `expect_setequal` ignores duplicates and order, so a duplicated menu entry passes.
- Nothing compares an entry's `text` with its article's title, so a renamed article keeps a stale menu label with every guard green.
- A heading with no section behind it also passes.
- All three are cosmetic, not failures.

### `.github/workflows/pkgdown.yaml:142-146` (new step)

Runs in: CI pkgdown, on every PR and every push to main. It has no `paths:` filter, and Deploy is gated on it.

| # | guard | defect it is for | fails on its defect? |
|---|---|---|---|
| 26 | `nrow(r) == 0` | a file skipped at its top level (no row in the frame) | **Yes, measured** (M4: `skip()` at the top of the file) |
| 27 | `r$failed > 0` | a stale menu | **Yes, measured** (M1, M2) |
| 28 | `r$error` | the test erroring | Yes. A skip in a helper escapes as a condition and Rscript exits 1. |
| 29 | `r$skipped` | the test skipping inside its block | **Yes, measured** (M3) |

Notes on the step:
- A frame-based skip count is safe here only because of guard 26: the file has one block, so a top-level skip leaves zero rows (code-check-r.md "testthat counts an uncaught error …").
- testthat and yaml come from Suggests, through `setup-r-dependencies` with its default `dependencies: '"all"'` and `local::.`. Confirmed: neither `with:` block overrides `dependencies`.
- The step's code passes unmutated in a worktree.

### `data-raw/vignette_method.R:498-507` (scope check)

Runs in: manual only (a promotion, `0335`, or a hand rerun, where `data/` is present).

| # | guard | defect it is for | fails on its defect? |
|---|---|---|---|
| 30 | `anyNA(scope[c("groups","groups_both","grade_withheld")])` | a missing count or flag. The summary is read as character, so `as.logical()` of anything but TRUE or FALSE gives NA. | Yes, by reading the code (not run: it needs `data/` and the evidence) |
| 31 | `any(scope$groups_both > scope$groups)` | impossible counts | Yes, by reading the code |
| 32 | `!identical(is.na(dev_curve), is.na(null_heldout_curve))` | one deviance of the gate without the other | Yes, by reading the code |

Notes on the scope check:
- It does not check that every published key is present, by design. A key whose summary file is absent from `data/tune` is not in `summ` and passes.
- The file-level md5 pin covers each summary once it is bundled, and `union(keys, scope$key)` adds `WCT_rear_summary.csv`, which is confirmed in `meta$md5`.

### `data-raw/bayesian_alignment_check.R`, touched checks

Runs in: manual only. It needs pdftotext and the Zotero PDFs, so it cannot run in CI. A quote edit can merge without it, and the committed log is the only record that it ran.

| # | guard | defect it is for | fails on its defect? |
|---|---|---|---|
| 33 | strict quote regex with `[@` and `]` (line 152), passage on the page with its folio | a misquote or a wrong page in the article | **Yes, measured** (A1 word changed; A6 page off by one) |
| 34 | bracket parity `(m[3]=="(") != (m[7]==")")` (line 188) | `[@key, p. N)` or `(key, p. N]` | **Yes, measured** (A2) |
| 35 | `n_quotes` per file, `want <- n_quotes[basename(md_path)]` (line 228) | a quote that left the checked form, or one added unchecked | **Yes, measured** (A3 curly marks: count 4 of 5) |
| 36 | near-check `pg` regex, with inline code now blanked with `x` (lines 167-183) | a quote mark near a citation, outside the checked form | **Yes, measured** (A3). Its `\[@` arm predates the branch. |
| 37 | Rmd front matter and fence blanking, plus the unclosed-fence `stop()` (lines 83-92) | chunk text read as quotes; a broken fence | The stop: yes, by reading the code. The blanking is a carve-out. |
| 38 | `if (!is_rmd)` around the coverage tables | the article failing for lacking the research file's tables | Not a guard. It is a scope switch. |
| 39 | log `stem`: none for an MD other than the two files | a stray log | Not a guard |

Notes on the alignment check:
- The unmutated runs pass: the article (5 quotes, PASS) and the research file (PASS).
- Guard 37's carve-out: a quote with a page citation inside a chunk, such as a kable caption that pandoc renders with its citation, is never checked. Mutation A10 passed. The article has no such quote today, and the script's header states the carve-out, so this is not a finding.

Clean apart from the one fragile finding. Every other guard the branch adds or changes can fail, where it runs, on the defect it is for: each was measured by mutation or read from the code.
