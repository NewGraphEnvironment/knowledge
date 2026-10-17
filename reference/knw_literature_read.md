# Read the literature evidence table, filtered by species and variable

One row per value a source gives for a habitat variable: species, life
stage, life-history form, variable, the model parameter it bears on
(`parameter`, e.g. `spawn_gradient_max`), bound, value, unit, metric,
kind, region, citation key, page and a verbatim quote. `value_min` and
`value_max` are numbers written as text, or `MM-DD` for `timing`, where
a range with `value_min > value_max` crosses 1 January. Gradient is in
percent, as sources write it; a model that stores gradient as a
proportion divides by 100. `cited_source` names the original study when
the quote is a secondary citation of it. `model_id` links a row to the
intrinsic-potential model it states a threshold of, as described in the
registry read by
[`knw_ip_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_ip_read.md);
it is blank for a row that is not a model's parameter.

## Usage

``` r
knw_literature_read(path, species_code = NULL, variable = NULL)
```

## Arguments

- path:

  `character(1)` path to the evidence CSV.

- species_code:

  `character` species codes to keep, or `NULL` for all.

- variable:

  `character` variables to keep (see
  [`knw_literature_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_vocab.md)),
  or `NULL` for all.

## Value

A `tibble` with the twenty columns, all `character`.

## Details

The unit must fit the variable (percent for gradient, a width unit for
channel width, and so on) and a bound must sit on its value: `min` on
`value_min`, `max` on `value_max`, `range` on both. A text quote is at
least 20 characters, so that a check against the PDF can tell it apart
from noise. A `temperature`, `air_temperature`, `degree_days`,
`instream_flow` or `fish_length` value needs a `metric` that fits its
variable, and a `none` row may name the metric it searched for; every
other row leaves `metric` blank. A cited `degree_days` row needs a
`note`, which gives the base temperature.

A `qual` row is a statement with no value. A row of kind `none` records
a search that found no value: it carries a `note` saying what was
searched and no value, key or quote. Its `bound` and `metric`, when
given, name what was searched for (an upper limit, a degree-day total to
emergence). Every other row needs a `citation_key` and a `quote`. A row
with a value needs a `unit`.

The table is validated before filtering, so a bad row anywhere in the
file is an error whichever species is asked for. A requested species or
variable absent from the table is a warning, so a typo does not read as
"no evidence".

## Examples

``` r
path <- tempfile(fileext = ".csv")
utils::write.csv(data.frame(
  species_code = "BT", life_stage = "spawning", life_history_form = "migratory",
  variable = "channel_width", parameter = "spawn_channel_width_min", bound = "min",
  value_min = "2", value_max = NA, unit = "m wetted", metric = NA, kind = "expert",
  region = "Parsnip, BC", citation_key = "key_a", page = "22",
  quote = "No streams of <2 m wetted width were surveyed", quote_source = "text",
  scale = "reach", cited_source = NA, note = NA, model_id = NA
), path, row.names = FALSE, na = "")
knw_literature_read(path, species_code = "BT", variable = "channel_width")
#> # A tibble: 1 × 20
#>   species_code life_stage life_history_form variable   parameter bound value_min
#>   <chr>        <chr>      <chr>             <chr>      <chr>     <chr> <chr>    
#> 1 BT           spawning   migratory         channel_w… spawn_ch… min   2        
#> # ℹ 13 more variables: value_max <chr>, unit <chr>, metric <chr>, kind <chr>,
#> #   region <chr>, citation_key <chr>, page <chr>, quote <chr>,
#> #   quote_source <chr>, scale <chr>, cited_source <chr>, note <chr>,
#> #   model_id <chr>
```
