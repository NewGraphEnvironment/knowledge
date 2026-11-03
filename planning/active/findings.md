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

## Phase 2: evidence on `fresh_default_minimal` (2026-11-03 UTC)

- `0310` 08:09 to 08:32 UTC (23 min), round trip 0.9 ms. Ledger
  `scripts/logs/habitat/20261103_evidence_build_ledger-derived_minimal.csv`; console
  `minimal_network_120/20261103_evidence_build.log`. Build record: schema `fresh_default_minimal`, run
  `20261102_203300-60ab009d`, flows wet 2026-10-24 (`b4bbc50`), walk `c3f7bdbe…` (the published build's walk md5),
  installed fresh 0.53.0 (the build ran on 0.52.0), tokens `cut-min.acc-v5.grad-seg.q-fwapg`. `schema_species`:
  the run modelled 9, this build carries 11 (KO, RB paused; expected).
- 45,529 visits placed (the published build's count); walks 36,928 starts × 3 sources × 7 sizes, all cold on the new
  load (110,784 pairs walked, 4.7 min on 4 workers); `walks.csv` 775,488 rows, the published count.
- **Placement** (`minimal_network_check.R`, steps 1-2 from the console,
  `minimal_network_120/20261103_minimal_network_check_console.log`; it stops at step 3 as planned):
  - the same 45,529 visits, every one at the same blue line, measure and own Atlas line (`linear_feature_id`).
  - 172 visits (BABL 22, UPCE 13, LPCE 12, …) sit on a minimal segment whose `segment_linear_feature_id` is another
    Atlas line: a minimal segment that runs across Atlas lines keeps one line's id. On the full build all 172 carry
    their own. The visit's flow, width and walks read the visit's own line (0310:265, 271, 346), so nothing the
    tuning reads moves; only the FISS workbook sites' flow reads the segment's line (0310:380), and the workbook
    sites are not scored.
  - outside the segment, access and habitat columns only `mad_pick` differs: the flow load.
  - `walks.csv`: same row count, 470,799 rows differ: the flow load (2026-10-19 against 2026-10-24) moves which
    river each size reaches and where; the walk md5 is the same.
  - `visits_species.csv`: only `in_range` differs, on 12,083 rows. Not the network: range comes from the installed
    link `default` bundle's presence table (`lnk_load_overrides()`, 0310:194-215), which link's presence review
    (`link#402`, 2026-10-30 to 11-01) changed after the published build's link 0.66.0. Gained: PK 24 groups, SK 25,
    ST 14, CH 10, CO 10, CM 5; lost: UDEN for CH, CM, CO, PK, SK, ST (34 visits each), BULL for GR (128 visits).
    In range on the minimal build against the published: CH 25,128 / 24,496, CO 20,090 / 19,502, PK 17,693 / 13,623.
    **So the pick report's differences from the published picks mix three changes: the network, the flow load and
    species range.** Only the published-vs-minimal comparison is confounded; a run on tomorrow's full `default`
    build with this evidence's flows and range separates the network from the rest.
  - steps 3 to 5 (access per group, the parent, stored habitat) need the published evidence rebuilt per group and the
    published schema, both on m1: not run here.
- **Premise** (`scripts/logs/habitat/20261103_segment_gradient_check-derived_minimal.txt`): on the stream branch
  (29,335 visits) 3.4 % of visits with fish start a segment of their own against 3.0 % of empty ones; median segment
  717 m against 699 m. Published build (link 0.66.0, every observation a break): 86 % against 10 %, 113 m against
  305 m. By species outcome the share is 0 to 5.6 % either way. 3,648,510 stream-branch segments.
- **Measured gradient** (`scripts/logs/habitat/20261103_site_gradient_check.txt` beside `20261030_…`): 16,279
  stream-branch visits with a measured gradient; segment gradient's rank correlation with it 0.678 (published full
  0.690; Atlas line 0.653 on both); chinook rearing's 11 % limit flips 5.9 % of its 2,453 visits (published 6.4 %;
  Atlas line 11.6 %); BT 0.6 % (0.8), CO 25.5 % (25.8), GR 11.4 % (11.7).

## Phase 3: DEV tuning on the minimal build (2026-11-03 UTC)

`DEV=1 … SPECIES=BT,CH,CM,CO,GR,PK,SK,ST,WCT WORKERS=14 0320`, 08:32:53 to 08:38:19 UTC (5.4 min; 18 keys scored in
5.1 min on 14 workers, smoke 0.1 min). Floors 5 and 5. Every smoke gate passed on the seven keys with a previous pick
(null ratio, clamp, behind null, coefficient); the other eleven are `no_response` (every spawning key but BT's) or
`no_stream_rule` (CM, PK, SK rearing), as on the published run. Log
`minimal_network_120/20261103_tune_run-bt_ch_cm_co_gr_pk_sk_st_wct-dev.txt`, report
`minimal_network_120/20261103_dev_minimal_pick_report.csv`. Evidence md5s: visits_link `c746c582…`,
visits_species `6a2e28f1…`, walks `2e0f0f41…`.

| key | minimal pick | published pick | published in region | published behind best (ddev / se) | visits |
|---|---|---|---|---|---|
| BT_rear | `mad>=0.35\|g<=0.1049\|none` | `mad>=0.1\|g<=0.3\|none` | yes | 2.71 / 11.17 | 9,344 |
| BT_spawn | `width>=2\|g<=0.25\|Q1@D500` | `width>=2\|g<=0.13\|Q1@D500` | yes | 1.41 / 4.04 | 513 |
| CH_rear | `mad>=0.75\|g<=0.09\|Q3@D1000` | `mad>=0.75\|g<=0.11\|Q3@D1000` | yes | 4.55 / 7.97 | 4,858 |
| CO_rear | `mad>=0.1\|g<=0.0549\|Q3@D2000` | the same | yes | 11.68 / 30.48 | 4,628 |
| GR_rear | `width>=1.5\|g<=0.0549\|none` | `width>=2\|g<=0.0549\|none` | yes | 3.92 / 5.25 | 1,355 |
| ST_rear | `mad>=0.5\|g<=0.0849\|Q1@D250` | `mad>=1\|g<=0.0849\|Q1@D250` | yes | 16.91 / 19.30 | 1,530 |
| WCT_rear (underpowered) | `mad>=0.03\|g<=0.25\|none` | the same | yes | 0 | 1,238 |

- Every key's visit count equals the published one: the range change (Phase 2) adds visits only in groups that do
  not hold both outcomes for the key.
- Every published rule stays in its key's region, each less than one standard error behind the minimal run's best.
  Two keys pick the same rule. CH, GR and ST move one or two steps on one part; BT rearing moves seven gradient steps
  (0.3 to 0.1049) and four MAD steps (0.1 to 0.35), BT spawning three gradient steps (0.13 to 0.25); counted on the
  run's own ladders (round-1 review corrected "five move one or two steps"). RB rearing has a published rule and is
  paused on this build, so it was not tested.
- Chinook rearing on three setups, one evidence count (4,858 visits): published (full, own segment) g ≤ 11 %, 164
  rules in region; minimal g ≤ 9 %, 102; Atlas line (`data/tune/grad_fwa/CH_rear_tune.csv`, tracked) g ≤ 15 %, 117.
  The flow floor (MAD ≥ 0.75) and near-river part (Q3@D1000) hold on all three.
- The ddev columns are in each run's own units, as `knw_tune_pick_report()` computes them.

## Phase 4: grading on the minimal build (2026-11-03 UTC)

`RUN=20261103_0838 … WORKERS=14 0320`, 08:38:46 to 09:49:52 UTC (70.9 min), exit 0, no `_refused` log. Smoke gates
passed for every key; the picks are the DEV run's, key for key (`data/tune/candidate/20261103_0838/pick_report.csv`).
Log `minimal_network_120/20261103_tune_run-20261103_0838-p20261103083846-bt_ch_cm_co_gr_pk_sk_st_wct.txt`, console
`minimal_network_120/20261103_tune_run_console.log`.

| key | grade minutes | groups | segments | walk cache hits / misses | grade withheld (published) |
|---|---|---|---|---|---|
| BT_rear | 17.3 | 158 | 3,617,470 | 161 / 1,920,860 | no (no) |
| BT_spawn | 11.5 | 158 | 3,617,470 | 161 / 1,920,860 | no (no) |
| CH_rear | 7.1 | 136 | 2,653,426 | 73 / 761,479 | no (no) |
| CO_rear | 3.9 | 113 | 2,250,212 | 545,184 / 31,301 | yes (yes) |
| GR_rear | 5.2 | 81 | 1,962,275 | 559,059 / 240,867 | no (no) |
| ST_rear | 4.6 | 93 | 1,990,611 | 381,522 / 289,836 | no (no) |
| WCT_rear | 3.3 | 16 | 394,925 | 89,519 / 21,458 | yes (yes) |

- The minimal network has 52 to 67 % fewer segments per key than the published full network (BT 3.62 M against
  8.41 M, CH 2.65 M against 5.76 M).
- The walks were cold on the new flow load: the first keys walked nearly every segment end; later keys reused the
  earlier keys' walks. Every record carries run `20261102_203300-60ab009d`, flows 2026-10-24 (`b4bbc50`), walk
  `c3f7bdbe…`, gradient `segment_gradient`, tokens `cut-min acc-v5 grad-seg q-fwapg`, link 0.78.1 `193cb8aa`.
- `0330` launched 09:51 UTC with `pg_stat_activity` idle (no client backend active), round trip 0.8 ms, the table
  comment unchanged since `0320`.

## Phase 4: comparison on the minimal build (2026-11-03 UTC)

`0330 … TUNE_DIR=data/tune/candidate/20261103_0838 CONFIG_SHA=193cb8aa GPKG=FALSE WORKERS=6`, 09:51 to about 10:35 UTC,
"Done in 43.5 min" (planned about 2.7 h: that figure was every structure's on the full network; since #112 only
`default` and `door`, and the minimal network has about half the segments). Exit 0, no `_refused` log. Console
`minimal_network_120/20261103_compare_console.log`; run log `data/compare/candidate/20261103_0838/20261103_compare-20261103_0838.txt`.

Per key minutes: BT_rear 6.8, BT_spawn 6.0, CH_rear 12.7, CO_rear 10.3, ST_rear 4.0, GR_rear 2.9, WCT_rear 0.8.

**`default` regenerated against link's stored km** (`stored_vs_default_differ_km`, all groups): BT_spawn 0; BT_rear
5.98 km (9 groups, max FROG 3.30), CH_rear 9.30 (KITL, LNIC, MSKE, TESR 8.50), CO_rear 2.26 (LNIC, NBNK), GR_rear 8.43
(FINL, PINE, TESR 7.90, UKEC), ST_rear 3.45 (INKR, NASC, TSAY), WCT_rear 0.05 (DUNC). At most 0.011 % of a key's km.
The published comparison differs by hundreds to thousands of km per key (its stored flags are not regenerable, CLAUDE.md).
- Segment level (`<key>_segments.rds`): 154 differing segments over six keys; 150 are stored rearing that the
  regeneration drops, 4 (CO) the other way; `rearing_pre_default` is TRUE on all, `user_habitat` FALSE on all, so the
  difference is in `.frs_run_connectivity()` (rearing clusters need spawning within 10 km, `cluster_direction = both`).
  TESR's CH and GR segments are lake edges (1200, 1450); elsewhere mostly 1000.
- Ruled out: stored spawning upstream in another group (0 rows, DB query on wscode/localcode); stored spawning on a
  segment the access gate blocks (0, and `access_gate_differ_km` 0); user habitat; fresh's version (`frs_cluster.R`
  and `.frs_run_connectivity()` unchanged from 0.52.0 to 0.53.0; 0.53.0's diff is the `to_streams` persist); link runs
  `.frs_run_connectivity()` per AOI on its working schema (`lnk_pipeline_connect()`), as the comparison does per group.
  A downstream test by wscode ancestry is too coarse (it reaches the whole mainstem) and TESR has no BC group
  downstream. Cause not established; it does not touch `default` against tuned, both regenerated the same way.
  Candidate next probe: link's own pipeline for TESR into a scratch schema, comparing its working `streams` at the
  connect step with the persisted minimal segments.

**km per key, `default` against tuned on the minimal build** (`compare.csv`, `ALL`):

| key | default km | tuned km | change | gained / lost km | published change (other network, build, load, range) |
|---|---|---|---|---|---|
| BT_rear | 248,016 | 141,049 | −43.1 % | 1,340 / 108,307 | −23.7 % |
| BT_spawn | 134,200 | 221,448 | +65.0 % | 87,248 / 0 | +49.5 % |
| CH_rear | 104,751 | 87,606 | −16.4 % | 14,643 / 31,788 | −15.9 % |
| CO_rear | 90,350 | 88,006 | −2.6 % | 8,586 / 10,929 | −2.3 % |
| ST_rear | 84,880 | 70,007 | −17.5 % | 7,320 / 22,192 | −27.0 % |
| GR_rear | 78,208 | 87,066 | +11.3 % | 9,170 / 312 | +3.4 % |
| WCT_rear | 20,613 | 24,416 | +18.4 % | 4,762 / 960 | +18.0 % |

Graded km, default → tuned: BT_rear 108,826 → 74,699; BT_spawn 79,026 → 117,982; CH_rear 52,369 → 58,350; ST_rear
43,632 → 46,069; GR_rear 45,024 → 49,684 (CO and WCT withheld).

## Phase 4: archive (2026-11-03 UTC)

`fdis_sites.csv` copied into `data/fdis/derived_minimal/`; the dry run listed 35 objects under
`tune/<key>/cut-min.acc-v5.grad-seg.q-fwapg/` and `evidence/3d907629ee200b4a7beb05cdd560fc0b/` (`reconcile.csv` and
`sites.rds` from `data/fdis/build/`, md5-checked against the ledger). The archive itself: 35 objects, 1,755 MB stored,
35 rows appended to `data/archive_index.csv` (batch `20261103T123953Z-2ce302a3`); its `source` column names the
promoted path by design, and its md5s are the candidate's (BT_rear grades `3bacfaa8…`, the candidate record's; the
published table's is `4b6fe521…`). Console `minimal_network_120/20261103_archive_console.log`.

## Errors Encountered

| Error | Resolution |
|-------|------------|
