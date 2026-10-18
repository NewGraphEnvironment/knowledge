test_that("hectares beside each segment come from the catalog's 30 m cells, one owner per cell", {
  skip_if_not_installed("flooded")
  skip_if_not_installed("terra")
  skip_if_not(
    "seg" %in% names(formals(flooded::fl_valley_join)) ||
      grepl("nearest$seg", paste(deparse(body(flooded::fl_valley_join)), collapse = ""), fixed = TRUE),
    "flooded without nearest$seg (flooded#89)"
  )
  tmp <- withr::local_tempfile(fileext = ".gpkg")
  cell <- function(x0, y0) sf::st_polygon(list(rbind(c(x0, y0), c(x0 + 30, y0), c(x0 + 30, y0 + 30), c(x0, y0 + 30), c(x0, y0))))
  # a floodplain of four 30 m cells in a row, x 1000000-1000120, y 500000-500030, exact on the grid
  fp_geom <- sf::st_union(sf::st_sfc(cell(1e6, 5e5), cell(1e6 + 30, 5e5), cell(1e6 + 60, 5e5), cell(1e6 + 90, 5e5), crs = 3005))
  fp <- sf::st_sf(valley = 1L, wsg = "TEST", species = "all", scenario = "all_ff04", geom = fp_geom)
  # blue line 1 claims the left three cells, blue line 2 the right three: two cells shared
  left <- sf::st_union(sf::st_sfc(cell(1e6, 5e5), cell(1e6 + 30, 5e5), cell(1e6 + 60, 5e5), crs = 3005))
  right <- sf::st_union(sf::st_sfc(cell(1e6 + 30, 5e5), cell(1e6 + 60, 5e5), cell(1e6 + 90, 5e5), crs = 3005))
  bl <- sf::st_sf(valley = 1L, blue_line_key = c(1, 2), wsg = "TEST", species = "all", scenario = "all_ff04",
                  geom = c(left, right))
  sf::st_write(fp, tmp, layer = "all_ff04", quiet = TRUE)
  sf::st_write(bl, tmp, layer = "all_ff04_by_blue_line_key", quiet = TRUE, append = TRUE)
  # segments: blue line 1's segment runs along the left edge, blue line 2's along the right edge
  seg <- sf::st_sf(id_segment = c(11, 22), blue_line_key = c(1, 2), grade = c(0.5, 1), rearing = c(TRUE, FALSE),
                   accessible = TRUE,
                   geom = sf::st_sfc(sf::st_linestring(rbind(c(1e6 + 1, 5e5), c(1e6 + 1, 5e5 + 30))),
                                     sf::st_linestring(rbind(c(1e6 + 119, 5e5), c(1e6 + 119, 5e5 + 30))), crs = 3005))
  out <- knw_floodplain_ha(tmp, seg, c("rearing", "accessible"))
  expect_equal(unname(out$check[["floodplain_ha"]]), 4 * 0.09)
  expect_equal(unname(out$check[["missing"]]), 0)
  expect_equal(unname(out$check[["ha_owned"]]), 4 * 0.09)
  # the two shared cells go to the nearer segment: cell 2 to segment 11, cell 3 to segment 22
  expect_equal(out$segments$fp_ha[out$segments$id_segment == 11], 2 * 0.09)
  expect_equal(out$segments$fp_ha[out$segments$id_segment == 22], 2 * 0.09)
  expect_equal(out$segments$fp_graded_ha[out$segments$id_segment == 11], 2 * 0.09 * 0.5)
  s <- out$summary
  expect_equal(s$ha[s$flag == "rearing"], 2 * 0.09)
  expect_equal(s$graded_ha[s$flag == "rearing"], 2 * 0.09 * 0.5)
  expect_equal(s$ha[s$flag == "accessible"], 4 * 0.09)
  expect_equal(s$`ha_0.4-0.6`[s$flag == "accessible"], 2 * 0.09)
})
