# Map a group's segments under two rules, by grade, and its floodplain by the grade beside it

Three readings of one group for one species and stage, each as a static
figure (tmap, lakes and rivers styled through gq's registry) and, when
`html` is given, an interactive page (mapgl):

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
  labels = NULL
)
```

## Arguments

- segments:

  an `sf` in EPSG:3005 with `accessible`, `stream_order`, `grade_class`
  and the two logical rule columns `flag_default` and `flag_tuned`.

- water:

  an `sf` of lake and river polygons for the group, or `NULL`.

- title:

  `character(1)` the figure's caption line (the map carries no title;
  this goes under it).

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

## Value

Invisibly, the paths written.

## Details

Line widths follow stream order so a group's mainstem reads over its
headwaters, and the legend names every class drawn.

## Examples

``` r
if (FALSE) { # \dontrun{
knw_compare_map(seg, water, "BULK: CH rearing, default against the tuned rule",
                png = "research/fig/compare_ch_rear_bulk.png")
} # }
```
