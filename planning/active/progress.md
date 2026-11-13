# Progress — Backlog move 4: Comparison maps out of the run, and one generated research page per key (#173)

## Session 2026-11-12

- Plan-mode exploration — phases approved by user (three gate questions answered: remove the 97 compare PNGs, split
  the other 6 fitted keys into a new issue, #90's move of the old chinook page)
- Created branch `173-backlog-move-4-comparison-maps-out-of-th` off origin/main; claimed move #173 (`in-flight`)
- Scaffolded PWF baseline from issue #173 with approved phases
- Next: start Phase 0

## Session 2026-11-13

- Phase 0: gq 0.16.1 → 0.21.0. gq cannot write a QML for a custom registry layer: filed gq#115; Al chose to build it
  in gq first
- Plan review (`review-plan.md`): three blockers (no QML source; neither on-demand stage reads the promoted run and the
  floodplain table is #65's; documented `GPKG=FALSE` calls), and batch 6 alone is a full PR. Both blockers checked
  and confirmed. Al cut the PR to batch 6; batch 7 goes to a split-off issue. `task_plan.md` rewritten to that scope
  with the review's gaps folded in
- Next: Phase 1, the GPKG helper
- Phase 1: `.knw_env_flag()` reads `GPKG` (off unless TRUE); `0330` drops the maps and HTML pages, `STAGE=floodplain`
  replaces `STAGE=maps` (which now refuses and names its replacements), floodplain rows carry `tune_run`,
  `config_sha` and `tuned_rule`, `STAGE=gpkg` takes the promoted run; the GeoPackage gains `rule_class`, `water`,
  `water_ha` and a `run` table; the classes and colours move into `inst/gq/compare.csv` (read the same by gq). The
  writer was run on BULK against `fresh_default_20261023` (findings)
- Phase 1: `knw_tune_promote()` loses `fig_dir` (a run's `fig/` from before #173 is left and noted); the figure-only
  promotion tests ported to the GeoPackage (145 pass). A by-key promotion now refuses when floodplain.csv's columns
  differ (the new run columns), naming the keys to promote: noted for NEWS. Docs: the 0330 and 0335 headers,
  scripts/README.md, README.md, inst/NOTICE.md, CLAUDE.md, and each research page's map line (now pointing to
  `STAGE=gpkg`). `data-raw/setup_compare.R` keeps its own `GPKG` default (a setups check, not 0330)
- gq#115 handed to a background agent at 06:47 UTC (its own worktree and PR; no merge)
- gq#115: the agent's gq PR #118 adds `gq_qgis_style()` and `gq_gpkg_style_write()` (CI green; loaded in headless
  QGIS 4.2.1 by the agent). Not merged: Al's word. The installed gq is that branch's build. Wired here:
  `.compare_qgis_styles()` builds both QMLs from `inst/gq/compare.csv`; `gpkg_one()` writes them (rule class default) and
  fills "not graded" on reachable ungraded segments; BULK trial reads both styles back. xml2 added to Suggests (the test)
- Al chose Esri tiles with attribution and no NOTICE row for the example maps (task_plan, decisions)
- Phase 2: `knw_compare_map()` gains `width` (canvas from the window's shape), `scalebar`, `keymap`, `places`, `basemap`
  (credit in a strip under the map), `logo` and `corners`; all off by default, and the default README and three-panel
  renders are byte-identical before and after (md5 518187…, d5d3fb…). Each extra's test was proved by breaking it (the
  first version of the test passed with the scale bar removed, because any extra switched the frame on: fixed by
  framing every sized map; the keymap needed a test on what reaches `tmap_save()`). `knw_compare_mapgl(scale = TRUE)`.
  `data-raw/vignette_context.R` → `bulk_context.rds` (39 KB: the BC outline needed exterior rings only, 3.4 MB
  before); towns from NRCan's Canadian Geographical Names (OGL-Canada; both provincial layers are Access Only).
  README figure: Esri topo × shaded relief (gamma 1), 5 in, legend NE over Babine Lake, keymap SW, scale bar NW, the
  outside faded, credit in a strip; checked at 600 px. Article: the static map gets keymap, scale bar and labels, no
  basemap (built without network under R CMD check); the site map gets the scale control. No logo on either: the
  README and site carry the hex sticker (cartography skill). 97 `compare_*.png` removed (list in findings);
  0335 now reruns `vignette_context.R` before `readme_figure.R`
- Phase 3: filed #211 (template, generator, chinook page; the six other keys and #90 item 7 named as next); #90, #64 and #173 point to it. #81 and #77 are ticked at merge
- Validation: full suite `[ FAIL 0 | WARN 0 | SKIP 4 | PASS 2361 ]` (skips: no fresh_default_20261017, no ignored FDIS
  build, KNW_CHECK_GRADES unset, no cut-points stage). Lints on the touched files: 51 new against origin/main, then 16
  after wrapping; the rest are `object_usage` on helpers the installed knowledge 0.4.36 lacks and 0330's script
  globals, two header/fixture forms the existing files share. `check_pkgdown()` clean. Touched tests after the lint
  edits: `[ FAIL 0 | SKIP 3 | PASS 495 ]`
