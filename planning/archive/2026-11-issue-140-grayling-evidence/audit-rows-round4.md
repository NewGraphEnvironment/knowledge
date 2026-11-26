# Audit, round 4: the seven rows fixed in round 3 (#140)

Meaning audit, every field and every note claim, of data rows 1201, 1260, 1267, 1268, 1269, 1277 and 1278 of
`data/literature_evidence.csv` as `fixes-rows-round3.md` left them (data row N is file line N + 1). Each was read
against its pages in `scratchpad/txt/<key>.txt` / `.layout.txt`, `stanislawski1997FallWinter.ocr.txt`, the OCR cache
`data/rag/ocr/71074d551009ef943fd5e88a414999b5.txt` (Stewart et al. 1982, Table 3 and Figures 5 and 13), and for the
Mathias et al. 1998 page a fresh render of the attachment's PDF page 8 (`~/Zotero/storage/DXVJJI6Z/`). Then the
siblings sharing a key and page, or a key and the fact a note restates, were read for duplication and contradiction:
1261 against 1260; 1288-1291 and 1297-1299 against 1278; 1266, 1276 and 1284 against 1267 and 1277. Page numbers are
printed page numbers unless "PDF page" is said.

Four findings, all minor, three of them in text that round 3's fixes wrote or kept (1260's first sentence, 1269's
reach clause, 1277's "spans spawning"). None changes a value, a field or a row's stage; each is a note sentence that
says a little more than its page.

## Findings

### 1. Data row 1201, `note` (minor): the 265-372 mm range is the 34 tagged fish, not the 24 whose means the row gives

- **What is wrong:** the parenthesis attaches Table 1's fork-length range to the fish whose overwintering gradients
  are reported. Table 1 lists all 34 tagged fish (265-372 mm). The two means are of N = 15 (sites 1 and 2) and N = 9
  (sites 3 and 4). Fish 1, the only one under 280 mm, moved upstream out of the study section and was not found after
  September 16 (p. 27), so it is in neither mean: the 15 from sites 1 and 2 are the 23 tagged there less the 8 lost
  (1, 4, 6, 12, 16, 17, 20, 23; p. 27), 280-372 mm by Table 1, and the 9 from sites 3 and 4 are drawn from fish of
  280-368 mm.
- **Page evidence (Stanislawski 1997, p. 15, OCR):** "Table 1. Identification number, fork length (mm), weight (gm),
  sex, date of implantation and location of capture / release sites of 34 radio tagged Arctic grayling ... 1 1 Aug.17
  265 222 Female". **(p. 27):** "In site 1, of the thirteen fish tagged, four were lost (1, 4, 6, and 12). Three fish
  (1, 4, and 12) moved upstream of the study section ... In site 2, of the ten fish tagged, four were lost (16, 17,
  20, and 23)." **(p. 39):** "overwintered at a mean gradient of 0.18 % (N=15 ...)".
- **Fix:** "Mean gradient of overwintering grounds of radio-tagged grayling (the 34 tagged were 265-372 mm fork length,
  sex recorded for each, Table 1 p. 15), winter 1993-94: ..." (rest as now).

### 2. Data row 1269, `note` (minor): "which left the 0.29 % middle reach" drops the page's named exception

- **What is wrong:** the page says the sites 3 and 4 fish left the middle part to overwinter downstream, then names
  an exception in the next sentence: fish 28 (site 4) overwintered close to its release site at 0.31 %. That value
  sits inside the row's 0.08-0.33 % range, so the range need not come only from fish that left. The note states the
  group's move without the exception.
- **Page evidence (Stanislawski 1997, p. 39, OCR):** "These fish migrated downstream and out of the middle (0.29 %
  gradient) part of the study section to overwinter at a mean gradient of 0.17 % (N=9; Range 0.08 - 0.33 %) in the
  lower part of the study section. The only exception was fish 28 which overwintered close to its release site at a
  gradient of 0.31 %."
- **Fix:** "Radio-tagged grayling from the middle study sites (3 and 4), which, all but fish 28, left the 0.29 %
  middle reach to overwinter downstream; fish 28 overwintered near its release site at 0.31 %. Winter 1993-94 (same
  page)."

### 3. Data row 1277, `note` (minor): the record does not span all of spawning

- **What is wrong:** "the record spans spawning (May 10-25, p. 31)": the measured record starts May 14 (p. 19), four
  days after spawning began (May 10, p. 31). It spans the peak (May 16-23) and the rest of spawning, not its start.
  The words came with round 3's proposed fix.
- **Page evidence (Stewart et al. 1982, p. 19):** "Adsett Creek discharge from May 14 - October 19 is shown ...".
  **(p. 31):** "Apparently, spawning occurred May 10 -25 with peak activity between May 16 and May 23."
- **Fix:** "...; the record spans spawning from May 14 (spawning May 10-25, peak May 16-23, p. 31) and young-of-year
  rearing from emergence in mid-June (p. 35) to emigration August-October (p. 47); ..." (rest as now).

### 4. Data row 1260, `note` (minor): "58 fry observed (28 captured) at 33 sites" reads as fry at all 33 sites

- **What is wrong:** the page says 33 sites from km 0 to 31 were surveyed and 58 fry were observed on the river; it
  does not say at how many sites fry were found. "Observed ... at 33 sites from km 0 to 31" reads as fry at each site
  up to km 31, which the same sentence's "none found upstream of km 29" then contradicts.
- **Page evidence (Blackman 2004, p. 6):** "Thirty-three sites on Table River from km 0 to 31, and thirty-seven sites
  on the Anzac River from km 0 to 47 were surveyed. Only 58 fry were observed (28 captured) from the Table River."
- **Fix:** "Table River, 1997: of 33 sites surveyed from km 0 to 31, 58 fry observed (28 captured) in all, none found
  upstream of km 29, and the only location with more than 10 fry near the mouth (p. 6)." (rest as now).

## Checked and not raised

- **1260, Blackman and Hunter 2001 against Blackman 2004 p. 11.** Blackman 2004 p. 11 says the fry distribution
  "(Table River 0-29 km ...) was confirmed by subsequent electrofishing", which could read as captures to km 29 and so
  against Blackman and Hunter's "no Arctic grayling fry had been captured upstream from km 27" (p. 27). But the Table
  River was electrofished only at km 10 and 22.5 (Blackman 2004 p. 7), so p. 11's confirmation cannot place captures
  at km 27-29, and the two pages do not conflict. "Blackman 2002 in prep" in Blackman and Hunter is "Arctic grayling
  habitat use in the Table and Anzac Rivers" (their reference list), the 1997 work this row's source reports, so "in
  this work" holds.
- **1267, "Not young-of-year."** Supported by placement: p. 46 sits in section 4.5.2 ("Yearlings and post-yearlings",
  pp. 44-46), whose p. 44 cites the same Figure 13 for "oversummering grayling"; young-of-year are section 4.5.1. The
  page does not say young-of-year were left out of Figure 13's counts in so many words, as round 3 noted.
- **1267, Table 3.** The `.layout.txt` carries the column head ("GradiP.nl", PDF page 34) and the OCR cache prints
  values in it (1.46, 1.23, 0.83, 0.72, 0.95, 0.59, no unit); which section each belongs to is not certain from the
  OCR (three values for Sections 4-7 on p. 24), so the round-3 decision to take no value stands.
- **1267, "smaller fish used the area throughout".** p. 46 "continuously throughout all variations in stream
  conditions": temporal, and the note's "throughout" reads the same way.
- **1277, the quoted "would be minimal (< 0.8 m3/s)".** The page prints "(<0.8m /sec)" with the 3 on the line above;
  the note's quotation normalises the unit. Not a change of meaning; restore "m3/sec" if quotations in notes are to
  be held verbatim.
- **1278, Mathias et al. 1998 "(p. 3)".** No number is printed on that page (text layer and a fresh OCR of PDF page 8
  both lack one). It is p. 3 by sequence (pp. 1 and 2 printed before it, p. 5 two PDF pages after, PDF page 9 a
  table image). The page holds "the mean daily discharge rate to be approximately 12.9 m3/sec. These estimates may be
  low", so "relays the same estimate" holds; "(p. 3, unnumbered; PDF page 8)" would follow the brief's page rule.

## Duplication and contradiction among siblings

- **1201 against 1268 and 1269** (same key): two means against two observed spans of the same two groups; no
  duplicate. Pointers now right (1201 names 1268 and 1269). The "adults" word is gone from all three.
- **1260 against 1261** (Table River fry, adjacent reaches): no contradiction. 1260 has 1997 fry none above km 29 and
  none captured above km 27 (Blackman and Hunter p. 27); 1261 has 1998 fry to km 32.6 and "no fry had been caught
  upstream of km 27 in earlier years (p. 27)". Different years, consistent on the earlier work. 1261's "concentrations
  at km 25, 26 and 29 (pp. 14, 27)" agrees with Blackman and Hunter p. 14 ("spikes in the counts at km 12, 15, 25 to
  26, and 29") and p. 27.
- **1278 against 1288-1291 and 1297-1299** (same key, pp. 3, 8, 12): different variables (depth, velocity) on other
  pages; no duplicate. Their Table River figures (67 points, fork length 25-58 mm, Table 1 p. 7; Table 2 p. 8 means
  11.5 cm and 0.07 m/s, SD 10.0 and 0.1) agree with the pages and with 1278's "fry observed in the Table mainstem in
  1997". 1290's "86% and 88%" and 1291/1299's abstract quote do not touch discharge.
- **1267 against 1266** (same key, section 4.5.2, pp. 44 and 46): 1266 is the upstream limit of use (km 18, rising
  gradient), 1267 the density by section; consistent, no duplicate.
- **1277 against 1276 and 1284** (same key): 1276 is mean discharge through peak spawning (1.5 m3/s, p. 31), 1277 the
  season's measured range (p. 19); no duplicate. 1284's "emigrated August-October (pp. 44, 47)" agrees with 1277's
  p. 47 clause.

## Every claim in the seven notes, with its page

### 1201 (stanislawski1997FallWinter, p. 42; bound blank, 0.17-0.18 percent, dist, reach, overwintering)

- Quote "most fish overwintered in water with a mean gradient in the 0.17-0.18% range" verbatim: p. 42 (OCR, first line).
- Mean gradient of overwintering grounds: p. 42; p. 39.
- Of radio-tagged grayling: pp. 14-15.
- Fork length 265-372 mm, Table 1 p. 15: p. 15, but of the 34 tagged, not the 24 in the means (finding 1).
- Sex recorded for each, Table 1: p. 15.
- Winter 1993-94: p. 15 (monitored August 31, 1993 to January 15, 1994).
- 0.18 % for fish from sites 1 and 2, N = 15: p. 39.
- 0.17 % for fish from sites 3 and 4, N = 9: p. 39.
- From 1:20,000 maps between 10 m contours: p. 26.
- The observed ranges are data rows 1268 and 1269: the table (1268, 1269: p. 39 ranges).
- Stewart et al. 2007 Table 2 p. 6 relays "Stream gradient 0.17-0.18% on overwintering grounds": Stewart et al. 2007,
  p. 6 (Adult column; ref. 51 = Stanislawski 1997 in the table's source list).
- `bound` blank for two group means: p. 39.

### 1260 (blackman20041997Arctic, p. 2; max 0.5 percent, bound blank, dist, reach, rearing)

- Quote "Reaches One and Two (0-9; 9-27 km respectively) are low gradient (<0.5%)" verbatim: p. 2.
- Table River, 1997: p. 6 (fry surveys July 15-16, 1997, p. 3).
- 58 fry observed (28 captured): p. 6.
- At 33 sites from km 0 to 31: p. 6 says 33 sites surveyed; "fry ... at 33 sites" overstates (finding 4).
- None found upstream of km 29: p. 6.
- Only location with more than 10 fry near the mouth: p. 6.
- Reaches 1 and 2 (km 0-27) < 0.5 %: p. 2.
- Reach 3 from km 27 is 1-2 %: p. 2 (reaches 3-7 together, reach 3 at km 27).
- Next row: data row 1261 (Blackman and Hunter 2001, p. 2, reaches 3-7 at 1-2 %).
- Blackman and Hunter 2001 p. 27 report no fry captured above km 27 in this work: Blackman and Hunter 2001, p. 27,
  with "Blackman 2002 in prep" = this work (their reference list).
- Habitat-use sites at km 10 and 22.5: p. 7.
- Reach gradient, not measured at fry sites: p. 2 (reach descriptions); p. 6 (fry sites).

### 1267 (stewart_etal1982Ecologicalstudies, p. 46; qual, reach, rearing)

- Quote "areas of steep gradient, typified by Sections 3 and 4" verbatim: p. 46.
- Yearling and older grayling, section 4.5.2: p. 44 (heading), section runs pp. 44-46.
- Adults included: p. 31 (spent grayling dispersed throughout the stream to oversummer); p. 46 (large, 250 mm).
- Densest per unit of habitat in Sections 3 and 4, 0.006 fish/m2: p. 46.
- Against 0.003 fish/m2 in Sections 5-7: p. 46.
- Sections 5-7 typified by low gradients: p. 26.
- Hedged, "These results suggest": p. 46.
- Large (250 mm) fish used the deeper pools there: p. 46.
- Smaller fish used the area throughout: p. 46 ("continuously throughout all variations in stream conditions").
- Not young-of-year: by section placement, pp. 44-46 (see "Checked and not raised").
- Section gradients are in Table 3 (pp. 23-25): pp. 23-25 (PDF pages 34-36; `.layout.txt` "GradiP.nl"; OCR cache).
- And Figure 5: p. 20 (caption "Percent composition of substrate types, gradient and frequency of run/riffle
  occurrence"); p. 21 ("gradient were noted (Fig. 5)").
- Both garbled in the text layer: `.txt` / `.layout.txt` of pp. 20, 23-25.
- No value taken from them: the row (value columns blank).
- No value: p. 46.

### 1268 (stanislawski1997FallWinter, p. 39; range 0.11-0.29 percent, dist, reach, overwintering)

- Quote "overwintered at a mean gradient of 0.18 % (N=15; Range 0.11 - 0.29 %)" verbatim: p. 39 (OCR).
- Radio-tagged grayling: p. 39.
- From the upper study sites (1 and 2): p. 39 ("from the upper (sites 1 and 2) part of the study section").
- Winter 1993-94: p. 15.
- Gradients of their overwintering locations: p. 39.
- From 1:20,000 maps: p. 26.

### 1269 (stanislawski1997FallWinter, p. 39; range 0.08-0.33 percent, dist, reach, overwintering)

- Quote "to overwinter at a mean gradient of 0.17 % (N=9; Range 0.08 - 0.33 %)" verbatim: p. 39 (OCR).
- Radio-tagged grayling from the middle study sites (3 and 4): p. 39; p. 27 ("middle study reaches (sites 3 and 4)").
- Which left the 0.29 % middle reach to overwinter downstream: p. 39, but for all but fish 28 (finding 2).
- Winter 1993-94: p. 15.
- Same page: p. 39.

### 1277 (stewart_etal1982Ecologicalstudies, p. 19; max 2.2 m3/s, bound blank, dist, reach, rearing)

- Quote "Discharge ranged from below limits of ... detection to approximately 2.2 m /sec during the period" verbatim:
  p. 19.
- Measured Adsett Creek discharge, May 14-October 19, 1981: p. 19.
- From below detection to approximately 2.2 m3/s: p. 19.
- After the staff gauge was installed: p. 21 ("prior to staff gauge installation") with p. 19 ("period of
  measurement").
- The record spans spawning (May 10-25, p. 31): p. 31 gives May 10-25; the record starts May 14 (finding 3).
- Young-of-year rearing from emergence in mid-June: p. 35 (initial emergence June 15-18).
- To emigration August-October: p. 47 (August 01-October 16).
- Breakup peak before the gauge estimated at 5-7 m3/s: p. 21.
- Without rain-driven peaks, flow after freshet "would be minimal (< 0.8 m3/s)": p. 21 (unit normalised in the
  quotation; see "Checked and not raised").
- Not MAD: p. 19 (a seasonal measured range).
- The ellipsis skips the superscript 3 set on its own line: p. 19 (`.txt`).

### 1278 (blackman20041997Arctic, p. 2; 12.9 m3/s, bound blank, dist, reach, rearing, cited Langston 1998)

- Quote "an average daily discharge of 12.9 m3/sec and a minimum discharge of 0.7-1.8 m3/sec was calculated for the
  Table River by Langston (1998)" verbatim: p. 2.
- Estimated mean daily discharge of the Table River: p. 2.
- Which Langston suggested could be low, same sentence: p. 2 ("although he suggested these estimates could be low").
- Grayling fry observed in the Table mainstem in 1997: p. 6 (58 observed on the Table River; "mainstem" from the
  survey sites on the river, p. 3).
- None upstream of km 29: p. 6.
- An estimate, not gauged: p. 2 ("There are no historic flow data for the Table and Anzac rivers").
- Mathias et al. 1998 p. 3 relays the same estimate: Mathias et al. 1998, p. 3 by sequence (unnumbered, PDF page 8;
  see "Checked and not raised").
- `cited_source` Langston 1998: p. 2.
