# Drop the FDIS site visits that cannot carry evidence, and count every drop

The quality drops `scripts/0290` and `0294` applied to `0230`'s site
table, in that order: a visit not placed on the FWA network, a pick
beyond its placement limit (see
[`knw_fdis_place()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fdis_place.md)),
an FDIS 1:50k watershed code that names no stream within the snap
search, a junk date, a sentinel effort or no effort at all (a visit with
only one of area and time is kept, so a model can use either), and a
catch whose status is unknown (neither fish nor an explicit zero). Each
drop is one ledger row, and the drops and the kept rows partition the
input, which the function asserts.

## Usage

``` r
knw_fdis_quality(sites)
```

## Arguments

- sites:

  `data.frame` of site visits as `0230` builds them, with the flag
  columns `flag_not_placed`, `flag_far_snap`, `flag_ws50_mismatch`,
  `flag_junk_date`, `flag_effort_sentinel`, `flag_no_area`,
  `flag_no_effort` and `catch_status`.

## Value

A list: `kept`, the visits that pass, and `ledger`, a `tibble` with
columns `kind` (`in`, `drop`, `kept`, `info`), `step`, `n` and `note`.
Where `sites` carries `0230`'s `snap_confirmed` and `snap_moved`, two
`info` rows count the kept visits confirmed by their 1:50k code and
those moved to a named stream that is not the nearest; they are not part
of the partition.

## Examples

``` r
sites <- data.frame(
  site_visit = c("a", "b", "c"),
  flag_not_placed = c(FALSE, TRUE, FALSE), flag_far_snap = FALSE,
  flag_ws50_mismatch = c(FALSE, FALSE, NA), flag_junk_date = FALSE,
  flag_effort_sentinel = FALSE, flag_no_area = c(FALSE, FALSE, TRUE),
  flag_no_effort = c(FALSE, FALSE, TRUE), catch_status = "fish"
)
q <- knw_fdis_quality(sites)
q$kept$site_visit
#> [1] "a"
q$ledger
#> # A tibble: 8 × 4
#>   kind  step                        n note                                      
#>   <chr> <chr>                   <int> <chr>                                     
#> 1 in    visits_in                   3 ""                                        
#> 2 drop  not_placed                  1 "not placed on the FWA network"           
#> 3 drop  far_snap                    0 "snapped beyond the placement limit (one …
#> 4 drop  ws50_mismatch               0 "FDIS 1:50k watershed code names no strea…
#> 5 drop  junk_date                   0 ""                                        
#> 6 drop  effort_sentinel_or_none     1 "sentinel effort, or neither fished area …
#> 7 drop  catch_unknown               0 "catch neither fish nor an explicit zero" 
#> 8 kept  visits_kept                 1 ""                                        
```
