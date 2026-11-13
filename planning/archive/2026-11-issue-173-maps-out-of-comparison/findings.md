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
- gq was 0.16.1; upgraded to 0.21.0 on 2026-11-13 (`github::NewGraphEnvironment/gq@9d59aba`). Signatures at 0.21.0:
  `gq_tmap_keymap(aoi, context, reg, aoi_layer = "watershed_group_boundary", context_layer, corner, width, height, asp, margin)`,
  `gq_basemap_tiles(bbox, provider = "Esri.WorldGrayCanvas", zoom = 12, pad = 0.1, crs = 3005)`,
  `gq_basemap_blend(base, relief, method = c("gamma", "weight"), ...)`, `gq_reg_custom(path)`, `gq_reg_merge(..., csv, priority)`.
- `gq_style_qml(layer_key, template)` returns the path of a QML gq ships for its own layer keys and errors on any
  other key. No gq export writes a QML from a registry entry, so a custom layer (the comparison's rule and grade
  classes) cannot get a QGIS style through gq. Filed as gq#115; Al chose to build it in gq first (2026-11-13).
- The chinook article draws its static map only off-site (`eval = !on_site`); on the site it is `knw_compare_mapgl()`.
- #79 (interactive map fixes) is closed.

## Plan review (2026-11-13, `review-plan.md`)

Checked before acting:
- `0330` reads only `TUNE_DIR=data/tune/candidate/<run>` (`scripts/0330-compare.R:100-104`), so neither on-demand stage
  can run on the promoted run: confirmed.
- `data/compare/floodplain.csv` was last written by #65 (4534f404, 2026-10-19). The #145 promotion (91ae2f5d) only
  deleted 69 rows, so the chinook rows are from the superseded rule: confirmed.
- The saved segments already carry `knw_size` (flow), `channel_width`, `gradient`, `knw_dist`, `stream_order`,
  `link_branch` and `user_habitat`; they lack the rule class and the waterbody area (#81 task 5).

Outcome: Al cut the PR to batch 6 (2026-11-13); batch 7 goes to a split-off issue.

## The GeoPackage writer on one group (2026-11-13)

The main checkout's ignored grade tables and segments are #73/#92's (CH grades md5 e37f76ea…, segments 2026-10-24), not
the promoted run `20261104_0543` (grades_md5 d35d785f…). So `STAGE=gpkg` on the promoted run cannot be run here without
`PULL=TRUE scripts/0336-archive.R`. The old segments match `fresh_default_20261023` (87,640 of 87,641 BULK segments), so
the new `gpkg_one()` was run on BULK against that schema through a scratch harness that evaluates the function from the
script (scratchpad `gpkg_try.R`): 87,640 segments; `rule_class` kept 4,081, lost 2,619, gained 875, accessible-neither
9,111, unreachable 70,954 left NA (the first try classed those as neither: fixed); `water` stream 77,883, wetland 5,066,
lake 2,556, river 2,135, with the 59.5 ha wetland of #81's Coffin Creek note on segments 85470 and 85475; a `run` table.

## research/fig/ removals (2026-11-13)

Recomputed at removal: each PNG's name grepped (`git grep -F`) over research/, vignettes/, README.md and data-raw/.
Shown, kept (5): chinook_rearing_tuned_curves.png, chinook_rearing_tuned_lfra.png, chinook_rearing_tuned_salr.png, chinook_rearing_tuned_twac.png, setups_ch_rear_mork.png.
Shown by nothing, removed (97):

- `compare_bt_rear_bowr.png`
- `compare_bt_rear_bulk.png`
- `compare_bt_rear_dunc.png`
- `compare_bt_rear_fran.png`
- `compare_bt_rear_kisp.png`
- `compare_bt_rear_kotl.png`
- `compare_bt_rear_larl.png`
- `compare_bt_rear_lchl.png`
- `compare_bt_rear_lhaf.png`
- `compare_bt_rear_lmus.png`
- `compare_bt_rear_lnth.png`
- `compare_bt_rear_mcgr.png`
- `compare_bt_rear_mork.png`
- `compare_bt_rear_morr.png`
- `compare_bt_rear_natr.png`
- `compare_bt_rear_necr.png`
- `compare_bt_rear_pars.png`
- `compare_bt_rear_pcea.png`
- `compare_bt_rear_pine.png`
- `compare_bt_rear_sloc.png`
- `compare_bt_rear_tabr.png`
- `compare_bt_rear_thom.png`
- `compare_bt_rear_ufra.png`
- `compare_bt_rear_unth.png`
- `compare_bt_rear_will.png`
- `compare_bt_spawn_bowr.png`
- `compare_bt_spawn_bulk.png`
- `compare_bt_spawn_dunc.png`
- `compare_bt_spawn_fran.png`
- `compare_bt_spawn_kisp.png`
- `compare_bt_spawn_kotl.png`
- `compare_bt_spawn_larl.png`
- `compare_bt_spawn_lchl.png`
- `compare_bt_spawn_lnth.png`
- `compare_bt_spawn_ltre.png`
- `compare_bt_spawn_mcgr.png`
- `compare_bt_spawn_mork.png`
- `compare_bt_spawn_morr.png`
- `compare_bt_spawn_necr.png`
- `compare_bt_spawn_pars.png`
- `compare_bt_spawn_pcea.png`
- `compare_bt_spawn_pine.png`
- `compare_bt_spawn_sloc.png`
- `compare_bt_spawn_tabr.png`
- `compare_bt_spawn_thom.png`
- `compare_bt_spawn_uden.png`
- `compare_bt_spawn_ufra.png`
- `compare_bt_spawn_unth.png`
- `compare_bt_spawn_will.png`
- `compare_ch_rear_bowr.png`
- `compare_ch_rear_bulk.png`
- `compare_ch_rear_fran.png`
- `compare_ch_rear_kisp.png`
- `compare_ch_rear_lchl.png`
- `compare_ch_rear_lnth.png`
- `compare_ch_rear_lsal.png`
- `compare_ch_rear_mcgr.png`
- `compare_ch_rear_mork.png`
- `compare_ch_rear_morr.png`
- `compare_ch_rear_necr.png`
- `compare_ch_rear_ques.png`
- `compare_ch_rear_tabr.png`
- `compare_ch_rear_thom.png`
- `compare_ch_rear_ufra.png`
- `compare_ch_rear_unth.png`
- `compare_ch_rear_vict.png`
- `compare_ch_rear_will.png`
- `compare_co_rear_bowr.png`
- `compare_co_rear_bulk.png`
- `compare_co_rear_chwk.png`
- `compare_co_rear_grai.png`
- `compare_co_rear_guic.png`
- `compare_co_rear_kisp.png`
- `compare_co_rear_lchl.png`
- `compare_co_rear_lnth.png`
- `compare_co_rear_morr.png`
- `compare_co_rear_necr.png`
- `compare_co_rear_thom.png`
- `compare_co_rear_unth.png`
- `compare_co_rear_will.png`
- `compare_gr_rear_atll.png`
- `compare_gr_rear_pars.png`
- `compare_gr_rear_pcea.png`
- `compare_gr_rear_pine.png`
- `compare_st_rear_bulk.png`
- `compare_st_rear_grai.png`
- `compare_st_rear_kisp.png`
- `compare_st_rear_morr.png`
- `compare_st_rear_pori.png`
- `compare_st_rear_seym.png`
- `compare_st_rear_thom.png`
- `compare_wct_rear_dunc.png`
- `compare_wct_rear_ketl.png`
- `compare_wct_rear_khor.png`
- `compare_wct_rear_kotl.png`
- `compare_wct_rear_larl.png`
- `compare_wct_rear_sloc.png`

## Errors Encountered

| Error | Resolution |
|-------|------------|
| A python span edit of `0330` anchored on the header line that shares the function comment's opening words, and deleted most of the script | `git restore`, then edits through `edit0330.py`, which refuses an anchor that is not unique |
