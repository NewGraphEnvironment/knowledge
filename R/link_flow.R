#' wet's annual flow on FWA segments, with a parent fallback
#'
#' `scripts/0294`'s flow read, for any set of FWA segments. The flow is month 0
#' (the annual mean) of `discharge.fwa_v1_segment_monthly`, scenario
#' `historical`, as `wet::wet_db_load()` loaded it: `pick` marks wet's default
#' source per segment, and both sources' values come back beside it. A segment
#' with no picked flow, or with no watershed code (side channels and connectors
#' with no watershed lut row), is not dropped: it takes the picked flow of the
#' nearest primary-flow segment on its main line (`watershed_key`) or its own
#' line, and `flow_from` says which (`own`, `parent`, or `NA` for neither); such
#' a segment takes that segment's watershed codes too (`code_from_parent`).
#'
#' @param conn a `DBI` connection to a database holding `discharge` and
#'   `whse_basemapping`.
#' @param linear_feature_id `numeric` FWA segment ids.
#' @return A `tibble`, one row per segment: `linear_feature_id`,
#'   `side_channel`, `fwa_gradient`, `wscode`, `localcode`, `code_from_parent`,
#'   `waterbody_key`, `mad_pick`, `pick_source`, `mad_routed`, `mad_balance`,
#'   `flow_from`, `parent_dist_m`.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_link_flow(conn, c(701747495, 701747496))
#' }
knw_link_flow <- function(conn, linear_feature_id) {
  chk::chk_numeric(linear_feature_id)
  chk::chk_not_any_na(linear_feature_id)
  tmp <- "tmp_knw_link_flow"
  DBI::dbWriteTable(conn, tmp, data.frame(linear_feature_id = unique(linear_feature_id)),
                    temporary = TRUE, overwrite = TRUE)
  on.exit(try(DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp)), silent = TRUE), add = TRUE)
  seg <- DBI::dbGetQuery(conn, sprintf("
    SELECT t.linear_feature_id,
           s.blue_line_key <> s.watershed_key AS side_channel,
           s.gradient AS fwa_gradient,
           coalesce(s.wscode_ltree, par.wscode)::text AS wscode,
           coalesce(s.localcode_ltree, par.localcode)::text AS localcode,
           (s.wscode_ltree IS NULL OR s.localcode_ltree IS NULL) AS code_from_parent, s.waterbody_key,
           own.mad_pick AS own_mad, own.pick_source AS own_source, own.mad_routed, own.mad_balance,
           par.q_m3s AS parent_mad, par.source AS parent_source, par.d AS parent_dist_m
    FROM %s t
    JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
    LEFT JOIN LATERAL (
      SELECT max(q.q_m3s) FILTER (WHERE q.pick) AS mad_pick,
             max(q.source) FILTER (WHERE q.pick) AS pick_source,
             max(q.q_m3s) FILTER (WHERE q.source = 'pcic_routed') AS mad_routed,
             max(q.q_m3s) FILTER (WHERE q.source = 'wet_balance') AS mad_balance
      FROM discharge.fwa_v1_segment_monthly q
      WHERE q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0
    ) own ON true
    LEFT JOIN LATERAL (
      SELECT q.q_m3s, q.source, ST_Distance(p.geom, s.geom) AS d,
             p.wscode_ltree AS wscode, p.localcode_ltree AS localcode
      FROM whse_basemapping.fwa_stream_networks_sp p
      JOIN discharge.fwa_v1_segment_monthly q
        ON q.linear_feature_id = p.linear_feature_id AND q.scenario = 'historical'
       AND q.month = 0 AND q.pick
      WHERE (own.mad_pick IS NULL OR s.wscode_ltree IS NULL OR s.localcode_ltree IS NULL)
        AND p.blue_line_key IN (s.watershed_key, s.blue_line_key)
        AND p.wscode_ltree IS NOT NULL AND p.localcode_ltree IS NOT NULL
        AND p.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
      ORDER BY p.geom <-> s.geom
      LIMIT 1
    ) par ON true", tmp))
  if (anyDuplicated(seg$linear_feature_id)) stop("a segment matched twice", call. = FALSE)
  own <- !is.na(seg$own_mad)
  out <- tibble::tibble(
    linear_feature_id = as.numeric(seg$linear_feature_id), side_channel = seg$side_channel,
    fwa_gradient = as.numeric(seg$fwa_gradient), wscode = seg$wscode, localcode = seg$localcode,
    code_from_parent = seg$code_from_parent, waterbody_key = as.numeric(seg$waterbody_key),
    mad_pick = as.numeric(ifelse(own, seg$own_mad, seg$parent_mad)),
    pick_source = ifelse(own, seg$own_source, seg$parent_source),
    mad_routed = as.numeric(seg$mad_routed), mad_balance = as.numeric(seg$mad_balance),
    flow_from = ifelse(own, "own", ifelse(!is.na(seg$parent_mad), "parent", NA_character_)),
    parent_dist_m = as.numeric(ifelse(own, NA, seg$parent_dist_m))
  )
  out[order(out$linear_feature_id), , drop = FALSE]
}
