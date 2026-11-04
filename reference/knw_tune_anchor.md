# How far each starting point moved the pick from the best-scoring rule

The pick is the one-SE region's rule with the fewest departures from a
starting point
([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)),
so where the data cannot rank several rules apart, the start chooses
between them. This sets the two picks a tuning table holds beside the
rule the data score best, and counts how far apart they are, so how much
a baseline steered a published rule is a number rather than a reading
(#141, \#139).

## Usage

``` r
knw_tune_anchor(tune, d_floor = formals(knw_tune_score)$d_floor)
```

## Arguments

- tune:

  a tuning table as
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
  returns it or `scripts/0320` saves it (`<sp>_<stage>_tune.csv`, read
  as text or typed): `rule`, `size_var`, `size_min`, `grad_max`,
  `exc_q`, `exc_d`, `in_region`, `recommended`, `ddev_best` and
  `se_diff`; and `departures_flow` with `recommended_flow` where the
  table has a flow start (a table from before \#80, or a species with no
  flow start, has none).

- d_floor:

  `numeric(1)` the shortest exception distance (m) a pick may carry;
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)'s
  own by default, so the register's one value
  (`inst/method/settings.csv`) holds for both.

## Value

One row: `rule_recommended`, `recommended_ddev` and `recommended_se`
(the pick from `default`, its distance behind the best and that
distance's SE); the same for the flow start (`rule_recommended_flow`,
`recommended_flow_ddev`, `recommended_flow_se`; `NA` with no flow
start); `rule_best` and `best_n`; `rule_best_allowed`,
`best_allowed_ddev` and `best_is_allowed`; `rec_moved` and `flow_moved`
(each pick's departures from the best, 0 to 3), `rec_moved_allowed` and
`flow_moved_allowed` (from the best allowed) and `starts_apart` (between
the two picks), each with its parts (`rec_moved_parts` and so on:
`size`, `gradient` and `exception` joined by `+`, or `none`);
`rec_is_best`, `flow_is_best` (the pick is tied at the best) and
`starts_agree`.

## Details

The picks are the `recommended` rules, the ones published: from link's
`default` (`recommended`) and from its flow version (`recommended_flow`,
\#80). The best is every rule at `ddev_best == 0`: rules with the same
in/out on every visit are one fit and tie, so `rule_best` is the first
of them in grid order (as `scripts/0320`'s summary names it), `best_n`
counts them, and a pick's distance to the best is its fewest departures
from any of them, the first such rule in grid order naming the parts.
Two rules depart in the three parts the grid counts
([`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)):
the size test (its variable or floor), the gradient maximum and the
exception (its river size or distance, or one having it and the other
not).

No pick may carry an exception closer than `d_floor`, but the best may,
and then no start could reach it: part of the distance is the floor's,
not the start's. So each pick is also measured against the **best
allowed** rule, the best-scoring rule a pick may be: the lowest-scoring
rule in the region (which holds converged rules only) with no exception
or one at `d_floor` or more (ties as above). It is the best itself
wherever `best_is_allowed`; the best is not allowed when its exception
is under the floor, or when it did not converge (the best is the lowest
score over every rule).

## Examples

``` r
tune <- data.frame(
  rule = c("width>=1.5|g<=0.0549|none", "width>=2|g<=0.0549|none", "mad>=0.5|g<=0.0549|none",
           "width>=1|g<=0.0549|Q50@D500"),
  size_var = c("width", "width", "mad", "width"), size_min = c(1.5, 2, 0.5, 1), grad_max = 0.0549,
  exc_q = c(NA, NA, NA, 50), exc_d = c(NA, NA, NA, 500),
  departures_flow = c(1L, 1L, 0L, 2L), in_region = c(FALSE, TRUE, TRUE, TRUE),
  recommended = c(FALSE, TRUE, FALSE, FALSE), recommended_flow = c(FALSE, FALSE, TRUE, FALSE),
  ddev_best = c(20, 5.7, 11.6, 0), se_diff = c(9, 10.4, 13.9, 0)
)
# from default the pick is two parts from the best (its width floor and the exception),
# and the flow start picks another rule, one part from it
knw_tune_anchor(tune)[, c("rule_recommended", "rec_moved", "rec_moved_parts", "rule_recommended_flow",
                          "starts_apart", "starts_apart_parts")]
#>          rule_recommended rec_moved rec_moved_parts   rule_recommended_flow
#> 1 width>=2|g<=0.0549|none         2  size+exception mad>=0.5|g<=0.0549|none
#>   starts_apart starts_apart_parts
#> 1            1               size
```
