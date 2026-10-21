# Pick a rule again from a tuning table, at another width of the region

[`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
keeps every rule whose held-out score is within one standard error of
the best (the region) and picks the region rule with the fewest
departures from `default`, ties to the lower score, moving off a pick
whose exception distance is under `d_floor`. One standard error is a
parsimony rule of thumb fixed before the run, not a boundary of noise;
this replays the same pick from the saved table at any multiple of the
standard error, so a reader can see which picks hold under a stricter
bar (1.96).

## Usage

``` r
knw_tune_repick(tune, se_mult = 1, d_floor = 200)
```

## Arguments

- tune:

  a tuning table as
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
  returns it and `scripts/0320` saves it (`<sp>_<stage>_tune.csv`), in
  grid order: `rule`, `departures`, `exc_d`, `converged`, `dev_heldout`,
  `ddev_best` and `se_diff`.

- se_mult:

  `numeric(1)` the region's width in standard errors.

- d_floor:

  `numeric(1)` the shortest exception distance (m) a recommended rule
  may carry, as in
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md).

## Value

The recommended row of `tune` (one row), with `n_region`, the number of
rules in the region at `se_mult`.

## Details

The region is `converged & ddev_best <= se_mult * se_diff`, which at
`se_mult = 1` is the table's own `in_region`, so the pick at 1 is the
table's `recommended` rule.

## Examples

``` r
tune <- data.frame(
  rule = c("width>=1.5|g<=0.0549|none", "mad>=0.75|g<=0.09|Q3@D1000", "mad>=0.75|g<=0.0549|none"),
  departures = c(0L, 3L, 1L), exc_d = c(NA, 1000, NA), converged = TRUE,
  dev_heldout = c(1150, 1000, 1040), ddev_best = c(150, 0, 40), se_diff = c(60, 0, 25)
)
knw_tune_repick(tune)$rule              # 1 SE: only the best rule is close enough
#> [1] "mad>=0.75|g<=0.09|Q3@D1000"
knw_tune_repick(tune, se_mult = 1.96)$rule  # 1.96 SE: the one-departure rule joins, and is picked
#> [1] "mad>=0.75|g<=0.0549|none"
```
