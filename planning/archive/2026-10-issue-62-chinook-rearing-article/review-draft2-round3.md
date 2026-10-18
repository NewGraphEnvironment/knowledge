## Findings

Draft 2, round 3, closing by enumeration. Five defects in the article, two of them medium. All five are the same mechanism the earlier rounds found: a sentence names a quantity by its role in the story, not by what the code computes. The code diff (draft 1 to now) is clean against the checklist. `test-compare_map.R` passes 4 of 4 blocks under `NOT_CRAN=true` with `load_all`.

### F1 (article, medium). The surface table's 5 m³/s row, and "5.3 % at 5 m³/s", describe places that cannot exist in the data
The distance walk (`inst/sql/ch_dist_profile.sql:41-54`) takes the first segment at or below the visit's measure whose flow is at least q. It measures that distance as `greatest(cur_m - urm, 0)`. The visit's own segment qualifies, so a visit on a stream carrying 3 m³/s or more is 0 m from "a river of at least 3 m³/s", because it is one.

The fitted data (`data/tune/CH_rear_curve.rds`, `$curve$data`, 4,487 visits) shows this:

| Flow | at 0 m | 1 m to 20 km | at the cap |
|---|---|---|---|
| above 4 m³/s (101 visits) | 98 | 0 | 3 |
| 3 to 4 m³/s (110 visits) | 109 | 1 (at 150-600 m) | 0 |

So the table's "5" row in the 100 m, 300 m, 1 km, 3 km and 10 km columns, and the sentence "Ten kilometres away it rises with flow, from 0.2 % at 0.1 m³/s to **5.3 % at 5 m³/s**", read the tensor smooth where no visit lies. The "9.3 %" lower end of "within 100 m ... 9.3 % to 10.3 %" also comes from that row.

Fix:
- End the rows at 2 m³/s, or say that a stream of 3 m³/s or more is the river itself (distance 0).
- Restate the 10 km rise as 0.2 % at 0.1 to 2.6 % at 2 m³/s.
- Restate the 100 m range as 9.4 % to 10.3 %.

### F2 (article, medium). "Orange is whole tributaries that fall below the flow floor": most orange lines keep their lower reach
In BULK, 252 of the 396 blue lines with lost segments still carry rearing under the recommended rule. Those lines hold 580 of the 744 lost km (78 %). Computed from `inst/vignette-data/bulk_segments.rds`, `flag_default & !flag_tuned` against `flag_tuned` by `blue_line_key`.

Flow grows downstream, so a tributary keeps its lower reach where its MAD reaches 0.75 m³/s, or where it lies within 1 km of a 3 m³/s river. It loses only its upper reach. On the lost lines, `data/compare/CH_rear_segments.rds` gives 1,095 km still kept, 99.5 km of it through the exception. The zoom panel shows the pattern: orange tributaries meet the main river through a blue lower reach.

Fix: "Orange is the upper reaches of tributaries, where the flow falls below the floor more than 1 km from a river."

### F3 (article, low). The score is not a prediction made without seeing the held-out group
"A rule is worth having if it predicts where chinook are caught in a watershed it was not built from ... The model also allows for ... each group's own overall catch rate."

In `.tune_score_one` (`R/tune_score.R:217-224`, roxygen lines 9-11), the held-out visits take only the rule, area, data-set and era coefficients from the other folds. Each held-out group then refits its own intercept on its own held-out visits before its deviance is scored. So the group's overall catch rate is taken from the very visits being scored. Only how much the rule matters is carried over. The article's wording lets a reader assume the held-out group's rate was predicted too.

Fix: "each held-out group's overall catch rate is set from its own visits; how much the rule matters, and the allowances for area, data set and era, come from the other four folds."

### F4 (article, low). "The rule was chosen on these records" overstates the overlap
The check covers 10,515 visits:
- in all 125 groups;
- on edges 1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250 and 1350 (`compare_rules.R:314`);
- with no stream-branch or both-outcomes filter.

The choice used 4,490 visits: stream-branch edges only, in the 43 groups with both outcomes (`tune_run.R:60-62`, `.tune_modelled`). At most 43 % of the check's visits informed the choice. The sentence says all of them did, which understates how independent the check is.

Fix: "the rule was chosen on part of these records (the 4,490 tuning visits are among them), so this is not an independent test."

### F5 (article, low). "Stream or canal" names two different edge sets in two adjacent sentences
- The FDIS check's "streams, canals and river lines" includes through-wetland lines (1050, 1150) and double-line canal banks (2100) (`compare_rules.R:314`).
- The outside check's "an accessible stream or canal" is the stream test's edge set only: 1000, 1100, 2000, 2300 (`on_stream` and `ks()`, `compare_rules.R:375-378`, `edge_stream` from `.knw_fresh_branches`). It leaves out the through-wetland lines that "stream" includes one sentence earlier.

The article itself defines the stream test as "a single-line stream or canal, not one drawn through a wetland".

Fix: "within 100 m of a stream and placed on an accessible line of the kind the stream test covers". The lift's "share of that stream length" then reads correctly against it.

### Checked, no defect
- **Code diff (`compare_map.R`, `data-raw/vignette_chinook.R`, man, tests).**
  - Argument checks, single-panel save, and `+ NULL` when `mark` is NULL.
  - The floodplain removal is complete.
  - The two `md5` vectors split on `names(src) != "thresholds"`.
  - `unlink()` of the old raster.
  - The `mark` test is bounded both ways (`0 < changed < 0.01`), and the `lwd` test compares ink.
  - The zoom panel's extent is the bbox of the accessible segments cropped to the box. In the render it fills the square window.
- **fresh's predicate** (installed fresh 0.39.0 on link's config at the run's sha `a17e917`). The stream disjunct is edges 1000/1100/2000/2300 with gradient 0-0.0549 and width 1.5-9999. River, wetland (1000/1100 and 1050/1150 in wetlands of at least 1 ha, no thresholds) and lake (listed edges in lakes or manmade waterbodies of at least 100 ha) all match the four bullets.
- **The wetland and lake rules' `requires_connected`.** It acts only on the `lake_rearing` and `wetland_rearing` columns (`.frs_bucket_connected`), not on `rearing`, so the bullets need not mention it.
- **The connectivity sentence.** It matches installed `.frs_cluster_both`: phase 2 is spawning upstream (plus the 10 m confluence case); phase 3 is mainstem downstream within 10 km with no segment of 5 % or steeper first; segments that are both rearing and spawning are protected.
- **The method file.** `parameters_habitat_method.csv` is all `cw`, so "a channel at least 1.5 m wide" is default's stream test in every group.
- **Not measured.** The river disjunct's `channel_width BETWEEN 0 AND 9999` fails on a NULL width ("any width"). Measuring that needs the database, so it is not flagged.

## Enumeration

Method: I numbered every line group of `article2.txt` (the rendered text) that states a fact, checking each against `vignettes/chinook_rearing.Rmd` so every inline expression was covered:
- every sentence;
- every list item;
- every table label and row;
- every caption;
- the citation block.

Headings phrased as questions were skipped. I also read both figures. Numbers were recomputed from `inst/vignette-data/chinook_rearing.rds`, and for F1, F2 and F4 from `data/tune/CH_rear_curve.rds`, `data/compare/CH_rear_segments.rds` and `bulk_segments.rds`.

| # | Article lines | Claim | Verdict | Defined by |
|---|---|---|---|---|
| 1 | 1-5 | link marks every segment as spawning or rearing per species, and reachable or not | holds | link `streams_habitat_<sp>`, `streams_access` |
| 2 | 5-7 | a configuration is rules and thresholds for size and steepness per species and stage; the standard one is `default` | holds | `configs/default/rules.yaml`, thresholds csv |
| 3 | 8-9 | thresholds start from bcfishpass's; New Graph contributes to bcfishpass | holds | link README ("fresh's copy"); CH 0.0549 / 1.5 |
| 4 | 10-15 | tests one rule against electrofishing catch or not; the tests are in `knowledge` | holds | `knw_tune_run` response `U = present` |
| 5 | 16-19 | recommended: gradient <= 9 %, MAD >= 0.75, or a 3 m³/s river within 1 km downstream | holds | `mad>=0.75\|g<=0.09\|Q3@D1000` |
| 6 | 19-20 | default: gradient <= 5.49 %, width >= 1.5 m | holds | predicate |
| 7 | 20-22 | 12.4 % fewer km; separates more sharply | holds | ALL `change_pct` -12.43; 15.9/1.4 against 7.1/2.3 |
| 8 | 24-25 | rearing = reachable and one of four tests | holds | access gate `compare_rules.R:158`; predicate |
| 9 | 26-28 | stream test: edges, not through wetland, gradient, width | holds | disjunct 1 (1000/1100/2000/2300) |
| 10 | 29-30 | river: river polygon, same gradient, any width | holds (NULL width not measured) | disjunct 2 |
| 11 | 31 | wetland >= 1 ha | holds | disjuncts 3-4 |
| 12 | 32-33 | lake or reservoir >= 100 ha | holds | disjunct 5 |
| 13 | 34-36 | hand-confirmed reaches added, then kept only where connected (upstream; or 10 km downstream, no 5 % stretch) | holds | `compare_rules.R:196-204`; `.frs_cluster_both` |
| 14 | 36-38 | width modelled only on order >= 2, so no unmeasured order-1 stream passes | holds | fwapg; NULL fails `BETWEEN` |
| 15 | 39-42 | only the stream test is tuned; rivers share the gradient maximum; no tuning visit is in a river polygon | holds | `compare_rules.R:99-131`; `tune_run.R:60` |
| 16 | 44-46 | watershed groups are atlas basins; the unit of counting and testing | holds | `wsg`; folds by group |
| 17 | 47-49 | FDIS electrofishing records placed on link's segments | holds | `visits_link` |
| 18 | 49-51 | stream-test edges, outside wetlands >= 1 ha and lakes >= 100 ha | holds | `tune_run.R:60`; `link_width.R:48-54` |
| 19 | 51 | fished area 10 to 10,000 m² | holds | `area_range` |
| 20 | 51-52 | group where link expects chinook | holds | `in_range` |
| 21 | 52-54 | no natural barrier downstream; no record code hiding a catch | holds | `barrier_dnstr_ch`; `status != blocked` |
| 22 | 54-55 | after placement/date/effort checks, 7,123 visits in 104 groups | holds | summary `visits_in`, `groups` |
| 23 | 55-58 | always/never groups dropped; 43 groups, 4,490 visits, 215 caught | holds | `.tune_modelled`; `n_visits`, `n_detect` |
| 24 | 60-61 | each rule sets the three things default sets | holds | grid |
| 25 | 62-64 | MAD floors 0.1 to 1; width floors 1 to 4 | holds | grid values |
| 26 | 65-66 | gradient maxima 3, 4, 5.49, 7, 9 % | holds | grid |
| 27 | 67-70 | exception: a stream below the floor counts with a Q river within D downstream; Q and D lists | holds | `knw_rule_in`; grid |
| 28 | 71-72 | every combination is a rule, 2,795, default among them | holds | `nrow`; `is_default` sum 1 |
| 29 | 72-73 | juveniles move into small streams near large rivers | not code | `research/chinook_stream_size.md` |
| 30 | 75-77 | groups split at random into 5 folds | holds (stratified random) | `.tune_fold_of_wsg` |
| 31 | 74-79 | learns from four folds, predicts the fifth, a watershed it was not built from | **imprecise (F3)** | `tune_score.R:217-224` |
| 32 | 79-81 | allows for area, data set, era, each group's rate | holds; see F3 | nuisance terms; intercept refit |
| 33 | 82-84 | score = summed deviance; lower is better | holds | `dv`, `s0$tot` |
| 34 | 84-85 | no-rule model 231.9 worse than best | holds | `ddev_null` -231.86 |
| 35 | 87-90 | region = within one SE of the best, SE across groups | holds | `.tune_sel` (all converged) |
| 36 | 91 | 23 rules | holds | `sum(in_region)` |
| 37 | 92 | flow floor 0.35-1, never width | holds | region rows |
| 38 | 93-94 | exception, river 1-10 m³/s within 1-2 km | holds | region `exc_q`, `exc_d` |
| 39 | 95 | gradient 7 or 9 % | holds | region `grad_max` |
| 40 | 96-97 | default 196.3 worse, SE 81.6, outside the region | holds | default row |
| 41 | 98-101 | profile caption | holds | profile chunk; figure checked |
| 42 | 103-106 | choice fixed before scoring: the region rule closest to default; all differ in 3, so the best scorer wins | holds | `.tune_pick`; departures all 3 |
| 43 | 106-107 | fewer visits called habitat, as many catches | holds | 1,047 vs 2,330; 166 vs 165 |
| 44 | 108-124 | raw table and caption | holds | `n_in`, `n_detect_in`, `raw_rate_*` |
| 45 | 126-127 | three checks fixed before the run | holds | `extra = TRUE` spec |
| 46 | 128-131 | seed; 4 other seeds; recommended in region on 4, default on 0 | holds | seeds table |
| 47 | 131-134 | 3 of 4 same rule at 7 %; seed 56 picks mad 0.5, g 5.49, Q3 within 2 km | holds | seeds 55/57/58; 56 |
| 48 | 135-138 | nested: beats default in 4 of 5 folds and in total | holds | fold 4 loses; 1234.5 < 1347.0 |
| 49 | 138-139 | partial: each fold's choice leans on fits that saw it | holds | `out_k` scores from fits that include fold k |
| 50 | 140-142 | 200 redraws; exact rule 22 % | holds | `boot_rec_share` |
| 51 | 142-145 | flow floor 100 %, 0.75 in 55 %, 3 m³/s in 76 %; gradient 40/34/25 % | holds | 1.00, 0.545, 0.755; 0.405/0.335/0.255 |
| 52 | 146-148 | shape settled; gradient least settled | holds | top shares by setting |
| 53 | 150-153 | one model after the choice, on visits with a modelled flow, flow x distance as one surface | holds | `knw_tune_curve` `te()`; 4,487 rows |
| 54 | 154-156 | surface caption, standard visit, 4.5 % gradient | holds | `knw_grade` at `ref`; `grad_ref` 0.045 |
| 55 | 157-198 | surface rows 0.1-2 m³/s; "50 km or more" | holds | `x$surface`; cap 50 km |
| 56 | 192-198 | surface row 5 m³/s at 100 m to 10 km | **outside the data (F1)** | `ch_dist_profile.sql:41-54`; curve data |
| 57 | 199-200 | within 100 m, 9.3-10.3 % whatever the flow | **9.3 is from F1's row** | surface |
| 58 | 200-201 | 10 km: 0.2 % at 0.1 to 5.3 % at 5 | **wrong upper end (F1)** | surface; curve data |
| 59 | 201-203 | the shape the rule draws | holds | surface 0.1-2 rows |
| 60 | 203-204 | falls off past a few hundred m; 1 km on the way down | holds | surface |
| 61 | 205 | at 9 % about 51 % of the chance at 2 % | holds | `grad_at` ratio 0.513 |
| 62 | 206-208 | smooth model, cannot show a step; each threshold is the best held-out cut | holds | `te` + `s(grad)`; recommended = best |
| 63 | 208-210 | 9 % is the edge of the grid | holds | `grad_max` max 0.09 |
| 64 | 212-214 | both rules through link's steps on 125 groups | holds | `knw_compare_rules`; 125 rows |
| 65 | 215-234 | km table: 101,184 / 88,607 / 24,843 / 24,542 / 12,266 / 9,666 / 6,952 and labels | holds | compare ALL; change reasons (`compare_rules.R:286-293`) |
| 66 | 235-236 | -73.6 % to 29.9 %; 48 of 125 gain | holds | per-group `change_pct`; none zero |
| 67 | 236-237 | Bulkley 1,611 vs 2,123 (-24.1 %) | holds | BULK row |
| 68 | 238-241 | map caption: classes, panels, 12 km window, width by order | holds | map chunk; `lwd` from order |
| 69 | 242-243 | orange = whole tributaries below the floor, no river close | **wrong (F2)** | `bulk_segments.rds` by `blue_line_key` |
| 70 | 243-244 | green = short exception reaches beside a river | holds | BULK gained 232.5 km, 199.0 km exception |
| 71 | 245-247 | 10,515 visits, 10-10,000 m², accessible streams, canals, river lines, 125 groups | holds | `compare_rules.R:314`; 5,717 + 4,798 |
| 72 | 247-249 | 17 % / 1.5 % against 14 % / 2.2 % | holds | 795/4,661; 85/5,854; 773/5,717; 107/4,798 |
| 73 | 249-250 | chosen on these records | **overstated (F4)** | `tune_run.R:60-62` vs `compare_rules.R:314` |
| 74 | 250-252 | 826 places within 100 m of an accessible stream or canal, spawning-only out, none scored | holds in count; **edge set (F5)** | match A/B; `loc`; `on_stream` |
| 75 | 252-254 | lift 3.3 against 2.5 | holds | `lift` 3.27, 2.46 |
| 76 | 256-257 | not applied until a config reads it (link#346) | holds | link#346 open |
| 77 | 258-261 | juveniles, electrofishing, streams; spawning outside; wetland and lake keep tests; rivers take the gradient, scored on streams only | holds | `fdis_size_breaks.csv`; `compare_rules.R:100` |
| 78 | 262-265 | separation, not extent; 1.4 % outside caught | holds | `raw_rate_out` 0.0142 |
| 79 | 266-267 | neighbours nearly as good; the region gives the range | holds | region |
| 80 | 268-271 | one link run; distances from visits vs segment ends, looser | holds | `meta$link_run_uid`; `compare_rules.R:21-22` |
| 81 | 272-274 | grade understates large streams near rivers, being redone | holds (accepted, knowledge#65) | knowledge#65 open |
| 82 | 276-279 | link: model and configs; fresh runs link's rules on the FWA | holds | n/a |
| 83 | 280-283 | knowledge: records, tests, article; no DOI; citation 0.4.3 | holds (accepted) | DESCRIPTION 0.4.3 |
