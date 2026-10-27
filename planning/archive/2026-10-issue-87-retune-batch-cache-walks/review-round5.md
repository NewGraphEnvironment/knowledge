# Code-check round 5: scripts/0330-compare.R (commit 2851566)

## Checklist read

- index_code-check-r.md and index_code-check.md (in full)
- code-check-r.md: "A database driver's value is not a base R type", "`nzchar(NA)` is TRUE", "`identical()` on two reader results tests the reader, not the file", "CSV whitespace: `trim_ws` and `strip.white`", "`system2(stdout = TRUE)` warns on a non-zero exit instead of raising"
- code-check.md: "A guard that fails toward pass"

## Verdict: Clean

What I checked:

1. **`rec` is defined on every path to the staleness check.** `rec <- knw_build_record(conn, schema, run_uid = run_uid)` runs unconditionally at the "compare" section, before `jobs` is built and before the `stale` vapply. The `STAGE=maps` / `STAGE=gpkg` branches come later in the file (after the check), so every stage reaches the check with `rec` set; a failed `knw_build_record()` stops before it. `knw_build_record()` always sets `discharge_load` via `knw_discharge_load()`, which refuses a NULL/NA/empty comment, so `rec$discharge_load` is always a `character(1)`. It is a plain character from a `text` result (`obj_description` returns `text`), not a driver class.

2. **CSV round trip vs the database string.** 0320 writes `discharge_load = knw_discharge_load(conn)` with `write_csv` and its keep-check reads it back with exactly the same call 0330 uses (`read_csv(n_max = 1, col_types = cols(.default = "c"))`, default `trim_ws = TRUE`, default `na = c("", "NA")`) and compares it with `identical()` to the same function's value. So any loss from the round trip (trimmed leading or trailing whitespace, a literal "NA") would hit 0320 just the same, and 0320 would regrade each time rather than keep the table. The two can't disagree: 0330 refuses exactly what 0320 would regrade. The failure goes toward refusal, never toward pass. Embedded commas and quotes are quoted by `write_csv` and survive. A quoted embedded newline would also survive the `n_max = 1` read. Measured on the eight local `data/tune/*_grades.csv`: the value is the 202-character ASCII comment (`wet_db_load(): ... (built 2026-10-19T06:08:31Z, wet 94deeb5)`), contains commas and parentheses, no leading or trailing whitespace, and reads back intact. It matches the `build:` line's `flows` text in the logs.
   (Not a defect in this diff: the local grade tables carry no `walk_md5` column, so on this machine the existing walk_md5 clause already refuses them. Expected, since the regrade happened on the database's host.)

3. **The message still names every reason.** Conjuncts: ref_population/walk bank/curve_prior_sd/grade_withheld/null_heldout_curve/evidence_md5 ("before #73's curve prior ..."), walk_md5 ("another walk than this tree's"), discharge_load ("on another flow load than the database's"), rule/run_uid/evidence_md5 ("another pick, link run or evidence build"). Every clause is named.

4. **CONFIG_SHA.** `Sys.getenv("CONFIG_SHA")` returns `""` for unset and for set-empty, so both now fall back to `origin/main`; the old `Sys.getenv(x, "origin/main")` gave `""` for a set-but-empty variable. Probed through `system2` (via /bin/sh, unquoted `^{commit}` is literal): `origin/main^{commit}` returns one 40-hex line with NULL status; a bad ref returns `fatal: Needed a single revision` with status 128, which the guard refuses. With `stderr = TRUE`, an ambiguity warning would add a second line, and `length != 1` refuses that too, so the guard fails toward refusal.

No findings.
