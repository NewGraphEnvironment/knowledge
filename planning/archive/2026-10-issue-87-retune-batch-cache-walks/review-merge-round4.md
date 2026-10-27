# Review, merge round 4: commit d80d70e, branch 87-make-a-retune-fast-enough-to-iterate-bat

## Checklist read

- `code-check.md`: the prose of every H3 under `## Mechanisms`, tables skipped. Read in full: "A guard that fails
  toward pass" (test against both known answers; what the guard reads), "A guard's scope, escape hatches, and
  remedies" (is the literal a contract this repo chose or a fact about a third party's output; read the upstream that
  writes it), "Restore the bug and prove the guard fires" (exact prior bytes, patch a copy, count failed and error),
  "A fixture that cannot reach the failure mode" (fixture mirrors production's format), "A proxy is not the property",
  and "An assertion that matches an interpolated value cannot see the claim around it".
- `code-check-r.md`: "A `function(...)` mock hides arguments the real callee no longer accepts", the
  `expect_message`/regex anchoring entries, and "`\<` and `\>` are word boundaries" (not relevant: the match is
  `fixed = TRUE`).

## What was checked

1. **Callers.** `knw_discharge_load()` is called by `knw_build_record()` (so `0320` and `0330` at connect),
   `.knw_walk_cache_prepare()` (the walk cache, so `knw_link_walks()` and `knw_grade_species()`), `0320` (line 296,
   recorded into every grade row and compared with `head1$discharge_load` in the keep-check), `0325` (line 58,
   compared with the grade tables' stored loads), `0310` (line 159, an info row), `data-raw/walk_batch_check.R`
   (line 107) and `test-link_walks.R` (line 107, live). `data-raw/vignette_method.R` and `data-raw/vignette_chinook.R`
   read only stored `discharge_load` values and never call the function. When the guard passes, the function returns
   `d` unchanged, so every stored and compared value is byte-identical to before. The refusal depends only on the
   live comment, never on a stored one, so no older grade table can be blocked by it: a stored load is only ever
   compared with the live value after the live value has passed. The eight `data/tune/*_grades.csv` first rows all
   carry `wet_db_load(): discharge/fwa/v1/segment_monthly, scenario historical last loaded from ... (built
   2026-10-19T06:08:31Z, wet 94deeb5)`, which passes. `test-build_record.R` mocks `knw_discharge_load` whole, so is
   unaffected.
2. **The fixed string.** wet's comment format (`"wet_db_load(): %s, scenario %s last loaded from %s (built %s, wet
   %s)%s"`) is unchanged since it was written (`git log -L` on wet: acde0a9, then 479ef31 changed only the subset
   suffix). `scenario` is asserted length 1 (wet `stopifnot`), so `scenario historical last` is exactly what a
   historical load writes, with or without a `; subset ...` suffix, which follows the provenance. A non-historical
   comment cannot pass: the other fields are the fixed dataset id, a manifest URL (no spaces) or `?`, a timestamp, a
   commit, and `where`, which wet builds from months/doys, `pick` and group codes only and never names a scenario. The
   trailing space keeps `historical_x`-style names out, and the leading `scenario ` keeps `pre-historical` out.
   The COMMENT is written inside wet's `dbWithTransaction`, so a comment naming `historical` always names the load
   that wrote the historical rows.
3. **The test.** Ran the new block alone in a `git archive` copy with `NOT_CRAN=true`: 4 expectations, 0 failed, 0
   error. With the guard line replaced by `if (FALSE) {` in a second copy: 1 failed (the `ssp245` expectation), so the
   test pins the refusal. The mock (`local_mocked_bindings(dbGetQuery = ..., .package = "DBI")` inside `load_of()`)
   is reached through `DBI::dbGetQuery`, and the fixture's comment is in wet's real format.
4. **Rd.** `roxygen2::roxygenise(roclets = "rd")` in the copy leaves `man/knw_discharge_load.Rd` byte-identical.

## Clean
