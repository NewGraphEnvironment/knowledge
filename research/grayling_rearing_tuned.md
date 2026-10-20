# Arctic grayling rearing rule tuned on the province-wide run

**Verified:** 2026-10-17; grade and comparison figures 2026-10-19 (#65) · **Issues:** #57, #65; link's own GR calibration is NewGraphEnvironment/link#343 ·
**Produced by:** `scripts/0310`, `scripts/0320` (`data/tune/GR_rear_*`), `scripts/0325` (`data/thresholds.csv`
row `GR_rear_v1`) · **Status:** measured; nothing applied in link. Method: `habitat_thresholds_tuned.md`.

**Population.** 1,230 stream-branch visits (212 with GR) in 26 groups with both outcomes, of 1,472 in link's GR
range with no natural barrier downstream; 82 groups carry a GR habitat table.

**`default` is inside the region, and is the pick.** `default` (width ≥ 1.5 m, gradient ≤ 3.49 %) is 10.7
deviance above the best rule with an SE of 12.1, so by the decision rule fixed before the run the data cannot
tell a tuned rule from it, and the recommended rule *is* `default`. The region is wide: 799 rules, width 1–4 m
(792 width rules, 7 MAD rules), gradient 3–9 %, with or without an exception. The best rule (width ≥ 2 m,
5.49 %, a 3 m³/s river within 250 m) buys 10.7 deviance, inside the noise. Nested selection: 849 against
`default`'s 836 and 848 for no rule. GR are caught on 23.8 % of the visits `default` admits against 7.9 %
outside. `default` is in the region of three of five seeds.

**Curve.** The joint GAM scores 1,022 held-out against the grid's best 825: the cut beats the surface here,
as for steelhead. Grayling are a river fish; width carries most of the signal, and the smooth adds noise.

**Grade** (regraded 2026-10-19, #65: every segment at its own distance to a 10 m³/s river, the reference over
the stream branch). 4.21 M segments in 82 groups, 856,113 accessible, 496,267 graded; 2.62 M have no width (unmeasured
first-order streams). Reference rate 0.034: grayling are rarely caught by electrofishing anywhere, so the
grade is relative to a low top. Of 258,724 accessible km, 146,128 are graded (72,867 grade-weighted km),
spread evenly across the classes (25 % under 0.2, 25 % at 0.8–1).

**Comparison (`scripts/0330`, `data/compare/GR_rear_*`).** The recommended rule is `default`, so nothing
changes: 77,740 km on link's 82 GR groups under both, graded km 44,602 (#65's regrade; 46,831 before),
bcfishobs outside lift 3.56, 96,530 ha of
floodplain beside the habitat in the three catalog groups. Three
groups (BULL ELKR TURN) have no segment passing the GR access gate and draw no map.

**What link#343 asked.** The MAD minima link proposed to re-tune on wet's discharge do not enter: the grid
prefers width for grayling, and 7 of 799 region rules are MAD rules.
