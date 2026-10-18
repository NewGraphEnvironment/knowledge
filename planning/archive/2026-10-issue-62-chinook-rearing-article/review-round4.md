# Code-check round 4, #62 (branch 62-chinook-rearing-as-a-vignette-how-the-th, HEAD c34813a)

Scope: every sentence, caption and code line that round 3's fixes (`round3_fixes.diff`) add or change.

## Findings

**G1 (low). "Single-line streams and canals" names two different sets, and in two places it is wider than the code.**

fresh's edge table (`fresh/inst/extdata/edge_types.csv`) gives 1000 main flow, 1050 main flow through wetland,
1100 secondary flow, 1150 secondary flow through wetland, 2000 canal, 2300 canal secondary flow, 2100 double-line
canal or reservoir bank.

- **Stream bullet (vignette L85).** "a single-line stream or canal". fresh's compiled CH rear predicate on link's
  `configs/default` has `s.edge_type IN (1000, 1100, 2000, 2300)` on the stream branch. So the lines drawn through
  a wetland (1050/1150) are not in the stream test; they count only inside a wetland of 1 ha or more. The bullet
  says a 1050 line in a 0.5 ha wetland passes the stream test, and it does not.
- **Outside check (L567-568).** "accessible single-line streams and canals". The code is `on_stream <-
  seg$edge_type[i] %in% edge_stream & seg$accessible[i]`, with `edge_stream` from `.knw_fresh_branches()` =
  1000/1100/2000/2300, and the km denominator `ks()` uses the same set. The FDIS bullet directly above uses
  "accessible single-line streams, canals and the lines through double-line rivers" for
  1000/1050/1100/1150/2000/2100/2300/1250/1350 (`compare_rules.R` L314). A reader takes the second set to be the
  first one less the river lines. It also drops the wetland lines (1050/1150) and the double-line canal (2100).
- **Scoring sentence (L129), the same words written right.** "a single-line stream or canal, not one drawn through
  a wetland" holds. Reproduced from `data/fdis/derived/visits_link.csv`: 7,123 visits, edge types 1000 = 6,978,
  1100 = 33, 2000 = 110, 2300 = 2.

Fix: write the stream bullet and the outside check as the scoring sentence does ("single-line streams or canals
not drawn through a wetland"). Or name the edge set once and refer to it.

**G2 (low). The outside check leaves out the bcfishobs match filter, so "the 826 places they were recorded" is
wider than the code.**

`compare_rules.R` L337 keeps only `substr(match_type, 1, 1) %in% c("A", "B")`: matched to a stream within 100 m.
It drops C, a stream match at 100-500 m, which can also fall on an accessible stream edge, and D/E, the waterbody
matches. So 826 counts locations of records *matched to a stream within 100 m*, not every place the records were
made on those streams. Round 3's suggested wording carried "A/B matches"; the fix dropped it.

The same omission is in `research/habitat_thresholds_tuned.md` Checks item 4 ("On the bcfishobs records FDIS does
not hold ... the share of their locations on accessible stream edges"). The rest of that sentence now holds.

Fix: "Of the 826 places they were matched to within 100 m on ...".

## Verdicts

### vignettes/chinook_rearing.Rmd

1. L76 "Every result of this tuning is computed from the tables it wrote": holds. Narrowed to the tuning. The
   surface and curves come from 0320's `CH_rear_curve.rds` and `CH_rear_curves.csv`, and the ground and check
   results are no longer claimed.
2. L85 stream bullet "a single-line stream or canal": **WRONG** (G1). The gradient and width hold
   (`s.gradient BETWEEN 0 AND 0.0549 AND s.channel_width BETWEEN 1.5 AND 9999`).
3. L89 "inside a lake or reservoir of at least 100 ha": holds. The predicate is `fwa_lakes_poly WHERE area_ha >= 100
   UNION ALL fwa_manmade_waterbodies_poly WHERE area_ha >= 100`.
4. L129-130 "on a single-line stream or canal, not one drawn through a wetland, and outside river polygons, wetlands
   of 1 ha or more and lakes or reservoirs of 100 ha or more": holds. The code is `knw_tune_run()` L59-61 with
   `edge_stream = c(1000L, 1100L, 2000L, 2300L)` (= `meta$spec$edge_stream`), and `wb_lake` from `knw_link_width()`
   L51-53 (lakes UNION manmade ≥ 100 ha). Reproduced to 7,123.
5. L130-131 fished area 10-10,000 m², group where link marks chinook present: holds (reflowed, unchanged).
6. L131-132 no hiding record code, no natural barrier downstream: holds (reflowed, unchanged).
7. L133 "After checks on each visit's placement, date and effort, that leaves 7,123 visits in 104 groups, 216":
   holds. The ledger `20261017_evidence_build_ledger.csv` lists these drops:
   - placement: not_placed 1,563, far_snap 5,242, ws50_mismatch 1,088, no_link_segment 1,491;
   - date: junk_date 23;
   - effort: effort_sentinel_or_none 1,353.

   catch_unknown is covered by "with what was caught". The counts are from `summ`.
8. L152 "in watersheds held out of the fit": holds. These are the held-out groups of `.tune_fold_setup`, and S44
   states the intercept refit.
9. L162 "in a held-out watershed scores low": holds.
10. L313 "on the fewer groups link had run by then": holds. #54 tuned on the 55-group build, fewer than the 125
    here.
11. L318-319 "fitted on the same visits, less the few with no modelled flow": holds.
    - `knw_tune_curve()` drops `!is.finite(log_size)`; `CH_rear_curve.rds` `$curve$dropped` is no_size 4, and the
      fit has 4,487 visits and 214 detections.
    - Note: the 4 have `mad_pick = 0`, a modelled flow of zero, not a missing one. All are on 1100 secondary
      channels (NAKR, TSAY, LNAR, COTR). The ledger has flow_missing 0. "No modelled flow" is loose but not
      misleading.
12. L324-325 chunk comment ("exp(fit - fit at the threshold) on the cloglog scale, a ratio of hazards; turned into a
    ratio of chances, rate / rate at the threshold, band converted the same way"): holds. `tune_curve.R` L241-244
    has `rel_rate = exp(fit - at)` with `at = approx(xs, fit, thr)`; under cloglog, exp(eta) = -log(1 - p).
13. `prob_ratio()` code: holds. The derivation and the checks were run on `inst/vignette-data/chinook_rearing.rds`.
    - `-log(1 - rate) / rel_rate` = exp(eta) / exp(eta - at) = exp(at), a constant. Per curve it varies by under
      2.2e-5 relative, which is the CSV's rounding, so the median is safe.
    - `p0 = 1 - exp(-h)` is the chance at the threshold. It matches rate interpolated at the threshold to within
      1e-5 on all three curves: size 0.016431 / 0.016431, gradient 0.010698 / 0.010698, distance 0.054814 /
      0.054824.
    - The band `1 - exp(-rel_lo * h)` = 1 - exp(-exp(eta_lo)) = p_lo. It equals an independent recomputation to
      2e-15. The transform is monotone, so lo ≤ rel ≤ hi holds on every row.
    - `rel_rate = rate / p0` is right.
14. L360-363 reference values "drawn 50 km from a river of at least 3 m³/s": holds. In `knw_tune_curve()` `base()`,
    `log_dist = log(dist_cap_m + 10)` on the walk to the first river of `q` = `pick$exc_q` = 3, and
    `meta$curve_ref$q` = 3.
15. L365 curves caption: holds (as item 14). The band is the pointwise 95 % band, converted.
16. L367 `one_curve()` on `prob_ratio()`: holds. The y-axis label "Chance relative to the threshold's" is now
    true.
17. L390-397 `at()` and `dc` on `prob_ratio()`: holds. The rendered numbers are reproduced:
    - 0.1 m³/s is 26 %, and 5 m³/s is 2.5×;
    - the peak is 124.6 m, so "120 m";
    - 300 m is 1.62×, so "1.6", which agrees with the surface table's 8.90 / 5.48;
    - 3 km is 43 % and 10 km is 21 %;
    - the low is 21,264 m.

    The unchanged sentence "falls in a straight line on this scale as gradient rises" still holds on the new
    scale: the log ratio of chances against gradient has a maximum residual from a line of 0.0018, over a range
    of 1.9.
18. L427-428 "as if far from a river of 3 m³/s or more": holds. `knw_grade()` L47 caps at `dist_cap_m`, and
    `knw_grade_species()` walks with `q_grid = pick$exc_q`.
19. L515-516 "each 30 m floodplain cell belongs to the nearest segment on the stream lines whose valley takes in the
    cell": holds. This is `knw_floodplain_ha()`, `fl_valley_join(valleys, bl, sg, group = "blue_line_key")`, with
    `nearest$seg`.
20. L567-571 outside check, part by part:
    - "never scored a rule": holds.
    - "826 places": holds as the count (`n = length(ls)`, locations by blue line and rounded measure).
    - "recorded on accessible single-line streams and canals": **WRONG** (G1, the edge set; G2, the A/B match
      filter).
    - "spawning-only places and hand-entered reaches left out": holds (`!(spawn & !rear)`, `in_uhc`).
    - "share on the recommended rule's streams ... times the rule's share of those streams' km": holds
      (`mean(flag[ls]) / ks()`, with the same edge set in the numerator and the denominator).
    - 3.3 and 2.5: hold.
21. L590 "graded as if far from a large river": holds (≥ 3 m³/s, as item 18).
22. L592 "Every figure of this tuning is on link run 20261017_004619-3f4c713b": holds (`meta$link_run_uid`).

### research/chinook_rearing_tuned.md

23. L40 "to 0.43 of the 1 km value at 3 km, as a ratio of predicted chances; `data/tune/CH_rear_curves.csv`":
    holds. 0.4313 comes from the file's `rate` column; its `rel_rate` column is the hazard ratio, 0.42. "Highest
    about 120 m" is unchanged by the monotone transform.

### research/habitat_thresholds_tuned.md

24. L23 "in watersheds held out of the fit": holds.
25. L29 "it reads a segment that passes the size test as far from the river the curve measures to": holds. The
    curve's river is `exc_q`, or `q_default` = 10 when there is no exception. The grade caps at `dist_cap_m` in
    both cases.
26. L153-154 "the share of their locations on accessible stream edges that falls on the rule's segments, over the
    rule's share of accessible stream-edge km": holds by the code (`ls`, `ks()`, the species' stream-rule edges).
    The sentence leaves out the A/B filter (G2).

### Out of scope (not in the diff, same class as F5)

The `R/grade.R` roxygen at L15 still says "(`dist_cap_m`): far from any river".

**Count.** 26 verdicts. 2 are WRONG (items 2 and 20). Item 26 is partly affected (G2). The `prob_ratio()`
conversion and every rendered number that depends on it hold.
