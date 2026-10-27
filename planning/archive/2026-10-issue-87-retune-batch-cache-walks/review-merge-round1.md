# Code-check review: merge round 1 (b0810ee, scripts/0310-evidence-build.R)

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of every H3 under `## Mechanisms` (table rows skipped). Applied most closely: "A guard that fails toward pass", "A proxy is not the property", "A guard's scope, escape hatches, and remedies".
- code-check-r.md: "A database driver's value is not a base R type — and it fails twice"; "`nzchar(NA)` is TRUE — non-empty checks silently pass NA"; "Inside a dplyr verb, a column named like a local variable wins". Also checked the index headings for `load_all`/`data-raw` (none apply: the script loads the source tree with `pkgload::load_all()`).
- code-check-shell.md and code-check-spatial.md: headings grepped (67 and 93). None names a tool, shape or pattern the diff uses (no shell, no spatial code), so no section read in full.

## What was checked

1. **Same value, same refusals.** Removed lines: `dbGetQuery(conn, "SELECT obj_description('discharge.fwa_v1_segment_monthly'::regclass) AS c")$c`, then `stop()` when `length != 1 || is.na || !nzchar`. `knw_discharge_load()` (R/link_walks.R:282) runs the same SQL on the same connection (alias `d`, which is internal), applies the identical three-part test in the same order (`is.na` before `nzchar`, so the `nzchar(NA)` trap does not arise), and returns the same `character(1)`. The error text is identical; only `call. = FALSE` differs, which changes the printed prefix, not whether it refuses. A missing table errors at the `::regclass` cast in both. Same as `0320` (line 296) and `0325` (line 58), which already call it.
2. **Reachable.** `pkgload::load_all(quiet = TRUE)` at line 52 loads the source tree before line 159; the function is also exported (NAMESPACE line 8). `conn <- pg()` is assigned at line 92 (a DBI connection from `RPostgres::Postgres()`) and is not reassigned or disconnected before line 159. No attached package exports a clashing name.
3. **Downstream use.** `wet_load` is used once more, at line 160 (`add("info", "wet_loaded_build", 0, wet_load)`), with the same value. Nothing else in the script referred to the removed lines.
4. **Registers and tests.** `inst/method/settings.csv` names `scripts/0310-evidence-build.R` only in `script:` entries for `cw_agree_min` and `q_grid`, both untouched; `.knw_where_value()` (R/settings_register.R:39) parses the script for top-level assignments of those names, and the file still parses (`parse()` ok) with one assignment each. No `code:` entry names 0310, so no text pattern reads the removed lines. `inst/method/pipeline.csv` row 5 names the script and functions, not the removed text. No test or `data-raw/` script reads `obj_description` or the removed message from 0310 (grep for `0310`, `obj_description`, `carries no load comment`, `wet_loaded_build`).

## Clean

No issues found.
