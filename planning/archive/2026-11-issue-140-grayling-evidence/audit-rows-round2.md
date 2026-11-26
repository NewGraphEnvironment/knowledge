# Audit, round 2: grayling rows (data rows 1190-1304)

Meaning audit of every row `fixes-rows-round1.md` marks other than "unchanged" (the round-1 fixes, the re-quoted
rows, the kept-review rows' new notes, and the 50 new rows 1255-1304), each read against its page in the extracted
text (`scratchpad/txt/<key>.txt`, `.layout.txt`, `stanislawski1997FallWinter.ocr.txt`) and, for 1285, the Zotero
item's `abstractNote`. Unchanged rows were checked only for duplication or contradiction by a fix elsewhere: none
found. Page numbers below are printed page numbers; "PDF page" where the extraction's page index is meant.

Nine findings: four that change what a row says (1216, 1260, 1262, 1267) and five minor (a hedge or a field).

## Findings

### 1. Data row 1216, `bound`: a selection-against breakpoint coded as a limit (inside a round-1 fix)

- **What is wrong:** round 1 kept `bound = max` and added a note saying the value is "use below availability, not
  absence, so not a limit of use". The field and the note now contradict each other. CLAUDE.md's convention: "An
  interior curve breakpoint (a non-zero score, a curve switch) has a blank `bound`; `min`/`max` is a limit or a
  zero-suitability edge." Juveniles are found in channels wider than 14 m at a lower rate than available; that is a
  non-zero preference, an interior breakpoint.
- **Page evidence (Den Beste and McCart 1984, p. 34):** "Juvenile grayling also appear to select for narrow channel
  widths (1 to 8 m wide) and, although they are found in channels of average width, tend to select against channels
  wider than 14 m."
- **Fix:** `bound` blank. Keep `kind = pref`, value 14, no parameter, and the note.

### 2. Data row 1260, `note`: says reaches 1-2 held the 1997 fry, but the fry reached km 29, inside reach 3

- **What is wrong:** the note reads "Reaches 1 and 2 (km 0-27) of the Table River held the 1997 fry, which were not
  found upstream of km 29 (p. 6)" and then says reaches 3 to 7 begin at km 27. By the same page's numbers the 1997
  fry reached 2 km into reach 3 (1-2 %), so the < 0.5 % reaches did not hold all of them. Read with the row's value
  (`value_max` 0.5), the note implies every fry was in water of < 0.5 % reach gradient.
- **Page evidence (Blackman 2004, p. 2):** "The upper reaches (Three to Seven: km 27; 35; 42; 43; and 51
  respectively) have a moderate gradient (1-2%) ... Reaches One and Two (0-9; 9-27 km respectively) are low gradient
  (<0.5%)". **(p. 6):** "No grayling fry were found upstream from km 29 and the only location where more that 10 fry
  were observed was near the mouth of the Table River." The habitat-use electrofishing was at km 10 and km 22.5 (p. 7).
- **Fix:** note: "Table River fry, 1997, were found up to km 29 (p. 6), so mostly in reaches 1 and 2 (km 0-27,
  < 0.5 %) and up to 2 km into reach 3 (1-2 %, from km 27, same page); the habitat-use sites were at km 10 and 22.5
  (p. 7). Reach gradient, not measured at fry sites."

### 3. Data row 1262, `note`: the authors' hedge on the Parsnip as age 1+ rearing area is dropped

- **What is wrong:** the note says "the authors judge its glides the primary rearing area of age 1+ (p. 30)". The
  page offers it as a possibility to be verified, and names the shallow low-velocity glides, not the river's glides
  in general.
- **Page evidence (Blackman and Hunter 2001, p. 30):** "The shallow low velocity glides in the Parsnip River may be
  the primary rearing area for this age class of Arctic grayling, not only from the Parsnip River but for fish from
  the Table and Anzac rivers as well. Analysis of the genetic data collected and the recapture of PIT tagged 1+ Arctic
  grayling from the Parsnip River should help verify this assumption."
- **Fix:** "...; the authors suggest its shallow, low-velocity glides 'may be' the primary rearing area of age 1+, an
  assumption still to be verified (p. 30)."

### 4. Data row 1267, `note` (and `life_stage`): "all ages" and "a small low-gradient creek" are not on the pages

- **What is wrong:** (a) the note says "Grayling of all ages, smaller fish included, were densest ... in Sections 3
  and 4". The density comparison sits in section 4.5.2, "Yearlings and post-yearlings", after young-of-year were
  treated in 4.5.1; the same paragraph says large (250 mm) grayling were repeatedly in the deeper pools there, and the
  oversummering population it describes averaged 255 fish per sampling period, spawners of 3-8 years among them. So
  the counts are of yearlings and older, adults included, not all ages, and the row's `rearing` stage (age 0 and
  juveniles in summer, per the drafter brief) holds only part of what was counted. (b) "Steep within a small
  low-gradient creek" is the drafter's inference: no page says Adsett Creek is low-gradient overall; p. 26 says
  Section 3 had "the steepest stream gradient" and Sections 5-7 were "typified by low gradients".
- **Page evidence (Stewart et al. 1982, p. 44):** "4.5.2 Yearlings and post-yearlings ... High numbers of
  oversummering grayling (x = 255 fish/sampling period) were recorded from June 14 - September 25". **(p. 46):**
  "these sections supported the most grayling per unit area of habitat (0.006 grayling/m2) ... These results suggest
  that grayling preferred areas of steep gradient, typified by Sections 3 and 4. Throughout the summer, large
  grayling (250 mm) were repeatedly found in the deeper pools of this area. Smaller fish utilized this area
  continuously". **(p. 26):** "This frequency reflected the steepest stream gradient and a confined, meandering
  channel."
- **Fix:** note: "Yearling and older grayling (section 4.5.2), adults included, were densest per unit of habitat in
  Sections 3 and 4 (0.006 fish/m2) against 0.003 fish/m2 in Sections 5-7, which are typified by low gradients
  (p. 26); hedged ('These results suggest'). Large (250 mm) fish used the deeper pools there and smaller fish used
  the area throughout. Not young-of-year. Section gradients appear only in Figure 5, which the text layer garbles.
  No value." Drop "Steep within a small low-gradient creek". Either keep `rearing` with this note, or, if the
  vocabulary's `adult` stage is preferred for a count dominated by adults, recode; the yearlings make `rearing`
  defensible only with the note saying adults are in it.

### 5. Data row 1266, `note` (minor): `rearing` for "yearling and post-yearling" fish

- **What is wrong:** the note correctly says "Yearling and older grayling", but post-yearlings include the
  oversummering adults (p. 44, as in finding 4), which the brief keeps out of `rearing`. The note does not say adults
  are among them.
- **Page evidence (Stewart et al. 1982, p. 44):** "Yearling and post-yearling grayling utilized virtually the entire
  habitable portion of Adsett Creek (approximately 18 km upstream of the Prophet River confluence) ... substantial
  numbers of grayling from 0+ to 3 years used areas throughout the upper reaches from July to mid-September."
- **Fix:** add "adults among them (section 4.5.2); opportunistic sampling found grayling of 0+ to 3 years in the
  upper reaches (km 13.7-18) from July to mid-September (same page)."

### 6. Data row 1256, `note` (minor): 'generally' dropped

- **What is wrong:** the note says "Most spawning ... was toward the tails of long runs"; the page says these areas
  "generally occurred" there. The quote keeps the word, the note does not.
- **Page evidence (Stewart et al. 1982, p. 31):** "These areas generally occurred toward the toil [tail] of long
  runs, particularly those preceding steep gradients."
- **Fix:** "The areas of most spawning generally lay toward the tails of long runs, particularly runs preceding
  steep gradients".

### 7. Data row 1277, `note` (minor): 'approximately' and a conditional dropped

- **What is wrong:** the value is printed "approximately 2.2", and the "< 0.8 m3/s" is what flow "would be" after
  freshets in the absence of rain-driven peaks, which the note states as a fact of the season. The 2.2 is also the
  maximum after the staff gauge went in; the breakup peak came before it.
- **Page evidence (Stewart et al. 1982, p. 19):** "Discharge ranged from below limits of detection to approximately
  2.2 m3/sec during the period of measurement." **(p. 21):** "Maximum discharge (estimated 5 - 7 m3/sec) occurred
  during spring breakup, prior to staff gauge installation ... In the absence of such phenomena, after spring
  freshets subside, stream flow would be minimal (<0.8m3/sec) for the majority of the ice-free season."
- **Fix:** "Measured Adsett Creek discharge, May 14-October 19, 1981, from below detection to approximately 2.2 m3/s,
  after the staff gauge was installed; the breakup peak before it was estimated at 5-7 m3/s, and without
  rain-driven peaks flow after freshet 'would be minimal (< 0.8 m3/s)' (p. 21). ..." (rest as now).

### 8. Data row 1283, `note` (minor): 'Apparently' dropped

- **What is wrong:** the note says grayling "spawned May 10-25, 1981"; the dates are the authors' inference.
- **Page evidence (Stewart et al. 1982, p. 31):** "Apparently, spawning occurred May 10 -25 with peak activity
  between May 16 and May 23."
- **Fix:** "Adsett Creek, where grayling apparently spawned May 10-25, 1981 (p. 31)."

### 9. Data row 1201, `bound` (minor): two group means coded as a range

- **What is wrong:** `bound = range` with 0.17-0.18 %. The two values are the mean overwintering gradients of two
  groups of fish (sites 1-2 and sites 3-4), not two limits; the observed spans are rows 1268 and 1269. The brief:
  `range` "for a span between two limits"; blank "for a value that is neither".
- **Page evidence (Stanislawski 1997, p. 39, OCR):** "overwintered at a mean gradient of 0.18 % (N=15; Range 0.11 -
  0.29 %) ... to overwinter at a mean gradient of 0.17 % (N=9; Range 0.08 - 0.33 %)". **(p. 42):** "most fish
  overwintered in water with a mean gradient in the 0.17-0.18% range".
- **Fix:** `bound` blank; the note already says what each value is.

## Checked and found right (selected, where a fix or new row could have gone wrong)

- 1215/1216 juveniles are 75-220 mm (p. 33), not fry; the adult statement is p. 35 as cited.
- 1229/1230: 'flow' is velocity x depth x wetted width at sampling (glossary), as the notes say.
- 1231: Appendix E's column heads give absent n = 41 and present n = 56, the reverse of the caption and of p. 21's
  42 % present; the Present column's order range (4-8) matches the text, so the data columns are right and the n's
  swapped, as the note says.
- 1252: Mathias pp. 47-48's < 20 cm and 0-0.2 m/s is the field crew's general salmonid fry guideline, as the note
  says.
- 1263/1272/1294/1302: Appendix F (p. 61) Present column read correctly; width is wetted; depth and width from one
  representative transect at the logger (p. 15); presence is one grayling of any size (p. 14).
- 1278: Langston's estimate, "which he suggested could be low" (Blackman 2004 p. 2), relayed by Mathias p. 3.
- 1280: 75.5 m3/s recomputed from Appendix 1's monthly means: the 1993-2002 January-August mean is 75.46; the
  annual mean of the same months would be 62.0, so "not MAD" is right and the January-August window holds.
- 1281: "(January to September)" printed on p. 4.
- 1285: the abstract (Zotero `abstractNote`) says what the quote says and gives no order.
- 1288/1289/1297/1298: Table 2 (p. 8) n = 275 and 67, SDs 11.7/0.07 and 10.0/0.1, footnote "m-s", velocity at
  60 % depth (p. 4); fry fork lengths 24-60 and 25-58 mm (Table 1, p. 7).
- 1293/1301: the abstract's 'shallow (60-100cm), low velocity (<0.5 ms-1)' (p. i) is quoted correctly.
- 1268/1269: OCR p. 39 values and site groups as written; gradients from 1:20,000 maps between 10 m contours (p. 26);
  tagged fish 265-372 mm (Table 1, p. 15).

## Every row audited

| data row | key | verdict |
|---|---|---|
| 1196 | stamford_etal2017FWCPArctic | ok |
| 1201 | stanislawski1997FallWinter | finding 9 (minor) |
| 1207 | hagen_etal2026futureArctic | ok |
| 1210 | cannings_ptolemy1998RareFreshwater | ok |
| 1215 | denbeste_mccart1984Overviewstudies | ok |
| 1216 | denbeste_mccart1984Overviewstudies | finding 1 |
| 1220 | hagen_etal2015Criticalhabitats | ok |
| 1229 | stuart_chislett1979AspectsLife | ok |
| 1230 | stuart_chislett1979AspectsLife | ok |
| 1231 | hawkshaw_shrimpton2014Temperaturepreference | ok |
| 1232 | stamford_etal2017FWCPArctic | ok |
| 1233 | stamford_etal2017FWCPArctic | ok |
| 1234 | cutting_etal2018Linkingbeaver | ok |
| 1237 | stewart_etal1982Ecologicalstudies | ok |
| 1238 | stewart_etal2007Fishlife | ok |
| 1240 | mcpherson2020Habitatuse | ok |
| 1241 | stewart_etal1982Ecologicalstudies | ok |
| 1245 | stewart_etal2007Fishlife | ok |
| 1247 | mcpherson2020Habitatuse | ok |
| 1248 | mcpherson2020Habitatuse | ok |
| 1249 | stewart_etal1982Ecologicalstudies | ok |
| 1250 | house2021Interdisciplinaryapproaches | ok |
| 1252 | stamford_etal2017FWCPArctic | ok |
| 1253 | mcpherson2020Habitatuse | ok |
| 1254 | mcpherson2020Habitatuse | ok |
| 1255 | denbeste_mccart1984Overviewstudies | ok |
| 1256 | stewart_etal1982Ecologicalstudies | finding 6 (minor) |
| 1257 | cowie_blackman200320012002Arctic | ok |
| 1258 | cowie_blackman200320012002Arctic | ok |
| 1259 | cowie_blackman200320012002Arctic | ok |
| 1260 | blackman20041997Arctic | finding 2 |
| 1261 | blackman_hunter20011998Arctic | ok |
| 1262 | blackman_hunter20011998Arctic | finding 3 |
| 1263 | hawkshaw_shrimpton2014Temperaturepreference | ok |
| 1264 | hawkshaw_shrimpton2014Temperaturepreference | ok |
| 1265 | cowie_blackman20042003Arctic | ok |
| 1266 | stewart_etal1982Ecologicalstudies | finding 5 (minor) |
| 1267 | stewart_etal1982Ecologicalstudies | finding 4 |
| 1268 | stanislawski1997FallWinter | ok |
| 1269 | stanislawski1997FallWinter | ok |
| 1270 | blackman2002RadioTelemetry | ok |
| 1271 | blackman2002DistributionRelative | ok |
| 1272 | hawkshaw_shrimpton2014Temperaturepreference | ok |
| 1273 | blackman_hunter20011998Arctic | ok |
| 1274 | mathias_etal1998SummaryReport | ok |
| 1275 | blackman2002RadioTelemetry | ok |
| 1276 | stewart_etal1982Ecologicalstudies | ok |
| 1277 | stewart_etal1982Ecologicalstudies | finding 7 (minor) |
| 1278 | blackman20041997Arctic | ok |
| 1279 | blackman_hunter20011998Arctic | ok |
| 1280 | cowie_blackman20042003Arctic | ok |
| 1281 | cowie_blackman2007Arcticgrayling | ok |
| 1282 | blackman2002RadioTelemetry | ok |
| 1283 | stewart_etal1982Ecologicalstudies | finding 8 (minor) |
| 1284 | stewart_etal1982Ecologicalstudies | ok |
| 1285 | hawkshaw_etal2013Habitatcharacteristics | ok |
| 1286 | blackman2002RadioTelemetry | ok |
| 1287 | denbeste_mccart1984Overviewstudies | ok |
| 1288 | blackman20041997Arctic | ok |
| 1289 | blackman20041997Arctic | ok |
| 1290 | blackman20041997Arctic | ok |
| 1291 | blackman20041997Arctic | ok |
| 1292 | blackman_hunter20011998Arctic | ok |
| 1293 | blackman_hunter20011998Arctic | ok |
| 1294 | hawkshaw_shrimpton2014Temperaturepreference | ok |
| 1295 | blackman2002RadioTelemetry | ok |
| 1296 | denbeste_mccart1984Overviewstudies | ok |
| 1297 | blackman20041997Arctic | ok |
| 1298 | blackman20041997Arctic | ok |
| 1299 | blackman20041997Arctic | ok |
| 1300 | blackman_hunter20011998Arctic | ok |
| 1301 | blackman_hunter20011998Arctic | ok |
| 1302 | hawkshaw_shrimpton2014Temperaturepreference | ok |
| 1303 | stewart_etal1982Ecologicalstudies | ok |
| 1304 | blackman2002RadioTelemetry | ok |
| unchanged rows (1190-1195, 1197-1200, 1202-1206, 1208-1209, 1211-1214, 1217-1219, 1221-1228, 1235-1236, 1239, 1242-1244, 1246, 1251) | various | duplication and contradiction only: ok |
