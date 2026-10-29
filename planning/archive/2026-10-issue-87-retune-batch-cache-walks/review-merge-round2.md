# Review, merge round 2: `git diff d37e956..HEAD` (b0810ee), branch 87-make-a-retune-fast-enough-to-iterate-bat

## Checklist read

- `code-check-python.md` in full (six rules; none applies: the change touches no Python).
- `code-check.md`: the prose of every H3 under `## Mechanisms` (a guard that fails toward pass; a fixture that cannot
  reach the failure mode; a proxy is not the property; verification that reads its own output; a guard's scope,
  escape hatches and remedies; a fix lands in one of two callers that share a harness; restore the bug and prove the
  guard fires; a shared working tree; a wrapper's exit is not the work; zero-length, empty and unset; the probe is
  broken before the world is; written data outlives the fix; serialization loses meaning silently; one fact derived
  twice).
- `code-check-r.md`, the full sections whose headings name what this change and the code it leans on use: "A database
  driver's value is not a base R type" (the cache path's `bigint` `large_lfid`), "Postgres row order is never fixed
  unless the query fixes it" (the compare's `seg` fetch, the cache's hit read), "A `data-raw/` script must load the
  source tree" (including its paragraph on PSOCK workers loading the installed copy), "Rscript reads a script as it
  runs".
- `code-check-shell.md` and `code-check-spatial.md`: headings grepped; none names a tool or pattern this change uses.

## What was checked

1. **The README's claim that no argument #87 added shapes a result.** Read against the code at d37e956^1 vs its
   merge base 80ea4c1:
   - `knw_link_walks(batch =)`: each start is walked alone (`unnest ... WITH ORDINALITY` + `LATERAL`), rows come back
     tagged by position, the start's own R values are reattached, every start must return one row per size, and the
     result is sorted on `(blue_line_key, downstream_route_measure, src, qmin)` with a duplicate check, so the key is
     unique and the order fixed. No dependence on `batch`.
   - `knw_link_walks(cache =)`: the cache table's column types are the walk function's `RETURNS TABLE` types one for
     one (`large_lfid bigint` both sides, so both paths arrive as `integer64` and go through the same `as.numeric`);
     hits and walked rows are rbind-ed by name, sorted by the same unique key, and keyed on exact `%.17g` doubles.
     The only differences in what is returned are the `cache` attribute and, in `knw_grade_species()`, the
     `walk_cache_hit`/`walk_cache_miss` counts, which reach only the tuning log's `grades` block (named columns;
     `vignette_chinook.R` reads the log by the `<key> grades: <n> groups` line and the `more seeds` / `nested
     selection` blocks, not by position). Neither reaches a grade table or a tracked table.
   - `knw_compare_rules(workers =)`: the bins only change which connection regenerates a group; `fl` is matched to
     `seg` by `(id_segment, watershed_group_code)`, so the order of `flags` does not reach any output; `seg`'s order
     comes from its own query, independent of workers; the bootstrap draws over `ls`, which follows `pl` (ordered by
     `loc_id` through `DISTINCT ON`), so `set.seed(seed_boot)` sees the same vector for any `workers`. fresh's
     `frs_near_river()` deletes and refills its target by watershed group, and `.frs_run_connectivity()`'s helpers
     use `CREATE TEMP TABLE`, so parallel bins on separate connections cannot collide. The predicate strings that now
     name `<scratch>_w<i>.near_river` are used only in SQL, never written to an output.
   - `test-settings-register.R` run in a scratch copy of the tree (load_all, `test_file`, NOT_CRAN=true): 256 passed,
     0 failed, 0 error, 0 skipped. The README's statement holds.
2. **`method.rds` pins the ignored grade tables.** `data-raw/vignette_method.R` puts every source not tracked by git
   into `meta$md5_local`; `data/tune/*_grades.csv` is ignored (`.gitignore:23`), and the bundle's `md5_local` lists
   the seven fitted keys' grade tables. `test-vignette-data.R`'s "every ignored source ... where present, is
   unchanged" compares each present file's md5 with it. The README's claim holds. All 26 tracked sources in
   `meta$md5`, and all 22 in `chinook_rearing.rds`'s, match the merged tree.
3. **Readers brought in by the merge.** `vignette_method.R` reads only `evidence_md5` and `discharge_load` from the
   grade tables' first row, so it neither needs nor breaks on `walk_md5`; `R/settings_register.R` reads no grade
   table; main's edits to `0310` and `0320` (`se_strict`, `formals(knw_tune_run)$prior_sd`, the load comment) merged
   cleanly with #87's, and the register resolves both. Call sites of the three changed signatures in the merged tree
   (`0310`, `0320`, `0322`, `0330`, `data-raw/*_check.R`, the tests) all pass arguments by name or in the unchanged
   leading positions; none in main's new files.

## Findings

- **[severity: fragile]** `R/link_walks.R:42-45` (the `cache` paragraph) and the archive README's Owed sentence "the
  walk cache returns identical walks" — the claim holds only while the FWA tables the walk reads are unchanged, and
  the walk reads more of them than the caveat names. `inst/sql/ch_dist_profile.sql:158-161` reads
  `fwa_rivers_poly`, `fwa_lakes_poly`, `fwa_manmade_waterbodies_poly` and `fwa_wetlands_poly` besides
  `fwa_stream_networks_sp`; the doc's caveat names only the network. Nothing keys on or records an FWA load
  (`knw_build_record()` records the schema's run, the flow load and the walk md5, not the FWA load), and
  `knw_grade_species()` now defaults to `cache = "knw.walk_cache"`, which is what `0320` runs. So after an fwapg
  reload, `cache` would change returned distances, silently, for every start whose measure did not move. The
  register-needs-no-row argument is true under the condition, but the condition is unguarded and half-documented.
  Remedy if wanted: name the polygon tables in the doc's caveat, and say "while the FWA load is unchanged" in the
  README sentence. Not introduced by b0810ee; raised because question 1 asked whether `cache` can change a value.

## Notes, not defects

- On this checkout the "ignored source" test in `test-vignette-data.R` fails right now: the seven local
  `data/tune/*_grades.csv` are dated 2026-10-24 and differ from the copies `method.rds` pinned (2026-10-25, the
  host's). That is the README's "fails wherever they differ" in action, on a machine the Owed list does not name. It is
  the state of this machine's ignored files, not of the code.
- `knw_grade_species()` now writes to the database by default (`CREATE SCHEMA IF NOT EXISTS knw`, the cache tables,
  inserts). A read-only role that could grade before #87 now fails at the first statement. Every caller in the repo
  already writes (scratch schemas), so it changes no result here.
