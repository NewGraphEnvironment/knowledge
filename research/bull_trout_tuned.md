# Bull trout rearing and spawning rules tuned on the province-wide run

**Verified:** 2026-10-17 · **Issues:** #57 (this); builds on #28 (`habitat_weights.md`, the gradient use curve on
link's 55-group build) and #33 (`bt_spawning.md`, spawner evidence by gradient class) · **Produced by:**
`scripts/0310` (evidence build, ledger `scripts/logs/habitat/20261017_evidence_build_ledger.csv`),
`scripts/0320` (`data/tune/BT_{rear,spawn}_*`, logs `scripts/logs/habitat/20261017_tune_run-*`), `scripts/0325`
(`data/thresholds.csv` rows `BT_rear_v1`, `BT_spawn_v1`; the grade table `knowledge/habitat_grade/v1`) ·
**Status:** measured; nothing applied in link. The method is `habitat_thresholds_tuned.md`.

## Rearing

**Population.** 8,717 stream-branch electrofishing visits (1,198 with BT) in 75 groups with both outcomes, of
11,015 in link's BT range with no natural barrier downstream; 158 groups carry a BT habitat table.

**Recommended rule: MAD ≥ 0.35 m³/s, gradient ≤ 10.49 %, no exception** (one departure from `default`: the
size test moves from a 1.5 m width floor to a MAD floor; the gradient is `default`'s own). It is the best rule
of the grid, and the region holds 196 rules: MAD 0.1–0.5 m³/s, gradient 9–10.49 %, with or without an
exception (10 of the 196 have none; 46 are width rules).

**`default` is outside the region**: 138.7 deviance above the best (SE 87.8), on all five fold seeds. The
recommended rule holds in every reading. Nested selection: 5,815 against `default`'s 5,931 and 6,031 for the
no-rule model. On the modelled visits the rule admits BT at 25.9 % against 9.6 % outside (`default`: 17.0 %
against 8.5 %). The bootstrap recommends this exact rule in 30 % of resamples; the floor sits at 0.1–0.5.

**Curve.** The joint GAM (log MAD × log distance to a 10 m³/s river, gradient) scores 5,731 held-out against the
grid's best 5,792: the curve carries a little more than the cut.

**Grade.** 8.41 M segments in 158 groups, 2.68 M accessible, 2.66 M graded (33,988 with no flow even from a
parent); reference rate 0.180. Of 577,130 accessible km, 571,306 are graded and sum to 175,327 grade-weighted
km: 54 % of graded km lies in the 0–0.2 class, 9 % in 0.8–1.

## Spawning

**Population.** 475 August–October visits that caught and maturity-coded BT (98 with spawner evidence) in 22
groups with both outcomes, of 552 in range.

**Recommended rule: MAD ≥ 0.75 m³/s, gradient ≤ 5.49 %, a ≥ 3 m³/s river within 2 km** (two departures). The
region holds 18 rules (MAD 0.15–1, gradient 4–9 %, Q 1–5, D 500–2,000 m; one without an exception). `default`
(width ≥ 2 m, ≤ 5.49 %) is 44.0 above the best with an SE of 41.6: outside, by a hair.

**Read this row as weak.** The rule separates nothing in raw terms: spawner evidence on 20.3 % of the visits it
admits and 20.8 % of those it leaves out. Nested selection puts the pick *worse* than `default` (462.6 against
453.0; no rule 449.2), it is in the region of only one of five fold seeds, and the bootstrap recommends it in
6.5 % of resamples. Ninety-eight detections in 22 groups do not carry a three-component rule. The grade's
reference rate is 0.239, and the curve is nearly flat: 61 % of graded km falls in the 0.4–0.8 classes and 0.1 %
under 0.2. #33's conclusion stands: the within-group spawner-evidence rate does not fall with gradient in a
way electrofishing can show, and redd surveys are the evidence spawning needs.

## What this replaces

#28's candidate weight per gradient class (`data/habitat_weight_bt_rear.csv`) is superseded by the rearing grade:
one surface over size, gradient and distance, graded against the best accessible segments, instead of a class
ratio. #28's held-out elevation contrast used link's step-5 split, which one province-wide schema no longer
carries; `habitat_weights.md` keeps those sections as history.
