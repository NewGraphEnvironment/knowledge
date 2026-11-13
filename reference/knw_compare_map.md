# Map a group's segments under two rules, by grade, and its floodplain by the grade beside it

Three readings of one group for one species and stage, each as a static
figure (tmap, lakes and rivers styled through gq's registry) and, when
`html` is given, an interactive page
([`knw_compare_mapgl()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_mapgl.md),
saved self-contained):

- **rules**: accessible segments coloured kept (habitat under both
  rules), lost (`default` only), gained (tuned only), neither;

- **grade**: accessible segments shaded by grade class;

- **floodplain**: the floodplain cells shaded by the grade of the
  segment that owns them (`fp_cells`, from
  [`knw_floodplain_ha()`](https://newgraphenvironment.github.io/knowledge/reference/knw_floodplain_ha.md)'s
  join), where given.

## Usage

``` r
knw_compare_map(
  segments,
  water = NULL,
  title = "",
  png = NULL,
  html = NULL,
  fp_cells = NULL,
  ncol = NULL,
  panels = c("rules", "grade", "floodplain"),
  mark = NULL,
  lwd = 1,
  legend = TRUE,
  labels = NULL,
  background = c("voyager", "openfreemap", "esri_topo"),
  width = NULL,
  scalebar = FALSE,
  keymap = NULL,
  places = NULL,
  basemap = NULL,
  logo = NULL,
  corners = c(legend = "bottomleft", scalebar = "bottomright", keymap = "topright", logo
    = "topleft")
)
```

## Arguments

- segments:

  an `sf` in EPSG:3005 with `accessible`, `stream_order`, `grade_class`
  and the two logical rule columns `flag_default` and `flag_tuned`.

- water:

  an `sf` of lake and river polygons for the group, or `NULL`.

- title:

  `character(1)` names the figure in the message when nothing is drawn,
  and is the interactive page's title and legend title; the static
  figure draws no title (that belongs in the caption).

- png:

  `character(1)` path for the static figure, or `NULL`: one panel for
  each of `panels` that can be drawn (`"floodplain"` needs `fp_cells`),
  `ncol` to a row.

- html:

  `character(1)` path for the interactive page, or `NULL`.

- fp_cells:

  `NULL`, or a `SpatRaster` of grade per floodplain cell.

- ncol:

  `integer(1)` panels per row in the static figure, or `NULL` for all
  panels side by side; each panel is 4 in by 4.6 in, so `ncol = 1`
  stacks them for a narrow column.

- panels:

  `character` which static panels to draw, any of `"rules"`, `"grade"`
  and `"floodplain"` (drawn only where `fp_cells` is given).

- mark:

  `NULL`, or an `sf` polygon outlined on every static panel, such as the
  window of a zoomed map drawn by a second call on cropped segments.

- lwd:

  `numeric(1)` multiplier on the static panels' line widths, for a
  zoomed window where stream-order widths read too thin.

- legend:

  `logical(1)` draw the static panels' legends; `FALSE` for a zoomed
  panel beside an overview that carries them.

- labels:

  `NULL`, or an `sf` of points with a `label` column, drawn as numbered
  markers on every static panel (examples a table beside the map
  describes).

- background:

  passed to
  [`knw_compare_mapgl()`](https://newgraphenvironment.github.io/knowledge/reference/knw_compare_mapgl.md)
  for the interactive page.

- width:

  `NULL`, or `numeric(1)` inches: draw one panel on a canvas of that
  width whose height follows the window's shape (the group's outline,
  `keymap$aoi`, where given, else the segments), so the map fills its
  frame. The arguments below need it; with all of them at their defaults
  the figure is drawn as before.

- scalebar:

  `logical(1)` draw a scale bar, its breaks from
  [`gq::gq_scale_breaks()`](https://newgraphenvironment.github.io/gq/reference/gq_scale_breaks.html).

- keymap:

  `NULL`, or a list of two `sf` polygons, `aoi` (the area mapped, also
  outlined on the map) and `context` (the region around it, such as the
  province), drawn as an inset by
  [`gq::gq_tmap_keymap()`](https://newgraphenvironment.github.io/gq/reference/gq_tmap_keymap.html).

- places:

  `NULL`, or a list with `towns` (an `sf` of points with a `label`
  column, marked and named in gq's `town` style) and `rivers` (an `sf`
  of points with `label` and `angle` columns, named in blue italic along
  the river), each name over a white halo.

- basemap:

  `NULL`, or an RGB raster (`stars`, as
  [`gq::gq_basemap_blend()`](https://newgraphenvironment.github.io/gq/reference/gq_basemap_blend.html)
  returns it) drawn under everything; its `"credit"` attribute is
  printed along the bottom of the map.

- logo:

  `NULL`, or the path of a square PNG drawn as a logo.

- corners:

  named `character`: the corner of each of `legend`, `scalebar`,
  `keymap` and `logo`, each in its own (`"bottomleft"`, `"bottomright"`,
  `"topleft"`, `"topright"`).

## Value

Invisibly, the paths written.

## Details

Line widths follow stream order so a group's mainstem reads over its
headwaters, and the legend names every class drawn.

## Examples

``` r
if (FALSE) { # \dontrun{
knw_compare_map(seg, water, "BULK: CH rearing, default against the tuned rule",
                png = tempfile(fileext = ".png"))
} # }
```
