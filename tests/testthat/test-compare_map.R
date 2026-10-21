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
  # the outline is drawn and the map keeps the segments' extent: a few pixels change, not the whole panel
  a <- png::readPNG(one)
  b <- png::readPNG(plain)
  changed <- mean(apply(abs(a[, , 1:3] - b[, , 1:3]), c(1, 2), max) > 0.1)
  expect_gt(changed, 0)
  expect_lt(changed, 0.01)
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

test_that("knw_compare_map draws numbered markers where labels are given", {
  skip_if_not_installed("tmap")
  skip_if_not_installed("png")
  seg <- sf::st_sf(
    accessible = rep(TRUE, 2), stream_order = 1:2, grade_class = c("0-0.2", "0.8-1"),
    flag_default = c(TRUE, FALSE), flag_tuned = c(TRUE, TRUE),
    geometry = sf::st_sfc(lapply(0:1, function(i) sf::st_linestring(rbind(c(i, 0), c(i + 1, 1)))), crs = 3005))
  pts <- sf::st_sf(label = c("1", "2"), geometry = sf::st_sfc(sf::st_point(c(0.5, 0.5)), sf::st_point(c(1.5, 0.5)),
                                                             crs = 3005))
  with_l <- tempfile(fileext = ".png")
  without <- tempfile(fileext = ".png")
  knw_compare_map(seg, NULL, "g", png = with_l, panels = "rules", labels = pts)
  knw_compare_map(seg, NULL, "g", png = without, panels = "rules")
  a <- png::readPNG(with_l)
  b <- png::readPNG(without)
  changed <- mean(apply(abs(a[, , 1:3] - b[, , 1:3]), c(1, 2), max) > 0.1)
  expect_gt(changed, 0)
  expect_lt(changed, 0.05)
  expect_error(knw_compare_map(seg, NULL, "g", png = with_l, labels = sf::st_sf(geometry = sf::st_geometry(pts))))
})

mapgl_fx <- function() {
  sf::st_sf(
    accessible = c(TRUE, TRUE, TRUE, FALSE), stream_order = 1:4, grade_class = c("0-0.2", "0.8-1", NA, "0.4-0.6"),
    grade = c(0.1, 0.9, NA, 0.5), flag_default = c(TRUE, TRUE, FALSE, TRUE), flag_tuned = c(TRUE, FALSE, TRUE, TRUE),
    pre_default = c(TRUE, TRUE, FALSE, TRUE), pre_tuned = c(TRUE, TRUE, FALSE, TRUE),
    mad = c(0.0372, 19.4, NA, 1), channel_width = c(2.2, NA, 1, 1), gradient = c(0.024, 0.001, 0.08, 0.01),
    dist_m = c(19400, 0, 250, NA), water = c("stream", "wetland", "river", "stream"), water_ha = c(NA, 7.93, NA, NA),
    geometry = sf::st_sfc(lapply(0:3, function(i) {
      sf::st_linestring(rbind(c(1e6 + i * 500.123456, 1e6), c(1e6 + (i + 1) * 500.987654, 1e6 + 300.55555)))
    }), crs = 3005))
}

test_that("knw_compare_mapgl colours every class in hex, places the legends and the switch, and keeps the background", {
  skip_if_not_installed("mapgl")
  m <- knw_compare_mapgl(mapgl_fx(), title = "Habitat by rule")
  expect_s3_class(m, "maplibregl")
  colours <- unlist(lapply(m$x$layers, function(l) unlist(l$paint[grepl("color", names(l$paint))])))
  colours <- colours[!grepl("^(match|get|rc|gc)$", colours) & is.na(suppressWarnings(as.numeric(colours)))]
  expect_true(all(grepl("^#[0-9a-f]{6}$", colours)), info = paste(unique(colours), collapse = " "))
  expect_true(all(grepl("^#[0-9a-f]{6}$", c(knowledge:::.compare_rule_cols, knowledge:::.compare_grade_cols))))
  json <- as.character(jsonlite::toJSON(m$x, auto_unbox = TRUE, null = "null"))
  # the legends bottom-left and the layer switch top-right, so they never share a corner
  expect_identical(m$x$layers_control$position, "top-right")
  expect_setequal(m$x$layers_control$layers, c("rules", "grade"))
  expect_match(m$x$legend_html, "legend_rules[^>]*bottom-left")
  expect_match(m$x$legend_html, "legend_grade[^>]*bottom-left")
  expect_false(grepl("grey8", json))
  expect_match(json, "voyager")
  m2 <- knw_compare_mapgl(mapgl_fx(), background = "openfreemap")
  expect_match(as.character(jsonlite::toJSON(m2$x$style, auto_unbox = TRUE)), "openfreemap")
})

test_that("knw_compare_mapgl's popup reads only expressions mapgl's evaluator knows, with per-value numbers", {
  skip_if_not_installed("mapgl")
  m <- knw_compare_mapgl(mapgl_fx())
  pop <- m$x$layers[[which(vapply(m$x$layers, `[[`, "", "id") == "rules")]]$popup
  ops <- character()
  walk <- function(e) {
    if (is.list(e)) {
      if (is.character(e[[1]])) ops <<- c(ops, e[[1]])
      lapply(e[-1], walk)
    }
  }
  walk(pop)
  expect_true(all(ops %in% c("get", "concat", "to-string", "to-number", "number-format")), info = paste(unique(ops)))
  src <- jsonlite::fromJSON(m$x$sources[[1]]$data)$features$properties
  # only the accessible segments, each with its own notation, and "none" for a missing value
  expect_equal(nrow(src), 3)
  expect_identical(src$q, c("0.037", "19", "none"))
  expect_identical(src$d, c("19", "0", "0.25"))
  expect_identical(src$vd, c("yes", "yes", "no"))
  expect_identical(src$vt, c("yes", "no (not connected to spawning)", "yes (a hand-entered reach)"))
  expect_identical(src$wa, c("stream line", "wetland, 7.93 ha", "river polygon"))
})

test_that("knw_compare_mapgl rounds coordinates after the transform to degrees", {
  skip_if_not_installed("mapgl")
  m <- knw_compare_mapgl(mapgl_fx(), digits = 3)
  xy <- unlist(jsonlite::fromJSON(m$x$sources[[1]]$data, simplifyVector = FALSE)$features[[1]]$geometry$coordinates)
  expect_true(all(abs(xy * 1000 - round(xy * 1000)) < 1e-6))
})

test_that("knw_compare_mapgl says so and returns NULL when no segment is accessible", {
  skip_if_not_installed("mapgl")
  seg <- mapgl_fx()
  seg$accessible <- FALSE
  expect_message(out <- knw_compare_mapgl(seg, title = "PARS"), "no accessible segment")
  expect_null(out)
})

test_that("knw_compare_mapgl writes a large or tiny waterbody area in fixed notation", {
  skip_if_not_installed("mapgl")
  seg <- mapgl_fx()
  seg$water <- c("lake", "wetland", "lake", "stream")
  seg$water_ha <- c(123456, 0.0001, 654.2, NA)
  src <- jsonlite::fromJSON(knw_compare_mapgl(seg)$x$sources[[1]]$data)$features$properties
  expect_identical(src$wa, c("lake, 123000 ha", "wetland, 0.0001 ha", "lake, 654 ha"))
})
