# Review p3 round 2: the round 1 fixes (data rows 484-489) and the `elevation` vocabulary

Rows are numbered as data rows (data row 487 = file line 488), which matches `data_row` in the gate log.

## Findings

- **[severity: bug]** row 488 (Porter Table 3.5, printed p. 37 / PDF p. 39): the note says the BT model has mean elevation "with drainage area, Melton's R and K factor". That reads as the full covariate set, and it is not. Rendered, the BT block also carries **Percent Wetland -0.696 (0.231), P 0.003** and **Percent Lake -0.115 (0.049), P 0.002**. The elevation coefficient is conditional on all six covariates, so the list should be complete, for example "with log drainage area, Melton's R, K factor, percent wetland and percent lake". Everything else in the row checks: +0.002 (0.001), P 0.005; the sign is positive on the render; Chinook -0.004 and coho -0.003; the response is Known Fish Observations with no life stage separated (PDF pp. 9, 11); network (watershed) scale.

- **[severity: fragile]** row 489 (Porter Table 3.15, p. 51), and the clause in row 486 "macroreach-scale nulls for gradient (... Porter 2008 Table 3.15)": "A segment-scale null for gradient" claims more than the source shows. The source says only that the selected model is sinuosity plus bankfull width, which the row also states correctly. Table 3.13 (printed p. 50, rendered) cannot be read as a test of gradient, for two reasons:
  - The table lists "Upstream elevation, downstream elevation, sinuosity, gradient, bankfull width" (5 parameters) **twice**, at ΔAIC 104.43 and at 410.91.
  - Every gradient model is a superset of the selected 2-parameter model. On identical data, adding 3 parameters can raise AIC by at most 6, yet these supersets sit 103-411 AIC above it. So the candidate models were not fitted to the same records, or the table has errors. Either way the ranking is not evidence that gradient has no effect.

  Even in the selected model, sinuosity has P = 0.454. Suggest "gradient was a candidate and was not selected (Table 3.13's ΔAICs are not comparable across models: the same model appears at 104.43 and 410.91)". Drop "null" from both rows. The Dunham & Chandler null (row 483) is different: there the authors state it themselves (p. 15).

- **[severity: fragile]** row 485 (Porter p. 66): the "(Porter's 2007-08 extract)" date is not stated in the source. Section 2.2.2 (PDF p. ~13) says only that a larger FDIS dataset was extracted for the Interior Freshwater Ecoregion: 254 BT sites, juvenile records, electroshocking only. The report is dated 2008, so "pre-2008" or "the report's Interior Freshwater Ecoregion extract" is supportable, and "2007-08" is an inference written as fact. The rest is correct: overlap with the province-wide export, so not independent, and not the same data.

## Checked and correct

- **Row 487** (Isaak App. S1 Fig. 1): it is on PDF p. 15, and the appendix's own page number is "1", so `S1-1` is right. The dashed BT line is labelled "Bull Trout < 150 mm (1102 sites)". The 50-200 m electrofishing reaches, "northwestern U.S." and reach scale are all in the appendix text. From a 300 dpi crop, the BT curve reads about 0.64 at 6 %, 0.84 at 9 % and 0.94-0.95 at 12 %, so the note's 0.63 / 0.84 / 0.95 are fair approximate readings and are stated as such. "Use only: no absences or available stream" is right: the figure counts sites where fish occurred. The quote is verbatim (gate: verified_text, PDF page 15).
- **Row 484**: "explaining 94% ... (F9,60 = 97.21)" runs across printed pp. 15-16. "Preliminary" is the source's own word (p. 4, "Preliminary temperature models"). "fit only for streams with both fish and temperature data collected in 2000" is verbatim on p. 16.
- **Row 486**: Isaak Table 4, Isaak App. S1, Porter Table 3.5 and Dunham & Chandler are characterised correctly, apart from the Porter "null" wording above. Searching the six sources' text for elevation finds no reach- or segment-scale occupancy fit by elevation. Porter's macroreach BT model has no elevation term, and Dunham & Chandler fit elevation only against temperature.
- **Row 489**: Table 3.15 BT block is intercept -2.035, sinuosity 0.3648 (0.487) P 0.454, and bankfull width 0.0228. Upstream and downstream elevation and gradient are in Table 3.13's candidates. The quote matches the table.
- **Code**: `elevation` is added to both `variable` and the `fits` map in `.literature_check`. Nothing else enumerates variables:
  - 0280 branches only on `timing`;
  - `ip.R` and its vocab are separate;
  - no man page lists variables;
  - test-literature.R:136 checks stages, not the variable list.

  Row 488 has no unit, so the unit check does not touch it. The full test-literature.R suite passes in a copy. Narrowing `fits$elevation` to `"m"` made the new test fail at line 232 (the `ft` expectation), and the `percent` arm catches a missing or over-permissive entry. So the test can fail.
- Not a defect, noted only: `pkg/NEWS.md` (0.2.0) lists the earlier new variables but not `elevation`. `/gh-pr-merge` writes the release entry.
