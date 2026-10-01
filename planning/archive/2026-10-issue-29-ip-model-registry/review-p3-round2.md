# Review p3 round 2: round-1 fixes re-checked, full sweep of model-tagged rows (#29)

Scope:
- every `data/literature_evidence.csv` row with a `model_id` (324 rows);
- every `data/ip_model_registry.csv` row (81 rows);
- the three `none` rows (479-481) and the untagged rows 410 and 411.

Each note claim and coded field was checked against the PDF text in `scratchpad/txt/`. Quote presence was not
re-checked. Row numbers are 1-based data rows with the header excluded: E is the evidence table, R the registry.

Six findings, seven fixes: finding 3 splits into 3a and 3b. Findings 1-3 are round-1 fixes that left the defect one
axis over; findings 4-6 are new.

## A. Round-1 fixes: verified, with three defects left behind

These fixes are correct:
- E27: `parameter` blanked;
- E310, E311, E318, E319: `parameter` blanked;
- E59 and E214-E226, R14-R16: `life_history_form` blanked;
- E300: note rewritten;
- R34: note fixed;
- R13-R16 and R21: `flow_source` notes;
- E356: note;
- E410 and E411: untagged;
- E101: parameter and bound blanked;
- R1-R3, R39-R51: rebellato validation;
- R47-R50: non-independence note;
- E479 and E481: notes. Checked against Woll 2015 Tables 5-7 (pp. 46, 50, 51), Porter p. 67 and Woll 2017 Table 15.

### 1. The form fix left stale "ocean_type" notes (E214-E226, R14-R16)

**What the rows say.** `life_history_form` is now blank, but the notes still assert the old value:
- **E214-E226 (13 rows).** "...ocean_type follows the committed row for this model's 2 m barrier (Lower Columbia fall
  Chinook)." The committed row, E59, is also blank now.
- **R14-R16.** "Ocean_type follows the committed 2 m barrier row; the Chinook models also cover spring run."

**What the source says.** Sheer Table A1 (p. 33) lists "CHN(s/f)" and "CHN (s)". The barrier sentence on p. 13
applies to Busch's Chinook in general: "Busch et al.: gradient > 16%, documented waterfalls >3.7 m, and bankfull
width <2 m".

**Correct.** Delete the "ocean_type follows ..." clause from all 16 rows. The coverage sentences already present
("Sheer's Busch Chinook models cover spring and fall runs ..."; "only the 350 m elevation rule is fall-only") are
enough.

### 2. The Bjorkstedt fix reached R34 but not R33 and R35

**What the rows say.** R33 (agrawal2005, CH rearing) and R35 (CH access) still end "Bjorkstedt et al. (2005) apply
it unchanged in the NCCC domain."

**What the source says.** Bjorkstedt does not use Agrawal's Chinook IP at all:
- p. 26 applies IP "for spawning and rearing habitat of coho salmon and winter steelhead ..., and for spawning
  habitat of fall-run Chinook salmon";
- p. 89 (PDF 109) says the Chinook model is the same "except that we used habitat suitability curves designed to
  capture the characteristics of areas in which fall-run Chinook salmon typically spawn".

**Correct.** On R33 and R35, use R34's wording: "Bjorkstedt et al. (2005) apply it unchanged for coho and
steelhead; their fall-Chinook spawning curves are their own (bjorkstedt2005)."

### 3. The bound fix removed a real limit (E404) and missed eleven interior breakpoints

**3a. E404 (cooney, CH rearing, BF > 50 m).** The bound was blanked, but this is a 0-suitability edge.
- Table C-1 (C-16) reads "BF > 50 m ≥0 None None None", which is None in every valley class.
- The row's own note says "(suitability 0)".
- Its spawning twin, E20, has the same quote and keeps `bound = max`.
- **Correct:** `bound = max`, as on E20.

**3b. Interior class breaks that still carry `bound` as if they were limits** (parameter blank, not a
0-suitability edge, so `bound` should be blank, as on the 26 fixed rows):

| Row | Model | What the row encodes | What the source says | Correct |
|---|---|---|---|---|
| E108 | porter2008 BT | width `min` 3.05 m | "If Bankfull Width < 3.05m Then LOW" (p. 67). LOW is a capacity class, not absence; the note says so. Its sibling E101 was blanked. | bound blank |
| E405, E406 | cooney CH, ST spawning | gradient `max` 0.5 % | Sediment screen (C-13): reaches ≤ 0.5 % on erodible soils "dropped to low". A downgrade, as the note says. A `max` reads as "suitable only up to 0.5 %", the opposite. Compare E380-E383, the valley downgrade, with bound blank. | bound blank |
| E418 | woll2015 CH overwintering | gradient `max` 1.5 % | Table 4 (p. 40): "Negligible: Streams with gradients > 1.5%". No potential is only above 5 % (E416). | bound blank |
| E427 | woll2015 CO rearing | gradient `max` 2 % | Table 6 (p. 50): "Low: Gradient > 2%". No potential is above 5 % (E426). | bound blank |
| E428 | woll2015 CO rearing | stream order `max` 7 | Table 6: "Negligible: Stream order > 7" (rank 1, not 0). | bound blank |
| E432 | woll2015 CO overwintering | gradient `max` 2 % | Table 7 (p. 51): "Negligible: Gradient > 2% and mean annual flow values < 0.5". | bound blank |
| E433 | woll2015 CO overwintering | MAF `min` 0.5 | Same cell. The row's note says "Not a 0-suitability edge". | bound blank |
| E442, E447, E455 | woll2017 SK, CH, CO rearing | gradient `max` 2 % | Tables 15, 17, 19 (pp. 82, 85, 88) score "Upstream gradient never exceeds 2%" as 1 of 4. p. 38 explains that the rule proxies fine substrate: "all reaches that were not downstream of any reaches with slopes > 2% were assumed to have a substrate size of < 2mm". The variable is the maximum *upstream* gradient, and ≤ 2 % is a *low* class. `max` on reach gradient reads as the reverse. | bound blank (the note already gives the meaning) |

Not flagged, because each is a class-conditional 0-edge rather than an interior break:
- Sloat E248, E253, E254, E256, E260, E261 and E263. Table 1 classes outside which a reach of that confinement is not
  rated.
- Cooney E378, E386, E392 and E400. Width-class edges rated None.

## B. New errors

### 4. E390 carries a parameter that does not exist (`rear_gradient_min`)

**What the row says.** E390 (cooney, ST rearing, gradient min 0) has `parameter = rear_gradient_min`.

**Why it is wrong.**
- The brief's parameter list has `spawn_gradient_min` but no `rear_gradient_min`.
- No other row in the table uses it.
- The CH twin, E402, leaves it blank with the note "No link rear_gradient_min parameter."

**Correct.** `parameter` blank.

### 5. cooney_holzer2006 validation: the redd comparison is calibration of the final ratings (R4-R6, R52-R54)

**What the rows say.** `validation = redd_surveys`. Round 1b set this and noted that the comparison is not
independent.

**What the source says.** The redd ANOVA did more than adjust the ratings: it set the final rating classes.
- C-14/C-15: "These results were used to adjust model parameters ... and formulated our final rating scheme. Using
  the results from our ANOVA analyses, the greatest mean redd count for a habitat category was assigned a 'high'
  intrinsic spawning potential ... between 25% and 50% of the highest value were given a 'moderate' rating, between
  12.5% and 25% a 'low' rating, and less than 12.5% a 'negligible' rating."
- Sheer p. 13 (PDF 20) summarises the same step: "Results from these comparisons were used to weight and summarize
  reach areas".

**Why it is calibration.** The model registered here is the final one. Round 1 untagged E410 and E411 because they
are the superseded initial ratings, and every tagged Cooney row is final Table C-1/C-2. That final model's ratings
were fitted to the same redd counts, which is calibration under the brief ("Calibration (for example widths set
from redd-count reaches) is not validation"). Porter's CART cross-validation was demoted to `none` for the same
reason.

**Correct.** On R4-R6 and R52-R54:
- `validation = none`;
- blank `validation_result`, `validation_page`, `validation_quote` and `validation_quote_source`;
- `note` adds: "The Middle Fork Salmon (CH, 1995-2003) and Upper Columbia (ST, 2004-06) redd ANOVAs compared the
  initial ratings with redds and then set the final rating classes from mean redd counts (C-12, C-14, C-15). That is
  calibration of the final model, not validation."

### 6. woll2017 validation: the model maps were compared with fish data, so `none` contradicts R38 and R1 (R64-R71, R74-R76)

**What the rows say.**
- `validation = none`.
- The note says "maps were compared by eye with the AWC, aerial counts and telemetry, and the authors call the
  models hypotheses for future validation".

**What the source says.** After each table, Woll et al. compare the model output map with fish data:
- **SK spawning, p. 81:** "consistent with patterns observed in telemetry studies (Daigneault et al. 2007) and the
  Anadromous Waters Catalog". It also reports false positives: Chulitna, and Chikuminuk and Upnuk lakes.
- **SK rearing, p. 82:** lakes "identified by this model, even though they are not known to have salmon currently
  rearing in them".
- **CH spawning, p. 84:** "This is in general supported by the aerial surveys (Dye & Schwanke 2012), the telemetry
  work (Daigneault et al. 2007) and Anadromous Waters Catalog". The model "fails in the Chulitna river drainage".
- **CH rearing (p. 86), CO spawning (p. 87) and CO rearing (p. 88):** "This seems to correspond with the limited
  knowledge about ... areas, including the Anadromous Waters Catalog".
- **CM spawning, p. 89:** "corresponds with what little is known about chum salmon spawning areas (Alaska
  Department of Fish and Game 2013b)".
- **PK, p. 90:** "corresponds with what little is known about pink salmon preferences". That is not fish data.

These are qualitative, after-the-fact comparisons of model output with fish distribution. The comparisons did not
tune the models, so they are not calibration. They are the same kind of evidence as Boughton & Goslin's map notes
(R38, coded `fish_observations`, "Qualitative only") and Rebellato's PSE comparison (R1-R3 and R39-R51,
`fish_observations`). The authors' own word "unvalidated" (p. 96, pink) does not change what was done. Under the
vocabulary ("how a model was checked against fish"), `none` is wrong.

**Correct.** On R64-R71 and R74-R76 (SK, CH, CO and CM, every stage including access, matching how R3 and R12 carry
model validation):
- `validation = fish_observations`;
- `validation_result`: "Qualitative only: each suitability map was compared by eye with the Anadromous Waters
  Catalog (and, for sockeye and Chinook spawning, aerial survey counts and radio telemetry), reporting general
  agreement and named false positives (Chulitna drainage; Chikuminuk and Upnuk lakes), with no statistic. The
  authors call the models hypotheses for future validation (p. 80)."
- `validation_page = 84`, quoting "This is in general supported by the aerial surveys (Dye & Schwanke 2012), the
  telemetry work (Daigneault et al. 2007) and Anadromous Waters Catalog". The page and quote may be per species
  (pp. 81, 82, 86, 87, 88, 89).

R72 and R73 (PK) stay `none`.

The two models must agree. If the team rules that a by-eye comparison is not validation, then R38, R1-R3 and
R39-R51 must become `none` instead.

## C. Checked and found consistent with the source

The sweep found these accurate against the source:
- every other note's search claims, "unchanged" claims and page attributions (Sheer pp. 6, 8, 9, 12-16, 19, 20, 43,
  45, 47; Agrawal PDF pp. 9, 12-13, 15, 19, 20; Bjorkstedt pp. 25-26, 54, 89; Busch PDF pp. 2-4; Rebellato
  pp. 3-7, 12; Porter pp. 18, 22, 32, 66-67; Woll 2015 pp. 39-56 and Appendix A pp. 8, 13, 17; Woll 2017 pp. 26, 33,
  36, 38, 80-96; Boughton pp. 4-5, 9, 13-18; Cooney C-6 to C-17; Lindley);
- every parameter/stage/variable pairing;
- the flow fields.

## Summary

| # | Rows | Mechanism | Fix |
|---|---|---|---|
| 1 | E214-E226, R14-R16 | A, stale note after the form fix | drop the "ocean_type follows" clause |
| 2 | R33, R35 | A, "unchanged" claim false for Chinook | R34's wording |
| 3a | E404 | B, real 0-edge lost its bound | `bound = max` |
| 3b | E108, E405, E406, E418, E427, E428, E432, E433, E442, E447, E455 | B, interior breaks coded as limits | `bound` blank |
| 4 | E390 | B, nonexistent parameter | `parameter` blank |
| 5 | R4-R6, R52-R54 | B, calibration coded as validation | `validation = none` |
| 6 | R64-R71, R74-R76 | B, fish comparison coded as none | `fish_observations`, or recode R38, R1-R3 and R39-R51 to none |
