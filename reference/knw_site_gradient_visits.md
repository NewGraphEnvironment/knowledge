# How a measured site gradient compares with a modelled one

FDIS crews measured the channel's slope at the site (`gradient_pct`, and
a second reading, `gradient2_pct`); every gradient limit the tuning
publishes is a limit on a Freshwater Atlas average (link's segment
gradient, or the whole Atlas line's). These measure how far apart the
two are (#121), as `data-raw/site_gradient_check.R` reports them and the
methodology article quotes them, from one code path.

## Usage

``` r
knw_site_gradient_visits(visits_link)

knw_site_gradient_population(v, visits_species, species_code, stage)

knw_gradient_agree(measured, modelled)

knw_gradient_flips(d, limit, against, ladder)
```

## Arguments

- visits_link:

  `0310`'s `visits_link.csv`.

- v:

  from `knw_site_gradient_visits()`.

- visits_species:

  `0310`'s `visits_species.csv`.

- species_code, stage:

  the key.

- measured, modelled:

  numeric gradients on one scale.

- d:

  a population with `meas` and the modelled gradient column.

- limit:

  `numeric(1)` the published limit.

- against:

  the modelled gradient column (`"segment_gradient"`, `"fwa_gradient"`).

- ladder:

  the key's gradient ladder (its tune table's `grad_max`).

## Value

`knw_site_gradient_visits()`: the visits with `meas`, `meas2`,
`at_visit` and `stream_branch`. `knw_site_gradient_population()`: the
key's visits. `knw_gradient_agree()` and `knw_gradient_flips()`: a
one-row tibble.

## Details

`knw_site_gradient_visits()` reads the visit table onto the rules' scale
(percent / 100, `meas` and `meas2`) and marks the tuning's stream branch
([`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md)'s
edge types and fished area, no river, wetland or lake).
`knw_site_gradient_population()` is a key's scored visits on it: in the
species' range, not blocked, no barrier downstream, and for rearing the
groups that hold both outcomes
([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md));
a spawning key's is before the spawner-evidence and groups filters,
which need tables not read here. `knw_gradient_agree()` is the agreement
of two gradients: rank correlation over every pair; over pairs both
above 0, the correlation of the logs and the measured/modelled ratio's
p10, p50 and p90; the absolute difference's median and p90; the share
where the model is higher. `knw_gradient_flips()` counts visits whose
measured and modelled gradients lie on opposite sides of a limit (a
reading on the limit is in, as a rule's `<=` has it), over every visit
and within one step of the key's own ladder either side of the limit
(`band`, mirrored at the ladder's ends; and the same window on the
measured gradient).

## Examples

``` r
knw_gradient_agree(c(0.01, 0.02, 0.05, 0.10), c(0.012, 0.03, 0.04, 0.08))
#> # A tibble: 1 × 10
#>   pairs zero_pairs spearman log_r ratio_p10 ratio_p50 ratio_p90 absdiff_p50
#>   <int>      <int>    <dbl> <dbl>     <dbl>     <dbl>     <dbl>       <dbl>
#> 1     4          0        1 0.971      0.72      1.04      1.25        0.01
#> # ℹ 2 more variables: absdiff_p90 <dbl>, model_higher_pct <dbl>
d <- data.frame(meas = c(0.10, 0.12, 0.05), segment_gradient = c(0.12, 0.10, 0.06))
knw_gradient_flips(d, 0.11, "segment_gradient", c(0.07, 0.09, 0.11, 0.13, 0.15))
#> # A tibble: 1 × 11
#>   against     visits flips_pct band  band_visits band_flips_pct meas_band_visits
#>   <chr>        <int>     <dbl> <chr>       <int>          <dbl>            <int>
#> 1 segment_gr…      3      66.7 (0.0…           2            100                2
#> # ℹ 4 more variables: meas_band_flips_pct <dbl>, meas_on_limit <int>,
#> #   meas_above_model_below <int>, meas_below_model_above <int>
```
