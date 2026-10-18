#' Floodplain hectares beside each segment, from a catalog item's floodplain
#'
#' The stac-floodplains-bc catalog publishes, per watershed group, a whole-network
#' floodplain (`all_ff04`) and its attribution by blue line
#' (`all_ff04_by_blue_line_key`): exact 30 m BC Albers cells, each blue line
#' claiming the cells of its own valley, so the claims overlap where valleys
#' meet. This rasterises `all_ff04` on that same 30 m grid (no reprojection; the
#' cell count times 0.09 ha reproduces the polygon's area), takes the blue-line
#' polygons as the claims, and gives every floodplain cell one owner with
#' `flooded::fl_valley_join()`: the nearest segment among the claiming blue lines'
#' segments (`nearest`, one owner per cell, so hectares add up). Each segment's
#' hectares are its cells times 0.09; graded hectares are hectares times the
#' segment's grade, so 500 ha beside grade-0.9 habitat is 450 and the same 500 ha
#' beside grade-0.3 habitat is 150.
#'
#' Needs `flooded` with `nearest$seg` (flooded#89).
#'
#' @param gpkg `character(1)` the item's `floodplain.gpkg`.
#' @param segments an `sf` of the group's link segments in EPSG:3005 with
#'   `id_segment`, `blue_line_key`, logical flag columns `flags`, and `grade`.
#' @param flags `character` the logical columns (habitat under each rule,
#'   `accessible`) to carry; `fl_valley_join()` takes logical columns only.
#' @param scenario `character(1)` the floodplain layer and the attribution layer's prefix.
#' @return A list: `segments`, `segments` with `fp_ha` and `fp_graded_ha` added;
#'   `summary`, one row per flag: hectares beside segments where the flag holds,
#'   graded hectares, and hectares by grade class; `check`, `fl_valley_join()`'s
#'   cell accounting plus the polygon area and the raster's area in km².
#' @export
#' @examples
#' \dontrun{
#' seg <- sf::st_read(conn, query = "SELECT id_segment, blue_line_key, geom FROM fresh_default.streams
#'                                   WHERE watershed_group_code = 'LARL'")
#' seg$rearing_default <- ...; seg$rearing_tuned <- ...; seg$grade <- ...
#' fp <- knw_floodplain_ha("larl_floodplain.gpkg", seg, c("rearing_default", "rearing_tuned"))
#' fp$summary
#' }
knw_floodplain_ha <- function(gpkg, segments, flags, scenario = "all_ff04") {
  chk::chk_file(gpkg)
  chk::chk_s3_class(segments, "sf")
  chk::check_names(segments, c("id_segment", "blue_line_key", "grade", flags))
  if (!requireNamespace("flooded", quietly = TRUE) || !requireNamespace("terra", quietly = TRUE)) {
    stop("flooded and terra are needed", call. = FALSE)
  }
  if (!.knw_flooded_has_seg()) {
    stop("flooded::fl_valley_join() does not return the owning segment: install flooded with #89", call. = FALSE)
  }
  layers <- sf::st_layers(gpkg)$name
  lyr_fp <- scenario
  lyr_bl <- paste0(scenario, "_by_blue_line_key")
  if (!all(c(lyr_fp, lyr_bl) %in% layers)) stop(gpkg, " lacks ", lyr_fp, " or ", lyr_bl, call. = FALSE)
  fp <- sf::st_read(gpkg, layer = lyr_fp, quiet = TRUE)
  bl <- sf::st_read(gpkg, layer = lyr_bl, quiet = TRUE)
  if (sf::st_crs(fp)$epsg != 3005 || sf::st_crs(bl)$epsg != 3005) {
    stop("the floodplain layers are not in EPSG:3005", call. = FALSE)
  }
  if (!nrow(segments)) stop("segments has no rows", call. = FALSE)
  if (is.na(sf::st_crs(segments))) stop("segments has no CRS", call. = FALSE)
  if (!isTRUE(sf::st_crs(segments)$epsg == 3005)) segments <- sf::st_transform(segments, 3005)
  bl$blue_line_key <- as.numeric(bl$blue_line_key)
  segments$blue_line_key <- as.numeric(segments$blue_line_key)
  for (f in flags) if (!is.logical(segments[[f]])) stop(f, " is not logical", call. = FALSE)

  # the 30 m BC Albers grid the polygons were cut on: cell edges at multiples of 30
  bb <- sf::st_bbox(fp)
  res <- 30
  xmin <- floor(bb[["xmin"]] / res) * res
  ymin <- floor(bb[["ymin"]] / res) * res
  xmax <- ceiling(bb[["xmax"]] / res) * res
  ymax <- ceiling(bb[["ymax"]] / res) * res
  tmpl <- terra::rast(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, resolution = res, crs = "EPSG:3005")
  valleys <- terra::rasterize(terra::vect(fp), tmpl, field = 1L, background = 0L, touches = FALSE)
  n_cells <- sum(terra::values(valleys, mat = FALSE) == 1L, na.rm = TRUE)
  area_poly_km2 <- as.numeric(sum(sf::st_area(fp))) / 1e6
  area_rast_km2 <- n_cells * res * res / 1e6
  if (abs(area_rast_km2 - area_poly_km2) / area_poly_km2 > 0.001) {
    stop(sprintf(paste("the rasterised floodplain (%.3f km2) does not reproduce the polygon (%.3f km2):",
                       "the grid is not the polygons'"), area_rast_km2, area_poly_km2), call. = FALSE)
  }
  sg <- segments[, c("id_segment", "blue_line_key", "grade", flags)]
  sg <- sg[sg$blue_line_key %in% bl$blue_line_key, ]
  j <- flooded::fl_valley_join(valleys, bl, sg, group = "blue_line_key", cols = flags)
  cell_ha <- res * res / 1e4
  own <- j$nearest$seg
  ok <- !is.na(own)
  ha_by_seg <- tapply(rep(cell_ha, sum(ok)), own[ok], sum)
  out <- segments
  i <- match(seq_len(nrow(sg)), as.integer(names(ha_by_seg)))
  fp_ha <- ifelse(is.na(i), 0, as.numeric(ha_by_seg)[i])
  out$fp_ha <- 0
  out$fp_ha[match(sg$id_segment, out$id_segment)] <- fp_ha
  out$fp_graded_ha <- out$fp_ha * ifelse(is.na(out$grade), 0, out$grade)
  classes <- c("0-0.2", "0.2-0.4", "0.4-0.6", "0.6-0.8", "0.8-1")
  gc <- as.character(cut(out$grade, c(0, 0.2, 0.4, 0.6, 0.8, 1), include.lowest = TRUE, labels = classes))
  summary <- do.call(rbind, lapply(flags, function(f) {
    sel <- out[[f]] %in% TRUE
    row <- tibble::tibble(flag = f, ha = sum(out$fp_ha[sel]), graded_ha = sum(out$fp_graded_ha[sel]),
                          ha_grade_na = sum(out$fp_ha[sel & is.na(out$grade)]))
    for (cl in classes) row[[paste0("ha_", cl)]] <- sum(out$fp_ha[sel & gc %in% cl])
    row
  }))
  check <- c(j$check, ties = j$ties, no_segment_groups = length(j$no_segments),
             cells_unowned = sum(!ok), area_poly_km2 = area_poly_km2, area_rast_km2 = area_rast_km2,
             floodplain_ha = n_cells * cell_ha, ha_owned = sum(out$fp_ha))
  list(segments = out, summary = summary, check = check)
}

# Whether the installed flooded returns the owning segment in `nearest` (flooded#89): one join on a
# two-cell valley with one claiming group and one segment.
.knw_flooded_has_seg <- function() {
  r <- terra::rast(nrows = 2, ncols = 2, xmin = 0, xmax = 60, ymin = 0, ymax = 60, crs = "EPSG:3005", vals = 1L)
  ring <- rbind(c(0, 0), c(60, 0), c(60, 60), c(0, 60), c(0, 0))
  a <- sf::st_sf(k = 1L, geometry = sf::st_sfc(sf::st_polygon(list(ring)), crs = 3005))
  s <- sf::st_sf(k = 1L, f = TRUE, geometry = sf::st_sfc(sf::st_linestring(rbind(c(5, 0), c(5, 60))), crs = 3005))
  "seg" %in% names(flooded::fl_valley_join(r, a, s, group = "k", cols = "f")$nearest)
}
