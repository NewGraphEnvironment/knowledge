# Database builds: what a retune reads, where it can run, and what a second database needs

**Verified:** 2026-10-27, the round-trip check, the structures a comparison runs and `default`'s cost 2026-10-28, and
"A second database" 2026-11-06 (#161's fix measured the same day; chinook regraded on both 2026-11-12, #165) ·
**Issues:** #87 (from #73's run times; #85 and #86 folded in or left open below), #110 (the round-trip check), #112 (the
structures), #101 (`default`'s cost), #158 (a retune reproduced on a second database; it spawned #161, fixed, and #162), #165 (chinook
rearing regraded on both after #161, with knowledge's receipts), #197 (the species column order, fixed) ·
**Produced by:** `data-raw/walk_batch_check.R` (logs `scripts/logs/habitat/20261026_walk_batch_check*`),
`data-raw/compare_parallel_check.R` (`20261026_compare_parallel_check*`), `data-raw/compare_structures_check.R`
(`20261028_compare_structures_check*`), `data-raw/database_compare.R`, `data-raw/database_walk_check.R` and
`data-raw/database_receipts.R` (`scripts/logs/habitat/database_second/`, #158), `data-raw/grade_receipt_compare.R`
(`scripts/logs/habitat/receipt_165/`, #165), the timed retune on the database's host
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
`default`'s flags, unchanged on every rerun, is the next cut (#101; below, measured but not built).

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

## Reading `default`'s flags instead of making them (measured, not built)

**The principle.** `default` is link's own rule, and its flags depend on nothing a retune changes: not the grades, not
the tuned pick, only link's configs, the build, the flow load, fresh and the regeneration code. So a rerun could read
them from the last run that shared all of those, and spend the database's cores on the tuned rule alone. Chinook gains
twice, because `default` is its only rule that reads the near-river table: under link configs `102762da` (fresh
0.44.0) CH rearing's `default` predicate reads it on both flow models, and neither the tuned rule's base nor spawning's
predicate does (built from the configs on 2026-10-28; `0330` logs the rules that read it on every run), so reading
`default`'s flags would skip the walk that fills the table as well. No other species' `default` walks to a river.

What `default` costs, from #112's worker minutes on an idle database (the every-structure run, with the structures
`0330` no longer runs taken out, so the rest is what a run since #112 does; the `door` alone run gives the same shares
within 4 points):

| key (groups) | copies and indexes | walks | `default` | `door` | `default`'s share (with the walk) |
|---|---|---|---|---|---|
| CH rearing (20 largest) | 1.2 | 19.5 | 9.3 | 9.0 | 74 % (28.8 of 39.0) |
| BT rearing (20 largest) | 1.4 | 0 | 19.2 | 11.2 | 60 % (19.2 of 31.8) |
| WCT rearing (all 16) | 0.8 | 0 | 6.3 | 5.3 | 51 % (6.3 of 12.4) |

Projected onto #87's host run (115.2 min of classify, overlay and connect, less what #112 dropped: about 89 min, with
#87's CO and ST dropping `free` alone at BT's 29 %), key by key, these shares come to about 27 min on the three measured
keys, and 25 to 29 more on the other five (RB, CO, ST, BT spawning and GR, none of which walks), which borrow BT's and
WCT's 51 to 60 %: about 52 to 56 of the 89, so a full `0330`
of about 2.5 h since #112 would take about 1.6. It is an estimate three ways: CH and BT were timed on their 20 largest
groups, five keys borrow a share, and a stage's wall time is its slowest worker's, so a share of summed worker minutes
is its share of the wall time only when the bins are balanced. `0330` now logs each worker's minutes with and without
`default`'s own (and without the walk where only `default` reads the near-river table), and projects the saving as
the slowest worker's minutes less the slowest worker's without them (not necessarily the same worker).

**Not built (Al, 2026-10-28):** link's stream layers are being reworked, and a cache keyed on today's build would be
dropped at the next one before it paid. When it is built, its key is species, stage, link's `config_sha`, the schema's
run, fresh's version, the flow load (`knw_discharge_load()`) and the regeneration code; it is per species and stage
(BT spawning's `default` may equal BT rearing's, but the waterbody floors differ by stage, so stage stays in the key
until shown otherwise); it skips the walk only where `0330`'s "Rules whose predicate reads the near-river table" line
names `default` alone; and its proof is the one `data-raw/compare_parallel_check.R` and
`data-raw/compare_structures_check.R` make, a run reading the cache returning the same tables as one regenerating
`default`.

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

The first one (2026-11-05) moved about 71 GB as 8 GB of dumps plus one 14-minute flow load, in 66 minutes of moving.
Scoring needs none of it (it is CPU work on the visit tables: about an hour for
every key on 12 workers of a remote machine, 2026-10-23), and grading from a remote link now costs about 12 to 18
ms per walk where it cost 116, so a second database pays off only for the comparison or for runs at the same time
as the host's.

### The published retune, reproduced there (#158)

**The principle.** The same code run on the same build should give the same answer on any database, but only if
every choice it makes is decided by the data. A query that asks for "the nearest" row and stops at one leaves a tie to
the database: two rows at the same distance come back in whatever order that database's plan reads them, and two
databases built separately read them differently. So a second database is a test of the code as much as of the load.

The published run (`20261104_0543`) was rerun there at main (4060cb2) on 2026-11-06: `0310` into
`data/fdis/derived_second`, `0320` for chinook rearing and then every key (candidate `20261106_0423`, 8 workers), `0330`
for every key (`GPKG=FALSE`, `CONFIG_SHA` the published run's), and every output compared with the archived and tracked
copies (`scripts/logs/habitat/database_second/20261106_database_compare-*.csv`, one verdict per output: identical,
equivalent within a tolerance, or different).

| what | verdict |
|---|---|
| every key's pick | the published one, 7 of 7 |
| tuning scores, fold seeds, nested selection, curves, groups | byte-identical for every key |
| km drawn, lost and gained by every rule | equal to the host's |
| evidence: visits per species, walks, bcfishobs match, workbook tables | identical (walks read from the cache) |
| evidence: access check; change and checks tables; comparison tables of the keys with no moved grade | equivalent, at most 3.3e-9 km (summing order) |
| evidence: `visits_link` | different in `mad_pick` on 3 of 45,529 visits, at most 0.0029 m³/s (#161) |
| grade tables | BT spawning identical; GR equivalent (one rate on a rounding edge); the other five different in segment size on 40 to 441 segments each, moving 0 to 276 grades and 0 to 9 grade classes past 1e-5 (#161) |
| graded km in the comparison | different by up to 0.41 km per group (the moved grades) |
| a cold walk of every visit start and of 20,000 chinook grade starts | different: the target line on 12.6 % of visit rows, the distance by more than 5 mm on 0.05 % of them and on 0.12 % of grade starts (#162) |

Three kinds of `different` were expected before the run: each smoke table's `previous` row, which reads the pick the
published run itself promoted; the pick report, which the published run did not keep; and the evidence ledger's context
rows and the two rows current code adds. One was not: steelhead's smoke table names a different term for its largest
coefficient on the no-rule fit, two terms tied at 2.127217, which `0320`'s report breaks by order and no decision reads.
Every other `different` traces to one of two ties, neither of them a fault in the load (the FWA and flow rows and PostGIS
3.5.2 are identical on both databases):

- **`knw_link_flow()`'s parent flow (#161).** A segment with no flow of its own takes its nearest parent's, and where two
  parents are equally near (almost always both at 0 m) the database chooses. That moves the three visits' flow and,
  through each segment's size, the grades. Fixed in knowledge 0.4.32: the lower `linear_feature_id` takes a tie, in
  the parent lookup and in `knw_link_regulated()`'s dam snap, which had the same gap. The check
  (`data-raw/link_flow_tie_check.R`, logs `scripts/logs/habitat/database_second/20261106_link_flow_tie_check*`) read
  every line whose flow or codes come from a parent: 2,831 lines, 1,800 of them with two parents within 1e-6 m. Under
  the old code the two databases differed on 614 of those lines and on 2 dams. Under the new code they were
  identical, and no slower. The published evidence and grades were made with the old code. The change reaches the
  visits at the next `0310`, and the grades at their next grading on any build, because grading reads each segment's
  parent flow live (`knw_link_segments()`): about 630 parent-flow lines move on either database, all of them tied.
  `0320`'s keep-check does not compare the knowledge commit a grade record carries, so a candidate graded before 0.4.32 is regraded, not
  resumed with `RUN=`.
- **The walk's landing (#162).** A tributary's mouth usually sits on a vertex two main-line segments share, so both are
  at 0 m from it. Where one of the two has no flow row, the walk either stops at once or walks that segment's length
  down to the next. The host's own cold walk reproduces its cache exactly, so the two databases walk differently. A run
  that reads the walk cache never shows it: every walk in this run came from the cache (0 misses).

**After #161's fix, chinook rearing on both (#165).** On 2026-11-12 the evidence and chinook rearing were rebuilt at
one commit on each database, each grade on its own database's evidence, and compared through the receipts knowledge's
own writers make (`scripts/logs/habitat/receipt_165/`). The evidence builds shared one recipe and compared `equivalent`
(`access_check` 5.3e-11 km; `visits_link`'s `mad_pick` now the same on all 45,529 visits). The two chinook grade
receipts compared `identical`, the pick and the four totals bit for bit, and every segment's grade and length agreed:
the `different` this table records for chinook's grade table was the tie, and the fix removed it. Every walk came
from each database's cache, so #162 was not tested. The bytes of `visits_link` and `workbook_sites` differ with the
same values (#158 saw `workbook_sites`' too): their species columns come out in each database's catalog order (#197),
so `visits_link`'s md5, and with it the `evidence_md5` every grade table and summary carries, differs. #197 has since
made `knw_link_place()` sort the species by name, so these two tables carry one column order on any database. That
order is not the published build's (its ledger lists both species groups in catalog order), so the next evidence
build's two tables, and `visits_link`'s md5 in `evidence_md5`, differ from the published build's once, with the same
values, and then agree across databases. `0320` for chinook rearing took 14.0 min on the host (14 workers) and 17.2
min on the second (8 workers, beside another session's link tests).

What a run costs on each:

| step | second database | host |
|---|---|---|
| `0310` | 11.5 min wall (4 workers, walks from the cache) | walks 0.1 min; wall not recorded |
| `0320`, chinook rearing alone | 11.0 min (scoring 9.0 on 8 workers, grading 1.9) | (not run alone) |
| `0320`, every key (CH's score cache reused) | 50.1 min (scoring 40.0 on 8 workers) | 51.7 min (scoring 17.8 on 14) |
| `0330`, chinook rearing | 13.8 min on 6 workers | 14.0 min |
| `0330`, the other six keys | 36.2 min summed per key (CO 14.8) | 32.9 min summed per key (CO 10.8) |
| cold walk, every visit start | 2.3 min on 8 workers | (not run) |

Scoring is CPU work and ran at about the speed its worker count predicts. The comparison, bound by the database, ran
within a minute of the host's on every key but coho, which took 4 minutes longer. From here on a run on the second database is an ordinary run. Until #162 is fixed, its cold walks can differ from the
host's, and grades made before knowledge 0.4.32 can differ on the tied segments (#161), so a promotion takes all its
keys from one database.

