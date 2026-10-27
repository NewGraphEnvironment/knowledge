# Findings — Make a retune fast enough to iterate: batch and cache the walks, parallel compare, any box with the build (#87)

## Issue context

## Problem

A retune is too slow to iterate on. Changing a curve or a pick and seeing its effect means a regrade (`0320`) and a
recompare (`0330`), and on #73 that took 3 h and then 5 to 7 h, almost all of it the database doing one small piece of
work at a time. Scoring is no longer the bottleneck: since #83 it is about 17 min for every key on 6 workers.

Measured on #73's Phase 7 runs (2026-10-24; logs under `scripts/logs/habitat/`, `planning/active/scratch/logs/`):

| step | time | where it goes |
|---|---|---|
| `0320` grading, every key | 190.9 min | the downstream walks: BT rearing 46.0 of 47.6 min. One query per segment (2.68 million for BT), R binding each result row by row |
| `0330`, one key at a time | 18 to 140 min per key | the group loop, about 90 % (BT rearing 105 to 130 min): one watershed group after another on one connection |
| `0330`, seven keys on six workers | bounded by BT rearing | one core of the database per key: 99 % CPU with one key running, 578 % with seven |

What repeats on every rerun:

- BT rearing and spawning walk the same 2.68 million segments to the same 10 m³/s river, and every regrade walks them
  again, though the walk depends only on the segment, the river size, the flow source, the flow load and the walk's
  code.
- Every recompare regenerates link's `default` flags unchanged.

Where it can run: database-bound steps must run on the database's own host (CLAUDE.md, "Database access"; a round trip
is 1.6 ms there and 104 ms over a remote link). A second machine helps only with its own database holding the same
build. One has a 14-CPU database (6 here), but its build differs: a partial `fresh_default` of 850k segments against
11.4 million, and an older flow load.

## Proposed (to plan with `/planning-init`)

1. **Walks batched**: one query per few hundred starts (`unnest` the starts, `LATERAL` the walk), so round trips and
   R's row binding stop dominating. Check: identical output on a whole group.
2. **Walks cached** per river size, flow source, flow load (the table comment) and walk-code md5, so a regrade after a
   curve or pick change walks nothing, and species and stages that share segments walk them once (#85, item 3).
3. **`0330` groups in parallel** (#86): each group in its own scratch schema on its own connection, keys in turn,
   so one key uses every database core. Check: one key's tables identical row for row.
4. **Optional caches** once 1 to 3 land, if still slow: `default`'s regenerated flags per species, stage, link config
   commit and build; the GeoPackage off by default for iteration (`GPKG=FALSE`) and written after, from the saved
   segments.
5. **Box portability**: every database step records and checks the build it reads (schema run, flow load, walk
   code), so the same command runs on any machine whose database holds that build and refuses one that does not; and
   a recipe for loading a build onto a second machine's database (the schema dump and the flow load), weighed against
   what else that database serves.
   The run rule from #84 lives here too: no chained tuning and comparison until every key's smoke gates have
   passed; score every key, check, then grade, then compare.

#85 (a walk pass per river size) stays the longer-term fix for a cold walk; #86 is item 3 here. #83 (the scorer's fit)
and #84 (the smoke gates) landed in #73 (PR #88) and are closed; #84's run rule is in item 5.

## Exploration (2026-10-26, plan mode, read-only)

### The walk path (`0320` grading)

- `knw_link_walks()` (`R/link_walks.R:46-97`): starts split into `min(n, workers * 8)` round-robin chunks; each chunk
  opens its own connection through `connector`, installs `inst/sql/ch_dist_profile.sql` as `pg_temp.ch_dist_profile`
  (`:63`), then per start and source runs `SELECT * FROM pg_temp.ch_dist_profile($1::integer, $2, $3::float8[], $4)`
  (`:66-67`) and binds with `cbind`/`rbind` (`:68-71`). Workers are a PSOCK cluster (`:76-79`). The row count is
  checked exactly (`:85-86`) and the output sorted (`:96`). One round trip per start per source; grading walks one
  source and one size, so one per segment.
- The SQL function is scalar plpgsql; each size in `qmins` is found independently (`inst/sql/ch_dist_profile.sql:59-72`;
  `todo` only extends the walk), so a result for one size does not depend on which other sizes were asked for.
- `knw_grade_species()` (`R/grade_species.R:66-127`): starts are the species' accessible segments with a gradient in
  its groups (`:86-87`), from `knw_link_segments()`; one size (`pick$exc_q`, else `curve$q`, `:89`); source `pick`;
  walks matched back by `paste(blue_line_key, downstream_route_measure)` (`:92-96`), an unmatched start silently
  `no_walk`; `target_in_group` needs `large_lfid` (`:98-110`); returns `walk = "bank"` (`:121`), a literal.
- `0320` (`scripts/0320-tune-run.R:281-350`): reads `discharge_load` inline (`:286`), keeps a grade table only when
  `rule`, `run_uid`, `walk == "bank"`, `ref_edge`, `discharge_load`, `curve_prior_sd`, `grade_withheld`,
  `evidence_md5` match and `null_heldout_curve` is present (`:304-321`); writes the table with those fields from what
  `knw_grade_species()` returns (`:337-343`). `0325` re-reads the load comment (`scripts/0325-publish.R:58`) and refuses
  a table whose load differs (`:105-109`); `0330` checks the same header (`scripts/0330-compare.R:157-171`).
- `evidence_md5` is the md5s of `data/fdis/derived/{visits_link,visits_species,walks}.csv` (`0320:106-110`); it moves
  only if `0310` reruns, which also rescores every key (`R/tune_run.R`, the score cache keyed on `evidence`).
- Nothing hashes the walk SQL anywhere; no walk result is kept per segment after a grade (only `dist_m`,
  `dist_status`, `target_in_group` in the grade table). The grade tables are 0.5 to 4.35 GB each and ignored; the
  regraded set of 2026-10-25 (with `null_heldout_curve`, `evidence_md5`) lives on the database's host; the copies on
  this machine are the 2026-10-24 ones (30 columns).
- `0310` (`scripts/0310-evidence-build.R`): `schema <- "fresh_default"` (`:55`), refuses unless that schema's
  `log_recompute` run_uid is the settle log's (`:93-94`); walks the distinct visit points at 7 sizes × 3 sources on 4
  workers (`:200-202`); records `link_run_uid` in the ledger (`:88`).
- Tests: `test-link_walks.R` needs a live database with `discharge` (`skip_if_no_pg`), two Bulkley starts, q 3 and 10,
  `pick`, 1 worker; `test-grade_species.R` mocks `knw_link_walks` as `function(connector, starts, q_grid, sources,
  workers)` (`:36-44`) returning six columns with no `large_lfid`.
- `data-raw/walk_bank_check.R`: the check pattern (one group, classes, a gate class that must hold 0, a log under
  `scripts/logs/habitat/`).

### The compare path (`0330`)

- `knw_compare_rules()` (`R/compare_rules.R:88-529`): one connection, one scratch schema (`knw_cmp_<key>` from
  `0330:188`); before the loop: `tmp_knw_wb` (session temp, `CREATE ... IF NOT EXISTS`, `:192`, `:624`),
  `<scratch>.uhc` (`:194`), `<scratch>.grades` for every group (`:200-201`). The loop (`:209-282`) per group:
  `<scratch>.streams` rebuilt (`:212-227`), geometry flattened and indexed (`:231-235`), the near-river pairs walked
  into `<scratch>.near_river` with `fresh::frs_near_river()` where `default` resolves a pair (`:236-242`; chinook
  only), the default-rule assertion (`:243-251`, a `stop()` inside the loop), then per rule `<scratch>.habitat_<k>`
  (`:252-268`), `fresh::frs_habitat_overlay()` (`:271-274`), `fresh:::.frs_run_connectivity()` (`:276-277`), flags read
  back (`:278-280`). The predicate SQL embeds `<scratch>.near_river` (`near_tbl`, `:138`) and is cached per model
  (`pred_cache`, `:140-182`); `preds_for`/`pred_of` are closures over the master's `conn`.
- After the loop: one `seg` query over every group (`:295-314`) joining `<scratch>.grades` and `<scratch>.uhc` and
  reading `tmp_knw_wb`; flags matched by key (`:318`); `compare` per group and `ALL` (`:377-384`), `change`
  (`:387-425`), the FDIS check (`:428-447`), the outside check with a seeded bootstrap over `pl`'s `DISTINCT ON ...
  ORDER BY` order (`:449-521`). The `seg` order sets every sum's order and is unchanged by a per-worker design.
- fresh 0.42.0: `frs_near_river` works on the connection it is given, its working table is `pg_temp`, the index names
  are per schema; the connectivity helpers' temp tables are `pg_temp.frs_*_<sp>`; no advisory locks, sequences or
  `search_path` (scanned by the exploration agent).
- `0330`: jobs (species × stage) on `parLapplyLB` (`:252-256`), `WORKERS` default 6, one connection per job
  (`run_one`, `:175-229`, which does `pkgload::load_all()` in the worker, `:176`); per-key tables written unrounded
  (`:190-193`), the combined ones rounded (`:343-345`); the GeoPackage loop per group on one file per key
  (`:194-211`), 4 to 17 min per key; `CONFIG_SHA` defaults to link's `origin/main` (`:103-107`).
- Tests: `test-compare_rules.R` covers only the pure helpers; nothing tests `knw_compare_rules()` itself.

### Measurements

| what | number |
|---|---|
| grading walk, database's host (`20261024_tune_run.txt`): BT rearing 2,681,583 starts in 46.0 min on 8 workers | 8.2 ms per walk per worker |
| the walk's own server cost (`EXPLAIN ANALYZE`, 300 visit starts, q 10, `pick`, warm) | 2.9 ms per walk |
| one batched query for 300 starts from a remote link | 4.7 s, 15.8 ms per walk, cold |
| one query per start from the same remote link | 116 ms per walk |
| batched against one-by-one on 40 starts | identical status, distance, target |
| RPostgres: a scalar double parameter, a `%.17g` array literal, a typed temp table (`field.types`) | each round-trips a 17-digit measure `identical()`; `blue_line_key` comes back integer |
| R's `paste()` | 15 significant digits on a measure; `3.56e+08` on a round key |
| reference walk sizes in BULK on `fresh_default_20261017` | CH accessible with gradient 16,686 starts; BT 32,342 |
| schema runs | `fresh_default_20261017`: `20261017_004619-3f4c713b` (the ledger's); `fresh_default`: `20261023_074321-24d85e8c` |
| the tracked `CH_rear` and `WCT_rear` compare tables | `config_sha` `102762da`, last written at `b8d3fbd` (2026-10-24); link's `configs/default` unchanged to `origin/main` `ef5b8234` |
| the connected role | can create schemas |

Probe scripts (not committed): the session scratchpad's `walk_batch_probe.R` and the RPostgres encoding probe.

### Plan review

`planning/active/review-plan.md`: the Plan agent's findings on the first draft and what each changed.

## Phase 1: the batched walk (2026-10-26)

`data-raw/walk_batch_check.R` on BULK, `fresh_default_20261017`, `pick`, 8 workers (logs
`scripts/logs/habitat/20261026_walk_batch_check*`):

| run | chinook, q 3, 16,686 starts | bull trout, q 10, 32,342 starts |
|---|---|---|
| host, one query per start (`-ref`) | 14.0 s, 6.71 ms per walk per worker | 29.4 s, 7.28 ms |
| host, batch 500 | 6.9 s, 3.30 ms | 15.6 s, 3.86 ms |
| remote link, batch 500 (`-remote`) | 36.5 s, 17.5 ms | 47.5 s, 11.7 ms |

Both batched runs: every start back, identical to the reference on all 14 columns. The host's batched run shared
the database with the Phase 0 compare reference, so its time is an upper bound; Phase 4 times the full grade alone.
Every BULK start found its river at both sizes, so the check exercises `found` only; the live test's hop start and
the per-start guard cover the rest of the row shape.

## Phase 3: the parallel comparison (2026-10-27)

`data-raw/compare_parallel_check.R` on the host, `fresh_default_20261017`, link configs at `102762da`, `door` (logs
`scripts/logs/habitat/20261026_compare_parallel_check*`):

| key | one connection (reference, code before #87) | 6 workers (`f3634dd`) |
|---|---|---|
| WCT rearing, 16 groups | 16.9 min | 4.4 min |
| CH rearing, its 20 largest groups (near-river pairs walked) | 45.3 min | 17.0 min |

Every segment's flags identical on both keys (1,190,110 and 1,829,223 segments, largest difference 0). The km sums
in `compare`, `change` and `checks` differ by at most 1.0e-13 relative: the segment query has no `ORDER BY`, so the
sums' order moved between runs, which is why round 1 of the review was right to relax identity to a relative 1e-9.
The reference ran while the Phase 1 walk check shared the database for a minute; neither run had the database alone
otherwise. CH's speed-up (2.7x) is below WCT's (3.8x); why was not measured (the bins' balance and the near-river walk's own
use of the server's cores are candidates).

## Phase 4: the first launch ran two regrades at once (2026-10-27)

The first Phase 4 chain ran attached over ssh; I stopped it with TaskStop, killed its shell and relaunched detached.
The R process of the first chain's `0320` survived (its parent was killed, it was reparented and kept running), and
the check for leftovers looked for `Rscript` while the running process is `exec/R --file=...`. So two cold `0320`
runs graded side by side from 01:03:57Z and 01:04:27Z, both writing `/tmp/knw87_p4/0320_cold.log` (interleaved lines,
two `Done in` lines: 97.4 and 96.8 min) and the same grade CSVs. What it did and did not damage:

- The cache: its primary key `(blue_line_key, downstream_route_measure, src, qmin, load_md5, walk_md5)` held; 4,459,402
  rows, all distinct. Both runs counted BT rearing's 2,681,583 starts as misses, then BT spawning as 2,681,583 hits.
- The timings: both runs shared the database and the CPUs for the whole 97 min (BT rearing's walks 53.6 min), so
  no number from it is a measurement of the change. The grade CSVs were written by both, so none is trusted.
- What it showed anyway: the cache check after it (`data-raw/walk_batch_check.R`) failed on a real bug, not on the
  dual run: `.knw_load_md5(conn, knw_discharge_load(conn))` ran the comment query as a lazy promise after preparing
  the md5 query, which cancelled it. Grading assigned the load first, so only the check's call shape hit it. Fixed
  with `force()` and a test that fails without it (`9e56f18`).

The rerun (`/tmp/knw87_phase4c.sh` on the host, from 02:49:07Z) drops `knw.walk_cache` and deletes every grade
table first, so its `0320` is cold, and runs alone (one `exec/R` process, checked at launch). The dual run's logs
are kept on the host under `/tmp/knw87_p4_dual/`, not committed.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `git pull` on the host worktree refused: untracked logs would be overwritten | the logs had been copied here and committed; checked their md5s equal and removed the host's copies before each pull |
| Phase 4's first `0320` kept running after its chain's shell was killed, so the relaunch ran a second one beside it | rerun from an emptied cache; check leftovers by the script name (`grep 0320` over `ps`), since R runs as `exec/R`, not `Rscript` |
| `bind message supplies 1 parameters, but prepared statement "" requires 0` in the cache check | `.knw_load_md5()` forces its argument before preparing (`9e56f18`) |
