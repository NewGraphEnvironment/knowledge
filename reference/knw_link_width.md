# The channel width link reads on a stream nobody measured, and the waterbody tests

`scripts/0296`'s width. link joins
`whse_basemapping.fwa_stream_networks_channel_width` province-wide, and
its `FIELD_MEASURMENT` rows are FDIS sites, so at a visit the stored
width can be that visit's own measurement, which link never sees on the
unmeasured streams it classifies. So fwapg's own width model (upstream
area and upstream mean annual precipitation, Thorley and Irvine 2021b)
is recomputed here for the segments' watershed codes, and `cw_deploy` is
the width link would read with no field measurement: the stored width
unless it is `FIELD_MEASURMENT`, then the model where `stream_order > 1`
(fwapg models no order-1 stream) and `NA` otherwise. The recomputed
model must match the stored `MODELLED` widths within `tol` (relative) on
at least `agree_min` of them, or the call stops: the stored widths come
from older inputs, and a larger disagreement means the formula or its
inputs have changed.

## Usage

``` r
knw_link_width(
  conn,
  linear_feature_id,
  tol = 0.05,
  agree_min = 0.95,
  wetland_ha_min = 1,
  lake_ha_min = 100
)
```

## Arguments

- conn:

  a `DBI` connection to a database holding `whse_basemapping`.

- linear_feature_id:

  `numeric` FWA segment ids.

- tol, agree_min:

  `numeric(1)` the model-agreement control.

- wetland_ha_min, lake_ha_min:

  `numeric(1)` link `default`'s area floors.

## Value

A list: `widths`, one row per segment (`linear_feature_id`,
`fwa_waterbody_key`, `fwa_channel_width`, `fwa_cw_source`,
`fwa_stream_order`, `cw_model`, `cw_deploy`, `wb_river`, `wb_wetland`,
`wb_lake`, `wb_any_lake`); `control`, a one-row `data.frame` with
`n_modelled`, `agree_share` and `median_ratio`.

## Details

Alongside the width, the waterbody tests of link's `default` rules:
whether the segment's `waterbody_key` is a river polygon, a wetland of
at least `wetland_ha_min`, or a lake or man-made waterbody of at least
`lake_ha_min`.

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(RPostgres::Postgres())
knw_link_width(conn, c(701747495, 701747496))$widths
} # }
```
