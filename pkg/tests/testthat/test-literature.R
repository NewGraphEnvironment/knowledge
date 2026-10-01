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
                variable = "slope", bound = "upper", kind = "HSI", unit = "feet",
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
  expect_true(all(c("life_stage", "life_history_form", "variable", "bound", "unit", "kind",
                    "quote_source", "scale") %in% names(v)))
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
