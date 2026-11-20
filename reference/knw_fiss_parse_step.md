# Parse one step of one workbook, naming why it yielded nothing

Finds the step's sheet, reads it and keeps its wanted rows, keyed by
`site_key` (`report_id:reference_number`: a reference number is unique
only within one submission). Every way a step can yield nothing has a
status of its own, so a group's parse log shows each one by name:

## Usage

``` r
knw_fiss_parse_step(path, report_id, step, cols = knw_fiss_columns()$wanted)
```

## Arguments

- path:

  `string`, a workbook (`.xls` or `.xlsx`).

- report_id:

  `string`, the submission's EcoCat report id.

- step:

  `string`, the step (see
  [`knw_fiss_match_sheet()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_match_sheet.md)).

- cols:

  `list`, the columns read per step (see
  [`knw_fiss_select()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_select.md)).

## Value

A list: `data`, a tibble led by `report_id` and `site_key` (`NULL`
unless the status is `"ok"`), and `log`, a one-row tibble: `report_id`,
`path`, `step`, `status`, `sheet_matched`, `n_sheet_hits`, `header_row`,
`banner`, `rows_raw`, `rows_after_filter`.

## Details

- `sheets_error`: the workbook's sheets could not be listed;

- `no_sheet_match`: no sheet matches the step (tissue data, reach
  summaries);

- `read_error`: reading the sheet failed;

- `empty_sheet`: the sheet has no rows;

- `no_header`: no "REFERENCE NUMBER" label row in the top 40;

- `no_rows`: a header, but no row kept;

- `fish_layout`: a Step 2 sheet laid out one row per fish (`length_mm`
  and no `total_number`), whose rows are read as Step 3 instead;

- `ok`: rows kept.

Step 3 falls back to the Step 2 sheet when its own sheet gives no rows
and the Step 2 sheet is in fish layout: the template ships an empty Step
3 beside whatever was filled in.

## Examples

``` r
f <- system.file("testdata", "fiss", "individual_fish.xls", package = "knowledge")
# a per-fish sheet named like Step 2 is set aside there and read as Step 3
knw_fiss_parse_step(f, "16389", "step2_fish_coll")$log$status
#> [1] "fish_layout"
s3 <- knw_fiss_parse_step(f, "16389", "step3_indiv_fish")
s3$log[, c("status", "sheet_matched", "header_row")]
#> # A tibble: 1 × 3
#>   status sheet_matched   header_row
#>   <chr>  <chr>                <int>
#> 1 ok     Fish collection          4
s3$data[, c("site_key", "species", "length_mm")]
#> # A tibble: 3 × 3
#>   site_key species length_mm
#>   <chr>    <chr>   <chr>    
#> 1 16389:1  RB      95       
#> 2 16389:1  RB      120      
#> 3 16389:2  BT      180      
```
