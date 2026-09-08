fixture_layers <- function() {
  url <- function(id) sprintf("https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=%d", id)
  assessment <- sf::st_sf(
    stream_crossing_id = c(10L, 11L, 12L),
    assessment_date = as.Date(c("2015-08-01", "2015-08-02", "2019-06-01")),
    consultant_name = c("A", "A", "B"),
    ecocat_url = c(url(100), url(100), NA),
    geometry = sf::st_sfc(sf::st_point(c(1200000, 1000000)),
                          sf::st_point(c(1200500, 1000500)),
                          sf::st_point(c(1201000, 1001000)), crs = 3005))
  design <- data.frame(stream_crossing_id = 11L, ecocat_url = url(200),
                       design_date = as.Date("2020-01-01"))
  list(assessment = assessment, design = design)
}

test_that("reports are one row per layer/url/consultant/year with a parsed report_id", {
  r <- knw_pscis_reports(fixture_layers())
  expect_equal(nrow(r), 2L)
  expect_equal(r$report_id, c("100", "200"))
  expect_equal(r$n_crossings[r$pscis_layer == "assessment"], 2L)
  expect_true(is.na(r$consultant[r$pscis_layer == "design"]))
})

test_that("a layer without ecocat_url is skipped and an empty input is typed", {
  r <- knw_pscis_reports(list(x = data.frame(stream_crossing_id = 1L)))
  expect_equal(nrow(r), 0L)
  expect_named(r, c("pscis_layer", "ecocat_url", "consultant", "year", "n_crossings", "report_id"))
})

test_that("crossings carry lon/lat, the group, and phase flags", {
  x <- knw_pscis_crossings(fixture_layers(), "PINE")
  expect_equal(nrow(x), 3L)
  expect_true(all(x$watershed_group_code == "PINE"))
  expect_equal(x$has_design, c(FALSE, TRUE, FALSE))
  expect_false(any(x$has_confirmation))
  expect_true(all(x$lon < -100 & x$lat > 48))
})

test_that("crossings refuses non-point assessment geometry rather than exploding rows", {
  l <- fixture_layers()
  l$assessment <- sf::st_buffer(l$assessment, 10)
  expect_error(knw_pscis_crossings(l, "PINE"), "POINT")
})

test_that("crossings is NULL without an assessment layer", {
  expect_null(knw_pscis_crossings(list(design = data.frame(stream_crossing_id = 1L)), "PINE"))
})

test_that("reports reads the habitat-confirmation layer's habconf_ecocat_url column", {
  url <- "https://a100.gov.bc.ca/pub/acat/public/advancedSearch.do?keywords=[PSCIS3940]"
  l <- list(confirmation = data.frame(stream_crossing_id = c(1L, 2L), habconf_ecocat_url = url,
                                      consultant_name = "C", assessment_date = as.Date("2018-07-01")))
  r <- knw_pscis_reports(l)
  expect_equal(nrow(r), 1L)
  expect_equal(r$ecocat_url, url)
  expect_equal(r$n_crossings, 2L)
  expect_true(is.na(r$report_id))
})
