## Outcome

Backlog move 4 (#173), batch 6 (#81, #77). The plan review measured batch 6 alone as one PR, so batch 7 (the template,
the generator and the chinook rearing page) was split to #211 on Al's word.

- **The comparison (`scripts/0330`) draws no maps.** It writes GeoPackages only with `GPKG=TRUE`.
- **The floodplain table is its own step** (`STAGE=floodplain`), and every row now names its run, link commit and tuned
  rule.
- **`STAGE=gpkg` also reads the promoted run** (`TUNE_DIR=data/tune`), so the published comparison opens in QGIS
  without a promotion.
- **Each GeoPackage carries more:** each segment's rule class, the waterbody it runs through and that waterbody's area,
  a `run` table, and QGIS styles. The styles come from the gq registry the maps read (`inst/gq/compare.csv`). gq had no
  writer for a custom layer's QML, so one was built in gq first (gq#115, gq PR #118, not merged at this archive).
- **`knw_compare_map()` gains opt-in context:** a canvas of the window's shape, scale bar, keymap, towns and rivers
  named over a halo, a basemap with its credit in a strip, a logo and corners. At its defaults it draws byte for byte
  as before.
- **The README figure** draws it all over Esri's topographic map with shaded relief, with Esri's attribution on the map
  and no NOTICE row (Al, 2026-11-13).
- **The chinook article** draws it without a basemap (it is built without network), and its site map gains a scale bar.
- **97 comparison PNGs that nothing showed were removed.** The list is in `findings.md`.

What was learned:

- gq could not style a layer outside its own registry.
- The Province's town layers are "Access Only", so the towns come from NRCan's Canadian Geographical Names (Open
  Government Licence – Canada).
- Five review rounds found a defect in each of the first four, all from one habit: checking a set on the Bulkley and
  applying it province-wide.

## Measurement

- **Default renders unchanged:** the README panel and the three-panel figure render byte-identical before and after
  the new arguments (md5 518187… and d5d3fb…), with the baseline taken after the gq 0.16.1 → 0.21.0 upgrade.
- **GeoPackage writer on BULK** (`fresh_default_20261023`, the schema the main checkout's older segments match):
  87,640 segments, rule classes kept 4,081, lost 2,619, gained 875, neither 9,111, and 70,954 unreachable left
  unclassed (the first try classed those as neither). Both QGIS styles were read back.
- **Waterbody areas:** every river waterbody had none until `fwa_rivers_poly` was joined (115 of 115 in BULK). The
  published `fresh_default` carries 10 waterbody keys, on 17 segments in CHWK, REVL and SHUL, that
  `fwa_waterbodies` lacks. Before round 3's fix they would have dropped the GeoPackage for 8 of 11 species. They are
  now counted as unknown (CHWK trial: 14,346 segments, 1 unknown).
- **Province outline for the keymap:** the merged watershed groups kept 143,676 vertices (3.4 MB) until only their
  exterior rings were kept. The bundle is now 39 KB.
- **Towns:** NRCan has no `DIST` code; district municipalities are `MUN1`. Hazelton and New Hazelton are 5.8 km apart
  and their names collide at the README's scale, so a town within 8 km of a higher-ranked one is not labelled.
- **README figure:** checked at 600 px (5 in at 150 dpi, shown at 70 % of the column). The first 6 in canvas left
  river names and scale-bar numbers unreadable.
- **Validation:** full suite `[ FAIL 0 | WARN 0 | SKIP 4 | PASS 2361 ]`; the site built all three articles.
  `/code-check branch` ran five rounds (3, 2, 2, 1, 0 findings) and none found a defect inside an earlier fix.

## Evidence

The review rounds and the plan review are in this directory, `review-*.md`. No run logs: `0330` was not run, and its
GeoPackage writer was exercised by scratch harnesses on two groups.

## Owed

- Merge and release gq PR #118 (gq#115, on Al's word), then set `gq (>= <that release>)` in DESCRIPTION. Until then a `GPKG=TRUE` run refuses at startup on a gq without the writer, and the style test skips.
- Tick #81's and #77's tasks (`/gh-pr-merge` 3b)

Closed by: the PR for branch `173-backlog-move-4-comparison-maps-out-of-th`
