## Outcome

`vignettes/chinook_rearing.Rmd` tells the province-wide chinook rearing tuning (#57) in plain language for a
reader who has not seen it, in the reader's order: what link draws now, the 2,795 rules asked about, the
evidence and the scoring, the region, the pick, the stability checks, the flow-by-distance surface and the
curves, the grade, the change on the ground with a Bulkley map, and the limits. It runs from
`inst/vignette-data/`, which `data-raw/vignette_chinook.R` writes from the tuning and comparison tables and
asserts against them; `tests/testthat/test-vignette-data.R` fails when any tracked source has moved on
(per-species files on their CH rearing rows). `0320` now writes the seeds and nested-selection tables;
`knw_compare_map()` gains `ncol`. The two research files and both READMEs point at the article. What was
learned: an article built for a reader is a second audit of the research it restates. A 141-claim audit and
four review rounds found that the grade #57 published reads every segment that passes the size test at the
50 km distance cap, though its curve was fitted on real distances (filed as #65, not fixed here); that the
saved curves' relative rates are cloglog hazard ratios, not ratios of chances; that the province-wide curve
bends in distance where #54's did not; and that `habitat_thresholds_tuned.md` had compared catalog-group
floodplain with all-group km for every species. Every defect the reviews found had one mechanism, named in
round 3: a sentence describing a quantity by its role in the story, or by a neighbouring set, rather than by
the code that computes it.

## Measurement

- `inst/vignette-data/`: 1.45 MB (0.14 tables, 0.84 BULK segments simplified at 10 m, 0.08 water, 0.39
  floodplain-by-grade raster); `R CMD check` installed size OK.
- The grade defect, from `CH_rear_curve.rds` at 3 % gradient: MAD 0.8 m³/s 100 m from a 3 m³/s river grades
  0.75 at its own distance and 0.13 at the cap; about 480,000 of 856,244 accessible CH segments were graded at
  the cap. This turned the grade from a published product into a provisional one (#65).
- Hazard against chance ratios on the saved curves: 1.7 -> 1.6 at 300 m, 2.6 -> 2.5 at 5 m³/s, 42 -> 43 % at
  3 km. Exact conversion, since each curve's implied baseline hazard is constant across its rows (to 2e-5).
- Floodplain against km on the same catalog groups: CH -20 % against -18.8 % (the research file had set it
  against -12.4 % over all groups); BT rearing -24 against -37, BT spawning -22 against -19, CO -11 against -14,
  RB -15 against -20, ST -31 against -45, WCT -4 against -24.
- Reviews: round 1, 3 findings; the article audit, 8 wrong and 7 unsupported of 141 claims; round 2, 1 (inside
  round 1's fix); round 3, 9 (enumeration of 161 article units and 23 research sentences); round 4, 2 of 26
  changed units. Five reviewer agents in all.

## Evidence

`planning/archive/2026-10-issue-62-chinook-rearing-article/review-*.md`; the tuning log
`scripts/logs/habitat/20261017_tune_run-bt_ch_co_st.txt` the data script asserts against.

Closed by: the PR for #62 (branch `62-chinook-rearing-as-a-vignette-how-the-th`)
