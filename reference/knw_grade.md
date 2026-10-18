# Grade segments by expected use, 0 to 1

A segment's grade is the curve's predicted detection rate at the
segment's size, gradient and distance to a river, at the reference
nuisance values and with the group random effect excluded (so grades
compare across groups), divided by the `ref_quantile` of that rate over
the species' accessible segments, and capped at 1. The top of the
accessible network reads 1, and a segment at a third of that rate reads
about 0.3. It is expected use per standard electrofishing visit, not
habitat quality, and is labelled so.

## Usage

``` r
knw_grade(
  curve,
  segments,
  cols = c(size = "mad_pick", grad = "gradient", dist = "dist_m"),
  ref_quantile = 0.95,
  classes = c(0, 0.2, 0.4, 0.6, 0.8, 1)
)
```

## Arguments

- curve:

  the list
  [`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)
  returns.

- segments:

  `data.frame` with `accessible` (logical) and the columns `cols` name:
  the size variable the curve was fit on, the gradient, and `dist_m`
  (metres to the first river of the curve's `q`; `NA` or `Inf` where
  none).

- cols:

  named `character`: `size`, `grad`, `dist`.

- ref_quantile:

  `numeric(1)` the quantile of accessible segments' rate that reads 1.

- classes:

  `numeric` the class breaks on the grade.

## Value

A list: `grades`, a `tibble` of `nrow(segments)` with `rate`, `grade`,
`grade_class`; `reference`, the rate that reads 1; `dropped`, counts of
segments with no size or gradient.

## Details

A segment whose size variable is missing (an unmeasured first-order
stream under a width model; a segment with no flow even from a parent
under a MAD model) or whose gradient is missing gets `NA`, and the
counts come back. A distance the walk did not find, or a segment with no
walk, is the cap (`dist_cap_m`): far from any river.

## Examples

``` r
if (FALSE) { # \dontrun{
g <- knw_grade(cv, seg, cols = c(size = "mad_pick", grad = "gradient", dist = "dist_m"))
table(g$grades$grade_class, useNA = "ifany")
} # }
```
