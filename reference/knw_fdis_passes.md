# FDIS electrofishing passes and the catch on each

The FDIS load (`scripts/0230-fdis-load.R`) takes the site visit as its
grain, so its visit tables sum catch and effort over a visit's passes.
This keeps the passes: one row per pass of a kept visit, and one row per
pass and species code caught, for a removal estimate or an occupancy
model that treats passes as repeat surveys (#225). A pass is one row of
the export's `visits.csv`, one method number and haul; `pass_index`
orders a visit's passes by method, then haul.

## Usage

``` r
knw_fdis_passes(passes, counts, fish, keep, codes)
```

## Arguments

- passes:

  `data.frame`, one row per pass: `KEY`, `site_visit`, `method_number`,
  `haul_or_pass`, `date`, `fishing_time_s`, `fished_length_m`,
  `fished_width_m`, `area_m2`, `flag_effort_sentinel`.

- counts:

  `data.frame`, the export's counts as `0230` reads them: `KEY`,
  `site_visit`, `species_code`, `n` (`NA` for a sentinel),
  `flag_count_sentinel`.

- fish:

  `data.frame`, one row per measured fish: `KEY`, `species_code`,
  `is_nfc`.

- keep:

  `character`, the site visits kept (the load drops repeat copies of one
  survey, \#35).

- codes:

  `data.frame`, `data/fdis_species_codes.csv`: `code`, `catch_class`
  (`"fish"`, `"zero_catch"` or `"not_fish"`). Every code in `counts` and
  `fish` must be in it.

## Value

A list of two tibbles. `passes`: `KEY`, `site_visit`, `pass_index`,
`n_pass`, `method_number`, `haul_or_pass`, `date`, `fishing_time_s`,
`fished_length_m`, `fished_width_m`, `area_m2`, `flag_effort_sentinel`,
`pass_status`, `flag_nfc_conflict`. `pass_catch`: `KEY`, `site_visit`,
`species_code`, `n_counted`, `n_measured`, `n_caught`,
`flag_count_sentinel`, `flag_counts_lt_measured`, for the kept passes
only.

## Details

The catch on a pass follows the visit table's rule, applied per pass:
the counted number (age rows summed), or the measured fish where the
count is missing or short of them; a sentinel count with nothing
measured is a catch of unknown size (`NA`, never 0); a row with 0 caught
and nothing measured is not a catch. Because the larger of the counted
and measured numbers is taken per pass, a visit's catch summed over its
passes can exceed the visit table's `n_caught`, which takes it once over
the summed passes. Codes are kept as recorded: a code that blocks a
species' absence (such as "all fish") is a catch row, and which passes
form one closed population is the caller's choice.

`pass_status` is `"fish"` where a fish code was caught on the pass,
`"nfc"` where only a no-fish-caught code was recorded, and `"no_record"`
where the pass has neither, which is unknown, never zero.
`flag_nfc_conflict` marks a pass recording both.

## Examples

``` r
passes <- data.frame(KEY = c("1_1_1_1_1", "1_1_1_1_2"), site_visit = "1_1_1",
                     method_number = 1L, haul_or_pass = 1:2, date = as.Date("2005-08-01"),
                     fishing_time_s = c(300, 250), fished_length_m = 50, fished_width_m = 4,
                     area_m2 = 200, flag_effort_sentinel = FALSE)
counts <- data.frame(KEY = c("1_1_1_1_1", "1_1_1_1_2"), site_visit = "1_1_1",
                     species_code = "BT", n = c(6, 2), flag_count_sentinel = FALSE)
fish <- data.frame(KEY = character(), species_code = character(), is_nfc = logical())
codes <- data.frame(code = c("BT", "NFC"), catch_class = c("fish", "zero_catch"))
# depletion from 6 to 2 over two passes: what a removal estimate reads
knw_fdis_passes(passes, counts, fish, keep = "1_1_1", codes)
#> $passes
#> # A tibble: 2 × 14
#>   KEY       site_visit pass_index n_pass method_number haul_or_pass date      
#>   <chr>     <chr>           <int>  <int>         <int>        <int> <date>    
#> 1 1_1_1_1_1 1_1_1               1      2             1            1 2005-08-01
#> 2 1_1_1_1_2 1_1_1               2      2             1            2 2005-08-01
#> # ℹ 7 more variables: fishing_time_s <dbl>, fished_length_m <dbl>,
#> #   fished_width_m <dbl>, area_m2 <dbl>, flag_effort_sentinel <lgl>,
#> #   pass_status <chr>, flag_nfc_conflict <lgl>
#> 
#> $pass_catch
#> # A tibble: 2 × 8
#>   KEY       site_visit species_code n_counted n_measured n_caught
#>   <chr>     <chr>      <chr>            <dbl>      <int>    <dbl>
#> 1 1_1_1_1_1 1_1_1      BT                   6          0        6
#> 2 1_1_1_1_2 1_1_1      BT                   2          0        2
#> # ℹ 2 more variables: flag_count_sentinel <lgl>, flag_counts_lt_measured <lgl>
#> 
```
