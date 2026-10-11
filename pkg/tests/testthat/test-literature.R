literature_fixture <- function() {
  data.frame(
    species_code      = c("CH", "CH", "BT", "BT", "CH"),
    life_stage        = c("spawning", "rearing", "spawning", "spawning", "spawning"),
    life_history_form = c("stream_type", NA, "migratory", NA, NA),
    variable          = c("gradient", "gradient", "channel_width", "timing", "gradient"),
    parameter         = c("spawn_gradient_max", "rear_gradient_max", "spawn_channel_width_min", NA,
                          "spawn_gradient_min"),
    bound             = c("max", "max", "min", "range", NA),
    value_min         = c(NA, NA, "2", "08-23", NA),
    value_max         = c("5", "6.5", NA, "10-15", NA),
    unit              = c("percent", "percent", "m wetted", "MM-DD", NA),
    metric            = c(NA, NA, NA, NA, NA),
    kind              = c("expert", "max_obs", "expert", "dist", "none"),
    region            = c("Interior Columbia", "Puget Sound", "Parsnip, BC", "Morice, BC", NA),
    citation_key      = c("key_a", "key_b", "key_c", "key_d", NA),
    page              = c("C-7", NA, "22", "14", NA),
    quote             = c("gradients above 5% were also excluded", "channels steeper than 6.5% did not have",
                          "less than 2 m wetted width", "spawn from late August", NA),
    quote_source      = c("text", "text", "text", "table", NA),
    scale             = c("reach", NA, "reach", NA, NA),
    cited_source      = c(NA, NA, NA, NA, NA),
    note              = c(NA, NA, NA, NA, "no source starts spawning habitat above 0 %"),
    model_id          = c("cooney_holzer2006", NA, NA, NA, NA)
  )
}

write_literature <- function(x = literature_fixture()) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(x, path, row.names = FALSE, na = "")
  path
}

test_that("with no filter every row comes back, typed as character", {
  out <- knw_literature_read(write_literature())
  expect_equal(nrow(out), 5)
  expect_named(out, names(literature_fixture()))
  expect_true(all(vapply(out, is.character, logical(1))))
})

test_that("rows filter by species and by variable, each taking several values", {
  p <- write_literature()
  expect_equal(knw_literature_read(p, species_code = "BT")$variable, c("channel_width", "timing"))
  expect_equal(nrow(knw_literature_read(p, variable = "gradient")), 3)
  expect_equal(nrow(knw_literature_read(p, species_code = c("CH", "BT"),
                                        variable = c("timing", "channel_width"))), 2)
})

test_that("a filter matching nothing returns the empty table with a warning", {
  expect_warning(out <- knw_literature_read(write_literature(), species_code = "CO"), "CO")
  expect_equal(nrow(out), 0)
  expect_named(out, names(literature_fixture()))
})

test_that("an empty filter is refused rather than read as everything", {
  expect_error(knw_literature_read(write_literature(), variable = character(0)), "NULL")
})

test_that("a missing column is refused", {
  x <- literature_fixture()
  x$quote <- NULL
  expect_error(knw_literature_read(write_literature(x)), "quote")
})

test_that("each controlled column refuses a value outside its vocabulary", {
  cases <- list(life_stage = "Spawning", life_history_form = "anadromous",
                parameter = "rear_gradient_min",
                variable = "slope", bound = "upper", kind = "HSI", unit = "feet", metric = "MWMT",
                quote_source = "memory", scale = "planet")
  for (col in names(cases)) {
    x <- literature_fixture()
    x[[col]][1] <- cases[[col]]
    expect_error(knw_literature_read(write_literature(x)), paste0(col, ".*", cases[[col]]),
                 info = col)
  }
})

test_that("a blank species code is refused", {
  x <- literature_fixture()
  x$species_code[2] <- " "
  expect_error(knw_literature_read(write_literature(x)), "species_code")
})

test_that("a non-numeric value on a numeric variable is refused", {
  x <- literature_fixture()
  x$value_max[1] <- "5%"
  expect_error(knw_literature_read(write_literature(x)), "numeric.*5%")
})

test_that("a timing value must be a real MM-DD, and may cross 1 January", {
  x <- literature_fixture()
  x$value_max[4] <- "10-32"
  expect_error(knw_literature_read(write_literature(x)), "MM-DD.*10-32")
  x$value_max[4] <- "04-30"
  expect_equal(knw_literature_read(write_literature(x))$value_max[4], "04-30")
})

test_that("a numeric range with min above max is refused", {
  x <- literature_fixture()
  x$value_min[1] <- "7"
  expect_error(knw_literature_read(write_literature(x)), "value_min > value_max")
})

test_that("a value without a unit is refused", {
  x <- literature_fixture()
  x$unit[2] <- NA
  expect_error(knw_literature_read(write_literature(x)), "unit")
})

test_that("a cited row needs a key and a quote; a 'none' row needs a note instead", {
  for (col in c("citation_key", "quote")) {
    x <- literature_fixture()
    x[[col]][3] <- NA
    expect_error(knw_literature_read(write_literature(x)), col, info = col)
  }
  x <- literature_fixture()
  x$note[5] <- NA
  expect_error(knw_literature_read(write_literature(x)), "none.*note")
})

test_that("a 'none' row carries no value", {
  x <- literature_fixture()
  x$value_max[5] <- "0"
  x$unit[5] <- "percent"
  expect_error(knw_literature_read(write_literature(x)), "none.*value")
})

test_that("whitespace-only cells read as NA, and a BOM does not break the header", {
  x <- literature_fixture()
  x$page[1] <- "  "
  p <- write_literature(x)
  writeBin(c(as.raw(c(0xEF, 0xBB, 0xBF)), readBin(p, "raw", file.size(p))), p)
  out <- knw_literature_read(p)
  expect_true(is.na(out$page[1]))
})

test_that("the vocabularies are exported and the stages extend the timing stages", {
  v <- knw_literature_vocab()
  expect_true(all(c("life_stage", "life_history_form", "variable", "bound", "unit", "metric",
                    "kind", "quote_source", "scale") %in% names(v)))
  expect_true(all(knw_timing_stages() %in% v$life_stage))
  expect_true("access" %in% v$life_stage)
})

test_that("a 'none' row carrying a key or a quote is refused", {
  x <- literature_fixture()
  x$quote[5] <- "a stray quote"
  expect_error(knw_literature_read(write_literature(x)), "none.*citation_key or quote")
})

test_that("an error names the data row of the first offending value", {
  x <- literature_fixture()
  x$kind[3] <- "guess"
  expect_error(knw_literature_read(write_literature(x)), "guess \\(data row 3\\)")
})

test_that("a file that is not UTF-8 is refused, not read as a truncated table", {
  p <- write_literature()
  lines <- readLines(p, encoding = "UTF-8")
  lines[4] <- sub("less than", "less than \xb0", lines[4], useBytes = TRUE)
  writeLines(lines, p, useBytes = TRUE)
  expect_error(knw_literature_read(p), "not valid UTF-8")
})

test_that("non-ASCII UTF-8 in a quote is read intact", {
  x <- literature_fixture()
  x$quote[1] <- "gradients ≥ 5 % at 12 °C"
  out <- knw_literature_read(write_literature(x))
  expect_equal(out$quote[1], "gradients ≥ 5 % at 12 °C")
})

test_that("a unit that does not fit the variable is refused", {
  x <- literature_fixture()
  x$unit[1] <- "m"
  expect_error(knw_literature_read(write_literature(x)), "unit m.*gradient")
})

test_that("a bound must sit on the value it bounds", {
  x <- literature_fixture()
  x$value_min[1] <- "5"
  x$value_max[1] <- NA
  expect_error(knw_literature_read(write_literature(x)), "bound max.*value_max")
  x <- literature_fixture()
  x$value_max[4] <- NA
  expect_error(knw_literature_read(write_literature(x)), "bound range.*both")
})

test_that("a cited row says where its quote came from, and a 'none' row does not", {
  x <- literature_fixture()
  x$quote_source[2] <- NA
  expect_error(knw_literature_read(write_literature(x)), "quote_source")
  x <- literature_fixture()
  x$quote_source[5] <- "text"
  expect_error(knw_literature_read(write_literature(x)), "none.*quote_source")
})

test_that("a text quote shorter than 20 characters is refused as unverifiable", {
  x <- literature_fixture()
  x$quote[2] <- "under 6.5%"
  expect_error(knw_literature_read(write_literature(x)), "quote.*20 characters")
})

test_that("model_id is a lower-case identifier, and a 'none' row has none", {
  x <- literature_fixture()
  x$model_id[1] <- "Cooney & Holzer"
  expect_error(knw_literature_read(write_literature(x)), "model_id.*Cooney & Holzer")
  x <- literature_fixture()
  x$model_id[5] <- "cooney_holzer2006"
  expect_error(knw_literature_read(write_literature(x)), "none.*model_id")
})

test_that("valley width index and drainage area read with their own units", {
  x <- literature_fixture()
  x$variable[2] <- "valley_width_index"
  x$unit[2] <- "ratio"
  x$variable[1] <- "drainage_area"
  x$unit[1] <- "km2"
  out <- knw_literature_read(write_literature(x))
  expect_equal(out$unit[1:2], c("km2", "ratio"))
  x$unit[2] <- "percent"
  expect_error(knw_literature_read(write_literature(x)), "unit percent.*valley_width_index")
  x$unit[2] <- "ratio"
  x$unit[1] <- "ha"
  expect_error(knw_literature_read(write_literature(x)), "unit ha.*drainage_area")
})

test_that("elevation reads in metres or feet and refuses other units", {
  x <- literature_fixture()
  x$variable[2] <- "elevation"
  x$unit[2] <- "m"
  expect_equal(knw_literature_read(write_literature(x))$variable[2], "elevation")
  x$unit[2] <- "ft"
  expect_equal(knw_literature_read(write_literature(x))$unit[2], "ft")
  x$unit[2] <- "percent"
  expect_error(knw_literature_read(write_literature(x)), "unit percent.*elevation")
})

test_that("US units are read as the source wrote them", {
  x <- literature_fixture()
  x$variable[1] <- "discharge"
  x$unit[1] <- "cfs"
  x$variable[2] <- "drainage_area"
  x$unit[2] <- "mi2"
  x$unit[3] <- "ft"
  out <- knw_literature_read(write_literature(x))
  expect_equal(out$unit[1:3], c("cfs", "mi2", "ft"))
})

test_that("a temperature or degree-day value says which metric it is", {
  x <- literature_fixture()
  x$variable[1] <- "temperature"
  x$unit[1] <- "degC"
  x$metric[1] <- "mwmt"
  x$variable[2] <- "degree_days"
  x$unit[2] <- "degC-day"
  x$value_max[2] <- "600"
  x$metric[2] <- "to_emergence"
  x$note[2] <- "base 0 C, from fertilization"
  x$variable[3] <- "air_temperature"
  x$unit[3] <- "degC"
  x$metric[3] <- "august_mean"
  out <- knw_literature_read(write_literature(x))
  expect_equal(out$metric[1:3], c("mwmt", "to_emergence", "august_mean"))
  expect_true(all(is.na(out$metric[4:5])))
  y <- x
  y$metric[1] <- NA
  expect_error(knw_literature_read(write_literature(y)), "temperature value needs a metric.*data row 1")
  y <- x
  y$metric[2] <- NA
  expect_error(knw_literature_read(write_literature(y)), "degree_days value needs a metric")
  y <- x
  y$metric[1] <- "weekly max"
  expect_error(knw_literature_read(write_literature(y)), "metric.*weekly max")
})

test_that("a qualitative temperature row may leave its metric blank", {
  x <- literature_fixture()
  x$variable[2] <- "temperature"
  x$value_max[2] <- NA
  x$bound[2] <- NA
  x$unit[2] <- NA
  x$kind[2] <- "qual"
  expect_true(is.na(knw_literature_read(write_literature(x))$metric[2]))
  x$metric[2] <- "7dadm"
  expect_error(knw_literature_read(write_literature(x)), "metric 7dadm on a row with no value.*data row 2")
})

test_that("a 'none' row may name the metric it searched for, which must fit its variable", {
  x <- literature_fixture()
  x$variable[5] <- "degree_days"
  x$metric[5] <- "to_emergence"
  expect_equal(knw_literature_read(write_literature(x))$metric[5], "to_emergence")
  x$metric[5] <- "mwmt"
  expect_error(knw_literature_read(write_literature(x)), "metric mwmt does not fit variable degree_days")
})

test_that("a metric sits only on the variable it describes", {
  x <- literature_fixture()
  x$metric[1] <- "daily_max"
  expect_error(knw_literature_read(write_literature(x)), "metric daily_max.*gradient.*data row 1")
  x <- literature_fixture()
  x$variable[1] <- "temperature"
  x$unit[1] <- "degC"
  x$metric[1] <- "growing_season"
  expect_error(knw_literature_read(write_literature(x)), "metric growing_season.*temperature")
  x$variable[1] <- "degree_days"
  x$unit[1] <- "degC-day"
  x$metric[1] <- "7dadm"
  expect_error(knw_literature_read(write_literature(x)), "metric 7dadm.*degree_days")
  x$metric[1] <- "unstated"
  x$note[1] <- "base not stated"
  expect_equal(knw_literature_read(write_literature(x))$metric[1], "unstated")
})

test_that("degree-days read in degC-day and temperatures in degC, and not the other way", {
  x <- literature_fixture()
  x$variable[1] <- "degree_days"
  x$metric[1] <- "growing_season"
  x$unit[1] <- "degC"
  expect_error(knw_literature_read(write_literature(x)), "unit degC.*degree_days")
  x$variable[1] <- "air_temperature"
  x$metric[1] <- "august_mean"
  x$unit[1] <- "degC-day"
  expect_error(knw_literature_read(write_literature(x)), "unit degC-day.*air_temperature")
  x$variable[1] <- "temperature"
  expect_error(knw_literature_read(write_literature(x)), "unit degC-day.*temperature")
})

test_that("a cited degree-day row says its base temperature in the note", {
  x <- literature_fixture()
  x$variable[1] <- "degree_days"
  x$unit[1] <- "degC-day"
  x$value_max[1] <- "900"
  x$metric[1] <- "growing_season"
  expect_error(knw_literature_read(write_literature(x)), "degree_days row needs a note.*data row 1")
  x$note[1] <- "Coleman & Fausch growing season, base 0 C"
  expect_equal(knw_literature_read(write_literature(x))$metric[1], "growing_season")
})

test_that("the metric vocabulary holds the temperature metrics and the degree-day windows", {
  m <- knw_literature_vocab()$metric
  expect_true(all(c("daily_max", "mwmt", "7dadm", "mwat", "7dec", "august_mean", "constant", "unstated",
                    "growing_season", "to_hatch", "to_emergence", "annual") %in% m))
  expect_false(anyDuplicated(m) > 0)
  expect_true(all(c("degree_days", "air_temperature") %in% knw_literature_vocab()$variable))
  expect_true("lab" %in% knw_literature_vocab()$kind)
})

test_that("a 'none' row may name the bound it searched for, and still carries no value", {
  x <- literature_fixture()
  x$variable[5] <- "temperature"
  x$bound[5] <- "max"
  expect_equal(knw_literature_read(write_literature(x))$bound[5], "max")
  x$bound[5] <- "range"
  expect_equal(knw_literature_read(write_literature(x))$bound[5], "range")
  x$value_max[5] <- "20"
  x$unit[5] <- "degC"
  expect_error(knw_literature_read(write_literature(x)), "none.*value")
})

test_that("a 'qual' row carries no value", {
  x <- literature_fixture()
  x$kind[1] <- "qual"
  expect_error(knw_literature_read(write_literature(x)), "'qual' row carries no value.*data row 1")
  x$value_max[1] <- NA
  x$bound[1] <- NA
  x$unit[1] <- NA
  expect_equal(knw_literature_read(write_literature(x))$kind[1], "qual")
})

test_that("groundwater is a qualitative variable: a statement reads, any unit is refused", {
  expect_true("groundwater" %in% knw_literature_vocab()$variable)
  x <- literature_fixture()
  x[1, c("variable", "parameter", "bound", "value_max", "unit", "model_id")] <- NA
  x$variable[1] <- "groundwater"
  x$kind[1] <- "qual"
  expect_equal(knw_literature_read(write_literature(x), variable = "groundwater")$kind, "qual")
  # No source has given an upwelling flux, so no unit fits, and so no value can be recorded.
  x$unit[1] <- "m/s"
  expect_error(knw_literature_read(write_literature(x)), "unit m/s does not fit variable groundwater")
  x$kind[1] <- "dist"
  x$value_max[1] <- "0.5"
  expect_error(knw_literature_read(write_literature(x)), "unit m/s does not fit variable groundwater")
})

test_that("an instream flow need reads in m3/s, cfs or percent MAD, and says its metric", {
  x <- literature_fixture()
  x$variable[1] <- "instream_flow"
  x$parameter[1] <- NA
  x$model_id[1] <- NA
  x$bound[1] <- "min"
  x$value_min[1] <- "20"
  x$value_max[1] <- NA
  x$unit[1] <- "percent MAD"
  x$metric[1] <- "monthly_median"
  x$variable[2] <- "instream_flow"
  x$parameter[2] <- NA
  x$unit[2] <- "cfs"
  x$metric[2] <- "unstated"
  out <- knw_literature_read(write_literature(x))
  expect_equal(out$unit[1:2], c("percent MAD", "cfs"))
  expect_equal(out$metric[1:2], c("monthly_median", "unstated"))
  y <- x
  y$metric[1] <- NA
  expect_error(knw_literature_read(write_literature(y)), "instream_flow value needs a metric.*data row 1")
  y <- x
  y$metric[1] <- "mwmt"
  expect_error(knw_literature_read(write_literature(y)), "metric mwmt does not fit variable instream_flow")
  y <- x
  y$unit[1] <- "percent"
  expect_error(knw_literature_read(write_literature(y)), "unit percent does not fit variable instream_flow")
})

test_that("percent MAD fits only a flow need, and a stream-size discharge row takes no metric", {
  x <- literature_fixture()
  x$variable[1] <- "discharge"
  x$parameter[1] <- "spawn_mad_min"
  x$unit[1] <- "percent MAD"
  expect_error(knw_literature_read(write_literature(x)), "unit percent MAD does not fit variable discharge")
  x$unit[1] <- "m3/s"
  expect_equal(knw_literature_read(write_literature(x))$unit[1], "m3/s")
  x$metric[1] <- "annual_mean"
  expect_error(knw_literature_read(write_literature(x)), "metric annual_mean on variable discharge")
  x <- literature_fixture()
  x$unit[1] <- "percent MAD"
  expect_error(knw_literature_read(write_literature(x)), "unit percent MAD does not fit variable gradient")
})

test_that("a flow need carries no model parameter, and a MAD parameter sits on discharge only", {
  x <- literature_fixture()
  x$variable[1] <- "instream_flow"
  x$unit[1] <- "m3/s"
  x$metric[1] <- "unstated"
  x$model_id[1] <- NA
  expect_error(knw_literature_read(write_literature(x)), "instream_flow row is a flow need.*data row 1")
  x$parameter[1] <- NA
  x$model_id[1] <- "cooney_holzer2006"
  expect_error(knw_literature_read(write_literature(x)), "parameter and model_id stay blank.*data row 1")
  x$model_id[1] <- NA
  expect_equal(knw_literature_read(write_literature(x))$variable[1], "instream_flow")
  y <- literature_fixture()
  y$parameter[3] <- "rear_mad_min"
  expect_error(knw_literature_read(write_literature(y)), "rear_mad_min belongs to discharge rows, not channel_width")
})

test_that("an instream_flow 'none' row may name its bound and metric; a qualitative one takes no metric", {
  x <- literature_fixture()
  x$variable[5] <- "instream_flow"
  x$parameter[5] <- NA
  x$bound[5] <- "min"
  x$metric[5] <- "monthly_mean"
  out <- knw_literature_read(write_literature(x))
  expect_equal(c(out$bound[5], out$metric[5]), c("min", "monthly_mean"))
  y <- literature_fixture()
  y$variable[2] <- "instream_flow"
  y$parameter[2] <- NA
  y$value_max[2] <- NA
  y$bound[2] <- NA
  y$unit[2] <- NA
  y$kind[2] <- "qual"
  expect_true(is.na(knw_literature_read(write_literature(y))$metric[2]))
  y$metric[2] <- "7day_low"
  expect_error(knw_literature_read(write_literature(y)), "metric 7day_low on a row with no value.*data row 2")
  x$metric[5] <- "annual_mean"
  expect_error(knw_literature_read(write_literature(x)), "metric annual_mean does not fit variable instream_flow")
})

test_that("depth and velocity read in the unit the source wrote, and bankfull depth is its own unit", {
  x <- literature_fixture()
  x$variable[3] <- "depth"
  x$parameter[3] <- NA
  for (u in c("m", "cm", "ft", "m bankfull")) {
    x$unit[3] <- u
    expect_equal(knw_literature_read(write_literature(x))$unit[3], u)
  }
  x$variable[3] <- "velocity"
  for (u in c("m/s", "cm/s", "ft/s")) {
    x$unit[3] <- u
    expect_equal(knw_literature_read(write_literature(x))$unit[3], u)
  }
  x$unit[3] <- "cm"
  expect_error(knw_literature_read(write_literature(x)), "unit cm does not fit variable velocity")
  x$variable[3] <- "depth"
  x$unit[3] <- "cm/s"
  expect_error(knw_literature_read(write_literature(x)), "unit cm/s does not fit variable depth")
})

test_that("a flow need may be a percentile or a percent exceedance, and a 7-day low names its return period", {
  x <- literature_fixture()
  x$variable[1] <- "instream_flow"
  x$parameter[1] <- NA
  x$model_id[1] <- NA
  x$metric[1] <- "daily_mean"
  x$unit[1] <- "percentile"
  expect_equal(knw_literature_read(write_literature(x))$unit[1], "percentile")
  x$unit[1] <- "percent exceedance"
  expect_equal(knw_literature_read(write_literature(x))$unit[1], "percent exceedance")
  y <- literature_fixture()
  y$unit[1] <- "percentile"
  expect_error(knw_literature_read(write_literature(y)), "unit percentile does not fit variable gradient")
  x$unit[1] <- "m3/s"
  x$metric[1] <- "7day_low"
  expect_error(knw_literature_read(write_literature(x)), "7day_low row needs a note.*data row 1")
  x$note[1] <- "7Q10"
  expect_equal(knw_literature_read(write_literature(x))$metric[1], "7day_low")
})
