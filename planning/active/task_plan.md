# Task: Make a retune fast enough to iterate: batch and cache the walks, parallel compare, any box with the build (#87)

A retune is too slow to iterate on. Changing a curve or a pick and seeing its effect means a regrade (`0320`) and a
recompare (`0330`), and on #73 that took 3 h and then 5 to 7 h, almost all of it the database doing one small piece of
work at a time. Scoring is no longer the bottleneck: since #83 it is about 17 min for every key on 6 workers.

Measured on #73's Phase 7 runs (2026-10-24; logs under `scripts/logs/habitat/`, the #73 archive's `scratch/logs/`):

| step | time | where it goes |
|---|---|---|
| `0320` grading, every key | 190.9 min | the downstream walks: BT rearing 46.0 of 47.6 min. One query per segment (2.68 million for BT), R binding each result row by row |
| `0330`, one key at a time | 18 to 140 min per key | the group loop, about 90 % (BT rearing 105 to 130 min): one watershed group after another on one connection |
| `0330`, seven keys on six workers | bounded by BT rearing | one core of the database per key: 99 % CPU with one key running, 578 % with seven |

What repeats on every rerun: BT rearing and spawning walk the same 2.68 million segments to the same 10 m³/s river,
and every regrade walks them again, though the walk depends only on the segment, the river size, the flow source, the
flow load and the walk's code; every recompare regenerates link's `default` flags unchanged.

## Decided at the gate

Proposed in the plan and approved with the parked baseline (Al, 2026-10-26):

1. **The walk cache is a table in the database**, `knw.walk_cache`, primary key (`blue_line_key`,
   `downstream_route_measure`, `src`, `qmin`, `load_md5`, `walk_md5`) with the walk's output columns and `walked_at`;
   `knw.walk_cache_load` maps `load_md5` to the flow load's comment text. The measure is kept as the exact float8
   (every path moving it is exact; nothing goes through `paste()`). Alternative not taken: a local Parquet set under
   `data/tune/`, which would need copying between machines and is invalid across builds anyway. Consequence: a durable
   table on the shared database (about 4M rows per river size and source over every species; roughly 1 GB in all),
   which a second machine's database gets its own copy of. Rows under an old load are never read; pruning is a
   documented `DELETE`, not built. `cache` is `FALSE` or a table name, so the live test uses a throwaway table.
2. **`walk_md5` is a new grade-table column that every reader compares** (`0320`'s keep-check, `0325`, `0330`),
   written from what `knw_grade_species()` returns, beside `walk = "bank"`, which stays as the convention's name.
   Consequence: every key regrades once on the first `0320` after this lands (the timed run wants that anyway).
3. **`0330` runs the keys in turn, each with every worker on its groups**, then writes every key's GeoPackage in
   parallel across keys from the saved segments. Consequence: `WORKERS` now means database cores (6 on the host);
   `GPKG=FALSE` still skips the GeoPackages while iterating.
4. **`0310` is out of scope.** Batching reaches it through `knw_link_walks()`; `cache` stays off there and `SCHEMA`
   is added when #91 reruns it (a task written into #91's body).
5. **The `default`-flags cache (the issue's item 4) is decided by Phase 4's measurement**, not built here: if a full
   `0330` on the host, `GPKG=FALSE`, still exceeds 60 min with 6 workers, it gets a follow-up issue with the numbers.
6. **#85 (one walk pass per river size) stays open** as the cold-walk fix; this plan makes a cold walk cheaper and a
   warm one free, it does not replace the walk.
7. **Assumption stated, not checked by code:** `whse_basemapping.fwa_stream_networks_sp` carries no load record, so the
   cache treats it as fixed; a reload of it (fwapg PR #43 moves measures by millimetres) means truncating the cache,
   which the function's documentation says.
8. **Resumed 2026-10-26 from a machine on a remote link (110 ms per round trip; approved by Al with the resume
   plan).** Code is written here; every database-bound run (the references, the checks, Phase 4) runs on the
   database's host from its own worktree of this branch (`~/Projects/repo/knowledge-87`), driven over ssh, with the
   ignored inputs (`data/tune`, `data/fdis`, `data/compare`) cloned copy-on-write from the host's checkout, which
   another issue's branch holds and is not touched.

## Context: what was measured and found for the plan (2026-10-26)

| what | number |
|---|---|
| grading walk today, on the database's host (`20261024_tune_run.txt`): BT rearing 2,681,583 starts in 46.0 min on 8 workers | 8.2 ms per walk per worker |
| the walk's own cost inside the server (`EXPLAIN ANALYZE`, 300 visit starts, q 10, `pick`, warm) | 2.9 ms per walk |
| one batched query (`unnest` the starts, `CROSS JOIN LATERAL pg_temp.ch_dist_profile`) for 300 starts from a remote link | 4.7 s, 15.8 ms per walk, cold cache |
| one query per start from the same remote link | 116 ms per walk |
| batched against one-by-one on 40 starts | identical status, distance and target |
| a scalar double parameter, a `%.17g` array literal and a typed temp table, round-tripped through RPostgres | exact (`identical()`); `paste()` of a measure keeps 15 digits and of a round key writes `3.56e+08` |

So on the host, batching removes the round trip and R's per-row binding (about 5 of the 8 ms); from a remote link it
removes almost everything, which is what makes "any box" possible. The cache removes the repeat outright. What the
exploration found that shapes the design is in `findings.md` ("Exploration"), with file:line.

## Phase 0: References before anything changes (on the database's host)

- [x] `.gitignore`: `data/compare/ref_*/` (`data/tune/ref_*/` was already ignored).
- [x] `data-raw/walk_batch_check.R` in `REF=1` mode: the grade's own starts in BULK (the bank check's group), from
      `knw_link_segments(conn, "fresh_default_20261017", sp, "BULK")` as `knw_grade_species()` takes them: chinook at
      q 3 (16,686 starts) and bull trout at q 10 (32,342), on `pick`, through the current `knw_link_walks()`, to
      `data/tune/ref_walks/bulk_<sp>_q<q>_pick.rds` (ignored; rds because `write.csv` keeps 15 significant digits).
- [x] `data-raw/compare_parallel_check.R` in `REF=1` mode: the current `knw_compare_rules()` (`workers` not yet an
      argument) on `WCT_rear` (all 16 groups) and `CH_rear`'s 20 largest groups, `CONFIG_SHA=102762da` (the commit the
      tracked tables carry; nothing under link's `configs/default` changed between it and `origin/main` at `ef5b8234`,
      checked 2026-10-26), `tuned_as = door`, to `data/compare/ref_<key>/{compare,change,checks,segments}.rds`
      (exact). CH is the only species whose `default` resolves a near-river pair, so its groups exercise the
      walk table. About 40 min on the host.
- [ ] `findings.md`: the exploration with file:line, the measured numbers, the review's findings and their
      disposition (`planning/active/review-plan.md`).

## Phase 1: Walks batched

- [x] `knw_link_walks(..., batch = 500L)`: each worker sends one query per `batch` starts and source:
      `unnest(ARRAY[...]::integer[], ARRAY[...]::float8[]) WITH ORDINALITY AS s(blue_line_key, m, ord) CROSS JOIN
      LATERAL pg_temp.ch_dist_profile(s.blue_line_key, s.m, $q, $src) w`, the literals written with
      `format(scientific = FALSE)` for keys and `%.17g` for measures, and the start's own R values attached by
      `ord`, so nothing is bound per row in R and no key passes through `paste()`. Chunks per worker as now; the
      exact-row-count check kept, plus a check that every start came back; the output order kept.
- [x] `tests/testthat/test-link_walks.R`: the live test also walks its starts with `batch = 1L` and `batch = 2L` and
      on two sources, expecting identical frames; a mocked test pins the batching arithmetic (every start in exactly
      one batch, none larger than `batch`) and the literal formatting (a round key, a 17-digit measure).
- [x] `data-raw/walk_batch_check.R`: the batched walk on the reference starts against the reference files: every
      start matched, and `status`, `dist_m`, `dist_centre_m`, `bank_m`, `large_lfid`, `n_hops`, `max_entry_gap_m`
      identical after sorting; refuses any difference; writes `scripts/logs/habitat/<date>_walk_batch_check.txt`.
- [x] Per-walk time recorded from this machine (remote link) and, in Phase 4, on the host.

## Phase 2: Walks cached

- [x] `knw_discharge_load(conn)` (the table comment, refusing an empty one) and `knw_walk_md5()` (the md5 of the
      package's `sql/ch_dist_profile.sql`); `0320` and `0325` call the first instead of their inline query.
- [x] `knw_link_walks(..., cache = FALSE)`: given a table name, creates it (and its load table) if absent; writes
      the starts to a typed temp table in chunks and reads the hits for every start, source and size in one join per
      chunk; a start with any miss on a source is walked for the whole size array on that source (Phase 1's batches,
      on the workers, each inserting its batch `ON CONFLICT DO NOTHING`); returns hits and new rows in the same shape
      and order, with the row-count and every-start checks; logs hits and misses.
- [x] `knw_grade_species()` walks with `cache = "knw.walk_cache"` and returns `walk_md5`; the grade table gains
      `walk_md5` from it; `0320`'s keep-check, `0325` and `0330` compare it with `knw_walk_md5()` and refuse a table
      that differs (the "every reader compares it" rule).
- [x] Tests: `test-grade_species.R`'s mock of `knw_link_walks` takes `...`; the live test, on a throwaway cache
      table it drops, walks a start with a fractional measure twice and expects every start a miss then every start a
      hit with identical frames, and a changed `walk_md5` or load string to miss everything.
- [ ] Check in `data-raw/walk_batch_check.R`: 1,000 cached rows re-walked with `cache = FALSE` are identical (run
      after Phase 4's `0320` has filled `knw.walk_cache`; `data-raw/vignette_chinook.R` compares `walk_md5` too, as
      the reader rule names it).

## Phase 3: Compare with the groups in parallel

- [x] `knw_compare_rules(..., workers = 1L)`: the groups split into `workers` bins balanced by segment count (one
      count query), largest first; each bin runs on a socket worker in a self-contained function modelled on
      `walk_chunk` (explicit arguments only: the predicate SQL built by the master for that worker's `near_river`
      table, the config values, the shared table names; `fresh::` and `getFromNamespace` on the worker; no
      `knowledge` namespace needed), with its own connection and scratch schema `<scratch>_w<i>`, its own
      `tmp_knw_wb` (dropped first), looping its groups exactly as the loop does today, reading the master's
      `<scratch>.uhc` and `<scratch>.grades` (written once, read-only), each group in a `tryCatch` that returns the
      error with the group's name; the worker's `on.exit` drops its schema; the master raises naming the group. The
      master keeps its connection and scratch for the `seg` query and the outside check, unchanged. `workers = 1L`
      runs the same function in-process.
- [x] `0330`: the jobs run in turn, each `knw_compare_rules(workers = WORKERS)`; then the GeoPackages for every key
      in parallel across keys (one file per key, one writer each) from `<key>_segments.rds`, the loop as it is today
      moved into that stage; `GPKG=FALSE` skips it.
- [x] Check in `data-raw/compare_parallel_check.R`, on the host: `WCT_rear` and `CH_rear`'s 20 groups with
      `workers = 6` at `CONFIG_SHA=102762da` reproduce the Phase 0 references: `compare`, `change`, `checks` and
      `segments` identical after sorting on their keys (the master's `seg` order and the seeded bootstrap are
      unchanged, so identity is expected); the script reports the largest numeric difference and refuses any above
      1e-9; writes `scripts/logs/habitat/<date>_compare_parallel_check.txt`.
- [x] Tests: the bin-balancing helper (pure R), and both worker functions calling no name of the package (a socket
      worker resolves those in the installed copy, or none). The predicate per worker's near-river table needs link's
      configs, so chinook's run in the check proves it, not a unit test.

## Phase 4: Measure the retune end to end on the host, and decide item 5

- [ ] On the database's host, `SCHEMA=fresh_default_20261017`, `CONFIG_SHA=102762da`: `0320` (every key regrades
      because `walk_md5` is new; the cache cold, then BT spawning warm from BT rearing: its log must say 0 misses);
      then `0330` for every key with `WORKERS=6`, `GPKG=FALSE`, timed per key; then `0330` again with the GeoPackages
      on, their stage timed; then BT spawning's grade table deleted and `0320` rerun, the warm regrade's time being
      the iteration cost. Logs under `scripts/logs/habitat/`.
- [ ] The full `0330`'s tables against the tracked ones of `b8d3fbd`: every difference explained by the 2026-10-25
      regrade (reported in `findings.md`, not refused).
- [ ] Before/after table (the #73 numbers against these) in `findings.md`, the issue body and `scripts/README.md`'s
      run-order notes for `0320` and `0330`.
- [ ] Decision 5 from the measurement, recorded in the issue body: a follow-up issue for the `default`-flags cache, or
      "not needed, measured".

## Phase 5: Box portability

- [x] `knw_build_record(conn, schema)`: the schema's `run_uid` (`<schema>.log_recompute`), the flow load, the walk md5
      and fresh's version, as a named list and a one-line string; `0320` and `0330` compare the schema's `run_uid`
      with the evidence ledger's at connect, before any work, and refuse a mismatch, so the same command runs on any
      machine whose database holds the build and stops on one that does not.
- [ ] `research/database_builds.md`: what a run reads from the database (the link schema and its run, wet's flow load
      and its comment, the FWA tables, the walk cache), how to load a build onto a second machine's database (link's
      schema dump, wet's load with its comment), and what that costs against what the database serves; the measured
      round-trip and batched-walk numbers, so the choice of machine is a number, not a rule.
- [ ] CLAUDE.md "Database access": the host paragraph revised with the batched numbers (what still must run on the
      host, what no longer must) and the #84 run rule.

## Phase 6: Wrap

- [ ] `/code-check branch` (round 1 over the code at `4615173`, rounds 2 and 3 at `2d395e4` (2026-10-27); 2 findings fixed in round 1, rounds 2 and 3
      clean, round 3 enumerating 21 boundary crossings; code changed after this gets its own round); `devtools::test()`, `devtools::document()`, `pkgdown::check_pkgdown()`.
- [ ] `/planning-archive` with the Measurement and Evidence sections; `/gh-pr-push`.

## Owed at the end (reported, done after merge)

- [ ] The host's main checkout: its grade tables (2026-10-25) carry no `walk_md5`, so after the merge `0325`, `0330`
      and `data-raw/vignette_chinook.R` refuse them; copy Phase 4's regraded tables from the host worktree, or rerun
      `0320` there (warm, minutes).

- [ ] #86's body: "done in #87's PR"; close it.
- [ ] #85's body: the new per-walk numbers, and that it is the cold-walk fix only.
- [ ] #91's body: a task for `0310` (`SCHEMA`, `cache = "knw.walk_cache"`) when it reruns there; #92: nothing.

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- Batching: `data-raw/walk_batch_check.R`, the reference starts matched one for one and identical, plus the live test
  with three batch sizes and two sources.
- Cache: the same script's 1,000 re-walked rows; the live miss-then-hit test on a fractional measure; BT spawning's
  grade after BT rearing logging 0 misses in Phase 4; a deleted grade table regraded warm.
- Parallel compare: `data-raw/compare_parallel_check.R` on `WCT_rear` and `CH_rear`'s 20 groups against Phase 0's
  references, identical after sorting; Phase 4's full run against the tracked tables, differences explained.
- Portability: `0320` and `0330` refused against `fresh_default` (run `20261023_074321-24d85e8c`, not the ledger's
  `20261017_004619-3f4c713b`) and run against `fresh_default_20261017`, both recorded in the logs.
- Speed: Phase 4's timed runs on the host, before/after in the issue body.
