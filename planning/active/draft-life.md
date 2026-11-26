# Arctic grayling life history: what the documents say

**Verified:** 2026-11-26 · **Issues:** #140 (this); the store is #122's `bull_trout_grayling` · **Produced by:** the
grayling documents of the group library listed in the #140 drafter brief, read in their PDF text, with each passage
checked by `scripts/0280-literature-verify.R` · **Status:** draft for #140's Phase 4; gaps at the end.

Each claim below is a plain sentence followed by the passage that carries it, quoted verbatim with its citation key
and page. Pages are the printed ones, with these exceptions, where the page is the PDF's:
- the summary of Stuart and Chislett 1979 (the Sukunka report), which carries no page number;
- the abstract of Tack 1980 (Alaska), which carries no page number.

Where a source reports another study, the sentence names it. Every claim says where it was measured: a BC drainage
(the Williston Reservoir watershed of the upper Peace, the Sukunka in the Peace below the dam, or the Liard), or the
Northwest Territories or Alaska. Numbers already held in `data/literature_evidence.csv` are not restated
where they can be cited by data row (row N is file line N + 1).

## In brief

- **Mostly river fish in the upper Peace.** Grayling can be stream-resident, fluvial, adfluvial or lake-dwelling.
  In the Williston Reservoir watershed they complete their lives in rivers, often below headwater lakes; only the
  Toodoggone (upper Finlay) is known to hold a lake-inlet spawning population, and grayling do not live in the
  reservoir.
- **Three habitats a year.** Adults move between overwintering water, spring spawning sites and summer feeding
  reaches. In the Parsnip they winter in the Parsnip mainstem, move up the tributaries around ice-out in April and
  May to spawn, feed through the summer, and gather in the mainstem again from October.
- **Spring spawners.** Spawning follows ice break-up, mostly mid-May to mid-June across the range; in the Sukunka it
  ran from mid-May to early June and in the Parsnip from late May to late June. Fish arrive as the water reaches
  about 4 °C. No redd is built: eggs fall on small, loose gravel in shallow riffles and runs. Spawning sites in the
  Williston watershed are mostly not known.
- **Eggs hatch in weeks.** Incubation takes from about a week in warm water to about a month in cold, and fry leave
  the gravel a few days after hatching.
- **Fry need slow, shallow margins.** Newly emerged fry are weak swimmers and hold in quiet margins, backwaters and
  side channels near the spawning site, moving to faster, deeper water as they grow. Floods in the weeks after
  hatching can wipe out a year class.
- **Juveniles downstream, adults upstream.** In the Williston watershed fry and juveniles generally stay downstream,
  in warmer, low-gradient river margins, small tributaries and side channels, and older juveniles in the larger
  mainstems; adults move upstream in summer to clear, cool water and pools. Juveniles are found mostly in
  fourth-order and larger tributaries.
- **Winter in big water.** Grayling overwinter in larger rivers, lakes, deep pools or spring-fed water. The flooding
  of the Peace, Finlay and Parsnip mainstems under Williston Reservoir took much of this habitat and is the likeliest
  reason grayling were lost from the reservoir's direct tributaries (the Williston and Upper Peace core areas).

What this file is not: a source for habitat thresholds. Gradient, channel width and discharge values are evidence
rows in `data/literature_evidence.csv`; the depth and velocity rows already held are data rows 903–911 and 912–925.

## What are the forms, and do they mix?

**Four forms across the range.** Stewart et al.'s review of Northwest Territories grayling names four:

> "Stream-resident, fluvial, adfluvial, and lacustrine life histories have been observed among Arctic grayling populations" (stewart_etal2007Fishlife, p. 3)

> "Their populations can be resident or migratory, and the latter can follow fluvial or adfluvial life histories." (stewart_etal2007Fishlife, p. v)

The review's habitat table gives small tributaries as spawning and rearing habitat for the migratory forms, and the
review says some grayling spend part or all of their lives near their overwintering water:

> "Small (~10 m wide), medium gradient tributary streams" (stewart_etal2007Fishlife, p. 3)

> "Spawning and rearing habitat." (stewart_etal2007Fishlife, p. 3)

> "Some grayling may spend part or all of their lives near their overwintering areas." (stewart_etal2007Fishlife, p. 22)

**River fish in the Williston watershed.** In the upper Peace, Hagen et al.'s 2026 synthesis says grayling complete
their lives in rivers, often below headwater lakes, that one lake-inlet spawning population is known, and that they
do not live in the reservoir:

> "Arctic Grayling in the Williston Reservoir watershed complete their life cycle in fluvial habitats and often downstream from headwater lakes" (hagen_etal2026futureArctic, p. 6)

> "The Toodoggone watershed in the Upper Finlay core area contains the only known lake inlet spawning metapopulation. Arctic Grayling do not reside in the reservoir" (hagen_etal2026futureArctic, p. 6)

Stamford et al. 2017 add that grayling are missing from most small lakes of the Williston watershed, unlike the lower
Peace:

> "extensive inventories found Arctic Grayling conspicuously absent in most small lakes within the Williston watershed" (stamford_etal2017FWCPArctic, p. 4)

> "but lake populations exist in the lower Peace watershed and are relatively common throughout the species range in North America" (stamford_etal2017FWCPArctic, p. 4)

They report three putative ecotypes for BC proposed by Stamford et al. 2015, two of them known in the Williston
watershed, and judge the clear-stream one uncertain:

> "for British Columbia as an additional component of grayling diversity in the province: ‘Large Turbid Rivers,’ ‘Clear Streams,’ and ‘Lakes,’ of which the first two are known to be present in the Williston watershed, and the third is suspected to be present only in the Upper Finlay/Toodoggone core area." (stamford_etal2017FWCPArctic, p. 5)

> "The ‘Clear Stream’ ecotype is therefore currently somewhat uncertain." (stamford_etal2017FWCPArctic, p. 5)

**Residents and migrants in one basin.** Hagen et al. 2026 suggest that the surviving populations move locally within
their home streams, and that the populations flooded by the reservoir were presumably adapted to large rivers:

> "Remnant Arctic Grayling populations in unflooded core areas (Parsnip, Nation, Omineca, Ingenika, Lower Finlay, Upper Finlay; Figure 1) appear to also move locally within their home streams and potentially also express locally adapted traits." (hagen_etal2026futureArctic, p. 5)

> "were demographically independent from surviving metapopulations and presumably adapted to the (now flooded) large river habitats" (hagen_etal2026futureArctic, p. 6)

In the Omineca core area (O'Connor et al. 2026, reported by Hagen et al.), fin ray chemistry suggests the adults of
the Mesilinka and the Osilinka each spend their whole lives in their own river:

> "Fin ray microchemistry analyses in Omineca core area found distinct element concentrations between adults rearing in Mesilinka River and Osilinka River that suggest adults in both streams complete their entire life history within their respective home streams" (hagen_etal2026futureArctic, p. 16)

**How far they travel.** Across the range, the migrations run from one small watershed to hundreds of kilometres:

> "These movements may be at the scale of a single, relatively restricted watershed or lake system (Stewart et al. 2007), or involve long, complex migrations among critical habitats" (hagen_etal2026futureArctic, p. 5)

> "span hundreds of kilometers between overwintering, spawning and summer feeding areas located in different systems" (hagen_etal2026futureArctic, p. 5)

In the Northwest Territories, one fish tagged on the Donnelly River moved 320 km:

> "A grayling tagged at Chick Lake on the Donnelly River moved 320 km to the Great Bear River between 9 July and 4 October 1972" (stewart_etal2007Fishlife, p. 22)

**Do fish from different spawning streams mix?** Stamford et al. 2017 say fluvial adults return to the same feeding
sites each year, while fish from different spawning streams can share summer or winter habitat:

> "Mark-recapture and radio telemetry studies suggest that individual fluvial adults home yearly to the same summer feeding sites, but grayling from different spawning streams may exhibit overlap in summer rearing and/or overwinter habitat" (stamford_etal2017FWCPArctic, p. 10)

In the Parsnip (BC), most tagged fish kept to one tributary, and about a quarter appeared to stray between years:

> "While most individuals display high tributary fidelity, one-quarter of the total population appeared to display what could be likened to a straying phenotype in Pacific salmon" (martins_etal2022SpatialEcology, p. 32)

## When do they migrate?

**The annual cycle.** Across the range, after Northcote (1993):

> "Northcote (1993) presented a conceptual model of Arctic Grayling life history, which is based on a cycle of potentially complex migratory behaviour involving alternation between three major habitat categories: 1) summer feeding habitat, 2) overwinter refuge, and 3) suitable spawning habitat." (hagen_etal2026futureArctic, p. 5)

**The Parsnip, by acoustic telemetry.** Martins et al. tagged grayling in the Parsnip River watershed from 2018 to
2021. They found the three phases, with spawning in the middle reaches of four tributaries:

> "Arctic Grayling in the Parsnip River watershed showed three distinct life phases: 1) an overwintering period spent in the Parsnip River mainstem; 2) a spring spawning migration into the middle reaches of the Anzac, Table, Hominka, and Missinka Rivers; and 3) a summer feeding migration in which they may disperse wide across the watershed in search of suitable feeding habitats." (martins_etal2022SpatialEcology, p. 3)

> "Springtime movements are sudden and wide-ranging, with individuals beginning to push into the middle tributaries around ice-out and freshet in April and May." (martins_etal2022SpatialEcology, p. 32)

> "Summer distribution patterns persist until October, at which time Arctic Grayling begin congregating in the Parsnip River mainstem once more, reaching an approximately winter distribution by November." (martins_etal2022SpatialEcology, p. 32)

The earlier radio telemetry in the same watershed (Blackman 2002b, reported by Stamford et al. 2017) gives the same
calendar, with distances, summer homing and a fall return perhaps cued by cooling water:

> "migrations to spawning areas were initiated during the late-April/early-May period, and covered distances ranging from 9 to 71 km." (stamford_etal2017FWCPArctic, p. 11)

> "Migration of radio-tagged grayling to summer feeding areas occurred primarily in July and individuals exhibited high site fidelity, returning to rear in the same locations where they were tagged." (stamford_etal2017FWCPArctic, p. 11)

> "The radio telemetry data indicated that downstream movements to overwintering locations occurred in September and October, and may have been triggered by a drop in water temperature" (stamford_etal2017FWCPArctic, p. 11)

**The cue in spring.** Stamford et al. 2017 say spawners arrive as the water reaches about 4 °C, citing Armstrong
1986, Northcote 1993 and Butcher et al. 1981, and that Parsnip grayling did the same (Blackman 2002a):

> "Mature adult Arctic Grayling migrate in spring to spawning locations and arrive there when water temperature reaches about 4oC" (stamford_etal2017FWCPArctic, p. 10)

> "This temperature-associated migration timing has also been observed in Parsnip River grayling" (stamford_etal2017FWCPArctic, p. 10)

In interior and Arctic Alaska, Tack ties the start of the run to the first warming to 1 °C:

> "The prespawning migration is probably stimulated by the first rise of water temperature to 1°C in the spring." (tack1980Migrationsdistributions, p. 3)

In the Mackenzie valley (Northwest Territories), spawners move into small tributaries during or just after the ice
breaks up:

> "Fish that spawn in the Mackenzie River valley generally migrate from lakes and larger rivers into small, clear, fast-flowing" (stewart_etal2007Fishlife, p. 11)

> "tributaries during (Jessop et al. 1974), or just after (Stein et al. 1973b), the breakup of river ice." (stewart_etal2007Fishlife, p. 12)

**Summer.** Hagen et al. 2026, citing Tack 1980, Armstrong 1986, Ridder 1994 and Blackman 2002a, have subadults
joining the adults' migrations from their second or third year, usually upstream to summer feeding water:

> "Beginning in their second or third year of life, many subadult grayling join adults in making migrations from overwintering locations (usually in an upstream direction) to summer feeding habitat" (hagen_etal2026futureArctic, p. 6)

**Fall.** In the Northwest Territories review, whole populations leave small lakes and streams for larger rivers or
lakes, at times that vary with local conditions:

> "In fall, entire populations of grayling migrate out of small headwater lakes and small streams to overwinter in larger rivers or lakes" (stewart_etal2007Fishlife, p. 21)

> "The timing of these migrations varies from early summer through December depending upon the local conditions" (stewart_etal2007Fishlife, p. 22)

In the Sukunka (Peace system, BC), Stuart and Chislett saw no large seasonal movements of juveniles between the
tributaries and the river:

> "There were no large seasonal movements of juveniles between the tributaries and the Sukunka River" (stuart_chislett1979AspectsLife, p. 3, OCR)

## When and where do they spawn?

**Timing.** Across the Mackenzie valley and elsewhere, spawning usually falls between mid-May and mid-June, at 4 to
16 °C:

> "Spawning can begin in April and extend into early July but usually occurs from mid-May to mid-June" (stewart_etal2007Fishlife, p. 12)

> "typically commences in mid-May in the southern Mackenzie Valley to mid-June in the north, at water temperatures of 4 to 16°C" (stewart_etal2007Fishlife, p. 12)

> "A rise in water temperature to 4°C and spring flooding may be factors that stimulate grayling to spawn" (stewart_etal2007Fishlife, p. 12)

In the Sukunka (Peace system, BC), spawning dates were estimated from fry development:

> "From the fry development data, grayling spawned in the Sukunka drainage between May 15 and June 7 in both 1977 and" (stuart_chislett1979AspectsLife, p. 31)

In the Parsnip, Blackman (2002a, reported by Stamford et al. 2017) inferred the spawning period from telemetry and
from fry emergence, without seeing spawning:

> "Spawning was estimated to have occurred over the late-May to late-June period." (stamford_etal2017FWCPArctic, p. 11)

> "While spawning was not observed directly by Blackman (2002a), the spawning period was inferred from the telemetry data and also from back-calculation based on estimated fry emergence dates" (stamford_etal2017FWCPArctic, p. 11)

In the Cannings and Ptolemy account of the Williston grayling, after Northcote (1995):

> "Grayling are spring spawners often moving onto spawning areas shortly after ice-out at temperatures near 4°C (Northcote, 1995)." (cannings_ptolemy1998RareFreshwater, p. 49)

In Alaska (Ott and Morris 2005 and 2006 and W. Morris, reported by Stewart et al.), spawning is abandoned or fails
when the water stays too cold:

> "Spawning is abandoned or fails during years when the temperatures stay too low after fish have arrived on the spawning grounds." (stewart_etal2007Fishlife, p. 14)

**Where in the Williston watershed.** Hagen et al. 2026 say the spawning sites are mostly unknown, and assumed to lie
near the fry and juvenile habitats:

> "Although specific spawning locations are generally unknown for Williston Arctic Grayling, elsewhere stream reaches that warm quickly in the spring are prime habitat for spawning and early rearing." (hagen_etal2026futureArctic, p. 6)

> "Spawning habitats have not been precisely delineated for Williston Arctic Grayling and are currently assumed to be near fry and juvenile critical habitats due to the dispersal ability of these life stages." (hagen_etal2026futureArctic, p. 26)

In the Parsnip they report spawning in the mainstem and in small tributaries:

> "The Parsnip core area presents a picture of complex migratory behaviour that includes spawning in the Parsnip River mainstem and small tributaries, with most adults exhibiting strong homing to the same summer rearing areas each year." (hagen_etal2026futureArctic, p. 16)

Blackman's telemetry (reported by Stamford et al. 2017) placed the Table and Anzac spawners in the lower reaches of
those rivers and in the Parsnip, favouring side channels with small gravel:

> "Telemetry data indicated that spawning sites were located mostly in the lower reaches of the Anzac and Table Rivers, and in the Parsnip mainstem, and that multiplechannel and side-channel locations with abundant small gravel were preferentially selected." (stamford_etal2017FWCPArctic, p. 11)

In the Sukunka (BC), large numbers of newly emerged fry in the mainstem pointed to spawning there more than in the
tributaries:

> "Large numbers of newly emerged fry in the Sukunka River suggested extensive use of the mainstem river and only limited spawning in the tributaries." (stuart_chislett1979AspectsLife, p. 2, OCR)

In the Ospika River (Finlay Reach), Stamford and O'Connor (2022, reported by Hagen et al. 2026) took two fry, which
Hagen et al. read as a sign of spawning:

> "capture of two fry in the Ospika River indicates spawning" (hagen_etal2026futureArctic, p. 17)

Unpublished otolith chemistry reported by Hagen et al. 2026 suggests that about a quarter of the fry caught in the
upper Finlay mainstem came from spawning areas outside the Finlay, and Hagen et al. point to small tributaries as
natal habitat:

> "suggest a significant proportion (roughly 27%) originated from spawning areas outside of Finlay River" (hagen_etal2026futureArctic, p. 17)

> "analyses of retrospective data (eDNA, microchemistry) suggest that small tributaries provide important natal habitats" (hagen_etal2026futureArctic, p. 18)

**Why spawning and summer streams can differ.** Hagen et al. 2026, citing Tack 1980, Butcher et al. 1981, Ridder
1994 and 1998 and Stewart et al. 2007:

> "However, such reaches may also be too small and possibly warm for rearing later in the summer or for older life stages, which may explain why critical habitats for spawning and summer rearing may be in different streams" (hagen_etal2026futureArctic, p. 6)

**The range of spawning sites.** Stamford et al. 2017:

> "Grayling spawn in a wide variety of habitats, including mainstem rivers, large and small tributaries to streams and lakes, and along lake shores at the mouths of inlets" (stamford_etal2017FWCPArctic, p. 10)

Tack (Alaska) holds that grayling spawn where their system warms first:

> "The hypothesis is advanced that these locations are used for spawning because they are the first areas in their systems to warm in the spring." (tack1980Migrationsdistributions, p. 3)

**Substrate, depth and current.** Fluvial grayling spawn mostly over small, loose gravel in shallow riffles and runs,
and build no redd. Stamford et al. 2017, citing Stuart and Chislett 1979, Tack 1980, Armstrong 1986 and Stewart et
al. 2007:

> "Fluvial Arctic Grayling have generally been observed spawning over small pea-sized unembedded gravels in shallow riffles and runs, but also use large cobbles and boulders to incubate their adhesive eggs" (stamford_etal2017FWCPArctic, p. 10)

The Northwest Territories review gives the gravel size; its depth and current limits are data rows 903–907:

> "but most spawning occurs over relatively small, unembedded gravels about 2.5 cm in diameter" (stewart_etal2007Fishlife, p. 14)

> "They do not build a redd" (stewart_etal2007Fishlife, p. 14)

In Adsett Creek (Liard, BC), Cannings and Ptolemy, summarising Northcote (1995), report spawning over coarse gravel at
the tails of long runs (Stewart et al. 2007 give the Adsett Creek study as Stewart et al. 1982):

> "In Adsett Creek (Liard) grayling spawned over coarse gravel (2-4 cm) at depths of 10-40 cm and flows of 0.5 to 1.0" (cannings_ptolemy1998RareFreshwater, p. 48)

> "usually at the tails of long runs." (cannings_ptolemy1998RareFreshwater, p. 48)

> "Structural elements such as stable large woody debris, boulders and bedrock are important measures of spawning capability." (cannings_ptolemy1998RareFreshwater, p. 48)

In the Sukunka study, four adults (a male and three females) were held in an artificial overflow channel. Spawning
was not seen, but gravel was disturbed in quiet water and fry later emerged there (next section):

> "The overflow channel was 18 m long, 0.5 per cent gradient with alternating areas of riffled and quiet waters." (stuart_chislett1979AspectsLife, p. 29)

> "On June 3, disturbed gravel was observed in two areas of quiet water in the overflow channel." (stuart_chislett1979AspectsLife, p. 30)

**Natal fidelity.** Stamford et al. 2017 report precise homing for many stream populations, with some adults
switching sites after a poor spring:

> "Relatively precise homing of adults on spawning migrations, and corresponding demographic independence, has been suggested for numerous stream populations" (stamford_etal2017FWCPArctic, p. 10)

> "although adults have also been observed moving to different spawning sites sometimes in response to poor spring conditions" (stamford_etal2017FWCPArctic, p. 10)

> "They show strong reproductive, trophic and refuge homing with offspring utilizing the same habitat areas as their parents." (cannings_ptolemy1998RareFreshwater, p. 48)

In the Northwest Territories, the evidence is limited tagging:

> "Limited tagging data suggest that individual grayling show fidelity to both spawning and overwintering areas" (stewart_etal2007Fishlife, p. 22)

**After spawning.** In the Northwest Territories review, spawning lasts two to three weeks, after which adults return
to larger rivers or lakes:

> "Spawning takes place over a 2 to 3 week period, after which the adults return to larger rivers or lakes" (stewart_etal2007Fishlife, p. 15)

**Age at spawning.** In the Sukunka, most spawners were four and five; McPhail (2007, reported by Stamford et al.
2017) says most BC grayling mature after their fifth summer:

> "Most of the mature grayling were four and five years old and spawning occurred between May 15 and June 7." (stuart_chislett1979AspectsLife, p. 2)

> "McPhail (2007) suggests, however, that most British Columbia grayling of both sexes mature after their fifth summer." (stamford_etal2017FWCPArctic, p. 11)

## How long do the eggs stay in the gravel?

Incubation is short and depends on temperature. The Northwest Territories review:

> "The time required for incubation of the eggs varies with mean water temperature, ranging from 8 days at 15.5°C and 16 to 18 days at 9°C, to 25 to 29 days at 7.1°C and 32 days at 5.8°C" (stewart_etal2007Fishlife, p. 15)

> "Young grayling emerge from the gravel 3 to 4 days after they hatch (Kratt and Smith 1977)." (stewart_etal2007Fishlife, p. 16)

The eggs lie only a few centimetres into the gravel:

> "They may be covered by up to 5 cm of substrate" (stewart_etal2007Fishlife, p. 15)

In the Sukunka overflow channel (BC), fry emerged on 27 June from the gravel disturbed on 3 June:

> "On June 27, fry emerged from the gravel in the two areas noted as possible grayling spawning sites" (stuart_chislett1979AspectsLife, p. 30)

> "An incubation period of 267.74 day degrees was obtained under semi-natural conditions." (stuart_chislett1979AspectsLife, p. 2)

## Where do fry live, and do they drift?

**Fry need quiet margins near the spawning site.** Stamford et al. 2017:

> "Newly-emerged grayling fry are weak swimmers, and a key habitat requirement is the availability of low velocity areas along channel margins (and including side channels, back channels, and alcoves) located in relatively close proximity to the spawning area" (stamford_etal2017FWCPArctic, p. 8)

In the Parsnip watershed (Mathias et al. 1998 and Blackman 2004, reported by Stamford et al. 2017), with the upstream
end of fry habitat where the bed turns from gravel to cobble:

> "Within the Parsnip River watershed, preferred habitats of newly-emerged grayling are shallow areas (approximately 0.l m) of little or no flow (approximately 0.1 m/s) along the channel margin" (stamford_etal2017FWCPArctic, p. 8)

> "In fry rearing streams of the Parsnip River watershed, the upstream distribution of these habitats corresponds to the shift from gravel to cobble as the dominant stream-bed material, indicating a change in stream energy" (stamford_etal2017FWCPArctic, p. 8)

> "The use of shallow, low-velocity habitat in alcoves, side channels, and back channels has been noted for fry rearing reaches in the Ingenika, Osilinka, Omineca, and Parsnip systems" (stamford_etal2017FWCPArctic, p. 12)

**As they grow, faster and deeper water.** Stamford et al. 2017, citing Stuart and Chislett 1979 and Armstrong 1986:

> "As they grow, however, Arctic Grayling fry undergo behavioural and habitat shifts away from schooling in quiet areas, and move out into deeper faster water along mainstem margins and side channels where they remain for the rest of the summer" (stamford_etal2017FWCPArctic, p. 8)

In the Sukunka (BC), fry used backchannels and the quiet edges of pools briefly after emergence, then side-channel
riffles:

> "Except for a short post-emergence period in the backchannels and quiet edges of pools, sidechannel riffles were the preferred habitat of the grayling fry in spring, summer and fall." (stuart_chislett1979AspectsLife, p. 2)

> "Greater numbers of fry per sample were obtained from riffles with a silt-free gravel substrate compared to a cobble-gravel complex." (stuart_chislett1979AspectsLife, p. 36)

The Northwest Territories review describes later fry habitat; its velocity values are data rows 908–910, and the
Sukunka fry's 0.80 m/s is row 911:

> "Later in the season, once they become more mobile, young-of-the-year in streams inhabit shallow pools and side channels with water velocities less than 80 cm/s and depths of 5 to 50 cm, over silt to boulder substrates" (stewart_etal2007Fishlife, p. 17)

**Where the fry rear in the Williston watershed.** Stamford et al. 2017, after Hawkshaw et al. 2013, place first-summer
rearing in low-gradient middle reaches of the larger tributaries:

> "rear during their first summer in locations with similar habitat characteristics (i.e. low gradient, stable summer temperatures, located in middle reaches of larger tributaries" (stamford_etal2017FWCPArctic, p. 8)

> "Fluvial grayling populations in Williston watershed appear to be centered around fry rearing areas located in the low gradient middle reaches of larger (e.g. 4th order and larger) tributaries where stable ambient summer temperatures hover close to16oC" (stamford_etal2017FWCPArctic, p. 16)

In the upper Finlay, beach seining found many fry in the Finlay mainstem but few yearlings (Chu Cho Environmental
2018, reported by Hagen et al. 2026):

> "Beach seine sampling in the Upper Finlay core area found abundant fry rearing in the Finlay River mainstem but found surprisingly few yearling-sized juveniles" (hagen_etal2026futureArctic, p. 17)

In mountain streams of the Little Nahanni (Northwest Territories), McPherson found young-of-the-year only low in the
basin:

> "YOY Arctic Grayling were found exclusively in low elevation, low gradient habitat dominated by silty-sand substrate with average water temperatures >10oC." (mcpherson2020Habitatuse, p. ii)

**Drift and downstream movement.** Floods in the first two weeks can kill many fry, and fry are most easily displaced
soon after swim-up (Northwest Territories review, citing de Bruyn and McCart 1974 and Armstrong 1986 for the first,
and Kratt 1977, Deleray 1991 and Deleray and Kaya 1992 for the second):

> "Because fry are helpless in water currents for two weeks after hatching, flooding or drought during this period may cause high mortalities, either by washing them downstream into unfavourable habitat or by stranding them in shallow, isolated pools" (stewart_etal2007Fishlife, p. 17)

> "Grayling fry are most susceptible to downstream displacement shortly after swimup, particularly at night" (stewart_etal2007Fishlife, p. 17)

Hagen et al. 2026, after Northcote (1993), describe fry moving down to larger streams by fall:

> "By fall they drift or move downstream into larger streams to overwinter (Northcote 1993)." (hagen_etal2026futureArctic, p. 6)

The Sukunka fry did not:

> "there was no downstream movement of fry from the tributaries in" (stuart_chislett1979AspectsLife, p. 3)

> "fall and the study indicates fry may overwinter in the cobbles of frozen sidechannels." (stuart_chislett1979AspectsLife, p. 3)

## Where do juveniles and adults spend the summer?

**Juveniles in the larger rivers.** Hagen et al. 2026, citing Tack 1980, Butcher et al. 1981, Northcote 1993 and
Stewart et al. 2007, describe juveniles of 100 to 200 mm using the larger streams through the year:

> "These larger streams are often utilized by juvenile grayling 100-200 mm (age-1+ to age-2+) throughout the year, and the summer rearing habitats and overwintering locations may be in relative proximity to each other" (hagen_etal2026futureArctic, p. 6)

In the Parsnip (Blackman and Hunter 2001, reported by Stamford et al. 2017), juveniles were found almost only in the
mainstem, in quiet water:

> "In the Parsnip River watershed, very few juvenile grayling have been observed in areas other than the Parsnip mainstem, where they utilize low velocity areas of approximately 0.4-1.0 m depth" (stamford_etal2017FWCPArctic, p. 9)

> "Juvenile rearing locations within the Williston watershed tend to be located downstream of spawning reaches in larger mainstem rivers" (stamford_etal2017FWCPArctic, p. 13)

In the Sukunka (BC), Stuart and Chislett (reported by Cannings and Ptolemy) found juveniles and adults in pools:

> "Stuart and Chislett (1979) found grayling using four mainstem habitat types during the summer and fall period on the Sukunka: back-channels were heavily used by recently emerged fry; side-channel riffles by older fry and pools by juveniles and adults." (cannings_ptolemy1998RareFreshwater, p. 48)

In Alaskan streams (Den Beste and McCart 1984, reported by Stewart et al.), juveniles selected narrow channels:

> "They appeared to select for channels that are 1 to 8 m wide and against channels wider than 14 m" (stewart_etal2007Fishlife, p. 19)

**Adults upstream in clear, cool water.** Hagen et al. 2026 describe the usual summer split across the core areas,
from habitat use recorded mostly in August; they add that adults and juveniles often overlap:

> "Critical habitats were defined primarily by data and observations collected during August" (hagen_etal2026futureArctic, p. 26)

> "Adult and juvenile life history stages often overlap in their summer rearing distributions but generally across all core areas, subadults and adults migrate upstream to find clear and cool (~12.5oC) water and well-defined pools and riparian cover. Fry and juveniles remain downstream where low gradient river margins, small tributaries, and off channel habitats provide warmer water (~16oC), rapid growth rates, and predator avoidance." (hagen_etal2026futureArctic, p. 26)

> "Clear stream reaches appear to be critical for summer rearing of subadult and adult Arctic Grayling, likely because they are highly dependent on sight for feeding" (hagen_etal2026futureArctic, p. 7)

In the Parsnip watershed, adults prefer pools and runs and avoid riffles (Zemlak and Langston 1998 and Blackman 2004,
reported by Stamford et al. 2017):

> "Habitat use studies have indicated that larger adult grayling in the Parsnip watershed are distributed further upstream, and that they have a strong preference for pool (>60% of observations) and run habitat and avoid riffles (<1% of observations" (stamford_etal2017FWCPArctic, p. 9)

> "Access to pool habitat, especially, within clear stream reaches of moderate gradient appears to be a key habitat requirement for adult and subadult Arctic Grayling within the Williston watershed" (stamford_etal2017FWCPArctic, p. 13)

In the Anzac River (Parsnip), snorkel and drone surveys in summer 2022 tied grayling to cool pools:

> "At both the reach-scale and the riverscape-scales, snorkel surveys showed associations between Arctic grayling occurrence and cool pool habitats." (bottoms_etal2023Criticalhabitats, p. 6)

Hagen and Stamford, from Parsnip snorkel counts, observe fewer adults in streams with long low-gradient meanders, and
report Blackman's (2004) Anzac adults in the deepest water:

> "Our observation is that streams of the Parsnip River watershed with extensive sections of low-gradient meanders have fewer adult grayling." (hagen_stamford2023ParsnipArctic, p. 51)

> "Anzac River adult Arctic grayling occupy the deepest water at or near the edge of the thalweg, usually where the river is narrow" (hagen_stamford2023ParsnipArctic, p. 51)

In Alaskan streams (Den Beste and McCart 1984, reported by Stewart et al.), adults used streams averaging 10 m wide:

> "The average stream width used by adults was 10 m, and channels less than 6 m wide were selected against." (stewart_etal2007Fishlife, p. 21)

In the Little Nahanni (Northwest Territories), adults were found high and cold:

> "Adults had a strong correlation to elevation and water temperature, using habitats with high elevation (>1200 m) and low temperature (7oC), and increased proportions of pool and boulder habitat." (mcpherson2020Habitatuse, p. iii)

Across the range, the larger fish hold the upstream positions (Northwest Territories review, citing Hughes 1998a and
Hughes and Reynolds 1994):

> "As cohorts age their distribution in the river gradually increases as they move upstream, with the fastest growing fish in the upper reaches and slower growing fish in the lower reaches." (stewart_etal2007Fishlife, p. 21)

> "Headwater positions appeared to be preferred by grayling, and the larger fishes were more successful competing for these positions" (stewart_etal2007Fishlife, p. 21)

**Stream size in the Williston watershed.** Juvenile occurrence rises with distance from the reservoir and with
stream order (Hawkshaw and Shrimpton 2014, reported by Hagen et al. 2026). Stamford et al. 2017 say grayling appear
more limited to cooler fifth-order streams:

> "The occurrence of juvenile Arctic Grayling among surviving core areas is positively related to the distance upstream from the reservoir and stream order, with occupied sites being characterized as locations in 4th order and larger tributaries with stable, cool water temperatures" (hagen_etal2026futureArctic, p. 7)

> "the Williston Reservoir watershed might present a somewhat unique picture, as grayling appear more limited to cooler fifth order streams" (stamford_etal2017FWCPArctic, p. 7)

> "In the Williston Reservoir watershed, a substantial amount of unflooded mainstem length appears to be necessary to complete the life cycle." (hagen_etal2026futureArctic, p. 7)

Hagen et al. note that summer sampling may miss small tributaries used early in the year:

> "Sampling in the summer may underestimate the importance of smaller tributaries which may have reduced habitat or be too warm in summer but provide conditions for rapid fry growth in spring and early summer." (hagen_etal2026futureArctic, p. 7)

**Low gradient, as the reviews state it.** Hagen et al. 2026, citing deBruyn and McCart 1974, Craig and Poulin 1975,
Stuart and Chislett 1979, Butcher et al. 1981, Northcote 1993 and Stewart et al. 2007:

> "Generally, across the range of Arctic Grayling, all life history stages (young-of-year fry, age-1+ and age-2+ juveniles, subadults and adults) require clear, relatively low gradient stream reaches for rearing" (hagen_etal2026futureArctic, p. 7)

## Where do they spend the winter?

**In the Parsnip, the mainstem.** Blackman's tagged fish (reported by Stamford et al. 2017) wintered in the Parsnip
mainstem, in shallow, faster water:

> "Radio tagged individuals moved throughout the winter but remained within the Parsnip River mainstem, frequenting shallow, higher velocity areas associated with riffles, side channels, and islands" (stamford_etal2017FWCPArctic, p. 11)

> "Overwintering assemblages of Arctic Grayling in the Parsnip River mainstem are concentrated in the reaches near the confluences of the four study tributaries" (martins_etal2022SpatialEcology, p. 32)

Stamford et al. 2017 note that the low-gradient lower Anzac and Table held almost no wintering grayling:

> "Of note, however, was the virtual absence of overwintering juvenile and adult grayling in the lower reaches of the Anzac and Table rivers, which are low gradient reaches with similar characteristics to the overwintering areas used in the Parsnip mainstem" (stamford_etal2017FWCPArctic, p. 14)

Across the Williston watershed, Hagen et al. 2026 assume wintering habitat overlaps juvenile habitat:

> "Overwinter habitats are also assumed to overlap with juvenile critical habitats (Section 3)." (hagen_etal2026futureArctic, p. 26)

In the Sukunka (BC), some two-year-olds wintered in deep tributary pools:

> "Under-ice sampling showed some two year olds remain in the deep tributary pools overwinter" (stuart_chislett1979AspectsLife, p. 3)

Cannings and Ptolemy:

> "Large deep pools are required for overwintering and holding water." (cannings_ptolemy1998RareFreshwater, p. 48)

**Elsewhere, spring-fed water.** In the Northwest Territories and Alaska, grayling winter in spring-fed reaches,
deep lakes and large rivers:

> "The use of spring-fed tributaries by grayling for overwintering and perhaps spawning may be relatively common" (stewart_etal2007Fishlife, p. 22)

> "Areas fed by perennial springs are used by adult grayling overwintering in Cache Creek, NT (Feb. 21-23, 1974, depth 0.5-1.5 m, 2-8°C Jessop and Lilley 1975)" (stewart_etal2007Fishlife, p. 22)

> "Deep lakes and large rapid runoff rivers serve as overwintering habitat in the Tanana River drainage." (tack1980Migrationsdistributions, p. 3)

## What limits them?

**Loss of large-river habitat to the reservoir.** Hagen et al. 2026:

> "The creation of Williston and Dinosaur Reservoirs resulted in the extirpation of an estimated 24 populations inhabiting the lower reaches of the Parsnip and Finlay rivers and upper reaches of the Peace River." (hagen_etal2026futureArctic, p. iii)

> "Flooding of roughly 350 km of the Peace River, Finlay River, and Parsnip River valleys eliminated much of the low gradient mainstem habitat that would have been used for rearing by juvenile grayling, and for overwintering for both juvenile and adult life stages." (hagen_etal2026futureArctic, p. 7)

> "This habitat loss is the most plausible explanation for the relatively rapid extirpation of populations in the Williston and Upper Peace core areas" (hagen_etal2026futureArctic, p. 7)

**Temperature.** Hagen et al. 2026:

> "Water temperature is also a key factor limiting Arctic Grayling populations, both through direct effects on survival and growth, and likely also through temperature-mediated species interactions." (hagen_etal2026futureArctic, p. 7)

> "In the Williston Reservoir watershed, Arctic Grayling are found in streams with cool, stable water temperatures" (hagen_etal2026futureArctic, p. 7)

In the Omineca region (Ballard and Shrimpton 2009, reported by Stamford et al. 2017):

> "Ballard and Shrimpton (2009) found no records of adult Arctic Grayling captured from water warmer than 14.5°C in the Omineca Region, which suggests their distribution is limited to cooler waters." (stamford_etal2017FWCPArctic, p. 16)

**Sediment and turbidity.** Hagen et al. 2026:

> "Elevated sediment transport reduces water clarity and negatively affects Arctic Grayling populations, both through direct effects on the health and survival of individual fish, and also through degradation of habitat for feeding and reproduction" (hagen_etal2026futureArctic, p. 7)

**Flow.** In the Sukunka (BC), a missing year class was put down to a summer of high
flows and sediment:

> "The grayling population in the Sukunka remained stable throughout the study period and was marked by the absence of the 1976 year class." (stuart_chislett1979AspectsLife, p. 2)

> "high flows and heavy sediment loads during the summer of 1976." (stuart_chislett1979AspectsLife, p. 2)

Stamford et al. 2017 see spring flows after emergence as a possible bottleneck:

> "Immediately following emergence, however, high and variable flows related to spring freshet might limit the availability of low-velocity rearing space." (stamford_etal2017FWCPArctic, p. 12)

> "Clark (1992) found a significant correlation between recruitment levels and stream flows over a 14-year period." (stamford_etal2017FWCPArctic, p. 12)

**Barriers.** The Northwest Territories review names unimpeded passage as a key requirement:

> "unimpeded access between spawning, feeding, and overwintering areas -- particularly during the spring spawning period" (stewart_etal2007Fishlife, p. v)

> "Spawning success appears to be strongly affected by stream obstructions that prevent or delay migrations" (stewart_etal2007Fishlife, p. v)

Stamford et al. 2017 name poorly installed crossings:

> "Disturbances to rare natal areas or restricted access (e.g. hanging culverts) to critical spawning and rearing habitat can seriously harm or eliminate Arctic Grayling from a watershed." (stamford_etal2017FWCPArctic, p. 19)

## What the documents read here do not settle

- **Spawning sites in the Williston watershed.** No source read locates spawning sites beyond the Parsnip telemetry
  (the Anzac, Table, Hominka and Missinka and the Parsnip mainstem) and fry captures; Hagen et al. 2026 call spawning
  and overwintering locations an information gap. No source read gives the gradient or size of a stream where
  spawning was seen, other than the artificial Sukunka channel.
- **Spawning dates seen, not inferred, in BC.** The Sukunka dates come from fry development and the Parsnip dates
  from telemetry and back-calculation.
- **Lacustrine grayling in BC.** The Toodoggone lake-inlet population is named but not described in any source read.
- **Winter habitat of fry and juveniles in BC.** The Sukunka winter fry habitat was not found, and the Williston
  syntheses assume, not show, that juvenile and winter habitats overlap.
- **Primary BC studies cited only through reviews.** Blackman 2002a, 2002b and 2004, Hawkshaw and Shrimpton 2014,
  Hawkshaw et al. 2013, Ballard and Shrimpton 2009, Mathias et al. 1998 and Stewart et al. 1982 (Adsett Creek) are
  read here only through Stamford et al. 2017, Hagen et al. 2026 or Cannings and Ptolemy 1998.

## How the quotes are checked

`scripts/0280-literature-verify.R` checks each quote as it checks the evidence table's: the citation key resolves to
one item in the group library, and the passage's words occur in that item's PDF text, or in an OCR of the page images
where the citation says `OCR`. The file is read as GitHub renders it (cmark-gfm). The gate proves the words are in the
source; the meaning of each sentence around them is audited by hand.
