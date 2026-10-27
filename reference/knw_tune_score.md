# Score candidate rules on held-out watershed groups

`scripts/0297`'s scoring spec, fixed for CH before its first fit and
applied here to any species × stage. Each rule's in/out on every visit
enters a binomial model with a complementary log-log link beside
`log(area)`, data set, era and the watershed group. The modelled groups
go into `folds` folds, stratified: groups are ranked by detections and
dealt in shuffled blocks, with a fixed seed. Each fold is scored from a
fit on the other folds: the held-out visits take that fit's rule, area,
data-set and era coefficients, and each held-out group refits only its
own intercept on its own visits (one parameter per group for every
rule). A level unseen in training takes the reference and is counted.
The score is the summed binomial deviance of the held-out visits. Rules
with the same in/out on every visit are one fit.

## Usage

``` r
knw_tune_score(
  d,
  rule_in,
  grid,
  resp = "U",
  seed = 54L,
  folds = 5L,
  n_boot = 200L,
  seed_boot = 541L,
  seeds_more = integer(),
  d_floor = 200,
  workers = 1L,
  extra = FALSE,
  fit = c("fe", "dense"),
  prior_sd = 2.5
)
```

## Arguments

- d:

  `data.frame` of visits with the response column `resp` (0/1), `wsg`
  (factor), `log_area`, `data_set` (factor), `era` (factor), and the
  columns `rule_in` reads.

- rule_in:

  a function `(d, rule)` returning a logical of `nrow(d)`: whether each
  visit is in under one row of `grid` (see
  [`knw_rule_in()`](https://newgraphenvironment.github.io/knowledge/reference/knw_rule_in.md)).

- grid:

  the rules, as
  [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)
  returns them.

- resp:

  `character(1)` the response column.

- seed:

  `integer(1)` fold seed.

- folds, n_boot, seed_boot, seeds_more, d_floor:

  the spec's constants.

- workers:

  `integer(1)` socket workers for the pattern fits.

- extra:

  `logical(1)` run the bootstrap, nested selection and extra seeds.

- fit:

  `"fe"` fits each pattern with the groups absorbed (one intercept per
  group found by projection, so a fit's cost grows with the nuisance
  columns, not the groups; \#83), `"dense"` with one model-matrix column
  per group ([`stats::glm.fit()`](https://rdrr.io/r/stats/glm.html)).
  They give the same coefficients and deviances to numerical tolerance;
  `"fe"` falls back to `"dense"` on a fold where a nuisance level is a
  combination of groups.

- prior_sd:

  `numeric(1)` the standard deviation, on the cloglog scale, of a normal
  prior on every training fit's `data_set` and `era` coefficients, `Inf`
  for none. The fit adds `b^2 / prior_sd^2` per coefficient to the
  deviance (a ridge), so a coefficient costs more the further it sits
  from zero. These terms are in the model so that a rule is not credited
  for a sampling difference, and with a group intercept each is measured
  only by the contrast between the two levels inside the groups that
  hold both; where every detection of those groups sits on one level the
  contrast is separated and the unpenalised coefficient runs until the
  deviance stops moving (steelhead's `data_set` to 19.6, a hazard ratio
  past a hundred million, 2026-10-23). At 2.5 a measured effect of two
  or three units (chinook's data set, bull trout spawning's) is left
  nearly where it is and a runaway is held to a few units. The dense fit
  takes none.

## Value

A list: `rules`, the grid with `n_visits`, `n_detect`, `n_wsg`,
`unseen_level_visits`, `n_wsg_varies`, `converged`, `dev_heldout`,
`ddev_best`, `se_diff`, `ddev_null`, `in_region`, `n_in`, `n_detect_in`,
`raw_rate_in`, `raw_rate_out`, `pick`, `recommended`, `pick_flow`,
`recommended_flow` (`NA` with no flow start), and with `extra`
`boot_region_share`, `boot_rec_share` and `boot_rec_share_flow`;
`folds`, the fold of each group; `honest`, `seeds`, `boot_recs` (with
`extra`), and `population`, counts.

## Details

The **best** rule has the lowest score. A rule is in the **region** when
its score is within one SE of the best, the SE being `sqrt(n groups)` ×
the sd of the per-group differences from the best (the group is the
unit). The **pick** is the region rule with the fewest departures from
`default`, ties to the lower score. If the pick's exception distance is
under `d_floor` (where mainstem catches snapped to a tributary mouth
cannot be told apart), **recommended** is the pick among region rules
with `exc_d >= d_floor` or no exception; otherwise it is the pick. Where
the grid carries `departures_flow` (the departures from link's flow
version of `default`,
[`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)),
the same pick is made from that starting point too (`pick_flow`,
`recommended_flow`; \#80), on the same region: the region does not
depend on the start, only which of its rules is nearest. With
`extra = TRUE` the call also runs `n_boot` bootstrap resamples of groups
(each rule's share in the region, and the share of resamples
recommending each rule), a nested selection (the pick chosen on the
other folds' held-out deviance and scored on each fold, against
`default` and against the no-rule model) and the grid on `seeds_more`
more fold seeds (each reporting its best, pick and recommended rule,
whether `default` and the main reading's recommended rule are in its
region, and the region's size).

Groups where the response never or always occurs are left out (they
inform no contrast) and counted.

## Examples

``` r
# a small made-up population: two "rules", eight groups
set.seed(1)
d <- data.frame(wsg = factor(rep(sprintf("W%02d", 1:8), each = 30)),
                log_area = log(runif(240, 20, 400)), data_set = factor("FDIS"),
                era = factor("2005on"), size = runif(240, 0.05, 3))
d$U <- rbinom(240, 1, plogis(-3 + 1.5 * (d$size > 0.5)))
grid <- data.frame(rule = c("default", "tuned"), size_var = "mad", size_min = c(0.1, 0.5),
                   grad_max = 0.05, exc_q = NA, exc_d = NA, departures = c(0L, 1L),
                   is_default = c(TRUE, FALSE))
rule_in <- function(d, r) d$size >= r$size_min
s <- knw_tune_score(d, rule_in, grid, "U", seed = 1, workers = 1)
s$rules[, c("rule", "dev_heldout", "ddev_best", "se_diff", "in_region", "pick")]
#> # A tibble: 2 × 6
#>   rule    dev_heldout ddev_best se_diff in_region pick 
#>   <chr>         <dbl>     <dbl>   <dbl> <lgl>     <lgl>
#> 1 default        202.     0.513    3.74 TRUE      TRUE 
#> 2 tuned          202.     0        0    TRUE      FALSE
```
