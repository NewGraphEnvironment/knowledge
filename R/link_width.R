#' The channel width link reads on a stream nobody measured, and the waterbody tests
#'
#' `scripts/0296`'s width. link joins `whse_basemapping.fwa_stream_networks_channel_width`
#' province-wide, and its `FIELD_MEASURMENT` rows are FDIS sites, so at a visit
#' the stored width can be that visit's own measurement, which link never sees on
#' the unmeasured streams it classifies. So fwapg's own width model (upstream area
#' and upstream mean annual precipitation, Thorley and Irvine 2021b) is recomputed
#' here for the segments' watershed codes, and `cw_deploy` is the width link would
#' read with no field measurement: the stored width unless it is `FIELD_MEASURMENT`,
#' then the model where `stream_order > 1` (fwapg models no order-1 stream) and `NA`
#' otherwise. The recomputed model must match the stored `MODELLED` widths within
#' `tol` (relative) on at least `agree_min` of them, or the call stops: the stored
#' widths come from older inputs, and a larger disagreement means the formula or
#' its inputs have changed.
#'
#' Alongside the width, the waterbody tests of link's `default` rules: whether the
#' segment's `waterbody_key` is a river polygon, a wetland of at least
#' `wetland_ha_min`, or a lake or man-made waterbody of at least `lake_ha_min`.
#'
#' @param conn a `DBI` connection to a database holding `whse_basemapping`.
#' @param linear_feature_id `numeric` FWA segment ids.
#' @param tol,agree_min `numeric(1)` the model-agreement control.
#' @param wetland_ha_min,lake_ha_min `numeric(1)` link `default`'s area floors.
#' @return A list: `widths`, one row per segment (`linear_feature_id`,
#'   `fwa_waterbody_key`, `fwa_channel_width`, `fwa_cw_source`, `fwa_stream_order`,
#'   `cw_model`, `cw_deploy`, `wb_river`, `wb_wetland`, `wb_lake`, `wb_any_lake`);
#'   `control`, a one-row `data.frame` with `n_modelled`, `agree_share` and
#'   `median_ratio`.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_link_width(conn, c(701747495, 701747496))$widths
#' }
knw_link_width <- function(conn, linear_feature_id, tol = 0.05, agree_min = 0.95,
                           wetland_ha_min = 1, lake_ha_min = 100) {
  chk::chk_numeric(linear_feature_id)
  chk::chk_not_any_na(linear_feature_id)
  chk::chk_number(tol)
  chk::chk_number(agree_min)
  tmp <- "tmp_knw_link_width"
  DBI::dbWriteTable(conn, tmp, data.frame(linear_feature_id = unique(linear_feature_id)),
                    temporary = TRUE, overwrite = TRUE)
  on.exit(try(DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp)), silent = TRUE), add = TRUE)
  fs <- DBI::dbGetQuery(conn, sprintf("
    SELECT t.linear_feature_id, s.waterbody_key, s.stream_order AS fwa_stream_order,
           cw.channel_width, cw.channel_width_source,
           s.waterbody_key IN (SELECT waterbody_key FROM whse_basemapping.fwa_rivers_poly) AS wb_river,
           s.waterbody_key IN (SELECT waterbody_key FROM whse_basemapping.fwa_wetlands_poly WHERE area_ha >= %2$s)
             AS wb_wetland,
           s.waterbody_key IN (SELECT waterbody_key FROM whse_basemapping.fwa_lakes_poly WHERE area_ha >= %3$s
                               UNION SELECT waterbody_key FROM whse_basemapping.fwa_manmade_waterbodies_poly
                               WHERE area_ha >= %3$s) AS wb_lake,
           s.waterbody_key IN (SELECT waterbody_key FROM whse_basemapping.fwa_lakes_poly) AS wb_any_lake
    FROM %1$s t
    JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
    LEFT JOIN whse_basemapping.fwa_stream_networks_channel_width cw
      ON cw.linear_feature_id = t.linear_feature_id", tmp, wetland_ha_min, lake_ha_min))
  if (anyDuplicated(fs$linear_feature_id)) stop("a segment has two channel widths", call. = FALSE)
  # fwapg's width model, recomputed for the segments' watershed codes (its SQL, restricted to them)
  cwm <- DBI::dbGetQuery(conn, sprintf("
    WITH vc AS (
      SELECT DISTINCT s.wscode_ltree, s.localcode_ltree, s.watershed_group_code
      FROM %1$s t
      JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
      WHERE s.localcode_ltree IS NOT NULL),
    streams AS (
      SELECT s.wscode_ltree, s.localcode_ltree, s.watershed_group_code,
             max(coalesce(ua.upstream_area_ha, 0)) + 1 AS upstream_area_ha
      FROM whse_basemapping.fwa_stream_networks_sp s
      JOIN vc ON vc.wscode_ltree = s.wscode_ltree AND vc.localcode_ltree = s.localcode_ltree
             AND vc.watershed_group_code = s.watershed_group_code
      LEFT JOIN whse_basemapping.fwa_streams_watersheds_lut l ON s.linear_feature_id = l.linear_feature_id
      JOIN whse_basemapping.fwa_watersheds_upstream_area ua ON l.watershed_feature_id = ua.watershed_feature_id
      GROUP BY 1, 2, 3)
    SELECT t.linear_feature_id,
           round(exp(0.3071300 + 0.4577882 *
             (ln(m.upstream_area_ha) + ln(coalesce(p.map_upstream, 0) + 1) - ln(100) - ln(1000)))::numeric, 2)::float8
             AS cw_model
    FROM %1$s t
    JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
    LEFT JOIN streams m ON m.wscode_ltree = s.wscode_ltree AND m.localcode_ltree = s.localcode_ltree
                       AND m.watershed_group_code = s.watershed_group_code
    LEFT JOIN whse_basemapping.fwa_stream_networks_mean_annual_precip p
      ON p.wscode_ltree = s.wscode_ltree AND p.localcode_ltree = s.localcode_ltree", tmp))
  if (anyDuplicated(cwm$linear_feature_id)) stop("a segment has two modelled widths", call. = FALSE)
  w <- merge(fs, cwm, by = "linear_feature_id", all.x = TRUE)
  field <- w$channel_width_source %in% "FIELD_MEASURMENT"
  w$cw_deploy <- ifelse(!field, w$channel_width, ifelse(w$fwa_stream_order > 1, w$cw_model, NA_real_))
  mo <- w[w$channel_width_source %in% "MODELLED", , drop = FALSE]
  ratio <- mo$cw_model / mo$channel_width
  agree <- if (nrow(mo)) mean(!is.na(ratio) & abs(ratio - 1) <= tol) else NA_real_
  control <- data.frame(n_modelled = nrow(mo), agree_share = agree,
                        median_ratio = if (nrow(mo)) stats::median(ratio, na.rm = TRUE) else NA_real_)
  if (nrow(mo) && agree < agree_min) {
    stop("fwapg's width model reproduces the stored MODELLED width within ", 100 * tol, " % on only ",
         round(100 * agree, 1), " % of segments", call. = FALSE)
  }
  widths <- tibble::tibble(
    linear_feature_id = as.numeric(w$linear_feature_id), fwa_waterbody_key = as.numeric(w$waterbody_key),
    fwa_channel_width = as.numeric(w$channel_width), fwa_cw_source = w$channel_width_source,
    fwa_stream_order = as.integer(w$fwa_stream_order), cw_model = as.numeric(w$cw_model),
    cw_deploy = as.numeric(w$cw_deploy),
    wb_river = w$wb_river %in% TRUE, wb_wetland = w$wb_wetland %in% TRUE, wb_lake = w$wb_lake %in% TRUE,
    wb_any_lake = w$wb_any_lake %in% TRUE
  )
  list(widths = widths[order(widths$linear_feature_id), , drop = FALSE], control = control)
}
