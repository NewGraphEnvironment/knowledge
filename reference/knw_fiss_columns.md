# The columns, name variants and sheet patterns the workbook parser reads

The provincial Fish Data Submission workbook has four step sheets: Step
1 (reference and location), Step 2 (fish collection: effort and the
catch per species), Step 3 (individual fish) and Step 4 (stream site).
Its editions name the sheets and some columns differently. This returns
what
[`knw_fiss_parse_step()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fiss_parse_step.md)
reads, so a caller can see it without reading the code.

## Usage

``` r
knw_fiss_columns()
```

## Value

A list: `wanted`, the columns read per step (plus `keys`, read on every
step), in
[`janitor::make_clean_names()`](https://sfirke.github.io/janitor/reference/make_clean_names.html)
form; `variants`, a named character vector mapping an edition's column
name to the canonical one; `step_pattern`, the regular expression that
finds each step's sheet by its lower-cased name.

## Examples

``` r
cols <- knw_fiss_columns()
cols$step_pattern
#>                                           step1_ref_loc 
#>                             "step.?1|ref.*loc|location" 
#>                                         step2_fish_coll 
#>                   "step.?2|fish.?coll|collection.?form" 
#>                                        step3_indiv_fish 
#>                                         "step.?3|indiv" 
#>                                         step4_site_data 
#> "step.?4|stream.?site|site.?data|site.?card|site.?coll" 
# the pre-2012 edition's names and the ones they are read as
cols$variants
#>          gazetted_names        alias_local_name waterbody_id_identifier 
#>         "gazetted_name"            "local_name"          "waterbody_id" 
#>            species_code                  method            haul_or_pass 
#>               "species"       "sampling_method"             "haul_pass" 
#> haul_number_pass_number        date_yyyy_mm_day 
#>             "haul_pass"           "survey_date" 
```
