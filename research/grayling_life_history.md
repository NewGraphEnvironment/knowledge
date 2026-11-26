# Arctic grayling life history: what the documents say

**Verified:** 2026-11-26 · **Issues:** #140 (this); the store is #122's `bull_trout_grayling` · **Produced by:** the
grayling documents of the group library listed in the #140 drafter brief, and the BC and Alaska originals filed for
#140 (the Parsnip telemetry, habitat and fry reports, the Omineca, Osilinka, Ingenika and Nation fry surveys, Adsett
Creek, the juvenile distribution study, the Omineca summary, the Trans Alaska Pipeline overview and the Little Smoky
River thesis), read in their PDF text, with each passage checked by `scripts/0280-literature-verify.R` · **Status:**
draft for #140's Phase 4, revised after a meaning audit; gaps at the end.

Each claim below is a plain sentence followed by the passage that carries it, quoted verbatim with its citation key
and page. Pages are the printed ones, with these exceptions, where the page is the PDF's:
- the summary of Stuart and Chislett 1979 (the Sukunka report), which carries no page number;
- the abstract of Tack 1980 (Alaska), which carries no page number.

Where a source reports another study, the sentence names it. Every claim says where it was measured: a BC drainage
(the Williston Reservoir watershed of the upper Peace, the Sukunka, a Pine River tributary beside the Williston watershed, or Adsett Creek in the
Liard), or the Northwest Territories, Alberta or Alaska, or range-wide where a review states it so. Habitat values
are the evidence table's grayling rows in `data/literature_evidence.csv`, and this file does not weigh them; where a
quote below prints a depth, width, gradient or velocity, the sentence says whether it is a limit or only where fish
were found.

## In brief

- **Mostly river fish in the upper Peace.** Grayling can be stream-resident, fluvial, adfluvial or lake-dwelling.
  In the Williston Reservoir watershed they complete their lives in rivers, often below headwater lakes; only the
  Toodoggone (upper Finlay) is known to hold a lake-inlet spawning population. They do not live in the reservoir,
  though eDNA and stray captures suggest some move through it.
- **Three habitats a year.** Adults move between overwintering water, spring spawning sites and summer feeding
  reaches. In the Parsnip they winter in the Parsnip mainstem, move up the tributaries around ice-out in late April
  and May, feed through the summer, and move back to the mainstem from September to November.
- **Spring spawners.** Spawning follows ice break-up, mostly mid-May to mid-June across the range. In BC no study has
  watched it: in the Sukunka it was estimated, from fry development, at mid-May to early June; in the Parsnip, from
  water temperature and fry emergence, at late May to late June, an estimate the tagged fish suggest may run a week
  late; in Adsett Creek (Liard) at mid to late May. The run starts as
  the ice goes and spawning as the water nears 4 °C. No redd is built: eggs go into small, loose gravel. Spawning
  sites in the Williston watershed are known only as suspected areas, inferred from tagged fish and fry.
- **Eggs hatch in weeks.** Incubation takes from about a week in warm water to about a month in cold, and fry leave
  the gravel a few days after hatching, in June or early July in the Williston and Liard streams studied.
- **Fry need slow, shallow margins.** Newly emerged fry are weak swimmers and hold in quiet margins, backwaters, side
  channels and pools on gravel bars near where they hatched. In some BC streams they move to faster, deeper water as
  they grow; in the Table and Anzac they tended to stay in water under 10 cm all summer. Floods or drought in the two
  weeks after hatching may kill many fry, and stranding as the water drops can also kill many.
- **Juveniles downstream, adults upstream.** In the Parsnip, yearlings appear to rear in the turbid Parsnip mainstem
  rather than the clear tributaries; adults spend the summer in pools of the clear tributaries and move upstream as the
  water drops. Across the Williston watershed juveniles were absent from the streams sampled below fourth order.
- **Winter in big water.** Grayling overwinter in larger rivers, lakes, deep pools or spring-fed water. In the
  Parsnip, tagged fish wintered spread along the mainstem, many in shallow, faster water. The flooding of the Peace,
  Finlay and Parsnip mainstems under Williston Reservoir took much of this habitat and is the likeliest reason grayling
  were lost from the reservoir's direct tributaries (the Williston and Upper Peace core areas).

What this file is not: a source for habitat thresholds. Gradient, channel width, discharge, depth, velocity and
substrate values are the evidence table's grayling rows in `data/literature_evidence.csv`.

## What are the forms, and do they mix?

**Four forms across the range.** Stewart et al.'s review of Northwest Territories grayling names four:

> "Stream-resident, fluvial, adfluvial, and lacustrine life histories have been observed among Arctic grayling populations" (stewart_etal2007Fishlife, p. 3)

> "Their populations can be resident or migratory, and the latter can follow fluvial or adfluvial life histories." (stewart_etal2007Fishlife, p. v)

The review's habitat table gives small tributaries as spawning and rearing habitat for fluvial populations and for
adfluvial or lake-dwelling ones (the table's width and gradient are the evidence table's grayling rows, not restated
here):

> "Small (~10 m wide), medium gradient tributary streams" (stewart_etal2007Fishlife, p. 3)

> "Spawning and rearing habitat." (stewart_etal2007Fishlife, p. 3)

The review says some grayling may spend part or all of their lives near their overwintering water:

> "Some grayling may spend part or all of their lives near their overwintering areas." (stewart_etal2007Fishlife, p. 22)

**River fish in the Williston watershed.** In the upper Peace, Hagen et al.'s 2026 synthesis says grayling complete
their lives in rivers, often below headwater lakes (citing Pollard and Miller 2011 and Stamford et al. 2017), that one
lake-inlet spawning population is known, and that they do not live in the reservoir (citing Clarke et al. 2005),
though eDNA and occasional captures suggest some move through it (citing Golder 2013, Stamford et al. 2022 and
Stamford and O'Connor 2022):

> "Arctic Grayling in the Williston Reservoir watershed complete their life cycle in fluvial habitats and often downstream from headwater lakes" (hagen_etal2026futureArctic, p. 6)

> "The Toodoggone watershed in the Upper Finlay core area contains the only known lake inlet spawning metapopulation. Arctic Grayling do not reside in the reservoir (Clarke et al. 2005), although new results from environmental DNA (eDNA) studies and infrequent grayling encounters in tributaries to the Williston and Upper Peace core areas suggest that successful movement through the reservoir occurs more frequently than previously thought" (hagen_etal2026futureArctic, p. 6)

In the Parsnip radio telemetry (Blackman, 1996 to 1997), three tagged fish were found in the reservoir in winter,
and none came back to spawn:

> "Three fish (33, 35, 51) were found in the reservoir during the winter" (blackman2002RadioTelemetry, p. 17)

> "However, none of the fish that moved to the reservoir returned to spawn." (blackman2002RadioTelemetry, p. 17)

Hawkshaw and Shrimpton, who sampled juveniles across the Williston watershed, say only the fluvial form has been
recognised there, and Cowie and Blackman's Omineca and Osilinka fry surveys say grayling do not appear to use lakes:

> "only fluvial Arctic grayling have been recognized in this area" (hawkshaw_shrimpton2014Temperaturepreference, p. 32)

> "In Williston Reservoir Watershed Arctic grayling do not appear to utilize lakes." (cowie_blackman200320012002Arctic, p. 10)

In the Nation, local knowledge and past surveys indicate grayling do not use the river above Chuchi Lake, and in the
Nation and the Osilinka none are reported above the lakes; in the Mesilinka, Cowie and Blackman, citing ECL Envirowest
1998, note grayling above the lake:

> "Local knowledge, review of historical data, and previous surveys indicate that grayling do not use the area upstream from the outlet of Chuchi Lake." (cowie_blackman2007Arcticgrayling, p. 6)

> "Arctic grayling in both the Nation and Osilinka watersheds have not been reported upstream from the lakes, while grayling have been noted as using the area upstream from the lake in the Mesilinka Watershed (ECL Envirowest Consultants Ltd. 1998)." (cowie_blackman2007Arcticgrayling, p. 11)

Stamford et al. 2017, citing McLean and Langston 1992 and Pollard and Miller 2011 for the Williston lakes and
Northcote 1993 for the rest, add that grayling are missing from most small lakes of the Williston watershed, unlike
the lower Peace:

> "extensive inventories found Arctic Grayling conspicuously absent in most small lakes within the Williston watershed" (stamford_etal2017FWCPArctic, p. 4)

> "but lake populations exist in the lower Peace watershed and are relatively common throughout the species range in North America" (stamford_etal2017FWCPArctic, p. 4)

They report three putative ecotypes for BC proposed by Stamford et al. 2015, two of them known in the Williston
watershed, and judge the clear-stream one uncertain:

> "for British Columbia as an additional component of grayling diversity in the province: ‘Large Turbid Rivers,’ ‘Clear Streams,’ and ‘Lakes,’ of which the first two are known to be present in the Williston watershed, and the third is suspected to be present only in the Upper Finlay/Toodoggone core area." (stamford_etal2017FWCPArctic, p. 5)

> "The ‘Clear Stream’ ecotype is therefore currently somewhat uncertain." (stamford_etal2017FWCPArctic, p. 5)

**Residents and migrants in one basin.** Hagen et al. 2026 suggest that the surviving populations move locally within
their home streams, and, citing Stamford et al. 2017, that the populations thought lost to flooding were presumably
adapted to large rivers:

> "Remnant Arctic Grayling populations in unflooded core areas (Parsnip, Nation, Omineca, Ingenika, Lower Finlay, Upper Finlay; Figure 1) appear to also move locally within their home streams and potentially also express locally adapted traits." (hagen_etal2026futureArctic, p. 5)

> "In contrast, Arctic Grayling metapopulations thought to be extirpated by flooding in the Williston and" (hagen_etal2026futureArctic, p. 5)

> "were demographically independent from surviving metapopulations and presumably adapted to the (now flooded) large river habitats" (hagen_etal2026futureArctic, p. 6)

In the Omineca core area (O'Connor et al. 2026, reported by Hagen et al.), fin ray chemistry suggests the adults of
the Mesilinka and the Osilinka each spend their whole lives in their own river:

> "Fin ray microchemistry analyses in Omineca core area found distinct element concentrations between adults rearing in Mesilinka River and Osilinka River that suggest adults in both streams complete their entire life history within their respective home streams" (hagen_etal2026futureArctic, p. 16)

**How far they travel.** Across the range, Hagen et al. 2026 write, citing Stewart et al. 2007 for the first passage
and Armstrong 1986, Northcote 1993 and Stewart et al. 2007 for the second, that the migrations run from one small
watershed to hundreds of kilometres:

> "These movements may be at the scale of a single, relatively restricted watershed or lake system (Stewart et al. 2007), or involve long, complex migrations among critical habitats" (hagen_etal2026futureArctic, p. 5)

> "span hundreds of kilometers between overwintering, spawning and summer feeding areas located in different systems" (hagen_etal2026futureArctic, p. 5)

In the Parsnip telemetry, the tagged fish tracked through a year travelled 67 to 245 km:

> "The maximum distance travelled from the initial tagging to return to summer feeding areas (~ one year) was 245 km, the average was 126 km and the minimum was 67 km." (blackman2002RadioTelemetry, p. 17)

In the Northwest Territories, one fish tagged on the Donnelly River moved 320 km (Tripp and McCart 1974, reported by
Stewart et al.):

> "A grayling tagged at Chick Lake on the Donnelly River moved 320 km to the Great Bear River between 9 July and 4 October 1972" (stewart_etal2007Fishlife, p. 22)

**Do fish from different spawning streams mix?** Stamford et al. 2017, citing studies in Alaska and the Parsnip (Tack
1980, Buzby and Deegan 2000, Blackman 2002a, Gryska 2006, Earth Tone and Mainstream 2013), say these suggest fluvial
adults return to the same feeding sites each year, and that fish from different spawning streams may share summer or
winter habitat:

> "Mark-recapture and radio telemetry studies suggest that individual fluvial adults home yearly to the same summer feeding sites, but grayling from different spawning streams may exhibit overlap in summer rearing and/or overwinter habitat" (stamford_etal2017FWCPArctic, p. 10)

In the Parsnip, the tagged fish of the Table and Anzac summered in those rivers but six of the eighteen that
survived to spawn spent the spawning period in another stream; Blackman's distribution report adds that the adults
summering in the two rivers may have reared elsewhere:

> "Five of the fifteen surviving Anzac grayling and one of the three Table fish spent the spawning period in rivers other than the streams they were tagged in." (blackman2002RadioTelemetry, p. 18)

> "For example, the Table and Anzac rivers provide summer feeding habitat, and are populated by adult grayling, which may have reared in other systems" (blackman2002DistributionRelative, p. 6)

In the later acoustic telemetry of the Parsnip, most tagged fish kept to one tributary, and about a quarter appeared
to stray between years:

> "While most individuals display high tributary fidelity, one-quarter of the total population appeared to display what could be likened to a straying phenotype in Pacific salmon" (martins_etal2022SpatialEcology, p. 32)

## When do they migrate?

**The annual cycle.** Across the range, Hagen et al. 2026 give Northcote's (1993) model:

> "Northcote (1993) presented a conceptual model of Arctic Grayling life history, which is based on a cycle of potentially complex migratory behaviour involving alternation between three major habitat categories: 1) summer feeding habitat, 2) overwinter refuge, and 3) suitable spawning habitat." (hagen_etal2026futureArctic, p. 5)

In the Parsnip, Cowie and Blackman's summary of the 1995 to 2007 studies has Table and Anzac fish of age 1 and older
moving into the Parsnip, and adults returning to the smaller rivers to spawn, with the Parsnip their route and winter
water:

> "Overall results of the beach seining efforts, in conjunction with telemetry and other surveys, have indicated that Table and Anzac river fish are moving into the Parsnip River for the age classes of 1+ and older. Once the grayling reach spawning age, they are returning to either of the smaller systems, and at times using both, with the Parsnip used by adults to migrate between and for overwintering." (cowie_blackman2012OverviewSummary, p. 6)

**The Parsnip, by acoustic telemetry.** Martins et al. tagged grayling across the Parsnip River watershed. They found
three phases, the second a spring migration into the middle reaches of four tributaries, which they read as a
spawning migration:

> "Arctic Grayling in the Parsnip River watershed showed three distinct life phases: 1) an overwintering period spent in the Parsnip River mainstem; 2) a spring spawning migration into the middle reaches of the Anzac, Table, Hominka, and Missinka Rivers; and 3) a summer feeding migration in which they may disperse wide across the watershed in search of suitable feeding habitats." (martins_etal2022SpatialEcology, p. 3)

> "Springtime movements are sudden and wide-ranging, with individuals beginning to push into the middle tributaries around ice-out and freshet in April and May." (martins_etal2022SpatialEcology, p. 32)

> "Summer distribution patterns persist until October, at which time Arctic Grayling begin congregating in the Parsnip River mainstem once more, reaching an approximately winter distribution by November." (martins_etal2022SpatialEcology, p. 32)

**The Parsnip, by radio telemetry.** Blackman's earlier radio telemetry of Table and Anzac adults gives a similar
calendar. Most fish set out for the spawning areas in late April or early May, at break-up, and moved 9 to 71 km:

> "The majority (13 of 18) of the grayling started moving towards spawning areas (Fig. 4), in late April or early May" (blackman2002RadioTelemetry, p. 9)

> "The late April movement coincided with rising water temperatures, increased flows, and spring break up" (blackman2002RadioTelemetry, p. 9)

> "The average movement from overwintering areas to spawning areas (March 25 to June 13) was 33 km with a minimum movement of 9 km and a maximum of 71 km" (blackman2002RadioTelemetry, p. 9)

After spawning, eight of the eighteen presumed spawners went back to where they had been tagged the summer before,
mostly in July:

> "Eight of the eighteen fish that were assumed to have spawned returned to the summer feeding locations where they had been tagged the previous year. These movements were primarily in July" (blackman2002RadioTelemetry, p. 9)

In the fall of tagging, the three surviving Table fish had reached their winter water by 19 September and the fifteen
surviving Anzac fish by 6 November, with no flight between 24 September and 6 November; the next year they started
moving by early October:

> "The three, tagged Table River grayling that returned to the river in spring, moved to overwintering areas by September 19th soon after being implanted with the radio tags." (blackman2002RadioTelemetry, p. 9)

> "had moved to overwintering areas by November 6th, 1996. (No flights were conducted between September 24 and November 6.)" (blackman2002RadioTelemetry, p. 9)

> "Grayling started moving to overwintering areas by early October." (blackman2002RadioTelemetry, p. ii)

**The cue in spring.** Across the range, Stamford et al. 2017, citing Armstrong 1986, Northcote 1993 and Butcher et
al. 1981, say spawners arrive as the water reaches about 4 °C:

> "Mature adult Arctic Grayling migrate in spring to spawning locations and arrive there when water temperature reaches about 4oC" (stamford_etal2017FWCPArctic, p. 10)

In the Parsnip, Blackman's tagged fish set out at break-up, when the water rose above zero, and the estimated start of
spawning fell at 4 °C:

> "Fish started to migrate to spawning areas at spring break up around April 30 when water temperatures rose above zero" (blackman2002RadioTelemetry, p. 16)

> "The initiation of the estimated spawning period does coincide with 4oC water temperatures" (blackman2002RadioTelemetry, p. 16)

In Adsett Creek (Liard, BC), the onset of flow probably cued the run into the creek, but no single factor appeared to
govern it:

> "While the onset of flow in Adsett Creek probably cued immigration, no single physical parameter appeared responsible for regulating ascent." (stewart_etal1982Ecologicalstudies, p. 31, OCR)

In interior and Arctic Alaska, Tack suggests the run is probably triggered by the first warming to 1 °C:

> "The prespawning migration is probably stimulated by the first rise of water temperature to 1°C in the spring." (tack1980Migrationsdistributions, p. 3)

In the Mackenzie valley (Northwest Territories), spawners move into small tributaries during or just after the ice
breaks up (Jessop et al. 1974 and Stein et al. 1973b, reported by Stewart et al.):

> "Fish that spawn in the Mackenzie River valley generally migrate from lakes and larger rivers into small, clear, fast-flowing" (stewart_etal2007Fishlife, p. 11)

> "tributaries during (Jessop et al. 1974), or just after (Stein et al. 1973b), the breakup of river ice." (stewart_etal2007Fishlife, p. 12)

**Summer.** Across the range, Hagen et al. 2026, citing Tack 1980, Armstrong 1986, Ridder 1994 and Blackman 2002a,
have subadults joining the adults' migrations from their second or third year, usually upstream to summer feeding
water:

> "Beginning in their second or third year of life, many subadult grayling join adults in making migrations from overwintering locations (usually in an upstream direction) to summer feeding habitat" (hagen_etal2026futureArctic, p. 6)

In the Anzac, the tagged adults did not reach their furthest upstream point until August (Blackman's habitat report,
citing the telemetry):

> "Upstream movement of grayling was confirmed by radio telemetry work conducted at the same time as this study (Blackman 2002b) which showed that adult grayling in the Anzac River did not reach their furthest upstream distribution until August." (blackman20041997Arctic, p. 13)

In Adsett Creek, spent spawners stayed in the creek for the summer:

> "Following reproduction, spent grayling dispersed throughout the stream to recuperate and oversummer." (stewart_etal1982Ecologicalstudies, p. 31, OCR)

**Fall.** In the Northwest Territories review, whole populations leave small lakes and streams for larger rivers or
lakes, at times that vary with local conditions:

> "In fall, entire populations of grayling migrate out of small headwater lakes and small streams to overwinter in larger rivers or lakes" (stewart_etal2007Fishlife, p. 21)

> "The timing of these migrations varies from early summer through December depending upon the local conditions" (stewart_etal2007Fishlife, p. 22)

In Adsett Creek, grayling of every age left the creek in the month before freeze-up, as the water cooled:

> "Up to 30 days prior to freeze up (late September to mid-October), grayling of all age classes emigrated from Adsett Creek as water temperatures markedly decreased." (stewart_etal1982Ecologicalstudies, p. 89, OCR)

In the Little Smoky River (Alberta), radio-tagged grayling moved downstream in the fall, mostly before 19 October, as
the water cooled and flows fell:

> "It appears that most of the fall migration occurred by October 19 with fish moving downstream between August 31 and October 19, 1993." (stanislawski1997FallWinter, p. 35, OCR)

> "In general, Arctic grayling in the Little Smoky River migrated downstream in fall as water temperatures and flows were decreasing." (stanislawski1997FallWinter, p. 43, OCR)

In the Sukunka (Peace system, BC), Stuart and Chislett saw no large seasonal movements of juveniles between the
tributaries and the river:

> "There were no large seasonal movements of juveniles between the tributaries and the Sukunka River" (stuart_chislett1979AspectsLife, p. 3, OCR)

## When and where do they spawn?

**Timing.** Across the Mackenzie valley and elsewhere, the Northwest Territories review gives spawning usually between
mid-May and mid-June, at 4 to 16 °C:

> "Spawning can begin in April and extend into early July but usually occurs from mid-May to mid-June" (stewart_etal2007Fishlife, p. 12)

> "typically commences in mid-May in the southern Mackenzie Valley to mid-June in the north, at water temperatures of 4 to 16°C" (stewart_etal2007Fishlife, p. 12)

> "A rise in water temperature to 4°C and spring flooding may be factors that stimulate grayling to spawn" (stewart_etal2007Fishlife, p. 12)

For northern BC, Stewart et al.'s Adsett Creek study puts spawning from late April to early June, depending on
break-up; in Adsett Creek itself spawning apparently peaked from 16 to 23 May, in water averaging 5.3 °C:

> "Grayling reproduction in northern British Columbia generally occurs from late April to early June, depending upon the timing of breakup." (stewart_etal1982Ecologicalstudies, p. 86, OCR)

> "with peak activity between May 16 and May 23" (stewart_etal1982Ecologicalstudies, p. 31)

> "mean water temperature was 5.3°C" (stewart_etal1982Ecologicalstudies, p. 31)

Turbid water there kept the spawning itself from being watched:

> "Sustained turbidity during the spawning period prevented description of reproductive behaviour." (stewart_etal1982Ecologicalstudies, p. 35)

In the Sukunka (Peace system, BC), spawning dates were estimated from fry development:

> "From the fry development data, grayling spawned in the Sukunka drainage between May 15 and June 7 in both 1977 and" (stuart_chislett1979AspectsLife, p. 31)

In the Parsnip, Blackman could not watch spawning in the high, turbid water; from water temperature and fry emergence
he estimated it at late May to mid or late June, and judged the estimate may run a week late:

> "High flow and turbid water made the observation of spawning activities impossible. Based on water temperatures and fry emergence dates, spawning is believed to have occurred during the high flow period from late May to mid June." (blackman2002RadioTelemetry, p. ii)

> "the spawning period was calculated to be between May 29 and June 25 based on the fry emergence dates and water temperatures. However, our estimates may have been a week late" (blackman2002RadioTelemetry, p. 16)

Blackman's habitat report on the Table and Anzac suggests most spawning occurs just after the peak of the spring
freshet:

> "In the Anzac and Table watersheds, most Arctic grayling spawning appears to occur just after the peak of spring freshet, when observing spawning fish is almost impossible." (blackman20041997Arctic, p. 13)

The year matters. In the early, low-water spring of 1998, Table and Anzac fry appeared about a month earlier than in
1997 (the abstract says they emerged in early June; by their size the report puts hatching at 10 to 25 June):

> "The unusually early spring, and low stream flows in 1998, resulted in the fry emerging in early June, one month earlier than in 1997." (blackman_hunter20011998Arctic, p. i)

> "The size of the Arctic grayling fry sampled during the surveys indicates hatching occurred from June 10th to June 25th in 1998" (blackman_hunter20011998Arctic, p. 28)

Across the range, Cannings and Ptolemy, citing Northcote (1995):

> "Grayling are spring spawners often moving onto spawning areas shortly after ice-out at temperatures near 4°C (Northcote, 1995)." (cannings_ptolemy1998RareFreshwater, p. 49)

In Alaska (Ott and Morris 2005 and 2006 and W. Morris, reported by Stewart et al.), spawning is abandoned or fails
when the water stays too cold:

> "Spawning is abandoned or fails during years when the temperatures stay too low after fish have arrived on the spawning grounds." (stewart_etal2007Fishlife, p. 14)

**Where in the Williston watershed.** Hagen et al. 2026 say the spawning sites are mostly unknown, and assumed to lie
near the fry and juvenile habitats; Ballard and Shrimpton say few potential spawning areas are identified in the
Omineca region:

> "Although specific spawning locations are generally unknown for Williston Arctic Grayling, elsewhere stream reaches that warm quickly in the spring are prime habitat for spawning and early rearing." (hagen_etal2026futureArctic, p. 6)

> "Spawning habitats have not been precisely delineated for Williston Arctic Grayling and are currently assumed to be near fry and juvenile critical habitats due to the dispersal ability of these life stages." (hagen_etal2026futureArctic, p. 26)

> "Few areas have been identified as potential spawning areas for grayling in the Omineca region." (ballard_shrimpton2009Summaryreport, p. 60)

In the Parsnip, their summary has spawning in the mainstem and in small tributaries, from telemetry that flagged
movements into tributaries possibly for spawning:

> "Telemetry studies informed the connections between adult critical habitats across seasons, identified overwintering locations in the Parsnip River, and flagged movements into tributaries possibly for spawning." (hagen_etal2026futureArctic, p. 16)

> "The Parsnip core area presents a picture of complex migratory behaviour that includes spawning in the Parsnip River mainstem and small tributaries, with most adults exhibiting strong homing to the same summer rearing areas each year." (hagen_etal2026futureArctic, p. 16)

**The Parsnip suspected spawning areas.** In Blackman's radio telemetry, the tagged fish held in deep pools, jams and
flooded riparian areas beside, not on, likely spawning water, and no exact spawning site was found:

> "During this period the grayling were located in deep pools, debris jams or in flooded riparian areas, close to but not in potential spawning habitat (shallow gravel riffles or glides). No exact spawning sites were located because the fish never appeared to be on a potential spawning site." (blackman2002RadioTelemetry, p. 13)

In the Anzac the fish gathered in two areas, one about 3 km above the mouth and one between km 12 and 22, where the
river splits into many channels across the valley flat (Martins et al., above, place the spring migration in the
middle reaches):

> "There were two main areas on the Anzac River (Fig. 4) where fish gathered during the spawning period." (blackman2002RadioTelemetry, p. 13)

> "were located about 3 km upstream from the river mouth" (blackman2002RadioTelemetry, p. 13)

> "Seven tagged grayling (26, 29, 31, 37, 39, 41, 48) were found in the second area between km 12 and km 22. This area has multiple channels meandering through the valley flat, which is up to 2 km wide." (blackman2002RadioTelemetry, p. 13)

The suspected Anzac spawning areas, from the telemetry and the fry, had shallow glides with much small gravel and
several channels, and their upper end came where gravel gave way to cobble and boulder (the evidence table's grayling
rows hold this passage as a statement, not the gravel size):

> "The suspected spawning areas of the Anzac River (based on telemetry and fry distribution data) all had extensive shallow glide areas with large quantities of small (<3 cm) gravel and were located in areas of the river that were multi-channelled. The upper limits of spawning coincided with a decrease in the percentage of gravel and an increase in cobble and boulder percentage" (blackman2002RadioTelemetry, p. 18)

Two Anzac fish spent the spawning period in side channels of the Parsnip, and a Table fish was found near the mouth of
a small Parsnip tributary that later held fry; the later ground surveys found fry at every suspected spawning location
but those in the Parsnip mainstem:

> "Two Anzac fish (52, 49) were located in two different side channels of the Parsnip River at approximately km 74." (blackman2002RadioTelemetry, p. 13)

> "The km 80 location was near the mouth of a small tributary stream, which subsequently was found to have grayling fry." (blackman2002RadioTelemetry, p. 13)

> "Subsequent ground surveys (data on file) found young of the year grayling fry at all the suspected spawning locations except those in the Parsnip River mainstem" (blackman2002RadioTelemetry, p. 18)

Blackman and Hunter, the next year, call the multi-channel Anzac reach at km 14 to 20 the main spawning area, by the
1997 telemetry and fry surveys; a search for eggs at one Anzac site found none:

> "The area from km 14-20 is multi channelled and radio telemetry and fry distribution studies conducted in 1997 concluded that this was the main spawning area" (blackman_hunter20011998Arctic, p. 14)

> "No eggs or redds were discovered at the site on the Anzac River." (blackman_hunter20011998Arctic, p. 11)

In 2005, fry were caught in six of thirteen tributaries sampled in the Parsnip watershed (Sherstone and Blackman
2008, reported by Cowie and Blackman 2012):

> "From 22 of the sites, 78 Arctic grayling fry were caught, with 6 of the 13 tributaries sampled containing grayling." (cowie_blackman2012OverviewSummary, p. 15)

**Other Williston rivers, from fry.** In the Osilinka, fry were found only in a 38 km low-gradient reach below
Usilinka Lake with fine substrate and many side and back channels, which Cowie and Blackman call the spawning and
rearing area (the reach gradient is where fry were found, not a limit):

> "It is not obvious why grayling fry were restricted only to this area. This 38 km section of river is low gradient (0.1%), and has a higher fines content than most other areas of the river. It also contains numerous small side and back channels. This spawning/rearing area is also downstream from Usilinka Lake, which may help stabilise flows." (cowie_blackman200320012002Arctic, p. 9)

The same report says steeper reaches with boulder and cobble limit spawning in the Table and Anzac (citing Blackman
et al. 2001):

> "Reaches with higher gradients and a high percentage of boulder/cobble substrate have been noted in the Table and Anzac rivers to limit the extent of spawning (Blackman et al. 2001)." (cowie_blackman200320012002Arctic, p. 9)

In the Nation, fry were caught over loose cobble and boulder, which the authors read as possible spawning there,
while allowing that the fry may have moved in:

> "In many areas of the Nation River substrates dominated by cobble and boulder were notably non compacted (had open interstitial spaces)." (cowie_blackman2007Arcticgrayling, p. 8)

> "The presence of grayling fry in these areas suggests these substrates may have been used by grayling for spawning." (cowie_blackman2007Arcticgrayling, p. 8)

> "It is also possible that the fry moved into these habitats after hatching elsewhere but we have no definitive proof either way." (cowie_blackman2007Arcticgrayling, p. 8)

In the Sukunka (BC), large numbers of newly emerged fry in the mainstem pointed to spawning there more than in the
tributaries; searches of its side and back channels for eggs found none:

> "Large numbers of newly emerged fry in the Sukunka River suggested extensive use of the mainstem river and only limited spawning in the tributaries." (stuart_chislett1979AspectsLife, p. 2, OCR)

> "Gravels in the Sukunka River sidechannels and backchannels were searched for eggs from June 1 to 30 but eggs were not located." (stuart_chislett1979AspectsLife, p. 30)

In the Ospika River (Finlay Reach), Stamford and O'Connor (2022, reported by Hagen et al. 2026) took two fry, which
Hagen et al. read as a sign of spawning:

> "capture of two fry in the Ospika River indicates spawning" (hagen_etal2026futureArctic, p. 17)

Unpublished otolith chemistry reported by Hagen et al. 2026 suggests that about a quarter of the fry caught in the
upper Finlay mainstem came from spawning areas outside the Finlay, and Hagen et al. point to small tributaries as
natal habitat:

> "suggest a significant proportion (roughly 27%) originated from spawning areas outside of Finlay River" (hagen_etal2026futureArctic, p. 17)

> "analyses of retrospective data (eDNA, microchemistry) suggest that small tributaries provide important natal habitats" (hagen_etal2026futureArctic, p. 18)

**Why spawning and summer streams can differ.** Across the range, Hagen et al. 2026, citing Tack 1980, Butcher et al.
1981, Ridder 1994 and 1998 and Stewart et al. 2007:

> "However, such reaches may also be too small and possibly warm for rearing later in the summer or for older life stages, which may explain why critical habitats for spawning and summer rearing may be in different streams" (hagen_etal2026futureArctic, p. 6)

**The range of spawning sites.** Across the range, Stamford et al. 2017, citing Tack 1980, Armstrong 1986, Blackman
2002a and Stewart et al. 2007:

> "Grayling spawn in a wide variety of habitats, including mainstem rivers, large and small tributaries to streams and lakes, and along lake shores at the mouths of inlets" (stamford_etal2017FWCPArctic, p. 10)

Tack (Alaska) advances the hypothesis that grayling spawn where their system warms first:

> "The hypothesis is advanced that these locations are used for spawning because they are the first areas in their systems to warm in the spring." (tack1980Migrationsdistributions, p. 3)

**Substrate, depth and current.** Across the range, Stamford et al. 2017, citing Stuart and Chislett 1979, Tack 1980,
Armstrong 1986 and Stewart et al. 2007, say fluvial grayling spawn mostly over small, loose gravel in shallow riffles
and runs:

> "Fluvial Arctic Grayling have generally been observed spawning over small pea-sized unembedded gravels in shallow riffles and runs, but also use large cobbles and boulders to incubate their adhesive eggs" (stamford_etal2017FWCPArctic, p. 10)

The Northwest Territories review gives the gravel size and says no redd is built (its depth and current values are
the evidence table's grayling rows):

> "but most spawning occurs over relatively small, unembedded gravels about 2.5 cm in diameter" (stewart_etal2007Fishlife, p. 14)

> "They do not build a redd" (stewart_etal2007Fishlife, p. 14)

In Adsett Creek (Liard, BC), spawning was concentrated 4 to 5 km above the Prophet River, over stable coarse gravel
generally toward the tails of long runs, especially those above steep gradients (the gravel size and depth are the
evidence table's grayling rows, where the sites were, not limits; the quote skips two words the scan misreads):

> "Most spawning activity occurred in areas characterized by stable, coarse (20 - 40 mm) ... substrates, water depths of 0.1 - 0.4 m, and flows of ... m/sec. These areas generally occurred toward the tail of long runs, particularly those preceding steep gradients." (stewart_etal1982Ecologicalstudies, p. 31, OCR)

> "although the majority of spawning activity occurred approximately 4 - 5 km from the Prophet River confluence" (stewart_etal1982Ecologicalstudies, p. 31, OCR)

Cannings and Ptolemy, in the habitat account that opens with Northcote's (1995) summary of the literature, name
structure as part of spawning capability:

> "Structural elements such as stable large woody debris, boulders and bedrock are important measures of spawning capability." (cannings_ptolemy1998RareFreshwater, p. 48)

In the Sukunka study, four adults caught in a trap (a male and three females) were held in an artificial
overflow channel. Spawning was not seen, but gravel was disturbed in two areas of quiet water (the channel is an
artificial one holding four trapped adults, not a measure of where grayling choose to spawn):

> "were taken in the upstream trap and held in the overflow with the male and first female" (stuart_chislett1979AspectsLife, p. 29)

> "The overflow channel was 18 m long, 0.5 per cent gradient with alternating areas of riffled and quiet waters." (stuart_chislett1979AspectsLife, p. 29)

> "The male and three females were observed daily from June 1 to 8" (stuart_chislett1979AspectsLife, p. 29)

> "Spawning activity was not observed but on June 3, disturbed gravel was observed" (stuart_chislett1979AspectsLife, p. 30)

**Natal fidelity.** Across the range, Stamford et al. 2017 say relatively precise homing has been suggested for many
stream populations (mostly Alaskan studies, and Blackman 2002a in the Parsnip), with adults sometimes switching sites
after a poor spring (Ridder 2000, Stewart et al. 2007):

> "Relatively precise homing of adults on spawning migrations, and corresponding demographic independence, has been suggested for numerous stream populations" (stamford_etal2017FWCPArctic, p. 10)

> "although adults have also been observed moving to different spawning sites sometimes in response to poor spring conditions" (stamford_etal2017FWCPArctic, p. 10)

Cannings and Ptolemy, of grayling in general:

> "They show strong reproductive, trophic and refuge homing with offspring utilizing the same habitat areas as their parents." (cannings_ptolemy1998RareFreshwater, p. 48)

In the Parsnip telemetry, Blackman set the literature's homing beside his own count of fish that appeared to spawn away
from their summer stream:

> "but they frequently utilise different streams for different life history stages (6 of 18 fish did not appear to spawn in the stream where they were tagged in this study)" (blackman2002RadioTelemetry, p. 16)

In the Northwest Territories, the evidence is limited tagging:

> "Limited tagging data suggest that individual grayling show fidelity to both spawning and overwintering areas" (stewart_etal2007Fishlife, p. 22)

**After spawning.** In the Northwest Territories review, spawning lasts two to three weeks, after which adults return
to larger rivers or lakes:

> "Spawning takes place over a 2 to 3 week period, after which the adults return to larger rivers or lakes" (stewart_etal2007Fishlife, p. 15)

**Age at spawning.** In the Sukunka, most spawners were four and five; in Adsett Creek, few fish were mature at three,
a quarter at four and all from five; McPhail (2007, reported by Stamford et al. 2017) says most BC grayling mature
after their fifth summer:

> "Most of the mature grayling were four and five years old and spawning occurred between May 15 and June 7." (stuart_chislett1979AspectsLife, p. 2)

> "Mature grayling were rare at age 3; however, 26% of grayling age 4, and all grayling age 5 or older were mature." (stewart_etal1982Ecologicalstudies, p. 33, OCR)

> "McPhail (2007) suggests, however, that most British Columbia grayling of both sexes mature after their fifth summer." (stamford_etal2017FWCPArctic, p. 11)

## How long do the eggs stay in the gravel?

Incubation is short and depends on temperature. The Northwest Territories review:

> "The time required for incubation of the eggs varies with mean water temperature, ranging from 8 days at 15.5°C and 16 to 18 days at 9°C, to 25 to 29 days at 7.1°C and 32 days at 5.8°C" (stewart_etal2007Fishlife, p. 15)

> "Young grayling emerge from the gravel 3 to 4 days after they hatch (Kratt and Smith 1977)." (stewart_etal2007Fishlife, p. 16)

The eggs may be covered by up to 5 cm of gravel:

> "They may be covered by up to 5 cm of substrate" (stewart_etal2007Fishlife, p. 15)

In Adsett Creek (BC), fry were first abundant along the margins on 25 June; from the published incubation data the
authors put incubation at about 170 degree-days:

> "Young-of-the-year grayling were first observed in abundance along stream margins on June 25" (stewart_etal1982Ecologicalstudies, p. 35, OCR)

> "indicate a mean incubation period of approximately 170 degree-days" (stewart_etal1982Ecologicalstudies, p. 35)

In the Sukunka overflow channel (BC), fry emerged on 27 June from the two areas of gravel disturbed on 3 June, which
the authors call possible spawning sites, and from a third area of quiet water:

> "On June 27, fry emerged from the gravel in the two areas noted as possible grayling spawning sites and in a third area of quiet water near the inlet of the channel." (stuart_chislett1979AspectsLife, p. 30)

> "An incubation period of 267.74 day degrees was obtained under semi-natural conditions." (stuart_chislett1979AspectsLife, p. 2)

In the Nation (BC), Cowie and Blackman give June as the usual emergence:

> "Grayling fry generally emerge in June so in 2004 fry distribution may have been somewhat reduced or altered due to lower flows." (cowie_blackman2007Arcticgrayling, p. 7)

## Where do fry live, and do they drift?

**Fry need quiet margins near the spawning site.** Across the range, Stamford et al. 2017, citing nine studies from
BC, Alaska and Finland (among them Stuart and Chislett 1979, Stewart et al. 1982, Armstrong 1986, Blackman 2004 and
Cowie and Blackman 2003 and 2004):

> "Newly-emerged grayling fry are weak swimmers, and a key habitat requirement is the availability of low velocity areas along channel margins (and including side channels, back channels, and alcoves) located in relatively close proximity to the spawning area" (stamford_etal2017FWCPArctic, p. 8)

In Adsett Creek (BC), fry stayed near the spawning areas for a time after emergence, in quiet water at the stream's
edge (the quote starts after a number the scan misreads):

> "days after emergence, grayling young-of-the-year remained proximal to spawning areas, and occupied peripheral stream habitat (quiescent areas where fast currents and back waters merged)" (stewart_etal1982Ecologicalstudies, p. 44, OCR)

**The Parsnip tributaries.** In the Table and Anzac, Blackman's 1997 electrofishing found grayling fry, like the bull
trout and burbot caught with them (which included one- and possibly two-year-olds, p. 7), in shallow, slow water, and their upstream limit appeared to fall where the bed
turned from gravel to cobble (the 12 cm and < 0.1 m/s are given for the three species together, where they were caught,
not limits; the grayling's own means are the evidence table's grayling rows):

> "The grayling fry, bull trout and burbot showed a strong affinity for shallow (average 12 cm) low velocity (<0.1m-s) habitats" (blackman20041997Arctic, p. 7)

> "The upstream distribution of fry appeared to coincide with a change from gravel to cobble as the dominant substrate in both streams." (blackman20041997Arctic, p. 11)

> "Grayling fry in the Anzac River showed a stronger association with habitats that contained a higher percentage of fines in the substrate than did those in the Table River" (blackman20041997Arctic, p. 12)

In the Table in 1996 and 1998, fry were found in side channels, alcoves and back channels of the mainstem, and none in
the tributaries:

> "No evidence exists to date for the use of tributaries by Table River grayling. Numerous Arctic grayling fry were observed in mainstem side channel habitats in 1996." (mathias_etal1998SummaryReport, p. 48)

> "Most of the fry observed were located in alcoves, back channels and side channels (Appendix I)." (blackman_hunter20011998Arctic, p. 13)

Mathias et al. add that the absence of grayling from the Table tributaries does not show those tributaries unused for
spawning and early rearing:

> "Although Arctic grayling were not captured nor observed in the Table River tributaries, there is no evidence that these tributaries are not important to Arctic grayling spawning and early rearing." (mathias_etal1998SummaryReport, p. 30)

**Other Williston rivers.** In the Ingenika, most fry were in isolated pools, back channels and side channels, and
most of them in two braided reaches:

> "Eighty-two percent of the grayling fry were captured from isolated pools, backchannel or sidechannel habitats. Two sections of multi-channel braided areas (a 29.3 km section of the 76 km grayling distribution area) yielded 138 of the 198 grayling fry caught. This area appears to be the core grayling fry rearing area." (cowie_blackman20042003Arctic, p. i)

> "Side and backchannel areas may provide protection from seasonal flood events, which may play a key role in the success/failure of the young of the year survivals." (cowie_blackman20042003Arctic, p. 8)

In the Osilinka, fry were confined to 38 km of the lower mainstem and mostly in isolated pools on gravel bars; in the
Omineca they were spread along the whole mainstem and in three large tributaries:

> "The fry were limited to a 38 Km section of the lower Osilinka mainstem. Eighty-five percent of the grayling fry captured from the Osilinka River were caught in isolated pools on mainstem gravel bars. No grayling were caught in any of the tributaries sampled." (cowie_blackman200320012002Arctic, p. i)

> "Arctic grayling fry were relatively evenly distributed throughout the Omineca mainstem (Figure 2), with no extensive areas where grayling were absent, nor were there any areas with high concentrations." (cowie_blackman200320012002Arctic, p. 6)

> "Arctic grayling were caught throughout the Omineca drainage, including 3 major tributaries." (cowie_blackman200320012002Arctic, p. 9)

The Nation differs: its fry were over gravel and cobble, in deeper and faster water, and almost none in side channels
or pools on bars; a few were in two tributaries:

> "Grayling were caught in areas with a gravel cobble substrate, and not in areas of gravels and fines as seen in other Williston Watersheds (Table, Anzac, and Parsnip rivers) (Blackman 2004). The Nation River grayling fry were also captured in areas with deeper and faster water than was observed in the other watersheds." (cowie_blackman2007Arcticgrayling, p. 5)

> "Grayling fry use of alcove, side and back channel habitats, as well as isolated pools on gravel bars, was much lower (<1%) in the Nation River than seen in other watersheds." (cowie_blackman2007Arcticgrayling, p. 10)

> "In the tributaries, six grayling fry were caught from five sites in only two tributaries (three grayling in 3 sites in Philip Creek and three grayling in 2 sites in Rainbow Creek)." (cowie_blackman2007Arcticgrayling, p. 6)

**As they grow.** Across the range, Stamford et al. 2017, citing Stuart and Chislett 1979 and Armstrong 1986, say fry
move to deeper, faster water as they grow:

> "As they grow, however, Arctic Grayling fry undergo behavioural and habitat shifts away from schooling in quiet areas, and move out into deeper faster water along mainstem margins and side channels where they remain for the rest of the summer" (stamford_etal2017FWCPArctic, p. 8)

In Adsett Creek (BC) they did; in the Table and Anzac, Blackman and Hunter, citing Blackman's habitat work, say they
tended to stay in water under 10 cm all summer:

> "As underyearlings grew, their preference to occupy deeper and faster water increased." (stewart_etal1982Ecologicalstudies, p. 44, OCR)

> "The young of the year Arctic grayling fry in the Table and Anzac rivers tend to remain in shallow water (<10cm) throughout the summer" (blackman_hunter20011998Arctic, p. 30)

In the Sukunka (BC), fry used backchannels and the quiet edges of pools briefly after emergence, then side-channel
riffles:

> "Except for a short post-emergence period in the backchannels and quiet edges of pools, sidechannel riffles were the preferred habitat of the grayling fry in spring, summer and fall." (stuart_chislett1979AspectsLife, p. 2)

> "Greater numbers of fry per sample were obtained from riffles with a silt-free gravel substrate compared to a cobble-gravel complex." (stuart_chislett1979AspectsLife, p. 36)

The Northwest Territories review describes later fry habitat (its velocity and depth values are the evidence table's
grayling rows):

> "Later in the season, once they become more mobile, young-of-the-year in streams inhabit shallow pools and side channels with water velocities less than 80 cm/s and depths of 5 to 50 cm, over silt to boulder substrates" (stewart_etal2007Fishlife, p. 17)

**Where the fry rear in the Williston watershed.** Stamford et al. 2017 report Hawkshaw et al. 2013 as placing
first-summer rearing in low-gradient middle reaches of the larger tributaries, at stable summer temperatures near
16 °C (stream order: the evidence table's grayling rows); the library holds only that study's abstract, which is not
quoted here:

> "rear during their first summer in locations with similar habitat characteristics (i.e. low gradient, stable summer temperatures, located in middle reaches of larger tributaries" (stamford_etal2017FWCPArctic, p. 8)

> "Fluvial grayling populations in Williston watershed appear to be centered around fry rearing areas located in the low gradient middle reaches of larger (e.g. 4th order and larger) tributaries where stable ambient summer temperatures hover close to16oC" (stamford_etal2017FWCPArctic, p. 16)

In the upper Finlay, beach seining found many fry in the Finlay mainstem but few yearlings (Chu Cho Environmental
2018, reported by Hagen et al. 2026):

> "Beach seine sampling in the Upper Finlay core area found abundant fry rearing in the Finlay River mainstem but found surprisingly few yearling-sized juveniles" (hagen_etal2026futureArctic, p. 17)

In mountain streams of the Little Nahanni (Northwest Territories), McPherson found young-of-the-year only low in the
basin:

> "YOY Arctic Grayling were found exclusively in low elevation, low gradient habitat dominated by silty-sand substrate with average water temperatures >10oC." (mcpherson2020Habitatuse, p. ii)

**Drift, stranding and downstream movement.** The Northwest Territories review, citing de Bruyn and McCart 1974 and
Armstrong 1986 for the first passage and Kratt 1977, Deleray 1991 and Deleray and Kaya 1992 for the second, says
flooding or drought in the first two weeks may cause high fry mortality, and that fry are most easily displaced soon
after swim-up:

> "Because fry are helpless in water currents for two weeks after hatching, flooding or drought during this period may cause high mortalities, either by washing them downstream into unfavourable habitat or by stranding them in shallow, isolated pools" (stewart_etal2007Fishlife, p. 17)

> "Grayling fry are most susceptible to downstream displacement shortly after swimup, particularly at night" (stewart_etal2007Fishlife, p. 17)

Newly hatched fry in the Table were seen drifting from a riffle margin; fyke nets in the Anzac caught no drifting fry,
which Blackman says could reflect how few fry there were:

> "These fry were located along the margin of a shallow riffle area and many were unable to hold a position against the current and were gradually drifting downstream." (blackman_hunter20011998Arctic, p. 11)

> "We were unable to document any downstream movement with the fyke nets, but this could have been a result of the very low number of fry in the system." (blackman20041997Arctic, p. 11)

In Adsett Creek (BC), fry left the creek when the flow rose:

> "Young-of-the-year grayling showed a strong emigratory response during periods of increased discharge. This was probably due to displacement of young-of-the-year from rearing habitat by sudden increases in flow." (stewart_etal1982Ecologicalstudies, p. 47, OCR)

In the Table and Anzac, fry rearing in very shallow water were often stranded in small pools:

> "The propensity of grayling fry to rear in shallow habitats (86% and 88% respectively of the Anzac and Table river grayling fry were captured in less than 20 cm of water) frequently leads to the stranding of fry in small isolated pools." (blackman20041997Arctic, p. 12)

Across the range, Hagen et al. 2026, after Northcote (1993), describe fry moving down to larger streams by fall:

> "By fall they drift or move downstream into larger streams to overwinter (Northcote 1993)." (hagen_etal2026futureArctic, p. 6)

The Sukunka fry did not; the study infers, from fry in ice-covered cobble riffles in November and a downstream
movement of yearlings in June, that fry may winter in the cobbles of frozen side channels (its summary) or in the
tributary (its discussion):

> "there was no downstream movement of fry from the tributaries in" (stuart_chislett1979AspectsLife, p. 3)

> "fall and the study indicates fry may overwinter in the cobbles of frozen sidechannels." (stuart_chislett1979AspectsLife, p. 3)

> "Fry were observed in cobbles in ice-covered riffles in November and a downstream movement of one year old grayling in June suggests fry over-wintered in the tributary." (stuart_chislett1979AspectsLife, p. 68)

## Where do juveniles and adults spend the summer?

**Where juveniles rear in summer.** Across the range, Hagen et al. 2026, citing Tack 1980, Butcher et al. 1981,
Northcote 1993 and Stewart et al. 2007, describe juveniles of 100 to 200 mm often using the larger streams through the
year:

> "These larger streams are often utilized by juvenile grayling 100-200 mm (age-1+ to age-2+) throughout the year, and the summer rearing habitats and overwintering locations may be in relative proximity to each other" (hagen_etal2026futureArctic, p. 6)

In the Parsnip, Blackman and Hunter found yearlings in the turbid Parsnip mainstem, in slow glides, and almost none
in the clear Table and Anzac; they suggest the Parsnip may be the main rearing water for yearlings of all three
rivers (the depth and velocity are a preference from use, not a limit):

> "This age class did not appear to rear in any significant numbers in the clear tributary streams but favoured the larger and more turbid Parsnip River." (blackman_hunter20011998Arctic, p. i)

> "Very few age 1+ Arctic grayling have been observed in either the Table of Anzac Rivers despite abundant habitat which appears to be suitable and limited competition from other species." (blackman_hunter20011998Arctic, p. 29)

> "Age 1+ Arctic grayling preferred for low velocity (<0.20 ms-1) sites with a depth between 0.40 and 1.0 m. The shallow low velocity glides in the Parsnip River may be the primary rearing area for this age class of Arctic grayling, not only from the Parsnip River but for fish from the Table and Anzac rivers as well." (blackman_hunter20011998Arctic, p. 30)

In the Sukunka (BC), Stuart and Chislett found juveniles almost only in pools, of the river and of the tributaries, and
adults mainly in the deepest pools of the river, seldom in tributary pools (the scan splits the
bracketed word across a line):

> "Juvenile grayling were found almost [exclusively] in the pools of the Sukunka River and the tributaries" (stuart_chislett1979AspectsLife, p. 3, OCR)

> "Adult grayling to age eight were found mainly in the deepest pools of the Sukunka River and seldom found in the tributary pools." (stuart_chislett1979AspectsLife, p. 3, OCR)

In Alaskan streams along the Trans Alaska Pipeline north of the Yukon River, Den Beste and McCart's juveniles (75 to
220 mm) appeared to select narrow channels (widths selected, not limits):

> "fish populations along the Trans Alaska Pipeline System (TAPS) north of the Yukon River" (denbeste_mccart1984Overviewstudies, p. 1)

> "Grayling were present in sufficient numbers to allow for a separate analysis of both juveniles (75 to 220 mm) and adults (>180 mm)." (denbeste_mccart1984Overviewstudies, p. 33)

> "Juvenile grayling also appear to select for narrow channel widths (1 to 8 m wide)" (denbeste_mccart1984Overviewstudies, p. 34)

**Adults in pools of clear, cool water.** Hagen et al. 2026 describe the usual summer split across the Williston core
areas, from habitat use recorded mostly in August; they add that adults and juveniles often overlap:

> "Critical habitats were defined primarily by data and observations collected during August" (hagen_etal2026futureArctic, p. 26)

> "Adult and juvenile life history stages often overlap in their summer rearing distributions but generally across all core areas, subadults and adults migrate upstream to find clear and cool (~12.5oC) water and well-defined pools and riparian cover. Fry and juveniles remain downstream where low gradient river margins, small tributaries, and off channel habitats provide warmer water (~16oC), rapid growth rates, and predator avoidance." (hagen_etal2026futureArctic, p. 26)

Across the range, Hagen et al. 2026, citing Birtwell et al. 1984, McLeay et al. 1987, Ott et al. 1998 and Stewart et
al. 2007, tie the adults' need for clear water to feeding by sight:

> "Clear stream reaches appear to be critical for summer rearing of subadult and adult Arctic Grayling, likely because they are highly dependent on sight for feeding" (hagen_etal2026futureArctic, p. 7)

**The Table and Anzac adults.** Blackman's habitat surveys found most adults in pools and almost none in riffles, in
the deepest water near the thalweg, usually where the river narrows:

> "When the Table River data (Mathias et al. 1998, and Langston 1998) were pooled with the Anzac data, 63% of the adult grayling were found in pools, 22% in glides, 15% in runs and less than 1% were found in riffles." (blackman20041997Arctic, p. 10)

> "Grayling in the Anzac River occupy the deepest water at or near the thalweg, usually where the river is narrow." (blackman20041997Arctic, p. 10)

> "Adults were frequently found in deep pools created by woody debris but were seldom observed in the debris, but instead near the thalweg of the current." (blackman20041997Arctic, p. 13)

In the Table, Mathias et al. saw adults and subadults most often in small pools or glides with some wood, beside the
wood rather than under it:

> "Adult and sub-adult Arctic grayling were most often observed in small pools or glides containing at least some large woody debris. The grayling were not generally observed directly under the debris or other cover, but typically to a few metres to the side, or behind the debris." (mathias_etal1998SummaryReport, p. 49)

As the water dropped in late summer, the adults crowded into pools and moved upstream; at higher water they stayed
spread out, in deeper glides as well:

> "In this report (Fig. 16) and subsequent surveys (Blackman and Hunter 2001) during late summer under low flow conditions, mature adults were more concentrated in pools and tended to be further upstream in the system. At higher flows in early summer, the adults were more widely distributed (Appendix B) and more frequently were observed in deeper glides." (blackman20041997Arctic, p. 13)

> "Adult grayling tend to become more concentrated in the upper reaches as water levels drop in late summer, but if water levels do not drop, more adults tend to remain in the lower and middle reaches." (blackman2002DistributionRelative, p. 6)

> "The larger grayling are residing in the upstream reaches as in previous surveys, as the adults move upstream as flows decrease and the season progresses." (cowie_blackman2012OverviewSummary, p. 13)

Across the Williston watershed, Stamford et al. 2017 judge pools in clear reaches of moderate gradient a key need of
adults and subadults, citing Blackman 2004 and Mathias et al. 1998, and Stewart et al. 1982 and Lamothe and Magee 2004
for other streams:

> "Access to pool habitat, especially, within clear stream reaches of moderate gradient appears to be a key habitat requirement for adult and subadult Arctic Grayling within the Williston watershed" (stamford_etal2017FWCPArctic, p. 13)

In the Anzac River (Parsnip), snorkel surveys in July to September 2022 found grayling associated with cool pools:

> "This work produced a suite of ecological data examining the Anzac River Arctic grayling during their summer rearing period from July-September 2022." (bottoms_etal2023Criticalhabitats, p. 6)

> "At both the reach-scale and the riverscape-scales, snorkel surveys showed associations between Arctic grayling occurrence and cool pool habitats." (bottoms_etal2023Criticalhabitats, p. 6)

Hagen and Stamford list, among natural factors their Parsnip snorkel counts could be used to evaluate (an analysis
not yet done), their observation that streams with long low-gradient meanders hold fewer adults:

> "These data therefore provide a good opportunity for evaluating natural factors limiting Arctic Grayling distribution and abundance in the Parsnip core area" (hagen_stamford2023ParsnipArctic, p. 51)

> "Our observation is that streams of the Parsnip River watershed with extensive sections of low-gradient meanders have fewer adult grayling." (hagen_stamford2023ParsnipArctic, p. 51)

> "The process of compiling these data and designing an analysis has begun." (hagen_stamford2023ParsnipArctic, p. 51)

In Adsett Creek (BC), grayling were densest, per unit of habitat, in the steep sections, which the authors read as a
preference; large grayling were repeatedly found in the deeper pools there through the summer, and smaller fish used the
area continuously (the first quote skips a word the scan splits across a line). Their diet was mostly terrestrial
insects:

> "these sections supported the most ... per unit area of habitat" (stewart_etal1982Ecologicalstudies, p. 46, OCR)

> "These results suggest that grayling preferred areas of steep gradient, typified by Sections 3 and 4. Throughout the summer, large grayling (250 mm) were repeatedly found in the deeper pools of this area. Smaller fish utilized this area continuously" (stewart_etal1982Ecologicalstudies, p. 46, OCR)

> "Most of their diet consisted of terrestrial insects" (stewart_etal1982Ecologicalstudies, p. 47, OCR)

In Alaskan streams north of the Yukon River, Den Beste and McCart's adults used channels averaging 10 m wide and
selected against those under 6 m (the 10 m is the average width used, and widths under 6 m were selected against; neither
is a limit):

> "The average channel width used by adults was is 10m, but channels less than 6 m wide are selected against." (denbeste_mccart1984Overviewstudies, p. 35)

In the Little Nahanni (Northwest Territories), adults were found high and cold:

> "Adults had a strong correlation to elevation and water temperature, using habitats with high elevation (>1200 m) and low temperature (7oC), and increased proportions of pool and boulder habitat." (mcpherson2020Habitatuse, p. iii)

Across the range, the Northwest Territories review, citing Vascotto 1970, Hughes and Reynolds 1994 and Hughes 1998a
and 1999, reports the larger fish holding the upstream positions:

> "As cohorts age their distribution in the river gradually increases as they move upstream, with the fastest growing fish in the upper reaches and slower growing fish in the lower reaches." (stewart_etal2007Fishlife, p. 21)

> "Headwater positions appeared to be preferred by grayling, and the larger fishes were more successful competing for these positions" (stewart_etal2007Fishlife, p. 21)

**Stream size in the Williston watershed.** Hawkshaw and Shrimpton sampled juveniles across the Williston watershed in
the low-flow summers of 2009 and 2010. Juveniles were absent from the streams sampled below fourth order, but present
or absent above it, so
stream order predicts only absence; at the site scale they were likelier far from the reservoir, in large streams with
steady temperatures, and short tributaries were unlikely to hold them (stream order is also the evidence table's
grayling rows):

> "Research was conducted in the Williston watershed during the low-flow summer months of 2009 and 2010" (hawkshaw_shrimpton2014Temperaturepreference, p. 2)

> "Juvenile Arctic grayling were absent from study streams with small stream order (< 4), but were both present and absent in large stream order streams (≥ 4)." (hawkshaw_shrimpton2014Temperaturepreference, p. 25)

> "The microhabitat analysis results suggest that in the summer months juvenile Arctic grayling are likely to be present in sites further away from the Williston reservoir in large streams with low daily temperature variance." (hawkshaw_shrimpton2014Temperaturepreference, p. 29)

> "The results of our investigation suggest that the probability of juvenile Arctic grayling occurrence increases with stream size and that shorter tributaries (< 79 km) are not likely to be used by juvenile Arctic grayling." (hawkshaw_shrimpton2014Temperaturepreference, p. 31)

Gradient did not predict where juveniles were, at the watershed scale, though grayling are absent from all the major
watersheds east of the reservoir:

> "We investigated the influence of three gradient variables (aveG, maxG and minG) on Arctic grayling occurrence in the Williston watershed in a single model. These variables showed no collinearity with one another and the model ranked poorly." (hawkshaw_shrimpton2014Temperaturepreference, p. 25)

> "Arctic grayling are also absent from all the major watersheds on the eastern side of the Williston reservoir regardless of stream order." (hawkshaw_shrimpton2014Temperaturepreference, p. 25)

Stamford et al. 2017 read this study and Ballard and Shrimpton 2009 as suggesting grayling are more limited to
cooler fifth-order streams; neither original says fifth order (Hawkshaw and Shrimpton, above, give fourth):

> "the Williston Reservoir watershed might present a somewhat unique picture, as grayling appear more limited to cooler fifth order streams" (stamford_etal2017FWCPArctic, p. 7)

Hagen et al. 2026 judge that a long unflooded mainstem is needed, and note that summer sampling may miss small
tributaries used early in the year:

> "In the Williston Reservoir watershed, a substantial amount of unflooded mainstem length appears to be necessary to complete the life cycle." (hagen_etal2026futureArctic, p. 7)

> "Sampling in the summer may underestimate the importance of smaller tributaries which may have reduced habitat or be too warm in summer but provide conditions for rapid fry growth in spring and early summer." (hagen_etal2026futureArctic, p. 7)

**Low gradient, as the reviews state it.** Across the range, Hagen et al. 2026, citing deBruyn and McCart 1974, Craig
and Poulin 1975, Stuart and Chislett 1979, Butcher et al. 1981, Northcote 1993 and Stewart et al. 2007:

> "Generally, across the range of Arctic Grayling, all life history stages (young-of-year fry, age-1+ and age-2+ juveniles, subadults and adults) require clear, relatively low gradient stream reaches for rearing" (hagen_etal2026futureArctic, p. 7)

## Where do they spend the winter?

**In the Parsnip, the mainstem.** Blackman's tagged adults wintered spread along the Parsnip mainstem, not gathered at
any one place, and many in shallow, faster water; only one wintered in the Table or Anzac, though deep pools there were
plenty:

> "There were no large concentrations of tagged fish at any one location during the winter, as had been expected. Rather, the fish were spread out along the Parsnip River (Fig. 3)." (blackman2002RadioTelemetry, p. 9)

> "Surprisingly, many of these grayling overwintered in shallow, higher velocity areas associated with riffles, side channels, islands or mid channel bars." (blackman2002RadioTelemetry, p. 17)

> "Only one fish remained in the tagging streams despite the presence of numerous deep pools and debris cover." (blackman2002RadioTelemetry, p. 13)

He judged that winter habitat may not be limiting:

> "Given the wide variety of areas utilised and the mobility of these fish during the winter, lack of overwintering habitat may not be a critical factor." (blackman2002RadioTelemetry, p. 18)

Martins et al.'s acoustic telemetry found the wintering fish gathered near the tributary mouths:

> "Overwintering assemblages of Arctic Grayling in the Parsnip River mainstem are concentrated in the reaches near the confluences of the four study tributaries" (martins_etal2022SpatialEcology, p. 32)

Across the Williston watershed, Hagen et al. 2026 assume wintering habitat overlaps juvenile habitat, and Ballard and
Shrimpton say little is known of winter movement and habitat in the Omineca region:

> "Overwinter habitats are also assumed to overlap with juvenile critical habitats (Section 3)." (hagen_etal2026futureArctic, p. 26)

> "Sampling effort has been focused in the summer months and very little is known about overwintering movements and habitat use." (ballard_shrimpton2009Summaryreport, p. 60)

**Small BC streams.** In the Sukunka (BC), some two-year-olds wintered in deep tributary pools:

> "Under-ice sampling showed some two year olds remain in the deep tributary pools overwinter" (stuart_chislett1979AspectsLife, p. 3)

In Adsett Creek (Liard, BC), the authors suggest that juveniles' wintering in small tributaries such as Adsett Creek is
related to the conditions before freeze-up and is not obligatory; winter sampling of similar small tributaries found only underyearlings and yearlings (EVS 1982d,
reported by Stewart et al. 1982):

> "suggest that the propensity to overwinter in small tributaries such as Adsett Creek is related to physical conditions which preceed freeze up, and that overwintering in such habitat is not obligatory." (stewart_etal1982Ecologicalstudies, p. 90, OCR)

> "tributaries similar in size to (and including) Adsett Creek were utilized only by overwintering underyearling and yearling grayling" (stewart_etal1982Ecologicalstudies, p. 90, OCR)

**The Little Smoky River (Alberta).** Radio-tagged grayling had no fixed winter grounds; they moved into deep pools
and glides with cover as the water cooled in October, then to the edges of the new ice, and most wintered where the
mean gradient was 0.17 to 0.18 % (where fish wintered, not a limit; the evidence table's grayling rows):

> "Arctic grayling overwintering grounds were not located in specific or restricted areas of the Little Smoky River." (stanislawski1997FallWinter, p. 37, OCR)

> "the fish were observed using more deep pools and glides with cover in the form of logs, log jams, beaver caches, and bridges" (stanislawski1997FallWinter, p. 37, OCR)

> "By October 26, the fish were moving out of deep pools and glides and started to utilize the edges of surface ice as cover." (stanislawski1997FallWinter, p. 37, OCR)

> "most fish overwintered in water with a mean gradient in the 0.17-0.18% range" (stanislawski1997FallWinter, p. 42, OCR)

> "In general, overwintering grounds were not restricted in the Little Smoky River as they are in Alaskan streams (Krueger 1981)." (stanislawski1997FallWinter, p. 42, OCR)

**Deep pools, across the range.** Cannings and Ptolemy, in the habitat account that opens with Northcote's (1995)
summary of the literature:

> "Large deep pools are required for overwintering and holding water." (cannings_ptolemy1998RareFreshwater, p. 48)

**Elsewhere, spring-fed water.** In the Northwest Territories and Alaska, grayling winter in deep lakes and large
rivers, and the use of spring-fed reaches may be relatively common (McCart 1974, Jessop and Lilley 1975 and
N. Mochnacz, reported by Stewart et al.; the Cache Creek depth is where fish wintered, not a limit):

> "The use of spring-fed tributaries by grayling for overwintering and perhaps spawning may be relatively common" (stewart_etal2007Fishlife, p. 22)

> "Areas fed by perennial springs are used by adult grayling overwintering in Cache Creek, NT (Feb. 21-23, 1974, depth 0.5-1.5 m, 2-8°C Jessop and Lilley 1975)" (stewart_etal2007Fishlife, p. 22)

> "Deep lakes and large rapid runoff rivers serve as overwintering habitat in the Tanana River drainage." (tack1980Migrationsdistributions, p. 3)

In Alaskan streams north of the Yukon River, Den Beste and McCart judged winter habitat the likelier limit on
numbers:

> "It appears that some other factor, most likely overwintering habitat, is probably limiting the number of fish in most areas." (denbeste_mccart1984Overviewstudies, p. 34)

## What limits them?

**Loss of large-river habitat to the reservoir.** Hagen et al. 2026, citing Stamford et al. 2017:

> "The creation of Williston and Dinosaur Reservoirs resulted in the extirpation of an estimated 24 populations inhabiting the lower reaches of the Parsnip and Finlay rivers and upper reaches of the Peace River." (hagen_etal2026futureArctic, p. iii)

> "Flooding of roughly 350 km of the Peace River, Finlay River, and Parsnip River valleys eliminated much of the low gradient mainstem habitat that would have been used for rearing by juvenile grayling, and for overwintering for both juvenile and adult life stages." (hagen_etal2026futureArctic, p. 7)

> "This habitat loss is the most plausible explanation for the relatively rapid extirpation of populations in the Williston and Upper Peace core areas" (hagen_etal2026futureArctic, p. 7)

**Temperature.** Across the range, Hagen et al. 2026:

> "Water temperature is also a key factor limiting Arctic Grayling populations, both through direct effects on survival and growth, and likely also through temperature-mediated species interactions." (hagen_etal2026futureArctic, p. 7)

In the Williston watershed, citing Bottoms et al. 2023, Hawkshaw and Shrimpton 2014 and O'Connor et al. 2025:

> "In the Williston Reservoir watershed, Arctic Grayling are found in streams with cool, stable water temperatures" (hagen_etal2026futureArctic, p. 7)

In the Omineca region, Ballard and Shrimpton found no grayling captured in water recorded above 14.5 °C, from records
they warn must be read with caution; in the Peace Region the recorded range was much wider:

> "These data, however, must be again be interpreted with caution." (ballard_shrimpton2009Summaryreport, p. 45)

> "It would appear that grayling distributions are limited to cooler waters as fish were not captured in water recorded to be greater than 14.5 oC in the Omineca Region." (ballard_shrimpton2009Summaryreport, p. 45)

> "The range in water temperatures where grayling have been found is much wider than documented for the Omineca Region; range from 1 oC in October to 25 oC in August." (ballard_shrimpton2009Summaryreport, p. 45)

**Sediment and turbidity.** Across the range, Hagen et al. 2026, citing Birtwell et al. 1984, McLeay et al. 1987 and
Reynolds et al. 1989:

> "Elevated sediment transport reduces water clarity and negatively affects Arctic Grayling populations, both through direct effects on the health and survival of individual fish, and also through degradation of habitat for feeding and reproduction" (hagen_etal2026futureArctic, p. 7)

**Flow.** In the Sukunka (BC), a missing year class was put down to high flows and heavy sediment in the summer of
1976:

> "The grayling population in the Sukunka remained stable throughout the study period and was marked by the absence of the 1976 year class." (stuart_chislett1979AspectsLife, p. 2)

> "high flows and heavy sediment loads during the summer of 1976." (stuart_chislett1979AspectsLife, p. 2)

Blackman, reviewing the literature, says fry losses to floods and year-class failures from high flows are widely
reported:

> "The vulnerability of newly hatched grayling fry to floods is cited throughout the literature with numerous year class failures attributed to high stream flows" (blackman2002RadioTelemetry, p. 19)

Stamford et al. 2017 see spring flows after emergence as a possible bottleneck, and report Tack (1974) on the Chena
River (Alaska) and Clark (1992):

> "Immediately following emergence, however, high and variable flows related to spring freshet might limit the availability of low-velocity rearing space." (stamford_etal2017FWCPArctic, p. 12)

> "Tack (1974) noted absence of a whole year class in Chena River following a flood event and Clark (1992) found a significant correlation between recruitment levels and stream flows over a 14-year period." (stamford_etal2017FWCPArctic, p. 12)

Low water kills fry too: in the Table and Anzac, Blackman and Hunter report fry concentrated in very shallow margins,
and cite reports of heavy losses to stranding:

> "Arctic grayling fry concentrate in very shallow (<10 cm) stream margin areas (Blackman 2002 in prep) and numerous authors (deBruyn and McCart 1974, Peterson 1968, McCart 1972) have reported that mortalities through stranding can be very high." (blackman_hunter20011998Arctic, p. 29)

**Barriers.** The Northwest Territories review names unimpeded passage as a key requirement:

> "unimpeded access between spawning, feeding, and overwintering areas -- particularly during the spring spawning period" (stewart_etal2007Fishlife, p. v)

> "Spawning success appears to be strongly affected by stream obstructions that prevent or delay migrations" (stewart_etal2007Fishlife, p. v)

Across the range, Stamford et al. 2017 name poorly installed crossings:

> "Disturbances to rare natal areas or restricted access (e.g. hanging culverts) to critical spawning and rearing habitat can seriously harm or eliminate Arctic Grayling from a watershed." (stamford_etal2017FWCPArctic, p. 19)

## What the documents read here do not settle

- **Spawning sites in the Williston watershed.** No spawning site there has been seen. The Parsnip telemetry gives
  suspected areas (two Anzac reaches, Parsnip side channels, a small Parsnip tributary), inferred from where tagged
  fish held and where fry were later found; an egg search in the Anzac found none (as did one in the Sukunka, a Pine River
  tributary beside the Williston watershed); elsewhere (the Osilinka, the Nation, the Ospika, the upper Finlay) spawning is inferred from fry. Hagen et
  al. 2026 call it a gap:

  > "Imprecise knowledge of overwintering and spawning locations remains an important information gap limiting conservation and recovery actions for these life stages" (hagen_etal2026futureArctic, p. 26)

  No source read gives the gradient or size of a Williston stream where spawning was seen. In BC, the one spawning
  stream described is Adsett Creek (Liard), where turbidity hid the spawning itself; spawning sites outside BC are the
  evidence table's grayling rows.
- **Spawning dates seen, not inferred, in BC.** The Sukunka dates come from fry development, the Parsnip dates from
  water temperature and fry emergence, and the Adsett Creek dates are given as apparent.
- **Lacustrine grayling in BC.** The Toodoggone lake-inlet population and the lower Peace lake populations are named
  but not described in any source read, and the Mesilinka grayling above the lake are named only through Cowie and
  Blackman's citation.
- **Winter habitat of fry and juveniles in BC.** The Sukunka study infers, from fry in ice-covered cobble riffles in
  November and yearlings moving downstream in June, that fry may winter in the cobbles of frozen side channels (its
  summary) or in the tributary (its discussion), and winter sampling of tributaries the size of Adsett Creek (Adsett
  among them) along the Alaska Highway gas pipeline found them used only by underyearlings and yearlings; no BC study
  follows fry or juveniles through a winter. The Williston syntheses assume, not show, that juvenile and winter habitats
  overlap. Adult winter habitat in the Williston watershed rests on one winter of Parsnip radio telemetry and the later
  acoustic telemetry.
- **Rearing in the Parsnip's other tributaries.** Fry were found in 6 of 13 Parsnip tributaries sampled in 2005 (the
  Table and Anzac not sampled), and none were caught or seen in the Table's tributaries; what these tributaries
  contribute is not measured.
- **Primary studies cited only through reviews.** Among them: Hawkshaw et al. 2013 (the library holds its abstract
  only), Northcote 1993 and 1995 (1995 held with no text), Butcher et al. 1981 (Liard), McPhail 2007, McLean and
  Langston 1992, Pollard and Miller 2011, Clarke et al. 2005, Stamford et al. 2015, O'Connor et al. 2026, Chu Cho
  Environmental 2018, Stamford and O'Connor 2022, Sherstone and Blackman 2008, ECL Envirowest 1998, EVS 1982d, Armstrong
  1986, Tack 1974, Clark 1992, Ott and Morris 2005 and 2006, Kratt 1977, Vascotto 1970, Hughes and Reynolds 1994, Tripp
  and McCart 1974 and Jessop and Lilley 1975, read here only through Stamford et al. 2017, Hagen et al. 2026, Stewart et
  al. 2007, Stewart et al. 1982, Cannings and Ptolemy 1998 or Cowie and Blackman 2007 and 2012.

## How the quotes are checked

`scripts/0280-literature-verify.R` checks each quote as it checks the evidence table's: the citation key resolves to
one item in the group library, and the passage's words occur in that item's PDF text, or in an OCR of the page images
where the citation says `OCR`. The file is read as GitHub renders it (cmark-gfm). The gate proves the words are in the
source; the meaning of each sentence around them is audited by hand.
