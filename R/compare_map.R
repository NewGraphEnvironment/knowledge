#' Map a group's segments under two rules, by grade, and its floodplain by the grade beside it
#'
#' Three readings of one group for one species and stage, each as a static
#' figure (tmap, lakes and rivers styled through gq's registry) and, when
#' `html` is given, an interactive page (mapgl):
#' - **rules**: accessible segments coloured kept (habitat under both rules),
#'   lost (`default` only), gained (tuned only), neither;
#' - **grade**: accessible segments shaded by grade class;
#' - **floodplain**: the floodplain cells shaded by the grade of the segment
#'   that owns them (`fp_cells`, from [knw_floodplain_ha()]'s join), where given.
#'
#' Line widths follow stream order so a group's mainstem reads over its
#' headwaters, and the legend names every class drawn.
#'
#' @param segments an `sf` in EPSG:3005 with `accessible`, `stream_order`,
#'   `grade_class` and the two logical rule columns `flag_default` and
#'   `flag_tuned`.
#' @param water an `sf` of lake and river polygons for the group, or `NULL`.
#' @param title `character(1)` the figure's caption line (the map carries no
#'   title; this goes under it).
#' @param png `character(1)` path for the static figure (three panels), or
#'   `NULL`.
#' @param html `character(1)` path for the interactive page, or `NULL`.
#' @param fp_cells `NULL`, or a `SpatRaster` of grade per floodplain cell.
#' @return Invisibly, the paths written.
#' @export
#' @examples
#' \dontrun{
#' knw_compare_map(seg, water, "BULK: CH rearing, default against the tuned rule",
#'                 png = "research/fig/compare_ch_rear_bulk.png")
#' }
knw_compare_map <- function(segments, water = NULL, title = "", png = NULL, html = NULL, fp_cells = NULL) {
  chk::chk_s3_class(segments, "sf")
  chk::check_names(segments, c("accessible", "stream_order", "grade_class", "flag_default", "flag_tuned"))
  if (!requireNamespace("tmap", quietly = TRUE)) stop("tmap is needed", call. = FALSE)
  sf::sf_use_s2(FALSE)
  seg <- segments[segments$accessible %in% TRUE, ]
  seg$rule_class <- factor(ifelse(seg$flag_default & seg$flag_tuned, "kept (both rules)",
                           ifelse(seg$flag_default, "lost (default only)",
                           ifelse(seg$flag_tuned, "gained (tuned only)", "accessible, neither"))),
                           levels = c("kept (both rules)", "lost (default only)", "gained (tuned only)",
                                      "accessible, neither"))
  seg$grade_class <- factor(ifelse(is.na(seg$grade_class), "not graded", seg$grade_class),
                            levels = c("0-0.2", "0.2-0.4", "0.4-0.6", "0.6-0.8", "0.8-1", "not graded"))
  seg$lwd <- pmin(pmax(as.numeric(seg$stream_order), 1), 6) / 3
  rule_cols <- c("kept (both rules)" = "#1b6ca8", "lost (default only)" = "#d95f02", "gained (tuned only)" = "#1b9e77",
                 "accessible, neither" = "grey80")
  grade_cols <- c("0-0.2" = "#f7fbff", "0.2-0.4" = "#c6dbef", "0.4-0.6" = "#6baed6", "0.6-0.8" = "#2171b5",
                  "0.8-1" = "#08306b", "not graded" = "grey85")
  water_style <- NULL
  if (!is.null(water) && nrow(water) && requireNamespace("gq", quietly = TRUE)) {
    reg <- tryCatch(gq::gq_reg_main(), error = function(e) NULL)
    if (!is.null(reg) && !is.null(reg$layers$lake)) {
      water_style <- tryCatch(gq::gq_tmap_style(reg$layers$lake), error = function(e) NULL)
    }
  }
  base <- function() {
    m <- tmap::tm_shape(seg) + tmap::tm_lines(col = "grey90", lwd = 0.3)
    if (!is.null(water) && nrow(water)) {
      m <- m + tmap::tm_shape(water) +
        (if (is.null(water_style)) tmap::tm_polygons(fill = "#9ecae1", col = NA)
         else do.call(tmap::tm_polygons, water_style))
    }
    m
  }
  written <- character()
  if (!is.null(png)) {
    tmap::tmap_mode("plot")
    p1 <- base() + tmap::tm_shape(seg) +
      tmap::tm_lines(col = "rule_class", col.scale = tmap::tm_scale_categorical(values = rule_cols),
                     col.legend = tmap::tm_legend(title = "Habitat by rule"), lwd = "lwd",
                     lwd.legend = tmap::tm_legend_hide()) +
      tmap::tm_layout(frame = FALSE, inner.margins = 0, legend.position = tmap::tm_pos_in("left", "bottom"))
    p2 <- base() + tmap::tm_shape(seg) +
      tmap::tm_lines(col = "grade_class", col.scale = tmap::tm_scale_categorical(values = grade_cols),
                     col.legend = tmap::tm_legend(title = "Grade (expected use)"), lwd = "lwd",
                     lwd.legend = tmap::tm_legend_hide()) +
      tmap::tm_layout(frame = FALSE, inner.margins = 0, legend.position = tmap::tm_pos_in("left", "bottom"))
    panels <- list(p1, p2)
    if (!is.null(fp_cells)) {
      p3 <- base() + tmap::tm_shape(fp_cells) +
        tmap::tm_raster(col.scale = tmap::tm_scale_intervals(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1),
                                                             values = unname(grade_cols[1:5])),
                        col.legend = tmap::tm_legend(title = "Floodplain by its segment's grade")) +
        tmap::tm_layout(frame = FALSE, inner.margins = 0, legend.position = tmap::tm_pos_in("left", "bottom"))
      panels <- c(panels, list(p3))
    }
    dir.create(dirname(png), showWarnings = FALSE, recursive = TRUE)
    tmap::tmap_save(tmap::tmap_arrange(panels, ncol = length(panels)), png, width = 4 * length(panels),
                    height = 4.6, dpi = 150)
    written <- c(written, png)
  }
  if (!is.null(html) && requireNamespace("mapgl", quietly = TRUE) && requireNamespace("htmlwidgets", quietly = TRUE)) {
    s4 <- sf::st_transform(sf::st_zm(seg, drop = TRUE), 4326)
    s4$rule_class <- as.character(s4$rule_class)
    s4$grade_class <- as.character(s4$grade_class)
    m <- mapgl::maplibre(style = mapgl::carto_style("positron"), bounds = s4) |>
      mapgl::add_source("seg", s4) |>
      mapgl::add_line_layer("rules", source = "seg",
                            line_color = mapgl::match_expr("rule_class", values = names(rule_cols),
                                                           stops = unname(rule_cols), default = "grey"),
                            line_width = mapgl::interpolate("stream_order", values = c(1, 6), stops = c(0.6, 3)),
                            tooltip = "rule_class") |>
      mapgl::add_line_layer("grade", source = "seg",
                            line_color = mapgl::match_expr("grade_class", values = names(grade_cols),
                                                           stops = unname(grade_cols), default = "grey"),
                            line_width = mapgl::interpolate("stream_order", values = c(1, 6), stops = c(0.6, 3)),
                            tooltip = "grade_class", visibility = "none") |>
      mapgl::add_categorical_legend(legend_title = title, values = names(rule_cols), colors = unname(rule_cols)) |>
      mapgl::add_layers_control(layers = c("rules", "grade"))
    dir.create(dirname(html), showWarnings = FALSE, recursive = TRUE)
    htmlwidgets::saveWidget(m, html, selfcontained = TRUE, title = title)
    written <- c(written, html)
  }
  invisible(written)
}
