# Tune every species and stage the evidence can speak to, in one run

For each species in `species` and each stage in `stages`: the scoring
population is cut, the rule grid built around link's own thresholds,
every rule scored on held-out groups
([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)),
and the curve fitted at the pick
([`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)).

## Usage

``` r
knw_tune_run(
  visits,
  species_tbl,
  walks,
  thresholds,
  species = knw_species(),
  stages = c("rear", "spawn"),
  spawner = NULL,
  edge_stream = c(1000L, 1100L, 2000L, 2300L),
  area_range = c(10, 10000),
  seed = 54L,
  folds = 5L,
  n_boot = 200L,
  seeds_more = 55:58,
  workers = 1L,
  d_floor = 200,
  min_wsg = 5L,
  power_wsg = 10L,
  src = "pick",
  grid_args = list(),
  cache_dir = NULL,
  thresholds_extra = NULL,
  previous = NULL,
  smoke = TRUE,
  smoke_only = FALSE,
  smoke_args = list(),
  extra = TRUE,
  fit = c("fe", "dense"),
  prior_sd = 2.5,
  evidence_id = NULL
)
```

## Arguments

- visits:

  the build's `visits_link` table.

- species_tbl:

  the build's `visits_species` table.

- walks:

  the build's walks, as
  [`knw_link_walks()`](https://newgraphenvironment.github.io/knowledge/reference/knw_link_walks.md)
  returns them.

- thresholds:

  link's `parameters_habitat_thresholds.csv`.

- species, stages:

  which to run.

- spawner:

  `NULL`, or
  [`knw_spawner_evidence()`](https://newgraphenvironment.github.io/knowledge/reference/knw_spawner_evidence.md)'s
  table.

- edge_stream, area_range:

  the population's constants.

- seed, folds, n_boot, seeds_more, workers, d_floor, fit, prior_sd:

  passed to
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)
  (and `fit` and `prior_sd` to
  [`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md),
  `prior_sd` to
  [`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)).

- min_wsg, power_wsg:

  `integer(1)` the floors described above.

- src:

  `character(1)` the flow source the exception reads.

- grid_args:

  `list` of arguments passed to
  [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)
  for every species × stage (for example
  `list(grid_grad = c(0.03, 0.09, 0.15))`); empty for its defaults.

- cache_dir:

  `NULL`, or a directory where each species × stage's scored grid is
  saved as `<sp>_<stage>_score.rds` and read back on a rerun when the
  population has the same number of visits and the grid the same rows,
  in the same order (every
  [`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)
  column, so a moved `default` counts), and the settings the score was
  made with match (`fit`, `prior_sd`, `seed`, `folds`, `d_floor` and
  `extra`, recorded as `spec` by
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md));
  a cache written before the record is read back with a message naming
  the settings it is taken as. `n_boot`, `seed_boot` and `seeds_more`
  are not checked: a cache's bootstrap and extra-seed tables are read
  back whatever the run asked for, so give a run with different ones its
  own directory.

- thresholds_extra:

  `NULL`, or another bundle's `parameters_habitat_thresholds.csv`
  (link's `default_tuned`): each species' row joins its grid as the
  `is_link_tuned` candidate
  ([`knw_tune_grid()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_grid.md)).

- previous:

  `NULL`, or a named `character` vector of the previous pick's rule
  string per `"<sp>_<stage>"`, which the smoke run scores where present.

- smoke:

  `logical(1)` run the smoke run and its checks first.

- smoke_only:

  `logical(1)` return after the smoke run, scoring nothing.

- smoke_args:

  `list` of arguments passed to
  [`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md)
  (`tol_null`, `coef_max`).

- extra:

  `logical(1)` passed to
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md):
  the bootstrap, the nested selection and the extra fold seeds. `FALSE`
  is the development setting, which proves a scorer change on every
  species in a fraction of the time; a run that publishes keeps `TRUE`.

- evidence_id:

  `NULL`, or `character(1)` naming the evidence build the visits and
  walks came from (`scripts/0320` passes the md5s of the three derived
  tables). It joins the cache's settings, so a score made on another
  build of the same visit count is not read back as this one's.

## Value

A list with one element per species × stage (`"<sp>_<stage>"`): a list
with `species_code`, `stage`, `response`, `status` (`fitted`,
`underpowered`, `no_stream_rule`, `no_response`, `too_few_groups`,
`curve_failed`; `smoke` with `smoke_only`), `population`, and when
scored `smoke`
([`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md)'s
result, with `smoke`), `score`
([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)'s
result), `pick` (the recommended rule row) and `curve`
([`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)'s;
`NULL` with `curve_error` when its fit failed); `null_heldout` (the
held-out deviance with no rule over the grid's visits),
`null_heldout_curve` (the same model scored over the curve's own visits,
those with a size, a gradient and a distance, on the same folds) and
`grade_withheld`, `TRUE` when the curve's held-out deviance is no better
than `null_heldout_curve`: a curve that predicts held-out groups no
better than knowing nothing ranks segments no better either, so its
grades are withheld. The comparison is over one population because a
width rule's curve fits fewer visits than the grid (unmeasured streams
have no width), and each visit it drops would otherwise leave only its
own side.

## Details

The population follows `scripts/0297`: visits on the stream branch (FWA
edge types `edge_stream`, not in a river polygon, a wetland of at least
1 ha or a lake of at least 100 ha), with a fished area in `area_range`,
in groups where link's presence rule marks the species present, with no
code blocking the species' absence, and no natural barrier to the
species downstream before observation overrides (`barrier_dnstr_<sp>` is
`FALSE`). Rearing's response is detection (`U`, the species caught);
spawning's is spawner evidence (`S`) from `spawner`, which the export
carries for char only, so a species × stage with no response, no stream
rule in `default`, or fewer than `min_wsg` groups with both outcomes
gets a one-row record saying so and is not fitted. A species × stage
with fewer than `power_wsg` groups is fitted and labelled
`underpowered`.

Before any grid is scored, every species × stage that would be fitted
gets the smoke run
([`knw_tune_smoke()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_smoke.md);
\#84): a handful of rules on the main fold seed, and four checks on the
scorer. One failed check on any key stops the run, with every key's
report printed, so a scorer defect costs minutes, not the hours of the
full grid. `smoke_only = TRUE` returns after the smoke run (each record
carries `smoke`, and none is scored), which is how `scripts/0320` writes
the reports before it decides to score.

## Examples

``` r
if (FALSE) { # \dontrun{
thr <- read.csv("parameters_habitat_thresholds.csv")
out <- knw_tune_run(visits, species_tbl, walks, thr, species = c("CH", "BT"), workers = 6)
out$CH_rear$pick
} # }
```
