# Findings — Tune habitat thresholds for every species and life stage in one run, as package functions (#57)

## Issue context

(body as read 2026-10-17, `updatedAt` 2026-10-17T09:44:03Z)

**If done:** one evidence build and one tuning run give, for every species and life stage the evidence can speak to,
on every watershed group the species occupies: calibrated thresholds, a 0–1 grade for each segment, and outputs that
show what a tuning changes on the ground (km, graded km and graded floodplain hectares, with maps), as published tables
that link and anyone else can read. **If never:** each species is tuned by its own one-off scripts (BT `0290`-`0293`,
CH `0296`-`0298`), each build is redone, each run covers only the groups that happened to have a link build, and
habitat stays on/off, so a floodplain beside marginal habitat ranks with one beside the best.

## Problem

- **One species at a time.** #28/#33 (BT) and #54 (CH) each built their own visit table, walks and scoring from
  scratch. The scoring method #54 fixed (held-out watershed groups, the one-SE region, a group bootstrap, readings by
  flow source) is in a script, not a function.
- **Partial coverage.** #54 scored rules only where link's `default` build exists (56 groups). 19 groups with CH
  detections and no build were dropped, 67 of them on small streams. Which CH size floor to carry, MAD ≥ 0.75 or
  ≥ 0.5 m³/s, is still open and needs those groups.
- **On/off only.** A rule is a switch: a segment just inside a cutoff counts the same as the best, and one just
  outside counts as nothing. The evidence says use tapers across the cutoffs rather than stopping: BT rearing by
  gradient class (#28, `data/habitat_weight_bt_rear.csv`) and CH detection against flow and distance to a river
  (#54, `data/ch_rule_curves.csv`).
- **No view of what a tuning changes on the ground.** #54's comparison (`0298`) has km tables and maps for CH only,
  and none says how much floodplain sits beside the habitat each rule keeps.
- **Calibration split across two repos.** link calibrates WCT, GR, RB and KO itself (NewGraphEnvironment/link#322,
  NewGraphEnvironment/link#343) with its own harness, on a subset of the same evidence.

## Proposed

### 0. Wait for link's province-wide run to settle, then begin

link's province-wide `default` run (NewGraphEnvironment/link#246) was still recomputing `streams_access` and
`streams_mapping_code` in `fresh_default` on 2026-10-17, after `streams`, the habitat tables and `barriers` were final.
The evidence build reads `streams_access` (`access_bt`), so the first phase after plan approval is a waiter, run in the
background, that starts phase 1 only when all three of these hold:
- [ ] every group in `fresh_default.streams` has a `fresh_default.log_recompute` row with `date_end` set;
- [ ] the summed inserts, updates and deletes over every `fresh_default` table (`pg_stat_user_tables`) are unchanged
      across three polls 10 minutes apart;
- [ ] no non-idle session's query names `fresh_default`.

It records the `run_uid`, the `log_recompute` count and the time it released in the PWF. If the conditions are not met
within 24 hours, it stops and reports instead of starting.

**Access: gate on `streams_access`, and ledger the gap every run** (decided 2026-10-17). The `streams_habitat_*`
tables' `accessible` disagrees with `streams_access`'s `access_<sp>`, and did before the province-wide run:

| species | habitat accessible, `access_<sp>` = 0: provincial run 2026-10-17 | the same in `score284_default` (link 0.53.0, 2026-09-30, 23 groups) |
|---|---|---|
| BT | 48,728 segments (1.8 % of habitat-accessible), 8,867 rearing | 2,948 (0.7 %), 40 rearing |
| CH | 14,242 (1.6 %), 330 rearing | 1,923 (1.7 %), 43 rearing |
| RB | 481,275 (17 %), 147,445 rearing | 99,992 (27 %), 27,056 rearing |
| KO | 55,989 (90 %), 983 rearing | not built |

Other species are at 1.3–3.5 %. The reverse (habitat inaccessible, access > 0) is at most about 1,000 segments per
species, and some spawning sits on segments the habitat table marks inaccessible (CH 178, CO 760), likely the
user-habitat overlay. The cause is not established (NewGraphEnvironment/link#349). So the evidence build:
- [ ] gates every species on `streams_access` (as `0290` already does for BT) and re-gates rearing and spawning on it;
- [ ] writes this cross-tabulation, per species, to its ledger on every run, so a change between link runs shows;
- [ ] treats RB and KO as unresolved until link says which access definition is meant.

### 1. One evidence build, as package functions
- [ ] Site-visit table for all species from #23, after #35's dedup: catch per species and age class, effort, fished
      area, measured habitat
- [ ] bcfishobs records matched to their FDIS visits through `fshclctn_id` (#23); a workbook record that bcfishobs
      holds and FDIS does not gains its count and effort from the workbook and joins the scoring
- [ ] Placed on link's segments province-wide (needs link's province-wide `default` run,
      NewGraphEnvironment/link#246), with link's width, gradient, MAD by flow source, access, and the
      distance-to-a-large-river walks at each Q. This replaces #59: the visit tables `0290`, `0294` and `0296` built are,
      since #35, the 55-WSG builds less the repeated surveys, and are not rebuilt separately.
- [ ] `knw_*` functions with tests and runnable examples; `0290`/`0294`/`0296` reduced to calls

Presence-only bcfishobs records (no effort, no zero catch) never score a rule. They choose the groups a species is
studied in and give the outside check after tuning (`0298`'s lift). `access_bt = 2` is never a covariate or stratum
(it is defined from these same records).

### 2. One tuning run across species and stages
- [ ] A function that takes species × stage × candidate rules and applies #54's fixed scoring spec
      - Held-out groups are #54's five WSG folds only, each group held out once (decided 2026-10-17). #28's fixed
        split, with link#284's 8 step-5 WSGs held out, is not carried: once one schema holds every group it needs a
        declared list, and the folds test every group instead. #28's held-out-only elevation contrast is
        therefore not reproduced as such.
- [ ] Rearing from electrofishing detection; spawning from spawner evidence (#33's method) where electrofishing cannot
      speak; each species × stage states which
- [ ] A curve per species × stage: one GAM fitting the rule's variables together (stream size, gradient, distance to a
      river) with the same nuisance terms (fished area, data set, era, group) and held-out groups. A segment's
      **grade** is its predicted rate relative to the best segments, 0–1. Never a product of one-variable curves, which
      counts correlated variables twice. The grade is expected use, and is labelled so, not habitat quality.
- [ ] One job for all species and stages (socket workers), seed fixed, run on the 16-core machine
- [ ] Settle CH's size floor (0.75 against 0.5 m³/s) on all CH groups

### 3. Published results
- [ ] Thresholds table: species, stage, variable, the pick, the one-SE range, the readings it holds in, n visits and
      groups, the evidence version; Parquet with a manifest on the public prefix
- [ ] Grade table: one row per segment × species × stage (`blue_line_key`, downstream and upstream measure, grade,
      grade class), with the link run and the evidence version; Parquet with a manifest on the public prefix
- [ ] One `research/` file per species, revised in place; the CH and BT files point at the tables

### 4. What a tuning changes: comparison outputs
For each species × stage × watershed group, `default` against the tuned rule:
- [ ] **Km:** kept, lost and gained; graded km (km × grade); km by grade class
- [ ] **Floodplain as a unit of measure.** Floodplain hectares beside each segment, from the floodplain catalog's join
      by position (`blue_line_key` and the FWA version). **Graded floodplain ha** = ha × the segment's grade, so
      500 ha beside grade-0.9 habitat scores 450 and the same 500 ha beside grade-0.3 habitat scores 150. Reported as
      ha, graded ha and ha by grade class, under each rule. The floodplain is a fixed input; nothing here models it.
      Covers the groups the catalog holds until whole-network floodplains are published
      (NewGraphEnvironment/floodplains#123).
- [ ] **Maps per group:** the network coloured kept / lost / gained; the network shaded by grade class; floodplain
      polygons shaded by the grade of their segment. Static through gq for reports, interactive through mapgl.

Totals upstream of a crossing (graded km, graded floodplain ha) are link's (NewGraphEnvironment/link#321, on
`fresh::frs_aggregate()`), read from the published grade table.

### 5. Take over link's calibration
- [ ] Once this repo is public, NewGraphEnvironment/link#322 (WCT) and NewGraphEnvironment/link#343 (GR, RB, KO on
      wet) transfer here and run through §2

Depends on #56, #35, #23, NewGraphEnvironment/link#246 (province-wide `default` run), NewGraphEnvironment/link#346
(link reads the result), NewGraphEnvironment/floodplains#123 (floodplain coverage beyond the catalog's groups), and
the bucket's public prefix (a policy change in our infrastructure repo).






## Plan-gate decisions (2026-10-17)

1. **Scope:** all six phases on this branch, one PR. Phase 5 ends at filing the transfer issues here and drafting
   (not posting) the link comments.
2. **Old scripts:** `0290`/`0294`/`0296` become calls that write their tables from the new build (the columns one
   schema cannot produce, `role`, `step5_class`, `*_score284`, `link_schema`, are gone); `0291`–`0293`, `0295`,
   `0297`, `0298` are frozen on the published v2 tables (`PULL=TRUE VERSION=v2` in `0299`). Phase 2 is their
   successor; #28/#54 results are not re-litigated. `research/habitat_weights.md`'s step-5 held-out sections are
   marked historical; `habitat_weight_bt_rear.csv` is superseded by the BT rearing grade.
3. **Grade reference:** grade = predicted rate / the 95th percentile of predicted rate over the species' accessible
   segments in its groups, capped at 1; predicted at reference nuisance values (median `log_area`, modal `data_set`,
   latest era) with the group random effect excluded. Labelled expected use.
4. **Run host:** the 16-core machine, after upgrading link and fresh there (exact versions logged and asserted);
   knowledge via `pkgload::load_all()` from its checkout.

Conventional defaults: dataset ids `knowledge/thresholds/v1` and `knowledge/habitat_grade/v1`, manifest-first,
Hive `species=/stage=`, one part per FWA drainage (wet#7 / link#308 layout); walks at `0296`'s `q_grid` and three
sources; scripts `0300`–`0330`; the `fresh` barrier fallback dropped.

## State of `fresh_default` at planning (read-only probe, 2026-10-17 09:47Z)

- 241 groups in `streams`; 11,388,157 segments; 1,887,603 km.
- `log_recompute`: 241 rows, 241 with `date_end`, one `run_uid`, last `date_end` 09:30:25Z (last `date_start`
  09:30:03Z). `log`: 241 rows, one `run_uid`, last `date_end` 06:48:58Z.
- `pg_stat_user_tables` churn over the schema's 22 tables: 179,288,878 at 09:47:25Z.
- No non-idle session's query named `fresh_default`.
- Habitat tables by group count: RB 210, BT 158, CH 125, CO 100, GR 82, ST 79, WCT 16, KO 4.
- `streams_access` carries `access_<sp>` for bt ch cm co pk sk st wct ko rb gr.
- Discharge picked counts: pcic_routed 3,152,838; wet_balance 1,380,005 (as `0294`'s manifest literal).
- bcfishobs FDIS-keyed share (`source ~ fshclctn_id`): BT 8,185/11,379; CH 4,660/9,044; CO 11,708/22,542;
  RB 22,795/119,883; WCT 2,389/6,777; GR 1,969/3,298; KO 3,000/9,665; ST 2,602/16,547; DV 4,637/13,094.

## Plan review (Plan agent, 09:56–10:04Z): 31 findings, disposition

| # | kind | finding | disposition |
|---|---|---|---|
| 1 | Blocker | `flooded::fl_valley_join()` takes logical `cols` only and drops the owning segment (`seg`) it computes | Phase 4 opens with a flooded issue + PR returning `seg`; fallback: grade-class dummies, ha by class only |
| 2 | Blocker | a distance-bearing grade implies a walk per segment province-wide | walks restricted to accessible stream-branch segments of the species' groups, every pick Q in one array per start; `none`/`Inf` censored at 50 km |
| 3 | Blocker | 0291–0293 read columns one schema cannot produce | decision 2 (freeze on v2) |
| 4 | Gap | grade reference undefined | decision 3 |
| 5 | Gap | the curve needs the pick's Q and size variable | Phase 2 order: score → pick → curve → grade; `te(log size, log dist)` |
| 6 | Gap | segments with NULL width or MAD | segment-scale MAD with parent fallback; NA only when both missing, counted |
| 7 | Gap | spawning evidence exists for char only | stated; other species' spawning rows say so |
| 8 | Gap | KO rearing has no stream rule | out of the grid, stated |
| 9 | Gap | 0298's predicate is CH-shaped SQL | predicate from `frs_habitat_predicates()` with substituted thresholds + injected exception, checked per species × stage; both stages regenerated together |
| 10 | Gap | walks cannot take a `conn` | connector function |
| 11 | Gap | bcfishobs match needs species and date | matched on collection × species × date |
| 12 | Gap | workbook effort is not in `fiss_evidence.csv` | effort from `0220`'s step-2 files (five groups); scores only with effort |
| 13 | Gap | absence blocking exists for char and CH only | `fdis_species_codes.csv` `blocks_absence_of` extended per species group |
| 14 | Gap | thresholds table not readable by link | `rule_id`, `link_parameter`, `model`, `unit`, exception fields, `default_in_region`, `config`, groups companion |
| 15 | Gap | grade table columns | `linear_feature_id`, `length_metre`, `access`, `config` added |
| 16 | Gap | PG tests | `skip_if_no_pg()` attempts a connection; pure parts factored out; `\dontrun{}` examples |
| 17 | Gap | the GAM has no held-out check | held-out deviance on the same folds |
| 18 | Ordering | publishing before #56's bucket policy | `PUBLISH=TRUE` gated; tables built locally regardless |
| 19 | Ordering | curve before pick | fixed |
| 20 | Ordering | `picked_expected` literal | read from wet's manifest |
| 21 | Assumption | catalog items: no raster, 10 m grid, EPSG 32610 | rasterise on `proj:transform`, check km² and claim coverage |
| 22 | Assumption | `fresh_default.barriers` coverage | verified and ledgered in Phase 0 |
| 23 | Assumption | `lnk_species_pooling()` per species | called per species; no row is normal |
| 24 | Assumption | run host versions | pinned and asserted |
| 25 | Scope | machine names in `planning/` | kept out of `task_plan.md` and this file |
| 26 | Scope | link links are public | fine; transfer issues wait for #56 |
| 27 | Scope | `habitat_weights.md` rests on step-5 figures | marked historical |
| 28 | Acceptance | Phase 1 tolerance | ledger-by-ledger: only segmentation-dependent rows may differ |
| 29 | Acceptance | ≥ 5 groups is thin | `underpowered` under 10 groups; `n_wsg` published |
| 30 | Acceptance | predicate check per species | yes |
| 31 | Acceptance | bcfishobs outside check missing | in `knw_compare_rules` |

## Phase 0: release (2026-10-17)

`scripts/0300` released at 10:54:24Z on its third stable poll (10:34:16, 10:44:20, 10:54:24; churn 179,288,878
throughout; 241/241 `log_recompute` rows ended; no active session). Record: `scripts/logs/habitat/20261017_link_settle.csv`.
`run_uid 20261017_004619-3f4c713b`; link 0.66.0 at `a17e9177` and `ee21eb13` (the two-group fix on top of the run);
fresh 0.39.0 `e247ca19`; fwapg `f9718cb7`; config `sha256:7e9dffa4…`; `discharge_source fwapg`, `config_drift false`.
A first run of the waiter met the conditions at 10:29:03Z and died writing its release row (columns bound to one row);
the record is from the fixed run. `fresh_default.barriers`: 241 groups, 7.74 M rows; sources GRADIENT (241 groups),
MODELLED_CROSSINGS (232), PSCIS (129), FALLS (187), CABD (142), USER_DEFINITE (8); no SUBSURFACE_FLOW rows, as before.

## Findings along the way

- **link recomputed one group after the waiter released.** `log_recompute` went from 241 to 243 rows under the same
  `run_uid`: UPET, twice (10:58:12–10:58:51Z and 10:59:09–10:59:45Z, from a link session on another checkout), after
  the release at 10:54:24Z and before the build started reading at 10:59:53Z; churn 179,288,878 → 179,319,500, then
  still. The build's five UPET visits place today on the same segments with the same access codes and flags, so the
  build stands on the current state. A three-poll quiet window is a necessary condition, not proof the run is over;
  the build records the `log_recompute` count it read against.

- **wet's discharge load cannot be checked by rows per source.** The manifest (`discharge/fwa/v1`, built
  2026-10-15T02:06:57Z) sums 100.8 M `wet_balance` rows; the database holds 58.9 M = 4,529,939 segments × 13 months
  exactly, and `pcic_routed` matches (43.9 M). `wet::wet_db_load()` filters the manifest's rows on load (its `WHERE` at
  `R/wet_db_load.R:95`), so the row count is the loader's to assert. The build ledgers the manifest's `built` stamp and
  the picked counts per source instead (plan-review finding 20 revised).
- **fwapg's width model reproduces the stored MODELLED width within 5 % on 88 % of a two-group sample** (BULK, MORR);
  0296 measured 96.2 % province-wide. The control is for a formula or input change, so the build's floor is 0.9.
- **The floodplain catalog's polygons are exact 30 m BC Albers cells** (every vertex a multiple of 30 in EPSG:3005),
  and the per-blue-line polygons tile `all_ff04` exactly (LARL: union 375.5088 km² against the item's 375.51; their sum
  972 km² is the overlapping claims). The valley raster is `all_ff04` on that grid, no reprojection; the item's
  `proj:transform` (10 m, EPSG:32611) is the land-cover rasters' grid, not this join's (plan corrected). On LARL:
  417,232 cells, all attributed and owned, 596 ties, 30 s.
- **flooded#89 / PR #90**: `fl_valley_join()`'s `nearest` now returns `seg`, the owning segment. Installed here from the
  branch; the run host still has 0.8.2 without it.
- **bcfishobs ↔ FDIS match (BT and CH, smoke run):** of 11,379 BT records 4,321 match one visit, 130 several, 230 a
  collection with no visit on that date, 3,504 an unknown collection, 3,194 are not FDIS-keyed; CH 1,286 / 38 / 42 /
  3,294 / 4,384.
- `knw_link_flow()`'s per-segment `LATERAL` parent fallback took 25 s for 223 segments, so segment-scale reads
  (`knw_link_segments()`) join own flow in one pass and run the fallback only on segments without it.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| waiter: `invalid format '%d'` on `integer64` counts | cast every count to integer before formatting |
| waiter: `rbind` refused the release row (extra SHA columns) | bind on the union of columns |
| run host `pak`: link pins `fresh@v0.39.0`, conflicts with an unpinned `fresh` request | install link alone, then flooded |
| `knw_size_class()`: 302,904 fish in no class | class only fish of the species groups the breaks tile |
| `left_join`: `integer64` ids against doubles | coerce the site table's `integer64` columns to double |
| bash 3.2: `gh pr create --body "$(cat <<'EOF' … it's …)"` unterminated quote | `--body-file` and `-F` for the commit |
