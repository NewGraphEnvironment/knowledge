# Bull trout life history: what the documents say

**Verified:** 2026-11-16 · **Issues:** #198 (this); the store is #194's; relates #33 (`bt_spawning.md`), #51 (age-0
length) and #199 (datasets) · **Produced by:** the `bull_trout` store, searched with expectations written first
(`scripts/logs/rag/20261116_query_bull_trout_198.log`); each passage read on its page of the group library's PDF; every
quote checked by `scripts/0280-literature-verify.R`, which lists this file in `QUOTED` (log
`scripts/logs/habitat/<yyyymmdd>_literature_verify_research.csv`) · **Status:** complete for the six topics #198 names;
gaps at the end.

Each claim below is a plain sentence followed by the passage that carries it, quoted verbatim with its citation key
and page. Pages are the printed ones, with these exceptions, where the page is the PDF's:
- the two federal registry pages and the 2025 COSEWIC report, which the library holds as prints of web pages;
- the covers of the COSEWIC reports;
- the executive summary of the Metolius report.

Where a source reports another study, the sentence names it. Every claim says where it was measured: a BC drainage,
or Montana, Oregon, Washington or Alberta. Numbers already held in `data/literature_evidence.csv` are not restated:
they are cited by data row (row N is file line N + 1), and the files that read them are linked.

## In brief

- **Three forms inland, a fourth on the south coast.** Bull trout grow up in small, cold streams. A resident form
  stays there all its life, small and early maturing, usually cut off by falls, fast water or, in the south, warm water. A fluvial form moves down to a large
  river to grow, and an adfluvial form moves to a lake or reservoir; both come back to small streams to spawn, large
  and late maturing. In Canada a sea-run form occurs only on BC's south coast, in the southern genetic lineage. The forms often
  share a watershed and its spawning streams.
- **Spawning runs in summer, spawning in late summer and fall.** Migratory adults leave the river or lake between
  spring and midsummer, earlier when the run is long. They spawn from August to October, and the spent fish, females
  first, leave the spawning streams soon after; tagged fish were back in their rivers or lakes by early November in
  the upper Kootenay and by the end of November in the Salmo (BC), and by the end of December in Oregon. Falling water temperature is the likely cue, though not a precise one. Hagen and
  Weber judge that most BC migratory spawners spawn every year and some every other year; in BC tagging studies, 41 to
  80 % of tagged spawners came back the next year, by measures that differ between studies.
- **Redds go where groundwater comes up.** Within the spawning streams, fish choose reaches fed by upwelling
  groundwater (the Swan basin in Montana, the Chowade River in BC). They spawn on gravel near cover in a small share
  of the stream length, and the same sites are used year after year. In the Chowade, eggs at the chosen sites survived better
  and stayed warmer than eggs nearby.
- **Eggs winter in the gravel.** They hatch in winter or early spring, and fry emerge in spring.
- **Juveniles live on the bed.** Fry hold in shallow, slow margins and side channels among cobble. In the Chowade
  River older juveniles used deeper, faster water with boulders and wood; in the Arrow Lakes tributaries juveniles,
  young-of-the-year among them, kept to shallow, slow margins over boulders. Both stay close to cover and the bottom. Migratory juveniles leave
  the natal stream mostly at age 2 or 3; residents stay.
- **Cold water throughout.** The temperature limits are evidence rows, read in `thermal_requirements.md`.
- **Five units in Canada, four of them in BC; two on Schedule 1.** COSEWIC splits Canada's bull trout into five
  designatable units. The
  South Coast and Western Arctic units are listed as Special Concern under the Species at Risk Act. COSEWIC moved the
  Pacific unit, the rest of BC's Pacific drainages, from Not at Risk to Special Concern in 2025.

What this file is not: a source for habitat thresholds. Spawning gradient and channel size are `bt_spawning.md` and
`habitat_literature.md`; the tuned rules are `bull_trout_tuned.md`.

## What are the forms, and do they mix?

**The three forms.** The reviews describe stream-resident, fluvial and adfluvial forms. The resident form spends its
whole life in small streams. The fluvial form lives in large rivers and the adfluvial form in lakes or reservoirs, and
both migrate to smaller streams to spawn.

> "Throughout much of its geographic distribution three life-history types are common: adfluvial, fluvial, and stream-resident populations. The adfluvial life-history involves migrations between lakes or reservoirs and spawning rivers or streams. The fluvial life-history form lives in large rivers and often migrates to smaller rivers or streams to spawn. In contrast, the stream resident form is non-migratory and spends its entire life in small streams." (mcphail_baxter1996reviewbull, p. 12)

A BC stock report on the Pine (Peace) and upper Kootenay watersheds opens, citing Rieman and McIntyre 1993, with the
migratory forms rearing in the natal tributary first and returning to it to spawn:

> "Migratory fish live in tributary streams for the first few years and then migrate either to larger rivers (fluvial form) or lakes (lacustrine or adfluvial form) to mature before returning to natal tributaries to spawn. Resident fish remain in small headwater streams throughout their entire life history" (pollard2001LifeHistory, p. 2)

**Where the resident form lives.** McPhail and Baxter place stream residents in headwater streams, usually cut off
from other populations by falls, fast water or, in the south, warm water. In the Arrow Lakes tributaries (BC), Ladell found the two patterns split at waterfalls.

> "Stream-resident bull trout usually are separated from other populations by some barrier (typically falls or velocity barriers and in the south by areas of high temperature). Consequently, stream-resident populations are associated with headwater streams in mountainous regions where cold water and velocity barriers are common." (mcphail_baxter1996reviewbull, p. 12)

> "Bull trout populations in the Arrow Lakes exhibit two distinct life history patterns depending on whether they live above or below waterfall barriers. Migratory populations utilize the lower reaches of tributaries for spawning and rearing but resident populations carry out their entire life history upstream of waterfall barriers." (ladell2003EcologyLife, p. ii)

In the Williston Reservoir watershed (BC, Peace), Hagen and Weber expect the resident form where migrants are cut
off or few:

> "In less productive tributaries of the Williston Reservoir that are somewhat or completely isolated by migration barriers or by distance from other populations of ... large-bodied, migratory fish, the stream resident life history may be favoured" (hagen_weber2019Limitingfactors, pp. 21–22)

**Size.** Resident adults are small and migratory adults large. In the Liard system (the review names no finer place), McPhail
and Baxter, citing Craig and Bruce 1982:

> "most stream-resident populations are dwarfed. For example, in the Liard system, stream-resident adults average about 200 mm and rarely exceed 300 mm; whereas, adults in larger tributaries and in the mainstem average about 400 mm, and often exceed 600 mm" (mcphail_baxter1996reviewbull, p. 12)

Rieman and McIntyre (a range-wide review, citing Goetz 1989 and others) give the same contrast:

> "Resident adults range from 150 to 300 millimeters in length ... while migratory fish commonly exceed 600 millimeters" (rieman_mcintyre1993Demographichabitat, p. 2)

In the Arrow Lakes tributaries (BC), mature residents above the falls were far shorter than adfluvial broodstock from
the same lakes. Ladell warns that the broodstock came from many Arrow Lakes tributaries, so it stands in for the
migrants of his study streams.

> "The average length of males and females combined was 186.2 ± 9.2 mm." (ladell2003EcologyLife, p. 86)

> "Fork lengths of a total of 260 mature adfluvial bull trout collected as broodstock for the Hill Creek Hatchery averaged 591.9 ± 5.0 mm for both sexes." (ladell2003EcologyLife, p. 86)

> "The body sizes of these fish are to be taken as a surrogate for body size of migratory bull trout populations from St. Leon and Burton Creeks." (ladell2003EcologyLife, p. 103)

> "as above-barrier and stream resident bull trout showed lower growth rates, reduced body sizes and younger ages at maturity compared to below-barrier fish." (ladell2003EcologyLife, p. 108)

The BC management plan gives sizes by form: for residents a range it does not tie to BC (it cites Goetz 1989 and
McPhail and Baxter 1996), for adfluvial fish BC's lakes and reservoirs, and for fluvial fish BC populations, some as large as
adfluvial ones:

> "Mature, stream resident Bull Trout may be up to eight years of age and range in size from 115-300 mm" (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 13)

> "In large lake and reservoir environments in B.C., adfluvial Bull Trout can reach sizes of up to 970 mm and 13.6 kg and live to 14 years" (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 13)

> "Most fluvial populations in B.C. are comprised of smaller individuals (means of 380 to 480 mm ... but populations in the Stikine, Liard, Peace, upper Fraser ... and upper Kootenay rivers can be as large as adfluvial populations" (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 13)

**Age at maturity.** Migratory fish mature later than residents. McPhail and Baxter, citing Robinson and McCart 1974
and Craig and Bruce 1982 for the first passage:

> "stream-resident fish tend to mature one or two years earlier than migratory populations in the same region" (mcphail_baxter1996reviewbull, p. 13)

> "In habitats where bull trout achieve sizes in excess of 400 mm, sexual maturity usually is reached in their fifth summer (4+)" (mcphail_baxter1996reviewbull, p. 15)

> "Most information indicates bull trout mature when they are between 5 and 7 years of age" (rieman_mcintyre1993Demographichabitat, p. 3)

In the North and Middle Forks of the Flathead (Montana, adfluvial), most spawners were six or seven; Fraley and
Shepard add, citing Leathe and Enk 1985, that most Swan system spawners were five or six:

> "Most bull trout spawners in the North and Middle Forks were six or seven years of age (Table 3) whereas most spawners in the Swan system were five or six years old" (fraley_shepard1989LifeHistory, p. 137)

**Migration.** The fluvial and adfluvial forms make the same kind of spawning run, out of a river or a lake in summer.

> "The adfluvial life-history form shows a similar migration pattern to the fluvial form: in the summer (during periods of maximum water temperature and low flows) adults migrate out of lakes into spawning streams" (mcphail_baxter1996reviewbull, p. 16)

The runs can be long. In the upper Kootenay (BC), one radio-tagged fish:

> "migrated 204 km upstream from its over-wintering location in Lake Koocanusa to reach its spawning grounds in the White River. After spawning, this same fish made a post-spawning migration of 208 km downstream to over-winter in Lake Koocanusa." (westover_heidt2004UpperKootenay, p. 19)

**Do the forms mix?** The BC management plan says they often share a watershed.

> "Different life history forms often co-occur in the same watershed although some spatial segregation may occur." (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 13)

In the upper Kootenay (BC), fish tagged in the river turned out to be both fluvial and adfluvial, and they spawned in
many of the same tributaries.

> "it was estimated from radio telemetry data that 20% of the radio tagged fish were adfluvial and over-wintered in Lake Koocanusa. The remaining 80% of the tagged bull trout displayed a fluvial life history form" (westover_heidt2004UpperKootenay, p. i)

> "Both life history forms spawned in many of the same systems, but clearly utilized different areas for over-wintering. The use of similar spawning areas suggests a degree of genetic mixing occurs between the adfluvial and fluvial bull trout populations found in the upper Kootenay watershed." (westover_heidt2004UpperKootenay, p. i)

In the Metolius River and Lake Billy Chinook (Oregon), most fish appeared adfluvial, but some were fluvial and some
appear to have switched:

> "Most bull trout in the Metolius River Basin and Lake Billy Chinook appeared to demonstrate an adfluvial life history pattern." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 20)

> "However, a portion of the population demonstrated a fluvial life history pattern in which juvenile bull trout migrated from tributary streams to the Metolius River, where they remained to rear." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 20)

> "Other bull trout appear to have changed life history patterns." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 20)

Migratory and resident fish can spawn in the same stream. McPhail and Baxter, citing McPhail and Murray 1979 for
Mackenzie Creek (upper Arrow Lakes, BC), say the extent of interbreeding is not known:

> "some lacustrine bull trout ascend Mackenzie Creek over barriers that stop rainbow trout, and spawn in a portion of the creek occupied by a stream-resident form" (mcphail_baxter1996reviewbull, p. 13)

> "How much genetic mixing between different life-history forms occurs in such areas is unknown" (mcphail_baxter1996reviewbull, p. 13)

Rieman and McIntyre, citing Jakober 1992 (Montana), say the forms live together, and that whether they are one
population or two is unknown:

> "Resident and migratory forms live together (Jakober 1992), but we do not know if they represent a single population or separate populations." (rieman_mcintyre1993Demographichabitat, p. 2)

In one upper Kootenay spawning stream (Line Creek, BC), Pollard reads a single small older male as possibly both forms,
or as males maturing early:

> "A small older male (240 mm, 6 yr.), in addition to the larger females, observed in Line Cr. might suggest two different life histories are occurring in this population; migratory and resident (or precious maturation of males)." (pollard2001LifeHistory, p. 9)

## When do they migrate and spawn?

**The spawning season.** Bull trout spawn in late summer and fall: September to October in McPhail and
Baxter's summary, and mid-August to mid-October in Hagen and Weber, who cite the same review for it. McPhail and Baxter note that the timing changes little
with latitude.

> "The bull trout spawns in the fall (September to October) in flowing water." (mcphail_baxter1996reviewbull, p. i)

> "Curiously, the actual time of spawning varies little with latitude, and both northern and southern populations spawn at about the same time" (mcphail_baxter1996reviewbull, p. 6)

> "Bull trout spawning generally takes place between mid-August and mid-October (McPhail and Baxter 1996), although spawning as early as July has been observed in Oregon (Ratliff 1992)." (hagen_weber2019Limitingfactors, p. 22)

**The run in BC.** In the upper Kootenay, radio-tagged fluvial and adfluvial fish started their run in late spring,
entered the tributaries in July, and spawned in September and early October.

> "Generally, bull trout began their pre-spawning migration from their over-wintering locations in the Kootenay River and/or Lake Koocanusa between mid-May and mid-June during ascending and peak discharge levels" (westover_heidt2004UpperKootenay, p. 18)

> "and entered their spawning tributary streams throughout July corresponding with decreasing discharge rates and with water temperatures in the Kootenay River approaching seasonal highs ... Spawning occurred throughout September and early October." (westover_heidt2004UpperKootenay, p. 19)

In the Duncan River (BC), radio-tagged adfluvial fish from Kootenay Lake moved to the spawning destination over the
summer, stayed there, then left quickly.

> "Migrations into the upper Duncan River system involved immigration to a spawning destination (mean = 51 days; from 8 July to 29 August), residence at the destination (mean = 32 days), and a rapid emigration back to the Duncan Reservoir (mean = 9 days; from 28 September to 8 October)." (obrien1999Duncanbull, p. i)

In the Salmo River (BC), a fluvial population, radio-tagged fish reached the spawning areas earlier in one year than
the other, which Baxter puts down to lower summer discharge.

> "In 1999, bull trout entered spawning areas as early as the first week of August, while in 2000 entry into spawning areas had begun as early as the first week of July. The difference in timing was likely due to reduced discharge in the summer of 2000." (baxter2001AspectsBiology, p. ii)

> "The spawning period in 1999 (timing while fish were in their spawning areas) for bull trout in the watershed was between the beginning of August and end of September, with spawning likely peaking around the middle of September." (baxter2001AspectsBiology, p. 11)

In the Williston Reservoir watershed (BC, Peace), Hagen and Weber tie the start of the run to the distance travelled,
citing O'Brien and Zimmerman 2001 and Hagen and Strohm 2019 for the short runs, and give the upper Peace spawning
window.

> "The timing of movements of adult Bull Trout to spawning areas also appears to be influenced by the distance to be traveled." (hagen_weber2019Limitingfactors, p. 21)

> "Bull Trout spawners returning to the Davis River in the Finlay Reach watershed and Attichika Creek in the upper Finlay River watershed, which have a shorter migration distances to spawning areas, leave the lake environment primarily in July" (hagen_weber2019Limitingfactors, p. 21)

> "In the upper Peace Basin, spawning for fluvial and adfluvial stocks appears to occur between late-August and mid-September" (hagen_weber2019Limitingfactors, p. 22, OCR)

The BC management plan says long runs start earliest:

> "When migrations are long or difficult, they may be initiated as early as May (Hagen 2003), even though Bull Trout spawning generally takes place between mid-August and mid-October" (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 17)

**The run elsewhere.** In the Flathead (Montana), adfluvial fish travelling far upstream left the lake in spring,
entered the tributaries mostly in August, and spawned in September and early October.

> "Bull trout maturing in Flathead Lake began their spawning migration into the river system during April and moved slowly upstream, arriving in the North and Middle forks during late June and July." (fraley_shepard1989LifeHistory, p. 135)

> "adult bull trout entered tributary streams at night from July through September; the majority entered in August." (fraley_shepard1989LifeHistory, p. 137)

> "Most bull trout spawned during September and early October in the Flathead River system" (fraley_shepard1989LifeHistory, p. 137)

In the Metolius River (Oregon), adfluvial fish:

> "Adult bull trout arrived at the traps on Jack and Jefferson creeks beginning in late July and continued through the first week of October." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 17)

> "Most spawning activity occurred between 15 August and 1 October, although spawning was observed as early as 13 July (Ratliff 1992) and as late as mid-October." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 17)

**The cue.** The sources name falling temperature as the likely cue, with day length and flow as possible partners.
McPhail and Baxter:

> "Like all char, bull trout are fall spawners, and water temperature may be the proximate cue that initiates redd building and spawning behaviour." (mcphail_baxter1996reviewbull, p. 6)

> "This suggests that, although there may be a threshold temperature, some other factor (perhaps the rate of change in day length) is also involved in the initiation of spawning." (mcphail_baxter1996reviewbull, p. 6)

In the Flathead (Montana), Fraley and Shepard tie the initiation of spawning largely to water temperature:

> "in the Flathead appeared to be related largely to water temperature, although photoperiod and streamflow probably also played a part" (fraley_shepard1989LifeHistory, p. 137)

Rieman and McIntyre, citing Shepard and others 1984b (Flathead):

> "Shepard and others (1984b) associated spawning with falling temperatures between 5 and 9" (rieman_mcintyre1993Demographichabitat, p. 2)

For BC, Hagen and Weber doubt that a temperature threshold predicts the date well:

> "Water temperatures of 9ºC have been associated with the onset of spawning (McPhail and Murray 1979; Fraley and Shepard 1989), although this does not appear to be a precise predictor of spawning timing at many locations" (hagen_weber2019Limitingfactors, p. 22)

**Every year, or every other?** Not all adults spawn every year. In the Flathead (Montana):

> "Not all mature bull trout spawned annually." (fraley_shepard1989LifeHistory, p. 135)

> "It appeared that 38 to 69 percent ... left the lake each spring and summer to spawn." (fraley_shepard1989LifeHistory, p. 135)

McPhail and Baxter, citing Allan 1980 for the Clearwater River (Alberta):

> "Not all mature bull trout spawn every year. Allan (1980) found that only 27% of the adult bull trout tagged in the Clearwater River, Alberta, returned to spawn the next year" (mcphail_baxter1996reviewbull, p. 15)

In BC, the telemetry studies found many fish spawning in successive years and some in alternate years. They count
different things: return to the White River, repeat spawning in the Salmo, and return to Duncan Dam standing in for a
spawning attempt.

> "Of the seventeen radio tagged bull trout that spawned in the White River during their first year, seven (41%) returned to the White River as repeat spawners in year two and three (17.6%) were alternate year spawners." (westover_heidt2004UpperKootenay, p. 21)

> "eight of the ten bull trout tagged in 1999 repeat spawned in 2000." (baxter2001AspectsBiology, p. 64)

> "I used movement to the dam as a surrogate for repeat spawning attempt (Table 12). In total, 46.8 % of tagged bull trout returned to the Dam the year following their radio-tagging (29 of 62)." (obrien1999Duncanbull, p. 88)

Hagen and Weber sum up BC migratory populations as mostly every-year spawners with some alternate-year ones:

> "It appears common that populations of large-bodied, migratory Bull Trout spawners in British Columbia contain a mix of both every-year and alternate-year spawning strategies with the majority of fish employing an every-year strategy" (hagen_weber2019Limitingfactors, p. 23)

In the Metolius (Oregon), most fish appeared to spawn each year; this sentence is in the executive summary:

> "Most bull trout appeared to return to the same stream and spawn each year." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 5)

In the far north, COSEWIC (citing Mochnacz 2002) reports longer intervals in the Northwest Territories:

> "Spawning may occur at 2 to 3 year intervals in the Northwest Territories from all life history types" (post_etal2012COSEWICassessment, p. 30)

**Back downstream.** Spent adults leave soon after spawning, females first. In the Flathead (Montana):

> "After spawning, females left the tributaries and returned to the lake sooner than males." (fraley_shepard1989LifeHistory, p. 133)

In the Wigwam River (BC), McPhail and Baxter, citing Oliver 1979:

> "In the Wigwam River, females returned downstream shortly after spawning; whereas, males remained on the spawning grounds until late fall" (mcphail_baxter1996reviewbull, p. 7)

In the Williston watershed (BC), Hagen and Weber, citing O'Brien and Zimmerman 2001 and others:

> "Female Bull Trout leave for downstream lacustrine or fluvial habitats shortly after spawning, but a small number of fish (especially males) may remain at spawning sites in the upper Peace Basin until late September or early October" (hagen_weber2019Limitingfactors, p. 23)

How fast: in the upper Kootenay (BC) the tagged fish were back by early November, and in the Duncan the return took
days (the O'Brien quote above). In the Salmo (BC), fluvial fish were back by the end of November:

> "After spawning, most radio tagged bull trout returned immediately to the Kootenay River, and by early November tagged fish were back in their over-wintering habitats" (westover_heidt2004UpperKootenay, p. 19)

> "Post-spawning migrations to overwintering habitat had generally occurred by the end of November, and it appeared that post-spawning mortality was 0% as all fish had moved significant distances downstream to overwintering areas in both years." (baxter2001AspectsBiology, p. 64)

In the Metolius (Oregon), the return varied between fish (the report gives the telemetry as Thiesfeld et al. 1996's):

> "Some post-spawning bull trout moved downstream rapidly (Figure 6), while others showed a protracted downstream migration" (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 20, OCR)

> "All radio-tagged bull trout migrated back to Lake Billy Chinook by 31 December." (DistributionlifehistoryabundanceharvesthabitatlimitingfactorsbulltroutMetoliusRiverLakeBillyChinookOregon198394, p. 18)

## Where do they build redds?

Spawning gradient and channel width are not restated here: `bt_spawning.md` weighs them against fish records, and
`habitat_literature.md` (Bull trout: what the literature does and does not give) holds the thresholds. The evidence
rows are:
- spawning gradient: data rows 72–85, 188, 500, 506 and 507;
- channel width and stream size: rows 86–94, 189, 490 and 496;
- depth and velocity at redds: rows 497, 498, 876, 877, 881–883, 886, 887, 889 and 890;
- substrate: rows 166, 167, 491 and 499;
- groundwater: rows 675–686;
- valley width: rows 502 and 505.

**Groundwater, chosen at the reach.** The strongest evidence that bull trout pick spawning places by groundwater
comes from the Swan River basin in northwestern Montana, where migratory fish spawn in the Swan's tributaries. Redds
sat mostly in alluvial valley segments held in at their downstream end by a knickpoint, and those segments carried the
upwelling.

> "Among all valley segment types, bull trout redds were primarily found in these bounded alluvial valley segments, which possessed complex patterns of hyporheic exchange and extensive upwelling zones." (baxter_hauer2000Geomorphologyhyporheic, p. 1470)

> "Of the redds observed, 88.5% were located in bounded alluvial valley segments, whereas 8% were found in unbounded alluvial floodplain segments and only 3.5% were observed in confined valley segments." (baxter_hauer2000Geomorphologyhyporheic, p. 1475)

**And at the redd, the bed where water goes down.** The choice reverses between scales. Fish chose reaches where
groundwater came up, but within those reaches they built redds where stream water went down into the bed.

> "Bull trout used stream reaches for spawning that were strongly influenced by upwelling. However, within these selected reaches, bull trout redds were primarily located in transitional bedforms that possessed strong localized downwelling and high intragravel flow rates." (baxter_hauer2000Geomorphologyhyporheic, p. 1470)

> "The median distance from redds to the nearest downwelling piezometer was only 2.1 m, while the median distance to the nearest upwelling piezometer was 14.6 m." (baxter_hauer2000Geomorphologyhyporheic, p. 1476)

In the Swan basin, low gradient went with spawning reaches but did not pick them out:

> "We found that low stream gradient was a character of both bounded and unbounded alluvial valley segments. Consequently, it was not a direct indicator of spawning reach selection. Rather, bull trout used reaches with hyporheic groundwater discharge that also possessed low stream gradient as a covariate." (baxter_hauer2000Geomorphologyhyporheic, p. 1478)

Across the basin's spawning tributaries, redd counts rose with the extent of these segments and fell with
logging-road density:

> "Bull trout redd numbers were positively correlated with the extent of alluvial valley segments bounded by knickpoints and negatively correlated with the density of logging roads in spawning tributary catchments." (baxter_etal1999GeomorphologyLogging, p. 854)

**The BC case.** In the Chowade River (Peace system, a fluvial population), spawning sites had groundwater coming up,
and places not used had stream water going down, though the two looked alike.

> "In general, sites that were selected for spawning were areas of groundwater discharge (upwelling), while areas that were not selected for spawning were areas of surface water recharge (down welling)." (baxter1997AspectsReproductive, p. 78)

> "Spawning sites were strongly associated with groundwater discharge, while adjacent areas with similar microhabitat characteristics, but no influx of groundwater, were not used for spawning." (baxter1997AspectsReproductive, p. 82)

Eggs planted at the chosen sites survived better and stayed warmer than eggs planted nearby where fish did not spawn:

> "demonstrated that egg to alevin survival was significantly higher at selected sites than randomly available sites." (baxter1997AspectsReproductive, p. ii)

> "The cumulative water temperature profiles between the non-selected and the selected sites were different (Figure 20): the selected sites had consistently higher temperatures" (baxter1997AspectsReproductive, p. 78)

> "in the winter when the egg capsules were pulled, the locations where bull trout had spawned were the only ice free areas on the river." (baxter1997AspectsReproductive, p. 82)

In the Flathead system (Montana), spawners chose gravel, low compaction and low gradient, and groundwater and cover also
counted:

> "Bull trout spawners selected areas in the stream channel characterized by gravel substrates, low compaction and low gradient (Table 4). Groundwater influence and proximity to cover also were important factors influencing spawning site selection." (fraley_shepard1989LifeHistory, p. 137)

McPhail and Baxter's review sets groundwater against stream size: in larger streams redds sit below aggrading areas
and near groundwater, in smaller streams in pockets of gravel.

> "In larger streams the redds are often sited downstream of aggrading areas (Graham et al. 1981) and are associated with ground water sources (Heimer 1965); whereas, in smaller streams the redds are associated with pockets of suitable gravel (McPhail and Murray 1979; Allan 1987)." (mcphail_baxter1996reviewbull, p. 5)

**Substrate, cover, depth and redd size.** At the Chowade River in 1995, redds were large, on large gravel, near cover
that was mostly undercut bank. In 1994, a survey Baxter calls incomplete, they sat close to logjam cover.

> "In 1995, mean water depth at the redd sites was 56.5 cm, and redds averaged 2.53 m long by 1.25 m wide (Table 18)." (baxter1997AspectsReproductive, p. 75)

> "Most redds were located fairly close to cover ... (average of 3.87 m), primarily in the form of undercut banks (Table 18)." (baxter1997AspectsReproductive, p. 75)

> "Substrate at the redd sites consisted, on average, of large gravel" (baxter1997AspectsReproductive, p. 75)

> "redds were located close (5.4 m) to logjam cover" (baxter1997AspectsReproductive, p. 75)

Baxter compared these with Bustard and Royea's measurements in the Kemess Creek watershed, also in the Peace system:

> "mean depth of redds as 0.31 m, and a mean distance to cover as 5.4 m. They also report the mean diameter of spawning substrates as averaging between 2-4 cm." (baxter1997AspectsReproductive, p. 81)

The review gives the range across studies:

> "Water depth over the redds varies from less than 10 cm to over 1.0 m, and the redds are relatively large (up to about 1.5 X 2 m, Brown 1984; Fraley and Shepard 1989)." (mcphail_baxter1996reviewbull, p. 5)

The Swan basin study adds that the alluvial segments carry the gravel as well as the groundwater:

> "In addition to habitat influenced by groundwater discharge, these segments contain large, stable expanses of well-sorted gravel and cobble." (baxter_hauer2000Geomorphologyhyporheic, p. 1478)

**Where in the stream and the watershed.** Spawning is packed into a small share of the stream length open to it. In
the Chowade River (BC):

> "Despite the apparent abundance of suitable habitat throughout this 70 km long river, most spawning is concentrated in a stretch of less than 500 m." (baxter1997AspectsReproductive, p. 81)

In the Flathead system (Montana):

> "Bull trout from Flathead Lake spawned in only 28 percent of the 750 km of available stream habitat" (fraley_shepard1989LifeHistory, p. 137)

Spawners use the same sites year after year. The review, citing Baxter's Chowade work:

> "the choice of the same site by different females in different years (Baxter 1995) suggests that redd site selection is precise." (mcphail_baxter1996reviewbull, p. 6)

The Swan basin spawning tributaries are small by stream order. The BC stream-order rows (data rows 88–93) run from
third order and smaller (the BC plan) to the fifth- and sixth-order streams of Williston adfluvial spawning.

> "Migratory bull trout in the Swan basin spawn in second- to fourth-order streams from August through October." (baxter_hauer2000Geomorphologyhyporheic, p. 1471)

## How long do the eggs stay in the gravel?

Eggs spend the winter in the gravel. In the Flathead system (Montana), eggs laid by early October hatched in January,
and fry came out in spring:

> "After deposition by early October, bull trout embryos incubated in the redd for several months before hatching in January. The alevins then remained in the gravel and absorbed the yolk sac, with the first fry appearing in electrofishing samples in mid April. Emergence occurred approximately 200 days after egg deposition." (fraley_shepard1989LifeHistory, p. 138)

In Coal Creek, a North Fork Flathead tributary, Fraley and Shepard, reporting Weaver and White 1985, give the time from
laying to emergence and the survival to emergence:

> "incubation and development phase for bull trout embryos and alevins (223 days in Coal Creek)" (fraley_shepard1989LifeHistory, p. 141)

> "Survival to emergence in Coal Creek averaged 53 percent." (fraley_shepard1989LifeHistory, p. 138)

Development is slower in colder water. McPhail and Baxter, citing McPhail and Murray 1979 on Mackenzie Creek eggs
(Arrow Lakes, BC) in the laboratory:

> "Mackenzie Creek bull trout eggs hatched in 51 days at 10°C, and in 126 days at 2°C; however, the lower temperature produced significantly better survival than the high temperature." (mcphail_baxter1996reviewbull, p. 9)

> "In the laboratory, bull trout emerged from the gravel approximately three weeks after hatching (McPhail and Murray 1979)." (mcphail_baxter1996reviewbull, p. 10)

Alevins may stay in the gravel after the yolk is gone. Rieman and McIntyre, citing Weaver and White 1985 and McPhail
and Murray 1979:

> "Hatching occurs in late winter or early spring (Weaver and White 1985); the alevins may stay within the gravel for an extended period after they absorb the yolk, feeding and growing there (McPhail and Murray 1979)." (rieman_mcintyre1993Demographichabitat, p. 2)

In the Chowade River (BC), egg capsules dug up in late March still held alevins with yolk:

> "The egg capsules were retrieved from the river on March 23, 1996." (baxter1997AspectsReproductive, p. 72)

> "The retrieved alevins were not feeding and still had a large yolk sac." (baxter1997AspectsReproductive, p. 75)

Emergence timing in southeastern BC and northern Montana is data row 179; the hatch at 350 CTU is row 534; incubation
temperatures are rows 150 and 510. The Swan basin authors tie groundwater to the egg stage:

> "Reaches influenced by groundwater discharge possess relatively stable thermal and flow regimes that may be important for bull trout egg incubation, emergence success, and the survival of juvenile bull trout." (baxter_hauer2000Geomorphologyhyporheic, p. 1479)

## Where do young bull trout live, and when do they leave?

**Fry.** Fry live at the shallow, slow edges of streams, in side channels and among cobble. In the Chowade River
(Peace system, BC), Baxter measured where fry and juveniles held by day in summer. His fry were fish under 65 mm, his
juveniles fish over 70 mm.

> "Bull trout fry were defined as fish less than 65 mm, while juveniles were defined as fish over 70 mm." (baxter1997Summerdaytime, p. 7)

> "Fry generally preferred shallow, low bottom velocity areas with an abundance of cobble and boulder that provided cover" (baxter1997Summerdaytime, p. 11)

> "Depths between 10 and 18 cm were highly preferred, but preference declined rapidly as depths exceeded 18 cm and was 0 at depths greater than 40 cm" (baxter1997Summerdaytime, p. 11)

No fry was found away from cover, and no fry or juvenile was seen in the water column by day:

> "not a single fry was found away from some form of cover." (baxter1997Summerdaytime, p. 26)

> "In this study no rearing bull trout were observed in the water column during the daytime" (baxter1997Summerdaytime, p. 25)

In the Wigwam River (upper Kootenay, BC), the same shallow cobble margins hold the fry:

> "The association of bull trout fry with shallow (5 – 20 cm), low velocity (<0.3 m/s), cobble dominated stream margin habitat has been previously ... documented within the Wigwam River (Cope 1998)." (cope_morris2001WigwamRiver, pp. 29–30)

In the Flathead system (Montana):

> "Young-of-the-year bull trout were generally found in side channel areas and along the stream margins in Flathead tributaries." (fraley_shepard1989LifeHistory, p. 138)

In the laboratory (McPhail and Murray 1979), newly emerged fry kept to the bottom and did not fill their swim bladders
for three weeks; in Mackenzie Creek (Arrow Lakes, BC), once buoyant, fry move to the stream edge. McPhail and Baxter:

> "In the laboratory, newly-emerged fry did not fill their swim bladders until three weeks after emergence." (mcphail_baxter1996reviewbull, p. 10)

> "These newly-emerged fry were strongly bottom oriented and spent much of their time in the gravel" (mcphail_baxter1996reviewbull, p. 10)

> "In Mackenzie Creek, once neutral buoyancy is achieved the fry concentrate in shallow, low velocity areas along the stream edge." (mcphail_baxter1996reviewbull, p. 10)

**Older juveniles.** In the Chowade River (BC), older juveniles used deeper and faster water than fry, and boulder and
wood for cover:

> "Juveniles generally preferred areas with deeper water, faster bottom velocities, boulder as substrate, and an abundance of cover in the form of rootwads" (baxter1997Summerdaytime, p. 11)

> "Depths between 30 and 40 cm were preferred, with depths greater than 45 cm having 0 suitability in my study area" (baxter1997Summerdaytime, p. 11)

**Below the falls in the Arrow Lakes tributaries.** In the Arrow Lakes tributaries (BC), Ladell's juveniles of the
adfluvial populations, below the waterfalls, kept to shallow margins, over boulders, in the slowest water:

> "Juveniles from the adfluvial populations were found primarily along the stream margins. They utilized mainly shallow water (Figure 2.13) that had low bottom velocity." (ladell2003EcologyLife, p. 41)

> "Juveniles below the barrier were associated with all substrate sizes, but were strongly associated with boulders." (ladell2003EcologyLife, p. 57)

> "Below the barriers, juveniles preferred the slowest water velocities available." (ladell2003EcologyLife, p. 56)

Across his sites above and below the barriers, it was the smaller young-of-the-year that held in shallow water:

> "smaller young-of-the-year held in shallow water (Figure 2.13)" (ladell2003EcologyLife, p. 64)

In the Wigwam River (BC), the authors judge a boulder reach good for juveniles:

> "Boulder dominated substrate however, provides excellent juvenile rearing habitat and an abundance of boulder pocket pools and velocity refuge." (cope_morris2001WigwamRiver, p. 24)

In the Flathead drainage (Montana), Fraley and Shepard, reporting Pratt 1984, found larger juveniles near cover:

> "Juveniles 100 mm or longer also remained near cover, including larger instream debris." (fraley_shepard1989LifeHistory, p. 138)

Rieman and McIntyre's review gives the general picture, citing Fraley and Shepard, Oliver, Pratt, Shepard and others,
and Hoelscher and Bjornn:

> "Juvenile fish are found in close association with the bottom of the channel, often using substrate for cover (Fraley and Shepard 1989;Oliver 1979;Pratt 1984;Shepard and others 1984b)." (rieman_mcintyre1993Demographichabitat, p. 5)

> "Young-of-the-year bull trout use side channels, stream margins, and other areas of low velocity. Older fish use pools (Hoelscher and Bjornn 1989; Pratt 1984)" (rieman_mcintyre1993Demographichabitat, p. 6)

The rearing velocity values from reviews are data rows 878–880, 884, 888 and 891–893.

**How long migratory juveniles stay in the natal stream.** Most leave after one to three years. In the Flathead system
(Montana):

> "Most juvenile bull trout in the Flathead drainage remained in the tributaries for one to three years before emigrating to the river system." (fraley_shepard1989LifeHistory, p. 138)

> "about half (49%) were age II, a third (32%) age III" (fraley_shepard1989LifeHistory, p. 139)

> "Emigration of juveniles from the tributaries into the Flathead River system took place largely from June through August (Table 7)" (fraley_shepard1989LifeHistory, p. 139)

In the Arrow Lakes tributaries (BC, adfluvial), Ladell, citing McPhail and Murray 1979 and Ladell 1999:

> "Bull trout juveniles feed and grow in the Arrow Lakes' tributaries for up to 3 years. There may be some migration by fry to the lake in the late spring, but typically juveniles move to the lake at 2 or 3 years of age" (ladell2003EcologyLife, p. 7)

In the upper Kootenay (BC), fish of intermediate size were scarce in the Line Creek natal streams. Pollard reads that as
fish leaving to rear in the upper Elk River:

> "A similar absence of intermediate sized fish was observed for Line and S. Line populations" (pollard2001LifeHistory, p. 10)

> "to rear after 130 mm or after 3 years of age not to return until 5-6 years of age (or >350 mm)." (pollard2001LifeHistory, p. 10)

In the Pine River (Peace system, BC), Pollard suggests the tributaries hold a wider range of ages:

> "these findings suggest that the tributaries sampled in the Pine system may provide rearing habitat for a wider range of age classes than those sampled in the U. Kootenay system." (pollard2001LifeHistory, p. 10)

At Packsaddle Creek, a Kinbasket Reservoir tributary (BC), detections suggest juveniles leave at about age 2+, with the
spring freshet and the fall rains:

> "Detections suggest that the timing of outmigration of juvenile Bull Trout from Packsaddle Creek coincides with the peak flows of spring freshet (May-June) and fall rains (Sept-Oct; Section 4.1.1) towards the end of the growth season." (kang_warnock2020KinbasketReservoir, p. i)

> "suggests that outmigration from Packsaddle Creek occurs at age 2+ years" (kang_warnock2020KinbasketReservoir, p. i)

McPhail and Baxter's review gives the same ages for both migratory forms (data row 109 states that juveniles of fluvial
populations rear in small streams for at least two years):

> "Most juveniles emigrate from the spawning areas in their third summer, although some migrate as fry, and some in their fourth summer (Oliver 1979; Pratt 1992; Sexauer 1994)." (mcphail_baxter1996reviewbull, p. 16)

> "The majority of migrants to lakes are 2+ (Chisholm et al. 1989)." (mcphail_baxter1996reviewbull, p. 16)

Size at leaving is less often stated. The review gives growth in the stream and the smallest fish usually found in
lakes and rivers:

> "Initially, growth in bull trout is rapid and, by the end of their first summer, most populations reach a mean size of about 60-70 mm." (mcphail_baxter1996reviewbull, p. 15)

> "It is unusual to find individuals smaller than 200 mm in lakes, reservoirs or larger rivers" (mcphail_baxter1996reviewbull, p. 15)

Some juveniles move up into tributaries rather than down. In the Skagit system (southwestern BC), McPhail and Baxter,
citing McPhail and Keeley (in preparation):

> "In the Skagit system, bull trout spawn in the main river but juveniles (especially 2+ and 3+) move into tributary streams and remain there until they reach about 300 mm in length (McPhail and Keeley in prep.)." (mcphail_baxter1996reviewbull, p. 11)

**Residents.** Resident bull trout stay in headwater streams all their lives (above), where they keep to deep pools
and cover:

> "In these headwater streams, resident bull trout are associated with deep pools and in-stream cover. Also, most stream-resident populations are dwarfed." (mcphail_baxter1996reviewbull, p. 12)

Above the waterfalls in the Arrow Lakes tributaries (BC), Ladell found residents using the same kind of water as
migratory juveniles below, with logjams for cover instead of boulders:

> "However, bull trout utilized similar habitats irrespective of whether they were above or below barriers, and appeared to maintain positions in shallow, low velocity areas of the stream. Daytime cover associated with above-barrier fish was typically logjams or other instream woody debris, while below-barrier cover usually consisted of large boulder substrates." (ladell2003EcologyLife, p. ii)

> "The smallest sexually mature adult sampled from above the barrier was 155 mm, and the largest was 245 mm (Figure 3.4)." (ladell2003EcologyLife, p. 103)

**Density, cover and temperature.** Cope and Morris measured juvenile density in the Wigwam River (BC), at sites chosen
for good fry catches, and cite Goetz 1989 for a density that marks critical rearing areas:

> "Mean density of juvenile bull trout (ages 0+ to 2+) was estimated to be 17.2 fish/100m2 with a range of 0 to 26.9 fish/100m2" (cope_morris2001WigwamRiver, p. 11)

> "Site selection was biased towards electrofishing sample sites which favored high bull trout fry capture success" (cope_morris2001WigwamRiver, p. 28)

> "Areas with juvenile bull trout densities greater than 1.5 fish/100m2 have been cited as critical rearing areas (Goetz 1989)" (cope_morris2001WigwamRiver, p. 28)

In the Flathead drainage (Montana), Fraley and Shepard give snorkel counts, and report Shepard et al. 1984a relating
juvenile density to unembedded rock in tributaries of the Swan River:

> "Snorkeling estimates of juvenile bull trout densities in Flathead drainage tributaries averaged 1.5 fish/100 m2 of stream surface area (range: 0.1-7.1)." (fraley_shepard1989LifeHistory, p. 138)

> "found a significant relationship (r2 = 0.40, P < .01) between substrate score (a measure of unimbedded instream rock cover) and juvenile bull trout" (fraley_shepard1989LifeHistory, p. 141)

In Washington, summer maximum temperature was, of the habitat variables modelled, the most likely to explain where
juveniles occurred:

> "Model selection analysis using logistic regression indicated that summer maximum temperature was the most likely factor to explain patterns of occurrence for juvenile bull trout (Table 4)." (dunham_chandler2001Modelspredict, p. 15)

## How cold?

Bull trout are a cold-water species. McPhail and Baxter say it of adults; the BC plan says it of rearing:

> "One thing, however, is clear: the bull trout is a coldwater species." (mcphail_baxter1996reviewbull, p. 12)

> "Bull Trout are adapted to cold water and swift flowing rearing environments" (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 16)

The numbers are evidence rows, read in `thermal_requirements.md` (Temperature limits; Degree-days); this file does not
restate them.
- Spawning onset as water cools: data rows 149 and 546 (BC reviews), 153 and 508 (Flathead) and 492 (Metolius).
- Temperatures at spawning sites: rows 161 and 549 (Morice River, BC).
- Spawning stopping in cold water: row 535 (Line Creek, BC).
- Incubation: rows 150 and 510; degree-days to hatch, row 534.
- Other spawning temperatures, from US reviews and the Metolius: rows 493, 503, 504, 509, 540 and 542.
- Migration: row 158.
- Upper limits stored under rearing: rows 151, 152, 155–157, 159, 160, 537–539, 541, 543, 547, 548, 550–552 and 674.
  The evidence table stores a bull trout limit that names no life stage under rearing (`thermal_requirements.md`
  says so), and several of these are such limits: 538 is not stage-specific, 541, 547, 548 and 552 name no stage, and
  551 is drawn against spawning and migration sites. Row 674 is the onset of stress in the laboratory.
- Preferred temperatures for juveniles and adults together: rows 544 and 545.
- Elevation as a proxy for temperature, with no value: row 484.
- Laboratory growth optimum and upper lethal temperature: rows 154 and 536 (Selong et al.).
- Thermal units from egg deposition to the onset of winter: row 1117 (Mochnacz, an inference from laboratory studies).

## How are the forms split across BC, and which units are listed?

**A fourth, sea-run form only on the south coast.** Interior bull trout take the three forms; the coastal lineage adds
limited movement into salt water.

Hagen and Decker, citing McPhail 2007 for the sea-run form:

> "In interior regions of western North America, the three general life history forms of bull trout are stream resident, fluvial, and adfluvial. For bull trout of the coastal evolutionary lineage, limited movements into saltwater also occur (anadromy), although few details of these movements are known" (hagen_decker2011StatusBull, p. 3)

The federal registry places the sea-run form, within Canada, on BC's south coast, and COSEWIC ties it to the southern
genetic lineage:

> "The first three forms are common throughout the Canadian range, but the anadromous form is restricted to the south coast of British Columbia." (speciesregistrycanada2020BullTrout, p. 6)

> "Genetic Lineage 1 contains the only anadromous (sea-going) Bull Trout" (post_etal2012COSEWICassessment, p. 17)

**Some populations have done well in reservoirs; impoundment may have cost fluvial ones.** Hagen and Decker, citing
Hagen 2008:

> "Some bull trout populations in BC have adapted well to living in large reservoirs, and in some cases where kokanee have been introduced as a prey fish base growth and survival may be greater than in pre-existing riverine conditions" (hagen_decker2011StatusBull, p. 7)

> "in a number of cases in BC, river impoundment has resulted in the replacement of hundreds of kilometers of diverse tributary stream habitat within a large river basin with a single, monomorphic reservoir environment, and this is likely to have resulted in breakdown of population structure and perhaps the loss of populations and genetic diversity (e.g. loss of fluvial form) as well" (hagen_decker2011StatusBull, p. 7)

**Where bull trout are absent.** The BC plan, citing McPhail 2007 and Hagen and Decker 2011:

> "Bull Trout are notably absent from most small coastal watersheds and from three adjacent, warm water drainages in the southern interior: the Kettle, Okanagan, and Similkameen" (b_c_ministryofwaterlandandresourcestewardship2023ManagementPlan, p. 14)

**Five designatable units.** COSEWIC split Canada's bull trout into five units by genetic lineage and biogeographic
zone:

> "this report recognizes five DUs for Bull Trout in Canada" (post_etal2012COSEWICassessment, p. 18)

Four of the five lie wholly or partly in BC.

The South Coast unit (DU1, Genetic Lineage 1):

> "range includes the Skagit River, Squamish River, Ryan River, Ure Creek, Lillooet River, Pitt Lake/River, Lower Fraser River (below Hell's Gate Canyon), Chilliwack Lake, Phelix Creek, Birkenhead Lake, and Chehalis Lake" (post_etal2012COSEWICassessment, p. 23)

The Western Arctic unit (DU2, Genetic Lineage 2) is the Mackenzie drainage, which in BC is the Peace and the Liard:

> "range includes Mackenzie River drainages including the Liard, Peace and Athabasca River basins." (post_etal2012COSEWICassessment, p. 23)

The Upper Yukon Watershed unit (DU3, Genetic Lineage 2):

> "range includes the upper Yukon River basin." (post_etal2012COSEWICassessment, p. 23)

> "This large freshwater fish is found in the upper Yukon River drainage in northern British Columbia and southern Yukon" (cosewic2025COSEWICassessment, p. 7)

The Pacific unit (DU5, Genetic Lineage 2) is the rest of BC's Pacific drainages:

> "range includes the Upper Columbia, Fraser above Hell's Gate Canyon, Homathko, Klinaklini, Skeena, Nass, Iskut-Stikine and Taku rivers." (post_etal2012COSEWICassessment, p. 24)

**Their status.** COSEWIC assessed the South Coast and Western Arctic units as Special Concern in 2012, the Upper Yukon
unit as Data Deficient, and the Pacific unit as Not at Risk:

> "South Coast British Columbia populations - SPECIAL CONCERN" (post_etal2012COSEWICassessment, p. 1)

> "Western Arctic populations - SPECIAL CONCERN" (post_etal2012COSEWICassessment, p. 1)

> "Upper Yukon Watershed populations - DATA DEFICIENT" (post_etal2012COSEWICassessment, p. 1)

> "Pacific populations - NOT AT RISK" (post_etal2012COSEWICassessment, p. 1)

The 2025 reassessment kept the two units at Special Concern and the Upper Yukon unit Data Deficient:

> "South Coast British Columbia population - Special Concern" (cosewic2025COSEWICassessment, p. 1)

> "Western Arctic population - Special Concern" (cosewic2025COSEWICassessment, p. 1)

> "Upper Yukon Watershed population - Data Deficient" (cosewic2025COSEWICassessment, p. 1)

It described the South Coast unit as five river systems that hold the sea-run form, and the Western Arctic unit as
spread across four jurisdictions:

> "This large freshwater fish is found in five river systems in southwestern British Columbia. It exhibits considerable diversity in life history traits, including a unique anadromous form that migrates to the sea." (cosewic2025COSEWICassessment, p. 5)

> "This large freshwater fish is distributed throughout northeastern British Columbia, southern Yukon, southwestern Northwest Territories, and parts of Alberta." (cosewic2025COSEWICassessment, p. 6)

It moved the Pacific unit up from Not at Risk:

> "Designated Not at Risk in November 2012. Status re-examined and designated Special Concern in May 2025." (cosewic2025COSEWICassessment, p. 8)

Under the Species at Risk Act, the South Coast and Western Arctic units are on Schedule 1 as Special Concern. Both
registry pages give the same status:

> "Status on Schedule 1 Special Concern" (speciesatriskpublicregistry2026BullTrout, p. 2)

> "Status on Schedule 1 Special Concern" (speciesregistrycanada2020BullTrout, p. 2)

## What the documents read here do not settle

- **The spawning cue in BC.** No BC source read measures spawning onset beside day length. The photoperiod idea comes
  from the reviews and the Flathead study, and Hagen and Weber doubt that a temperature threshold predicts the date.
- **Skip spawning by form.** No source read gives alternate-year rates for residents, or compares fluvial and
  adfluvial rates in one system. The BC rates come from small tagged samples that count different things.
- **Resident spawning dates.** No source read dates resident spawning apart from the migrants'.
- **The sea-run form.** Only reviews and the federal documents mention it; no study of it was read.
- **Redd sites beyond two basins.** The groundwater measurements are from the Chowade River (BC) and the Swan basin
  (Montana). The Williston and Kootenay redd-count series were not read for site-scale habitat. No source in the
  collection measures dissolved oxygen in redds.
- **Size at leaving the natal stream.** Only the upper Kootenay length gaps and the Skagit statement stand for BC.
  Fraley and Shepard give mean lengths at annulus for North Fork Flathead tributaries (Montana) on p. 139; the PDF's
  text layer misreads one of them, so they are not quoted here.
- **Winter juvenile habitat.** The sources read describe summer daytime habitat.
- **Forms by place.** No source read gives the share of BC populations by form. Hagen and Decker 2011's Appendix 4
  names the forms core area by core area, in a table, which this file does not quote.
- **What the store cannot see.** Ten scans hold no text for any store build (#217), so a search never returns them.
  The restricted EcoCat reports and the Metolius 1996 report are not in the collection (#209).
- **Read and not quoted:**
  - baxter1997GeomorphologyLandUse, the thesis behind Baxter and Hauer 2000, whose paper is quoted;
  - baxterBullTrout, the Chowade egg-to-fry report. The thesis is quoted, and the two differ on how long the alevins
    had left before absorbing the yolk;
  - baxterChowadeRiver;
  - prince2009SubadultBull, subadults after the natal stream;
  - the 2016–2018 Kinbasket interim reports, superseded by kang_warnock2020KinbasketReservoir;
  - mochnacz2021Thermalecology, beyond row 1117.

## How the quotes are checked

`scripts/0280-literature-verify.R` lists this file in `QUOTED` and checks each quote as it checks the evidence table's:
the citation key resolves to one item in the group library, and the passage's words occur in that item's PDF text, or
in an OCR of the page images where the citation says `OCR`. The file is read as GitHub renders it (cmark-gfm), and
a quotation mark outside that form, a link, code or emphasis inside a quote, or any quote that is not found fails the
run. The log gives every PDF page a quote matched on, for checking the printed page. The gate
proves the words are in the source; the meaning of each sentence around them was audited by hand
(`planning/archive/2026-11-issue-198-*`).
