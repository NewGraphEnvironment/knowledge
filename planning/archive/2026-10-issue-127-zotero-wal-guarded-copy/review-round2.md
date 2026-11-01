# Code-check round 2 (#127): branch diff 9e10a19...HEAD

## Checklist read

- code-check-python.md: in full.
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped); also "Percent-encode a URL at construction, not at consumption". Not read: the other 20 headings under "Rules that stand alone", Security and Spreadsheets and PDFs.
- code-check-r.md: "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising…", "`Rscript -e` supplies `--args` itself…", "`tryCatch()` nests its handlers…", "A `data-raw/` script must load the source tree, not the installed package", "A database driver's value is not a base R type…", "`tempfile()` lives in the session tempdir…", "Rscript reads a script as it runs…", "`$` on a list partial-matches…". About 110 headings not read.
- code-check-shell.md: "Quoting", which includes the `python -c` double-quote variant. About 90 headings not read.
- code-check-spatial.md: "Restoring a GeoPackage from a copy: refuse sidecars before the first read, delete them before the copy-back" and "A GeoPackage is a SQLite database, and that leaks in three ways". About 95 headings not read.

## Findings

- **[severity: fragile]** data-raw/zotero_copy_check.R:232-236 (with 194 and 188). The interference cases cannot tell the guard refusing a try from any error on the hooked path, so the four expected-refusal cases can pass with no interference having happened. `tryCatch(..., error = function(e) NA_integer_)` maps every error to `NA`, and `it$ok` counts `NA` as the refusal it expects. On the R side, an error raised inside the hook (`interfere()`) leaves the guard before it accepts anything, and that reads as a refusal. On the Python side, only a `SystemExit` prints `NA NA`. Any other exception (a broken `hooked`/`touch`, a failing `os.utime`) prints nothing to stdout. `strsplit(character(0))[[1]]` then fails, and that error also becomes `NA`. Reproduced on a copy of HEAD: I replaced the Python `touch()` body with `raise OSError('hook broke')` and the R `touch_main` arm with `stop("hook broke")`. The run printed `ok TRUE` for every touch case and ended `PASS: every guard read every fixture's rows and handled every interference case`, though no file was touched. So the cases that pin the stability check go vacuous, and say nothing, the moment the hook stops reaching its target. That is the property round 1 added them for. The checkpoint case is not affected, because it expects 10 rows and an `NA` fails it. Remedy: score a refusal by the guard's own message, not by `NA`. On the R side, keep `conditionMessage(e)` and require `grepl("no consistent copy", msg)` where `expected` is `NA`. On the Python side, treat output with no final `NA NA` / two-integer line as an error (`stop()`), not as `NA`. Also count a case whose hook never fired as a failure, for example by having the hook record that it ran.
  - **Rule:** code-check.md "A guard that fails toward pass" ; code-check.md "Restore the bug and prove the guard fires"

Checked and found sound, so not findings:

- The R hook reaches the guard's `file.copy`. `environment(g)` is `e`, whose parent is `snapshot`'s own environment, so the hook is found ahead of base's. `interfere()`'s own `file.copy` resolves to base, so it does not recurse.
- The Python hook reaches `db()`'s calls. `db()` imports `shutil` locally and calls `shutil.copyfile` by attribute. The hook is installed after `exec_module`, so imports are not counted.
- Python argv and quoting are sound. `shQuote` falls back to double quotes because the program contains `'`, and it escapes `$`, `` ` ``, `"` and `\`, none of which the program uses. An empty `other` arrives as `''`.
- No NA leaks into `it$ok`, `gt$ok` or `st$ok`: every `NA` arm is `FALSE & NA`, which is `FALSE`.
- The case set also pins "state taken after the last copy". I moved 0270's `after = state()` to between the main copy and the `-wal` copy, on a copy of HEAD. The checkpoint case caught it: 8 rows against 10 expected, so the script stopped.
