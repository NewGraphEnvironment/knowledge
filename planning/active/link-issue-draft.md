# Draft: link issue (not filed)

Destination: NewGraphEnvironment/link, which is **PUBLIC**. Nothing below names a private repository, a client or a
host. The numbers are aggregates.

---

**Title:** default_tuned: a CH rearing rule sized by MAD, with a near-a-river exception

**If done:** `default_tuned` carries a CH rearing rule tested against where juvenile Chinook are caught, and a vignette
shows it beside `default` on the same segments. **If never:** CH rearing stays width ≥ 1.5 m and gradient ≤ 5.49 %,
the bcfishpass values. In an out-of-sample test both sit well outside the rules the data cannot tell apart.

## Problem

`default`'s CH rearing stream branch tests `channel_width BETWEEN 1.5 AND 9999` and `gradient BETWEEN 0 AND 0.0549`.
Its MAD bounds (0.28–100 m³/s) never act, because every group is on `cw`.

These were tested against effort-corrected juvenile CH electrofishing detection: provincial FDIS site visits on
the CH stream branch, with no natural CH barrier downstream before observation overrides. That is 4,516 visits and
166 CH, scored in the 26 watershed groups with both outcomes.

- **2,795 candidate rules** were scored by held-out deviance, with watershed groups held out in 5 folds. Each rule
  had a size floor (MAD 0.1–1 m³/s or width 1–4 m), a gradient maximum (3–9 %), and optionally an exception: a
  segment of MAD ≥ Q (1–50 m³/s) within D m downstream (100–5,000 m).
- **Every rule within one SE of the best** sizes by MAD (0.28–1 m³/s), allows 7–9 % gradient, and carries the
  exception with Q 1–10 m³/s and D 1–2 km. The best, and the recommendation, is **MAD ≥ 0.75 m³/s, gradient ≤ 7 %,
  or a ≥ 3 m³/s segment within 1,000 m downstream**.
  - In a WSG bootstrap, 86 % of resamples put the floor at 0.5–0.75 m³/s, and 78 % put Q at 3 m³/s.
  - The gradient is the least settled component: 5.49–9 %.
- **`default` scores 188 deviance above the best (SE 79).** Its MAD form (0.28 m³/s, 5.49 %, no exception) scores
  131 above (SE 59). No width rule reaches the region, and nor does any rule without the exception.
- **Neither size nor distance has a threshold in the data.** Detection rises log-linearly with MAD and steadily
  with width. Each value is the cut that best separates held-out detection.

Applied to the 31 groups `fresh_default` classifies for CH, both rules went through the same predicate, overlay and
connectivity pass:
- CH rearing goes from 31,948 to 25,494 km (−20 %), with 9,399 km lost and 2,945 km gained.
- Raw FDIS detection on rearing segments is 34.6 % against 24.7 %, and 2.1 % against 2.6 % on accessible
  non-rearing segments.
- bcfishobs CH records not from FDIS (812 locations) fall on rearing at 4.4 times the rearing km share, against 3.0
  under `default`.

`default`'s MAD bounds, applied as fresh's `mad` model does, would also drop rivers over 100 m³/s, because the
river-polygon branch takes the MAD range. Most FDIS CH detections on accessible segments in those groups are there.

## Proposed solution

1. **A new rule shape:** a stream-branch alternative to the size test that holds where a segment of MAD ≥ Q lies
   within D m downstream. The distance is walked on route measures from the segment's downstream end, to the first
   primary-flow segment of that flow. `fwa_downstreamtrace()` returns side channels off the path and drops segments
   with no watershed lookup row, so its rows cannot be summed into a distance. Lake segments count as targets. A
   walk that reaches the sea first fails.
2. **In `default_tuned`**, CH rearing:
   - a rule-level `mad: [0.75, 9999]` on the stream rule, which reaches `s.mad_m3s` on a `cw` group (no maximum, so
     large rivers stay in);
   - `rear_gradient_max` 0.07;
   - the exception with Q 3 m³/s and D 1,000 m.

   This needs wet's discharge (#331). The values above were tuned on wet's `pick`, and fwapg's MAD covers only part
   of the province.
3. **A vignette** setting `default` and `default_tuned` side by side for CH on the same segments: rearing km, maps of
   a small-stream, an interior and a coastal group, and FDIS and bcfishobs checks.

Relates to #331
