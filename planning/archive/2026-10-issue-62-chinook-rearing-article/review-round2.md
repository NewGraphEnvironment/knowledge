# Code-check round 2 (#62): branch diff against main, round 1's fixes in particular

## Findings

- **[severity: bug]** vignettes/chinook_rearing.Rmd:492-493. Round 1's fix (3) still names the population wrongly.
  The sentence says "the 10,515 FDIS visits with a recorded catch or miss on accessible segments in all 125 groups,
  rivers included". `knw_compare_rules()` (R/compare_rules.R:309-317) applies two more filters before it counts:
  - fished area 10 to 10,000 m² (`!is.na(area_m2) & area_m2 >= 10 & area_m2 <= 10000`);
  - edge type in `c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350)`.

  I rebuilt the count read-only from `data/fdis/derived/visits_{link,species}.csv` and
  `data/compare/CH_rear_segments.rds`, and it comes to exactly 5,717 + 4,798 = 10,515:
  - **11,828** CH present/absent visits fall on accessible segments;
  - 10,897 of them pass the area filter (741 have no area, 190 are out of range);
  - 11,403 pass the edge filter. The 425 left out are on edge types 1450 (228, the connector lines inside river
    polygons), 1200 (89), 1400 (71), 1410 (32), 1425 (3) and 1300 (2);
  - **10,515** pass both.

  So the number printed is 1,313 short (11 %) of the population the sentence names. "Rivers included" is also only
  half true: double-line river main lines (1250, 1350) are in, but the 228 visits on river connectors (1450) are
  out. Suggested wording: "On the 10,515 FDIS visits with a recorded catch or miss, a fished area of 10 to
  10,000 m², and a stream or river main line on an accessible segment…". Or drop "rivers included" and say "on
  accessible stream and river lines".

## Checked and clean

- **Round-1 fix (1), the ledger.** The log's first line names `scripts/logs/habitat/20261017_evidence_build_ledger.csv`,
  and the regex pulls it out. The no-match and missing-file guard works. The ledger's `link_run_uid`
  (`20261017_004619-3f4c713b`) matches the run the log names, and the saved meta carries it.
- **Round-1 fix (2), per-species md5.**
  - `.knw_rows_md5()` restored-bug probe, on copies in the scratchpad: editing a non-CH row leaves the hash
    unchanged, and editing a CH-rear row changes it. This holds on both `thresholds.csv` and `floodplain.csv`.
  - Every md5 source the test checks is tracked: the 7 per-species csv files, the log, the ledger, and the two
    row-hashed files.
  - The multi-species tuning log is hashed whole, which is right: a rerun writes a new log and leaves this one as
    it is.
- **Tests.** `test-compare_map.R` (3/3) and `test-vignette-data.R` (6/6, 36 expectations) pass under
  `NOT_CRAN=true` in a scratch copy with `data/` symlinked. Under R CMD check the source-tree tests skip as
  intended (root has no `data/`).
- **Article numbers.** I recomputed every inline value from `inst/vignette-data/chinook_rearing.rds`, and each
  quantifier holds:
  - 2,795 rules, 23 in the region, every one MAD 0.35–1 with the exception, Q 1–10, D 1–2 km, gradient 7 or 9 %;
  - every region rule departs from `default` in all three parts;
  - `default` is +196.3 (SE 81.6); the best rule with no exception is +136.9 and the best width rule +70.6;
  - the no-rule model is 231.9 above the best;
  - "fewer visits, as many catches": 1,047 against 2,330 visits in, 166 against 165 detections in;
  - seeds: 0 of 4 recommend the same rule, it is in the region of 4, `default` in 0, and 3 differ only in gradient;
  - nested selection: 1,234.5 against 1,347.0, losing only fold 4 (by 3.6), and every fold's choice is MAD with
    the exception;
  - bootstrap shares: gradient (40.5 %) is the least settled part;
  - curves: MAD is monotone; the distance peak is 124.6 m (rel 1.80) and 300 m is 1.65; 3 km is 0.42 and 10 km 0.21;
  - grade: 852,431 of 856,244 accessible segments graded;
  - km, graded km, change range, median and 48 groups gaining, change reasons, and BULK figures all check;
  - floodplain −20 % against the km's −18.8 % in the same 16 groups, so "more than the km" holds there as well as
    against −12 % overall;
  - checks rates 17 % / 1.5 % and 14 % / 2.2 %, and lifts 3.3 and 2.5;
  - "55 groups … 7 %" matches `research/chinook_rearing_tuned.md` (#54).
- **`habitat_thresholds_tuned.md` plain words.** `default` is in the region only for GR among the fitted and
  underpowered species, and every other species' recommended rule draws less (−4.9 % to −37.3 %).
- **`knw_compare_map(ncol =)`.** The validation, `nc`/`nr` and figure size are correct, and the vignette's
  `fig.height = 13.8` equals 3 × 4.6.

planning/active/review-round2.md
