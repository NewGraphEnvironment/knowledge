# One curve per species and stage: use against size, gradient and distance to a river, together

After
[`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
has picked a rule, one GAM fits the rule's variables together on the
scoring population: a tensor smooth of log size (the pick's size
variable, width or MAD) and log distance downstream to the first river
of the pick's `exc_q` m³/s, a smooth of gradient, and the same nuisance
terms as the scorer (`log_area`, data set, era) with the watershed group
as a random effect; binomial with a complementary log-log link, REML.
The data-set and era coefficients carry the scorer's normal prior
(`prior_sd`): where the two nearly coincide (steelhead's FDIS visits are
its 1995-2004 visits) an unpenalised fit sends them to about +-30 with
offsetting signs, and a held-out group that mixes the combinations takes
one of those offsets. A distance the walk did not find (`Inf`) is
censored at `dist_cap_m`, and distance enters as `log(dist + 10)`. The
model is one surface, never a product of one-variable curves, so a size
effect that only holds far from a river is not counted twice.

## Usage

``` r
knw_tune_curve(
  d,
  pick,
  walks,
  folds,
  resp = "U",
  cols = c(grad = "segment_gradient", width = "cw_deploy", mad = "mad_pick"),
  src = "pick",
  dist_cap_m = 50000,
  q_default = 10,
  k = c(size = 6, dist = 6, grad = 6),
  edge_stream = NULL,
  prior_sd = 2.5
)
```

## Arguments

- d:

  the scoring population, with `resp`, `wsg`, `log_area`, `data_set`,
  `era`, `blue_line_key`, `downstream_route_measure` and the columns
  `cols` name.

- pick:

  one row of the scored grid: `size_var`, `size_min`, `grad_max`,
  `exc_q`, `exc_d`. With no exception, distance is to a river of
  `q_default`.

- walks:

  the index
  [`knw_walk_index()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_index.md)
  returns.

- folds:

  the named fold of each group, as
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
  returns it.

- resp, cols, src:

  as in
  [`knw_rule_in()`](https://newgraphenvironment.github.io/knowledge/reference/knw_rule_in.md).

- dist_cap_m, q_default, k:

  `numeric` the spec's constants: the distance cap, the river size when
  the pick has no exception, and the basis sizes (`size`, `dist`,
  `grad`).

- edge_stream:

  `integer` or `NULL`: the FWA edge types the visits in `d` were
  filtered on, recorded on the result as `edge_stream` so the grade's
  reference population can be taken from the curve (#72).

- prior_sd:

  `numeric(1)` the standard deviation, on the cloglog scale, of a normal
  prior on the `data_set` and `era` coefficients, as in
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md):
  a fixed penalty `b^2 / prior_sd^2` per coefficient. `Inf` for none
  (the curve before \#73's Phase 7).

## Value

A list: `model` (the
[`mgcv::gam`](https://rdrr.io/pkg/mgcv/man/gam.html)), `data` (the rows
fitted, with `log_size`, `log_dist`, `grad`), `ref` (the reference
nuisance values a segment is predicted at: median `log_area`, modal
`data_set`, latest `era`), `dropped` (visits with no size or gradient),
`capped` (visits kept at the distance cap: no walk, or no river found),
`heldout` (summed held-out deviance), `edf` (the smooths' effective
degrees of freedom), and `curves`, a `tibble` of marginal curves
(`curve`, `x`, `rate`, `rel_rate`, `rel_lo`, `rel_hi`, `threshold`)
relative to the pick's thresholds, each other variable held at its
reference; `edge_stream`, as given; `dist_in_model`, `FALSE` when the
distances were too few to carry a smooth and size stood alone;
`prior_sd` and `cols`, as given (`cols[["grad"]]` is the gradient the
curve was fitted on, which a grade table records, \#92).

## Details

Its held-out deviance is reported on the scorer's own folds: the fixed
terms are refit on the other folds, and each held-out group refits only
its own intercept, as the grid's rules did, so the two numbers compare.

## Examples

``` r
if (FALSE) { # \dontrun{
s <- knw_tune_score(d, rule_in, grid, "U")
cv <- knw_tune_curve(d, s$rules[s$rules$recommended, ], knw_walk_index(walks), s$folds)
cv$heldout; cv$edf
} # }
```
