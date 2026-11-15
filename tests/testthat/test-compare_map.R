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
  m <- knw_compare_mapgl(mapgl_fx(), title = "Habitat definition")
  expect_s3_class(m, "maplibregl")
  colours <- unlist(lapply(m$x$layers, function(l) unlist(l$paint[grepl("color", names(l$paint))])))
  colours <- colours[!grepl("^(match|get|rc|gc)$", colours) & is.na(suppressWarnings(as.numeric(colours)))]
  expect_true(all(grepl("^#[0-9a-f]{6}$", colours)), info = paste(unique(colours), collapse = " "))
  hex <- c(knowledge:::.compare_cols("compare_rule"), knowledge:::.compare_cols("compare_grade"))
  expect_true(all(grepl("^#[0-9a-f]{6}$", hex)))
  json <- as.character(jsonlite::toJSON(m$x, auto_unbox = TRUE, null = "null"))
  # the legends top-left, the layer switch top-right and the attribution along the bottom, so none share a corner
  expect_identical(m$x$layers_control$position, "top-right")
  expect_setequal(unlist(m$x$layers_control$layers), c("rules", "grade"))
  # the switch shows readers its labels, not the layer ids (#156: no "rule" in what a reader sees)
  expect_setequal(names(unlist(m$x$layers_control$layers)), c("Habitat", "Grade"))
  expect_match(m$x$legend_html, "legend_rules[^>]*top-left")
  expect_match(m$x$legend_html, "legend_grade[^>]*top-left")
  expect_false(grepl("grey8", json))
  expect_match(json, "voyager")
  m2 <- knw_compare_mapgl(mapgl_fx(), background = "openfreemap")
  expect_match(as.character(jsonlite::toJSON(m2$x$style, auto_unbox = TRUE)), "openfreemap")
})

test_that("no map label a reader sees says rule (#156)", {
  expect_false(any(grepl("\\brules?\\b", knowledge:::.compare_rule_labels(), ignore.case = TRUE, perl = TRUE)))
  pop <- knowledge:::.compare_popup(mapgl_fx())
  expect_false(any(grepl("\\brules?\\b", unlist(Filter(is.character, pop$expr)), ignore.case = TRUE, perl = TRUE)))
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

test_that("knw_compare_mapgl's Esri topo background is a keyless raster style that carries Esri's attribution", {
  skip_if_not_installed("mapgl")
  st <- knw_compare_mapgl(mapgl_fx(), background = "esri_topo")$x$style
  expect_identical(st$version, 8)
  src <- st$sources$esri_topo
  expect_identical(src$type, "raster")
  expect_match(src$tiles[[1]], "^https://server\\.arcgisonline\\.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/")
  expect_false(grepl("token|key", src$tiles[[1]]))
  expect_match(src$attribution, "Powered by .*Esri")
  expect_match(src$attribution, "OpenStreetMap contributors")
  expect_identical(st$layers[[1]]$source, "esri_topo")
  # serialised as the widget sends it: tiles must be a JSON array
  expect_match(as.character(jsonlite::toJSON(st, auto_unbox = TRUE)), '"tiles":\\["https')
})

test_that("the maps' classes and colours come from one gq registry, read the same way by gq (#173)", {
  rule <- knowledge:::.compare_cols("compare_rule")
  grade <- knowledge:::.compare_cols("compare_grade")
  expect_identical(names(rule), c("kept (both)", "lost (default only)", "gained (tuned only)", "accessible, neither"))
  expect_identical(names(grade), c("0-0.2", "0.2-0.4", "0.4-0.6", "0.6-0.8", "0.8-1", "not graded"))
  # the grade classes are the grade table's own labels, so a graded segment always finds its colour
  expect_true(all(c("0-0.2", "0.8-1") %in% names(grade)))
  skip_if_not_installed("gq")
  reg <- gq::gq_reg_custom(system.file("gq", "compare.csv", package = "knowledge"))
  for (k in c("compare_rule", "compare_grade")) {
    cls <- gq::gq_style(reg$layers[[k]])$classification
    expect_identical(unname(cls$values), unname(knowledge:::.compare_cols(k)))
    expect_identical(unname(cls$labels), names(knowledge:::.compare_cols(k)))
  }
})

test_that(".knw_rule_class gives each pair of flags its class, a missing flag reading as not habitat (#173)", {
  lab <- knowledge:::.compare_rule_labels()
  got <- knowledge:::.knw_rule_class(c(TRUE, TRUE, FALSE, FALSE, NA, TRUE), c(TRUE, FALSE, TRUE, FALSE, TRUE, NA), lab)
  expect_identical(got, lab[c(1, 2, 3, 4, 3, 2)])
  expect_error(knowledge:::.knw_rule_class(TRUE, TRUE, lab[1:3]))
  # a segment the species cannot reach has no class, whatever its flags
  expect_identical(knowledge:::.knw_rule_class(c(TRUE, FALSE, TRUE), c(TRUE, FALSE, FALSE), lab,
                                               accessible = c(TRUE, FALSE, NA)),
                   c(lab[1], NA, NA))
})

test_that("the GeoPackage's QGIS styles come from the same registry, rule class first (#173, gq#115)", {
  skip_if_not_installed("gq")
  skip_if_not(exists("gq_qgis_style", asNamespace("gq")), "gq predates gq_qgis_style() (gq#115)")
  st <- knowledge:::.compare_qgis_styles()
  expect_identical(names(st), c("rule_class", "grade_class"))
  for (k in c("rule_class", "grade_class")) {
    doc <- xml2::read_xml(st[[k]])
    cats <- xml2::xml_find_all(doc, ".//categories/category")
    expect_identical(xml2::xml_attr(cats, "label"),
                     names(knowledge:::.compare_cols(if (k == "rule_class") "compare_rule" else "compare_grade")))
    expect_identical(xml2::xml_attr(xml2::xml_find_first(doc, ".//renderer-v2"), "attr"), k)
  }
  skip_if_not_installed("sf")
  f <- tempfile(fileext = ".gpkg")
  seg <- sf::st_sf(rule_class = "kept (both)", grade_class = "0-0.2",
                   geometry = sf::st_sfc(sf::st_linestring(rbind(c(0, 0), c(1, 1))), crs = 3005))
  sf::st_write(seg, f, layer = "segments", quiet = TRUE)
  gq::gq_gpkg_style_write(f, "segments", st)
  ls <- sf::st_read(f, layer = "layer_styles", quiet = TRUE)
  expect_setequal(ls$styleName, c("rule_class", "grade_class"))
  expect_identical(ls$styleName[as.logical(ls$useAsDefault)], "rule_class")
})

# a composed map's fixture (#77): four segments in a 20 km window, its outline, a region around it, a town and a river
ctx_fx <- function() {
  seg <- sf::st_sf(
    accessible = rep(TRUE, 4), stream_order = c(5L, 3L, 2L, 1L), grade_class = c("0.8-1", "0-0.2", NA, "0.4-0.6"),
    flag_default = c(TRUE, TRUE, FALSE, FALSE), flag_tuned = c(TRUE, FALSE, TRUE, FALSE),
    geometry = sf::st_sfc(lapply(0:3, function(i) {
      sf::st_linestring(rbind(c(1e6 + i * 4000, 1e6), c(1e6 + (i + 1) * 4000, 1e6 + 30000)))
    }), crs = 3005))
  box <- function(x0, y0, x1, y1) {
    sf::st_sf(geometry = sf::st_as_sfc(sf::st_bbox(c(xmin = x0, ymin = y0, xmax = x1, ymax = y1), crs = 3005)))
  }
  list(seg = seg, aoi = box(1e6, 1e6, 1.02e6, 1.03e6), context = box(0.8e6, 0.8e6, 1.4e6, 1.4e6),
       towns = sf::st_sf(label = "Townsville", geometry = sf::st_sfc(sf::st_point(c(1.008e6, 1.012e6)), crs = 3005)),
       rivers = sf::st_sf(label = "Big River", angle = 30,
                          geometry = sf::st_sfc(sf::st_point(c(1.012e6, 1.02e6)), crs = 3005)))
}
px_of <- function(f) png::readPNG(f)[, , 1:3]

test_that("a composed map takes its canvas from the window's shape, and its extras need `width` (#77)", {
  skip_if_not_installed("tmap")
  skip_if_not_installed("png")
  skip_if_not_installed("gq")
  fx <- ctx_fx()
  f <- tempfile(fileext = ".png")
  knw_compare_map(fx$seg, png = f, panels = "rules", width = 4, keymap = list(aoi = fx$aoi, context = fx$context))
  # the outline padded 2 km: 24 km by 34 km, so a 4 in canvas is 34/24 * 4 in tall
  expect_equal(dim(png::readPNG(f))[1:2], round(c(4 * 34 / 24, 4) * 150), tolerance = 1e-3)
  expect_error(knw_compare_map(fx$seg, png = f, panels = "rules", scalebar = TRUE), "need `width`")
  expect_error(knw_compare_map(fx$seg, png = f, width = 4), "draws one panel")
  same <- c(legend = "topleft", scalebar = "topleft", keymap = "topright", logo = "bottomright")
  expect_error(knw_compare_map(fx$seg, png = f, panels = "rules", width = 4, corners = same), "different corner")
  expect_error(knw_compare_map(fx$seg, png = f, panels = "rules", width = 4, keymap = list(aoi = fx$aoi)),
               "aoi` and `context")
  expect_error(knw_compare_map(fx$seg, png = f, panels = "rules", width = 4, places = list(rivers = fx$towns)), "angle")
})

test_that("each of the scale bar, keymap, places, basemap and logo draws something of its own (#77)", {
  skip_if_not_installed("tmap")
  skip_if_not_installed("png")
  skip_if_not_installed("gq")
  skip_if_not_installed("stars")
  fx <- ctx_fx()
  draw <- function(...) {
    f <- tempfile(fileext = ".png")
    knw_compare_map(fx$seg, png = f, panels = "rules", width = 4, ...)
    f
  }
  plain <- px_of(draw())
  differs <- function(f) {
    x <- px_of(f)
    if (!identical(dim(x), dim(plain))) return(TRUE)
    mean(apply(abs(x - plain), c(1, 2), max) > 0.1) > 0.001
  }
  expect_true(differs(draw(scalebar = TRUE)))
  expect_true(differs(draw(keymap = list(aoi = fx$aoi, context = fx$context))))
  expect_true(differs(draw(places = list(towns = fx$towns, rivers = fx$rivers))))
  logo <- tempfile(fileext = ".png")
  png::writePNG(array(c(rep(0, 100 * 100), rep(0, 100 * 100), rep(0, 100 * 100)), c(100, 100, 3)), logo)
  expect_true(differs(draw(logo = logo)))
  # a basemap with a credit: drawn under the map, its credit in a strip below it
  r <- terra::rast(xmin = 0.99e6, xmax = 1.03e6, ymin = 0.99e6, ymax = 1.04e6, resolution = 1000, crs = "EPSG:3005",
                   nlyrs = 3, vals = 120)
  bm <- stars::st_as_stars(r)
  attr(bm, "credit") <- "Tiles: a test provider"
  with_bm <- draw(basemap = bm)
  without <- dim(plain)
  expect_gt(dim(png::readPNG(with_bm))[1], without[1])
  expect_identical(dim(png::readPNG(with_bm))[2], without[2])
})

test_that("a keymap reaches the saved figure as an inset in its corner (#77)", {
  skip_if_not_installed("tmap")
  skip_if_not_installed("png")
  skip_if_not_installed("gq")
  fx <- ctx_fx()
  seen <- list()
  real <- tmap::tmap_save
  local_mocked_bindings(tmap_save = function(tm, filename, ..., insets_tm = NULL, insets_vp = NULL) {
    seen[[length(seen) + 1]] <<- list(tm = insets_tm, vp = insets_vp)
    if (is.null(insets_tm)) return(real(tm, filename, ...))
    real(tm, filename, ..., insets_tm = insets_tm, insets_vp = insets_vp)
  }, .package = "tmap")
  f <- tempfile(fileext = ".png")
  knw_compare_map(fx$seg, png = f, panels = "rules", width = 4, keymap = list(aoi = fx$aoi, context = fx$context),
                  corners = c(legend = "topleft", scalebar = "topright", keymap = "bottomleft", logo = "bottomright"))
  knw_compare_map(fx$seg, png = f, panels = "rules", width = 4)
  expect_length(seen, 2)
  expect_s3_class(seen[[1]]$tm, "tmap")
  expect_s3_class(seen[[1]]$vp, "viewport")
  # bottom-left: the inset's centre in the left half and the lower half of the canvas
  expect_lt(as.numeric(seen[[1]]$vp$x), 0.5)
  expect_lt(as.numeric(seen[[1]]$vp$y), 0.5)
  expect_null(seen[[2]]$tm)
})

test_that("knw_compare_mapgl adds a metric scale bar bottom-left only when asked (#77)", {
  skip_if_not_installed("mapgl")
  plain <- knw_compare_mapgl(mapgl_fx())
  scaled <- knw_compare_mapgl(mapgl_fx(), scale = TRUE)
  expect_null(plain$x$scale_control)
  expect_identical(scaled$x$scale_control$position, "bottom-left")
  expect_identical(scaled$x$scale_control$unit, "metric")
})
