# Westslope cutthroat rearing rule tuned on the province-wide run (underpowered)

**Verified:** 2026-10-24 (retuned on the evidence rebuilt on wet's 2026-10-19 flows, with the walk ending at the river's
bank and the gradient ladder to 30 %, #73; first tuned 2026-10-17, #57; regraded 2026-10-19, #65) · **Issues:** #57,
#65, #73; link's own WCT calibration is NewGraphEnvironment/link#322 · **Produced by:** `scripts/0310` (evidence build),
`scripts/0320` (`data/tune/WCT_rear_*`; the grade table is there, with its rates withheld), `scripts/0330`
(`data/compare/WCT_rear_*`), `scripts/0325` (`data/thresholds.csv` row `WCT_rear_v1`, `power = underpowered`, which still
holds the pick from before #73 until `0325` runs again; it leaves this key out of the published grades) · **Status:** measured; nothing applied in link. The method and the
cross-species table are `habitat_thresholds_tuned.md`.

## What to expect of juvenile westslope cutthroat

The literature rows say little that bears on a size floor or a gradient limit, and this file does not invent one. For
westslope cutthroat rearing the library holds temperature (25 rows), velocity (5 rows), degree-day entries (3, one of them a
searched absence) and one more search that found nothing: **no gradient, channel-width, discharge or stream-order row, and no flow need** (data
row 1003 records a search of the flow collection that found no westslope cutthroat rearing flow need). What the rows do
say is cool, slow water: a preferred 9–12 °C (rows 518 and 520), upper lethal limits near 19.6–20 °C in the laboratory
(rows 521 and 1075), and fry and parr in water of 0.01–0.4 m/s (row 931; fry at 7–10 cm/s in row 935, juveniles
preferring 10–12.5 cm/s in row 937). Those are conditions at a site, not a rule for which segments to call rearing
habitat, so they set no expectation for either threshold.

The intrinsic-potential registry (`data/ip_model_registry.csv`) holds no cutthroat model. Its nearest relative is
Porter et al. (2008), a Thompson-region model of juvenile bull trout and rainbow trout capacity fitted to electrofishing
catch (rows 79 and 80): it sizes streams by modelled bankfull width, tested confinement and dropped it, and has no
gradient barrier. That says how a trout model in interior British Columbia has been built; it does not say what
westslope cutthroat need. So the only expectation here is the weak one the species allows: a size floor and gradient
limit the data can place, tested against link's `default` (width ≥ 1.5 m, gradient ≤ 8.49 %).

## Evidence

1,679 stream-branch electrofishing visits in link's WCT range with no natural barrier downstream, in 14 groups. Only 6
of the groups hold visits where westslope cutthroat were caught and visits where they were not (BULL, ELKR, KETL, KOTL,
KOTR, SMAR), and a rule can only be scored where both happen. Those 6 hold 1,157 visits, with all 536 detections
(46.3 %); the other 8 groups hold the remaining 522 visits and no detection. The scoring is on the 1,157.

**What "underpowered" means, and what it implies.** The run needs 5 groups with both outcomes to fit at all and calls a
key powered at 10. Cutthroat has 6, so it is fitted and labelled `underpowered`. The group is the unit of the
comparison because a rule is scored on watersheds it was not fitted to, and the standard error that sets the "within
noise" region comes from how a rule's score varies across those watersheds. Many fish (536) in few places (6) is not many
independent trials. With 6 groups in 5 folds, four folds hold one group and one holds two (KETL and KOTL), so each
held-out score rests on a single watershed. Expect the pick to be a direction, not a value: it shows which way the
evidence leans, and a different set of six groups could lean elsewhere.

## Recommended rule: MAD ≥ 0.03 m³/s, gradient ≤ 30 %, no exception (and how little it can claim)

In plain words: link keeps a segment as rearing habitat if it is wide enough and not too steep. For cutthroat the best
rule on held-out watersheds keeps almost every stream: the size floor sits at the bottom of the grid's ladder and the
gradient limit at the top. It is two departures from `default` (the size test moves from width to flow; the gradient
maximum rises from 8.49 % to 30 %), and one from link's flow form of `default` (`default_tuned`'s MAD ≥ 0.03 m³/s at
8.49 %, link#331), which differs only in the gradient.

| | link `default` (width ≥ 1.5, ≤ 8.49 %) | link's flow form (MAD ≥ 0.03, ≤ 8.49 %) | this pick (MAD ≥ 0.03, ≤ 30 %) | the last version of this file (width ≥ 1.5, ≤ 4 %) |
|---|---|---|---|---|
| held-out deviance (lower is better; no rule: 1,329.7) | 1,328.8 | 1,327.8 | 1,298.1 | 1,321.3 |
| behind the best, deviance (SE) | 30.6 (22.4) | 29.7 (20.5) | 0 | 23.1 (22.4) |
| inside the one-SE region | no | no | yes | no |
| visits the rule admits, of 1,157 | 771 | 740 | 982 | 494 |
| detection on admitted visits | 53.3 % | 55.0 % | 51.4 % | 60.3 % |
| detection on the visits it leaves out | 32.4 % | 30.9 % | 17.7 % | 35.9 % |

*Held-out deviance* is how surprised a fitted model is by the fish at watersheds it never saw: the lower, the better
the rule sorts present from absent. The baseline is "no rule", one detection rate for every visit. Two things follow
from the table. `default` scores 1.0 better than no rule at all, so on these six groups its size and gradient tests
sort cutthroat visits hardly better than a coin weighted to the species' overall catch rate. And the pick's 31.6 gain
over no rule (2.4 %) is the whole of what the rule offers; it keeps 84.9 % of the visits and leaves out the 175 that
caught 31 cutthroat. What it does is stop excluding the steep and the smallest streams where cutthroat are caught, not
single out a better habitat.

The region holds 225 of 7,224 rules. They are 169 MAD rules (floors 0.03, 0.28 or 0.35 m³/s) and 56 width rules (1, 1.5
or 3 m), with gradient limits of 4, 5.49, 7, 13, 15, 20, 25 or 30 %; 216 carry an exception and 9 do not. The pick is
the region rule with the fewest departures from `default`; no region rule has fewer than two. The rule best on held-out
score is the same rule.

**Where the 1.96 SE bar lands.** The one-SE region is a parsimony rule of thumb, not a test. At the stricter bar
(1.96 SE) 7,183 of the 7,224 rules are inside, `default` among them (1.37 SEs behind the best), and the pick is
`default` itself from the width start (width ≥ 1.5, ≤ 8.49 %) and link's flow form from the flow start (MAD ≥ 0.03,
≤ 8.49 %). At 1.96 SE, then, the evidence cannot tell the tuned rule from link's own, and a reader who wants the
cautious reading should take it: change nothing. link's flow form sits outside the one-SE region by 29.7 (SE 20.5, 1.45
SEs).

**The pick moved in #73.** The version of this file before #73 recommended width ≥ 1.5 m, gradient ≤ 4 %. Its rule was not
re-scored badly: the 3,612 rules the old grid and the new share moved by a median of −0.02 deviance (the middle half
between −0.13 and +2.0), and the old pick now scores 1,321.3. What changed is the ladder: the new grid reaches 30 % where the old
stopped at 9 %, which doubled it to 7,224 rules, and the best rule on the new grid beats the best rule at 9 % or less (MAD ≥ 0.28 m³/s, ≤ 4 %, with an
exception, 1,309.6) by 11.4 deviance. The old pick is now 23.1
behind with an SE of 22.4, just outside the region. A pick that moves when the grid grows is what a weak signal looks
like.

**What the checks say** (each listed with its direction):
- *`default` and link's flow form outside the one-SE region.* 1.37 and 1.45 SEs behind the best. For the pick, but
  narrowly, and only at one SE (see the 1.96 SE paragraph, against).
- *At 1.96 SE.* 99.4 % of the rules inside, `default` among them. Against moving off `default`.
- *Nested selection* (the pick chosen on four folds and scored on the fifth): 1,339.4 against `default`'s 1,328.8 and
  1,329.7 for no rule. Against: choosing from this grid on this few groups does worse on a watershed it did not choose
  with than doing nothing, or keeping `default`. The chosen rule beat `default` on 1 fold of 5 and no rule on 2 of 5. The
  fold picks were width ≥ 1.5 at 25 %, 13 %, 11 % and 13 % (folds 1, 2, 4 and 5) and MAD ≥ 0.03 at 13 % (fold 3). This
  is the honest estimate: the best of 7,224 rules is flattered by being the best, and the 1,298.1 above includes that
  flattery.
- *Four more fold seeds.* All four recommend this exact rule, with `default` outside the region on all four (regions of
  105–121 rules). For, though weakly: five folds over six groups, by the fold sizes above (one pair and four
  singletons), can only be made 15 ways, so new seeds mostly re-draw the same splits.
- *Group bootstrap* (200 resamples of the groups, width start | flow start): a MAD floor in 44 | 93 %, of which a 0.03
  floor in 43.5 | 92 %; a width floor of 1.5 m in 42 | 2 %; gradient limit of 13 % or looser in 62.5 | 83.5 %, of
  which 30 % in 36.5 | 56.5 %; a limit of 8.49 % or tighter in 23 | 13.5 %; no exception in 96.5 | 93.5 %. The exact
  rule in 33 | 51 % (`default` exactly: 5.5 | 0 %); 19 rules got any share from the width start. The flow start measures
  departures from a MAD rule, so it prefers a MAD floor when rules tie; the width start tests the choice of size
  variable, and it splits 44 % MAD against 56 % width. For a looser gradient and for no exception; split on the size
  variable.
- *Profiles* (best rule at each value, as deviance behind the best, SE): gradient 30 % best, 25 % +2.5 (2.0), 20 %
  +6.0 (3.4), 13 % +6.4 (9.5), 4 % +11.4 (12.3), 5.49 % +11.7 (12.1), 15 % +13.8 (9.2), 3 % +19.6 (17.8), 7 % +20.7
  (24.5), 9 % +26.5 (19.2), 8.49 % +26.6 (20.1), 11 % +28.5 (26.0); size MAD 0.03 best, 0.28 +11.4 (12.3), 0.35 +11.7
  (12.1), width 1.5 +14.8 (13.7), 3 +16.3 (16.3), 1 +19.9 (20.0), MAD 0.1 +19.0 (16.8) and every other MAD floor
  +20 to +29; no exception best, each exception flow within +4.6 and each exception distance within +7.0. For a high gradient limit against `default`'s 8.49 %
  (+26.6), for a floor at the bottom of the ladder, and against anything a shape could be read from: 4 % is better
  than 11 %, and 25 % better than 15 %, which is not a curve a species' habitat takes. It is what six groups do.
- *The joint curve* (size × distance to a 10 m³/s river, gradient; edf 8.85, 1.00, group effect 4.88) scores 1,453.4
  held-out, 155.3 behind the grid's best, 123.6 behind no rule, and 124.6 behind `default`: against reading more than a
  cut into the data (next section).
- *The smoke run's checks* (four rules, before the grid) pass on this key: no rule scores 1,329.7 held-out against 1,292.9 in-sample (ratio 1.03, limit
  1.25), no visit clamped, and the largest fitted coefficient 1.23 (limit 5).

## Why grades are not published

A grade ranks segments by the rate of detection the curve predicts for each. A curve earns the right to rank only if it
predicts unseen watersheds better than one constant rate everywhere; if it does worse, its ranking is noise that looks
like precision. The gate (Al, 2026-10-24) withholds grades from a key whose curve does not beat no rule on held-out
groups. Cutthroat's curve scores **1,453.4 held-out against 1,329.7 for no rule**: it is 123.6 worse. The curve is a
flexible surface (8.85 effective degrees of freedom for size and distance, plus a group effect of 4.88) learned from
five watersheds at a time and asked to predict the sixth, which is the thing six groups cannot support. Its grade table
(1,190,110 segments in 16 groups; 167,459 accessible, 166,124 of them with a river found by the walk to a 10 m³/s river,
1,335 with none) carries sizes and distances and no rate, grade or class, and `0325` leaves it out of the published grades.

**The rule is not touched by this.** It comes from the grid of cut rules scored on held-out groups, which beats no rule
by 31.6 and does not use the curve. What is withheld is the rate per segment, not the pass or fail.

## What it is not

- **Not a lower bound on cutthroat streams.** MAD 0.03 m³/s is the bottom of the ladder (`default_tuned`'s own floor),
  not a value the data placed. The visits the rule leaves out still caught cutthroat on 17.7 % (31 of 175).
- **Not a limit of use at 30 %.** The ladder ends at 30 %, the rungs at 20, 25 and 30 % are within 6.0 of each other and
  nothing in the literature rows places a limit. The data cannot say where cutthroat stop being found.
- **Not a gradient effect.** The profile above is not monotone (4 % is better than 11 %, 25 % better than 15 %), and
  `default`'s 8.49 % is among the three worst rungs. That ordering is a feature of six groups.
- **Not a rate per segment or a map of capacity.** It is a pass or fail on a rate of catch per standard electrofishing
  visit.
- **Not a calibration.** link#322 asks for a calibration scored on held-out groups, which needs more groups where
  cutthroat were absent as well as present; six groups cannot carry it, and that issue's design is what the transfer
  should bring, not a number from this file.
- **Not a change to river polygons, wetlands or lakes**, which keep `default`'s tests under every rule.

## What the rule changes on link's segments (`scripts/0330`, `data/compare/WCT_rear_*`)

The baseline is link's `default`, regenerated through fresh's predicate, the user-habitat overlay and connectivity on
link's 16 WCT groups (link configs at `102762d`); 35,285 accessible km, 466 of which are km the habitat table's
`accessible` and `streams_access` disagree on. `default` draws 20,632 km (58.5 % of accessible), where the stored flags
hold 20,751. The tuned rule has no exception, so it has two structures and no third:

| structure | tuned km | change | lost | gained | of the gain, through-wetland lines |
|---|---|---|---|---|---|
| free pass on through-wetland lines (as the rule was scored) | 24,572 | +19.1 % | 867 | 4,807 | 164 |
| door on through-wetland lines (link's `stream`) | 24,428 (69.2 % of accessible) | +18.4 % | 913 | 4,710 | 54 |

This rule adds habitat. Under the door, 3,090 km (66 % of the
gain) come from the gradient between the two maxima, 1,165 km where the flow passes and the width fails or is unmeasured,
385 km from connectivity and the overlay, 54 km of through-wetland lines and 16 km of other branch; of the 4,710 km
gained, 974 km are order-1 streams, 1,180 km order 2, 1,717 km order 3 and 839 km order 4 and above. The 913 km lost are
827 km of streams over 1.5 m wide under 0.03 m³/s (91 %), 84 km of through-wetland lines and 2.5 km to connectivity. All
16 groups gain, from +6.5 % (COLR) to +29.0 % (KOTL), median +17.6 %. Graded km is not reported: with no grades there
are none.

**Checks.** FDIS detection on each rule's segments against accessible segments outside it, on all 3,835 visits that fall
on link's segments in the 16 groups (a wider set than the 1,157 the rule was scored on): `default` 34.6 % against 23.4 %
(945 of 2,730 visits, 259 of 1,105); the tuned rule 33.3 % against 18.1 % with the free pass (1,119 of 3,365, 85 of 470)
and 33.3 % against 17.9 % with the door (1,120 of 3,366, 84 of 469). The rule's segments catch at about the rate
`default`'s do, over more stream, and the segments it leaves out are cleaner (17.9 % against 23.4 %). On the bcfishobs records FDIS does not hold
(presence only, never scored; 1,408 locations), the share of locations on the rule's segments over the rule's share of
accessible km is 1.560 (1.515–1.601) for `default`, 1.460 (1.435–1.482) with the free pass and 1.459 (1.434–1.480) with
the door; the door's lift over `default` is −0.101 (−0.141 to −0.061). The rule captures 1,291 of the 1,408 locations
against `default`'s 1,032, and does so by drawing more stream, so the lift (concentration) falls. **The two structures
cannot be told apart by either check**, and the comparison tables record the door, the structure the thresholds table
uses. The floodplain table and the maps (`research/fig/compare_wct_rear_*.png`) were not redrawn for #73: they date
from 2026-10-20, before this tuning, and are not quoted here.
