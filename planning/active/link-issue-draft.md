# Draft: link issue (not filed)

Destination: NewGraphEnvironment/link, which is **PUBLIC**. Nothing below names a private repository, a client or a
host. The numbers are aggregates.

---

**Title:** default_tuned: a CH rearing rule sized by MAD, with a near-a-river exception

**If done:** `default_tuned` carries a CH rearing rule tested against where juvenile Chinook are caught, and a vignette
shows it beside `default` on the same segments. **If never:** CH rearing keeps a 1.5 m width floor with no allowance
for small streams near a river, the bcfishpass rule. That floor scores well outside the rules an out-of-sample test
cannot tell apart, and so does its MAD form.

## Problem

`default`'s CH rearing stream branch tests `channel_width BETWEEN 1.5 AND 9999` and `gradient BETWEEN 0 AND 0.0549`.
Its MAD bounds (0.28–100 m³/s) never act, because every group is on `cw`.

They were tested against effort-corrected juvenile CH electrofishing detection. The visits are provincial FDIS site
visits on the CH stream branch with no natural CH barrier downstream before observation overrides: 4,516 visits and
166 CH in 45 watershed groups. They are scored in the 26 groups with both outcomes: 3,434 visits, 166 CH.

- **2,795 candidate rules** were scored by held-out deviance, with watershed groups held out in 5 folds. Each rule
  had:
  - a size floor: MAD 0.1–1 m³/s or width 1–4 m;
  - a gradient maximum: 3–9 %;
  - optionally an exception: a segment of MAD ≥ Q (1–50 m³/s) within D m downstream (100–5,000 m).
- **Every rule within one SE of the best** has the exception and sizes by MAD (0.28–1 m³/s), with gradient 7–9 %,
  Q 1–10 m³/s and D 1–2 km. The best, and the recommendation, is **MAD ≥ 0.75 m³/s, gradient ≤ 7 %, or a ≥ 3 m³/s
  segment within 1,000 m downstream**.
  - In a watershed-group bootstrap, 86 % of resamples put the floor at 0.5–0.75 m³/s, and 78 % put Q at 3 m³/s.
  - The gradient is the least settled component. 5.49 % is recommended in 23.5 % of resamples, while the best rule
    has 7 or 9 % in every reading, including on link's own segment gradient.
- **`default` scores 188 deviance above the best (SE 79).** Its MAD form (0.28 m³/s, 5.49 %, no exception) scores
  131 above (SE 59). No rule without the exception is within one SE of the best in any reading.
- **Neither size nor distance has a threshold in the data.** Detection rises log-linearly with MAD and steadily
  with width, and falls steadily with distance. Each value is the cut that best separates held-out detection.

Applied to the 31 groups `fresh_default` classifies for CH, all rules went through the same predicate, overlay and
connectivity pass:
- **CH rearing** goes from 31,948 to 26,092 km (−18 %).
  - 8,756 km are lost. 8,660 km of it is streams that pass the 1.5 m width but carry under 0.75 m³/s with no
    ≥ 3 m³/s river within 1 km. 98 % of the loss is on order 2 and above.
  - 2,900 km are gained. 2,471 km of it comes through the exception, mostly on order-1 streams, which `default`
    leaves out because fwapg models no width there.
- **Raw FDIS detection** on rearing segments is 34.6 % against 24.7 %, and on accessible non-rearing segments 1.8 %
  against 2.6 %.
- **bcfishobs CH records not from FDIS**, at 315 locations on accessible stream edges, fall on rearing at 4.0 times
  the rearing km share, against 2.8 under `default`.

`default`'s MAD bounds, applied as fresh's `mad` model does, would also drop rivers over 100 m³/s, because the
river-polygon branch takes the MAD range. Most FDIS CH detections on accessible segments in those groups are on
such rivers.

## Proposed solution

1. **A new rule shape:** a stream-branch alternative to the size test that holds where a segment of MAD ≥ Q lies
   within D m downstream.
   - The distance is walked on route measures from the segment's downstream end, to the first primary-flow segment
     of that flow.
   - `fwa_downstreamtrace()` returns side channels off the path and drops segments with no watershed lookup row, so
     its rows cannot be summed into a distance.
   - Lake segments count as targets. A walk that reaches the sea first fails.
2. **In `default_tuned`**, CH rearing (the bundle then needs its own `rules.yaml`):
   - **The stream rule**: `edge_types_explicit: [1000, 1100, 2000, 2300]`, `thresholds: false`,
     `gradient: [0, 0.07]` and `mad: [0.75, 9999]`. With `thresholds: false` the inherited width test drops out;
     without it, a rule-level `mad:` is added to the width test rather than replacing it. There is no MAD maximum,
     so large rivers stay in.
   - **A second stream rule** with the same edges and gradient and the new exception (Q 3 m³/s, D 1,000 m) in place
     of the size test.
   - **The river-polygon rule** keeps `channel_width: [0, 9999]`, taking the gradient from the CSV.
   - `rear_gradient_max` 0.07.
   - **The habitat method stays `cw`.** Under `mad`, fresh drops the river rule's `channel_width` and the river
     branch takes the CSV's MAD range (0.28–100 m³/s), which removes large rivers. Set CH `rear_mad_min` to 0 and
     `rear_mad_max` to 9999 in the bundle's CSV, so that a group moved to `mad` keeps them.

   This needs wet's discharge (#331). The values were tuned on wet's `pick`, and fwapg's MAD covers only part of the
   province.
3. **A vignette** setting `default` and `default_tuned` side by side for CH on the same segments: rearing km, maps of
   a small-stream, an interior and a coastal group, and the FDIS and bcfishobs checks.

Relates to #331
