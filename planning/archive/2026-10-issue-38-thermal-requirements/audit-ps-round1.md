# Audit, round 1: `ps` thermal rows (CH, CO, ST), data rows 560-673

I checked all 114 rows (560-673) against their pages: Richter & Kolmes 2005 pp. 27-39; Sauter et al. 2001
Table 4 (p. 18); Bjornn & Reiser 1991 OCR pp. 91-92, 106-107, 112-114; Raleigh et al. 1986 pp. 4, 6, 8-9;
Hasnain et al. Table A2 (p. 39); Lusardi et al. 2020 pp. 414 and 421; Iacarella et al. 2024 p. 1218;
Eaton & Scheller 1996 Table 1; Cooney & Holzer 2006 p. C-9; Bustard & Schell 2002 p. 67. For the 12 `none`
rows I grepped every txt file for degree-day wording. I found 13 findings covering 22 rows, plus one
missed value and two advisories. The rows not listed below match their pages.

## Settled checks (not errors)

- **Richter & Kolmes Table 1 applied to CO and ST (563-574)** has support in the review. Table 1 has no
  species column, and its only species-specific row is "Smoltification except steelhead" / "Steelhead
  smoltification", so the other rows cover steelhead too. Pp. 38-39 then discuss the spawning and
  incubation criterion for chinook, coho, chum and steelhead in turn, and the rearing criterion for each
  of them. The p. 39 notes on the CO and ST rows are accurate.
- Page numbers, `cited_source`, species, and the values all match. Sauter Table 4 is on printed p. 18:
  the "17" just above it in the layout text is the previous page's footer.
- The `none`-row search holds up. The only degree-day figures for salmon in the corpus are Raleigh p. 4
  (already row 637); Bjornn & Reiser p. 103, which gives 200-390 temperature units (Alderdice et al. 1958,
  embryo hypoxia sensitivity, no species named, and Alderdice studied chum); and B&R Table 4.7, 670
  degree-days to 50% hatch, which is sockeye. Roberge p. 64 (coho, 137 d to hatch at 2.2 C) and B&R
  pp. 106-107 say what the notes say. None of the `none` notes claims that no value exists.

## Findings

### 1. Rows 626, 627, 628 (Sauter Table 4): `metric` daily_mean is wrong
- **Severity:** wrong.
- **What's wrong:** the row records the statistic as known. The source says it is not.
- **Page:** p. 17, the text that introduces Table 4: "The temperature metrics are not given with these
  studies but are assumed to be either instantaneous or daily average temperatures (DAT) at the time of
  spawning." The Table 4 caption says the references "are assumed to be Daily Average Temperatures (DAT)"
  for criteria purposes. The existing WCT row from the same table (data row 529) already uses `unstated`.
- **Fix:** `metric` = `unstated` on all three. Change the note to: "Table 4 'selected' spawning
  temperatures. The paper says the original studies give no metric, and assumes instantaneous or daily
  average temperatures (p. 17) and DAT for criteria purposes. Table prints F with C in brackets." Keep
  "Fall/summer-run Chinook." at the front of row 628's note.

### 2. Row 646 (Hasnain Table A2, coho spawning 4.4-7.7): bound and region overstated
- **Severity:** overstated.
- **What's wrong:** the row is `range` / `dist`, filling both spawning limit cells.
- **Page:** p. 39. The Table A2 caption reads "Reproductive thermal data (optimum spawning temperature
  [OS] and optimum egg development temperature [OE])". Hasnain defines OS as "that at which spawning
  reaches its peak". So the 4.4-7.7 in the "Temperature Range" column is the table's optimum-spawning
  datum given as a span, not the limits of spawning. The value comes from Wismer & Christie (1987),
  "Temperature Relationships of Great Lakes Fishes: A Data Compilation".
- **Fix:** `bound` = `optimum`, `kind` = `pref`, `region` = "Great Lakes (compilation)". Note: "Table A2,
  reproductive thermal data (optimum spawning temperature); the span sits in the table's 'Temperature
  Range' column, with no single optimum given; from Wismer and Christie (1987), a Great Lakes compilation."
  Coho spawning limit cells stay filled by other rows.

### 3. Rows 593 and 618: the upper edge of an optimum, stored as a limit
- **Severity:** overstated.
- **What's wrong:** both are stored as a `max`, which reads as a harm limit. Row 618 also takes the lower
  end of a span, a convention accepted only when the span is a limit.
- **Page:**
  - Row 618, p. 35: "McCullough et al. (2001) suggested an optimal constant incubation temperature occurs
    below 11–12 C". That is the top of an optimal range.
  - Row 593, p. 32: "A constant 12 C may form the upper threshold for optimal development of coho salmon
    eggs and alevin". This is the same kind of statement.
  - Neither says harm begins there.
- **Fix:**
  - Row 618: `bound` = `optimum`, `value_min` blank, `value_max` = 12 (or 11, stated in the note),
    `kind` = `expert`. Note: "Optimal constant incubation is below 11-12 C; this is the upper edge of the
    optimum, not a harm limit."
  - Row 593: `bound` = `optimum`, `value_min` blank, `value_max` = 12. Note: "Upper threshold for optimal
    development of eggs and alevins; the edge of the optimum, not a harm limit."
  - The CO and ST incubation upper cells stay filled by other rows.

### 4. Rows 585, 594, 595, 599, 639: `kind` expert on a measured result
- **Severity:** wrong.
- **What's wrong:** `expert` means a recommendation, criterion or opinion. Each of these quotes reports a
  measured outcome.
- **Page:**
  - Row 585, p. 31: "Using live-box tests on juveniles, Burck (1993) found high mortalities with daily
    maximums in the range of 23.8–25.5 C."
  - Row 594, p. 32: "Murray and McPhail (1988) reported increased mortality above 11 C".
  - Row 595, p. 32: "Brett (1952) and Reiser and Bjornn (1979) reported egg mortality at 14 C."
  - Row 599, p. 32: "Cessation of growth has been reported above 20.3 C". This is the same kind of value
    as row 622 (growth zero at 22.5 C), which is `lab`.
  - Row 639, Raleigh p. 6: "temperatures >12.8 C resulted in increased mortality to females prior to
    spawning (Andrew and Geen 1960)".
- **Fix:**
  - Rows 594, 595, 599: `kind` = `lab`, matching rows 613 and 616 ("Rombough found elevated embryonic
    mortality", "Survival became very poor").
  - Row 585: `kind` = `lab`. Add "In-stream live-box exposure test" to the note.
  - Row 639: `kind` = `dist`, or `lab` if the original was an exposure. The page does not say, so `dist`
    with "reported effect" in the note.
  - Row 594's note says "embryo mortality". The page says only "increased mortality", in the incubation
    section, so make it: "Increased mortality above 11 C (under 'Incubation and Early Fry
    Development'; the page does not name the stage)."

### 5. Row 639: life stage is adult pre-spawn mortality
- **Severity:** overstated.
- **What's wrong:** the row sits in the CH `spawning` upper-limit cell, as if 12.8 C were a limit on
  spawning-ground temperature. The page reports mortality of adult females before spawning, which is
  the holding stage. The brief says holding values are left out or put in notes, and the audit brief
  says pre-spawn mortality is not a rearing or spawning-habitat value.
- **Page:** p. 6: "increased mortality to females prior to spawning (Andrew and Geen 1960)".
- **Fix:** move the value to `draft-ps-notes.md` ("found but not entered: adult pre-spawn holding").
  Alternatively keep it as `spawning` with the note: "Adult pre-spawning mortality of females above
  12.8 C (holding adults), not a spawning-ground temperature limit." The CH spawning upper cell is
  filled by other rows either way.

### 6. Row 580: spawning versus incubation, and an inconsistency with row 596
- **Severity:** wrong (stage).
- **What's wrong:** the row puts Hicks's 11-12 C 7-DAM "at the time of fertilization" under spawning.
  On the page it is printed under "Incubation and Early Fry Development", and it protects the eggs.
  Row 596 applies the opposite rule: it files "to fully support the pre-emergent states" under
  incubation because of the stage protected, even though it is printed under a rearing heading.
- **Page:** p. 30, under the heading "Incubation and Early Fry Development": "Hicks (2000) recommended an
  adjusted 7-day average of the daily maximum temperatures (7-DAM) of 11 to 12 C at the time of
  fertilization of chinook salmon eggs".
- **Fix:** `life_stage` = `incubation`. Note: "Recommended 7DADM of 11-12 C at the time of fertilization of
  the eggs (printed under 'Incubation and Early Fry Development'); the value is the lower end." If
  spawning is kept, the note must at least name the heading.

### 7. Rows 647, 654, 657: life stage not named, and the note does not say so
- **Severity:** overstated.
- **What's wrong:** each is filed as `rearing` from a statement that names no stage.
- **Page:**
  - Row 647, Lusardi p. 414: "Coho salmon ... experience thermal stress at water temperatures as low as
    16 C (Brett 1952)". This is said of the species. Juveniles are named only in the next sentence.
  - Row 654, Lusardi p. 421: "Stenhouse et al. (2012) recommended an instantaneous maximum temperature of
    15.5 C for coho salmon in the Shasta River". No stage.
  - Row 657, Eaton & Scheller Table 1: a species-level "maximum weekly average temperature tolerance"
    from FTDMS distribution records. No stage.
- **Fix:** keep `rearing`, and add to each note: "The page names no life stage; filed as rearing from
  context (a juvenile summer study / species-level tolerance)." For row 657, follow whatever convention
  the existing CH Eaton row 147 sets; it has the same gap.

## Missed value (filled cell, outside the `none` rows)

### 8. Richter & Kolmes p. 30, CH incubation: a Hicks mortality range is not in the table
- **Severity:** missing.
- **What's missing:** "Incubation temperatures of 9.9–16.7 C produced significant mortality, with
  complete mortality from 13.9–19.4 C (Hicks, 2000)." The brief asks for every value a source gives for a
  cell, and this value is in no row.
- **Fix:** a CH incubation `max` row, value 9.9, `metric` `unstated`, `kind` `lab`, `cited_source`
  "Hicks 2000". Note: "Significant mortality at 9.9-16.7 C, complete mortality at 13.9-19.4 C; the value is
  the lower end of the significant-mortality range." A second row for 13.9 (complete mortality) is
  optional.

## Advisory (judgment calls, not errors against the page)

- **Rows 587, 609, 624 (Richter "DAT"):** Richter labels these daily average temperatures, so
  `daily_mean` is what the page says. But for the same Bell 1991 and Raleigh values, Sauter p. 17 (which
  Richter cites) says the original studies give no metric and that DAT is an assumption. Consider
  `unstated` with a note naming Sauter, or at least add that sentence to each note, so the label is not
  read as a measured statistic. Row 641, Raleigh's own page, is already `unstated`.
- **Row 673 (CO rearing lower, `none`):** Bjornn & Reiser p. 113 gives a value with no species named:
  "lower lethal temperatures for most species are near 0 C" (generic salmonids). The note's search
  claim stands, and that sentence could be mentioned there as found but not species-specific.
