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
  cache_dir = NULL
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

- seed, folds, n_boot, seeds_more, workers, d_floor:

  passed to
  [`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md).

- min_wsg, power_wsg:

  `integer(1)` the floors described above.

- src:

  `character(1)` the flow source the exception reads.

- cache_dir:

  `NULL`, or a directory where each species × stage's scored grid is
  saved as `<sp>_<stage>_score.rds` and read back on a rerun when the
  population has the same number of visits.

## Value

A list with one element per species × stage (`"<sp>_<stage>"`): a list
with `species_code`, `stage`, `response`, `status` (`fitted`,
`underpowered`, `no_stream_rule`, `no_response`, `too_few_groups`,
`curve_failed`), `population`, and when scored `score`
([`knw_tune_score()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_score.md)'s
result), `pick` (the recommended rule row) and `curve`
([`knw_tune_curve()`](https://newgraphenvironment.github.io/knowledge/reference/knw_tune_curve.md)'s;
`NULL` with `curve_error` when its fit failed).

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

## Examples

``` r
if (FALSE) { # \dontrun{
thr <- read.csv("parameters_habitat_thresholds.csv")
out <- knw_tune_run(visits, species_tbl, walks, thr, species = c("CH", "BT"), workers = 6)
out$CH_rear$pick
} # }
```
