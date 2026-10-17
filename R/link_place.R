#' Place site visits on link's segments, with access and habitat for every species
#'
#' `scripts/0290`'s placement, on one schema for every species at once. A visit
#' takes the segment of its blue line whose downstream end lies within
#' `[measure - 1, measure + start_window_m]`, the lowest such start if there are
#' several (link breaks streams at observations, and an FDIS site's point sits
#' at or a few metres below the record's). Only when no segment starts in that
#' window does it take the segment containing its point; adjacent segments
#' overlap by up to a few millimetres at breaks, so there the segment with the
#' greatest downstream measure wins and `id_segment` breaks any tie. An overlap
#' longer than `overlap_max_m` anywhere a visit's point falls stops the run.
#'
#' Each placed visit carries the segment's attributes, its `access_<sp>` from
#' `streams_access` for every species the schema models, and for every species
#' with a habitat table its `accessible`, `spawning`, `rearing`, `lake_rearing`
#' and `wetland_rearing`, re-gated on `access_<sp> > 0` (link#349: the two
#' columns disagree, and `streams_access` is the gate). The stored habitat flag
#' is kept beside the re-gated one as `<sp>_<flag>_stored`.
#'
#' @param conn a `DBI` connection to a database holding `schema`.
#' @param visits `data.frame` with `site_visit`, `watershed_group_code`,
#'   `blue_line_key` and `downstream_route_measure`.
#' @param schema `character(1)` link persist schema, e.g. `"fresh_default"`.
#' @param start_window_m `numeric(1)` metres above the visit within which a
#'   segment start is taken as the visit's segment.
#' @param overlap_max_m `numeric(1)` the largest segment overlap tolerated.
#' @return A list: `placed`, one row per placed visit (`site_visit`,
#'   `id_segment`, `segment_start_offset_m`, the segment attributes, elevation,
#'   `access_<sp>` columns, `<sp>_<flag>` and `<sp>_<flag>_stored` columns);
#'   `species_access`, the species with an `access_<sp>` column;
#'   `species_habitat`, the species with a habitat table; `overlap`, a one-row
#'   `data.frame` with the number of visits whose point lies in two segments and
#'   the largest overlap found.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' v <- data.frame(site_visit = "x", watershed_group_code = "BULK",
#'                 blue_line_key = 360886335, downstream_route_measure = 1520.4)
#' knw_link_place(conn, v, "fresh_default")$placed
#' }
knw_link_place <- function(conn, visits, schema, start_window_m = 5, overlap_max_m = 0.01) {
  chk::chk_data(visits)
  chk::check_names(visits, c("site_visit", "watershed_group_code", "blue_line_key", "downstream_route_measure"))
  chk::chk_string(schema)
  chk::chk_number(start_window_m)
  chk::chk_number(overlap_max_m)
  if (anyDuplicated(visits$site_visit)) stop("a site_visit appears twice in visits", call. = FALSE)

  cols <- DBI::dbGetQuery(conn, "
    SELECT table_name, column_name FROM information_schema.columns
    WHERE (table_schema = $1 AND table_name = 'streams_access')
       OR (table_schema = $1 AND table_name LIKE 'streams_habitat_%' AND table_name <> 'streams_habitat_long_vw')",
    params = list(schema))
  sp_access <- toupper(sub("^access_", "", grep("^access_", cols$column_name[cols$table_name == "streams_access"],
                                                 value = TRUE)))
  sp_hab <- toupper(sub("^streams_habitat_", "", unique(grep("^streams_habitat_", cols$table_name, value = TRUE))))
  if (!length(sp_access)) stop(schema, ".streams_access has no access_<sp> column", call. = FALSE)

  tmp <- "tmp_knw_link_place"
  DBI::dbWriteTable(conn, tmp, visits[, c("site_visit", "watershed_group_code", "blue_line_key",
                                           "downstream_route_measure")],
                    temporary = TRUE, overwrite = TRUE)
  on.exit(try(DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp)), silent = TRUE), add = TRUE)
  q <- .knw_place_sql(schema, tmp, sp_access, sp_hab, start_window_m)
  overlap <- DBI::dbGetQuery(conn, q$overlap)
  overlap$n <- as.integer(overlap$n)
  overlap$max_overlap <- as.numeric(overlap$max_overlap)
  if (overlap$max_overlap > overlap_max_m) {
    stop(schema, ": segments overlap by ", overlap$max_overlap, " m at a visit's point", call. = FALSE)
  }
  placed <- tibble::as_tibble(DBI::dbGetQuery(conn, q$place))
  if (anyDuplicated(placed$site_visit)) stop("a visit was placed twice", call. = FALSE)
  for (sp in sp_hab) {
    g <- if (tolower(sp) %in% tolower(sp_access)) placed[[paste0("access_", tolower(sp))]] > 0 else NA
    for (f in c("accessible", "spawning", "rearing", "lake_rearing", "wetland_rearing")) {
      col <- paste0(tolower(sp), "_", f)
      if (!col %in% names(placed)) next
      placed[[paste0(col, "_stored")]] <- placed[[col]]
      placed[[col]] <- placed[[col]] & !is.na(g) & g
    }
  }
  list(placed = placed, species_access = sp_access, species_habitat = sp_hab, overlap = overlap)
}

# The two statements knw_link_place() runs: the overlap check and the placement.
# Split out so the text can be read in a test without a database.
.knw_place_sql <- function(schema, tmp, sp_access, sp_hab, start_window_m) {
  acc <- paste0("a.access_", tolower(sp_access), collapse = ", ")
  hab_sel <- paste(unlist(lapply(tolower(sp_hab), function(s) {
    sprintf("h_%1$s.accessible AS %1$s_accessible, h_%1$s.spawning AS %1$s_spawning, h_%1$s.rearing AS %1$s_rearing,
         h_%1$s.lake_rearing AS %1$s_lake_rearing, h_%1$s.wetland_rearing AS %1$s_wetland_rearing", s)
  })), collapse = ",\n         ")
  hab_join <- paste(unlist(lapply(tolower(sp_hab), function(s) {
    sprintf("LEFT JOIN %1$s.streams_habitat_%2$s h_%2$s
    ON h_%2$s.id_segment = s.id_segment AND h_%2$s.watershed_group_code = s.watershed_group_code", schema, s)
  })), collapse = "\n  ")
  win <- sprintf(paste("(s.downstream_route_measure BETWEEN t.downstream_route_measure - 1",
                       "AND t.downstream_route_measure + %s)"), start_window_m)
  place <- sprintf("
  SELECT DISTINCT ON (t.site_visit) t.site_visit,
         s.id_segment, s.downstream_route_measure - t.downstream_route_measure AS segment_start_offset_m,
         s.linear_feature_id AS segment_linear_feature_id, s.edge_type AS segment_edge_type,
         s.stream_order AS segment_stream_order, s.waterbody_key AS segment_waterbody_key,
         s.gradient AS segment_gradient, s.channel_width AS segment_channel_width,
         s.channel_width_source AS segment_cw_source, s.length_metre AS segment_length_m,
         s.downstream_route_measure AS segment_downstream_m, s.upstream_route_measure AS segment_upstream_m,
         (ST_ZMin(s.geom) + ST_ZMax(s.geom)) / 2 AS elevation_m,
         %4$s,
         %5$s
  FROM %1$s t
  JOIN %2$s.streams s
    ON s.watershed_group_code = t.watershed_group_code
   AND s.blue_line_key = t.blue_line_key
   AND (%3$s
        OR (t.downstream_route_measure >= s.downstream_route_measure
            AND t.downstream_route_measure < s.upstream_route_measure))
  LEFT JOIN %2$s.streams_access a
    ON a.id_segment = s.id_segment AND a.watershed_group_code = s.watershed_group_code
  %6$s
  ORDER BY t.site_visit,
           %3$s DESC,
           CASE WHEN %3$s THEN s.downstream_route_measure END ASC,
           s.downstream_route_measure DESC, s.id_segment", tmp, schema, win, acc, hab_sel, hab_join)
  overlap <- sprintf("
  SELECT count(*) AS n, coalesce(max(o), 0) AS max_overlap FROM (
    SELECT t.site_visit,
           sum(s.upstream_route_measure - s.downstream_route_measure)
             - (max(s.upstream_route_measure) - min(s.downstream_route_measure)) AS o
    FROM %1$s t
    JOIN %2$s.streams s
      ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
     AND t.downstream_route_measure >= s.downstream_route_measure
     AND t.downstream_route_measure < s.upstream_route_measure
    GROUP BY t.site_visit HAVING count(*) > 1) x", tmp, schema)
  list(place = place, overlap = overlap)
}
