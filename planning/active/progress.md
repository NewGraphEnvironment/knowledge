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
