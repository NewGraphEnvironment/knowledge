# Code-check round 1: branch 173-backlog-move-4-comparison-maps-out-of-th (eac16623...44042b97)

## Checklist read

- code-check-python.md: in full (no Python in the diff; nothing applies).
- code-check.md: the prose of all 14 H3s under `## Mechanisms`, table rows skipped. Of "Rules that stand alone",
  I read none in full. I judged Documentation Staleness and "Do not write to an artifact a human is testing on"
  from their index lines. Security, Spreadsheets and PDFs: not applicable, not read (about 31 headings unread).
- code-check-r.md, read by heading: "Regenerated binaries churn git even when nothing changed"; "Postgres row order
  is never fixed..."; "`clusterApply()` returns `NULL` for no tasks..."; "Forked `parallel::mclapply()` workers
  segfault..."; "A `function(...)` mock hides arguments..."; "Under `R CMD check`, tests run from a temp dir against
  the INSTALLED package"; "`on.exit()` at a script's top level never fires"; "`tryCatch()` nests its handlers...";
  "A database driver's value is not a base R type". I checked the rest against the diff from their index lines only
  (about 120 headings not read in full).
- code-check-spatial.md, read by heading: "A GeoPackage is a SQLite database, and that leaks in three ways"; "The
  same leak reaches R and OGR SQL..."; "A name is not a key: `GNIS_NAME`..."; "sf: `st_intersection()` /
  `st_difference()` return a GEOMETRYCOLLECTION..."; "A GDAL failure partway through `sf::st_read()`..."; "`atan2(0,
  0)` is 0...". The rest were checked from their index lines (about 95 headings unread).
- code-check-shell.md: index lines only. The diff has no shell code (0 headings read in full).

## Findings

- **[severity: fragile]** scripts/0330-compare.R:435 (called from :489). This can throw away a full comparison run.
  - **The failure.** With `GPKG=TRUE`, `write_gpkgs()` builds its arguments in the master process with
    `styles = .compare_qgis_styles()`, and that call is not inside any `tryCatch`. `.compare_qgis_styles()` stops
    when the installed gq has no `gq_qgis_style()`.
  - **Why a host hits it.** gq `main` (0.21.0) does not export `gq_qgis_style()`: I checked its NAMESPACE on GitHub,
    and the function is only in the open gq PR. DESCRIPTION gives gq no floor. So on a database host whose gq comes
    from `main`, a full `GPKG=TRUE` run fails this way.
  - **When it stops.** The run compares every key first (162.9 min for every key per CLAUDE.md), and only then dies.
  - **What it leaves.**
    - Line 484 has already unlinked `compare.csv`, `change.csv` and `checks.csv`, and the composition that rewrites
      them comes after line 489, so the candidate holds none of the three.
    - `knw_tune_promote()` therefore refuses the run with "its last comparison did not finish".
    - The log is written only at line 633, so it is lost too.
    - No STAGE composes the saved per-key tables, so the only way back is a second full run.
  - **The contrast.** Before this branch, everything that could fail in the GeoPackage step ran inside
    `gpkg_one()`'s per-key `tryCatch` and came back as a message. Now one up-front dependency, checkable in a
    millisecond at startup, sits after hours of work.
  - **Fix.** Resolve the styles, or at least check that gq has `gq_qgis_style()` and `gq_gpkg_style_write()`, at
    startup whenever `gpkg` is TRUE or `STAGE=gpkg`, before any comparison starts.
  - **Rule:** code-check.md "A guard that fails toward pass" (its paragraphs on a guard failing toward abort, which
    throws away completed work, and on where a guard sits)

- **[severity: bug]** R/segment_water.R:9 and :413-418. Every river segment gets `water_ha = NA`.
  - **The code.** `water_ha` is `coalesce(l.area_ha, wl.area_ha, m.area_ha)` over the lakes, wetlands and man-made
    polygons. `fwa_rivers_poly` is never joined, though it has `area_ha`.
  - **What the comment says.** `water_ha` is "the summed area of the waterbody's polygons" for every waterbody key,
    river included. 0330's header (`water`, `water_ha`) says the same.
  - **Measured** read-only on the database, BULK: of the 115 type-`R` waterbodies its streams carry, all 115 have no
    area from the three joined tables. The other types have none missing: L 0 of 1509, W 0 of 2372, X 0 of 20.
  - **Effect.** In the GeoPackage, every segment inside a double-line river reads `water = "river"` with no area. In
    QGIS that looks like a lookup that failed, or an area of nothing, and nothing in the file says rivers were left
    out on purpose.
  - **Fix.** Add a fourth `LEFT JOIN` on `fwa_rivers_poly` (sum of `area_ha` by key) to the coalesce, or state in
    the comment and the 0330 header that `water_ha` is blank for rivers.
  - **Rule:** none

- **[severity: fragile]** data-raw/readme_figure.R:30. The credit check passes when there is no credit.
  - **The check.** `stopifnot(nzchar(attr(basemap, "credit")))` passes when the attribute is `NULL`: `nzchar(NULL)`
    is `logical(0)`, and `stopifnot(logical(0))` passes. I ran it: it passed.
  - **Where NULL comes from.** gq's `basemap_credit()` returns `NULL`, not `""`, when neither tile set carries a
    credit (gq 0.21.0 source).
  - **Effect.** The figure is then written with no attribution: `knw_compare_map()` skips the credit strip on
    `length(credit) == 0`. The owner's 2026-11-13 decision (Esri tiles, no NOTICE row) rests on that attribution
    being drawn.
  - **Fix.** `stopifnot(is.character(attr(basemap, "credit")), length(attr(basemap, "credit")) == 1L,
    nzchar(attr(basemap, "credit")))`.
  - **Rule:** code-check.md "Zero-length, empty, and unset are three different things" ; code-check.md "A guard that
    fails toward pass"

## Checked and found sound

- CLAUDE.md's new sentences on `0330`, `GPKG=TRUE`, `STAGE=gpkg` with `TUNE_DIR=data/tune`, and `data/compare/gpkg/`
  match the code.
  - Promoted mode writes only under `data/compare/gpkg/`, its log included, and that directory is ignored (checked
    with `git check-ignore -v`).
  - The promoted run name comes from the summaries' `tune_run`. The tracked summaries name exactly one,
    `20261104_0543`.
- `knw_compare_map()` with a basemap alone (`.compare_context()` returns `NULL`, so `NULL + lay`) renders. So does a
  basemap with a scale bar, and a call on EPSG:4326 segments with a width: all three ran in a worktree.
- `gq_gpkg_style_write()` writes `layer_styles` through `sf::st_write`, so GDAL registers it in `gpkg_contents`. The
  `run` attributes table therefore does not hide the styles from QGIS.
- None of the 97 deleted `research/fig/compare_*.png` files is named anywhere outside planning/ and the logs, except
  the test that creates one on purpose.
- In `gpkg_one()`, the saved segments have no `waterbody_key` or `water` column (checked against
  `R/compare_rules.R`'s select), so the join adds no `.x`/`.y` columns.
- The new readers of `floodplain.csv` cope with its new columns. The by-key refusal on a changed header is the
  documented behaviour.
