# Audit, round 3: the nine rows fixed in round 2 (#140)

Meaning audit, every field, of data rows 1201, 1216, 1256, 1260, 1262, 1266, 1267, 1277 and 1283 of
`data/literature_evidence.csv` as `fixes-rows-round2.md` left them, each read against its pages in
`scratchpad/txt/<key>.txt` / `.layout.txt`, `stanislawski1997FallWinter.ocr.txt`, and for Stewart et al. 1982's
tables the OCR cache `data/rag/ocr/71074d551009ef943fd5e88a414999b5.txt`. Then every sibling in 1190-1304 that shares
a key and page (or a key and the fact a fix restates) was read for duplication or contradiction. Page numbers are
printed page numbers unless "PDF page" is said.

Six findings: five in the nine rows (one that changes what a row says, 1260; one false claim about the source, 1267;
three minor) and one in a sibling row that carries the same defect as 1260 (1278). Three of the five sit inside
round-2 fix text (1260's reach 3 clause, 1267's Figure 5 sentence, which round 2's proposed fix carried; 1277's
season clause, kept by round 2's "rest as now").

## Findings

### 1. Data row 1260, `note`: the fix puts 1997 fry into reach 3, which no page says, and contradicts row 1261

- **What is wrong:** (a) "were found up to km 29 ... and up to 2 km into reach 3" turns the page's upper bound ("No
  grayling fry were found upstream from km 29") into a statement that fry were found between km 27 and 29. The page
  does not say any were. (b) Blackman and Hunter 2001 (p. 27), which row 1261's note cites, says that in the earlier
  studies, Blackman 2002 in prep (the 1997 work this row's source reports) among them, "no Arctic grayling fry had
  been captured upstream from km 27". So the fixed note now contradicts its sibling 1261. (c) "mostly in reaches 1
  and 2" is the drafter's inference; the page gives no count by reach, only that the one location with more than 10
  fry was near the mouth. (d) "(1-2 %, from km 27, same page ...)": the last page cited is p. 6, but the reach
  gradients are on p. 2.
- **Page evidence (Blackman 2004, p. 6):** "Thirty-three sites on Table River from km 0 to 31 ... were surveyed. Only
  58 fry were observed (28 captured) from the Table River. No grayling fry were found upstream from km 29 and the
  only location where more that 10 fry were observed was near the mouth of the Table River." **(p. 2):** "The upper
  reaches (Three to Seven: km 27; 35; 42; 43; and 51 respectively) have a moderate gradient (1-2%) ... Reaches One and
  Two (0-9; 9-27 km respectively) are low gradient (<0.5%)". **(Blackman and Hunter 2001, p. 27):** "In previous
  studies (Mathias et al 1998, Zemlak and Langston 1998, Blackman 2002 in prep), no Arctic grayling fry had been
  captured upstream from km 27."
- **Fix:** note: "Table River, 1997: 58 fry observed (28 captured) at 33 sites from km 0 to 31, none found upstream
  of km 29, and the only location with more than 10 fry near the mouth (p. 6). Reaches 1 and 2 (km 0-27) are
  < 0.5 % and reach 3 from km 27 is 1-2 % (p. 2; next row); Blackman and Hunter 2001 (p. 27) report no fry captured
  above km 27 in this work. The habitat-use sites were at km 10 and 22.5 (p. 7). Reach gradient, not measured at fry
  sites."

### 2. Data row 1267, `note`: "Section gradients appear only in Figure 5" is false

- **What is wrong:** Table 3 ("Physical characteristics of Adsett Creek by stream section", pp. 23-25, PDF pages
  34-36, printed in the rotated margin) has a "Section Gradient" column. The text layer garbles it, but the OCR cache
  reads it: Section 3 1.46, Section 4 1.23, Section 5 0.83, Section 7 0.72, Section 8 0.95, Section 2 0.59, with no
  unit printed in the column head. The sentence came with round 2's proposed fix.
- **Page evidence (Stewart et al. 1982, Table 3, OCR):** header "... Substrate (%) ... Section | ... Gradient ..."
  (p. 23); rows "2 422 257 165 ... 0.49 10 25 25 40 1.46" (Section 3), "Section ... 1.23" (Section 4, p. 24), "8 \
  730 294 436 ... 0.95 [logjam" (p. 25). The `.layout.txt` shows the same column ("GradiP.nl", "I. 23", "U.'J5").
- **Fix:** replace the sentence with "Section gradients are in Table 3 (pp. 23-25: Sections 3 and 4, 1.46 and 1.23;
  Sections 5 and 7, 0.83 and 0.72; no unit printed) and Figure 5, both garbled in the text layer." With no unit
  printed, they stay out of `value_*` (the brief's rule for an unprinted percent).

### 3. Data row 1277, `note` (minor): the measured period is not "the season young-of-year reared there"

- **What is wrong:** the note calls May 14-October 19 "the season young-of-year reared there before emigrating
  August-October". Young-of-year emerged about June 15-18 and were first seen in abundance on June 25 (p. 35); the
  first month of the record covers spawning (May 10-25, p. 31) and incubation. The pages the note cites (44, 47-49)
  give dispersal after emergence and emigration, not that the whole period was rearing.
- **Page evidence (Stewart et al. 1982, p. 35):** "Young-of-the-year grayling were first observed in abundance along
  stream margins on June 25 ... hatching probably occurred about 21 days after egg deposition (June 11 - 15) and
  initial emergence from June 15 - 18." **(p. 19):** "Adsett Creek discharge from May 14 - October 19 is shown ...
  Discharge ranged from below limits of detection to approximately 2.2 m3/sec during the period of measurement."
- **Fix:** "..., after the staff gauge was installed; the record spans spawning (May 10-25, p. 31) and young-of-year
  rearing from emergence in mid-June (p. 35) to emigration August 1-October 16 (p. 47); ..." (rest as now).

### 4. Data row 1201, `note` (minor): "The ranges are the next two rows" points at the wrong rows

- **What is wrong:** the rows after 1201 are 1202 (Stewart et al. 2007, spawning channel width) and 1203 (House 2021,
  spawning channel width). The two observed ranges are data rows 1268 and 1269.
- **Evidence:** the table itself (data rows 1202, 1203, 1268, 1269).
- **Fix:** "The observed ranges are data rows 1268 and 1269." (Or "the two range rows of this key, p. 39", which
  survives appends.)

### 5. Data row 1201, `note` (minor; same word in siblings 1268 and 1269): "adults" is not the source's word

- **What is wrong:** the thesis never calls the radio-tagged fish adults. It gives each fish's fork length, weight
  and sex (Table 1) and says transmitters went into fish of a minimum weight (">300 mm total length", p. 16). Most
  are probably mature at 265-372 mm FL, but that is the drafter's inference.
- **Page evidence (Stanislawski 1997, p. 15, OCR):** "Table 1. Identification number, fork length (mm), weight (gm),
  sex, date of implantation and location of capture / release sites of 34 radio tagged Arctic grayling from the
  Little Smoky River, Alberta, fall 1993." A search of the OCR for "adult" and "mature" finds neither said of the
  tagged fish.
- **Fix:** "radio-tagged grayling (fork length 265-372 mm, sex recorded for each, Table 1 p. 15)" in 1201, and
  "radio-tagged grayling" in 1268 and 1269.

### 6. Data row 1278 (sibling, not one of the nine), `note` (minor): "fry were caught ... km 0-29" overstates p. 6

- **What is wrong:** the same defect as finding 1. p. 6 says 58 fry were observed, 28 captured, none found upstream of
  km 29; it does not say fry were caught throughout km 0-29, and Blackman and Hunter 2001 (p. 27) report none
  captured above km 27 in this work.
- **Page evidence:** as finding 1.
- **Fix:** "grayling fry were observed in the Table mainstem in 1997, none upstream of km 29 (p. 6)".

## Duplication and contradiction among siblings

- 1201 against 1268/1269 (same key): distinct values (two means against two observed spans); no duplicate. Notes
  consistent except the "adults" word shared by all three (finding 5).
- 1216 against 1215 (same key and page): 1215 is the 1-8 m preference (`optimum`), 1216 the 14 m selection against
  (bound blank); 1215's note "The avoidance of channels wider than 14 m is the next row" is right. No duplicate.
- 1256 against 1237/1241/1249 (same key and page): 1237's note restates the run-tail sentence with "generally", as
  1256 now does. No contradiction.
- 1260 against 1261 (Table River fry, adjacent reaches): contradiction introduced by the round-2 fix (finding 1).
  Against 1278 (same key, p. 2): 1278 carries the same overstatement (finding 6). Against 1288-1291, 1297-1299 (same
  key, other pages): no conflict.
- 1262 against 1279, 1273, 1292-1293, 1300-1301 (same key): 1279 shares p. 3 but is discharge (142 m3/s), not a
  duplicate; 1293 and 1301 (age 1+ in the Parsnip, p. 30) agree with 1262's p. 30 sentence.
- 1266 against 1267, 1303, 1284 (same key): different pages or variables; 1284's "yearlings and older also
  oversummered there (p. 44)" agrees with 1266's.
- 1277 against 1276 (same key, discharge): spawning 1.5 m3/s (p. 31) against the season's range (p. 19); not a
  duplicate. 1277's "breakup peak ... 5-7 m3/s" and 1276 do not conflict.
- 1283 against 1284 (same key and page, same quote): two stages, as both notes say. 1283's dates agree with p. 31 and
  with 1276's peak-spawning dates (May 16-23).

## Every claim in the nine notes, with its page

### 1201 (stanislawski1997FallWinter, p. 42; bound blank, 0.17-0.18 %, dist, reach, overwintering)

- Quote verbatim on p. 42 (OCR): supported, p. 42.
- Mean gradient of overwintering grounds: p. 42 ("water with a mean gradient in the 0.17-0.18% range"), p. 39.
- Fish are "radio-tagged adults": radio-tagged, p. 14 and Table 1 p. 15; "adults" unsupported (finding 5).
- Fork length 265-372 mm, Table 1 p. 15: supported, p. 15.
- Winter 1993-94: p. 15 (monitored August 31, 1993 to January 15, 1994).
- 0.18 % for sites 1 and 2, N = 15: p. 39.
- 0.17 % for sites 3 and 4, N = 9: p. 39.
- From 1:20,000 maps between 10 m contours: p. 26.
- "The ranges are the next two rows": unsupported; they are data rows 1268 and 1269 (finding 4).
- Stewart et al. 2007 Table 2 p. 6 relays "0.17-0.18% on overwintering grounds": Stewart et al. 2007, p. 6 (ref. 51 =
  Stanislawski 1997).
- `bound` blank for two group means: p. 39 (two means of two groups).

### 1216 (denbeste_mccart1984Overviewstudies, p. 34; bound blank, max 14 m, pref, reach, rearing)

- Juveniles are 75 to 220 mm: p. 33.
- Found in channels of average width but tend to select against channels wider than 14 m: p. 34.
- Use below availability, not absence, so not a limit: p. 34 ("although they are found in channels of average width,
  tend to select against"); selection is use against availability (method, p. 32).
- No parameter, the model has no maximum rearing width: `knw_literature_vocab()$parameter` (no `rear_channel_width_max`).
- Adults used channels averaging 10 m and selected against channels less than 6 m wide: p. 35.
- Stewart et al. 2007 p. 19 relays it ("appeared to select ... against channels wider than 14 m"): Stewart et al.
  2007, p. 19.
- Region, Trans Alaska Pipeline streams north of the Yukon River: report introduction (PDF page with "fish
  populations along the Trans Alaska Pipeline System (TAPS) north of the Yukon River").

### 1256 (stewart_etal1982Ecologicalstudies, p. 31; qual, site, spawning)

- Adsett Creek is a second-order stream: p. 2.
- The areas of most spawning: p. 31 ("Most spawning activity occurred in areas ...").
- Generally lay toward the tails of long runs: p. 31 ("These areas generally occurred toward the toil of long runs").
- Particularly runs preceding steep gradients: p. 31.
- No value: p. 31 gives none for gradient.
- Text layer reads "tail" as "toil", skipped by the ellipsis: p. 31 (`.txt`: "toil").

### 1260 (blackman20041997Arctic, p. 2; max 0.5 %, dist, reach, rearing)

- Table River fry, 1997, found up to km 29: p. 6 says none found upstream of km 29; "found up to" overstates
  (finding 1).
- So mostly in reaches 1 and 2: unsupported as stated; p. 6 gives no count by reach (finding 1).
- Reaches 1 and 2 are km 0-27, < 0.5 %: p. 2.
- Up to 2 km into reach 3: unsupported; Blackman and Hunter 2001 p. 27 says none captured above km 27 (finding 1).
- Reach 3 is 1-2 % from km 27, "same page": p. 2, not p. 6 (finding 1).
- Next row gives reach 3's gradient: data row 1261, Blackman and Hunter 2001 p. 2.
- Habitat-use sites at km 10 and 22.5: p. 7.
- Reach gradient, not measured at fry sites: p. 2 (reach descriptions); fry sites p. 6.

### 1262 (blackman_hunter20011998Arctic, p. 3; 0.3 %, dist, reach, rearing)

- Whole-river gradient of the Parsnip River: p. 3 ("This river is low gradient (0.3%) and is unconfined", of the
  175 km river).
- Age 0+ and 1+ grayling were beach-seined there in 1998: pp. 15-16.
- 85 and 55 in the first session: p. 16 (first session named at the foot of p. 15).
- The authors suggest its shallow, low-velocity glides "may be" the primary rearing area of age 1+: p. 30.
- An assumption still to be verified: p. 30 ("should help verify this assumption").

### 1266 (stewart_etal1982Ecologicalstudies, p. 44; qual, reach, rearing)

- Yearling and older grayling: p. 44 (section 4.5.2, "Yearling and post-yearling grayling").
- Adults among them: p. 46 (large grayling, 250 mm, in section 4.5.2) and p. 31 (spent grayling dispersed to
  oversummer); inference from those pages, acceptable.
- Used Adsett Creek up to about 18 km above the Prophet River confluence: p. 44.
- Beyond, habitat marginal from rapidly increasing gradient: p. 44.
- And lack of riparian cover after a fire: p. 44 (and p. 2, fire near km 18).
- Opportunistic sampling found grayling of 0+ to 3 years in the upper reaches, km 13.7-18: p. 44 (Section 10).
- July to mid-September: p. 44.
- No value: p. 44.

### 1267 (stewart_etal1982Ecologicalstudies, p. 46; qual, reach, rearing)

- Yearling and older grayling (section 4.5.2): pp. 44-46 (section 4.5.2 runs pp. 44-46; TOC p. iv).
- Adults included: p. 46 (large grayling, 250 mm); p. 44 (oversummering population).
- Densest per unit of habitat in Sections 3 and 4, 0.006 fish/m2: p. 46.
- Against 0.003 fish/m2 in Sections 5-7: p. 46.
- Sections 5-7 typified by low gradients: p. 26.
- Hedged, "These results suggest": p. 46.
- Large (250 mm) fish used the deeper pools there: p. 46.
- Smaller fish used the area throughout: p. 46 ("continuously throughout all variations in stream conditions").
- Not young-of-year: by section placement, pp. 44-46 (young-of-year are section 4.5.1); the page does not say YOY
  were excluded from the counts, but the section structure supports it.
- Section gradients appear only in Figure 5: unsupported; Table 3, pp. 23-25, has a Section Gradient column
  (finding 2).
- The text layer garbles Figure 5: p. 20 (PDF page 31).
- No value: p. 46.

### 1277 (stewart_etal1982Ecologicalstudies, p. 19; max 2.2 m3/s, dist, reach, rearing)

- Measured discharge, May 14-October 19, 1981: p. 19.
- From below detection to approximately 2.2 m3/s: p. 19.
- After the staff gauge was installed: p. 21 ("prior to staff gauge installation") with p. 19 ("the period of
  measurement").
- The season young-of-year reared there: unsupported for May 14 to mid-June; emergence June 15-18, first seen
  June 25 (p. 35) (finding 3).
- Before emigrating August-October: p. 47 (August 01-October 16).
- Breakup peak before the gauge estimated at 5-7 m3/s: p. 21.
- Without rain-driven peaks flow after freshet "would be minimal (< 0.8 m3/s)": p. 21.
- Not MAD: p. 19 (a seasonal measured range).
- The ellipsis skips the superscript 3 set on its own line: p. 19 (`.txt`).

### 1283 (stewart_etal1982Ecologicalstudies, p. 2; 2-2 order, dist, reach, spawning)

- Adsett Creek is a second-order tributary of the Prophet River: p. 2.
- Grayling apparently spawned there May 10-25, 1981: p. 31 ("Apparently, spawning occurred May 10 -25").
- Shares the quote with the rearing row: data row 1284 (same quote, `rearing`).
