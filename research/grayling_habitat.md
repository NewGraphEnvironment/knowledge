# What the literature and grayling capture records say about link's grayling `default`

**Verified:** 2026-11-26 · **Issues:** #140 (this evidence), for #280 (the proposed baseline and its retune) and #139
(the baseline review); the FISS workbook records are #281 · **Produced by:** `data/literature_evidence.csv`'s GR rows
(audited for meaning, `planning/archive/<#140>/`), `research/grayling_life_history.md`, `data-raw/grayling_use.R`
(`data/gr_use.csv`, log `scripts/logs/habitat/20261126_grayling_use.txt`), `data-raw/grayling_segments.R` (log
`scripts/logs/habitat/20261126_grayling_segments.txt`) · **Status:** evidence gathered; no value proposed (#280).

## In plain words

link calls a stream rearing habitat for Arctic grayling when it is no steeper than 3.49 %, at least 1.5 m wide and
carries a mean annual discharge (MAD) of at least 0.021 m³/s, and spawning habitat at 2.49 %, 4 m and 0.2 m³/s. Those
numbers were set to get the work started. This file gathers what can stand behind them instead, without proposing
replacements (#280 does that).

What grayling are expected to do, from the life history (`research/grayling_life_history.md`): they spawn in spring,
in tributaries and in mainstem rivers, and their fry rear first in slow, shallow water at the margins. Where juveniles
and adults spend the summer, and where they winter, differs from study to study; that file sets the studies out.

What the evidence says about link's six numbers:
- **Gradient.** No source gives a gradient value as a limit, though some tie steeper reaches to less use or less
  spawning. The gradients given are of rivers, reaches and map segments where grayling were found, mostly under 2 %,
  with sites scored as holding juveniles on segments up to 6.96 %. The catch rate in the capture records does not fall at 2.49 % or
  3.49 %: up to 5.49 % no class was caught detectably less often than 1-2 % (though with river-polygon visits kept
  the classes from 2 to 5.49 % read somewhat lower), and at 5.49–8 % grayling were caught on 2 of 152 visits; too few
  steeper streams were fished to say more.
- **Channel width.** No source gives a minimum. Grayling were found at sites from about 1 m wide (sites a Williston
  study scored as holding juveniles, by one grayling of any size), and juveniles in Alaska appeared to select
  channels 1-8 m wide. Sources call spawning streams small, name large rivers, or both, and a 3 m
  constructed channel drew spawners. The catch rate is low under 2 m, and as low on streams with no modelled width, where few
  visits caught fish of any kind.
- **MAD.** No source gives a MAD limit. The flows given are of other kinds (on the day of spawning, a river's mean
  daily flow, the flow through a sampled pool), from below detection to about 400 m³/s. The catch rate is lowest under
  0.021 m³/s, where few visits caught fish of any kind; among visits that caught some fish it is not lower.

Most visits that caught grayling, and nearly all the length of Hagen et al.'s critical-habitat segments, are in large
rivers that link's stream rules leave to its river branch. The small-stream thresholds are where the evidence is
thinnest.

## Where grayling were caught

### What was counted

The tuning scores a rule by how well it separates electrofishing visits that caught grayling from those that did
not. These tables count the same visits: the tuning's own grayling rearing population (`.tune_population()`), 1,580
FDIS visits in 45 watershed groups, 229 of them with grayling. Each table holds one of the three things link's rule
tests: the segment's gradient, its channel width (`cw_deploy`, the width link reads where nobody measured) and its
mean annual discharge (`mad_pick`, wet's flow).

A rate ratio compares how often grayling were caught in a class with a reference class, after allowing for the area
fished, the data set, the era and the watershed group: 0.5 means half as often. It comes from the same model the
bull trout use curve used (`scripts/0291`): a complementary log-log link, under which a class multiplies the catch
rate whatever the effort. The interval is the middle 95 % of 200 refits on streams drawn with replacement, because
repeat visits to one stream are not independent. A class with fewer than 30 visits or 10 catches is marked
underpowered.

### Most grayling were caught where the tuning does not look

Of the 1,231 visits in grayling's range that caught grayling, 882 sit in a double-line river by the tuning's own
river-polygon test (by edge type: 711 on main flow inside the river, 56 on its side channels and 117 on connectors, two
of which lie outside any river polygon). The tuning's population leaves river polygons
out, as link's stream rules do, so only 229 of the 1,231 are scored. The tables below describe small and mid-sized
streams; the river polygons where most grayling were caught are not in them.

### Gradient

| gradient | visits | with grayling | rate ratio (95 % interval) |
|---|---|---|---|
| <= 0.5 % | 158 | 33 | 1.162 (0.705–1.778) |
| 0.5-1 % | 151 | 29 | 0.951 (0.584–1.583) |
| 1-2 % (reference) | 385 | 78 | 1 |
| 2-2.49 % | 134 | 19 | 0.869 (0.479–1.417) |
| 2.49-3.49 % | 251 | 35 | 1.102 (0.701–1.601) |
| 3.49-5.49 % | 295 | 28 | 0.811 (0.485–1.282) |
| 5.49-8 % | 152 | 2 | 0.124 (0.000–0.312), underpowered |
| 8-12 % | 49 | 5 | 1.084 (0.296–3.426), underpowered |
| > 12 % | 5 | 0 | none caught |

The catch rate does not fall across link's spawning limit (2.49 %) or its rearing limit (3.49 %): every class up to
5.49 % has an interval that holds 1. At 5.49–8 % grayling were caught on 2 of 152 visits; the 54 steeper visits caught
5, too few to read. The tuning's picks
move `default`'s gradient limit to 5.49 % on both networks (`research/baseline_anchoring.md`), and these counts are
the same visits seen class by class.

### Channel width

| width (m) | visits | with grayling | rate ratio (95 % interval) |
|---|---|---|---|
| < 1.5 | 88 | 6 | 0.345 (0.113–0.721), underpowered |
| 1.5-2 | 106 | 7 | 0.260 (0.069–0.480), underpowered |
| 2-4 | 478 | 64 | 0.621 (0.416–0.907) |
| 4-8 (reference) | 481 | 105 | 1 |
| 8-15 | 195 | 35 | 0.913 (0.567–1.548) |
| 15-30 | 11 | 2 | 0.667 (0.000–3.316), underpowered |
| >= 30 | 4 | 0 | none caught |
| no width | 217 | 10 | 0.253 (0.093–0.495) |

Grayling were caught about a quarter to a third as often in channels under 2 m as in channels of 4–8 m, and about
0.6 times as often at 2–4 m. Fewer visits caught any fish at all in those small channels (any-fish ratios 0.15–0.47
against 4–8 m); among visits that caught some fish, no width class caught grayling less often than 4–8 m by more than its interval
allows (`data/gr_use.csv`, response `gr_caught_given_fish`). The small channels' low rate goes with their low catch of
any fish.

### Mean annual discharge

| MAD (m³/s) | visits | with grayling | rate ratio (95 % interval) |
|---|---|---|---|
| < 0.021 | 445 | 28 | 0.314 (0.143–0.550) |
| 0.021-0.05 | 244 | 40 | 0.671 (0.341–1.237) |
| 0.05-0.2 | 400 | 75 | 0.782 (0.474–1.454) |
| 0.2-0.5 (reference) | 241 | 49 | 1 |
| 0.5-1 | 139 | 18 | 0.729 (0.339–1.333) |
| 1-5 | 107 | 19 | 0.867 (0.462–1.767) |
| 5-20 | 2 | 0 | none caught |
| >= 20 | 2 | 0 | none caught |

Below link's rearing floor (0.021 m³/s) grayling were caught about a third as often as at 0.2–0.5 m³/s. Few visits
there caught fish of any kind (any-fish ratio 0.143), and among visits that caught some fish, grayling were caught
about as often as at 0.2–0.5 m³/s (0.939, 0.333–2.085). From 0.021 to 5 m³/s every class's interval holds 1; the four
visits over 5 m³/s caught none, because larger rivers are river polygons, which the scored population leaves out.

### How firm these are

The pattern holds under a logit link and with river-polygon visits added back (the log's sensitivity table): channels
under 2 m, MAD under 0.021 m³/s and gradients of 5.49–8 % stay low. With river polygons added, the classes from 2 to
5.49 % read somewhat lower (0.62–0.78 against 1–2 %). Two limits apply to all of them. Code 2 of link's grayling access is set by
grayling records upstream, so it is never used here; access enters only as the tuning's barrier test. And summer
electrofishing samples rearing, not spawning: 1,357 of the 1,580 visits were fished in July to September, and the 175
in May and June caught grayling on 11. The tables say nothing about where grayling spawn.

## Hagen et al.'s critical-habitat segments

Hagen et al. 2026 map 85 critical-habitat segments for grayling in six Williston core areas, each with the life
stages seen there; some segments redraw reaches others already hold, so each Atlas line is counted once, and the
connector lines that carry a tributary's flow across a river are left out. Read against the Freshwater Atlas lines
they follow (1,726 km, outside lakes and the reservoir), they are large rivers: 93 % of their
length lies in river polygons, the median MAD is 30 m³/s and the median width about 57 m, and over 99 % of the length
is under 2.49 % gradient (the Atlas line's own gradient, which the tuning uses as its gradient sensitivity). The
segments where fry were recorded look the same (median MAD 37 m³/s, over 99 % under 2.49 %), as do those named as
spawning habitat (24 m³/s). They show where the
Williston's grayling live and are protected, mostly in rivers link's stream rules leave to the river branch; they do
not show where small-stream rearing stops.

## What the literature says about each of link's values

The evidence table (`data/literature_evidence.csv`) holds 115 grayling rows from #140, data rows 1190-1304, each a
verbatim quote checked by `scripts/0280-literature-verify.R` and audited for meaning against its page. Rows are cited
below by data row. Most say where grayling were found, not where they could not live; each row's `kind` says which.

### Gradient (rearing 3.49 %, spawning 2.49 %)

No source gives a gradient limit. The reviews describe grayling habitat as "medium", "low" or "relatively low"
gradient (1190, 1193-1195, 1197), one sentence passed from Hagen et al. 2015 to Stamford et al. 2017 to Hagen et al. 2026 (1194, 1195,
1197), and Stamford et al. relay a Williston study as placing fry rearing in low-gradient middle reaches (1196), though
at the watershed scale that study's report found gradient a poor predictor (1264), and its sites with juveniles lay
on segments up to 6.96 % (1263).

Some sources tie steeper reaches to less use or less spawning. In Adsett Creek, habitat for yearlings and older became
marginal upstream with rapidly increasing gradient and the loss of riparian cover after a fire (1266). Steeper boulder
and cobble reaches limit spawning in the Table and Anzac (Cowie and Blackman 2003, p. 9, citing Blackman et al. 2001;
`research/grayling_life_history.md`). In the Atigun most spawning lay in lakes, side channels and tributaries where
gradient and scour are less severe (1255). Hawkshaw and Shrimpton relay the suggestion that steep canyons are why
grayling are absent from the watersheds east of the Williston Reservoir (Hawkshaw and Shrimpton 2014, p. 25). Others
point the other way: in Adsett Creek yearlings and older were densest, per unit of habitat, in the steep sections, which the
authors suggest grayling preferred (1267); Stamford et al. judge that pools in clear reaches of moderate gradient appear to be a key need of Williston adults, and Hagen and
Stamford observe fewer adults in Parsnip streams with long low-gradient meanders (both in
`research/grayling_life_history.md`).

The values are of rivers and reaches where fry and juveniles were caught in the Williston watershed: 0.1 % on the
Osilinka (1258), 0.2 % on the Omineca (1259), 0.3 % on the Parsnip (1262), under 0.5 % and 1-2 % on the Table (1260,
1261). The one rearing set given site by site is Hawkshaw and Shrimpton's: the map segments holding the 27 sites they
scored as holding juveniles (one grayling of any size) run from 0 to 6.96 % (mean 1.22 %), against 0 to 12.55 % at the 30 without (1263). A watershed's gradient did
not predict whether juveniles were there, but most of the watersheds had maximum gradients under 2.6 %, which the
authors offer as one possible reason the test found nothing (1264). For spawning, the only value is the Osilinka reach the authors call a
spawning and rearing area, inferred from fry (1257). Overwintering fish in Alberta's Little Smoky held reaches of
0.08-0.33 % (1201, 1268, 1269).

### Channel width (rearing 1.5 m, spawning 4 m)

No source gives a minimum. In Alaska juveniles appeared to select channels 1-8 m wide and to select against channels
wider than 14 m (1215, 1216), and adults in the same streams used channels averaging 10 m and selected against those
under 6 m (1216's note): preferences, not limits. The Northwest Territories review's habitat class for spawning and
rearing is about 10 m wide (1202, 1214). In the Williston watershed the sites scored as holding juveniles (one grayling of any size) were 0.96 to 43 m
wetted (1272),
fry and yearlings were seined in the 60-70 m Parsnip (1271), and yearlings favoured the larger, turbid Parsnip over its
clear tributaries (1273); other sources place juveniles and fry in small tributaries, or possibly along mainstem
margins, with no width (1217, 1218, 1274). For spawning, a constructed 3.0 m channel drew spawners (1203), and apart
from the review's class every other source calls spawning streams small, names rivers, or both, with no width
(1204-1213, 1270).

### MAD (rearing 0.021 m³/s, spawning 0.2 m³/s)

No source gives a MAD limit. Two give a river's mean daily flow where fry were caught: the Table's 12.9 m³/s, an
estimate its author suggested could be low, and the Parsnip's 142 m³/s over 1985-1995 (1278, 1279), beside
partial-year means of the Ingenika and Nation, 75.5 and 104.4 m³/s (1280, 1281). Among the other flows given: on the
day of peak spawning in a constructed channel, 0.21 and 0.25 m³/s (1224, 1225); Adsett Creek's mean through peak
spawning, 1.5 m³/s (1276); spawning streams' flows across 34 location-years, 0.096 to 33.90 m³/s (1223); and about
400 m³/s in the Fond du Lac River, where eggs were found (1226). In Interior Alaska even many bog streams that go dry
in late summer are used for spawning (1228). Adsett Creek, where fry reared through the summer, measured from below
detection to about 2.2 m³/s (1277), and the Sukunka pools that held two-year-old juveniles carried 1-15 and 21-65 m³/s
at sampling (1229, 1230).

### Stream order (no link value; a size proxy)

At the watershed scale, Hawkshaw and Shrimpton found juveniles absent from study streams below fourth order and both
present and absent at fourth order and above; order alone predicted presence poorly (1231). Stamford et al. relay the
study as placing the fry rearing areas, around which they say populations appear centred, in "e.g. 4th order and
larger" tributaries (1232) and, elsewhere, as
grayling that "appear more limited to cooler fifth order streams" (1233, citing Hawkshaw and Shrimpton 2014 and
Ballard and Shrimpton 2009); neither original has a fifth-order statement. Outside the Williston, grayling apparently
spawned in Adsett Creek, a second-order stream, and their fry reared there through the summer (1283, 1284).

## What this is not

This is evidence, not a proposal: the next step reads it into a baseline (#280). It is also thin where link needs it
most. No source sets a gradient, width or flow value as a limit for grayling: the values are where grayling were found,
with a review's class and widths fish selected, many of them large Williston rivers and the rest sites and reaches
across BC, the Northwest Territories, Alaska, Alberta, Saskatchewan and Montana. The capture records are summer
electrofishing on small and mid-sized streams, with most grayling captures on river polygons outside them, few spring
visits (175 in May and June) and none aimed at spawning, and no FISS workbook records yet (#281).
