# A tuned Chinook rearing rule: stream size, gradient and distance to a river, beside link's `default`

**Verified:** 2026-10-16; 0297's figures rerun 2026-10-17 without repeated surveys (#35), with the same recommended rule; the head paragraph and the last section 2026-10-18 (#62) · **Issues:** #54 (this); builds on #52 (`chinook_stream_size.md`), which picked 0.5 m³/s, 10 m³/s
and 500 m by hand; uses wet's flow (`modelled_discharge.md`) and the FDIS export (`fdis_export.md`); the link issue for
a tuned rule is drafted, not filed (planning archive for #54) · **Produced by:**
- `scripts/0296-ch-rule-build.R` with `scripts/sql/ch_dist_profile.sql`: walks, widths, barrier status, link segment
  and zone per visit; ledger `scripts/logs/habitat/20261015_ch_rule_build_ledger.csv`. Since #35 the table is that
  build less the repeated-survey copies 0230 drops (`scripts/logs/habitat/20261017_fdis_repeat_filter.txt`; a rebuild
  on the current `fresh_default` is part of #57);
- `scripts/0297-ch-rule-tune.R`: `data/ch_rule_tune.csv`, `data/ch_rule_curves.csv`, `data/ch_rule_flips.csv`,
  `fig/chinook_rearing_tuned_curves.png`, log `scripts/logs/habitat/20261017_ch_rule_tune.txt`;
- `scripts/0298-ch-rule-compare.R`: `data/ch_rule_compare.csv`, `data/ch_rule_checks.csv`, `data/ch_rule_change.csv`,
  the maps in `fig/`, log
  `scripts/logs/habitat/20261015_ch_rule_compare.txt`. Not rerun for #35: the recommended rule is unchanged, so its km
  figures cannot move, but its FDIS detection figures (on each rule's segments, and the maps' visit shares) are from
  the visits before #35 dropped repeated surveys;
- the plan review and its disposition: `planning/archive/2026-10-issue-54-chinook-rearing-tuned/review-plan.md`.

**Status:** measured; nothing applied in link. The plain-language account is the package article (last section).

**On the province-wide run (#57, 2026-10-17).** The same rule family rescored by `scripts/0320` on `0310`'s
evidence build (link run `20261017_004619-3f4c713b`, 241 groups): 4,490 stream-branch visits (215 CH) in 43
groups with both outcomes, against 3,433 in 26 here. The shape holds: the region is 23 rules, all MAD rules with
the exception, MAD 0.35–1 m³/s, gradient 7–9 %, Q 1–10 m³/s, D 1–2 km; the recommended rule is
**MAD ≥ 0.75 m³/s, gradient ≤ 9 %, a ≥ 3 m³/s river within 1 km**, which differs from this file's only in the
gradient (9 % against 7 %, both inside both regions). `default` is 196.3 above the best (SE 81.6), outside on
every seed; nested selection 1,234 against `default`'s 1,347. **The size floor settles at 0.75 m³/s** (the open
question of #54), with 0.5 inside the region. The thresholds table carries it as `CH_rear_v1`
(`data/thresholds.csv`); every CH segment of the 125 groups carries a grade (`knowledge/habitat_grade/v1`:
856,244 accessible segments, 852,431 graded, reference rate 0.146, 76 % of graded km under 0.2). The method
and the cross-species table are `habitat_thresholds_tuned.md`. Regenerated on all 125 CH groups
(`scripts/0330`, `data/compare/CH_rear_*`), the rule draws 88,607 km against `default`'s 101,184 (−12.4 %):
24,843 km lost, 24,542 of them to the 0.75 m³/s floor, and 12,266 gained, 9,666 through the exception (6,952
order 1) and 1,398 between the two gradient maxima. Graded km rises, 27,681 → 32,018, the only species where it
does. FDIS detection on the rule's segments is 17 % against 1.5 % outside (`default`: 14 % against 2 %); the
bcfishobs outside lift moves 2.46 → 3.27. Floodplain (16 catalog groups): 341,298 ha beside the rule's habitat
against 426,681 under `default` (−20 %, against −18.8 % in km on the same 16 groups), graded ha 146,059 → 147,442;
graded figures are provisional until #65, because the grade reads a segment that passes the size test at the 50 km
distance cap. The province-wide joint curve bends in distance (at 0.75 m³/s, the predicted chance is highest about
120 m from a ≥ 3 m³/s river and falls past a few hundred metres, to 0.42 of the 1 km value at 3 km;
`data/tune/CH_rear_curves.csv`), so D = 1 km sits past the bend. #54's distance curve below, fitted separately on the
visits failing the floor, showed no plateau; the two are different models. The figures below are #54's, on the 55-group build; the province-wide
maps are `research/fig/compare_ch_rear_*.png`.

Every figure names its population. Three recur:
- **Tuning population.** FDIS electrofishing visits on link's CH stream branch, with no natural CH barrier downstream:
  4,516 visits (166 CH) in 45 WSGs. The models use the 26 WSGs where CH were both caught and missed: 3,433 visits,
  166 CH.
- **All stream-branch visits**, barrier status unknown or blocked kept: 15,186 visits (264 CH); 9,745 visits
  (263 CH) in 46 WSGs modelled.
- **Side-by-side groups.** The 31 WSGs where link's `fresh_default` classified CH: 53,653 km of accessible stream
  edges.

## The question

#52 found CH rarely caught in streams under about 0.5 m³/s unless a ≥ 10 m³/s river is within 500 m downstream.
Those three numbers were picked by hand. Which rearing rule do the visits support, and how far can each value move
before the data can tell the difference?

The rule tuned here is link's `default` CH rearing rule with three things open:
- the stream size test (a MAD floor or a channel-width floor);
- the gradient maximum;
- an exception for small streams within D m downstream of a river of at least Q m³/s.

Nothing else in `default` changes. River polygons keep their size test (any non-NULL width) under every rule. In
this comparison their gradient maximum moves with the stream branch's. In the configuration the link draft proposes,
those are three settings (each of the two stream rules' own gradient, and the CSV's `rear_gradient_max`, which the
river rule inherits), and they must be moved together. Wetlands, lakes, access, the user-habitat overlay and the cluster pass that keeps only rearing connected to spawning are unchanged.

## Short answer

1. **The visits support a different rule from `default`, in all three components.** Recommended, by the rule fixed
   before the run (the main reading's pick): **gradient ≤ 7 %, and either MAD ≥ 0.75 m³/s or a ≥ 3 m³/s river within 1,000 m downstream**. Ranges the data cannot tell apart on the main reading
   (within one SE of the best):
   - MAD floor 0.28–1 m³/s, with 0.5–0.75 in 86 % of bootstrap resamples;
   - gradient 7–9 %, the best rule's 7 or 9 % in all 15 readings (5.49 % is recommended in 23.5 % of bootstrap
     resamples and on one of four extra fold seeds, and is in the region of only two of the 15 readings: FWA gradients
     for link-placed visits, and fwapg's old MAD);
   - river size Q 1–10 m³/s, mostly 3;
   - distance D 1–2 km.

   `default` (width ≥ 1.5 m, ≤ 5.49 %) is outside the region in all 15 readings: on the main one, 188 deviance above
   the best (SE 79) on held-out groups. So is `default`'s MAD form (0.28 m³/s, 5.49 %, no exception), at 131 (SE 59).
   No rule without the exception is in any reading's region. On the main reading no width rule is either; one
   reading (link-placed visits on FWA gradients) has 2 width rules among the 87 in its region.

   **Two rules are inside the region of all 15 readings:** MAD ≥ 0.5 m³/s, Q 3 m³/s within 1,000 m, at a gradient of
   7 % or 9 %. On the main reading they are 4.1 (SE 17.0) and 2.8 (SE 18.2) above the best. The recommended rule is
   inside 13 regions. It is outside the region of both readings on the visits placed on link's segments (2,825
   modelled visits in 16 WSGs). There, on link's segment gradient MAD ≥ 0.75 is in the region only at 9 %, and on the
   FWA gradient only at 5.49 % and 7 %.
2. **The tuned rule is narrower than `default`, not wider.** On the 3,433 modelled visits it admits 730 against
   1,788 and takes in 128 CH against 130 (raw rates 17.5 % against 7.3 %). On link's segments in the 31 groups,
   CH rearing falls from 31,948 to 26,092 km (−18 %).
   - 8,756 km are lost. 8,660 km of that is streams that pass the 1.5 m width but carry under 0.75 m³/s with no
     ≥ 3 m³/s river within 1 km, and 98 % is on order 2 and above.
   - 2,900 km are gained. 2,471 km of that comes through the exception. 69 % of the gain (77 % of the exception's)
     is on order-1 streams, which `default`'s stream branch never admits unmeasured.
3. **Neither size nor distance has a threshold in the data.** Detection rises log-linearly with MAD and steadily
   with width, and falls steadily with distance. Each value is the cut that best separates held-out detection, not a
   bend in a curve.
4. **The flow model moves the floor between 0.5 and 0.75 m³/s** (the best rule on routed flow alone has 0.5, on the
   balance alone 0.75, on fwapg's old MAD 0.5). It does not move the exception or the conclusion about `default`.
5. **`default`'s MAD bounds, if a group were moved to `mad`, would drop large rivers.** Under fresh's `mad` model the
   river-polygon branch takes the 0.28–100 m³/s range. On link's segments, 441 of the 699 FDIS CH detections on
   accessible segments (counted before #35) are on segments over 100 m³/s, and they fall outside rearing.

## What `default` does

`default`'s CH rearing comes from `fresh::frs_habitat_predicates()` on link's `configs/default`. A segment rears CH
when it is accessible and any branch holds:

| branch | test |
|---|---|
| stream | edge 1000/1100/2000/2300, `gradient BETWEEN 0 AND 0.0549`, `channel_width BETWEEN 1.5 AND 9999` |
| river | in a river polygon, the same gradient, any non-NULL width |
| wetland | edge 1000/1100/1050/1150 in a wetland ≥ 1 ha |
| lake | lake edges in a lake or man-made waterbody ≥ 100 ha |

Then three passes run:
- the user-habitat overlay sets known reaches;
- `fresh`'s connectivity pass removes rearing clusters with no spawning within 10 km (both directions, bridging
  gradients up to 5 %);
- the lake and wetland rearing buckets must connect to spawning.

`BETWEEN` is inclusive, and a NULL width fails. fwapg models width only where `stream_order > 1`, so `default`'s
stream branch never admits an unmeasured first-order stream. Its wetland and lake branches carry no width test, and
they can. The MAD bounds (0.28–100 m³/s) never act, because all 188 groups size
streams by width. bcfishpass carries the same thresholds; link's `research/default_vs_bcfishpass.md` gives how the
two differ in structure.

## Data and population

0294's FDIS visits (`chinook_stream_size.md`): 21,325 visits, 1,173 with CH, once #35's repeated surveys are dropped.
0295's population (0291's edges, a fished area of 10–10,000 m²) is 19,085 visits, 978 CH. The plan review moved the tuning onto a
narrower population before any fit, for two reasons:
- **The rule only acts on the stream branch.** 3,014 of 0295's visits are in a river polygon or on its edges. They
  hold 702 of the 978 CH, a detection rate of 23.3 %. Every rule keeps a river polygon's size test, so only the gradient maximum can differ
  there. Those visits would set the in-group's rate, and one regulated Nechako survey
  dominates them. So the rule is scored on stream-branch visits: stream edges not in a river polygon, a wetland of at
  least 1 ha, or a lake of at least 100 ha. That is 15,186 visits, 264 CH.
- **link applies the rule behind its access gate.** A rule scored on visits above natural barriers learns barriers.
  0296 tests for a natural CH barrier downstream before observation overrides (GRADIENT ≥ 15 %, FALLS,
  SUBSURFACE_FLOW, USER_DEFINITE). It reads them from `fresh_default.barriers` for 27 of the visits' groups, and from
  link's bcfishpass-bundle schema `fresh` for 24 more: 51 of the 103 groups the visits are in. `fresh_default`
  carries no SUBSURFACE_FLOW rows, so that source is tested only in the 24.
  - Of the stream-branch visits with a known status, 4,777 have such a barrier downstream, and CH were caught on 25
    of them.
  - The tuning population is the 4,516 visits with none.

**Inputs at the visit.**
- **Flow** is wet's `pick`.
- **Gradient** is the FWA segment's.
- **Width** is the one link would read on a stream nobody measured (`cw_deploy`). Stored widths include FDIS field
  measurements of the visit itself: 2,101 of the 4,516. A first-order stream has a width only where someone measured
  it. So where the stored width is a field measurement, 0296 recomputes fwapg's model (Thorley and Irvine 2021b:
  upstream area and precipitation). That model matches the stored MODELLED widths within 5 % on 96.2 % of
  segments. The model width is used where `stream_order > 1`, and NULL otherwise: 224 of the population's visits.
- **The exception distance** is #52's route-measure walk, extended to an array of river sizes and to each flow source
  (`ch_dist_profile.sql`). At 10 m³/s on `pick` it reproduces 0294's walk on all 12,932 starts. The target is the
  first primary-flow segment of flow ≥ Q: side channels and other secondary-flow edges are passed over, as in #52's
  walk, and a lake segment counts, as it would in a link rule. A walk that reaches the sea first fails the exception.

## Method

- **Grid: 2,795 rules.**
  - Size: a MAD floor *m* ∈ {0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1} m³/s with no maximum, or a width floor
    *w* ∈ {1, 1.5, 2, 3, 4} m.
  - Gradient maximum *g* ∈ {3, 4, 5.49, 7, 9} %.
  - Exception: none, or *Q* ∈ {1, 3, 5, 10, 20, 30, 50} m³/s × *D* ∈ {100, 250, 500, 1000, 2000, 5000} m.
- **Model.** Each rule enters 0295's cloglog model (log area, data set, era, WSG) as one in/out term.
- **Score.** Held-out deviance. The WSGs go into 5 folds, stratified by detections. Each held-out WSG refits only its
  own intercept, which costs every rule the same.
- **Region and pick.** The **region** is every rule within one SE of the best; the SE is of the per-WSG
  differences, so the WSG is the unit. The **pick** is the region rule with the fewest departures from `default`,
  ties to the lower score. Each component is also reported as a **profile**: for each value, the best score over
  every other component.
- **Decision rule, fixed before the run.** If `default` is in the region, the data cannot tell the tuned rule from it.
- **Honesty and stability.**
  - Nested selection: the pick is chosen on four folds and scored on the fifth.
  - A WSG bootstrap (200 resamples) of the selection.
  - Four more fold seeds.
- **Curves.** mgcv GAMs with a WSG random effect check whether each threshold sits where the curve bends.

## Results

### `default` is outside the region in every analysis

`default` scores 188.3 deviance above the best rule (SE 78.7). The no-term ("all in") model is 211.9 above the best.

In the region, all 27 rules have the same shape:

| component | values in the region | best-scoring profile value |
|---|---|---|
| size | MAD 0.28–1 m³/s (no width rule) | MAD ≥ 0.75 |
| gradient maximum | 7 or 9 % | 7 % |
| exception river size Q | 1, 3, 5 or 10 m³/s | 3 m³/s |
| exception distance D | 1,000 or 2,000 m | 1,000 m |

Every region rule has the exception. The best rule without one is 105.4 above the best (SE 53.3).

The best width rule (≥ 4 m, 9 %, Q 3 m³/s within 1,000 m) is 61.5 above the best (SE 28.4). `default`'s width floor
with an exception added scores 164–209 above the best (185–194 at its own 5.49 %).

Every rule in the region departs from `default` in all three components. The **recommended rule** is:

> **gradient ≤ 7 %, and either MAD ≥ 0.75 m³/s or a ≥ 3 m³/s river within 1,000 m downstream**.

What the two rules admit on the 3,433 modelled visits (raw rates):

| rule | visits in | CH in | raw rate in | raw rate out |
|---|---:|---:|---:|---:|
| `default` (width ≥ 1.5 m, ≤ 5.49 %) | 1,788 | 130 | 7.3 % | 2.2 % |
| recommended | 730 | 128 | 17.5 % | 1.4 % |

The tuned rule is **narrower** on the stream branch than `default`, not wider. It takes in 128 detections to
`default`'s 130, on 41 % as many visits. The exception does not mainly add streams: it is what lets a stricter size
floor keep the small streams near a river where CH are caught.

`default`'s MAD bounds (0.28–100 m³/s, as in bcfishpass) at its gradient and with no exception score 131.2 above the
best (SE 59.5), outside the region. On this population the 100 m³/s cap cuts nothing, because no tuning visit is
above it, so the grid rule MAD ≥ 0.28, 5.49 %, none is that rule exactly. It admits 737 visits, with 98 CH (13.3 %;
2.5 % outside).

### Component profiles

For each value, the best score over every other component, as deviance above the best rule. Each rule carries its own
SE, so a value's best-scoring rule can fall outside the region while another rule with that value is inside it. The
values with any rule inside are those in the table above.

- **Size.** MAD ≥ 0.75 is best. Then 0.5 at +2.8, 0.35 at +17.9, 1 at +26.1, 0.28 at +26.6 and 0.1 at +76.8. Every
  width floor is out of the region: from +61.5 at 4 m to +174.8 at 1 m.
- **Gradient.** 7 % is best, then 9 % at +2.7. 5.49 % (`default`) is +49.6 (SE 25.5), outside, and 3 % is +111.6.
- **Exception river size.** Q 3 m³/s is best, then 1 m³/s at +13.0, 5 m³/s at +21.8 and 10 m³/s at +25.7. 20–50 m³/s
  are +48 to +52, and none is in the region.
- **Exception distance.** 1,000 m is best, then 2,000 m at +5.4. 500 m is +30.1, 250 m +51.5 and 5,000 m +46.9, all
  outside.

### Stability

- **WSG bootstrap (200 resamples).** The recommended rule's components:
  - size is MAD in 99.5 % of resamples: 0.75 in 57.5 %, 0.5 in 28.5 %, 1 in 7.0 %;
  - gradient is 9 % in 44.5 %, 7 % in 32.0 % and 5.49 % in 23.5 %;
  - Q is 3 m³/s in 77.5 %, 10 in 11.0 % and 1 in 8.0 %;
  - D is 1,000 m in 57.5 % and 2,000 m in 40.0 %.
- **Four more fold seeds.**
  - Two recommend the same rule.
  - One recommends MAD ≥ 0.5, 9 %, Q 3 @ 2,000 m.
  - One recommends MAD ≥ 0.75, 5.49 %, Q 3 @ 2,000 m.
  - `default` is outside the region on every seed.
- **Nested selection.** A pick made on four folds and scored on the fifth gives a held-out deviance of 937.5, against
  1,039.8 for `default` and 1,063.4 for "all in". Each fold's own pick has MAD 0.5–0.75 and Q 3 m³/s.

The gradient is the least settled component: 5.49–9 %. The size floor sits at 0.5–0.75 m³/s, and the exception at
3 m³/s within 1–2 km.

### Curves: no threshold sits at a bend in size

![CH detection curves](fig/chinook_rearing_tuned_curves.png)

On the tuning population:
- **MAD.** Detection rises **log-linearly** in MAD: the smooth has 1.0 effective degrees of freedom, with no bend
  between 0.01 and 50 m³/s. Any MAD floor cuts a steady slope. The grid places it at 0.5–0.75 m³/s because that is
  where in and out separate best on held-out groups, not because the curve changes there.
- **Width.** Detection rises with width (edf 3.3) without levelling off. The steepest part is around 11 m, and 1.5 m
  sits low on the curve: 6 % of its rise over the 5–95 % range of widths.
- **Gradient.** With MAD in the model, gradient adds little (p = 0.46). The grid's preference for 7–9 % over 5.49 %
  is a held-out improvement of about 50 deviance (SE 26). The curve itself does not show a step there.
- **Distance.** The visits failing the 0.75 m³/s floor number 3,523; 72 of them have no ≥ 3 m³/s river before the
  sea and are left out, and the model uses 2,462 in the WSGs with both outcomes. Among them, detection falls
  steadily with distance from 10 m (edf 2.3) and more steeply beyond about 1–2 km. There is no plateau.
  On the log scale, 1,000 m is 19 % of the way down the curve's fall between the 5th and 95th percentiles of
  distance (the log's rise share, 0.81, is measured from the far end). As with size, D is a cut on a slope; the grid
  puts it at 1–2 km.

### link's own gradient

Of the tuning visits, 3,544 are placed on a link segment. The models use 2,825 of them (131 CH, 16 WSGs). The best
rule is MAD ≥ 0.5, 9 %, Q 3 @ 1,000 m with either gradient. The regions differ:
- **link's segment gradient**: 25 rules, all at 7–9 %. That reading's pick is its best rule. The main reading's
  recommended rule is outside this region; here MAD ≥ 0.75 is in the region only at 9 % (+11.5, SE 17.4).
- **FWA gradient**: 87 rules, at 5.49–9 %, with 2 width rules. Its fewest-departures pick is MAD ≥ 0.5, 5.49 %,
  Q 3 @ 1,000 m, 22.5 above the best.

On link's own segments, then, the gradient settles at 7–9 %, and the best rule's floor is 0.5 m³/s. `default` is out of
the region on both.

### Where the flow model moves the answer

Modelled visits where both wet sources exist (3,027, 163 CH; 4,085 tuning visits before the both-outcomes filter):

| flow | best rule (that reading's pick) | `default` above the best |
|---|---|---:|
| `pick` | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m | 200.7 (SE 73.7) |
| routed alone | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m | 204.4 |
| balance alone | MAD ≥ 0.75, 7 %, Q 3 @ 1,000 m | 191.6 |

The main reading's recommended rule is best on the balance alone. It is 0.3 above the best on `pick` and 1.6 above
on routed flow, inside both regions. On fwapg's old MAD (2,695 visits, 112 CH, 18 WSGs, walks on
`pick`), the best rule is MAD ≥ 0.5, 9 %, Q 3 @ 1,000 m, the same as on `pick` for those visits. That region is wider
(62 rules, gradient 5.49–9 %; 6 in/out patterns had a fit that did not converge), and its fewest-departures pick is MAD ≥ 0.5, 5.49 %,
Q 50 @ 2,000 m, 55.8 above the best.

**At the recommended rule**, among the 4,085 tuning-population visits where both sources exist, the visits whose
in/out flips between `pick` and one source alone:
- **Routed.** 55 flip. 50 of them are in hydrologic zone 26, all in `pick`'s 1–3 m³/s class.
- **Balance.** 47 flip, spread over 11 zones at up to 3.6 % of a zone's visits. 32 of them are in `pick`'s 0.5–1 m³/s
  class.

In wet's weakest zones (15, 17, 23, 24) the balance flips 9 of 677 visits in zone 15 and 1 of 28 in zone 17. The
tuning population has no visits in zone 23, and 18 in zone 24 with no flips (`data/ch_rule_flips.csv`).

### Sensitivities

`default` is outside the region in every one. Each sensitivity's own pick:

| sensitivity | modelled visits (CH) | pick |
|---|---|---|
| every stream-branch visit (barrier unknown or blocked kept) | 9,745 (263) | MAD ≥ 0.75, 7 %, Q 3 @ 2,000 m |
| stored width (field measurements kept) | 3,433 (166) | unchanged |
| lake targets out | 3,433 (166) | MAD ≥ 0.75, 9 %, Q 3 @ 1,000 m |
| regulated visits and targets out | 3,353 (147) | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m |
| ambiguous placements out | 3,427 (163) | unchanged |
| CHES and NECR out | 3,267 (154) | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m |
| C: CH among visits that caught any fish | 2,136 (166) | MAD ≥ 0.75, 7 %, Q 3 @ 2,000 m |

## Side by side on link's segments

Three rules on the 31 groups where `fresh_default` classified CH: `default` as it runs (width), `default`'s MAD
bounds as fresh's `mad` model builds them (`default_mad`, on wet's `pick`), and the recommended rule. Each goes
through the same steps, on scratch copies:
- the predicate behind stored access;
- link's CH user-habitat overlay for rearing. Its 24 CH rows with rearing set are in HORS and QUES, none in these
  groups, so here it changes nothing;
- fresh's connectivity pass (`.frs_run_connectivity`, link `default` params at commit 62fae0bb).

Two checks:
- **The SQL `default` predicate equals fresh's own** on all 786,317 segments.
- **Regenerated `default` against the stored flags.** They differ on 4,584 km: 31,948 km regenerated against 27,953
  stored. FRAN (1,018 km, +955 net) and HARR (547 km, +547 net) differ most. The stored flags come from link runs of unknown vintage (no
  `fresh_default.log` rows for these groups), so the comparison below is between rules regenerated alike, never
  against the stored flags.

| | `default` | `default_mad` | tuned |
|---|---:|---:|---:|
| CH rearing km (31 groups) | 31,948 | 21,548 | 26,092 |
| change from `default` | | −32.6 % | −18.3 % |

Across groups the tuned rule's change runs from −42.6 % (NARC) to +13.5 % (UFRA), with a median of −15.0 %; 5 of 31
groups gain. Lake and wetland rearing (4,208 and 7,449 km) are the same under the tuned rule and `default` in every
group.

**What changes, tuned against `default`** (`data/ch_rule_change.csv`). Each reason is read from the predicates'
parts. Where the two predicates agree, the difference came from the connectivity pass, because the overlay has no CH
rearing rows here. The script labels that `connectivity or overlay`.

| | segments | km | of which order 1 | order 2 | order 3 | order 4+ |
|---|---:|---:|---:|---:|---:|---:|
| **lost** | 25,451 | 8,756 | 174 | 2,817 | 3,272 | 2,492 |
| width passes, MAD < 0.75, no river within 1 km | 24,893 | 8,660 | | | | |
| connectivity | 558 | 96 | | | | |
| **gained** | 10,656 | 2,900 | 1,991 | 489 | 177 | 244 |
| the exception (size fails, a ≥ 3 m³/s river within 1 km) | 8,676 | 2,471 | | | | |
| gradient between 5.49 and 7 % | 854 | 211 | | | | |
| connectivity | 419 | 111 | | | | |
| MAD passes where width fails or is NULL | 316 | 77 | | | | |
| other (river-polygon branch, mixed) | 391 | 29 | | | | |

The losses are not headwaters: 98 % are on order 2 and above, streams at least 1.5 m wide whose wet flow
is under 0.75 m³/s. The gains are mostly the small streams the exception admits.

**FDIS detection on each rule's segments** (0298's run of 2026-10-15, on the visits before #35 dropped repeated
surveys). The 4,944 analysed visits on accessible link segments (699 CH), raw:

| rule | visits on rearing | CH rate on rearing | CH rate on accessible non-rearing |
|---|---:|---:|---:|
| `default` | 2,582 | 24.7 % | 2.6 % |
| `default_mad` | 1,324 | 14.0 % | 14.2 % |
| tuned | 1,859 | 34.6 % | 1.8 % |

`default_mad` separates nothing here because of its 100 m³/s cap: 441 of the 699 CH are on segments over 100 m³/s,
196 of them in NECR. Below the cap, its out-rate would be about 2.3 %, on 72 CH among 3,099 visits.

**Outside check: bcfishobs records FDIS does not hold.** In these groups there are:
- 1,344 non-FDIS CH records, 1,215 of them of match type A/B, dated 1964–2007 (78 undated);
- 812 locations once deduplicated per blue line and metre, with spawn-only locations out (no location falls in an
  overlay rearing reach here);
- 326 of those on stream edges, 315 of them on accessible segments.

The lift compares the share of the 315 accessible stream-edge locations on rearing with the share of accessible
stream-edge km that rears. It was fixed before the run, with a 200-resample location bootstrap:

| rule | locations on rearing (of 315) | capture | km share | lift (95 %) | all 812 locations on rearing |
|---|---:|---:|---:|---|---:|
| `default` | 267 | 84.8 % | 30.0 % | 2.82 (2.69–2.95) | 724 |
| `default_mad` | 225 | 71.4 % | 15.7 % | 4.54 (4.28–4.88) | 607 |
| tuned | 241 | 76.5 % | 19.1 % | 4.00 (3.71–4.20) | 698 |

- **Against `default`**, the tuned rule's lift is higher by 1.17 (0.94–1.37). It loses 40 of `default`'s locations
  and gains 14, for 10.9 points less km share.
- **Against `default_mad`**, it is lower by 0.54 (0.30–0.87). It keeps 40 locations `default_mad` misses and misses 24
  it keeps, for 3.4 points more km share.

A presence-only lift tends to favour fewer km: it ranks rules by concentration, not by what they leave out.
The life stage of these records is mostly unrecorded, and only spawn-only locations could be removed.

**Maps.** The groups were chosen by criteria fixed before drawing. The visit shares are over the analysed FDIS
visits on link segments, before #35. Orange is `default` only, green tuned only, blue both.
- **SALR** has the largest share of accessible stream km on order 1–2 (0.85).
- **TWAC** has all of its visits in hydrologic zones 15, 17, 23 or 24. That is 2 visits, so it was picked on a thin
  base. NARC (320 visits, 99.7 % of them in those zones, −42.6 %) and SETN (341, 87.7 %) are far better sampled.
- **LFRA** has the largest share of visits whose 10 m³/s walk reaches the sea (0.21).

![SALR](fig/chinook_rearing_tuned_salr.png)
![TWAC](fig/chinook_rearing_tuned_twac.png)
![LFRA](fig/chinook_rearing_tuned_lfra.png)

Per group, tuned against `default`:
- SALR: −17.1 % (101 km gained, 295 lost);
- TWAC: −28.0 % (13 gained, 81 lost);
- LFRA: −15.0 % (208 gained, 449 lost).

In all three maps the orange (`default` only) is whole tributaries below the 0.75 m³/s floor. In TWAC that is the
eastern sub-basin's network. The green (tuned only) is short reaches on small streams beside a river.

## Limits

- **Juveniles, electrofished, at margins.** FDIS caught 2 CH ≥ 150 mm in the whole export. Spawning is out of
  scope.
- **The score rewards separation, not extent.** Held-out deviance prefers the rule whose in and out differ most in
  detection. It does not weigh the cost of leaving out streams where CH are caught at low rates: 1.4 % of the
  visits the recommended rule leaves out caught CH, against 2.2 % under `default`.
- **The tuning population is small**: 26 WSGs with both outcomes and 166 CH. Barrier status is known in 51 of the
  103 groups (48 of the 97 with stream-branch visits). The all-stream-branch sensitivity (46 WSGs, 263 CH) agrees.
- **No size threshold sits at a bend.** Detection rises steadily with MAD and width, so any floor is a choice of
  where to cut a slope.
- **Distance.** It runs to the river's centreline. The scoring measured it from the visit's own point. On link's
  segments it is measured from the segment's downstream end, which on the 3,544 tuning visits placed on a link
  segment lies a median 0.9 m below the visit, 90 m at the 75th percentile and 332 m at the 90th. The applied rule is
  therefore slightly looser than the scored one. Under 200 m a distance cannot be told from mainstem catches
  snapped to a tributary mouth; no main-reading region rule is that close. The ambiguous-placement
  sensitivity uses #52's flag, which was set at 10 m³/s on visits under 0.5 m³/s.
- **Gradient.** Tuned on FWA segments, while link applies it to its own finer segments. On link's segment gradient
  the region's gradient is 7–9 %, and on FWA gradients for the same visits 5.49–9 %. In link the threshold also applies to river polygons; the scoring did
  not see them, and 0 of 156 river-polygon visits above 5.49 % caught CH.
- **The cluster pass is not in the scoring.** It is in the side by side.
- **The side by side reads wet's `pick` for every rule.** link main still sizes a `mad` group with fwapg's old MAD
  (`fwa_stream_networks_discharge`, bcfishpass's) until link#331. That table covers only part of the province. On it
  the best rule was unchanged (MAD ≥ 0.5, 9 %, Q 3 @ 1,000 m).
- **Outside-check records are presence only**, mostly undated as to life stage. Their lift ranks rules by
  concentration, not by how much habitat they leave out.

## The plain-language account

The province-wide result is told for a reader who has not seen the tuning in the package article
<https://newgraphenvironment.github.io/knowledge/articles/chinook_rearing.html> (#62), built from `inst/vignette-data/` by `data-raw/vignette_chinook.R`: what link draws now, the
rules, the scoring, the region, the pick, the stability checks, the curves and the grade, and what the rule
changes on the ground, with a Bulkley map. link's own account, the rule drawn by link, waits on its configuration
reading the thresholds table (NewGraphEnvironment/link#346).
