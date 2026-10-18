test_that("knw_compare_map draws nothing, and says so, when no segment passes the access gate", {
  skip_if_not_installed("tmap")
  seg <- sf::st_sf(
    accessible = c(FALSE, FALSE), stream_order = c(1L, 2L), grade_class = c(NA, "0.2-0.4"),
    flag_default = c(TRUE, TRUE), flag_tuned = c(FALSE, TRUE),
    geometry = sf::st_sfc(sf::st_linestring(rbind(c(0, 0), c(1, 1))), sf::st_linestring(rbind(c(1, 1), c(2, 2))),
                          crs = 3005))
  png <- tempfile(fileext = ".png")
  expect_message(out <- knw_compare_map(seg, NULL, "PARS: RB rearing", png = png), "no accessible segment")
  expect_identical(out, character())
  expect_false(file.exists(png))
})

test_that("knw_compare_map writes the static figure for one accessible segment under each class", {
  skip_if_not_installed("tmap")
  seg <- sf::st_sf(
    accessible = rep(TRUE, 4), stream_order = 1:4, grade_class = c("0-0.2", "0.8-1", NA, "0.4-0.6"),
    flag_default = c(TRUE, TRUE, FALSE, FALSE), flag_tuned = c(TRUE, FALSE, TRUE, FALSE),
    geometry = sf::st_sfc(lapply(0:3, function(i) sf::st_linestring(rbind(c(i, 0), c(i + 1, 1)))), crs = 3005))
  png <- tempfile(fileext = ".png")
  out <- knw_compare_map(seg, NULL, "a group", png = png)
  expect_identical(out, png)
  expect_true(file.exists(png))
  expect_gt(file.size(png), 0)
})
