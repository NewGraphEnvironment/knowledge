# Roll Fish Data Submission Step 2 records up to sites, flagging no fish caught

Step 2 of the provincial workbook carries one row per method, pass or
trap and species: the effort and the number caught. The workbook has no
no-fish field of its own. The submitter records "No Fish Caught" (the
picklist from 2016) or a zero-catch code such as `NFC` (earlier
editions), which is their own call; this takes it as given and invents
no effort threshold. A site is flagged `nfc` when nothing at it was
caught and either the submitter recorded no fish
(`nfc_source = "submitted"`) or a count of 0 was entered with effort
recorded (`"derived"`). Blank counts are never read as zero: the derived
branch needs a count to have been entered. Editions record no fish per
trap or pass, so one empty trap beside a full one is not a no-fish site;
`nfc_conflict` keeps that case visible. A site with no Step 2 record
gets no row here, so joined to the site table its `nfc` is `NA`, unknown
rather than no fish.

## Usage

``` r
knw_fiss_nfc(step2, codes)
```

## Arguments

- step2:

  `data.frame`, Step 2 rows as
  [`knw_fiss_parse_step()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_parse_step.md)
  returns them, bound over workbooks: `site_key`, `sampling_method`,
  `species`, `total_number`, `ef_seconds`, `ef_length_m`, `soak_time`,
  `comments`. Cells may be character, as the sheets give them.

- codes:

  `data.frame`, `data/fdis_species_codes.csv`: `code`, `catch_class`.
  The codes whose class is `"zero_catch"` are the no-fish entries.

## Value

A tibble, one row per `site_key`: `methods_used`, `n_records`,
`total_ef_secs`, `total_ef_len_m`, `max_soak_time`, `total_fish`,
`fish_counted`, `species_list`, `any_no_fish`, `any_caught`,
`species_caught`, `effort_recorded`, `comments_fish`, `nfc_conflict`,
`nfc`, `nfc_source`.

## Details

A record caught something when it names a species that is not a no-fish
entry, unless its count is an explicit 0, or when its count is above 0.
`species_list` names every species entered and `species_caught` only
those caught, so an empty trap recorded as "RB, 0" lists RB without
catching it. Effort and comments ride along, so a reader can weigh a
no-fish site ("electrofished 1200 m, nothing" against a brief dip net).

Moved from `scripts/0220-fiss-xls-parse-nfc.R` (#7).

## Examples

``` r
step2 <- data.frame(
  site_key        = c("1:1", "1:1", "1:2", "1:3", "1:4"),
  sampling_method = "EF",
  species         = c("Rainbow Trout", "No Fish Caught", "No Fish Caught", NA, NA),
  total_number    = c("4", NA, NA, "0", NA),
  ef_seconds      = c("300", "200", "450", "600", "500"),
  ef_length_m = NA, soak_time = NA, comments = NA)
codes <- data.frame(code = c("RB", "NFC"), catch_class = c("fish", "zero_catch"))
# 1:1 a pass with fish beside an empty one, 1:2 submitted no fish, 1:3 a zero count with effort,
# 1:4 effort and no count at all: not a no-fish site
knw_fiss_nfc(step2, codes)[, c("site_key", "any_caught", "nfc_conflict", "nfc", "nfc_source")]
#> # A tibble: 4 × 5
#>   site_key any_caught nfc_conflict nfc   nfc_source
#>   <chr>    <lgl>      <lgl>        <lgl> <chr>     
#> 1 1:1      TRUE       TRUE         FALSE NA        
#> 2 1:2      FALSE      FALSE        TRUE  submitted 
#> 3 1:3      FALSE      FALSE        TRUE  derived   
#> 4 1:4      FALSE      FALSE        FALSE NA        
```
