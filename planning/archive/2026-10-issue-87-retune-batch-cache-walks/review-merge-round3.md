# Review, merge round 3: `git diff d37e956..HEAD` (b0810ee, b951c09), branch 87-make-a-retune-fast-enough-to-iterate-bat

## Checklist read

- `code-check.md`: the prose of every H3 under `## Mechanisms`, tables skipped. Applied most closely: "A proxy is not
  the property" (the flow-load md5 standing for the flow rows), "Written data outlives the fix" ("a cache keyed by
  fewer inputs than the write depends on returns plausible wrong data ... over-key, never under-key"), "A guard's
  scope, escape hatches, and remedies" (terminate by enumeration), "One fact derived twice".
- `code-check-r.md`: "Postgres row order is never fixed unless the query fixes it" (the walk's `LIMIT 1` picks),
  "A value compared as `::text` in SQL has PostgreSQL's spelling", "Never name a durable artifact by a hash the
  library reserves the right to change" (headings checked; the md5s here are `tools::md5sum` and Postgres `md5()`,
  both stable).
- Read-only database probes (session set `default_transaction_read_only = on`), 2026-10-27: the flow table's comment,
  its scenarios, its forcings and sources, a sample of its periods, and the extension versions.
- wet's loader read at wet `2dc95cb` (`R/wet_db_load.R`, `R/wet_catalog.R`), because the cache key's flow-load term
  is the comment that loader writes.

## Enumeration: everything the walk reads, and how the cache covers it

Cache key: `blue_line_key`, `downstream_route_measure`, `src`, `qmin`, `load_md5` (md5 of the flow table's comment),
`walk_md5` (md5 of `inst/sql/ch_dist_profile.sql`). (a) in the key; (b) fixed in the walk's code, so in `walk_md5`;
(c) named in the caveat as a truncate-by-hand case; (d) none.

| Input | Where read | Class | Notes |
|---|---|---|---|
| `start_blk`, `start_m` | function args, from `unnest($1::integer[], $2::float8[])` | (a) | The row stores the server-parsed values from the same unnest it walked. |
| `qmins` | `$3::float8[]` (all of `q_grid`) | (a) per row as `qmin` | A size's row does not depend on the other sizes in the array: the path (`cur_blk`, `cur_m`, `d`, `hops`, `gap`, `bank_wb`) is the same whatever `todo` holds, termination is a property of the path, and a size's row is fixed when it is found or when the walk stops. So keying per size is sound. |
| `src` | `$4` | (a) | Validated in SQL and by `chk_subset`. |
| `whse_basemapping.fwa_stream_networks_sp` (`linear_feature_id`, `blue_line_key`, `downstream_route_measure`, `upstream_route_measure`, `edge_type`, `waterbody_key`, `wscode_ltree`, `watershed_key`, `geom`) | target search, connector sums, mouth, parent search, coast test | (c) | |
| `whse_basemapping.fwa_rivers_poly`, `fwa_lakes_poly`, `fwa_manmade_waterbodies_poly`, `fwa_wetlands_poly` (`waterbody_key`, `geom`) | the jump's crossing of the landing polygon (sql:158-161) | (c) | Named since b951c09. These are the only other relations the SQL reads. |
| `discharge.fwa_v1_segment_monthly` (`linear_feature_id`, `scenario`, `month`, `pick`, `source`, `q_m3s`) | target search join | (a) through `load_md5` | `load_md5` is the md5 of the table's comment, not of its rows. See the finding: the comment names the last scenario loaded, not the `historical` rows the walk reads. |
| same table, `forcing`, `period` | not filtered | n/a today | Measured 2026-10-27: one forcing per source (`climr`/`wet_balance`, `PNWNAmet`/`pcic_routed`), one period in a 200,000-row sample of `historical`/month 0. A second forcing or period could only arrive by a load, which rewrites the comment. |
| constants: `scenario = 'historical'`, `month = 0`, the source list, excluded edge types (1100, 1150, 1300, 1350, 2300, 1400, 1450), connector types (1400, 1450), hop cap 60, gap tolerance 0.001 | the SQL | (b) | |
| The R-side query around the walk (`from`, `sql`, the insert) | `R/link_walks.R:99-115` | not in `walk_md5`, but passes only keyed values | The function takes exactly (start, qmins, src); the insert names its columns, so `.knw_walk_cache_cols` order does not matter. |
| `batch`, `workers` | R | no effect on a row | Round 2. |
| link's `<schema>` (`fresh_default*`) | not read by the walk | n/a | `knw_grade_species()` reads the schema only to choose the starts, which are the key. A schema renamed or rebuilt changes which starts are asked for, not what a start's walk returns. |
| PostGIS and ltree functions (`ST_Force2D`, `ST_StartPoint`, `ST_LineLocatePoint`, `ST_Distance`, `ST_ClosestPoint`, `ST_MakeLine`, `ST_Intersection`, `ST_Length`, `<->`, `nlevel`, `subpath`) and their versions (PostGIS 3.5.2, ltree 1.3) | the SQL, resolved through `search_path` | (d) | Note only: an extension or GEOS upgrade can move a distance in its last bits or flip a nearest-line tie; not a practical risk to a grade. Tables are schema-qualified and the walk is called as `pg_temp.ch_dist_profile`, so `search_path` reaches only the extension functions. |
| Plan and row order at two `LIMIT 1` picks without a unique tiebreak | sql:124-125 (`wscode_ltree ... LIMIT 1`, no `ORDER BY`), sql:141 (`ORDER BY s.geom <-> mouth.pt LIMIT 1`) | (d), pre-existing | Note only, below. |

## Findings

- **[severity: fragile]** `R/link_walks.R:253-257` with `knw_discharge_load()` (`R/link_walks.R:283`) — the cache's
  flow-load term does not identify the rows the walk reads once a second scenario is loaded. wet's loader writes
  one table comment per load, naming that load's scenario only (`wet_db_load(): <dataset>, scenario <s> last loaded
  from <manifest> (built <t>, wet <commit>)`, wet `R/wet_db_load.R:164-176`). wet documents `ssp245` and `ssp585` as
  coming (`R/wet_catalog.R:17`), and each `wet_db_load(scenario = "ssp245")` replaces only that scenario's rows and
  rewrites the comment. The walk reads `scenario = 'historical'` only. So with an ssp loaded last, the comment names
  the ssp's build. Two different `historical` contents can then share one comment: historical at build B1 with
  ssp245 loaded from B2, and later historical reloaded from B2 with ssp245 reloaded from B2, both read
  `scenario ssp245 ... built B2`. The `load_md5` is the same, and every hit returns walks made on B1's flows. They are
  plausible and wrong, and nothing reports it (the "keyed by fewer inputs than the write depends on" shape). Today
  the table holds only `historical`, and its comment names it (probe 2026-10-27), so nothing cached is wrong yet.
  The same proxy sits under the grade tables' `discharge_load` and `0325`'s comparison, but those re-read live rows
  at each run. The cache keeps old results, so it is the place where the gap returns wrong data rather than a
  mislabelled run.
  Remedy, if wanted: have `knw_discharge_load()` refuse a comment that does not name `scenario historical`, since
  the walk, `0310` and the grades read only that scenario. That makes an ssp-last load a loud stop, not a silent key
  collision. Also surface the one-comment-per-table limit to wet (first-party), for example a per-scenario load
  record.

## Notes, not findings

- **b951c09's text is accurate.** The four polygon tables it names are the only relations the SQL reads besides the
  network and the flow table. `man/knw_link_walks.Rd` matches the roxygen line for line. `research/database_builds.md`
  says the same. `knw_build_record()` records no FWA load, so "carry no load record" is true.
- **The archive README's sentence** (`planning/archive/2026-10-issue-87-retune-batch-cache-walks/README.md:56`,
  "the walk cache returns identical walks") still has no condition attached. Round 2 suggested "while the FWA load is
  unchanged". It is planning prose, not code.
- **Two `LIMIT 1` picks in the walk have no unique tiebreak** (pre-existing, not in this diff). The parent search
  `ORDER BY s.geom <-> mouth.pt LIMIT 1` ties at distance 0 wherever the mouth point is the node shared by two parent
  segments. The two candidates give `m` values that differ by the FWA measure gap (millimetres, fwapg#43). On the
  lower segment, the segment just above the confluence can become a target at distance 0. That changes `large_lfid`,
  `large_mad` and possibly `large_waterbody_key`, but not `dist_m`. The cache freezes whichever outcome the first walk
  got, so it makes runs more repeatable, not less. The cache-off identity check on 1,000 walks shows the plan was
  stable on one database. I did not measure how often the tie occurs, or whether the two outcomes really differ.
  `SELECT c.wscode_ltree ... LIMIT 1` has no `ORDER BY`, but it relies on a blue line's segments sharing one code,
  which the comment states.
- `research/database_builds.md` step 4 ("Optionally the walk cache, dumped and restored, under the same flow load")
  does not repeat "and the same FWA load". The paragraph's opening sentence requires it, so this is not a defect.
