# Task: Backlog move 4: Comparison maps out of the run, and one generated research page per key (#173)

**If we do it:** a comparison run writes tables (and GeoPackages only when asked), the few example maps carry a scale bar and keymap, and each species × stage has one generated page in one template. **If we never do:** comparisons keep spending hours on GeoPackages nobody opens, the maps cannot be placed by a stranger, and the research files stay eight shapes with hand-copied numbers and stale figures.

## Context

`scripts/0330-compare.R` writes GeoPackages by default (196.9 min on #92's run from the remote link). Under
`STAGE=maps` it draws the floodplain table, the static PNGs in `research/fig/` and the HTML pages together. Its
static maps have no scale bar, keymap or place names, so nobody new to the area can find the Bulkley (#77). Move 2
(PR #208, merged 2026-11-12) renamed the articles to `tuning-method`, `tuning-chinook-rearing` and
`tuning-stream-splits`.

This PR is **batch 6 only (#81, #77)**. It reads the tracked tables and the ignored saved segments, and does no retune
or promotion.

## Decided at the gate (Al, 2026-11-12)

- `GPKG` is opt-in in `0330` (`GPKG=TRUE`) and off by default. The GeoPackage gets a gq style, not hardcoded hex colours.
- The example maps from #81 and #77 follow the cartography rules: BC Albers, the four corners (legend, logo, scale bar,
  keymap), town and river labels, a gq basemap blend. Each PNG is checked at the width it is published at.
- research/fig/ was measured, not assumed. Of 102 PNGs, 5 are embedded by name: 4 `chinook_rearing_tuned_*.png` and
  `setups_ch_rear_mork.png`. The 97 `compare_*.png` are named only in `scripts/logs/`, in a test fixture, in a roxygen
  example and by a glob line in 7 research pages. **A glob line does not count as showing a map:** remove all 97,
  rewrite each glob line, and list them in the PR. A script recomputes this list at the time of removal.
- Upgrade gq 0.16.1 to 0.21.0 (done in Phase 0).
- #79 is closed and the mapgl/Esri map landed with it (NEWS 0.4.8), so #81's first open task is ticked against it.

## Decided after the gate (Al, 2026-11-13)

- **gq has no QML writer for a custom registry layer** (`gq_style_qml()` returns only the QMLs gq ships). Filed as
  [gq#115](https://github.com/NewGraphEnvironment/gq/issues/115). **Build it in gq first** (its own branch and PR),
  then use the release here. If that release is not out by this PR, the style task moves to the split-off issue.
- **Split, after the plan review (`review-plan.md`) measured batch 6 alone as a full PR: this PR carries batch 6 only.**
  Batch 7 goes to one split-off issue naming #173, left out of `planning/backlog.md`. It covers the template, the
  generator, the chinook page and #90's move of `chinook_rearing_tuned.md`, then the other six fitted keys, and the
  floodplain question. (The tracked floodplain table's chinook rows are #65's, from the superseded rule: the #145
  promotion only deleted rows. No stage can redraw them without a comparison run and a promotion.)
  The gate's batch 7 decisions travel with it: #64's order with #90's specification beneath, every number from the
  tables, and the 15 unfitted keys as table rows only.

- **Basemap (Al, 2026-11-13): Esri World Topo over World Shaded Relief, with Esri's attribution drawn on the map, and
  no `inst/NOTICE.md` row** ("esri with attribution. no notice ... 'not intended' does not say forbidden"). Esri's
  catalogue items put both under the Esri Master License Agreement; the topographic item says it "is not intended to be
  used to export tiles for offline". This is a stated exception to CLAUDE.md's rule that a new tracked source gets a
  NOTICE row.

## Mechanism (decided by the agent; reported)

- `GPKG` is parsed by an `R/` helper so it can be tested: unset or `FALSE` gives FALSE, `TRUE` gives TRUE, anything
  else refuses. `FALSE` stays valid, so every documented `GPKG=FALSE` call still works.
- `STAGE=maps` remains as a refusal that names its replacements. `STAGE=floodplain` writes the floodplain table alone,
  and gains `tune_run`, `config_sha` and `tuned_rule` columns so a stale row can be told apart.
- `STAGE=gpkg` also accepts the promoted run (`TUNE_DIR=data/tune`). It reads `data/compare/<key>_segments.rds` and
  writes into the ignored `data/compare/gpkg/`, so the published run can be opened in QGIS without a promotion. Each
  GeoPackage carries a `run` table naming the run it was written from.
- The README figure keeps `data-raw/readme_figure.R`, which 0335 already runs. With the maps gone from 0330, it and the
  article's map chunk are the only scripted example maps.
- The context layers for the article's static map are written by their own script (`data-raw/vignette_context.R`)
  into new bundle files, pinned to `chinook_rearing.rds$meta$map_group`. `vignette_chinook.R` is not rerun, because a
  rerun would rewrite `bulk_segments.rds`, which `method.rds` pins (#77's task 2 says rerun it; this is why not).

## Phase 0: Setup
- [x] Install gq 0.21.0; record what it can and cannot do in findings.md (no QML writer for custom layers: gq#115)
- [x] Plan review written to `review-plan.md` and folded in here; scope cut to batch 6 on Al's word

## Phase 1: Maps out of the comparison (#81)
- [x] `GPKG` opt-in through a tested `R/` helper (unset or FALSE gives off, TRUE gives on, anything else refuses)
- [x] `0330`: drop the static maps and HTML pages. Add `STAGE=floodplain` (the floodplain table alone, with run
      columns); `STAGE=maps` refuses and names `floodplain` and `gpkg`
- [x] `STAGE=gpkg` accepts `TUNE_DIR=data/tune` (the promoted run → `data/compare/gpkg/`), and every GeoPackage gets
      a `run` table
- [x] GeoPackage fields (#81 task 5): add the rule class (kept, lost, gained, neither) and the area of the waterbody a
      through-wetland segment runs through. Flow, width, gradient, distance, order and `link_branch` are already there
- [x] Classes and colours move into one custom registry (`inst/gq/compare.csv`), which `knw_compare_map()` and
      `knw_compare_mapgl()` read. `.compare_rule_cols` and `.compare_grade_cols` stop holding hex values, and the
      integer `match_expr` mapping is tied to the registry's class order
- [ ] gq#115: the QML writer in gq (its own branch and PR; the merge and release on Al's word). Once released, the
      GeoPackage carries rule-class (default) and grade-class styles in `layer_styles`, tested on a fixture: every
      class present, one style default. If it is not released by this PR, the style task moves to the split-off
  - [x] gq PR #118 (`gq_qgis_style()`, `gq_gpkg_style_write()`), CI green, open for Al's merge and release
  - [x] knowledge side wired against the branch build: `.compare_qgis_styles()`, `gpkg_one()` writes both styles,
        a test on a fixture GeoPackage, the BULK trial reads them back
  - [ ] gq released, and DESCRIPTION's gq floor set to that release
- [x] `knw_tune_promote()`: drop `fig_dir`, covering its signature, roxygen, example, archive place map and comments.
      `0335`: the header, its list, and "regenerate figures" left out. Port the two figure-only tests
      (`test-tune_promote.R` "archive and undo" and "an undo restores whatever the files' ages") to the GeoPackage
- [x] Docs: the 0330 header, the 0335 header, `scripts/README.md`, `data-raw/README.md`, README's `research/fig/`
      line, `inst/NOTICE.md` (the maps and floodplain panel lines), and CLAUDE.md's 0330, `data/compare/gpkg/` and
      promotion lines

## Phase 2: Example maps a stranger can place (#77)
- [ ] `knw_compare_map()`: opt-in `scalebar`, `keymap` (`gq_tmap_keymap()` on the watershed group in BC), `places`
      (town labels and river names, with halos) and `basemap` (`gq_basemap_tiles()` with `gq_basemap_blend()`, Esri
      World Topo over World Shaded Relief, its `credit` drawn), in BC Albers. Legend, logo, scale bar and keymap each
      get their own corner, and the canvas aspect comes from the window. All default off. Tests for each argument;
      the basemap test skips offline and on CRAN
- [ ] `knw_compare_mapgl()`: an opt-in scale control, so the site's map carries a scale too
- [ ] Sources and terms: towns from BC Geographical Names through bcdata, names only (the `vignette_cut_points_places.R`
      pattern); river names from the Freshwater Atlas; the keymap's BC outline from a named source. NOTICE rows for
      Esri tiles and each new source. `maptiles` added to Suggests, gq floor set (`gq (>= 0.21.0)`)
- [ ] `data-raw/vignette_context.R` writes the context layers for the Bulkley map into new bundle files, added to
      `test-vignette-data.R`'s shipped-files list and pinned to the bundle's `map_group`
- [ ] Turn them on in `data-raw/readme_figure.R` (README figure) and the article's `map-static` chunk and site map.
      The "defaults unchanged" baseline is redrawn after the gq upgrade, not taken from the committed PNG
- [ ] Self-review every PNG at its published width (README column; article at 80 %) against `cartography.md`'s 14
      checks. Render the article off-site after installing the branch, and check whether `R CMD check` now needs
      network
- [ ] Remove the 97 `compare_*.png` (the list is recomputed by script and pasted into the PR), rewrite the glob line in
      each of the 7 research pages to point to `STAGE=gpkg`, and fix the roxygen example path. The frozen `0297` and
      `0298` keep their paths (they are frozen)
- [ ] NEWS: the GPKG default flip, `fig_dir` removed, `STAGE=maps` renamed, the new map arguments

## Phase 3: Issues
- [ ] File the split-off issue for batch 7, naming #173, left out of `planning/backlog.md`. It carries: the template
      (#64's order, #90's specification), the generator, a check register with each check's direction and the
      firmness columns, figure functions taken out of the article, the chinook page and #90's move, pointer files for
      the other `_tuned.md` pages, the other six fitted keys, the floodplain hectares (stale for CH), the per-key data
      bundle and readiness test (#90 item 7), and the GeoPackage style if gq#115 is not released by then
- [ ] Edit the bodies of #81 and #77 (tick what landed) and of #90, #64 and #173 (point to the split-off issue)

## Validation

- [ ] Tests pass (`devtools::test()`, with `NOT_CRAN=true` for any single-file rerun)
- [ ] `lintr` compared per file against `origin/main`; `devtools::document()`; `pkgdown::check_pkgdown()`; the site
      builds the three articles
- [ ] `/code-check` clean (once over the branch with `/code-check branch`, three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

How each change is proved:
- **GPKG opt-in:** the helper's test, with the bug restored (default on) it must fail.
- **STAGE=gpkg on the promoted run:** a fixture `data/compare/` with saved segments; the GeoPackage has the class
  column, the waterbody area and a `run` table.
- **GeoPackage style (if gq#115 lands):** read `layer_styles` from a fixture; every registry class present; one default.
- **Maps:** a test per new argument; with everything off, the output is unchanged against a post-upgrade baseline.
  Each PNG read and reviewed at its published width.
- **Figure removal:** the script's list, rerun after removal, names nothing gone (`git grep` over research/,
  vignettes/, README and data-raw).
