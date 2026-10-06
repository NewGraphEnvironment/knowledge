# Audit, round 2: thermal rows 511-673, the round-1 fixes, and `research/thermal_requirements.md`

Read against the PDF text in the scratchpad (`txt/<key>.txt`, `.layout.txt`, `.ocr.txt`). Row numbers are current
data rows (CSV line minus 1). Printed pages were checked against the page furniture: Richter & Kolmes printed
page = PDF page + 22; Sauter Table 4 is printed p. 18 (PDF 20) and its introducing text p. 17 (PDF 19);
McPhail & Baxter p. 9 = PDF 18; Thorley 2022 p. 30 = PDF 41; Coleman & Fausch 2007a pp. 1231-1241 = PDF 1-11;
the lab paper pp. 639-652 = PDF 1-14; Hasnain Table A2 coho row p. 39 = PDF 47; O'Connor p. 23/24/33 =
PDF 33/34/43.

The prompt's "623 (Richter DAT note)" is row **624** (ST Bell 1991 DAT). Row 623 is Nielsen et al. 1994; it
carries no DAT note and needs none.

---

## TASK 1: the fixed rows

Every fixed row's page, quote, stage and note was read against its page. These hold and need nothing:
**522, 523, 534, 551, 556, 557, 558, 559, 580, 587, 593, 594, 595, 599, 609, 618, 624, 625, 626, 627, 628, 645,
646 (stage note), 653, 656, 672, 673, 147.** Specifically:

- 557/558: the pp. 1232-1234 GSDD definition and the p. 1241 30-35 mm statement are on those pages, and the
  start rule is now quoted in full.
- 580: the Hicks sentence is on p. 30, inside the "Incubation and Early Fry Development" section that opens on
  p. 29. It is now consistent with 596.
- 593 and 618 are now `optimum` with no lower value, and 618's "(11, the lower end of the span)" is stated.
- 645: the Table A2 caption, the OS definition ("that at which spawning reaches its peak (Wismer and Christie
  1987)"), the empty Optimum column and the 4.4-7.7 in the Range column all match.
- 672's p. 113 quote ("lower lethal temperatures for most species are near 0°C") is on the page. It refers to
  salmonids in general.
- 673's quote, values and kind match p. 30.
- 147 and 656 now say the same thing, and Eaton describes FTDMS as "the highest weekly mean temperatures
  encountered", so `max_obs` / `mwat` are right.

Four findings sit inside or next to the fixes.

### 1.1 Sauter Table 4: the five same-table rows are coded two ways, and the fix to 542 took the wrong side (wrong)

- **Rows:** 529 (WCT) and 542 (BT) are `expert`; 626 (ST), 627 (CO) and 628 (CH) are `dist`.
- **Page:** p. 17, the text that introduces the table: "Table 4 lists water temperatures at which spawning of
  different salmonids has been observed (Reiser and Bjornn 1979, ODEQ 1995, Spence et al. 1996). The
  temperature metrics are not given with these studies but are assumed to be ..." The p. 18 caption says
  "Selected water temperatures for spawning". "For the purpose of water temperature criteria ..." governs only
  the DAT assumption, not what the numbers are.
- **What is wrong:** Round 1 changed 542 from `pref` to `expert` because "529 ... is `expert`, correctly: the table
  selects values for criteria". The ps fix (626-628) correctly kept `dist`. The paper says these are observed
  spawning temperatures. That is `dist`, and the "expert on a measured result" class.
- **Fix:** 529 `kind` = `dist`; 542 `kind` = `dist` (keep `bound` `optimum`, `value_max` 7; `optimum` with `dist`
  is the shape of rows 651/652). Add to both notes: "p. 17: Table 4 lists temperatures at which spawning has
  been observed." Optionally give 542's note the same metric sentence 626-628 carry: "the paper says the
  original studies give no metric and assumes DAT (p. 17)".
- **Related (missing, minor):** Table 4's "Spring chinook salmon 39.9-64 (4.4-17.8) Olson and Foster 1955, cited
  in ODEQ 1995" is the only salmon or steelhead line of the table not filed. The value is in the table through
  Richter row 138. Either file it alongside 626-628 (CH, spawning, `range` 4.4-17.8, `unstated`, `dist`, cited
  "Olson and Foster 1955 (cited in ODEQ 1995)", note "Spring-run Chinook." plus the 626-628 note), or say in
  draft-ps-notes why it was skipped.

### 1.2 Row 585: "In-stream" is not on the page (overstated, minor)

- **Page:** p. 31: "Using live-box tests on juveniles, Burck (1993) found high mortalities ...". The page does not
  say where the live boxes were.
- **Fix (note, last sentence):** "Live-box exposure test (a field exposure, not a laboratory one; the page does not
  say where)." Kind `lab` is the nearest kind, since no field-exposure kind exists. The note now says it was
  not a laboratory exposure.

### 1.3 Richter "DAT" rows: the note was added to the new rows, not to the existing sibling (inconsistent)

- **Rows:** 587, 609 and 624 now carry the Sauter sentence. **Row 138** (existing, CH spring, Olson & Foster 4.4-17.8,
  `daily_mean`) is from the same Richter p. 31 sentence ("reported spawning temperature ranges in daily average
  temperatures (DAT)") and has no such note. Sauter Table 4 lists Olson & Foster 1955 too.
- **Fix:** add the 587 sentence to row 138's note: "Richter & Kolmes label these daily average temperatures;
  Sauter et al. 2001 (p. 17), for the same values, say the original studies give no metric and DAT is
  assumed." See also 2.2: the metric itself is still the open question.

### 1.4 Row 646: the stage note is right, but the `kind` is in round 1's class (wrong)

Listed in Task 2, item 2.1(e).

---

## TASK 2: the four classes, swept over all rows 511-673

### 2.1 `expert` on a measured result

| row | page | what the page reports | fix |
|---|---|---|---|
| (a) **637** CH to_hatch 900-1,000 | Raleigh p. 4 | "requires roughly 900 to 1,000 thermal units (Seymour 1956)": a development figure from an incubation study. This is the same thing 523, 534 and 556 hold as `lab`, and the research file's own `lab` definition ("a development time in degree-days") covers it. | `kind` = `lab`; `region` = "laboratory (Seymour 1956)" or leave blank |
| (b) **592** CO incubation max 10.9 | Richter p. 32 | "Alevin and fry survival and health may be best at constant temperatures of 4◦ to 8◦ C, but survival may remain acceptable up to 10.9◦ C (Tang et al., 1987)". This is the **same sentence** as row 591, which is `lab`. Same study, same hedge, two kinds. | `kind` = `lab` |
| (c) **590** CO incubation range 1.3-10.9 | Richter p. 32 | "Egg survival may still be acceptable for many stocks at temperatures of 1.3◦ to 10.9◦ C (Tang et al., 1987)": egg survival in Tang's incubation study, worded like 591/592 | `kind` = `lab` (judgement; the "acceptable" reading is the reviewers', as it is in 591) |
| (d) **579** CH incubation max 9 | Richter p. 30 | "Constant temperatures above 9◦ to 10◦ C may reduce embryo and alevin survival", eight incubation studies cited. Sibling 578 ("Constant temperatures above 12◦ reduced alevin survival", Ringler & Hall) and 673 are `lab`. | `kind` = `lab` (judgement: it is a synthesis, but of survival at held temperatures, which is the `lab` definition) |
| (e) **646** CO rearing max 16 | Lusardi p. 414 | "experience thermal stress at water temperatures as low as 16 °C (Brett 1952)": a reported result of Brett's laboratory work, not a recommendation | `kind` = `lab`. Also decide this once across families: the tc drafter did **not** file Hagen & Weber p. 25 "physiological stress begins to occur at constant temperatures of 14-16°C (Selong et al. 2001)" because onset of stress "is not a limit" (draft-tc-notes). Either both are limits (file Hagen 14 as BT rearing `max`, `constant`, `lab`, lower end) or neither is (drop 646 to notes). |
| (f) **529, 542** | Sauter p. 17-18 | observed spawning temperatures | see 1.1: `kind` = `dist` |

Checked and left as `expert`, since each page states a recommendation, criterion or conclusion: 511-514, 538,
548, 551, 557-559, 560-575, 580-582, 584, 588, 593, 596, 601, 602, 607, 617, 618, 620, 621, 642, 653, 654, 657
and 658. 552 (O'Connor's 13 °C, "above which feeding, and occurrence are known to decrease (Selong et al. 2001;
Mochnacz et al. 2022)") is borderline: it reports lab and field results, but the report uses it as a threshold
line. Leave it as `expert`.

### 2.2 A statistic recorded as known where the source says it is assumed

| row | page | issue | fix |
|---|---|---|---|
| 587, 609, 624, and existing **138** | Richter p. 31, 33, 36; Sauter p. 17 | `daily_mean` for Bell 1991, Raleigh 1986/Chambers 1956 and Olson & Foster 1955. Richter labels them DAT. Sauter, writing about the same three studies, says "The temperature metrics are not given with these studies but are assumed". The same Chambers numbers are `unstated` in 628 (Sauter) and 640 (Raleigh's own p. 8), so one value carries two metrics. The round-1 advisory offered "`unstated`, or at least the sentence". The sentence was added; the metric was not changed. | `metric` = `unstated` on 587, 609, 624 and 138, keeping the note. If `daily_mean` is kept on purpose, record that decision in draft-ps-notes, and row 138 still needs the note (1.3). |

No other instance. Every other non-`unstated` metric among rows 511-673 is printed on its page: `daily_mean`
524; `daily_max` 525, 581, 585, 617, 635, 636; MWMT/MWAT 544, 545, 548, 649, 656; `7dadm` 560-574, 580, 596,
601, 602, 621; `weekly_mean` 657, 658; `summer_mean` 650, 651 (Lusardi defines mean T); `7dec` 655; `constant`
on held or UILT/ILT exposures 521, 536, 578, 579, 589, 591, 593, 603, 607, 618, 630, 634, 644. One instance runs
the other way: **653** is `unstated`, but the page prints "an instantaneous maximum temperature of 15.5 °C". The
vocabulary has no instantaneous metric, and a never-exceed instantaneous maximum is a ceiling on every daily
maximum, so `daily_max` is defensible. Otherwise keep `unstated` and say "instantaneous maximum (no vocabulary
term)" in the note.

### 2.3 The upper edge of an optimum stored as a harm limit

None remaining. 593 and 618 are fixed. The candidates checked:

- Richter Table 1 rows 560-574 are "Upper optimal temperature criteria, above which recovery planning would
  have to propose ways to fix the thermal regime" (p. 37). They are criteria that act as limits, so `max` is
  right.
- 581 is limits "required to provide optimal protection" and 620 is "to fully protect": both criteria.
- 582 is a growth optimum McCullough proposed "as the temperature standard", with the page's reason (above it,
  growth falls and mortality rises). That is a limit; the note says so.
- 654 ("exceeding ⬃16 °C likely constrain ... growth") states a harm.
- The optima 583, 584, 589, 591, 597, 600, 612, 614, 619, 625, 645, 647, 651, 652, 542, 543-545, 518, 520 are
  all `optimum`.

### 2.4 A stage the page does not name, with no note saying so

Every rearing row filed from a stage-less statement now says so (517, 518, 520, 521, 522, 538, 541, 547, 548,
551, 552, 646, 653, 656, 147). Two minor gaps:

| row | page | issue | fix |
|---|---|---|---|
| 558 | Coleman & Fausch 2007a p. 1231 | filed `overwintering`, but the quoted sentence speaks of "recruitment and translocation success"; the note does not say why that is the overwintering cell | add: "Filed as overwintering: recruitment here turns on fry size at the onset of winter (same paragraph, p. 1231; 30-35 mm TL, p. 1241)." |
| 559 | lab paper p. 652 | same: "support consistent recruitment" | add: "Filed as overwintering: the lab paper's recruitment bottleneck is survival from swim-up through the first winter (p. 648)." |

### Not one of the four classes, found during the sweep

- **547 vs the lower-end convention.** 547 stores the upper end of "15-16°C" (16), and its note says so. Every
  other span stored as a single limit holds its lower end, recommendations and measured onsets alike (579,
  580, 581, 585, 596, 601, 607, 617, 620, 648, 673). Either store 15, or keep 16 and name 547 as the exception in
  the research file (Task 3, item 3.6).
- **583 vs 584.** Both are recommended optima in the same Richter paragraph: 583 "led McCullough et al. (2001) to
  recommend an optimum production temperature zone" is `pref`, and 584 "Hicks (2000) recommended that a 7-DAM ...
  provides for optimal growth" is `expert`. This is cosmetic, since both are `optimum` and fill no cell, but they
  should be coded alike.
- **623 `region`** "Pacific Northwest": Richter places Nielsen et al. 1994 in Rancheria Creek, CA (p. 36).
  Consider "northern California".
- **tc `none` notes 531-533 and 553-555** say "Searched the #38 temperature collection (44 items) with grep". Seven
  members have no text: Bear et al. 2005 and 2007 (WCT thermal tolerance and requirements) and McMahon et al.
  2007 (BT) among them. Bear 2005, a report on WCT thermal requirements, is the most likely member to give WCT
  degree-days. The ps notes already say "every member with a PDF". Fix: insert "(the members with a PDF; Bear et
  al. 2005, 2007 and McMahon et al. 2007 have none)" after "(44 items)" in all six notes.
- **Collection membership.** `hagen_weber2019Limitingfactorsa` (rows 546-548) is the only #38 row source that is not
  in `data/temperature_members.csv`, so 0270 will not put it in `Fisheries/temperature`. Add it as a member
  ("cited by a temperature row"), or have the research-file header say it was read from outside the collection.

---

## TASK 3: `research/thermal_requirements.md`

These were checked and match the rows and sources:

- the read snippet, which runs and returns 205 rows;
- the 17 `none` degree-day cells, and the "Every cell has at least one value, except CO rearing lower" claim
  (computed from the rows);
- every degree-day table line's species, window, value, page and base;
- Thorley 2022 p. 30's under-30 mm reading;
- the Hill memos' quote, which is verbatim in both;
- Iacarella 24 °C `7dec`;
- the Richter Table 1 lines;
- Hagen & Weber p. 25 11 °C MWAT;
- Isaak 11 °C August mean;
- Selong 20.9 UILT age-0;
- Cleator p. 4 19.6;
- the DFO Table 2 lines;
- the OCR-garbled B&R list;
- Hasnain's "All metric estimates were derived using adult members of each species";
- the Richter Table 1 species coverage (p. 39).

Findings:

### 3.1 The "No source in the collection" claims are wider than the search (overstated)

- **Lines:** Status ("No source in the collection gives a growing-season degree-day requirement for a BC
  species") and Degree-days ("**No source** in the collection gives degree-days to emergence ... to hatch for WCT
  ...").
- **Why:** 7 of the 44 members have no text and were not read. They include Bear et al. 2005, a WCT
  thermal-requirements report and the likeliest place for WCT degree-days, and McMahon et al. 2007 (BT). The
  `none` rows can only say what was searched.
- **Fix:** "No source read (the collection's members with a PDF; Bear et al. 2005 and 2007 and McMahon et al. 2007
  have none) gives ...", in both places.

### 3.2 "label those values as Colorado River cutthroat" (overstated)

- **Lines:** wet#40 bullet ("label those values as Colorado River cutthroat") and the degree-day table's 2007a line
  (which correctly says "greenback and Colorado River cutthroat").
- **Why:** the 800 and 900-1,200 values are from the field study of greenback and Colorado River cutthroat
  together (rows 557/558 notes, p. 1231). The 900 value is "native cutthroat trout" from the integrated lab
  (Colorado River cutthroat) and field study (row 559 note, p. 652). The rows are coded CRCT only because
  greenback has no code.
- **Fix:** "label those values as Colorado cutthroat (greenback and Colorado River cutthroat; filed as CRCT)". In
  "any WCT GSDD threshold is a transfer from Colorado River cutthroat", write "from Colorado's native cutthroat".

### 3.3 The link#21 recommendation for CH/CO contradicts the metric rule it follows (wrong)

- **Line:** "The Hill models predict weekly means, so `weekly_mean` and `mwat` rows apply directly. A `7dadm` or
  `daily_max` limit needs a daily maximum the models do not produce. ... for CH and CO, 24 °C 7DEC (Iacarella,
  BC)."
- **Why:** Iacarella defines the 7DEC as "the median value between 7DADM and MWAT" (p. 1218; methods), so it
  needs the daily maximum the paragraph has just said the Hill models lack. A weekly-mean prediction compared
  with 24 °C sits below the 7DEC by about half the diel range, so it under-calls exceedance. Iacarella refit a BC
  model to predict 7DEC directly.
- **Fix:** "for CH and CO, 24 °C 7DEC (Iacarella, BC), which needs a 7DEC product (Iacarella's BC model), not the
  Hill weekly means; against a weekly mean it under-calls exceedance. With Hill predictions, the Richter Table 1
  weekly means (15 °C rearing, 10 °C spawning and incubation) are the matching CH/CO/ST rows."

### 3.4 BT spawning line cites rows that do not say "onset, falling" (wrong row)

- **Line:** "BT | spawning | 9–10 °C onset, falling | `unstated` | several, rows 149, 492, 508, 546, 549".
- **Why:**
  - **549** is "Spawning sites rarely exceed 10ºC" (Bustard p. 106, footnote 73: summer mean daily temperatures at
    four streams). That is a site maximum, not an onset.
  - **546**'s own note says "the page does not say whether temperatures are falling".
  - 149 (via its note), 492 and 508 do support onset on falling temperatures.
- **Fix:** "9–10 °C onset as temperatures fall | rows 149, 492, 508 (546 gives 9 °C onset without saying
  falling)". Drop 549, or list it separately as "spawning sites rarely exceed 10 °C (Bustard & Schell p. 106)".

### 3.5 `kind` list omits `param`, and the metric list omits `daily_mean` (incomplete)

- **Why:** two lines of "Values a BC model would most likely use" are `param` (Iacarella row 148/655, Isaak row
  155), and five rows are `daily_mean` (524, 587, 609, 624, 138).
- **Fix:** add "`param` (a value a model or standard sets: the Iacarella and Isaak thresholds)" to the `kind`
  sentence, and "a daily mean" to the first metric bullet. If 2.2 is applied, only 524 remains `daily_mean`.

### 3.6 The lower-end convention: quote and scope (minor)

- **Line:** "A recommended span stored as a limit holds its lower end. Examples are Hicks's '7-DAM of 14 to 17 °C to
  fully protect rearing' ..."
- **Why:**
  - The quoted words are not the source's. Richter p. 32 reads "a recommendation of 14◦ to 17◦ C for the 7-DAM
    to fully protect juvenile coho salmon rearing".
  - The convention also covers measured spans (585, 648, 673, 579).
  - It has one exception, 547 (15-16, stored as 16), and the first convention bullet names "Hagen & Weber's
    15–16 °C" without saying which end is stored.
- **Fix:** "A span stored as a single limit holds its lower end, for recommendations (Hicks's 14-17 °C 7-DAM for
  juvenile coho rearing; a 13.5-14.5 °C single daily maximum) and measured onsets (Burck's 23.8-25.5 °C) alike;
  the note gives the span. Hagen & Weber's 15-16 °C distribution limit is the exception and stores 16." Or change
  547 to 15 and drop the exception.

### 3.7 "Their UILT reaches the table through Cleator et al. 2009 and Thorley et al. 2021" (overstated)

- **Why:**
  - Only Bear et al. **2007** reaches the table.
  - Thorley 2021 gives a survival statement, "survival declines sharply at temperatures above 19ºC (Bear et al.
    2007)" (row 522), not the UILT.
  - Bear 2005 reaches no row. Hasnain cites it for 19.7 C under species-level "Cutthroat Trout", which was not
    filed.
- **Fix:** "Bear et al. 2007 reaches the table as secondary citations: the 19.6 °C UILT through Cleator et al.
  2009 (p. 4) and 'survival declines sharply above 19 °C' through Thorley et al. 2021 (p. 1). Bear et al. 2005
  reaches no row."

### 3.8 template#214 bullet: the 575-600 start point is not stated (overstated, minor)

- **Line:** "Compare degree-days from WCT spawning (...) with the 575–600 to emergence."
- **Why:** row 523's note says "the start of accumulation is not stated". The page says only that "the eggs have
  accumulated 575 to 600 thermal units" (hatchery, Kootenay Trout Hatchery pers. comm.).
- **Fix:** append "(the hatchery figure counts from when the eggs were taken, which the source does not state;
  counting from spawning onset is the nearest field equivalent)".

### 3.9 Smaller wording points

- Degree-day table, CRCT to_emergence: the value on 2007a p. 1234 is cited to the lab paper ("(Coleman and Fausch
  2007)"). Write "Coleman & Fausch 2007a p. 1234 (citing the 2007 laboratory study)".
- "Values with no stage: ... several Chinook and coho lethal limits in Richter & Kolmes pp. 28–36": draft-ps-notes
  also lists Hicks's **steelhead** daily maximum below 19-20 °C (p. 36) and Roberge's coho 25.1 °C (p. 65). Write
  "Chinook, coho and steelhead lethal limits in Richter & Kolmes pp. 28–36 and Roberge et al. 2002 p. 65".
- link#21: "11 °C MWAT (BC) and 11 °C August mean (Isaak) are the network-scale criteria". Neither row carries a
  scale (rows 548 and 155 have it blank). Write "the BC and regional criteria" or similar.
- Header "sources in the group's `Fisheries/temperature` collection": Hagen & Weber 2019 is not a member (Task 2,
  "Collection membership").

---

## Summary of cell changes

| row | column | from | to |
|---|---|---|---|
| 529 | kind | expert | dist (+ note: p. 17 "has been observed") |
| 542 | kind | expert | dist (+ same note) |
| 637 | kind | expert | lab |
| 592 | kind | expert | lab |
| 590 | kind | expert | lab (judgement) |
| 579 | kind | expert | lab (judgement) |
| 646 | kind | expert | lab (and decide Hagen p. 25 14-16 °C stress onset to match) |
| 587, 609, 624, 138 | metric | daily_mean | unstated (or record the keep decision; 138 needs the note either way) |
| 585 | note | "In-stream live-box exposure test." | "Live-box exposure test (a field exposure, not a laboratory one; the page does not say where)." |
| 558, 559 | note | (append) | why recruitment is the overwintering cell |
| 531-533, 553-555 | note | "(44 items)" | "(44 items; the members with a PDF: Bear et al. 2005, 2007 and McMahon et al. 2007 have none)" |
| 547 | value_max | 16 | 15 (or keep it and name the exception in the research file) |
| 653 | metric | unstated | daily_max (optional), or note "instantaneous maximum (no vocabulary term)" |
| 584 or 583 | kind | expert / pref | make them alike (optional) |
| 623 | region | Pacific Northwest | northern California (optional) |
| new | | | Sauter Table 4 spring CH 4.4-17.8 (optional, or a note saying why it was skipped) |
| members | | | add `hagen_weber2019Limitingfactorsa` to `data/temperature_members.csv` |
