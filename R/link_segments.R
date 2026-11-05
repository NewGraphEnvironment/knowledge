#' link's segments for one species in a set of groups, with flow and access, for grading
#'
#' The segment table a grade is written on: every `streams` row of the groups,
#' with `streams_access.access_<sp>`, the species' habitat flags (re-gated on
#' access, stored flags beside), and wet's picked annual flow. Own flow is one
#' join; the parent fallback [knw_link_flow()] applies per visit (the nearest
#' primary-flow segment on the main line or the segment's own line) runs only on
#' the segments with no own flow, so millions of segments read in one pass.
#'
#' @param conn a `DBI` connection to a database holding `schema` and `discharge`.
#' @param schema `character(1)` link persist schema.
#' @param species `character(1)` species code.
#' @param wsg `character` watershed group codes.
#' @param parent_fallback `logical(1)` run the parent fallback for segments with
#'   no own picked flow.
#' @param gradient `character(1)` where `gradient` comes from (#120):
#'   `"segment"`, the segment's own (link's `gradient`, token `grad-seg`);
#'   `"parent"`, its minimal-network parent's, from `<schema>.streams_parent`
#'   (link#444, `grad-parent`), checked by [knw_parent_read()] first; `"fwa"`,
#'   its Freshwater Atlas segment's (`fwa_stream_networks_sp.gradient` on
#'   `linear_feature_id`; no link segment crosses an Atlas segment, link#444).
#'   A segment with no row in the source stops the read.
#' @return A `tibble`, one row per segment: `id_segment`, `watershed_group_code`,
#'   `linear_feature_id`, `blue_line_key`, `downstream_route_measure`,
#'   `upstream_route_measure`, `length_metre`, `edge_type`, `stream_order`,
#'   `waterbody_key`, `gradient`, `channel_width`, `channel_width_source`,
#'   `wscode`, `localcode`, `access`, `accessible`, `spawning`, `rearing`,
#'   `lake_rearing`, `wetland_rearing` (re-gated), `*_stored`, `mad_pick`,
#'   `pick_source`, `flow_from`.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' seg <- knw_link_segments(conn, "fresh_default", "CH", c("BULK", "MORR"))
#' }
knw_link_segments <- function(conn, schema, species, wsg, parent_fallback = TRUE, gradient = "segment") {
  chk::chk_string(schema)
  chk::chk_string(species)
  chk::chk_character(wsg)
  chk::chk_not_any_na(wsg)
  s <- tolower(species)
  wsg_in <- paste0("'", unique(wsg), "'", collapse = ",")
  gs <- .knw_seg_grad(gradient, schema)
  .knw_seg_grad_check(conn, gradient, schema, wsg)
  seg <- DBI::dbGetQuery(conn, sprintf("
    SELECT s.id_segment, s.watershed_group_code, s.linear_feature_id, s.blue_line_key, s.downstream_route_measure,
           s.upstream_route_measure, s.length_metre, s.edge_type, s.stream_order, s.waterbody_key,
           %4$s AS gradient, s.channel_width, s.channel_width_source, s.wscode_ltree::text AS wscode,
           s.localcode_ltree::text AS localcode,
           a.access_%1$s AS access,
           h.accessible AS accessible_stored, h.spawning AS spawning_stored, h.rearing AS rearing_stored,
           h.lake_rearing AS lake_rearing_stored, h.wetland_rearing AS wetland_rearing_stored,
           q.q_m3s AS own_mad, q.source AS own_source
    FROM %2$s.streams s
    LEFT JOIN %2$s.streams_access a ON a.id_segment = s.id_segment AND a.watershed_group_code = s.watershed_group_code
    LEFT JOIN %2$s.streams_habitat_%1$s h
      ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
    LEFT JOIN discharge.fwa_v1_segment_monthly q
      ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick
    %5$s
    WHERE s.watershed_group_code IN (%3$s)", s, schema, wsg_in, gs$col, gs$join))
  seg <- tibble::as_tibble(seg)
  num_cols <- c("id_segment", "linear_feature_id", "blue_line_key", "downstream_route_measure",
                "upstream_route_measure", "length_metre", "gradient", "channel_width", "own_mad", "waterbody_key")
  for (col in num_cols) {
    seg[[col]] <- as.numeric(seg[[col]])
  }
  seg$edge_type <- as.integer(seg$edge_type)
  seg$stream_order <- as.integer(seg$stream_order)
  seg$access <- as.integer(seg$access)
  g <- !is.na(seg$access) & seg$access > 0
  for (f in c("accessible", "spawning", "rearing", "lake_rearing", "wetland_rearing")) {
    seg[[f]] <- seg[[paste0(f, "_stored")]] %in% TRUE & g
  }
  seg$mad_pick <- seg$own_mad
  seg$pick_source <- seg$own_source
  seg$flow_from <- ifelse(is.na(seg$own_mad), NA_character_, "own")
  seg$own_mad <- NULL
  seg$own_source <- NULL
  if (parent_fallback) {
    miss <- unique(seg$linear_feature_id[is.na(seg$mad_pick)])
    if (length(miss)) {
      fl <- knw_link_flow(conn, miss)
      i <- match(seg$linear_feature_id, fl$linear_feature_id)
      take <- is.na(seg$mad_pick) & !is.na(i)
      seg$mad_pick[take] <- fl$mad_pick[i[take]]
      seg$pick_source[take] <- fl$pick_source[i[take]]
      seg$flow_from[take] <- fl$flow_from[i[take]]
      seg$wscode[take & is.na(seg$wscode)] <- fl$wscode[i[take & is.na(seg$wscode)]]
      seg$localcode[take & is.na(seg$localcode)] <- fl$localcode[i[take & is.na(seg$localcode)]]
    }
  }
  seg[order(seg$watershed_group_code, seg$blue_line_key, seg$downstream_route_measure), , drop = FALSE]
}

# where a segment's gradient comes from (#120): its own, link's `gradient` (`grad-seg`); its minimal-network parent's,
# link#444's streams_parent (`grad-parent`); or its Freshwater Atlas segment's, on the segment's linear_feature_id.
# `col` is the expression, `join` what it needs, both written against the alias `s` for <schema>.streams
.knw_seg_grad <- function(gradient, schema) {
  chk::chk_string(gradient)
  switch(gradient,
    segment = list(col = "s.gradient", join = ""),
    parent = list(col = "kp.gradient_minimal",
                  join = sprintf(paste("LEFT JOIN %s.streams_parent kp ON kp.id_segment = s.id_segment",
                                       "AND kp.watershed_group_code = s.watershed_group_code"), schema)),
    fwa = list(col = "kf.gradient",
               join = paste("LEFT JOIN whse_basemapping.fwa_stream_networks_sp kf",
                            "ON kf.linear_feature_id = s.linear_feature_id")),
    stop("gradient must be segment, parent or fwa, not ", gradient, call. = FALSE)
  )
}

# the source covers every segment of the groups, or a read on it is refused: a segment whose source gradient is missing
# (no row, or a NULL where its own gradient is not) would drop out of grading silently. The parent table is also held
# to knw_parent_read()'s checks (its builds, its run ids, one row per segment of the length it records)
.knw_seg_grad_check <- function(conn, gradient, schema, wsg) {
  if (identical(gradient, "segment")) return(invisible(TRUE))
  if (identical(gradient, "parent")) {
    knw_parent_read(conn, schema, keys = data.frame(watershed_group_code = character(), id_segment = integer()))
  }
  gs <- .knw_seg_grad(gradient, schema)
  n <- DBI::dbGetQuery(conn, sprintf("SELECT count(*)::int AS n FROM %s.streams s %s
                                      WHERE s.watershed_group_code = ANY($1::text[]) AND %s IS NULL
                                        AND s.gradient IS NOT NULL", schema, gs$join, gs$col),
                       params = list(paste0("{", paste(unique(wsg), collapse = ","), "}")))$n
  if (n > 0L) {
    stop(n, " segments of ", schema, " have a gradient of their own and none from the ", gradient, " source",
         call. = FALSE)
  }
  invisible(TRUE)
}
