# Review round 3 (#87): branch diff against merge-base aa0398b

## Checklist read

- code-check-python.md: in full (nothing in the diff is Python).
- code-check.md: the prose of every H3 under `## Mechanisms` (all fourteen, table rows skipped). Of `## Rules that
  stand alone`, `## Security` and `## Spreadsheets and PDFs` (18 headings), read none in full: their index lines
  name nothing this diff uses.
- code-check-r.md, read in full: "`on.exit()` at a script's top level never fires"; "A `data-raw/` script must load
  the source tree" (with its parallel-workers paragraph); "`$` on a list partial-matches"; "A database driver's value
  is not a base R type"; "A value compared as `::text` in SQL has PostgreSQL's spelling"; "`paste()` with a
  zero-length argument"; "`identical()` on two reader results"; "Under `R CMD check`, tests run from a temp dir";
  "`dbConnect(SQLite(), path)` CREATES the file"; "`match()` treats NA as a matchable VALUE"; "`expect_message(expr,
  regexp)` checks only the FIRST condition"; "Postgres row order is never fixed"; "`sprintf("%g", x)` writes `Inf`
  and `NA` into SQL"; "An `information_schema` lookup"; "Rscript reads a script as it runs"; "A `pkg::` call in a
  test"; "Inside a dplyr verb"; "testthat 3e `expect_message()` returns the condition"; "Forked
  `parallel::mclapply()`"; "A `function(...)` mock hides arguments"; "`expect_message(regexp = "...$")`";
  "`tryCatch()` nests its handlers". 22 read; the other headings (about 110) not read.
- code-check-shell.md: no heading read (the diff has no shell); all not read.
- code-check-spatial.md: no heading read in full; the only spatial code (0330's GeoPackage writer) was moved, not
  changed, and reads through `sf::st_read(conn, query =)` over DBI, not GDAL. All not read.

## The mechanism behind round 1

Both round-1 findings are one shape: **a value crosses a boundary and is compared exactly on the far side, under an
assumption about the boundary that nothing enforces.** In (a) the boundary was R's default printing of a double
(`paste()` writes 300000 as `3e+05`), read back by a `[0-9]+` pattern; in (b) it was an unordered server result
summed in floating point, compared bit-for-bit as though the order were fixed. The diff reaches that mechanism in
the places below; each holds.

### Printed or serialised form, compared or joined on the far side

| # | Where | Holds because |
|---|---|---|
| 1 | `R/link_walks.R:220` `.knw_pg_array()`: doubles as SQL array text | `%.17g` reads back exactly in `float8in`; whole keys print without exponent below 1e17; a non-finite element is refused; `test-link_walks.R` pins the round trip on `356000000` and `1520.1234567890123` |
| 2 | `R/link_walks.R:131` the `sources` array literal | members fixed by `chk_subset()` to three plain words |
| 3 | `R/link_walks.R:115` `tmp_knw_walk_starts` via `dbWriteTable()`, then joined to the cache on double equality | RPostgres 1.4.10 COPY encodes a double with `snprintf("%.17g")` (`src/encode.cpp`, read upstream), the same exact form the walk's array carries into the cache, so the `downstream_route_measure =` join is exact |
| 4 | `R/link_walks.R:125` `c.qmin = ANY($4::float8[])` | `ch_dist_profile.sql:59-62` returns `qmin` as the input array element itself (`t.qq`), never recomputed |
| 5 | `R/link_walks.R:136-142` `paste(hits$ord, hits$src)`, `outer(seq_len(n), sources, paste)` | `ord` is coerced to integer first, and `as.character()` of an integer never uses an exponent (probed: `300000L` prints `300000`); a zero-row `hits` gives `character(0)` (probed) |
| 6 | `R/grade_species.R:99` `match(paste(blk, m), paste(w$blk, w$m))` (context line, pre-existing) | both sides are doubles of the same values: `knw_link_segments()` converts `blue_line_key` to numeric, and `knw_link_walks()` returns each start's own values (`chunk[b[ord], ]`, `starts[hits$ord, ]`) then `as.numeric()`, so one value prints one way on both sides |
| 7 | `R/grade_species.R:95-133` the counts that `0320:358` pastes and `vignette_chinook.R:211` reads by pattern | every element is an integer: `nrow()`, sums of logicals, `cache_n` via `as.integer()`, and `g$dropped` (`R/grade.R:56`, sums of logicals); `test-grade_species.R` pins `expect_type(..., "integer")`. The new `walk_cache_*=` names contain none of the patterns read (`segments=`, `accessible=`, `graded=`, `no_size=`) |
| 8 | `walk_md5` written to the grade CSV and read back by `0320:318`, `0325:72`, `0330:~170`, `vignette_chinook.R:82` | every reader reads with `cols(.default = "c")`, so a hex string is never parsed as a number |
| 9 | `knw_build_record()`: `run_uid` from the ledger against `string_agg(...)` | the ledger is read as character, `log_recompute.run_uid` is `text` in link (`R/lnk_log.R:238`); an empty or multi-run schema reads as a different string and is refused |
| 10 | the cache key's `load_md5` | taken by Postgres `md5()`, so the same from any R; interpolated as 32 hex characters |
| 11 | `R/compare_rules.R:~282` flags joined to segments by `paste(id_segment, wsg)` | both sides fetched through the same connector and driver, and the paste runs in the caller's session for both, so one value prints one way |
| 12 | `0320:357` `%g` for `g$q` in the result line | not among the values `vignette_chinook.R` reads back |

### An order assumed where no query fixes one

| # | Where | Holds because |
|---|---|---|
| 13 | the batched walk's rows | tagged by `WITH ORDINALITY`; R attaches each start by `ord`, never by position, and checks one row per start and size |
| 14 | the cache-hit query (no `ORDER BY`) | rows carry `ord`; selection by name; the result is sorted on `(blue_line_key, measure, src, qmin)`, unique by the duplicate check |
| 15 | `flags` now in bin order, not group order | joined to segments by key; the segment frame's order comes from its own query, not from the flags |
| 16 | the comparison's km sums over the unordered segment query | accepted since round 1: the parallel check compares under a relative 1e-9; the bootstrap reads `pl`, whose `DISTINCT ON ... ORDER BY t.loc_id, ..., s.id_segment` is fixed |
| 17 | `.knw_bin_groups()` ties by `order(-n, names(n))` | group codes are four upper-case ASCII letters, which collate alike in C and UTF-8 locales |
| 18 | `string_agg(DISTINCT run_uid, ';' ORDER BY run_uid)` | collation matters only with several runs, which are refused whatever the order |
| 19 | `parLapplyLB()` results in `write_gpkgs()` and `knw_compare_rules()` | `parLapplyLB` returns results in input order; `names(gl) <- keys` is positional on that order |
| 20 | `walk_batch_check.R` | sorted on a unique key; the cache sample is ordered by an md5 of the key |
| 21 | `compare_parallel_check.R` `sort_on()` | each table's keys are unique: compare by group (with `ALL`) x structure; change by `aggregate()`'s by-columns plus structure; checks by check x rule x segment |

A neighbour of the same mechanism, checked: `compare_tbl()`'s `is.finite(d)` gate lets a non-finite difference
through (`Inf` against a finite value, which also masks the column's other rows through `max()`). An `Inf` in
`change_pct` or `lift` can differ between the two runs only where `default_km` or `km_share` differs, and those finite
columns are compared under the same gate, so the discrepancy still stops the check. Holds.

Also checked and holding: the cache key covers the walk's inputs other than the FWA network, which the roxygen states
needs a hand truncation (documented, not new to this diff); a duplicate row for one size cannot reach the cache,
because the walk's per-size `LIMIT 1` and `todo` removal return one row per size; `on.exit()` inside `gpkg_one()`'s
`tryCatch()` fires at the function's exit (probed); every worker function either has its environment set to the
global one or passes its helpers as arguments, and the one in-process bin path (`workers = 1`) runs the same closure.

## Clean

No issues found.
