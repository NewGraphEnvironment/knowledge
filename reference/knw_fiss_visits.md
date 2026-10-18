# Fish Data Submission workbook sites as visits, with the effort they recorded

The FDIS export covers electrofishing to about 2022; the workbooks
`0220` parses cover later years and other methods (issue \#23). `0250`
already dedupes their fish against the export and writes
`data/fiss_evidence.csv` at the site × species × size-class grain, keyed
by `site_key` (`report_id:reference_number`). This turns those rows into
one row per site, species and method (a site records each method's catch
on its own), and takes the site's electrofishing effort from the step-2
collection form where the group's `fiss_step2_fishcoll_<wsg>.csv` holds
it: electrofishing seconds summed over passes, and the fished area as
the first pass's length × width. A site enters the scoring only with an
effort (`scores`); the rest are presence-only, which choose groups and
feed the outside check but never score a rule.

## Usage

``` r
knw_fiss_visits(evidence, step2 = NULL)
```

## Arguments

- evidence:

  `data.frame`, `data/fiss_evidence.csv` as written by `0250`.

- step2:

  `data.frame`, the step-2 rows of the groups (`0220`), bound together;
  `NULL` when none are held.

## Value

A `tibble`, one row per site, species and method: `site_visit` (the
`site_key`), `watershed_group_code`, `blue_line_key`,
`downstream_route_measure`, `year`, `month`, `method`, `species_code`,
`n_caught`, `fishing_time_s`, `area_m2`, `fished_length_m`, `scores`,
`data_set = "FISS_WORKBOOK"`.

## Examples

``` r
ev <- data.frame(site_visit = "17491:1", species_code = c("BT", "BT"), size_class = c("fry", "adult"),
                 n = c(2, 1), n_caught = 3, watershed_group_code = "COTR", blue_line_key = 1,
                 downstream_route_measure = 10, month = 8, year = 2015, method = "electrofishing")
s2 <- data.frame(site_key = "17491:1", sampling_method = "EF", haul_pass = c(1, 2),
                 ef_seconds = c(300, 250), length_m = 50, width_m = 2, ef_length_m = NA, ef_width_m = NA)
knw_fiss_visits(ev, s2)
#> # A tibble: 1 × 14
#>   site_visit watershed_group_code blue_line_key downstream_route_measure  year
#>   <chr>      <chr>                        <dbl>                    <dbl> <int>
#> 1 17491:1    COTR                             1                       10  2015
#> # ℹ 9 more variables: month <int>, method <chr>, species_code <chr>,
#> #   n_caught <dbl>, fishing_time_s <dbl>, area_m2 <dbl>, fished_length_m <dbl>,
#> #   scores <lgl>, data_set <chr>
```
