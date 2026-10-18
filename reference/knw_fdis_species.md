# Catch, presence and absence per FDIS site visit and species

One row per visit and species in `species`: how many were caught (summed
over the codes that count as that species), how many of them were
measured into each size class of `breaks`, whether the species is
present, and whether an absence claim is blocked by a code that could
hide it.

## Usage

``` r
knw_fdis_species(
  sites,
  catch,
  fish,
  codes,
  breaks,
  species = knw_species(),
  pooled = NULL
)
```

## Arguments

- sites:

  `data.frame` with `site_visit`, `watershed_group_code`, `year` and
  `catch_status`.

- catch:

  `data.frame` with `site_visit`, `species_code`, `n_caught` and
  `n_measured` (`0230`'s `catch.rds`).

- fish:

  `data.frame` with `site_visit`, `species_code` and `length_mm`
  (`0230`'s `fish.rds`).

- codes:

  `data.frame` with `code`, `catch_class`, `species_group` and
  `blocks_absence_of` (`data/fdis_species_codes.csv`, read as
  character).

- breaks:

  size-class breaks, as
  [`knw_size_class()`](https://newgraphenvironment.github.io/knowledge/reference/knw_size_class.md)
  takes them.

- species:

  `character` species codes to keep rows for.

- pooled:

  `NULL`, or a `data.frame` with `watershed_group_code` and
  `obs_year_max` naming the groups where DV records are pooled into BT,
  up to that year (`NA` for no limit), as `link::lnk_species_pooling()`
  reports them.

## Value

A `tibble` with `site_visit`, `species_code`, `n_caught`, `n_measured`,
one `n_<size_class>` column per class in `breaks`, `n_unmeasured`,
`pooling` (`"BT+DV"` or `"BT"` for BT, `NA` otherwise), `present`,
`absence_blocked` and `status` (`present`, `absent`, `blocked`,
`unknown`).

## Details

Presence follows `scripts/0290`'s pooling rule for bull trout and the
code table for everything else:

- a species is present when a code that counts as it was caught. For
  `BT` the codes are `BT` alone, or every char code except `SLV` (`BT`,
  `DV`, `BT/DV`, `DV/BT`, `DVxBT`) where link pools Dolly Varden records
  into bull trout for that watershed group and year (`pooled`);

- an absence is blocked when the visit caught a code whose
  `blocks_absence_of` names the species or its species group (`char` for
  BT), or, for `BT`, any other char code (`DV` counts as a BT absence
  where DV is not pooled, as link counts it);

- a visit whose `catch_status` is `unknown` carries no absence.

`n_caught` is `NA` where every counting code's count was a sentinel
(caught, abundance unknown). Size-class counts exist only for the
species groups `breaks` tiles (a measured fish of another species has a
length and no class); `n_unmeasured` is the counted fish with no usable
length.

## Examples

``` r
sites <- data.frame(site_visit = c("v1", "v2"), watershed_group_code = "BULK",
                    year = 2010L, catch_status = c("fish", "zero"))
catch <- data.frame(site_visit = c("v1", "v1"), species_code = c("DV", "CH"),
                    n_caught = c(3, 2), n_measured = c(2, 0))
fish <- data.frame(site_visit = "v1", species_code = c("DV", "DV"), length_mm = c(55, 120))
codes <- data.frame(code = c("DV", "CH", "BT"), catch_class = "fish",
                    species_group = c("char", "CH", "char"), blocks_absence_of = "")
breaks <- data.frame(species_group = c("char", "char"), size_class = c("fry", "juvenile"),
                     length_min_mm = c(0, 80), length_max_mm = c(80, Inf))
# DV is a BT absence unless pooled; pooling makes v1 a BT visit with 3 fish
knw_fdis_species(sites, catch, fish, codes, breaks, species = c("BT", "CH"))
#> # A tibble: 4 × 11
#>   site_visit species_code n_caught n_measured n_fry n_juvenile n_unmeasured
#>   <chr>      <chr>           <dbl>      <dbl> <int>      <int>        <dbl>
#> 1 v1         BT                  0          0     0          0            0
#> 2 v1         CH                  2          0     0          0            2
#> 3 v2         BT                  0          0     0          0            0
#> 4 v2         CH                  0          0     0          0            0
#> # ℹ 4 more variables: pooling <chr>, present <lgl>, absence_blocked <lgl>,
#> #   status <chr>
knw_fdis_species(sites, catch, fish, codes, breaks, species = "BT",
                 pooled = data.frame(watershed_group_code = "BULK", obs_year_max = NA))
#> # A tibble: 2 × 11
#>   site_visit species_code n_caught n_measured n_fry n_juvenile n_unmeasured
#>   <chr>      <chr>           <dbl>      <dbl> <int>      <int>        <dbl>
#> 1 v1         BT                  3          2     1          1            1
#> 2 v2         BT                  0          0     0          0            0
#> # ℹ 4 more variables: pooling <chr>, present <lgl>, absence_blocked <lgl>,
#> #   status <chr>
```
