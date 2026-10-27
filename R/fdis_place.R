#' Pick each FDIS site visit's stream from the nearest snap and the streams its 1:50k code names
#'
#' `scripts/0230` snaps every visit twice with `fresh::frs_point_snap()`: once
#' to the nearest stream, and once to each stream its FDIS 1:50k watershed code
#' names (the code's 20k `blue_line_key`s from `fwa_streams_20k_50k`, passed as
#' a hint, so that snap can land only on that stream). This function makes the
#' pick from the two results, with no database.
#'
#' A visit whose code names a stream within the search takes the nearest such
#' stream (`snap_method = "code"`, `snap_confirmed = TRUE`): the placement is
#' on a stream the code names, which is what `0230`'s check has always asked.
#' Where that stream is not the nearest one, the visit is moved to it
#' (`snap_moved`). A visit with no code the cross-reference knows takes the
#' nearest stream (`snap_method = "nearest"`, unconfirmed). A visit whose code
#' names streams none of which lies within the search keeps the nearest
#' placement and is flagged `flag_ws50_mismatch`: the code contradicts every
#' stream in reach, so there is nothing to move it to.
#'
#' A confirmed pick and an unconfirmed one are held to different limits,
#' because distance predicts a wrong stream only where nothing names the
#' stream: `flag_far_snap` marks an unconfirmed pick beyond `limit_near` and a
#' confirmed one beyond `limit_code`. Ties in distance go to the lowest
#' `linear_feature_id`, as in `frs_point_snap()`.
#'
#' The default limits are the ones `0230` uses, set by
#' `data-raw/snap_limit_sensitivity.R` (#91): 200 m, the widest distance band
#' whose code-checked disagreement stays under one in three, for an unconfirmed
#' pick, and the 500 m search radius for a confirmed one.
#'
#' @param nearest `data.frame`, one row per visit to place: `site_visit`,
#'   `blue_line_key`, `downstream_route_measure`, `linear_feature_id`,
#'   `distance_to_stream`, with the four position columns missing where no
#'   stream lies within the search.
#' @param hinted `data.frame`, one row per visit and stream its code names:
#'   `site_visit`, `hint_blue_line_key` (the stream named) and the four position
#'   columns of the hinted snap, missing where that stream is not within the
#'   search. A visit with no row here has no code the cross-reference knows.
#'   Every `site_visit` must be in `nearest`.
#' @param limit_near `numeric(1)` metres: an unconfirmed pick farther than this
#'   is flagged `flag_far_snap`.
#' @param limit_code `numeric(1)` metres: a confirmed pick farther than this is
#'   flagged `flag_far_snap`.
#' @return A `tibble`, one row per row of `nearest` in its order: `site_visit`,
#'   `blue_line_key`, `downstream_route_measure`, `linear_feature_id`,
#'   `distance_to_stream` (the pick's), `snap_method` (`code`, `nearest`, or
#'   `NA` when not placed), `snap_confirmed`, `snap_moved`,
#'   `nearest_distance_m`, `ws50_checked` (the visit has a code the
#'   cross-reference knows), `flag_not_placed`, `flag_far_snap` and
#'   `flag_ws50_mismatch`. `integer64` columns are refused: convert them with
#'   `as.numeric()` first, as `0230` does.
#' @export
#' @examples
#' nearest <- data.frame(
#'   site_visit = c("a", "b", "c"),
#'   blue_line_key = c(1, 1, 2), downstream_route_measure = c(10, 50, 5),
#'   linear_feature_id = c(11, 12, 21), distance_to_stream = c(4, 30, 150)
#' )
#' # b's code names stream 3, 60 m away; c's code names stream 2, its nearest
#' hinted <- data.frame(
#'   site_visit = c("b", "c"), hint_blue_line_key = c(3, 2),
#'   blue_line_key = c(3, 2), downstream_route_measure = c(80, 5),
#'   linear_feature_id = c(31, 21), distance_to_stream = c(60, 150)
#' )
#' knw_fdis_place(nearest, hinted, limit_near = 100, limit_code = 500)
knw_fdis_place <- function(nearest, hinted, limit_near = 200, limit_code = 500) {
  pos <- c("blue_line_key", "downstream_route_measure", "linear_feature_id", "distance_to_stream")
  chk::chk_data(nearest)
  chk::chk_data(hinted)
  chk::check_names(nearest, c("site_visit", pos))
  chk::check_names(hinted, c("site_visit", "hint_blue_line_key", pos))
  chk::chk_number(limit_near)
  chk::chk_number(limit_code)
  chk::chk_gte(limit_near, 0)
  chk::chk_gte(limit_code, 0)
  big <- vapply(c(nearest[pos], hinted[c("hint_blue_line_key", pos)]), inherits, logical(1), "integer64")
  if (any(big)) {
    stop("convert integer64 columns with as.numeric() first (FWA ids are below 2^53): ",
         paste(unique(names(big)[big]), collapse = ", "), call. = FALSE)
  }
  if (anyNA(nearest$site_visit) || anyDuplicated(nearest$site_visit)) {
    stop("nearest needs one row per site_visit, none missing", call. = FALSE)
  }
  if (!all(hinted$site_visit %in% nearest$site_visit)) {
    stop("a site_visit in hinted is not in nearest", call. = FALSE)
  }
  hit <- hinted[!is.na(hinted$blue_line_key), , drop = FALSE]
  if (any(hit$blue_line_key != hit$hint_blue_line_key)) {
    stop("a hinted snap landed on another stream than its hint", call. = FALSE)
  }

  # the nearest hit per visit; ties to the lowest linear_feature_id
  hit <- hit[order(hit$site_visit, hit$distance_to_stream, hit$linear_feature_id), , drop = FALSE]
  hit <- hit[!duplicated(hit$site_visit), , drop = FALSE]
  i <- match(nearest$site_visit, hit$site_visit)
  confirmed <- !is.na(i)

  out <- tibble::tibble(site_visit = nearest$site_visit)
  for (p in pos) out[[p]] <- ifelse(confirmed, hit[[p]][i], nearest[[p]])
  placed <- !is.na(out$blue_line_key)
  out$snap_method <- ifelse(confirmed, "code", ifelse(placed, "nearest", NA_character_))
  out$snap_confirmed <- confirmed
  out$snap_moved <- confirmed & (is.na(nearest$blue_line_key) | out$blue_line_key != nearest$blue_line_key)
  out$nearest_distance_m <- nearest$distance_to_stream
  out$ws50_checked <- nearest$site_visit %in% hinted$site_visit
  out$flag_not_placed <- !placed
  out$flag_far_snap <- placed & out$distance_to_stream > ifelse(confirmed, limit_code, limit_near)
  out$flag_ws50_mismatch <- out$ws50_checked & !confirmed & placed
  out
}
