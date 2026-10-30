# The archive's index: what is stored where

`data/archive_index.csv` (tracked) holds one row per stored object
(`event = "archived"`), with its S3 version id, and one row per key per
promotion event (`promoted`, `superseded`, `undone`), so a run is found
by reading a table and restored by version id after a later run
overwrote its folder.

## Usage

``` r
knw_archive_index_read(path = "data/archive_index.csv")
```

## Arguments

- path:

  the index.

## Value

A data frame of the index's columns (all character); zero rows when the
file does not exist.

## Examples

``` r
nrow(knw_archive_index_read(tempfile()))
#> [1] 0
```
