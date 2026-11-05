# Findings: Tune chinook rearing on minimal segments and map how the cuts move the result (#120)

## Issue context

**If we do it:** we learn how much the places link cuts streams (fish records, crossings, habitat end points) move each species' tuned thresholds, starting with chinook rearing, and we can map where the habitat drawn differs, so the trade-off between tuning on an ideal network and deploying on a connectivity network is measured and stated. **If we never do:** every threshold rests on segments partly cut at the catches that score it, and nobody can say whether that matters or where.

## Problem

From #92 the tuning reads link's segment gradient. link cuts a segment at fish records of the species it models, so the gradient at a site that caught fish is averaged over a stretch that starts there: on the tuning's stream branch 86 % of visits with a catch start a segment of their own against 10 % of empty ones (median 113 m against 305 m; link 0.66.0's build, every observation a break). Crossings and habitat end points cut segments too: not at catches, but at places unrelated to the stream's form. Chinook rearing's rule moved when the gradient source changed (#92), so the tuning is sensitive to how segments are cut.

Tuning on segments cut only at barriers and access gradients removes the catch from the predictor. But link deploys a rule on its full network, where segments are shorter and their gradients differ, so a rule tuned on the minimal network does not transfer cleanly unless each full segment carries its minimal parent's gradient. That is link's half: NewGraphEnvironment/link#415, with outputs named from NewGraphEnvironment/link#414. The minimal network still cuts at access gradients, and those cuts depend on which species link models and at which classes (0.15, 0.20, 0.25 and 0.30, each species cut at every class at or above the steepest gradient it passes), so pausing a species (NewGraphEnvironment/link#432, NewGraphEnvironment/link#433) or changing a class moves the segments a minimal-network tuning reads; #132 reviews the classes themselves.

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
- [x] Wet's current flow load in the database the provincial minimal build lives in, so every minimal-network setup reads one load (the published setup keeps its 2026-10-19 load; picks are compared in each run's own units). **Done:** wet's 2026-10-24 build (`b4bbc50`) loaded in 43.5 min; rows per source unchanged
- [x] `0300` → `0310` on `fresh_default_minimal` (`EVIDENCE_DIR=data/fdis/derived_minimal`) and `DEV=1 0320` with the same species, and the pick report (each key's pick beside the published one), reported. The full retune and any promotion wait on Al's word. **Done:** the same 45,529 visits placed, at the same stream and measure. The premise holds province-wide: 3.4 % of stream-branch visits with fish start a segment of their own against 3.0 % of empty ones (link 0.66.0's full network: 86 % against 10 %). Every smoke gate passed. For all seven keys fitted on this build the verdict matches the full network's: link's `default` is outside the region, and the published rule is inside it. The pick is the region rule that changes the fewest parts of `default`, so what moves is which near-equal rule is simplest: scores reshuffle among equally simple rules (chinook rearing's 11 % and 9 % limits), or a rule closer to `default` crosses just into the region and displaces a better-scoring published rule (bull trout and grayling rearing). Rainbow trout rearing has a published rule but is paused on this build, so it was not tested:

  | key | minimal pick | published pick |
  |---|---|---|
  | BT_rear | `mad>=0.35\|g<=0.1049\|none` | `mad>=0.1\|g<=0.3\|none` |
  | BT_spawn | `width>=2\|g<=0.25\|Q1@D500` | `width>=2\|g<=0.13\|Q1@D500` |
  | CH_rear | `mad>=0.75\|g<=0.09\|Q3@D1000` | `mad>=0.75\|g<=0.11\|Q3@D1000` |
  | CO_rear | the same | `mad>=0.1\|g<=0.0549\|Q3@D2000` |
  | GR_rear | `width>=1.5\|g<=0.0549\|none` | `width>=2\|g<=0.0549\|none` |
  | ST_rear | `mad>=0.5\|g<=0.0849\|Q1@D250` | `mad>=1\|g<=0.0849\|Q1@D250` |
  | WCT_rear (underpowered) | the same | `mad>=0.03\|g<=0.25\|none` |

  These picks differ from the published ones in three ways at once, not only the network: the flow load, and each species' range, which link's presence review (`link#402`) changed after the published build's link 0.66.0. A run on the next full `default` build with this evidence's flows and range separates the network from the rest. Details: `research/minimal_network_tuning.md`
- [x] `0330` for CH rearing on the minimal schema: regenerated `default` against link's stored km. **Nearly:** every key ran (43.5 min); regenerated `default` reproduces link's stored km to within 0.011 % per key (bull trout spawning exactly; chinook rearing 9.3 of 104,751 km, 8.5 of it in TESR, mostly inside lakes). The residue is all in the connectivity stage (rearing with no spawning within 10 km), mostly segments link keeps and the regeneration drops; spawning in another group, the access gate, user habitat and fresh's version are ruled out, and the cause is not established. It does not touch `default` against the tuned rule, which are regenerated the same way: chinook rearing −16.4 % on the minimal network (the published run, on another network, build and load: −15.9 %); every key's km in `research/minimal_network_tuning.md`

### Chinook rearing on every setup

- [ ] Read the parent from `fresh_default.streams_parent` (NewGraphEnvironment/link#444, built 2026-11-03 on all 241 groups beside `fresh_default_minimal`) instead of `PARENT_DIR`: its group column is `watershed_group_code`, not the prototype's `wsg`. Rerun the mechanics check on the table; that ticks link#444's first acceptance line, which stays open until it does.

- [ ] Chinook rearing, one key, scored on every setup from one evidence build and flow load, so the network and gradient are the only differences:

  | Setup | Segments | Gradient read | Status |
  |---|---|---|---|
  | published | full | its own segment | the promoted run since 2026-11-04 (#145): run `20261104_0543` on link's new full `default` build (link 0.78.2, run `20261103_163715-269b585a`, the minimal run's flows), graded and compared, in `data/tune/` and `data/compare/` (chinook rearing picks `mad>=0.75\|g<=0.13\|Q3@D1000`); the run before it (link 0.66.0, 2026-10-19 load) is #92's |
  | minimal | minimal | its own segment | done, every key (candidate `20261103_0838`, not promoted) |
  | minimal, other access classes | minimal, cut at another access-gradient set (a species paused, or classes independent of species) | its own segment | waits on #132 |
  | full, parent gradient | full | its minimal parent's | link#444 is done: read `fresh_default.streams_parent` (the item above) |
  | Atlas line | full | the whole Atlas line (today's `grad_fwa`) | scored on the published evidence (chinook rearing g ≤ 15 %) |
  | fixed window | full | a fixed window (#70, when fresh provides it) | waits on #70 |

  "Minimal" and "full, parent gradient" read the same gradient at every visit, so their picks should agree; where their drawn km differ is the transfer cost.
- [x] Rerun #121's measured-gradient comparison on the minimal network's visit table, beside its full-network result (on the four groups: rank correlation 0.696 on both networks, chinook's 11 % limit flipping 8.5 % against 8.7 % of visits; the province follows the provincial build): `EVIDENCE_CHECK=FALSE EVIDENCE_DIR=<minimal network's build> Rscript data-raw/site_gradient_check.R` (the full-network result is `scripts/logs/habitat/20261030_site_gradient_check.txt`). One run covers "full, parent gradient" too, since both read the same gradient at every visit. The difference is what link's cuts at catches do to how well the gradient a rule reads matches the gradient measured on site. **Done** on the province: on 16,279 stream-branch visits the minimal segment gradient's rank correlation with the measured one is 0.678 (full network 0.690, Atlas line 0.653); chinook rearing's 11 % limit flips 5.9 % of its visits (full 6.4 %, Atlas line 11.6 %). The minimal network drops crossings and habitat end points with the catches, on a newer link, so this cannot be pinned on one break source.
- [ ] Report per setup: the pick, whether the published rule is in its region, km drawn and graded, and a map of where the habitat drawn differs (a GeoPackage for QGIS, as `0330` writes, and one static figure).
- [ ] Each setup archived and indexed by #119's layout (`tune/CH_rear/<setup tokens>/`), its tokens from NewGraphEnvironment/link#414.
- [ ] `research/` gains what each break source does to the tuning, and the trade-off between the network a rule is tuned on and the one it is deployed on; the methodology article gets a short section once the result holds. Other species follow one at a time. #149 writes this as a public article, led by figures of our own data, with the methodology article's short section linking it; this task stays here until it lands.

## Decided at the gate (Al, 2026-11-02)

- The four-group test runs on the database link's proof schemas `zz415_default` and `zz415_minimal` live in, reached with `PGSERVICE`; they stay until the provincial run fills `fresh_default_minimal`.
- Scope: the mechanics, the four-group test and its write-up land as the first PR; the province and chinook rearing on every setup run on a second branch of this issue when NewGraphEnvironment/link#441 and NewGraphEnvironment/link#444 land.
- link at 0.78.1 where the runs go (`0310` reads the installed `default` config for species range and pooling).
- No step of the test reaches the database the published build lives in; the latency check (#110) refuses one that lands there by accident.

Relates to #70 (fixed-window gradients), #92 (segment gradient), #121 (measured gradient), #119 (storage layout and run index).

## Exploration at the gate (2026-11-04)

- `fresh_default.streams_parent` on m4: 5,546,370 rows, 241 groups; columns `id_segment, watershed_group_code,
  id_segment_minimal, gradient_minimal, length_minimal, overlap_m, straddle_m, schema_minimal, run_id_minimal,
  run_uid_minimal, config_hash_minimal, link_sha_minimal, run_id_full, built_at`. `run_uid_minimal` is
  `20261102_203300-60ab009d` (the minimal build); `run_id_full` values are the full build's per-host run ids. No table
  comment.
- link's vocabulary (`../link/inst/extdata/vocabulary.csv`, main `e2a85938`) holds `grad-seg` and `grad-parent`
  (0.79.0, "no link build writes it"); no token for the FWA segment's own gradient. link#414 lists "over the whole
  Atlas line" as a value on the gradient axis.
- `fwa_gradient` in the evidence is `whse_basemapping.fwa_stream_networks_sp.gradient` on the visit's
  `linear_feature_id` (`R/link_flow.R`), so the "Atlas line" setup reads the FWA segment's gradient, not the whole
  blue line's.
- The archive (`R/archive.R`, `0336`) is driven by grade records: `knw_archive_setup()` builds the folder from the
  record's four tokens and refuses a token not in link's vocabulary. CH_rear is archived under
  `cut-full-top.acc-v5.grad-seg.q-fwapg/` (run `20261104_0543`) and `cut-min.acc-v5.grad-seg.q-fwapg/` (`20261103_0838`).
- Grading refuses a curve fitted on any gradient but `segment_gradient` (`R/grade_species.R`, `.knw_grade_grad`);
  `0320` runs any other gradient as main-seed only, no grades (`main_only`); `0330`'s stale check refuses
  `curve_grad != segment_gradient`.
- m4's `data/fdis/derived/visits_link.csv` md5 `db5ca99a…` equals the promoted CH_rear record's `evidence_md5`; link
  0.78.1 and fresh 0.52.0 installed. The minimal candidate's `CH_rear_segments.rds` exists
  (`data/compare/candidate/20261103_0838/`).

## Full test suite after `bd2c7d0` (2026-11-05)

1,961 expectations, 0 failed, 1 error, 1 skipped. The error is `test-link_place.R:39`, "placement runs against a live
schema": `skip_if_no_pg("fresh_default")` connects with `~/.Renviron`'s `PG*`, which reach m1, whose `fresh_default`
schema exists but has held no segments since #145's promotion moved the published build to m4. The test then finds no
row to place and errors instead of skipping. Environmental, and not in code this branch touched; with
`PGSERVICE=fresh_local` the file passes (18 expectations), and the guard's gap (a schema present but empty) is the test's own.

## Regression: the gradient swap on the segment's own gradient reproduces the published run (MFRA, 2026-11-05)

On MFRA (8,771 chinook segments), with the published curve and pick on m4's `fresh_default`:
- `knw_grade_species()` (now reading `gradient = "segment"` through the source map) reproduces the published grade
  table's rows exactly: the same segment ids, size, distance, accessibility and rearing flags, and rates to 0 at five
  significant figures (the walk cache served all 1,449 starts).
- `knw_compare_rules(gradient = "segment")`, with link's configs at the published comparison's `e2a85938`, reproduces
  the promoted `CH_rear_segments.rds` rows exactly (`rearing_default`, `_tuned`, `_pre_tuned`, `_door`, `gradient`,
  `grade`, `knw_dist`, `link_branch`).
- `gradient = "parent"` on the same group: the gradient differs on 2,609 segments; the tuned rule's rearing on 0 of
  them and `default`'s on 4 (`stored_vs_default_differ_km` 0.442), at 121 km `default` and 98.6 km tuned. The log
  line names the gradient.

## The parent evidence (first build, 2026-11-05 04:09Z) and the Atlas line a visit reads

`0310 PARENT=TRUE EVIDENCE_DIR=data/fdis/derived_parent` (19 min, walks all cached): 45,529 visits placed, as the
published build. `visits_species.csv`, `walks.csv`, `bcfishobs_fdis_match.csv` and the workbook tables are
byte-identical to `data/fdis/derived`; `visits_link.csv` matches it cell for cell in every shared column and adds the four
parent columns; `access_check.csv` differs only by float summation order (at most 9.8e-11 km, as #145 found). The parent
table joined 45,529 visits on 30,847 full segments; 12 visits sit on a full segment straddling a minimal break, and
21,784 read a parent gradient other than their own segment's.

The review's Q5 point is real: 732 visits (1.6 %; 393 with fish, 339 without) were placed on a link segment of another
Atlas line than their own (placement prefers the segment starting just past the visit, so a visit near a line's end
lands on the next line). `fwa_gradient` is the visit's own line's; the segment's line differs in gradient on 637 of
them (median 0.022, 90th percentile 0.17), and 136 cross a 13 % limit (122 an 11 % one). A rule applied to a segment
reads the segment's line, so the Atlas setup tunes and grades on a new visit column, `segment_fwa_gradient` (`0310`),
mapped to the `fwa` source; `fwa_gradient` stays #92's sensitivity and is not gradable. The parent evidence was rebuilt
with it.

Not this branch's, for a follow-up: the visit's flow and width (`mad_pick`, `cw_deploy`) are also its own line's
(`knw_link_flow(v$linear_feature_id)`), while the grade and link read the segment's, on every run including the
published one; the 732 visits are where they can differ.

## Mechanics on link's parent table, province-wide (2026-11-05, `20261104_minimal_network_check.txt`)

`FULL_DIR=data/fdis/derived_parent MIN_DIR=data/fdis/derived_minimal data-raw/minimal_network_check.R`, the rebuilt
parent evidence (with `segment_fwa_gradient`) against the minimal build's:
- every one of the 45,529 visits is placed on both networks, 45,463 at one blue line, measure and Atlas line (the 66 are
  the Atlas-id difference #145 found); every visit's full segment joins a parent row;
- the parent is the minimal segment the visit sits on for 45,450 visits, with its gradient for 45,452;
- 12 visits sit on a full segment straddling a minimal break, and for all 12 the parent is still the visit's minimal
  segment;
- the other 79 (0.17 %, all with fish) are one pattern: the same blue line and measure on both networks, each within
  5 m of the start of both its full and its minimal segment, and the parent is the minimal segment just below the one
  the visit lands on. Placement prefers a segment starting in a short window above the visit: on the full network
  that is the short piece cut at the catch itself, whose parent lies below the break, and on the minimal network the
  segment starting at the break above. There the parent setup and the minimal network read different gradients
  (median difference 0.041, at most 0.33). It is placement's window meeting two cuts a few metres apart, not the
  parent table; four groups held none.

link#444's acceptance line ("every visit lands on a segment on both networks, segment ids join, and the
parent-gradient setup reads its parent's value") holds on the table.

## The parent setup's DEV pick (2026-11-05 04:34Z, 1.0 min scoring)

`DEV=1 GRADIENT=parent_gradient SPECIES=CH EVIDENCE_DIR=data/fdis/derived_parent DEV_DIR=data/tune/dev_parent 0320`:
chinook rearing picks `mad>=0.75|g<=0.09|Q3@D1000`, the minimal network's pick, on 4,858 visits (7,823 with any size,
45 groups with both outcomes); `default` outside the region (+238.3, SE 95.0). The stronger of the two criteria fixed
before the run (the same rule) holds.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| A `until ! pgrep -f "0310_run.R"` waiter never exits: the pattern matches the waiter's own command line (code-check-shell's trap) | Stopped both waiters; waited on the background task's own notification |
| `/planning-init`'s `gh_rest.sh` fails to parse under macOS `/bin/bash` 3.2 (line 300, `case` inside `$( )`) | Ran the skill's blocks under Homebrew bash; filed soul#725 |
