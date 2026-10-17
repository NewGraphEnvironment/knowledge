# Controlled vocabularies of the intrinsic-potential model registry

The values each controlled column of a registry read by
[`knw_ip_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_ip_read.md)
may take, beyond the `life_stage`, `life_history_form` and
`quote_source` it shares with
[`knw_literature_vocab()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_vocab.md).
A registry quote comes from the paper, with its page, so the evidence
table's `abstract` fallback is not one of them.

## Usage

``` r
knw_ip_vocab()
```

## Value

A named `list` of `character` vectors, one per controlled column.

## Details

`flow_metric` is the variable a model uses to say how big a stream is:
mean annual flow, summer low flow, channel width (bankfull or wetted;
say which in `note`), drainage area, precipitation, or `none`: the
variable the model's thresholds are written on. `flow_source` says how
the model obtained it: `gauged` (measured at gauges and assigned to
reaches), `modelled`, `field` (measured on the ground), or `unstated`,
when the only source is a secondary account that names the metric but
not how it was obtained. `flow_inputs` names what a modelled value was
built from, as a `;`-separated list: `gauge` records, `drainage_area`,
`precipitation`, a `hydrologic_model`, or `field_measurement`s of the
variable (field widths regressed on drainage area and precipitation are
`field_measurement;drainage_area;precipitation`). `valley_confinement`
is the confinement variable a model uses, if any. `validation` is how a
model was checked against fish: not at all, fish observations, redd
surveys, or densities.

## Examples

``` r
knw_ip_vocab()$flow_metric
#> [1] "mean_annual_flow" "summer_low_flow"  "channel_width"    "drainage_area"   
#> [5] "precipitation"    "none"            
```
