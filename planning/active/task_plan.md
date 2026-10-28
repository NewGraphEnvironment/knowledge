# Task: Cache link's default flags in the comparison, once measured: a full 0330 is still 2.9 h (#101)

## Problem

A full `0330` still takes 2.9 h on the database's host after #87: 162.9 min (2.7 h) for eight keys with `GPKG=FALSE`, groups on 6 workers, then 14.0 min of GeoPackages (2026-10-27, `scripts/logs/habitat/20261026_compare*.txt`). #87's plan set the bar at 60 min on 6 workers for a follow-up; this is it.

The time is the database regenerating link's habitat flags. Classify, overlay and connect is 115.2 of the 162.9 min (BT rearing 27.4 of 33.4). The database's cores are the limit: before #87, seven keys running at once took 160.1 min, and now one key at a time on six connections takes about the same for all of them. What changed is the time to see one key (4 to 37 min).

Part of that work repeats on every rerun: link's `default` rule is regenerated unchanged for every key, every time. It is one of three rules for most keys (`default`, `free`, `door`), one of two for BT spawning and GR (whose tuned rule is `default`'s own for GR), and one of four for CH. If every rule cost the same, `default` would be about 41 of the 115 classify minutes. That is an estimate, not a measurement.


## Decided at the gate

- **Measure only; no cache built** (Al, 2026-10-28: "stop after measuring … we dont need to cache till we have new
  outputs from there"). The PR is "Part of #101" and "Part of #112", not "Fixes"; both stay open.
- The measurement runs on the published comparison's setting (schema `fresh_default_20261017`, run
  `20261017_004619-3f4c713b`, link configs `102762da`, published `data/tune/` grades), so its per-key totals sit beside
  the published 37.1 min (CH) and 33.4 min (BT rearing). Runs on the database's host (this Mac), with no other
  database-bound job running.

## Found while planning (shapes the parked design)

- `default`'s flags read nothing from the grades or the tuned pick: its predicate is fresh's on link's configs, the
  scratch copy's `accessible`, widths, `mad_m3s` (the flow load) and the near-river table. So a cache key is species,
  stage, `config_sha`, the schema's run, fresh's version, the flow load, and the regeneration code.
- CH's near-river pair is on the through-wetland rule only, which the tuned base drops: the tuned predicates never
  read the near-river table (checked on link origin/main, cw and mad). So a `default` cache hit for CH would also skip
  fresh's walk — 58.6 worker-min of CH's 27.1 wall-min classify stage (#87's log). Re-check at run time, not assume.
- GR's tuned rule is `default`'s (`assert_default` proves the predicates equal), so its `door` regeneration duplicates
  `default`'s.

## Phase 1: Time every rule's stages inside the comparison

- [ ] `.knw_compare_bin()` (`R/compare_rules.R`) records seconds per group for the shared steps (scratch copy with its
      indexes; near-river walk) and per rule for classify (habitat table), overlay and connect, base R only (the worker
      must call no name of this package), and returns them beside `flags` and `walk_s`
- [ ] A pure helper sums the bins' records into one table per rule × stage (worker-minutes, share of the summed
      classify-overlay-connect time); `knw_compare_rules()` logs one line per rule and returns the table as
      `stage_minutes`. The existing `walk_s` line stays as written
- [ ] Tests in `tests/testthat/test-compare_rules.R`: the helper sums bins correctly and keeps every rule and stage
      (including a rule with zero seconds); the existing "worker function calls no name of this package" test stays
      green
- [ ] `0330`'s header names the new log lines (#110's stage lines)

## Phase 2: Measure CH rearing and BT rearing

- [ ] `data-raw/compare_stage_time.R`: on `SCHEMA` (default `fresh_default_20261017`) and `CONFIG_SHA` (default
      `102762da`), refuse off the host (`knw_db_latency_check()`) and on another run's schema (`knw_build_record()`
      against `knw_run_ledger("data/tune")`); run `knw_compare_rules()` on `KEYS` (default `CH_rear,BT_rear`), every
      group, `WORKERS=6`, from the published `data/tune/` curves and grades; log the per-rule stage table and each
      key's wall minutes to `scripts/logs/habitat/<date>_compare_stage_time.txt`, and which rules' predicates read the
      near-river table
- [ ] The same script holds each key's compare table to the tracked `data/compare/<key>_compare.csv` (km within a
      relative 1e-9, as `compare_parallel_check.R` does) when the live flow load equals the grade table's
      `discharge_load`, and says so when it does not, so the timing is shown not to have moved the results
- [ ] Run it on the host (~70 min); commit the log

## Phase 3: Record and park

- [ ] `research/database_builds.md`, "Comparing with a key's groups in parallel": the measured per-rule minutes for
      both keys, `default`'s share of the classify stage and of each key's wall time, the walk that only `default`
      needs, and the projected saving of a `default` cache on a full rerun (measured shares × the published per-key
      times, stated as a projection); replace "not yet measured"
- [ ] `data-raw/README.md`: a line for `compare_stage_time.R`
- [ ] #101's body: Phase 1 done with the numbers and the research link; the cache design above (key, per species ×
      stage, walk skip where no tuned predicate reads the near-river table, GR's duplicate, the
      `compare_parallel_check.R`-style identity check); parked until link's reworked stream layers are built
      (Al, 2026-10-28)
- [ ] #112's body: its step 1 is this measurement, with the numbers and link; its step 2 decision now has them

## Owed at the end (reported, done after merge)

- [ ] Build #101's cache when link's reworked stream layers are out and Al says so (in #101's body)

## Validation

- [ ] Tests pass (`devtools::test()`), lintr clean on the changed files
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion; archive README carries `## Measurement` and `## Evidence`
      (`scripts/logs/habitat/*_compare_stage_time*`)

**Verification:** the helper's unit tests; the measurement run's compare tables identical (within 1e-9 relative) to
the tracked ones where the flow load matches, proving the instrumentation changed nothing; the per-rule minutes sum to
within a few percent of the logged classify-overlay-connect stage × workers (the stages not timed are the gap, stated).

