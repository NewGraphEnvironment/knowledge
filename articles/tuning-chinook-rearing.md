# Tuning habitat: chinook rearing

Young chinook salmon do not always rear where they hatched: from earlier
fish inventories in Alaska, Kirsch et al. recommend looking for more
chinook rearing in the lower reaches of small tributaries, other than
the ones they hatched in, of large rivers that hold chinook ([2014,
42](#ref-kirsch_etal2014Fishinventory)). British Columbia’s
electrofishing records point the same way, putting young chinook in more
of the province’s small streams near large rivers, and in fewer far from
one, than link’s current fish habitat definition allows.
[`link`](https://www.newgraphenvironment.com/link/) ([Irvine
2026b](#ref-link)) is an R package that maps where each fish species can
reach and where it can spawn and rear on BC’s streams. Its standard
settings,
[`default`](https://github.com/NewGraphEnvironment/link/tree/4dfbfa4980eb259e2f6a3e9b198c54014315d0ce/inst/extdata/configs/default),
start from the thresholds New Graph runs bcfishpass with ([Norris
2024b](#ref-norris2024smnorrisbcfishpass)): for chinook rearing, a slope
of at most 5.49 %, and a channel at least 1.5 m wide. The records
support **a slope of at most 13 %, and either an average flow of at
least 0.75 m³/s or a river of at least 3 m³/s within 1 km downstream**.
[How the tuning
works](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.md)
says [what a habitat definition
is](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.html#thresholds),
and how one is tested and tuned.

In the Bulkley watershed group, around Smithers, the recommended habitat
definition draws 1,494 km of rearing habitat against 2,101 under link’s.
What it drops (orange) is mostly the upper reaches of tributaries, where
flow falls below its floor more than 1 km from a river. What it adds
(green) is short reaches of small streams beside a river. The rest comes
from the two habitat definitions’ own slope and flow limits, and from
link’s step that keeps rearing only where it connects to spawning: that
step keeps different stretches under each. Click a stream for what each
habitat definition reads there; the switch at the top right shows the
grade, the use to expect on each segment.

## What changes?

The recommended habitat definition draws less habitat than link’s, and
chinook are caught on it more often and off it less often.

|  | link now | Recommended |
|:---|---:|---:|
| Smallest stream | 1.5 m channel width | 0.75 m³/s average flow |
| Steepest slope | 5.49 % | 13 % |
| Near a river | none on stream lines | smaller streams within 1 km of a 3 m³/s river |
| Rearing habitat | 102,951 km | 88,458 km |
| Sites with chinook, on the habitat | 14 % | 18 % |
| Sites with chinook, elsewhere | 2.3 % | 1.3 % |
|  Habitat is summed over the 136 watershed groups link classified for chinook when the comparison ran, each habitat definition run through all of link’s steps. Both totals include lines through wetlands, which the two habitat definitions test differently (below). Sites are the 11,762 electrofishing sites of a usual fished area on reachable stream, river and wetland lines in those groups, a wider set than the one the habitat definition was chosen on. They overlap the sites it was chosen on, so the rates show it does what it was chosen to do, not that it predicts new places. |  |  |

Chinook rearing under link’s current habitat definition and the
recommended one. {.table .table
style="width: auto !important; margin-left: auto; margin-right: auto;border-bottom: 0;"}

## Why does a nearby river matter?

Young chinook move up from large rivers into small streams close by.
bcfishpass writes that idea with stream order: where streams are sized
by width, a first-order stream whose parent is order 5 or more counts as
rearing below the minimum width, if its width is mapped, along its whole
length ([its chinook
model](https://github.com/smnorris/bcfishpass/blob/3bd2824c300c5f9c0c041380d412a52987df1ebb/model/02_habitat_linear/sql/load_habitat_linear_ch.sql)).
link’s `default` leaves that exception off. A model fitted after the
choice shows the same idea in the records, with a distance on it:

![The fitted chance of catching chinook on one standard visit, by
distance downstream to a river of at least 3 m³/s, for four stream
flows, at a slope of 6.5 %. The dashed line is the recommended habitat
definition's 1 km allowance: beyond it, streams below its 0.75 m³/s
floor no longer count (grey). The fit is shown at six distances; the
last stands for 50 km or more, or no such river, and is not
joined.](tuning-chinook-rearing_files/figure-html/river-1.png)

The fitted chance of catching chinook on one standard visit, by distance
downstream to a river of at least 3 m³/s, for four stream flows, at a
slope of 6.5 %. The dashed line is the recommended habitat definition’s
1 km allowance: beyond it, streams below its 0.75 m³/s floor no longer
count (grey). The fit is shown at six distances; the last stands for 50
km or more, or no such river, and is not joined.

Within 100 m of a river the chance is about the same whatever the
stream’s flow, 11.4 % to 12.5 %. Ten kilometres away it rises with flow,
from 0.3 % to 3.1 %. That is the shape the recommended habitat
definition draws: beside a river a small stream counts, away from one
only a larger stream does.

## How sure are we?

Scores carry error: another draw of watersheds would rank close habitat
definitions differently. So the tuning treats every habitat definition
within one standard error of the best as a close call, a convention
fixed before the run ([how two habitat definitions are told
apart](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.html#se)).
For chinook, 169 of 6,149 habitat definitions are close calls, all with
a flow floor of 0.1 to 1 m³/s, the near-a-river allowance, and a slope
limit of 7 % or more. The tie-break fixed in advance takes the close
call nearest link’s; all differ from link’s on stream lines in every
dial, so it is the best scorer. link’s habitat definition is 2.6
standard errors behind it.

![How close the best habitat definition using each value of each dial
comes to the best overall, as score above the best (lower is better).
Dark blue: at least one habitat definition with that value is a close
call at one standard error; light blue: only at 1.96 standard errors;
white: neither. The orange ring marks the value of link's habitat
definition on stream
lines.](tuning-chinook-rearing_files/figure-html/profile-1.png)

How close the best habitat definition using each value of each dial
comes to the best overall, as score above the best (lower is better).
Dark blue: at least one habitat definition with that value is a close
call at one standard error; light blue: only at 1.96 standard errors;
white: neither. The orange ring marks the value of link’s habitat
definition on stream lines.

The flow floors near the best are close calls at one standard error and
no width floor is; the slope limit is flat from 7 % up.

**A stricter bar.** At 1.96 standard errors, about the width of a 95 %
interval, more habitat definitions are close calls, and the same choice
holds:

|  | link now | Chosen at 1 SE | Chosen at 1.96 SE |
|:---|:---|:---|:---|
| Smallest stream | 1.5 m channel width | **0.75 m³/s average flow** | **0.75 m³/s average flow** |
| Steepest slope | 5.49 % | **13 %** | **13 %** |
| Near a river | none on stream lines | **smaller streams within 1 km of a 3 m³/s river** | **smaller streams within 1 km of a 3 m³/s river** |
|  Bold: differs from link’s. Close calls: 169 habitat definitions at one standard error, 2,297 at 1.96; link’s is a close call at neither. This package’s thresholds table (data/thresholds.csv, column rule_196) gives the choice at 1.96 for every species tuned. |  |  |  |

The chinook rearing habitat definition chosen from the close calls at
each bar, beside link’s current one. {.table .table
style="font-size: 13px; width: auto !important; margin-left: auto; margin-right: auto;border-bottom: 0;"}

**Three other checks.**

| Check | Result | Points to |
|:---|:---|:---|
| 4 other random splits into sets | the recommended habitat definition is a close call on 4 of 4; link’s on 0 | the recommended habitat definition |
| Chosen on four sets, scored on the fifth | the chosen habitat definition beats link’s on 4 of 5 and beats it overall | choosing from the records |
| 200 redraws of the groups | a flow floor is chosen in every draw; the recommended slope limit in 40 % | a steady shape; an unsettled slope limit |

## Before you use it

- **It is about young chinook in streams.** It was fitted to juvenile
  chinook caught by electrofishing in streams and says nothing about
  spawning. River polygons share the stream slope limit, so they get 13
  % too, though no site in one was scored. Lines drawn through wetlands
  of 1 ha or more were tested by neither habitat definition’s records.
  In the comparison, link’s counts them by their size or by a
  near-a-river pair, and the recommended one puts them through the same
  test as a stream line, which leaves about 2,500 km of them as chinook
  rearing under the recommended habitat definition, with a median grade
  of 0.38, against 8,200 km under link’s. Lakes keep their own
  condition.
- **The cut-offs are a judgment call.** Chinook get gradually less
  common as streams get smaller and steeper; there is no flow or slope
  where they stop. At one standard error, flow floors of 0.1 to 1 m³/s
  fit almost as well, and at 1.96 standard errors the choice is the
  same.
- **Steeper slopes fit nearly as well.** The close calls run from 7 % to
  30 %, the top of the list, and 13 % is the best scorer among them, not
  a slope at which chinook stop.
- **It was not tested against bcfishpass’s own exception.** The
  candidates never included the stream-order exception above, so the
  records show that the flow-and-distance allowance beats link’s
  `default`, not that it beats bcfishpass’s.
- **On the map, distance is measured from the bottom of each segment.**
  To choose the habitat definition, the distance to a river’s bank was
  measured from each site. On the map it is measured from each segment’s
  downstream end, so when that end is within 1 km of the river the whole
  segment counts.

## How was this done?

| Step | For chinook rearing |
|:---|:---|
| Records | The Fisheries Data Information System’s electrofishing sites ([Province of British Columbia 2022](#ref-provinceofbritishcolumbia2022FisheriesData)): where crews fished, and whether they caught chinook. 7,823 sites in 111 watershed groups: those on ordinary stream lines, of a usual fished area, with no code in the catch that could hide chinook and no barrier to chinook downstream, in groups where link expected chinook when the tuning ran; the tests use the 45 groups where chinook were caught at some sites and not others, **4,858 sites, 234 with chinook**. ([More](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.html#steps)) |
| Placement | Each site went onto the BC Freshwater Atlas, loaded by fwapg ([Norris 2024c](#ref-norris2024smnorrisfwapg)). A site whose 1:50k tributary code the Atlas’s crosswalk knows went to the nearest stream that code names, kept when it lay within 500 m of the point, and was dropped otherwise; a site with no such code went to the nearest stream, kept when it lay within 200 m. ([More](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.html#snap)) |
| Flow | wet’s modelled average flow ([Irvine 2026c](#ref-wet)): PCIC’s VIC-GL runoff ([Schnorbus 2018](#ref-schnorbus2018VICGlacierVICGL)) routed with Raven ([Craig et al. 2020](#ref-craig_etal2020Flexiblewatershed)) and carried onto Atlas streams by a crosswalk in New Graph’s fork of fwapg ([Norris and Irvine 2026](#ref-norris_irvine2026NewGraphEnvironmentfwapg)), with wet’s own water balance where that flow does not reach or, on a stream’s own line, carries under a fifth of the balance’s. |
| Slope | The slope of the link segment a site sits on, the one link tests a habitat definition on. link can cut a stream at a site that caught a species it models, so a site with chinook can start a short segment of its own. |
| Candidates | 6,149 habitat definitions, link’s among them, from three dials: the smallest stream (an average flow of 0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75 or 1 m³/s, or a channel width of 1, 1.5, 2, 3 or 4 m); the steepest slope (3 %, 4 %, 5.49 %, 7 %, 9 %, 11 %, 13 %, 15 %, 20 %, 25 % or 30 %); and a near-a-river allowance (none, or a river of 1, 3, 5, 10, 20, 30 or 50 m³/s within 100, 250, 500, 1,000, 2,000 or 5,000 m downstream). |
| Scoring | The groups were split into 5 sets, and each set was predicted by a model fitted to the others. The score adds up how far each prediction was from what the crew found; lower is better. ([More](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.html#se)) |
| Run by | fresh ([Irvine 2026a](#ref-fresh)), through all of link’s steps for the map and the habitat totals. |
| Left out | The province’s other fish observations, gathered in bcfishobs ([Norris 2024a](#ref-norris2024smnorrisbcfishobs)): they record where fish were found, not where they were sought and missed. Sites off ordinary stream lines, of an unusual fished area, with a code in the catch that could hide chinook, or with a barrier to chinook downstream. ([More](https://newgraphenvironment.github.io/knowledge/articles/tuning-method.html#lost)) |

How the chinook rearing habitat definition was tested. {.table}

## Software and citation

Each tool is cited where it is first used. To cite this package,
`citation("knowledge")` gives:

Irvine A (2026). *knowledge: Tests Fish Habitat Definitions Against What
is Known About Where Fish Live, and Tunes Them from the Fish Records*.
New Graph Environment Ltd. <doi:10.5281/zenodo.23990335>
<https://doi.org/10.5281/zenodo.23990335>. Version 0.4.37,
<https://newgraphenvironment.github.io/knowledge/>.

## References

Craig, James R., Genevieve Brown, Robert Chlumsky, et al. 2020.
“Flexible Watershed Simulation with the Raven Hydrological Modelling
Framework.” *Environmental Modelling & Software* 129 (July): 104728.
<https://doi.org/10.1016/j.envsoft.2020.104728>.

Irvine, Allan. 2026a. *fresh: Freshwater Referenced Spatial Hydrology*.
Version 0.52.0. New Graph Environment Ltd.
<https://doi.org/10.5281/zenodo.23524744>.

Irvine, Allan. 2026b. *link: Develop, Test and Communicate Intrinsic
Habitat and Connectivity Models for the BC Freshwater Atlas Stream
Network*. Version 0.78.2. New Graph Environment Ltd.
<https://doi.org/10.5281/zenodo.23264990>.

Irvine, Allan. 2026c. *wet: Stream Flow and Water Temperature for the BC
Freshwater Atlas*. Version discharge/fwa/v1. New Graph Environment Ltd.
<https://doi.org/10.5281/zenodo.23305781>.

Kirsch, Jonathan M., Joseph D. Buckwalter, and Daniel J. Reed. 2014.
*Fish Inventory and Anadromous Cataloging in the Susitna River,
Matanuska River, and Knik River Basins, 2003 and 2011*. Fishery Data
Series. Alaska Department of Fish and Game, Divisions of Sport Fish and
Commercial Fisheries.
<https://www.adfg.alaska.gov/FedAidPDFs/FDS14-04.pdf>.

Norris, Simon. 2024a. *bcfishobs*.
<https://github.com/smnorris/bcfishobs>.

Norris, Simon. 2024b. *bcfishpass*.
<https://github.com/smnorris/bcfishpass>.

Norris, Simon. 2024c. *fwapg*. <https://github.com/smnorris/fwapg>.

Norris, Simon, and Allan Irvine. 2026. *fwapg, New Graph Environment’s
fork*. Version 7c30f58. New Graph Environment Ltd.
<https://github.com/NewGraphEnvironment/fwapg/tree/newgraph>.

Province of British Columbia. 2022. “Fisheries Data Information System
(FDIS) Electrofishing Extract.” Electrofishing extract, exports of
2020-11-16 and 2022-03-22.

Schnorbus, Markus A. 2018. *VIC-Glacier (VIC-GL): Description of VIC
Model Changes and Upgrades*. Pacific Climate Impacts Consortium,
University of Victoria. <https://hdl.handle.net/1828/21631>.
