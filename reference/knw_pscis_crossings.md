# Crossings table from the PSCIS assessment layer

Assessment records with WGS84 coordinates, the watershed group stamped
on, and flags for presence in the confirmation, design and remediation
phases.

## Usage

``` r
knw_pscis_crossings(layers, wsg_code)
```

## Arguments

- layers:

  Named `list` of `sf` or `data.frame` PSCIS layers, as returned by
  [`knw_pscis_pull()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_pull.md).

- wsg_code:

  `character(1)` watershed group code to stamp on every row.

## Value

A `tibble`, or `NULL` when there is no non-empty assessment layer.

## Examples

``` r
pts <- sf::st_sf(
  stream_crossing_id = c(10L, 11L),
  assessment_date = as.Date(c("2015-08-01", "2016-08-01")),
  geometry = sf::st_sfc(sf::st_point(c(1200000, 1000000)),
                        sf::st_point(c(1200500, 1000500)), crs = 3005))
knw_pscis_crossings(list(assessment = pts,
                         design = data.frame(stream_crossing_id = 11L)), "PINE")
#> # A tibble: 2 × 8
#>   stream_crossing_id assessment_date   lon   lat watershed_group_code
#>                <int> <date>          <dbl> <dbl> <chr>               
#> 1                 10 2015-08-01      -123.  54.0 PINE                
#> 2                 11 2016-08-01      -123.  54.0 PINE                
#> # ℹ 3 more variables: has_confirmation <lgl>, has_design <lgl>,
#> #   has_remediation <lgl>
```
