# Rainbow trout rearing rule tuned on the province-wide run

**Verified:** 2026-10-17 · **Issues:** #57 (this); link's own RB calibration is NewGraphEnvironment/link#343 ·
**Produced by:** `scripts/0310`, `scripts/0320` (`data/tune/RB_rear_*`), `scripts/0325` (`data/thresholds.csv`
row `RB_rear_v1`) · **Status:** measured; nothing applied in link. Method: `habitat_thresholds_tuned.md`.

**Population.** 12,959 stream-branch visits (3,513 with RB) in 129 groups with both outcomes, of 13,578 in
link's RB range with no natural barrier downstream: the largest population of any species. 210 groups carry an
RB habitat table.

**Recommended rule: channel width ≥ 3 m, gradient ≤ 9 %, no exception** (two departures from `default`'s
width ≥ 1.5 m, ≤ 8.49 %). The region holds 81 rules, all width rules: width 2–3 m, gradient 7–9 %. The best
rule (width ≥ 3 m, 7 %, a 1 m³/s river within 250 m) is 32.8 below the pick, inside the same SE.

**`default` is outside the region**: 150.6 above the best (SE 63.9). Nested selection: 11,863 against
`default`'s 11,955 and 12,617 for the no-rule model. RB are caught on 41.5 % of the visits the rule admits
against 18.0 % outside (`default`: 36.3 % against 15.9 %).

**The pick is not stable across fold seeds.** It is in the region of two of five seeds and recommended by
4 % of bootstrap resamples; the components move between 2 and 3 m and between 7 and 9 %. What is stable is
the direction: wider and steeper than `default`.

**Curve.** The joint GAM scores 9,737 held-out against the grid's best 11,804: a large gain, the largest of any
species. Rainbow detection rises with width over the whole range rather than stepping at a floor, so a graded
surface carries what a cut cannot.

**Grade, and the width rule's blind spot.** 10.33 M segments in 210 groups, 2.35 M accessible, 1.22 M graded.
6.26 M segments have no width: fwapg models width only where `stream_order > 1`, so every unmeasured
first-order stream is ungraded (`NA`, counted), and of 510,150 accessible km only 277,539 are graded (134,596
grade-weighted km). Reference rate 0.411. Graded km spread evenly: 24 % under 0.2, 21 % at 0.8–1.

**Comparison (`scripts/0330`, `data/compare/RB_rear_*`).** Regenerated on link's 210 RB groups, the rule draws
183,988 km against `default`'s 227,089 (−19.0 %): 44,368 km lost, all of them streams between 1.5 and 3 m wide,
and 1,267 gained between the two gradient maxima. Graded km 115,119 → 101,860. FDIS detection on the rule's
segments is 35 % against 18 % outside (`default`: 33 % against 15 %); the bcfishobs outside lift moves
2.34 → 3.04. The regenerated `default` differs from link's stored RB flags by 45,970 km, more than for any other
species. Floodplain (23 catalog groups): 560,759 ha beside the rule's habitat against 663,464 under `default`
(−15 %); graded ha 324,847 → 293,833. Maps: `research/fig/compare_rb_rear_*.png`.

**Access.** link's two access columns disagree most for RB (`access_check.csv`: 481,275 habitat-accessible
segments with `access_rb = 0`, 147,445 of them rearing), and the comparison shows the disagreement is whole
groups: in 23 of the 210 (BRID CANO CARP CLRH CRKD FINA FINL FIRE FOXR INGR LEUT LOMI MAHD MESI MURT NATR OSPK
PARA PARS PCEA TURN UEUT UOMI; 37,895 km of stored rearing) every segment has `access_rb = 0`, so they carry no
grade and draw no map. The grade is gated on `streams_access` until link settles which column is meant
(NewGraphEnvironment/link#349).
