# Review round 2: the fixes to the groundwater rows (#36), audited for meaning

Audited 2026-10-07. Scope: only the cells changed since `review-p2-meaning.md`. That means the region of
data rows 501, 502 and 676; the notes of 493, 503, 505, 675, 677-680 and 682-685; the scale of 685; and
new row 686. Each claim was checked against pdftotext of the 2015 plan (PDF 20-21), the 2010 rule
(PDF 33 = p. 63930), Hagen & Weber 2019 (PDF 21 = p. 19), Hagen & Sary 2023 (p. 4 and its reference
list), and the Metolius OCR (pages 10, 32, 40 and 41). Data row N is file line N+1.

Verdict: 2 errors, both in notes. Row 680's "two sentences earlier" is wrong; the first audit introduced
it. Rows 682 and 683 now say "the two incubation rows", which became ambiguous once row 686 added a third.
There is 1 minor wording issue (row 493) and there are 3 optional firm-ups. Everything else is OK.

## Errors

### Row 680 (2010 rule p. 63930, Fraley and Shepard): "two sentences earlier" is wrong
The note says: "The Flathead is named two sentences earlier for the same work and page." The text
runs:
1. "Fraley and Shepard (1989, p. 137) reported the initiation of spawning by bull trout in the Flathead
   River system ... below 10 °C"
2. "Goetz (1989, pp. 22–32) reported ..."
3. "Selection of spawning habitat ... hyporheic flow ..."
4. "Hyporheic flow is influenced by ..."
5. "Spawning areas are often associated with cold-water springs ..."
6. The quoted sentence.

The Flathead is therefore named **five** sentences earlier. "Same work and page" is true, because both
sentences cite Fraley and Shepard 1989, p. 137. The error came from my first-round audit, which suggested
the wording. **Fix:** "The Flathead is named five sentences earlier, in the sentence citing the same work
and page for the 10 C spawning onset (the 2010 rule's temperature row)." Region, scale and the rest of the
note are OK.

### Rows 682 and 683: "the two incubation rows" is now ambiguous
Both notes end "Probably the thesis and its paper, so the two incubation rows are not independent." Row
686 is also a groundwater incubation row, and it sits on the same page as 682. That makes three such
rows, and the phrase no longer says which two are meant. **Fix:**
- Row 682: "... so this row and the 2015 plan p. 6 incubation row are not independent."
- Row 683: "... so this row and the Hagen & Weber p. 19 Halfway River row are not independent."

The rest of both notes is true:
- **Reference lists.** Hagen & Weber and Hagen & Sary list Baxter, J.S. 1997 as an MSc thesis on "the
  reproductive ecology of bull trout ... in the Chowade River, British Columbia". The 2015 plan lists
  Baxter and McPhail 1999 as "The influence of redd site selection, groundwater upwelling, and
  over-winter incubation temperature on survival of bull trout ... from egg to alevin".
- **Row 682, "Pratt 1992 on the same page is its own row":** true (row 686).
- **Row 683, "the sentence before, citing the same work, names the Swan River (that row's note
  questions the citation)":** true. PDF 21 reads "In the Swan River, Montana, ... (Baxter and McPhail,
  1999). Survival of bull trout embryos ... (Baxter and McPhail 1999)".

## Minor

### Row 493 (Metolius p. 36, temperature): the p. 6 clause puts "no spawning documented" on the mainstem
The changed note keeps an older clause: "p. 6: no perennial cold spring areas suitable for spawning exist
in the mainstem Crooked River, where no spawning was ever documented." On OCR p. 10 (printed 6), "no bull
trout spawning was ever documented" closes a sentence about the **upper Crooked River Basin** ("If a
separate spawning population of bull trout existed in the upper Crooked River Basin ..."). The
cold-spring absence is the sentence about the mainstem. **Fix:** "p. 6: no perennial cold spring areas
suitable for spawning exist in the mainstem Crooked River; no spawning was ever documented in the upper
Crooked River Basin." Row 685's note does not repeat the conflation, so after this fix the two rows agree.

The new text in this note is OK. "Spring influence on summer water temperature; the same sentence is also
a groundwater row" is true (row 675). "The sentence itself carries no citation; Riehle 1993 closes the
paragraph's third sentence" is true. The paragraph runs "Summer water temperatures ... cold springs." /
"Roaring and Candle creeks ... 4-6°C." / "In all spawning streams, temperatures fell below 9°C before
spawning began (Riehle 1993)."

## OK

- **Rows 501, 502 and 676 (region, "citing Montana and northern BC studies"):** OK, and the three rows
  are coded alike.
  - Baxter 1997 (Chowade River, BC) and Williamson 2006 ("pristine streams of northern British
    Columbia") are northern BC, by their reference-list titles.
  - Graham et al. 1981 (Flathead) and Baxter and Hauer 2000 (Swan River) are Montana. That is known from
    the literature, not from this report's reference list: neither title names a place.
  - My first audit said the reference list placed all four, which overstated it for those two. The
    region is still right.
- **Row 503 (2015 plan p. 5, temperature):** "Cold water; the same sentence is also a groundwater row"
  is true (row 677). The p. 6 'Redds are often constructed ...' quote is verbatim (PDF 21).
- **Rows 505 and 678 (Swan River, valley_width_index and groundwater):**
  - The attribution text is identical on both rows, and true:
    - The plan's reference list titles Baxter and McPhail 1999 as above, so "egg-to-alevin survival
      study (redd site selection, groundwater upwelling, incubation temperature)" is accurate.
    - Baxter, Frissell and Hauer 1999 is in the list as TAFS 128:854-867, "Geomorphology, logging
      roads, and the distribution of bull trout spawning in a forested river basin".
    - "Neither paper read" is honest.
  - Dropping the Baxter and Hauer 2000 speculation from 505 is right.
  - 678's "the plan's inference ('likely')" and "see its note" are fine.
- **Row 675 (Metolius p. 36, groundwater):**
  - The Riehle sentence is true, as on row 493.
  - "The same sentence is the temperature row" is true (row 493).
  - "The p. 6 Crooked River contrast and the p. 28 spring spawning sites are their own groundwater rows"
    is true (rows 685 and 684).
  - cited_source Riehle 1993 is kept, as on row 493: coded alike.
- **Row 677 (2015 plan p. 5, groundwater):**
  - The 2010 rule's parallel sentence is quoted verbatim, and it cites "Rieman et al. 1997, p. 1121;
    Baxter et al. 1999, p. 137". Both author-years are in this row's list. It adds glacial and snow
    melt.
  - The p. 6 Redds sentence is cited correctly (Goetz 1989; Pratt 1992; Rieman and McIntyre 1993), and
    the shared pair is right.
  - Optional firm-up: the rule's "Baxter et al. 1999, p. 137" cannot be a page of TAFS 128:854-867, and
    the rule prints no reference list ("A complete list of all references cited ..." points elsewhere).
    The identity with the plan's Baxter et al. 1999 therefore rests on author and year. The redundancy
    argument still holds, because the claim is the same.
- **Row 679 (2010 rule, hyporheic):** all three claims are true. The springs and upwelling sentence is
  on the same page and is quoted in row 677's note. Hagen & Sary p. 4 cites Baxter and Hauer 2000.
  "Partly dependent" is exact.
- **Row 684 (Metolius p. 28 = OCR 32):** "excluded from the tributary redd-count trend (Table 4)"
  matches the text: "For those tributaries surveyed since 1986 (excluding the Metolius River near the
  mouth of Jack Creek and at Heising Springs), the number of redds counted ... (Table 4)". "A
  spring-influenced area of the mainstem" is the Metolius River near Jack Creek mouth. OK.
- **Row 685 (Metolius p. 6 = OCR 10):** blank scale with "covers the whole mainstem" is consistent with
  the vocabulary (no surveyed reach) and with row 679's blank-scale reasoning. The note is accurate:
  - wandering individuals "from other Deschutes River Basin populations";
  - "no perennial 'cold' spring areas suitable for bull trout spawning exist in the mainstem Crooked
    River";
  - the absence is the authors' statement.

  Region "Crooked River, Oregon" and the blank life_history_form are fine.
- **Row 686 (new: Hagen & Weber p. 19, Pratt 1992):** coding is right, with one judgment point below.
  - The quote is verbatim on PDF 21 (printed 19).
  - `incubation` is right: the passage is the Early life history section, and the sentence before says
    "Emergence success is negatively related to the proportion of fine substrates present in the redd
    site".
  - cited_source Pratt 1992 is printed in the sentence and is in the reference list ("A review of Bull
    Trout life history", Gearhart Mountain workshop).
  - The region matches row 681, its groundwater sibling from the same report: coded alike.
  - kind `qual`, the "Hedged ('may')" note, "from the sentence before" and "Same page as the Halfway
    River experiment row" are all true.
  - **Scale, judgment:** blank is defensible, because the sentence names no grain. But the effect is in
    the redd site (named in the sentence the note draws on), and rows 681 and 682 on the same topic are
    `site`. Recommend `site`. Low priority.
  - **Optional firm-up:** the source says "groundwater **or streambed recharge**", and the note
    paraphrases this as groundwater alone. Row 683 found *lower* embryo survival in areas of
    surface-water recharge. Suggested addition: "The source pairs groundwater with 'streambed recharge';
    the 2015 plan p. 6 incubation row found lower survival in surface-water recharge areas, so only the
    groundwater half is this variable."
  - Optional consistency check: another row with Pratt 1992 as a cited source uses "Pacific Northwest
    (review)" (row 106). The report-level region is the better match to row 681, so no change.

## Not re-flagged
In round 1, the Metolius pp. 36-37 incubation-buffering sentences were proposed as a candidate row. The
parent recorded in findings.md why they are not a groundwater row (the mechanism is temperature and
oxygen). That is a reasonable call, and it was not re-audited.
