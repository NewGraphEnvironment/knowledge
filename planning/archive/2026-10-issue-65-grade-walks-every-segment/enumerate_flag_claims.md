# Every claim the stream_branch change makes, against its source

Round 2 found a defect inside a round-1 fix, so the review ends on this enumeration, not on a quiet round. Round 3
named the mechanism behind every finding: a sentence about one population whose pattern was seen on a narrower one
(found sites, traced sites, one key, river polygons standing in for edge 1200, one inspected site), and showed that
checking each number against its column misses the clause around it. So this table lists every clause of the added
text, quantified or not, with the population its source measures. Text: research Limits ("The grade off the stream
branch..." and "Distance is to the river's main line..."), the research header and Produced by, NEWS, the archive
README's new lines, #73's connector paragraph, and 0325's `habitat_grade` description.

Sources: OB `check_off_branch.txt` (graded accessible km per key), CS `check_connector_share.txt` (the curves' visit
sites, one walk each at the curve's q on `pick`), WB `check_e1200_waterbody.txt` (every edge-1200 line), all rerun
2026-10-20; per-key values in key order BT rear, BT spawn, CH, CO, GR, RB, ST, WCT.

| # | clause | where | population and source | values | verdict |
|---|---|---|---|---|---|
| 1 | `stream_branch` is TRUE on the edge types the curve's visits were on and the reference was taken over | 0325, NEWS, research | 0325 `formals(knw_grade_species)$ref_edge`; 0320 passes no `ref_edge` and calls `knw_tune_run()` at its default `edge_stream` | 1000 1100 2000 2300 both | holds (round 1) |
| 2 | FALSE on lines through lakes, wetlands and double-line rivers and on other connectors | 0325, NEWS | every off-branch edge type in the grade tables, against `fwa_edge_type_codes` | 1050 1150 (through wetland), 1200 and 1300 (main and secondary flow construction lines; 1200 by WB 83.8 % lake, 16.1 % wetland, 0.1 % man-made km), 1250 1350 1450 (double-line river), 1400 1410 1425 1475 (connectors, subsurface, lake arm) | holds (round 1, WB) |
| 3 | off the branch the grade extrapolates the curve past its visits | 0325, NEWS, research | `knw_tune_run()` keeps only `edge_stream` visits outside river, wetland and lake polygons | code | holds |
| 4 | edge 1200 is main flow through lakes and wetlands | research, README | WB, every edge-1200 line | 99.9 % of km | holds |
| 5 | edge 1200 within 1 m of its river on 10–18 % of graded km (WCT 62 %) | research | OB `e1200_within1m_pct` | 12 16 18 14 10 17 12 62 | holds |
| 6 | edge 1200 km at 0.8+ 4–34 % (WCT 79 %); CH 20 % | research, README | OB `e1200_hi_pct` | 4 17 20 31 34 4 20 79 | holds |
| 7 | off-branch 24–36 % of each key's graded km | research, README | OB `off_pct` | 24 24 34 36 32 30 30 34 | holds |
| 8 | off-branch lines hold 21–79 % of each key's km at 0.8+ | research, NEWS, README | OB `hi_off_pct` | 34 21 79 66 29 24 70 35 | holds |
| 9 | far above its share for CH 79, ST 70, CO 66 | research, README | OB `off_pct` → `hi_off_pct` | 34→79, 30→70, 36→66 | holds |
| 10 | below its share for BT spawning, GR, RB | research, README | same | 24→21, 32→29, 30→24 | holds; BT rear (24→34) and WCT (34→35) are not named either way |
| 11 | the flag says which segments the curve's visits support | research | rows 1 and 3 | | holds |
| 12 | published off-branch graded km equals the measured | `habitat_grade/v1` built 2026-10-20T14:20:54Z at 588b47e | Parquet `sum(length_metre)` of graded rows by `stream_branch` | BT 135,130; CH 76,792; CO 52,204; GR 47,339; RB 83,818; ST 45,727; WCT 8,694 | equals OB `off_km` on every key (round 3 recomputed) |
| 13 | a tributary's line usually crosses the polygon as a connector (edge 1450) to the centreline | research, #73 | CS traced sites ending on a double-line river, `connector_pct` | 90 93 91 89 96 90 91 93 | holds ("usually") |
| 14 | the connector carries the tributary's flow, so the walk counts it | research, #73 | CS found sites, `end_connector_pct` | 0 on every key: no walk at q 3 or 10 ended on a connector | holds |
| 15 | for visits and segments alike | research, #73 | `knw_grade_species()` and the visit walks both call `inst/sql/ch_dist_profile.sql` | code | holds |
| 16 | 59–94 % of found sites end on a double-line river | research, README, #73 | CS found sites, `end_double_line_pct` | 79 59 60 74 94 79 87 87 | holds |
| 17 | the tributary could be traced on 97–99 % of those | research, #73 | CS `n_measured / n_double_line` | 98.8 98.5 97.5 97.9 98.6 98.3 97.6 97.8 | holds |
| 18 | 89–96 % of the traced have a connector | research, README, #73 | CS `connector_pct` | as row 13 | holds |
| 19 | the connector adds a median 14–88 m, 90th percentile 38–324 m | research, README, #73 | CS sites with a connector, `conn_med_m`, `conn_p90_m` | 35 14 33 36 46 36 88 31; 166 38 182 219 138 182 324 49 | holds |
| 20 | a median 0–2 % of the site's distance | research, #73 | CS sites with a connector, `share_of_dist_med_pct` | 0 0 1 1 0 0 2 0 | holds |
| 21 | the rest (4–11 %) have none | research, #73 | CS traced, `100 - connector_pct` | 10 7 9 11 4 10 9 7 | holds |
| 22 | 31–96 % of them hop no gap of 1 m or more | research, README, #73 | CS no-connector sites, `no_conn_nogap_pct` (every hop gap under 1 m) | 53 71 43 55 31 55 96 40 | holds |
| 23 | the others hop one somewhere on the walk, which the walk does not count | research, README, #73 | `ch_dist_profile.sql`: `gap` takes `ST_Distance` of the mouth to the parent line and `d` never adds it | code | holds |
| 24 | largest hop gap median 0 m for BT, CO, RB, ST; 135–311 m for GR, CH, WCT, over all no-connector sites | #73 | CS `gap_med_m` (`max_entry_gap_m`, the largest over all hops) | 0 0 181 0 135 0 0 311 | holds |
| 25 | to the bank, 22 of 2,260 traced CH sites fall inside 1 km | research, README, #73 | CS traced CH sites, `flips_exc` (`dist_m > 1000` and `dist_m - conn_m <= 1000`) | 22 of 2260 | holds |
| 26 | none of BT spawning's inside 2 km | research, #73 | CS traced BT spawning sites, `flips_exc` | 0 of 260 | holds |
| 27 | ending at the bank changes the visits' distances, so it waits for the retune | research, #73, README | rows 19 and 25 | | holds |
| 28 | Al chose to flag rather than blank, and to leave the walk at the centreline until #73 (2026-10-20) | README | the conversation of 2026-10-20 | | holds |
| 29 | thirteen reviewer rounds | README | `ls review-*.md` | 13 | holds |
