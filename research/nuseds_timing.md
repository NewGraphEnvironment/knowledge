# NuSEDS spawning windows: what the spawner records can say about a group's timing

**Verified:** 2026-11-21 · **Issues:** #240 (this file), #244 (move 16), #96 (the first windows, UFRA and COTR); read
by #241 and #242 · **Produced by:** `data-raw/timing_nuseds.R` on the published `knowledge/nuseds/v1` (release
20260601), logs `scripts/logs/timing/20261121_timing_nuseds*`

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
table's rows uses the same year.

## The four groups' rows beside NuSEDS

Days are NuSEDS's pooled group window minus the row; a migration row's end is set against the day before NuSEDS's
median start, the table's convention that migration ends where spawning starts.

| group | species | stage | row | NuSEDS | start | end |
|---|---|---|---|---|---:|---:|
| BULK | CH | spawning | 08-01 to 09-15 | 08-15 to 09-10 | +14 | -5 |
| BULK | CH | migration | to 08-01 | to 08-14 | | +13 |
| BULK | CO | spawning | 09-15 to 11-15 | 10-01 to 11-15 | +16 | 0 |
| BULK | SK | spawning | 08-01 to 09-15 | 08-15 to 09-15 | +14 | 0 |
| MORR | CH | spawning | 09-01 to 10-07 | 08-21 to 09-30 | -11 | -7 |
| MORR | CH | migration | to 09-30 | to 08-20 | | -41 |
| MORR | CO | spawning | 10-15 to 11-30 | 10-01 to 11-10 | -14 | -20 |
| MORR | CO | migration | to 09-07 | to 09-30 | | +23 |
| MORR | SK | spawning | 09-01 to 09-30 | 09-01 to 10-10 | 0 | +10 |
| MORR | SK | migration | to 08-31 | to 08-31 | | 0 |
| UFRA, COTR | CH | spawning and migration | | | 0 | 0 |

BULK's chinook window pools seven tributary populations (28 dated starts); the Bulkley's two reaches and the Morice
are apart, and run 08-15 to 09-15, 08-17 to 09-18 and 08-21 to 09-30. MORR's pools the Nanika alone (45 starts); the
Morice mainstem (64) is apart and matches it, 08-21 to 09-30. MORR's chinook migration row runs a month into spawning,
which is why its end differs by 41 days. UFRA and COTR rest on #96's windows, which the script reproduces.
