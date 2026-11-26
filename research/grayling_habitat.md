# What the literature and grayling capture records say about link's grayling `default`

**Verified:** 2026-11-26 · **Issues:** #140 (this evidence), for #280 (the proposed baseline and its retune) and #139
(the baseline review); the FISS workbook records are #281 · **Produced by:** `data/literature_evidence.csv`'s GR rows
(audited for meaning, `planning/archive/<#140>/`), `research/grayling_life_history.md`, `data-raw/grayling_use.R`
(`data/gr_use.csv`, log `scripts/logs/habitat/20261126_grayling_use.txt`), `data-raw/grayling_segments.R` (log
`scripts/logs/habitat/20261126_grayling_segments.txt`) · **Status:** evidence gathered; no value proposed (#280).

## In plain words

<!-- LITERATURE: written once the audited rows are final -->

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
| ≤ 0.5 % | 158 | 33 | 1.16 (0.71–1.78) |
| 0.5–1 % | 151 | 29 | 0.95 (0.58–1.58) |
| 1–2 % (reference) | 385 | 78 | 1 |
| 2–2.49 % | 134 | 19 | 0.87 (0.48–1.42) |
| 2.49–3.49 % | 251 | 35 | 1.10 (0.70–1.60) |
| 3.49–5.49 % | 295 | 28 | 0.81 (0.49–1.28) |
| 5.49–8 % | 152 | 2 | underpowered: 2 catches |
| 8–12 % | 49 | 5 | underpowered |
| > 12 % | 5 | 0 | none caught |

The catch rate does not fall across link's spawning limit (2.49 %) or its rearing limit (3.49 %): every class up to
5.49 % sits within the reference's interval. Above 5.49 % grayling were caught on 2 of 152 visits. The tuning's picks
move `default`'s gradient limit to 5.49 % on both networks (`research/baseline_anchoring.md`), and these counts are
the same visits seen class by class.

### Channel width

| width (m) | visits | with grayling | rate ratio (95 % interval) |
|---|---|---|---|
| < 1.5 | 88 | 6 | 0.35 (0.11–0.72), underpowered |
| 1.5–2 | 106 | 7 | 0.26 (0.07–0.48), underpowered |
| 2–4 | 478 | 64 | 0.62 (0.42–0.91) |
| 4–8 (reference) | 481 | 105 | 1 |
| 8–15 | 195 | 35 | 0.91 (0.57–1.55) |
| 15–30 | 11 | 2 | underpowered |
| ≥ 30 | 4 | 0 | none caught |
| no width (order-1, unmeasured) | 217 | 10 | 0.25 (0.09–0.50) |

Grayling were caught about a quarter to a third as often in channels under 2 m as in channels of 4–8 m, and about
0.6 times as often at 2–4 m. Fewer visits caught any fish at all in those small channels (any-fish ratios 0.15–0.47
against 4–8 m); among visits that caught some fish, no width class caught grayling less often than 4–8 m by more than its interval
allows (`data/gr_use.csv`, response `gr_caught_given_fish`). The small channels' low rate goes with their low catch of
any fish.

### Mean annual discharge

| MAD (m³/s) | visits | with grayling | rate ratio (95 % interval) |
|---|---|---|---|
| < 0.021 | 445 | 28 | 0.31 (0.14–0.55) |
| 0.021–0.05 | 244 | 40 | 0.67 (0.34–1.24) |
| 0.05–0.2 | 400 | 75 | 0.78 (0.47–1.45) |
| 0.2–0.5 (reference) | 241 | 49 | 1 |
| 0.5–1 | 139 | 18 | 0.73 (0.34–1.33) |
| 1–5 | 107 | 19 | 0.87 (0.46–1.77) |
| ≥ 5 | 4 | 0 | none caught |

Below link's rearing floor (0.021 m³/s) grayling were caught about a third as often as at 0.2–0.5 m³/s. Above it no
class differs from the reference by more than its interval allows; the scored population holds almost no stream over
5 m³/s, because larger rivers are river polygons.

### How firm these are

The pattern holds under a logit link and with river-polygon visits added back (the log's sensitivity table): channels
under 2 m, MAD under 0.021 m³/s and gradients over 5.49 % stay low. With river polygons added, the classes from 2 to
5.49 % read somewhat lower (0.63–0.79 against 1–2 %). Two limits apply to all of them. Code 2 of link's grayling access is set by
grayling records upstream, so it is never used here; access enters only as the tuning's barrier test. And summer
electrofishing samples rearing, not spawning: 1,357 of the 1,580 visits were fished in July to September, and the 175
in May and June caught grayling on 11. The tables say nothing about where grayling spawn.

## Hagen et al.'s critical-habitat segments

Hagen et al. 2026 map 85 critical-habitat segments for grayling in six Williston core areas, each with the life
stages seen there. Read against the Freshwater Atlas lines they follow (3,176 km outside lakes and the reservoir),
they are large rivers: 93 % of their length lies in river polygons, the median MAD is 35 m³/s and the median width
about 60 m, and 99 % of the length is under 2.49 % gradient. The segments where fry were recorded look the same
(median MAD 37 m³/s, 99 % under 2.49 %), as do those named as spawning habitat (26 m³/s). They show where the
Williston's grayling live and are protected, mostly in rivers link's stream rules leave to the river branch; they do
not show where small-stream rearing stops.

<!-- WHAT EACH SAYS ABOUT LINK'S SIX VALUES; WHAT THIS IS NOT: written with the literature -->
