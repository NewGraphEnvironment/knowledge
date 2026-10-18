## Findings

Draft 2, round 1. Four defects: one test that cannot fail, two wrong claims in the article, one stale roxygen line. Every number the article prints matches its table. The default output of `knw_compare_map()` is pixel-identical to draft 1.

### F1 (test). The `mark` outline is untested, though the test's name says it checks it
`tests/testthat/test-compare_map.R:45` is called "draws only the panels asked for, with a window outlined". Nothing in it checks the outline. Mutation check: in a copy of `R/compare_map.R` I replaced `outline <- if (is.null(mark)) NULL else ...` with `outline <- NULL`, then ran the test file against that copy (`test_file(env = )`). All 4 blocks pass, with 0 failures and 0 errors. The same harness does catch a `legend` mutation (hard-wiring the rules legend on makes block 4 fail), so the harness is not the reason it passes. Fix: render the same panel with and without `mark`, then assert that the pixels differ and that dark pixels appear along the box's edge.

### F2 (article). The order of link's last two steps is reversed
"Rearing with no spawning within 10 km is then removed, and reaches confirmed by hand are added." In the code the hand-confirmed overlay runs first and the connectivity pass second: `R/compare_rules.R:196-204` calls `frs_habitat_overlay()` and then `.frs_run_connectivity()`. This matches CLAUDE.md's three stages: predicate, overlay, connectivity. The connectivity pass (`frs_cluster`, label_cluster = "rearing", fresh `R/frs_habitat.R:1211-1221`) works on the whole rearing column, including reaches the overlay added. So a hand-confirmed reach with no spawning nearby can still be removed. The sentence says hand additions come last and always stand. Fix: give the order the code runs: "reaches confirmed by hand are added, then rearing with no spawning within 10 km is removed."

### F3 (article). "Rivers, wetlands and lakes keep their own tests" contradicts the article's own exception
The bullet "Juveniles caught by electrofishing, on streams. Spawning is outside it, and rivers, wetlands and lakes keep their own tests" leaves out the exception the article states earlier ("except that river polygons share the stream test's gradient maximum"). The tuned rule raises the river branch's gradient maximum from 5.49 % to 9 %:
- `compare_rules.R:100` substitutes the gradient into `ps_t`.
- Off the stream branch, `tuned_sql` uses `p_tuned_base`, whose river disjunct is `waterbody_key IN rivers_poly AND gradient BETWEEN 0 AND 0.09` (printed from `frs_habitat_predicates()` on link's default with the gradient substituted).

The records never tested that gradient. No scored visit lies in a river polygon: the population excludes `wb_river` (`tune_run.R:60`), and of 30,136 stream-edge visits in `visits_link.csv`, 0 have `wb_river`. This bullet is where a reader looks for what the evidence does not cover, so it should say "rivers keep their tests except the gradient maximum, which the records did not test; wetlands and lakes keep theirs." (The wetland and lake disjuncts carry no gradient or width test, so they really are unchanged.)

### F4 (article, low). "Neither flow nor gradient shows a step at its threshold" holds by construction
The curve is `te(log_size, log_dist, k = c(6, 6)) + s(grad, k = 6)` (`tune_curve.R:76-82`). A penalised smooth with 6 basis functions cannot fit a step, and `s(grad)` came out with edf 1.00 (summary `curve_edf`), a straight line on the cloglog scale. "Shows no step" describes the smoother, not the records. Either drop the clause, or say the model is smooth by design so it cannot show a step, and keep "each threshold is where habitat and non-habitat separate best."

### F5 (roxygen, low). The `png` parameter still says "(three panels)"
`R/compare_map.R:21`, `@param png ... path for the static figure (three panels)`. The figure now holds whichever of `panels` are drawn (one in the article). Even before this change it held two panels when `fp_cells` was NULL. Fix: "(one panel per entry of `panels` drawn)".

### Code review: other results (no defect)
- Default behaviour is unchanged. I rendered BULK's saved segments and water through draft 1's `knw_compare_map()` (`git show 741facc:R/compare_map.R`) and through draft 2's, both with defaults. The PNGs are both 690 x 1200 and their maximum per-pixel difference is 0. `lwd.scale = tm_scale_continuous(values.scale = 1)` therefore equals tmap's default, and `+ NULL` (when `mark` is NULL) is harmless.
- Argument checks work: `chk_subset` rejects "rivers", `chk_gt(lwd, 0)` rejects 0, and `panels = "floodplain"` with no `fp_cells` stops with "needs fp_cells". A single panel skips `tmap_arrange`, and the test confirms its 4 x 4.6 in size.
- The zoom chunk:
  - The 4 grid offsets give origins `(kx + o) * w` that match `floor(x / w - o)`.
  - Both `tapply` calls are keyed by the same `k`, so `pmin` aligns.
  - The comment ("the 12 km square ... whichever of lost and gained is smaller") matches the code.
  - In the render the right panel fills a square window.
  - The window holds mostly exception gains and size losses. The local `CH_rear_segments.rds` gives, for BULK: gained 232.5 km, of which 199.0 km is exception; lost 744.1 km, of which 734.0 km is size. That supports the "Orange ... Green ..." sentence.
- The data script's floodplain removal is complete:
  - `chinook_rearing.rds` has no `floodplain` element.
  - `meta$md5` and `md5_rows` hold only `data/thresholds.csv` as a row-hash.
  - `md5_local` holds no gpkg.
  - `unlink(bulk_fp_grade.tif)` removes the old raster.
  - Nothing outside `planning/archive/` reads `bulk_fp_grade.tif` or `$floodplain`.
  - `test-vignette-data.R` passes 5/5 with `NOT_CRAN=true`.
  - `vapply(unname(src["thresholds"]), ...)` keeps the path as its name, which the test reads.
- Dependencies are declared: the vignette uses `png` (Suggests), `grid` (base), `ggplot2` (Suggests) and `dplyr` (Imports).

## Enumeration

Method: I walked `article2.txt` line by line against the Rmd source. Every sentence, list item, caption, table row and inline expression that states a fact got a number. Purely rhetorical lines (questions, headings) were skipped. For each inline `r` expression I recomputed the value from `chinook_rearing.rds`. For each descriptive claim I read the code that defines the set or step.

| # | Claim (article line) | Verdict | Defined by |
|---|---|---|---|
| 1 | link marks every segment as spawning/rearing per species and reachable or not (1-5) | holds | link README; `streams_habitat_<sp>`, `streams_access` |
| 2 | a configuration is rules and thresholds for size and steepness, per species and stage (5-7) | holds | `configs/default/rules.yaml`, `parameters_habitat_thresholds.csv` |
| 3 | standard configuration is `default` (7) | holds | link `configs/default` |
| 4 | thresholds start from bcfishpass's (8-9) | holds | README ("fresh's copy"); CH row 0.0549 / 1.5 |
| 5 | tested against electrofishing records, catch or not (10-12) | holds | `knw_tune_run`: response `U = present` |
| 6 | tests are part of `knowledge` (14-15) | holds | `R/tune_*.R` |
| 7 | recommended: gradient <= 9 %, MAD >= 0.75, or a 3 m³/s river within 1 km (17-19) | holds | `tune$recommended`: `mad>=0.75\|g<=0.09\|Q3@D1000` |
| 8 | default: gradient <= 5.49 %, width >= 1.5 m (19-20) | holds | thresholds CH 0.0549, 1.5 |
| 9 | 12.4 % fewer km across the province (21) | holds | compare ALL `change_pct` -12.43 over all 125 CH groups |
| 10 | separates catches more sharply (22) | holds | raw rates 15.9 / 1.4 against 7.1 / 2.3 |
| 11 | rearing = accessible and one of four tests (24-25) | holds | `rules.yaml` CH rear; access gate in `compare_rules.R:158` |
| 12 | stream: single-line stream or canal not through a wetland, gradient <= 5.49 %, width >= 1.5 (26-28) | holds | edges 1000, 1100, 2000, 2300; predicate SQL |
| 13 | river: in a river polygon, same gradient, any width (29-30) | holds | R rule `channel_width 0-9999`, gradient applies |
| 14 | wetland: in a wetland >= 1 ha (31) | holds | both W disjuncts are wetland >= 1 ha with no thresholds (printed predicate) |
| 15 | lake: in a lake or reservoir >= 100 ha (32-33) | holds | L disjunct: lakes plus manmade >= 100 ha |
| 16 | no spawning within 10 km removed, then hand-confirmed added (34-35) | **wrong order (F2)** | `compare_rules.R:196-204`; fresh `frs_habitat.R:1211` |
| 17 | width modelled only on order >= 2, so the stream test never admits an unmeasured order-1 stream (35-37) | holds | CLAUDE.md (fwapg widths); NULL width fails |
| 18 | only the stream test is tuned; river polygons share the gradient maximum (38-40) | holds | `compare_rules.R:99-131` |
| 19 | watershed groups are large atlas basins; the unit of counting and testing (42-44) | holds | `wsg` factor; folds by group |
| 20 | evidence is FDIS electrofishing records on link's segments (45-47) | holds | 0310 header; `visits_link` |
| 21 | visit on the stream-test kind of stream, outside wetlands >= 1 ha and lakes >= 100 ha (47-49) | holds | `tune_run.R:60`; `link_width.R:48-53` (the `wb_river` exclusion is immaterial: 0 stream-edge visits) |
| 22 | fished area 10 to 10,000 m² (49) | holds | `area_range` |
| 23 | in a group where link expects chinook (50) | holds | `in_range` (link's presence rule) |
| 24 | no natural barrier downstream (50-51) | holds | `barrier_dnstr_ch == FALSE` |
| 25 | no record code that could hide a catch (51-52) | holds | `status != "blocked"` |
| 26 | checks on placement, date and effort (52) | holds | ledger drops: not_placed, far_snap, ws50_mismatch, junk_date, effort_sentinel_or_none |
| 27 | 7,123 visits in 104 groups (52-53) | holds | summary `visits_in`, `groups` |
| 28 | always/never groups cannot tell rules apart, so 43 groups with both outcomes are used (53-55) | holds | `.tune_modelled`; `groups_both` 43 |
| 29 | 4,490 visits, 215 caught (55-56) | holds | `n_visits`, `n_detect` |
| 30 | each rule sets the same three things default sets (58-59) | holds | `knw_tune_grid` |
| 31 | MAD floors 0.1 ... 1; width floors 1 ... 4 (60-62) | holds | `grid_mad`, `grid_width` |
| 32 | gradient maxima 3, 4, 5.49, 7, 9 % (63-64) | holds | `grid_grad` |
| 33 | exception: below the size floor counts with a Q river within D downstream; Q and D lists (65-68) | holds | `knw_rule_in` (still inside the gradient maximum); `knw_link_walks` |
| 34 | every combination one rule, 2,795, default among them (69-70) | holds | 13 x 5 x 43 = 2,795; `is_default` sum 1 |
| 35 | exception's biological reason (70-71) | not code; consistent with `research/chinook_stream_size.md` | n/a |
| 36 | groups split at random into 5 folds (74-75) | holds (stratified random) | `.tune_fold_of_wsg` |
| 37 | model learns from four folds and predicts the fifth until every group is predicted once (75-77) | holds | `.tune_score_one` |
| 38 | allows for area, data set, era, each group's own rate (77-79) | holds | nuisance terms plus per-group intercept refit |
| 39 | score = summed deviance over predicted visits; lower is better (80-82) | holds | `dv`; `s0$tot` |
| 40 | no-rule model 231.9 worse than best (82-83) | holds | `ddev_null` -231.86 |
| 41 | region = within one SE of best, across groups (86-88) | holds | `.tune_sel` (plus `converged`, all 2,795 TRUE) |
| 42 | 23 rules (89) | holds | `sum(in_region)` 23 |
| 43 | flow floor 0.35-1, never width (90) | holds | region `size_var` all mad; range 0.35-1 |
| 44 | exception, river 1-10 m³/s within 1-2 km (91-92) | holds | region `exc_q` 1/3/5/10; `exc_d` 1000/2000; no NA |
| 45 | gradient 7 % or 9 % (93) | holds | region `grad_max` |
| 46 | default 196.3 worse, SE 81.6, outside the region (94-95) | holds | default row |
| 47 | profile caption: best score per value, deviance above best, filled = a region rule, ring = default's value (96-99) | holds | profile chunk `comp()`, `dflt_vals` |
| 48 | choice fixed before scoring: region rule closest to default (101-102) | holds | `.tune_pick` (fewest departures); `tune_score.R` roxygen "fixed ... before its first fit" |
| 49 | every region rule differs in all three settings, so the best scorer is recommended (102-104) | holds | region `departures` all 3; `exc_d` 1000 >= `d_floor` |
| 50 | fewer visits as habitat, as many catches (104-105) | holds | 1,047 against 2,330; 166 against 165 |
| 51 | table rows (106-122) | holds | `n_in`, `n_detect_in`, `raw_rate_in/out` |
| 52 | three checks fixed before the run (124-125) | holds | `knw_tune_score(extra = TRUE)` spec |
| 53 | folds split by a seed (126-127) | holds | `seed` |
| 54 | 4 other seeds; recommended in region on 4, default on 0 (127-129) | holds | seeds table |
| 55 | 3 of 4 same rule at another gradient; the other mad 0.5, g 5.49, Q3 within 2 km (129-132) | holds | seeds 55, 57, 58 g0.07; 56 `mad>=0.5\|g<=0.0549\|Q3@D2000` |
| 56 | nested: chosen beats default in 4 of 5 folds and over all five (134-136) | holds | honest: fold 4 loses; 1234.5 < 1347.0 |
| 57 | separation partial: choice leans on scores from models that saw the fold (136-137) | holds | out_k scores come from fits trained on fold k |
| 58 | 200 redraws; exact rule 22 % (138-140) | holds | `n_boot`; `boot_rec_share` 0.22 |
| 59 | flow floor 100 %, 0.75 in 55 %, 3 m³/s river in 76 % (140-141) | holds | 1.00, 0.545, 0.755 |
| 60 | gradient 9 % 40 %, 7 % 34 %, 5.49 % 25 % (141-143) | holds | 0.405, 0.335, 0.255 (rounding of .5 values) |
| 61 | gradient varies most / least settled (141-146) | holds | top shares: gradient 40.5 %, against MAD 54.5, D 62, Q 75.5 |
| 62 | one model after the choice, on visits with a modelled flow, flow x distance to a 3 m³/s river as one surface (148-150) | holds | `knw_tune_curve` `te()`; `q` 3 |
| 63 | surface caption: rates by flow and distance at 4.5 % gradient, one standard visit (152-154) | holds | `grad_ref` 0.045; `ref` area/FDIS/2005on |
| 64 | "50 km or more" column (161) | holds | `dist_cap_m` 50,000; capped in fit and grade |
| 65 | within 100 m: 9.3-10.3 % whatever the flow (197-198) | holds | surface |
| 66 | 10 km: 0.2 % at 0.1 to 5.3 % at 5 (198-199) | holds | surface |
| 67 | falls off past a few hundred m; 1 km on the way down (201-202) | holds | surface |
| 68 | 9 % chance about 51 % of 2 % (203-204) | holds | `grad_at` ratio 0.513 |
| 69 | no step at either threshold (204) | **by construction (F4)** | `tune_curve.R:76-82`; edf 1.00 |
| 70 | both rules through all of link's steps on the 125 groups link classifies for CH (208-210) | holds | 0330 `groups_sp()`; `knw_compare_rules` three stages |
| 71 | km table: 101,184 / 88,607 / 24,843 / 24,542 / 12,266 / 9,666 / 6,952 (211-229) | holds | compare ALL; change reasons size / exception / order 1 |
| 72 | km label "wide enough for default but below the flow floor, with no river close" (220-221) | holds | reason `w_ok & g_def & !size_tun & !ex_ok` |
| 73 | km label "small streams near a river (the exception)" (225-226) | holds | reason `!size_tun & ex_ok` |
| 74 | -73.6 % to 29.9 %; 48 of 125 gain (230-231) | holds | per-group `change_pct`; no zero-default group |
| 75 | Bulkley 1,611 against 2,123 (-24.1 %) (231-232) | holds | BULK row |
| 76 | map caption: classes, left/right panels, 12 km window, width follows order (233-236) | holds | map chunk; `seg$lwd` from `stream_order` |
| 77 | orange = whole tributaries below the floor with no river close; green = short exception reaches (237-239) | holds | BULK lost 734 of 744 km size; gained 199 of 232.5 km exception |
| 78 | 10,515 visits, 10-10,000 m², accessible streams, canals and river lines in 125 groups (240-242) | holds | `compare_rules.R:314` edges 1000/1050/1100/1150/2000/2100/2300/1250/1350; 5717+4798 |
| 79 | 17 % / 1.5 % against 14 % / 2.2 % (242-244) | holds | 795/4661, 85/5854, 773/5717, 107/4798 |
| 80 | rule chosen on these records, so not independent (244-245) | holds | the tuning visits are a subset |
| 81 | 826 places from other sources within 100 m of an accessible stream or canal, spawning-only excluded; none scored (245-247) | holds | `match_type` A/B; `loc` filter; `on_stream`; 4 overlay places of 2,409 also left out (log), immaterial |
| 82 | lift 3.3 against 2.5 (247-249) | holds | checks `lift` 3.27, 2.46 |
| 83 | not applied; link changes nothing until a config reads it (link#346) (251-252) | holds | link#346 open, "Threshold calibration read from published evidence ..." |
| 84 | juveniles caught by electrofishing, on streams (253) | holds | `fdis_size_breaks.csv`: "no adult CH in the export"; stream-branch population |
| 85 | spawning outside; rivers, wetlands and lakes keep their own tests (253-255) | **wrong (F3)** | river gradient raised to 9 %, `compare_rules.R:100,130` |
| 86 | score rewards separation; 1.4 % outside still caught (256-259) | holds | `raw_rate_out` 0.0142 |
| 87 | values next to the recommended are nearly as good; the region gives the range (260-261) | holds | region table |
| 88 | one link run 20261017_004619-3f4c713b (262-263) | holds | `meta$link_run_uid`; ledger |
| 89 | distances scored from each visit; on segments from the downstream end, a little looser (263-265) | holds | 0310 walks from the visit point; `compare_rules.R:21-22` |
| 90 | grade understates large streams near rivers, being redone (266-268) | holds (accepted: knowledge#65) | knowledge#65: segments passing the size test are graded at the 50 km cap |
| 91 | link: habitat model and configurations (270-271) | holds | n/a |
| 92 | fresh runs link's rules on the BC Freshwater Atlas (272-273) | holds | `frs_habitat_predicates`, `.frs_run_connectivity` |
| 93 | knowledge: fish records, tests, article; no DOI (274-275) | holds (accepted) | n/a |
| 94 | citation, version 0.4.3 (276-277) | holds | DESCRIPTION Version 0.4.3; `utils::citation()` |
