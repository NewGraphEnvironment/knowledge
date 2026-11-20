# Review round 2: branch 176-backlog-move-7-fiss-workbooks-a-tested-p (base 8535ae0f, HEAD 6b4b25b6)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check-r.md, by heading: read "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are", "Inside a dplyr verb, a column named like a local variable wins", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared", "`nzchar(NA)` is TRUE — non-empty checks silently pass NA", "`tryCatch(warning = )` DISCARDS the value the expression produced", "Do not abort inside a handler for a warning raised from C++; note it and abort after the call returns", "A `data-raw/` script must load the source tree, not the installed package", "CSV whitespace: `trim_ws` and `strip.white` do not do what the name suggests", "Regenerated binaries churn git even when nothing changed", "`sort()` and `order()` collate by `LC_COLLATE`, so a canonical form is locale-dependent", "`summarise()` and `mutate()` evaluate in order, so a later argument sees the summarised column", "`tolerance` in testthat is RELATIVE, so it pins a published figure far more loosely than it looks" (14 read; about 120 not read, their tools absent from the diff).
- code-check-shell.md, by heading: none read (the only shell-out is `system2(soffice, ...)`, under the R heading above); about 95 not read.
- code-check-spatial.md, by heading: none read (no spatial code changed); about 115 not read.
- code-check.md, by heading: the prose of every H3 under `## Mechanisms` (14), "A guard that fails toward pass" and "One fact derived twice" at length; none under "Rules that stand alone".

## Verification done

- `test-fiss_parse.R` and `test-fiss_nfc.R` under `pkgload::load_all()`, `NOT_CRAN=true`: 0 failed, 0 errors (57 and 21 passes).
- Round-1 fix, scripts/0250-fiss-evidence.R:
  - `gradient_raw` is in `sites` and `site_attr` only; the `evidence` `transmute()` (line 309) names its columns explicitly and omits it, and the `identical(names(evidence), fdis_cols)` stop (line 316) would refuse it. It never reaches `data/fiss_evidence.csv`.
  - `site_gradient_raw_above_1_set_na` now takes `chk()`'s default `pass = expected == actual` (0L against an integer `sum(..., na.rm = TRUE)`, never NA), so any raw value above 1 fails. It counts over all owned sites, not only evidence sites: stricter than the ratio's population, and it can fire on good data only where a workbook really holds a value above 1. Measured today: 0 of 469 numeric raw gradients across the five groups' `fiss_sites_<wsg>_all.csv` exceed 1 (max 0.43), so the committed run passes; the committed reconcile row reads `0,0,TRUE`.
  - The ratio is taken on `100 * gradient_raw` at evidence sites with both gradients above 0, before the NA rule, so a slip cannot shrink its population. Its remaining NA-is-pass branch (`grad_n < 5`) leaves only the case where every slipped value is at or below 1, which is the accepted limitation; any slipped value above 1 fails the other row whatever `grad_n` is. `chk()` coerces `expected` to character, so the `"0.25-4"` row binds with the others.
  - `ifelse(gradient_raw > 1, ...)` returns logical when every `gradient_raw` is NA; it is only written to CSV, as empty, the same bytes as the numeric NA it replaced. Not a defect.
- `0220`'s `write_csv` writes `average_gradient_percent` unrounded, so the x100 sees the stored fraction.
- No leftover references to the removed 0220 helpers; `data/fiss_evidence.csv`'s other readers (0293, 0310) do not compute on `gradient_pct`.

## Findings

- **[severity: security]** data-raw/fiss_fixtures.R:616, 678, 717, 737, 751, 759 (and the six committed `inst/testdata/fiss/*` fixtures) — `openxlsx::createWorkbook()` with no `creator` stamps the workbook's author as `Sys.getenv("USER")`, the local login. Every fixture carries it: `docProps/core.xml` in the two `.xlsx` holds `<dc:creator><login></dc:creator>`, and the four `.xls` converted by LibreOffice carry it in their summary information (`git grep -c <login>` hits all four). These files are tracked in a public repo and ship in the installed package (`inst/`). The repo's rule bars logins and home paths from tracked files, and the #56 `public_sweep.py` lists `<login>` as a `local_path` pattern. It cannot see these copies: the `.xlsx` metadata is deflated inside the zip, and the `.xls` string is UTF-16, so the sweep's 8-character ASCII runs miss it (checked with its own regex on all six files: no hits). Fix in the generator: `openxlsx::createWorkbook(creator = "knowledge")` (or another fixed value) on each call, run soffice with a fresh profile (`-env:UserInstallation=file://<tmp>/prof`) so LibreOffice adds no author of its own, regenerate, and check with `unzip -p <f> docProps/core.xml` and a UTF-16 search of the `.xls`. A fixed creator also stops the fixtures changing with whoever regenerates them.
  - **Rule:** none

## Checked, not findings

- 0250 writes `data/fiss_evidence.csv` (line 317) before the reconcile's `stop()` (line 433), so a run that fails either gradient row still overwrites the tracked table with the NA or 100x values. That order is unchanged by the branch and holds for every reconcile row (the header says the reconcile stops on failure); the tracked table is recoverable from git. Noted because the round-1 proof run ("a run reading every gradient in percent, which stops on both rows") went through this path.
- `knw_fiss_read_step()`'s `muffle_mu` matches janitor's actual text ("Watch out!  The mu or micro symbol is in the input string…"), so only that warning is muffled.
- The test pinning `"0.025000000000000001"` depends on readxl's rendering of a double in a text column from `.xls`; it passes on the readxl installed here. Not a defect today.
