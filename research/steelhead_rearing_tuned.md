# Steelhead rearing rule tuned on the province-wide run

**Verified:** 2026-10-17; grade and comparison figures 2026-10-19 (#65) · **Issues:** #57, #65 · **Produced by:** `scripts/0310`, `scripts/0320`
(`data/tune/ST_rear_*`), `scripts/0325` (`data/thresholds.csv` row `ST_rear_v1`) · **Status:** measured;
nothing applied in link. Method: `habitat_thresholds_tuned.md`.

**Population.** 1,375 stream-branch visits (82 with ST) in 11 groups with both outcomes, of 4,798 in link's ST
range with no natural barrier downstream. The export calls few juveniles steelhead (most are recorded as
rainbow), so this is a thin row: fitted, above the 10-group power floor by one group.

**Recommended rule: MAD ≥ 1 m³/s, gradient ≤ 8.49 %, no exception** (one departure: `default`'s width floor
becomes a MAD floor). The region holds 330 rules, all MAD rules: MAD 0.35–1 m³/s at any gradient in the grid
(3–9 %), with or without an exception. The gradient does not separate at this size.

**`default` is outside the region**: 42.4 above the best (SE 29.9). Nested selection: 726 against `default`'s 716
and 723 for no rule, so the honest comparison is a tie. ST are caught on 19.7 % of the visits the rule admits
against 2.0 % outside (`default`: 8.3 % against 2.9 %). The pick is in the region of four of five seeds.

**Curve.** The joint GAM scores 2,354 held-out against the grid's best 673: with 82 detections the smooth
overfits its training folds badly, and the cut is the better predictor. The grade is still the curve's
prediction at the reference, so read it as a ranking, not a rate.

**Grade** (regraded 2026-10-19, #65: every segment at its own distance to a 10 m³/s river, the reference over
the stream branch, on the flows wet republished that day). 4.14 M segments in 79 groups, 720,768 accessible,
717,790 graded; reference rate 0.201. Of 155,481 accessible km, 154,855 are graded (32,290 grade-weighted km);
76 % of graded km is under 0.2.

**Comparison (`scripts/0330`, `data/compare/ST_rear_*`).** Regenerated on link's 79 ST groups (#65's run, on the
flows wet republished on 2026-10-19, which moved the rule by +60 km), the rule draws 45,274 km against `default`'s
71,619 (−36.8 %): 26,677 km lost, 26,284 of them to the 1 m³/s floor, and 332 gained. Graded km
22,498 → 20,730. FDIS detection on the rule's segments is 7.5 % against 0.6 % outside (`default`: 4.8 % against
0.7 %); the bcfishobs outside lift moves 2.20 → 4.08, the largest rise after BT
rearing. Floodplain (4 catalog groups): 74,948 ha beside the rule's habitat against 108,807 under `default`
(−31 %); graded ha 35,822 → 34,802. Read with the row's 82 detections. Maps: `research/fig/compare_st_rear_*.png`.
