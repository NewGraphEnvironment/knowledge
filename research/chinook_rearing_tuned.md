# A tuned Chinook rearing rule: stream size, gradient and distance to a river, beside link's `default`

**Verified:** 2026-10-16 · **Issues:** #54 (this); builds on #52 (`chinook_stream_size.md`), which picked 0.5 m³/s, 10 m³/s
and 500 m by hand; uses wet's flow (`modelled_discharge.md`) and the FDIS export (`fdis_export.md`); the link issue for
a tuned rule is drafted, not filed (planning archive for #54) · **Produced by:**
- `scripts/0296-ch-rule-build.R` with `scripts/sql/ch_dist_profile.sql`: walks, widths, barrier status, link segment
  and zone per visit; ledger `scripts/logs/habitat/20261015_ch_rule_build_ledger.csv`;
- `scripts/0297-ch-rule-tune.R`: `data/ch_rule_tune.csv`, `data/ch_rule_curves.csv`, `data/ch_rule_flips.csv`,
  `fig/chinook_rearing_tuned_curves.png`, log `scripts/logs/habitat/20261015_ch_rule_tune.txt`;
- `scripts/0298-ch-rule-compare.R`: `data/ch_rule_compare.csv`, `data/ch_rule_checks.csv`, the maps in `fig/`, log
  `scripts/logs/habitat/20261015_ch_rule_compare.txt`;
- the plan review and its disposition: `planning/archive/2026-10-issue-54-*/review-plan.md`.

**Status:** measured; nothing applied in link. Written to lift into a link vignette (last section).

Every figure names its population. Three recur:
- **Tuning population.** FDIS electrofishing visits on link's CH stream branch, with no natural CH barrier downstream:
  4,516 visits (166 CH) in 45 WSGs. The models use the 26 WSGs where CH were both caught and missed: 3,434 visits,
  166 CH.
- **All stream-branch visits**, barrier status unknown or blocked kept: 15,178 visits (264 CH); 9,742 visits
  (263 CH) in 46 WSGs modelled.
- **Side-by-side groups.** The 31 WSGs where link's `fresh_default` classified CH.

## The question

#52 found CH rarely caught in streams under about 0.5 m³/s unless a ≥ 10 m³/s river is within 500 m downstream.
Those three numbers were picked by hand. Which rearing rule do the visits support, and how far can each value move
before the data can tell the difference?

The rule tuned here is link's `default` CH rearing rule with three things open:
- the stream size test (a MAD floor or a channel-width floor);
- the gradient maximum;
- an exception for small streams within D m downstream of a river of at least Q m³/s.

Nothing else in `default` changes: river polygons, wetlands, lakes, access, the user-habitat overlay, and the cluster
pass that keeps only rearing connected to spawning.

## Short answer

(filled in after the side by side)

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

`BETWEEN` is inclusive, and a NULL width fails. fwapg models width only where `stream_order > 1`, so `default` never
rears CH on an unmeasured first-order stream. The MAD bounds (0.28–100 m³/s) never act, because all 188 groups size
streams by width. bcfishpass carries the same thresholds; link's `research/default_vs_bcfishpass.md` gives how the
two differ in structure.

## Data and population

0294's FDIS visits (`chinook_stream_size.md`): 21,862 visits, 1,186 with CH. 0295's population (0291's edges, a fished
area of 10–10,000 m², #35's duplicates out) is 19,077 visits, 978 CH. The plan review moved the tuning onto a
narrower population before any fit, for two reasons:
- **The rule only acts on the stream branch.** 702 of the 978 CH are on river-polygon edges, where every rule is
  "in". There they would set the in-group's rate, at about 22 % and dominated by one regulated Nechako survey.
  The tuning population is therefore stream edges not in a river polygon, a wetland of at least 1 ha, or a lake of at
  least 100 ha: 15,178 visits, 264 CH.
- **link applies the rule behind its access gate.** A rule scored on visits above natural barriers learns barriers.
  0296 tests for a natural CH barrier downstream before observation overrides (GRADIENT ≥ 15 %, FALLS,
  SUBSURFACE_FLOW, USER_DEFINITE). It reads them from `fresh_default.barriers`, or from link's bcfishpass-bundle
  schema `fresh` where `fresh_default` lacks the group. That covers 51 of the 103 groups the visits are in.
  - Of the stream-branch visits with a known status, 4,774 have such a barrier downstream, and CH were caught on 25
    of them.
  - The tuning population is the 4,516 visits with none.

**Inputs at the visit.**
- **Flow** is wet's `pick`.
- **Gradient** is the FWA segment's.
- **Width** is the one link would read on a stream nobody measured (`cw_deploy`). Stored widths include FDIS field
  measurements of the visit itself: 2,100 of the 4,516. A first-order stream has a width only where someone measured
  it. So where the stored width is a field measurement, 0296 recomputes fwapg's model (Thorley and Irvine 2021b:
  upstream area and precipitation). That model matches the stored MODELLED widths within 5 % on 96.2 % of
  segments. The model width is used where `stream_order > 1`, and NULL otherwise: 223 of the population's visits.
- **The exception distance** is #52's route-measure walk, extended to an array of river sizes and to each flow source
  (`ch_dist_profile.sql`). At 10 m³/s on `pick` it reproduces 0294's walk on all 12,932 starts. The target is the
  first segment of flow ≥ Q of any kind; a lake counts, as it would in a link rule. A walk that reaches the sea first
  fails the exception.

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

`default` scores 188.2 deviance above the best rule (SE 78.7). The no-term ("all in") model is 211.8 above the best.

In the region, all 27 rules have the same shape:

| component | values in the region | best-scoring profile value |
|---|---|---|
| size | MAD 0.28–1 m³/s (no width rule) | MAD ≥ 0.75 |
| gradient maximum | 7 or 9 % | 7 % |
| exception river size Q | 1, 3, 5 or 10 m³/s | 3 m³/s |
| exception distance D | 1,000 or 2,000 m | 1,000 m |

Every region rule has the exception. The best rule without one is 105.2 above the best (SE 53.3).

The best width rule (≥ 4 m, 9 %, Q 3 m³/s within 1,000 m) is 61.5 above the best (SE 28.4). Width at 1.5 m with any
exception is 187–188 above.

Every rule in the region departs from `default` in all three components. The **recommended rule** is:

> **MAD ≥ 0.75 m³/s, gradient ≤ 7 %, or a ≥ 3 m³/s river within 1,000 m downstream.**

What the two rules admit on the 3,434 modelled visits (raw rates):

| rule | visits in | CH in | raw rate in | raw rate out |
|---|---:|---:|---:|---:|
| `default` (width ≥ 1.5 m, ≤ 5.49 %) | 1,788 | 130 | 7.3 % | 2.2 % |
| recommended | 731 | 128 | 17.5 % | 1.4 % |

The tuned rule is **narrower** on the stream branch than `default`, not wider. It takes in 128 detections to
`default`'s 130, on 41 % as many visits. The exception does not mainly add streams: it is what lets a stricter size
floor keep the small streams near a river where CH are caught.

### Component profiles

For each value, the best score over every other component, as deviance above the best rule. Each rule carries its own
SE, so a value's best-scoring rule can fall outside the region while another rule with that value is inside it. The
values with any rule inside are those in the table above.

- **Size.** MAD ≥ 0.75 is best. Then 0.5 at +2.8, 0.35 at +17.9, 1 at +26.1, 0.28 at +26.6 and 0.1 at +76.8. Every
  width floor is out of the region: from +61.5 at 4 m to +174.7 at 1 m.
- **Gradient.** 7 % is best, then 9 % at +2.7. 5.49 % (`default`) is +49.7 (SE 25.5), outside, and 3 % is +111.7.
- **Exception river size.** Q 3 m³/s is best, then 1 m³/s at +13.0, 5 m³/s at +21.8 and 10 m³/s at +25.7. 20–50 m³/s
  are +48 to +52, and none is in the region.
- **Exception distance.** 1,000 m is best, then 2,000 m at +5.4. 500 m is +30.1, 250 m +51.5 and 5,000 m +46.9, all
  outside.

### Stability

- **WSG bootstrap (200 resamples).** The recommended rule's components:
  - size is MAD in 99.5 % of resamples: 0.75 in 57.5 %, 0.5 in 28.5 %, 1 in 7.0 %;
  - gradient is 9 % in 44.5 %, 7 % in 32.0 % and 5.49 % in 23.5 %;
  - Q is 3 m³/s in 77.5 %, 10 in 10.5 % and 1 in 8.0 %;
  - D is 1,000 m in 57.5 % and 2,000 m in 40.0 %.
- **Four more fold seeds.**
  - Two recommend the same rule.
  - One recommends MAD ≥ 0.5, 9 %, Q 3 @ 2,000 m.
  - One recommends MAD ≥ 0.75, 5.49 %, Q 3 @ 2,000 m.
  - `default` is outside the region on every seed.
- **Nested selection.** A pick made on four folds and scored on the fifth gives a held-out deviance of 937.7, against
  1,039.8 for `default` and 1,063.5 for "all in". Each fold's own pick has MAD 0.5–0.75 and Q 3 m³/s.

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
- **Distance.** Among visits failing the 0.75 m³/s floor (3,523; 72 with no ≥ 3 m³/s river before the sea, left
  out), detection is flat out to about a kilometre and falls steeply beyond a few kilometres. 1,000 m sits at 81 %
  of the curve's range, on the shoulder before the fall.

### link's own gradient

On the 2,826 visits placed on a link segment (131 CH, 16 WSGs), the recommended rule is MAD ≥ 0.5, 9 %, Q 3 @ 1,000
m with link's segment gradient, and MAD ≥ 0.5, 5.49 %, Q 3 @ 1,000 m with the FWA gradient. The gradient is where the
segmentation matters. Size and exception do not move. `default` is out of the region on both.

### Where the flow model moves the answer

Visits where both wet sources exist (3,028 visits, 163 CH):

| flow | recommended rule | `default` above the best |
|---|---|---:|
| `pick` | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m | 200.6 (SE 73.7) |
| routed alone | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m | 204.3 |
| balance alone | MAD ≥ 0.75, 7 %, Q 3 @ 1,000 m | 191.5 |

On fwapg's old MAD (2,695 visits, 112 CH), the recommendation is MAD ≥ 0.5, 5.49 %, Q 50 @ 2,000 m, with walks on
`pick`. That is beside MAD ≥ 0.5, 9 %, Q 3 @ 1,000 m on `pick` for the same visits.

**At the recommended rule**, among the 4,085 tuning-population visits where both sources exist, the visits whose
in/out flips between `pick` and one source alone:
- **Routed.** 55 flip. 50 of them are in hydrologic zone 26, all in `pick`'s 1–3 m³/s class.
- **Balance.** 47 flip, spread over 11 zones at up to 3.6 % of a zone's visits. 32 of them are in `pick`'s 0.5–1 m³/s
  class.

In wet's weakest zones (15, 17, 23, 24) the balance flips 9 of 677 visits in zone 15 and 1 of 28 in zone 17. The
tuning population has no visits in zone 23, and 18 in zone 24 with no flips (`data/ch_rule_flips.csv`).

### Sensitivities

`default` is outside the region in every one. The recommended rule:

| sensitivity | modelled visits (CH) | recommended |
|---|---|---|
| every stream-branch visit (barrier unknown or blocked kept) | 9,742 (263) | MAD ≥ 0.75, 7 %, Q 3 @ 2,000 m |
| stored width (field measurements kept) | 3,434 (166) | unchanged |
| lake targets out | 3,434 (166) | MAD ≥ 0.75, 9 %, Q 3 @ 1,000 m |
| regulated visits and targets out | 3,354 (147) | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m |
| ambiguous placements out | 3,428 (163) | unchanged |
| CHES and NECR out | 3,268 (154) | MAD ≥ 0.5, 7 %, Q 3 @ 1,000 m |
| C: CH among visits that caught any fish | 2,137 (166) | MAD ≥ 0.75, 7 %, Q 3 @ 2,000 m |

## Side by side on link's segments

(filled in after 0298)

## Limits

- **Juveniles, electrofished, at margins.** FDIS caught 2 CH ≥ 150 mm in the whole export. Spawning is out of
  scope.
- **The score rewards separation, not extent.** Held-out deviance prefers the rule whose in and out differ most in
  detection. It does not weigh the cost of leaving out streams where CH are caught at low rates: 1.4 % of the
  visits the recommended rule leaves out caught CH, against 2.2 % under `default`.
- **The tuning population is small**: 26 WSGs with both outcomes and 166 CH. Barrier status is known in 51 of 103
  groups. The all-stream-branch sensitivity (46 WSGs, 263 CH) agrees.
- **No size threshold sits at a bend.** Detection rises steadily with MAD and width, so any floor is a choice of
  where to cut a slope.
- **Distance.** It is measured from the segment's downstream end to the river's centreline. Under 200 m it cannot be
  told from mainstem catches snapped to a tributary mouth; no region rule is that close. The ambiguous-placement
  sensitivity uses #52's flag, which was set at 10 m³/s on visits under 0.5 m³/s.
- **Gradient.** Tuned on FWA segments, while link applies it to its own finer segments. On link's segments the
  recommendation moves between 5.49 and 9 %. In link the threshold also applies to river polygons; the scoring did
  not see them, and 0 of 156 river-polygon visits above 5.49 % caught CH.
- **The cluster pass is not in the scoring.** It is in the side by side.

## For a link vignette

(filled in after the side by side)
