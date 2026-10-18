# Code-check round 3, #62 (branch 62-chinook-rearing-as-a-vignette-how-the-th, HEAD 4f1048b)

## Mechanism

Every earlier finding has one cause. A sentence describes a computed quantity from what it is for in the
method's story, or from the set a nearby sentence already introduced, and not from the line of code that
computes it. Each time, a familiar or nearby set, scale or reference value stood in for the code's own:

- the scoring population for the check's population;
- all-group km for catalog-group km;
- "its own distance" for a distance walked only for candidate segments;
- "visits it did not see" for held-out groups that refit their own intercept;
- "link measures" for "the comparison measures".

Round 2's fix of the FDIS-check sentence was right about that sentence. Three other places still carry the
same kind of substitution:

- the sibling check (bcfishobs);
- the curves (a cloglog hazard ratio called a ratio of chances);
- the other sentences that restate a corrected claim ("watersheds the model has not seen").

The mechanism reaches every noun phrase that names a population, a denominator, a reference value or a
scale. The fix that ends it: write each such phrase from the code's predicate (its filter list, its
denominator, its link scale), and compute each in-text number from the same object as the table or figure
beside it.

## Findings

Severity is about what a reader would get wrong. None of these breaks a build.

**F1 (moderate). The bcfishobs check (article S151b, `vignettes/chinook_rearing.Rmd` L549-551) names the wrong
population and the wrong denominator.**

The code is `R/compare_rules.R` L329-394. The "records" are 826 locations: A/B-matched, non-FDIS CH
observations, grouped by blue line and rounded measure. Locations that are spawning-only are dropped, and so
are those inside a user-habitat reach. Only locations on accessible stream-edge segments are counted (FWA
1000/1100/2000/2300). The lift divides by the rule's share of accessible **stream-edge** km (`ks()`):
- `default`: 0.329;
- tuned: 0.243.

The article says "its share of accessible km". Its own km table gives 101,184 / 225,152 = 0.449 and
88,607 / 225,152 = 0.394, which would make the lifts 0.809 / 0.449 = 1.80 and 0.795 / 0.394 = 2.02, not 2.5
and 3.3. Suggested wording: "Chinook locations from other sources (bcfishobs, A/B matches, not spawning-only),
on accessible stream edges, fall 3.3 times as often on the recommended rule's stream edges as its share of
accessible stream-edge km would give, against 2.5 for `default`."

The same phrase was already in `research/habitat_thresholds_tuned.md`, Checks item 4 ("over the rule's share
of accessible km"). Those lines are not this branch's, but they carry the same defect.

**F2 (low to moderate). The curves are ratios of cloglog hazards, and the article calls them ratios of the
chance of a catch.**

`R/tune_curve.R` L241-243 sets `rel_rate = exp(fit - at)` on the link scale. Under cloglog, exp(eta) is
-log(1-p), so rel_rate is log(1-p) / log(1-p_thr), not p / p_thr. Two printed digits change, and one
contradicts the surface table on the same page:

| sentence | printed | ratio of chances |
|---|---|---|
| S106: 300 m against 1 km | "1.7 times" | 0.0890 / 0.0548 = 1.62, so "1.6" |
| S102: 5 m³/s against 0.75 at the cap | "2.6 times" | 0.0415 / 0.0164 = 2.52, so "2.5" |
| S107: 3 km against 1 km | "42 %" | 43 % |
| S107: 10 km against 1 km | "21 %" | 21 % |
| S102: 0.1 m³/s against 0.75 at the cap | "26 %" | 26 % |

The table's own 8.9 % and 5.5 % make S106's ratio 1.6. Also affected:
- S100 and the S101 caption ("relative to the chance");
- the y-axis label "Chance relative to the threshold's";
- `research/chinook_rearing_tuned.md` added line 40 ("0.42 of the 1 km value").

Fix: in the vignette, use the curves table's `rate` column, with
`at <- function(c, v) approx(log x, rate, v) / approx(log x, rate, thr)`. The band is
`p = 1 - exp(-rel * -log(1 - p_thr))`. Or relabel the quantity as a relative hazard.

**F3 (low). S93 (L317): "one smooth model of detection was fitted on the same visits".**

The curve was fitted on 4,487 visits with 214 detections. The scoring used 4,490 and 215.
`knw_tune_curve()` drops visits with no finite log MAD (`cr$dropped` no_size = 4 of the 7,123), then reruns
`.tune_modelled()`. This breaks S34's "Every count below is on these visits unless it says otherwise."
Suggested wording: "on the same visits, less the 3 with no modelled flow".

**F4 (low). S39 (L151), S47 (L162) and `research/habitat_thresholds_tuned.md` added line 23 ("in watersheds
the scoring had not seen") all claim the predictions are for watersheds the model has not seen.**

S44, which the audit added, says the opposite and is right: a held-out group's intercept is fitted on its
own visits (`R/tune_score.R` L356-361). Only the rule, area, data-set and era terms are unseen. The audit
fixed step 3 and left these restatements.

**F5 (low). "Any river" where the code means a downstream river of at least 3 m³/s.**

Sentences: S99 (L344), the S101 caption, S118 (L411), S159 ("as if far from any river"), and the research
added line 29.

The distance is the walk to the first downstream segment of at least `q` = 3 m³/s:
- `knw_tune_curve()` `log_dist`;
- `knw_grade()` `dist_cap_m`;
- `knw_grade_species()` `q_grid = pick$exc_q`.

A stream "50 km from a 3 m³/s river" can sit beside a 1 m³/s one. Say "50 km from a ≥ 3 m³/s river". The
surface caption (S95) already says it correctly.

**F6 (low). S143 (L498): "each 30 m floodplain cell belongs to its nearest segment".**

The owner is the nearest segment *among the segments of the blue lines whose valley claims the cell*
(`R/floodplain_ha.R` L7-11; `fl_valley_join(group = "blue_line_key")`). A tributary segment nearer to a cell
in the mainstem's valley does not own it. `research/habitat_thresholds_tuned.md` states this correctly
("the nearest among the claiming blue lines' segments").

**F7 (low). The earlier-tuning sentence and the article's two "every" claims.**

S91 (L312) says the earlier tuning ran "on the 55 groups link had run by then". #54's tuning population was
4,516 visits in 45 WSGs, 26 of them modelled, drawn from the 55-group build (`research/chinook_rearing_tuned.md`,
"Tuning population"). Suggested wording: "on the visits in the 55 groups link had run by then".

S91 is typed text, so two quantifiers are false:
- S3 (L75), "Every result is computed from the tables the tuning wrote". The ground, floodplain and check
  results also come from 0330's tables, not the tuning's.
- S159c (L572), "Every figure is on link run 20261017_004619-3f4c713b".

Narrow both to "every result from this run".

**F8 (low). "Lakes of 100 ha" also counts man-made waterbodies of 100 ha or more.**

Sentences: S8's lake bullet (L89), S28 (L130) and S154b (L558).

fresh's compiled rear predicate has `fwa_lakes_poly WHERE area_ha >= 100 UNION ALL
fwa_manmade_waterbodies_poly WHERE area_ha >= 100`, printed from `frs_habitat_predicates()` on the run's
config. `R/link_width.R` L51-53 sets `wb_lake` the same way, and `R/compare_rules.R` L110-112 does too. This
is the example the convention cites (link#302: "its `L` includes reservoirs"). Say "lakes or reservoirs of
100 ha or more".

**F9 (low). The scoring-population sentences S27-S31 (L127-133) name fewer filters than produced the 7,123.**

The sentences are followed by "That leaves 7,123". Some upstream drops are covered by the article's words:
- "placed" covers `knw_fdis_quality()`'s not_placed (1,563) and far_snap (5,242), and 0310's
  no_link_segment (1,491);
- "with what was caught" covers catch_unknown (275).

Three drops have no wording: ws50_mismatch (1,088), junk_date (23) and effort_sentinel_or_none (1,353,
partly also removed by the area filter). The counts are from the ledger
`scripts/logs/habitat/20261017_evidence_build_ledger.csv`.

"A stream edge" is also undefined. It is FWA 1000/1100/2000/2300: main-flow single-line streams and
single-line canals. Secondary channels (1050/1150) are out of the scoring, but S150's check counts them as
"single-line streams". This is the same omission round 2 found in the check sentence, now on the scoring
sentence.

### Code (round 2's fixes and the branch)

Clean.
- The `surface` table (`data-raw/vignette_chinook.R` L148-162) predicts with `knw_grade()` on the curve at the
  curve's own reference values (gradient `min(grad_max, 0.2) / 2` = 0.045, cap 50 km, nuisance from
  `cr$ref`, group excluded). It reproduces the curves table at the thresholds:
  - 0.75 m³/s at 1 km: 0.054825 in the surface, 0.054823 in the curves;
  - 0.75 m³/s at the cap: 0.016431 and 0.016431.
- The column alignment in the article's `surface-tab` chunk is by the sorted `size`. That is correct.
- `r_at()`'s exact-equality lookups match the grid's literals.
- `.knw_rows_md5()` errors whenever lines ≠ rows. That direction is safe.
- `knw_compare_map(ncol =)` sizes the figure as `4 * nc` by `4.6 * nr`, and the test pins it.
- Not a defect: `md5_local` is recorded but no test reads it. The sources it covers are ignored files, and a
  rerun of 0320 or 0330 also changes a tracked file that the md5 test does check (`CH_rear_curves.csv`,
  `CH_rear_compare.csv`). So the guard still fires.

## Enumeration

**How completeness was ensured.**
- For the article, `vignettes/chinook_rearing.Rmd` was split mechanically: the prose lines outside chunks from
  L72 to the end were split into sentences and bullets, and every chunk's `fig.cap` and `caption =` were
  added. That gives 161 units, S1-S161, in source order. The rendered text in
  `docs/articles/chinook_rearing.html` was read beside them.
- Every unit is listed below with a verdict, or as "names no set".
- For the research files, every sentence that `git diff main...HEAD -- research/` adds is listed: R* for
  `habitat_thresholds_tuned.md`, C* for `chinook_rearing_tuned.md`.
- The README lines this branch adds name no population.

Verdicts: **holds**, or **WRONG** with its finding number.

### vignettes/chinook_rearing.Rmd

1. S1 L72 "yes or no on every stream segment, from a size floor and a gradient maximum": holds as a summary.
   fresh's stream and river rules carry size and gradient; S8 details the others.
2. S2 L74 "2,795 versions": holds (`nrow(tune)`).
3. S3 L75 "Every result is computed from the tables the tuning wrote": **WRONG** (F7).
4. S4/S5 L78 the recommended rule: holds (`words(rec)`, the row with `recommended`; it equals the thresholds
   table's `CH_rear` rule, a check in data-raw L81).
5. S7 L82 "accessible and one of four tests": holds. fresh's compiled predicate has five rules, with the two
   wetland rules merged; access is the combined gate in `compare_rules.R` L158.
6. S8 stream bullet: holds (edges 1000/1100/2000/2300, gradient 0-0.0549, width 1.5-9999).
7. S8 river bullet: holds (`waterbody_key IN fwa_rivers_poly`, the same gradient, width 0-9999, so any
   recorded width).
8. S8 wetland bullet: holds (edges 1000/1100 and 1050/1150, in wetlands of 1 ha or more).
9. S8 lake bullet: **WRONG** (F8).
10. S9-S12 L91-92, the three passes (overlay; rearing with no spawning within 10 km removed; lake and wetland
    rearing connected to spawning): holds. The code is `frs_habitat_overlay` and `.frs_run_connectivity`:
    `frs_cluster` with bridge 10,000 m and bridge gradient 0.05; `.frs_bucket_connected` with 10 km.
11. S13 L94 "width modelled only on order ≥ 2 ... never admits an unmeasured first-order stream": holds
    (fwapg; CLAUDE.md #54).
12. S14 "the rule this article recommends can": holds (6,952 km of order-1 gains, change table).
13. S15 "tuning asks about the stream test only": holds (`knw_rule_in` and the population's edge and
    waterbody filters).
14. S16 "River polygons keep their size test, and wetlands and lakes keep theirs": holds (`tuned_sql`: off
    the stream branch it uses `p_tuned_base`, where only the gradient is substituted under a MAD rule).
15. S17 "River polygons share the stream test's gradient maximum": holds (fresh's R rule takes
    `ranges$rear$gradient`; `ps_t` substitutes it).
16. S19 "changes three parts of the stream test": holds (`knw_tune_grid`).
17. S20 size, gradient and exception ladders: holds (computed from `tune`). The exception's definition: a
    segment failing the size test counts when a river of at least Q lies within D, provided it is within the
    gradient (`knw_rule_in` L89).
18. S22 "13 × 5 × 43 = 2,795": holds.
19. S23 `default` is one of them: holds.
20. S27 L127 "FDIS export: site visits with what was caught, placed on link's stream segments": holds,
    with a gap (F9).
21. S28 L128 "on a stream edge outside river polygons, wetlands ≥ 1 ha and lakes ≥ 100 ha": **WRONG** (F8,
    lakes include reservoirs; F9, "stream edge" undefined). Code: `tune_run.R` L60-62 and `link_width.R`
    L48-53.
22. S29 L130 fished area 10-10,000 m²; "a group where link marks chinook present": holds (`area_range`;
    `in_range` from `lnk_species_pooling`, 0310 L131).
23. S30 "no record code that could hide chinook, no natural barrier downstream": holds (`status !=
    "blocked"`; `barrier_dnstr_ch %in% FALSE`).
24. S31 "7,123 visits in 104 groups, 216 caught": holds (summary).
25. S32/S33 "43 groups with both outcomes: 4,490 visits and 215 detections": holds (`.tune_modelled`).
26. S34 "Every count below is on these visits unless it says otherwise": holds as a rule; S93 breaks it (F3).
27. S35/S36 "what link would read": gradient of the FWA segment, width link would use unmeasured, modelled
    MAD, distance to the first river of each Q on the same flow. Holds (`fwa_gradient`, `cw_deploy`,
    `mad_pick`, walks with `src = "pick"`). That the gradient is FWA's and not link's is acknowledged in S159.
27a. S38 "A rule splits the visits into those it calls habitat and those it does not": holds (`X` in
     `knw_tune_score`).
28. S39 L151 "in watersheds the model has not seen": **WRONG** (F4).
29. S41 model terms (fished area, data set, era, group; the rule in or out): holds (`glm.fit` with cloglog on
    `log_area`, `data_set`, `era`, `wsg`, `rule`).
30. S42 "5 folds of 9, 8, 9, 8 and 9 groups, balanced by detections": holds (`.tune_fold_of_wsg`;
    `groups.csv`).
31. S43 "rule's effect fitted on four folds ... each group held out once": holds (`.tune_fold_setup`).
32. S44 "held-out group gets only its own baseline level, fitted on its own visits": holds
    (`.tune_score_one` L356-361).
33. S45 "held-out deviance": holds.
34. S47 "a new watershed": **WRONG** (F4, the softer form).
35. S48/S49 "compared with the best group by group; SE over groups": holds (`.tune_sel`:
    `sqrt(n) * sd(M - M[, best])`).
36. S50 "no rule term scores 231.9 above the best": holds (`dev_null` 1,382.5 - 1,150.7; the recommended
    rule is the best, `ddev_best` 0).
37. S51 "534 of the 2,795 do worse than no rule": holds (`ddev_null > 0`).
38. S53 region "within one SE of the best": holds (`tot - best <= se`, and converged).
39. S55/S56 "23 rules; every one MAD 0.35-1, every one with the exception, Q 1-10 within 1-2 km, gradient 7 or
    9 %": holds. The hardcoded "every" was checked: 23 of 23 are MAD rules and 23 of 23 have the exception.
40. S57 "default 196.3 above the best, SE 81.6, outside": holds.
41. S58 "every rule without the exception outside; best 136.9": holds (none in the region).
42. S59 "every width rule outside; best 70.6": holds (none in the region).
43. S60 profile caption (each value's best score, filled when at least one rule is in the region, a ring on
    `default`'s value): holds (`comp()`).
44. S62 "fixed: fewest departures, then the best scorer": holds (`.tune_pick`).
45. S63 "Every rule in the region departs in all three parts": holds (all 23 have `departures` 3).
46. S66/S67 "a distance under 200 m would be moved off; 1 km stands": holds (`d_floor` 200; `recommended` is
    the pick among rules with `exc_d >= 200` or no exception).
47. S68/S69 "narrower; fewer visits, as many catches": holds (1,047 against 2,330; 166 against 165).
48. S70 raw-table caption "on the 4,490 visits the models use": holds (`n_in` on the modelled `d`).
49. S72 "Three checks were fixed before the run": holds (0297's spec in 0320's header).
50. S73-S76 seeds: 4 more, 0 the same, recommended in the region of 4, `default` in 0, 3 differ only in the
    gradient. Holds (the seeds table, verified against the tuning log).
51. S78 seeds caption: holds.
52. S79 "region and pick use every group": holds (`.tune_sel` over all rows).
53. S80/S81 nested selection, and "separation is partial": holds (`out_k` and `in_k` on `Sw` from the main
    folds' fits).
54. S82 honest caption: holds (`dev_rec`, `dev_default`, `dev_null` per fold).
55. S83-S85 totals 1,234.5 against 1,347.0; loses fold 4 by 3.6; every fold's choice MAD with the exception:
    holds.
56. S86 "drawing the groups 200 times with replacement and repeating the choice; 22 %; in the region 75 %":
    holds (resampled `Sw` rows; `.tune_pick` on each draw).
57. S88 part shares 55 / 100 / 76 / 62 and 33 / 40, 34 and 25: holds (`share_of` on `boot_rec_share`).
58. S89/S90 shape settled; gradient least settled: holds as interpretation.
59. S91 L312 "earlier tuning ... on the 55 groups link had run by then": **WRONG** (F7).
60. S93 L317 "fitted on the same visits": **WRONG** (F3).
61. S94 surface terms ("te of flow and distance to a 3 m³/s river, s(gradient), the same other terms"):
    holds. The group enters as a random effect, not per-group intercepts.
62. S95 surface caption (standard visit, distance downstream to ≥ 3 m³/s, gradient 4.5 %): holds
    (`knw_grade` at `cr$ref`, `s(wsg)` excluded).
63. S96 "within 100 m, 9.3-10.3 % whatever the flow": holds over the table's five flows.
64. S97 "at 10 km, 0.2 % to 5.3 %": holds.
65. S98 shape interpretation: holds.
66. S99 L343 reference values: "50 km from any river" **WRONG** (F5). "Distance at 0.75 m³/s" and "gradient
    4.5 %" hold (`knw_tune_curve` `base()`).
67. S100 "relative to the chance at the recommended threshold": **WRONG** (F2).
68. S101 curves caption: **WRONG** (F2, F5); the band holds.
69. S102 "26 %" holds. "2.6 times as high" **WRONG** (F2: the ratio of chances is 2.5).
70. S103 "falls in a straight line on this scale with gradient": holds (`s(grad)` edf 1.00, log axis).
71. S104 "where in and out separate best on held-out groups": holds.
72. S105/S106 "highest about 120 m": holds (124.6 m). "1.7 times the chance at 1 km" **WRONG** (F2: 1.6,
    and the table beside it gives 8.9 / 5.5).
73. S107 "42 % by 3 km" **WRONG** (F2: 43 %). "21 % by 10 km" holds.
74. S108/S109 "past the bend; lowest about 21,000 m and turns up": holds (21,264 m).
75. S113 "the curve's predicted chance on a standard visit, the group's level left out": holds (`knw_grade`:
    `type = "response"`, `exclude = "s(wsg)"`).
76. S114 "divided by the chance 95 % of accessible segments fall below, 0.1457, capped at 1": holds
    (quantile 0.95 of the rates of accessible segments; the log rounds 0.1456659).
77. S115 "top twentieth of the accessible network; 0.3 a third as often": holds (by segment count; a ratio
    on the response scale).
78. S117 "reads each segment's own flow and gradient": holds (`size = mad_pick`; gradient clamped to 0-0.2).
79. S118 "own distance only where the segment fails the size test, the segments the exception could admit":
    holds (`cand` = accessible, stream edge, gradient ≤ 9 %, fails the size test). "As if far from any
    river" **WRONG** (F5).
80. S119 the example (0.6 at its own distance, 0.2 at the cap): holds (0.644 and 0.188).
81. S120/S121 "understates streams above the floor where a river is close; open issue": holds (#65 is open,
    titled "The grade reads segments that pass the size test at the 50 km distance cap").
82. S122 "125 groups; 852,431 of 856,244 graded; the rest have no modelled flow": holds (groups from
    `streams_habitat_ch`; the log has no_gradient = 0, so the 3,813 lack MAD).
83. S123 "same under either rule": holds (one grades table).
84. S125 grade-km caption: holds.
85. S126-S128 "12,577 fewer km, 4,337 more graded; kept streams above the floor at the cap under both; the
    difference is mostly own-distance segments": holds. Of the loss, 24,542 of 24,843 km are floor losses,
    which are walked candidates. Of the gain, 9,666 of 12,266 km come through the exception. The 1,398 km of
    gradient gains are graded at the cap, which is why "mostly" is right.
86. S130/S131 "three stages on copies of every group link classifies; access gate; overlay; 10 km pass;
    regenerated, not stored": holds (`knw_compare_rules`).
87. S132 km caption, "over all 125 groups": holds. The "accessible stream" row is accessible segments of
    every edge type (network km), so it holds as network km. It is not the denominator F1 needs.
88. S133/S134 "-73.6 % to 29.9 %, median -6.2 %, 48 groups gain": holds.
89. S135 change caption: holds.
90. S136 "loss 24,542 km: wide enough for default, under 0.75 m³/s, no 3 m³/s river within 1 km": holds
    (reason: stream edge, width passes, default's gradient, fails MAD or has no MAD, no exception).
91. S137 "gain 9,666 through the exception, 6,952 order 1": holds.
92. S139 BULK 1,611 against 2,123, -24.1 %, 744 lost, 233 gained: holds.
93. S140 map caption: holds. The "accessible, neither" class is drawn but not named in the caption.
94. S141 "orange is whole tributaries below the flow floor": holds. All 744 km lost in BULK fail the floor
    with no river ≥ 3 m³/s within 1 km (`CH_rear_segments.rds`).
95. S142 "gains few, short reaches beside a river": holds (212 of 233 km through the exception).
96. S143 "groups whose whole floodplain has been mapped": holds (CH's 16 of the catalog's 23 `all_ff04`
    groups). "Each cell belongs to its nearest segment" **WRONG** (F6).
97. S144 floodplain caption: holds.
98. S145-S148 "-20 %; -18.8 % km on the same 16 groups; 98 % of km lost on order ≥ 2 across all groups;
    graded barely moves": holds (98.5 %; 146,059 → 147,442).
99. S150 FDIS check: 10,515 visits, all 125 groups, status present or absent, 10-10,000 m², accessible
    single-line streams, canals and lines through double-line rivers. Holds (`compare_rules.R` L310-325:
    edges 1000/1050/1100/1150/2000/2100/2300/1250/1350; 5,717 + 4,798).
100. S151a "The tuning chose its rule on visits from this same record": holds.
101. S151b bcfishobs lift: **WRONG** (F1).
102. S152 "presence-only records": holds.
103. S154a "Not applied": holds.
104. S154b "River polygons, wetlands and lakes keep default's size tests; river polygons take the gradient":
     holds, except "lakes" (F8).
105. S155 "Spawning is not part of it" holds. "The score prefers the rule whose in and out differ most":
     holds.
106. S156/S157 "1.4 % outside recommended against 2.3 % outside default": holds (`raw_rate_out` on the
     4,490).
107. S157b "No threshold sits where the curve bends": holds (D is past the bend, S108).
108. S158a "The region gives the range": holds.
109. S158b "distance measured from each visit; the comparison measured it from each segment's downstream end;
     looser": holds (walks keyed on the visit's measure; `knw_dist` from the segment's downstream end).
110. S159a "gradient scored on FWA segments; link applies its own": holds.
111. S159b provisional grade "as if far from any river": **WRONG** (F5). The set is also not only "streams
     above the floor", but that is incomplete rather than false.
112. S159c "Every figure is on link run …": **WRONG** (F7).
113. S159d "Not habitat quality": holds.
114. S161 link#346 "waits on its configuration reading the thresholds table": holds (open: "Threshold
     calibration read from published evidence, on the province-wide default run").

S4, S6, S18, S21, S24-S26, S37, S40, S46, S52, S54, S61, S64, S65, S71, S77, S87, S92, S110-S112, S116, S124,
S129, S138, S149, S153 and S160 name no set: headings, list markers, rationale, or a lead-in to a list
already enumerated above.

### research/habitat_thresholds_tuned.md (added lines)

R1. "a yes-or-no test: big enough, and not too steep": holds as a summary.

R2. "for each species and life stage the electrofishing record can speak to": holds (the rows of
`<sp>_<stage>_summary.csv` statuses). "in watersheds the scoring had not seen": **WRONG** (F4).

R3. "a ladder of size floors (flow or width) and gradient limits, and for small streams an allowance for a
river": holds. Every scored grid has MAD, width and exception rules (CH has 2,730 exception rules of 2,795;
BT, GR, RB, ST and WCT have 3,528 of 3,612; BT spawning and CO have 2,940 of 3,010).

R4. "scored on held-out groups, kept every version the data cannot tell from the best, recommended the one
closest to link's current test": holds (the region, fewest departures, `d_floor`).

R5. "link's current test not among them for any fitted species but grayling": holds (`default_in_region` is
TRUE only for GR among the 8 scored).

R6. "every recommended rule but grayling's draws less habitat than link does now": holds against the
regenerated `default` (ALL rows -37.3 % to -4.9 %; GR 0 %).

R7. "the grade is provisional until #65: it reads a segment that passes the size test as far from any river":
holds, except "any river" (F5).

R8. "the package article walks through one species": holds.

R9. "Set against the km on the same catalog groups (compare.csv's rows for those groups)": holds.

R10. The floodplain against the km, recomputed from `compare.csv` rows of `floodplain.csv`'s groups: holds.

| species × stage | floodplain change | km change |
|---|---|---|
| BT rearing | -24.2 % | -37.4 % |
| CO rearing | -10.8 % | -13.9 % |
| RB rearing | -15.5 % | -20.4 % |
| ST rearing | -31.1 % | -45.0 % |
| WCT rearing | -4.0 % | -24.1 % |

R11. "the streams those rules drop carry less floodplain per km": holds (it follows from R10).

R12. "CH 20 against 19, BT spawning 22 against 19": holds (-20.0 / -18.8; -22.3 / -19.0).

R13. "Graded ha follows graded km, rising only for CH": holds, both on the catalog groups (CH 5,624 → 6,544
graded km) and on all groups.

R14. "the grade reads every segment that passes its size test at the 50 km cap (#65)": holds. With no
exception on the pick, every segment is at the cap, which is still consistent.

R15. "(Revised 2026-10-18 …)": holds.

### research/chinook_rearing_tuned.md (added lines)

C1. The Verified line: holds.

C2. The Status line, "the plain-language account is the package article": holds.

C3. "Floodplain (16 catalog groups) 341,298 against 426,681 (-20 %, against -18.8 % in km on the same 16
groups), graded ha 146,059 → 147,442": holds.

C4. "graded figures provisional until #65 … a segment that passes the size test at the 50 km cap": holds.

C5. "highest about 120 m from a ≥ 3 m³/s river at 0.75 m³/s": holds. "0.42 of the 1 km value at 3 km":
**WRONG** (F2: 0.42 is the hazard ratio; the ratio of chances is 0.43).

C6. "so D = 1 km sits past the bend": holds.

C7. "#54's distance curve below, fitted separately on the visits failing the floor, showed no plateau":
holds (the file's lines 269-271).

C8. Last section: built by `data-raw/vignette_chinook.R` from `inst/vignette-data/`, its list of contents,
and link#346. Holds.

**Count.**
- Article: 161 units; 33 name no set; the 128 that do are verdicted in items 1-114, some items covering
  several units. 18 verdicts are WRONG: items 3, 9, 21, 28, 34, 59, 60, 66-69, 72, 73, 79, 96, 101, 111
  and 112.
- Research files: 23 sentences. WRONG: R2 and C5. R7 holds except for F5's wording.
