# Arctic grayling rearing rule tuned on the province-wide run

**Verified:** 2026-10-24 (retuned on the evidence rebuilt on wet's 2026-10-19 flows, with the walk ending at the river's
bank and the gradient ladder to 30 %, #73; first tuned 2026-10-17, #57; regraded 2026-10-19, #65; the one-SE wording
2026-10-20, #79) · **Issues:** #57, #65, #73; link's own GR calibration is NewGraphEnvironment/link#343 ·
**Produced by:** `scripts/0310` (evidence build, ledger `scripts/logs/habitat/20261022_evidence_build_ledger.csv`),
`scripts/0320` (`data/tune/GR_rear_*`, with the curve prior and the grade gate; its log for 2026-10-24 is
`planning/active/scratch/logs/20261024_0320_prior.log`), `scripts/0330` (`data/compare/GR_rear_*`; stdout
`planning/active/scratch/logs/20261024_0330_prior_par.log`) · **Status:** measured; nothing applied in link. The
method and the cross-species table are `habitat_thresholds_tuned.md`; `data/thresholds.csv` row `GR_rear_v1` was
rewritten by `0325`'s run of 2026-10-25, so its region is #73's.

## In plain words

link calls a stream segment rearing habitat for Arctic grayling when it is at least 1.5 m wide and no steeper than
3.49 % (`default`). The question was whether any other test of the same kind, a different width or flow floor, a
different gradient limit, or an exception that admits a narrow stream near a big river, does better at telling the
electrofishing visits that caught grayling from those that did not, **on watershed groups the rule was never fitted
to**. 7,740 such rules were scored that way. None can be shown to beat `default`, so `default` is the
recommendation, and the comparison on link's segments shows no change.

That is a weaker statement than it sounds, and the rest of this file says how weak. "The tuning confirms `default`"
means the data do not contradict it and cannot pick a better rule from the 1,231 that score about as well. It does
not mean 1.5 m and 3.49 % are values the data located.

| | link's `default` today | recommended | change |
|---|---|---|---|
| size test | width ≥ 1.5 m | width ≥ 1.5 m | none |
| gradient limit | ≤ 3.49 % | ≤ 3.49 % | none |
| exception | none | none | none |
| habitat on link's 82 GR groups | 77,740 km | 77,740 km | 0 km gained, 0 lost |
| grayling caught on the rule's segments / outside (FDIS visits) | 15.0 % / 5.0 % | the same | none |

## What to expect of juvenile grayling

The literature in this repo says where young grayling sit in the water, and nothing about stream size or slope.
Young-of-the-year in streams "inhabit shallow pools and side channels with water velocities less than 80 cm/s" and
prefer 0–25 cm/s (`data/literature_evidence.csv` rows 908–909, Stewart et al. 2007, p. 17); Alaskan young-of-the-year
held 15–25 cm/s (row 910); fry in the Sukunka drainage were found in velocities up to 0.80 m/s in side-channel and
mainstem riffles (row 911); fry rear in "semi-deep pools and side channels" of 30–50 cm depth and velocities below
0.8 m/s (row 925, Ford et al. 1995); and the habitat suitability curves for fry run 1.0 from 0 to 0.5 ft/s and fall to
0 at 0.6 ft/s (rows 920–921). The one rearing flow row (998) records a search of the flow collection that found no
grayling rearing flow need. There is no rearing row for gradient, channel width or stream size, and the intrinsic
potential registry (`data/ip_model_registry.csv`) holds no model for grayling.

So no bound is lifted from the literature here. What the rows do support is a kind of water: slow, shallow, in pools
and side channels. A gradient limit and a size test are only proxies for the velocity and depth the model never sees,
so the expectation is a weak one (low-gradient reaches are likelier than steep ones, which the rows do not state), and
the data have to say where a limit sits; the size test has no prior at all.

## Evidence

1,472 stream-branch electrofishing visits (212 with grayling) in the 44 groups in link's GR range with no natural
barrier downstream. Only the 26 groups where grayling were both caught and missed carry information about a rule, so
the model is fitted on their 1,230 visits, which hold all 212 detections (17.2 %). 168 of those visits (13.7 %) have no
width link would see (first-order streams, which fwapg does not model), and 7 of them caught grayling.
These are crude rates, not adjusted for group, but they show what the rules are working with:

- By gradient: grayling were caught on 131 of 533 visits at 2 % or less (24.6 %), 47 of 289 at 2–3.49 % (16.3 %), 26 of
  222 at 3.49–5.49 % (11.7 %), 5 of 134 at 5.49–9 % (3.7 %) and 3 of 52 above 9 % (5.8 %).
- By width, among the 748 visits at 3.49 % or less that have a width: 2 of 25 visits under 1.5 m (8.0 %), 23 of 160 at
  1.5 to under 3 m (14.4 %) and 149 of 563 at 3 m or more (26.5 %).

`default` admits 723 of the 1,230 visits and 172 of the 212 detections: grayling are caught on 23.8 % of the visits it
admits and 7.9 % (40 of 507) of those it does not.

## Recommended rule: `default` (width ≥ 1.5 m, gradient ≤ 3.49 %, no exception)

The score is held-out deviance: the groups are split into five folds, each fold's visits are scored by a model fitted
on the other four, and a lower total means the rule predicted unseen groups better. `default` scores 815.6, the best
rule 804.8 (width ≥ 2 m, gradient ≤ 5.49 %, a 3 m³/s river within 100 m) and no rule at all (one detection rate for
everything) 828.0. So `default` is 12.4 better than no rule and 10.8 behind the best.

Ten units of deviance sounds like something, so it is compared with its own noise. The standard error (SE) is how much
the difference between two rules would move if a different set of groups had been sampled, with the group as the unit.
`default` is 10.8 behind with an SE of 12.0, which is 0.90 SE. A decision rule fixed before the run puts every rule
within one SE of the best into a **region** (rules the data cannot tell apart from the best) and recommends the region
rule with the fewest departures from `default`; here that is `default` itself, with none.

The region holds 1,231 of the 7,740 rules (15.9 %): 35 with no exception and 1,196 with one. It spans every width on
the ladder (1, 1.5, 2, 3 and 4 m), every gradient limit from 3 to 30 %, and no flow (MAD) rule: the 5,160 rules with a
MAD floor are all outside it. At the stricter 1.96 SE bar (#79) it holds 7,337 rules (94.8 %), and the pick is
`default` from the width start and `MAD ≥ 0.021 m³/s, gradient ≤ 3.49 %` (`default` written as a flow test) from the
flow start. The width-start decision is `default`; the flow-start decision at one SE is width ≥ 3 m at 3.49 %, the
nearest region rule to the flow form of `default`.

**What the checks say** (each one, with its direction; a check measures only what its description says):
- *Where `default` sits.* In the region at 0.90 SE; 12.4 better than no rule; 3,971 of the 7,740 rules (51 %) score
  worse than no rule and `default` is not one of them. For `default`, weakly: it is not worse than doing nothing and
  not detectably worse than the best.
- *How wide the region is.* The data accept widths from 1 to 4 m and gradient limits from 3 to 30 % with or without an
  exception. Neither for nor against `default`: it says the 212 detections in 26 groups cannot place either limit.
- *Nested selection* (a pick chosen on four folds and scored on the fifth, which tests the choosing, not any one
  rule): 823.5 against `default`'s 815.6 and 828.0 for no rule. The folds pick width ≥ 1.5 at 3.49 % twice, width ≥ 2
  at 3.49 %, width ≥ 3 at 3.49 % and width ≥ 3 at 7 %; fold 3's pick scores 9.9 worse than `default` on its fold. For
  keeping `default` over choosing again from the grid, which does 8.0 worse than `default` and 4.5 better than nothing.
- *Four more fold seeds.* Two recommend `default` exactly (seeds 55 and 57) and two recommend width ≥ 3 m at 3.49 %
  (56 and 58); `default` is inside the region on the first two and outside it on the other two. Two for, two against.
- *Group bootstrap* (200 resamples of the groups; width start | flow start). The size variable is width in 98.0 | 81.5
  % and a MAD floor in 2.0 | 18.5 %; the width floor is 1.5 m in 35.0 | 3.0 %, 3 m in 31.5 | 36.5 %, 2 m in 14.5 | 21.5
  %; the gradient limit is 3.49 % in 43.5 | 48.0 %, 5.49 % in 28.5 | 24.5 % and 7 % in 10.5 | 10.5 %; there is no
  exception in 91.0 | 91.0 %. The exact rule `default` is the recommendation in 18.5 | 2.5 %. For width over a flow
  floor and for no exception; for 3.49 % as the most common single limit, though under half; the floor of 1.5 m is
  barely ahead of 3 m from the width start and well behind it from the flow start. The exact rule is one of several the
  resamples spread over.
- *Profiles* (the best rule at each value, as deviance behind the best, with its SE). Width: 2 m is best, 3 m +0.8
  (5.9), 1 m +1.6 (8.3), 1.5 m +4.3 (8.8), 4 m +6.5 (11.0). Gradient: 5.49 % is best, then 7 % +0.9, 9 % +1.9, 11 and
  13 % +2.0, 3 % +2.2, 4 % +3.1, 15 % +3.4, 3.49 % +3.5 (7.9), and 20, 25 and 30 % +3.5. Exception: with none +0.9
  (6.0), with a river of 3, 5, 10 or 20 m³/s within 100 or 250 m, 0. Every width and gradient difference is under
  0.6 SE and every value on both ladders has rules in the region, so none is excluded. The profile leans away from
  1.5 m and from 3.49 % (the ninth of twelve limits) toward 2 to 3 m and 5.49 to 7 %, and finds an exception worth
  0.9 deviance, which is nothing.
- *The flow form.* The best MAD rule (MAD ≥ 0.021 m³/s, 5.49 %, a 3 m³/s river within 100 m) is 8.2 behind (SE 5.7,
  1.43 SE); `default` written as a flow test (MAD ≥ 0.021, 3.49 %) is 10.3 behind (SE 7.8) and link's `default_tuned`
  floor for grayling (MAD ≥ 0.97 m³/s at 3.49 %, link#331) is 23.8 behind (SE 16.3, 1.46 SE); all three are outside.
  Against a flow floor, mildly: none of the 5,160 MAD rules is in the region (#57 had 7 of 799).
- *The joint curve* (below) scores 743.6 held out, better than every rule. Against any single cut as the whole
  story; it says nothing about which cut.

## What it is not

- **Not a validation of 1.5 m or 3.49 %.** The region admits every width and gradient limit on the ladder. The
  tuning failed to find a better rule, which is a different statement from finding that this one is right.
- **Not a limit of use at 3.49 %.** Grayling were caught on 34 of 408 visits above it (8.3 %), and the best rule on
  held-out groups tolerates 5.49 %; the gradient curve falls gently with no step (below).
- **Not a flow rule.** No MAD floor reaches the region. link#343's question about MAD minima on wet's discharge is
  answered for this species by the grid preferring width, not by a value.
- **Not a statement about spawning.** Grayling spawning has no electrofishing response, so there is no spawning
  tuning (`GR_spawn`: `no_response`).
- **A rate per standard electrofishing visit, not capacity or density.**

## The curve beats every cut, and what that means for the grades

The grade does not come from a cut. It comes from a smooth curve fitted to the same visits: the chance of catching
grayling as a function of stream width, distance to a 10 m³/s river and gradient, with the group effect left out. Its
held-out deviance, scored on the same folds, is **743.6**: 61.2 better than the best of the 7,740 cuts (804.8) and 20.3
better than no rule scored on the curve's own 1,049 visits (763.9; the grid's no-rule score, 828.0, is over all 1,230,
and the 181 visits with no width the curve leaves out are the difference, which the gate compared across until it
was corrected on 2026-10-25). The curve is fitted with the same prior as the grid (a normal prior, SD 2.5, on the
data-set and era coefficients, #84): without it the curve scored 786.9, and #57's curve, fitted without a prior,
scored 1,022.1 against the grid's 825.3 then (the smoke run's no-prior fit puts 13.96 on the era coefficient, limit
5).

What that means: a cut says habitat is either in or out, and a segment just inside it is treated like one far inside.
Held-out groups are better predicted by a rate that changes by degrees, so every cut, including `default`, throws
away about 61 units of deviance that a graded rate keeps. It does not say which cut is nearest the curve, and the
grades below are rates, not a rule. Because the curve beats no rule, the gate (grades are published only for a key
whose curve scores better than no rule on held-out groups) lets grayling through.

The curve's shape, at the reference values of the other terms (rate per standard visit, relative to the pick's
thresholds; the 95 % bands, which carry the reference's own uncertainty, are wide: those of the width and gradient
curves include 1 everywhere):
- **Width.** 0.031 at 1.5 m, 0.060 at 3 m, a peak of 0.083 at 5.4 m, 0.044 at 20 m and 0.017 at 78 m. The rate nearly
  doubles between the floor and 3 m, which is why the profile and the bootstrap give 3 m a share.
- **Gradient.** A straight line on the model's link scale (edf 1.00): 0.033 at 0 %, 0.029 at 3.49 %, 0.027 at 5.49 %,
  0.017 at 20 %. It roughly halves over the range and has no knee at the limit.
- **Distance to a 10 m³/s river.** The rate rises with distance: 0.0018 at 500 m, 0.0074 at 5 km and 0.031 at
  50 km (its band clears 1 only beyond about 18 km). That is the opposite of what an exception to the size test
  assumes, and agrees with the grid finding no exception worth keeping. The surface (size by distance, edf 6.26,
  group effect 18.74) is fitted to 212 detections, so its shape is not a mechanism, and the direction is not diagnosed
  here.

## Grade (`knowledge/habitat_grade/v1`; `scripts/0320`, 2026-10-24)

Every accessible segment of the 82 groups is walked from its downstream end to the first ≥ 10 m³/s river, ending at a
double-line river's bank (#73), read on the flows wet republished on 2026-10-19, and graded by the curve with its prior
(`curve_prior_sd` 2.5 on the table). 4,214,528 segments; 856,113 accessible (258,576 km); 496,267 graded (146,128 km).
Of the 359,846 accessible segments left ungraded (112,448 km), 359,713 (112,421 km) have no width, and 112,383 km of
that is first-order stream: fwapg models width only where the stream order is above 1. The reference rate, the 95th percentile of the rate on
accessible stream-branch segments (edge types 1000, 1100, 2000 and 2300), is 0.0814 per standard visit, so a grade of
1 means a segment at that rate or better. The grade is relative to a low top: even the best segments are predicted to
catch grayling on about 8 % of standard visits.

The graded kilometres sum to 74,376 grade-weighted km. By class: 32,794 km under 0.2 (22 %), 28,994 at
0.2–0.4 (20 %), 24,962 at 0.4–0.6 (17 %), 21,506 at 0.6–0.8 (15 %) and 37,872 at 0.8–1 (26 %). The classes are
fifths of the grade, not of the kilometres, so an even spread is not expected.

Three things to read against the grade:
- 17,761 km of graded segments read a distance under 1 m to a 10 m³/s river, 13,224 km of them river-polygon lines.
  The curve's range starts at 10 m, where its distance term is 0.13 of its 500 m value, so these grades extrapolate it.
  Among river-polygon lines 13.4 % of the 27,783 graded km reach 0.8, against 27.2 % of the stream branch (98,789 km,
  26,874 km at 0.8–1) and 37.1 % of all other edge types (19,556 km, 7,263 km).
- 33,667 km of graded segments lie 50 km or more from such a river (the farthest is 290.7 km) and a further 2,241 km
  found none; both read the distance term at its 50 km end, where it is highest, because the curve was fitted to
  distances capped at 50 km.
- 3,514 km of graded segments read a river found in another watershed group.

## What the rule changes on link's segments (`scripts/0330`, `data/compare/GR_rear_*`)

The baseline is link's `default`, regenerated through fresh's predicate, the user-habitat overlay and connectivity
on link's 82 GR groups. The tuned rule is `default`, so the comparison table carries one structure (`door`, which is
what link's `stream` does with through-wetland lines) and it gains and loses nothing: 77,740 km of 258,576 accessible km
(30.1 %) under both. The stored flags, from the run's older configs, hold 79,882 km, and 2,142 km differ from the
regeneration (not split by cause here); the access gate differs from the habitat tables' `accessible` on 7,195 km
(link#349). Three groups (BULL, ELKR, TURN) have no segment passing the grayling access gate and draw no habitat; the
other 79 draw from 2.6 to 2,228.8 km.

Graded, the rule's kilometres sum to 45,564 grade-weighted km (#65: 44,602), over 73,582 graded km: 10,269 under 0.2
(14.0 %), 9,123 at 0.2–0.4 (12.4 %), 13,236 at 0.4–0.6 (18.0 %), 12,856 at 0.6–0.8 (17.5 %) and 28,097 at 0.8–1
(38.2 %). The rule holds the highest-graded segments in a larger share than the graded accessible stream as a whole
does (38 % against 26 % at 0.8–1), so the cut and the curve point the same way. 4,158 of the rule's km (77,740 less 73,582) are not graded, and
112,448 accessible km are not graded at all.

**Checks.** FDIS detection on the rule's segments against accessible segments outside it: 326 of 2,167 visits (15.0 %)
against 81 of 1,606 (5.0 %). On the bcfishobs records FDIS does not hold (presence only, never scored), 256 of 310
locations (82.6 %) lie on the rule's segments, which are 23.2 % of accessible stream-edge km, a lift of 3.56 (3.35–3.72).
Both are the same for the tuned rule, so the difference is 0 (0–0). The floodplain table and the maps were not redrawn
for #73 (`0330 STAGE=maps`).
