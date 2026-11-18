# NuSEDS escapement records, each with the kind of evidence it is

Reads a NuSEDS All Areas release
([`knw_nuseds_fetch()`](https://newgraphenvironment.github.io/knowledge/reference/knw_nuseds_fetch.md))
through crate (`crate::crt_ingest("dfo", "nuseds_all_areas")`), which
reads whichever registered release shape arrives into one set of
lower-case columns, and adds `evidence_kind`. Every column NuSEDS
carries is kept as DFO wrote it: counts, presence, survey methods,
inspections, estimate method and quality, and the arrival and spawn
dates (`DD-MON-YY`, as written).

## Usage

``` r
knw_nuseds_records(path)
```

## Arguments

- path:

  `character(1)` a NuSEDS All Areas zip or CSV.

## Value

A `tibble`: crate's canonical NuSEDS columns and `evidence_kind`.

## Details

One row is one estimate (`act_id`): a population (`pop_id`) on one
stream (`gfe_id`, `waterbody_id`, `fwa_watershed_cde`) in one year. A
population can be counted on several streams in a year, so a population,
species and year is not a key; a population, stream and year is, and
both keys are checked.

`evidence_kind` says what each record shows, so a reader can tell counts
from judgements. It is decided from `adult_presence` first, then for a
present population by the first of these that holds:

- `count_expert`: a spawner or return number greater than 0, with the
  estimate method "Expert Opinion" and no survey recorded;

- `count`: a spawner or return number greater than 0;

- `presence_expert`: present by expert opinion, with no number and no
  survey recorded;

- `presence_survey`: present, with a survey method or a number of
  inspections recorded;

- `presence_unrecorded`: present, with none of the above recorded.

The other presence values give `none_observed` (NONE OBSERVED),
`not_inspected` (NOT INSPECTED) and `unknown` (UNKNOWN or blank). A
survey is recorded where `enumeration_methods` or `no_inspections_used`
is filled; the number is the larger of `natural_adult_spawners` and
`total_return_to_river`.

## Examples

``` r
f <- system.file("extdata/examples/dfo/nuseds_all_areas_2026-06-01.csv", package = "crate")
if (nzchar(f)) {
  x <- knw_nuseds_records(f)
  table(x$evidence_kind)
  x[x$waterbody == "MAXAN CREEK" & x$evidence_kind != "not_inspected",
    c("analysis_yr", "evidence_kind", "total_return_to_river", "enumeration_methods")]
}
#> # A tibble: 6 × 4
#>   analysis_yr evidence_kind   total_return_to_river enumeration_methods
#>         <int> <chr>                           <dbl> <chr>              
#> 1        1986 none_observed                      NA NA                 
#> 2        1988 count                              50 Walk               
#> 3        1993 count                              20 Helicopter         
#> 4        2003 presence_survey                    NA Helicopter         
#> 5        2007 none_observed                      NA NA                 
#> 6        2008 presence_expert                    NA NA                 
```
