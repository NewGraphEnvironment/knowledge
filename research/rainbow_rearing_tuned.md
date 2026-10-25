# Rainbow trout rearing rule tuned on the province-wide run

**Verified:** 2026-10-24 (retuned, graded and compared on the evidence rebuilt on wet's 2026-10-19 flows, with the
walk ending at the river's bank, the gradient ladder to 30 % and the curve's prior on its data-set and era terms, #73;
first tuned 2026-10-17, #57; regraded 2026-10-19, #65) · **Issues:** #57, #65, #73 (#83, the scorer's fit without a
dense column per group, is what made the rainbow rerun possible); link's own RB calibration is
NewGraphEnvironment/link#343 · **Produced by:** `scripts/0310` (evidence build, ledger
`scripts/logs/habitat/20261022_evidence_build_ledger.csv`), `scripts/0320` (`data/tune/RB_rear_*`, log
`scripts/logs/habitat/20261024_tune_run.txt`), `scripts/0330` (`data/compare/RB_rear_*`, log
`scripts/logs/habitat/20261024_compare.txt`), `data/literature_evidence.csv` and `data/ip_model_registry.csv` (rows
cited), and the visit tables in `data/fdis/derived/` (the descriptive counts below) · **Status:** measured; nothing
applied in link (`data/thresholds.csv` carries this rule as `RB_rear_v1` since `0325`'s run of 2026-10-25).
The method and the cross-species table are `habitat_thresholds_tuned.md`.

## In plain words

**What link does now.** `default` calls a stream segment rainbow rearing habitat when it is at least 1.5 m wide and no
steeper than 8.49 %. **What was asked.** Of every version of that test on a ladder of width floors, flow floors,
gradient limits and an allowance for a river close downstream (7,740 rules), which best predicts where rainbow were
caught in watershed groups held out of the fit? **How it was judged.** Each rule is scored by *held-out deviance*: how
badly the fitted model predicts catches at visits in groups it never saw, lower being better, with the model that
uses no rule at all as the floor to beat. A rule has to earn its place on groups it has not seen, because a rule can
always be bent to the visits it was drawn from. **What was chosen.** Channel width of at least 3 m and a gradient
limit of 30 %, the top of the ladder, with no near-river exception. Two departures from `default`, in opposite
directions: it asks more of the width and much less of the gradient. **Why.** The visits `default` admits and the tuned
rule refuses (1.5 to 3 m wide, 8.49 % or less: 2,173) caught rainbow on 24.6 %, and the visits the tuned rule admits and
`default` refuses (3 m or wider, 8.49 to 30 %: 1,106) on 37.1 %, against 27.1 % over all 12,959 modelled visits.

| | `default` | tuned rule |
|---|---|---|
| rule | width ≥ 1.5 m, gradient ≤ 8.49 % | width ≥ 3 m, gradient ≤ 30 %, no exception |
| held-out deviance (no rule: 12,617.4) | 11,954.8 | 11,651.9 |
| rainbow caught on the visits it admits, against the rest | 36.3 % against 15.9 % | 40.6 % against 15.2 % |
| km of rearing on link's 210 groups (free pass on through-wetland lines, door) | 219,156 | 194,307, 180,951 |
| FDIS visits on its segments, against accessible segments outside (door) | 33.7 % against 15.2 % | 35.0 % against 16.4 % |
| bcfishobs records, outside lift (door) | 2.34 | 3.03 |

The pick is the best rule the grid holds, but its gradient sits at the ladder's end, so the data say that a limit
below about 20 % costs and do not say where the limit is (checks, below). The pick is what the grid recommends and not
a claim that rainbow rear to 30 %.

## What to expect of juvenile rainbow

Juvenile rainbow trout rear in small streams up to mid-size rivers and tolerate a wide gradient range. The one
intrinsic-potential model the registry holds for rainbow is Porter et al. (2008) for the Thompson ecological drainage
unit (`data/ip_model_registry.csv` row 80), a CART tree grown on FDIS electrofishing catch per unit effort and applied
to modelled bankfull width. Its top class is a gradient of 0.85 to 7.4 % with a bankfull width of 2.05 to 8.05 m
(`data/literature_evidence.csv` rows 476, 477); a gradient under 0.85 % is the lowest class (row 475); at or above 7.4 %
the class is medium whatever the width, so the model sets no gradient limit (row 478); narrower or wider than the
window is medium, not low (row 477). Its authors call the classes not statistically significant, and the registry
records that the tree's cross-validation rejected every split and the classes used were grown with a relaxed
complexity parameter (row 80, note). The model is also not validated against fish it was not fitted to
(`validation = none`).

Flow needs, a different quantity, bound nothing in the grid: they ask what a stream needs, not how large a stream must
be to hold fish. Raleigh et al. (1984) rate a base flow (the lowest flows of late summer to winter) under 25 % of the average annual
daily flow poor, 25 to 50 % fair and 50 % or more excellent for trout (rows 1039, 1040; Ford et al. 1995 print the
excellent class as 55 %, row 961, which the original does not); Hatfield et al. (2002)'s fish periodicity charts set
juvenile rainbow rearing at 20 % of the mean annual discharge on the Nechako River and Sinmax Creek (rows 975, 980);
the Blackwater instream flow study recommends a minimum monthly flow of 0.130 m³/s for rainbow juveniles in Middle
Davidson Creek and finds 0.268 m³/s gives the most habitat (rows 987, 986); and
Hatfield & Bruce (2000) regress the flow giving the most habitat on the mean annual flow, for fry and for juveniles
(rows 1018, 1019).

The expectation, then, is a width floor at the low end of Porter's window (about 2 m, though theirs is a modelled
bankfull width and link's is a channel width) or below it, and no tight gradient limit: a source that rates steeper
streams medium and not low. link's `default` (width ≥ 1.5 m, gradient ≤ 8.49 %) is at the low end on width and tighter
than Porter's tree on gradient. The sources fix neither a width floor nor a gradient limit, so the grid has to.

## Evidence

13,578 stream-branch electrofishing visits (3,514 with RB) in 160 groups in link's RB range with no natural barrier
downstream; 12,959 of them (3,513 with RB), in the 129 groups where rainbow were both caught and missed, are modelled:
the largest population of any key. Rainbow were caught on 27.1 % of them. Half the modelled visits are on streams under
0.07 m³/s of modelled flow (63 % under 0.15). On visits with a width, detection climbs with it: 10.3 % under 1.5 m,
17.0 % at 1.5 to 2 m, 23.7 % at 2 to 3, 32.2 % at 3 to 4, 38.0 % at 4 to 6, 45.1 % at 6 to 10 and 46.1 % at 10 m or
more. On gradient it falls gently, with no step: 31.0 % of the visits at 3 % or less, 32.7 % at 3 to 5.49 %, 25.0 % at
5.49 to 8.49 %, 21.6 % at 8.49 to 12 %, 18.8 % at 12 to 20 %, 16.9 % at 20 to 30 % and 11.1 % above 30 %. These raw
rates mix width and gradient (steep streams are small), so the tuning, which holds the data set, era and group fixed,
is what separates them.

**The export does not separate resident rainbow from juvenile steelhead.** Porter et al. say so for the same records:
their rainbow row is "juvenile O. mykiss in FDIS; steelhead not separated" (row 475, note; row 80, note). The export
bears this out: among the modelled visits inside link's steelhead range with no natural barrier to steelhead
downstream (4,726 visits in 56 groups), rainbow were caught on 1,185 and steelhead on 78, and no visit caught both;
across all of the export's visits rainbow were recorded on 9,458 and steelhead on 254, both on 3. That is consistent
with one fish being recorded under one name per visit and mostly under the rainbow code; it does not show which fish
were migratory, and nothing in the tables does. The rule below is therefore a rule for juvenile *O. mykiss* as the
export records them, resident and anadromous together: 1,185 of the 3,513 detections lie in steelhead range, and the
rule separates there as it does elsewhere (caught on 39.3 % of the visits it admits and 11.0 % of the rest inside
steelhead range, 41.5 % and 17.5 % outside it). `steelhead_rearing_tuned.md` is tuned on the 82 detections the export
calls steelhead, a different and much thinner record of the same fish.

## Recommended rule: width ≥ 3 m, gradient ≤ 30 %, no exception

Two departures from `default`. The best rule in the grid is this rule, so the pick, the recommendation (the exception
distance is not at issue with no exception) and the 1.96 SE pick on the width start are the one rule, and it has the
same two departures from link's flow start as from the width start. It is 302.9 deviance ahead of `default` (SE
104.8, 2.89 SEs); the rule admits 6,055 visits and rainbow were caught on 2,461 (40.6 %), against 1,052 of 6,904 (15.2 %)
outside it (`default`: 2,586 of 7,122, 36.3 %, against 927 of 5,837, 15.9 %).

**The region** (every rule within one SE of the best, a rule of thumb fixed before the run, not a boundary of noise)
holds 14 rules: width 3 m in 11, 4 m in one and 2 m in two, at a gradient limit of 20 or 30 %, 13 of them with a
near-river exception (Q 1 to 50 m³/s within 100 or 250 m). None is a MAD rule and none is within one departure of
`default`. **`default` is outside it**, as is link's `default_tuned` floor (MAD ≥ 0.019 m³/s at 8.49 %, link#331: 281.5
behind, SE 116.6, 2.41 SEs) and `default`'s own width floor written as flow (MAD ≥ 0.021 m³/s at 8.49 %: 262.0, SE
116.6).

**The 1.96 SE reading** (#79) holds 463 rules: 388 width and 75 MAD rules, widths 2, 3 and 4 m, MAD floors 0.019 and
0.021 m³/s, gradient limits 7 to 30 %, 19 with no exception. `default` is still outside it. The pick from the width
start is the same rule; from the flow start it is MAD ≥ 0.021 m³/s, gradient ≤ 11 %, no exception, which keeps
`default`'s size test in flow form and moves only the gradient. At the stricter bar the size test cannot be told from
`default`'s MAD floors, and a width floor of 1.5 m falls just outside (1.98 SEs); the gradient limit still separates.

**What the checks say** (each listed with its direction, and what it counts):
- *Nested selection* (the pick chosen on four folds, scored on the fifth): all five folds choose this exact rule, so
  its nested score is its own, 11,651.9, against `default`'s 11,954.8 and 12,617.4 for no rule. It beats `default` on
  four folds, by 48.3 to 92.7, and loses to it on the fifth by 4.0. For the rule.
- *Four more fold seeds* (exact rule): all four recommend this exact rule, it is in the region on all four (regions of
  20, 13, 27 and 11 rules) and `default` is outside on all four. For.
- *Group bootstrap* (200 resamples, width start | flow start; the share recommending any rule at the value, except
  the last): width as the size variable in 98.0 | 91.5 %, a 3 m floor in 70.5 | 69.5 %, 2 m in 19.5 | 15 %, 4 m in 7 | 7 %; gradient 30 % in 76.5 | 74 %, 20 %
  in 17 | 14.5 %, 8.49 % in 2.5 | 2 %; no exception in 88 | 87.5 %. The exact rule in 62 | 60.5 % of resamples and
  inside the region in 81.5 %. For the width, the 3 m floor and the high gradient limit; the exception is the part the
  resamples spread over.
- *Profiles* (best rule at each value, as deviance behind the best, SE): width 3 m best, 4 m +80.2 (94.2), 2 m +81.5
  (75.4), 1.5 m +192.4 (97.1), 1 m +353.3 (110.2); the best MAD floor, 0.021, +195.6 (115.6), 0.1 +348.2, 1.0 +699.2.
  Gradient 30 % best, 20 % +10.5 (52.8), 25 % +25.5 (11.3), 15 % +63.8 (59.5), 11 % +108.5 (85.4), 9 % +160.7 (95.0),
  8.49 % +193.6 (93.2), 5.49 % +309.4 (104.6), 4 % +419.8 (121.7), 3 % +643.0 (134.2). Exceptions: none best, then Q1 at
  250 m +10.5. For a width floor between 2 and 4 m and against any limit under about 20 %.
- *The ladder's edge.* The best gradient limit is the top rung, so nothing here shows that a limit above 30 % would
  not do as well; 261 of the 12,959 visits (2.0 %) are steeper. Against reading 30 % as a placed limit.
- *The joint curve* (width × distance to a 10 m³/s river, gradient; edf 20.3, 4.6, group effect 113.7) scores 9,409.8
  held-out, 2,242.1 below the grid's best and 3,207.6 below no rule: the largest gap of any key. Against a cut being
  all the structure there is (below).
- *The #57 pick moved.* #57 chose width ≥ 3 m, gradient ≤ 9 % on a grid of 3,612 rules whose gradient ladder ended at
  9 %; it was recommended by 4 % of resamples and in the region on 1 of 4 more seeds. This grid holds 7,740 rules to 30 %,
  and the same rule at 9 % is 185.1 behind the best (SE 84.3, 2.2 SEs). The ladder could not have shown that in
  #57; the old ladder was not rerun on the new evidence, so the move has two candidate causes (the longer ladder, and
  the rebuilt evidence and prior), and the rule's stability on the new run is the better reason to trust it.

## What it is not

- **Not a gradient limit of 30 %.** The ladder ends there. The visits above 20 % are 735 (5.7 %) and rainbow were caught
  on 109 of them (14.8 %); Porter's tree sets no limit either (row 478). The curve's gradient term rises from a rate of 0.143 at 0 %
  to a peak of 0.228 near 3.9 %, falls to 0.159–0.181 from 9 to 19 % and reads 0.195 at 20 %, where it is drawn to: no
  drop toward a limit. What the
  evidence supports is that a limit of 8.49 % refuses streams that still catch rainbow: the visits at 3 m or wider,
  between 8.49 and 30 %, are 1,106 and rainbow were caught on 410 of them (37.1 %), against 41.4 % at 8.49 % or less.
  link's access gate is a separate rule and is not tested here.
- **Not a statement that streams under 3 m are poor rainbow habitat.** The 3,983 measured visits under 3 m caught
  rainbow 754 times (18.9 %), and on the 3,080 between 1.5 and 3 m, 21.5 %. The curve rises smoothly with width (a
  rate of 0.007 at 0.5 m, 0.060 at 1.48 m, 0.174 at 3.06 m, peaking at 0.386 near 17 m, and 0.223 at 162 m with a very
  wide interval) and the 3 m cut is where a yes-or-no test best separates held-out detection.
- **Not a rule for streams of unmeasured width.** fwapg models a width only where `stream_order > 1`, so an unmeasured
  first-order stream has no width and fails any width rule: 2,911 modelled visits (22.5 %) have none and rainbow were
  caught on 294 of them (10.1 %). A width rule cannot see those streams and the grade covers none of them; `default` misses them too, and a flow rule would see them.
- **Not a steelhead rule, and not a resident-only rule.** See Evidence: the records are juvenile *O. mykiss* of either
  life history.
- **A rate per standard electrofishing visit, not capacity or density.**

## Grade (`knowledge/habitat_grade/v1`; `scripts/0320`, 2026-10-24)

The grade is the curve's predicted rate at the reference nuisance values and a segment's own distance to a 10 m³/s
river, over the rate at the 95th percentile of accessible stream-branch segments, capped at 1 and read in fifths. It is
a ranking of where an electrofishing visit is more likely to catch rainbow, not a density. Graded because the curve
earns it: 9,409.8 held-out against 12,617.4 for no rule (a curve that predicted unseen groups worse than one constant
rate could not rank segments, and the three keys where that happened get no grade).

Every accessible segment of the 210 groups is walked from its downstream end to the first ≥ 10 m³/s river, ending at a
double-line river's bank (#73), and read on the flows wet republished on 2026-10-19 (the table records the load). Of
10,331,001 segments, 2,350,883 are accessible and 1,221,351 graded; the reference rate is 0.448 over edge types 1000,
1100, 2000 and 2300. **Of the 509,975 accessible km only 277,539 (54 %) are graded**, and they sum to 117,596
grade-weighted km. The 232,436 km left out have no width (1,127,940 segments, 99.9 % of them first order) or, for 1,592 segments that have a width, no predicted rate (the cause was not traced): the width rule's blind spot is a hole in the grade, and a rule on flow would not leave it. The graded
km are 30.8 % under 0.2 and 14.5 % at 0.8 to 1 (85,596 and 40,149 km). 36,435 km read a distance of 0, where the
curve is an extrapolation (`habitat_thresholds_tuned.md`, Limits); 18,941 km found their river in another watershed
group and 19,010 found none within the cap. The curve's prior (sd 2.5) is recorded on the table.

## What the rule changes on link's segments (`scripts/0330`, `data/compare/RB_rear_*`)

The baseline is `default` regenerated through fresh's predicate, the user-habitat overlay and connectivity on link's 210
RB groups (`configs/default` at `102762da`), gated on `streams_access`; through-wetland lines (edge 1050/1150) go
through the gradient and size door (link#364). The tuned rule is set beside it under two structures; having no
exception, it has no third:

| structure | tuned km | change | lost | gained | of the gain, through-wetland lines | graded km, `default` → tuned |
|---|---|---|---|---|---|---|
| free pass on through-wetland lines (as the rule was scored) | 194,307 | −11.3 % | 45,037 | 20,189 | 8,603 | 99,441 → 93,416 |
| door on through-wetland lines (link's `stream`) | 180,951 | −17.4 % | 49,797 | 11,593 | 7 | 99,441 → 92,150 |

`default` draws 219,156 km. Under the door, 44,368 km are lost to the width floor (streams 1.5 to 3 m wide) and 5,429
km are through-wetland lines that pass `default`'s door and fail the tuned one; 11,402 km are gained between the two
gradient maxima, 184 km on the river-polygon branch or mixed, and 7 km through-wetland. The gained km are 130 km of order
1 (unmeasured streams stay out), 2,224 of order 2, 5,694 of order 3 and 3,544 of order 4 or above. Across groups the change
runs from −41.4 % to +33.2 %, median −14.8 %; of the 185 groups with habitat under `default`, 48 gain, 135 lose and 2 are unchanged.

**Checks.** FDIS detection on each rule's segments against accessible segments outside it: `default` 33.7 % against
15.2 % (3,941 of 11,692 visits, 966 of 6,338); the tuned rule 34.4 % against 16.5 % with the free pass (3,713 of
10,784; 1,194 of 7,246) and 35.0 % against 16.4 % with the door (3,672 of 10,494; 1,235 of 7,536). These visits are
every one the compare table places on accessible segments, a wider set than the 12,959 the rule was scored on. On the
bcfishobs records FDIS does not hold (presence only, never scored), the share of locations on the rule's segments over
the rule's share of accessible stream-edge km is 2.337 (2.309 to 2.364) for `default` and 3.033 (2.990 to 3.073) for
both structures; the lift over `default` is 0.696 (0.651 to 0.732). **The two structures cannot be told apart by either
check**, and the scoring never saw a through-wetland line, so the structure is link's call: `door` is what link#364
chose and what the thresholds table records (`0325`, 2026-10-25: `near_river_scope` empty, the rule having no pair).

**link's stored flags.** The regenerated `default` differs from link's stored RB rearing flags on 55,242 km, more than
for any other key (the next, bull trout rearing, 9,243), and the cause is the access gate: link's two access columns
disagree most for RB (`data/fdis/derived/access_check.csv`: 481,275 habitat-accessible segments with `streams_access`
blocking, 147,445 of them rearing; 102,578 km). In 23 of the 210 groups every segment has `access_rb = 0` (BRID CANO
CARP CLRH CRKD FINA FINL FIRE FOXR INGR LEUT LOMI MAHD MESI MURT NATR OSPK PARA PARS PCEA TURN UEUT UOMI), so they carry
no grade, and two more (TOOD, UNRS) draw no km under `default`: 25 groups draw none under either rule. The grade is
gated on `streams_access` until link settles which column is meant (NewGraphEnvironment/link#349).

The floodplain table (`data/compare/floodplain.csv`) and the maps (`research/fig/compare_rb_rear_*.png`) were not redrawn
for #73 (`0330 STAGE=maps`): they show #65's `width>=3|g<=0.09|none` rule on the 23 catalog groups, not this one.
