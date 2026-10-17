# Read the life-history timing table, filtered by group and species

One row per watershed group, species, life stage and window. `start` and
`end` are month-day (`MM-DD`) with no year, so a window with
`start > end` crosses 1 January. A window the source gave only one end
of keeps the other as `NA`; a row with neither is an error. `source`
holds Zotero citation keys separated by `"; "`.

## Usage

``` r
knw_timing_read(path, wsg_code = NULL, species_code = NULL)
```

## Arguments

- path:

  `character(1)` path to the timing CSV, with columns `wsg_code`,
  `species_code`, `life_stage`, `start`, `end`, `source` and `note`.

- wsg_code:

  `character` watershed group codes to keep, or `NULL` for all.

- species_code:

  `character` species codes to keep, or `NULL` for all.

## Value

A `tibble` with the seven columns, all `character`.

## Details

The table is validated before filtering, so a bad row anywhere in the
file is an error whichever group is asked for. Within one group, species
and stage, windows must not overlap (a half window's known day counts),
and a window crossing 1 January is one row: a window ending `12-31`
beside one starting `01-01` is refused, because the pair reads as two
windows to anything that counts them. `start == end` is refused as
ambiguous between one day and a whole year. A requested group or species
absent from the table is a warning, so a typo does not read as "no
data".

## Examples

``` r
path <- tempfile(fileext = ".csv")
utils::write.csv(data.frame(
  wsg_code = c("MORR", "MORR"), species_code = c("CH", "BT"),
  life_stage = c("spawning", "incubation"), start = c("09-01", "08-23"),
  end = c("10-07", "04-30"), source = c("key_a", "key_b"), note = NA
), path, row.names = FALSE, na = "")
knw_timing_read(path, wsg_code = "MORR", species_code = "BT")
#> # A tibble: 1 × 7
#>   wsg_code species_code life_stage start end   source note 
#>   <chr>    <chr>        <chr>      <chr> <chr> <chr>  <chr>
#> 1 MORR     BT           incubation 08-23 04-30 key_b  NA   
```
