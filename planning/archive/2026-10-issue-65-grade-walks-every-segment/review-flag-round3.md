# Review: `stream_branch` flag and connector measure (round 3)

Diff: `git diff ca3d72b..HEAD` (588b47e, be4ff75, e9d6f0c), issue #73's body, and `enumerate_flag_claims.md`.

## Checklist read

- `code-check-python.md`: in full. It is under 40 KB, and the diff has no Python.
- `code-check.md`: the prose of every H3 under `## Mechanisms`, with the evidence blocks and table rows stripped. That covers all fourteen, from "A guard that fails toward pass" through "One fact derived twice". I read nothing under "Rules that stand alone" or "Security" beyond their index lines.
- `code-check-r.md`, read in full: "Postgres row order is never fixed unless the query fixes it" (the scripts' `LIMIT 1` subqueries), "Inside a dplyr verb, a column named like a local variable wins" (0325's `edge_stream` inside `transmute()`), and "`match()` treats NA as a matchable VALUE" (`%in%` on `edge_type`). The rest I read as index lines.
- `code-check-spatial.md`, read in full: "A Freshwater Atlas main stem's downstream end lies on the receiving river's centreline", "FWA main flow is not edge type 1000 alone" and "FWA `upstream_route_measure` misses the next segment's start". The rest I read as index lines.
- `code-check-shell.md`: index only. The diff has no shell.

## Mechanism

Every earlier defect, and the one below, has the same shape: a sentence states a pattern for a population, but the pattern was seen on a narrower population.
- **The populations involved.** The sentence names all sites, every key, or "the rest". The pattern came from the found sites, the ancestry-traced sites, CH alone, river polygons rather than edge 1200, or the single CH case round 2 inspected.
- **The shared assumption.** What the measured or inspected subset shows is assumed to hold for the set the sentence names. Nobody checked that the computation's population (`f`, `dl`, `dl$conn_m > 0`, one key) is the sentence's population.
- **Where it entered this time.** The enumeration checks each number against its column, so a number computed on the right population passes. It does not check the clause around the number. Here a clause about "the rest" was carried over from round 2's single inspected CH site, and that site has a hop gap.

The mechanism reaches these places in the change:
1. research `habitat_thresholds_tuned.md:239-241`, "the rest have none, and the walk hops … without counting the gap". This is **false** for most keys; see Findings.
2. archive `README.md:56-57`, "the rest hop an uncounted gap". **False**; same finding.
3. Issue #73's connector paragraph, the same clause. **False**, and its own parenthetical ("0 m for the other keys") contradicts it.
4. `enumerate_flag_claims.md` row 17. It accepts the gap medians as "holds", but for five keys those medians are 0 m, which contradicts the clause they are cited beside. The clause itself has no row; see Findings.
5. research `:236` "usually crosses the polygon as a connector" (89–96 % of traced double-line endings): **holds**. research `:228-229` "far above … below it for": **holds**, because each key is named. research `:226-227` "(WCT 62 %)": **holds**, because the range and its exception are stated separately.
6. NEWS and the 0325 description, "lines through lakes, wetlands and double-line rivers". The off-branch set also holds 1425, 1400 and 1410 lines. The 0325 description names "other connectors". Round 2 judged this immaterial (≤37 km of 1425 per key), and I agree.
7. "for visits and segments alike" (research `:237`, #73): this holds by code. Segments and visits are walked by the same `inst/sql/ch_dist_profile.sql`, which counts a line's whole measure below its start (`d := d + cur_m`, line 66) before it hops.

## Findings

- **[false-claim]** `research/habitat_thresholds_tuned.md:239-241`, `planning/archive/2026-10-issue-65-grade-walks-every-segment/README.md:56-57` and issue #73's connector paragraph all say that the traced double-line endings with no connector ("the rest") reach the river by a hop that the walk does not count. The research text is "the rest have none, and the walk hops from the tributary's mouth to the river's line without counting the gap"; the README is "the rest hop an uncounted gap". For most of those sites on five of the eight keys there is no gap.
  - **The script's own output contradicts it.** `check_connector_share.txt` reports `gap_med_m = 0` for BT rear, BT spawning, CO, RB and ST. `max_entry_gap_m` is the largest gap over every hop of the walk (`ch_dist_profile.sql:113`, `gap := greatest(gap, par.g)`). A median of 0 m therefore means at least half of those sites hopped no gap anywhere.
  - **What I re-derived.** I re-ran a copy of the script's trace in the scratchpad. All hop gaps were under 1 m at 12 of BT spawning's 17 no-connector sites, 43 of ST's 45 and 85 of CH's 197.
  - **What those sites are.** For every one of them, the tributary's main stem has no length inside the end river's polygon (`ST_Intersection` with `fwa_rivers_poly` by the end segment's `waterbody_key` returned nothing). The river's segment nearest the tributary's mouth is single-line:

    | key | 1000 | 1050 | 2000 |
    |---|---|---|---|
    | ST | 33 | 10 | — |
    | BT spawning | 7 | — | 5 |
    | CH | 61 | 7 | 17 |

    So these tributaries join the river upstream of its double-line reach. The walk then follows the river's own line to its first 1250 segment carrying flow q. They neither cross the polygon nor hop a gap.
  - **What still holds.** The hop clause holds for CH's other 112 no-connector sites, and for most such sites on GR and WCT, whose medians are 135 and 311 m. The 22 flips and BT spawning's 0 are unaffected: I recomputed both from the in-polygon length of every traced site and got 22 and 0. For connector sites the connector length equals the in-polygon length, with a median ratio of 1.000.
  - **Fix.** Split "the rest": some join the river where it is single-line and reach its double-line reach along its own line, and the others hop a gap the walk does not count. Give the per-key share of each (probe: `max_entry_gap_m < 1` among `conn_m == 0`). In #73, the open question "whether an uncounted hop gap should count" then applies only to the second group.

- **[omission]** `planning/archive/2026-10-issue-65-grade-walks-every-segment/enumerate_flag_claims.md:23-25` (rows 15-17). The enumeration has no row for the clause "the rest … hop(s) … without counting the gap", which appears in the research text, the README and #73. Row 17 lists `gap_med_m` as "holds", reading the numbers alone, so the 0 m medians that falsify the clause beside them passed unexamined. Add a row for the clause, with `gap_med_m` and a count of no-connector sites with a gap under 1 m as its source.

Checked and matching, for (b):
- **Rows 1-16, 18 and 20.** Rows 1-16 match the `.txt` values. Row 18 matches: I recomputed it from the Parquet files under `data/publish/habitat_grade_v1/habitat_grade/`, and off-branch graded km equal OB `off_km` for every key. Row 20 matches: thirteen `review-*.md` files exist once this one is written.
- **Denominators.** Row 9 (`n_measured / n_double_line`), row 10 (`dl`), rows 11-13 (`conn_m > 0`) and row 15 (`dl`) each use the population their sentence names.
- **Row 17's wording.** "Largest hop gap" in #73 matches `max_entry_gap_m`, which is the maximum over every hop of the walk, not only the hop into the end river. It is therefore an upper bound on the river-entry gap.
