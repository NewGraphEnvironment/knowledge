# Review p3 round 1b: meaning audit of the nb-family IP rows (#29)

Scope: every row with model_id rebellato2024, cooney_holzer2006, woll2015, woll2017 or porter2008 in
`data/literature_evidence.csv` (181 rows) and `data/ip_model_registry.csv` (45 rows), the three new `none` rows
(479-481), and the two code changes. Row numbers are 1-based data rows, header excluded. Each row was read
against the surrounding PDF text and table layout.

## Part A: code

**Clean.** `knw_ip_vocab()` gains `unstated`. `.ip_check()` takes `flow_source` from the vocab and handles it
like `gauged` or `field`, so it needs no inputs and none is checked. The new test exercises the read path. In
`0280`, `COVERAGE$species` is used only in the `expand.grid` coverage table and the exit condition, so the CO
and ST rows extend it with no other effect. With 479-481 in place, every CO and ST cell has a row.

One contract is not enforced, and it is not a bug: the roxygen says `unstated` is for "a secondary account",
but nothing requires `cited_source` on those rows. The five current `unstated` rows all carry it.

## Part B: errors of meaning

### 1. rebellato2024 registry, validation (registry rows 1, 2, 3, 39-51; 16 rows)

The `note` says "Not validated: p. 14 says the IP results have not been validated by field assessments."
That is wrong.

- **What p. 14 actually says:** the sentence is in the *Lateral habitat fragmentation* section. It reads
  "Approaches used to identify lateral habitat and its connectivity status were preliminary and have not been
  validated by field assessments." It is about the floodplain/lateral model, not the IP models.
- **What the report says about the IP models (p. 12):** "Overall, comparison with existing datasets such as
  the PSE (Pacific Salmon Foundation 2020) demonstrated that the IP models used in this analysis successfully
  identified almost all known spawning and rearing habitat; however, field verification is required...".
  This compares model output with known fish spawning and rearing locations.

Correct values:
- `validation = fish_observations`;
- `validation_result`: the IP models were compared with the Pacific Salmon Explorer's known spawning and
  rearing habitat and identified almost all of it. No statistic is given, and field checks of similar outputs
  found some modelled habitat unsuitable;
- `validation_page = 12`, with the quote above.

For CM and PK, add to `note` that the comparison is not independent: their thresholds were set from PSE
spawning sites (p. 5).

At minimum, the p. 14 attribution must come out of all 16 notes.

### 2. cooney_holzer2006 CH registry: `fish_observations` is wrong, and the ST `redd_surveys` is right (registry rows 4, 5, 6)

On C-12, the comparison is "between IP habitat classes and productivity as measured by redd counts". It
continues: "The spring/summer Chinook survey from the Middle Fork Salmon River (USFWS) was used for our IP
analysis of stream type Chinook".

C-14 describes that survey:
- GPS-located Middle Fork Salmon redds, 1995-2003;
- an ANOVA of redd counts per IP class;
- "general agreement ... but some differences", and the results "were used to adjust model parameters".

The C-3 quote the CH rows use ("relative abundance of spawning adults") is the step-5 summary of this same
redd comparison.

Correct values for rows 4-6:
- `validation = redd_surveys`;
- `validation_page = C-12`, quoting "The spring/summer Chinook survey from the Middle Fork Salmon River
  (USFWS) was used for our IP analysis of stream type Chinook";
- `validation_result`: the ANOVA of Middle Fork Salmon redd counts by IP class showed general agreement with
  some differences and was used to adjust the ratings. No statistic is given, and the comparison is not
  independent.

The new ST rows 52-54 (`redd_surveys`, C-12) are correct, and so is their non-independence note.

### 3. cooney_holzer2006 evidence rows 410 and 411 carry the model_id but state values the final model does not use

- **Row 410** (ST spawning, gradient optimum 4-7 %, C-11) and **row 411** (ST spawning, gradient max 15 %,
  C-11): both are the *initial* steelhead rating.
- **C-12:** after the redd comparison, "class specific adjustments were made to IP ratings, most notably ...
  modification of gradient and width classes".
- **Final Table C-2 (C-17):** 4-7 % rates None/Low/Low, 0.5-4 % rates High, and >7 % rates None.

The drafter's own notes say both rows are superseded. The brief's tag rule says to tag "only when it states a
value or variable the model itself uses". As tagged, the model carries two contradicting ST spawning optima
(4-7 % in row 410, 0.5-4 % in row 377) and two zero edges (15 % in row 411, 7 % in row 375).

Correct: a blank `model_id` on rows 410 and 411, or drop them. ST spawning keeps registry support from rows
373-381, 406, 407 and 409.

### 4. porter2008 registry, `validation = density` (registry rows 77-80)

The quoted p. 66 cross-validation is the CART pruning step, part of fitting the model:
- **p. 32:** "We applied a 10-fold cross-validation procedure to prune each species' tree back to the most
  parsimonious structure. This type of validation is useful when no test sample is available".
- **The outcome:** that procedure rejected every split. The trees actually used were grown with a relaxed
  complexity parameter outside it (p. 32, p. 66), so no fish data checked the delivered capacity classes.
- **What the authors call for:** "field validation is required" (p. 82), and under further work, "Field
  validate model predictions of ... habitat capacity at the macroreach scale" (p. 83, item 3).

The brief excludes calibration. The CART fitting diagnostic is calibration.

Correct: `validation = none`, with the validation fields blank and `note` recording the failed pruning
cross-validation and the p. 83 call for field validation. If the team counts the CV as validation, keep
`density`, but then say in `validation_result` that the classes it scores are not the ones the CV selected.

### 5. porter2008 evidence rows 101 and 108: parameter set on rules that are not limits

These two rows were tagged into the model, but their `parameter` contradicts their own notes and the rule the
other Porter rows follow:
- **Row 101:** BT `rear_gradient_max` at 9.75 %. Its note says "Steeper is better here; not a maximum".
- **Row 108:** BT `rear_channel_width_min` at 3.05 m. Its note says "LOW capacity, not absence".

On p. 67, `<3.05 m` gives LOW and `>=9.75 %` gives MEDIUM, so neither is a 0-suitability edge. The brief says
an interior breakpoint that is not a 0-suitability edge has a blank `parameter`. The drafter notes say "no
class is a 0-suitability edge, so every row is hsi with blank parameter", and new rows 468-478 apply exactly
that to the same kind of split.

Correct: a blank `parameter` on rows 101 and 108. BT coverage is not affected: other rows carry
`rear_gradient_max` (95-100, 102-104, 190) and `rear_channel_width_min` (105-107, 109).

### 6. `none` rows 479 and 481: the search claims in `note` are false, though the conclusions hold

I grepped all 13 model texts for lake, pond, wetland, marsh and beaver. No model sets a lake-area minimum for
coho or steelhead, or a wetland-area minimum for steelhead, so the `none` verdicts stand. Two sentences in the
notes are wrong:
- **Row 479 (CO lake):**
  - "Woll 2017 Table 15: lakes >1.5 and >2 km2" mixes two reports. The 1.5 km2 rule is Woll 2015 Table 5
    (p. 46); Woll 2017 Table 15 has only "Lakes bigger than 2 km2" (p. 82).
  - "coho, whose lake rearing no model treats separately" is false:
    - Woll 2015 Table 6 (p. 50) rates "lakes" No potential for coho summer rearing;
    - Porter 2008 p. 67 (and Sheer et al. 2009) assign "Channel Type = Lake" its own LAKE class for coho.

  Correct the note to say that coho lake rules exist but none is a size threshold.
- **Row 481 (ST wetland):** "The only wetland rule is Rebellato 2024 p. 7" is false. Woll 2015 Table 5
  (sockeye: wetland streams Negligible), Table 6 and Table 7 (coho: wetland streams High) are wetland rules.
  This diff records two of them itself (rows 430 and 435). Correct the note to say that every wetland rule is
  for sockeye or coho and that none sets an area threshold.

### 7. Minor: row 356 note (rebellato2024 SK access)

"the 15 % rule was set from Chinook and coho observations in BC (p. 4)" misreads p. 4:
- the observation analysis was run on pink and chum because no literature limit existed for them;
- it was repeated for Chinook and coho "to confirm whether literature-derived gradient thresholds ...
  reflected observed thresholds";
- "Based on these results" covers all four species.

Correct: "set from BC observations of pink, chum, Chinook and coho (p. 4)".

## Checked and found correct

- **Rebellato Table 1, every row:** each species maps to the right columns:
  - CO 0-5 / 0.164-59.15 / 2 / 0-5 / 0.03-40 / 1.5;
  - ST 0-4 / 0.447-75 / 4 / 0-7.4 / 0.02-60 / 1.5;
  - SK 0-2 / 0.175-65 / 2 / NA;
  - CM 0-6 / >0.023 / 2.1;
  - PK 0-6 / >0.411 / 2.1.
- **Other Rebellato rows:** access 15 % and 20 % for the right species; the bridge rule; the 10 m and 2 m gap
  exceptions; the sockeye lake rules (200 ha, 3 km, 5 %); coho wetland `qual`; the registry flow fields and the
  surrogate.
- **Cooney:** Table C-1 and C-2 rows (verified on the layout); 3.6 m wetted and 3.8 m bankfull; valley ratios
  4 and 20; the sediment screen; the velocity `qual`; WMAT 22 C; access 20 %; the flow fields (modelled width
  regressed on drainage area and precipitation, wetted for CH and bankfull for ST).
- **Woll 2015:** Tables 3-7 and Appendix A pp. 8, 13 and 17. The rows are correct by stage, including
  sockeye on both seasons per p. 45, and so are the registry metric and confinement per stage. "Not
  validated" is supported by p. 56.
- **Woll 2017:** Tables 14-21 and pp. 33 and 36. `validation = none` is supported: the authors call the models
  "only qualitative" and "unvalidated", and say they "offer hypotheses for validation".
- **Porter 2008:** rows 468-478 match the p. 67 rules and their direction notes.
- **Kind usage:** no data summary (`dist`, `max_obs`) carries an in-scope model_id.

Not counted as an error: Porter registry `flow_inputs` lists `field_measurement` for widths that Davies et al.
2007 measured from orthophotos (p. 22). It is a vocabulary gap, and `note` says so.
