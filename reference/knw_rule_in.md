# Whether each visit is in under one rule, on the stream branch

`scripts/0297`'s rule: a visit on a stream edge is in when its gradient
lies in `[0, grad_max]` and either the size test holds (width in
`[size_min, 9999]`, or MAD at least `size_min`) or the exception does (a
river of at least `exc_q` m³/s within `exc_d` m downstream on the flow
source `src`). A `NA` gradient, width or MAD fails its test. The river,
wetland and lake branches of link's rules are constant across the rules
a grid varies, so a scoring population holds stream-branch visits only,
and a visit off the stream edges is out here.

## Usage

``` r
knw_rule_in(
  d,
  rule,
  walks = NULL,
  cols = c(grad = "fwa_gradient", width = "cw_deploy", mad = "mad_pick"),
  src = "pick",
  edge_stream = c(1000L, 1100L, 2000L, 2300L),
  no_lake_target = FALSE,
  no_reg_target = FALSE
)
```

## Arguments

- d:

  `data.frame` of visits with `edge_type`, `blue_line_key`,
  `downstream_route_measure` and the columns named by `cols`.

- rule:

  one row of
  [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)'s
  table.

- walks:

  the index
  [`knw_walk_index()`](https://newgraphenvironment.github.io/knowledge/reference/knw_walk_index.md)
  returns, or `NULL` when no rule in play has an exception.

- cols:

  named `character`: which columns of `d` carry `grad`, `width` and
  `mad`.

- src:

  `character(1)` the flow source the exception reads.

- edge_stream:

  `integer` the stream-branch edge types.

- no_lake_target, no_reg_target:

  `logical(1)` fail the exception where the river found is a lake
  segment, or lies on a regulated reach.

## Value

`logical` of `nrow(d)`.

## Examples

``` r
d <- data.frame(edge_type = c(1000, 1000, 1250), blue_line_key = 1, downstream_route_measure = 1:3,
                fwa_gradient = c(0.02, 0.02, 0.01), cw_deploy = c(2, 1, 50), mad_pick = c(0.3, 0.1, 40))
r <- data.frame(size_var = "width", size_min = 1.5, grad_max = 0.0549, exc_q = NA, exc_d = NA)
knw_rule_in(d, r)
#> [1]  TRUE FALSE FALSE
```
