# Task: Backlog move 4: Comparison maps out of the run, and one generated research page per key (#173)

**If we do it:** a comparison run writes tables (and GeoPackages only when asked), the few example maps carry a scale bar and keymap, and each species × stage has one generated page in one template. **If we never do:** comparisons keep spending hours on GeoPackages nobody opens, the maps cannot be placed by a stranger, and the research files stay eight shapes with hand-copied numbers and stale figures.

## Context

`scripts/0330-compare.R` still writes GeoPackages by default (`GPKG` defaults to on; 196.9 min on #92's run from the
remote link) and, under `STAGE=maps`, draws the floodplain table, 121 static PNGs into `research/fig/` and 102 HTML
pages together. Its static maps have no scale bar, keymap or place names, so nobody new to the area can find the
Bulkley (#77). The eight tuning write-ups in `research/` each have a different hand-written layout and hand-copied
numbers (#90, #64). Move 2 (PR #208, merged 2026-11-12) renamed the articles to `tuning-method`,
`tuning-chinook-rearing` and `tuning-stream-splits`, so #77's map goes into those names.

The plan reads only the tracked tables and the ignored saved segments. It does no retune or promotion.

**Split (per #173's rule):** batch 7 is more than one PR. This PR carries batch 6 (#81, #77), the template and
generator, and one key, chinook rearing. The other six fitted keys' pages are filed as a new issue split from #173
and left out of `planning/backlog.md`.

## Decided at the gate (Al, 2026-11-12)

- `GPKG` is opt-in in `0330` (`GPKG=TRUE`) and off by default. The GeoPackage gets a gq style, not hardcoded hex colours.
- The example maps from #81 and #77 follow the cartography rules: BC Albers, the four corners (legend, logo, scale bar,
  keymap), town and river labels, a gq basemap blend. Each PNG is checked at the width it is published at.
- research/fig/ was measured, not assumed. Of 102 PNGs, 5 are embedded by name: 4 `chinook_rearing_tuned_*.png` and
  `setups_ch_rear_mork.png`. The 97 `compare_*.png` are named only in `scripts/logs/`, in a test fixture, in a roxygen
  example and by a glob line in 7 research pages. **A glob line does not count as showing a map:** remove all 97,
  rewrite each glob line, and list them in the PR. A script recomputes this list at the time of removal.
- One template. #64's order supplies the sections (life-history prior, evidence, recommendation, what it draws, what
  is left open), with a plain-language walk first. #90's fixed fields and figures go beneath as the specification.
  Every number comes from the tables; none is typed by hand.
- Which keys get pages: the generator writes any key. This PR runs it for chinook rearing. **The split-off issue
  covers the other 6 fitted keys** (BT rearing and spawning, CO, GR, ST, WCT rearing). The 15 unfitted keys get one
  row each in `research/tuning/README.md`'s table across keys, and no page.
- `research/chinook_rearing_tuned.md` gets **#90's move**: #54's record and its 4 embedded figures go to
  `planning/archive/`, a one-line pointer stays at the old path, and every reference to the old file is updated in
  one pass.
- Upgrade gq 0.16.1 to 0.21.0. It is stale, and this work uses `gq_tmap_keymap()`, `gq_style_qml()`,
  `gq_basemap_tiles()` and `gq_basemap_blend()`. fresh and link are stale too; this work reads neither through code
  that moved.
- Interactive map fixes: #79 is closed. #81's first open task is ticked against it.

## Phase 0: Setup
- [ ] Install gq 0.21.0; check that the functions above exist and record their signatures in findings.md
- [ ] Point `COMPARE_DIR` at the main checkout's saved segments (`../knowledge/data/compare/*_segments.rds`); check
      that their grade md5 matches the tracked `CH_rear_grades_record.csv`

## Phase 1: Maps out of the comparison (#81)
- [ ] `0330`: `GPKG` opt-in (`GPKG=TRUE`), off by default; `STAGE=gpkg` stays as the on-demand step
- [ ] `0330`: drop the static maps and HTML pages; `STAGE=maps` becomes `STAGE=floodplain`, which writes only the
      floodplain table, from the saved segments
- [ ] Classes and colours in one gq custom registry (`inst/gq/compare.csv`: rule class, grade class), read through
      `gq_reg_custom()`/`gq_reg_merge()`. `knw_compare_map()`, `knw_compare_mapgl()` and the GeoPackage read the same
      values, so `.compare_rule_cols` and `.compare_grade_cols` stop holding hex values
- [ ] The GeoPackage carries its QGIS style (`gq_style_qml()` into `layer_styles`, rule class as the default style
      and grade class as a second one); a test opens a written fixture and reads both styles back
- [ ] `knw_tune_promote()` and `0335`: drop the `fig_dir` promotion of `compare_<key>_*.png`, because no run writes
      them now; update `test-tune_promote.R`
- [ ] Docs: the 0330 header, `scripts/README.md`, the README line on `research/fig/`, and CLAUDE.md's 0330 and
      `data/compare/gpkg/` lines

## Phase 2: Example maps a stranger can place (#77)
- [ ] `knw_compare_map()`: opt-in `scalebar`, `keymap` (`gq_tmap_keymap()` on the watershed group in BC), `places`
      (town labels from `gns_geographical_names_sp`, river names from the Freshwater Atlas, with halos) and
      `basemap` (`gq_basemap_tiles()` + `gq_basemap_blend()`, Esri World Topo over World Shaded Relief), drawn in BC
      Albers; legend, logo, scale bar and keymap each in its own corner; canvas aspect from the window. All default
      off, so existing calls do not move. Tests for each argument
- [ ] `data-raw/example_maps.R` replaces `data-raw/readme_figure.R`: it draws the README figure
      (`man/figures/readme-bulk.png`) and each generated page's map panel, with everything turned on
- [ ] The chinook article's static map (`map-static`, drawn off-site) turns them on. If the bundle needs the
      context layers (group boundary, towns, river names), `data-raw/vignette_chinook.R` writes them as new bundle
      files; check `test-vignette-data.R`'s source md5s stay unmoved
- [ ] Self-review every PNG at its published width (README column; article at 80 %): the 14 checks in
      `cartography.md`
- [ ] Remove the 97 `compare_*.png` (the list is recomputed by script and pasted into the PR); rewrite the glob line
      in each of the 7 research pages to point to the GeoPackage step; fix the roxygen example path
- [ ] NEWS entry

## Phase 3: One template, one generator, chinook rearing (#90, #64)
- [ ] `data-raw/tuning_reports.R KEYS=CH_rear`: writes `research/tuning/<key>.md` from `data/tune/` and
      `data/compare/` (plus the saved segments for its map). Section order: plain-language walk with a before/after
      table; life history and prior (from `data/literature_evidence.csv` and `data/ip_model_registry.csv`, cited
      by row); evidence; what the data supports and the recommendation (the checks in one order, each with its
      direction); what it draws (km, graded km, floodplain ha, one map); what is left open; then the specification
      (#90's fixed fields). Each number is filled from a table and checked with `stopifnot()`; the script refuses to
      write when a quoted number has moved
- [ ] Each key's interpretation is a short hand-written block, `research/tuning/blocks/<key>.md`, whose numbers are
      placeholders the generator fills
- [ ] Figures in `research/tuning/fig/<key>_*.png`: detection curves, profile and region, one map panel (Phase 2
      code), each with alt text and a caption. The page records the `run_uid` it was drawn from; a test fails when a
      page's `run_uid` is not the tracked summary's
- [ ] `research/tuning/README.md`: links the methodology article for the method, and holds one table across all 22
      keys (rule, km changed, graded or not, how firm), linking each page that exists
- [ ] #90's move of `chinook_rearing_tuned.md`: #54's record and its 4 figures to `planning/archive/`, a one-line
      pointer at the old path, every reference updated (CLAUDE.md, `research/README.md`, scripts, Rmd files)
- [ ] `research/README.md` states the template and the order to read the files in (#64)

## Phase 4: Issues
- [ ] File the split-off issue (the 6 other fitted keys' pages from the generator). Its body names #173 as where it
      was split from. Leave it out of `planning/backlog.md`
- [ ] Edit the bodies of #81, #77, #90 and #64: tick what landed, and add a pointer to the new issue in #90 and #64

## Owed at the end (reported, done after merge)

- [ ] Run `0330 STAGE=floodplain` on the database's host so `data/compare/floodplain.csv` is written by the new step
      (this PR leaves the tracked table as it is)

## Validation

- [ ] Tests pass (`devtools::test()`, with `NOT_CRAN=true` for any single-file rerun)
- [ ] `lintr` compared per file against `origin/main`; `devtools::document()`; `pkgdown::check_pkgdown()`; the site
      builds the three articles
- [ ] `/code-check` clean (once over the branch with `/code-check branch`, three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- **GPKG opt-in:** a test of the env parsing (unset gives FALSE, `TRUE` gives TRUE, anything else refuses).
- **GeoPackage style:** write a fixture GeoPackage, read `layer_styles`, and check that every class in the registry is
  in the QML.
- **Maps:** a test per new argument checks it draws, and that the defaults leave the old output unchanged (the
  README figure compared before and after with everything off). Each PNG read and reviewed at its published width.
- **Generator:** run twice and get identical bytes; mutate one tracked number in a temp copy and check that the
  script refuses; the `run_uid` test is restored to the bug state and must fail.
- **Figure removal:** the script's list, rerun after the removal, finds nothing named that is gone
  (`git grep` over research/, vignettes/, README and data-raw).
