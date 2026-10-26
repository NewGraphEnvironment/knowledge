# Bull trout rearing and spawning rules tuned on the province-wide run

**Verified:** 2026-10-25 (retuned, graded and compared on the evidence rebuilt on wet's 2026-10-19 flows, with the walk
ending at the river's bank, the gradient ladder to 30 %, the grid's fit with the groups absorbed and a prior on its
data-set and era terms, and the curve's prior, #73; a first #73 reading of 2026-10-23 was scored under the intercept
search #84 replaced; first tuned 2026-10-17, #57; regraded 2026-10-19, #65) · **Issues:** #57, #65, #73 (folding #68,
#80 and #81's run-time pieces; #83 and #84 are its scorer work); builds on #28 (`habitat_weights.md`, the gradient use
curve on link's 55-group build) and #33 (`bt_spawning.md`, spawner evidence by gradient class) · **Produced by:**
`scripts/0310` (evidence build, ledger `scripts/logs/habitat/20261022_evidence_build_ledger.csv`), `scripts/0320`
(`data/tune/BT_{rear,spawn}_*`, log `scripts/logs/habitat/20261024_tune_run.txt`), `scripts/0330`
(`data/compare/BT_{rear,spawn}_*`, log `scripts/logs/habitat/20261024_compare.txt`), `data/literature_evidence.csv` and
`data/ip_model_registry.csv` (rows cited), and the visit tables in `data/fdis/derived/` (the descriptive counts below) ·
**Status:** measured; nothing applied in link (`data/thresholds.csv` carries these rules as `BT_rear_v1` and
`BT_spawn_v1` since `0325`'s run of 2026-10-25). The method and the cross-species table are `habitat_thresholds_tuned.md`.

## In plain words

**What link does now.** `default` calls a stream segment bull trout rearing habitat when it is at least 1.5 m wide and
no steeper than 10.49 %, and spawning habitat when it is at least 2 m wide and no steeper than 5.49 %. **What was
asked.** Of every version of each test on a ladder of width floors, flow floors, gradient limits and an allowance for a
river close downstream (8,385 rearing rules, 7,095 spawning rules), which best predicts where juvenile bull trout were
caught, and where a caught bull trout carried spawner evidence, in watershed groups held out of the fit? **How it was
judged.** Each rule is scored by *held-out deviance*: how badly the fitted model predicts the outcome at visits in groups
it never saw, lower being better, with the model that uses no rule at all as the floor to beat. A rule has to earn its
place on groups it has not seen, because a rule can always be bent to the visits it was drawn from.

**Rearing: what was chosen.** A mean annual discharge of at least 0.35 m³/s and a gradient limit of 25 %, with no
near-river exception. Two departures from `default`: the size test moves from width to flow and asks for a larger
stream, and the gradient limit more than doubles. **Why.** The visits `default` admits and the tuned rule refuses (1.5 m
or wider, 10.49 % or less, under 0.35 m³/s: 3,163) caught bull trout on 10.7 %, and the visits the tuned rule admits
and `default` refuses (0.35 m³/s or more and either steeper than 10.49 % or narrower than 1.5 m: 259) on 31.3 %,
against 13.7 % over all 8,717 modelled visits.

| | `default` | tuned rule |
|---|---|---|
| rule | width ≥ 1.5 m, gradient ≤ 10.49 % | MAD ≥ 0.35 m³/s, gradient ≤ 25 %, no exception |
| held-out deviance (no rule: 6,031.2) | 5,930.9 | 5,704.5 |
| bull trout caught on the visits it admits, against the rest | 17.0 % against 8.5 % | 26.6 % against 8.7 % |
| km of rearing on link's 158 groups (free pass on through-wetland lines, door) | 244,328 | 158,584, 142,015 |
| FDIS visits on its segments, against accessible segments outside (door) | 16.7 % against 6.2 % | 21.4 % against 7.5 % |
| bcfishobs records, outside lift (door) | 2.45 | 5.42 |

The pick is the best rule the grid holds. Its flow floor is a value in a flat stretch (0.1 to 0.5 m³/s within 6
deviance) and its gradient limit sits one rung below the ladder's end (25 and 30 % within 1.0), so the data say that a
width floor costs more than a flow floor and that a limit near 10.49 % costs, and do not say where in those stretches
the values belong (checks, below).

**Spawning: what was chosen.** Width of at least 2 m, `default`'s own, and a gradient limit of 13 %: one departure.
**Why, and why to read it as weak.** The 110 visits the tuned rule adds (2 m or wider, 5.49 to 13 %) carried spawner
evidence on 24.5 %, against 17.7 % on the 265 visits `default` admits; but the 100 visits both rules refuse carried it on
24.0 %, so in raw terms neither rule separates the visits with evidence from the rest. The model prefers the tuned rule
because it holds the watershed group, the data set and the era fixed, and that preference is 4.3 deviance on 98
detections. A rule whose admitted visits carry evidence at a lower rate than the visits it refuses is not a rule the
records have found; it is the least-bad cut on a ladder that has to return one.

| | `default` | tuned rule |
|---|---|---|
| rule | width ≥ 2 m, gradient ≤ 5.49 % | width ≥ 2 m, gradient ≤ 13 %, no exception |
| held-out deviance (no rule: 401.4) | 405.5 | 401.3 |
| spawner evidence on the visits it admits, against the rest | 17.7 % against 24.3 % | 19.7 % against 24.0 % |
| km of spawning on link's 158 groups (one structure) | 133,382 | 169,416 |
| bcfishobs records, outside lift | 3.04 | 3.03 |

## What to expect of bull trout

**Rearing.** Juvenile bull trout rear in small, often steep streams for two years or more before any move to larger water
(McPhail & Baxter 1996, `data/literature_evidence.csv` row 109), and resident forms hold streams "smaller and [with]
higher gradients than those occupied by adfluvial and fluvial" fish (row 100). The models that size their streams
disagree on where the floor sits: Isaak et al. (2015) trim reaches with summer flows under 0.0057 m³/s, about a 1 m
wetted width (row 122), and slopes over 15 %, which held under 1 % of occurrences (row 95), with slope a negative effect
inside those bounds (row 97); Dunham & Chandler (2001) found occurrence rising with width and note the belief that bull
trout "select larger habitats (e.g., > 2 m in width)" (rows 105–106); Porter et al. (2008) key the Thompson HSI on
bankfull width, low under 3.05 m and high over 3.35 m (rows 108, 474), use gradient only at the margin (row 101) and
report the highest catch per unit effort "in higher gradient streams" (row 102). The field accounts put rearing on
gradients well past link's `default` limit of 10.49 %: Bustard & Schell (2002) found juveniles rearing at 1–14.5 % in
the Morice (row 190), Trotter's (2000) last-fish reaches ran 7.5–22.5 % and Watson & Hillman's survey found bull trout to
23 % (rows 98–99), while the Wigwam rearing reaches were 0.4 and 2.8 % (rows 103–104). Rieman & McIntyre (1993) place
rearing in order 2–4 streams (rows 110–111); the 2023 provincial management plan uses order ≤ 3 (row 112). The
expectation, then, is split on size (Isaak's floor far below `default`'s 1.5 m, Dunham & Chandler's 2 m and Porter's
3 m above it), and firm on gradient: a limit above 10.49 %, and use that declines slowly with gradient rather than
stopping. #28's reading of link's 55-group build (`habitat_weights.md`) was that most of the fall in use with gradient is
in whether fish are found at all, not in how often bull trout are among them.

**Spawning.** The reach studies put spawning on low gradients and moderate streams: 0.6–1.0 % in the Wigwam (row 85),
1.3–4.9 % section averages in the Duncan (rows 80–84), 1–4 % in the Morice (row 188), 1–1.5 % in Gill (2006, row 74),
≤ 1 % in Ford et al.'s (1995) review (row 72); none gives a limit (rows 70–71). On size, Hagen et al. (2015, 2020) use a
2 m wetted width as the spawning floor (rows 86, 496), Bustard & Schell's Morice spawning streams were ≥ 7 m (row 189),
and stream order runs from Trotter's 1–2 (row 94) through the management plan's ≤ 3 (row 93) and Hagen's ≥ 3 (rows 91–92)
to 5–6 in the Duncan and Elk (rows 89–90). The expectation is a low gradient limit and a size floor near 2 m. The evidence
below cannot test it: it is spawner codes on electrofishing catch, and #33 showed the within-group rate does not fall with
gradient in a way that catch can show.

## Rearing

### Evidence

11,015 stream-branch electrofishing visits (1,199 with bull trout) in 122 groups in link's bull trout range with no
natural barrier downstream; 8,717 of them (1,198 detections), in the 75 groups where bull trout were both caught and
missed, are modelled, every one with a flow and a gradient (1,643, 18.8 %, have no width). Half the modelled visits are
on streams under 0.08 m³/s and a quarter under 0.02. Detection rises with stream size the whole way to 3 m³/s (4.9 % of
2,329 visits under 0.021 m³/s, 6.9 % at 0.021–0.043, 9.8 % at 0.043–0.1, 14.1 % at 0.1–0.2, 15.3 % at 0.2–0.35, 20.6 %
at 0.35–0.5, 22.7 % at 0.5–1, 32.1 % of 970 at 1–3, 26.9 % at 3–10, 1 of 40 at 10 or more) and barely moves with
gradient: on the FWA gradient the rules read, 13.7 % of the 4,688 visits below 5.49 %, 16.0 % at 5.49–7 %, 14.8 % at
7–9 %, 15.3 % of 510 at 9–10.49 %, 13.1 % of 616 at 10.49–13 %, 6.1 % of 294 at 13–15 %, 13.8 % of 426 at 15–20 %,
15.1 % of 232 at 20–25 %, 10.9 % of 128 at 25–30 % and 8.3 % of the 156 steeper. These raw rates mix size and gradient
(steep streams are small), so the tuning, which holds the data set, era and group fixed, is what separates them.

### Recommended rule: MAD ≥ 0.35 m³/s, gradient ≤ 25 %, no exception

Two departures from `default` (the size test moves from a 1.5 m width floor to a flow floor of 0.35 m³/s, and the
gradient limit from 10.49 to 25 %), and the same two from link's flow start (MAD ≥ 0.021 m³/s at 10.49 %, which is 192.3
behind the best, SE 110.1, outside the region). It is the best rule in the grid (held-out deviance 5,704.5 against 6,031.2
for no rule), so the pick, the recommendation from either start and the best are one rule. The pick is the rule with the
fewest departures inside one SE of the best; here no rule with one departure is inside, so the best is the pick. Bull
trout are caught on 26.6 % of the visits the rule admits (656 of 2,468) against 8.7 % outside (542 of 6,249); `default`
17.0 % (915 of 5,372) against 8.5 % (283 of 3,345).

**The region** (every rule within one SE of the best, a rule of thumb fixed before the run, not a boundary of noise)
holds 316 rules: MAD floors 0.043–0.5 m³/s (304) and a 3 m width floor (12); every gradient limit from 11 to 30 %; 291
with an exception (every Q from 1 to 50 m³/s and every D from 100 to 5,000 m on the ladder, because an exception admits
little a floor this low refuses) and 25 without; every one with two or three departures from `default`. **`default` is
outside it**, 226.4 behind (SE 111.7, 2.03 SEs), outside on all four extra fold seeds too, and outside the 1.96 SE
region (3,312 of the 8,385 rules). link's `default_tuned` floor (MAD ≥ 0.043 m³/s at 13.49 %, link#331) is outside the one-SE
region, 120.0 behind (SE 109.9, 1.09 SEs), and inside at 1.96, with 19.4 % against 7.0 %. The 2026-10-23 reading's pick,
MAD ≥ 0.1 m³/s at 10.49 %, is outside too: 93.3 behind (SE 88.4), with 22.0 % against 8.4 %.

**The 1.96 SE reading** (#79): from the width start the pick is MAD ≥ 0.35 m³/s at 10.49 %, one departure (the size
test; 93.2 behind, SE 55.5); from the flow start it is the flow start's own rule, MAD ≥ 0.021 m³/s at 10.49 % (192.3
behind, SE 110.1, 1.75 SEs). At the stricter bar the size test still leaves width, and the gradient limit cannot be told
from `default`'s.

**What the checks say** (each listed with its direction, and what it counts):
- *Nested selection* (the pick chosen on four folds, scored on the fifth): 5,778.9 against `default`'s 5,930.9 and
  6,031.2 for no rule. Its fold picks are MAD ≥ 0.35 at 25 % (this rule), 0.1 at 10.49 % (the 2026-10-23 pick), 0.1 at
  25 %, 0.5 at 25 % and 0.15 at 25 %: four of five at 25 %, floors from 0.1 to 0.5. It beats `default` on four folds (by
  84.3, 46.3, 19.1 and 2.9) and loses on one by 0.6. For a flow floor and a 25 % limit; the floor's value is not fixed.
- *Four more fold seeds* (exact rule): one recommends this exact rule, one MAD ≥ 0.1 at 25 % and two the 2026-10-23
  pick, MAD ≥ 0.1 at 10.49 %; the best rule on the four seeds is MAD ≥ 0.1 at 25 %, 0.5 at 25 %, 0.5 at 30 % with a
  50 m³/s river within 100 m, and this rule. `default` is outside the region on all four; this rule is inside on all four
  (regions of 167, 434, 609 and 312 rules). For a flow floor; on the limit, the recommendation splits two to two between
  25 and 10.49 % while the best is at 25 % or above on every seed.
- *Group bootstrap* (200 resamples, width start | flow start; the share recommending any rule at the value, except the
  last): a MAD floor in 99 | 99 %; 0.1 m³/s in 39 | 38.5 %, 0.5 in 20.5 | 20.5 %, 0.35 in 16.5 | 16 %, 0.15 in 13 | 12.5 %,
  0.043 in 5 | 4 %, 0.2 in 4.5 | 4.5 %; a limit of 25 % in 57.5 | 57 %, 10.49 % in 21 | 20.5 %, 30 % in 16 | 16 %, 11 %
  in 2 | 2 %, 20 % in 1.5 | 3 %; no exception in 98 | 98 %. The exact rule in 13 | 12.5 % of resamples and inside the
  region in 60.5 %. For a flow floor and against an exception; the floor spreads from 0.1 to 0.5; the limit is 25 % in a
  majority and `default`'s 10.49 % in a fifth.
- *Profiles* (best rule at each value, as deviance behind the best, SE): size 0.35 m³/s best, 0.5 +2.0 (28.1), 0.1 +5.7
  (78.7), 0.15 +5.7 (57.7), 0.2 +14.7 (49.4), 0.28 +33.3 (24.4), width 3 m +60.2 (77.0), 4 m +60.2 (55.4), 0.75 +76.5
  (52.2), 0.043 +85.1 (104.8), 1 +91.7 (62.3), 0.021 +165.9 (112.6), width 2 m +171.0 (103.0), 1.5 m +224.2 (113.8), 1 m
  +227.2 (112.3). Gradient 25 % best, 30 % +1.0 (0.9), 20 % +37.3 (35.5), 13 % +49.9 (84.6), 13.49 % +52.4 (40.1), 15 %
  +53.7 (39.1), 11 % +83.1 (89.1), 10.49 % +93.2 (55.5), 9 % +128.7 (83.6), 7 % +195.3 (69.8), 3 % +234.9 (76.0), 5.49 %
  +252.5 (97.7), 4 % +274.7 (90.3). Exceptions: none best, then a 50 m³/s river within 100 m +2.1 (26.8); the best rule at
  each river size is within 46 and at each distance within 73 (5,000 m). For a floor between 0.1 and 0.5 m³/s and against every width floor under 3 m; for a limit of 20 % or more
  over 10.49 % (1.7 SEs).
- *The ladder's edge.* The two top rungs are within 1.0 of each other (SE 0.9); 283 of the 8,717 visits (3.2 %) are
  steeper than 25 % and bull trout were caught on 26 of them (9.2 %), 156 are steeper than 30 %. Against reading 25 % as a
  placed limit: the data say a limit below about 20 % costs, not where the limit is.
- *The joint curve* (size × distance to a 10 m³/s river, gradient; edf 18.8, 4.2, group effect 60.8) scores 5,618.4
  held-out, 86.1 below the grid's best and 407.9 below no rule scored on the curve's own 8,710 visits (6,026.3; the grid's
  no-rule score, 6,031.2, is over all 8,717): the surface carries more than any cut. Its size term rises
  through the whole range (relative rate 0.19 at 0.021 m³/s, 0.28 at 0.043, 0.53 at 0.1, 1.0 at the 0.35 floor, 1.12 at
  0.5, 1.29 at 1, a peak of 1.36 near 2.3, 1.19 at 10 and 0.70 at 85 m³/s, with a wide interval). Its gradient term is
  fitted on gradient clamped at 20 % (`knw_tune_curve()`): a rate of 0.093 at 0 %, 0.154 at 3 %, 0.190 at 5.5 %, a first
  peak of 0.228 near 10.4 %, 0.191 at 15 % and 0.329 at the clamp, where every steeper visit is read, so it says nothing
  above 20 % and its rise at the edge is the clamp's pile-up, not a trend. For reading the grade as a surface; silent on
  the 25 % limit.
- *The pick moved.* The 2026-10-23 reading of this grid chose MAD ≥ 0.1 m³/s at 10.49 % as the one-departure rule
  inside a region of 594 rules, under the scorer's old intercept search (#84: a held-out group's intercept stopped on the
  clamp's plateau, and every rule was scored on that noise). With the search fixed, the fit with the groups absorbed
  (#83) and the prior on the data-set and era terms, the region holds 316 rules and no one-departure rule is inside it,
  so the best rule is the pick. The evidence did not change; the scorer did, and the earlier reading's 594-rule region
  was the defect's width, not the data's.

### What it is not

- **Not a gradient limit of 25 %.** Detection is as high at 15–25 % as at 5 %; the best rule, nested selection's folds,
  the bootstrap's majority and the best rule on every extra seed put the limit at 25 % or above, and the region reaches
  30 %, the top of the ladder. Trotter's 22.5 % and Watson & Hillman's 23 % are the field limits on record (rows 98–99).
  link's access gate is a separate rule and is not tested here.
- **Not a lower bound on bull trout streams.** The 6,242 modelled visits under 0.35 m³/s caught bull trout on 8.7 %
  (542), and the 3,384 under 0.043 m³/s on 5.5 % (187). 0.35 m³/s is where a yes-or-no test best separates held-out
  detection, and the profile is within 6 deviance from 0.1 to 0.5.
- **Not a verdict on the streams `default` admits and this rule refuses.** Those 3,163 visits (1.5 m or wider, under
  0.35 m³/s, 10.49 % or less) caught bull trout on 10.7 %: 7.1 % at 1.5–2 m, 8.3 % at 2–3 m, 14.8 % at 3–5 m and 10.2 %
  at 5–10 m. They hold fish at a rate below the population's 13.7 %, not none.
- **Not evidence for or against an exception.** 291 of the region's 316 rules carry one because it changes almost
  nothing beside a 0.35 floor (the best rule with an exception is 2.1 behind the best without); the bootstrap drops it in
  98 % of resamples, and the distance curve is not monotone (relative rate 1.14 on the river's own line, 1.00 at 500 m,
  1.09 at 2 km, 1.31 at 30 km, 1.15 at the 50 km cap).
- **Not a change to river polygons, wetlands or lakes**, which keep `default`'s tests under every rule.
- **A rate per standard electrofishing visit, not capacity or density.**

### Grade (`knowledge/habitat_grade/v1`; `scripts/0320`, 2026-10-24)

The grade is the curve's predicted rate at the reference nuisance values and a segment's own distance to a 10 m³/s
river, over the rate at the 95th percentile of accessible stream-branch segments, capped at 1 and read in fifths. It is
a ranking of where an electrofishing visit is more likely to catch bull trout, not a density. Graded because the curve
earns it: 5,618.4 held-out against 6,026.3 for no rule on the curve's own visits (a curve that predicted unseen groups
worse than one constant rate could not rank segments, and the four keys where that happened, bull trout spawning among
them, get no grade).

Every accessible segment of the 158 groups is walked from its downstream end to the first ≥ 10 m³/s river, ending at a
double-line river's bank (#73), and read on the flows wet republished on 2026-10-19 (the table records the load). 8.41 M
segments, 2.68 M accessible, 2.66 M graded (33,992 with no flow even from a parent); reference rate 0.221 over edge types
1000, 1100, 2000 and 2300 (#65: 0.226). Of 576,908 accessible km, 571,305 are graded and sum to 146,894 grade-weighted km
(#65: 151,418, to the centreline); 64 % of graded km lies under 0.2 (364,967 km) and 10 % at 0.8–1 (55,462). 53,897 km
read a distance of 0 (40,327 of them river-polygon lines), where the curve is an extrapolation
(`habitat_thresholds_tuned.md`, Limits); 120,636 of the 2,647,784 segments whose walk found a river (30,841 km) found it
in another watershed group, and 33,782 found none within the cap. The curve's prior (sd 2.5) is recorded on the table; it
moved this curve by 0.1 (5,618.5 to 5,618.4), so the grade is the 2026-10-23 one to the kilometre.

## Spawning

### Evidence

552 stream-branch visits in 50 groups caught bull trout that #33's rule could code for spawner evidence (a mature code in
September or October, or in August, or an adult-sized fish without a code in August to October, `knw_spawner_evidence()`;
101 with evidence); 475 of them (98 with evidence), in the 22 groups with both outcomes, are modelled (450 carry a width
and a gradient; 25 have no width). Most were fished in July, August and September (65, 197 and 170), 18 in October. The
spawner-evidence rate rises with gradient on the FWA gradient the rules read, 14.6 % of 192 visits below 3 %, 22.7 % of
97 at 3–5.49 %, 25.4 % of 118 at 5.49–10.49 %, 3 of the 18 at 10.49–13 % and 15 of the 50 steeper, as #33 found on
link's 55-group build, where the rise was between groups and vanished with a group term. On width it has no trend: 6 of
the 42 visits under 2 m, 10.5 % of 57 at 2–3 m, 27.8 % of 90 at 3–5 m, 26.1 % of 115 at 5–10 m and 17.1 % of 146 at
10 m or more.

### Recommended rule: width ≥ 2 m, gradient ≤ 13 %, no exception

One departure from `default` (width ≥ 2 m at 5.49 %): the gradient limit; two from link's flow start (MAD ≥ 0.041 m³/s
at 5.49 %), whose own pick is MAD ≥ 0.041 at 13 % (5.0 behind, SE 5.2). It sits 5.9 deviance behind the best rule
(width ≥ 2 m, gradient ≤ 30 %, a ≥ 1 m³/s river within 500 m; held-out deviance 395.4 against 401.4 for no rule) with an
SE of 5.9, inside a region of 333 rules: width floors 1.5–3 m (125) and MAD floors 0.041–1 m³/s (208), every gradient
limit from 11 to 30 %, 325 with an exception. It is the one rule in the region with a single departure, which is why
it is the pick. Spawner evidence sits on 19.7 % of the visits it admits (74 of 375) and 24.0 % of those it leaves out (24
of 100); `default` 17.7 % (47 of 265) against 24.3 % (51 of 210). **`default` is outside the region** (10.1 behind, SE
5.7, 1.77 SEs) on the main seed and on all four extra fold seeds, and scores behind no rule at all (405.5 against
401.4); it is inside the 1.96 SE region (5,774 of the 7,095 rules), so the 1.96 SE pick is `default` itself from the width start and `default`'s
flow form from the flow start. link's `default_tuned` floor (MAD ≥ 0.043 m³/s at 5.49 %) is outside, 13.1 behind (SE
6.8), and behind no rule too (408.5).

**Read this row as weak, as #57's was.** The checks, each with its direction:
- *Nested selection*: 404.0 against `default`'s 405.5 and 401.4 for no rule, so behind no rule. Its folds pick width
  ≥ 2 m at 30 % four times (no exception once, a 1 m³/s river within 250 m once and within 2,000 m twice) and this rule
  once; it beats `default` on two folds (by 3.1 and 5.1) and loses on three (by 5.5, 0.5 and 0.7), and is behind no rule
  on three of five. For a 2 m width on every fold; against the rule as a gain over no rule.
- *Four more fold seeds*: the best rule on all four is width ≥ 2 m at 30 % with a 1 m³/s river within 2,000 m; the
  recommendation is that rule on one seed and this exact rule on three. `default` is outside the region on all four.
  For the width and against 5.49 %; the limit's value splits between 13 and 30 %.
- *Group bootstrap* (width start | flow start): width as the size variable in 85 | 52 %, a 2 m floor in 82.5 | 32 %, a
  MAD floor in 15 | 48 % (0.041 m³/s in 0 | 15.5 %); a limit of 30 % in 64 | 40.5 %, 13 % in 20.5 | 35 %, 25 % in
  5 | 14.5 %, 20 % in 7.5 | 2 %, 5.49 % in 1.5 | 3 %; a 1 m³/s exception in 53 | 36.5 %, none in 34.5 | 49.5 %. The exact
  rule in 3 | 0.5 % and inside the region in 8 %. For a 2 m width from the width start, which the flow start does not
  share; for a limit of 13 % or more; the exception splits.
- *Profiles*: flat. Every size floor is within 7.2 of the best on SEs of 3 to 8 (width 2 m best, MAD 1 +2.6 (6.3), 0.35
  +2.6 (6.8), width 3 m +3.0 (5.8), 1.5 m +3.6 (3.2), 1 m +6.2 (6.1), 4 m +6.6 (5.9)); every gradient limit from 7 % up is
  within 8 (30 % best, 20 % +2.5 (3.2), 13 % +2.6 (6.3), 25 % +2.8 (3.4), 15 % +3.7 (5.9), 11 % +5.1 (6.4), 9 % +6.1 (5.8),
  7 % +7.9 (5.4), 4 % +8.3 (6.9), 5.49 % +8.9 (6.4), 3 % +10.9 (6.1)); a 1 m³/s exception is best and none +2.6 (2.1).
  Against 5.49 %; for nothing in particular.
- *The joint curve* (width × distance, gradient; edf 3.0, 1.0, group effect 11.1) is flat too: relative rate 0.99 to
  1.01 across widths of 0.7 to 18 m, 0.82 at 0 % rising to 1.10 at 20 % (intervals 0.23–2.8 and 0.28–4.3), 1.02 to 0.97
  across distance. It scores 397.3 held-out, 1.9 behind the best cut (403.7 before the curve took the grid's prior), and
  behind no rule: scored on the curve's own 450 visits (those with a width), no rule is 377.9, so the curve is 19.4
  worse. The grid's no-rule score of 401.4 is over all 475 visits, and the 25 the curve leaves out are what made it
  look 4.2 ahead until the gate was corrected on 2026-10-25 (below). Against the curve as a surface.

Ninety-eight detections in 22 groups do not carry a rule; what they say is that `default`'s 5.49 % limit is the one value
the evidence scores worse than no rule, in the direction #33 reported.

### What it is not

- **Not a spawning gradient limit at 13 %, nor a placed limit at all.** The profile is flat from 7 % up and the best
  rule's limit is 30 %; 13 % is the value the one-departure rule happened to carry inside the region.
- **Not evidence that spawning rises with gradient.** The raw rise is between groups (#33); within groups the curve's
  gradient term rises from 0.82 to 1.10 with intervals of 0.23–2.8 at 0 % and 0.28–4.3 at 20 %.
- **Not a width floor the evidence set.** Every size floor is within 7.2 deviance; 2 m is `default`'s own, kept because
  the pick is the rule with the fewest departures.
- **Not spawning habitat.** The response is spawner codes on electrofishing catch where the fish were caught, not redds;
  the reach studies above are what describes where bull trout spawn.
- **A rate per visit, not a count of spawners.**

### No grade (the gate, corrected 2026-10-25)

A grade is published only where the curve predicts held-out groups better than one constant rate; a curve that does
not could not rank segments either (Al, 2026-10-24). The 2026-10-24 run published this key's grades on a comparison of
unlike populations: the curve, 397.3, is scored over the 450 modelled visits that carry a width, while the no-rule
score it was set against, 401.4, is over all 475, and the 25 visits with no width leave only no rule's side. Scored on
the curve's own visits, no rule is 377.9 and the curve 19.4 behind it (the branch review of 2026-10-25, which found the
mismatch in `knw_tune_run()`; the gate now compares like with like, `null_heldout_curve`, and the same correction
narrows grayling's margin from 84.4 to 19.2 and rainbow's from 3,207.6 to 906.1 without moving their verdicts). Bull
trout spawning therefore joins coho, steelhead and westslope cutthroat with a rule and no grade. The grade of
2026-10-24 (reference rate 0.151, 246,336 grade-weighted km, 52 % of graded km at 0.6–0.8 and 39 % at 0.8–1, a surface
so flat it ordered segments within a narrow band) is withdrawn. The regrade of 2026-10-25 (`0320` on the database's host, every key, 191.1 min) blanked its `rate`, `grade` and
`grade_class` with `grade_withheld = TRUE`, the recompare (`0330 SPECIES=BT`, 143.3 min) reports no graded km for it,
and `0325` leaves it out of `habitat_grade/v1`.

## What each rule changes on link's segments (`scripts/0330`, `data/compare/BT_*`)

The baseline is `default` regenerated through fresh's predicate, the user-habitat overlay and connectivity on link's 158
BT groups (link 0.68.3's `configs/default` at `102762da`; since the `67a410e2` the chinook and coho comparisons read,
`config.yaml` gained only `cabd_additions_barriers`, which link says never moves access), gated on `streams_access`;
through-wetland lines (edge 1050/1150) go through the gradient and size door (link#364). One group, TURN, has no
accessible BT stream under either rule. The run read the archived schema `fresh_default_20261017` on the database's own
host, the two BT keys beside five others in one process (160.0 min for rearing, 130.6 for spawning); the log is
`scripts/logs/habitat/20261024_compare.txt`.

### Rearing

`default` (width ≥ 1.5 m, ≤ 10.49 %) draws 244,328 km, where the stored flags, from the run's older configs and access
column, hold 251,584 (9,243 km differ). The tuned rule is set beside it under two structures; having no exception, it has
no third:

| structure | tuned km | change | lost | gained | of the gain, through-wetland lines | graded km, `default` → tuned |
|---|---|---|---|---|---|---|
| free pass on through-wetland lines (as the rule was scored) | 158,584 | −35.1 % | 94,965 | 9,221 | 5,343 | 101,583 → 76,791 |
| door on through-wetland lines (link's `stream`) | 142,015 | −41.9 % | 106,132 | 3,819 | 43 | 101,583 → 74,218 |

Under the door, 93,550 km are lost where the stream is 1.5 m or wider and under 0.35 m³/s (266,979 segments), 12,130 km
of through-wetland lines that pass `default`'s door and fail the tuned one, and 452 km to connectivity and the overlay;
2,107 km are gained between the two gradient limits (10.49 to 25 %), 1,221 km where the flow passes and the width fails
or is unmeasured, 346 km through connectivity, 102 km on the river-polygon branch or mixed, and 43 km of through-wetland
lines that pass the tuned door and not `default`'s. The gained km are 1,209 km of order 1, 218 of order 2, 1,046 of
order 3 and 1,347 of order 4 or above. The km the rule sheds are the grade's low end: under the door the 0–0.2 class
falls from 88,869 to 46,407 km and the 0.2–0.4 class from 55,862 to 18,502, while the 0.8–1 class rises from 49,466 to
50,485 (the grade is fitted on the same visits, so this is consistency, not a check). Across groups the change runs
from −73.5 % to +3.5 % (REVL), median −42.7 %; of the 157 groups with `default` km, 2 gain (DUNC, REVL) and 155 lose. The
2026-10-23 reading's rule (MAD ≥ 0.1 m³/s at the same 10.49 %) drew 177,669 km under the door (−27.3 %); the move to
0.35 m³/s at 25 % takes a further 35,654 km.

**Checks.** FDIS detection on each rule's segments against accessible segments outside it: `default` 16.7 % against
6.2 % (2,340 of 14,017 visits, 440 of 7,055); the tuned rule 20.7 % against 7.6 % with the free pass (1,866 of 9,033;
914 of 12,039) and 21.4 % against 7.5 % with the door (1,852 of 8,635; 928 of 12,437). These visits are every one the
compare table places on accessible segments, a wider set than the 8,717 the rule was scored on. On the bcfishobs records
FDIS does not hold (presence only, never scored), the share of locations on the rule's segments over the rule's share of
accessible stream-edge km is 2.447 (2.397–2.503) for `default`, 5.409 (5.248–5.565) with the free pass and 5.416
(5.255–5.572) with the door; the door's lift over `default` is 2.969 (2.822–3.102). #57's rule (MAD ≥ 0.35 at 10.49 %)
read 5.21 on #65's run and the 2026-10-23 reading's 3.81: the lift rises as a rule narrows, which is why it reads density
and not extent. **The two structures cannot be told apart by either check**, and the scoring never saw a through-wetland
line (its visits are on edge 1000/1100/2000/2300), so the structure is link's call: `door` is link's `stream` for bull
trout and what the thresholds table records (`0325`, 2026-10-25: `near_river_scope` empty, the rule having no pair).

### Spawning

`default` (width ≥ 2 m, ≤ 5.49 %) draws 133,382 km (the stored flags hold 134,879), and its spawning has no
through-wetland line rule, so the stage has one structure. The tuned rule keeps the size test and raises the gradient
limit to 13 %, so it contains `default`: 169,416 km (+27.0 %), nothing lost, 36,034 km gained, 35,500 of them stream
between 5.49 and 13 % and 534 on the river-polygon branch. The gain is on measured or modelled widths, so it is order 2
and above (382 km order 1, 8,783 order 2, 16,864 order 3, 10,006 order 4 and up). With the grade withheld, the recompare of
2026-10-25 reports no graded km (the withdrawn grade of 2026-10-24 had read 93,333 to 123,687, the gain sitting in its
0.8–1 class). Every group with `default` km gains, from +0.7 % (UBTN) to +70.8 % (PCEA), median +29.5 %.

**Checks.** There is no FDIS check for spawning (electrofishing catch is not spawning evidence). On the bcfishobs
records, the lift is 3.042 (2.927–3.160) for `default` and 3.025 (2.973–3.083) for the tuned rule, a difference of
−0.016 (−0.117 to +0.075): the 36,034 km the rule adds hold BT locations at the same density as `default`'s km. For a
rule the scoring called weak, that is the one independent reading, and it is neutral, neither for nor against the 13 %
limit. #57's rule (MAD ≥ 0.75 at 5.49 % with a river within 2 km) read 3.70 on #65's run.

The floodplain table (`data/compare/floodplain.csv`) and the maps were not redrawn for #73 (`0330 STAGE=maps`); their
bull trout figures are #65's, on the run's own configs. Maps: `research/fig/compare_bt_{rear,spawn}_*.png`.

## What this replaces

#28's candidate weight per gradient class (`data/habitat_weight_bt_rear.csv`) is superseded by the rearing grade: one
surface over size, gradient and distance, graded against the best accessible stream-branch segments, instead of a class
ratio. #28's held-out elevation contrast used link's step-5 split, which one province-wide schema no longer carries;
`habitat_weights.md` keeps those sections as history. #57's rules (MAD ≥ 0.35 at 10.49 %; MAD ≥ 0.75 at 5.49 % with a
3 m³/s river within 2 km) were tuned on the 2026-10-17 flows with the walk to the centreline and the ladder ending at
10.49 %. This file's own first #73 reading (2026-10-23: MAD ≥ 0.1 at 10.49 %; width ≥ 2 m at 13 %) was scored under the
intercept search #84 replaced. This file replaces both: the rearing floor returns to #57's 0.35 m³/s with the limit moved
from 10.49 to 25 %, and the spawning rule is the 2026-10-23 one.
