# Database builds: what a retune reads, where it can run, and what a second database needs

**Verified:** 2026-10-27, and the round-trip check and the structures a comparison runs 2026-10-28 · **Issues:** #87
(from #73's run times; #85 and #86 folded in or left open below), #110 (the round-trip check), #112 (the structures) ·
**Produced by:** `data-raw/walk_batch_check.R` (logs `scripts/logs/habitat/20261026_walk_batch_check*`),
`data-raw/compare_parallel_check.R` (`20261026_compare_parallel_check*`), `data-raw/compare_structures_check.R`
(`20261028_compare_structures_check*`), the timed retune on the database's host
(`20261026_tune_run.txt`, `20261026_tune_run-warm.txt`, `20261026_compare.txt`, `20261026_compare-gpkg.txt`;
#73's `20261024_*` and `20261025_*` for the before), and the table sizes read from the host's catalog on 2026-10-26.

## The answer

A retune (`0320` grading, then `0330` comparing) now takes about 4 min to regrade the key being tuned and 4 to 37
min to recompare it, on the database's own host. A cold regrade of every key takes 53 min (191 before) and a
recompare of every key 2.9 h with its GeoPackages (2.7 h before, for one key fewer: the database's cores were
already the limit). Those comparisons ran every through-wetland structure; since #112 a run compares `door` alone,
whose dropped rules were 29 to 33 % of the worker minutes on three keys (below). Grading can now also
run from a machine on a remote link: a batched walk cost 12 to 18 ms there, against about 3 ms on the host and 116
ms one query per walk over the same link. The comparison still belongs on the host, or on a second database that holds the
same build. `0320` and `0330` refuse a schema built by another run before any work, and refuse or regrade a grade
table walked by other code or on another flow load. `0310`, a grading `0320` and `0330` also measure the round trip at
connect (`knw_db_latency_check()`) and stop over 20 ms unless `REMOTE=TRUE` (#110), so a run off the host, grading
included, is a choice its log records.

## Why a query's count matters more than its size

**The principle.** Every query a script sends pays a fixed toll beside the work it asks for: the trip there and
back, and setting up and reading each answer. On the database's host the toll is about 1.6 ms; over a remote
link it was 104 to 110 ms (2026-10-24, 2026-10-26). The walk itself, the work the query asks for, costs about 2.9
ms inside the server. So a script that sends one query per segment pays the toll 2.68 million times for bull trout,
and from a remote link the toll is nearly all of the time. Sending 500 segments in one query pays it once per 500.

What that measured, on one watershed group's grade starts (BULK, `pick`, 8 workers; ms per walk per worker):

| where | one query per start | 500 starts per query |
|---|---|---|
| the database's host | 6.71 (chinook, q 3), 7.28 (bull trout, q 10) | 2.65, 3.15 (alone) |
| a machine on a remote link | 116 (300 visit starts) | 17.5, 11.7 |

Every batched run returned every start, identical to the one-query reference on all 14 columns. On the full bull
trout rearing grade (2,681,583 starts, the host, alone) a batched cold walk cost 4.67 ms per walk per worker,
against 8.2 ms on #73's run: the walk's own server cost is now most of it, which #85 (one walk pass per river size)
is the fix for.

## Not walking twice: the walk cache

**The principle.** A segment's walk to a river of a given size depends on five things only: the segment, the river
size, the flow source, the flow load and the walk's code. Nothing about the species or the rule enters it. So a
walk kept under those five keys is the same walk the next time anyone asks, and bull trout spawning, which walks
the same 2.68 million segments to the same 10 m³/s river as bull trout rearing, should walk none of them.

`knw.walk_cache` keeps each walk under exactly those keys: the flow load as the md5 of the flow table's comment (the
comment names wet's build, CLAUDE.md "The segment flows can change under a run"), and the walk's code as the md5 of
`inst/sql/ch_dist_profile.sql`. A row under another load or another walk is never read. After the cold regrade of
every key it held 4,459,402 walks of 3,606,831 starts (sizes 3 and 10 m³/s, `pick`), 1,595 MB with its index.
What it bought:

- Bull trout spawning, regraded right after rearing: 2,681,583 walks read, 0 walked; its grading 2.8 min, against
  48.2.
- Every later key that walks to 10 m³/s reads most of its walks (from coho's 373,154 of 615,302 to steelhead's
  703,705 of 720,768), because species share segments; chinook, the one key walking to 3 m³/s, walked all of its
  856,244.
- One key regraded after a curve or pick change: the whole `0320` run 4.1 min, against that key's 48.2 min of
  grading before.

1,000 cached walks re-walked with the cache off were identical on all 14 columns. The cache treats the FWA
tables the walk reads as fixed: a reload of `whse_basemapping.fwa_stream_networks_sp`, or of the river, lake, manmade
waterbody and wetland polygons it measures the bank on, means emptying the table, because no load of them is recorded.

## Comparing with a key's groups in parallel

**The principle.** `0330` regenerates link's habitat flags for each rule, one watershed group at a time, and each
group's work runs in one database process, so one key used one database core however many the server had. Running
several keys at once used more cores, but the key being tuned still took as long. Splitting a key's groups across
six connections, each with its own scratch schema, gives that one key every core.

| key | groups one after another (#73, keys sharing 6 workers) | groups on 6 workers, keys in turn (#87) |
|---|---|---|
| BT rearing | 160.0 min (143.3 with one other key) | 33.4 min |
| CH rearing | 150.9 | 37.1 |
| BT spawning | 130.6 | 24.9 |
| CO rearing | 94.6 | 26.3 |
| ST rearing | 62.2 | 14.9 |
| RB rearing | 56.0 | 12.6 |
| GR rearing | 49.6 | 9.3 |
| WCT rearing | (not in that run) | 4.5 |
| every key | 160.1 min, 7 keys, GeoPackages inside | 162.9 min, 8 keys, plus 14.0 min of GeoPackages |

The #73 times include each key's GeoPackage (4 to 17 min) and the other keys' contention, so the per-key ratios
overstate the change. On the two keys checked against the one-connection code (WCT rearing's 16 groups, CH
rearing's 20 largest), every segment's flags were identical and the km sums agreed within 1.04e-13 relative; the
full run's tables matched the tracked ones within 2.6e-13. The whole recompare did not get faster, because the
database's cores were the bound both ways: classify, overlay and connect is 115 of its 163 min. Regenerating
`default`'s flags, unchanged on every rerun, is the next cut (#101), not yet measured.

## Comparing only the structure that is published

**The principle.** Each through-wetland structure (`free`, `door`, `door_wetland`, #73) is one more rule: link's three
stages are run again on every group the key covers, while the group's copy and indexes, and chinook's walks to a river,
are shared by every rule. Only `door` is published, so since #112 `0330` regenerates `default` and `door` alone, and
`STRUCTURES=all` brings back the others. Dropping a rule saves its own stages and nothing else.

| key (groups) | structures | every structure | `door` alone | dropped rules' share of worker minutes |
|---|---|---|---|---|
| WCT rearing (all 16) | `free`, `door` | 4.5 min | 3.2 min | 33 % (6.1 of 18.4) |
| CH rearing (20 largest) | `free`, `door`, `door_wetland` | 16.6 | 12.6 | 31 % (17.6 of 56.6) |
| BT rearing (20 largest) | `free`, `door` | 9.9 | 7.0 | 29 % (13.2 of 44.9) |

Each rule cost 5 to 19 worker minutes, against 0.7 to 1.4 for all the groups' copies and indexes, and CH's walks
about 20. The `door` alone run went second, on a cache the first had warmed, so its wall times flatter it a little;
the worker-minute shares come from the every-structure run alone. A first pass (`20261028_compare_structures_check.txt`
and `-2`) overlapped a link run on the same database until 22:18 UTC for WCT and the start of CH; the rows above are
the reruns on an idle database (`-2` for BT rearing, which started after it, `-3` and `-4`). The contended pass read
31 % for CH, as the rerun did, and 35 % for WCT against the rerun's 33, on other inputs (#92's staged tables against
the host's own), so it cannot tell contention from inputs. Applied to #92's minutes for classify, overlay and connect
(from the remote link), key by key, the shares come to about 46 of its 164, 28 %: CH 31 %, BT rearing's 29 % for RB,
WCT 33 %, and for CO and ST, which drop two rules like CH but walk to no river, CH's dropped rules' share of its
minutes without the walks, 47 % (17.6 of 37.1); BT spawning and GR have only `door`. RB, CO and ST borrow another
key's share, and CH and BT rearing were timed on their 20 largest groups, so the 46 is an estimate on those choices. On every key the `door` alone tables equalled the every-structure run's `default` and `door` rows
(largest relative difference 9.9e-14, segments' flags identical). WCT rearing's every-structure run also equalled
#92's tracked tables row for row (1.7e-14), on fresh 0.44.0 where #92 ran 0.43.0, from #92's grade, curve and
evidence tables staged for the first pass. The reruns read the host's own older tables (2026-10-25's picks), which time
the rules as well as #92's would, and so differ from the tracked tables as they should (`-4`).

## What a run reads from the database

| what | where | size on the host (2026-10-26) |
|---|---|---|
| link's segments, habitat and access per species, and the run that built them | `<schema>.streams`, `streams_habitat_<sp>`, `streams_access`, `log_recompute` | 32 GB (`fresh_default_20261017`) |
| wet's segment flows and the comment naming their build | `discharge.fwa_v1_segment_monthly` | 41 GB (the `discharge` schema 49 GB) |
| the FWA network, lakes, rivers, wetlands, reservoirs, groups, modelled widths, upstream areas, precipitation | `whse_basemapping.*` (fwapg) | 39 GB |
| fish observations for the outside check | `bcfishobs.observations` | 227 MB |
| the walk cache | `knw.walk_cache`, `knw.walk_cache_load` | 1.6 GB |

`0330` also runs fresh 0.42.0's `frs_near_river()`, `frs_habitat_overlay()` and `.frs_run_connectivity()` on
scratch copies, so fresh's version is part of the build. `knw_build_record()` reads the schema's run, the flow load,
the walk's md5 and fresh's version; `0320` and `0330` refuse a schema whose run is not the evidence ledger's at
connect (both refused `fresh_default`, rebuilt by another run, on 2026-10-27), and every grade table carries the
flow load and walk md5, which `0320`'s keep-check, `0325` and `0330` compare.

## A second database

A second machine helps a database-bound step only with a database of its own holding the same build: the schema
from the same link run, the flow load named by the same comment, and the same FWA load. The walk is not part of
it: every connection creates it from this package's `inst/sql/ch_dist_profile.sql`, so it travels with the code. Loading one means:

1. link's schema: a `pg_dump` of `<schema>` from the host restored under the same name (its `log_recompute` carries
   the run, which is what the check reads).
2. wet's flows: `wet_db_load()`, which writes the table and its comment; the comment must match the host's, or every
   grade regrades and every cached walk misses.
3. fwapg's `whse_basemapping` load, and `bcfishobs` for the outside check.
4. Optionally the walk cache, dumped and restored, under the same flow load.

That is about 110 GB of tables to move or rebuild before the first run, against a database that serves other work.
The load time was not measured. Scoring needs none of it (it is CPU work on the visit tables: about an hour for
every key on 12 workers of a remote machine, 2026-10-23), and grading from a remote link now costs about 12 to 18
ms per walk where it cost 116, so a second database pays off only for the comparison or for runs at the same time
as the host's.
