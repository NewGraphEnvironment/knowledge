# Findings — Cache link's default flags in the comparison (#101)

## Issue context

## Problem

A full `0330` still takes 2.9 h on the database's host after #87: 162.9 min (2.7 h) for eight keys with `GPKG=FALSE`, groups on 6 workers, then 14.0 min of GeoPackages (2026-10-27, `scripts/logs/habitat/20261026_compare*.txt`). #87's plan set the bar at 60 min on 6 workers for a follow-up; this is it.

The time is the database regenerating link's habitat flags. Classify, overlay and connect is 115.2 of the 162.9 min (BT rearing 27.4 of 33.4). The database's cores are the limit: before #87, seven keys running at once took 160.1 min, and now one key at a time on six connections takes about the same for all of them. What changed is the time to see one key (4 to 37 min).

Part of that work repeats on every rerun: link's `default` rule is regenerated unchanged for every key, every time. It is one of three rules for most keys (`default`, `free`, `door`), one of two for BT spawning and GR (whose tuned rule is `default`'s own for GR), and one of four for CH. If every rule cost the same, `default` would be about 41 of the 115 classify minutes. That is an estimate, not a measurement.

## Proposed

1. **Measure first.** Time `default`'s three stages (classify, the user-habitat overlay, connectivity) per group against the tuned rules' on one key (CH, which walks near-river pairs, and BT rearing, the slowest), so the saving is a number before anything is built.
2. **If it pays:** keep `default`'s regenerated flags per species, stage, link config commit (`config_sha`, resolved to the full commit since #87), the schema's run, fresh's version and the flow load, in a table like `knw.walk_cache`, and read them where every key now regenerates them. Each key that tunes to `default` (GR) would also skip the duplicate regeneration.
3. **Check:** one key's tables with the cache and without, identical row for row (`data-raw/compare_parallel_check.R`'s comparison).

Not here: the cold grading walk (#85). #112 times every rule's three stages on CH and BT rearing; one measurement serves step 1 here and #112's, so run it once. A new link build resets this cache, so it speeds reruns on one build, not a run per link change (#111).

Found by #87's Phase 4 measurement (`research/database_builds.md`, "Comparing with a key's groups in parallel").




## Errors Encountered

| Error | Resolution |
|-------|------------|
| `test-vignette-data.R:115` fails: one test block, 12 expectations (first counted as 8) | Expected on this machine: `method.rds` pins the md5s of #92's ignored inputs, and this host's 7 `data/tune/*_grades.csv`, `data/fdis/build/reconcile.csv` and 4 `data/fdis/derived/*.csv` are an older build (#112's archive found the same). CLAUDE.md: fails "there and nowhere else"; CI has no `data/`. Not this branch's; every other expectation passes (1648) |
| A `python3 - <<EOF` (unquoted) with Markdown backticks in its body ran each backticked word as a command | Nothing existed under those names and the first assertion stopped the script before any write; reran with `<<'EOF'` and the path through the environment |

## Collision with #112's branch (2026-10-28 22:20 UTC)

A parallel session has `origin/112-compare-only-default-and-the-reported-st` (6 commits). Its e533fb6 instruments
`.knw_compare_bin()` too: `setup_s` (copy and indexes), `walk_s`, and `rule_s` per rule (classify, overlay, connect and
read together), logged as "Summed over workers: …" and returned as `worker_minutes`. That is this branch's Phase 1 in
another shape, in the same lines. Its `data-raw/compare_structures_check.R` was launched on the host at ~21:56 UTC
(WCT done at 22:06; CH_rear and BT_rear on their 20 largest groups, every structure and reported-only, running from
22:06). Its per-rule minutes carry `default`'s cost, which is #101's measurement ("run it once").
This branch's measurement was not run: it would contend with that run on the database's cores. Escalated to Al:
which body of work survives.

## Resolution: #112 first (2026-10-29 00:13 UTC, PR #116)

Merged origin/main; #112's timing stands, this branch keeps `.knw_bin_minutes()` (with `walk_dropped`) and the
near-river line on it. `default`'s cost was read from #112's committed logs, not a second run. Checked at link
configs 102762da with fresh 0.44.0 by building every fitted species' predicates: only CH rearing's `default` reads the
near-river table, on both models. The branch review's round 3 named the mechanism behind rounds 1 and 2's prose
defects (one computation restated by hand in six places, each re-derived alone); the fix makes the roxygen the one
definition, and an enumeration of the nine restatements that remain closed the loop.
