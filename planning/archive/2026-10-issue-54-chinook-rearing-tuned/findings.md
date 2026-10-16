# Findings — Tuned Chinook rearing rule: size, gradient and distance to a large river, set beside link's default (#54)

## Issue context

**If done:** a tuned Chinook rearing rule, built on link's `default` bundle and changing only Chinook's rearing size and gradient tests plus a near-a-large-river exception, each value given as the range the data cannot tell apart, scored on held-out watershed groups and against bcfishobs records FDIS does not hold. A research page sets it beside `default` on the same segments (km, maps, detection rates), says where the flow model moves the answer by hydrologic zone, and is written to become a link vignette once the kinks are out. **If never:** Chinook rearing stays width ≥ 1.5 m and gradient ≤ 5.49 %, values copied from bcfishpass and never checked against where Chinook are caught, and #52's 0.5 / 10 m³/s / 500 m stays a hand-picked illustration.

## Problem

#52 (PR #53) found Chinook rarely caught in streams under about 0.5 m³/s unless a ≥ 10 m³/s river is within 500 m downstream (14.5 % of visits against 0.8 %, rate ratio 26.7). Those three numbers were picked by hand. What link runs today:

- **bcfishpass and our `default` carry identical Chinook thresholds**: spawning gradient ≤ 4.49 %, width ≥ 4 m, MAD ≥ 0.46 m³/s; rearing gradient ≤ 5.49 %, width ≥ 1.5 m, MAD 0.28–100 m³/s.
- **The MAD bounds never act.** All 188 groups size streams by channel width (`parameters_habitat_method.csv`, `cw`), in both bundles.
- **`default` and bcfishpass differ for Chinook rearing by structure, not threshold**: +24 % (DEAD) to +184 % (BABL) rearing km in link's four-group comparison, plus lake and wetland hectares, from intermittent streams, wetlands, lakes and river polygons (link `research/default_vs_bcfishpass.md`). Spawning km are identical.

So the comparison is tuned against `default`, two side by side, with bcfishpass a one-line pointer.

The two wet flow sources agree within 2× on 81–88 % of small-stream visits, against the 1.8× between 0.28 and 0.5, so where a size step sits can depend on the flow model. wet's balance is adjusted by the Extended BC Hydrologic Zones and is weakest on small basins, headwaters and the dry interior (zones 15, 17, 23, 24; `research/modelled_discharge.md`).

## Plan

Built on 0294/0295 and `ch_mad_visits.csv`; new `scripts/0296-ch-rule-tune.R` (and a build step if the walks need one).

1. **Walks at several river sizes.** `ch_dist_large.sql` takes the river size as an argument: run *Q* ∈ {1, 3, 5, 10, 20, 30, 50} m³/s on every kept visit under 1 m³/s (15,486), keeping whether each target is a lake or a regulated river.
2. **Attach what link classifies on**: segment gradient and link's modelled channel width from `fresh_default.streams` where the group is covered (56 groups locally), so the tuned rule is tested on the same inputs `default` uses.
3. **Grid of rules**, rearing only: size floor by MAD *m* ∈ {0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1} m³/s, or by width *w* ∈ {1, 1.5, 2, 3, 4} m; gradient maximum ∈ {3, 4, 5.49, 7, 9} %; exception *Q* as above and *D* ∈ {100, 250, 500, 1000, 2000, 5000} m, plus no exception. Each rule enters 0295's cloglog model (area, data set, era, WSG) as one in/out term, scored by held-out deviance with watershed groups held out together in 5 folds. **The optimum is the region within one standard error of the best; the simplest rule in it is reported**, with its stability over 200 bootstrap resamples by stream.
4. **Curves.** A GAM (`mgcv` 1.9.3) of detection on s(log MAD) or s(log width), s(gradient), and on small streams s(log distance) to the tuned *Q*, WSG as a random effect: a check that each threshold sits where the curve bends, not partway up a slope.
5. **Outside check.** Score `default` and the tuned rule against bcfishobs CH records not in FDIS (other methods and years), as share of records falling on rearing segments against rearing km.
6. **Where the flow model matters.** Re-run 3–4 on routed flow alone, the balance alone, and fwapg's old MAD; report how far each optimum moves, and at the chosen rule count visits whose in/out flips between sources by hydrologic zone and MAD class.
7. **Sensitivities**: lake targets out, regulated targets and visits out (Nechako 2010), ambiguous placements out, CHES and NECR out, and C (CH given any fish) in place of U.
8. **Side by side.** Apply the tuned rule to `fresh_default`'s Chinook segments in SQL for the covered groups: rearing km per group under each, segments gained and lost, and maps of two or three groups (one small-stream-heavy, one interior, one coastal). No link change.
9. **Write-up.** `research/chinook_rearing_tuned.md` (provenance line, figures), aggregates in `data/ch_rule_tune.csv`, a `research/README.md` row and run order. Structured to lift into a link vignette; the link issue for a `default_tuned` Chinook rule and the vignette is drafted at the end, not filed.

## Limits stated up front

- **Width is circular in part.** link's modelled channel widths were fitted on the same FDIS field measurements, so a width rule scores optimistically on these sites, and holding out watershed groups does not remove it. Said beside every width result; the outside check (5) is the guard.
- **Distance floor.** An optimum *D* under about 200 m cannot be told from mainstem catches snapped onto a tributary mouth; reported, not recommended.
- **Rearing only.** Electrofishing catches juveniles; spawning's 0.46 m³/s and 4 m are out of scope.
- **The exception is a new rule shape** for link (a downstream walk to a size), not a threshold edit; how link would carry it is the link issue's question.

Depends on PR #53. Relates to #52, #42.

## Plan-mode exploration (2026-10-15)

- **`fresh_default` covers only 27 of the CH-range groups the visits sit in**: 7,917 of 19,077 analysed visits and
  760 of 978 CH. Of those 760, 432 are the 2010 Nechako survey, and 22 of the groups have both outcomes. Fitting the
  grid only there would leave about 330 CH outside NECR for 2,795 rules.
- **link's channel width is province-wide.** `lnk_pipeline_prepare()` joins
  `whse_basemapping.fwa_stream_networks_channel_width` by `linear_feature_id`, so the width default uses can be
  attached to every visit. That table's `FIELD_MEASURMENT` rows (75,736) are the FDIS sites themselves (CLAUDE.md).
  At a visit, then, the width can be **that visit's own measured width**: a sharper form of the issue's
  circularity limit.
- **Gradient differs.** link's segment gradient (over its own break-at-everything segmentation) exists only in
  `fresh_default`. Elsewhere only the FWA segment gradient (`fwa_gradient` in `ch_mad_visits.csv`) is available.
- **Decision (mine, stated here for the gate):** the grid runs on all 0295 MAD-analysis visits (67 groups with
  both outcomes). Width comes from link's province table, and gradient from the FWA segment. The grid is repeated on
  the 27 covered groups with link's segment gradient, and the write-up reports how far the optimum moves.
- `ch_dist_large.sql` already takes `qmin`, and 0294 ran it only below 0.5 m³/s. Walking every kept visit at every Q
  costs about 0.4 min per 13k starts. One walk that returns the first hit for an **array** of Q values also serves
  the side-by-side: about 172k accessible stream-edge CH segments, roughly 5 min per flow source.
- Hydrologic zones are not in fwapg. wet reads them from the BC catalogue zip (`bc_hydrologic_zones.zip`,
  `HYDZN_NO`). We do the same, into a tempfile, with a point-in-polygon on each visit's UTM point.
- `mgcv` 1.9.3 is installed. `lme4` and `glmmTMB` are not, so WSG random effects use `s(wsg, bs = "re")` in mgcv.
- link's CH `rear` rule (`parameters_habitat_rules.yaml`) has branches for stream edges (1000/1100/2000/2300), river
  polygons (R, any width), wetlands and lakes. Only the stream branch's size test, and the gradient test wherever
  `default` applies one, change. The lake and wetland branches depend on spawning, which does not change.
- A visit's CH access is circular in the same way as `access_bt = 2`: link's `barriers_ch_access` drops barriers
  that observations override, and those observations are mostly FDIS. **The rule term is the size, gradient and
  exception test alone. Access is never a covariate.** In the side-by-side, access is `default`'s under both rules.

## Scripts and names (locked before baseline)

- `scripts/sql/ch_dist_profile.sql`: `pg_temp.ch_dist_profile(blk, m, qmins float8[], src text)`. It runs
  `ch_dist_large`'s walk, returns one row per Q for the first hit, and `src` is `pick | pcic_routed | wet_balance`.
  `ch_dist_large.sql` stays untouched for 0294.
- `scripts/0296-ch-rule-build.R`: visits with walks, width, link segment, zone →
  `data/fdis/derived/ch_rule_visits.csv` (private, to S3).
- `scripts/0297-ch-rule-tune.R`: grid, CV, bootstrap, GAM, flow sources, sensitivities, outside check →
  `data/ch_rule_tune.csv` + log.
- `scripts/0298-ch-rule-compare.R`: the tuned rule against `default` on `fresh_default` segments →
  `data/ch_rule_compare.csv`, figures under `research/fig/`.
- `research/chinook_rearing_tuned.md`.

The issue named `0296-ch-rule-tune.R`. The split follows 0294/0295's build/use pair and keeps the side-by-side's
database writes-out-of-R separate from the model.

## Walk profile positive control (2026-10-16)

`ch_dist_profile(blk, m, '{1,10,50}', 'pick')` was run on 0294's 12,932 small-stream starts, on 4 workers in 0.65 min.
At Q = 10 it matches 0294's `ch_dist_large` on all 12,932: status, `large_lfid`, and distance to within 2.9e-11 m.
The distances for Q = 1, 10, 50 are monotone. `none` counts: 602 at Q = 1, 1,305 at Q = 10, 2,019 at Q = 50.

## link's `default` CH rearing is a predicate, then a cluster pass (2026-10-16)

- **The predicate.** `fresh::frs_habitat_predicates()` builds it from link `configs/default` (thresholds plus
  `rules.yaml`):
  - stream edges (1000, 1100, 2000, 2300) with `gradient BETWEEN 0 AND 0.0549` and `channel_width BETWEEN 1.5 AND 9999`;
  - OR a river polygon with the same gradient and `channel_width BETWEEN 0 AND 9999`, which fails a NULL width;
  - OR a wetland ≥ 1 ha on edges 1000/1100/1050/1150;
  - OR a lake or man-made waterbody ≥ 100 ha on lake edges.
  `BETWEEN 0` means a negative FWA gradient fails.
- **The cluster pass.** `lnk_pipeline_connect()` runs `fresh::frs_cluster()` after it. For CH that is
  `cluster_rearing TRUE`, direction `both`, bridge gradient 0.05, bridge distance 10 km, confluence 10 m
  (`parameters_fresh.csv`). A rearing cluster with no spawning connection loses its rearing.
- **No stream-order bypass.** For CH, `rear_stream_order_bypass` is `no`.
- **Mixed versions.** `fresh_default.log` records runs for only 5 of 56 groups, at link 0.44.3–0.63.1. CH is
  classified in 31 groups.
- **Agreement of the predicate alone with stored `rearing`** (accessible segments):
  - predicate true, stored false: 7,795 segments, 2,472 km. Expected from the cluster pass, plus any version drift.
  - stored true, no branch true: 2,664 segments, 210 km. Overlay or drift.
  - both true: 107,646 segments.
- **Consequence.** The side by side regenerates both rules through the same predicate generator and the same
  cluster pass, and reports regenerated `default` against the stored flags per group. Visit-level scoring
  (0297) uses the predicate only. The cluster pass is a stated limit there.
- **MAD-floor rules.** Under fresh's `mad` model the river-polygon branch drops its width test and inherits the MAD
  range. The tuned rule puts its MAD floor on the stream branch only, with no maximum, and keeps `default`'s river
  test (a non-NULL width). Round 1 caught the first version, which had the floor on the river branch too and so
  dropped 7,415 river-polygon lines carrying a tributary's own flow (636 km).

## Results (2026-10-16)

- **0297.** On the main population (3,434 visits, 166 CH, 26 WSGs), the recommended rule is MAD ≥ 0.75, ≤ 7 %,
  Q 3 @ 1,000 m. `default` is +188 (SE 79), outside the region in all 15 analyses. `default`'s MAD form is +131
  (SE 59). The region holds 27 rules: MAD 0.28–1, g 7–9 %, Q 1–10, D 1–2 km, and all of them have the exception.
  Nested selection gives 937.7 against 1,039.8 for `default`. The MAD and width smooths are log-linear, with no bend.
  The re-run is byte-identical for `ch_rule_tune.csv` and `ch_rule_flips.csv`.
- **0298** (final, after code-check rounds 1–2). The SQL `default` equals fresh's predicate on 786,317 segments.
  Regenerated `default` differs from the stored flags on 4,584 km. CH rearing km: tuned −18.3 % (26,092 against
  31,948), `default_mad` −32.6 %. Outside-check lift on the 315 accessible stream-edge locations: `default` 2.82, `default_mad` 4.54, tuned 4.00.
  - The first runs read −20.2 %, then lifts of 2.97 / 4.75 / 4.36 on all locations, then 2.73 / 4.39 / 3.86 on all
    stream-edge locations. Round 1 and round 2 each corrected one.
  - Round 2's mechanism: a ratio whose numerator and denominator cover different populations. All 22 ratios in 0296,
    0297 and 0298 were enumerated, plus `order12_share`, which wraps a line. The lift was the only mismatch.
    - The rest are unit conversions, change_pct (both rules over the same segments), the FDIS rates (rearing implies
      accessible), the km share, capture, the interior and sea shares (both over the same visits), raw rates in and
      out, the bootstrap shares, the flip shares (per zone over `both`), the rise share, and the width-model agreement
      (over distinct MODELLED segments).
- **The user asked, mid-run, whether the MAD form of `default` (the bcfishpass bounds) was compared.** It was added
  to 0298 as a third rule. Its 100 m³/s cap, inherited by the river branch under the `mad` model, drops 441 of the
  699 FDIS CH on accessible link segments.

## Code-check rounds (2026-10-16)

- **Round 1:** 17 findings, all fixed.
  - The tuned rule's MAD floor sat on river polygons.
  - The draft config did not encode the rule.
  - The lift was taken across edge types.
  - The positive control used `%in%`.
  - Prose numbers.
- **Round 2:** 10 findings, 2 of them inside round-1 fixes: the lift across access, and 702/978 given with the
  23.3 % rate.
- **Round 3** named the mechanism. Each figure comes out of a filter in code, while the prose names its population
  with a noun defined elsewhere, and the two lists are kept equal by hand.
  - It enumerated 140 rows (write-up, draft, CLAUDE.md) and found 8 issues, 6 of them inside earlier fixes.
  - It found that the recommended rule (MAD ≥ 0.75, 7 %) is outside the region of both readings on the 16
    link-placed groups. The two rules inside all 15 regions are MAD ≥ 0.5, Q 3 @ 1,000 m, at 7 or 9 %.
  - The pre-registered pick stays the recommendation. The all-readings rules are reported beside it, and the choice
    for link goes to the user.
- **Round 4:** re-runs the enumeration on round 3's changed lines.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `OGR: Corrupt data` in st_join of hydrologic zones | `st_transform(3005)` of a layer already in BC Albers (WKT) corrupted 7 of 43 features; transform the points to the layer's CRS instead |
| width-model control at 20.4 % agreement (0.01 m tolerance) | stored widths are from older inputs (corr 1.000, ratio 1.007); relative 5 % tolerance gives 96.2 % |
| `cannot insert multiple commands into a prepared statement` | one statement per `dbExecute()` |
| distance curve drawn flat to 1 km | the grid started at x = 0 on a log axis; started at 10 m, and the curve falls steadily (write-up corrected) |
| field-measured widths at visits | an order-1 stream has a width only where measured (fwapg models order > 1); `cw_deploy` is the unmeasured width |
