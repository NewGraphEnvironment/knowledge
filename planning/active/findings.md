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
