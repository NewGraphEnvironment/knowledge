# Steelhead rearing rule tuned on the province-wide run

**Verified:** 2026-10-24 (retuned on the evidence rebuilt on wet's 2026-10-19 flows, the walk ending at the river's
bank, the gradient ladder to 30 % and the prior on the data-set and era terms, #73; first tuned 2026-10-17, #57;
regraded 2026-10-19, #65) · **Issues:** #57, #65, #73 · **Produced by:** `scripts/0310` (the evidence build),
`scripts/0320` (`data/tune/ST_rear_*`, script log `scripts/logs/habitat/20261024_tune_run.txt`), `scripts/0330`
(`data/compare/ST_rear_*`, script log `scripts/logs/habitat/20261024_compare.txt`); the curve's held-out loop
repeated by hand with the prior on and off (`planning/active/scratch/curve_prior_probe.R`) · **Status:** measured;
nothing applied in link. The method and the cross-species table are `habitat_thresholds_tuned.md`.

## In plain words

link calls a stream segment steelhead rearing habitat with a yes-or-no test: wide enough (1.5 m) and not too steep
(8.49 %). This run asked which version of that test best predicts where steelhead were caught in watersheds held out
of the fit, trying size floors by flow or by width and gradient limits from 3 to 30 %. A rule is judged by held-out
deviance, a score of how surprised the rule is by fish records it never saw (lower is better), and "no rule" (one
catch rate everywhere) is the zero line: a rule that scores worse than no rule has learned nothing that carries over.
The rule chosen is the simplest one the data cannot tell from the best, so a size floor in flow, not width, and
`default`'s gradient. A second model, a smooth curve of catch rate on size, distance to a large river and gradient,
was to turn the rule into grades from 0 to 1. **That curve scored worse on held-out groups than no rule, so no grades
are published for steelhead rearing** (below).

| | `default` | recommended |
|---|---|---|
| rule | width ≥ 1.5 m, gradient ≤ 8.49 % | MAD ≥ 1 m³/s, gradient ≤ 8.49 %, no exception |
| held-out deviance (no rule 420.8; best rule 357.5) | 407.8 | 372.9 |
| steelhead caught on the visits it admits / on the rest | 8.3 % / 2.9 % | 19.7 % / 2.0 % |
| km on link's 79 steelhead groups | 70,980 | 41,714 (−41.2 %, link's structure) |
| FDIS visits with steelhead, on its segments / accessible segments outside it | 4.8 % / 0.7 % | 7.8 % / 0.6 % |
| grades | not published | not published |

The honest reading is that the data say steelhead are caught mostly on streams of 3 m³/s or more (61 of the 82
detections), chiefly in two watershed groups, and cannot say where the gradient limit goes. Eleven groups carry the
evidence.

## What to expect of juvenile steelhead

The intrinsic-potential models that name steelhead are generous on size and set the gradient limit between 7 and 12 %.
Rebellato et al. (2024) give steelhead rearing a mean annual flow range of 0.02–60 m³/s, a minimum width of 1.5 m and a
gradient of 0–7.4 % (their Table 1; `data/literature_evidence.csv` rows 339–342); Lindley et al. (2006) call a
Central Valley reach suitable above 0.028 m³/s and under 12 % (rows 304–305); Burnett et al. (2007) score steelhead
"high across a broad range of mean annual stream flows", with the gradient score highest at 2–3 % and no use above 10 %
(rows 197, 204–205); Agrawal's model ends the gradient curve at 12 % (row 292, Agrawal's as Sheer et al. summarise it). Boughton and
Goslin (2006) put the 95 % envelope's upper gradient at 9.31 % and 10.57 % on two California coast ESUs (rows 313, 321).
Cooney and Holzer (2006) are stricter on both: a minimum bankfull width of 3.8 m (rows 387–388), 0.5–4 % rated high in
moderate and wide valleys and over 7 % no use in channels 3.8–25 m wide (rows 389–391). Rebellato's 5 % gradient (row 362) is the
rearing-connectivity rule, not a rearing limit. The expectation, then, is a rule with a small size floor (a few
hundredths of a m³/s, or 1.5–4 m of width) and a gradient limit between 7 and 12 %, so `default`'s 8.49 % should
stand. Nothing in these rows puts a floor near 1 m³/s.

## Evidence

4,798 stream-branch electrofishing visits (82 with steelhead) in the 68 groups of link's steelhead range with no
natural barrier downstream; 1,375 of them, in the 11 groups where steelhead were both caught and missed, are modelled.
That is one group above the 10-group floor under which a key is called underpowered, and a thin row. Of the 82
detections, 27 are in NIMP and 26 in SETN; the other nine groups share 29. Steelhead were caught on 1.3 % of the 470
visits under 0.1 m³/s, 1.1 % of 355 at 0.1–0.35, 4.3 % of 208 at 0.35–1, 1.0 % of 202 at 1–3 and 43.9 % of the 139
at 3 m³/s or more (the curve's 1,374 visits). By gradient they were caught on 8.5 % of the 683 visits at 3 % or less,
2.3 % at 3–5.49 %, 1.4 % at 5.49–8.49 %, 1.9 % at 8.49–15 % and 12.3 % of the 106 above 15 %.

## Recommended rule: MAD ≥ 1 m³/s, gradient ≤ 8.49 %, no exception

One departure from `default`: the size test moves from width to flow, and the gradient stays at 8.49 %. It sits 15.4
deviance behind the best rule (MAD ≥ 1 m³/s, gradient ≤ 3 %, no exception; held-out 357.5 against 420.8 for no rule)
with an SE of 20.3, inside the region. The region (every rule within one SE of the best) holds 1,034 of the 7,224
rules: 976 MAD rules with floors of 0.15 to 1 m³/s, 58 width ≥ 4 m rules, every one of the grid's 12 gradient limits
from 3 to 30 %, and an exception (a large river close downstream) on 989 of them. Steelhead are caught on 19.7 % of the
309 visits the rule admits against 2.0 % of the 1,066 outside; `default` admits 787 visits and catches steelhead on
8.3 % of them against 2.9 % outside.

**`default` is outside the region**, 50.3 behind the best (SE 29.9, 1.68 SEs), and so is link's `default_tuned` floor at
`default`'s gradient (MAD ≥ 0.02 m³/s, 58.8 behind, SE 31.8). The bar matters here: at the 1.96 SE bar `default` is
inside (the region has 6,434 rules), and the 1.96 pick from the flow start is the `default_tuned` rule. So steelhead's
data prefer a flow floor at the 1 SE bar and cannot tell any of these rules from `default` at the 1.96 bar.

**What the checks say** (each listed with its direction):
- *Nested selection* (the pick chosen on four folds, scored on the fifth): 392.0 against `default`'s 407.8 and 420.8
  for no rule. The chosen rule differs by fold (floors 1, 1, 1, 0.28 and 0.5 m³/s; gradients 8.49, 3, 3, 25 and 8.49 %),
  beats `default` and no rule in four folds and loses to both in fold 2 (57.9 against 51.4 and 50.1). For a flow floor;
  neutral on the exact rule.
- *Four more fold seeds*: the best rule is the same 3 % rule on all four, the recommendation is this rule on all four, it
  is in the region on all four, and `default` is outside it on all four. For.
- *Group bootstrap* (200 resamples, width start | flow start): MAD as the size variable in 98 | 100 %, a floor of 1 in
  62.5 | 64 % (0.5 in 18 | 18.5 %, the rest below); no exception in 86 | 86 %; gradient 3 % in 36.5 | 36.5 %, 25 % in
  20.5 | 20.5 %, 8.49 % in 19.5 | 20 %, 4 % in 9.5 | 9 %, 7 % in 7 | 7 %. The exact rule in 16.5 %. For the flow
  variable and the top of the ladder; against any one gradient.
- *Profiles* (best rule at each value, as deviance behind the best, SE): size floor 1 best, 0.5 +3.7 (31.9), 0.75 +5.0
  (4.2), 0.35 +6.7 (32.6), 0.2 +13.1 (5.1), every width floor +11.8 to +23.8 (width ≥ 1.5 m, `default`'s, +23.4 (6.8)),
  0.02 +30.9 (9.6); gradient 3 % best, 25 % +1.5 (28.3), 30 % +2.1 (28.0), 4 % +5.3 (8.0), 7 % +9.3 (15.1), 5.49 %
  +11.7 (9.2), 8.49 % +15.4 (20.3). For a flow floor over a width floor; the gradient profile is flat inside its SEs, so
  against any claim about the gradient limit.
- *The joint curve* (edf 10.81 for size × distance, 2.55 for gradient, 7.87 for the group effect) scores 553.8
  held-out, worse than no rule. Against reading the curve at all (below).
- *Power*: 11 groups with both outcomes, 82 detections, and 47 of the 61 detections inside the rule are in NIMP (21) and
  SETN (26). Against any claim the contrast carries beyond those two groups.

## What it is not

- **Not a lower bound on steelhead streams.** 1 m³/s is the top of the ladder of flow floors (0.02 to 1), so the rule sits
  at the edge of what the grid offers, and the visits below it still catch steelhead on 2.0 % (21 of 1,066). The visits
  between 1 and 3 m³/s catch them on 1.0 % (2 of 202) and those at 3 or more on 43.9 %: the data jump above a floor the
  grid cannot reach, mostly in two groups. The literature's floors (0.02 to 0.06 m³/s) are lower, which the data do not
  contradict so much as fail to test.
- **Not a gradient limit.** Every gradient from 3 to 30 % is in the region; 8.49 % is kept because it is `default`'s.
  Rebellato's 7.4 %, Cooney's 7 % and Burnett's 10 % bracket it.
- **Not a change to river polygons, wetlands or lakes**, which keep `default`'s tests under every rule.
- **A rate per standard electrofishing visit, not capacity or density.**

## Grades are not published

The grade turns the rule into a ranking: the curve's predicted catch rate on each segment, at its own distance to a
river of 10 m³/s or more. A ranking is worth publishing only if the curve predicts groups it was not fitted to better
than one constant rate does. Steelhead's curve does not: held-out deviance 553.8 against 420.8 for no rule, 407.8 for
`default` and 357.5 for the grid's best, so it ranks unseen segments worse than not ranking them. The gate (Al,
2026-10-24) therefore withholds the key's grades; the rule itself still comes from the grid of cut rules, which the
gate does not touch, and which beats no rule by 47.9 (the best rule by 63.3). The grade table
(`data/tune/ST_rear_grades.csv`) carries sizes and distances for 4,142,681 segments in 79 groups (720,768 accessible, a
river found from 566,647) and no rate, grade or class; graded km in the comparison tables is NA.

**Why the curve trails the grid** (the held-out loop repeated by hand): two causes, the larger first.
1. *Two labels that always travel together.* The model carries a term for the data set (the FDIS export's own
   `DATA_SET` code, `FDIS` or `FDS`) and one for the era of the visit, so a rule is not credited for a sampling
   difference. Steelhead's 272 `FDIS` visits are all from 1995–2004, and only one other visit is, so the two terms mark
   the same visits but one. Where two labels cannot be told apart the fit has no best split, so it gives them large opposite values that cancel on the visits that carry both (fold fits:
   57.6 to 99.3 on the cloglog scale, where each unit multiplies the hazard of detection by e). A held-out group with
   visits in both combinations gets one of those offsets on part of its visits, which the group's single intercept
   cannot absorb. The grid's fit had this repaired by a prior (a normal with SD 2.5 on those two coefficients, #73);
   the curve's took it only after the first rescore. With the prior the fold coefficients sit between −0.5 and 2.5 and the held-out total
   falls from 860.8 to 553.8 (SALM 229 to 43, TSAY 172 to 72, BABR 57 to 15).
2. *A joint smooth on 82 detections.* With the prior, NIMP alone scores 260.2 of the 553.8 (240.4 before). NIMP holds 27 of
   the 82 detections, and 88.5 % of its 87 visits, with all 27 detections, sit at the distance cap (50 km or no river
   of 10 m³/s found), against 39.3 % of the 1,237 visits the fold's fit was trained on. The smooth bends to those
   few groups' high catch and predicts the held-out group badly. The grid's rules have one binary term each and cannot
   do this.

The prior moved steelhead's curve by 307 (860.8 to 553.8) and no other key's by more than 43.

## What the rule changes on link's segments (`scripts/0330`, `data/compare/ST_rear_*`)

The baseline is link's `default` (configs at `102762da`), regenerated through fresh's predicate, the user-habitat
overlay and connectivity on link's 79 steelhead groups: 70,980 km, where the stored flags hold 71,738. The tuned rule is
set beside it under two structures for through-wetland lines (edges 1050 and 1150: a free pass, as the rule was scored,
or link's door through the gradient and size test, link#364); with no exception it has no third:

| structure | tuned km | change | lost | gained | of the gain, through-wetland lines |
|---|---|---|---|---|---|
| free pass | 45,274 | −36.2 % | 27,027 | 1,320 | 975 |
| door (link's `stream`) | 41,714 | −41.2 % | 29,605 | 339 | 9 |

Under the door 26,451 km are lost to the 1 m³/s floor (segments `default` passes on width that the flow fails), 2,984 km
to through-wetland lines the tuned door drops and 170 km to connectivity and the overlay; none is lost to the gradient,
which is `default`'s. Of the 339 km gained, 309 are where the flow passes and the width fails or is unmeasured (305 km
of the gain is order-1 streams). All 79 groups lose, from −83.6 % to −10.2 % (median −36.9 %); GRAI loses the most,
2,191 km (−64.0 %), then BULK 1,614 km (−61.5 %) and UDEN 1,582 km (−77.8 %).

**Checks.** FDIS visits with steelhead, on each rule's segments against accessible segments outside it (these are the
visits on link's accessible segments in the 79 groups, a wider set than the tuning's): `default` 204 of 4,225 (4.8 %)
against 18 of 2,667 (0.7 %); the tuned rule 195 of 2,586 (7.5 %) against 27 of 4,306 (0.6 %) with the free pass, and 195
of 2,502 (7.8 %) against 27 of 4,390 (0.6 %) with the door. On the 1,066 bcfishobs locations FDIS does not hold
(presence only, never scored), the share of locations on a rule's segments over its share of accessible stream-edge km
is 2.19 (2.13–2.24) for `default`, 4.08 (3.84–4.31) with the free pass and 4.08 (3.84–4.31) with the door; the door's
lift over `default` is 1.89 (1.67–2.11). **The two structures cannot be told apart by either check**, and the scoring
never saw a through-wetland line, so the structure is link's call: `door` is what link#364 chose and what the
comparison records as tuned. Both checks say the rule keeps most of what the fish records sit on: 195 of the 222 FDIS
detections lie on its segments against `default`'s 204, on 41 % fewer km under the door.

The floodplain table (`data/compare/floodplain.csv`) and the maps were not redrawn for #73 (`0330 STAGE=maps`);
the maps in `research/fig/compare_st_rear_*.png` date from 2026-10-20 (#65).
