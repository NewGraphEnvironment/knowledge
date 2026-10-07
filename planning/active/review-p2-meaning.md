# Review: groundwater rows (#36), audited for meaning

Audited 2026-10-07. Scope: data rows 675-685 of `data/literature_evidence.csv` (all `groundwater`, `qual`)
and the edited `note` on rows 493 and 503. Every quote was read inside its full paragraph in the source:
pdftotext for the 2015 plan, the 2010 rule, Hagen & Weber 2019 and Hagen & Sary 2023 (extracted for this
audit), and the OCR for the Metolius report. Reference-list entries were read where a note makes a
claim about attribution.

Verdict: 4 errors (rows 676, 677, 678, and cited_source on 675 together with 493), 3 groundwater statements
that are in scope and not yet rows, and 3 notes that can be firmed up because a cheap check now settles them.
Everything else is OK.

## Errors

### Row 676 (Hagen & Sary 2023 p. 4): wrong `region`. Same error on its sibling elevation and valley_width_index rows
`region` reads "General statement in a Williston Reservoir watershed report, citing mostly Montana studies".
The sentence cites four works, and the report's own reference list places them:
- Graham et al. 1981: Flathead, Montana.
- Baxter 1997: MSc thesis, "reproductive ecology of bull trout ... in the Chowade River, British Columbia".
- Baxter and Hauer 2000: Montana (CJFAS 57:1470).
- Williamson 2006: MSc thesis, "pristine streams of northern British Columbia".

That makes two Montana works and two northern BC works, so "mostly Montana" is wrong. **Fix:** "General
statement in a Williston Reservoir watershed report, citing Montana and northern BC studies", on row 676
and on the two pre-existing sibling rows from the same sentence (the elevation and valley_width_index rows,
Hagen & Sary p. 4), so the three rows stay coded alike.
Page (printed 4 = PDF 10), scale `reach`, cited_source and the note are OK.

### Row 677 (2015 plan p. 5): the note's reason for not making the 2010 sentence a row is muddled
The note says: "The 2015 plan restates the rule elsewhere, so that sentence is not a second row." That
reason says nothing about this sentence. The parallel sentence in the 2010 rule is real and verbatim as
quoted (p. 63930: "Spawning areas are often associated with cold-water springs, glacial and snow melt, or
groundwater upwelling (Rieman et al. 1997, p. 1121; Baxter et al. 1999, p. 137)"). What actually makes it
redundant is narrower. **Fix:** replace that sentence with "Same agency and same claim, and both of its
citations (Rieman et al. 1997; Baxter et al. 1999) are in this row's list, so it is not a second row; it
adds glacial and snow melt, which is not groundwater."
Everything else in this row is OK: life_stage, page (PDF 20 = p. 5), scale `reach` (matching the
temperature row), the cited_source list, and the p. 6 'Redds are often constructed ...' quote.

### Row 678 (2015 plan p. 6, Swan River): the attribution needs a note, and the evidence for it is in the plan
`cited_source = Baxter and McPhail 1999` is what the plan prints, so the field is right. The plan's own
reference list shows that the citation probably does not support the Swan River claim:
- **Baxter, J.S., and J.D. McPhail. 1999.** "The influence of redd site selection, groundwater upwelling,
  and over-winter incubation temperature on survival of bull trout ... from egg to alevin." Can. J. Zool.
  77:1233. This is an egg-to-alevin survival study, and the next sentence of the plan (row 683) cites it
  for exactly that.
- **Baxter, C.V., C.A. Frissell, and F.R. Hauer. 1999.** "Geomorphology, logging roads, and the
  distribution of bull trout spawning in a forested river basin." TAFS 128:854. This is the study of redd
  distribution against valley geomorphology.

The Swan River bounded-alluvial-valley correlation therefore matches the title of Baxter et al. 1999 and
not that of Baxter and McPhail 1999. Domain knowledge agrees, though no PDF of either paper was read here:
Baxter et al. 1999 is the Swan River basin study, and Baxter and McPhail 1999 worked in the Chowade River,
BC.

The current note sends the reader to the valley_width_index row, whose note says "Attribution not checked"
and points at Baxter and Hauer 2000. **Fix (both rows):** keep the cited_source as printed, and say in
the note: "The plan cites Baxter and McPhail 1999, which its reference list titles as an egg-to-alevin
survival study. The Swan River redd/valley result matches the title of Baxter, Frissell and Hauer 1999
(TAFS 128:854), also in the list, so this is probably a citation slip in the plan. Not checked against
either paper." Then drop the Baxter and Hauer 2000 speculation from the valley_width_index note, or keep it
as secondary.
Region (Swan River, Montana), scale `network`, page and the "'likely' is the plan's inference" sentence
are OK.

### Rows 675 and 493 (Metolius p. 36): `cited_source = Riehle 1993` is not cited by the quoted sentence
The quote is the first sentence of the paragraph, and it carries no citation. "(Riehle 1993)" closes the
third sentence ("In all spawning streams, temperatures fell below 9°C before spawning began"). Reading the
whole paragraph as Riehle's monitoring is plausible, because the habitat section cites Riehle 1993
throughout. Still, it is an inference, and `cited_source` is meant to hold the studies the quote itself
cites. **Fix:** keep Riehle 1993 and add to both notes "The sentence itself carries no citation; Riehle
1993 closes the paragraph's third sentence." Alternatively, blank cited_source on both rows. Either way,
change the two rows together.
Everything else is OK. Row 675: life_stage `spawning` ("streams used ... for spawning and rearing"),
`migratory`, region, page (OCR 40 = p. 36), scale `reach`. Its note claims are true: rows 684 (p. 28) and
685 (p. 6) exist as groundwater rows.

## OK

- **Row 493 (edited note):** "Spring influence on summer water temperature; the same sentence is also a
  groundwater row" is true (row 675). The rest of the note was not changed. Apply the cited_source caveat
  above.
- **Row 503 (edited note):** "Cold water; the same sentence is also a groundwater row" is true (row 677).
- **Row 679 (2010 rule p. 63930, hyporheic):** life_stage, region (the rule names no stream) and page are
  OK. Blank scale is justified by "across multiple spatial scales". Both note claims are true: the springs
  and upwelling sentence is on the same page and is quoted in row 677's note, and Hagen & Sary p. 4 cites
  Baxter and Hauer 2000 (CJFAS 57:1470, the same paper). "Not independent" overstates slightly, because
  Hagen & Sary cites three other works too. "Partly dependent" would be exact. Optional.
- **Row 680 (2010 rule p. 63930, Fraley and Shepard):** life_stage, scale `site` ("spawning site
  selection") and the note are true. The quoted sentence does not name the Flathead. The region comes from
  two sentences earlier in the same paragraph ("Fraley and Shepard (1989, p. 137) reported ... in the
  Flathead River system"), which is the same work and the same page, and the 2015 plan's reference list
  titles the paper "... in the Flathead Lake and River System, Montana". This matches row 508. Optional:
  add "Flathead named two sentences earlier for the same work and page" to the note. The next sentence
  ("the combination of relatively specific requirements resulted in a restricted spawning distribution")
  could also go in the note. Optional.
- **Row 681 (Hagen & Weber p. 22 = PDF 24):** life_stage, region, scale `site`, cited_source (six works,
  matching the text) and the note ("larger streams only"; the smaller-stream clause is J. Hagen's personal
  observation) are all correct.
- **Row 682 (Hagen & Weber p. 19 = PDF 21):** `incubation` (egg-to-alevin survival), region Halfway River,
  BC (stated in the text; Baxter 1997 is the Chowade River thesis, and the Chowade drains to the Halfway),
  scale `site` and cited_source are OK. The note's "same page" claim about Pratt 1992 is verbatim-true. See
  firm-ups below.
- **Row 683 (2015 plan p. 6):** `incubation`, scale `site` and cited_source are OK. "The plan names no
  study stream" is true of this sentence. However, the sentence before it cites the same work and names
  the Swan River, so a reader of the plan would assume Swan River (see row 678). Suggest: "The plan names
  no study stream here; the preceding sentence, citing the same work, names the Swan River (see that row)."
  Region "Coterminous United States (review)" is the right call given that.
- **Row 684 (Metolius p. 28 = OCR 32):** OK. Life_stage, `migratory`, region, scale `site` and an empty
  cited_source (the report's own observation) are all right. "Outside the surveyed tributaries" is
  accurate in substance. The text says the trend counts are "for those tributaries surveyed since 1986
  (excluding the Metolius River near the mouth of Jack Creek and at Heising Springs)". "Excluded from the
  tributary trend counts (Table 4)" would be more exact. Optional.
- **Row 685 (Metolius p. 6 = OCR 10):** OK. The note is accurate: the absence is the authors' explanation
  for wandering fish, not a survey result, and "no bull trout spawning was ever documented" refers to the
  upper Crooked River Basin. One judgment point: the statement covers the whole mainstem Crooked River (the
  fish ranged to Prineville, RK 77), not a surveyed reach. `segment` or blank fits the vocabulary
  ("a surveyed `reach`") better than `reach`. Low priority.

## Firm-ups (the notes are correct; a check costing one grep now settles them)

- **Rows 682 and 683, "Possibly the same work ... not checked":** the reference lists settle most of it.
  - Hagen & Weber list Baxter, J.S. 1997 as an MSc thesis on bull trout reproductive ecology in the
    Chowade River, BC.
  - The 2015 plan lists Baxter, J.S. and J.D. McPhail 1999 as the egg-to-alevin paper on redd site
    selection and groundwater upwelling (Can. J. Zool. 77:1233).

  Same first author, same topic, and the paper came out two years after the thesis: very likely the thesis
  and its journal paper. **Suggest** both notes say: "Reference lists: Baxter 1997 is J.S. Baxter's MSc
  thesis (Chowade River, BC); Baxter and McPhail 1999 is the egg-to-alevin groundwater-upwelling paper.
  Very likely the same study, so the two rows are not independent."

## Groundwater statements in scope that are not rows

1. **Hagen & Weber 2019 p. 19, Pratt 1992.** "However, where present, groundwater or streambed recharge
   may compensate for the negative effects of fines (Pratt 1992)."
   - Ties groundwater to egg and emergence survival: incubation, `qual`.
   - It is a distinct claim from a distinct source, and it appears today only inside row 682's note.
   - **Candidate row:** BT, incubation, groundwater, qual, region "General statement in a Williston
     Reservoir watershed report (review)", page 19, scale blank or `site`, cited_source Pratt 1992.

2. **2015 plan p. 6, redds near springs.** "Redds are often constructed in stream reaches fed by springs or
   near other sources of cold groundwater (Goetz 1989; Pratt 1992; Rieman and McIntyre 1993)."
   - A reach-scale spawning claim. It is quoted in the notes of rows 503 and 677 but is not a row, and
     neither note says why.
   - Its citation set differs from the p. 5 sentence: it adds Goetz 1989, and the p. 5 sentence adds
     Rieman et al. 1997, Baxter and McPhail 1999 and Baxter et al. 1999.
   - **Either** make it a row (spawning, groundwater, qual, p. 6, `reach`, cited_source Goetz 1989; Pratt
     1992; Rieman and McIntyre 1993), **or** give row 677's note the reason it is not one: "Same plan,
     same claim, sharing Pratt 1992 and Rieman and McIntyre 1993 with this row, so not a separate row."

3. **Metolius report pp. 36-37, cold springs and embryo survival under sediment.**
   - p. 36, straight after the quoted spring sentence: "These cold water conditions may help buffer the
     negative effects of sedimentation on egg-to-emergence survival, as salmonid embryos require lower
     oxygen concentrations at cooler water temperatures."
   - p. 37: "at the extremely cold water temperatures from tributaries and springs, incubating bull trout
     embryos use less oxygen and therefore the adverse effects of sedimentation inputs may be partially
     mitigated."
   - Both tie springs to incubation survival. Both are the authors' inference ("may"), with no citation.
   - No Metolius incubation row exists for either.
   - **Candidate row:** BT, incubation, migratory, groundwater, qual, Metolius River basin, Oregon, p. 37,
     scale blank, no cited_source, with a note marking it as the authors' hypothesis. The p. 36 sentence
     goes in the note.
   - Whether it belongs under `groundwater` or `temperature` is a coding choice. The mechanism the text
     names is cold water from springs.

Not flagged, off the audited pages: Hagen & Sary 2023 has management text, not habitat evidence, saying
that floodplain areas where groundwater processes affect spawning sites are "of especially high value"
(Baxter et al. 1999, 2000; Bean et al. 2015).
