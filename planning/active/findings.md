# Findings — Rebuild the evidence and retune on the republished flows, with the walk ending at the river's bank (#73)

## Issue context

**If done:** the thresholds, the fitted curves and the grade all rest on one flow build, the one wet republished on 2026-10-19 (wet 94deeb5, routed PCIC over 1981–2010; NewGraphEnvironment/wet#103). **If never:** `thresholds/v1` and the curves stay fitted on visits carrying the flows before that republish, while `habitat_grade/v1` and the comparison read the segments' current flows, so a rule's floor is tested on flows it was not tuned on.

## Problem

#57 built the visit tables (`scripts/0310`, `knowledge/fdis/v3`) and tuned every threshold (`scripts/0320`) on the database's flows of 2026-10-17. wet#103 then republished `discharge.fwa_v1_segment_monthly` (comment: built 2026-10-19T06:08:31Z, wet 94deeb5). #65 regraded and compared on the new flows (decided 2026-10-19), so its grades and rule km read them while the thresholds and curves do not.

Measured on accessible stream-branch segments, the 17 October comparison against #65's grade tables (#65's `findings.md`):

| key | segments whose flow moved | new/old flow, 5th–95th percentile | km that now pass the floor | km that now fail it |
|---|---|---|---|---|
| BT rearing (0.35 m³/s) | 73.5 % | 0.939–1.043 | 222 | 252 |
| BT spawning (0.75) | 73.5 % | 0.939–1.043 | 191 | 213 |
| CH rearing (0.75) | 81.2 % | 0.941–1.043 | 104 | 62 |
| CO rearing (0.03) | 79.3 % | 0.953–1.041 | 132 | 150 |
| ST rearing (1.0) | 77.5 % | 0.974–1.036 | 89 | 20 |

Width rules (GR, RB, WCT) do not move.

### Distance ends at the river's centreline, not its bank (added 2026-10-20, from #65's review)

The walk (`inst/sql/ch_dist_profile.sql`) follows network lines to the first river of the curve's flow. Where a tributary meets a double-line river, its line usually crosses the river polygon as a connector (FWA edge type 1450) to the centreline, and the connector carries the tributary's small flow, so the walk counts it, for visits and segments alike. Of the curves' visit sites whose walk found a river, 59–94 % per key end on a double-line river. Of those whose tributary could be traced (97–99 %), 89–96 % have a connector, which adds a median of 14–88 m (90th percentile 38–324 m), a median 0–2 % of the site's distance; the rest (4–11 %) have none: 31–96 % of them hop no gap of 1 m or more on the way, and the others hop one somewhere on the walk, which the walk does not count (over all no-connector sites, the largest hop gap has a median of 0 m for BT, CO, RB and ST and 135–311 m for GR, CH and WCT). Measured to the bank instead, 22 of the 2,260 traced CH sites would fall inside its 1 km exception, and none of BT spawning's inside 2 km (#65's archive, `check_connector_share.txt`). The retune is the time to end the walk at the polygon's edge, and to decide whether a hop gap the walk does not count should count, because both change the visits' distances and so the picks and the curves.

## Order (Al, 2026-10-20)

CH and CO first, all the way through (scoring, comparison, write-up); then BT; then the rest. One retune covers #73, #68 and #80 (the flow starting point), and the comparison runs without map drawing (#81).

## Plan

- Rebuild the visit tables on the current flows (`scripts/0310`), a new `knowledge/fdis` version if any column's values move.
- End the walk where the tributary's line enters the target river's polygon (the bank), for visits and segments alike, and rewalk the visits (`scripts/0310`).
- Retune (`scripts/0320`): the picks, the regions and the curves; the grade then regrades on the new curves.
- Republish the thresholds and the grade, and rerun the comparison.
- Rerun the README's example against the new `data/thresholds.csv` and repaste its output, and rerun `data-raw/readme_figure.R` (#75).

Thresholds/v1 and habitat_grade/v1 have not been uploaded (#56's bucket policy); if this lands before the upload, both stay v1.



## Plan review (2026-10-22)

`review-plan.md` holds the Plan agent's findings and what was done about each. Two defects in Phase 1's first draft came
from it (a record variable shadowing a table alias, so every hopping walk errored; and a jump subtracted that the walk
never counted), and two corrections to the plan (the near-river pair link walks under `cw` is channel width 15 m, not
3 m³/s; `default_tuned` is read at the run's sha).

## Decisions and overrides recorded

- `knowledge/fdis/v3`, `thresholds/v1` and `habitat_grade/v1` keep their version numbers although values and (for the
  thresholds) columns move: none has been uploaded, and a version is a published thing (plan review S1, B5).
- The near-river scope the comparison recommends is not a thresholds-table column: it is a judgement made after
  Phases 6–7, carried in the research files and link#346's body (plan review O1).

## One-time check of the comparison code (plan review O4, 2026-10-22)

Before `knw_compare_rules()` was edited: CH rearing on ADMS and BULK with link's configs at the run's sha (a17e9177),
fresh 0.42.0, 2.3 min. `default_km` and `tuned_km` per group reproduce `data/compare/CH_rear_compare.csv` (#65, fresh
0.39.0) to within 1e-11 km (ADMS 588.884 / 608.304; BULK 2,123.017 / 1,608.110). So the regeneration is unchanged across
the fresh bump, and a difference after the Phase 4 edits is the edits' (`scratchpad/default_check_o4.out`).

## The walk against fresh's on BULK (`scripts/logs/habitat/20261022_walk_bank_check.txt`)

Three runs on 2026-10-22, each 2,460 origins (2,000 random main-flow segments below 3 m³/s with a local code, plus 500
fresh places within 200 m of a river), fresh 0.42.0 at 3 m³/s within 20 km:

| run | agree | bank | path | beyond | note |
|---|---|---|---|---|---|
| first draft | — | — | — | — | every hopping walk errored (record `c` shadowed the alias `c`) |
| hops fixed, gaps not counted | 1,799 (73.1 %) | 0 | 216 (8.8 %) | 445 (18.1 %) | 209 of the 216 `path` rows had our walk shorter: the uncounted jumps, which the `bank` class could not see (review B3) |
| gaps counted | 1,859 (75.6 %) | 8 (0.3 %) | 148 (6.0 %) | 445 (18.1 %) | 85 side-line-connector origins agree with fresh to 0.00 m |
| final, `bank_jump` classed apart | 1,859 (75.6 %) | 0 (`bank_jump` 8) | 148 (6.0 %) | 445 (18.1 %) | the gate: `bank` 0; fresh's subtraction and ours identical within 0.01 m on 92.6 % of 2,006 starts both found, within 1 m on 92.9 %; the rest are `path` rows, whose subtractions differ with their paths |

The 8 `bank` rows all land on two rivers (waterbody keys 329706585 and 329706586) by a jump of 311 m or 46 m from a line
ending in a plain stream segment; our subtraction is 26.6 m against fresh's 23.8, and 16.2 against 15.7. The
subtraction there is the jump line's crossing of the bank, which depends on the row each walk lands on (fresh: the row
`FWA_Downstream()` orders first; ours: the nearest), so the difference, 1 % of the jump, is the landing point, not the
rule; the class `bank_jump` now separates these from a true rule difference (`bank`, expected 0). `beyond` is fresh's
20 km cap against our uncapped walk. Our walk's `bank_m` is positive on 67 % of found starts: median 31.8 m, 90th
percentile 66.1 m, largest 599 m (against #65's connector estimate, median 14–88 m). 2,460 starts walked in 4.7 s.

## The comparison smoke on ADMS and BULK (2026-10-22, old grades and pick, link 0.67.0 configs at 67a410e)

CH rearing, 3.6 min for 2 groups × 4 rules (near-river walks 0.8 min). `default` under 0.67.0 (the door on through-wetland
lines, CH's 15 m pair on them) is 588.7 km on ADMS and 2,096.4 on BULK against 588.9 and 2,123.0 under the run's `default`:
the door took 26.8 km of through-wetland CH rearing off the two groups. The `free` structure gives 608.304 and 1,608.110
km, #65's tuned km to the metre, so T1 is the structure `CH_rear_v1` was scored and compared under. Through-wetland CH km
on the two groups: `default` 184.4 (216.9 before connectivity), `free` 205.8, `door` 45.9, `door_wetland` 43.6. The
bcfishobs lift (40 locations on accessible stream edges): default 2.63, free 3.72, door 3.72, door_wetland 4.06.
`gained_exception_other_group_km` reads 0 because the old grade tables carry no `target_in_group`; the regrade will.

## The evidence rebuild (0310, 2026-10-22; `scripts/logs/habitat/20261022_evidence_build_ledger.csv`)

Same run (`20261017_004619-3f4c713b`, link a17e9177), link 0.67.0 installed, the database's flow build still
2026-10-19 (wet 94deeb5; the S3 manifest the ledger names is wet's 2026-10-20 publish, which added `segment_daily`
without changing the monthly table the database holds). 40,552 visits placed, 34,192 walk starts × 3 sources × 7 sizes
in 4.2 min (4.4 in #57). The loaded pick counts moved with the 2026-10-19 reload (routed 3,152,838 → 3,154,131; balance
1,380,005 → 1,378,712); every other drop and kept count is #57's.

How the visits' distances moved, old (v3 Parquet of 2026-10-17: centreline, no gaps, the flows of 2026-10-17) against
new (bank, gaps, the flows of 2026-10-19), on `pick`, 213,738 of 239,344 rows joined on the start key (the rest differ
in the measure's printed precision between Parquet and CSV):

| river size | both found | change, median (p10, p90) | bank taken off, median | gaps and flows, median (p90) | abs change > 100 m | crossing 1 km down / up | crossing 2 km down / up |
|---|---|---|---|---|---|---|---|
| 1 m³/s | 29,852 | 0.0 (−428, 0) | 0.0 | 0.0 (0.0) | 21.9 % | 594 / 136 | 478 / 151 |
| 3 m³/s | 29,481 | −11.9 (−757, 43) | 14.6 | 0.0 (99) | 29.7 % | 607 / 120 | 518 / 125 |
| 10 m³/s | 28,546 | −24.4 (−1,081, 345) | 34.7 | 0.0 (462) | 39.0 % | 572 / 108 | 502 / 123 |
| 50 m³/s | 26,906 | −49.4 (−1,458, 1,071) | 67.9 | 0.0 (2,084) | 46.9 % | 373 / 80 | 358 / 81 |

So the bank rule shortens the typical walk to a 3 m³/s river by about 15 m, the counted gaps lengthen one walk in ten
to a large river by hundreds of metres (a tributary ending across a lake or a wide polygon from its parent's line), and
the republished flows move the first segment at or above a size up or down the line, which is most of the p10. No walk
that found a river lost it; 15 found one they had not. Over every source and size, 459,556 of 654,793 found rows have
`bank_m > 0`, median 66.9 m, 90th percentile 1,816 m (the lake case: the walk ends at the shore).

## Errors Encountered

| Error | Resolution |
|-------|------------|
| CH rearing's curve scored 2,434 held-out against 1,383 for no rule (`0320`, 2026-10-22) | The per-group intercept refit (`stats::glm.fit()` with the fold's predictions as offset, cloglog) reported convergence at an intercept where every detection's chance was under the 1e-12 clamp (55.3 deviance each: NECR's 12 detections 663.1, 28 detections in 7 groups in all). `.tune_group_dev()` now fits the intercept by a bounded golden-section minimiser of the deviance, convex in the intercept under cloglog, in both callers. A probe that replayed three rule patterns (no rule, the pick, the flow default) found their scores unchanged to 0.01 and was read as the rule scorer being unaffected; the rescoring showed otherwise: 2,269 of CH's 6,149 rules moved, 2,267 of them down (median drop 445, up to 1,195), every one an exception rule or a MAD rule, while the three replayed patterns and CO's 6,149 rules did not move. The pick moved from `mad>=0.5\|g<=0.15\|Q1@D1000` (unchanged at 1,132.1, now 11.5 behind) to `mad>=0.75\|g<=0.13\|Q3@D1000` (1,305.6 before, 1,120.5 after); the curve scores 1,053 |
| The first `0320` rerun failed on every socket worker: `could not find function ".tune_group_dev"` | A worker loads no package and gets its functions by `clusterExport()`; the new helper is exported beside `.tune_score_one()`, and the re-run test now scores on two workers |
| The `0330` run launched beside the rescoring compared CH against the first run's pick | `0330` reads the picks when it starts, so it was stopped once the rescoring moved CH's pick (CO's tables were written, its pick unchanged); it now composes the combined tables from every per-key table made under this comparison, and CH reruns alone |
| Phase 4's box said `knw_thresholds_table()` adds `near_river_scope`; the column is absent from `R/thresholds_table.R` (grep, 2026-10-23), and two research files had described it as present | Prose corrected to "from `0325`'s next run"; the column is a Phase 8 task, written after the chain stops reading `R/` |
| The gradient bands in the chinook evidence paragraph were read from the curve data's `grad`, which `knw_tune_curve()` clamps at 20 % (`R/tune_curve.R` line 70) and which is `fwa_gradient`, not `segment_gradient`; the file said no modelled visit is above 20 % when 145 are (1 detection) | Bands recomputed on the unclamped `fwa_gradient` for CH, BT rear and BT spawn (2026-10-23); the sentence corrected; every later band table reads that column. The clamp also means the fitted gradient curve, and the grade, hold the 20 % rate above 20 %: a Limits point for Phase 7 |

## The CH and CO tuning on the rebuilt evidence (`0320`, 2026-10-22/23; `scripts/logs/habitat/20261022_tune_run-ch_co.txt`)

Two runs: the first (67.6 min, 8 workers) scored the rules with the runaway intercept refit; the second (91.2 min, 6
workers) rescored them under `.tune_group_dev()`. The tables in `data/tune/` are the second's. Rule deviances that
did not involve a pinned group are identical between the two (CO: every rule; CH: 3,880 of 6,149).

**CH rear** (7,123 visits, 216 detections, 104 groups, 43 with both outcomes; 4,490 modelled): best and recommended
`mad>=0.75|g<=0.13|Q3@D1000` at 1,120.5 (null 1,382.5; `default` 1,347.0, +226.4, SE 91.8, 2.47 SE behind, outside
the region; link's `default_tuned` `mad>=0.28|g<=0.0549|none` +188.9, SE 81.2, outside). Region 83 rules, every one a
MAD rule with an exception (MAD 0.15–1, gradient 7–30 %, Q 1–10, D 500–2,000), all three departures from `default`;
from the flow start the pick is `mad>=0.28|g<=0.11|Q3@D1000` (+26.3, SE 28.8, in the region, two departures). At
1.96 SE: `mad>=1|g<=0.0549|Q3@D1000` (width start), `mad>=0.28|g<=0.0549|Q3@D1000` (flow start); the 1.96 region
holds 2,066 rules and `default` is 2.47 SE outside it. Profiles (best per value; ddev, SE): size 0.75 best, 1 +1.8
(18.2), 0.5 +4.4 (20.6), 0.2 +19.5, 0.35 +21.0, 0.28 +25.7, 0.15 +34.7, 0.1 +52.9 (50.6); widths +66.4 (4 m) to
+199.0 (1 m), none in the region. Gradient 13 % best, 11 % +0.4 (12.9), 15 % +2.3 (6.0), 30 % +7.3 (11.9), 20 % +7.3
(7.7), 25 % +11.4, 9 % +17.5 (17.3), 7 % +21.6 (29.9), 5.49 % +63.6 (46.1), 4 % +105.4, 3 % +149.6. Q 3 best, 1 +11.5
(24.7), 5 +20.9, 10 +26.6, 20 +54.1, 50 +105.0, 30 +112.6, none +150.5 (77.8). D 1,000 best, 2,000 +16.3 (23.5), 500
+35.4, 5,000 +51.2, 250 +54.3, 100 +85.5. Best rule without an exception `mad>=0.2|g<=0.11|none` +150.5 (SE 77.8); best
width rule `width>=4|g<=0.15|Q3@D1000` +66.4 (40.5). Raw rates: the pick 1,234 visits in, 180 detections, 14.6 % against
1.1 % out; `default` 2,330 in, 165 detections, 7.1 % against 2.3 %. Bootstrap (200 resamples; width start | flow
start): MAD 100 % | 100 %; 0.75 28.5 | 18.5, 0.5 24.5 | 18.5, 1 23.5 | 18.5, 0.28 2.0 | 37.0; gradient 11 % 26.0 |
26.5, 15 % 24.0 | 27.5, 30 % 18.5 | 16.5, 5.49 % 15.0 | 10.5, 13 % 14.0 | 16.0; Q 3 68.5 | 62.5, 1 21.0 | 26.5; D
1,000 71.0 | 71.5, 2,000 21.5 | 19.0. The exact pick came back on 5.5 % of resamples; its region share 59.5 %. Seeds
55–58 recommend `mad>=0.75|g<=0.15|Q3@D1000`, `mad>=0.5|g<=0.11|Q3@D1000`, `mad>=0.5|g<=0.13|Q3@D1000`,
`mad>=0.75|g<=0.11|Q3@D1000`: the exact rule on 0 of 4, a MAD floor of 0.5 or 0.75 with 3 m³/s within 1 km on 4 of 4,
`default` outside on 4 of 4, the main pick inside the region on 4 of 4. Honest (nested) 1,183.4 for the pick against
1,347.0 for `default` and 1,382.5 for no rule; fold picks `mad>=1|g<=0.11|Q3@D1000` (twice), `mad>=0.75|g<=0.11|Q3@D1000`,
`mad>=0.5|g<=0.13|Q3@D1000`, `mad>=0.5|g<=0.13|Q10@D1000`, each beating `default` on its fold except fold 4 (243.4
against 230.3). Curve 1,053.2 held-out, below the grid's best; edf te(log_size, log_dist) 12.11, s(grad) 1.00,
s(wsg) 33.56.

**CO rear** (5,442 visits, 1,107 detections, 85 groups, 62 both; 4,263 modelled): unchanged by the rescoring.
Recommended `mad>=0.03|g<=0.04|none` from both starts (+11.8, SE 17.3; raw 41.2 % in against 15.2 % out); best
`mad>=0.1|g<=0.04|Q3@D2000` 3,856.3; null 4,024.6; `default` 3,968.1 (+111.8, SE 47.4, 2.36 SE, outside);
`default_tuned` `mad>=0.03|g<=0.0549|none` +72.5 (SE 28.5), outside. Region 89 rules (87 with an exception). 1.96 pick
`width>=1.5|g<=0.04|none`. Bootstrap: MAD 86 | 97 %, 0.03 69 | 86 %, gradient 4 % 54 | 50.5, 3 % 37.5 | 41.5, no
exception 55.5 | 59; exact pick 27 %. Seeds 4 of 4 the same pick, `default` outside on 4 of 4. Honest 3,877.8 against
3,968.1 and 4,024.6 (folds 1–3 pick 3 %, 4–5 4 %). Curve 4,092.5 held-out, above the grid's best and the null; edf te
23.11, s(grad) 3.75, s(wsg) 48.74.

**Grades** (`scratchpad/grade_summ*.out`; discharge load "built 2026-10-19T06:08:31Z, wet 94deeb5"; walk `bank`;
reference over edges 1000, 1100, 2000, 2300). CH under the pick: 125 groups, 856,244 accessible segments, 852,431
graded (6,259 without a size), reference rate 0.1357, walks to 3 m³/s (18.7 min; 9,159 of 809,410 found rivers in
another group); km accessible 225,152, graded 224,459, grade-weighted 61,423 (#65: 63,059); under 0.2: 153,211 km
(68 %); 0.8–1: 46,373 km (20.7 %); km at distance 0: 51,257 (river polygons 33,350, stream branch 12,827). CO
(kept from the first run; the pick did not move): 100 groups, 615,302 accessible, 607,483 graded (10,518 without a
size), reference 0.5196, walks to 10 m³/s (43,945 of 484,751 found rivers in another group); km accessible 147,795,
graded 146,612, grade-weighted 72,637 (#65: 70,905); under 0.2: 28,477 km (19 %); 0.8–1: 33,620 km (23 %).

The first scoring's tables (before the intercept fix) are kept as `scripts/logs/habitat/20261022_tune_run-ch_co_run1_{CH,CO}_rear_tune.csv`; the rescored tables are `data/tune/`. The probes used in the diagnosis (`curve_diag.R`, `score_probe.R`, the three-pattern probe that wrongly cleared the scorer) and the walk and baseline checks (`walks_moved.R`, `default_check_o4.R`) are in `planning/active/scratch/`.

## Phase 8 notes gathered while the runs went (2026-10-23)

`vignettes/chinook_rearing.Rmd` guards that the new chinook pick will break: line 78 `ch196$size_min == rec$size_min`
(1 against 0.75) and `is.na(ch196$exc_q)` (the 1.96 pick now keeps an exception); line 90
`abs(wl$km_tuned - 10200) < 200` (through-wetland km change under the door); line 83 `ge_best$grad_max > rec$grad_max`
now holds (15 > 13); boot_grad 0.14 < 0.5 still ok. Prose to revise: "The answer" (the stricter-bar sentence), "What
does link do now?" (0.67.0's pair on 1050/1150, the flow start), "A stricter bar", "Before you use it" wetland bullet
(door now), "Steeper slopes" bullet (the ladder is shared; 13 % pick), the distance-from-bottom bullet (bank).
`data-raw/vignette_chinook.R` already checks `walk == "bank"`, the `structure` columns, `link_config_sha` and
`tuned_structure`; builds `out$wetland` per structure from `<key>_segments.rds`; reads the grad_ext tables and
`scripts/logs/habitat/20261018_tune_grad_extend.txt`; takes meta from the tuning log's `CH_rear grades:` line.
`scripts/README.md`'s 0310/0320/0322/0325/0330 entries and CLAUDE.md's walk sentence already describe the #73 state.
`README.md`'s thresholds example (lines ~48–60) is repasted after 0325 (#75). `data/thresholds.csv` carries
`rule_196`, `holds_196`, `config`; `R/thresholds_table.R` has `river_measure` and `near_river_scope`.

Detached chain: `scripts/logs/habitat/20261023_chain_73.sh`, launched 05:12 UTC with nohup, pid 83818; its log is
`20261023_chain_73.out`. The handoff brief is `progress.md`'s "Resume" section.

| `relation "fresh_default.streams" does not exist` (bull trout `0330`, 2026-10-23 07:42 UTC, two minutes after the tuning exited) | link#361's provincial run renamed the schema to `fresh_default_20261017` at 07:41 UTC, having waited for the two jobs it could see; the chain's next step was not one of them. `0320`/`0330` take `SCHEMA` (default `fresh_default`), log it, and the second chain sets `SCHEMA=fresh_default_20261017`. `0325` and `data-raw/vignette_chinook.R` still name `fresh_default` (Phase 8). |

## Rainbow deferred (Al, 2026-10-23)

The four-species `0320` (6 workers on this 10-core machine, shared with link#361's provincial run, load ~13) scored
rainbow alone from 07:48 to 15:52 UTC: 8.1 h, each worker ~88 % busy (grayling's score came from the stopped first
attempt's cache; steelhead and cutthroat score in minutes). The cost is the scorer's design: each pattern's fold fit
(`R/tune_score.R`, `.tune_fold_setup()` and `.tune_score_one()`) is a dense `glm.fit()` whose model matrix carries one
column per training group, so a fit costs about n × p² and grows with the square of the group count. Per pattern,
against CH (4,490 modelled visits, 43 groups with both outcomes): CO about 2×, BT rearing about 6×, RB (12,959 visits,
129 groups, #57's population) about 25×. RB's rule result was also the least settled of the fitted rows (#57: the pick
in the region on 2 of 5 seeds, 4 % of bootstrap resamples; the pick at the top of the old 9 % ladder), its width rule
grades only measured streams (6.26 M of 10.33 M segments ungraded), link's access columns disagree on whole RB groups
(link#349), and the export records most juvenile steelhead as rainbow.

Decided: the middle course. The chain's wrapper was stopped at 15:55 UTC before its `GR,RB,ST,WCT 0330` (logged in
`20261023_chain2_73.out`); the `0320` run was left to finish, so RB's tune tables and grade are written and kept, but
`0330` runs as `SPECIES=GR,ST,WCT`. Its compose step leaves RB's saved comparison (2026-10-20, no `structure` column)
out of the combined tables and names it ("Left out of the combined tables…"), which is the intended result here, not
a defect. RB comes back once the scorer's group intercepts are fitted without a dense column per group (#83), on whatever evidence build is current then. Its kept tables are reusable only while the evidence build
is this one.

mgcv's "Fitting terminated with step failure" appears in the four-species `0320` stdout: once at 07:48:45 UTC, 13 s
after launch, which is grayling's curve (its score read from cache), and once after rainbow's scoring at 15:52 UTC,
rainbow's curve; any later occurrence is attributed by its position between the species' score files.

## The intercept minimiser sticks on a flat clamp (found 2026-10-23, the four-species `0320`)

The four-species scores came back impossible: GR's no-rule held-out deviance 8,397.5 (#57: about 848), its best rule
8,384.3; RB's `default` +394,289.7 behind (SE 51,705.8); ST's `default` +2,793.5, WCT's +5,844.2. Replayed for GR
outside the run (`scratchpad` probe: 0320's inputs, the scorer's input captured, the fold setup and no-rule fit
rerun): fold 4's training fit sets `data_setFDS` 12.99 and `era1995-2004` 13.96 (near-confounded with the group
columns; converged, 17 iterations), so its held-out visits carry offsets of +15 to +20. `.tune_group_dev()` (84c3c78)
searches the group intercept on [−30, 30] with `stats::optimize()`, but the deviance is clamped at p = 1e-12 and so is
flat at both ends: with offsets that large every first probe lands on the plateau and the search never reaches the
minimum near −18. Every visit of BLUR, KISK, LHAF and UBTN scores 55.3, and fold 4 carries 7,756.3 of the 8,397.5.
Centring the search on the group's own offsets (`-median(eta) ± 30`) gives fold 4 207.2 and leaves folds 1, 2, 3 and 5
identical to 0.001 (85.231, 156.140, 202.773, 197.033); the no-rule total becomes about 848.4.

The minimiser was committed 2026-10-23T01:26Z; CH and CO were rescored with it, and BT's `0320` (started about
03:17Z) ran with it, so every #73 score carries it. Whether any of their rules hit the plateau is not known without
rescoring: a probe on a few patterns wrongly cleared the scorer last time. The score caches are keyed on the grid,
not the code, so a fixed scorer rescores only once the `<key>_score.rds` caches are removed.

## The smoke run's mutation table (#84, 2026-10-23)

`knw_tune_smoke()` scores no rule, `default`, link's `default_tuned` row and the previous pick on the main fold seed
and checks four things (`null_ratio` ≤ 1.25, `clamp` = 0 visits at 55.26, `behind_null` ≤ the no-rule deviance,
`coef` ≤ the stated limit). The whole smoke over the eight keys takes about 20 s on one worker (rainbow 12 s), so a
scorer change is checked on every species in under a minute. `planning/active/scratch/smoke_mutation.R` ran it on
`0320`'s own inputs under three intercept searches: `84c3c78` (a golden section of the deviance on [−30, 30]),
`ca78ca6` (the same centred on the group's offsets) and the root of the deviance's derivative (committed with this
finding). Tables: `smoke_mutation.csv` (checks), `smoke_mutation_rules.csv` (the rules' scores), `smoke_mutation_lines.txt`.

| key | check | 84c3c78 | ca78ca6 | derivative root |
|---|---|---|---|---|
| GR_rear | null_ratio | **9.19** | 0.93 | 0.93 |
| GR_rear | clamp | **556** | 0 | 0 |
| RB_rear | null_ratio | **6.96** | 1.02 | 0.99 |
| RB_rear | clamp | **24,190** | **32** | 0 |
| RB_rear | behind_null | **332,264 / 89,147** | 0 | 0 |
| ST_rear | null_ratio | **7.56** | **7.56** | **1.42** |
| ST_rear | clamp | **165** | **73** | 0 |
| WCT_rear | clamp | **129** | 0 | 0 |
| WCT_rear | behind_null | **5,813 / 1,330** | 0 | 0 |
| BT_rear | clamp | **12** | **12** | 0 |
| BT_spawn, CH_rear, CO_rear | all four | pass | pass | pass |
| GR, RB, ST, WCT | coef (limit 5) | **13.96, 11.3, 19.6, 10.1** | same | same |

Bold fails. What the table says, in order:

- **`ca78ca6` did not fix the search.** ST rearing's no-rule model scores 3,372 against 446 in-sample on both golden
  sections, and its previous pick (`mad>=1|g<=0.0849|none`) scores 586.5 on the fixed range and 810.0 on the centred one:
  two searches of a convex function returning different minima means neither finds it. Replayed per group
  (`planning/active/scratch/st_groups.R`): fold 1's training fit sets `data_setFDS` 19.63, so a held-out group's FDS visits sit
  twenty units above its FDIS ones (BABR: 108 visits, one detection, offsets 0.4 to 20.4), both searches score it
  1,392.2 and its minimum is 47.4. Golden section stops wherever its first probes land on the clamp's plateau, from
  either centre. A spread *within* a group is not a constant the intercept absorbs, so centring could not help.
- **The derivative has no plateau.** The deviance is convex in the intercept (the cloglog log-likelihood is concave
  in the linear predictor), so its minimiser is the root of its derivative, 2 (Σ_{y=0} e^x − Σ_{y=1} e^x / expm1(e^x)),
  which is monotone, finite (e^x held at e^700) and bracketed by [−max η − 30, −min η + 30]. `uniroot` finds it to
  1e-10. `test-tune_score.R` holds the BABR construction (both golden sections > 400, the root 45.0 = a brute-force grid)
  and the fold that stuck the fixed range. On every key it leaves no visit at the clamp, and where the training fit is
  sane it agrees with #57's IRLS scorer to four decimals (no rule: GR 848.409, RB 12,617.376, WCT 1,329.869 against
  the restored `_summary.csv`), so three methods find one minimum where none is pathological.
- **BT rearing's committed scores carried the search too.** Both golden sections leave 12 BT_rear visits at the clamp;
  the root moves its no-rule model 6,180.6 → 6,031.2 and its previous pick 5,951.5 → 5,797.9. CH_rear, CO_rear and
  BT_spawn are identical to three decimals under all three searches, so their committed tables are not affected by
  the search (they still rest on the pre-#84 run's grid, to be rescored with everything else).
- **Every failure left is the training fit's.** The coefficient check reads the same numbers at every version, because
  the search does not touch the fit: GR fold 4 `era1995-2004` 13.96, RB fold 1 `era2005on` 11.3, ST fold 1
  `data_setFDS` 19.6, WCT fold 2 `era2005on` 10.1, each `converged = TRUE` (IRLS stops when the deviance stops moving,
  which a separated coefficient does). The sound keys' largest is BT_spawn's `data_setFDS` 3.63 and the separated keys'
  smallest is RB's no-rule `era2005on` 9.65, so the limit is 5: a hazard ratio past e^5 ≈ 150 between data sets or
  eras is separation, not a measured effect. ST's ratio of 1.42 at the root is this coefficient's consequence (the
  FDS visits of a mixed group still pay), so with the fit stabilised every check should pass on every key.
- **What the separation is.** With a group intercept in the model, a data-set or era effect is identified by the
  within-group contrast between visits of the two levels. Where the training groups that carry both levels put all
  their detections on one level (ST: 82 detections in 4,798 visits), the contrast is separated and the coefficient
  runs until the deviance change is under 1e-8. The options, for Al (a change to the model's terms, so every score
  moves): (A) a quadratic penalty on the `data_set` and `era` coefficients inside the fit (a ridge with a stated
  prior SD, say 2.5 on the cloglog scale), which stops a runaway and leaves a measured 2–3 unit effect nearly where it
  is, and adds no Import once #83's own IRLS exists; (B) drop `data_set` and `era` from every species' model, keeping
  `log(area)`, the rule and the groups, which loses the real data-set effects (CH 2.3, BT_spawn 3.6); (C) drop a term
  per fold where its coefficient passes the limit, which makes the model differ between folds. Recommended: A, with
  the penalty measured on the smoke run of every key before it is adopted. Nothing is changed in the fit here.

## The fit with the groups absorbed (#83, 2026-10-23)

`.tune_glm_fe()` (`R/tune_score.R`) is `stats::glm.fit()`'s IRLS (its start from `mustart`, its `good` subset where
`mu.eta` is zero, its step halving, its convergence test on the deviance at `epsilon` 1e-8, `maxit` 100) with each
weighted least-squares step solved by projecting the groups out: the weighted group means of the working response and
of the nuisance columns are subtracted, a pivoted QR (`.lm.fit`, the LINPACK routine `glm.fit` uses, at its tolerance)
solves for the nuisance coefficients and the rule, and each group's effect is its weighted mean residual. A step costs
n × p² in the nuisance columns (five or six) instead of in the groups (43 to 129), and no package is added. Checked
on simulated data against `glm.fit` before it went in (`planning/active/scratch/glm_fe.R`): coefficients to 1e-15, the same
iteration count and convergence flag, a separated data-set coefficient to 1.7e-12 over the same 20 iterations,
zero columns dropped alike; at rainbow's size (10,400 visits, 103 training groups) one fit took 0.012 s against
0.293 s. The one divergence is a nuisance level that is exactly a combination of groups: `glm.fit`'s QR keeps the
level and drops a group column, the projection drops the level, and though the fitted values and deviance are the
same the held-out offsets would not be, so the solver reports `fallback` and `.tune_score_one()` uses the dense fit
on that fold. `test-tune_score.R` holds each case, and the scorer's whole table under `fit = "dense"` against
`fit = "fe"` (equal to 1e-9, flags identical). The pivoting order is the dense fit's (nuisance, then the rule last),
so a rule aliased with whole groups is dropped by both.

**The fall-back test was too coarse, and it cost chinook every fit twice over (found 2026-10-23).** The first
reproduction run (`FIT=fe`, 3 workers, alongside the dense run and link#361) took 50.4 min on CH rearing and 41.5 on
CO against the dense run's 19.0 and 22.0 on 6 workers, and a probe on CH with a 52-pattern grid (`planning/active/scratch/fit_probe.R`,
one worker; its output `scratch/logs/20261023_fit_probe_fixed.txt` is the fixed code's) showed why: 265 fits, 265 fall-backs, so each fold paid the projection and then the dense
fit. The dropped column was `era2005on` on every fold. Chinook's population has no visit before 1995, so the two era
dummies sum to the intercept, which the groups carry; the dense fit drops that column too (its QR has the intercept
and the nuisance columns before the groups), so the two fits agree and no fall-back is needed. The test now asks
whether the dense fit's own QR (`qr(cbind(1, nuisance))` at the same tolerance) drops the column, and falls back only
on a dropped non-zero column it would keep: a level that is a combination of the groups but not of the intercept and
the columns before it. `test-tune_score.R` holds the era case (both drop the last dummy, no fall-back) beside the
group-carried level (fall-back). On the fixed code the same probe: 265 fits, 0 fall-backs, 8.9 iterations a fit under
either solver, 0.013 s a fit against the dense fit's 0.033 s on chinook's 34 training groups (the 25-fold gain of the
design note is rainbow's, with 103). The reproduction run was stopped (its CH and CO caches were the dense fit's, and
were removed) and relaunched on the fixed code with 6 workers.

**The dense reference on the current scorer (8a20461, `FIT=dense`, 6 workers, main seed, no bootstrap, nested
selection or extra seeds; `data/tune/ref_dense/`, `planning/active/scratch/logs/20261023_ref_dense.log`, 18:17 to 20:07 UTC on 2026-10-23
alongside link#361 and, from 18:31, the first `fe` run):**

| key | min | patterns | not converged | recommended | no-rule held-out | best | curve held-out |
|---|---|---|---|---|---|---|---|
| CH_rear | 19.0 | 6,101 | 27 | `mad>=0.75\|g<=0.13\|Q3@D1000` | 1,382.5 | 1,120.5 | 1,053.2 |
| CO_rear | 22.0 | 6,526 | 0 | `mad>=0.03\|g<=0.04\|none` | 4,024.6 | 3,856.3 | 4,092.5 |
| BT_rear | 65.5 (BT both) | 8,285 | 0 | `mad>=0.35\|g<=0.25\|none` | 6,031.2 | 5,704.6 | 5,618.5 |
| BT_spawn | (with BT_rear) | 3,023 | 0 | `width>=2\|g<=0.13\|none` | 408.0 | 402.0 | 403.7 |
| GR_rear | 1.1 | 5,046 | 0 | `width>=1.5\|g<=0.0349\|none` | 848.4 | 825.3 | 786.9 |
| ST_rear | 1.5 | 6,366 | 0 | `mad>=1\|g<=0.0849\|none` | 634.5 | 569.1 | 860.8 |
| WCT_rear | 0.8 | 5,268 | 0 | `mad>=0.03\|g<=0.3\|none` | 1,329.9 | 1,298.4 | 1,454.5 |

The minutes are a species' whole `knw_tune_run()` (prep, the grid, the curve), under load. The picks are the main
seed's alone and the smoke gates were off (they refuse GR, ST and WCT on the coefficient check), so none of this is a
rescore. Still, CH's and CO's recommended rules are their committed tables' (`data/tune/{CH,CO}_rear_tune.csv`, old
search, with the extra seeds), and BT rearing's is not: committed `mad>=0.1|g<=0.1049|none` against
`mad>=0.35|g<=0.25|none` here, which is the key the smoke run's mutation table showed the old search had moved
(no rule 6,180.6 against 6,031.2). Phase 7's rescore settles it. The reference exists to be reproduced by the
group-absorbing fit, rule by rule, flag by flag (`compare_fit.R`, below).

**The reproduction (`FIT=fe` on the fixed fall-back test, 6 workers, 20:17 to 20:34 UTC on 2026-10-23;
`data/tune/ref_fe/`, `scratch/logs/20261023_ref_fe.log`; `compare_fit.R` → `planning/active/scratch/fit_compare.csv`):** on every
key the region, the pick, the recommended rule, the fold assignment and every rule's convergence flag are identical to
the dense reference's, and the curve's held-out deviance is the same to the printed digit. Held-out deviances agree to
1e-9 relative on BT_spawn, CO, GR, ST and WCT and to 2.5e-9 on BT_rear (one rule at 1.5e-5 absolute); on CH six
converged rules differ by up to 4.0e-4 absolute (3.3e-7 relative, on about 1,200) and 4 of the 27 unconverged ones by
more than 1e-9, which is the two solvers stopping at slightly different points of a flat deviance (CH's fold with the
separated coefficient), far under anything the pick reads. Minutes per species, whole `knw_tune_run()`, both under
load: CH 19.0 → 4.9, CO 22.0 → 2.4, BT (both stages) 65.5 → 5.9, GR 1.1 → 1.1, ST 1.5 → 1.6, WCT 0.8 → 1.0; the three
small keys are the curve and the prep, not the fits. The caches under `data/tune/ref_*/` are ignored (the score
caches already were); the comparison table is the record.

**Rainbow with every extra, on m4 (2026-10-23, 20:58 to 21:15 UTC; `data/tune/ref_fe_extra/` there, its log
copied to `scratch/logs/20261023_ref_fe_extra_rb_m4.log`):** `FIT=fe EXTRA=1 SPECIES=RB WORKERS=12` took **16.6 min** for the whole
`knw_tune_run()` (7,706 patterns, 0 not converged, the 200-resample bootstrap, nested selection and four extra seeds,
the curve), against the **8.1 h** of 2026-10-23 for the same job on the dense fit here (6 workers, load about 13; the
run that was stopped). m4 has 16 cores at load 2 to 6 against 10 here under link's provincial run, so the comparison is
machine to machine as well as fit to fit; the six-species reference on one machine is the like-for-like (110 min to
17). The same probe as chinook's on rainbow (52-pattern grid, 455 fits): 0 fall-backs, 9.1 iterations a fit, and
of 966 s under the loaded machine 18 s were fits, the rest the GAM curve, so rainbow's floor is the curve. Rainbow's
gates were off in this run and it fails the coefficient gate without the prior, so nothing it scored is a result.
m4 now carries the branch, the evidence build (md5s checked against the ledger), link's threshold commits and the
database, so Phase 7's rescore runs there.

## The prior on the data-set and era coefficients (option A, Al 2026-10-23)

**The principle.** The model adds effects on the cloglog scale, where a step of one multiplies the hazard of
detection by e, and turns the sum into a probability. The data-set and era terms are there so that a rule is not
credited for a sampling difference (which provincial record a visit came from, and whether it was fished before 1995,
1995 to 2004 or since). With one intercept per group in the model, each of those effects is measured only by the
contrast between the two levels inside the groups that hold both. Where every detection of those groups sits on one
level there is no finite effect that fits best: the likelihood keeps improving as the coefficient grows, the fitter
stops only when the deviance stops moving, and it reports convergence (steelhead's `data_set` 19.6, a hazard ratio
near 300 million; grayling's era 14.0, rainbow's 11.3, cutthroat's 10.1). That coefficient is then an offset on the
held-out groups' visits of that level, so they start at a chance of detection near zero or one before the rule says
anything, and every rule is scored on that noise. A normal prior on the coefficient, SD `prior_sd` on the cloglog
scale, says that a sampling effect is probably modest: the fit adds `b^2 / prior_sd^2` to the deviance (a ridge), so
a coefficient costs more the further it sits from zero. A real effect of two or three units is left nearly where it
is; a runaway stops where the evidence runs out. Nothing else in the model is penalised: not the group intercepts,
not area, not the rule.

**Where it is.** `.tune_glm_fe(ridge = )` adds one pseudo-observation per penalised column to each weighted
least-squares step (sqrt of the weight in that column, response 0, which is the penalty's contribution to the
quadratic the step minimises) and tests convergence on the penalised deviance; the held-out deviance it reports is
unpenalised. `.tune_fold_setup()` marks the `data_set` and `era` columns, `.tune_score_one(prior_sd = )` turns the
SD into weights, and `prior_sd = 2.5` is the default of `knw_tune_score()`, `knw_tune_smoke()` and
`knw_tune_run()`; `Inf` is no prior, and the dense fit takes none (it errors on a finite `prior_sd`), so it stays the
unpenalised reference. A penalised column is never aliased: a level the groups carry gets 0 and the groups take it,
so the fall-back to the dense fit has nothing left to fire on. `test-tune_score.R` checks the fit against a general
optimiser on the penalised deviance (to 1e-4 in the coefficients), that zero weights reproduce the unpenalised fit
exactly, that a separated data set's coefficient is held between 2 and 6 in size where it ran past 8, and that the
prior reaches the scorer and the smoke run.

**The measurement the prior is adopted on** (`planning/active/scratch/prior_smoke.R` → `prior_smoke.csv`,
`prior_smoke_rules.csv`, `prior_smoke_lines.txt`, `logs/20261023_prior_smoke.log`; the smoke run on every key, main seed, 0320's inputs, 2026-10-23;
each setting 0.1 min over the eight keys). The gates and the largest non-group coefficient of any smoke rule:

| key | no prior | SD 5 | SD 2.5 | SD 1.5 |
|---|---|---|---|---|
| BT_rear | pass, 1.15 (rule) | pass, 1.15 | pass, 1.15 | pass, 1.15 |
| BT_spawn | pass, 3.63 (data set) | pass, 3.40 | pass, 2.92 | pass, 2.28 |
| CH_rear | pass, 3.12 (rule) | pass, 3.12 | pass, 3.12 | pass, 3.12 |
| CO_rear | pass, 1.51 (era) | pass, 1.21 | pass, 1.16 | pass, 1.05 |
| GR_rear | **coef**, 13.96 (era) | pass, 4.44 | pass, 2.89 | pass, 1.29 |
| RB_rear | **coef**, 11.31 (era) | pass, 1.80 | pass, 1.17 | pass, 1.17 |
| ST_rear | **null_ratio, coef**, 19.63 (data set) | pass, 2.50 | pass, 2.10 | pass, 2.02 |
| WCT_rear | **coef**, 10.12 (era) | pass, 0.74 | pass, 0.74 | pass, 0.74 |

The no-rule model's held-out deviance under each: BT_rear 6,031.2 at every setting; BT_spawn 408.0, 405.9, 401.4,
395.1; CH 1,382.5, 1,382.0, 1,380.5, 1,377.9; CO 4,024.6 to 4,023.2; GR 848.4, 831.2, 828.0, 825.0; RB 12,617.4 at
every setting; **ST 634.5, 439.8, 420.8, 407.7**; WCT 1,329.9 to 1,329.5. Steelhead's previous pick goes from 586.6
held-out to 372.9 at 2.5 while its distance from no rule hardly moves (−47.9 to −47.9): the runaway had been scoring
a fold's held-out visits at a chance near zero, for every rule alike. Reading the table: the sound keys' largest
coefficients are the rule's or a data-set effect of about 3, and 2.5 moves them by at most 0.7 (BT_spawn's 3.63 to
2.92, the one real effect the prior visibly shrinks); the separated keys' coefficients fall from 10 to 20 to under 3,
with grayling's at 4.4 under SD 5 still near the limit; the null ratio on steelhead goes from 1.42 to 0.94; nothing
is at the clamp and no rule is behind no rule anywhere. **Adopted: SD 2.5**, the default, with SD 5 and 1.5 on record
as the sensitivity. The curve's GAM has its own `data_set` and `era` terms and no prior; its held-out deviance beside
the grid's will say whether that matters on the four keys (Phase 7).

## Phase 7's rescore: scored on m4, graded here (`fa638f2`, 2026-10-23 and 24)

**Scoring, m4.** Every species, 12 workers, from 21:21 UTC 2026-10-23: smoke passed on all eight keys, every grid
scored with its extras, no `FAILED`, by 22:26 UTC (`scratch/logs/20261023_0320_m4.log`).

**Grading on m4 was stopped, and why.** Grading sends one `ch_dist_profile()` query per accessible segment. A trivial
query's round trip is 104 ms from m4 and 1.6 ms here (50 each, 2026-10-24). After 7.5 h m4's eight walk workers sat
at about 2 % CPU each and BT rearing had not finished walking; at that pace the eight keys needed about two days. Al
chose (2026-10-24, option A) to reuse m4's scores and grade here: the run was stopped at 06:33 UTC (`exit 143`), its
100 outputs copied into `data/tune/` (md5s checked), the earlier grade tables moved out of `data/tune/` so every key
graded fresh, and `0320` rerun here from a frozen copy at `fa638f2` (8 workers). The redesign is #85.

**Grading here** (`scratch/logs/20261024_0320_grade_local.log`, `scripts/logs/habitat/20261023_tune_run.txt`, dated by
the local day): 224.6 min, exit 0, no `FAILED`. Per key, walks and total:

| key | river size walked to | total |
|---|---|---|
| BT_rear | 10 m³/s | 55.4 min |
| BT_spawn | 10 m³/s | 55.9 min |
| CH_rear | 3 m³/s | 18.2 min |
| CO_rear | 10 m³/s | 13.7 min |
| GR_rear | 10 m³/s | 19.5 min |
| RB_rear | 10 m³/s | 42.2 min |
| ST_rear | 10 m³/s | 11.9 min |
| WCT_rear | 10 m³/s | 3.1 min |

`q` checked by hand against the 2026-10-22 runs' lines (BT 10, CH 3): unchanged. Every grade table carries
`walk = bank`, `ref_edge = 1000;1100;2000;2300`, run_uid `20261017_004619-3f4c713b`.

**Picks against the committed tables** (`recommended` in `<key>_tune.csv`, HEAD before this commit):

| key | committed | rescore |
|---|---|---|
| BT_rear | `mad>=0.1\|g<=0.1049\|none` | `mad>=0.35\|g<=0.25\|none` (moved; the dense reference found the same) |
| BT_spawn | `width>=2\|g<=0.13\|none` | same |
| CH_rear | `mad>=0.75\|g<=0.13\|Q3@D1000` | same |
| CO_rear | `mad>=0.03\|g<=0.04\|none` | same |
| GR_rear | `width>=1.5\|g<=0.0349\|none` | same |
| RB_rear | `width>=3\|g<=0.09\|none` | `width>=3\|g<=0.3\|none` (moved) |
| ST_rear | `mad>=1\|g<=0.0849\|none` | same |
| WCT_rear | `width>=1.5\|g<=0.04\|none` | `mad>=0.03\|g<=0.3\|none` (moved; underpowered, 6 groups with both outcomes) |

**The joint curve does not refit identically on two machines.** The rerun here refit each curve (the GAM; the grid
scores were the cached ones). Five keys' held-out curve scores match m4's to the digit; three do not: RB 9409.7 on m4,
9408.7 here; ST 840.2, 860.8; WCT 1464.4, 1454.5. The fits log `newton` "step failure" warnings. The committed grades
come from this machine's curves.

**Steelhead's curve is far behind its grid.** Held-out 840.2 (m4) or 860.8 (here) against the grid's best 357.5;
every other key's curve is within 13 % of its grid's best or below it (CO 4092.5 against 3855.9, WCT 1454.5 against
1298.1, BT_spawn 403.7 against 395.4, the rest below). Steelhead has 82 detections in 68 groups, 11 with both outcomes. The curve's GAM carries
its own data-set and era terms with no prior; the likely cause is the separation the prior fixed in the grid's fit,
not yet measured. Its pick comes from the grid, so it stands; its grades come from the curve, so no write-up uses
steelhead's grades until this is measured.

## Phase 7's recompare (`0330` here at `eb7b382`, 2026-10-24)

`0330` ran here one species at a time from a frozen copy, `SCHEMA=fresh_default_20261017`, 6 workers, 10:23 to 15:13
UTC: GR 38.3 min, WCT 17.6, ST 53.8, RB 40.4, BT 140.1 (rear and spawn). Every run exited 0 with no `FAILED`. The
combined `compare`, `change` and `checks` tables are composed with the saved CH and CO comparisons, which did not rerun
because neither pick moved. Kilometres on link's segments, `default` against the tuned rule (structure `door` is what
the thresholds table records):

| Key | default | free | door | lift outside FDIS, door minus default (95 % interval) |
|---|---|---|---|---|
| BT_rear | 244,328 | 158,584 (-35.1 %) | 142,015 (-41.9 %) | +2.97 (2.82 to 3.10) |
| BT_spawn | 133,382 | | 169,416 (+27.0 %) | -0.02 (-0.12 to 0.07) |
| GR_rear | 77,740 | | 77,740 (+0.0 %) | 0 (the pick is `default`'s rule) |
| RB_rear | 219,156 | 194,307 (-11.3 %) | 180,951 (-17.4 %) | +0.70 (0.65 to 0.73) |
| ST_rear | 70,980 | 45,274 (-36.2 %) | 41,714 (-41.2 %) | +1.89 (1.67 to 2.11) |
| WCT_rear | 20,632 | 24,572 (+19.1 %) | 24,428 (+18.4 %) | -0.10 (-0.14 to -0.06) |

BT_rear's pick moved (`mad>=0.1|g<=0.1049` to `mad>=0.35|g<=0.25`), so its comparison moved with it: the door
structure was 177,669 km (-27.3 %) on 2026-10-23 and is 142,015 km (-41.9 %) now. BT_spawn's pick held and its
kilometres are the same to the kilometre. WCT's new rule adds stream and lowers the outside-FDIS lift slightly; its pick
is underpowered (6 groups with both outcomes). Steelhead's lines come from the grid's pick and are usable; its graded
kilometres (17,573 to 16,236) come from the curve, which is not yet trusted (previous section).

Each species' run overwrote the script's own log, so `scripts/logs/habitat/` keeps BT's (`20261024_compare-bt.txt`,
`20261024_compare-workers-bt.out`); every species' stdout is `planning/active/scratch/logs/20261024_0330_<sp>.log`.

## Why steelhead's curve trails its grid (measured 2026-10-24)

`planning/active/scratch/curve_prior_probe.R` (`KEY=ST_rear`, from the repo root) repeats `knw_tune_curve()`'s held-out
loop on the cached curve and the score's folds. It reproduces the cached 860.8 exactly, then refits each fold with
the grid's prior (sd 2.5, a fixed penalty `b^2 / 2.5^2` on the `data_set` and `era` coefficients through `paraPen`).
Two causes, in order of size:

1. **`data_set` and `era` are aliased and carry no prior in the curve.** Steelhead's FDIS visits are 272, its
   1995-2004 visits 273; the full fit puts -31.6 on `data_set` FDS and +32.6 on `era` 2005on, each with a standard
   error of 3e7, and the fold fits put 57 to 99 on them. A held-out group that mixes the two combinations takes
   one of those offsets on part of its visits. With the prior the coefficients sit between -0.5 and 2.5, and the
   held-out total falls from 860.8 to 553.8 (SALM 229 to 43, TSAY 172 to 72, BABR 57 to 15). This is the separation
   the prior fixed in the grid's fit (#84), left unfixed in the curve's.
2. **The joint smooth overfits on 82 detections.** With the prior, NIMP alone is 260 of the 553.8. NIMP holds 27
   of the 82 detections; its covariates sit inside fold 4's training range (88 % of its visits, and every detection,
   are at the distance cap, against 39 % in training). The fold's fit predicts its visits from -19.7 to -2 on the link
   scale, and NIMP scores 236 under it (no data-set or era terms), 147 under a size-only smooth, against 107.8 for
   NIMP's own intercept alone. A curve that scores a group worse than no curve at all ranks that group's visits
   wrongly, and the grade inherits the ranking.

**The prior on every other key's curve** (same probe, each reproducing its cached score):

| Key | as fitted | with prior sd 2.5 | grid's best |
|---|---|---|---|
| ST_rear | 860.8 | 553.8 | 357.5 |
| GR_rear | 786.9 | 743.6 | 804.8 |
| BT_spawn | 403.7 | 397.3 | 395.4 |
| WCT_rear | 1454.5 | 1453.4 | 1298.1 |
| CH_rear | 1053.2 | 1052.7 | 1120.1 |
| CO_rear | 4092.5 | 4092.0 | 3855.9 |
| BT_rear | 5618.5 | 5618.4 | 5704.5 |
| RB_rear | 9408.7 | 9409.8 | 11651.9 |

The prior moves steelhead's curve by 307, grayling's by 43 and bull trout spawning's by 6; the other five by about 1.

The grid's rules have one binary term each and do not overfit this way; the best scores 357.5 against `default`'s
407.8. Steelhead's pick stands. Its grades come from the curve, so they wait on a decision (Al): give the curve the
grid's prior (an `R/tune_curve.R` change, so every key's curve refits and every key regrades, about four hours here),
and whether a key this thin should be graded from a joint curve at all.

**Decided (Al, 2026-10-24).** The curve takes the grid's prior (`44d4372`), and a key whose curve scores no better
on held-out groups than no rule is published without grades. With the prior that is steelhead (553.8 against 420.8
for no rule), coho (4092.0 against 4024.0) and WCT (1453.4 against 1329.7); bull trout spawning passes narrowly
(397.3 against 401.4). Coho's curve is behind no rule with 62 groups with both outcomes, so the cause there is not
power alone; its write-up loses its grade section.
