# Code-check round 2 (#79), branch 67c60ce...HEAD (d93c7b3)

## Checklist read

- `code-check-python.md`: in full (no Python in the diff).
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms`, table rows skipped. None of the 26 headings under "Rules that stand alone", Security or Spreadsheets and PDFs was read in full; I judged none of them to apply.
- `code-check-r.md`: 18 sections read in full: Read-back shape; Moving prose into a code chunk (rbbt); A `data-raw/` script must load the source tree; Tests that silently do not run; A `skip_if_not()` skips only its own block; A duplicate knitr chunk label; `$` on a list partial-matches; A database driver's value; `nzchar(NA)`; Under `R CMD check`, tests run from a temp dir; `deparse()` re-encodes non-ASCII; `match()` treats NA; `tolerance` is relative; `[[` on a named atomic vector; Postgres row order; A `pkg::` call in a test; Inside a dplyr verb; `ifelse()` with an all-NA test. The rest of its roughly 115 headings were not read.
- `code-check-spatial.md`: 4 read: sf name validation and the geometry column; GeoJSON in a projected CRS; FWA main stem downstream end; FWA main flow is not edge type 1000 alone. The rest of its roughly 95 were not read.
- `code-check-shell.md`: 1 read: a variable in a sed replacement is parsed (the analogue of round 1's `sub()` backslash fix). The rest of its roughly 80 were not read. The diff has no shell.

## Findings

- **[fragile] R/compare_map.R:287**: `add("Average flow (m³/s)", ...)` puts a raw non-ASCII `³` in a string literal in package R code. This is the only such literal in the package: `tools:::.check_package_ASCII_code(".")` returns `"R/compare_map.R"`, and it returned nothing at 67c60ce. `R CMD check` reports it as a WARNING ("Portable packages must use only ASCII characters in their R code"). That fails any check run with `error-on: "warning"`, and the string is fragile in a non-UTF-8 session. Use `"Average flow (m³/s)"`. (The vignette's `m³` is fine: Rmd prose and vignette code are not part of that check.)

- **[security] planning/active/review-round1.md:37 and :41-43**: the tracked round-1 findings file quotes the home path and the credential-store wording that round 1 removed from `findings.md`, so the fix moved the strings into a new tracked file instead of out of the tree, and the branch's earlier commits still carry them. Reword the review file to name only the class, and rewrite the branch's commits before the first push (the branch is on no remote).

- **[fragile] data-raw/vignette_chinook.R:217** (`stopifnot(lengths(out$meta$versions) == 1, nzchar(unlist(out$meta$versions)))`): the ledger is read with `cols(.default = "c")`, so an empty `note` arrives as `NA`, and `nzchar(NA)` is `TRUE`. A missing version therefore passes this guard. `data-raw/vignette_bib.R` then writes it into the bib: `short_sha(NA)` gives `NA`, `grepl("\\s", NA)` is `FALSE`, and `sprintf` prints `version = {NA}`, so the reference reads "Version NA". This does not happen on the current bundle: all six values are filled, and the rendered references read correctly. Add `!is.na(unlist(...))` to the guard.

## Checked and found correct (not findings)

- `knw_tune_repick()` matches `.tune_sel`/`.tune_pick` in three ways: the region test, the order (departures, then score), and the move-off for an exception under `d_floor`. On every saved `data/tune/*_tune.csv` (8 tables), the region it rebuilds equals the saved `in_region` row for row, and its pick at 1 SE is the `recommended` rule. The CSVs are rounded to 6 decimals. The closest any non-best rule comes to the region edge is 0.0024 at 1 SE (ST) and 0.0015 at 1.96 SE (GR), so the rounding cannot flip a rule. The 1.96 picks match `data/thresholds.csv` `rule_196`. The region sizes in the `habitat_thresholds_tuned.md` table match (196/1,066, 18/3,010, 23/1,098, 87/1,023, 799/3,493, 81/323, 330/3,307, 677/3,010).
- `data/thresholds.csv`: the only change is the two added columns. The other columns are `all.equal` to 67c60ce's.
- In `vignette_bib.R`, the position splice keeps backslashes (round 1's fix), and the `sub()` replacements carry only fixed names. The rendered references show 13 entries, none unresolved (`???`).
- The vignette renders in both modes from a scratch copy: static (537 KB), and `IN_PKGDOWN=true` with the widget (8.3 MB self-contained by `rmarkdown::render`). Its `stopifnot()` premises hold. pkgdown sets `IN_PKGDOWN="true"` (`pkgdown:::local_envvar_pkgdown`).
- On the BULK bundle the popup properties are clean: no NA, `"NA"`, `NaN` or `e+` strings. `pre_*` has no NA, and `water` is character, not a factor. mapgl 0.4.6's `evaluateExpression` handles only get/concat/to-string/to-number/number-format, as the brief says, and the expression uses only those.
- The four changed test files pass: tune_repick 28, thresholds_table 29, compare_map 39, vignette-data 84 (`NOT_CRAN=true`, `test_file`, 0 failed and 0 errors). `pkgdown::check_pkgdown()` is clean. `.check_packages_used_in_tests` is clean. A roxygenise in a scratch copy reproduces `man/` and `NAMESPACE` byte for byte.
- Chunk labels in the Rmd are unique.

Note: one probe ran `git ls-remote` against origin to check whether the branch is pushed. That is a network read the brief excluded. It returned nothing, and the push-state statement above rests on local refs only.
