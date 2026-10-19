#' Grade every segment of a species' groups by its tuned curve
#'
#' Reads the species' segments ([knw_link_segments()]), walks every accessible
#' segment with a gradient (on any edge type and at any gradient: wetland lines,
#' river polygons and steep segments included, and whatever its size) from its
#' downstream end to the first river of the pick's `exc_q`, or of the curve's
#' `q` when the pick has no exception, and grades them all ([knw_grade()]). The
#' curve reads size and distance jointly, so every graded segment needs its own
#' distance, whether or not it passes the size test. For the pick the curve was
#' fitted on, the two rivers are the same.
#'
#' `dist_m` also serves [knw_compare_rules()] as the exception's distance. That
#' is why a segment with no size is walked although it is not graded (the
#' exception admits a segment whose size fails, missing included), and why a
#' pick's own `exc_q` wins: a candidate whose river differs from the curve's
#' gets a correct exception and a grade that is not comparable.
#'
#' The curve was fitted on stream-branch visits outside lakes, wetlands and
#' river polygons, so a river-polygon or wetland segment reads it near 0 m and
#' at sizes few visits had: its grade is an extrapolation.
#'
#' A walk that finds no river of `q` (`none`: the sea first; `no_parent`;
#' `too_many_hops`) leaves `dist_m` missing, which the grade reads as the
#' distance cap, as [knw_tune_curve()] censors such visits. `dist_status` says
#' which, and is `no_walk` for a segment outside the walk set (not accessible,
#' or with no gradient).
#'
#' @param connector a function returning a `DBI` connection (each walk worker
#'   opens its own).
#' @param schema `character(1)` link persist schema.
#' @param species `character(1)` species code.
#' @param wsg `character` the species' groups.
#' @param curve [knw_tune_curve()]'s result for the species and stage.
#' @param pick the recommended rule row.
#' @param stage `"rear"` or `"spawn"`.
#' @param workers `integer(1)` walk workers.
#' @param src `character(1)` the flow source.
#' @return A list: `grades`, one row per segment with the segment's keys,
#'   `length_metre`, `access`, `accessible`, the stage's flag, `size`, `dist_m`,
#'   `dist_status`, `rate`, `grade`, `grade_class`; `reference`; `counts`
#'   (segments, accessible, walked starts, segments whose walk was found, none
#'   or other, graded, no size, no gradient); `walk_minutes`.
#' @export
#' @examples
#' \dontrun{
#' pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' g <- knw_grade_species(pg, "fresh_default", "CH", c("BULK", "MORR"), out$CH_rear$curve, out$CH_rear$pick)
#' }
knw_grade_species <- function(connector, schema, species, wsg, curve, pick, stage = "rear",
                              workers = 4L, src = "pick") {
  chk::chk_function(connector)
  chk::chk_string(species)
  chk::chk_character(wsg)
  conn <- connector()
  seg <- knw_link_segments(conn, schema, species, wsg)
  DBI::dbDisconnect(conn)
  size_col <- if (pick$size_var == "width") "channel_width" else "mad_pick"
  seg$size <- seg[[size_col]]
  seg$dist_m <- NA_real_
  seg$dist_status <- "no_walk"
  t0 <- Sys.time()
  # every accessible segment with a gradient: the graded ones (size above 0 too) and the ones only the
  # exception can admit (a missing or zero size fails the size test, so their distance decides them)
  cand <- seg$accessible %in% TRUE & !is.na(seg$gradient)
  starts <- unique(seg[cand, c("blue_line_key", "downstream_route_measure")])
  walked <- nrow(starts)
  q_walk <- if (is.na(pick$exc_q)) curve$q else pick$exc_q
  if (walked) {
    w <- knw_link_walks(connector, starts, q_grid = q_walk, sources = src, workers = workers)
    i <- match(paste(seg$blue_line_key, seg$downstream_route_measure),
               paste(w$blue_line_key, w$downstream_route_measure))
    hit <- cand & !is.na(i)
    seg$dist_status[hit] <- w$status[i[hit]]
    seg$dist_m[hit] <- ifelse(w$status[i[hit]] == "found", w$dist_m[i[hit]], NA_real_)
  }
  g <- knw_grade(curve, seg, cols = c(size = "size", grad = "gradient", dist = "dist_m"))
  flag <- if (stage == "rear") "rearing" else "spawning"
  grades <- seg[, c("id_segment", "watershed_group_code", "linear_feature_id", "blue_line_key",
                    "downstream_route_measure", "upstream_route_measure", "length_metre", "edge_type", "stream_order",
                    "access", "accessible", flag, "size", "dist_m", "dist_status")]
  grades$rate <- g$grades$rate
  grades$grade <- ifelse(grades$accessible, g$grades$grade, NA_real_)
  grades$grade_class <- ifelse(grades$accessible, g$grades$grade_class, NA_character_)
  list(grades = grades, reference = g$reference,
       counts = c(segments = nrow(seg), accessible = sum(seg$accessible %in% TRUE), walked = walked,
                  walk_found = sum(seg$dist_status == "found"), walk_none = sum(seg$dist_status == "none"),
                  walk_other = sum(seg$dist_status %in% c("no_parent", "too_many_hops")),
                  graded = sum(!is.na(grades$grade)), g$dropped),
       walk_minutes = as.numeric(difftime(Sys.time(), t0, units = "mins")))
}
