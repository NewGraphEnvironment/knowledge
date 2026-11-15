# Code-check round 3: #173, branch against eac16623

## Checklist read

- code-check-python.md: read in full (nothing in this diff is Python).
- code-check.md, every H3 under `## Mechanisms`, prose read (tables skipped): A guard that fails toward pass; A fixture
  that cannot reach the failure mode; A proxy is not the property; Verification that reads its own output; A guard's
  scope, escape hatches, and remedies; A fix lands in one of two callers that share a harness; Restore the bug and prove
  the guard fires; A shared working tree, and what generators leave in it; plus the index lines of the rest.
- code-check-r.md, by heading: the sections on socket workers (`clusterApply()` / `parLapplyLB`), `system.file()` and
  `load_all()`, DBI driver types, `match()` and NA, `ifelse()` with NA, `paste()` zero length, testthat counts,
  Postgres row order, `tryCatch()` nesting.
- code-check-spatial.md, by heading: GeoPackage writes (SQLite leaks, layer_styles), `st_difference()` collections,
  tmap/terra plotting, `sf` reading, BC WFS, keymap/bbox.
- code-check-shell.md: `curl -o`/HTTP status, grep-count traps (no shell in this diff beyond docs).

Ran in a detached worktree of HEAD (removed after): `test-compare_map.R` 89 pass, `test-env_flag.R` 17,
`test-tune_promote.R` 145, `test-vignette-data.R` 247 pass / 3 skip, all with 0 failed and 0 error. Read-only queries
against the local fwapg database (whose `fresh_default.log_recompute` names run `20261103_163715-269b585a`, the
published build).

## Mechanism

The three earlier findings and the one below share one shape: a set or value the code takes as given, checked on the
sample in hand (the Bulkley, the article's group), never enumerated over the population the code runs on. R1's rivers
(`fwa_rivers_poly` assumed not to be an area source) and R2's `DIST` (a concise code assumed to exist; Houston was the
one place that showed it) were both visible only from outside BULK's happy path; the guard below was proved on BULK by
`vignette_chinook.R` and by rounds 1 and 2 (BULK, LFRA, NECR), then copied to every group by `gpkg_one()`.

Every external vocabulary, source table, attribute and exported function the diff assumes, each measured:

| # | assumption | where | measured | verdict |
|---|---|---|---|---|
| 1 | `fwa_waterbodies.waterbody_type` is {L, R, W, X} | R/segment_water.R | `GROUP BY waterbody_type`: L 302,274, R 19,719, W 216,382, X 368, nothing else | holds |
| 2 | each type's area sits in its own polygon table | R/segment_water.R | every L key in lakes_poly only, R in rivers_poly only, W in wetlands_poly only, X in manmade only; 0 in none | holds; `water_ha` never NA |
| 3 | `waterbody_key` unique in `fwa_waterbodies` | R/segment_water.R | 538,743 rows, 538,743 distinct | holds |
| 4 | **every link segment's `waterbody_key` is in `fwa_waterbodies`** | scripts/0330-compare.R:408 | `fresh_default.streams`: 10 keys in 3 groups (CHWK 1, SHUL 1, REVL 8) name a waterbody in no polygon table and not in `fwa_waterbodies` (edges 1450, 1400, 1000; the same keys on `fwa_stream_networks_sp`) | **fails: finding 1** |
| 5 | grade class labels `0-0.2` ... `0.8-1` | inst/gq/compare.csv | `R/grade.R:74` cuts with `paste0(head(classes,-1), "-", classes[-1])`; `R/compare_rules.R:344` and `R/floodplain_ha.R:92` list the same five | holds |
| 6 | saved segments carry `<flag>_default`, `<flag>_tuned`, `accessible`, `grade_class` and no `waterbody_key`/`water` to collide in the join | scripts/0330-compare.R gpkg_one | `R/compare_rules.R:303-327` select list | holds |
| 7 | gq exports and signatures: `gq_qgis_style(layer_or_reg, name)`, `gq_gpkg_style_write(gpkg, layer, styles)`, `gq_reg_custom(path)`, `gq_tmap_keymap(aoi, context, corner, width, asp)` returning `map`/`viewport`, `gq_scale_breaks(bbox)`, `gq_basemap_tiles`, `gq_basemap_blend`, `gq_tmap_style`, `gq_mapgl_style` | R/compare_map.R, data-raw/readme_figure.R | all exist in installed gq 0.21.0 with those formals; on gq `main`, all but the two QGIS writers (the accepted tradeoff) | holds |
| 8 | gq registry fields `town$mark$color/stroke_color/stroke_width`, `town$label$color`, `watershed_group_boundary$stroke$color` | R/compare_map.R `.compare_context` | present in the installed registry and in gq `main`'s `inst/registry/reg_main.json` | holds |
| 9 | `gq_reg_custom()` reads every column of compare.csv and builds categorized QML on `rule_class` / `grade_class` | inst/gq/compare.csv | `.compare_qgis_styles()` ran with no warning; QML categories are the four rule labels | holds |
| 10 | tmap 4.4.1 arguments: `tm_text(xmod, ymod, angle)`, `tmap_save(insets_tm, insets_vp)`, `tm_logo(height, position)`, `tm_scalebar(breaks, text.size, position)` | R/compare_map.R | all in `formals()` | holds |
| 11 | mapgl 0.4.6 `add_scale_control(position, unit)` | R/compare_map.R | in `formals()` | holds |
| 12 | NRCan geonames: concise codes CITY, TOWN, VILG, MUN1, a comma list accepted, `items$concise$code` | data-raw/vignette_context.R | live query on the bundle's bbox: HTTP 200, 6 items (MUN1 2, TOWN 1, VILG 3); each code alone returns its subset | holds |
| 13 | data/tune's summaries name one `tune_run` | scripts/0330-compare.R promoted mode | 7 of 22 carry `20261104_0543`; 15 carry none; one run | holds |
| 14 | floodplain.csv's new run columns merge at promotion | R/tune_promote.R `.knw_rows_merge` | a header change is taken when every tracked key is promoted, refused otherwise (no partial write) | holds (safe refusal) |
| 15 | **research/fig's remaining maps are all `compare_*` ones the branch removes** | inst/NOTICE.md:10-14 | 4 FWA maps stay tracked: `chinook_rearing_tuned_{lfra,salr,twac}.png`, `setups_ch_rear_mork.png` (FWA streams and lakes drawn) | **fails: finding 2** |

## Findings

- **[severity: bug]** scripts/0330-compare.R:408 (with R/segment_water.R) — `gpkg_one()` stops a key's whole
  GeoPackage when any segment's `waterbody_key` is not in `fwa_waterbodies`. On the published build that is true in
  CHWK (key 329707206), SHUL (329534421) and REVL (eight keys): orphan keys on connector and stream lines that sit in no
  lake, wetland, river or man-made polygon. Reproduced: the function's own match logic over `fresh_default.streams`
  "would stop" for CHWK and SHUL, not for BULK. Those groups are in the habitat tables of BT, CH, CM, CO, PK, SK, ST and
  WCT, so `GPKG=TRUE` or `STAGE=gpkg` on the published run writes no GeoPackage for 8 of 11 species (only GR, KO, RB
  survive), each logged as "GeoPackage for <key> FAILED". The run itself exits 0. The check was carried over from
  `data-raw/vignette_chinook.R:334`, where it is right for BULK alone, and was verified only on BULK, LFRA and NECR. An
  orphan key should read as an unknown waterbody (`water` NA, which the popup already prints "unknown"), or be counted
  and logged, not end the key.
  - **Rule:** code-check.md "A fixture that cannot reach the failure mode" ; code-check.md "A guard's scope, escape hatches, and remedies"

- **[severity: fragile]** inst/NOTICE.md:10-14 — the Open Government Licence – British Columbia paragraph dropped "the
  maps in `research/fig/`" with the 97 comparison PNGs. Four Freshwater Atlas maps stay tracked there and are still
  shown by `research/chinook_rearing_tuned.md:615` and `research/minimal_network_tuning.md:201`:
  `chinook_rearing_tuned_{lfra,salr,twac}.png` and `setups_ch_rear_mork.png`. The Atlas's attribution no longer names
  them. This is the repo's rule that NOTICE lists each source with its files. The sentence assumed that every map in
  `research/fig/` was a comparison map; nobody listed the directory to check.
  - **Rule:** code-check.md "Documentation Staleness"
