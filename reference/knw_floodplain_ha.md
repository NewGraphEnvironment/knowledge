# Floodplain hectares beside each segment, from a catalog item's floodplain

The stac-floodplains-bc catalog publishes, per watershed group, a
whole-network floodplain (`all_ff04`) and its attribution by blue line
(`all_ff04_by_blue_line_key`): exact 30 m BC Albers cells, each blue
line claiming the cells of its own valley, so the claims overlap where
valleys meet. This rasterises `all_ff04` on that same 30 m grid (no
reprojection; the cell count times 0.09 ha reproduces the polygon's
area), takes the blue-line polygons as the claims, and gives every
floodplain cell one owner with
[`flooded::fl_valley_join()`](https://newgraphenvironment.github.io/flooded/reference/fl_valley_join.html):
the nearest segment among the claiming blue lines' segments (`nearest`,
one owner per cell, so hectares add up). Each segment's hectares are its
cells times 0.09; graded hectares are hectares times the segment's
grade, so 500 ha beside grade-0.9 habitat is 450 and the same 500 ha
beside grade-0.3 habitat is 150.

## Usage

``` r
knw_floodplain_ha(gpkg, segments, flags, scenario = "all_ff04")
```

## Arguments

- gpkg:

  `character(1)` the item's `floodplain.gpkg`.

- segments:

  an `sf` of the group's link segments in EPSG:3005 with `id_segment`,
  `blue_line_key`, logical flag columns `flags`, and `grade`.

- flags:

  `character` the logical columns (habitat under each rule,
  `accessible`) to carry; `fl_valley_join()` takes logical columns only.

- scenario:

  `character(1)` the floodplain layer and the attribution layer's
  prefix.

## Value

A list: `segments`, `segments` with `fp_ha` and `fp_graded_ha` added;
`summary`, one row per flag: hectares beside segments where the flag
holds, graded hectares, and hectares by grade class; `check`,
`fl_valley_join()`'s cell accounting plus the polygon area and the
raster's area in km².

## Details

Needs `flooded` with `nearest$seg` (flooded#89).

## Examples

``` r
if (FALSE) { # \dontrun{
seg <- sf::st_read(conn, query = "SELECT id_segment, blue_line_key, geom FROM fresh_default.streams
                                  WHERE watershed_group_code = 'LARL'")
seg$rearing_default <- ...; seg$rearing_tuned <- ...; seg$grade <- ...
fp <- knw_floodplain_ha("larl_floodplain.gpkg", seg, c("rearing_default", "rearing_tuned"))
fp$summary
} # }
```
