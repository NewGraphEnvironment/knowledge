#' Map a group's segments under two rules, by grade, and its floodplain by the grade beside it
#'
#' Three readings of one group for one species and stage, each as a static
#' figure (tmap, lakes and rivers styled through gq's registry) and, when
#' `html` is given, an interactive page ([knw_compare_mapgl()], saved
#' self-contained):
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
#' @param title `character(1)` names the figure in the message when nothing is
#'   drawn, and is the interactive page's title and legend title; the static
#'   figure draws no title (that belongs in the caption).
#' @param png `character(1)` path for the static figure, or `NULL`: one panel
#'   for each of `panels` that can be drawn (`"floodplain"` needs `fp_cells`),
#'   `ncol` to a row.
#' @param html `character(1)` path for the interactive page, or `NULL`.
#' @param background passed to [knw_compare_mapgl()] for the interactive page.
#' @param fp_cells `NULL`, or a `SpatRaster` of grade per floodplain cell.
#' @param ncol `integer(1)` panels per row in the static figure, or `NULL`
#'   for all panels side by side; each panel is 4 in by 4.6 in, so `ncol = 1`
#'   stacks them for a narrow column.
#' @param panels `character` which static panels to draw, any of `"rules"`,
#'   `"grade"` and `"floodplain"` (drawn only where `fp_cells` is given).
#' @param mark `NULL`, or an `sf` polygon outlined on every static panel, such
#'   as the window of a zoomed map drawn by a second call on cropped segments.
#' @param lwd `numeric(1)` multiplier on the static panels' line widths, for a
#'   zoomed window where stream-order widths read too thin.
#' @param legend `logical(1)` draw the static panels' legends; `FALSE` for a
#'   zoomed panel beside an overview that carries them.
#' @param labels `NULL`, or an `sf` of points with a `label` column, drawn as
#'   numbered markers on every static panel (examples a table beside the map
#'   describes).
#' @return Invisibly, the paths written.
#' @export
#' @examples
#' \dontrun{
#' knw_compare_map(seg, water, "BULK: CH rearing, default against the tuned rule",
#'                 png = "research/fig/compare_ch_rear_bulk.png")
#' }
knw_compare_map <- function(segments, water = NULL, title = "", png = NULL, html = NULL, fp_cells = NULL,
                            ncol = NULL, panels = c("rules", "grade", "floodplain"), mark = NULL, lwd = 1,
                            legend = TRUE, labels = NULL, background = c("voyager", "openfreemap", "esri_topo")) {
  chk::chk_s3_class(segments, "sf")
  chk::check_names(segments, c("accessible", "stream_order", "grade_class", "flag_default", "flag_tuned"))
  if (!is.null(ncol)) chk::chk_whole_number(ncol)
  if (!is.null(ncol)) chk::chk_gte(ncol, 1)
  chk::chk_character(panels)
  chk::chk_subset(panels, c("rules", "grade", "floodplain"))
  if (!length(panels)) stop("panels names no panel", call. = FALSE)
  if (!is.null(mark)) chk::chk_s3_class(mark, "sf")
  chk::chk_number(lwd)
  chk::chk_gt(lwd, 0)
  chk::chk_flag(legend)
  if (!is.null(labels)) {
    chk::chk_s3_class(labels, "sf")
    chk::check_names(labels, "label")
  }
  background <- match.arg(background)
  if (!requireNamespace("tmap", quietly = TRUE)) stop("tmap is needed", call. = FALSE)
  sf::sf_use_s2(FALSE)
  seg <- segments[segments$accessible %in% TRUE, ]
  if (!nrow(seg)) {
    # a group where no segment passes the species' access gate (link#349: RB in 23 groups) has nothing to draw
    message("no accessible segment: nothing drawn for ", title)
    return(invisible(character()))
  }
  seg <- .compare_classes(seg)
  seg$lwd <- pmin(pmax(as.numeric(seg$stream_order), 1), 6) / 3
  rule_cols <- .compare_rule_cols
  grade_cols <- .compare_grade_cols
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
    lay <- tmap::tm_layout(frame = FALSE, inner.margins = 0, legend.position = tmap::tm_pos_in("left", "bottom"))
    outline <- if (is.null(mark)) NULL else tmap::tm_shape(mark) + tmap::tm_borders(col = "black", lwd = 1.5)
    if (!is.null(labels)) {
      marks <- tmap::tm_shape(labels) + tmap::tm_symbols(size = 1.1, fill = "white", col = "black", lwd = 1.2) +
        tmap::tm_text(text = "label", size = 0.8, fontface = "bold")
      outline <- if (is.null(outline)) marks else outline + marks
    }
    drawn <- list()
    if ("rules" %in% panels) {
      drawn$rules <- base() + tmap::tm_shape(seg) +
        tmap::tm_lines(col = "rule_class", col.scale = tmap::tm_scale_categorical(values = rule_cols),
                       col.legend = if (legend) tmap::tm_legend(title = "Habitat by rule") else tmap::tm_legend_hide(),
                       lwd = "lwd", lwd.scale = tmap::tm_scale_continuous(values.scale = lwd),
                       lwd.legend = tmap::tm_legend_hide()) + outline + lay
    }
    if ("grade" %in% panels) {
      drawn$grade <- base() + tmap::tm_shape(seg) +
        tmap::tm_lines(col = "grade_class", col.scale = tmap::tm_scale_categorical(values = grade_cols),
                       col.legend = if (legend) tmap::tm_legend(title = "Grade (expected use)") else tmap::tm_legend_hide(),
                       lwd = "lwd", lwd.scale = tmap::tm_scale_continuous(values.scale = lwd),
                       lwd.legend = tmap::tm_legend_hide()) + outline + lay
    }
    if ("floodplain" %in% panels && !is.null(fp_cells)) {
      drawn$floodplain <- base() + tmap::tm_shape(fp_cells) +
        tmap::tm_raster(col.scale = tmap::tm_scale_intervals(breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1),
                                                             values = unname(grade_cols[1:5]),
                                                             labels = names(grade_cols)[1:5]),
                        col.legend = if (legend) tmap::tm_legend(title = "Floodplain by its segment's grade") else tmap::tm_legend_hide()) + outline + lay
    }
    if (!length(drawn)) stop("no panel to draw: 'floodplain' alone needs fp_cells", call. = FALSE)
    dir.create(dirname(png), showWarnings = FALSE, recursive = TRUE)
    nc <- min(if (is.null(ncol)) length(drawn) else as.integer(ncol), length(drawn))
    nr <- ceiling(length(drawn) / nc)
    fig <- if (length(drawn) == 1L) drawn[[1]] else tmap::tmap_arrange(unname(drawn), ncol = nc, nrow = nr)
    tmap::tmap_save(fig, png, width = 4 * nc, height = 4.6 * nr, dpi = 150)
    written <- c(written, png)
  }
  if (!is.null(html) && requireNamespace("mapgl", quietly = TRUE) && requireNamespace("htmlwidgets", quietly = TRUE)) {
    m <- knw_compare_mapgl(segments, water, title = title, background = background)
    dir.create(dirname(html), showWarnings = FALSE, recursive = TRUE)
    htmlwidgets::saveWidget(m, html, selfcontained = TRUE, title = title)
    written <- c(written, html)
  }
  invisible(written)
}

# the classes and colours both maps draw; hex throughout, because MapLibre rejects R's colour names (grey80)
.compare_rule_cols <- c("kept (both rules)" = "#1b6ca8", "lost (default only)" = "#d95f02",
                        "gained (tuned only)" = "#1b9e77", "accessible, neither" = "#cccccc")
.compare_grade_cols <- c("0-0.2" = "#f7fbff", "0.2-0.4" = "#c6dbef", "0.4-0.6" = "#6baed6", "0.6-0.8" = "#2171b5",
                         "0.8-1" = "#08306b", "not graded" = "#d9d9d9")

.compare_classes <- function(seg) {
  seg$rule_class <- factor(ifelse(seg$flag_default & seg$flag_tuned, "kept (both rules)",
                           ifelse(seg$flag_default, "lost (default only)",
                           ifelse(seg$flag_tuned, "gained (tuned only)", "accessible, neither"))),
                           levels = names(.compare_rule_cols))
  seg$grade_class <- factor(ifelse(is.na(seg$grade_class), "not graded", seg$grade_class),
                            levels = names(.compare_grade_cols))
  seg
}

#' The interactive map of a group's segments under two rules
#'
#' The page [knw_compare_map()] saves when given `html`, as a mapgl widget to
#' print in an R Markdown page or save: accessible segments coloured by rule
#' (kept by both, lost, gained, neither) and, on a second layer the switch at the
#' top right turns on, by grade class, each with its legend at the top left;
#' lakes and rivers styled through gq's registry where it loads. Clicking a
#' segment opens a popup with the fields it carries among the stream order, grade,
#' mean annual flow (`mad`), channel width, gradient, the walk distance to the
#' rule's river (`dist_m`), the waterbody it lies in (`water`, `water_ha`), and
#' each rule's verdict, saying where the hand-entered reaches or the step that keeps
#' rearing only where it connects to spawning changed it (`pre_default`,
#' `pre_tuned`, the verdict from the habitat test alone).
#'
#' Coordinates are rounded to `digits` decimal degrees after the transform to
#' EPSG:4326 (5 is about 1 m), and only the drawn and popup fields are kept, which
#' sets the page's size.
#'
#' @inheritParams knw_compare_map
#' @param title `character(1)` the rules legend's title.
#' @param background `"voyager"` (Carto Voyager), `"openfreemap"` (OpenFreeMap
#'   Liberty) or `"esri_topo"` (Esri's World Topographic Map raster tiles, keyless;
#'   Esri allows free noncommercial use with attribution, which the map shows).
#' @param digits `integer(1)` decimal places kept in the coordinates.
#' @return A `maplibregl` htmlwidget, or `NULL` with a message when no segment is
#'   accessible.
#' @export
#' @examples
#' if (requireNamespace("mapgl", quietly = TRUE)) {
#'   seg <- sf::st_sf(
#'     accessible = TRUE, stream_order = 1:3, grade_class = c("0-0.2", "0.8-1", NA),
#'     flag_default = c(TRUE, TRUE, FALSE), flag_tuned = c(TRUE, FALSE, TRUE), mad = c(0.4, 2.1, 0.1),
#'     geometry = sf::st_sfc(lapply(0:2, function(i) {
#'       sf::st_linestring(rbind(c(1e6 + i * 500, 1e6), c(1e6 + (i + 1) * 500, 1e6 + 300)))
#'     }), crs = 3005)
#'   )
#'   m <- knw_compare_mapgl(seg, title = "Habitat by rule")
#'   class(m)
#' }
knw_compare_mapgl <- function(segments, water = NULL, title = "",
                              background = c("voyager", "openfreemap", "esri_topo"),
                              digits = 5L) {
  chk::chk_s3_class(segments, "sf")
  chk::check_names(segments, c("accessible", "stream_order", "grade_class", "flag_default", "flag_tuned"))
  background <- match.arg(background)
  chk::chk_whole_number(digits)
  if (!requireNamespace("mapgl", quietly = TRUE)) stop("mapgl is needed", call. = FALSE)
  seg <- segments[segments$accessible %in% TRUE, ]
  if (!nrow(seg)) {
    message("no accessible segment: nothing drawn for ", title)
    return(invisible(NULL))
  }
  seg <- .compare_classes(seg)
  pop <- .compare_popup(seg)
  # classes as their position in the colour vectors: the names, repeated on every feature, were a fifth of the page
  s4 <- sf::st_sf(data.frame(rc = as.integer(seg$rule_class), gc = as.integer(seg$grade_class),
                             stream_order = as.integer(seg$stream_order), pop$props, stringsAsFactors = FALSE),
                  geometry = .round_sfc(sf::st_transform(sf::st_geometry(sf::st_zm(seg, drop = TRUE)), 4326), digits))
  style <- switch(background,
                  voyager = mapgl::carto_style("voyager"),
                  openfreemap = mapgl::openfreemap_style("liberty"),
                  esri_topo = .esri_topo_style())
  m <- mapgl::maplibre(style = style, bounds = s4)
  if (!is.null(water) && nrow(water)) {
    # an attribute column, because geojsonsf writes a geometry-only sf as bare geometries, not a FeatureCollection
    w4 <- sf::st_sf(kind = if ("kind" %in% names(water)) as.character(water$kind) else "water",
                    geometry = .round_sfc(sf::st_transform(sf::st_geometry(sf::st_zm(water, drop = TRUE)), 4326),
                                          digits))
    paint <- list(`fill-color` = "#dcecf4", `fill-opacity` = 0.7, `fill-outline-color` = "#1f78b4")
    if (requireNamespace("gq", quietly = TRUE)) {
      st <- tryCatch(gq::gq_mapgl_style(gq::gq_reg_main()$layers$lake), error = function(e) NULL)
      if (!is.null(st$paint)) paint <- utils::modifyList(paint, st$paint)
    }
    m <- m |>
      mapgl::add_source("knw_water", w4) |>
      mapgl::add_fill_layer("knw_water", source = "knw_water", fill_color = paint$`fill-color`,
                            fill_opacity = paint$`fill-opacity`, fill_outline_color = paint$`fill-outline-color`)
  }
  width <- mapgl::interpolate("stream_order", values = c(1, 6), stops = c(0.6, 3))
  m |>
    mapgl::add_source("knw_seg", s4) |>
    mapgl::add_line_layer("rules", source = "knw_seg",
                          line_color = mapgl::match_expr("rc", values = seq_along(.compare_rule_cols),
                                                         stops = unname(.compare_rule_cols), default = "#cccccc"),
                          line_width = width, popup = pop$expr) |>
    mapgl::add_line_layer("grade", source = "knw_seg",
                          line_color = mapgl::match_expr("gc", values = seq_along(.compare_grade_cols),
                                                         stops = unname(.compare_grade_cols), default = "#d9d9d9"),
                          line_width = width, popup = pop$expr, visibility = "none") |>
    mapgl::add_categorical_legend(legend_title = title, values = names(.compare_rule_cols),
                                  colors = unname(.compare_rule_cols), position = "top-left", layer_id = "rules",
                                  unique_id = "legend_rules") |>
    mapgl::add_categorical_legend(legend_title = "Grade (expected use)", values = names(.compare_grade_cols),
                                  colors = unname(.compare_grade_cols), position = "top-left", layer_id = "grade",
                                  unique_id = "legend_grade", add = TRUE) |>
    mapgl::add_layers_control(layers = c("rules", "grade"), position = "top-right")
}

# the popup's fields as short display strings, and the expression that writes the popup from them in the browser: a
# prebuilt HTML string per segment more than doubled the page, and mapgl's popup evaluator reads only get, concat,
# to-string, to-number and number-format, so a missing value is the string "none" rather than a case expression
.compare_popup <- function(seg) {
  has <- function(k) k %in% names(seg)
  txt <- function(v, f) ifelse(is.na(v), "none", f(v))
  # per value, never format() over the vector, which picks one notation for all (3.7e-02 beside 2.20)
  sig2 <- function(v) trimws(formatC(signif(v, 2), digits = 2, format = "fg"))
  verdict <- function(final, pre) {
    out <- ifelse(final, "yes", "no")
    if (!is.null(pre)) {
      out[final & !(pre %in% TRUE)] <- "yes (a hand-entered reach)"
      out[!final & pre %in% TRUE] <- "no (not connected to spawning)"
    }
    out
  }
  props <- data.frame(vd = verdict(seg$flag_default %in% TRUE, if (has("pre_default")) seg$pre_default),
                      vt = verdict(seg$flag_tuned %in% TRUE, if (has("pre_tuned")) seg$pre_tuned))
  get <- function(k) list("get", k)
  expr <- list("concat", "Habitat under default: ", get("vd"), "<br>Habitat under the tuned rule: ", get("vt"))
  add <- function(label, k, v) {
    props[[k]] <<- v
    expr <<- c(expr, list(paste0("<br>", label, ": ")), list(get(k)))
  }
  if (has("grade")) add("Grade", "gr", txt(seg$grade, function(v) formatC(v, format = "f", digits = 2)))
  add("Stream order", "so", as.character(seg$stream_order))
  if (has("water")) {
    wa <- unname(c(stream = "stream line", river = "river polygon", wetland = "wetland", lake = "lake")[seg$water])
    wa[is.na(wa)] <- "unknown"
    sig3 <- function(v) trimws(formatC(signif(v, 3), digits = 3, format = "fg"))
    if (has("water_ha")) wa <- ifelse(is.na(seg$water_ha), wa, paste0(wa, ", ", sig3(seg$water_ha), " ha"))
    add("Water", "wa", wa)
  }
  if (has("mad")) add("Average flow (m\u00b3/s)", "q", txt(seg$mad, sig2))
  if (has("channel_width")) add("Channel width (m)", "w", txt(seg$channel_width, sig2))
  pct1 <- function(v) formatC(100 * v, format = "f", digits = 1)
  if (has("gradient")) add("Gradient (%)", "g", txt(seg$gradient, pct1))
  if (has("dist_m")) {
    add("Downstream to the rule's river (km)", "d", txt(seg$dist_m / 1000, sig2))
  }
  list(props = props, expr = expr)
}

# round every coordinate of a line or polygon sfc
.round_sfc <- function(g, digits) {
  rnd <- function(x) {
    y <- if (is.list(x)) lapply(x, rnd) else round(as.numeric(unclass(x)), digits)
    attributes(y) <- attributes(x)
    y
  }
  sf::st_sfc(lapply(g, rnd), crs = sf::st_crs(g))
}

# Esri's World Topographic Map as a MapLibre raster style. Its tile service needs no key, and Esri allows free
# noncommercial use with attribution; the attribution is the service's own `copyrightText` (World_Topo_Map/MapServer,
# read 2026-10-21) after "Powered by Esri", shown in the map's attribution control.
.esri_topo_style <- function() {
  attribution <- paste0("Powered by <a href=\"https://www.esri.com\">Esri</a> | Sources: Esri, HERE, Garmin, ",
                        "Intermap, increment P Corp., GEBCO, USGS, FAO, NPS, NRCAN, GeoBase, IGN, Kadaster NL, ",
                        "Ordnance Survey, Esri Japan, METI, Esri China (Hong Kong), (c) OpenStreetMap contributors, ",
                        "and the GIS User Community")
  tiles <- "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}"
  src <- list(type = "raster", tiles = list(tiles), tileSize = 256, maxzoom = 19, attribution = attribution)
  list(version = 8, sources = list(esri_topo = src),
       layers = list(list(id = "esri_topo", type = "raster", source = "esri_topo")))
}
