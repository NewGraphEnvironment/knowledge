# Drafter notes: trout and char (`tc`), #47

19 rows, data rows 1103-1121 (file lines 1104-1122 once appended after the current 1,102). All 19 pass `0280`
(`verified_text`) against the merged table, and the run printed no new failure (coverage, thermal and flow cells
all still met). Printed page numbers were checked against the PDF page each quote matched.

| data row | species | stage | variable | bound / kind | source |
|---|---|---|---|---|---|
| 1103 | CRCT | overwintering | fish_length | min 30 mm TL, expert | Coleman & Fausch 2007, field (p. 1241) |
| 1104 | CRCT | overwintering | fish_length | min 30 mm unstated, expert | Coleman & Fausch 2007, lab (p. 651) |
| 1105 | CRCT | overwintering | fish_length | qual | lab (p. 650): size dependence in cold regimes only |
| 1106 | CRCT | rearing | degree_days | qual | field (p. 1239): TL as exponential function of degree-days |
| 1107 | CRCT | overwintering | fish_length | range 34-34 mm TL, lab | field (p. 1241), restating the lab study |
| 1108 | CRCT | overwintering | fish_length | range 25-26 mm TL, lab | field (p. 1241), restating the lab study |
| 1109 | CRCT | overwintering | fish_length | min 28 mm FL, expert | Thorley & Branton 2022 (p. 3): their FL conversion |
| 1110 | CRCT | overwintering | fish_length | min 30 mm unstated, expert | Thorley et al. 2022 UFR (p. 30) |
| 1111 | WCT | rearing | degree_days | qual | Thorley & Branton (p. 25): FL on GSDD |
| 1112 | WCT | overwintering | fish_length | qual | Thorley & Branton (p. 27): energetic status predicts egg-to-age-1 survival |
| 1113 | WCT | overwintering | degree_days | qual | Thorley & Branton (p. ii): GSDD explains 34% of Reduced Recruitment |
| 1114 | CRCT | overwintering | fish_length | min 30 mm FL, lab | Hocking et al. 2022 (p. 51): their logistic on lab means |
| 1115 | CRCT | overwintering | degree_days | qual | Hocking et al. (p. 49): survival to onset of winter on GSDD |
| 1116 | WCT | rearing | degree_days | qual | Hocking et al. (p. 75): Elk Valley fry larger than the Colorado relation predicts |
| 1117 | BT | overwintering | degree_days | min 1600 degC-day unstated, expert | Mochnacz 2021 (p. 98) |
| 1118 | BT | overwintering | degree_days | qual | Mochnacz 2021 (p. 115): NWT streams at 800 or less hold self-sustaining BT |
| 1119 | ST | rearing | degree_days | qual | Hartman & Scrivener 1990 (p. 85), Table 14, pooled |
| 1120 | CT | rearing | degree_days | qual | same statement, pooled |
| 1121 | CT | rearing | degree_days | qual | Hartman & Scrivener (p. 86), Table 15, cutthroat only |

No `none` rows, as the brief says.

## Key identities (read before checking cited_source)

- In the repo, `coleman_fausch2007ColdSummera` is the **field** paper (TAFS 136:1231) and
  `coleman_fausch2007ColdSummer` the **laboratory** paper (TAFS 136:639).
- Thorley & Branton (2022) and Hocking et al. (2022) both list 2007a = laboratory, 2007b = field in their reference
  lists. To avoid ambiguity, each `cited_source` I wrote names the journal pages.
- Thorley & Branton (p. 3) credit the 30-35 mm TL sentence to "Coleman and Fausch (2007a)" and the field studies,
  but their 2007a is the lab paper. The sentence is in the field paper (p. 1241). Row 1109's note says so.

## Per source

### coleman_fausch2007ColdSummera (field, size statements only)
- Filed: 1103 (the 30-35 mm TL minimum), 1106 (TL on degree-days, qual), 1107 and 1108 (the lab treatment means the
  field paper restates. The lab paper shows these means only in figures, so the field paper is where they are
  printed. `cited_source` names the lab study).
- Not filed:
  - Peterson & Fausch (2002) fry lengths: 26 and 30 mm TL by early September in two cold streams where recruitment
    nearly always failed, and 45 and 69 mm TL by mid-September in two warmer streams (p. 1240). They are secondary,
    and the original 2002 report is not held. The field paper says "averaged ... TL" and the lab paper (p. 651) says
    "median length" with no length type, so the two disagree on the statistic. The populations are named only as
    "cutthroat trout". They appear in the notes of 1103 and 1104.
  - Table 4 predicted TL by reach (23.1-37.3 mm). These are model outputs. The range is cited in 1106's note.
  - "fry less than 30 mm TL are weak swimmers" (pp. 1235-1236). This is about habitat use and sampling, not survival.
  - The survivorship-from-GSDD statements (p. 1239: fewer than 800 GSDD unlikely to survive to the onset of winter)
    are degree-day statements, outside my "size statements only" scope. The degree-day rows are data rows 557-559.

### coleman_fausch2007ColdSummer (laboratory, size statements only)
- Filed: 1104 (threshold length 30-35 mm), 1105 (size-dependent mortality only in the colder regimes, qual).
- 1104's `metric` is `unstated`. The sentence names no length type, and its "observations" are Peterson's field
  medians, whose length type the paper does not give. The paper's own lengths are TL, and the companion paper says
  TL. A reviewer may prefer `total_length`, but I followed "never infer one".

### thorley_branton2022SubjectMatter
- Filed: 1109 (28-33 mm FL, their conversion of the C&F TL threshold, coded CRCT with `cited_source`; it is the
  second row of the pair whose TL row is 1103), 1111 (fork length on GSDD, qual), 1112 (energetic status at the onset
  of winter predicts egg-to-age-1 survival, qual), 1113 (GSDD's 34% share of Reduced Recruitment, qual).
- 1109's quote: the source prints the FL values inside square brackets, "[28 – 33 mm FL]". The gate strips
  `[...]` from quotes as an editor's insert, which would also strip the value. So the quote skips each bracket with
  ` ... `, and every fragment is verbatim.
- Not filed:
  - Estimated mean FL by population (Grave 41-43 mm, Harmer 30-37 mm; 2018: 43 (39-48) vs 30 (28-33) mm FL, p. 26).
    These are model estimates, and the report ties survival to energetic status, not to these values as a threshold.
  - GSDD estimates by population (p. 25). They are in 1113's note.
  - The 37.5 mm FL "typical" fish is a reference size for standardizing condition and for the counterfactual, not a
    threshold.
  - Population replacement needs 3.7% egg-to-age-1 survival (Figure 19 caption, p. 28). This is not a length or
    degree-day value. It is in 1112's note.
  - The starvation condition estimate of 0.32 (0.02-0.74) is called implausibly low by the authors (p. 27).
  - The exec summary (p. ii) and discussion (p. 32) say "A strong negative relationship between the size of young of
    year trout and overwintering survival is well documented". Read literally this is inverted: the rest of the
    report treats larger size as better. Not quoted for that reason.
- Table cannot hold: the hBIN structure, the energetic-status formula, the counterfactual percentages. These are in
  notes as printed.

### thorley_etal2022UpperFording (the 30 mm statement only)
- Filed: 1110, coded CRCT with `cited_source` "Sogard 1997; Coleman and Fausch 2007a, 2007b" and a note that the report
  applies the threshold to WCT. Sogard (1997) is a multi-species review (its title from the report's reference list),
  so CRCT is not a clean code for this row. I kept CRCT because the brief routes restated C&F values there. A reviewer
  could argue for leaving this row out as a restatement.
- Not filed: the WCT age-0 length estimates for Ewin and LCO Dry creeks ("less than 30 mm"). As a `dist` row they
  would read as where fish were found, not as a failing size.
- The report uses 30 mm with no length type in a paragraph about fork lengths, while C&F's figure is TL. That
  mismatch is noted on the row.

### hocking_etal2022SubjectMatter
- Filed: 1114 (their logistic of lab overwinter survival on fork length: >90% above ~30 mm FL; coded CRCT `lab`
  because the data are C&F's lab Colorado River cutthroat; 3 points only), 1115 (survival to the onset of winter on
  GSDD, qual, CRCT), 1116 (observed Elk Valley fry slightly larger than predicted, qual, WCT).
- 1114 `kind`: `lab` because the points are laboratory survival and size. It could arguably be `param`, since it is
  a curve the report fitted. The page carries a contradiction: p. 53 first says C&F's lab mortality estimates "are
  likely higher than would occur in the wild", then calls the lab relation "an overly conservative estimate of
  mortality" because the wild is harsher. The note gives both.
- 1115 `life_stage` is `overwintering` because the brief puts survival to the onset of winter there. The equation is
  given as printed. Its exponent grouping is flattened in the text, and the C&F original (field paper Figure 3) has
  no coefficients in its text, so it was not checked.
- Not filed:
  - p. 18 restatements: 30-35 mm TL "minimum size for overwinter survival" and the <800 / 800-900 / >900 GSDD
    classes. Both are restated C&F values that are already rows (1103; 557-559).
  - p. 18: "overwinter Cutthroat Trout survival was 28 - 50% in age 0 fish ... (Coleman and Fausch 2007b)". This
    appears to misread C&F's predicted survivorship 0.28-0.50 (to the onset of winter, from the lab logistic, in the
    colder reaches; field p. 1239 and Table 4) as overwinter survival. Not filed.
  - p. 46 GSDD-to-FL equation: "Fry Fork Length (mm) = (18.983 + 0.17e0.046 × GSDD) / 1.04". As printed, e^(0.046 x
    GSDD) is astronomically large at any real GSDD (e^36.8 at 800), so the exponent is mis-set or mis-typed. The
    printed predictions (22-30 mm FL at 723-926 GSDD; >35 mm at >1,000) cannot come from it as printed. Not filed, and
    I did not reconstruct it. 1116's note mentions the conversion without the equation.
  - Predicted fry FL by station (p. 47), predicted survival by station (p. 49; in 1115's note), and the conceptual
    low-survival scenario (p. 54). These are model predictions.
  - Harmer fry "~15% smaller by length" than Grave fry (p. 47). This is an observation not tied to survival on the
    page.
  - TL = 1.040 FL + 1.697 (Mayhood 2012, p. 46) is a conversion equation, not a length tied to survival. It is cited
    in 1114's note.

### mochnacz2021Thermalecology
- Filed: 1117 (BT needs 1600 ATU from egg deposition to the onset of winter; `metric` unstated; expert, as the
  author's inference), 1118 (counter-evidence: self-sustaining juvenile BT in NWT streams with 800 or fewer
  growing-season thermal units; qual).
- The search file put 1118's sentence on p. 114. It is on p. 115: PDF page 115 carries printed 115, and the paragraph
  begins after the page break.
- 1117's 1600 is half bull trout (800 ATU to emerge, Gould 1987, lab) and half Arctic char (800 ATU after emergence,
  Bebak et al. 2000, aquaculture). No bull trout growth or survival measurement supports the second 800. Neither
  original is held, so `cited_source` is blank (the value is the author's own sum) and the note names both.
- Not filed:
  - 500 ATU to hatch and 800 ATU to emerge (Gould 1987, p. 98). These are BT incubation/emergence values from a
    secondary source, outside this brief's rearing/overwintering scope. They could be `to_hatch` / `to_emergence` BT
    rows with `cited_source` Gould 1987 if wanted.
  - Table 3.5 growing-season ATU (NT mean 651, range 378-936; AB 597, 321-787; ID 1230, 807-1745; p. 130). Only the NT
    streams are tied to recruitment, and only in prose. The figures are in 1118's note.
  - p. 109 (C&F "survival and recruitment ... low in streams accumulating <700 thermal units") and p. 114 (C&F
    "at least 800 thermal units from egg deposition to the onset of winter"). Both misstate C&F's 800/900 GSDD on
    C&F's growing-season window. Not filed, and they should not be cited for C&F values.
- Window conflict inside the thesis: the onset of winter is "≤ 1.5°C for 7 consecutive days" on p. 101 and "≤ 2°C on
  two consecutive days" in Table 3.2 (p. 127). 1118's note gives both.

### hartman_scrivener1990Impactsforestry (trout passages only)
- Filed: 1119 (ST) and 1120 (CT): the same pooled statement, "the size of age 0 + trout in autumn was dependent upon
  stream temperature during the incubation period" (p. 85), with Table 14's age 0+ equations in the notes. Table 14
  pools steelhead and cutthroat, so the brief's one row per named species applies. 1121 (CT only): Table 15 / Fig. 71,
  age 0+ cutthroat in Tributary-C and section IX (p. 86, table p. 87).
- Nothing on age-0 trout winter survival: "The survival rates of the different age classes of trout in Carnation
  Creek have not been determined ... Further analysis is required to determine how trout size, trout density, and
  habitat conditions affect winter survival" (p. 89). So no trout size is tied to survival, and there is no
  `fish_length` row. The coho size-survival relation (Fig. 72) is for the `ps` drafter.
- Not filed: age 1+ and 2+ rows of Table 14 (not age-0); the density regressions; the deLeeuw (1982) enclosure weight
  gains for age 0+ steelhead (p. 87; no degree-days); the summary "Stream temperature influenced fish size mainly by
  shortening the egg incubation period; thus lengthening the growth period during their first summer" (p. 87). The
  last would make a good quote if a reviewer wants the mechanism stated on 1119-1120.
- Table 14's windows (Mar.-May, June-Sept., Mar.-Sept.) are calendar sums at B-weir, base not stated. Qual rows carry
  no metric, so the windows are in the notes.

## Things the table cannot hold

- Fitted curves and their uncertainty: C&F's exponential TL model (equation only in the Figure 4 graphic); Thorley &
  Branton's hBIN parameters; Hocking's two logistics. All are in notes as printed, none solved for a threshold.
- Survival percentages attached to sizes (Hocking: 40% at ~20 mm FL; C&F lab: >50% vs 18-35%). These are in notes,
  because the table has no survival column.
- Energetic status (length x condition) as a predictor. It is neither a length nor a degree-day value.

## Unsure

- Species for 1103 and 1104: the threshold rests on Colorado River cutthroat lab fish plus field populations named
  only as cutthroat (greenback plus CRCT in the field paper). I followed the existing C&F rows in coding CRCT.
- 1107/1108 as `lab` rows with `range` (equal ends for 34). These are lab means tied to survival, not requirements;
  the notes say so. Drop them if the coordinator wants only thresholds and relations.
- 1110 as CRCT rather than left out (see above).
- 1118 region: "the northern watershed" is the NT watershed (Table 3.5), which the thesis's figure list names as
  Prairie Creek, Northwest Territories.
- 1119-1121 region "Carnation Creek, Vancouver Island, BC": the `ps` drafter may word Carnation Creek differently, so
  harmonise when merging.
