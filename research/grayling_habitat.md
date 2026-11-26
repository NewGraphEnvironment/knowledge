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
in tributaries and in mainstem rivers; their fry rear in slow, shallow water at the margins; juveniles and adults feed
through summer in mid-sized and larger streams and rivers; and they winter in large rivers and lakes.

What the evidence says about link's six numbers:
- **Gradient.** No source gives a gradient limit for grayling. Where gradients are given they are those of reaches
  and sites where grayling were found, nearly all under 2 %. The capture records do not fall at 2.49 % or 3.49 %:
  grayling were caught as often up to 5.49 %, and rarely at 5.49–8 % (2 of 152 visits); too few steeper streams were
  fished to say more.
- **Channel width.** No source gives a minimum. Juveniles were found from about 1 m wide upward; spawning was seen in
  a 3 m constructed channel and in large rivers. The capture records are lowest under 2 m, where few fish of any kind
  were caught.
- **MAD.** No source states one. Flows are given for the day of spawning or for a river's mean, from 0.2 m³/s to
  hundreds. The capture records are lowest under 0.021 m³/s.

Most grayling in the capture records, and all of Hagen et al.'s critical-habitat segments, are in large rivers that
link's stream rules leave to its river branch. The small-stream thresholds are where the evidence is thinnest.

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

Of the 1,231 visits in grayling's range that caught grayling, 884 sit on river-polygon lines (711 on main flow
inside a double-line river, 56 on its side channels, 117 on connectors). The tuning's population leaves river polygons
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

Below link's rearing floor (0.021 m³/s) grayling were caught about a third as often as at 0.2–0.5 m³/s. Above it every
class has an interval that holds 1; the scored population holds almost no stream over
5 m³/s, because larger rivers are river polygons.

### How firm these are

The pattern holds under a logit link and with river-polygon visits added back (the log's sensitivity table): channels
under 2 m, MAD under 0.021 m³/s and gradients of 5.49–8 % stay low. With river polygons added, the classes from 2 to
5.49 % read somewhat lower (0.62–0.78 against 1–2 %). Two limits apply to all of them. Code 2 of link's grayling access is set by
grayling records upstream, so it is never used here; access enters only as the tuning's barrier test. And summer
electrofishing samples rearing, not spawning: 1,357 of the 1,580 visits were fished in July to September, and the 175
in May and June caught grayling on 11. The tables say nothing about where grayling spawn.

## Hagen et al.'s critical-habitat segments

Hagen et al. 2026 map 85 critical-habitat segments for grayling in six Williston core areas, each with the life
stages seen there; some segments redraw reaches others already hold, so each Atlas line is counted once. Read
against the Freshwater Atlas lines they follow (1,814 km outside lakes and the reservoir), they are large rivers: 94 %
of their length lies in river polygons, the median MAD is 29 m³/s and the median width about 56 m, and 99 % of the
length is under 2.49 % gradient (the Atlas line's own gradient, which the tuning uses as its gradient sensitivity).
The segments where fry were recorded look the same (median MAD 37 m³/s, 99 % under 2.49 %), as do those named as
spawning habitat (24 m³/s). They show where the
Williston's grayling live and are protected, mostly in rivers link's stream rules leave to the river branch; they do
not show where small-stream rearing stops.

## What the literature says about each of link's values

The evidence table (`data/literature_evidence.csv`) holds 115 grayling rows from #140, data rows 1190-1304, each a
verbatim quote checked by `scripts/0280-literature-verify.R` and audited for meaning against its page. Rows are cited
below by data row. Most say where grayling were found, not where they could not live: a site measurement is
coded `dist`, a stated preference `pref`, a statement with no value `qual`.

### Gradient (rearing 3.49 %, spawning 2.49 %)

No source gives a limit. The reviews describe grayling habitat as "medium" or "relatively low" gradient with no number
(1190, 1193-1197), one sentence passed from Hagen et al. 2015 to Stamford et al. 2017 to Hagen et al. 2026 (1194,
1195, 1197). The values are reach gradients where fry and juveniles were caught in the Williston watershed: 0.1 % on
the Osilinka (1258), 0.2 % on the Omineca (1259), 0.3 % on the Parsnip (1262), under 0.5 % and 1-2 % on the Table
(1260, 1261). Hawkshaw and Shrimpton's 27 sites with juveniles sat on segments of 0 to 6.96 % (mean 1.22 %), against 0
to 12.55 % at the 30 without (1263), and a watershed's gradient did not predict whether juveniles were there (1264).
For spawning, the only value is the Osilinka reach the authors call a spawning and rearing area, inferred from fry
(1257); in Adsett Creek the most spawning generally lay toward the tails of runs before steep sections (1256).
Overwintering fish in Alberta's Little Smoky held reaches of 0.08-0.33 % (1201, 1268, 1269).

### Channel width (rearing 1.5 m, spawning 4 m)

No source gives a minimum. In Alaska juveniles appeared to select channels 1-8 m wide and to select against channels
wider than 14 m (1215, 1216), a preference, not a limit. In the Williston watershed juveniles were at sites 0.96 to
43 m wetted (1272), and fry and yearlings were seined in the 60-70 m Parsnip (1271). For spawning, a constructed 3.0 m
channel drew spawners (1203), the Northwest Territories review's habitat class is about 10 m (1202), and every other
source says "small tributaries" or names large rivers, with no width (1204-1213, 1270).

### MAD (rearing 0.021 m³/s, spawning 0.2 m³/s)

No source states a MAD. The flows given are of other kinds: on the day of peak spawning in a constructed channel,
0.21 and 0.25 m³/s (1224, 1225); Adsett Creek's mean through peak spawning, 1.5 m³/s (1276); spawning streams'
flows across 34 location-years, 0.096 to 33.90 m³/s (1223); and the mean daily flows of rivers where fry were caught,
12.9 to 142 m³/s (1278-1281). Adsett Creek, where fry reared through the summer, measured from below detection to
about 2.2 m³/s (1277).

### Stream order (no link value; a size proxy)

At the watershed scale, Hawkshaw and Shrimpton found juveniles absent from study streams below fourth order and both
present and absent at fourth order and above; order alone predicted presence poorly (1231). Stamford et al. relay the
study as fry rearing in "e.g. 4th order and larger" tributaries and, elsewhere, as grayling limited to "cooler fifth
order streams" (1232, 1233); the report itself has no fifth-order statement. Outside the Williston, grayling spawned in and their fry
reared through the summer in Adsett Creek, a second-order stream (1283, 1284).

## What this is not

This is evidence, not a proposal: the next step reads it into a baseline (#280). It is also thin where link needs it
most. No source sets a gradient, width or flow limit for grayling; the values are where grayling were seen, mostly in
large Williston rivers. The capture records are summer electrofishing on small and mid-sized streams, with most
grayling captures on river polygons outside them, no spring spawning sample, and no FISS workbook records yet (#281).
