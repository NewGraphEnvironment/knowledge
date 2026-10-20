# Review: `stream_branch` flag and connector measure (round 2)

Diff: `git diff ca3d72b..HEAD` (588b47e, be4ff75), plus issue #73's body (updated 2026-10-20T14:19:45Z).

## Checklist read

- `code-check.md`: the prose of every H3 under `## Mechanisms`, with the table rows skipped. I read these in full: "A guard that fails toward pass", "A fixture that cannot reach the failure mode", "A proxy is not the property", "Verification that reads its own output", "A guard's scope, escape hatches, and remedies" (including "Compression runs both ways" and its enumeration-of-claims paragraph), "A fix lands in one of two callers that share a harness", and most of "Restore the bug and prove the guard fires". I read the others as index lines only.
- `code-check-r.md`: index lines, plus these rules in the diff's shapes: "Inside a dplyr verb, a column named like a local variable wins", "Postgres row order is never fixed unless the query fixes it" (the `LIMIT 1` subqueries), and "`match()` treats NA as a matchable VALUE" (`%in%`).
- `code-check-spatial.md`: index lines, plus "FWA main flow is not edge type 1000 alone" and "A Freshwater Atlas main stem's downstream end lies on the receiving river's centreline".
- `code-check-shell.md` and `code-check-python.md`: index only. The diff has no shell and no Python.

## What I re-derived

- **`check_off_branch.txt`.** I re-derived it independently with duckdb over all eight `data/tune/<key>_grades.csv`, per off-branch edge type. These figures agree with the output: 24–36 %, 21–79 %, CH 79 / ST 70 / CO 66 above; BT spawning 24→21, GR 32→29 and RB 30→24 below (the gaps exceed rounding); edge-1200 within 1 m 10–18 % except WCT at 62 %; edge-1200 at 0.8+ 4–34 % except WCT at 79 %; CH edge 1200 at 20 %. No off-branch row has a NULL `edge_type`.
- **`check_connector_share.R`.** I re-ran a copy for CH, GR and BT spawning against the database, and it reproduced every printed column exactly. Traced share: n_measured/n_double_line is 97.5–98.8 % across all eight keys, which supports "97–99 %". The figures 59–94 %, 14–46 m, 34–321 m, 0–2 %, 22 of 2,260 and BT spawning's 0 all match the output.
- **Round-1 fixes.** Fix (1), the README qualifier, is present. Fix (2), the "but": the new "far above … below it for BT spawning, GR and RB" holds per key. Fix (4), the research header naming the check scripts, is present, and "four fifths in lakes" is gone. Fix (5), `n_double_line`/`n_measured`, is printed. Fix (3) has a defect inside it (first finding below).
- **NEWS, the 0325 description, and the rest of #73's body.** I found nothing false. Off-branch also holds 1425 (subsurface flow, at most 37 km per key), which "lines through lakes, wetlands and double-line rivers" does not name. That is immaterial.

## Findings

- **[false-claim]** `research/habitat_thresholds_tuned.md:225-227`: "Main-flow lines through lakes and wetlands (edge type 1200) read a river 0 m away less often (10–18 % … for every key but WCT, 62 %)". This is the round-1 fix (3). The "less often" is a comparison with river polygons, and for WCT it is false. Edge 1200 reads within 1 m on 61.7 % of WCT's graded km (1,396 km). WCT's river-polygon lines (1250, 1350 and 1450; 5,939 km) read within 1 m on 60.4 %. I measured both with duckdb on `data/tune/WCT_rear_grades.csv`, filtered to accessible and graded. As written, the parenthetical excepts WCT only from the 10–18 % range, not from "less often". Make the exception explicit, for example "less often for every key but WCT (10–18 % of their graded km within 1 m; WCT 62 %, as often as its river polygons' 60 %)".

- **[false-claim]** `research/habitat_thresholds_tuned.md:235-239`, `planning/archive/2026-10-issue-65-grade-walks-every-segment/README.md:56`, and issue #73's body ("Distance ends at the river's centreline" section): "where the connector could be traced (97–99 % of those) it adds a median of 14–46 m" / "the traced connector adds". The 97–99 % is the share of double-line endings that passed the `rws @> vws` ancestry test. It is not the share where a connector was found. `check_connector_share.R:26` `coalesce(…, 0)` turns "no 1450 segment on the tributary's main stem" into 0 m, and such sites stay in `n_measured`.
  - **CH:** 197 of the 2,260 "traced" sites have `conn_m = 0`.
  - **GR:** 36 of 934.
  - **BT spawning:** 17 of 260.
  - **Why the zeros:** in every CH zero case, the tributary's main stem holds no 1450 at all and its mouth segment is edge 1000. In the sample I inspected (blk 356360030 into 356362759), the tributary's line ends 767 m from the nearest line of the river, and the walk bridges that as an entry gap without adding it to `dist_m`.
  - **Connector share:** a connector was found on 89 % of CH's double-line endings (2,063 / 2,318), 95 % of GR's and 92 % of BT spawning's. That is not 97–99 %.
  - **Medians:** they include the zeros. CH's median over sites with a connector is 33 m, against the 28 m in the output.
  - **Effect on the bullet:** its premise, "its line crosses the polygon as a connector to the river's centreline", does not hold for these sites. Their distance stops short of the river rather than running past its bank.
  - **Fix:** either say "where the river could be resolved (97–99 %), the connector adds a median of 14–46 m, counting as 0 the 4–9 % with no connector" (that range is from three keys; print `n_zero` per key to state it for all eight), or report the connector-found share and medians over those sites. The zeros do not move the 22 flips, which require `conn_m > 0`.

- **[false-claim]** `planning/archive/2026-10-issue-65-grade-walks-every-segment/README.md:66`: "this directory's `review-*.md` (ten reviewer rounds)". This line was edited in this diff, and the directory now holds eleven `review-*.md` files: plan; round 1–3; ref 1–3; branch 1–3; flag-round1. This file makes twelve. Update the count, or drop it in favour of the glob.
