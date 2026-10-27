# Code-check review, round 2 (#87, branch diff against main)

## Checklist read

- `code-check-python.md`: in full (no Python in the diff).
- `code-check.md`: the prose of all 14 H3s under `## Mechanisms`, table rows skipped. The other 23 headings (Rules that stand alone, Security, Spreadsheets and PDFs) were not read.
- `code-check-r.md`: read 10 sections: Postgres row order; A database driver's value is not a base R type; A value compared as `::text`; `sprintf("%g")` writes Inf/NA; Forked `mclapply()` under Accelerate; `tryCatch()` nests its handlers; `system2(stdout = TRUE)` warns; `unlist()` prefixes split names; `on.exit()` at a script's top level; Under `R CMD check` tests run against the installed package. 101 not read.
- `code-check-spatial.md`: read 2 sections: GDAL reserves 3,276 MB / PSOCK workers outlive their master; A GDAL failure partway through `st_read()`. 91 not read.
- `code-check-shell.md`: none read. The diff adds no shell. 67 not read.

## What was checked, and how

- **`R/link_walks.R`**
  - Batched SQL: rows are matched back by ordinality, and the per-batch check that every start has one row per size was traced.
  - Cache-hit bookkeeping (`factor`/`outer`/`table`, the logical `table` used as a row index, the zero-hit case, integer keys printed without an exponent): a pure-R probe confirmed each.
  - Column order and types of cache rows against walked rows: `.knw_walk_cache_cols` agrees with `ch_dist_profile()`'s `RETURNS TABLE`, so `rbind` matches by name with no integer64/integer mix. `status` is never NULL, so the `NOT NULL` insert is safe.
  - PK and `ON CONFLICT DO NOTHING`, given unique starts.
  - Read-only walk over `inst/sql/ch_dist_profile.sql`: each size's result does not depend on the other sizes in `qmins`. Only termination reads `todo`. So serving a cached q=3 row to a later `q_grid = 3` call is sound, and `walk_batch_check.R`'s re-walk of the cache sample tests exactly that.
  - The walk reads only `whse_basemapping` and `discharge`, never link's schema, so the six-column key covers everything except the FWA reload the roxygen names.
  - Cost of the `anyDuplicated()` guard: about 3 s and 1.5 GB peak RSS on 3M rows. Acceptable.
- **`R/compare_rules.R`**
  - The worker's scratch schemas, and the `on.exit` order: the `after = FALSE` DROP runs before the disconnect.
  - fresh 0.42.0's `.frs_run_connectivity`, `frs_cluster`, `.frs_connected_waterbody`, `.frs_bucket_connected`, `frs_near_river` and `frs_habitat_overlay`, read for shared fixed-name tables: everything they create is `pg_temp.*`, or is named inside the passed table's schema. Workers therefore cannot collide.
  - `frs_habitat_predicates(model = "mad")` returns `"FALSE"` rather than stopping when thresholds are missing, so building both models' predicates eagerly is safe.
  - Flags are joined by `(id_segment, watershed_group_code)` on values from one connector type.
  - Assignments inside `tryCatch` land in the worker's own frame.
  - `bin_fun` and `run_job` have the global environment, so the call frame holding the grade table is not shipped.
  - Edge cases for `.knw_bin_groups`: NA counts, more workers than groups, an all-zero group set (empty bins are harmless).
- **`R/grade_species.R`**: the counts vector is integer throughout. `g$dropped` is integer (`R/grade.R:56`). The new names `walk_cache_hit` and `walk_cache_miss` do not collide with the regexes in `vignette_chinook.R` (`segments=`, `accessible=`, `graded=`, `no_size=`).
- **`R/build_record.R`**: the run_uid check fails toward refusal on a missing ledger value (`character(0)`), on an empty log (NA) and on several runs. That is consistent with `0310`'s own gate (`scripts/0310:93-94`).
- **Scripts**
  - `0320`: the build check sits before any work. `fail()` stops inside a single handler.
  - `0320`, `0325`, `0330` and `vignette_chinook.R` compare `walk_md5` by value. Every grade-table reader in `R/`, `scripts/` and `data-raw/` is covered.
  - `0330`: `run_one` now runs in the master, using globals all defined above it. `gpkg_one` and `write_gpkgs` are self-contained on workers. STAGE=gpkg does not fall through into code that needs `res`.
- **Check scripts**
  - `compare_parallel_check.R`: the relative tolerance is `pmax(1, |b|)`, absolute below 1, with the NA pattern compared first. The sort keys exist on every table.
  - `walk_batch_check.R`: the cache sample is typed like the walk's output before the identical comparison.

## Clean

No issues found.
