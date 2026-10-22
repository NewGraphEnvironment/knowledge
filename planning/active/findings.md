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



## Errors Encountered

| Error | Resolution |
|-------|------------|
