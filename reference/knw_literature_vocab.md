# Controlled vocabularies of the literature evidence table

The values each controlled column of a table read by
[`knw_literature_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_literature_read.md)
may take. `life_stage` is
[`knw_timing_stages()`](https://newgraphenvironment.github.io/knowledge/reference/knw_timing_stages.md)
plus `access`. `life_history_form` separates stream- and ocean-type
Chinook and resident, fluvial and adfluvial bull trout; `migratory` is
for a source that says "migratory" without separating fluvial from
adfluvial. US units (`cfs`, `mi2`, `ft`, `ft/s`) are kept as the source
wrote them. Width units say which width a source measured, because
bankfull and wetted width are not interchangeable. `parameter` is the
habitat-model parameter a row bears on, one of the model's own names, or
blank. `kind` says what sort of number a row is: a parameter someone
chose, a habitat-suitability breakpoint, the largest value observed, a
statistic of where fish were found, a preference, expert opinion, a
laboratory or hatchery measurement (`lab`: a lethal limit, CTmax,
survival or growth at held temperatures, or a development time in
degree-days), a qualitative statement, or `none`, a search that found
nothing. `quote_source` says how a quote can be checked against its PDF:
running `text`, a `table` cell (checked by its numbers), or `ocr` of a
scan with no text layer. `abstract` is the fallback for a work whose PDF
cannot be had: the quote is checked against the publisher's abstract,
held as the reference item's abstract, and so carries no page. An
abstract states less than the paper (often not which body length was
measured, or how), so a row resting on one says only what the abstract
says. `scale` is the grain a value was measured at: a redd or
microhabitat `site`, a surveyed `reach`, a model `segment`, or a
`network` summary; a site value is not a reach cutoff.

## Usage

``` r
knw_literature_vocab()
```

## Value

A named `list` of `character` vectors, one per controlled column.

## Details

`metric` says which statistic a `temperature` or `air_temperature` value
is (a daily maximum, `mwmt` the maximum weekly maximum, `7dadm` the
7-day average of daily maxima, `mwat` the maximum weekly mean, `7dec`
the 7-day equivalent constant midway between 7DADM and MWAT, a weekly,
monthly, August, summer or annual mean, a `constant` laboratory
exposure), and over which window a `degree_days` value accumulates
(`growing_season` as `gsdd` defines it after Coleman and Fausch 2007,
`to_hatch` or `to_emergence` from fertilization, or `annual`).
`unstated` is for a source that gives a value without saying. Air
temperature is its own variable because models use it as a proxy for
water temperature, and the two are not interchangeable.

`discharge` is stream size: a flow statistic used to say how big a
channel is, usually its mean annual discharge (MAD), the filter an
intrinsic-potential model applies, sometimes a summer flow used the same
way. `instream_flow` is a flow need: the water a life stage needs while
it is in the stream, which the stage's window in
[`knw_timing_read()`](https://newgraphenvironment.github.io/knowledge/reference/knw_timing_read.md)
places in the year. The two are not interchangeable, so of the two only
`instream_flow` takes a `metric`, the statistic the flow is held to (an
`instantaneous` flow, a daily or monthly mean, a monthly median, a
`7day_low` average). A need written as a fraction of MAD is in
`percent MAD`, which fits no other variable. A need written as a point
in a flow distribution is a `percentile` (the 90th percentile is a high
flow) or a `percent exceedance` (Q95, the flow exceeded 95 % of the
time, is a low one); the two run in opposite directions, so the unit
says which the source used, and the metric which flows were ranked. A
`7day_low` row gives its return period (7Q2, 7Q10) in the note. A flow
need is no model's stream-size filter, so it carries no `parameter` or
`model_id`, and the `*_mad_*` parameters belong to `discharge` rows
alone.

`depth` and `velocity` are what a fish meets at a site (a redd, a
passage riffle, a rearing position), in the unit the source wrote (`cm`,
`ft`, `cm/s`, `ft/s` as well as `m` and `m/s`). A channel's bankfull
depth is stream size, and is written in `m bankfull`.

`fish_length` is a body length a source ties to survival or recruitment
(an age-0 fish's size at the onset of its first winter, say), not a
habitat dimension. It reads in `mm`, and its `metric` says which length
the source measured: `fork_length`, `total_length`, or `unstated`.

`groundwater` covers upwelling, hyporheic exchange and springs. It takes
no unit, so a groundwater row carries no value: no source read so far
gives an upwelling measure (a vertical hydraulic gradient, say).

## Examples

``` r
knw_literature_vocab()$variable
#>  [1] "gradient"           "channel_width"      "stream_order"      
#>  [4] "discharge"          "lake_area"          "wetland_area"      
#>  [7] "bridge_distance"    "temperature"        "substrate"         
#> [10] "depth"              "velocity"           "timing"            
#> [13] "valley_width_index" "drainage_area"      "elevation"         
#> [16] "air_temperature"    "degree_days"        "groundwater"       
#> [19] "instream_flow"      "fish_length"       
```
