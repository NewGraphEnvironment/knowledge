#' Controlled vocabularies of the literature evidence table
#'
#' The values each controlled column of a table read by [knw_literature_read()]
#' may take. `life_stage` is [knw_timing_stages()] plus `access`.
#' `life_history_form` separates stream- and ocean-type Chinook and resident,
#' fluvial and adfluvial bull trout; `migratory` is for a source that says
#' "migratory" without separating fluvial from adfluvial. US units (`cfs`,
#' `mi2`, `ft`, `ft/s`) are kept as the source wrote them. Width units say
#' which width a source measured, because bankfull and wetted width are not
#' interchangeable. `parameter` is the habitat-model parameter a row bears on,
#' one of the model's own names, or blank. `kind` says what sort of number a row is: a parameter
#' someone chose, a habitat-suitability breakpoint, the largest value observed,
#' a statistic of where fish were found, a preference, expert opinion, a
#' laboratory or hatchery measurement (`lab`: a lethal limit, CTmax, survival
#' or growth at held temperatures, or a development time in degree-days), a
#' qualitative statement, or `none`, a search that found nothing.
#' `quote_source` says how a quote can be checked against its PDF: running
#' `text`, a `table` cell (checked by its numbers), or `ocr` of a scan with no
#' text layer. `scale` is the grain a value was measured at: a redd or
#' microhabitat `site`, a surveyed `reach`, a model `segment`, or a `network`
#' summary; a site value is not a reach cutoff.
#'
#' `metric` says which statistic a `temperature` or `air_temperature` value is
#' (a daily maximum, `mwmt` the maximum weekly maximum, `7dadm` the 7-day
#' average of daily maxima, `mwat` the maximum weekly mean, `7dec` the 7-day
#' equivalent constant midway between 7DADM and MWAT, a weekly, monthly,
#' August, summer or annual mean, a `constant` laboratory exposure), and over
#' which window a `degree_days` value accumulates (`growing_season` as `gsdd`
#' defines it after Coleman and Fausch 2007, `to_hatch` or `to_emergence` from
#' fertilization, or `annual`).
#' `unstated` is for a source that gives a value without saying. Air
#' temperature is its own variable because models use it as a proxy for water
#' temperature, and the two are not interchangeable.
#'
#' `discharge` is stream size: a flow statistic used to say how big a channel
#' is, usually its mean annual discharge (MAD), the filter an intrinsic-potential
#' model applies, sometimes a summer flow used the same way. `instream_flow` is a flow
#' need: the water a life stage needs while it is in the stream, which the
#' stage's window in [knw_timing_read()] places in the year. The two are not
#' interchangeable, so of the two only `instream_flow` takes a `metric`, the
#' statistic the flow is held to (an `instantaneous` flow, a daily, monthly or
#' seasonal mean, a monthly median, a `7day_low` average). A need written as a
#' fraction of MAD is in `percent MAD`, which fits no other variable. A need
#' written as a point in a flow distribution is a `percentile` (the 90th
#' percentile is a high flow) or a `percent exceedance` (Q95, the flow exceeded
#' 95 % of the time, is a low one); the two run in opposite directions, so the
#' unit says which the source used, and the metric which flows were ranked. A
#' `7day_low` row gives its return period (7Q2, 7Q10) in the note. A flow need
#' is no model's stream-size filter, so it carries no `parameter` or `model_id`,
#' and the `*_mad_*` parameters belong to `discharge` rows alone.
#'
#' `depth` and `velocity` are what a fish meets at a site (a redd, a passage
#' riffle, a rearing position), in the unit the source wrote (`cm`, `ft`,
#' `cm/s`, `ft/s` as well as `m` and `m/s`). A channel's bankfull depth is stream
#' size, and is written in `m bankfull`.
#'
#' `groundwater` covers upwelling, hyporheic exchange and springs. It takes no
#' unit, so a groundwater row carries no value: no source read so far gives an
#' upwelling measure (a vertical hydraulic gradient, say).
#'
#' @return A named `list` of `character` vectors, one per controlled column.
#' @export
#' @examples
#' knw_literature_vocab()$variable
knw_literature_vocab <- function() {
  list(
    life_stage = c(knw_timing_stages(), "access"),
    life_history_form = c("stream_type", "ocean_type", "resident", "fluvial", "adfluvial",
                          "migratory"),
    variable = c("gradient", "channel_width", "stream_order", "discharge", "lake_area",
                 "wetland_area", "bridge_distance", "temperature", "substrate", "depth",
                 "velocity", "timing", "valley_width_index", "drainage_area", "elevation",
                 "air_temperature", "degree_days", "groundwater", "instream_flow"),
    parameter = c("spawn_gradient_max", "spawn_gradient_min", "spawn_channel_width_min",
                  "spawn_mad_min", "rear_gradient_max", "rear_channel_width_min", "rear_mad_min",
                  "rear_mad_max", "rear_lake_ha_min", "rear_wetland_ha_min", "access_gradient_max",
                  "cluster_bridge_gradient", "cluster_bridge_distance"),
    bound = c("min", "max", "range", "optimum"),
    unit = c("percent", "m bankfull", "m wetted", "m", "order", "m3/s", "ha", "km", "degC",
             "mm", "m/s", "MM-DD", "ratio", "km2", "cfs", "mi2", "ft", "degC-day", "percent MAD",
             "cm", "cm/s", "ft/s", "percentile", "percent exceedance"),
    metric = unique(unlist(.knw_metric_fits(), use.names = FALSE)),
    kind = c("param", "hsi", "max_obs", "dist", "pref", "expert", "lab", "qual", "none"),
    quote_source = c("text", "table", "ocr"),
    scale = c("site", "reach", "segment", "network")
  )
}

# Which metrics each variable takes: a statistic of temperature, the window a
# degree-day total accumulates over, or the statistic a flow need is held to.
# Variables not named here carry no metric.
.knw_metric_fits <- function() {
  temp <- c("daily_max", "daily_mean", "mwmt", "7dadm", "mwat", "7dec", "weekly_mean",
            "monthly_mean", "august_mean", "summer_mean", "annual_mean", "constant", "unstated")
  list(temperature = temp, air_temperature = temp,
       degree_days = c("growing_season", "to_hatch", "to_emergence", "annual", "unstated"),
       instream_flow = c("instantaneous", "daily_mean", "7day_low", "monthly_mean", "monthly_median",
                         "seasonal_mean", "unstated"))
}

#' Read the literature evidence table, filtered by species and variable
#'
#' One row per value a source gives for a habitat variable: species, life
#' stage, life-history form, variable, the model parameter it bears on
#' (`parameter`, e.g. `spawn_gradient_max`), bound, value, unit, metric, kind, region,
#' citation key, page and a verbatim quote. `value_min` and `value_max` are
#' numbers written as text, or `MM-DD` for `timing`, where a range with
#' `value_min > value_max` crosses 1 January. Gradient is in percent, as sources
#' write it; a model that stores gradient as a proportion divides by 100.
#' `cited_source` names the original study when the quote is a secondary
#' citation of it. `model_id` links a row to the intrinsic-potential model it
#' states a threshold of, as described in the registry read by [knw_ip_read()];
#' it is blank for a row that is not a model's parameter.
#'
#' The unit must fit the variable (percent for gradient, a width unit for
#' channel width, and so on) and a bound must sit on its value: `min` on
#' `value_min`, `max` on `value_max`, `range` on both. A text quote is at least
#' 20 characters, so that a check against the PDF can tell it apart from noise.
#' A `temperature`, `air_temperature`, `degree_days` or `instream_flow` value needs a `metric`
#' that fits its variable, and a `none` row may name the metric it searched
#' for; every other row leaves `metric` blank. A cited
#' `degree_days` row needs a `note`, which gives the base temperature.
#'
#' A `qual` row is a statement with no value. A row of kind `none` records a search that found no value: it carries a
#' `note` saying what was searched and no value, key or quote. Its `bound`
#' and `metric`, when given, name what was searched for (an upper limit, a
#' degree-day total to emergence). Every other row
#' needs a `citation_key` and a `quote`. A row with a value needs a `unit`.
#'
#' The table is validated before filtering, so a bad row anywhere in the file is
#' an error whichever species is asked for. A requested species or variable
#' absent from the table is a warning, so a typo does not read as "no evidence".
#'
#' @param path `character(1)` path to the evidence CSV.
#' @param species_code `character` species codes to keep, or `NULL` for all.
#' @param variable `character` variables to keep (see [knw_literature_vocab()]),
#'   or `NULL` for all.
#' @return A `tibble` with the twenty columns, all `character`.
#' @export
#' @examples
#' path <- tempfile(fileext = ".csv")
#' utils::write.csv(data.frame(
#'   species_code = "BT", life_stage = "spawning", life_history_form = "migratory",
#'   variable = "channel_width", parameter = "spawn_channel_width_min", bound = "min",
#'   value_min = "2", value_max = NA, unit = "m wetted", metric = NA, kind = "expert",
#'   region = "Parsnip, BC", citation_key = "key_a", page = "22",
#'   quote = "No streams of <2 m wetted width were surveyed", quote_source = "text",
#'   scale = "reach", cited_source = NA, note = NA, model_id = NA
#' ), path, row.names = FALSE, na = "")
#' knw_literature_read(path, species_code = "BT", variable = "channel_width")
knw_literature_read <- function(path, species_code = NULL, variable = NULL) {
  chk::chk_file(path)
  chk::chk_null_or(species_code, vld = chk::vld_character)
  chk::chk_null_or(variable, vld = chk::vld_character)
  if ((!is.null(species_code) && !length(species_code)) ||
      (!is.null(variable) && !length(variable))) {
    stop("an empty filter matches nothing; pass NULL for all", call. = FALSE)
  }
  cols <- c("species_code", "life_stage", "life_history_form", "variable", "parameter",
            "bound", "value_min", "value_max", "unit", "metric", "kind", "region", "citation_key",
            "page", "quote", "quote_source", "scale", "cited_source", "note", "model_id")
  x <- .knw_read_csv(path)
  chk::check_names(x, cols)
  x <- .knw_blank_to_na(x[cols])
  .literature_check(x)

  for (arg in c("species_code", "variable")) {
    miss <- setdiff(get(arg), x[[arg]])
    if (length(miss)) warning(arg, " not in the evidence table: ", paste(miss, collapse = ", "),
                              call. = FALSE)
  }
  keep <- rep(TRUE, nrow(x))
  if (!is.null(species_code)) keep <- keep & x$species_code %in% species_code
  if (!is.null(variable)) keep <- keep & x$variable %in% variable
  tibble::as_tibble(x[keep, , drop = FALSE])
}

# Row-level rules. Each stop() names the column and the first offending value so
# a hand edit can be found without re-reading the whole table.
.literature_check <- function(x) {
  # The data row only: its file line depends on blank lines and quoted line breaks,
  # which read.csv() absorbs, so a line number here would be a guess.
  first <- function(i) paste0(" (data row ", which(i)[1], ")")
  if (anyNA(x$species_code)) {
    stop("species_code is blank", first(is.na(x$species_code)), call. = FALSE)
  }
  vocab <- knw_literature_vocab()
  required <- c("life_stage", "variable", "kind")
  for (col in names(vocab)) {
    v <- x[[col]]
    bad <- if (col %in% required) is.na(v) | !v %in% vocab[[col]] else !is.na(v) & !v %in% vocab[[col]]
    if (any(bad)) {
      stop(col, " outside knw_literature_vocab(): ", v[bad][1], first(bad), call. = FALSE)
    }
  }

  none <- x$kind == "none"
  has_value <- !is.na(x$value_min) | !is.na(x$value_max)
  if (any(none & (has_value | !is.na(x$unit)))) {
    stop("a 'none' row carries no value or unit", first(none & (has_value | !is.na(x$unit))),
         call. = FALSE)
  }
  # A qualitative row is a statement with no value; 0280's thermal grid counts on it.
  qual_value <- x$kind == "qual" & has_value
  if (any(qual_value)) stop("a 'qual' row carries no value", first(qual_value), call. = FALSE)
  cited <- !is.na(x$citation_key) | !is.na(x$quote)
  if (any(none & cited)) {
    stop("a 'none' row carries no citation_key or quote", first(none & cited), call. = FALSE)
  }
  if (any(none & is.na(x$note))) {
    stop("a 'none' row needs a note saying what was searched", first(none & is.na(x$note)),
         call. = FALSE)
  }
  for (col in c("citation_key", "quote", "quote_source")) {
    miss <- !none & is.na(x[[col]])
    if (any(miss)) stop(col, " is blank on a cited row", first(miss), call. = FALSE)
  }
  if (any(none & !is.na(x$model_id))) {
    stop("a 'none' row belongs to no model, so no model_id", first(none & !is.na(x$model_id)),
         call. = FALSE)
  }
  bad_id <- !is.na(x$model_id) & !grepl(.knw_model_id_pattern, x$model_id)
  if (any(bad_id)) {
    stop("model_id must be a lower-case identifier: ", x$model_id[bad_id][1], first(bad_id),
         call. = FALSE)
  }
  if (any(none & !is.na(x$quote_source))) {
    stop("a 'none' row has no quote, so no quote_source", first(none & !is.na(x$quote_source)),
         call. = FALSE)
  }
  short <- !none & x$quote_source %in% "text" & nchar(x$quote) < 20
  if (any(short)) {
    stop("a text quote needs at least 20 characters to be checked against its PDF: ",
         x$quote[short][1], first(short), call. = FALSE)
  }
  no_unit <- has_value & is.na(x$unit)
  if (any(no_unit)) stop("a value needs a unit", first(no_unit), call. = FALSE)

  timing <- x$variable == "timing"
  day <- c(x$value_min[timing], x$value_max[timing])
  day <- day[!is.na(day)]
  ok <- grepl("^[0-9]{2}-[0-9]{2}$", day) &
    !is.na(as.Date(paste0("2000-", day), format = "%Y-%m-%d"))
  if (!all(ok)) {
    stop("timing values must be real dates written MM-DD: ", day[!ok][1], call. = FALSE)
  }
  # MM-DD on a numeric variable, or a number on a timing row, is a unit mix-up.
  unit_bad <- (timing & has_value & !x$unit %in% "MM-DD") | (!timing & x$unit %in% "MM-DD")
  if (any(unit_bad)) {
    stop("unit MM-DD belongs to timing rows only", first(unit_bad), call. = FALSE)
  }

  # A flow need is no model's filter; a MAD parameter sizes a stream, so it sits on discharge only.
  flow <- x$variable == "instream_flow"
  modelled <- flow & (!is.na(x$parameter) | !is.na(x$model_id))
  if (any(modelled)) {
    stop("an instream_flow row is a flow need, not a model parameter: parameter and model_id ",
         "stay blank", first(modelled), call. = FALSE)
  }
  mad_off <- grepl("_mad_", x$parameter) & x$variable != "discharge"
  if (any(mad_off)) {
    stop("parameter ", x$parameter[mad_off][1], " belongs to discharge rows, not ",
         x$variable[mad_off][1], first(mad_off), call. = FALSE)
  }

  fits <- list(gradient = "percent", channel_width = c("m bankfull", "m wetted", "m", "ft"),
               stream_order = "order", discharge = c("m3/s", "cfs"), lake_area = "ha", wetland_area = "ha",
               bridge_distance = c("km", "m"), temperature = "degC", substrate = "mm",
               depth = c("m", "cm", "ft", "m bankfull"), velocity = c("m/s", "cm/s", "ft/s"),
               timing = "MM-DD", valley_width_index = "ratio",
               drainage_area = c("km2", "mi2"), elevation = c("m", "ft"),
               air_temperature = "degC", degree_days = "degC-day",
               instream_flow = c("m3/s", "cfs", "percent MAD", "percentile", "percent exceedance"),
               # Qualitative until a source gives an upwelling measure: no unit fits, so no value can.
               groundwater = character(0))
  misfit <- !is.na(x$unit) & !mapply(function(v, u) u %in% fits[[v]], x$variable, x$unit)
  if (any(misfit)) {
    stop("unit ", x$unit[misfit][1], " does not fit variable ", x$variable[misfit][1],
         first(misfit), call. = FALSE)
  }
  mfits <- .knw_metric_fits()
  stray <- !is.na(x$metric) & !x$variable %in% names(mfits)
  if (any(stray)) {
    stop("metric ", x$metric[stray][1], " on variable ", x$variable[stray][1], ": only ",
         paste(names(mfits), collapse = ", "), " rows carry a metric", first(stray), call. = FALSE)
  }
  misfit <- !is.na(x$metric) & !stray &
    !mapply(function(v, m) m %in% mfits[[v]], x$variable, x$metric)
  if (any(misfit)) {
    stop("metric ", x$metric[misfit][1], " does not fit variable ", x$variable[misfit][1],
         first(misfit), call. = FALSE)
  }
  # A metric describes a value, or for a `none` row the statistic that was searched for.
  idle <- !none & !has_value & !is.na(x$metric)
  if (any(idle)) {
    stop("metric ", x$metric[idle][1], " on a row with no value: only a value or a 'none' row ",
         "carries a metric", first(idle), call. = FALSE)
  }
  bare <- has_value & x$variable %in% names(mfits) & is.na(x$metric)
  if (any(bare)) {
    stop("a ", x$variable[bare][1], " value needs a metric (unstated if the source does not say)",
         first(bare), call. = FALSE)
  }
  # Degree-day totals at base 0 and base 5 are not comparable, and the base has no column.
  dd_bare <- !none & x$variable == "degree_days" & is.na(x$note)
  if (any(dd_bare)) {
    stop("a degree_days row needs a note giving the base temperature", first(dd_bare), call. = FALSE)
  }
  # A 7-day low flow at a 2-year and at a 10-year return period are different flows.
  low7_bare <- !none & x$metric %in% "7day_low" & is.na(x$note)
  if (any(low7_bare)) {
    stop("a 7day_low row needs a note giving its return period", first(low7_bare), call. = FALSE)
  }
  need <- list(min = "value_min", max = "value_max")
  for (b in names(need)) {
    off <- !none & x$bound %in% b & is.na(x[[need[[b]]]])
    if (any(off)) stop("bound ", b, " needs ", need[[b]], first(off), call. = FALSE)
  }
  off <- !none & x$bound %in% "range" & (is.na(x$value_min) | is.na(x$value_max))
  if (any(off)) stop("bound range needs both value_min and value_max", first(off), call. = FALSE)

  num <- lapply(c("value_min", "value_max"), function(col) {
    v <- x[[col]]
    n <- suppressWarnings(as.numeric(v))
    bad <- !timing & !is.na(v) & !is.finite(n)
    if (any(bad)) stop(col, " must be numeric: ", v[bad][1], first(bad), call. = FALSE)
    n
  })
  flip <- !timing & !is.na(num[[1]]) & !is.na(num[[2]]) & num[[1]] > num[[2]]
  if (any(flip)) stop("value_min > value_max", first(flip), call. = FALSE)
  invisible(x)
}
