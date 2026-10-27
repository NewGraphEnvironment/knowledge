# Code-check round 1 — branch 87-make-a-retune-fast-enough-to-iterate-bat

## Checklist read

- code-check-python.md: in full (no Python in the diff).
- code-check.md: the prose of all 14 H3s under `## Mechanisms` (table rows skipped); the other 23 H3s not read.
- code-check-r.md: 14 of 111 headings read in full: `on.exit()` at a script's top level; a `data-raw/` script must
  load the source tree (incl. the PSOCK-worker paragraph); `$` partial match; a database driver's value is not a base
  R type (integer64); a value compared as `::text` (R's `"1e+05"` spelling); `paste()` with a zero-length argument;
  Postgres row order is never fixed; `sprintf("%g")` writes Inf/NA into SQL; an `information_schema` lookup;
  `expect_message()` checks only the first condition; `tryCatch()` nests its handlers; forked `mclapply`;
  a `function(...)` mock; `system2(stdout = TRUE)`. 97 not read.
- code-check-spatial.md: 2 of 93 read (GDAL reservation / PSOCK workers outlive their master; a GDAL failure partway
  through `st_read()`), for 0330's moved GeoPackage writer. 91 not read.
- code-check-shell.md: 0 of 67 read (no shell in the diff).

Probed (pure R, no database): RPostgres 1.4.10 binds numeric params with `format(digits = 17)` and its COPY encoder
carries `%.17g`, so the walk cache's temp starts table and the hit join keep exact measures; testthat 3.3.2's
`expect_message()` passes a non-matching message through (the checklist's "first condition only" does not hold on
this version, so the live cache test's leading Postgres NOTICE messages do not break it); the walk SQL's per-q results
do not depend on the other q's in the array (each q records the walk state when it is found; terminal statuses apply to
all unfound q alike), so reading some sizes from the cache and walking others is sound; fresh's overlay reads `from`
only, and its near-river and cluster helpers use `pg_temp` tables, so the per-bin connections share nothing mutable.

## Findings

- **[fragile]** R/grade_species.R:93 (with :96 and :128) — `cache_n <- c(walk_cache_hit = 0, walk_cache_miss = ...)`
  uses a double literal, so `counts` (previously all integer: `nrow()`, `sum()` of logicals, `g$dropped`) becomes a
  double vector. 0320:357 prints it with `paste(names(g$counts), g$counts, sep = "=")`, and R writes a whole double
  with five or more trailing zeros in exponent form: measured, `c(segments = 300000L, walked = 100000L, cache_n)`
  prints `segments=3e+05, walked=1e+05`, where the integer vector printed `segments=300000`. data-raw/vignette_chinook.R
  :211 parses that line with `num_of("segments=([0-9]+)")` (also `accessible=`, `graded=`, `no_size=`) and would read
  `3` with no error. Unlikely on any given run, but it is a silent wrong number in the article's metadata, and the
  `walk_cache_*` counts make the vector double whatever the data. Fix: `0L` literals and
  `cache_n[] <- as.integer(attr(w, "cache")[c("hit", "miss")])`.

- **[fragile]** data-raw/compare_parallel_check.R:12-16 and :84-87 — the header's premise ("the seg query's order and
  the seeded bootstrap are the master's in both, so identity is expected") does not hold: `knw_compare_rules()`'s seg
  query (R/compare_rules.R, the `SELECT s.id_segment ... WHERE s.watershed_group_code IN (%4$s)` fetch) has no
  `ORDER BY`, and every km in `compare` and `change` is a floating sum over seg in fetched order
  (`km <- function(x, len) sum(len[x %in% TRUE]) / 1000`, the `aggregate()` in `change`). A parallel plan or a
  synchronized seqscan (the reference run is using the database now) reorders rows between the REF run and the check
  run, and on totals of 1e4-1e5 km over hundreds of thousands of segments a reordered sum moves by roughly 1e-9 to 1e-8,
  past the check's absolute 1e-9 tolerance. The check would then refuse a correct parallel comparison after hours on the
  host, and the reported difference would point at the workers rather than at the fetch order. Either use a relative
  tolerance (or 1e-6 km) on the km columns, or note that only reordering-sized differences are expected. (The bootstrap
  itself is fine: `ls` follows `pl`'s `ORDER BY t.loc_id`.)

No other issues found. Checked and not findings: the batched walk's column set and order equal the old `SELECT *`
(the function's RETURNS TABLE order is `.knw_walk_cache_cols`'s); `$4` in the data-modifying CTE is typed `text` by the
function call and reused in the INSERT; `w` is referenced twice so it is materialized once and the insert sees the rows
the SELECT returns; hits are mapped by `t.ord` and take the start's own R values; `full` keys are built from integers on
both sides, so no `"1e+05"` split; the PK makes `n_have == length(q_grid)` exact; on.exit order in `.knw_compare_bin`
drops the schema before disconnecting; flags are joined back by `(id_segment, watershed_group_code)`, so bin order does
not matter; 0320's new `conn <- pg()` / `dbDisconnect(conn)` precedes the script's own `conn <- pg()` at :290; every
reader the CLAUDE.md names (0320 keep-check, 0325, 0330, vignette_chinook.R) compares `walk_md5`'s value, not its
presence; no host names, ports, paths or private links in the diff.
