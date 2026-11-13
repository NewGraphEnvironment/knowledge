# Findings — Backlog move 4: Comparison maps out of the run, and one generated research page per key (#173)

## Issue context

**If we do it:** a comparison run writes tables (and GeoPackages only when asked), the few example maps carry a scale bar and keymap, and each species × stage has one generated page in one template. **If we never do:** comparisons keep spending hours on GeoPackages nobody opens, the maps cannot be placed by a stranger, and the research files stay eight shapes with hand-copied numbers and stale figures.

### Batch 6. Maps out of the comparison
- **Why here:** both edit `R/compare_map.R` and the example-map script #81 creates; #77's scale bar and keymap apply to exactly those maps.
- **Touches:** `scripts/0330-compare.R` (`GPKG` opt-in), `R/compare_map.R`, a new example-map script, `data-raw/readme_figure.R`, a gq style for the GeoPackage.
- **Decided at the gate:** `GPKG` off by default; which `research/fig/` PNGs no file shows.

| issue | title |
|---|---|
| #81 | Separate map making from the comparison: GeoPackages for QGIS, a few scripted examples |
| #77 | knw_compare_map: no scale bar or keymap on the static maps |

### Batch 7. One research page per key
- **Why here:** #90's fixed skeleton and #64's per-species order are one template; one generator writes every page from the tables.
- **Touches:** `research/tuning/`, `research/README.md`, `data-raw/tuning_reports.R`, `research/fig/` (removals).
- **Decided at the gate:** the one template (reconcile #90's headings with #64's order); which keys get pages now.

| issue | title |
|---|---|
| #90 | Tuning reports in research/tuning/, generated from the tables, with their figures |
| #64 | One template per species: life-history prior, evidence, recommendation, what it draws, left open |

Runs after move 2, which renames the article #77 turns the scale bar on in.


---

Backlog: `planning/backlog.md`, move 4. Plan it with `/planning-init <this issue>`: one phase per batch, one PR. If the plan finds that a batch, or one of its members, is more than one PR's work, it carries the first piece and files each other piece as its own issue, its body naming this move as where it was split from, and leaves it out of `planning/backlog.md`: the next `/backlog-sweep` reads an issue the file does not name as unplaced, and folds it into a move other than the one it was split from (a sweep run before that move merges would otherwise put it back in, and the merge would tick it undone). Split rather than take it all in one PR.

## Exploration at the gate (2026-11-12)

- `0330` already splits its stages: `STAGE=maps` draws the floodplain table, the static PNGs and the HTML pages
  together; `STAGE=gpkg` writes the GeoPackages alone; `GPKG` defaults to on (`!identical(Sys.getenv("GPKG"), "FALSE")`).
- `knw_tune_promote()` promotes `research/fig/compare_<key>_*.png` from a candidate's `fig/` (`R/tune_promote.R:305`).
- research/fig/: 102 PNGs. Embedded by name: `chinook_rearing_tuned_{curves,salr,twac,lfra}.png`
  (`research/chinook_rearing_tuned.md`), `setups_ch_rear_mork.png` (`research/minimal_network_tuning.md`). The 97
  `compare_*.png` are named in `scripts/logs/habitat/2026101{7,9}_compare*.out`, in `test-tune_promote.R` fixtures, in
  `R/compare_map.R`'s roxygen example (`compare_ch_rear_bulk.png`), and by glob lines in bull_trout, chinook, coho,
  habitat_thresholds, rainbow, steelhead and westslope_cutthroat `_tuned.md`.
- Keys: 22 summaries in `data/tune/`; 7 have a grade record (BT rear, BT spawn, CH, CO, GR, ST, WCT rear).
- Saved segments (ignored) exist in the main checkout: `../knowledge/data/compare/{BT_rear,BT_spawn,CH_rear,CO_rear,GR_rear,RB_rear,ST_rear,WCT_rear}_segments.rds`.
- gq installed 0.16.1, latest 0.21.0; it exports `gq_tmap_keymap(aoi, context, reg, aoi_layer, context_layer, corner, ...)`,
  `gq_style_qml(layer_key, template)`, `gq_basemap_tiles()`, `gq_basemap_blend(base, relief, method, ...)` at 0.16.1.
- The chinook article draws its static map only off-site (`eval = !on_site`); on the site it is `knw_compare_mapgl()`.
- #79 (interactive map fixes) is closed.

## Errors Encountered

| Error | Resolution |
|-------|------------|
