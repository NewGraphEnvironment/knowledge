## Outcome

#54 asked for a tuned Chinook rearing rule built on link's `default`. Only three things were open:
- the stream size test;
- the gradient test;
- a new exception for small streams near a large river.

Each value was to be given as the range the data cannot tell apart. The rule was scored on held-out watershed groups,
set beside `default` on link's own segments, and written to lift into a link vignette.

The result is `research/chinook_rearing_tuned.md`.
- **The recommendation.** The rule fixed before the run picks **gradient ≤ 7 %, and either MAD ≥ 0.75 m³/s or a
  ≥ 3 m³/s river within 1,000 m downstream**. On the main reading's region, the MAD floor runs 0.28–1, the gradient
  7–9 %, Q 1–10 m³/s and D 1–2 km.
- **Robustness.** Two rules are inside the region of all 15 readings: MAD ≥ 0.5 m³/s, Q 3 @ 1,000 m, at 7 % or 9 %.
  The recommended rule is inside 13 of them. It is outside both readings on the visits placed on link's segments.
  Which rule to carry to link is left to the link issue, drafted in `link-issue-draft.md` and not filed.
- **`default`.** It is outside the region in all 15 readings. So are its MAD bounds (0.28–100 m³/s, bcfishpass's),
  which the user asked about mid-run and which became a third rule in the side by side.
- **Curves.** Neither size nor distance bends: each value is the cut that best separates held-out detection.
- **Extent.** On link's segments the tuned rule is 18 % narrower than `default`, not wider.

The plan review changed the population before any fit:
- stream-branch visits only, because 702 of the 978 CH sit on river polygons, where every rule keeps its size test;
- no natural CH barrier downstream, because link applies the rule behind its access gate;
- the width link reads on unmeasured streams, because fwapg models no order-1 width and the stored field widths are
  the FDIS sites themselves.

## Code-check (branch mode)

| Round | Findings | Fixed | Accepted | Inside previous fix? |
|---|---|---|---|---|
| 1 | 17 | 17 | 0 | — |
| 2 | 10 | 10 | 0 | y: the lift across access; a rate given with a share |
| 3 | 8 + 7 notes | 8 + 7 | 0 | y: 6 of 8 |
| 4 | 3 + 5 notes | 3 + 4 | 1 note | y: 1 |
| 5 (lead) | closing enumeration, 12 rows | — | — | — |

Five reviewer agents were spent (one plan review, four rounds), the per-task bound.
- **Round 1's main finding.** The tuned rule had put its MAD floor on river polygons, dropping 636 km of lines that
  carry a tributary's flow or a small river's own.
- **Round 3's mechanism.** Every figure comes from a filter in code, while the prose names its population with a
  noun defined elsewhere, and the two lists are kept equal by hand.
- **How the loop ended.** Round 3 enumerated 140 claims. Round 4 re-enumerated the lines round 3 changed, and round 5
  the lines round 4 changed, checked by script.

## Measurement

- **Grid.** 2,795 rules on 3,434 stream-branch visits (166 CH, 26 WSGs).
  - `default` is +188.2 (SE 78.7) above the best, and its MAD form +131.0 (SE 59.5).
  - Nested selection: 937.7 against 1,039.8 for `default` and 1,063.5 for "all in".
  - WSG bootstrap: MAD floor 0.5–0.75 in 86 % of resamples, Q 3 in 78 %.
  - The rule outputs are byte-identical on two re-runs.
- **Side by side** on 31 groups, CH rearing:
  - `default`: 31,948 km;
  - `default_mad`: 21,548 km (−32.6 %);
  - tuned: 26,092 km (−18.3 %), with 8,756 km lost (8,660 of them streams at least 1.5 m wide under 0.75 m³/s with
    no river near) and 2,900 km gained (2,471 through the exception).
  - Regenerated `default` differs from the stored flags on 4,584 km.
- **Outside check.** bcfishobs lift on 315 accessible stream-edge locations: 2.82 / 4.54 / 4.00.
- **Runtimes.**
  - 0296: about 3.5 min, of which 2.2 min is walks (17,747 starts × 3 sources × 7 sizes).
  - 0297: about 23 min on 6 workers.
  - 0298: about 20 min alone (3.4 min of walks, 16.1 min of classify, overlay and connectivity for 93 rule runs).
- **Wrong turns kept.**
  - **The side by side** read −20.2 % with lifts of 2.97 / 4.75 / 4.36, then 2.73 / 4.39 / 3.86 (rounds 1 and 2).
  - **The distance curve** was first drawn flat to 1 km, an artifact of x = 0 on a log axis.
  - **The hydrologic zones** broke `st_join` after an `st_transform()` to the CRS they were already in.
  - **The width-model check** first failed at 20 % agreement on a 0.01 m tolerance; the stored widths are from older
    inputs (ratio 1.007).
  - **`default`'s MAD bounds.** On FDIS visits they separate nothing (14.0 % against 14.2 %), because their 100 m³/s
    cap drops the large rivers where 441 of 699 detections sit.

## Evidence

`scripts/logs/habitat/20261015_ch_rule_*`. The private tables `ch_rule_visits.csv` and `ch_rule_walks.csv` are in
`s3://fresh-bc/fdis/derived/`.

Closed by: PR for branch `54-tuned-chinook-rearing-rule-size-gradient`
