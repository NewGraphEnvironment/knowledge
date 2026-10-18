# Audit: the claims in `vignettes/chinook_rearing.Rmd`, checked against its data and code (#62)

Audited 2026-10-18 against the rendered `docs/articles/chinook_rearing.html` (rendered 12:00 local),
`inst/vignette-data/chinook_rearing.rds`, the code named in the brief, link's `configs/default` at the run's
commit `a17e917` (read with `git show`), fresh's `frs_habitat_predicates()` / `.frs_run_connectivity()`, and
these local, ignored files: `data/fdis/derived/{visits_link,visits_species}.csv` (used to rebuild the tuning
population, which matches exactly: 7,123 / 216 / 104 groups, then 4,490 / 215 / 43), `data/tune/CH_rear_curve.rds`
(the fitted GAM, used to predict at other reference values), `data/compare/CH_rear_segments.rds`, and
`data/compare/catalog/bulk_floodplain.gpkg`. Nothing in the repo was edited.

Verdicts: **WRONG**: the sentence is false or misleading as written. **UNSUPPORTED**: nothing in the data or
code shows it. **VERIFIED**: checked, with the source named.

---

## Summary: WRONG and UNSUPPORTED, most consequential first

### W1. The grade does not use "the segment's own ... distance to a river" for most segments (WRONG, and a method defect)
Article: "A segment's grade is the curve's predicted chance of a catch ... at the segment's own size, gradient and
distance to a river".
`R/grade_species.R` walks to the river only for exception candidates: accessible stream-branch segments inside
the gradient maximum that **fail** the size test (`cand <- ... & !size_ok`). Every other segment gets
`dist_m = NA`, which `knw_grade()` turns into the 50 km cap. The tuning log shows 373,133 walked and 348,873 found
among 856,244 accessible segments, so roughly 480,000 accessible segments are graded as if 50 km from any river,
including every segment with MAD at least 0.75 m³/s however close it lies to one.
Because size and distance share one tensor smooth, this matters a lot. Predicted from `CH_rear_curve.rds` at
gradient 3 %:

| MAD (m³/s) | rate 100 m from a 3 m³/s river | rate at the 50 km cap | grade at 100 m | grade at the cap |
|---|---|---|---|---|
| 0.3 | 0.114 | 0.011 | 0.78 | 0.07 |
| 0.8 | 0.110 | 0.020 | 0.75 | 0.13 |
| 2 | 0.108 | 0.032 | 0.74 | 0.22 |

So a 0.3 m³/s stream 100 m from a river (walked, because it fails the floor) grades 0.78, while a 0.8 m³/s stream
at the same spot (not walked, because it passes) grades 0.13. Several later claims depend on this:
- the grade-class table and "graded km": kept segments are graded at the cap, gained exception segments at their
  real, short distance;
- "It gives up low-grade streams and takes on high-grade ones near rivers": the high grade of the gained streams
  comes partly from their being the only small streams graded at their real distance;
- the floodplain "graded ha" columns, the map's grade and floodplain panels, and "Weighted by grade, it barely
  moves";
- `knowledge/habitat_grade/v1` and the plain-words sentence in `habitat_thresholds_tuned.md` ("A grade from 0 to 1
  then gives the use to expect on each segment").

The difference in graded km between the rules (gained minus lost) mostly involves walked segments (the size losses
were walked; the exception gains were walked), so the +4,337 is less distorted than the class totals. The
1,398 km gained through the gradient band pass the size test and are graded at the cap.

### W2. The flow curve's "26 %" and "2.6 times" hold only at the 50 km reference distance, which the article never names (WRONG by omission)
Article: "The chance of a catch rises steadily with flow: at 0.1 m³/s it is 26 % of the chance at 0.75 m³/s, and at
5 m³/s it is 2.6 times as high." The numbers match `x$curves` (0.260, 2.556). But `knw_tune_curve()` draws the size
and gradient curves at `log_dist = log(dist_cap_m + 10)`, that is 50 km from any 3 m³/s river, at gradient
`grad_max / 2` = 4.5 %. With the tensor smooth, the size effect depends on distance (predicted from the saved model,
gradient 4.5 %):

| distance to the 3 m³/s river | 0.1 m³/s vs 0.75 | 5 m³/s vs 0.75 |
|---|---|---|
| 100 m | 1.08 | 0.97 |
| 1 km | 0.44 | 1.50 |
| 3 km | 0.24 | 3.07 |
| 50 km (the curve shown) | 0.26 | 2.56 |

Near a river, flow makes no difference. "Each curve below holds the other two at reference values" should name
them (size 0.75 m³/s, gradient 4.5 %, distance 50 km). The article also says beyond about 10 km "the curve is not to
be read" while drawing the size and gradient curves at 50 km.

### W3. "That is the range a rule can move the score" (WRONG)
"The model with no rule term at all scores 231.9 above the best rule" is right (`ddev_null` of the best =
−231.86). But 534 of the 2,795 rules score **worse** than the no-rule model, by up to 379.6 (`max(tune$ddev_null)`).
A rule can move the score well beyond 231.9 in the worse direction. Suggested: "a rule can improve on it by at most
that much."

### W4. Floodplain "falls by 20 %, more than the km": compares 16 groups with 125 (WRONG population)
The floodplain fall, −20.0 %, is over the 16 mapped groups. The km figure it is set against, −12.4 %, is over all
125. On the same 16 groups the km fall is −18.8 % (`compare` rows for the 16 `floodplain` groups), so the floodplain
falls only a little more than the km. On those groups graded km rises 16.4 % while graded floodplain ha rises
0.9 %. The explanation that follows ("The streams the flow floor drops are mid-sized ones with floodplain beside
them, and the small streams the exception adds bring little") is built on the mismatched comparison, and no saved
table splits floodplain ha by lost or gained segment (see U1). The same "more than the km's −12 %" sentence is in
`research/chinook_rearing_tuned.md`'s head paragraph (not new in this branch).

### W5. "These are the visits the tuning learned from" (WRONG: the check's population is about 2.3 times larger)
The FDIS check in `knw_compare_rules()` takes every FDIS visit with status `present`/`absent`, a fished area of
10–10,000 m² and edge type in {1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350}, on any of the 125 groups'
segments: 10,515 visits (5,717 + 4,798). The tuning learned from 4,490 (7,123 before the both-outcomes filter). The
check adds river-polygon visits, groups with one outcome, visits with a barrier downstream and visits outside link's
range. The circularity caveat holds for the 4,490 inside it, but the sentence says all of them. "On **all** FDIS
visits on these groups' accessible segments" also overstates: the area filter, the status filter and the
edge-type list apply (lake edge types are not in it).

### W6. "Held out" is not fully held out: each held-out group's own level is fitted on the visits being scored (WRONG by omission, method description)
Article: "The model is fitted on four folds and predicts the visits of the fifth ... how surprised the model is, in
total, by the visits it did not see." In `.tune_score_one()` the rule, area, data-set and era coefficients come from
the four folds, but each held-out group then refits its own intercept on its own held-out visits (`glm.fit(...,
offset = eta[i])`), and the deviance is scored on those same visits. The research files say this ("each held-out
WSG refits only its own intercept, which costs every rule the same"); the article does not. It is defensible, but
"visits it did not see" is not exactly true, and the reader is told the model "takes ... the watershed group into
account" without being told the held-out group's level is fitted in-sample.

### W7. Nested selection is not independent of the scored fold (WRONG in a detail)
"the choice was made on four folds and scored on the fifth". The choice for fold k uses the per-group held-out
deviances `Sw` of groups in the other four folds (`honest` block of `knw_tune_score()`). Each of those was computed
from a model trained on every fold but its own, **including fold k**. So fold k's visits have entered the rule
coefficients behind the choice. The leakage is small (one fold of training data for each of the other folds' scores)
but the sentence claims a clean separation. The bootstrap likewise resamples saved per-group deviances; it does not
refit (the article's "repeating the choice" is accurate).

### W8. Limits list: "River polygons ... keep `default`'s tests under every rule" contradicts the first section (WRONG)
The first section says, correctly, that river polygons keep their **size** test and share the stream test's gradient
maximum, "so that one value moves with it". `knw_compare_rules()` substitutes the tuned gradient into fresh's
predicate (`ps_t$ranges[[stage]]$gradient[2] <- tuned$grad_max`), so river-polygon segments go from 5.49 % to 9 %
under the recommended rule (part of the 230 km "other (river-polygon branch or mixed)" gain). The limits bullet
drops "size" and says the opposite.

### U1. "mid-sized ones with floodplain beside them" and "the small streams the exception adds bring little" (UNSUPPORTED by any saved table)
`floodplain.csv` has hectares per rule only, not per lost or gained segment. An indicative rerun for BULK alone
(`knw_floodplain_ha()` on `inst/vignette-data/bulk_segments.rds`, which holds accessible segments only and
simplified geometry, so its totals run about 9 % above `floodplain.csv`'s) gives 16.5 ha per km beside lost
segments, 5.6 ha per km beside gained ones and 19.3 beside kept ones. That points the same way as the sentence, but in
one group, from a non-reproducing run. By stream order the BULK loss is spread over order 2 (3,418 ha), 3 (4,617)
and 4+ (4,161), so "mid-sized" is loose. Province-wide, the size loss is 8,091 km on order 2, 9,196 on order 3 and
6,953 on order 4+ (`change` table).

### U2. "The exception is not mainly a way of adding streams" (UNSUPPORTED, arguably contradicted)
On the 4,490 visits, the same size floor and gradient without the exception (`mad>=0.75|g<=0.09|none`) takes in 634
visits and 88 detections. With the exception it takes in 1,047 and 166. So the exception adds 413 visits and 78 of
the 166 detections. On the ground it adds 9,666 km. It is narrower only relative to `default`. Suggested: "With
it, a higher floor keeps ..." and drop "not mainly a way of adding streams".

### U3. Gradient falls "less steeply than with flow" (UNSUPPORTED)
The two axes have different units (fraction against log m³/s), so "less steeply" has no common measure. Over the
plotted ranges, gradient moves the relative chance from 2.37 to 0.38 (a factor of 6) and flow from 0.0016 to 6.2.
Also, at 100 m from a river the flow curve is flat (W2), so the comparison depends on the reference distance.

### U4. "Beyond about 10 km the band widens and the curve is not to be read" (UNSUPPORTED as stated)
The band's width ratio (`rel_hi / rel_lo`) is 9.9 at 10 m, 8.9 at 1 km, 11.2 at 11 km and 14.5 at 24 km, a modest
widening. 43 % of the modelled visits lie beyond 10 km (7.6 % at the 50 km cap), so data are not sparse there. What
does show beyond about 24 km is the curve turning back up (0.10 at 24 km, 0.20 at 41 km). Also see W2: the other
two curves are drawn at 50 km.

### U5. The curve figure's band is not a band on the relative chance (UNSUPPORTED caption wording, minor)
`rel_lo` and `rel_hi` are the pointwise 95 % band of the linear predictor divided by the point estimate at the
threshold. They do not collapse at the threshold: at the gradient threshold the band is 0.21 to 4.7. "relative to
the chance at the recommended threshold ... with its 95 % band" reads as a band on the ratio.

### U6. "link measures it from a segment's downstream end" (UNSUPPORTED for link)
link does not measure an exception distance yet (the rule needs a new rule shape in link, and link#346 is open).
knowledge's comparison and grade (`knw_grade_species()`) walk from the segment's downstream end. Suggested: "the
comparison here, as link would, measures it ...". "so the applied rule is a little looser" is VERIFIED against
`chinook_rearing_tuned.md` (median 0.9 m, 75th percentile 90 m, 90th 332 m).

### U7. "Every number is read from the tables the tuning wrote" (minor overstatement)
Typed in prose: 10 km, 1 ha, 100 ha, order 2, "55 groups ... 7 %", "near 0.75 m³/s", "about 3 m³/s", 300 m, 3 km,
10 km, "about 10 km". All checked below and right except as noted, but they are not read from tables.

### Smaller points (not wrong, worth a word)
- Curve "on the same visits": 4,487 visits and 214 detections. Three visits have no MAD (`no_size = 4` in
  `CH_rear_curve.rds`, and one group effect drops with it).
- "with the same other terms": same nuisance terms, but the group is a random effect in the GAM and a fixed effect in
  the scorer.
- River test "with any width": `channel_width BETWEEN 0 AND 9999` fails on a NULL width.
- Lake test: "inside a lake of at least 100 ha" also takes manmade waterbodies of at least 100 ha (fresh's compiled
  predicate). The population filter's `wb_lake` does the same (`R/link_width.R`).
- "Rearing that has no spawning within 10 km is removed": `frs_cluster(..., direction = "both",
  bridge_gradient = 0.05, bridge_distance = 10000)`. The 5 % bridge gradient is not mentioned.
- First section "Three passes follow" (overlay, cluster, lake/wetland connection) and later "link's three stages"
  (test behind the access gate, overlay, cluster) count different things.
- km table row "accessible stream" (225,152 km) is all accessible segments (`km(seg$accessible)`), lakes, wetlands
  and river polygons included.
- "Nearly all the loss ... carry less than 0.75 m³/s" also covers segments with no MAD (`!size_tun` holds when
  `knw_size` is NA).
- bcfishobs check: the lift is over 826 **locations** (records grouped by blue line and metre) on accessible
  stream-branch edges, against each rule's share of accessible stream-branch km, not of all accessible km.
- Nested-selection fold 4: the chosen rule (233.9) also loses to the no-rule model (231.9). Not claimed otherwise.

---

## Sentence by sentence

### Opening
| # | Claim | Verdict | How |
|---|---|---|---|
| 1 | link draws CH rearing as yes/no on every segment from a size floor and a gradient maximum | VERIFIED (simplified) | compiled rear predicate at `a17e917`; waterbody tests come later |
| 2 | choose between 2,795 versions | VERIFIED | `nrow(tune)` = 2795 |
| 3 | "Every number is read from the tables the tuning wrote" | UNSUPPORTED (minor) | U7 |
| 4 | Recommended: gradient ≤ 9 %, MAD ≥ 0.75 m³/s or a ≥ 3 m³/s river within 1 km | VERIFIED | `tune$recommended` = `mad>=0.75|g<=0.09|Q3@D1000`; = `thresholds$rule` |

### What does link draw now?
| # | Claim | Verdict | How |
|---|---|---|---|
| 5 | accessible and one of four tests | VERIFIED | access gate `h.accessible AND access_ch > 0` (`compare_rules.R`); four test types in `rules.yaml` (two W rules) |
| 6 | stream: stream edge, gradient ≤ 5.49 %, width ≥ 1.5 m | VERIFIED | thresholds row CH `rear_gradient_max 0.0549`, `rear_channel_width_min 1.5`; edges 1000/1100/2000/2300 |
| 7 | river: river polygon, same gradient, any width | VERIFIED (nuance) | predicate `waterbody_key IN rivers_poly AND gradient BETWEEN 0 AND 0.0549 AND channel_width BETWEEN 0 AND 9999`; NULL width fails |
| 8 | wetland ≥ 1 ha | VERIFIED | `wetland_ha_min: 1.0` (edges 1000/1100 and 1050/1150) |
| 9 | lake ≥ 100 ha | VERIFIED (nuance) | `lake_ha_min: 100.0`; includes manmade waterbodies |
| 10 | Three passes follow | VERIFIED (counting differs from line 46) | `.frs_run_connectivity()`, overlay |
| 11 | Known reaches entered by hand are set | VERIFIED | `frs_habitat_overlay()` from link's `user_habitat_classification.csv` |
| 12 | Rearing with no spawning within 10 km is removed | VERIFIED | `cluster_rearing TRUE`, `cluster_bridge_distance 10000` (`parameters_fresh.csv`); also a 5 % bridge gradient |
| 13 | Lake and wetland rearing must connect to spawning | VERIFIED | `requires_connected: spawning`, 10 km, on the L rule and the first W rule; `.frs_bucket_connected()` on `lake_rearing`/`wetland_rearing` |
| 14 | width modelled only on order 2 and up, so the stream test never admits an unmeasured first-order stream | VERIFIED | `R/link_width.R` (fwapg models no order-1 stream); CLAUDE.md (#54) |
| 15 | the recommended rule can | VERIFIED | `change`: 6,952 km gained through the exception on order 1 |
| 16 | the tuning asks about the stream test only | VERIFIED | `knw_rule_in()`; population excludes river/wetland/lake visits |
| 17 | river polygons keep their size test, wetlands and lakes theirs | VERIFIED | `compare_rules.R`: off the stream branch, fresh's predicate |
| 18 | river polygons share the gradient maximum, so it moves with it | VERIFIED | `ps_t$ranges[[stage]]$gradient[2] <- tuned$grad_max` |

### Which rules were asked about?
| # | Claim | Verdict | How |
|---|---|---|---|
| 19 | MAD floors 0.1 … 1; width floors 1 … 4 | VERIFIED | `knw_tune_grid()` defaults; `unique(tune$size_min)` |
| 20 | gradients 3, 4, 5.49, 7, 9 % | VERIFIED | `unique(tune$grad_max)` |
| 21 | exception Q 1 … 50, D 100 … 5,000 | VERIFIED | `unique(tune$exc_q)`, `unique(tune$exc_d)` |
| 22 | a segment failing size still counts when a river of ≥ Q lies within D downstream | VERIFIED | `knw_rule_in()`: `grad_ok & (size_ok | ex)`; gradient still applies |
| 23 | 13 × 5 × 43 = 2,795 | VERIFIED | computed |
| 24 | default is one of them: width ≥ 1.5 m, 5.49 %, no exception | VERIFIED | `tune[is_default, ]` |
| 25 | the exception exists because CH juveniles move up out of large rivers into small streams close to them | VERIFIED (by literature, not cited in the article) | `data/literature_evidence.csv` non-natal tributary rows (Gregersen 2019; Kirsch et al. 2014; Buckwalter & Kirsch 2012) |
| 26 | a small stream next to a large river can hold them when one far away does not | VERIFIED | `research/chinook_stream_size.md`: within 500 m 14.6 % vs 0.8 % |

### What evidence scores a rule?
| # | Claim | Verdict | How |
|---|---|---|---|
| 27 | FDIS electrofishing export, visits placed on link's segments | VERIFIED | `0310`, `visits_link.csv` |
| 28 | stream edge outside river polygons, wetlands ≥ 1 ha, lakes ≥ 100 ha | VERIFIED | `knw_tune_run()` `base`; `wb_*` in `R/link_width.R` (1 ha, 100 ha) |
| 29 | fished area 10–10,000 m² | VERIFIED | `area_range = c(10, 10000)` |
| 30 | in a group where link marks CH present | VERIFIED | `in_range` from `link::lnk_species_pooling()` (`0310`) |
| 31 | no record code that could hide CH | VERIFIED | `status != "blocked"`; no `unknown` status visits are in the population (rebuilt: absent 6,907, present 216) |
| 32 | no natural CH barrier downstream | VERIFIED | `barrier_dnstr_ch %in% FALSE` |
| 33 | 7,123 visits in 104 groups, 216 caught CH | VERIFIED | `summary`; rebuilt from `data/fdis/derived` |
| 34 | groups never or always catching cannot tell rules apart, so 43 groups with both | VERIFIED | `.tune_modelled()`; 60 never, 1 always |
| 35 | 4,490 visits and 215 detections | VERIFIED | `tune$n_visits`, `n_detect`; rebuilt |
| 36 | gradient of its FWA segment | VERIFIED | `cols["grad"] = "fwa_gradient"` |
| 37 | width link would use on an unmeasured stream, never the visit's measured width | VERIFIED | `cw_deploy`: stored width unless `FIELD_MEASURMENT`, then the model on order > 1, else NA |
| 38 | the modelled MAD | VERIFIED | `mad_pick` |
| 39 | distance to the first river of each Q, same flow | VERIFIED | walks, `src = "pick"` |

### How is a rule scored?
| # | Claim | Verdict | How |
|---|---|---|---|
| 40 | model has fished area, data set, era, group, plus in/out | VERIFIED | `.tune_fold_setup()`: `log_area`, `data_set`, `era`, `wsg`; cloglog binomial |
| 41 | 5 folds of 9, 8, 9, 8, 9, balanced by detections | VERIFIED | `table(groups$fold)`; `.tune_fold_of_wsg()` ranks by detections, deals in shuffled blocks |
| 42 | fitted on four, predicts the fifth; each group held out once | WRONG by omission | W6 |
| 43 | score is held-out deviance; lower is better | VERIFIED | summed binomial deviance |
| 44 | compared with the best group by group; SE over groups | VERIFIED | `.tune_sel()`: `sqrt(n) * sd(per-group diff)` |
| 45 | no-rule model 231.9 above the best | VERIFIED | `ddev_null` = −231.86 |
| 46 | "That is the range a rule can move the score" | WRONG | W3 |

### Which rules can the data not tell apart?
| # | Claim | Verdict | How |
|---|---|---|---|
| 47 | region: within one SE of the best | VERIFIED | `region = tot - tot[best] <= se`, and converged (all 2,795 converged) |
| 48 | 23 rules | VERIFIED | `sum(in_region)` |
| 49 | every one by flow, MAD 0.35–1 | VERIFIED | region rows |
| 50 | every one has the exception, Q 1–10, D 1–2 km | VERIFIED | region rows |
| 51 | every one at 7 % or 9 % | VERIFIED | region rows |
| 52 | default 196.3 above, SE 81.6, outside | VERIFIED | `tune[is_default, ]` |
| 53 | every rule without the exception is outside; best 136.9 | VERIFIED | `min(ddev_best[is.na(exc_q)])`; no such rule in region |
| 54 | every width rule outside; best 70.6 | VERIFIED | `min(ddev_best[size_var == "width"])` |
| 55 | profile caption (best score per value; filled = a rule in region; ring = default) | VERIFIED | chunk `profile` |

### Which rule is recommended?
| # | Claim | Verdict | How |
|---|---|---|---|
| 56 | choice fixed before scoring: fewest departures, then best score | VERIFIED (code; timing by documentation) | `.tune_pick()`; spec "fixed before its first fit" in `tune_score.R`, `0320` header |
| 57 | every region rule departs in all three parts | VERIFIED | `departures == 3` for all 23 |
| 58 | exception under 200 m moved off, fixed in advance | VERIFIED | `d_floor = 200`; `.tune_pick()` |
| 59 | reason (stream visit vs a catch in the river snapped to the mouth) | VERIFIED (documented) | `tune_score.R` roxygen; `chinook_rearing_tuned.md` limits |
| 60 | recommended distance is 1 km, so it stands | VERIFIED | `exc_d = 1000` |
| 61 | narrower than default; fewer visits in, as many catches | VERIFIED | 1,047 vs 2,330 in; 166 vs 165 |
| 62 | table: 2,330 / 165 / 7.1 % / 2.3 %; 1,047 / 166 / 15.9 % / 1.4 % | VERIFIED | `n_in`, `n_detect_in`, `raw_rate_in/out` |
| 63 | exception not mainly a way of adding streams | UNSUPPORTED | U2 |

### How firm is the choice?
| # | Claim | Verdict | How |
|---|---|---|---|
| 64 | three checks fixed before the run | VERIFIED (documented) | `0320` header spec |
| 65 | dealing into folds is random | VERIFIED | seeded shuffle |
| 66 | 4 more seeds; 0 of 4 recommend the same rule | VERIFIED | `seeds$recommended` |
| 67 | recommended rule in the region of 4 | VERIFIED | `main_rec_in_region` |
| 68 | default in 0 | VERIFIED | `default_in_region` |
| 69 | 3 differ only in the gradient | VERIFIED | seeds 55, 57, 58 at 7 % |
| 70 | seeds table (rules; region sizes 24, 59, 18, 24) | VERIFIED | `seeds` |
| 71 | region and pick use every group | VERIFIED | `.tune_sel(Sw, all)` |
| 72 | choice made on four folds, scored on the fifth | WRONG in a detail | W7 |
| 73 | nested table values, total 1,234.5 / 1,347.0 / 1,382.5 | VERIFIED | `honest` |
| 74 | beats default in total | VERIFIED | |
| 75 | loses in 1 of 5, fold 4, by 3.6 | VERIFIED | 233.93 − 230.29 |
| 76 | every fold's choice by flow with the exception | VERIFIED | `honest$rule` |
| 77 | resampling 200 times, repeating the choice | VERIFIED (resamples saved per-group deviances, no refit) | `n_boot`, `extra` block |
| 78 | 22 % recommended, 75 % in region | VERIFIED | `boot_rec_share` 0.22, `boot_region_share` 0.75 |
| 79 | MAD 0.75 in 55 %, a MAD floor in 100 % | VERIFIED | shares 0.545, 1.0 |
| 80 | river ≥ 3 m³/s in 76 % | VERIFIED | 0.755 |
| 81 | 1 km in 62 %, 2 km in 33 % | VERIFIED | 0.62, 0.325 |
| 82 | gradient 9 % 40 %, 7 % 34 %, 5.49 % 25 % | VERIFIED | 0.405, 0.335, 0.255 (half-way values round both ways in floating point) |
| 83 | parts more stable than the whole | VERIFIED | each part ≥ 40 % against 22 % |
| 84 | shape settled: floor near 0.75, exception near a ~3 m³/s river | VERIFIED (loosely) | MAD 0.5–1 in 98.5 %, Q = 3 in 75.5 % |
| 85 | gradient the least settled part | VERIFIED | top share 40.5 %, lowest of the four parts |
| 86 | earlier tuning of the same rules on 55 groups recommended the same shape at 7 % | VERIFIED | `chinook_rearing_tuned.md`: same 2,795-rule grid; head says it differs only in gradient (9 against 7); scored on 26 groups of the 55-group build |

### How does the chance of a catch change?
| # | Claim | Verdict | How |
|---|---|---|---|
| 87 | one smooth model after the choice, on the same visits | VERIFIED (4,487 of 4,490) | `knw_tune_curve()`; `CH_rear_curve.rds` |
| 88 | size and distance together, gradient alone, same other terms | VERIFIED (group random, not fixed) | `te(log_size, log_dist) + s(grad) + nuisance + s(wsg, re)` |
| 89 | each curve holds the other two at reference values | VERIFIED but incomplete | values never named: W2 |
| 90 | relative to the chance at the threshold | VERIFIED | `rel_rate = exp(fit - at)` |
| 91 | caption: "with its 95 % band" | UNSUPPORTED wording | U5 |
| 92 | flow and gradient have no bend at their thresholds | VERIFIED (at the reference) | size log-log slope falls smoothly 0.84 → 0.36; gradient edf 1.00 |
| 93 | rises steadily with flow; 26 %; 2.6 times | WRONG by omission | W2 (numbers match the table; they hold at 50 km only) |
| 94 | falls in a straight line with gradient | VERIFIED | constant log slope −9.6 per unit gradient |
| 95 | less steeply than with flow | UNSUPPORTED | U3 |
| 96 | the two thresholds are where in and out separate best, a cut on a slope | VERIFIED | scoring vs curves |
| 97 | distance bends; highest about 120 m | VERIFIED | peak at 124.6 m |
| 98 | nearly as high at 300 m, 1.7 times the 1 km chance | VERIFIED | 1.65 (peak 1.80) |
| 99 | falls to 42 % at 3 km and 21 % at 10 km | VERIFIED | 0.424, 0.208 |
| 100 | the recommended distance sits on the way down, past the bend | VERIFIED | |
| 101 | beyond about 10 km the band widens, not to be read | UNSUPPORTED as stated | U4 |

### What is the grade?
| # | Claim | Verdict | How |
|---|---|---|---|
| 102 | the grade: predicted chance on a standard visit at the segment's own size, gradient and distance, group effect left out | WRONG for distance | W1; standard visit = median log area, modal data set (FDIS), latest era: VERIFIED |
| 103 | divided by the 95th percentile of accessible segments, 0.1457, capped at 1 | VERIFIED | `knw_grade()`; log line 1446 |
| 104 | at 1, top twentieth of the accessible network | VERIFIED | quantile 0.95 over graded accessible segments, all 125 groups pooled |
| 105 | 0.3 is about a third as often as one at 1 | VERIFIED (approximately: a third of the reference rate; segments "at 1" may be above it) | |
| 106 | expected use, not habitat quality | VERIFIED | roxygen |
| 107 | 125 groups; 852,431 of 856,244 graded; the rest have no modelled flow | VERIFIED | log: `no_gradient = 0` |
| 108 | the grade is the same under either rule | VERIFIED | one grade per segment (but see W1 on how distance enters) |
| 109 | grade-class table | VERIFIED | `compare` ALL row |
| 110 | 12,577 fewer km, 4,337 more graded km | VERIFIED | computed |
| 111 | gives up low-grade streams, takes on high-grade ones near rivers | VERIFIED by table, but partly an artefact | W1 |

### What does it change on the ground?
| # | Claim | Verdict | How |
|---|---|---|---|
| 112 | both rules through link's three stages on copies of every CH group | VERIFIED | `knw_compare_rules()`; groups from `streams_habitat_ch` (125) |
| 113 | default is the regeneration, not the stored flags | VERIFIED | `stored_vs_default_differ_km` 44.5 |
| 114 | km table: 225,152 / 101,184 / 88,607 / 24,843 / 12,266 / −12.4 % | VERIFIED (accessible row is all accessible segments) | `compare` ALL |
| 115 | range −73.6 % to 29.9 %, median −6.2 %, 48 of 125 gain | VERIFIED | per-group rows |
| 116 | change-by-reason table | VERIFIED | `change` summed by direction × reason; order "1" = `stream_order <= 1` |
| 117 | nearly all the loss, 24,542 km, wide enough for default, under 0.75, no river within 1 km | VERIFIED (98.8 %; includes NA MAD) | reason logic in `compare_rules.R` |
| 118 | most of the gain, 9,666 km, through the exception | VERIFIED (78.8 %) | |
| 119 | 6,952 km of that on first-order streams default never admits unmeasured | VERIFIED | `change` order 1 |
| 120 | BULK: 1,611 vs 2,123 (−24.1 %), losing 744, gaining 233 | VERIFIED | `compare` BULK |
| 121 | map caption (legend "tuned only" = recommended only; three panels; line width by order) | VERIFIED | `R/compare_map.R`; the rendered PNG |
| 122 | orange is whole tributaries below the floor; gains few, short reaches of small streams beside a river | VERIFIED (visual; BULK gains about 142 km order 1, 47 order 2, 15 order 3, 29 order 4+ in the indicative rerun) | rendered map |
| 123 | floodplain: groups whose whole floodplain is mapped; 30 m cells to the nearest segment | VERIFIED (nearest among the claiming blue lines' segments) | `R/floodplain_ha.R` |
| 124 | floodplain table (16 groups; BULK) | VERIFIED | `floodplain` summed by rule |
| 125 | falls by 20 %, more than the km | WRONG | W4 |
| 126 | mid-sized streams with floodplain dropped; exception's small streams bring little | UNSUPPORTED | U1 |
| 127 | weighted by grade, it barely moves | VERIFIED (+0.9 %), but carries W1 | |
| 128 | FDIS check: 17 % vs 1.5 %; default 14 % vs 2.2 % | VERIFIED | 795/4,661, 85/5,854, 773/5,717, 107/4,798 |
| 129 | "all FDIS visits ... rivers included"; "the visits the tuning learned from" | WRONG | W5 |
| 130 | other-source records, never scored a rule, 3.3 times vs 2.5 | VERIFIED (locations, stream-branch km) | `checks` lift 3.27, 2.46; non-FDIS `source` |
| 131 | presence-only, rewards concentration | VERIFIED | interpretation consistent with the lift's definition |

### Limits and next
| # | Claim | Verdict | How |
|---|---|---|---|
| 132 | not applied; nothing changes until link reads the thresholds table | VERIFIED | link#346 open ("Threshold calibration read from published evidence ...") |
| 133 | juveniles by electrofishing, on streams; spawning not part | VERIFIED | |
| 134 | river polygons, wetlands, lakes keep default's tests under every rule | WRONG for river polygons | W8 |
| 135 | separation, not extent; 1.4 % vs 2.3 % out | VERIFIED | `raw_rate_out` 0.0142, 0.0231 |
| 136 | a cut on a slope; neighbours nearly as good; the region gives the range | VERIFIED for size and gradient; distance is past a bend | |
| 137 | distance measured at the visit, link measures from the segment's downstream end, applied rule looser | VERIFIED for "looser"; UNSUPPORTED for "link measures" | U6 |
| 138 | gradient scored on FWA segments, link applies it to its own finer ones | VERIFIED | `fwa_gradient` vs `seg$gradient` |
| 139 | one link run, `20261017_004619-3f4c713b` | VERIFIED | `meta$link_run_uid` |
| 140 | not habitat quality | VERIFIED | |
| 141 | link's half waits on link#346 | VERIFIED | `gh issue view 346` |

---

## `research/habitat_thresholds_tuned.md`, "In plain words"
| Claim | Verdict | How |
|---|---|---|
| link's yes/no test: big enough, not too steep | VERIFIED (simplified) | |
| asked which version best predicts where fish were caught in watersheds the scoring had not seen | VERIFIED with W6's caveat; for BT spawning the response is spawner evidence, not any catch | |
| ladder of size floors by flow or width, gradient limits, an allowance for a river close downstream for small streams | VERIFIED | `knw_tune_grid()` |
| scored on held-out groups, kept those it cannot tell from the best, recommended the one closest to link's current test | VERIFIED | `.tune_pick()` |
| link's current test is not among them for any fitted species but grayling | VERIFIED | `default_in_region` FALSE for BT rear, BT spawn, CH, CO, RB, ST, WCT (underpowered); TRUE for GR |
| every recommended rule but grayling's draws less habitat | VERIFIED | `compare` ALL: BT −37.3, BT spawn −25.2, CH −12.4, CO −4.9, GR 0, RB −19.0, ST −36.9, WCT −21.7 % |
| a grade from 0 to 1 gives the use to expect on each segment | VERIFIED as a definition, but W1 applies (distance capped for segments not walked) | |
| the article walks one species from the question to the map | VERIFIED | |

## `research/chinook_rearing_tuned.md`, new sentences
| Claim | Verdict | How |
|---|---|---|
| Status: plain-language account is the package article | VERIFIED | |
| Unlike #54's curve, the province-wide one bends in distance | VERIFIED in part | #54's distance curve "falls steadily ... and more steeply beyond about 1–2 km" (also a change of slope); the new one rises to a peak. The two curves are different models (#54's on visits failing the 0.75 floor; this one a tensor smooth at MAD 0.75, gradient 4.5 %). "rises to a peak near 120 m" is the contrast |
| highest about 120 m from a ≥ 3 m³/s river | VERIFIED | 124.6 m |
| falls past a few hundred metres, to 0.42 of the 1 km value at 3 km | VERIFIED | 0.424 |
| D = 1 km sits past the bend | VERIFIED | |
| last section: built from `inst/vignette-data/` by `data-raw/vignette_chinook.R`; contents; Bulkley map; link#346 | VERIFIED | |
| (head paragraph, not new) "−20 %, more than the km's −12 %" | WRONG | W4 |
