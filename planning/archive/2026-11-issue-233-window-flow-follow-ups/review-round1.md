# Code-check round 1: the window walk, the window flow and the four-reading tuning (#226)

Reviewed 2026-11-22 (UTC), branch `233-backlog-move-14-window-flow-follow-ups` at `ffdeee52`, diff
`b07ce5ad...HEAD`, each listed file read in full. Probes ran in a detached worktree of `HEAD` (removed) and
against the database read-only (temporary tables, session-temporary functions, the tests' own
`public.knw_walk_cache_*test*` tables, which were dropped; `knw.walk_cache` and `knw.walk_cache_window` not
written). The working tree was not touched apart from this file.

## Checklist read

- `code-check-python.md`: in full.
- `code-check.md`: the prose of all 14 mechanisms (table rows skipped); of the stand-alone rules, in full "Do not
  edit files a long test run is reading", "Test the cold/create path of idempotent code, not just the warm no-op",
  "A preview flag is only safe if it previews", "Documentation Staleness", "An assertion that matches an
  interpolated value cannot see the claim around it"; the other 9 stand-alone rules and the Security and
  Spreadsheets sections by index line only.
- `code-check-r.md`: 53 of 130 headings read (the first 1,700 characters of each, evidence blocks skipped), among
  them: data-raw loads the source tree; lintr and the installed package; tests that silently do not run; testthat
  error against failed; `skip_if_not()` scope; `$` partial matching; a driver's value is not a base type; `::text`
  spelling; `paste()` zero-length; `identical()` on two reader results; tests under `R CMD check`; CSV
  whitespace; `sort()` collation; `match()` and NA; `expect_message()` (three rules); `tolerance` is relative;
  `expect_false(identical())`; `unlist()` and `split()`; Postgres row order; `sprintf("%g")` into SQL; float
  formatting in its consumer; Rscript reads as it runs; `pkg::` in a test; `system2(stdout = TRUE)`;
  `clusterApply()`; `c(name = x)`; `ifelse()` all-NA; `data.frame()` zero-length; two repos pinning a remote; a
  `function(...)` mock. 77 not read (index line only).
- `code-check-spatial.md`: 5 of 96 read (the five Freshwater Atlas rules: route measures, main-flow edge types,
  lookup area, watershed codes are not a place, a main stem's downstream end); 91 by index line only.
- `code-check-shell.md`: 4 of 73 read (`git diff a..b`, git plumbing defaults, `git worktree prune`, psql and
  dollar quoting); 69 by index line only.

## What was checked and held

Stated so the findings below are read against it; none of this is a finding.

- **The verdict.** `data-raw/chinook_window_tune.R` computes the three conditions as
  `research/chinook_window_flow.md` "The verdict rule" states them. In a two-row grid `.tune_sel()` gives the
  best row an SE of 0 and the other `sqrt(n) * sd` of the per-group differences, so `max(s$se_diff)` is the SE of
  the pair's difference. `ch_rear_pairs.csv` and `ch_rear_verdict.csv` agree with the log and the research table.
- **The summary columns.** `honest_same_*`, `seeds_same_*` and `boot_share_*` recomputed by hand from each
  reading's `CH_rear_honest.csv` and `CH_rear_seeds.csv` give `ch_rear_readings.csv`'s values on all four
  readings (control 2/2/4/2 and 4/4/4/4; river 3/3/4/4 and 0/0/4/4).
- **The score cache.** One directory per reading and population, and the reading's label in `evidence_id`, which
  `knw_tune_run()` compares before reading a cache back: no cross-read.
- **The control check** compares all 6,149 rule strings, deviances, pick, recommended rule and region with the
  tracked `data/tune/CH_rear_tune.csv`, and three summary values with `CH_rear_summary.csv`; a missing column on
  either side stops it. Not vacuous.
- **`knw_link_walks(window = )`**: no cache, cache cold, cache warm, a start short of a size, two sources: rows
  carry the labelled `src` and the start's own values (read, and the tests pass: 13 of 13 blocks in
  `test-link_walks.R`, 7 of 7 in `test-link_flow.R`, 0 failed, 0 errors, 0 skipped, on the database). The annual
  path's query text, file, md5 and labels are unchanged.
- `inst/sql/ch_dist_profile.sql` is untouched by the branch. `roxygen2::roxygenise()` changes nothing,
  `pkgdown::check_pkgdown()` and `tools:::.check_packages_used_in_tests()` are clean.
- The flow table today holds one forcing and period per source and no NULL `q_m3s` (102,790,688 historical rows
  counted), which bounds the second finding to a future load.

## Findings

- **[severity: fragile]** `data-raw/chinook_window_tune.R:174` (and `:243`, `:244`, `:350`) — `r$curve` is
  read with `$` on `knw_tune_run()`'s record, a list. When a curve fails, `knw_tune_run()` leaves no `curve`
  element and sets `curve_error`, the only name with that prefix, so `r$curve` returns the error string:
  `is.null(r$curve)` is FALSE, the "not fitted" stop at 174 does not fire, and the run dies later in
  `reading_row()` at `nz(r$curve$heldout)` with `$ operator is invalid for atomic vectors`, after that reading's
  region, seeds, honest and groups files were written. The no-LFRA runs (checked at 345 on `$score` only) reach
  the same line at 350, so the `nz()` helper's stated purpose ("a run whose curve did not fit still has its
  scores") cannot happen. Measured: `r <- list(score = 1, curve_error = "x"); is.null(r$curve)` is FALSE. No
  committed number is affected: all eight runs fitted. `r[["curve"]]` at each read is exact.
  - **Rule:** code-check-r.md "`$` on a list partial-matches, so a longer sibling key answers for a missing one"

- **[severity: fragile]** `inst/sql/ch_dist_profile_window.sql:51`, `:66`, `:71` (and
  `data-raw/chinook_window_evidence.R:101-110`) — the two checks that make "a segment missing a month is passed
  over, never read short" true count rows, not values, and the array check lets NULL through.
  `cardinality(months) <> cardinality(weights)` is NULL for a NULL `weights`, so the `IF` is not taken; and
  `sum(m.q_m3s * w.wt)` skips a NULL product while `count(*)` still equals `cardinality(months)`. Probed on the
  database from `(360886335, 1520)`, `pick`, months `{8,9}`: weights `{0.53125,0.46875}` find segment 79047591 at
  23.116 m³/s; weights `NULL` return `none` for every size with no error; weights `{0.53125,NULL}` return
  `found` on the same segment at 12.417 m³/s, a flow read short. A NULL `q_m3s` in a window month would read
  short the same way (the column is nullable), and the evidence script's count of short segments
  (`count(*) FILTER (WHERE month IN ...)`) would pass it too. Not reachable through `knw_link_walks()` today:
  its weights go through `.knw_pg_array()`, which refuses a non-finite value, and the load has no NULL flow. So
  no committed number is affected; a later load, or a direct call, is where it bites. `count(m.q_m3s * w.wt)` in
  the HAVING, and `array_position(weights, NULL) IS NULL` with a NULL test on `weights` in the `IF`, close it.
  - **Rule:** code-check.md "A guard that fails toward pass"

- **[severity: fragile]** `inst/sql/ch_dist_profile_window.sql:71`, `tests/testthat/test-link_walks.R` (the six
  window blocks) — nothing tests the HAVING. With the line deleted in a copy (`) q ON true` in its place, the
  loaded file confirmed to hold no `HAVING`), all six window blocks stayed green: 54 expectations, 0 failed, 0
  errors. The tests walk the live network, where no picked segment lacks a window month (the evidence run counted
  0 of 4,532,843), so no start can reach the branch; the header's and the roxygen's claim about a short segment
  rests on reading alone. Each of the other new tests can fail in the direction it guards (read against the
  code: the label on walked rows, the cache's `src` and md5, the weights against `knw_link_flow_window()`, the
  source and the parent in the flow fixture, the months check). A fixture is the only way to reach this one,
  and the walk reads `whse_basemapping` and `discharge` by name, so it is stated here rather than asked for.
  - **Rule:** code-check.md "Restore the bug and prove the guard fires" ; code-check.md "A fixture that cannot reach the failure mode"

- **[severity: fragile]** `R/link_walks.R:263-283` (key built at `:116`, `:125`, `:275`) — a window walk's
  cache rows are keyed on the window's dates (`src`, `pick@0815-0915`), the flow load and the window SQL file's
  md5, but the query that makes them also carries the month weights as literals, which come from
  `wet::wet_flow_window()` through `.knw_window_weights()` and are in no part of the key. `DESCRIPTION` sets a
  floor on wet and no ceiling, so a wet release that counts a window's days differently would walk new starts on
  new weights and read every kept start on the old ones, with no sign: the warm path compares nothing. Today the
  weights are a fixed function of the dates (`0.53125;0.46875` for the kept rows, recorded in
  `ch_rear_window_evidence_run.csv`), so the 258,496 kept rows are right. Putting the months and weights in the
  key (in `src`, or hashed into the `walk_md5` a window walk passes to `.knw_walk_cache_prepare()`) removes the
  dependence.
  - **Rule:** code-check.md "Written data outlives the fix"
