ip_fixture <- function() {
  data.frame(
    model_id                = c("burnett2007", "burnett2007", "agrawal2005", "agrawal2005"),
    model                   = c("CLAMS coastal IP", "CLAMS coastal IP", "SWFSC historical IP",
                                "SWFSC historical IP"),
    region                  = c("Oregon Coast Range", "Oregon Coast Range",
                                "Northern California coast", "Northern California coast"),
    species_code            = c("CO", "ST", "CH", "CO"),
    life_stage              = c("rearing", "rearing", "spawning", "rearing"),
    life_history_form       = c(NA, NA, "ocean_type", NA),
    flow_metric             = c("mean_annual_flow", "mean_annual_flow", "mean_annual_flow", "none"),
    flow_source             = c("modelled", "modelled", "modelled", NA),
    flow_inputs             = c("drainage_area;precipitation", "drainage_area;precipitation",
                                "gauge;drainage_area", NA),
    flow_surrogate          = c(NA, NA, "channel_width", NA),
    valley_confinement      = c("valley_width_index", "valley_width_index", "none",
                                "valley_width_index"),
    validation              = c("fish_observations", "none", "none", "none"),
    validation_result       = c("high-IP reaches held more juveniles", NA, NA, NA),
    citation_key            = c("key_b", "key_b", "key_a", "key_a"),
    cited_source            = c(NA, NA, "Spence et al. 2008", NA),
    page                    = c("4", "4", "12", "12"),
    quote                   = c("mean annual flow was estimated from drainage area",
                                "mean annual flow was estimated from drainage area",
                                "discharge was modelled from precipitation",
                                "suitability depends on gradient and valley width alone"),
    quote_source            = c("text", "text", "text", "text"),
    validation_citation_key = c("key_c", NA, NA, NA),
    validation_page         = c("9", NA, NA, NA),
    validation_quote        = c("densities were higher in high-IP reaches", NA, NA, NA),
    validation_quote_source = c("text", NA, NA, NA),
    note                    = NA
  )
}

write_ip <- function(x = ip_fixture()) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(x, path, row.names = FALSE, na = "")
  path
}

test_that("the registry reads whole, typed as character, and filters by species", {
  p <- write_ip()
  out <- knw_ip_read(p)
  expect_equal(nrow(out), 4)
  expect_named(out, names(ip_fixture()))
  expect_true(all(vapply(out, is.character, logical(1))))
  expect_equal(knw_ip_read(p, species_code = "CO")$model_id, c("burnett2007", "agrawal2005"))
})

test_that("a species absent from the registry warns, and an empty filter is refused", {
  expect_warning(out <- knw_ip_read(write_ip(), species_code = "SK"), "SK")
  expect_equal(nrow(out), 0)
  expect_error(knw_ip_read(write_ip(), species_code = character(0)), "NULL")
})

test_that("a header-only registry reads as an empty table", {
  out <- knw_ip_read(write_ip(ip_fixture()[0, ]))
  expect_equal(nrow(out), 0)
  expect_named(out, names(ip_fixture()))
})

test_that("a missing column is refused", {
  x <- ip_fixture()
  x$validation_quote <- NULL
  expect_error(knw_ip_read(write_ip(x)), "validation_quote")
})

test_that("each controlled column refuses a value outside its vocabulary", {
  cases <- list(flow_metric = "MAD", flow_source = "surrogate", flow_surrogate = "none",
                valley_confinement = "VWI",
                validation = "redds", life_stage = "Rearing", life_history_form = "anadromous",
                quote_source = "memory")
  for (col in names(cases)) {
    x <- ip_fixture()
    x[[col]][1] <- cases[[col]]
    expect_error(knw_ip_read(write_ip(x)), paste0(col, ".*", cases[[col]]), info = col)
  }
})

test_that("required descriptors may not be blank", {
  for (col in c("model_id", "model", "region", "species_code", "life_stage", "flow_metric",
                "valley_confinement", "validation", "citation_key", "page", "quote",
                "quote_source")) {
    x <- ip_fixture()
    x[[col]][2] <- NA
    expect_error(knw_ip_read(write_ip(x)), col, info = col)
  }
})

test_that("a model_id is a lower-case identifier", {
  x <- ip_fixture()
  x$model_id[1:2] <- "Burnett 2007"
  expect_error(knw_ip_read(write_ip(x)), "model_id.*Burnett 2007")
})

test_that("one model_id names one model", {
  x <- ip_fixture()
  x$model[2] <- "Another model"
  expect_error(knw_ip_read(write_ip(x)), "burnett2007.*more than one model")
})

test_that("a model x species x stage x form appears once", {
  x <- ip_fixture()
  x$species_code[2] <- "CO"
  expect_error(knw_ip_read(write_ip(x)), "duplicate.*burnett2007")
  x$life_history_form[2] <- "stream_type"
  expect_equal(nrow(knw_ip_read(write_ip(x))), 4)
})

test_that("a flow metric needs its source, and 'none' has no source, inputs or surrogate", {
  x <- ip_fixture()
  x$flow_source[1] <- NA
  expect_error(knw_ip_read(write_ip(x)), "flow_source")
  for (col in c("flow_source", "flow_inputs", "flow_surrogate")) {
    x <- ip_fixture()
    x[[col]][4] <- if (col == "flow_inputs") "gauge" else if (col == "flow_source") "modelled" else
      "channel_width"
    expect_error(knw_ip_read(write_ip(x)), paste0("flow_metric none.*", col), info = col)
  }
})

test_that("modelled flow names its inputs, each from the vocabulary", {
  x <- ip_fixture()
  x$flow_inputs[1] <- NA
  expect_error(knw_ip_read(write_ip(x)), "flow_inputs.*modelled")
  x <- ip_fixture()
  x$flow_inputs[2] <- "drainage_area; rainfall"
  expect_error(knw_ip_read(write_ip(x)), "flow_inputs.*rainfall")
  x <- ip_fixture()
  x$flow_inputs[1] <- " ; "
  expect_error(knw_ip_read(write_ip(x)), "flow_inputs.*modelled")
  x <- ip_fixture()
  x$flow_inputs[2] <- "precipitation ; drainage_area;"
  expect_equal(knw_ip_read(write_ip(x))$flow_inputs[2], "precipitation;drainage_area")
})

test_that("separators alone are no input: blank on read, so a 'none' flow stays clean", {
  x <- ip_fixture()
  x$flow_inputs[4] <- " ; "
  out <- knw_ip_read(write_ip(x))
  expect_true(is.na(out$flow_inputs[4]))
})

test_that("a flow source a secondary account does not state is 'unstated', with no inputs", {
  x <- ip_fixture()
  x$flow_source[1] <- "unstated"
  x$flow_inputs[1] <- NA
  expect_equal(knw_ip_read(write_ip(x))$flow_source[1], "unstated")
})

test_that("a surrogate differs from the metric it stands in for", {
  x <- ip_fixture()
  x$flow_surrogate[1] <- "mean_annual_flow"
  expect_error(knw_ip_read(write_ip(x)), "flow_surrogate.*flow_metric")
})

test_that("a claimed validation is quoted, and 'none' carries no validation quote", {
  for (col in c("validation_result", "validation_page", "validation_quote",
                "validation_quote_source")) {
    x <- ip_fixture()
    x[[col]][1] <- NA
    expect_error(knw_ip_read(write_ip(x)), col, info = col)
  }
  x <- ip_fixture()
  x$validation_citation_key[1] <- NA
  expect_equal(nrow(knw_ip_read(write_ip(x))), 4)
  x$validation_citation_key[2] <- "key_d"
  expect_error(knw_ip_read(write_ip(x)), "validation none.*validation_citation_key")
  x <- ip_fixture()
  x$validation_quote[2] <- "a stray validation quote here"
  expect_error(knw_ip_read(write_ip(x)), "validation none.*validation_quote")
})

test_that("a text quote shorter than 20 characters is refused, on either quote", {
  x <- ip_fixture()
  x$quote[3] <- "from rainfall"
  expect_error(knw_ip_read(write_ip(x)), "quote.*20 characters")
  x <- ip_fixture()
  x$validation_quote[1] <- "denser"
  expect_error(knw_ip_read(write_ip(x)), "validation_quote.*20 characters")
})

test_that("an error names the data row of the first offending value", {
  x <- ip_fixture()
  x$validation[3] <- "hope"
  expect_error(knw_ip_read(write_ip(x)), "hope \\(data row 3\\)")
})

test_that("the registry vocabularies are exported", {
  v <- knw_ip_vocab()
  expect_true(all(c("flow_metric", "flow_source", "flow_inputs", "valley_confinement",
                    "validation") %in% names(v)))
  expect_true("none" %in% v$flow_metric)
  expect_true("none" %in% v$validation)
})
