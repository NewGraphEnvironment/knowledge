# Plan review (#87), 2026-10-26

A Plan agent read the first draft of the plan against the issue and the code before the gate. Its findings, with what
each changed. Where a finding was checked by a probe, the probe is named.

## Blockers

- **B1. The batched query's start key is not R's key.** Array literals built with `paste()` lose digits (15 on a
  measure; `3.56e+08` on a round key), and `knw_grade_species()` matches by `paste()` and leaves an unmatched start
  silently `no_walk`. Probed: RPostgres sends a scalar double exactly; a `%.17g` literal and a typed temp table
  round-trip exactly. **Changed:** Phase 1 writes keys with `format(scientific = FALSE)` and measures with `%.17g`,
  attaches the start's own R values by `WITH ORDINALITY`, and checks that every start came back, not only the count.
- **B2. `0310` cannot run as drafted.** Its schema is hard-coded `fresh_default` and it refuses unless that schema's
  run is the settle log's; `fresh_default` is now another run. **Changed:** `0310` is out of scope (decision 4); its
  `SCHEMA` and `cache` land when #91 reruns it (a task for #91's body, owed).

## Gaps

- **G1. `evidence_md5`.** Moves only if `0310` reruns; then every key rescores and `0325` refuses a partial set.
  **Changed:** stated in the context; `0310` is not rerun here.
- **G2. Partial cache hits.** A start with a miss on a source is walked for the whole size array on that source and
  inserted `ON CONFLICT DO NOTHING`; sound because each size's result is independent of the array. **Changed:** stated
  in Phase 2.
- **G3. The cache needs a unique index and a non-float key.** **Changed:** a primary key; `load_md5` (with a lookup
  table for the comment text) in place of the 200-character comment. The measure stays float8 because every path
  moving it is exact (B1's probe); the live test uses a fractional measure.
- **G4. `bigint = "numeric"` and the temp table.** A written `blue_line_key` would be float8 and defeat the index.
  **Changed:** the temp table is typed (`field.types`), probed to come back integer.
- **G5. The worker body is not self-contained.** The loop's closures hold the master's connection and the package's
  internals; `0330`'s `load_all()` in a worker is not available to a package function. **Changed:** the worker is a
  self-contained function modelled on `walk_chunk`, given the predicate SQL and config values as arguments, calling
  `fresh::` and `getFromNamespace` on the worker.
- **G6. Worker errors.** A `stop()` inside the loop surfaces only after every bin finishes, and worker schemas leak.
  **Changed:** each group in a `tryCatch` returning the error with its name; the worker's `on.exit` drops its schema;
  the master raises naming the group.
- **G7. The live cache test would write to the production table.** **Changed:** `cache` is `FALSE` or a table name;
  the test uses a throwaway table it drops.
- **G8. `walk_md5` should come from `knw_grade_species()`.** **Changed:** it does, as `walk` does.

## Ordering

- **O1. Phase 4 overwrites the Phase 3 reference.** **Changed:** references live under `data/compare/ref_*/`
  (ignored, Phase 0) and are not the per-key tables `0330` writes.
- **O2. Phase 3's check needs the host's regraded grade tables.** **Changed:** the check runs on the host.
- **O3. After Phase 2, `0330` refuses the host's tables until Phase 4 regrades.** Fine: the check calls
  `knw_compare_rules()` directly. Stated.

## Assumptions

- **A1. fresh is worker-safe.** Holds (no advisory locks, sequences or `search_path`; temp tables in `pg_temp`;
  index names per schema).
- **A2. `config_sha`.** `102762da` exists and link's `configs/default` is unchanged to `origin/main`; but `0330`
  defaults to `origin/main`. **Changed:** Phase 4 pins `CONFIG_SHA=102762da`.
- **A3. The row-for-row comparison is well-defined** on the per-key unrounded tables; the `seg` order and the seeded
  bootstrap are unchanged, so identity is expected. **Changed:** the check demands identity after sorting, reports the
  largest numeric difference and refuses any above 1e-9.
- **A4. RPostgres's double encoding was unverified.** Probed: exact.

## Scope

- **S1. The GeoPackage moved onto the critical path** once keys run in turn. **Changed:** written after every key, in
  parallel across keys from the saved segments (#86, item 2); `GPKG=FALSE` skips it; decision 5's threshold is for
  `GPKG=FALSE`.
- **S2. `0310` with `cache = TRUE` was added without need.** **Changed:** dropped (B2).
- **S3. "Identical row for row" was relaxed to 1e-6.** **Changed:** identity demanded (A3).

## Acceptance

- **AC1. A second `0320` with the cache warm measures nothing**, since the keep-check keeps every table.
  **Changed:** BT spawning's grade table is deleted first.
- **AC2. Phase 1 covers `pick` only.** The live test adds a second source; the other sources are exercised only when
  `0310` reruns.
- **AC3. Phase 4's full `0330` as the all-key comparison.** **Changed:** compared with the tracked tables of
  `b8d3fbd`, with every difference explained by the 2026-10-25 regrade (those tables predate it).
- **AC4. Phase 5's `0320` check belongs at connect.** **Changed.**
- **AC5. "BT spawning 0 misses" is valid** (both curves walk q 10, starts are per species).
