# Set a tuning run's pick beside the published one

After a change upstream (a link build, placement, a flow reload) the
first question is whether the pick moved. This answers it for one
species x stage from two tuning tables: the run's
([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
or `data/tune/dev/<key>_tune.csv`) and the published one
(`data/tune/<key>_tune.csv`). It says which rule each recommends and at
what gradient limit, whether the published rule is still in the run's
one-SE region, and how far its score sits behind the run's best, beside
where it sat in the published table. Deviances are compared only in
units of their own run: a rebuilt evidence changes the visits, so raw
held-out deviances of the two runs are not on one scale.

## Usage

``` r
knw_tune_pick_report(tune, published = NULL)
```

## Arguments

- tune:

  the run's tuning table: `rule`, `grad_max`, `recommended`,
  `in_region`, `ddev_best`, `se_diff` and `n_visits`.

- published:

  the published tuning table for the same species x stage, with the same
  columns, or `NULL` where none is published.

## Value

One row: `rule_run` and `grad_max_run` (the run's recommended rule),
`rule_published` and `grad_max_published`, `same_pick`,
`published_in_grid` (the published rule was scored in this run),
`published_in_region` (`NA` when not in the grid), `published_ddev` and
`published_se` (its distance behind the run's best and that distance's
standard error, in this run), `published_ddev_was` and
`published_se_was` (the same in the published table), `n_visits_run` and
`n_visits_published`.

## Examples

``` r
pub <- data.frame(rule = c("mad>=0.5|g<=0.07|none", "mad>=0.75|g<=0.09|none"),
                  grad_max = c(0.07, 0.09),
                  recommended = c(FALSE, TRUE), in_region = c(TRUE, TRUE), ddev_best = c(4, 0),
                  se_diff = c(6, 0), n_visits = 4858)
run <- transform(pub, recommended = c(TRUE, FALSE), ddev_best = c(0, 9), se_diff = c(0, 5))
knw_tune_pick_report(run, pub)   # the pick moved to 7 %, and the published 9 % rule left the region
#>                rule_run grad_max_run         rule_published grad_max_published
#> 1 mad>=0.5|g<=0.07|none         0.07 mad>=0.75|g<=0.09|none               0.09
#>   same_pick published_in_grid published_in_region published_ddev published_se
#> 1     FALSE              TRUE                TRUE              9            5
#>   published_ddev_was published_se_was n_visits_run n_visits_published
#> 1                  0                0         4858               4858
```
