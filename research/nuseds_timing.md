# NuSEDS spawning windows: what the spawner records can say about a group's timing

**Verified:** 2026-11-24 · **Issues:** #256 (what a date is, the method), #240 (the windows), #244 (move 16), #96 (the
first windows, UFRA and COTR); read by #241 and #242 · **Produced by:** `data-raw/nuseds_dates_check.R` and
`data-raw/timing_nuseds.R` (sharing `data-raw/nuseds_dates_read.R`) on the published `knowledge/nuseds/v1` (release
20260601), logs `scripts/logs/timing/20261124_nuseds_dates_check.txt` and `scripts/logs/timing/20261124_timing_nuseds*`
(#240's, `20261121_timing_nuseds*`, are the as-recorded windows alone)

## What a NuSEDS spawning date is

A NuSEDS start, peak or end of spawning is an estimate written on the record, not the day a surveyor saw the first or
last spawner. So a NuSEDS window speaks to the middle of a season: where its bulk falls and when it peaks. It speaks
to an edge only where a survey of several visits began before that edge (or ran past it), and even then it is
consistent with an edge someone saw, not proof of one, because NuSEDS keeps no count per visit.

Four things in the 102,807 dated records of the six species (a start or an end; #240's 102,800 count a start only
where `start_spawn_dt_from` gives it) show it (`20261124_nuseds_dates_check.txt`):

- **The dates are rounded.** Before 1990 a start is a single date on the five-day grid (the 1st, 5th, 10th, 15th,
  20th, 25th, 30th or 31st) on 91 to 94 % of starts; the 15th alone holds 42,491 single starts. From the 1990s the
  dates are ten-day bins (1 to 10, 11 to 20, 21 to the month's end): 3,009 of 12,086 starts in the 1990s, 7,157 of
  7,455 from 2010. Of 15,678 start bins, 15,005 are 10 or 11 days long; 664 are longer, and 2 run backwards.
- **The start is often recorded before the survey began.** Where a record's survey is compared (372 are set aside,
  below) and gives its first day, the start precedes it on 10,249 of 21,773 records before 1970 and 1,341 of 7,117
  from 2010. Visits were seldom recorded before the
  1980s (21 records before 1980 give a number).
- **Dates are written where no spawner was seen.** 3,725 dated records say NONE OBSERVED. Of the 2,479 whose survey
  is compared and gives both dates, 1,910 had a survey overlapping the very window they give; none gives a spawner count above 0. Their
  dates are the stream's expected timing. 332 dated records say NOT INSPECTED. The windows #240 built count both.
- **How a date was made is mostly unrecorded.** `estimate_method` is "Unknown Estimate Method" on 82,437 dated
  records.

**The upper Bulkley chinook,** the worked example (#241; the upper mainstem, `pop_id` 47859, and Buck Creek, 49223;
40 dated records). From 1953 to 1991 (27 records) the dates are round, most often 15 August and 15 September, with no
count of visits, mostly no survey dates and "Unknown Estimate Method". Buck Creek's 1977, 1978 and 1983 records say
NONE OBSERVED and still carry a full window. From 2008 to 2020 (13 records) the dates are ten-day bins, from 1 to 4
visits a year, mostly "Peak Live + Dead". The recorded start precedes the survey on five of them: 2009 (one
visit, on 10 September), 2016 (survey from 28 August) and 2017 (survey from 30 September), each giving a start of 11
to 20 August, and 2018 and 2019. It does so on the mainstem's 1986 to 1988 records too, and on Buck Creek's 1982 and
1988.
No record shows a visit that found no spawners before the start or after the end. The 2020 record's survey runs 20 October 2008 to
20 September 2030, a typing slip. 372 dated records' surveys are not compared: 98 give a survey year over a year
from the record's own, 309 a survey that ends before it starts even on the season year (below), and 35 both.

**The Morice and Nanika** (#241 asked for them before any MORR row is revised). To 1991 they read as the upper
Bulkley does: 34 of 39 Morice and 19 of 21 Nanika records give a start on the grid, a median of 2 visits where any is given, and
the start before the survey on 15 of 24 Morice and 9 of 15 Nanika records that give the survey's first day. From 1995 they are
better surveyed: 24 of 25 starts in each are bins, a median of 4 visits, 16 Morice and 12 Nanika records estimated by
"Area Under the Curve", and 5 Morice and 4 Nanika records have a survey of 3 or more visits that began before the
recorded start. Even so, the start
precedes the survey on 8 of 20 Morice and 10 of 19 Nanika records.

## Which records can bound an edge

Ten candidate rules were measured over records whose adults were present: a3s over those giving a start with a day
to read (a bin over 31 days or running backwards gives none), a3e likewise over those giving an end, the others over
those giving both. The table shows the six that differ in kind (a2, a4 and a5
vary a3's visits, and a fourth joins a3 and c):

| rule | records | chinook groups with 5 or more |
|---|---:|---:|
| a3: the survey brackets both edges, 3 or more visits | 2,076 | 12 |
| a3s: the survey began before the recorded start, 3 or more visits | 7,023 | 19 |
| a3e: the survey ended after the recorded end, 3 or more visits | 3,849 | 19 |
| b: a fence or fixed-site census | 560 | 1 |
| c: start and end single dates off the five-day grid | 1,605 | 15 |
| d: estimated by area under the curve | 3,679 | 13 |

Each rule had to pass a test set before it was run: dated NONE OBSERVED records must meet its conditions at under
half the rate present records do, each over the records the rule can be asked of (else the rule admits dates written whatever was seen), and no more than half the
records it admits may put an edge on the five-day grid. Every rule but b passes: NONE OBSERVED records meet their
conditions at 0.14 of the present rate or less. Within the 1990s, where both kinds of record are numerous and visits
recorded, the separation holds (a3: 5.8 % of present records against 0.4 % of NONE OBSERVED). A fence fails on the
grid (63 % of its records), and it dates passage, not spawning: its records' recorded start falls a median 20 days
after their arrival.

**The rule chosen:** an edge is taken from a3s records for the start and a3e records for the end, apart, because the
start and the end are separate claims and a survey can stand before one without standing after the other. Three
visits are the fewest that can put one before, one during and one after spawning. Rule c needs no visit before the
date, and d needs repeated counts but no visit beyond either edge.
An edge is given for a group and species only where 5 or more records qualify, a threshold set before the results.

## The window: bulk, peak and edges

`data-raw/timing_nuseds.R` gives every group, run type and population four readings
(`20261124_timing_nuseds_windows.csv`):

- **As recorded** (`rec_`): #240's window, the median `start_spawn_dt_from` to the median `end_spawn_dt_to` (else
  `end_spawn_dt_from`) over every dated record. Kept so the windows the UFRA and COTR rows rest on stay
  reproducible; every one of its 6,112 rows equals #240's.
- **The bulk of spawning** (`bulk_`): the median start to the median end, a bin entering as its midpoint, over
  records whose adults were present (any adult presence but NONE OBSERVED and NOT INSPECTED: 98,705 dated records say
  PRESENT, 43 UNKNOWN and 2 nothing) and whose window does not end before it starts on the season year. Each edge is
  read over the records that give it, so the bulk carries its own years (`bulk_first_year`, `bulk_last_year`); a start
  given only as `start_spawn_dt_to`, which the as-recorded window skips, enters it. Reading a
  start bin's first day and an end bin's last day, as the as-recorded window does, moves each edge outward by half
  the bin: four or five days for a ten-day bin, more for the 664 start bins and 1,573 end bins longer than 11 days.
  The 21 longer than 31 days give no midpoint and leave the bulk.
- **The peak** (`peak_`): the median peak, read the same way over present records that give a peak, some of which
  give no start or end, so it carries its own years (`peak_first_year`, `peak_last_year`): UFRA's chinook peaks run to
  2014, its bulk to 2008 and its as-recorded starts and ends to 2000.
- **An edge** (`edge_`): the median start over a3s records and the median end over a3e records (the same sets, from
  `nuseds_survey()`), given where 5 or more qualify. 162 of 357 group windows have a start edge and 124 an end edge; chinook 24 of 81 either.

## What a NuSEDS window may claim beside a cited row

A NuSEDS window supports or questions the middle of a cited row: where the bulk of spawning falls and when it peaks.
It is no reason to move a row's start or end, except where an edge is given, and an edge given is consistent with a
seen edge, never proof. A row's note says so in these words, filled from the windows table:

> NuSEDS (release 20260601; `data-raw/timing_nuseds.R`, `scripts/logs/timing/<date>_timing_nuseds.txt`): the bulk of
> spawning runs <bulk start> to <bulk end> (<n> population-years, <years>), peaking about <peak> (<peak n>, <peak
> years>). NuSEDS's start and
> end dates are estimates, not the first and last spawners seen, so they support the middle of this window and cannot
> test its edges[; its <start/end> of <date> rests on <n> records whose survey of three or more visits began before
> it (ran past it)].

## What the records hold

Of the release's 421,001 rows, 102,800 carry a spawning start or end date, from 5,221 populations: chum 34,047,
coho 29,454, pink 21,899, chinook 8,818, sockeye 8,567, steelhead 15. A record is one population, stream (`gfe_id`)
and year, and almost always one population-year: 16 dated records with a watershed code, of two populations, share
one. The windows cover 480 group and species pairs in 126 watershed groups; 357 have populations that pool into the
group, and 123 have only populations on streams that cross several groups.

## Mainstems: a watershed code does not say where on a river the fish spawn

A population is placed by its FWA watershed code. 4,928 dated populations sit on a code that lies in one group; 189
sit on a code that crosses several (70 named waterbodies: the Kitlope, Dean, Morice, Lakelse, the Bulkley's two
reaches, the Skeena, the North Thompson, Maria Slough on the Fraser's code), and 72 carry a code the Atlas does not
hold. A mainstem's code says nothing about where on it the fish spawn, so those populations join no group's window
and are listed apart under each group they cross. `data/nuseds_reach_groups.csv` names the reach (`gfe_id`) and group
where a review has placed one; it holds UFRA's Fraser above Tete Jaune.

DFO's Conservation Unit Census Sites file (the same Open Government record) gives a point for 97 % of dated
populations, but the points are not spawning reaches: Morice River's falls in BULK (it spawns in MORR, below Morice
Lake), the North Thompson's in LNTH and the Skeena's in LSKE. They were tried and set aside (#244's gate).

## Spawning past the new year

About 3,000 coho and chum spawning ends fall in January to March (coho 2,512, chum 540). On a calendar year their
day numbers sit before August, so a median over a group mixes them with October ends. The windows count days on a
season year that starts on 1 April (1 September for steelhead, which spawn in spring), and the comparison with the
table's rows uses the same year. Every date is read by its month and day alone: DFO often writes a January-to-March
end, or a survey's last day, with the record's own year (start 25-SEP-93, end 25-FEB-93), which would put it before
the start. 165 present records end before they start on their written years; 98 of them (76 coho) run forward on the
season year, and the other 67 run backwards either way and leave the bulk. A survey that opens before the season start (a
whole-year survey from 2 January) stays in the season it opened. A bin is halved after both its ends are on the
season year.

## The four groups' rows beside NuSEDS, estimate against estimate

Days are NuSEDS's pooled group window minus the row: the row's start and end against the bulk, the row's middle
against the peak. A migration row's end is set against the day before the bulk's median start, the table's
convention that migration ends where spawning starts. Edges are given only where 5 or more records qualify.

| group | species | stage | row | NuSEDS bulk | peak | edges | start | end | middle |
|---|---|---|---|---|---|---|---:|---:|---:|
| BULK | CH | spawning | 08-01 to 09-15 | 08-15 to 09-05 | 08-25 | none | +14 | -10 | +1.5 |
| BULK | CH | migration | to 08-01 | starts 08-15 | | | | +13 | |
| BULK | CO | spawning | 09-15 to 11-15 | 10-05 to 11-15 | 10-15 | none | +20 | 0 | -0.5 |
| BULK | SK | spawning | 08-01 to 09-15 | 08-15 to 09-15 | 08-31 | none | +14 | 0 | +7.5 |
| MORR | CH | spawning | 09-01 to 10-07 | 08-25 to 09-25 | 09-15 | end 09-25 (9) | -7 | -12 | -4.0 |
| MORR | CH | migration | to 09-30 | starts 08-25 | | | | -37 | |
| MORR | CO | spawning | 10-15 to 11-30 | 10-05 to 11-05 | 10-15 | start 10-15 (8) | -10 | -25 | -23.0 |
| MORR | CO | migration | to 09-07 | starts 10-05 | | | | +27 | |
| MORR | SK | spawning | 09-01 to 09-30 | 09-05 to 10-05 | 09-15 | 09-05 (6) to 10-05 (11) | +4 | +5 | -0.5 |
| MORR | SK | migration | to 08-31 | starts 09-05 | | | | +4 | |
| UFRA | CH | spawning | 08-11 to 09-05 | 08-12 to 09-05 | 08-24 | start 08-15 (11) | +1 | 0 | +0.5 |
| UFRA | CH | migration | to 08-10 | starts 08-12 | | | | +1 | |
| COTR | CH | spawning | 08-10 to 09-06 | 08-10 to 09-05 | 08-24 | none | 0 | -1 | +0.5 |
| COTR | CH | migration | to 08-09 | starts 08-10 | | | | 0 | |

Read by the method, the BULK chinook row's middle agrees with NuSEDS (the peak 1.5 days off the row's middle), and
its start and end differ from NuSEDS's estimated dates, which cannot test them; BULK sockeye's bulk rests on 4
records. MORR chinook's end has an edge, 09-25 on 9 records, 12 days before the row's end. NuSEDS's MORR coho peak
falls 23 days before the row's middle. MORR chinook's migration row runs a month into spawning, which is why its end differs
by 37 days. BULK's chinook window pools seven tributary populations; the Bulkley's two reaches and the Morice are
apart.

**UFRA and COTR** (#96, read by NewGraphEnvironment/wet#182). Their spawning rows are NuSEDS's as-recorded windows,
which the script still reproduces. Under the method they barely move: UFRA's as-recorded starts and ends run 1967 to
2000 (its bulk to 2008), only 20 of its 124 starts are bins (6 of COTR's 35). UFRA's bulk is 08-12 to 09-05, peaking 08-24 (over 172 peaks,
1967 to 2014), and its start has an edge, 08-15 on 11 records; COTR's bulk is 08-10 to 09-05, peaking 08-24, with no edge. Their start dates are
estimates like any other: 83 of UFRA's 124 starts and 19 of COTR's 35 fall on the five-day grid, and 28 of UFRA's 76
and 12 of COTR's 32 starts with a survey's first day precede it. The rows keep their dates, and their notes say
what NuSEDS shows (owner, 2026-11-24); any change to the dates is #242's.
