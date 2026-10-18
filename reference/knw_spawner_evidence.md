# Spawner evidence per visit for the char species, from maturity codes

`scripts/0293`'s response, as `0240` fixed it: a visit carries spawner
evidence for bull trout when a BT fish (DV pooled where link pools it)
was coded `SP` or `ST` at any date, or `M` in August to October. Only
visits that caught the species and maturity-coded at least one of its
fish can carry the response; on a visit nobody coded, evidence was
impossible, so those visits get `NA`. Electrofishing catches no adult
Pacific salmon, so this is the only spawning response the export can
give.

## Usage

``` r
knw_spawner_evidence(
  fish,
  visits,
  codes,
  species = "BT",
  coded = c("IM", "M", "MT", "SP", "ST"),
  large_mm = 350
)
```

## Arguments

- fish:

  `data.frame` with `site_visit`, `species_code`, `maturity_code`,
  `length_mm` (`0230`'s `fish.rds`).

- visits:

  `data.frame` with `site_visit`, `month` and `pooling` (`"BT+DV"` where
  DV counts as BT, from
  [`knw_fdis_species()`](https://newgraphenvironment.github.io/knowledge/reference/knw_fdis_species.md)).

- codes:

  `data.frame` with `code` and `species_group`.

- species:

  `character(1)` the species; `"BT"` is the only one the codes support
  today.

- coded:

  `character` the maturity codes that count as a coded fish.

- large_mm:

  `numeric(1)` the length at and above which a spawner is large (a
  migratory-adult size); the split comes back as `S_large`, `S_small`.

## Value

A `tibble`, one row per visit: `site_visit`, `species_code`, `n_coded`,
`S` (0/1, `NA` where no fish was coded), `S_large`, `S_small`, `kind`
(the strongest evidence kind: `SP/ST`, `M Sep-Oct`, `M Aug`,
`M other months`, `adult size only`, `none`).

## Examples

``` r
fish <- data.frame(site_visit = c("v1", "v1", "v2", "v3"), species_code = c("BT", "BT", "DV", "BT"),
                   maturity_code = c("IM", "M", "SP", NA), length_mm = c(90, 410, 300, 500))
visits <- data.frame(site_visit = c("v1", "v2", "v3"), month = c(9, 6, 9), pooling = c("BT", "BT+DV", "BT"))
codes <- data.frame(code = c("BT", "DV"), species_group = "char")
knw_spawner_evidence(fish, visits, codes)
#> # A tibble: 3 × 7
#>   site_visit species_code n_coded     S S_large S_small kind           
#>   <chr>      <chr>          <int> <int>   <int>   <int> <chr>          
#> 1 v1         BT                 2     1       1       0 M Sep-Oct      
#> 2 v2         BT                 1     1       0       1 SP/ST          
#> 3 v3         BT                 0    NA      NA      NA adult size only
```
