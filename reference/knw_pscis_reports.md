# Past reports referenced by PSCIS records

One row per distinct (`pscis_layer`, `ecocat_url`, consultant, year),
with the number of crossings each report covers and the EcoCat
`report_id` parsed from the URL. Layers without an `ecocat_url` column
are skipped. The stored URL is sometimes wrong for the crossing, so
treat the result as leads to verify rather than an inventory.

## Usage

``` r
knw_pscis_reports(layers)
```

## Arguments

- layers:

  Named `list` of `sf` or `data.frame` PSCIS layers, as returned by
  [`knw_pscis_pull()`](https://newgraphenvironment.github.io/knowledge/reference/knw_pscis_pull.md).

## Value

A `tibble` with `pscis_layer`, `ecocat_url`, `consultant`, `year`,
`n_crossings`, `report_id`.

## Examples

``` r
layers <- list(assessment = data.frame(
  stream_crossing_id = c(1L, 2L, 3L),
  ecocat_url = c("https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=100",
                 "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=100",
                 NA),
  consultant_name = "Someone", assessment_date = as.Date("2015-08-01")))
knw_pscis_reports(layers)
#> # A tibble: 1 × 6
#>   pscis_layer ecocat_url                  consultant  year n_crossings report_id
#>   <chr>       <chr>                       <chr>      <dbl>       <int> <chr>    
#> 1 assessment  https://a100.gov.bc.ca/pub… Someone     2015           2 100      
```
