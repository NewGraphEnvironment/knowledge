# Meaning audit, round 3: `research/grayling_habitat.md` (plain words, literature, what this is not)

Scope: "In plain words" (lines 9-35), "What the literature says about each of link's values" (lines 140-204) and
"What this is not" (lines 206-213), as they stand after round 2's fixes (`fixes-habitat-round2.md`). Rows read: every
GR row 1190-1304 (quote, note, kind, stage, region, value) and the 30 GR rows outside it (903-925, 996-1000, 1185,
1186) for the "no source" quantifiers; `research/grayling_life_history.md` In brief, spawning (285-449), summer
(701-857) and winter (859-930). Source text checked where a claim rests on wording: Stewart et al. 1982 pp. 44, 46
(text lines 6300-6320, 6794-6815), Hawkshaw and Shrimpton 2014 pp. 13-14, 25 (text lines 800-822, 855-870,
1903-1928) and its microhabitat variables (line 1165), Den Beste and McCart 1984 p. 21 (lines 1050-1057), Stewart et
al. 2007 Table 1 (layout lines 406-438). Capture numbers checked against `data/gr_use.csv` and the sensitivity table
of `scripts/logs/habitat/20261126_grayling_use.txt` (lines 266-320) where a sentence of the three sections restates
or summarises them.

10 findings. Severity: **M** = changes what a reader proposing the baseline would take from the sentence; **m** =
hedge, attribution or scope. Two sit inside round 2's fixes (F1, the gradient lead-in rewritten by F5/F6; F6, round 2's
F8 hedge fix); F7, F8 and F9 sit in plain-words bullets round 2 shortened.

## Findings

### F1 (M) line 146: "No source gives a number."

The section's first sentence, standing alone under the gradient heading, says no source gives a gradient number. Ten
valued gradient rows do (1201, 1257-1263, 1268, 1269), and the same section lists them at lines 164-171 ("The values
are ... 0.1 % on the Osilinka ..."). Round 2's version scoped the sentence to the reviews ("reviews say 'medium' or
'relatively low' gradient, no number"); the rewrite after its F5 left the quantifier unscoped. Line 21 of the plain
words says it correctly ("No source gives a gradient value as a limit").
**Fix:** "No source gives a gradient limit." (or "The reviews give no number:").

### F2 (m) line 148: 'describe grayling habitat as "medium" or "relatively low" gradient (1190, 1193-1195, 1197)'

The quoted words are credited to five rows; "relatively low" is 1197's alone (Hagen et al. 2026). 1194 (Hagen et al.
2015) and 1195 (Stamford et al. 2017) say "low gradient", and the line goes on to say the sentence was passed from 2015
to 2017 to 2026, which is where "relatively" was added.
**Fix:** 'as "medium", "low" or "relatively low" gradient'.

### F3 (m) line 151: "though that study's report found gradient a poor predictor (1263, 1264)"

Two faults. The report's finding is at the watershed scale: three watershed gradient variables in one macrohabitat
model ranked poorly (p. 25, text lines 1911-1913; row 1264, whose note says "watershed-scale"), and the authors add
that "the effects of stream gradient and elevation would be more evident at a smaller scale" (lines 1927-1928). 1196's
claim is a reach-scale one (low-gradient middle reaches), so the "though" sets the watershed result against a reach
statement the authors themselves say their test could not reach. And 1263 says nothing of prediction: it is Appendix
F's segment gradients at sites with and without juveniles. Line 167 states the scale correctly ("A watershed's gradient
did not predict").
**Fix:** "though at the watershed scale that study's report found gradient a poor predictor (1264), and its sites with
juveniles lay on segments up to 6.96 % (1263)".

### F4 (m) line 159: "in Adsett Creek yearlings and older were densest in the steep sections, the authors suggest (1267)"

The hedge sits on the wrong claim. The density is reported, per unit of available habitat: "these sections supported
the most grayling per unit area of habitat (0.006 grayling/m²)" against 0.003 in Sections 5-7 (p. 46, text lines
6804-6810). What the authors suggest is the preference: "These results suggest that grayling preferred areas of steep
gradient" (lines 6810-6812; row 1267's note: "hedged ('These results suggest')"). The sentence makes the measurement
sound tentative and drops the inference, and "densest" without "per unit of habitat" loses that the steep sections
held little habitat and that fish numbers per section did not differ (Kruskal-Wallis, lines 6795-6798).
**Fix:** "in Adsett Creek yearlings and older were densest, per unit of habitat, in the steep sections, which the
authors suggest grayling preferred (1267)".

### F5 (m) lines 167-169: "most of the watersheds had maximum gradients under 2.6 %, which the authors say left little contrast to test (1264)"

The authors offer it as one of "several factors that could account for the poor predictive ability of these
macrohabitat models" (p. 25, text lines 1923-1925: "indicating a lack of watersheds with overall high gradients"),
not as a finding that the test lacked contrast. The hedge ("could account") is dropped.
**Fix:** "which the authors offer as one possible reason the test found nothing (1264)".

### F6 (m) lines 200-201: "Stamford et al. relay the study as fry rearing areas that appear centred in 'e.g. 4th order and larger' tributaries (1232)" (inside round 2's F8 fix)

Round 2's hedge fix moved "appear" onto the wrong subject. The source: "Fluvial grayling populations in Williston
watershed appear to be centered around fry rearing areas located in the low gradient middle reaches of larger (e.g. 4th
order and larger) tributaries" (1232). What appears centred is the populations, around the fry rearing areas; that the
rearing areas lie in 4th-order-and-larger tributaries is stated without a hedge. The same quote at line 150 (1196) is
rendered unhedged and correctly ("placing fry rearing in low-gradient middle reaches"), so the two renderings of one
sentence now disagree.
**Fix:** "Stamford et al. relay the study as placing the fry rearing areas, around which they say populations appear
centred, in 'e.g. 4th order and larger' tributaries (1232)".

### F7 (M) lines 23-24: "grayling were caught as often up to 5.49 %"

The evidence is that no class up to 5.49 % was caught detectably less often than 1-2 %, not that they were caught as
often. The point estimates run 0.81 to 1.16, and the intervals are wide below 1 (2-2.49 %: 0.869, 0.479-1.417;
3.49-5.49 %: 0.811, 0.485-1.282; `data/gr_use.csv`). With river-polygon visits kept, the classes from 2 to 5.49 % read
0.63-0.79 (log lines 272-275), which the file's own "How firm these are" reports (line 122). "As often" reads, to a
reader setting a gradient limit, as a measured equality the data do not give.
**Fix:** "grayling were caught no detectably less often up to 5.49 % (every class's interval holds 1), though with
river-polygon visits kept the classes from 2 to 5.49 % read somewhat lower".

### F8 (m) line 28: "The catch rate is lowest under 2 m"

Not over all width classes. The visits with no modelled width (`cw_deploy` empty, 217 visits) have a ratio of 0.253
(0.093-0.495), as low as 1.5-2 m's 0.260 and below < 1.5 m's 0.345, and like them few caught any fish (31 of 217;
any-fish ratio 0.141). These are streams link cannot size by width, so they bear on what a width floor does. (The
>= 30 m class, 0 of 4, is unreadable.)
**Fix:** "The catch rate is low under 2 m, and as low on streams with no modelled width, where few visits caught fish
of any kind."

### F9 (M) lines 30-31: "The catch rate is lowest under 0.021 m³/s." (no any-fish caveat, where the width bullet carries one)

The width bullet two lines up qualifies its low rate ("where few visits caught fish of any kind"); the MAD bullet,
read beside it, implies the MAD floor's low rate is not so confounded. It is, and more plainly: under 0.021 m³/s 80 of
445 visits caught any fish (any-fish ratio 0.143, 0.095-0.211, against 0.2-0.5 m³/s), and among visits that caught
some fish grayling were caught as often as at 0.2-0.5 m³/s (`gr_caught_given_fish` 0.939, 0.333-2.085;
`data/gr_use.csv`). A reader would take the bullet as cleaner support for the 0.021 floor than the width evidence; it
is the same pattern. (The body's MAD paragraph, lines 114-116, outside this audit's scope, omits it too.)
**Fix:** "The catch rate is lowest under 0.021 m³/s, where few visits caught fish of any kind; among visits that
caught some fish it is not lower."

### F10 (m) lines 23, 26, 166-167, 178: "juvenile sites", "Juveniles were found at sites from about 1 m wide", "27 sites with juveniles", "juveniles were at sites 0.96 to 43 m wetted"

Hawkshaw and Shrimpton "assumed juvenile Arctic grayling to be present in the study site if at least one individual
of any size was observed" (p. 14, text lines 818-819; rows 1263 and 1272 note it: "a site counted as present for one
grayling of any size"). The four sentences say juveniles were found; the study recorded a grayling of any size and
called the site a juvenile site. Round 2's enumeration marked line 177-178 OK with this caveat in hand; the sentences
do not carry it. It matters most at the width floor: the 0.96 m site is the evidence for "from about 1 m".
**Fix:** at line 26, "Grayling, counted by the study as juveniles, were found at sites from about 1 m wide"; at lines
166 and 178, "sites the study scored as holding juveniles (one grayling of any size)"; line 23 can keep "juvenile
sites" if line 26 carries the definition.

## Noticed outside this audit's scope

- Line 114-115: "Above it every class has an interval that holds 1" — the 5-20 and >= 20 m³/s classes (2 visits
  each, none caught) have no interval; the clause after the semicolon explains why they are empty, but the quantifier
  is literally false.
- Lines 114-116: the MAD paragraph lacks the any-fish reading the width paragraph gives (F9).

## Enumeration: every sentence in the three sections

Verdicts: OK = each cited row or page says it, and its quantifier holds over the GR rows of its variable and stage and
the life-history file; F*n* = see finding; out of scope = a statement about link's configuration.

| line | sentence (abridged) | rows / pages cited | verdict |
|---|---|---|---|
| 11-12 | link's rearing and spawning values | none (link) | out of scope |
| 12-13 | numbers set to get the work started | none | out of scope |
| 13-14 | this file gathers, does not propose (#280) | none | OK |
| 16-17 | spawn in spring, in tributaries and mainstem rivers | life history 24-38, 285-449 | OK |
| 17 | fry rear first in slow, shallow water at the margins | life history 39-42, 559-637 | OK |
| 17-18 | summer and winter places differ from study to study; that file sets them out | life history 701-930 | OK (winter varies: Parsnip mainstem shallow fast water, Sukunka tributary pools, Adsett small tributaries, Little Smoky pools, NT spring-fed) |
| 20 | lead-in | none | OK |
| 21 | no source gives a gradient value as a limit | 1186, 1190-1201, 1255-1269; 903-925 | OK |
| 21-22 | some tie steeper reaches to less use or less spawning | 1255, 1266; Cowie and Blackman 2003 p. 9; Hawkshaw and Shrimpton 2014 p. 25 | OK |
| 22 | gradients given are of rivers, reaches and map segments where found, mostly under 2 % | 1201, 1257-1263, 1268, 1269 | OK (only 1263's range passes 2 %) |
| 23 | juvenile sites on segments up to 6.96 % | 1263 | OK (value); F10 (juvenile = any grayling) |
| 23-24 | catch rate does not fall at 2.49 or 3.49 % | `gr_use.csv` gradient | OK |
| 24 | grayling caught as often up to 5.49 % | `gr_use.csv`; log 272-275 | F7 |
| 24 | rarely at 5.49-8 % (2 of 152) | `gr_use.csv` | OK (interval 0-0.312) |
| 24-25 | too few steeper streams fished to say more | 49 + 5 visits | OK |
| 26 | no source gives a width minimum | 1202-1218, 1270-1274 | OK (1202, 1214 a class; 1215, 1216 preferences) |
| 26 | juveniles found at sites from about 1 m wide | 1272 | F10 |
| 26-27 | in Alaska appeared to select channels 1-8 m | 1215 | OK |
| 27 | sources call spawning streams small, name large rivers, or both | 1202, 1204-1213, 1270 | OK |
| 27-28 | a 3 m constructed channel drew spawners | 1203 | OK |
| 28 | catch rate lowest under 2 m | `gr_use.csv` width | F8 |
| 28 | where few visits caught fish of any kind | `gr_use.csv` any_fish_caught | OK (17/88, 14/106 against 323/481) |
| 29 | no source gives a MAD limit | 996-1000, 1223-1230, 1276-1282 | OK |
| 29-30 | flows of other kinds: day of spawning, mean daily flow, flow through a sampled pool | 1224-1226, 1229, 1230, 1278-1281 | OK |
| 30-31 | from below detection to about 400 m³/s | 1277, 1226 | OK |
| 31 | catch rate lowest under 0.021 m³/s | `gr_use.csv` mad | OK as a number; F9 (caveat missing) |
| 33-34 | most visits with grayling, nearly all segment length, in large rivers left to the river branch | lines 56-60, 132-133 | OK (882 of 1,231; 93 %) |
| 34-35 | small-stream thresholds where evidence thinnest | summary | OK |
| 142-143 | 115 GR rows 1190-1304, verbatim, checked by 0280, audited | 1190-1304 | OK |
| 143-144 | rows cited by data row | none | OK |
| 144 | most say where found, not where they could not live; `kind` says which | kinds of 1190-1304 | OK (no row is a limit; dist plus location qual rows a majority) |
| 148 | no source gives a number | gradient rows | F1 |
| 148-149 | reviews say "medium" or "relatively low" gradient | 1190, 1193-1195, 1197 | F2 |
| 149-150 | one sentence passed 2015 → 2017 → 2026 | 1194, 1195, 1197 | OK |
| 150 | Stamford relay a Williston study as placing fry rearing in low-gradient middle reaches | 1196 | OK |
| 151 | though that study's report found gradient a poor predictor | 1263, 1264 | F3 |
| 153 | some sources tie steeper reaches to less use or less spawning | 1255, 1266, pages below | OK |
| 153-154 | Adsett: habitat for yearlings and older marginal upstream, gradient and loss of riparian cover after fire | 1266; p. 44 text 6313-6318 | OK |
| 154-156 | steeper boulder and cobble reaches limit spawning in Table and Anzac | Cowie and Blackman 2003 p. 9; life history 410 | OK |
| 156-157 | Atigun: most spawning in lakes, side channels, tributaries where gradient and scour less severe | 1255; p. 21 text 1050-1055 | OK |
| 157-158 | Hawkshaw and Shrimpton relay suggestion that steep canyons explain absence east of the reservoir | p. 25 text 1905-1911 | OK |
| 158-159 | Adsett yearlings and older densest in steep sections, the authors suggest | 1267; p. 46 text 6804-6812 | F4 |
| 160 | Stamford: pools in clear reaches of moderate gradient appear a key need of Williston adults | life history 775 | OK (adults and subadults) |
| 160-162 | Hagen and Stamford observe fewer adults in Parsnip streams with long low-gradient meanders | life history 786-790 | OK |
| 164-166 | values of rivers and reaches with fry and juveniles: 0.1, 0.2, 0.3, < 0.5 and 1-2 % | 1258, 1259, 1262, 1260, 1261 | OK |
| 166-167 | the one rearing set given site by site: segments at 27 sites 0-6.96 % (mean 1.22), 0-12.55 % at 30 without | 1263 | OK (values, uniqueness); F10 (juveniles) |
| 167-168 | a watershed's gradient did not predict whether juveniles were there | 1264 | OK |
| 168-169 | most watersheds max gradient under 2.6 %, which the authors say left little contrast | 1264; p. 25 text 1923-1925 | F5 |
| 169-170 | for spawning the only value is the Osilinka reach, called spawning and rearing area, inferred from fry | 1257 | OK (only valued spawning gradient row) |
| 170-171 | Little Smoky overwintering reaches 0.08-0.33 % | 1201, 1268, 1269 | OK |
| 175 | no source gives a minimum | width rows | OK |
| 175-176 | Alaska juveniles appeared to select 1-8 m, against > 14 m | 1215, 1216 | OK |
| 176-177 | adults used channels averaging 10 m, selected against < 6 m; preferences | 1216 note; life history 807 | OK |
| 177-178 | NWT review's spawning and rearing class about 10 m | 1202, 1214; Table 1 | OK |
| 178 | Williston juveniles at sites 0.96-43 m wetted | 1272 | F10 |
| 179 | fry and yearlings seined in the 60-70 m Parsnip | 1271 | OK |
| 179-180 | yearlings favoured the larger, turbid Parsnip over clear tributaries | 1273 | OK |
| 180-181 | others place juveniles and fry in small tributaries or possibly mainstem margins | 1217, 1218, 1274 | OK |
| 181 | a constructed 3.0 m channel drew spawners | 1203 | OK |
| 181-183 | apart from the review's class, every other source small, rivers or both, no width | 1204-1213, 1270 | OK |
| 187-189 | two give a river's mean daily flow where fry caught: Table 12.9 (estimate thought low), Parsnip 142 (1985-1995) | 1278, 1279 | OK |
| 189 | partial-year means of Ingenika and Nation, 75.5 and 104.4 | 1280, 1281 | OK |
| 189-190 | day of peak spawning in a constructed channel 0.21 and 0.25 | 1224, 1225 | OK |
| 190-191 | Adsett mean through peak spawning 1.5 | 1276 | OK |
| 191 | 34 location-years, 0.096-33.90 | 1223 | OK |
| 191-192 | about 400 in the Fond du Lac, eggs found | 1226 | OK |
| 192-193 | Interior Alaska, many bog streams that go dry in late summer used for spawning | 1228 | OK |
| 193-194 | Adsett, fry reared through summer, below detection to about 2.2 | 1277 | OK |
| 194-195 | Sukunka pools with two-year-olds 1-15 and 21-65 at sampling | 1229, 1230 | OK |
| 199-200 | watershed scale: absent below 4th order, present and absent above; order predicted poorly | 1231 | OK |
| 200-201 | Stamford relay as fry rearing areas that appear centred in "e.g. 4th order and larger" tributaries | 1232 | F6 |
| 201-203 | and elsewhere as grayling that "appear more limited to cooler fifth order streams" (citing H&S 2014, Ballard and Shrimpton 2009) | 1233 | OK |
| 203 | neither original has a fifth-order statement | 1233 note | OK |
| 203-204 | Adsett, second order: grayling apparently spawned, fry reared through summer | 1283, 1284 | OK |
| 208 | evidence, not a proposal (#280) | none | OK |
| 208-209 | thin where link needs it most | summary | OK |
| 209 | no source sets a gradient, width or flow value as a limit | gradient, width, discharge rows; 1186, 996-1000 | OK (Hubert's HSI edges are depth and velocity) |
| 209-211 | values where found, a review's class and selected widths; large Williston rivers, rest across BC, NT, Alaska, Alberta, Saskatchewan, Montana | valued rows of the three variables | OK |
| 211-213 | capture records summer electrofishing on small and mid-sized streams, most captures on river polygons, 175 spring visits, none aimed at spawning, no FISS yet (#281) | lines 56-60, 123-125 | OK |
