# Find a workbook's sheet for one step

Sheet names drift across the template's editions ("Step 4 (Stream Site
Data)", "Step 4 (Site Card Data)", "Fish collection"), so each step is
found by a pattern on the lower-cased name (see
[`knw_fiss_columns()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_columns.md)).

## Usage

``` r
knw_fiss_match_sheet(sheets, step)
```

## Arguments

- sheets:

  `character`, the workbook's sheet names
  ([`readxl::excel_sheets()`](https://readxl.tidyverse.org/reference/excel_sheets.html)).

- step:

  `string`, one of `"step1_ref_loc"`, `"step2_fish_coll"`,
  `"step3_indiv_fish"`, `"step4_site_data"`.

## Value

`string`, the first sheet that matches, or `NA` when none does (a
tissue-data workbook or a reach summary).

## Examples

``` r
sheets <- c("INSTRUCTIONS", "Step 1 (Ref. and Loc. Info)", "Step 2 (Fish Coll. Data)",
            "Step 3 (Individual Fish Data)", "Step 4 (Site Card Data)")
knw_fiss_match_sheet(sheets, "step4_site_data")
#> [1] "Step 4 (Site Card Data)"
knw_fiss_match_sheet("Tissue", "step2_fish_coll")
#> [1] NA
```
