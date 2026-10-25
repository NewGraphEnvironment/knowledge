# Task: Rebuild the evidence and retune on the republished flows, with the walk ending at the river's bank (#73)

Folds in #68 (the gradient ladder above 9 % for every species) and #80 (the comparison against link's flow
settings), as Al ordered on 2026-10-20: one retune, CH and CO first all the way through, then BT, then the rest, and
the comparison runs without map drawing (#81's run-time pieces).

## Context

The thresholds (`data/thresholds.csv`, `thresholds/v1`) and the fitted curves were tuned on the segment flows of
2026-10-17; wet republished `discharge.fwa_v1_segment_monthly` on 2026-10-19 (build 94deeb5, routed PCIC over
1981–2010) and #65 regraded on the new flows, so the grades and rule km read flows the thresholds were not tuned on.
The database still holds that 2026-10-19 build (checked 2026-10-22), `fresh_default` is still the released run
`20261017_004619-3f4c713b` (log_recompute unchanged, so `0310`'s gate passes on the existing settle log), and nothing
in this repo has moved since.

**What changed outside since the issue was written**, and what it means here:

- **fresh 0.42.0 made the near-river exception a rule condition and an inherited threshold** (fresh#259, #262,
  #263). Its walk, `frs_near_river()`, starts at a segment's downstream end, ends at the river's *bank* (the connector
  inside the target's polygon and the mouth-to-centreline jump are left out; every other gap counts at its straight
  length), never takes a connector as a target, follows main flow, sees one group's table, and never walks a row with no
  local code. fresh checked it against *our* `ch_dist_profile` on BULK (`data-raw/near_river_check.R`): every residual
  falls in a named class, `bank` being the rule difference. So the two walks are already reconciled except for the bank
  rule, which is what #73 planned to add.
- **link 0.67.0 (#364) carries ten `<stage>_river_*` columns** in `parameters_habitat_thresholds.csv`
  (`_measure` ∈ discharge | channel_width | stream_order | model, the three `_min`s, `_distance_max`), scoped per
  species by `rear_near_river` in `dimensions.csv` (`default`: CH `wetland_flow`, CO `both`), and `rear_wetland_flow`
  (`default`: `stream` for the eight species, so 1050/1150 lines go through the gradient and size door). `default`
  gives CH `model`, 3 m³/s / 15 m within 1,000 m on its 1050/1150 rule only; the pair on every stream rule was measured
  on five held-out groups and refused (275.6 km added at 5 % of the core rate). CO has no values yet. Our
  `exception_q` / `exception_d` rows carry a blank `link_parameter` because none existed; link#346 now waits on these
  values from a published table.
- `fresh_default.streams` has no `mad_m3s` (link joins it on the working table) and no `streams_near_river` yet, so a
  regeneration of 0.67.0's `default` on a scratch copy must join wet's pick and walk CH's pair itself.
- Installed: fresh 0.42.0, link 0.66.0 (0.67.0 needed for the configs read through the package; `0310` reads
  `lnk_species_pooling()` and the configs read by `git show` from `LINK_REPO`), wet 0.4.15.

## Decided at the gate (recommendation first; Al confirms or picks)

1. **The walk.** Keep `ch_dist_profile` for every walk (it walks seven river sizes on three sources in one pass,
   uncapped, across group outlets; `frs_near_river()` is one pair per call, one group, capped) and give it fresh's
   bank rule: a connector (1400/1450) is never a target; the connector run inside the target's polygon and the mouth
   jump into it are left out; every other gap counts. Gate: fresh's BULK check reversed (our walk against
   `frs_near_river()` at 3 m³/s within 20 km): the `bank` class must vanish, every other residual in a named class.
   *Alternative:* run `frs_near_river()` for everything: 21 pairs × ~150 groups × up to 50 km, hours per build against
   4 minutes, and it cannot see a river past the group outlet.
2. **Baseline `default` for the comparison: link 0.67.0's** (the door on 1050/1150, CH's pair on them), read from
   `LINK_REPO` at a recorded `config_sha`, with the schema's `link_sha` kept as the provenance of segments and access.
   It is what link draws now. One-time check before the switch: `default` at the run's sha regenerated equals #65's
   `default` km per group. *Alternative:* keep `default` at the run's sha.
3. **One PR, every species, CH and CO written up first.** The evidence build is one build and the thresholds table one
   file: a half-retuned table would mix flows. Machine time is about 8 h in all (scoring 104 min on 14 workers, grading
   ~200 min, comparison ~130 min without maps); BT's comparison is the long one. *Alternative:* PR 1 CH and CO, PR 2 the
   rest, with a mixed table in between.
4. **The pair is published as discharge:** `exception_q` → `<stage>_river_discharge_min` (`_river_measure =
   discharge`), `exception_d` → `<stage>_river_distance_max`; link converts to width where a group is on `cw`, as it
   did 3 m³/s → 15 m. The table gains `river_measure`, `rule_flow` and `rule_flow_196` (plan review B5): a change of
   columns is a new version once a version is published, and `thresholds/v1` has never been uploaded, so it stays v1,
   as do `knowledge/fdis/v3` and `habitat_grade/v1` (the issue's own rule for them).
5. **The scope of the pair is compared, not inherited:** for every species the tuned rule is set beside `default`
   under (T1) the run's structure (free pass on 1050/1150, pair on every stream line, as `CH_rear_v1` was scored),
   (T2) the door with the pair on every stream and 1050/1150 line (link's `both`), and, where the rule has an
   exception, (T3) the door with the pair on 1050/1150 only (link's `wetland_flow`). The write-up says which the
   evidence supports per species; the thresholds table records the scope the comparison recommends.
6. **Which number sets link's floors is link#346's call.** This repo publishes the tuning's pick; link's
   `default_tuned` floors (BT 0.043 on wet, link#331) are scored as candidates in the grid so the table shows how they
   score, and the write-up states both.
7. **#81 and #72 here only as far as the run needs:** `0330` stops drawing and writes one GeoPackage per species ×
   stage; the floodplain table and maps stay under `STAGE=maps`; the grade tables record how they were made (`ref_edge`,
   `q`, the walk, the discharge load) and the consumers check the record. QGIS styling, example maps and the popup stay
   in #81; #72's remaining items close with this.
8. **The fresh-convention differences that remain are reported, not mimicked:** visits walk from their own point (a
   segment property in fresh, since the grade already walks from the downstream end); the comparison's exception
   applies only where fresh's walk would (a local code present), and km that pass only through a river in another
   group are counted.

## Phase 1: The walk ends at the bank

`inst/sql/ch_dist_profile.sql`, `R/link_walks.R` (`scripts/sql/ch_dist_profile.sql` stays frozen for `0298`).

- [x] Never stop on an edge 1400/1450 segment: the target is the first primary-flow segment with flow ≥ q that is
      not a connector
- [x] When the target is a double-line river (edge 1250, a `waterbody_key`), leave out the connector run inside its
      polygon (same `waterbody_key`) and the mouth-to-centreline jump into it; keep every other gap in `max_entry_gap_m`
      and return the old distance as `dist_centre_m` and the subtraction as `bank_m`, so the change is measurable per
      start
- [x] `knw_link_walks()` returns the two new columns; roxygen and `man/` say the distance ends at the bank
- [x] `data-raw/walk_bank_check.R`: on BULK, a scratch segmentation with wet's pick as `mad_m3s` (fresh's
      `near_river_check.R` pattern), `frs_near_river()` at 3 m³/s within 20 km against our walk from the same
      segments' downstream ends; classes `agree`, `bank`, `bank_jump`, `path`, `beyond`, `truncation`, `ref_none`,
      each residual in one, the bank residual reported by class and for origins whose line ends at a side-line
      connector (plan review B3); `bank` must be 0 rows; log under `scripts/logs/habitat/<date>_walk_bank_check.txt`
- [x] Every hop's gap counts in the distance, as fresh counts it (plan review B2: the walk before #73 counted none,
      so subtracting a jump's crossing of the bank would have discounted a length never counted)
- [x] Unit test on a synthetic three-segment network (tributary, connector, river) if the suite can hold one without a
      database; otherwise the BULK check is the gate and the test file says so

## Phase 2: The grid, the pick and link's floors

`R/tune_grid.R`, `R/tune_score.R`, `R/tune_repick.R`, `R/tune_run.R`, `scripts/0320-tune-run.R`.

- [x] `knw_tune_grid()` default `grid_grad` extended to 11, 13, 15, 20, 25 and 30 % (#67's steps), one shared ladder
      (#68); `test-tune_grid.R` pins the ladder
- [x] link's `default_tuned` MAD floors join each species' grid as candidates (read from `configs/default_tuned` at
      the run's `link_sha`, where `default` is read too: the grid is anchored on the run's bundle; plan review O2),
      labelled so the tune table can name them
- [x] The pick with link's flow version as the starting point (#80 task 1): `departures` counted from a chosen start
      rule; `knw_tune_score()` / `knw_tune_repick()` take `start`, the tune table carries `recommended` (width start)
      and `recommended_flow_start`, each at 1 and 1.96 SE; smoke it on the saved tables before the retune
- [x] `0320` writes both picks to `<key>_summary.csv`; the scored-grid cache stays keyed on the grid (#67)

## Phase 3: Grade tables say how they were made (#72)

`R/tune_curve.R`, `R/grade_species.R`, `scripts/0320`, `scripts/0325`, `scripts/0330`, `R/thresholds_table.R`.

- [x] `knw_tune_curve()` records `edge_stream` on the curve object; `knw_grade_species()` takes `ref_edge` from the
      curve by default and returns `ref_edge`, `q` and `walk = "bank"` beside `reference`
- [x] `0320` writes `ref_edge`, `q`, `walk`, `discharge_load` (the table comment at grading) into the grade table and
      its log line; the keep check reads them, not the `stream_branch` literal
- [x] `0325` derives `stream_branch` from the recorded edges, publishes `discharge_load` and refuses when the live
      comment differs; `0330` and `data-raw/vignette_chinook.R` check the recorded values

## Phase 4: The comparison without maps, both structures, a GeoPackage

`R/compare_rules.R`, `scripts/0330-compare.R`, `R/thresholds_table.R`.

- [x] `knw_compare_rules()` reads link's configs at `config_sha` (default: `LINK_REPO`'s `origin/main` at run time,
      recorded in the log and `compare.csv`); for a `default` rule carrying `near_river`, join wet's pick as `mad_m3s`
      on the scratch copy, walk the rule's pairs with `frs_near_river()` and pass `near_river_table` to
      `frs_habitat_predicates()`
- [x] One-time check (before the baseline moves): `default` at the run's `link_sha` regenerated equals #65's
      `compare.csv` `default` km per group for every key; logged
- [x] The tuned predicate takes a `structure` argument: T1 (free pass on 1050/1150, pair on stream lines), T2 (door,
      pair on stream and 1050/1150 lines), T3 (door, pair on 1050/1150 only); the exception applies only where
      `localcode_ltree` is present; km passing only through a river in another group counted (`large_lfid`'s group)
- [x] `0330` runs `default` + T1 + T2 (+ T3 where the rule has an exception) per key; `compare.csv`, `change.csv` and
      `checks.csv` carry a `structure` column; the default run draws nothing and skips the floodplain (`STAGE=maps`
      keeps both); one GeoPackage per key under `data/compare/gpkg/` (ignored) with each segment's verdict under each
      rule and structure, class, grade, size, width, gradient, walked distance, stream order and the link branch that
      kept it (#81's data part)
- [x] `knw_thresholds_table()` fills `link_parameter` for `exception_q` and `exception_d`, adds `river_measure =
      discharge`, `rule_flow` and `rule_flow_196` (the flow-start picks); the recommended scope of the pair is a
      judgement made after the comparison and goes in the research files and link#346's body, not the table (plan
      review O1); `test-thresholds_table.R` pins it

## Phase 5: The evidence build on the current flows

- [x] Install link 0.67.0; confirm the discharge comment is still build 94deeb5 and `fresh_default.log_recompute`
      still the released run (else rerun `0300`)
- [x] `0310` (~20 min): the visit tables and the walks rebuilt; `0290`, `0294`, `0296` rewritten from it; `0299`
      local build as v3 (unpublished; the ledger records the flow build)
- [x] Record in `findings.md` how many visit distances moved and by how much (bank rule and flows separately, from
      `dist_centre_m` and `bank_m`)

## Phase 6: CH and CO, all the way through

- [x] `SPECIES=CH,CO` `0320` on the 16-core machine (`WORKERS=14`): scores on the extended ladder, both picks, curve,
      grade at the bank distance (run on this machine: 67.6 min on 8 workers, then rescored under the intercept fix in
      91.2 min on 6 workers; `scripts/logs/habitat/20261022_tune_run-ch_co.txt` is the second run's)
- [x] `SPECIES=CH,CO` `0330`: `default` (0.67.0) + T1 + T2 + T3; FDIS and bcfishobs checks per structure (CO in the
      first run, stopped once the CH pick moved; CH alone 153.1 min, 2026-10-23; the combined tables compose per-key runs)
- [x] Write-up: `research/chinook_rearing_tuned.md` and `coho_rearing_tuned.md` revised in place (life-history prior
      first, then the evidence, the recommendation, what it is not; the pair's scope with link#364's measurement beside
      ours; the flow-start pick; the ladder); the two rows of `research/habitat_thresholds_tuned.md`

## Phase 6a: The gate and the scorer's cost, before any rescore (#84, #83)

Added 2026-10-23 (Al), after Phase 7's BT box: the four-species scores showed a second scorer defect only after the
run (findings, "The intercept minimiser sticks on a flat clamp"), so Phase 7's remaining boxes wait on this phase.

- [x] #84: a smoke run per key (no rule, `default`, the previous pick, link's `default_tuned` floor; one fold seed, no
      bootstrap, no nested selection) and its gates: no-rule held-out deviance near the in-sample null, no visit at the
      clamp's 55.3, no rule behind no rule by more than the null deviance, no training coefficient past a stated size
      (`knw_tune_smoke()`, `R/tune_smoke.R`; `tol_null` 0.25, `coef_max` 10; the whole smoke over eight keys takes
      about 25 s on one worker, rainbow 11 s)
- [x] #84: `0320` runs the smoke run and gates first, for every key, and refuses the full grid on a failure; a
      development setting skips the extra seeds, the bootstrap and nested selection (`knw_tune_run(smoke, smoke_only,
      previous, extra)`; `0320` `DEV=1`: main seed only, no grades, outputs under `data/tune/dev/`)
- [x] #84: the gates fail on the scorer at `84c3c78` and pass on `ca78ca6` (mutation table in findings); the
      coefficient check's finding on `data_set` and `era` recorded, and any change to those terms decided from it.
      **Measured 2026-10-23: they do not all pass on `ca78ca6`** (findings, "The smoke run's mutation table"): the
      centred search still stops on the plateau where a held-out group's offsets are spread (ST), so the search is
      now the root of the deviance's derivative; the coefficient check fails on GR, RB, ST and WCT at every scorer
      version, which is the training fit's finding. **Decided (Al, 2026-10-23): option A**, a normal prior, SD 2.5
      on the cloglog scale, on the `data_set` and `era` coefficients inside the fit (`prior_sd`); measured on every
      key at no prior, 5, 2.5 and 1.5 (findings, "The prior on the data-set and era coefficients"): every gate passes
      on every key at every prior, the largest coefficient at 2.5 is 3.12
- [x] #83: group intercepts without a dense column per group; a dense-fit reference rescored first on the current
      scorer (the committed CH and CO tables came from the old search) and reproduced; rainbow timed against 8.1 h
      (`.tune_glm_fe()` in, `fit = "fe"` the default; the reference on six species reproduced rule by rule on
      2026-10-23, 110 min to 17, findings "The fit with the groups absorbed"; the fall-back test narrowed after it
      fired on every chinook fold; rainbow with every extra 16.6 min on m4's 12 workers against 8.1 h here, a
      machine-to-machine comparison as well; m4 set up with the branch, the evidence build and the database)
- [ ] Run rule from here: no chained tuning and comparison; every key's gates pass, then score, check, grade, compare

## Phase 7: BT, then GR, RB, ST and WCT

- [x] `SPECIES=BT` `0320` and `0330` (rear and spawn; the long one); `bull_trout_tuned.md` (0320 262.7 min on
      2026-10-22; 0330 206.9 min on 2026-10-23 against the archived schema; file rewritten)
- [x] `SPECIES=GR,RB,ST,WCT` `0320` and `SPECIES=GR,ST,WCT` `0330`; GR, ST and WCT research files' numbers, picks and
      the ladder sentence (done 2026-10-24 on every key with RB in: all four files rewritten, `0320` with the curve's
      prior and the gate, `0330` on all eight keys; coho and chinook revised too). **RB deferred (Al, 2026-10-23):** left out of the comparison, the write-ups and the
      thresholds table until #83 lands (findings, "Rainbow deferred"); the stopped run's RB tables were restored to
      HEAD, so nothing of it is kept. If #83 makes RB feasible, it comes back in this box
- [x] **Hold lifted 2026-10-23: Phase 6a done, the prior adopted, every gate passes on every key; the rescore is
      scored on m4 and graded here** (`0320` at `fa638f2`, every species: scored on m4 by 22:26 UTC 2026-10-23, smoke
      passed on all eight keys; grading moved here, 224.6 min, exit 0, 2026-10-24; picks moved on BT_rear, RB_rear and
      WCT_rear; findings, "Phase 7's rescore"; recompared here, GR, WCT, ST, RB, BT, all exit 0, 2026-10-24,
      findings, "Phase 7's recompare"; regraded with the curve prior and the grade gate, 190.9 min, exit 0,
      2026-10-24, grades withheld from CO_rear, ST_rear and WCT_rear; recompared on all eight keys, WCT 18.4 min then
      the other seven in one run, 160.1 min, all exit 0). The write-ups: CO, CH, GR, RB, ST and WCT on 2026-10-24, bull trout on
      2026-10-25 (`research/bull_trout_tuned.md` rewritten on the rescore; its rearing pick moved to MAD ≥ 0.35 at 25 %). Was: on hold until Phase 6a (Al, 2026-10-23),
      no rescore until the tuning is organized for fast, checked iteration (findings,
      "The intercept minimiser sticks on a flat clamp"). The fix is in (`ca78ca6`); every #73 score (CH, CO, BT and the
      four) came from the old search. `data/tune/{CH,CO,BT}_*_score.rds` are stale caches of it and must be removed
      before any `0320`, which keys its cache on the grid, not the code. The committed CH, CO and BT write-ups rest
      on those scores until a rescore says whether their picks hold. Then one rescore of every key (CH, CO, BT rear and
      spawn, GR, ST, WCT; RB if #83 allows) on `SCHEMA=fresh_default_20261017`; regrade; recompare the keys whose pick
      moves and GR, ST, WCT; revise the CH, CO and BT write-ups where a pick moves. The grade keep-check compares rule,
      run_uid, walk, ref_edge and discharge_load, not `q`: check `q` by hand
- [x] `research/habitat_thresholds_tuned.md`: Results, "At 1.96 SE", Grades, "What each rule changes" and Limits
      rewritten from the new tables (2026-10-25, every row #73's; the README's eight rows with it) (the distance bullet now says bank); every quantified claim recomputed at the grain
      of the sentence

## Phase 8: Publish and regenerate

- [ ] `0325` includes RB in `thresholds/v1`, `thresholds_groups` and the grade table (no longer deferred: #83 landed and
      RB was tuned, graded, compared and written up on 2026-10-24; was: leave RB out and name the deferral), and leaves
      the grade-withheld keys (CO, ST, WCT rearing) out of `habitat_grade/v1`
- [x] `knw_thresholds_table()` adds `near_river_scope` from each key's `compare.csv` `tuned_structure` (door → `both`,
      door_wetland → `wetland_flow`, empty where the rule has no pair); Phase 4 ticked it but the column was never written
      (found 2026-10-23); `test-thresholds_table.R` pins it; `R/` is edited only after the chain's last `0320`/`0330` exits
- [ ] `0325`: `thresholds/v1`, `thresholds_groups`, `habitat_grade/v1` (local; `PUBLISH` waits on #56's bucket
      policy); `data/thresholds.csv` and `thresholds_groups.csv`
- [x] (2026-10-25: `vignette_chinook.R` takes `SCHEMA`; `0325` reads no schema, only the discharge comment, and
      `readme_figure.R` reads no database, so neither needed it) `0325`, `data-raw/vignette_chinook.R` and `data-raw/readme_figure.R` read the run's schema by name (`SCHEMA`,
      default `fresh_default`), as `0320`/`0330` do since link#361 renamed it to `fresh_default_20261017` on 2026-10-23;
      the thresholds table's provenance names the run, not the schema
- [ ] `data-raw/vignette_chinook.R`, then `data-raw/vignette_bib.R` if a citation changed, then
      `data-raw/readme_figure.R`; the article's prose checked against the new numbers (every number is computed inline;
      read the rendered page for sentences the numbers no longer support); the `grad_ext` section now reads as the run
      that led to the shared ladder
- [ ] README example output repasted from the new `data/thresholds.csv` (#75)
- [ ] `scripts/README.md` run order (0310 bank walk, 0320 ladder and picks, 0330 structures and GeoPackage, 0322 as
      #67's record), `research/README.md` rows, `CLAUDE.md`'s walk sentence (centreline → bank) and the `0322`
      paragraph
- [ ] `devtools::test()`, `lintr::lint_package()`, `devtools::document()`, `pkgdown::check_pkgdown()`

## Owed at the end (reported, done after merge)

- [ ] link#346's body: one line naming the published table's columns for the pair and the scope the comparison
      recommends per species
- [ ] #81's body: which tasks landed here (no maps in the default run, the GeoPackage) and which remain
- [ ] #72, #68 and #80 bodies: what landed, then close with #73 when the PR merges
- [ ] `PUBLISH=TRUE` for `0299` v3, `0325` thresholds and grade, once #56's bucket policy is in

## Validation

- [ ] Tests pass
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:

- **Walk:** `walk_bank_check.R` on BULK, `bank` class 0 rows and every residual classed; the per-start `bank_m`
  distribution reported (median, 90th percentile) beside #65's connector measurement (median 14–88 m).
- **Grid and picks:** `test-tune_grid.R` pins the ladder; the flow-start pick smoke on the saved tables reproduces
  #80's table (BT rear 1.26 SE behind, etc.) before the retune.
- **Comparison code:** `default` at the run's sha equals #65's km per group before the baseline switches to 0.67.0;
  after, the 0.67.0 `default`'s CH through-wetland km is checked against link#364's measurement on the five groups it
  scored (ADMS, BULK, CHWK, CLWR, SQAM: door alone removes 43.1 km of CH rearing).
- **Provenance:** `0325` refuses when the live discharge comment differs from the grade's; `0330` refuses a grade
  table whose recorded walk is not `bank`.
- **Tables:** `test-vignette-data.R` green after the regen; `test-thresholds_table.R` pins `link_parameter` for the
  pair; the README example's printed output equals the committed CSV.
- **Prose:** every quantifier in the research files and the article recomputed from the tables at the sentence's
  grain (the #65 lesson), listed in `findings.md` with its verdict.

