# The interactive map of a group's segments under two rules

The page
[`knw_compare_map()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_map.md)
saves when given `html`, as a mapgl widget to print in an R Markdown
page or save: accessible segments coloured by rule (kept by both, lost,
gained, neither) and, on a second layer the switch at the top right
turns on, by grade class, each with its legend at the top left; lakes
and rivers styled through gq's registry where it loads. Clicking a
segment opens a popup with the fields it carries among the stream order,
grade, mean annual flow (`mad`), channel width, gradient, the walk
distance to the rule's river (`dist_m`), the waterbody it lies in
(`water`, `water_ha`), and each rule's verdict, saying where the
hand-entered reaches or the step that keeps rearing only where it
connects to spawning changed it (`pre_default`, `pre_tuned`, the verdict
from the habitat test alone).

## Usage

``` r
knw_compare_mapgl(
  segments,
  water = NULL,
  title = "",
  background = c("voyager", "openfreemap", "esri_topo"),
  digits = 5L,
  scale = FALSE
)
```

## Arguments

- segments:

  an `sf` in EPSG:3005 with `accessible`, `stream_order`, `grade_class`
  and the two logical rule columns `flag_default` and `flag_tuned`.

- water:

  an `sf` of lake and river polygons for the group, or `NULL`.

- title:

  `character(1)` the rules legend's title.

- background:

  `"voyager"` (Carto Voyager), `"openfreemap"` (OpenFreeMap Liberty) or
  `"esri_topo"` (Esri's World Topographic Map raster tiles, keyless;
  Esri allows free noncommercial use with attribution, which the map
  shows).

- digits:

  `integer(1)` decimal places kept in the coordinates.

- scale:

  `logical(1)` add a metric scale bar at the bottom left (#77).

## Value

A `maplibregl` htmlwidget, or `NULL` with a message when no segment is
accessible.

## Details

Coordinates are rounded to `digits` decimal degrees after the transform
to EPSG:4326 (5 is about 1 m), and only the drawn and popup fields are
kept, which sets the page's size.

## Examples

``` r
if (requireNamespace("mapgl", quietly = TRUE)) {
  seg <- sf::st_sf(
    accessible = TRUE, stream_order = 1:3, grade_class = c("0-0.2", "0.8-1", NA),
    flag_default = c(TRUE, TRUE, FALSE), flag_tuned = c(TRUE, FALSE, TRUE), mad = c(0.4, 2.1, 0.1),
    geometry = sf::st_sfc(lapply(0:2, function(i) {
      sf::st_linestring(rbind(c(1e6 + i * 500, 1e6), c(1e6 + (i + 1) * 500, 1e6 + 300)))
    }), crs = 3005)
  )
  m <- knw_compare_mapgl(seg, title = "Habitat definition")
  class(m)
}
#> [1] "maplibregl" "htmlwidget"
```
