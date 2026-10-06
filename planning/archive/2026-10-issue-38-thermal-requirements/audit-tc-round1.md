# Audit, round 1: trout and char temperature and degree-day rows (data rows 511-559)

I checked all 49 rows (23 WCT, 22 BT, 4 CRCT) against their pages, reading each quote in its PDF page
context, plus the printed page numbers. For the 6 `none` rows I grepped every collection text (`*.txt`,
`*.ocr.txt`) for degree-day, degreedays, thermal unit, temperature units, ATU, CTU and GSDD within 300
characters of westslope, cutthroat, bull trout, char or Salvelinus. I also grepped the WCT and BT documents
for growing season, hatch, emergence and swim-up. The only hits are the values already in rows 523, 534 and
556-559, site statistics (O'Connor Table 4 ATU, Hill GSDD predictions), and the Hill GSDD definition with no
requirement. Every `none` search claim holds, and no row is missing for a degree-day cell.

Six findings: 3 wrong, 2 overstated, 1 missing.

## 1. Row 522: `kind` should be `lab` (wrong)

- **Page:** Thorley et al. 2021, p. 1 (PDF 9): "survival declines sharply at temperatures above 19ºC (Bear et
  al. 2007)". This reports the laboratory study that row 521 files as `lab`. The row's own `region` says
  "citing a laboratory study", and its note says "Same study as the 19.6 C UILT".
- **Wrong:** `kind` is `expert`. Nothing on the page is a recommendation or a criterion. It is a reported
  laboratory survival result, the same thing row 521 holds as `lab`.
- **Fix:** `kind` = `lab`. Keep `metric` = `unstated`, because the page does not say the temperatures were
  held.

## 2. Row 556: `kind` should be `lab` (wrong)

- **Page:** Coleman and Fausch 2007a, p. 1234: "fry begin to emerge from redds after 570–600 Celsius
  degree-days have accumulated (Coleman and Fausch 2007)". The citation is the companion laboratory paper.
  The row's `region` ("laboratory value cited") and its note ("The cited 2007 laboratory study used Colorado
  River cutthroat") both call it a laboratory value.
- **Wrong:** `kind` = `expert`. This is a cited laboratory development figure, not a recommendation.
- **Fix:** `kind` = `lab`.

## 3. Row 542: `kind` `pref` disagrees with its own table (wrong)

- **Page:** Sauter et al. 2001, p. 18 (PDF 20), Table 4: "Selected water temperatures for spawning by Pacific
  Northwest salmonids. For the purpose of water temperature criteria protective of spawning salmonids, these
  references are assumed to be Daily Average Temperatures". The bull trout cell reads "peak: <44.6 (<7)".
- **Wrong:** Row 529 is the WCT row from the same table, and it is `expert`, correctly: the table selects
  values for criteria. Row 542 files the bull trout cell as `pref`, but the table states no preference.
  "Peak" is when spawning peaks, inside a list of temperatures selected for criteria.
- **Fix:** `kind` = `expert`. `bound` = `optimum` with `value_max` 7 can stay, since the note says no lower
  end is given.

## 4. Rows 557 and 558: wrong pages and a shortened growing-season definition in the notes (overstated)

- **Page:** Coleman and Fausch 2007a. The growing-season limits are defined on pp. 1232-1233: "the beginning
  of the first week that average stream temperatures exceeded and remained above 5°C for the season; the end
  of the growing season was defined as the last day of the first week that average stream temperature
  dropped below 4°C". Summing daily means into GSDD is on p. 1234. The 30-35 mm statement is on **p. 1241**
  (PDF 11), not 1240: "cutthroat trout fry need to reach a minimum of 30–35 mm TL by the onset of winter to
  allow recruitment to age 1".
- **Wrong:** Both notes cite "(p. 1234)" for the start and end rules. Both also shorten the start rule to
  "first week averaging above 5 C" and drop "and remained above 5 C for the season". The Hill memos quote the
  full rule, and `gsdd` implements it. Row 557 also cites the 30-35 mm statement as "Discussion (p. 1240)".
- **Fix (557 note):** "GSDD sums daily mean temperatures (in effect base 0 C) from the start of the first week
  whose average exceeded and remained above 5 C for the season to the last day of the first week averaging
  below 4 C (pp. 1232-1234). Field study of greenback and Colorado River cutthroat together; streams of
  800-900 'probably sustain recruitment in some years'. Discussion (p. 1241): fry need 30-35 mm TL by the
  onset of winter."
- **Fix (558 note):** the same definition sentence with "(pp. 1232-1234)", then the rest of the current note
  unchanged.

## 5. Row 559: the note omits that the page speaks of native cutthroat generally (overstated)

- **Page:** Coleman and Fausch 2007 (lab), p. 652: "The results of our integrated laboratory and field study
  indicate that locating streams with growing seasons warm enough to support consistent recruitment (.900
  degree-days) will be a key to increasing translocation success of native cutthroat trout in southern Rocky
  Mountain streams."
- **Wrong:** The row is filed as CRCT, and its note does not say that the sentence is about "native cutthroat
  trout" from the combined laboratory (Colorado River cutthroat) and field (greenback and Colorado River
  cutthroat) studies. Rows 557 and 558 both state that grouping; this row stores a multi-subspecies value as
  CRCT without a word about it.
- **Fix (note):** add "The sentence is about native cutthroat trout in southern Rocky Mountain streams, from
  the integrated laboratory study (Colorado River cutthroat) and field study (greenback and Colorado River
  cutthroat)." Keep the rest.

## 6. Sauter Table 4 bull trout "cessation: >50 (>10)": the notes say it was written, but no row exists (missing)

- **Page:** Sauter et al. 2001, p. 18 (PDF 20), Table 4, bull trout: "peak: <44.6 (<7)" / "cessation: >50
  (>10)" (Goetz 1989; Pratt 1992; Kraemer 1994; Fraley and Shepard 1989; James and Sexauer 1997; Wydoski and
  Whitney 1979).
- **Missing:** `draft-tc-notes.md` lists "10 (Sauter Table 4, 'cessation >10')" as a new BT spawning upper
  value and discusses how to read it. It is not in `draft-tc-evidence.csv` or in `data/literature_evidence.csv`
  (grep "cessation" finds only rows 535 and 599). Either it was dropped without a record, or it was never
  written.
- **Fix:** add the row: BT, spawning, `temperature`, `bound` `max`, `value_max` 10, degC, `metric` `unstated`
  (the header's DAT is an assumption, as row 529 notes), `kind` `expert` (as row 529), region "Pacific
  Northwest (review)", `sauter_etal2001Issuepaper`, page 18, `quote_source` `table`, `cited_source` as row 542.
  The note should say: "Table 4 'cessation: >10'; the table does not define cessation; read as spawning
  ceasing above 10 C. PDF page 20." The table quote must be that line's tokens in layout order, so it may need
  the citation fragment on the same line ("cessation: >50 (>10) Fraley and Shepard 1989; James and"). Check it
  at the gate. If the term is judged too unclear to file, record that decision in the notes instead, and
  remove the claim from the cell table.

## Judgement calls, not flagged

- Rows 523 and 534 (hatchery thermal units to emergence and to hatch) are `expert`. The drafter chose this
  before `lab` existed. A hatchery development figure is closer to `lab` than to a recommendation. Decide this
  once for the hatchery rows, the way it was decided for the UILT rows.
- Row 551: O'Connor p. 23 names no stage. The same report applies the 11 C threshold to spawning habitats
  (p. 33: "monitored spawning habitats are meeting thermal habitat requirements of Bull Trout (i.e., <11ºC;
  Parkinson et al. 2016)"), and Table 4 (p. 24) applies it across the migration, spawning, incubation and
  rearing periods. Filing it under rearing follows the accepted convention. The note could add that the report
  applies it in all four periods.
- Rows 549 and 550: `scale` = `reach` for statements about Morice spawning sites and rearing areas in general
  (the footnote covers four streams). `network`, or blank, may fit better. The page does not settle it.
