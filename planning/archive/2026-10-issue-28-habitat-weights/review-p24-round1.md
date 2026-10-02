# Review p2/p4 round 1 — 0291, 0292, research/habitat_weights.md, findings Phase 2, link draft

Verified as correct (no action): `class_weight()` reference math (count-weighted core mean of the
modelled data reproduces exactly 1.000 on a re-fit); C fitted on `F == 1` with no NA in
`catch_status`/`U`/`F` and no `U = 1, F = 0` rows; bootstrap (duplicated streams, `modelled()` after
resampling, NA for absent/aliased classes, `na.rm` quantiles, `n_boot_ok`); held-out offset (every
calibration shape coefficient has a matching `model.matrix` column, all 9 classes present in both
calibration and held-out, data_set/era levels shared); log(area) coefficients 0.070 (F), 0.192 (U),
0.193 (C) match the "0.07–0.19" claim; `site_visit` unique in `v`. PAVA in 0292 matches a brute-force
min–max isotonic reference on 2,000 random weighted sequences (0 mismatches), gives 2.5 x4 on
c(1,3,2,4), and reproduces the shipped column (0.9493, 0.9493, 0.894, 0.739, 0.641, 0.5047 x3). The
research weight table, the issue-answer table and the link draft weight table all match
`data/habitat_weight_bt_rear.csv`.

## Findings

- **[severity: bug]** research/habitat_weights.md:70-71, planning/active/findings.md (Phase 2 "What it
  says" 3), #28 issue body "Answer / Elevation" — "Per visit, detection does not fall with elevation, so
  step 5's per-km elevation taper is sampling density" is contradicted on the very WSGs step 5 measured.
  Probe on the held-out 8 (core classes, `elev_class`): visits low/mid/high 942 / 818 / 913 (flat — no
  sampling-density drop), BT rate 0.401 / 0.275 / 0.106. The adjusted held-out fit (U ~ cls + elev_class
  + log_area + data_set + era + wsg) gives rate ratios mid 0.765, high 0.360 — almost exactly step 5's
  24.6 : 19.3 : 10.2 (1 : 0.78 : 0.41). Calibration has the opposite sign (mid exp(0.621) = 1.86, high
  exp(0.727) = 2.07), and the all-WSG 1.27 / 1.01 is the average of the two. So the −82 held-out
  log-lik is a sign flip between WSG sets (region-dependent elevation effect), not an absent one. Across
  all WSGs the "fewer visits high up" half is also not what the log shows: core visits 3,744 / 2,851 /
  2,940 (a 21 % drop, cannot carry a 59 % taper) and all-class visits 4,692 / 4,376 / 5,395 (most visits
  in the high third). "Elevation does not earn a place" by the spec's rule stands; the sampling-density
  explanation of step 5's taper and "detection does not fall with elevation" do not.
- **[severity: bug]** research/habitat_weights.md:51 — "Spawner evidence is rare in the steep classes: 9
  visits above 14.49 %, against 23 at 0–2 %" compares raw counts across classes with 10x different BT
  visit totals. Per BT visit (0291 log "BT visits with fry or juveniles"): >14.49 % 9/75 = 12 %,
  10.49–12.49 % 9/63 = 14 %, core 0–2 % 23/791 = 2.9 %, core 2–5 % 34/564 = 6 %. Spawner evidence is
  proportionally 4–5x more frequent in the steep classes, which weakens rather than supports Q4's
  "Rearing, not adults moving through".
- **[severity: bug]** research/habitat_weights.md:69 and :124 — "FDS-only fits have no steep decline
  (0.60–1.12)" / "The forestry fish-stream surveys show no steep decline in U. FDIS does." The log's
  `fds_only` column for the steep classes is 0.600, 0.907, 0.499, 1.117, so the range is 0.50–1.12, and
  at 10.49–12.49 % FDS (0.600) equals FDIS (0.605). The two FDS values near 1 rest on 6 and 24 BT
  detections; FDS steep classes hold 11 / 6 / 2 / 24 detections in 161 / 52 / 51 / 198 visits, so
  12.49–13.49 and 13.49–14.49 fail the script's own power rule (>= 10 detections). The data do not show
  "no steep decline" in FDS; findings.md point 5 states the numbers correctly but the research file's
  reading is unsupported.
- **[severity: bug]** research/habitat_weights.md:72 — "MAD lifts them 0.3–0.4": log `mad_subset` →
  `mad_subset_with_mad` steep lifts are 0.392, 0.300, 0.150, 0.434 (range 0.15–0.43). The width lifts
  (0.151, 0.141, 0.096, 0.138) do fit "about 0.1–0.15".
- **[severity: bug]** planning/active/findings.md Phase 2 "Population" — "58 for any fish": the log says
  `all / any_fish_caught: 14461 visits in 57 WSGs modelled; ... 1 WSGs ... left out`. 57 (58 is the
  population before the both-outcome filter).
- **[severity: bug]** research/habitat_weights.md:106, :20-21 and link-issue-draft.md:40-42 — "among
  fish-bearing visits the steep classes are as good as core" / "BT occur as often on the steep classes as
  on core" read C as habitat quality/preference. C is P(BT caught | any fish caught), and a visit that
  catches only BT counts as a fish visit; as other species drop out of steep, small streams, C rises
  mechanically even if BT density falls. C ≈ 1 shows BT's presence among fish-bearing visits holds up,
  not that the habitat is "as good". Similarly "A fishless visit up a steep stream is usually above the
  upper limit of fish" (research :23-24; findings 1; draft :41-42 "that is, the upper limit of fish") is
  an inference, not a measurement — nothing in 0290/0291 locates the fish limit, and the header's own F
  definition allows gear failure. The access-code split in the log points to a further component:
  within code 1 the steep BT rates (0.020–0.050) are near core 0–2 (0.016), within code 2 steep rates
  (0.50–0.85) exceed core 0–2 (0.30), and the code-2 share falls 0.50 → 0.05–0.10 — so much of the U
  decline is composition by access code, which research.md never quantifies (it is in findings 9 only).
- **[severity: fragile]** research/habitat_weights.md:126-127 — "Only WSGs that link has modelled are
  covered: 58 of them (fresh_default plus the 8 step-5 held-out)." fresh_default holds 55 WSGs (0290
  header) + 8 = 63 modelled; 59 WSGs have visits in 0290's table and 58 survive the area trim. The 58 is
  the population, not what link models.
- **[severity: fragile]** planning/active/link-issue-draft.md:12-13 — "stops jumping when
  `rear_gradient_max` moves, because stream just past the line counts at about half" contradicts the
  recommended option (A), under which the cutoff still decides inclusion: moving 0.1049 → 0.1349 still
  adds 0.64 x km(10.49–12.49) + 0.50 x km(12.49–13.49) in one step. It shrinks the jump; it stops it only
  under (B). (Also 0.64 is not "about half".)
- **[severity: fragile]** data/habitat_weight_bt_rear.csv `sources` column / 0292:21 "can leave this
  repo" — every row carries "knowledge#28: scripts/0290-0292", a private-repo reference, while the link
  draft proposes a `source` column in a public bundle. No client identifier, but the string should not be
  copied into link verbatim.
- **[severity: fragile]** planning/active/task_plan.md Phase 2 last item checked as "Output:
  data/bt_rear_use_curve.csv (aggregates only: band × elevation class, ...)" — the CSV is role ×
  response × class with no elevation dimension (elevation appears only in the log). The checkbox marks
  done something other than what was built.
