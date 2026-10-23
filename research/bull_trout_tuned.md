# Bull trout rearing and spawning rules tuned on the province-wide run

**Verified:** 2026-10-23 (retuned on the evidence rebuilt on wet's 2026-10-19 flows, with the walk ending at the river's
bank and the gradient ladder to 30 %, #73; first tuned 2026-10-17, #57; regraded 2026-10-19, #65) · **Issues:** #57,
#65, #73 (folding #68, #80 and #81's run-time pieces); builds on #28 (`habitat_weights.md`, the gradient use curve on
link's 55-group build) and #33 (`bt_spawning.md`, spawner evidence by gradient class) · **Produced by:** `scripts/0310`
(evidence build, ledger `scripts/logs/habitat/20261022_evidence_build_ledger.csv`), `scripts/0320`
(`data/tune/BT_{rear,spawn}_*`, log `scripts/logs/habitat/20261022_tune_run-bt.txt`), `scripts/0330`
(`data/compare/BT_{rear,spawn}_*`, log `scripts/logs/habitat/20261023_compare-bt.txt`), `scripts/0325` (`data/thresholds.csv`
rows `BT_rear_v1`, `BT_spawn_v1`; the grade table `knowledge/habitat_grade/v1`) · **Status:** measured; nothing applied
in link. The method and the cross-species table are `habitat_thresholds_tuned.md`.

## What to expect of bull trout

**Rearing.** Juvenile bull trout rear in small, often steep streams for two years or more before any move to larger water
(McPhail & Baxter 1996, `data/literature_evidence.csv` row 109), and resident forms hold streams "smaller and [with]
higher gradients than those occupied by adfluvial and fluvial" fish (row 100). The models that size their streams set
small floors: Isaak et al. (2015) trim reaches with summer flows under 0.0057 m³/s, about a 1 m wetted width (row 122),
and slopes over 15 %, which held under 1 % of occurrences (row 95), with slope a negative effect inside those bounds
(row 97); Dunham & Chandler (2001) found occurrence rising with width and note the belief that bull trout "select larger
habitats (e.g., > 2 m in width)" (rows 105–106); Porter et al. (2008) key the Thompson HSI on bankfull width, low under
3.05 m and high over 3.35 m (rows 108, 474), use gradient only at the margin (row 101) and report the highest catch per
unit effort "in higher gradient streams" (row 102). The field accounts put rearing on gradients well past link's
`default` limit of 10.49 %: Bustard & Schell (2002) found juveniles rearing at 1–14.5 % in the Morice (row 190),
Trotter's (2000) last-fish reaches ran 7.5–22.5 % and Watson & Hillman's survey found bull trout to 23 % (rows 98–99),
while the Wigwam rearing reaches were 0.4 and 2.8 % (rows 103–104). Rieman & McIntyre (1993) place rearing in order 2–4
streams (rows 110–111); the 2023 provincial management plan uses order ≤ 3 (row 112). The expectation, then, is a size
floor below `default`'s 1.5 m width, a gradient limit above 10.49 %, and use that declines slowly with gradient rather
than stopping: #28's reading of link's 55-group build (`habitat_weights.md`) was that most of the fall in use with
gradient is in whether fish are found at all, not in how often bull trout are among them.

**Spawning.** The reach studies put spawning on low gradients and moderate streams: 0.6–1.0 % in the Wigwam (row 85),
1.3–4.9 % section averages in the Duncan (rows 80–84), 1–4 % in the Morice (row 188), 1–1.5 % in Gill (2006, row 74),
≤ 1 % in Ford et al.'s (1995) review (row 72); none gives a limit (rows 70–71). On size, Hagen et al. (2015, 2020) use a
2 m wetted width as the spawning floor (rows 86, 496), Bustard & Schell's Morice spawning streams were ≥ 7 m (row 189),
and stream order runs from Trotter's 1–2 (row 94) through the management plan's ≤ 3 (row 93) and Hagen's ≥ 3 (rows 91–92)
to 5–6 in the Duncan and Elk (rows 89–90). The expectation is a low gradient limit and a size floor near 2 m. The evidence
below cannot test it: it is spawner codes on August–October electrofishing, and #33 showed the within-group rate does not
fall with gradient in a way that catch can show.

## Rearing

### Evidence

11,015 stream-branch electrofishing visits (1,199 with bull trout) in 122 groups in link's bull trout range with no
natural barrier downstream; 8,717 of them (1,198 detections), in the 75 groups where bull trout were both caught and
missed, are modelled (8,710 carry a size and a gradient). Half the modelled visits are on streams under 0.08 m³/s and a
quarter under 0.02. Detection rises with stream size the whole way to 3 m³/s (4.9 % of 2,322 visits under 0.021 m³/s,
6.9 % at 0.021–0.043, 9.8 % at 0.043–0.1, 14.1 % at 0.1–0.2, 15.3 % at 0.2–0.35, 20.6 % at 0.35–0.5, 22.7 % at 0.5–1,
32.1 % of 970 at 1–3, 26.9 % at 3–10) and barely moves with gradient: on the FWA gradient the rules read, 13.7 % of the
4,684 visits at 5.49 % or less, 16.1 % at 5.49–7 %, 14.8 % at 7–9 %, 15.3 % of 510 at 9–10.49 %, 13.1 % of 617 at
10.49–13 %, 6.5 % of 291 at 13–15 %, 13.6 % of 428 at 15–20 %, 15.7 % of 230 at 20–25 %, 10.2 % of 127 at 25–30 % and
8.3 % of the 156 steeper.

### Recommended rule: MAD ≥ 0.1 m³/s, gradient ≤ 10.49 %, no exception

One departure from `default` (the size test moves from a 1.5 m width floor to a flow floor; the gradient is
`default`'s own), and one departure from link's flow start too (MAD ≥ 0.021 m³/s at 10.49 %, which is 195.5 behind the
best, SE 126.4, outside the region). It sits
97.1 deviance behind the best rule (MAD ≥ 0.5 m³/s, gradient ≤ 25 %, no exception; held-out deviance 5,854.4 against
6,180.6 for no rule) with an SE of 101.5, inside the region. The region holds 594 rules: MAD floors 0.043–0.5 m³/s and
width floors of 3–4 m, every gradient maximum from 10.49 to 30 %, with or without an exception (555 have one, at every
Q and D on the ladder, because the exception admits little a MAD floor that low refuses). Bull trout are caught on
22.0 % of the visits the rule admits against 8.4 % outside (`default`: 17.0 % against 8.5 %).

**`default` is outside the region**, 229.2 behind the best (SE 127.5, 1.80 SEs), on all four extra fold seeds. link's
`default_tuned` floor (MAD ≥ 0.043 at 13.49 %) is inside, 115.8 behind (SE 125.1), with 19.4 % against 7.0 %. The 1.96 SE
pick (#79) is `default` itself from the width start and the flow start's own rule from the flow start, from a region of
4,860 of the 8,385 rules: at the stricter bar nothing is told from either start.

**What the checks say** (each listed with its direction):
- *Nested selection* (the pick chosen on four folds, scored on the fifth): 5,927.8 against `default`'s 6,083.6 and
  6,180.6 for no rule. For a MAD floor; its fold picks are MAD 0.1–0.5 at 25 % three times, 0.1 at 30 % once and this
  exact rule once, so for the floor more than for the 10.49 % maximum.
- *Four more fold seeds*: one recommends this exact rule; the other three recommend MAD ≥ 0.1 or 0.5 at 25 %. `default`
  is outside the region on all four; this rule is inside the region on one of four. Against the gradient maximum as
  chosen, for the floor.
- *Group bootstrap* (200 resamples, width start | flow start): a MAD floor in 99.5 | 99.5 %, 0.1 in 43 | 42 %, 0.5 in
  23.5 | 23.5 %, 0.35 in 13.5 | 13 %; a maximum of 25 % in 56.5 | 55.5 %, 10.49 % in 20 | 19.5 %, 30 % in 18.5 | 19 %;
  no exception in 98 | 98 %. The exact rule in 5 %. For the size variable and against an exception; the maximum splits
  between 25 % and `default`'s 10.49 %.
- *Profiles* (best rule at each value, as deviance behind the best, SE): size 0.5 best, 0.1 +0.01 (89.5), 0.35 +4.7
  (27.3), 0.15 +10.3, 0.2 +19.3, 0.28 +37.8, width 3 m +55.0 (91.1), 0.75 +75.9 (45.5), 0.043 +79.7 (118.2), 1 +91.2,
  width 2 m +166.6, 1.5 m +221.4 (127.0); gradient 25 % best, 30 % +0.3 (89.4), 20 % +35.4 (34.3), 13 % +45.1 (98.0),
  15 % +55.3 (42.6), 11 % +87.0, 10.49 % +96.0 (58.8), 9 % +132.1 (61.1), 7 % +198.4, 5.49 % +251.6 (112.0), 3–4 %
  +234 to +274. For a floor between 0.1 and 0.5 and against every width floor under 3 m; for a maximum of 20 % or more
  over 10.49 % by 1.6 SE.
- *The joint curve* (size × distance to a 10 m³/s river, gradient; edf 18.8, 4.2, group effect 60.8) scores 5,767.6
  held-out, 86.8 below the grid's best: the surface carries more than any cut. Its size term rises through the whole
  range (relative rate 0.36 at 0.021 m³/s, 0.53 at 0.043, 1.0 at 0.1, 1.9 at 0.35, 2.4 at 1, 2.6 at 3); its gradient
  term is fitted on gradient clamped at 20 % (`knw_tune_curve()`), so it says nothing above that. For reading the grade
  as a surface; silent on the 25 % maximum.

The pick is therefore a decision the tie-break made, not one the evidence made: the rule with the fewest departures
inside one SE of the best keeps `default`'s gradient because the records cannot separate 10.49 % from 25 % (96.0 behind
on an SE of 58.8), and every other check that speaks to gradient points above 10.49 %. link#346 has both numbers.

### What it is not

- **Not a limit of use at 10.49 %.** Detection is as high at 15–25 % as at 5 %; the best rule, three of four seeds, the
  bootstrap's plurality and nested selection's folds put the maximum at 25 %, and the region reaches 30 %, the top of
  the ladder. Trotter's 22.5 % and Watson & Hillman's 23 % are the field limits on record.
- **Not a lower bound on bull trout streams.** 0.1 m³/s is where the profile flattens (0.1 to 0.5 within 5 deviance);
  the 3,377 visits under 0.043 m³/s still catch bull trout on 5.5 %.
- **Not evidence for or against an exception.** 555 of the region's 594 rules carry one because it changes almost
  nothing beside a 0.1 floor; the bootstrap drops it in 98 % of resamples, and the distance curve is not monotone
  (relative rate 1.8 on the river's own line, 1.0 at 1 km, 1.7 at the 50 km cap).
- **Not a change to river polygons, wetlands or lakes**, which keep `default`'s tests under every rule.
- **A rate per standard electrofishing visit, not capacity or density.**

### Grade (`knowledge/habitat_grade/v1`; `scripts/0320`, 2026-10-23)

Every accessible segment of the 158 groups is walked from its downstream end to the first ≥ 10 m³/s river, ending at a
double-line river's bank (#73), and read on the flows wet republished on 2026-10-19 (the table records the load). 8.41 M
segments, 2.68 M accessible, 2.66 M graded (33,992 with no flow even from a parent); reference rate 0.221 over edge types
1000, 1100, 2000 and 2300 (#65: 0.226). Of 576,908 accessible km, 571,305 are graded and sum to 146,894 grade-weighted km
(#65: 151,418, to the centreline); 64 % of graded km lies under 0.2 and 10 % at 0.8–1. 53,897 km read a distance of 0
(40,327 of them river-polygon lines), where the curve is an extrapolation (`habitat_thresholds_tuned.md`, Limits);
120,636 of the 2,647,784 segments whose walk found a river (30,841 km) found it in another watershed group.

## Spawning

### Evidence

552 August–October visits that caught and maturity-coded bull trout (101 with spawner evidence) in 50 groups; 475 of
them (98 detections), in the 22 groups with both outcomes, are modelled (450 carry a size and a gradient). The
spawner-evidence rate rises with gradient on the FWA gradient the rules read, 14.7 % of 190 visits at 3 % or less,
22.3 % of 94 at 3–5.49 %, 25–27 % of the 109 at 5.49–10.49 %, and 15 of the 57 above 10.49 %, as #33 found on link's
55-group build, where the rise was between groups and vanished with a group term.

### Recommended rule: width ≥ 2 m, gradient ≤ 13 %, no exception

One departure from `default` (width ≥ 2 m at 5.49 %): the gradient maximum. It sits 5.6 deviance behind the best rule
(width ≥ 2 m, gradient ≤ 30 %, a ≥ 1 m³/s river within 500 m; held-out deviance 402.0 against 408.0 for no rule) with an
SE of 5.9, inside a region of 328 rules: width floors 1–3 m and MAD floors 0.041–1 m³/s, every gradient maximum from
11 to 30 %, with or without an exception. From link's flow start the pick is MAD ≥ 0.041 at 13 % (4.9 behind, SE 5.2).
**`default` is outside the region** (10.2 behind, SE 5.8, 1.74 SEs), and scores above no rule at all (412.2 against
408.0), on all four extra fold seeds; so is link's `default_tuned` floor (13.2, SE 6.8). The 1.96 SE pick is `default`,
from a region of 5,780 of the 7,095 rules.

**Read this row as weak, as #57's was.** The rule separates nothing in raw terms: spawner evidence on 19.7 % of the
visits it admits and 24.0 % of those it leaves out (`default`: 17.7 % against 24.3 %). Nested selection scores it at
412.2, level with `default` (412.2) and behind no rule (408.0), its folds picking 20, 30, 13, 30 and 30 %. Three of four
seeds recommend this exact rule and one a 30 % maximum with an exception; the bootstrap recommends it in 3.5 % of
resamples, a width floor in 86 % (2 m in 82.5 %) from the width start and 56.5 % from the flow start, a 30 % maximum in
60 | 42 % and 13 % in 21 | 30.5 %. The profiles are flat: every size floor within 7 deviance of the best on SEs of 3–7,
every gradient maximum from 7 % up within 8. The joint curve (edf 3.0, 1.05, group effect 11.1) is flat too, 0.99–1.02
across width and 0.81–1.09 across gradient to 20 %, and scores 403.7 held-out, between the best cut and no rule.
Ninety-eight detections in 22 groups do not carry a rule; what they say is that `default`'s 5.49 % maximum is the
one value the evidence scores worse than no rule, in the direction #33 reported.

### Grade (`knowledge/habitat_grade/v1`; `scripts/0320`, 2026-10-23)

The same walk and flows, with the channel width as the size, which fwapg models only where the stream order is above 1:
1.40 M of the 2.68 M accessible segments are graded (5.10 M of the 8.41 M segments carry no width), 319,633 of 576,908
accessible km. Reference rate 0.148 (#65: 0.210). The graded km sum to 246,569 grade-weighted km, and the surface is
nearly flat: 51 % of graded km lies at 0.6–0.8 and 39 % at 0.8–1, none under 0.2, so the grade orders segments within a
narrow band and separates little. 40,236 km read a distance of 0.

## What each rule changes on link's segments (`scripts/0330`, `data/compare/BT_*`)

The baseline is link 0.68.0's `default` (configs at `5f8f9f1d`, origin/main on 2026-10-23; `configs/` is unchanged since
the `67a410e2` the chinook and coho comparisons read), regenerated through fresh's predicate, the user-habitat overlay
and connectivity on link's 158 BT groups (one, TURN, has no accessible BT stream under either rule). The log is
`scripts/logs/habitat/20261023_compare-bt.txt`; the run read the archived schema `fresh_default_20261017`, the released
run under its new name, because link#361's provincial run took the name `fresh_default` while the chain was running.

### Rearing

`default` (width ≥ 1.5 m, ≤ 10.49 %) draws 244,328 km, where the stored flags, from the run's older configs, hold
251,584 and #65's regeneration under the run's configs drew 248,927: the door on through-wetland lines (link#364) takes
about 4,600 km of BT rearing. The tuned rule (MAD ≥ 0.1 m³/s at the same 10.49 %) is set beside it under two structures;
having no exception, it has no third:

| structure | tuned km | change | lost | gained | of the gain, through-wetland lines | graded km, `default` → tuned |
|---|---|---|---|---|---|---|
| free pass on through-wetland lines (as the rule was scored) | 190,117 | −22.2 % | 62,557 | 8,346 | 5,359 | 101,584 → 91,323 |
| door on through-wetland lines (link's `stream`) | 177,669 | −27.3 % | 69,697 | 3,038 | 149 | 101,584 → 90,145 |

Both rules share the gradient maximum, so everything moves on size. Under the door, 61,172 km are lost where the stream
is over 1.5 m wide and under 0.1 m³/s, 8,114 km of through-wetland lines that pass `default`'s door and fail the tuned
one, and 411 km to connectivity and the overlay; 2,774 km are gained where the flow passes and the width fails or is
unmeasured (2,609 of the 3,038 km gained are order-1 streams), 149 km of through-wetland lines that pass the tuned door
and not `default`'s, and 115 km through connectivity. The km the rule sheds are the grade's low end: under the door the
0–0.2 class falls from 88,868 to 47,008 km and the 0.2–0.4 class from 55,863 to 31,951, while the 0.8–1 class rises
from 49,466 to 50,200 (the grade is fitted on the same visits, so this is consistency, not a check). Across groups the
change runs from −61.5 % (GUIC) to +3.5 % (CHWK), median −24.7 %; 7 of the 157 groups with `default` km gain.

**Checks.** FDIS detection on each rule's segments against accessible segments outside it: `default` 16.7 % against
6.2 % (2,340 of 14,017 visits, 440 of 7,055); the tuned rule 19.5 % against 6.4 % with the free pass, 19.9 % against
6.3 % with the door (2,129 of 10,688, 651 of 10,384). On the bcfishobs records FDIS does not hold (presence only, never
scored), the share of locations on the rule's segments over the rule's share of accessible stream-edge km is 2.447
(2.397–2.503) for `default`, 3.806 (3.707–3.898) with the free pass and 3.809 (3.710–3.901) with the door; the door's
lift over `default` is 1.362 (1.287–1.427). #57's narrower rule (MAD ≥ 0.35) read 5.21 on #65's run: the lift rises as
a rule narrows, which is why it reads density and not extent. **The two structures cannot be told apart by either
check**, and the scoring never saw a through-wetland line (its visits are on edge 1000/1100/2000/2300), so the structure
is link's call: `door` is link's `stream` for bull trout and what the thresholds table will record from `0325`'s next
run (`near_river_scope`, Phase 8; empty for a rule with no pair).

### Spawning

`default` (width ≥ 2 m, ≤ 5.49 %) draws 133,382 km (the stored flags hold 134,879; #65's regeneration drew the same
133,382, the door being a rearing structure), and its spawning has no through-wetland line rule, so the stage has one
structure. The tuned rule keeps the size test and raises the gradient maximum to 13 %, so it contains `default`:
169,416 km (+27.0 %), nothing lost, 36,034 km gained, 35,500 of them stream between 5.49 and 13 % and 534 on the
river-polygon branch. The gain is on measured or modelled widths, so it is order 2 and above (382 km order 1, 8,783
order 2, 16,864 order 3, 10,006 order 4 and up). Graded km rises from 93,411 to 123,823, and the gained km sit high on
the spawning grade, whose 0.8–1 class rises from 12,608 to 46,131 km (the same consistency, not a check). Every group
with `default` km gains, from +0.7 % (UBTN) to +70.8 % (PCEA), median +29.5 %.

**Checks.** There is no FDIS check for spawning (electrofishing catch is not spawning evidence). On the bcfishobs
records, the lift is 3.042 (2.927–3.160) for `default` and 3.025 (2.973–3.083) for the tuned rule, a difference of
−0.016 (−0.117 to +0.075): the 36,034 km the rule adds hold BT locations at the same density as `default`'s km. For a
rule the scoring called weak, that is the one independent reading, and it is neutral, neither for nor against the 13 %
maximum. #57's rule (MAD ≥ 0.75 at 5.49 % with a river within 2 km) read 3.70 on #65's run.

The floodplain table (`data/compare/floodplain.csv`) and the maps were not redrawn for #73 (`0330 STAGE=maps`); their
bull trout figures are #65's, on the run's own configs. Maps: `research/fig/compare_bt_{rear,spawn}_*.png`.

## What this replaces

#28's candidate weight per gradient class (`data/habitat_weight_bt_rear.csv`) is superseded by the rearing grade: one
surface over size, gradient and distance, graded against the best accessible stream-branch segments, instead of a class
ratio. #28's held-out elevation contrast used link's step-5 split, which one province-wide schema no longer carries;
`habitat_weights.md` keeps those sections as history. #57's rules (MAD ≥ 0.35 at 10.49 %; MAD ≥ 0.75 at 5.49 % with a
3 m³/s river within 2 km) were tuned on the 2026-10-17 flows with the walk to the centreline and the ladder ending at
10.49 %; this file replaces them.
