# Drafter notes: Pacific salmon and steelhead (`ps`), #47

15 rows in `draft-ps-evidence.csv` (data rows 1103-1117 when merged after the 1,102 committed rows). All 15 pass
`0280` (`verified_text`) on the merged table, and the run printed no new failure (1117 rows; coverage, thermal and
flow grids complete; model links clean). Each row was then re-read against its page for species, stage, variable,
bound, metric and note.

Summary of what the sources hold: **no Pacific salmon or steelhead source here states a growing-season degree-day
requirement**, and only two state a fall length: Ebersole et al. 2006 (survival highest above 90 mm FL) and
Ebersole et al. 2009 (80 mm FL used as a hypothesized threshold, which then explained little). The Carnation Creek
sources give size-survival *regressions* and say temperature acts mainly through emergence timing (incubation
degree-days), not first-summer degree-days. Counter-evidence is filed: Ebersole 2009 (fall length uninformative),
Quinn & Peterson 1996 (size effect in one of two winters; small lake-reared fish survived better), Holtby &
Scrivener 1989 (summer growth rate not affected by summer temperature).

No row fills a grid cell: the valued degree-day row is `metric = unstated` and the fish-length rows have no cell.
No `none` rows, per the brief.

## Page numbers

Printed page numbers throughout. PDF-to-printed offsets checked against the gate's matched PDF page:
Holtby & Scrivener 1989 PDF 76-78 = pp. 69-71 (the chapter is PDF 69-88 = pp. 62-81 of the volume);
Hartman & Scrivener 1990 PDF 92 = p. 83, PDF 97 = p. 88; Riley PDF 9 = p. 5; journal articles by their printed
page. **The search notes (`search-ps.md`) are off by one on several pages**: Holtby & Scrivener eq. 17-19 are on
p. 70, not 69; Hartman & Scrivener's emergence and thermal-summation sentences are on p. 83 (not 82), Table 14 on
p. 85 (not 84) and the survival/Fig. 72 passage on p. 88 (not 87).

## Per source

### holtby_scrivener1989Observedsimulated (pp. 62-81)
Filed (4):
- CO `emergence` `degree_days` qual, p. 69: eq. 14, emergence date on February-March thermal summation. Note
  carries the chain eq. 14 -> eq. 17 (fall FL from emergence date and summer density) -> eq. 18 (winter survival).
- CO `overwintering` `fish_length` qual, p. 70: "Most of the variability in winter survival was associated with
  changes in fish size going into the winter"; eq. 18 in the note (survival = -1.188 + 0.0232 FLfall + 0.288 HQIw,
  r=0.897, n=17).
- CO `overwintering` `fish_length` qual, p. 71: survival an asymptotic function of size (yearling mean 0.645 is
  similar to the largest sub-yearlings'). No length printed for the asymptote.
- CO `rearing` `temperature` qual, p. 70: summer growth rates not affected by increased summer temperatures
  (Holtby 1988c). **Flag:** this is `temperature`, outside the two variables the brief targets. I kept it because
  it is the source's direct counter-evidence to a summer-degree-day mechanism for coho; drop it if the coordinator
  wants #47 confined to `degree_days` and `fish_length`. It is qual, so it touches no thermal cell.

Not filed:
- Eq. 17 (fall FL = -0.254 JDemerge + density term + 91.7, r=0.912, n=16): a length on emergence date, not a length
  tied to survival; it is in the eq. 14 row's note. The sign of the density term is not legible in the text layer.
- Eq. 19 (proportion smolting at age 1 rises with fall FL, "possibly a reflection of a size-threshold that must be
  obtained before smolting occurs", p. 70): smolting, not survival or recruitment; no threshold printed.
- Eqs. 22-24 (smolt and yearling FL from fall FL): sizes, no survival.
- Eqs. 30-31 (smolt emigration date on April thermal summation, p. 71): emigration timing, not growth or survival.
- Chum salmon (eqs. 6-9, pp. 67-68): fry length predicts recruitment strongly ("within the observed range of FL
  (41.6-43.3 mm), and increment of one mm in length was associated with an increase in recruitment of 596 fish",
  p. 68), and emigration date is predicted from February-March thermal summation (eq. 8). Chum fry go to sea at
  emergence, so this is early-marine survival, not a first winter in fresh water; out of #47's scope and CM is not
  in the THERMAL species list. Worth a row only if a chum fry-size question comes up.

### hartman_scrivener1990Impactsforestry (coho passages only)
Filed (3):
- CO `overwintering` `fish_length` qual, p. 88: first-winter survival dependent on autumn size; Fig. 72's fit
  (y = 0.0212x - 0.837, r = 0.91, p < 0.001; x axis 45-75 mm FL, 1970-1987) in the note. Fig. 72 checked on the
  rendered page.
- CO `emergence` `degree_days` qual, p. 83: 50 % emergence date correlated with incubation thermal summation
  (cited to Hartman et al. 1984; Scrivener and Andersen 1984).
- CO `rearing` `degree_days` qual, p. 83: summer thermal summation at B-weir positively correlated with autumn fry
  FL and weight (Holtby 1988). Which of the three Holtby 1988 items is meant is not stated.

Not filed:
- Fig. 72's equation solved for zero or 50 % survival (about 39.5 and 63 mm, the search notes' arithmetic): the
  brief forbids computing a value the source does not print.
- Age 1+ and 2+ coho (p. 84: age 1+ growth negatively correlated with summer thermal summation; p. 88: second-winter
  survival not correlated with size at age 1+): not the first winter; mentioned in notes of filed rows.
- p. 106: "larger autumn fry which had higher over winter survival (Fig. 72)" and "attain the size necessary for
  smoltification": restatements; the first is in the p. 88 row's note.
- **For the `tc` drafter / coordinator:** p. 121 (PDF 130) says "The larger size of juvenile trout in autumn did not
  appear to improve their over-winter survival", in a steelhead paragraph. It is trout-passage counter-evidence and
  belongs to the `tc` family's Hartman & Scrivener assignment; I did not file it. If `tc` codes it, the paragraph is
  about steelhead (ST), not pooled trout. Table 14 (p. 85) is also `tc`'s.

### riley_etal1998Habitatbasedassessment
Filed (1):
- ST `rearing` `degree_days` min 450 degC-day, `metric = unstated`, `kind = param`, p. 5: "a requirement of 450 such
  days prior to smoltification", base 7 C.

Unsure of:
- **Life stage.** This is a smolting requirement accumulated over the whole freshwater residence (more than one
  year where annual degree-days above 7 C fall short of 450), not first-summer growth or first-winter survival. `rearing` is the closest stage; it fills no cell
  because the metric is `unstated`. `outmigration` is the alternative if the coordinator reads it as a smolting
  trigger.
- **"450 such days".** Read as 450 degree-days above 7 C because it follows "degree days > 7o C"; it could be read as
  450 days above 7 C. The note says so.
- **Origin.** The report cites no source for the rule; the search suspects Tautz, Ward & Ptolemy 1992 or Ptolemy
  unpublished. Left `cited_source` blank rather than guess.

Not filed: SMAGE = 587.203 FL1^-1.14116 (smolt age from age 1+ FL, fitted to the DD-estimated ages) and FSURV (fry-to-
smolt survival falls with smolt age): together they tie age 1+ length to recruitment of smolts, but not the first
winter, and no threshold; in the row's note. Ptolemy's (1993) FPU model uses "fish size at the end of the growing
season" to set fry density, not survival.

### ebersole_etal2006JuvenileCoho
Filed (2):
- CO `overwintering` `fish_length` qual, p. 1690: survival probability positively associated with fall FL (logistic,
  Table 7: chi-square 5.64, P = 0.018; model deviance explained 8.7 %).
- CO `overwintering` `fish_length` min 90 mm `fork_length`, `kind = dist`, p. 1690: "Survival was highest for coho
  salmon that were larger than 90 mm at the time of tagging (Figure 5)". Fig. 5 read on the rendered page: 10-mm
  classes 60-69 to >90 mm, by tributary.

Unsure of: `bound = min` with `kind = dist`. The source does not call 90 mm a threshold; it is the lower edge of the
top length class, where survival was highest. Survival below it was lower in all three tributaries (Fig. 5), which
is why I used `min` rather than a qual row, but the note says it is a class edge, not a fitted threshold, and gives
the weak model fit. Downgrade to qual if a class edge should not carry a value.

### ebersole_etal2009ModelingStream (OCR scan with a text layer)
Filed (3):
- CO `overwintering` `fish_length` min 80 mm `fork_length`, `kind = param`, `scale = reach`, p. 569, cited_source
  Ebersole et al. 2006: the hypothesized threshold the survival models used (percent of a reach's parr above it).
  The note gives the result (low importance, CI including zero). The quote skips the OCR word "sizedependent".
- CO `overwintering` `fish_length` qual, p. 564 (abstract): fall FL "relatively uninformative": counter-evidence.
- CO `outmigration` `degree_days` qual, p. 572: smolt length positively related to degree-days (base 0 C) from
  January 1 to capture; 100 units -> 6 mm. **Flag:** smolt length at emigration, not survival and not the first
  summer, and the authors say the degree-day value "primarily indexes date of emigration". Kept because the brief
  names length-on-degree-day relations as worth a row; drop if out of scope. `outmigration` is in
  `knw_timing_stages()` (the brief's list omits it).

Note the internal inconsistency between the two Ebersole papers: 2006 says survival was highest above 90 mm; 2009
cites 2006 as survival increasing "markedly above 80 mm". Both rows say so.

### quinn_peterson1996influencehabitat
Filed (2):
- CO `overwintering` `fish_length` qual, p. 1557: larger size classes survived better in 1990-91 but not 1991-92;
  Table 1 means and the p. 1560 between-year statement in the note. Fig. 2 read on the rendered page (classes
  <60 to >89 mm, October).
- CO `overwintering` `fish_length` qual, p. 1555 (abstract): fish above the lake were smaller in fall but survived
  better: counter-evidence to an absolute fall-length threshold.

Not filed: Table 1 survivor and nonsurvivor mean lengths (75.7 vs 73.6 mm in 1990-91) as `dist` rows. They are tied
to survival, but a survivors' mean length would read as a size requirement, and the difference is 2 mm with
overlapping SDs; they are in the note instead. The quote of the size-class sentence stops before "(chi2" because
the text layer's chi glyph is untested in the gate's tokenizer; the statistics are in the note.

## Things the table cannot hold
- Multivariable survival models (eq. 18: fall FL plus winter habitat quality) have no column for the second
  covariate; the qual note carries it.
- Survival is "apparent" in both Ebersole papers and in Quinn & Peterson (emigration counts as death); the table has
  no field for that, so every note says it.
- Winter severity as a modifier of the size effect (Quinn & Peterson; Ebersole 2009 p. 574) has no column.

## Sources with no CH rows
None of the six sources measures Chinook. The CH first-winter evidence the search found (Zabel & Achord 2004,
Bradford et al. 2001, Boersma 2016) is not among this brief's sources and was not read.
