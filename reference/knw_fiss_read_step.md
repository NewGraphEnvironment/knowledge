# Read one step sheet, finding its header row

The header is not row 1: title, instruction and section rows sit above
the field labels, and how many depends on the edition and the step (rows
17, 26 and 31 for Step 1, 4 to 23 for the others). The label row is the
first within the top 40 whose first non-empty cell starts with
"REFERENCE NUMBER". Its labels become
[`janitor::make_clean_names()`](https://sfirke.github.io/janitor/reference/make_clean_names.html)
names, and an edition's variant name is renamed to the canonical one
unless the sheet already carries the canonical name. A data row must
carry a reference number, which drops the template's pre-formatted blank
entry rows.

## Usage

``` r
knw_fiss_read_step(path, sheet)
```

## Arguments

- path:

  `string`, a workbook (`.xls` or `.xlsx`).

- sheet:

  `string`, the sheet to read.

## Value

A list: `status` (`"ok"`, `"empty_sheet"` or `"no_header"`),
`header_row`, `banner` (the first non-empty cell of row 1, which names
the template edition), `rows_raw` (rows under the header before
filtering) and `data` (a tibble of the rows kept, every cell as `readxl`
returned it, or `NULL`).

## Examples

``` r
f <- system.file("testdata", "fiss", "template_v2.xls", package = "knowledge")
s <- knw_fiss_read_step(f, "Step 1 (Ref. and Loc. Info)")
s$header_row
#> [1] 31
s$banner
#> [1] "Fish Data Submission Spreadsheet Template -V 2.0, April 27, 2012"
s$data[, c("reference_number", "utm_zone", "utm_easting", "utm_northing")]
#> # A tibble: 5 × 4
#>   reference_number utm_zone utm_easting utm_northing
#>   <chr>            <chr>    <chr>       <chr>       
#> 1 1                10       612000      5980000     
#> 2 2                11U      312000      5700000     
#> 3 3                10       613500      5981200     
#> 4 4                NA       NA          NA          
#> 5 5                NA       NA          NA          
```
