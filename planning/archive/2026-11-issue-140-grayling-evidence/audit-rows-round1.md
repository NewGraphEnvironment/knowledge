# Meaning audit, round 1: grayling rows (data rows 1190-1254)

Every one of the 65 rows was read against its page: the text layer (`txt/<key>.txt`, `.layout.txt`), page images
rendered from the PDF where a unit or glyph was in doubt (Cannings and Ptolemy 1998 p. 48; Stuart and Chislett 1979
p. 41), `pdftotext` of the OCR'd Stuart and Chislett and Hubert PDFs, and `data/rag/ocr/3af6c0ba…txt` (Hubert).
Existing GR rows (data rows 903-925, 996-1000, 1185-1186) were checked for duplicates: none of the 65 duplicates
one (same key, page, value and stage).

14 findings. None changes a value, unit, species or life stage; they are a wrong note (one), hedges dropped, a missing
`cited_source`, region and scale fields that say more or other than the page, and two relay chains whose shared
original the notes should name.

## Findings

### 1. Data row 1215, `note`: the hedge "appeared" is dropped
- **Page** (Stewart et al. 2007, p. 19): "They appeared to select for channels that are 1 to 8 m wide and against
  channels wider than 14 m (Den Beste and McCart 1984)."
- **Wrong:** the note says "channels 1 to 8 m wide selected for", stated as a finding.
- **Fix:** "Juveniles (age 1 and older, before maturity) appeared to select for channels 1 to 8 m wide (hedged in the
  source). Width type not stated. The upper avoidance is the next row."

### 2. Data row 1216, `note`: hedge dropped, and "selected against" is avoidance, not a limit
- **Page:** the same sentence as finding 1.
- **Wrong:** the note says "Juveniles selected against channels wider than 14 m" without "appeared". With
  `bound = max` the row reads as a limit, but the source reports use below availability above 14 m, not absence.
- **Fix:** keep `bound = max` (as the CH CART-split rows do, data row 44) and write: "Juveniles appeared to select
  against channels wider than 14 m (hedged): use below availability, not absence, so not a limit of use. No parameter:
  the model has no maximum rearing width. Adults in the same streams averaged 10 m and selected against channels
  under 6 m (p. 21)."

### 3. Data row 1229, `note`: the unit doubt is settled by the scan; say so
- **Page** (Stuart and Chislett 1979, p. 41, page image of `XDKIU3UA/stuart_chislett_1979_grayling_sukunka.pdf`,
  PDF page 47): "Flows in the tributary and sidechannel pools were 1 - 15 m³/s and the two year olds utilized the
  full depth and width of the pool". The superscript 3 is printed clearly; only the OCR loses it.
- **Wrong:** the note rests the unit on the OCR's "m?/s" and Appendix 3's column head, leaving the drafter's doubt
  (notes: "this rests on reading a lost superscript") open. The scan settles it: `m3/s` is right.
- **Fix:** replace the last sentence with "The scan prints 'm³/s'; the OCR reads it 'm?/s' and 'pools' as 'poole',
  so the quote skips both. Appendix 3 heads the column 'Flow (m3/s)'."

### 4. Data row 1230, `note`: says the scan prints "m/s"; it prints "m³/s"
- **Page** (same image): "Summer flows in the Sukunka mainstem pools ranged from 21 - 65 m³/s with the 2+ grayling
  occupying the shallower downstream end and the sides of the pool."
- **Wrong:** "the scan prints 'm/s' here for the same flow unit (superscript lost)". The scan prints the superscript;
  the OCR text layer (`21 - 65 m/s`) is what lost it.
- **Fix:** "...not MAD. The scan prints 'm³/s'; the OCR text drops the superscript ('m/s'), which the quote keeps as
  read."

### 5. Data row 1233, `note`: the held original cited for "fifth order" says nothing of stream order
- **Page** (Stamford et al. 2017, p. 7): "grayling appear more limited to cooler fifth order streams (Ballard and
  Shrimpton 2009; Hawkshaw and Shrimpton 2014)".
- **Original held:** `ballard_shrimpton2009Summaryreport` (`XQNJAC2D/…report_no_337…pdf`). Its whole text has no
  stream-order statement ("order" occurs only as "in order to"); the nearest is p. 45: "It would appear that grayling
  distributions are limited to cooler waters as fish were not captured in water recorded to be greater than 14.5 oC
  in the Omineca Region." So "fifth order" rests on Hawkshaw and Shrimpton 2014 alone, which is not held, and which
  Hagen et al. 2026 (p. 7, data row 1231) relays as "4th order and larger tributaries".
- **Fix:** add to the note: "Of the two sources cited, Ballard and Shrimpton 2009 (held) says only that grayling
  'appear ... limited to cooler waters' (p. 45) and gives no stream order; the order rests on Hawkshaw and Shrimpton
  2014 (not held), which Hagen et al. 2026 p. 7 (data row 1231) relays as '4th order and larger'."

### 6. Data rows 1231 and 1232, `note`: one claim passed between reports, relayed two ways
- **Pages:** Hagen et al. 2026 p. 7 "occupied sites being characterized as locations in 4th order and larger
  tributaries with stable, cool water temperatures (Hawkshaw and Shrimpton 2014)"; Stamford et al. 2017 p. 16
  "larger (e.g. 4th order and larger) tributaries where stable ambient summer temperatures hover close to16oC
  (Hawkshaw et al. 2013)"; and the same Stamford report p. 7 (data row 1233) "cooler fifth order streams (…;
  Hawkshaw and Shrimpton 2014)".
- **Wrong:** neither note says the three rows rest on one Hawkshaw study (a 2013 report and its 2014 paper, by the
  shared first author and topic, fry rearing temperature in the Williston), so they read as three independent
  observations, two of them agreeing. Row 1232's `bound = min` also reads more than "e.g." gives: the page offers 4th
  order as an example of "larger".
- **Fix:** add to both notes: "One claim with data rows 1231, 1232 and 1233: Hawkshaw et al. 2013 / Hawkshaw and
  Shrimpton 2014 (not held), relayed as '4th order and larger' (Hagen 2026 p. 7, Stamford 2017 p. 16) and as 'fifth
  order' (Stamford 2017 p. 7)." In row 1232's note, add: "4th order is given as an example ('e.g.') of 'larger', not
  as a stated minimum."

### 7. Data row 1234, `cited_source` blank; the stage is narrower than the page
- **Page** (Cutting et al. 2018, p. 12907): "During the non‐spawning seasons, adfluvial grayling swim downstream and
  reside in Upper Red Rock Lake, which is a shallow (<2 m) postglacial depression encompassing 893 ha where ice covers
  the lake for 7 months a year (Cutting et al., 2016)."
- **Wrong:** the sentence cites Cutting et al. 2016 for the lake's description; `cited_source` is blank. The row's
  `overwintering` covers half of "the non-spawning seasons" (summer feeding as well); the note says so, but not that
  the page names no age class.
- **Fix:** `cited_source` = `Cutting et al. 2016`. Note: "...where the adfluvial population lives outside the
  spawning season (summer and winter; no age class named); coded overwintering because the vocabulary has no
  residence stage. ..."

### 8. Data row 1207, `note`: "otolith" is not on the page
- **Page** (Hagen et al. 2026, Appendix B p. 6): "Recent microchemistry analyses of retrospective movements also
  suggest that significant proportions (e.g., 13-27%) of fry rearing in large river habitats (e.g., Finlay, Osilinka,
  Mesilinka) originated from spawning areas in tributaries (Stamford 2023 data on file)."
- **Wrong:** the note says "(otolith microchemistry, data on file)" and drops "suggest" and "e.g.".
- **Fix:** "The next sentence says microchemistry analyses 'suggest' that significant proportions (e.g. 13-27 %) of
  fry rearing in large rivers came from tributary spawning areas (Stamford 2023 data on file)."

### 9. Data row 1210, `region`: the statement is Scott and Crossman's general one, not a Williston account
- **Page** (Cannings and Ptolemy 1998, p. 49): "Fluvial grayling migrate from mainstem rivers to smaller
  rockbottomed tributaries prior to spawning (Scott and Crossman 1973)."
- **Wrong:** `region` "BC (Williston watershed population account)" places a statement the page attributes to a
  Canada-wide review (Scott and Crossman 1973) in the Williston watershed.
- **Fix:** `region` = "Range-wide (Scott and Crossman 1973), in a BC species account".

### 10. Data row 1238, `region`: "NT" is not what the page says
- **Page** (Stewart et al. 2007, p. 28, section 4.1.5 Physical disturbances): "Groundwater discharge areas may also
  be used by Arctic grayling for spawning as they provide a stable environment for egg incubation." The paragraph is
  general (the one before it is about Alberta's Wildhay River).
- **Wrong:** `region` "NT (review)".
- **Fix:** `region` = "Range-wide (review)", as data rows 1217 and 1219 code Stewart's general statements.

### 11. Data rows 1240, 1247, 1248, 1253, 1254, `scale`: a McPherson "site" is a 100 m surveyed reach, not a fish position
- **Page** (McPherson 2020, p. 23, methods): "one transect (stream bank to stream bank, perpendicular to the flow) was
  selected at the upstream extent of the site to record habitat data representative of the entire site. … At four
  equidistant points across the transect, water depth and velocity was measured … The mean depth and velocity was
  determined for each site." Sites are 100 m electrofishing sections (same page).
- **Wrong:** `scale = site`, which the vocabulary reserves for "a redd or microhabitat". These are means over a 100 m
  section where a life stage was caught (and its elevation), not where the fish sat; `reach` ("a surveyed reach") is
  the vocabulary's word for it. The notes are right ("range of site-mean depths (four points on one transect per
  100 m site)").
- **Fix:** `scale` = `reach` on all five rows; add to each note "describes the 100 m section, not fish positions".

### 12. Data row 1250, `note`: drops "generally" and "approximately"
- **Page** (House 2021, p. 74): "Arctic grayling were generally observed spawning in areas with mean velocities of
  approximately 0.32 m/s in both years." The same page gives the 2014 mean velocity of all measured available habitat
  as 0.32 m/s too.
- **Wrong:** note "Mean velocity at observed spawning positions in a constructed channel" states it as exact.
- **Fix:** "Approximate mean velocity ('generally', 'approximately') of areas where spawning was observed in a
  constructed channel, 2014 and 2015, from velocity/depth mapping. The 2014 mean of all measured available habitat
  was also 0.32 m/s (0.39 m/s in 2015), so the value does not separate spawning sites from what was available."

### 13. Data row 1252, `note`: drops "approximately"
- **Page** (Stamford et al. 2017, p. 8): "preferred habitats of newly-emerged grayling are shallow areas (approximately
  0.l m) of little or no flow (approximately 0.1 m/s) along the channel margin (Mathias et al. 1998; Blackman 2004)."
- **Wrong:** note "Newly emerged fry." gives no hint that the value is approximate (bound is blank, so the row reads
  as a point value).
- **Fix:** "Newly emerged fry, Parsnip River watershed: 'little or no flow (approximately 0.1 m/s)'. The depth is
  printed '0.l m' (letter l), so no depth row is written from it."

### 14. Data row 1220, `note`: "(next sentence)" is the same sentence
- **Page** (Hagen et al. 2015, pp. 15-16): "…migrate downstream to overwinter in larger streams (e.g. large turbid
  rivers that run clear during winter, such as the Parsnip River) that also provide overwintering habitat for subadult
  and adult grayling (Stamford et al. 2015)."
- **Fix:** "These rivers also hold overwintering subadults and adults (same sentence, continuing on p. 16)."

## Remarks that are not findings

- **Data rows 1202 and 1214** (Stewart Table 1, "~10 m", `kind = expert`, blank bound, `*_channel_width_min`): the
  coding is defensible (a review's habitat-class definition, flagged "not a limit" in the note, and precedent exists
  for valued rows with a blank bound, e.g. data rows 33 and 35). The risk is a reader of `spawn_channel_width_min`
  taking 10 m as a floor when the class is "Small (~10 m wide)": the note already says so.
- **Data row 1249**: the page image prints "0.5 to 1.0 m◊s⁻¹" (m s⁻¹ with an unrendered separator glyph), so `m/s`
  velocity is right; the note could say "the scan prints m s⁻¹" instead of "read as m/s".
- **Data rows 1194, 1195, 1197** are one claim relayed (Hagen 2015 → Stamford 2017 → Hagen 2026); rows 1195 and 1197
  say so. **Data rows 1220 and 1221**: Hagen 2015 p. 15 gives the fry clause of row 1221 too ("by fall they drift or
  move downstream into larger streams to overwinter (reviewed in Stamford et al. 2015)"), which Hagen 2026 p. 6
  attributes to Northcote 1993. **Data rows 1237, 1241, 1249** (Cannings, Adsett Creek) and existing data rows 903-904
  (Stewart p. 14) both trace to Stewart et al. 1982; different values, no duplicate.
- **Data row 1224**: the page gives the 2014 recession both as 0.10 m3/s (the row's sentence) and 0.12 m3/s (two
  sentences later); the note quotes the first. Harmless.
- **Statements on audited pages the rows do not hold** (for the drafter's completeness, not errors in a row):
  Hagen et al. 2026 Appendix B p. 6: "Small tributaries, particularly lake headed, also provide important rearing and
  overwintering areas for yearling stage (~100mm fork length) Arctic Grayling throughout the species' range", which
  qualifies the "larger streams" overwintering rows 1219-1222, and "extensive overlap between juveniles and fry rearing
  in low gradient reaches in large rivers" (a rearing-gradient qual). Hubert et al. 1985 (OCR, the habitat section
  before p. 5): "During winter Arctic grayling generally reside in large streams or deep holes in smaller streams
  (Nelson and Wojcik 1953)". Stamford et al. 2017 p. 8: fry "rear during their first summer in locations with similar
  habitat characteristics (i.e. low gradient, stable summer temperatures, located in middle reaches of larger
  tributaries; Hawkshaw…)", the same Hawkshaw relay as finding 6.

## Every row

| data row | key, page | variable / stage | verdict |
|---|---|---|---|
| 1190 | stewart_etal2007 p. 3 | gradient / spawning | ok |
| 1191 | cutting_etal2018 p. 12907 | gradient / spawning | ok |
| 1192 | mcpherson2020 p. 54 | gradient / spawning | ok |
| 1193 | stewart_etal2007 p. 3 | gradient / rearing | ok |
| 1194 | hagen_etal2015 p. 15 | gradient / rearing | ok |
| 1195 | stamford_etal2017 p. 7 | gradient / rearing | ok |
| 1196 | stamford_etal2017 p. 16 | gradient / rearing | ok |
| 1197 | hagen_etal2026 p. 7 | gradient / rearing | ok |
| 1198 | hagen_etal2026 p. 26 | gradient / rearing | ok |
| 1199 | mcpherson2020 p. 30 | gradient / rearing | ok |
| 1200 | mcpherson2020 p. 54 | gradient / rearing | ok |
| 1201 | stewart_etal2007 p. 6 | gradient / overwintering | ok |
| 1202 | stewart_etal2007 p. 3 | channel_width / spawning | ok (remark) |
| 1203 | house2021 p. 71 | channel_width / spawning | ok |
| 1204 | hagen_etal2015 p. 16 | channel_width / spawning | ok |
| 1205 | hagen_etal2015 p. 55 | channel_width / spawning | ok |
| 1206 | hagen_etal2026 p. 6 | channel_width / spawning | ok |
| 1207 | hagen_etal2026 p. B-6 | channel_width / spawning | finding 8 |
| 1208 | tack1980 PDF p. 18 | channel_width / spawning | ok |
| 1209 | tack1980 PDF p. 29 | channel_width / spawning | ok |
| 1210 | cannings_ptolemy1998 p. 49 | channel_width / spawning | finding 9 |
| 1211 | whyte_etal1997 p. 5-2 | channel_width / spawning | ok |
| 1212 | hubert_etal1985 p. 5 | channel_width / spawning | ok |
| 1213 | martins_etal2022 p. 3 | channel_width / spawning | ok |
| 1214 | stewart_etal2007 p. 3 | channel_width / rearing | ok (remark) |
| 1215 | stewart_etal2007 p. 19 | channel_width / rearing | finding 1 |
| 1216 | stewart_etal2007 p. 19 | channel_width / rearing | finding 2 |
| 1217 | stewart_etal2007 p. 18 | channel_width / rearing | ok |
| 1218 | hubert_etal1985 p. 5 | channel_width / rearing | ok |
| 1219 | stewart_etal2007 p. 18 | channel_width / overwintering | ok |
| 1220 | hagen_etal2015 p. 15 | channel_width / overwintering | finding 14 |
| 1221 | hagen_etal2026 p. 6 | channel_width / overwintering | ok |
| 1222 | martins_etal2022 p. 32 | channel_width / overwintering | ok |
| 1223 | house2021 p. 104 | discharge / spawning | ok |
| 1224 | house2021 p. 74 | discharge / spawning | ok |
| 1225 | house2021 p. 74 | discharge / spawning | ok |
| 1226 | house2021 p. 80 | discharge / spawning | ok |
| 1227 | cutting_etal2018 p. 12907 | discharge / spawning | ok |
| 1228 | tack1980 PDF p. 18 | discharge / spawning | ok |
| 1229 | stuart_chislett1979 p. 41 | discharge / rearing | finding 3 |
| 1230 | stuart_chislett1979 p. 41 | discharge / rearing | finding 4 |
| 1231 | hagen_etal2026 p. 7 | stream_order / rearing | finding 6 |
| 1232 | stamford_etal2017 p. 16 | stream_order / rearing | finding 6 |
| 1233 | stamford_etal2017 p. 7 | stream_order / rearing | finding 5 |
| 1234 | cutting_etal2018 p. 12907 | lake_area / overwintering | finding 7 |
| 1235 | hagen_etal2015 p. 16 | substrate / spawning | ok |
| 1236 | stewart_etal2007 p. 14 | substrate / spawning | ok |
| 1237 | cannings_ptolemy1998 p. 48 | substrate / spawning | ok |
| 1238 | stewart_etal2007 p. 28 | groundwater / spawning | finding 10 |
| 1239 | stewart_etal2007 p. 3 | groundwater / overwintering | ok |
| 1240 | mcpherson2020 p. 32 | elevation / rearing | finding 11 |
| 1241 | cannings_ptolemy1998 p. 48 | depth / spawning | ok |
| 1242 | house2021 p. 80 | depth / spawning | ok |
| 1243 | stewart_etal2007 p. 17 | depth / rearing | ok |
| 1244 | stewart_etal2007 p. 17 | depth / rearing | ok |
| 1245 | stewart_etal2007 p. 6 | depth / rearing | ok |
| 1246 | stuart_chislett1979 p. 36 | depth / rearing | ok |
| 1247 | mcpherson2020 p. 32 | depth / rearing | finding 11 |
| 1248 | mcpherson2020 p. 32 | depth / rearing | finding 11 |
| 1249 | cannings_ptolemy1998 p. 48 | velocity / spawning | ok (remark) |
| 1250 | house2021 p. 74 | velocity / spawning | finding 12 |
| 1251 | house2021 p. 80 | velocity / spawning | ok |
| 1252 | stamford_etal2017 p. 8 | velocity / rearing | finding 13 |
| 1253 | mcpherson2020 p. 32 | velocity / rearing | finding 11 |
| 1254 | mcpherson2020 p. 32 | velocity / rearing | finding 11 |

Rows with a finding: 19 (findings 6 and 11 cover several rows). Rows ok: 46.
