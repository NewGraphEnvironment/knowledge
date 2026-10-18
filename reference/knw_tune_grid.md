# The candidate rules for one species and stage, around link's own thresholds

`scripts/0297` tuned CH rearing over a grid of three components; this
builds that grid for any species and stage from link's `default`
thresholds. A rule is a stream-branch test with three parts: a size test
(a MAD floor in m³/s with no maximum, or a channel-width floor in m), a
gradient maximum, and an exception admitting a segment that fails the
size test when a river of at least `exc_q` m³/s lies within `exc_d` m
downstream. `default` is the member with link's own width floor and
gradient maximum and no exception; `departures` counts how many parts
differ from it (a size test that differs in variable or value: 1; a
gradient that differs: 1; an exception: 1).

## Usage

``` r
knw_tune_grid(
  thresholds,
  stage = c("rear", "spawn"),
  grid_mad = c(0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1),
  grid_width = c(1, 1.5, 2, 3, 4),
  grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09),
  grid_q = c(1, 3, 5, 10, 20, 30, 50),
  grid_d = c(100, 250, 500, 1000, 2000, 5000)
)
```

## Arguments

- thresholds:

  one row of link's `parameters_habitat_thresholds.csv` for the species
  (a `data.frame` with `species_code`, `<stage>_gradient_max`,
  `<stage>_channel_width_min`, `<stage>_mad_min`).

- stage:

  `"rear"` or `"spawn"`.

- grid_mad, grid_width, grid_grad, grid_q, grid_d:

  `numeric` candidate values; the species' own `default` width and
  gradient are added when absent.

## Value

A `tibble` with `rule`, `size_var`, `size_min`, `grad_max`, `exc_q`,
`exc_d`, `departures`, `is_default`; zero rows when the species has no
stream rule for the stage.

## Details

The size and gradient grids are the species' `default` values and the
fixed steps around them, so every species is tuned against the same
ladder; a species whose `default` has no stream rule for the stage (KO
and SK rear in lakes only) gets an empty grid, and the caller says so.

## Examples

``` r
thr <- data.frame(species_code = "CH", rear_gradient_max = 0.0549, rear_channel_width_min = 1.5,
                  rear_mad_min = 0.28)
g <- knw_tune_grid(thr, "rear")
nrow(g)
#> [1] 2795
g[g$is_default, ]
#> # A tibble: 1 × 8
#>   rule              size_var size_min grad_max exc_q exc_d departures is_default
#>   <chr>             <chr>       <dbl>    <dbl> <dbl> <dbl>      <int> <lgl>     
#> 1 width>=1.5|g<=0.… width         1.5   0.0549    NA    NA          0 TRUE      
```
