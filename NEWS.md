# knowledge 0.4.2

* The README points at the published FDIS visit tables' second release, `knowledge/fdis/v2/`, which keeps one
  copy of a survey loaded under several collection ids and carries the crosswalk from v1's `site_visit` ids
  (#35).

# knowledge 0.4.1

* The package now sits at the repository root and installs with
  `pak::pak("NewGraphEnvironment/knowledge")`. `DESCRIPTION` gains `URL` (the new
  pkgdown site and the repository) and `BugReports`, and the `knw_pscis_pull()`
  example connects through the standard `PG*` environment variables.

# knowledge 0.4.0

* New evidence variable `instream_flow`: a flow need, the water a life stage
  needs while it is in the stream, kept apart from `discharge`, which is stream
  size (usually the MAD an intrinsic-potential model filters on). It takes
  `m3/s`, `cfs`, `percent MAD`, a `percentile` or a `percent exceedance`, and a
  `metric` naming the flow statistic it is held to (`instantaneous`,
  `daily_mean`, `7day_low`, `monthly_mean`, `monthly_median`, `unstated`). It
  carries no `parameter` or `model_id`, and the `*_mad_*` parameters now sit on
  `discharge` rows only. A `7day_low` row needs a note giving its return period.
* `depth` and `velocity` read in the unit the source wrote: `cm` and `ft` for
  depth, `cm/s` and `ft/s` for velocity, as well as `m` and `m/s`. A channel's
  bankfull depth is stream size and reads as `m bankfull`.
* Rows that changed variable or unit, so a filter on the old values returns
  fewer rows: data row 121 (a migration low flow, now `instream_flow` and coded
  `SALMON`), rows 250, 257 and 264 (bankfull depths, now `m bankfull`), and
  rows 497 and 498 (redd velocities, now `cm/s` as quoted).

# knowledge 0.3.1

* New evidence variable `groundwater`: upwelling, hyporheic exchange and
  springs. It takes no unit, so a `groundwater` row is a statement with no
  value, until a source gives an upwelling measure.

# knowledge 0.3.0

* `knw_literature_read()` requires a `metric` column, after `unit`: which
  statistic a temperature value is (daily maximum, MWMT, 7DADM, MWAT, 7DEC, a
  weekly, monthly, August, summer or annual mean, a constant laboratory
  exposure, or `unstated`), or which window a degree-day total accumulates over
  (`growing_season`, `to_hatch`, `to_emergence`, `annual`). A table without the
  column is refused. A temperature-family value needs a metric that fits its
  variable; a `none` row may name the one it searched for; every other row
  leaves it blank.
* New evidence variables `degree_days` (`degC-day`) and `air_temperature`
  (`degC`). Air temperature is its own variable because intrinsic-potential
  models use it as a proxy for water temperature. A cited `degree_days` row
  needs a `note` giving its base temperature.
* A `none` row may carry `bound`, naming the limit that was searched for.
* New `kind` `lab`: a laboratory or hatchery measurement (a lethal limit,
  CTmax, survival or growth at held temperatures, a development time in
  degree-days), which is not expert opinion.
* A `qual` row is refused a value: it is a statement, and a value on it would
  be counted as evidence it is not.

# knowledge 0.2.1

* `knw_literature_vocab()` adds `elevation` to the `variable` vocabulary, in
  `m` or `ft`, so a source that fits an elevation term (a watershed-scale
  occurrence coefficient, say) can be recorded. Other units are refused.

# knowledge 0.2.0

* `knw_ip_read()` and `knw_ip_vocab()` read and validate the intrinsic-potential
  model registry: one row per model, species and life stage, recording how the
  model sizes streams (`flow_metric`, `flow_source`, `flow_inputs`,
  `flow_surrogate`), its valley-confinement variable and whether it was
  validated against fish, each claim with a verbatim quote.
* `knw_literature_read()` requires a `model_id` column (its value may be
  blank), linking a threshold to the registry model that uses it. A table
  without the column is refused.
* `parameter` is now a controlled vocabulary (the habitat-model parameter
  names, in `knw_literature_vocab()`), so a misspelt or invented parameter is
  refused rather than silently matching nothing.
* New evidence variables `valley_width_index` (`ratio`) and `drainage_area`
  (`km2`, `mi2`); `cfs` for discharge and `ft` for channel width are read as the
  source wrote them.

# knowledge 0.1.0

* First version: PSCIS pulls by watershed group, GNIS collision checks, size
  classes, and readers for the life-history timing and literature evidence
  tables.
