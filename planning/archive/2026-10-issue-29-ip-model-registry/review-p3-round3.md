# Review p3 round 3: the round-2 fixes and the `parameter` vocabulary (#29)

Scope: the six round-2 fixes and the `parameter` vocabulary change. For fix 5, every registry row's `validation`
was checked against the rule. Row numbers are 1-based data rows with the header excluded: E is
`data/literature_evidence.csv`, R is `data/ip_model_registry.csv`. All pages were checked against the PDF text in
`scratchpad/txt/`.

## Verified correct

1. **E214-E226 and R14-R16.** The "ocean_type follows ..." clause is gone from every row. No busch_nwfsc row
   mentions ocean_type now. The rows that still say ocean_type (E237-E240, E275, E276, R21) are bartz2006 or
   agrawal2005, and they are correct.
2. **R33, R35.** Both now carry R34's Bjorkstedt wording, which matches Bjorkstedt pp. 26 and 89. R27-R32 keep
   "apply it unchanged". That is true for coho and steelhead.
3. **E404** is `bound = max`. On E108, E405, E406, E418, E427, E428, E432, E433, E442, E447 and E455, `bound` is
   blank.
4. **E390.** `parameter` is blank.
5. **Cooney and Rebellato.**
   - R4-R6 and R52-R54 are `none`, and every validation field is blank. The notes give the C-12/C-14/C-15
     reason. Sheer p. 13 agrees: "Results from these comparisons were used to weight and summarize reach areas".
   - Rebellato R47-R50 (CM, PK) are `none`. p. 5 says those thresholds were "estimated based on known spawning
     locations ... from the Pacific Salmon Explorer". CH, CO, SK and ST stay `fish_observations`. Their
     thresholds come from the literature (p. 5, Table 1), and only CM and PK PSE sites were added by hand.
6. **Woll 2017 validation quotes.**
   - Every validation quote is on its stated page and fits its species and stage: SK spawning p. 81, SK rearing
     p. 82, CH spawning p. 84, CH rearing p. 86, CO spawning p. 87, CO rearing p. 88, CM p. 89.
   - The access rows R65, R67, R69 and R71 carry their species' spawning quote.
   - "hypotheses for validation under future efforts" is on p. 80.
7. **The rest of the registry under the rule.** No other row needs to change code:
   - burnett2007 (density bins; Sheer pp. 9, 19) and blm2008 (current distribution vs IP > 0.75) compare with
     fish records.
   - busch_nwfsc CH compares with population size (Sheer p. 13). CO R13 is correctly `none`: no coho technique is
     listed on p. 9.
   - boughton_goslin2006 compares with historical records. Those are independent of the juvenile observations its
     envelopes were fitted to.
   - The `none` rows check out:
     - agrawal2005: the Mad River check is of barriers, not fish (PDF p. 19), and the temperature mask was set
       from presence;
     - bjorkstedt2005: the conservative curve was chosen "to reflect current spawning distributions" (p. 89),
       which is calibration;
     - lindley2006, sloat2017, dent2005, bartz2006 and herger2003;
     - woll2015: p. 56, "only conceptual". The AWC figures are shown but never compared with model output;
     - porter2008.
8. **Code (fix 6).**
   - `knw_literature_vocab()$parameter` has 13 names. They match the drafter brief's list, including
     `rear_mad_max`.
   - `.literature_check()` treats `parameter` as optional (it is not in `required`), so NA still passes. The
     fixture's NA row reads cleanly.
   - The new test case (`rear_gradient_min`) fails if `parameter` is removed from the vocabulary, because the
     loop only checks names in the vocab.
   - The roxygen matches the Rd.
   - `scripts/0280` `COVERAGE$parameter` is a 12-name subset of the vocabulary: everything except
     `rear_mad_max`, which is not a coverage target. Nothing disagrees.
   - Results:
     - `devtools::test()` on a copy: 177 pass, 0 fail.
     - The 0280 gate (LOG= to scratch) exits 0: 481 rows, 117 registry quotes all verified, 0 unlinked, 48/48
       coverage.
     - Its two logs are byte-identical to the staged `scripts/logs/habitat/20261001_*` files.

## Errors

### 1. R72, R73 (woll2017 PK): the note claims a comparison that the pink section does not make

**What the rows say.** The note reads: "Not validated: maps were compared by eye with the AWC, aerial counts and
telemetry, and the authors call the models hypotheses for future validation (p. 80, p. 95)."

**What the source says.**
- The pink section (p. 90) compares the map only with "what little is known about pink salmon preferences". It
  cites no AWC, aerial or telemetry source.
- Under the fix-5 rule, the note as written would make PK `fish_observations`. So it contradicts its own
  `none`.
- p. 95 has no validation statement. The pink caveat is on p. 96: "the qualitative suitability models on their
  habitats offer just an unvalidated estimate of likely areas of pink salmon productivity".

**Correct value.** Replace that sentence on R72 and R73 with: "Not validated: the pink map is compared only with
'what little is known about pink salmon preferences' (p. 90), not with fish records, and the authors call the pink
models 'an unvalidated estimate' (p. 96)."

### 2. R64-R71, R74-R76: the shared `validation_result` is wrong for several species

**What the rows say.** Every row reads: "compared by eye with the Anadromous Waters Catalog (and, for sockeye and
Chinook spawning, aerial counts and telemetry), reporting general agreement and named false positives (Chulitna
drainage; Chikuminuk and Upnuk lakes)".

**What the source says.**
- **Sockeye spawning (p. 81)** cites telemetry (Daigneault et al. 2007) and the AWC, with no aerial counts. Aerial
  surveys (Dye & Schwanke 2012) are cited only for Chinook spawning (p. 84).
- **Sockeye rearing (p. 82)** cites no AWC. Its only comparison is the Chikuminuk and Upnuk false positive.
- **False positives are named only for:**
  - sockeye: Chulitna, Chikuminuk and Upnuk on p. 81; Chikuminuk and Upnuk on p. 82;
  - Chinook: Chulitna on p. 84 and on p. 86.

  The coho rows (R68, R69, R75) and the chum rows (R70, R71) state false positives their sections do not have.

**Correct value.** Either write a per-species `validation_result`, or use this one text, which is true for every
row: "Qualitative only: each species' suitability map was compared by eye with fish records: the Anadromous
Waters Catalog (all but sockeye rearing), radio telemetry (sockeye and Chinook spawning) and aerial surveys
(Chinook spawning). General agreement is reported, with false positives named for sockeye (Chulitna drainage;
Chikuminuk and Upnuk lakes) and Chinook (Chulitna drainage), and no statistic. The authors call the models
hypotheses for future validation (p. 80)."

### 3. woll2017: the source says the comparison data were used to develop the models (needs a ruling under fix 5)

Round 2 coded Woll 2017 `fish_observations` on the premise that "the comparisons did not tune the models, so they
are not calibration". The source partly contradicts that premise:
- **p. 80:** "Using our synthesis of salmon-habitat relationships, the mapping and modelling of habitat
  characteristics and the known patterns of salmon abundance for the Nushagak and Kvichak, we developed
  preliminary watershed-scale estimates of relative habitat suitability". The "known patterns" section
  (pp. 40-79) is the AWC maps (e.g. Fig. 18, p. 41), the aerial-count analyses (p. 59) and the telemetry
  analyses (pp. 47, 60). Those are the records the maps were later compared with.
- **p. 24:** the coarse floodplain metrics "were compared with absence-presence data within the State of Alaska's
  Anadromous Waters Catalog to validate the utility of these metrics". Floodplain size is a variable in sockeye,
  Chinook and coho rearing (Tables 15, 17, 19) and chum spawning (Table 20). So for those rows the AWC chose a
  predictor before the output was compared with the AWC.

None of the thresholds was fitted to these records, unlike Rebellato's CM/PK thresholds set from PSE sites. So
this is weaker than the Cooney and Rebellato cases. But the comparison is not independent in the sense the rule
requires.

**Correct value.** Recommended, the smaller change: keep `fish_observations` and add to `validation_result` (or
`note`) on R64-R71 and R74-R76: "Not fully independent: the AWC, aerial counts and telemetry were among the
'known patterns of salmon abundance' used to develop the models (p. 80), and the floodplain metrics were checked
against AWC presence before use (p. 24)."

The strict alternative is `none` on all eleven rows, with that sentence as the reason. Whichever is chosen,
`research/ip_models.md` § Validation (untracked) must say the same. It currently lists woll2017 under
"independent fish records".

### 4. busch2011 R11, R12: the lower network limit was set from the same spawning maps (minor; disclose)

**What the source says.** PDF pp. 2-3. Tidally influenced reaches, which are excluded, include those "in the
floodplain and downstream of the lowermost points of documented (current) spawning". The authors add: "We
verified this lower-limit threshold against state maps of the distribution of spawning fall Chinook salmon". The
89 % comparison (PDF p. 6, result p. 8) uses those same WDFW/ODFW spawning maps.

**Why it stays coded as validation.** The reach IP scores (gradient, width and confinement curves) were not set
from the maps. The abundance and EDT comparisons are independent. So `fish_observations` stands.

**Correct value.** Append to `validation_result` on R11 and R12: "The network's tidal lower limit was set at, and
checked against, the lowest documented spawning on the same state maps (PDF pp. 2-3), so the 89 % comparison is
not wholly independent."

The same, weaker, point applies to blm2008 R17-R19. Burnett's barriers, which BLM reuses, were placed partly from
"1:100,000-scale maps of fish distribution" (Sheer pp. 9, 19). Since BLM's result is not reported, a clause in
the note is enough.

## Summary

| # | Rows | Fix |
|---|---|---|
| 1 | R72, R73 | PK note: compared only with "pink salmon preferences" (p. 90); "unvalidated" is p. 96, not p. 95 |
| 2 | R64-R71, R74-R76 | `validation_result`: aerial surveys are Chinook-only; no AWC for SK rearing; false positives SK and CH only |
| 3 | R64-R71, R74-R76 (+ research/ip_models.md) | Ruling: disclose non-independence (pp. 80, 24), or `none` |
| 4 | R11, R12 (R17-R19) | Disclose the lower limit set from the same spawning maps |

Fixes 1-4 and 6 from round 2 are correct and complete. Fix 5 is correct for Cooney and Rebellato; Woll 2017 has
items 1-3 above.
