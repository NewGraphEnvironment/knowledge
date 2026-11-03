# Findings — Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

## Issue context

**If we do it:** we learn how much the places link cuts streams (fish records, crossings, habitat end points) move each species' tuned thresholds, starting with chinook rearing, and we can map where the habitat drawn differs, so the trade-off between tuning on an ideal network and deploying on a connectivity network is measured and stated. **If we never do:** every threshold rests on segments partly cut at the catches that score it, and nobody can say whether that matters or where.

## Problem

From #92 the tuning reads link's segment gradient. link cuts a segment at fish records of the species it models, so the gradient at a site that caught fish is averaged over a stretch that starts there: on the tuning's stream branch 86 % of visits with a catch start a segment of their own against 10 % of empty ones (median 113 m against 305 m; link 0.66.0's build, every observation a break). Crossings and habitat end points cut segments too: not at catches, but at places unrelated to the stream's form. Chinook rearing's rule moved when the gradient source changed (#92), so the tuning is sensitive to how segments are cut.

Tuning on segments cut only at barriers and access gradients removes the catch from the predictor. But link deploys a rule on its full network, where segments are shorter and their gradients differ, so a rule tuned on the minimal network does not transfer cleanly unless each full segment carries its minimal parent's gradient. That is link's half: NewGraphEnvironment/link#415, with outputs named from NewGraphEnvironment/link#414. The minimal network still cuts at access gradients, and those cuts depend on which species link models and at which classes (0.15, 0.20, 0.25), so pausing a species (NewGraphEnvironment/link#432, NewGraphEnvironment/link#433) or changing a class moves the segments a minimal-network tuning reads; #132 reviews the classes themselves.

## Proposed

- [x] The minimal network: NewGraphEnvironment/link#415 (closed) built `default_minimal` (link 0.78.0, fresh 0.52.0). Parent attributes on the full network moved to NewGraphEnvironment/link#444 (open); its prototype is link's `data-raw/logs/minimal_breaks_415/parent_<wsg>.csv.gz`, each full segment with its minimal parent's gradient and length.

### Before the province-wide minimal run: test on link's four groups

link's proof schema `zz415_minimal` holds the minimal network for BULK, SETN, MORK and COTR, recomputed, with the tables a provincial build writes, and every log row carries the tokens `cut-min acc-v5 grad-seg q-fwapg`. `zz415_default` holds the same groups on the full network from the same commit. Both are scratch: pass the schema as `SCHEMA=`, never hard-code it, and point at `fresh_default_minimal` once the provincial run lands. link's caveat: each group was built without its downstream neighbours, so only access read through another group's dams may be incomplete. Species: the run's list, BT, CH, CM, CO, GR, PK, SK, ST and WCT (no RB or KO). Four groups hold too few records for a threshold, so these check mechanics, not results.

The four-group test ran on 2026-11-02; each result, its log and what four groups cannot show are in `research/minimal_network_tuning.md`.

Clear first (from the code, 2026-11-02):
- [x] `0310` runs only after `0300` released, and `knw_build_record()` refuses a schema built by another run: give the test run an explicit, logged override that is never the default. **Done:** `0300` takes `SCHEMA` and `POLL_MIN` and writes both on every row; `0310` takes that log with `SETTLE=` and ledgers it as an override. The gate stays the log's `run_uid`, never its schema, because a provincial schema is renamed after its run
- [x] The test database holds what `0310` reads besides the schema: wet's segment flows with a table comment naming `scenario historical` (`knw_discharge_load()`), cabd, bcfishobs and the FDIS tables. Run on the database's own host. **Done:** the database the proof schemas live in holds all of them (wet's load of 2026-10-15, not the 2026-10-19 load the published grades name); every command reached it with `PGSERVICE` and a 1 ms round trip
- [x] link's tokens land in `log_recompute`'s `token_cut`, `token_acc`, `token_grad` and `token_flow`, which `knw_build_record()` reads, and the grade record writes them. **Found otherwise:** link writes them on `<schema>.log`, not `log_recompute`, so every tokened build had recorded none. `knw_build_record()` reads them over every `log` row now (`cut-full-top.acc-v5.grad-seg.q-fwapg` and `cut-min.acc-v5.grad-seg.q-fwapg`)

Checks, `zz415_minimal` against `zz415_default`:
- [x] Placement: every FDIS visit in the four groups lands on both networks at the same stream and measure; only the segment id differs. **Holds:** the same 2,082 visits, blue line, measure and Atlas line; the columns that differ are the segment's own, access codes and habitat flags
- [ ] The premise: `data-raw/segment_gradient_check.R` on both networks. On link 0.66.0's full network 86 % of visits with a catch started a segment of their own against 10 % of empty ones; on the minimal network that gap should close. If it does not, stop here. **Closes:** on link 0.78.0's full network of the four groups 52.0 % against 5.8 % of stream-branch visits; on the minimal network 2.8 % against 1.5 %, both medians 742 m
- [x] Access: `knw_link_access_check()` per species. A difference anywhere but at dams read through a neighbouring group is a finding. **None:** accessible km are equal in every species × group cell (the check is per group now). Access codes differ at 141 visit × species pairs, each 1 on the full network and 2 on the minimal; none crosses zero
- [x] Walks: the cache is keyed on stream and measure, so visit walks are reused, and walks from a segment's downstream end miss where segments lengthen. The walk results themselves do not change. **Holds:** `walks.csv` and `visits_species.csv` byte-identical; the minimal build read all 5,724 visit walks from the cache, and bull trout's grade walks on the full network found 84 % there
- [x] `DEV=1 SCHEMA=zz415_minimal SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT 0320`: all four smoke gates pass for every key, a key with no records in these groups says so rather than failing, and minutes per key are logged to time the provincial run. **Done** at `MIN_WSG=4 FOLDS=4` (the tuning's floors are 5 and 5; `0320` takes both now, each summary records them, and promotion refuses any other): bull trout rearing is the one key with four groups holding both outcomes, and its gates pass; every other key says `too_few_groups`, `no_response` or `no_stream_rule`. The run logs 0.2 min for all 18 keys, not minutes per key
- [x] `0330` for CH rearing on the minimal schema: does `default`, regenerated through all three stages, reproduce link's stored km (rearing BULK 2,205, COTR 1,419, MORK 2,528, SETN 1,018)? If not, know why before the province. **Not on chinook:** it has both outcomes in three groups, and at three folds the smoke gate refuses it (a rule coefficient of 20.0 on one fold, against a limit of 5). Run on bull trout rearing instead, on both schemas: regenerated `default` equals link's stored km in every group. The chinook figures above are the minimal schema's stored rearing; the full schema stores 6 to 104 km less per group. The chinook check moves to the province, below
- [x] The parent join: every full segment gets a parent from `parent_<wsg>.csv.gz`, and "full, parent gradient" picks the same rule as "minimal" (the setups below). **Holds:** every visit's parent is the minimal segment it sits on, none on a full segment straddling a minimal break; on bull trout rearing the two setups give byte-identical scores and curves (`0310`'s `PARENT_DIR`, `0320`'s `GRADIENT=parent_gradient`)

Then the province, once `fresh_default_minimal` lands (NewGraphEnvironment/link#441), on a second branch of this issue:
- [ ] Wet's current flow load in the database the provincial minimal build lives in, so the published and minimal setups read one load
- [ ] `0300` → `0310` on `fresh_default_minimal` (`EVIDENCE_DIR=data/fdis/derived_minimal`) and `DEV=1 0320` with the same species, and the pick report (each key's pick beside the published one), reported. The full retune and any promotion wait on Al's word
- [ ] `0330` for CH rearing on the minimal schema: regenerated `default` against link's stored km

### Chinook rearing on every setup

- [ ] Chinook rearing, one key, scored on every setup from one evidence build and flow load, so the network and gradient are the only differences:

  | Setup | Segments | Gradient read |
  |---|---|---|
  | published | full | its own segment |
  | minimal | minimal | its own segment |
  | minimal, other access classes | minimal, cut at another access-gradient set (a species paused, or classes independent of species) | its own segment |
  | full, parent gradient | full | its minimal parent's |
  | Atlas line | full | the whole Atlas line (today's `grad_fwa`) |
  | fixed window | full | a fixed window (#70, when fresh provides it) |

  "Minimal" and "full, parent gradient" read the same gradient at every visit, so their picks should agree; where their drawn km differ is the transfer cost.
- [ ] Rerun #121's measured-gradient comparison on the minimal network's visit table, beside its full-network result (on the four groups: rank correlation 0.696 on both networks, chinook's 11 % limit flipping 8.5 % against 8.7 % of visits; the province follows the provincial build): `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=<minimal network's build> Rscript data-raw/site_gradient_check.R` (the full-network result is `scripts/logs/habitat/20261030_site_gradient_check.txt`). One run covers "full, parent gradient" too, since both read the same gradient at every visit. The difference is what link's cuts at catches do to how well the gradient a rule reads matches the gradient measured on site.
- [ ] Report per setup: the pick, whether the published rule is in its region, km drawn and graded, and a map of where the habitat drawn differs (a GeoPackage for QGIS, as `0330` writes, and one static figure).
- [ ] Each setup archived and indexed by #119's layout (`tune/CH_rear/<setup tokens>/`), its tokens from NewGraphEnvironment/link#414.
- [ ] `research/` gains what each break source does to the tuning, and the trade-off between the network a rule is tuned on and the one it is deployed on; the methodology article gets a short section once the result holds. Other species follow one at a time.

## Decided at the gate (Al, 2026-11-02)

- The four-group test runs on the database link's proof schemas `zz415_default` and `zz415_minimal` live in, reached with `PGSERVICE`; they stay until the provincial run fills `fresh_default_minimal`.
- Scope: the mechanics, the four-group test and its write-up land as the first PR; the province and chinook rearing on every setup run on a second branch of this issue when NewGraphEnvironment/link#441 and NewGraphEnvironment/link#444 land.
- link at 0.78.1 where the runs go (`0310` reads the installed `default` config for species range and pooling).
- No step of the test reaches the database the published build lives in; the latency check (#110) refuses one that lands there by accident.

Relates to #70 (fixed-window gradients), #92 (segment gradient), #121 (measured gradient), #119 (storage layout and run index).



## Where the inputs are (probed 2026-11-03 UTC, plan mode)

- m4's local database (`PGSERVICE=fresh_local`, 1.7 ms): `fresh_default_minimal`, 241 groups, 4,987,761 segments,
  `log_recompute` run `20261102_203300-60ab009d` (241 rows, ended 2026-11-03 00:15 UTC), `log` carries the four token
  columns; no `streams_parent` (link#444 open). `discharge.fwa_v1_segment_monthly` comment: wet's build of
  2026-10-15T02:06:57Z (`acb820f`). `knw.walk_cache` 135,933 rows under that one load (`walk_cache_load` one row).
  `fresh_default` there is a 30-group test schema. `whse_basemapping.fwa_watershed_groups_poly` 246 rows. 271 GB database,
  277 GB free on the disk.
- m1 (`PG*` from `~/.Renviron`, 137 ms): the published `fresh_default` (241 groups, run `20261023_074321-24d85e8c`),
  flow comment wet 2026-10-19T06:08:31Z (`94deeb5`), `knw.walk_cache` 8,274,143 rows; `fresh_default_minimal` exists
  with 0 segments (m1 was a worker of the minimal run, consolidated to m4).
- wet's live manifest: built 2026-10-24T12:23:01Z, wet 0.4.19 `b4bbc50`; `discharge/fwa/v1/manifest.json` has no older
  version in the bucket (`list-object-versions`: one version, id null), so the 2026-10-19 load exists only on m1.
- `data/fdis/derived` here is the published evidence build: its three md5s equal the published grades'
  `evidence_md5` (`1bd35829…;009698d7…;99f499bb…`). `data/tune/` and `data/compare/` here hold the published run's
  ignored files (CH_rear grades 3.5 GB, segments, the GeoPackages of 2026-10-28).
- Published CH rearing: rule `mad>=0.75|g<=0.11|Q3@D1000`, run `20261017_004619-3f4c713b`, link 0.66.0, tune run
  `published_20261028`, no tokens (untokened); archived under `tune/CH_rear/untokened/published_20261028/` with every
  other key (`data/archive_index.csv`).
- link 0.78.2 on origin/main is records only (no code change); 0.78.1 installed here. link's parent prototype
  (`data-raw/logs/minimal_breaks_415/parent_<wsg>.csv.gz`) covers the four proof groups only.
- Stale first-party installs (`check_pkg_stale.sh`): link 0.78.1 → 0.78.2, knowledge 0.4.20 → 0.4.23, cred 0.1.0 →
  0.7.0, fly, mc, ngr, spacehakr, xciter. None of them bears on this branch's scripts (`pkgload::load_all()`).

## Phase 1: wet's 2026-10-24 build loaded on m4 (2026-11-03 UTC)

- Before: `pg_stat_activity` empty on m4's database; comment `… (built 2026-10-15T02:06:57Z, wet acb820f)`.
- `wet::wet_db_load(con, wet::wet_catalog())` (wet 0.4.33), 06:53:38 to 07:37 UTC, **43.5 min**; 43 parquet parts
  (23 wet_balance, 20 pcic_routed). Log: `scripts/logs/habitat/minimal_network_120/20261103_wet_db_load.log`.
- After: comment `wet_db_load(): discharge/fwa/v1/segment_monthly, scenario historical last loaded from …/manifest.json
  (built 2026-10-24T12:23:01Z, wet b4bbc50)`; `knw_discharge_load()` returns it. Rows per source are the same counts
  before and after (pcic_routed 43,901,481; wet_balance 58,889,207): the build moved values, not coverage.
- Autovacuum ran `VACUUM ANALYZE` on the table right after the load; 0310 waited for it.

## Phase 2: settle

- `0300` released at 06:55:55 UTC after three one-minute polls: run `20261102_203300-60ab009d`, 241 of 241 groups
  ended, churn 70,537,175, link 0.78.1 `193cb8aa`, fresh 0.52.0 `245c8d8d`, fwapg `9a62b0c2`.
  Log `scripts/logs/habitat/20261102_link_settle-fresh_default_minimal.csv` (named by m4's local date).
- Baseline tests before any run: 1,853 pass, 0 fail, 1 skip.

## Errors Encountered

| Error | Resolution |
|-------|------------|
