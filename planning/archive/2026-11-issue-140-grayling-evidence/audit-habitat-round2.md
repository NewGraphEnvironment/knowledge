# Meaning audit, round 2: `research/grayling_habitat.md` (literature claims and summaries)

Scope: "In plain words" (lines 9-39), "What the literature says about each of link's values" (lines 144-201) and
"What this is not" (lines 203-210), as they stand after round 1's fixes (`fixes-habitat-round1.md`). Rows read: every
GR row 1190-1304 (quote, note, kind, stage, region, value) and the 30 GR rows outside it (903-925, 996-1000, 1185,
1186) for the "no source" quantifiers; `research/grayling_life_history.md` In brief and the spawning, fry, summer and
winter sections (lines 22-52, 285-527, 559-930). Source text checked where a claim rests on wording: Stewart et al.
1982 pp. 27, 31, 44 (text lines 4237-4241, 4592-4601, 6314-6323), Den Beste and McCart 1984 p. 21 (lines 1047-1057),
Hawkshaw and Shrimpton 2014 p. 25 (lines 1895-1932), Cowie and Blackman 2004 p. 9 (lines 539-553), Blackman 2004
p. 2 (lines 147-153), House 2021 pp. 100-105 (lines 3600-3625, 3727-3761), Tack 1980 p. 18 (lines 745-751), and
`data/gr_use.csv` (`any_fish_caught`, channel width). Capture-table and segments-log numbers were checked only where a
sentence of the three sections restates them.

18 findings. Severity: **M** = changes what a reader proposing the baseline would take from the sentence; **m** =
wording, hedge, place or citation completeness. Several sit inside round 1's fixes (F1, F2, F3, F8, F9, F11, F14,
F16, F17).

## Findings

### F1 (M) line 18: "juveniles and adults feed through summer in clear streams and rivers" (inside round 1's F1 fix)

"Clear" holds for adults: Hagen et al. 2026 p. 7, "Clear stream reaches appear to be critical for summer rearing of
subadult and adult Arctic Grayling" (life history line 746); p. 26, subadults and adults "migrate upstream to find
clear and cool" water (line 741). For juveniles the Williston evidence goes the other way: Parsnip yearlings "did not
appear to rear in any significant numbers in the clear tributary streams but favoured the larger and more turbid
Parsnip River" (row 1273; life history lines 43-44, 713, the file's own In brief: "yearlings appear to rear in the
turbid Parsnip mainstem rather than the clear tributaries"), and Hagen et al. 2026 p. 26 puts fry and juveniles
downstream in warmer water, not clear water. Only the range-wide review sentence (1194, 1195, 1197, "all life history
stages ... require clear") says clear for juveniles. The sentence's parenthesis then says "in the Williston studies
juveniles in larger streams", which a reader takes as larger clear streams.
**Fix:** "adults feed through summer in pools of clear streams and rivers, and juveniles in a range of streams (in the
Parsnip, yearlings in the turbid mainstem rather than the clear tributaries ...)".

### F2 (M) lines 19-20: "in the Williston studies juveniles in larger streams ..., while reviews and Adsett Creek in the Liard also place them in small tributaries"

The split by source is wrong. Hagen et al. 2026 p. 26 is a Williston statement (its summary of the 85 critical-habitat
segments across the Williston core areas; row 1198, region "Upper Peace (Williston Reservoir watershed)"; life
history lines 736-741): "Fry and juveniles remain downstream where low gradient river margins, small tributaries, and
off channel habitats provide warmer water". Hagen et al. 2026 p. 7 adds, for the Williston, that summer sampling may
underestimate smaller tributaries (life history line 852). So the Williston studies themselves are split, not set
against the reviews. And "them" (juveniles and adults) fits the reviews for juveniles only: 1217 is yearlings and
juveniles, 1218 fry; no review row places adults in small tributaries (Stewart et al. 2007 p. 15 has adults return to
larger rivers or lakes after spawning, life history line 517). Adults in a small tributary rest on Adsett Creek alone
(1266, 1267, 1284).
**Fix:** "(in the Williston, Hawkshaw and Shrimpton found juveniles in larger streams, none below fourth order, while
Hagen et al. 2026 place fry and juveniles in river margins, small tributaries and off-channel habitat; reviews also put
juveniles in small tributaries, and in Adsett Creek in the Liard yearlings and adults spent the summer in a
second-order stream)".

### F3 (M) lines 24 and 156-159: "three name steeper reaches as where use or spawning ends" / "Three sources say steeper reaches end use"

Inside round 1's F3 fix, three faults:
- **1266 loses its second cause.** The source (p. 44, text lines 6315-6318): yearling and older grayling used
  "virtually the entire habitable portion" to about km 18; "beyond this point, fish habitat become marginal as a result
  of rapidly increasing gradient and lack of riparian cover as result of a forest fire". Line 157 gives gradient alone.
  Row 1266's note keeps both.
- **1255 does not say spawning ends.** Den Beste and McCart p. 21 (text lines 1050-1055): "most spawning occurs in
  lakes, clear side channels, and tributary streams where the stream gradient and scour are less severe", set against
  the upper Atigun mainstem below a sediment source. It says where most spawning is, relative, with scour beside
  gradient; it is not a statement that steeper reaches end spawning. Line 159 words it correctly; the lead-ins at lines
  24 and 156 ("end") do not.
- **The count misses a Williston statement.** Hawkshaw and Shrimpton 2014 p. 25 (text lines 1905-1911), the page of
  row 1264: grayling are absent from all the major watersheds east of the reservoir, "composed primarily of cascades and
  canyons ... terrain that creates high velocity from steep gradients", and "it has been suggested that this is likely
  the reason" (Williamson and Zimmerman 2004, with McPhail and Lindsey 1970 and Cowie and Blackman 2003 on a preference
  for shallower gradient). Life history line 840 quotes the absence but not the reason. It is a relayed suggestion,
  hedged, but it is the one gradient statement about where grayling are absent in the Williston itself.
**Fix:** line 24: "No source gives a gradient value as a limit, though some tie steeper reaches to less use or less
spawning." Lines 156-159: "Four sources tie steeper reaches to less use: in Adsett Creek habitat for yearlings and older
became marginal upstream with rapidly increasing gradient and loss of riparian cover after a fire (1266); steeper
boulder and cobble reaches limit spawning in the Table and Anzac (Cowie and Blackman 2003 ...); in the Atigun most
spawning lay in lakes, side channels and tributaries where gradient and scour are less severe (1255); and Hawkshaw and
Shrimpton relay the suggestion that the steep canyons east of the Williston Reservoir are why grayling are absent from
its eastern watersheds (Hawkshaw and Shrimpton 2014, p. 25)."

### F4 (m) lines 160-161: the Osilinka sentence drops the authors' frame and half the contrast (1265)

"Osilinka fry stopped short of the river's mouth, slightly steeper with larger substrate, but were also absent from
some low-gradient reaches where they were expected". The source (Cowie and Blackman 2004 p. 9, text lines 540-547)
opens the sentence "In the Osilinka River, where impacts have been fairly severe", after suggesting the restricted
distributions "may be a function of the natural range being restricted in systems where grayling populations have been
impacted"; the low-gradient reaches are "low gradient fine substrate" ones, which matters because the occupied 38 km
reach is the one with more fines (1257, 1258). The same passage says the Ingenika fry reached further upstream than
gradient and substrate elsewhere led the authors to expect (row 1265's note), another point against gradient as the
limit, uncited.
**Fix:** "and Osilinka fry, in a river the authors call fairly severely impacted, stopped short of the slightly steeper,
coarser river mouth but were also absent from some low-gradient, fine-substrate reaches where they were expected, while
Ingenika fry reached further upstream than gradient and substrate led the authors to expect (1265)."

### F5 (m) lines 154-155: 1196 is not a review

"The reviews describe grayling habitat as "medium" or "relatively low" gradient (1190, 1193-1197)". 1196 is Stamford et
al. 2017 p. 16 on Williston fry-rearing areas, relaying Hawkshaw et al. 2013, and its row note says the report of that
study found gradient a poor predictor of juvenile occurrence and caught juveniles at sites on segments of 0-6.96 %. It
is a Williston relay, not a range-wide description.
**Fix:** cite 1190, 1193-1195, 1197 for the reviews, and 1196 separately: "Stamford et al. relay the Williston study
as placing fry rearing in low-gradient middle reaches (1196), though its report found gradient a poor predictor (1263,
1264)."

### F6 (m) lines 154-161: the gradient paragraph leaves out statements that point either way

Not cited, and bearing on whether "low gradient" is the whole picture:
- Stamford et al. 2017 p. 13: "Access to pool habitat, especially, within clear stream reaches of moderate gradient
  appears to be a key habitat requirement for adult and subadult Arctic Grayling within the Williston watershed" (life
  history line 775);
- Hagen and Stamford 2023 p. 51: "streams of the Parsnip River watershed with extensive sections of low-gradient
  meanders have fewer adult grayling", an observation not yet analysed (life history lines 786-790);
- the site studies' "low" or "gentle" gradient statements, 1191 (Red Rock Creek), 1192 and 1199-1200 (Little Nahanni
  young-of-year found only in low-gradient channels), 1198 (Hagen et al. 2026 p. 26, fry and juveniles in low-gradient
  river margins).
**Fix:** after the Adsett and Osilinka sentence: "For Williston adults, Stamford et al. call pools in clear reaches of
moderate gradient a key need (2017, p. 13), and Hagen and Stamford observe fewer adults in Parsnip streams with long
low-gradient meanders (2023, p. 51); young-of-year in the Little Nahanni were found only in low-gradient channels (1199)."

### F7 (m) lines 165-166: "The one set measured at sites is Hawkshaw and Shrimpton's"

1263 is "average gradient of the TRIM stream segment holding each of the 27 sites" (row note; Appendix F), a map
value for the segment, not a measurement at the site. And "the one set" by site or fish position does not hold across
stages: 1268 and 1269 are the gradients of each radio-tagged fish's overwintering location, also from 1:20,000 maps.
**Fix:** "The one rearing set given site by site is Hawkshaw and Shrimpton's: the map segments holding 27 sites with
juveniles run from 0 to 6.96 % (mean 1.22 %), against 0 to 12.55 % at the 30 without (1263)."

### F8 (m) lines 30, 33-34, 179-180, 197-198: hedges dropped from carried or fixed sentences

- Line 30, plain words: "in Alaska selected channels 1-8 m wide"; 1215 is "appear to select" (the literature section,
  line 174, keeps "appeared").
- Line 34, plain words: "Two give a river's mean daily flow ... (12.9 and 142 m³/s)"; 12.9 is Langston's estimate,
  which "he suggested ... could be low" (Blackman 2004 p. 2, text lines 151-152); line 185-186 keeps it, the summary
  does not.
- Line 180: "other sources place juveniles and fry ... along mainstem margins (... 1274)"; 1274 is "may be the most
  important rearing location", inferred from fry carried downstream and young-of-year caught in the mainstem but not
  the tributaries.
- Line 197-198: "Stamford et al. relay the study as fry rearing in "e.g. 4th order and larger" tributaries (1232)";
  the source: populations "appear to be centered around fry rearing areas" in such tributaries (1232's note:
  "hedged ('appear')").
**Fix:** "appeared to select"; "(an estimated 12.9 m³/s, which its author thought could be low, and 142 m³/s)"; "and
possibly along mainstem margins"; "as fry rearing areas that appear centred in ...".

### F9 (m) line 31: "most sources call spawning streams small, with no width"

Over the spawning width rows' sources (1204-1213, 1270; eight sources), six call some spawning streams small, but three
of those six also name mainstem or large rivers in the same passage (1204 "mainstem rivers, large and small
tributaries", 1207 large river habitats in the Parsnip, Anzac and Table, 1209 "throughout the main stem and lower ends
of major tributaries in large unsilted rapid runoff rivers"), and two name only rivers (1213, 1270). The life-history
file adds the Sukunka, where newly emerged fry "suggested extensive use of the mainstem river and only limited spawning
in the tributaries" (line 424). Read beside a 4 m spawning minimum, "most ... small" tilts the sources; the literature
section's wording (line 181, "calls spawning streams small, names rivers, or both") is the accurate one.
**Fix:** "sources call spawning streams small, name large rivers, or both, with no width".

### F10 (m) line 32: "The capture records are lowest under 2 m, where few fish of any kind were caught"

The measure is visits that caught any fish, not numbers of fish: under 1.5 m 17 of 88 visits and at 1.5-2 m 14 of 106
caught any fish (19 % and 13 %), against 323 of 481 at 4-8 m (`data/gr_use.csv`, `any_fish_caught`).
**Fix:** "where few visits caught fish of any kind".

### F11 (m) lines 34-35 and 189-190: Tack's bog streams lose their place and gain a reason

Tack 1980 p. 18 (text lines 746-748): "Most bog streams of interior Alaska are utilized for spawning by Arctic
grayling. Even many bog streams that become dry during late summer will be used for spawning." Line 35 drops
"Interior Alaska" and "many", so it reads range-wide; line 190 says "bog streams too small to keep flowing through
late summer", but Tack gives no reason for the drying (the "too small" is row 1228's note; 1208, a separate passage,
calls bog streams small).
**Fix:** line 35: "and in Interior Alaska even many bog streams that dry up in late summer are used for spawning";
line 190: "in Interior Alaska, even many bog streams that go dry in late summer are used for spawning (1228)".

### F12 (m) line 37: "Most grayling in the capture records ... are in large rivers"

The count is visits: 882 of the 1,231 visits in grayling's range that caught grayling (line 60), not fish. (Line 209,
"most grayling captures", reads correctly as captures.)
**Fix:** "Most visits that caught grayling, and nearly all the length of ...".

### F13 (m) line 26: "The capture records do not fall at 2.49 % or 3.49 %"

The records do not fall; the catch rate does not. A number says what it is of.
**Fix:** "The catch rate in the capture records does not fall at 2.49 % or 3.49 %".

### F14 (m) line 21: "some young fish in pools of small tributaries" (inside round 1's F2 fix)

Two passages merged into one: in the Sukunka, "some two year olds remain in the deep tributary pools overwinter"
(life history line 888; the tributaries' size is not given), and in Adsett Creek's study, "tributaries similar in size
to (and including) Adsett Creek were utilized only by overwintering underyearling and yearling grayling" (line 896; no
pools named), which the authors call not obligatory (line 894).
**Fix:** "some young fish in small tributaries like Adsett Creek and in deep tributary pools of the Sukunka".

### F15 (m) lines 180-181: "every other source calls spawning streams small, names rivers, or both, with no width"

The spawning width rows also hold 1202, Stewart et al. 2007's ~10 m class (`spawn_channel_width_min` = 10, `expert`),
which line 177 cites; "every other" after 1203 excludes only the constructed channel.
**Fix:** "and apart from the review's class, every other source calls ...".

### F16 (m) lines 148-150: the kinds named are still not all the kinds used (inside round 1's F17 fix)

Round 1 counted `max_obs` 1 (1246, Sukunka fry in broken water to 50 cm); the fix left it out. And "a value where
grayling were found ... is coded `dist`" does not describe three `dist` rows: 1231 (the order below which juveniles
were absent), 1232 and 1233 (Stamford's relayed "e.g. 4th order and larger" and "fifth order").
**Fix:** "... a statement with no value `qual`, and the most a source saw them use `max_obs`; three stream-order `dist`
rows are a class bound and two relays (1231-1233)."

### F17 (m) lines 206-208: "the values are where grayling were found, many of them large Williston rivers and the rest sites and reaches across BC, the Northwest Territories, Alaska and Alberta" (inside round 1's F15 fix)

- Places: the valued rows also include Saskatchewan (1226, the Fond du Lac River's ~400 m³/s at spawning, cited at
  lines 31 and 189), Montana (1227, Red Rock Creek's annual peaks) and the multi-region 1223 (NT, Montana, Alaska,
  Alberta). Round 1's count listed both; the fix dropped them.
- Kinds: Stewart et al.'s ~10 m class (1202, 1214, `expert`) and Den Beste and McCart's selected widths (1215, 1216,
  `pref`) are not where grayling were found.
**Fix:** "the values are where grayling were found, or a review's class and widths fish selected, many of them large
Williston rivers and the rest sites and reaches across BC, the Northwest Territories, Alaska, Alberta, Saskatchewan and
Montana."

### F18 (m) line 199: "(1233, citing this report and Ballard and Shrimpton 2009)"

"This report" has no antecedent in the sentence ("the study" is Hawkshaw and Shrimpton's), and in a research file it
reads as this file. Row 1233 cites Hawkshaw and Shrimpton 2014.
**Fix:** "(1233, citing Hawkshaw and Shrimpton 2014 and Ballard and Shrimpton 2009)".

## Enumeration: every sentence in the three sections

Verdicts: OK = each cited row or page says it, and its quantifier holds over the GR rows of its variable and stage and
the life-history file; F*n* = see finding; out of scope = a statement about link's configuration.

| line | sentence (abridged) | rows / pages cited | verdict |
|---|---|---|---|
| 11-12 | link's rearing and spawning values | none (link) | out of scope |
| 12-13 | numbers set to get the work started | none | out of scope |
| 13-14 | this file gathers, does not propose (#280) | none | OK |
| 16-17 | spawn in spring, in tributaries and mainstem rivers | life history 22-36, 285-449 | OK |
| 17-18 | fry rear first in slow shallow margins, in some streams move to deeper faster water | life history 39-42, 559-637 | OK (Table and Anzac fry stayed shallow; "in some streams" covers it) |
| 18 | juveniles and adults feed through summer in clear streams and rivers | life history 701-857 | F1 |
| 19 | Williston: juveniles in larger streams, none below fourth order | 1231; life history 820-833 | OK (absent from study streams below order 4) |
| 19-20 | Williston adults in pools of clear tributaries | life history 736-775 | OK |
| 20 | reviews and Adsett Creek place them in small tributaries | 1217, 1218, 1266, 1267, 1284; life history 741 | F2 |
| 20-21 | winter mostly in larger rivers and lakes | life history 46-49, 859-930 | OK |
| 21 | some young fish in pools of small tributaries | life history 886-896 | F14 |
| 23 | lead-in | none | OK |
| 24 | no source gives a gradient value as a limit | 1186, 1190-1201, 1255-1269; 903-925 | OK |
| 24 | three name steeper reaches as where use or spawning ends | 1255, 1266, Cowie and Blackman 2003 p. 9 | F3 |
| 24-26 | gradients given: rivers and reaches at or under 2 %; 27 Williston sites 0-6.96 % (mean 1.22) | 1201, 1257-1263, 1268, 1269 | OK (all ten valued gradient rows; largest river or reach value 1261's 1-2 %) |
| 26-28 | capture records: no fall at 2.49 or 3.49 %; 2 of 152 at 5.49-8 %; too few steeper | table lines 70-78 | F13 (wording); numbers match |
| 29 | no source gives a width minimum | 1202-1218, 1270-1274 | OK (1202, 1214 a class; 1216's < 6 m a preference) |
| 29-30 | juveniles from about 1 m upward | 1272 (0.96-43 m), 1271 | OK |
| 30 | in Alaska selected channels 1-8 m | 1215 | F8 (hedge) |
| 30-31 | spawning seen in a 3 m constructed channel; eggs in a large Saskatchewan river | 1203, 1226, 1242 | OK |
| 31 | most sources call spawning streams small, no width | 1204-1213, 1270 | F9 |
| 31-32 | Williston large-river spawning inferred from tagged fish and fry | 1207, 1213, 1270; life history 341-399 | OK |
| 32 | capture records lowest under 2 m | table lines 90-92 | OK |
| 32 | where few fish of any kind were caught | `data/gr_use.csv` any_fish_caught | F10 |
| 33 | no source gives a MAD limit | 996-1000, 1223-1230, 1276-1282 | OK |
| 33-34 | two give a river's mean daily flow where fry were caught, 12.9 and 142 | 1278, 1279 | OK; F8 (12.9 an estimate thought low) |
| 34 | other flows of other kinds, below detection and 0.1 to about 400 | 1223-1227, 1229, 1230, 1276, 1277, 1280-1282 | OK (0.096 to 400; 1000's Martin Creek 10-15 inside) |
| 34-35 | bog streams that dry up in late summer used for spawning | 1228 | F11 |
| 35 | capture records lowest under 0.021 | table line 109 | OK |
| 37-38 | most grayling in capture records, nearly all segment length, in large rivers | lines 60-64, 136-137 | F12 (visits); 93 % OK |
| 38-39 | small-stream thresholds where evidence thinnest | summary | OK |
| 146-148 | 115 GR rows 1190-1304, verbatim, checked, audited | 1190-1304 | OK (115 GR rows, every one with a quote) |
| 148 | rows cited by data row | none | OK |
| 148-150 | most say where found; dist, pref, expert, qual | kinds of 1190-1304 (dist 54, qual 47, pref 11, expert 2, max_obs 1) | F16 |
| 154-155 | reviews say "medium" or "relatively low" gradient, no number | 1190, 1193-1197 | F5 (1196) |
| 155 | one sentence passed Hagen 2015 → Stamford 2017 → Hagen 2026 | 1194, 1195, 1197 | OK |
| 156-157 | three sources say steeper reaches end use; Adsett marginal with gradient | 1266 | F3 |
| 157-158 | Table and Anzac: steeper boulder and cobble reaches limit spawning | Cowie and Blackman 2003 p. 9; life history 410 | OK |
| 158-159 | Atigun: most spawning where gradient and scour less severe | 1255 | OK as worded; F3 for the lead-in |
| 159-160 | Adsett yearlings and older densest in steep sections | 1267 | OK (densest per unit habitat is reported; the hedge is on "preferred") |
| 160-161 | Osilinka fry short of the steeper mouth, absent from some low-gradient reaches | 1265 | F4 |
| 154-161 | (paragraph) | 1191, 1192, 1198-1200; life history 771-790 | F6 |
| 163-165 | values of rivers and reaches with fry and juveniles: 0.1, 0.2, 0.3, < 0.5, 1-2 % | 1258, 1259, 1262, 1260, 1261 | OK |
| 165-166 | the one set measured at sites: 27 sites 0-6.96 %, 30 without 0-12.55 % | 1263 | F7 (values OK) |
| 166-168 | watershed gradient did not predict; most watersheds max < 2.6 %, little contrast | 1264; p. 25 text 1921-1927 | OK ("indicating a lack of watersheds with overall high gradients") |
| 168-169 | for spawning the only value is the Osilinka reach, inferred from fry | 1257 | OK (only valued spawning gradient row; the Sukunka 0.5 % holding channel held four trapped adults) |
| 169-170 | Adsett: most spawning generally toward tails of long runs, particularly runs above steep gradients | 1256; p. 31 text 4593-4595 | OK (anchor: a run's tail is its downstream end, so a run "preceding" a steep section lies above it) |
| 170 | Little Smoky overwintering 0.08-0.33 % | 1201, 1268, 1269 | OK (fish 28's 0.31 % inside) |
| 174 | no source gives a minimum | width rows | OK |
| 174-176 | Alaska juveniles appeared to select 1-8 m, against > 14 m; adults 10 m, against < 6 m; preferences | 1215, 1216; life history 807 | OK |
| 176-177 | NWT review's class about 10 m for spawning and rearing | 1202, 1214 | OK |
| 177-178 | Williston juveniles at sites 0.96-43 m wetted | 1272 | OK (presence is one grayling of any size) |
| 178 | fry and yearlings seined in the 60-70 m Parsnip | 1271 | OK |
| 178-179 | yearlings favoured the larger Parsnip over its clear tributaries | 1273 | OK |
| 179-180 | other sources: juveniles and fry in small tributaries or mainstem margins | 1217, 1218, 1274 | F8 (1274 hedge) |
| 180 | a constructed 3.0 m channel drew spawners | 1203 | OK |
| 180-181 | every other source small, rivers or both, no width | 1204-1213, 1270 | F15 (1202) |
| 185 | no source gives a MAD limit | discharge rows; 996-1000 | OK |
| 185-186 | Table 12.9 estimate thought low; Parsnip 142 over 1985-1995 | 1278, 1279; Blackman 2004 p. 2 | OK |
| 186-187 | partial-year means of the Ingenika and Nation, 75.5 and 104.4 | 1280, 1281 | OK |
| 187-188 | day of peak spawning in a constructed channel, 0.21 and 0.25 | 1224, 1225 | OK (0.21 an estimate; minor) |
| 188 | Adsett mean through peak spawning 1.5 | 1276 | OK |
| 188-189 | 34 location-years, 0.096-33.90 | 1223; House pp. 100, 104 | OK ("A total of 34 data sets") |
| 189 | about 400 in the Fond du Lac, eggs found | 1226 | OK |
| 189-190 | Interior Alaska bog streams too small to keep flowing used for spawning | 1228 | F11 |
| 190-191 | Adsett, fry reared through summer, below detection to about 2.2 | 1277 | OK |
| 191-192 | Sukunka pools with two-year-olds, 1-15 and 21-65 at sampling | 1229, 1230 | OK |
| 196-197 | Hawkshaw: absent below 4th order, present and absent above; order predicted poorly | 1231 | OK |
| 197-198 | Stamford relays the study as fry rearing in "e.g. 4th order and larger" tributaries | 1232 | F8 (hedge) |
| 198-199 | and as grayling that "appear more limited to cooler fifth order streams" | 1233 | OK; F18 ("this report") |
| 199-200 | neither original has a fifth-order statement | 1233 note | OK |
| 200-201 | Adsett, second order: grayling apparently spawned, fry reared through summer | 1283, 1284 | OK |
| 205 | evidence, not a proposal (#280) | none | OK |
| 205-206 | thin where link needs it most | summary | OK |
| 206 | no source sets a gradient, width or flow value as a limit | all three variables' rows; 1186, 996-1000 | OK |
| 206-208 | values where found; many large Williston rivers; rest across BC, NT, Alaska, Alberta | 31 valued rows | F17 |
| 208-210 | capture records summer, small and mid-sized, most captures on river polygons, 175 spring visits, none aimed at spawning, no FISS yet (#281) | lines 60-64, 128-129 | OK |
