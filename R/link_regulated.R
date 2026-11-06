#' Points on the FWA network downstream of a regulating dam
#'
#' `scripts/0294`'s regulated-reach test. A CABD dam with a reservoir, or a
#' degree of regulation of `regulation_min` percent or more, is placed on the
#' nearest main-flow FWA segment within `dam_snap_m`; a point is regulated when
#' such a dam lies upstream of it (`fwa_downstream()` with the roles swapped).
#' wet's flow is natural flow, so on a regulated river it is not the flow the
#' fish meet. A dam equally near two segments is placed on the one with the
#' lower `linear_feature_id`, so every database places it alike (#161).
#'
#' @param conn a `DBI` connection to a database holding `cabd` and
#'   `whse_basemapping`.
#' @param pts `data.frame` with `blue_line_key`, `downstream_route_measure`,
#'   `wscode` and `localcode` (ltree text, as [knw_link_flow()] returns them).
#' @param dam_snap_m `numeric(1)` how far a dam may sit from the segment it is
#'   placed on.
#' @param regulation_min `numeric(1)` percent degree of regulation at or above
#'   which a dam without a reservoir counts.
#' @return A list: `regulated`, a `tibble` of the distinct `pts` keys with a
#'   logical `regulated`; `dams`, the dams placed (`cabd_id`, `dam_name_en`,
#'   `degree_of_regulation_pc`, `reservoir_present`, position, `snap_m`).
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' f <- knw_link_flow(conn, 701747495)
#' knw_link_regulated(conn, data.frame(blue_line_key = 360886335, downstream_route_measure = 100,
#'                                     wscode = f$wscode, localcode = f$localcode))
#' }
knw_link_regulated <- function(conn, pts, dam_snap_m = 500, regulation_min = 10) {
  chk::chk_data(pts)
  chk::check_names(pts, c("blue_line_key", "downstream_route_measure", "wscode", "localcode"))
  chk::chk_number(dam_snap_m)
  chk::chk_number(regulation_min)
  pts <- unique(pts[, c("blue_line_key", "downstream_route_measure", "wscode", "localcode")])
  pts <- pts[!is.na(pts$wscode) & !is.na(pts$localcode), , drop = FALSE]
  dams <- DBI::dbGetQuery(conn, sprintf("
    SELECT d.cabd_id, d.dam_name_en, d.degree_of_regulation_pc, d.reservoir_present,
           s.blue_line_key, s.wscode_ltree::text AS wscode, s.localcode_ltree::text AS localcode,
           s.downstream_route_measure + ST_LineLocatePoint(ST_Force2D(s.geom), ST_Force2D(p.pt))
             * (s.upstream_route_measure - s.downstream_route_measure) AS measure,
           ST_Distance(s.geom, p.pt) AS snap_m
    FROM cabd.dams d
    CROSS JOIN LATERAL (SELECT ST_Transform(d.geom, 3005) AS pt) p
    CROSS JOIN LATERAL (
      SELECT * FROM whse_basemapping.fwa_stream_networks_sp s
      WHERE s.blue_line_key = s.watershed_key AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
      ORDER BY s.geom <-> p.pt, s.linear_feature_id LIMIT 1) s
    WHERE (d.reservoir_present OR d.degree_of_regulation_pc >= %s)
      AND ST_Distance(s.geom, p.pt) <= %s", regulation_min, dam_snap_m))
  tmp_d <- "tmp_knw_reg_dams"
  tmp_p <- "tmp_knw_reg_pts"
  DBI::dbWriteTable(conn, tmp_d, dams, temporary = TRUE, overwrite = TRUE)
  DBI::dbWriteTable(conn, tmp_p, pts, temporary = TRUE, overwrite = TRUE)
  on.exit(try({
    DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp_d))
    DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp_p))
  }, silent = TRUE), add = TRUE)
  # a dam is upstream of the point when the point is downstream of the dam: swap the roles
  reg <- DBI::dbGetQuery(conn, sprintf("
    SELECT t.blue_line_key, t.downstream_route_measure,
           EXISTS (SELECT 1 FROM %s d
                   WHERE t.wscode::ltree @> d.wscode::ltree
                     AND fwa_downstream(d.blue_line_key::integer, d.measure, d.wscode::ltree, d.localcode::ltree,
                                        t.blue_line_key::integer, t.downstream_route_measure,
                                        t.wscode::ltree, t.localcode::ltree)) AS regulated
    FROM %s t", tmp_d, tmp_p))
  reg$blue_line_key <- as.numeric(reg$blue_line_key)
  list(regulated = tibble::as_tibble(reg), dams = tibble::as_tibble(dams))
}
