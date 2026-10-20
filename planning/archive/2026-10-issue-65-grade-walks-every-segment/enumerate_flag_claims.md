# Every quantified claim the stream_branch change makes, against its source

Round 2 found a defect inside a round-1 fix (a "traced" share that counted no-connector sites as 0 m), so the review
ends on this enumeration, not on a quiet round. Sources: `check_off_branch.txt` (OB) and `check_connector_share.txt`
(CS), as rerun 2026-10-20; per-key values in key order BT rear, BT spawn, CH, CO, GR, RB, ST, WCT.

| # | claim | where | source column | values | verdict |
|---|---|---|---|---|---|
| 1 | edge 1200 within 1 m of its river on 10–18 % of graded km (WCT 62 %) | research Limits | OB `e1200_within1m_pct` | 12 16 18 14 10 17 12 62 | holds |
| 2 | edge 1200 km at 0.8+ 4–34 % (WCT 79 %) | research Limits | OB `e1200_hi_pct` | 4 17 20 31 34 4 20 79 | holds |
| 3 | CH edge 1200 20 % at 0.8+ | archive README | OB `e1200_hi_pct` | CH 20 | holds |
| 4 | off-branch 24–36 % of each key's graded km | research Limits | OB `off_pct` | 24 24 34 36 32 30 30 34 | holds |
| 5 | off-branch 21–79 % of km at 0.8+ | research, NEWS, README | OB `hi_off_pct` | 34 21 79 66 29 24 70 35 | holds |
| 6 | far above its share for CH 79, ST 70, CO 66 | research, README | OB `off_pct` vs `hi_off_pct` | 34→79, 30→70, 36→66 | holds |
| 7 | below its share for BT spawning, GR, RB | research, README | same | 24→21, 32→29, 30→24 | holds (BT rear and WCT not claimed: 24→34, 34→35) |
| 8 | 59–94 % of found sites end on a double-line river | research, README, #73 | CS `end_double_line_pct` | 79 59 60 74 94 79 87 87 | holds |
| 9 | tributary traced on 97–99 % of those | research, #73 | CS `n_measured / n_double_line` | 98.8 98.5 97.5 97.9 98.6 98.3 97.6 97.8 | holds |
| 10 | 89–96 % of traced have a connector ("usually crosses") | research, README, #73 | CS `connector_pct` | 90 93 91 89 96 90 91 93 | holds |
| 11 | connector median 14–88 m | research, README, #73 | CS `conn_med_m` (over `n_connector`) | 35 14 33 36 46 36 88 31 | holds |
| 12 | connector 90th percentile 38–324 m | research, README, #73 | CS `conn_p90_m` | 166 38 182 219 138 182 324 49 | holds |
| 13 | a median 0–2 % of the site's distance | research, #73 | CS `share_of_dist_med_pct` | 0 0 1 1 0 0 2 0 | holds |
| 14 | the connector carries the tributary's flow, so the walk counts it | research, #73 | CS `end_connector_pct` | 0 on every key: no walk at q 3 or 10 ended on a connector | holds |
| 15 | 22 of 2,260 traced CH sites cross 1 km to the bank | research, README, #73 | CS `flips_exc`, `n_measured` | 22, 2260 | holds |
| 16 | none of BT spawning's cross 2 km | research, #73 | CS `flips_exc` | 0 | holds |
| 17 | largest hop gap median 135–311 m on no-connector sites for CH, GR, WCT; 0 m for the others | #73 | CS `gap_med_m` | 0 0 181 0 135 0 0 311 | holds |
| 18 | published off-branch graded km equals the measured | `habitat_grade/v1` (built 2026-10-20T14:20:54Z, 588b47e) | Parquet `sum(length_metre)` by `stream_branch` | BT 135,130; CH 76,792; CO 52,204; GR 47,339; RB 83,818; ST 45,727; WCT 8,694 | equal to OB `off_km` on every key |
| 19 | the flag's edge set is the reference's and the fit's | 0325 | `formals(knw_grade_species)$ref_edge`; 0320 passes no `ref_edge` and calls `knw_tune_run()` at its default `edge_stream` | 1000 1100 2000 2300 both | holds (round 1) |
| 20 | thirteen reviewer rounds | archive README | `ls review-*.md` | 13 once round 3 has written | holds when round 3 delivers |
