# Coho rearing rule tuned on the province-wide run

**Verified:** 2026-10-17 · **Issues:** #57 · **Produced by:** `scripts/0310`, `scripts/0320`
(`data/tune/CO_rear_*`), `scripts/0325` (`data/thresholds.csv` row `CO_rear_v1`) · **Status:** measured;
nothing applied in link. Method: `habitat_thresholds_tuned.md`.

**Population.** 4,263 stream-branch visits (1,107 with CO) in 62 groups with both outcomes, of 5,442 in link's
CO range with no natural barrier downstream; 100 groups carry a CO habitat table.

**Recommended rule: MAD ≥ 0.03 m³/s, gradient ≤ 4 %, no exception** (two departures from `default`'s width
≥ 1.5 m, ≤ 5.49 %). The region holds 87 rules, all MAD rules: MAD 0.03–0.2 m³/s, gradient 3–4 %, with or
without an exception (2 of the 87 have none). The best rule (MAD ≥ 0.1, 4 %, a 3 m³/s river within 2 km) is 15.6
below the pick, inside the SE.

**The size floor is the smallest a rule can carry: coho rear in the smallest streams.** 0.03 m³/s is the bottom
of the grid (`default`'s MAD form is 0.03), and the region runs to 0.2. The change from `default` is the
gradient: 4 % against 5.49 %, with 3 % inside the region too. Coho are caught on 40.9 % of the visits the rule
admits against 15.2 % outside (`default`: 33.0 % against 19.2 %).

**`default` is outside the region**: 113.2 above the best (SE 45.8), on four of five seeds for the pick's
standing. Nested selection: 3,880 against `default`'s 3,968 and 4,025 for no rule. The bootstrap recommends the
pick in 18.5 % of resamples.

**Curve.** The joint GAM scores 4,068 held-out against the grid's best 3,855: the cut carries more than the
surface; coho detection is high and flat across small streams, and the gradient cut is what separates.

**Grade.** 4.92 M segments in 100 groups, 615,302 accessible, 607,483 graded (10,518 with no flow); reference
rate 0.514, the highest of any species, so grades spread: 20 % of graded km under 0.2, 14 % at 0.8–1. Of
147,962 accessible km, 146,612 are graded (66,893 grade-weighted km).

**Comparison (`scripts/0330`, `data/compare/CO_rear_*`).** Regenerated on link's 100 CO groups, the rule draws
77,612 km against `default`'s 81,629 (−4.9 %). 9,184 km are lost, 5,059 of them to the 4 % gradient maximum and
3,599 streams over 1.5 m wide under 0.03 m³/s; 5,167 km are gained, 4,634 of them order-1 streams under 1.5 m
wide that carry the flow. Graded km 48,879 → 48,516. FDIS detection on the rule's segments is 32 % against 11 %
on accessible segments outside it (`default`: 29 % against 13 %); the bcfishobs outside lift moves 1.75 → 1.82.
Floodplain (10 catalog groups): 243,051 ha beside the rule's habitat against 272,429 under `default` (−11 %, more than
the km's −5 %: the lost streams carry floodplain, the gained order-1 streams do not); graded ha 176,396 → 166,814.
Maps: `research/fig/compare_co_rear_*.png`.
