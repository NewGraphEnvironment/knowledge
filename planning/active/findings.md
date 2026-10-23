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
