# Chinook rearing: choosing link's thresholds from fish records

New Graph Environment maps where fish can live in British Columbia’s
streams with [`link`](https://www.newgraphenvironment.com/link/)
([Irvine 2026b](#ref-irvine2026linkDevelop)), an R package that marks
every stream segment as spawning or rearing habitat for each species,
and as reachable by fish or not. Its standard settings, called
[`default`](https://github.com/NewGraphEnvironment/link/tree/a17e91773b283b021811f8b5b76b887d5f4c16e4/inst/extdata/configs/default),
start from those [bcfishpass](https://smnorris.github.io/bcfishpass/)
has used for years ([Norris 2024b](#ref-norris2024smnorrisbcfishpass)).
This article tests one of them, where young chinook salmon rear, against
the province’s electrofishing records.

**The answer.** The records support a different rule from link’s current
one: **a slope of at most 11 %, and either an average flow of at least
0.75 m³/s or a river of at least 3 m³/s within 1 km downstream**. link
now asks for a slope of at most 5.49 %, and a channel at least 1.5 m
wide. The new rule draws 15.9 % less habitat across the province, and
chinook are caught far more often inside it than outside. Its cut-offs
are a judgment call, though: under a stricter bar the slope limit goes
back to link’s (below).

## What does link do now?

link counts a stream segment as chinook rearing habitat when chinook can
reach it, its slope is at most 5.49 %, and its channel is at least 1.5 m
wide. link can size streams by width or by flow, set group by group. Its
`default` uses width in every group, and every comparison here is
against that. link’s own flow cut-offs were scored as candidates, not
used as the starting point. Rivers, wetlands and lakes have their own
conditions (last section).

## What records were used?

The province’s stream atlas divides British Columbia into **watershed
groups**, large basins such as the Bulkley. The records are the
Fisheries Data Information System’s electrofishing sites ([Province of
British Columbia
2022](#ref-provinceofbritishcolumbia2022FisheriesData)): where crews
fished, and whether they caught chinook. Each site’s mapped point was
snapped to the BC Freshwater Atlas, loaded by fwapg ([Norris
2024c](#ref-norris2024smnorrisfwapg)). Where FDIS recorded the site’s
1:50k tributary code and the Atlas’s 1:20k-1:50k crosswalk knows it, the
point went to the nearest stream that code names, kept when it lay
within 500 m of the point; otherwise it went to the nearest stream, kept
when it lay within 200 m. The site then took link’s segment at that
point. Each segment’s flow is wet’s default ([Irvine
2026c](#ref-irvine2026wetStream)): PCIC’s modelled flow, VIC-GL runoff
([Schnorbus 2018](#ref-schnorbus2018VICGlacierVICGL)) routed with Raven
([Craig et al. 2020](#ref-craig_etal2020Flexiblewatershed)) on PCIC’s
own network and carried onto Atlas streams by a crosswalk in New Graph’s
fork of fwapg ([Norris and Irvine
2026](#ref-norris_irvine2026NewGraphEnvironmentfwapg)), with wet’s own
water balance where that flow does not reach or, on a stream’s own line,
carries under a fifth of the balance’s. A site’s gradient is its link
segment’s, the gradient link applies a rule to, worked out from the
segment’s own ends; link can cut a stream at a site that caught a
species it models, so a site with chinook can start a short segment of
its own. fresh ran the rules ([Irvine
2026a](#ref-irvine2026freshFreshwater)). The province’s other fish
observations, gathered in bcfishobs ([Norris
2024a](#ref-norris2024smnorrisbcfishobs)), scored no rule: they record
where fish were found, not where they were sought and missed. Sites were
kept when they were on ordinary stream lines, of a usual fished area,
with no barrier to chinook downstream, in a group where link expects
chinook: 7,659 sites in 105 groups. The tests use the 45 groups where
chinook were caught at some sites and not others: **4,858 sites, 234
with chinook**.

## How were rules compared?

Each candidate rule sets three dials:

- **the smallest stream**: an average flow of 0.1, 0.15, 0.2, 0.28,
  0.35, 0.5, 0.75 or 1 m³/s, or a channel width of 1, 1.5, 2, 3 or 4 m;
- **the steepest slope**: 3 %, 4 %, 5.49 %, 7 %, 9 %, 11 %, 13 %, 15 %,
  20 %, 25 % or 30 %;
- **a near-a-river allowance**: none, or a stream below the smallest
  size still counts when a river of 1, 3, 5, 10, 20, 30 or 50 m³/s is
  within 100, 250, 500, 1,000, 2,000 or 5,000 m downstream.

That makes 6,149 rules, link’s among them. Each was scored on watersheds
it never saw: the groups were split into 5 sets, and each set was
predicted by a model fitted to the other four. The score adds up how far
each prediction was from what the crew found; lower is better.

## Which rule fits best, and how sure are we?

**Close-call rules.** Scores carry error: another draw of watersheds
would rank close rules differently. So the tuning kept every rule within
one standard error of the best. That rule of thumb began with pruning
classification trees ([Breiman et al.
1984](#ref-breiman_etal1984ClassificationRegression); as cited in [Chen
and Yang 2021](#ref-chen_yang2021OneStandard)) and is now a common way
to prefer the simpler of close models ([Hastie et al.
2009](#ref-hastie_etal2009ElementsStatistical)). It is a convention
fixed before the run, not a line below which rules are equal. There is
no evidence it consistently beats taking the best score, though it often
picks fewer variables ([Chen and Yang
2021](#ref-chen_yang2021OneStandard)). The error it rests on has no
unbiased estimate ([Bengio and Grandvalet
2004](#ref-bengio_grandvalet2004NoUnbiased)), and the usual estimate is
often too small ([Bengio and Grandvalet
2004](#ref-bengio_grandvalet2004NoUnbiased); [Bates et al.
2024](#ref-bates_etal2024CrossValidationWhat)), though it can also be
too large ([Chen and Yang 2021](#ref-chen_yang2021OneStandard)). For
chinook, 164 rules are close calls, all with a flow floor of 0.1 to 1
m³/s, the near-a-river allowance, and a slope limit of 7 %, 9 %, 11 %,
13 %, 15 %, 20 %, 25 % or 30 %. From them, the rule fixed in advance
takes the one closest to link’s; all differ in every dial, so it is the
best scorer. link’s rule is 2.5 standard errors behind it. It calls
fewer sites habitat (1,448 against 2,571) and catches more chinook there
(198 against 178).

![How close the best rule using each value of each dial comes to the
best rule overall, as score above the best (lower is better). Dark blue:
at least one rule with that value is a close call at one standard error;
light blue: only at 1.96 standard errors; white: neither. The orange
ring marks link's current
value.](chinook_rearing_files/figure-html/profile-1.png)

How close the best rule using each value of each dial comes to the best
rule overall, as score above the best (lower is better). Dark blue: at
least one rule with that value is a close call at one standard error;
light blue: only at 1.96 standard errors; white: neither. The orange
ring marks link’s current value.

The flow floors near the best are close calls at one standard error and
no width floor is; the slope limit is flat from 7 % up.

**A stricter bar.** Widen the close calls to 1.96 standard errors and
2,456 rules are close calls instead of 164. The same choice then
changes:

|  | Close-call rules | Smallest stream | Steepest slope | Near-a-river allowance |
|:---|---:|:---|:---|:---|
| Chosen at one standard error | 164 | 0.75 m³/s average flow | 11 % | a 3 m³/s river within 1 km |
| Chosen at 1.96 | 2,456 | 0.75 m³/s average flow | 5.49 % | a 3 m³/s river within 1 km |
| link’s current rule | outside both | 1.5 m channel width | 5.49 % | none |

The chinook rule chosen from the close calls at each bar, beside link’s
current rule. {.table}

The slope limit goes back to link’s 5.49 %, and the flow floor and the
near-a-river allowance stay as they were. link’s own rule is still not a
close call. link’s thresholds table gives the choice at 1.96 for every
species tuned (`rule_196`).

**Two other checks.** Split into sets again with 4 other random draws,
the recommended rule is a close call on 4 and link’s on 0. Chosen on
four sets and scored on the fifth, the chosen rule beats link’s on 4 of
5 and beats it overall. Redrawing the groups 200 times, a flow floor is
chosen in 99.5 % of draws but the recommended slope limit in only 46 %:
the shape is steady, the slope limit is not.

## Why does a nearby river matter?

Young chinook move up from large rivers into small streams close by. A
model fitted after the choice, with flow and distance to a river of at
least 3 m³/s together, gives the chance of a catch on one standard
visit:

| Stream flow (m³/s) |  100 m |  300 m |  1 km |  3 km | 10 km | 50 km or more |
|:-------------------|-------:|-------:|------:|------:|------:|--------------:|
| 0.1                | 10.2 % |  7.1 % | 2.7 % | 0.7 % | 0.3 % |         0.3 % |
| 0.3                | 11.0 % |  9.0 % | 4.2 % | 1.3 % | 0.6 % |         0.8 % |
| 0.75               | 11.3 % | 10.1 % | 5.6 % | 2.2 % | 1.3 % |         1.6 % |
| 2                  | 11.4 % | 10.6 % | 7.1 % | 3.9 % | 2.9 % |         3.3 % |

The fitted chance of catching chinook on one standard visit, by stream
flow (rows) and by distance downstream to a river of at least 3 m³/s
(columns), at a slope of 5.5 %. {.table}

Within 100 m of a river the chance is about the same whatever the
stream’s flow, 10.2 % to 11.4 %. Ten kilometres away it rises with flow,
from 0.3 % to 2.9 %. That is the shape the recommended rule draws:
beside a river a small stream counts, away from one only a larger stream
does.

## What changes on the ground?

Both rules were run through all of link’s steps on the 125 watershed
groups link classifies for chinook: 99,186 km of rearing habitat under
link’s rule, 83,435 km under the recommended one. The change ranges from
-76.1 % to 33.1 % by group. In the Bulkley the recommended rule draws
1,482 km against 2,096. On the map, click a stream for what each rule
reads there; the switch at the top right shows the grade, the use to
expect on each segment.

Orange is mostly the upper reaches of tributaries, where flow falls
below the floor more than 1 km from a river. Green is short reaches of
small streams beside a river. The rest of the change comes from the step
that keeps rearing only where it links to spawning, which keeps
different stretches under each rule.

**A check.** On the 11,532 electrofishing sites on reachable streams in
those groups, chinook were caught at 18 % of sites on the recommended
rule’s habitat and 1.4 % elsewhere, against 15 % and 2.2 % for link’s.
These sites overlap the ones scored, so this shows the rule does what it
was chosen to do, not that it predicts new places.

## Before you use it

- **It is about young chinook in streams.** It was fitted to juvenile
  chinook caught by electrofishing in streams and says nothing about
  spawning. River polygons share the stream slope limit, so they get 11
  % too, though no site in one was scored. Lines drawn through wetlands
  of 1 ha or more were tested by neither rule’s records: link now puts
  them through the same test as a stream line, and so does the
  comparison here, which leaves about 2,500 km of them as chinook
  rearing under the recommended rule, with a median grade of 0.34,
  against 8,400 km under link’s rule. Lakes keep their own condition.
- **The cut-offs are a judgment call.** Chinook get gradually less
  common as streams get smaller and steeper; there is no flow or slope
  where they stop. At one standard error, flow floors of 0.1 to 1 m³/s
  fit almost as well; at 1.96 the choice is 0.75 m³/s at link’s slope
  limit, with the allowance kept.
- **Steeper slopes fit nearly as well.** The close calls run from 7 % to
  30 %, the top of the list, and 11 % is the best scorer among them, not
  a slope at which chinook stop. The list was lengthened to 30 % after
  an earlier run of chinook alone on the longer list picked 15 %, with
  close calls from 7 % to 30 %; every species is now tuned on it. That
  run scored the slope of the whole Atlas line a site sat on, on an
  earlier build of the records, so its numbers are not this run’s.
- **On the map, distance is measured from the bottom of each segment.**
  To choose the rule, the distance to a river’s bank was measured from
  each site. On the map it is measured from each segment’s downstream
  end, so when that end is within 1 km of the river the whole segment
  counts.

## References

To cite this package, `citation("knowledge")` gives:

Irvine A (2026). *knowledge: Fisheries Evidence and Tuned Habitat
Thresholds for BC Watershed Groups*. New Graph Environment Ltd. Version
0.4.25, <https://newgraphenvironment.github.io/knowledge/>.

Bates, Stephen, Trevor Hastie, and Robert Tibshirani. 2024.
“Cross-Validation: What Does It Estimate and How Well Does It Do It?”
*Journal of the American Statistical Association* 119 (546): 1434–45.
<https://doi.org/10.1080/01621459.2023.2197686>.

Bengio, Yoshua, and Yves Grandvalet. 2004. “No Unbiased Estimator of the
Variance of K-Fold Cross-Validation.” *Journal of Machine Learning
Research* 5: 1089–105. <https://jmlr.org/papers/v5/grandvalet04a.html>.

Breiman, Leo, Jerome H. Friedman, Richard A. Olshen, and Charles J.
Stone. 1984. *Classification and Regression Trees*. The Wadsworth
Statistics/Probability Series. Wadsworth International Group.

Chen, Yuchen, and Yuhong Yang. 2021. “The One Standard Error Rule for
Model Selection: Does It Work?” *Stats* 4 (4): 868–92.
<https://doi.org/10.3390/stats4040051>.

Craig, James R., Genevieve Brown, Robert Chlumsky, et al. 2020.
“Flexible Watershed Simulation with the Raven Hydrological Modelling
Framework.” *Environmental Modelling & Software* 129 (July): 104728.
<https://doi.org/10.1016/j.envsoft.2020.104728>.

Hastie, Trevor, Robert Tibshirani, and Jerome Friedman. 2009. *The
Elements of Statistical Learning: Data Mining, Inference, and
Prediction*. 2nd ed. Springer Series in Statistics. Springer.
<https://doi.org/10.1007/978-0-387-84858-7>.

Irvine, Allan. 2026a. *fresh: Freshwater Referenced Spatial Hydrology*.
Version 0.39.0. New Graph Environment Ltd.
<https://github.com/NewGraphEnvironment/fresh>.

Irvine, Allan. 2026b. *link: Develop, Test and Communicate Intrinsic
Habitat and Connectivity Models for the BC Freshwater Atlas Stream
Network*. Version 0.66.0. New Graph Environment Ltd.
<https://doi.org/10.5281/zenodo.23264990>.

Irvine, Allan. 2026c. *wet: Stream Flow and Water Temperature for the BC
Freshwater Atlas*. Version discharge/fwa/v1. New Graph Environment Ltd.
<https://doi.org/10.5281/zenodo.23305781>.

Norris, Simon. 2024a. *bcfishobs*.
<https://github.com/smnorris/bcfishobs>.

Norris, Simon. 2024b. *bcfishpass*.
<https://github.com/smnorris/bcfishpass>.

Norris, Simon. 2024c. *fwapg*. Version f9718cb.
<https://github.com/smnorris/fwapg>.

Norris, Simon, and Allan Irvine. 2026. *fwapg, New Graph Environment’s
fork*. Version 7c30f58. New Graph Environment Ltd.
<https://github.com/NewGraphEnvironment/fwapg/tree/newgraph>.

Province of British Columbia. 2022. “Fisheries Data Information System
(FDIS) Electrofishing Extract.” Electrofishing extract, exports of
2020-11-16 and 2022-03-22.

Schnorbus, Markus A. 2018. *VIC-Glacier (VIC-GL): Description of VIC
Model Changes and Upgrades*. Pacific Climate Impacts Consortium,
University of Victoria. <https://hdl.handle.net/1828/21631>.
