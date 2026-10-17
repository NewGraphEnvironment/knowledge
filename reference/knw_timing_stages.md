# Life stages in the life-history timing table

The controlled vocabulary for `life_stage` in a timing table read by
[`knw_timing_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_timing_read.md).
`fry_migration` is upstream movement of fry; `outmigration` is seaward
movement of juveniles.

## Usage

``` r
knw_timing_stages()
```

## Value

`character` life stages.

## Examples

``` r
knw_timing_stages()
#> [1] "migration"     "spawning"      "incubation"    "emergence"    
#> [5] "fry_migration" "rearing"       "overwintering" "outmigration" 
```
