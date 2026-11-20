# Keep a step's wanted columns and drop rows that carry only keys

Takes the key columns, the step's columns (see
[`knw_fiss_columns()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_columns.md))
and every column whose name contains "comment", and adds a wanted column
the sheet lacks as `NA`. The template pre-fills the reference number and
names on hundreds of blank entry rows, so a row is kept only when at
least one non-key cell is filled.

## Usage

``` r
knw_fiss_select(df, step, cols = knw_fiss_columns()$wanted)
```

## Arguments

- df:

  `data.frame`, a step's rows as
  [`knw_fiss_read_step()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_read_step.md)
  returns them in `data`.

- step:

  `string`, the step (see
  [`knw_fiss_match_sheet()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_match_sheet.md)).

- cols:

  `list`, the columns read per step, with `keys` read on every step; by
  default `knw_fiss_columns()$wanted`. Add a name to read a column the
  default does not.

## Value

`df`'s wanted columns, then any other comment columns, with the key-only
rows dropped.

## Examples

``` r
df <- data.frame(reference_number = c("1", "2"), gazetted_name = "Test Creek",
                 utm_zone = c("10", NA), utm_easting = c("612000", NA),
                 utm_northing = c("5980000", NA), site_comments = c(NA, NA))
# row 2 carries only keys
knw_fiss_select(df, "step1_ref_loc")
#>   reference_number gazetted_name utm_zone utm_easting utm_northing
#> 1                1    Test Creek       10      612000      5980000
#>   site_comments reach_number site_number local_name waterbody_id survey_date
#> 1            NA           NA          NA         NA           NA          NA
```
