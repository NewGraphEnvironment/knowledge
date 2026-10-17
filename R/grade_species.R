#' Grade every segment of a species' groups by its tuned curve
#'
#' Reads the species' segments ([knw_link_segments()]), walks the ones the pick's
#' exception could admit (accessible stream-branch segments inside the gradient
#' maximum that fail the size test) to the first river of the pick's `exc_q`
#' from the segment's downstream end, and grades them all ([knw_grade()]).
#' Segments the exception cannot reach take the distance cap: a segment passing
#' the size test is graded on its size, and one off the stream branch or above
#' the gradient maximum is far from any river by construction, which the curve
#' reads as the exception not helping it. With no exception on the pick, no walk
#' is made.
#'
#' @param connector a function returning a `DBI` connection (each walk worker
#'   opens its own).
#' @param schema `character(1)` link persist schema.
#' @param species `character(1)` species code.
#' @param wsg `character` the species' groups.
#' @param curve [knw_tune_curve()]'s result for the species and stage.
#' @param pick the recommended rule row.
#' @param stage `"rear"` or `"spawn"`.
#' @param edge_stream `integer` stream-branch edge types.
#' @param workers `integer(1)` walk workers.
#' @param src `character(1)` the flow source.
#' @return A list: `grades`, one row per segment with the segment's keys,
#'   `length_metre`, `access`, `accessible`, the stage's flag, `size`, `dist_m`,
#'   `rate`, `grade`, `grade_class`; `reference`; `counts` (segments, walked,
#'   found, graded, no size, no gradient); `walk_minutes`.
#' @export
#' @examples
#' \dontrun{
#' pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' g <- knw_grade_species(pg, "fresh_default", "CH", c("BULK", "MORR"), out$CH_rear$curve, out$CH_rear$pick)
#' }
knw_grade_species <- function(connector, schema, species, wsg, curve, pick, stage = "rear",
                              edge_stream = c(1000L, 1100L, 2000L, 2300L), workers = 4L, src = "pick") {
  chk::chk_function(connector)
  chk::chk_string(species)
  chk::chk_character(wsg)
  conn <- connector()
  seg <- knw_link_segments(conn, schema, species, wsg)
  DBI::dbDisconnect(conn)
  size_col <- if (pick$size_var == "width") "channel_width" else "mad_pick"
  seg$size <- seg[[size_col]]
  seg$dist_m <- NA_real_
  walked <- 0L
  found <- 0L
  t0 <- Sys.time()
  if (!is.na(pick$exc_q)) {
    size_ok <- !is.na(seg$size) & seg$size >= pick$size_min & (pick$size_var != "width" | seg$size <= 9999)
    cand <- seg$accessible & seg$edge_type %in% edge_stream & !is.na(seg$gradient) & seg$gradient >= 0 &
      seg$gradient <= pick$grad_max & !size_ok
    starts <- unique(seg[cand, c("blue_line_key", "downstream_route_measure")])
    walked <- nrow(starts)
    if (walked) {
      w <- knw_link_walks(connector, starts, q_grid = pick$exc_q, sources = src, workers = workers)
      w <- w[w$status == "found", , drop = FALSE]
      found <- nrow(w)
      i <- match(paste(seg$blue_line_key, seg$downstream_route_measure), paste(w$blue_line_key, w$downstream_route_measure))
      seg$dist_m <- ifelse(cand & !is.na(i), w$dist_m[i], NA_real_)
    }
  }
  g <- knw_grade(curve, seg, cols = c(size = "size", grad = "gradient", dist = "dist_m"))
  flag <- if (stage == "rear") "rearing" else "spawning"
  grades <- seg[, c("id_segment", "watershed_group_code", "linear_feature_id", "blue_line_key", "downstream_route_measure",
                    "upstream_route_measure", "length_metre", "edge_type", "stream_order", "access", "accessible", flag,
                    "size", "dist_m")]
  grades$rate <- g$grades$rate
  grades$grade <- ifelse(grades$accessible, g$grades$grade, NA_real_)
  grades$grade_class <- ifelse(grades$accessible, g$grades$grade_class, NA_character_)
  list(grades = grades, reference = g$reference,
       counts = c(segments = nrow(seg), accessible = sum(seg$accessible), walked = walked, found = found,
                  graded = sum(!is.na(grades$grade)), g$dropped),
       walk_minutes = as.numeric(difftime(Sys.time(), t0, units = "mins")))
}
