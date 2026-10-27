# Score a handful of rules and gate the scorer before a full tuning run

Twice in \#73 a scorer defect showed in the first minutes of a tuning
run's output and was found only after hours had been spent on it (#84).
This scores the rules a defect shows on, no rule, `default`, link's
`default_tuned` row where the grid carries one (`is_link_tuned`), and
the previous pick where one is given, on the main fold seed alone, with
[`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)'s
fold setup and fits, and checks four things, each a hard stop in
[`knw_tune_run()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_run.md):

## Usage

``` r
knw_tune_smoke(
  d,
  rule_in,
  grid,
  resp = "U",
  previous = NULL,
  seed = 54L,
  folds = 5L,
  tol_null = 0.25,
  coef_max = 5,
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

- previous:

  `NULL`, or `character(1)` the rule string of the previous pick, which
  must be in `grid`.

- seed:

  `integer(1)` fold seed.

- tol_null:

  `numeric(1)` check 1's tolerance.

- coef_max:

  `numeric(1)` check 4's limit.

- fit, prior_sd:

  passed to the fits, as in
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md).

## Value

A list: `rules`, one row per smoke rule (`role`, `rule`, `dev_heldout`,
`ddev_null`, `n_clamp`, `dev_visit_max`, `converged`, `coef_max`,
`coef_max_term`, `coef_max_fold`); `checks`, one row per check (`check`,
`value`, `limit`, `pass`); `pass`, whether every check passed;
`null_insample` and `null_heldout`; `lines`, the report as text; and
`population`, counts.

## Details

1.  `null_ratio`: the no-rule model's held-out deviance over the
    in-sample null deviance on the same visits (each group at its own
    rate) is at most `1 + tol_null`. The held-out model refits each
    group's intercept on its own visits, so it can exceed the in-sample
    null only through the nuisance offsets it takes from training, never
    by multiples (grayling's no-rule model scored 8,397.5 held-out
    against about 848 on 2026-10-23).

2.  `clamp`: no visit's held-out deviance sits at the clamp,
    `-2 log(1e-12)` = 55.26, which is where a group intercept the search
    did not find puts every visit.

3.  `behind_null`: no rule's held-out deviance exceeds the no-rule
    model's by more than the no-rule deviance itself.

4.  `coef`: no training fit's non-group coefficient (the nuisance terms
    and the rule, on the cloglog scale) exceeds `coef_max` in size. The
    training fit is the same whatever the intercept search does, so this
    check reads the model, not the fix: a fold whose `data_set` and
    `era` coefficients sat near 13 was where the search stuck. On the
    eight keys of 2026-10-23 the sound fits' largest coefficient was
    3.63 and the separated fits' smallest 9.65, so the limit is 5: a
    hazard ratio past e^5 between data sets or eras is separation, not a
    measured effect.

## Examples

``` r
set.seed(1)
d <- data.frame(wsg = factor(rep(sprintf("W%02d", 1:8), each = 30)),
                log_area = log(runif(240, 20, 400)), data_set = factor("FDIS"),
                era = factor("2005on"), size = runif(240, 0.05, 3))
d$U <- rbinom(240, 1, plogis(-3 + 1.5 * (d$size > 0.5)))
grid <- data.frame(rule = c("default", "tuned"), size_var = "mad", size_min = c(0.1, 0.5),
                   grad_max = 0.05, exc_q = NA, exc_d = NA, departures = c(0L, 1L),
                   is_default = c(TRUE, FALSE))
sm <- knw_tune_smoke(d, function(d, r) d$size >= r$size_min, grid, "U", previous = "tuned", seed = 1)
sm$checks
#> # A tibble: 4 × 4
#>   check       value  limit pass 
#>   <chr>       <dbl>  <dbl> <lgl>
#> 1 null_ratio   1.01   1.25 TRUE 
#> 2 clamp        0      0    TRUE 
#> 3 behind_null  0    203.   TRUE 
#> 4 coef        14.3    5    FALSE
cat(sm$lines, sep = "\n")
#> smoke: 240 visits (39 detections) in 8 groups with both outcomes; 3 rules, 3 fits.
#>   null_ratio: no rule 203.1 held-out against 201.9 in-sample, ratio 1.006 (limit 1.25): pass
#>   clamp: 0 visits at 55.26 over 3 rules (limit 0): pass
#>   behind_null: no_rule (none) is +0.0 against no rule (limit 203.1): pass
#>   coef: rule 14.26 on fold 5 of default (default) (limit 5.0): FAIL
#>   default: default held-out 202.1 (-1.0 against no rule), converged TRUE
#>   previous: tuned held-out 201.6 (-1.5 against no rule), converged TRUE
```
