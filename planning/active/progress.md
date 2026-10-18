# Progress — Chinook rearing as a vignette: how the threshold was chosen and what it draws, in plain language (#62)

## Session 2026-10-18

- Plan approved in the previous session and recorded in the issue body; premises re-checked against the tree
  (the `data/tune/CH_rear_*` and `data/compare/CH_rear_*` files, `score.rds`, the catalog's
  `bulk_floodplain.gpkg`, log lines 538-554 and 1446)
- Created branch `62-chinook-rearing-as-a-vignette-how-the-th` off main
- Scaffolded PWF baseline from issue #62 with the approved phases
- Next: start Phase 1
- Phase 1 (`9990d64`): `VignetteBuilder: knitr`; bookdown, ggplot2, knitr, png, rmarkdown in Suggests;
  `^data-raw$`, `^doc$`, `^Meta$` build-ignored; `pkgdown::check_pkgdown()` clean
- Phase 2: `data-raw/vignette_chinook.R` run 2026-10-18 (18:50-18:52 UTC). Every assertion held: the seeds
  and nested-selection tables print exactly as the tuning log's blocks, the floodplain join reproduces
  `floodplain.csv`'s BULK rows (674 ties both times), graded raster cells x 0.09 = accessible ha less
  ungraded within 1 ha, km by rule equal `compare`'s BULK row. Stability tables came from `score.rds`;
  `0320` now writes `<key>_{seeds,honest}.csv` for the next run.

  | file | MB |
  |---|---:|
  | `chinook_rearing.rds` | 0.14 |
  | `bulk_segments.rds` | 0.84 |
  | `bulk_water.rds` | 0.08 |
  | `bulk_fp_grade.tif` | 0.39 |
  | `inst/vignette-data/` | 1.45 |

  `test-vignette-data.R`: 5 tests, 37 expectations pass. Guard proven: one line appended to
  `data/tune/CH_rear_groups.csv` turns the md5 test red; restored from git.
- `meta$md5` covers the tracked sources (the ten tables, the tuning log, the evidence ledger);
  `meta$md5_local` records the ignored ones (saved segments, catalog gpkg, score.rds) for provenance only,
  since the test cannot expect them on another clone.
- Phase 3: `vignettes/chinook_rearing.Rmd` rendered with `pkgdown::build_article()` against a scratch install
  (knowledge is not installed on this machine, and the article calls `library(knowledge)`). Every `<img src>`
  resolves under `docs/articles/chinook_rearing_files/`; `footnote-ref` 0; no literal `\@ref`; no `Error`.
  The figures were read at their rendered size: the profile marks `default` in all four panels, the map is
  three stacked panels with every class in its legend and the floodplain legend in five classes on 0-1.
- Deviation: `knw_compare_map()` gains `ncol` (default unchanged, side by side). Side by side the map is
  12 in wide and its legends unreadable in a 700 px column; `ncol = 1` stacks it 4 in wide. One test added.
- Deviation: captions carry no "Figure N" on the site. pkgdown renders articles in its own format, and the
  published link and flooded articles show none either. The article cross-references nothing, so nothing
  depends on the number.
- Prose corrected after reading the render: the distance curve does bend (highest about 120 m from the river,
  falling past a few hundred metres), so the sentence that none of the three curves bends was wrong.
- Phase 4: the thresholds file opens with a plain-language paragraph; the chinook file's last section points at the
  article and its head paragraph records that the province-wide curve bends in distance (#54's did not); both
  READMEs name the article; `scripts/README.md` names the refresh after `0330`.
- Code-check round 1 (`review-round1.md`, 3 findings, all fixed): the evidence ledger is now the one the tuning
  log names on its first line, with a stop when its link run differs; `thresholds.csv` and `floodplain.csv`,
  which hold every species, are guarded on their CH rearing rows (`.knw_rows_md5()`; proven: a BT-row edit
  stays green, a CH-row edit goes red); the detection check's sentence names its own population (10,515
  visits in all 125 groups) and no longer calls them the tuning's visits. Data script rerun 19:10-19:12 UTC.
- Tests (frozen worktree at `1c8c5c9`): 522 pass, 0 skipped. `devtools::check()`: 0 errors, 0 warnings, 1 NOTE
  (Rd example lines over 100 characters in five pages that predate this branch); installed size OK; the
  vignette builds and rebuilds. The build adds R >= 3.5 (the rds files) and R >= 4.1 (the native pipe).
- Article audit (`review-audit.md`, 141 claims; 8 wrong, 7 unsupported). One is a defect in #57's published grade,
  reproduced from `CH_rear_curve.rds` and filed as #65: segments that pass the size test are graded at the 50 km
  distance cap, though the curve was fitted on every visit's real distance (a 2 m³/s stream 100 m from a river
  grades 0.6 at its own distance and 0.2 at the cap). Not fixed here: regrading republishes `habitat_grade`.
  The article now says what the grade does and calls graded figures provisional; the data script saves a
  flow-by-distance surface from the curve so the curve section shows the joint shape and names its reference
  values. Other fixes: the scoring's held-out intercept, 534 rules worse than no rule, the nested selection's
  partial separation, floodplain against km on the same 16 groups (-20 % against -18.8 %), river polygons'
  gradient in the limits, the comparison (not link) measuring distance from a segment's end; three
  unsupported causal sentences cut. `habitat_thresholds_tuned.md`'s floodplain paragraph compared
  catalog-group floodplain with all-group km for every species; rewritten on the same groups.
- Code-check round 2 (`review-round2.md`): one defect inside round 1's fix, the check sentence still omitting
  the area filter and the edge types the check keeps; fixed from `fwa_edge_type_codes`.
- Code-check round 3 (`review-round3.md`): mechanism named (a sentence describes a quantity by its role in the
  story or by a neighbouring set, not by the code that computes it); enumeration of 161 article units and 23
  added research sentences; 9 prose findings, code clean. Fixed: the bcfishobs check's set (826 locations on
  accessible stream edges) and denominator (stream-edge km share); curve ratios were cloglog hazard ratios,
  now converted to ratios of predicted chances (exact: each curve's implied baseline hazard is constant across
  its rows), so 1.7 -> 1.6, 2.6 -> 2.5, 42 % -> 43 %; distance always to a river of at least 3 m³/s; the
  floodplain cell's owner; lakes or reservoirs; the scoring population's edge types and quality checks;
  "held out of the fit" for "not seen"; the earlier tuning's group count no longer typed.
- Code-check round 4 (`review-round4.md`): all 26 units round 3's fixes changed, 24 hold; the probability-ratio
  conversion verified exact. Two low defects fixed: each edge set now named by its own types (the default
  stream test and the outside check take 1000/1100/2000/2300; the FDIS check also takes wetland lines, the
  reservoir bank and the double-line river lines), and the outside check's A/B match (within 100 m, confirmed
  in bcfishobs' match-type labels). The three rewritten sentences checked against those definitions by hand.
  Loop ended by enumeration: round 3 enumerated 161 article units and 23 research sentences; round 4 every unit
  round 3's fixes changed; the last three rewrites against the code's set definitions.
