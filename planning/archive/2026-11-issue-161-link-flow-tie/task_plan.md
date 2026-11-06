# Task: knw_link_flow() picks a parent flow by distance alone, so an equidistant tie resolves by the database's scan order (#161)

**If we do it:** a visit's picked flow is the same on any database holding the same build, so two runs of one recipe give identical evidence. **If we never do:** where two parent lines are equally near, which one's flow a visit takes depends on the index and scan order, and a rebuild on another database (or after a reindex) moves the flow on those visits.

`knw_link_flow()` (`R/link_flow.R`) takes a segment's flow from its nearest parent when it has none of its own, through `ORDER BY p.geom <-> s.geom LIMIT 1`. Nothing breaks a tie (#158 found 3 visits and 40-441 grade sizes per key differing between two databases).

## Context

`knw_link_flow()` (`R/link_flow.R:63`) takes a flow-less segment's flow from its nearest parent with
`ORDER BY p.geom <-> s.geom LIMIT 1`, and nothing breaks a tie. #158 ran the published build on a second database
and found 3 of 45,529 visits whose `mad_pick` differed, plus 40 to 441 segment sizes per grade key; every one sat on a
line with two parents at the same distance. Measured in planning (m1, PG 17.5, PostGIS 3.5.2, read-only):

- The tied parents: 104084627 (70.278863, measure 6127) and 104084784 (70.277205, measure 5620) on blue line 359570578;
  105073883 (8.526702, measure 1183) and 105073915 (8.523775, measure 1435) on 359568465. On the first pair the larger
  flow belongs to the upstream segment, so "larger flow" and "downstream" are different rules.
- Each parent has exactly one picked month-0 historical row (0 have more than one), and no picked `q_m3s` is NULL.
- 8,167 distinct lines in `fresh_default.streams` have no picked flow of their own. That is the parent-fallback population
  for grading.
- `knw_link_regulated()` (`R/link_regulated.R:47`, run by `0310`) has the same unordered lookup: 2 of the 101
  regulating dams sit equidistant from two main-line segments, both within the 500 m snap.

## Decided at the gate (Al, 2026-11-06)

- **Tie rule: the lower `linear_feature_id`.** `ORDER BY p.geom <-> s.geom, p.linear_feature_id`. It is fixed but
  arbitrary, and the roxygen says so. Neither physical rule fits cleanly, and the tied flows differ by about 0.01 %.
  On #158's two pairs it picks 104084627 and 105073883, so each database took one wrong pick under the old code, and a
  test pinned to this rule fails the old code on either database.
- **Include `knw_link_regulated()`'s dam snap** (`ORDER BY s.geom <-> p.pt, s.linear_feature_id`) in this PR.
- **No rebuild here.** Any evidence build or grade made after the merge carries the change by construction. It moves
  `mad_pick` on the tied visits and sizes on the tied segments (issue checkbox 3).
- The other nearest lookups are out of scope: the walk's landing (`inst/sql/ch_dist_profile.sql:140`) is #162, and
  `data-raw/vignette_cut_points_places.R:123` is a place lookup for a figure, outside the pipeline.

## Phase 1: Tests that fail on the old ORDER BY

- [x] Move the query into an internal `.knw_link_flow_sql(tmp, fwa = "whse_basemapping.fwa_stream_networks_sp",
      q = "discharge.fwa_v1_segment_monthly")` that `knw_link_flow()` calls unchanged. The table names become
      arguments so that a fixture can stand in for them.
- [x] `tests/testthat/test-link_flow.R`, fixture test: build `pg_temp` tables, one flow-less segment and two parents
      at distance 0 with codes and picked flows. Insert the parents in both orders and run the SQL. Both orders take
      the lower-id parent. It skips without Postgres, and without the `postgis` and `ltree` extensions.
- [x] Live test (`skip_if_no_pg("discharge")`): `knw_link_flow(conn, c(104084643, 105073914))` returns, for each
      line, the flow of the lower-id parent among those at the minimum distance, computed in the test from the
      database. Pinning no flow value keeps the test valid across a wet reload.
- [x] Live test for `knw_link_regulated()`: for each regulating dam equidistant from two segments (found in the
      test), `$dams` carries the lower-id segment's `blue_line_key` and measure.
- [x] Restore the bug: with the old ORDER BY on m1, the live tests fail, and the fixture test fails in at least one
      insertion order. Record the result in findings. If the fixture cannot fail on the old code, say so, and let the
      live test carry the proof.

## Phase 2: The fix

- [x] `R/link_flow.R`: change to `ORDER BY p.geom <-> s.geom, p.linear_feature_id`. Add a roxygen sentence: where two
      parents are equally near, the lower `linear_feature_id` gives the flow, an arbitrary but fixed choice, so every
      database holding the build picks the same one (#161).
- [x] `R/link_regulated.R`: change to `ORDER BY s.geom <-> p.pt, s.linear_feature_id`, with the same roxygen sentence
      for the dam's segment.
- [x] `devtools::document()`, `lintr::lint_package()`, and the full `devtools::test()`.

## Phase 3: Measure on both databases

- [x] `data-raw/link_flow_tie_check.R` writes `knw_link_flow()` for the parent-fallback population and
      `knw_link_regulated()$dams`, each sorted, to CSV, with timing. The population is every `fresh_default.streams`
      line with no picked flow or no watershed codes, plus #158's three visit lines. The script sources the
      `link_flow.R` and `link_regulated.R` that it is given, so on m4 it runs from a scratch copy with
      `PGSERVICE=fresh_local`, and m4's checkout is not touched.
- [x] Run it on m1 and on m4, with the old code and the new code. Expected: the old code differs between the two
      databases on the tied lines (reproducing #158), and the new code is identical on both (md5 of the sorted CSV).
      Wall time stays about the same: PG 17 adds an incremental sort after the index scan.
- [x] Commit the logs under `scripts/logs/habitat/database_second/` with #158's naming
      (`<date>_link_flow_tie_check-<db>-<code>.csv`).

## Phase 4: Documentation

- [x] (NEWS lines come with `/gh-pr-merge`'s release commit, as v0.4.31's did; the PR body carries it) `NEWS.md`: one line saying that the parent flow and the dam snap break a tie by id, and that the next build moves
      the tied visits and segments.
- [x] `research/database_builds.md`: in the #161 bullet, add that it is fixed in code, the measured result, and that
      it takes effect in the first build made after the merge.
- [x] `CLAUDE.md`, "Database access": change "Until both are fixed" so that #161 is fixed for builds made after it,
      and only #162 still holds a promotion to one database.
- [x] #161's issue body: tick the boxes and record the rule and why.

## Owed at the end (reported, done after merge)

None. The next evidence build happens on Al's word, as CLAUDE.md requires.

## Validation

- [x] Tests pass
- [x] `/code-check` clean (once over the branch with `/code-check branch`)
- [x] PWF checkboxes match landed work
- [x] `/planning-archive` on completion

How each change is proved:

- The tie rule: the fixture test in both insertion orders, plus the live test. Each must fail on the old code (Phase 1's
  restore check).
- The goal ("two runs give identical evidence"): Phase 3's comparison across the two databases, old code against new.
- Nothing else moved: lines with a single nearest parent have identical old and new output on each database. The
  Phase 3 CSVs are diffed old against new per database, and the only lines that differ are the tied ones.

