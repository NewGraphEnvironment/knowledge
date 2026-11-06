# Findings — knw_link_flow() picks a parent flow by distance alone (#161)

## Issue context

**If we do it:** a visit's picked flow is the same on any database holding the same build, so two runs of one recipe give identical evidence. **If we never do:** where two parent lines are equally near, which one's flow a visit takes depends on the index and scan order, and a rebuild on another database (or after a reindex) moves the flow on those visits.

## Problem

`knw_link_flow()` (`R/link_flow.R`) takes a segment's flow from its nearest parent when it has none of its own, through `ORDER BY p.geom <-> s.geom LIMIT 1`. Nothing breaks a tie. #158's rerun of the published evidence build on a second database holding the same build found `mad_pick` differing on 3 of 45,529 visits (LIAR `59694_1_1`; LHAF `95183_49_1` and `97120_75_1`), by at most 0.0029 m³/s. Each sits on an Atlas line with no flow of its own and two parent lines at distance 0:

| visit line | parent | edge | q (m³/s) | d (m) | taken by |
|---|---|---|---|---|---|
| 104084643 | 104084784 | 1250 | 70.277205 | 0 | the host |
| 104084643 | 104084627 | 1250 | 70.278863 | 0 | the second database |
| 105073914 | 105073883 | 1250 | 8.526702 | 0 | the host |
| 105073914 | 105073915 | 1250 | 8.523775 | 0 | the second database |

The host and the second database each took one of each pair. The same tie reaches the grade through each segment's size: #158's chinook rearing regrade on the second database gave 315 of 3,016,042 segments another size (311 lines, every one taking its flow from a parent at distance 0), which moved 50 grades and the grade class of 3. The tuning tables, which read the visits, came out byte-identical. The function has not changed since the published run, so the code is the cause, not the database.

## Proposed

- [ ] Order the parent lookup on a unique key after the distance (`ORDER BY p.geom <-> s.geom, p.linear_feature_id`), or choose a tie by a rule that means something (the larger flow, the downstream line) and say which in the roxygen
- [ ] A test with two equidistant parents whose result does not depend on insertion order
- [ ] The next evidence build carries the change (it moves `mad_pick` on the tied visits); not a reason for a rebuild on its own

Found by #158.




## Planning probes (m1, 2026-11-06, read-only)

- PG 17.5, PostGIS 3.5.2. Tied parents: 104084627 (70.278863, dsm 6127.05) / 104084784 (70.277205, dsm 5620.01) on blk 359570578; 105073883 (8.526702, dsm 1182.99) / 105073915 (8.523775, dsm 1434.98) on blk 359568465.
- 0 segments with more than one picked month-0 historical row; 0 picked rows with NULL q_m3s.
- 8,167 distinct fresh_default.streams lines have no picked flow of their own.
- 2 of 101 regulating dams (reservoir or >= 10 % regulation) are equidistant from their two nearest main-flow segments, both within 500 m.

## Restore check: the new tests on the old ORDER BY (m1, 2026-11-06)

Run before the fix, with `.knw_link_flow_sql()` carrying the old `ORDER BY p.geom <-> s.geom`:

- Fixture: insertion order 20, 30 took 20 (5); order 30, 20 took 30 (7). The scan order decides, so the test can fail.
- Live flow: m1 gave 70.278863 (104084627, the lower id) and 8.523775 (105073915, the higher id), so it fails on the
  second line. m4 took the other parent of each pair (#158), so it would fail on the first.
- Live dam snap: on m1 both tied dams took the higher-id segment (measures 18319.28380 and 1651.96479 against the lower
  id's 18319.28361 and 1651.96526).

## Errors Encountered

| Error | Resolution |
|-------|------------|
