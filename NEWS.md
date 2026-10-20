# knowledge (development version)

* The grade reads every segment at its own distance to a river (#65). `knw_grade_species()` used to walk only the
  segments the rule's exception could admit and read the rest at the 50 km distance cap, which on the joint size
  and distance curve understates any segment near a river: every key was affected, and six of the eight walked
  nothing at all. It now walks every accessible segment with a gradient to the pick's exception river (10 m³/s
  where it has none) and records `dist_status`. The reference rate that reads 1 is now taken over the stream
  branch, the edge types the curve was fitted on: river-polygon and lake segments, about 0 m from their river,
  would otherwise set it (chinook's 0.52 over every accessible segment against 0.14). `knw_grade()` gains
  `ref_rows` and `knw_grade_species()` gains `ref_edge` for this, in place of its unused `edge_stream`.
  `habitat_grade/v1`, never uploaded, is regraded before its first publication. The thresholds, `default`'s km and
  the width rules' km do not move; the flow-ruled tuned rules move by under 0.3 % because wet republished the
  segment flows the same day (NewGraphEnvironment/wet#103), and retuning on those flows is #73.

# knowledge 0.4.5

* `knw_tune_run()` gains `grid_args`, passed to `knw_tune_grid()`, and reads a cached score back only for the grid
  it was scored on (#67). `scripts/0322` scored chinook rearing on gradient limits up to 30 %: the best rule moves
  from 9 % to 15 %, and every limit from 7 to 30 % has rules in the region, but choosing among the longer ladder loses
  to `default` under nested selection. `CH_rear_v1` keeps 9 %; extending the ladder for every species is #68. The
  chinook rearing article says so.

# knowledge 0.4.4

* A pkgdown article, `vignette("chinook_rearing")`, explains in plain language how the chinook rearing threshold
  was chosen from the province's electrofishing records and what it changes on link's segments, with a Bulkley
  map, a zoom and three labelled example segments (#62). Its data are written by `data-raw/vignette_chinook.R`
  to `inst/vignette-data/`, and a test fails when a tracked source moves on. `knw_compare_map()` gains `ncol`,
  `panels`, `mark`, `lwd`, `legend` and `labels`; its default output is unchanged. The package now declares
  R >= 4.1.0.

# knowledge 0.4.3

* One evidence build, one tuning run and one comparison across species and life stages, as package functions on
  link's province-wide `default` run (#57): `knw_fdis_visits()`, `knw_link_place()`, `knw_link_flow()`,
  `knw_link_width()`, `knw_link_walks()`, `knw_link_barrier_dnstr()`, `knw_bcfishobs_match()` and
  `knw_link_access_check()` build the evidence; `knw_tune_grid()`, `knw_tune_score()`, `knw_tune_curve()`,
  `knw_grade()` and `knw_tune_run()` score every rule of each species and stage on held-out watershed groups, pick,
  fit the joint curve and grade every segment; `knw_thresholds_table()` and `knw_publish()` write the thresholds and
  grade tables; `knw_compare_rules()`, `knw_floodplain_ha()` and `knw_compare_map()` show what a rule changes on
  link's segments (km, graded km, floodplain hectares, maps). Scripts `0300`–`0330` run them.
* Eight species × stage fit. `default` is outside the one-SE region for every species but grayling; chinook's
  size floor settles at 0.75 m³/s; bull trout spawning fits but is weak. `data/thresholds.csv` and
  `data/thresholds_groups.csv` carry the result in link's parameter names; `0290`, `0294` and `0296` write their
  tables from the new build, and `0291`–`0298` read the published v2 visit tables (`0299 PULL=TRUE VERSION=v2`).
  Results: `research/habitat_thresholds_tuned.md` and one file per species.

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
