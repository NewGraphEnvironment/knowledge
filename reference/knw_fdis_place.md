# Pick each FDIS site visit's stream from the nearest snap and the streams its 1:50k code names

`scripts/0230` snaps every visit twice with
[`fresh::frs_point_snap()`](https://newgraphenvironment.github.io/fresh/reference/frs_point_snap.html):
once to the nearest stream, and once to each stream its FDIS 1:50k
watershed code names (the code's 20k `blue_line_key`s from
`fwa_streams_20k_50k`, passed as a hint, so that snap can land only on
that stream). This function makes the pick from the two results, with no
database.

## Usage

``` r
knw_fdis_place(nearest, hinted, limit_near = 200, limit_code = 500)
```

## Arguments

- nearest:

  `data.frame`, one row per visit to place: `site_visit`,
  `blue_line_key`, `downstream_route_measure`, `linear_feature_id`,
  `distance_to_stream`, with the four position columns missing where no
  stream lies within the search.

- hinted:

  `data.frame`, one row per visit and stream its code names:
  `site_visit`, `hint_blue_line_key` (the stream named) and the four
  position columns of the hinted snap, missing where that stream is not
  within the search. A visit with no row here has no code the
  cross-reference knows. Every `site_visit` must be in `nearest`.

- limit_near:

  `numeric(1)` metres: an unconfirmed pick farther than this is flagged
  `flag_far_snap`.

- limit_code:

  `numeric(1)` metres: a confirmed pick farther than this is flagged
  `flag_far_snap`.

## Value

A `tibble`, one row per row of `nearest` in its order: `site_visit`,
`blue_line_key`, `downstream_route_measure`, `linear_feature_id`,
`distance_to_stream` (the pick's), `snap_method` (`code`, `nearest`, or
`NA` when not placed), `snap_confirmed`, `snap_moved`,
`nearest_distance_m`, `ws50_checked` (the visit has a code the
cross-reference knows), `flag_not_placed`, `flag_far_snap` and
`flag_ws50_mismatch`. `integer64` columns are refused: convert them with
[`as.numeric()`](https://rdrr.io/r/base/numeric.html) first, as `0230`
does.

## Details

A visit whose code names a stream within the search takes the nearest
such stream (`snap_method = "code"`, `snap_confirmed = TRUE`): the
placement is on a stream the code names, which is what `0230`'s check
has always asked. Where that stream is not the nearest one, the visit is
moved to it (`snap_moved`). A visit with no code the cross-reference
knows takes the nearest stream (`snap_method = "nearest"`, unconfirmed).
A visit whose code names streams none of which lies within the search
keeps the nearest placement and is flagged `flag_ws50_mismatch`: the
code contradicts every stream in reach, so there is nothing to move it
to.

A confirmed pick and an unconfirmed one are held to different limits,
because distance predicts a wrong stream only where nothing names the
stream: `flag_far_snap` marks an unconfirmed pick beyond `limit_near`
and a confirmed one beyond `limit_code`. Ties in distance go to the
lowest `linear_feature_id`, as in `frs_point_snap()`.

The default limits are the ones `0230` uses, set by
`data-raw/snap_limit_sensitivity.R` (#91): 200 m, the widest distance
band whose code-checked disagreement stays under one in three, for an
unconfirmed pick, and the 500 m search radius for a confirmed one.

## Examples

``` r
nearest <- data.frame(
  site_visit = c("a", "b", "c"),
  blue_line_key = c(1, 1, 2), downstream_route_measure = c(10, 50, 5),
  linear_feature_id = c(11, 12, 21), distance_to_stream = c(4, 30, 150)
)
# b's code names stream 3, 60 m away; c's code names stream 2, its nearest
hinted <- data.frame(
  site_visit = c("b", "c"), hint_blue_line_key = c(3, 2),
  blue_line_key = c(3, 2), downstream_route_measure = c(80, 5),
  linear_feature_id = c(31, 21), distance_to_stream = c(60, 150)
)
knw_fdis_place(nearest, hinted, limit_near = 100, limit_code = 500)
#> # A tibble: 3 × 13
#>   site_visit blue_line_key downstream_route_measure linear_feature_id
#>   <chr>              <dbl>                    <dbl>             <dbl>
#> 1 a                      1                       10                11
#> 2 b                      3                       80                31
#> 3 c                      2                        5                21
#> # ℹ 9 more variables: distance_to_stream <dbl>, snap_method <chr>,
#> #   snap_confirmed <lgl>, snap_moved <lgl>, nearest_distance_m <dbl>,
#> #   ws50_checked <lgl>, flag_not_placed <lgl>, flag_far_snap <lgl>,
#> #   flag_ws50_mismatch <lgl>
```
