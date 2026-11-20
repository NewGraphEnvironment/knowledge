# Review round 1: branch 176-backlog-move-7-fiss-workbooks-a-tested-p (base 8535ae0f)

## Checklist read

- code-check-python.md: in full (the diff has no Python).
- code-check-r.md, by heading: read "Inside a dplyr verb, a column named like a local variable wins", "`ifelse()` with an all-NA test returns a logical vector, whatever `yes` and `no` are", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising, so a `tryCatch(error =)` around it never fires", "Regenerated binaries churn git even when nothing changed", "Under `R CMD check`, tests run from a temp dir against the INSTALLED package", "A `pkg::` call in a test passes `devtools::test()` and fails `R CMD check` if `pkg` is undeclared", "`nzchar(NA)` is TRUE — non-empty checks silently pass NA", "`tryCatch(warning = )` DISCARDS the value the expression produced", "Do not abort inside a handler for a warning raised from C++; note it and abort after the call returns", "A `data-raw/` script must load the source tree, not the installed package", "`load_all()` runs every `.R` file at the top of a package's `data/` as a data script", "`deparse()` re-encodes non-ASCII, so it answers about itself rather than the file" (12 read; about 120 not read, their tools absent from the diff).
- code-check-shell.md, by heading: none read (the diff's only shell-out is `system2(soffice, ...)`, covered under the R heading above); about 95 not read.
- code-check-spatial.md, by heading: none read (no sf/GeoPackage code in the diff; 0220's spatial code is untouched); about 115 not read.
- code-check.md, by heading: the prose of every H3 under `## Mechanisms` (14), with "A guard that fails toward pass" read in full; under "Rules that stand alone" none further.

## Verification done

- `tests/testthat/test-fiss_parse.R` and `test-fiss_nfc.R` run under `pkgload::load_all()` with `NOT_CRAN=true`: 0 failed, 0 errors (57 and 21 passes).
- Every new export's `@examples` runs (`pkgload::run_example()` on each Rd).
- No leftover references in `scripts/0220` to the removed helpers (`step_pat`, `variant_map`, `zone_num`, `read_step`, `select_wanted`, `match_sheet`, `first_nonempty`, `is_fish_layout`, `parse_step`, `zero_catch_codes`).
- `flog$report_id` is read as character in 0220, so `knw_fiss_parse_step()`'s new `chk::chk_string(report_id)` does not abort a run.
- `data/fiss_evidence.csv` before and after: only `gradient_pct` differs, on 31 rows, each exactly x100; NA pattern unchanged.
- `R/` carries no non-ASCII code (`tools:::.check_package_ASCII_code(".")` empty); `readxl`, `janitor` added to Imports, `withr` already in Suggests; fixtures tracked.

## Findings

- **[severity: fragile]** scripts/0250-fiss-evidence.R:141, 147, 368-371, 413-419 — The two new gradient checks cannot fail on the unit slip they exist to catch. `gradient_pct = ifelse(gradient_raw > 1, NA_real_, 100 * gradient_raw)` silently drops every value above 1, and `site_gradient_raw_above_1_set_na` is `pass = TRUE` whatever its count. The ratio check then sees only what survived, and `grad_ratio` is `NA` (counted as a pass) when fewer than 5 sites remain. Worked case on today's data: if the per-group tables start holding percent (the change owed to #248, or a workbook typed in percent), 12 of the 16 sites with both gradients above 0 have raw values above 1 and go NA. The 4 left (17242:1, 17242:2, 59204:2 at 1 %, 59204:4 at 0.5 %) are multiplied to 100 % and 50 %, `grad_n` = 4 < 5, so `grad_ratio` is NA and the check passes. That would write 27 of the 31 gradient rows as NA and the other 4 at 100x, with every reconcile row `TRUE`. The same blind spot covers a single workbook typed in percent in General cells: anything at or below 1 % is read as a fraction and comes out 100x too large, unflagged. Ways to close it: make `site_gradient_raw_above_1_set_na` fail when its count is above 0 (it is 0 today), or above a stated share of sites with a gradient; and have the ratio check fail rather than pass when `grad_n` falls well below the sites carrying a raw gradient, so NA means "nothing to compare" and not "everything dropped".
  - **Rule:** code-check.md "A guard that fails toward pass"

## Checked, not findings

- 0310 hashes the whole of `data/fiss_evidence.csv` into the evidence build's recipe (`inst/receipt/evidence.yaml`, input `fiss_evidence`) but never reads `gradient_pct`. So the next `0310` on the published link build will report its recipe as `different` from the published evidence receipt, while its tables should come back the same. That is the receipt doing its job on a changed tracked input, not a defect; it is noted so the first post-merge evidence comparison is read with this in mind.
- `knw_fiss_parse_step()`'s `mutate(report_id = report_id, site_key = paste(report_id, ...))` takes the argument, then the column it just made (the same value); `knw_fiss_select()` returns only key, step and comment columns, so no `report_id` column can shadow it.
- `knw_fiss_nfc()`'s `ifelse()` calls get no NA tests (`nfc`, `any_no_fish` and `is.infinite()` are never NA), so they keep their types except on zero rows, as the old inline code did.
