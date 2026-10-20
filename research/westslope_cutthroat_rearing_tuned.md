# Westslope cutthroat rearing rule tuned on the province-wide run (underpowered)

**Verified:** 2026-10-17; grade and comparison figures 2026-10-19 (#65) · **Issues:** #57, #65; link's own WCT calibration is NewGraphEnvironment/link#322 ·
**Produced by:** `scripts/0310`, `scripts/0320` (`data/tune/WCT_rear_*`), `scripts/0325` (`data/thresholds.csv`
row `WCT_rear_v1`, `power = underpowered`) · **Status:** measured; nothing applied in link. Method:
`habitat_thresholds_tuned.md`.

**Population.** 1,157 stream-branch visits (536 with WCT) in 6 groups with both outcomes, of 1,679 in link's
WCT range with no natural barrier downstream. Six groups is above the five the run needs to fold and below
the ten it calls powered, so every number here is **underpowered**: WCT are caught on nearly half the visits
in their range, and the groups that lack them are the contrast.

**Recommended rule: channel width ≥ 1.5 m, gradient ≤ 4 %, no exception** (one departure: the gradient
maximum falls from `default`'s 8.49 %). The region holds 677 rules, width 1–4 m or MAD 0.28 and up, gradient
3–9 %, so almost everything is inside it. `default` is 17.8 above the best with an SE of 13.4: outside, but by
less than one more SE. Nested selection: 1,344 against `default`'s 1,329 and 1,330 for no rule, a tie. WCT are
caught on 60.3 % of the visits the rule admits against 35.9 % outside (`default`: 53.3 % against 32.4 %). The
pick is in the region of all five seeds, and recommended by 12.5 % of bootstrap resamples.

**Curve and grade.** The joint GAM scores 1,375 held-out against the grid's best 1,311. 1.19 M segments in 16
groups, 167,459 accessible, 111,698 graded (683,918 with no width); reference rate 0.473 (regraded 2026-10-19,
#65: every segment at its own distance to a 10 m³/s river, the reference over the stream branch). Of 35,320
accessible km, 25,932 are graded (18,671 grade-weighted km), and 52 % of graded km is in the 0.8–1 class: in the groups
WCT hold, most graded stream reads as near the top.

**Comparison (`scripts/0330`, `data/compare/WCT_rear_*`).** Regenerated on link's 16 WCT groups, the rule draws
16,243 km against `default`'s 20,749 (−21.7 %): 4,510 km lost, 4,332 of them to the 4 % gradient maximum, and
4 km gained. Graded km 14,939 → 11,277 (#65's regrade; 12,463 → 8,543 before). FDIS detection on the rule's segments is 35 % against 27 % outside
(`default`: 35 % against 24 %): the segments the rule drops hold detections at nearly the rate it keeps, which is
the underpowered row showing in the change. The bcfishobs outside lift moves 1.56 → 1.73. Floodplain (4 catalog
groups): 117,691 ha beside the rule's habitat against 122,584 under `default` (−4 %, against −22 % in km); graded
ha 89,778 → 85,858. Maps:
`research/fig/compare_wct_rear_*.png`.

**What link#322 asked.** A calibration scored on held-out groups needs groups where WCT are absent as well as
present; with six such groups the evidence here cannot carry it, and link#322's design (its held-out groups
and ladders) is what the transfer issue should bring, not a number from this row.
