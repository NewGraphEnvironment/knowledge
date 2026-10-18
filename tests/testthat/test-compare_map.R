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

test_that("knw_compare_map stacks the panels when ncol is 1", {
  skip_if_not_installed("tmap")
  skip_if_not_installed("png")
  seg <- sf::st_sf(
    accessible = rep(TRUE, 2), stream_order = 1:2, grade_class = c("0-0.2", "0.8-1"),
    flag_default = c(TRUE, FALSE), flag_tuned = c(TRUE, TRUE),
    geometry = sf::st_sfc(lapply(0:1, function(i) sf::st_linestring(rbind(c(i, 0), c(i + 1, 1)))), crs = 3005))
  wide <- tempfile(fileext = ".png")
  tall <- tempfile(fileext = ".png")
  knw_compare_map(seg, NULL, "a group", png = wide)
  knw_compare_map(seg, NULL, "a group", png = tall, ncol = 1)
  dw <- dim(png::readPNG(wide))
  dt <- dim(png::readPNG(tall))
  expect_equal(dw[1:2], c(4.6, 8) * 150)
  expect_equal(dt[1:2], c(9.2, 4) * 150)
  expect_error(knw_compare_map(seg, NULL, "a group", png = tall, ncol = 0))
})

test_that("knw_compare_map draws only the panels asked for, with a window outlined", {
  skip_if_not_installed("tmap")
  skip_if_not_installed("png")
  seg <- sf::st_sf(
    accessible = rep(TRUE, 2), stream_order = 1:2, grade_class = c("0-0.2", "0.8-1"),
    flag_default = c(TRUE, FALSE), flag_tuned = c(TRUE, TRUE),
    geometry = sf::st_sfc(lapply(0:1, function(i) sf::st_linestring(rbind(c(i, 0), c(i + 1, 1)))), crs = 3005))
  box <- sf::st_sf(geometry = sf::st_as_sfc(sf::st_bbox(c(xmin = 0.2, ymin = 0.2, xmax = 0.8, ymax = 0.8), crs = 3005)))
  one <- tempfile(fileext = ".png")
  plain <- tempfile(fileext = ".png")
  knw_compare_map(seg, NULL, "a group", png = one, panels = "rules", mark = box)
  knw_compare_map(seg, NULL, "a group", png = plain, panels = "rules")
  expect_false(identical(png::readPNG(one), png::readPNG(plain)))
  expect_equal(dim(png::readPNG(one))[1:2], c(4.6, 4) * 150)
  expect_error(knw_compare_map(seg, NULL, "a group", png = one, panels = "floodplain"), "needs fp_cells")
  expect_error(knw_compare_map(seg, NULL, "a group", png = one, panels = "rivers"))
  thin <- tempfile(fileext = ".png")
  thick <- tempfile(fileext = ".png")
  knw_compare_map(seg, NULL, "a group", png = thin, panels = "rules", legend = FALSE)
  knw_compare_map(seg, NULL, "a group", png = thick, panels = "rules", lwd = 3, legend = FALSE)
  # thicker lines cover more of the panel: count the pixels that are not white
  inked <- function(f) {
    img <- png::readPNG(f)
    sum(img[, , 1] + img[, , 2] + img[, , 3] < 2.9)
  }
  expect_gt(inked(thick), 1.5 * inked(thin))
  bare <- thick
  expect_error(knw_compare_map(seg, NULL, "a group", png = bare, lwd = 0))
})
