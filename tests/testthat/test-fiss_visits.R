ev_fx <- function() {
  data.frame(site_visit = c("1:1", "1:1", "1:1", "2:1", "3:4"), species_code = c("BT", "BT", "CH", "RB", "CH"),
             size_class = c("fry", "adult", "unmeasured", "unmeasured", "unmeasured"),
             n = c(2, 1, 4, 1, 2), n_caught = c(3, 3, 4, 1, 2), watershed_group_code = "COTR",
             blue_line_key = c(1, 1, 1, 2, 3), downstream_route_measure = c(10, 10, 10, 20, 30),
             month = 8, year = c(2015, 2015, 2015, 2016, 2017),
             method = c("electrofishing", "electrofishing", "electrofishing", "electrofishing", "minnow trapping"),
             stringsAsFactors = FALSE)
}
s2_fx <- function() {
  data.frame(site_key = c("1:1", "1:1", "2:1"), sampling_method = c("EF", "EF", "MT"), haul_pass = c(2, 1, 1),
             ef_seconds = c(250, 300, NA), length_m = c(50, 50, 10), width_m = c(2, 2.5, 1),
             ef_length_m = c(NA, 48, NA), ef_width_m = c(NA, NA, NA), stringsAsFactors = FALSE)
}

test_that("one row per site and species, effort from the step-2 passes", {
  out <- knw_fiss_visits(ev_fx(), s2_fx())
  expect_equal(nrow(out), 4)
  bt <- out[out$site_visit == "1:1" & out$species_code == "BT", ]
  expect_equal(bt$n_caught, 3)
  expect_equal(bt$fishing_time_s, 550)
  # the first pass: ef_length 48 over length 50, width 2.5; area 48 x 2.5
  expect_equal(bt$fished_length_m, 48)
  expect_equal(bt$area_m2, 120)
  expect_true(bt$scores)
  expect_equal(unique(out$data_set), "FISS_WORKBOOK")
})

test_that("a site with no electrofishing effort, or another method, does not score", {
  out <- knw_fiss_visits(ev_fx(), s2_fx())
  expect_false(out$scores[out$site_visit == "2:1"])
  expect_true(is.na(out$fishing_time_s[out$site_visit == "2:1"]))
  expect_false(out$scores[out$site_visit == "3:4"])
  out2 <- knw_fiss_visits(ev_fx(), NULL)
  expect_true(all(!out2$scores))
})

test_that("two counts for one site and species are refused", {
  ev <- ev_fx()
  ev$n_caught[2] <- 5
  expect_error(knw_fiss_visits(ev, NULL), "two counts")
})
