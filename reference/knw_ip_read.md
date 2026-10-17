# Read the intrinsic-potential model registry, filtered by species

One row per intrinsic-potential (IP) model, species, life stage and
life-history form: where the model was built, how it represents flow and
valley confinement, and whether it was validated against fish. The
registry describes models and holds none of their numbers. A model's
thresholds and curve breakpoints are rows of the literature evidence
table
([`knw_literature_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_read.md))
carrying the same `model_id`, so the variables a model uses are the
variables of those rows. `scripts/0280` checks that link both ways on
model, species, stage and life-history form.

## Usage

``` r
knw_ip_read(path, species_code = NULL)
```

## Arguments

- path:

  `character(1)` path to the registry CSV.

- species_code:

  `character` species codes to keep, or `NULL` for all.

## Value

A `tibble` with the twenty-three registry columns, all `character`.

## Details

`citation_key`, `page` and `quote` support the flow claim: how the model
sizes streams, or, for `flow_metric = none`, the variables it does use.
`cited_source` names the original when that quote is a secondary account
of the model (Sheer et al. 2009 describing Burnett's, for example).
`flow_surrogate` is the metric a model used where its `flow_metric` was
not available (modelled width standing in for discharge), and differs
from it.

A model with a `validation` other than `none` also needs
`validation_result` and its own `validation_page`, `validation_quote`
and `validation_quote_source`; `validation_citation_key` names the
document that quote is in when it is not `citation_key`'s. A model with
`validation = none` carries none of them, since an absence cannot be
quoted (say what was read in `note`). Likewise `flow_source` is required
unless `flow_metric` is `none`; `flow_inputs` is required when the flow
is `modelled`; and a `none` flow has no source, inputs or surrogate. A
text quote is at least 20 characters. `model_id` is a lower-case
identifier that names one `model`, and a model x species x stage x form
appears once.

The registry is validated before filtering, so a bad row anywhere in the
file is an error whichever species is asked for. A requested species
absent from the registry is a warning.

## Examples

``` r
path <- tempfile(fileext = ".csv")
utils::write.csv(data.frame(
  model_id = "burnett2007", model = "CLAMS coastal IP", region = "Oregon Coast Range",
  species_code = "CO", life_stage = "rearing", life_history_form = NA,
  flow_metric = "mean_annual_flow", flow_source = "modelled",
  flow_inputs = "gauge;drainage_area;precipitation", flow_surrogate = NA,
  valley_confinement = "valley_width_index", validation = "none", validation_result = NA,
  citation_key = "key_a", cited_source = NA, page = "4",
  quote = "mean annual flow was estimated from drainage area", quote_source = "text",
  validation_citation_key = NA, validation_page = NA, validation_quote = NA,
  validation_quote_source = NA, note = NA
), path, row.names = FALSE, na = "")
knw_ip_read(path, species_code = "CO")
#> # A tibble: 1 × 23
#>   model_id    model region species_code life_stage life_history_form flow_metric
#>   <chr>       <chr> <chr>  <chr>        <chr>      <chr>             <chr>      
#> 1 burnett2007 CLAM… Orego… CO           rearing    NA                mean_annua…
#> # ℹ 16 more variables: flow_source <chr>, flow_inputs <chr>,
#> #   flow_surrogate <chr>, valley_confinement <chr>, validation <chr>,
#> #   validation_result <chr>, citation_key <chr>, cited_source <chr>,
#> #   page <chr>, quote <chr>, quote_source <chr>, validation_citation_key <chr>,
#> #   validation_page <chr>, validation_quote <chr>,
#> #   validation_quote_source <chr>, note <chr>
```
