# Size class of each fish from a table of length breaks

Each break row covers `[length_min_mm, length_max_mm)` for one species
group, so a fish exactly on a break takes the upper class. The breaks
must tile every group that has a measured fish: a fish with a positive
length that falls in no class, or in more than one, is an error rather
than an `NA`, because a gap or an overlap in the table would otherwise
read as "unmeasured".

## Usage

``` r
knw_size_class(species_group, length_mm, breaks)
```

## Arguments

- species_group:

  `character` species group per fish, matched against
  `breaks$species_group`.

- length_mm:

  `numeric` length per fish, same length as `species_group`. `NA`, zero
  and negative lengths are unmeasured and return `NA`.

- breaks:

  `data.frame` with columns `species_group`, `size_class`,
  `length_min_mm` and `length_max_mm` (use `Inf` for an open top class).

## Value

`character` size class per fish, `NA` where unmeasured.

## Examples

``` r
breaks <- data.frame(
  species_group = c("CH", "CH"),
  size_class    = c("fry", "parr"),
  length_min_mm = c(0, 70),
  length_max_mm = c(70, Inf)
)
knw_size_class(c("CH", "CH", "CH"), c(45, 70, NA), breaks)
#> [1] "fry"  "parr" NA    
```
