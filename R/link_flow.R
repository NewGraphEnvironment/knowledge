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
#' Where two such segments are equally near, the one with the lower
#' `linear_feature_id` gives the flow: an arbitrary but fixed choice, so every
#' database holding the build takes the same one (#161).
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
  seg <- DBI::dbGetQuery(conn, .knw_link_flow_sql(tmp))
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

# knw_link_flow()'s query on the segment ids in `tmp`; the FWA and flow tables are arguments so that a test can put
# fixtures in their place. `parent_lfid` names the parent a segment with no flow of its own took its flow from, for a
# caller that reads that segment's other months (data-raw/chinook_window_flow.R); knw_link_flow() does not return it.
.knw_link_flow_sql <- function(tmp, fwa = "whse_basemapping.fwa_stream_networks_sp",
                               q = "discharge.fwa_v1_segment_monthly") {
  sprintf("
    SELECT t.linear_feature_id,
           s.blue_line_key <> s.watershed_key AS side_channel,
           s.gradient AS fwa_gradient,
           coalesce(s.wscode_ltree, par.wscode)::text AS wscode,
           coalesce(s.localcode_ltree, par.localcode)::text AS localcode,
           (s.wscode_ltree IS NULL OR s.localcode_ltree IS NULL) AS code_from_parent, s.waterbody_key,
           own.mad_pick AS own_mad, own.pick_source AS own_source, own.mad_routed, own.mad_balance,
           par.q_m3s AS parent_mad, par.source AS parent_source, par.d AS parent_dist_m,
           par.linear_feature_id AS parent_lfid
    FROM %1$s t
    JOIN %2$s s ON s.linear_feature_id = t.linear_feature_id
    LEFT JOIN LATERAL (
      SELECT max(q.q_m3s) FILTER (WHERE q.pick) AS mad_pick,
             max(q.source) FILTER (WHERE q.pick) AS pick_source,
             max(q.q_m3s) FILTER (WHERE q.source = 'pcic_routed') AS mad_routed,
             max(q.q_m3s) FILTER (WHERE q.source = 'wet_balance') AS mad_balance
      FROM %3$s q
      WHERE q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0
    ) own ON true
    LEFT JOIN LATERAL (
      SELECT p.linear_feature_id, q.q_m3s, q.source, ST_Distance(p.geom, s.geom) AS d,
             p.wscode_ltree AS wscode, p.localcode_ltree AS localcode
      FROM %2$s p
      JOIN %3$s q
        ON q.linear_feature_id = p.linear_feature_id AND q.scenario = 'historical'
       AND q.month = 0 AND q.pick
      WHERE (own.mad_pick IS NULL OR s.wscode_ltree IS NULL OR s.localcode_ltree IS NULL)
        AND p.blue_line_key IN (s.watershed_key, s.blue_line_key)
        AND p.wscode_ltree IS NOT NULL AND p.localcode_ltree IS NOT NULL
        AND p.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
      ORDER BY p.geom <-> s.geom, p.linear_feature_id
      LIMIT 1
    ) par ON true", tmp, fwa, q)
}

#' wet's flow in a seasonal window on FWA segments, on the segment MAD came from
#'
#' [knw_link_flow()] reads the annual flow (MAD). This reads the mean flow over a
#' window of the year, such as 1 August to 30 September, so a stream can be sized
#' by what it carries when a life stage is in it (#226). The flow is wet's monthly
#' flow (`discharge.fwa_v1_segment_monthly`, scenario `historical`) on the source
#' wet picks for the segment, averaged over the window's days with each day
#' taking its month's mean (`wet::wet_flow_window()`, the monthly basis).
#'
#' A window is read on the segment the annual flow came from: the segment's own,
#' or the parent [knw_link_flow()] falls back to. So a window flow is present
#' exactly where `mad_pick` is, on the same source, and `mad_pick` comes back
#' beside it for a caller to hold to its own. A segment read must carry months 0
#' to 12 once each on one picked source, or the call stops: a window read from
#' some of its months, or across two sources, is not that window's flow.
#'
#' @inheritParams knw_link_flow
#' @param windows `data.frame` with `start` and `end`, each `"MM-DD"`, one row per
#'   window. A window whose end is before its start crosses 1 January.
#' @return A `tibble`, one row per segment, ordered by `linear_feature_id`:
#'   `linear_feature_id`, `mad_pick`, and one column per window named by its
#'   dates, `flow_<mmdd>_<mmdd>` (m³/s).
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_link_flow_window(conn, c(701747495, 701747496), data.frame(start = "08-01", end = "09-30"))
#' }
knw_link_flow_window <- function(conn, linear_feature_id, windows) {
  .knw_link_flow_window(conn, linear_feature_id, windows)
}

# knw_link_flow_window() with the FWA and flow tables as arguments, so a test can put fixtures in their place
.knw_link_flow_window <- function(conn, linear_feature_id, windows, fwa = "whse_basemapping.fwa_stream_networks_sp",
                                  q = "discharge.fwa_v1_segment_monthly") {
  chk::chk_numeric(linear_feature_id)
  chk::chk_not_any_na(linear_feature_id)
  rlang::check_installed("wet", reason = "to average monthly flow over a window")
  win <- .knw_windows(windows)
  tmp <- "tmp_knw_link_flow_window"
  DBI::dbWriteTable(conn, tmp, data.frame(linear_feature_id = unique(linear_feature_id)),
                    temporary = TRUE, overwrite = TRUE)
  on.exit(try(DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp)), silent = TRUE), add = TRUE)
  seg <- DBI::dbGetQuery(conn, .knw_link_flow_sql(tmp, fwa = fwa, q = q))
  if (anyDuplicated(seg$linear_feature_id)) stop("a segment matched twice", call. = FALSE)
  # a bigint arrives as integer64 on a default connection, and base ifelse() copies its bits into a double
  id <- as.numeric(seg$linear_feature_id)
  own <- !is.na(seg$own_mad)
  src <- ifelse(own, id, as.numeric(seg$parent_lfid))
  out <- tibble::tibble(linear_feature_id = id,
                        mad_pick = as.numeric(ifelse(own, seg$own_mad, seg$parent_mad)))
  for (col in win$col) out[[col]] <- NA_real_
  read <- unique(src[!is.na(src)])
  if (length(read)) {
    mon <- DBI::dbGetQuery(conn, sprintf("SELECT linear_feature_id, source, month, q_m3s FROM %s
                                          WHERE scenario = 'historical' AND pick
                                            AND linear_feature_id = ANY($1::bigint[])", q),
                           params = list(.knw_pg_array(read)))
    mon <- data.frame(linear_feature_id = as.numeric(mon$linear_feature_id), source = mon$source,
                      month = as.integer(mon$month), q_m3s = as.numeric(mon$q_m3s))
    by_seg <- split(mon, factor(mon$linear_feature_id, levels = read))
    whole <- vapply(by_seg, function(x) identical(sort(x$month), 0:12) && length(unique(x$source)) == 1L, logical(1))
    if (!all(whole)) {
      stop(sum(!whole), " of the ", length(read), " segments read do not carry months 0 to 12 once each on one ",
           "picked source", call. = FALSE)
    }
    # the annual flow among the months is the flow query's, or the two read different rows
    mad0 <- mon$q_m3s[mon$month == 0L][match(src, mon$linear_feature_id[mon$month == 0L])]
    if (!isTRUE(all.equal(mad0, out$mad_pick, tolerance = 1e-12))) {
      stop("the annual flow read with the months is not the flow query's", call. = FALSE)
    }
    wf <- wet::wet_flow_window(mon, data.frame(window = win$col, start = win$start, end = win$end))
    for (col in win$col) {
      w <- wf[wf$window == col, , drop = FALSE]
      out[[col]] <- w$q_m3s[match(src, w$linear_feature_id)]
    }
  }
  out[order(out$linear_feature_id), , drop = FALSE]
}

# Windows as the window readers take them: `start` and `end` checked as "MM-DD", each window's label by its dates
# (`0815-0915`, which a window walk's source carries) and its column name (`flow_0815_0915`).
.knw_windows <- function(windows) {
  chk::chk_data(windows)
  chk::check_names(windows, c("start", "end"))
  start <- as.character(windows$start)
  end <- as.character(windows$end)
  md <- "^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$"
  if (!length(start) || anyNA(c(start, end)) || !all(grepl(md, c(start, end)))) {
    stop("windows must hold at least one row, each start and end written \"MM-DD\"", call. = FALSE)
  }
  label <- paste0(sub("-", "", start, fixed = TRUE), "-", sub("-", "", end, fixed = TRUE))
  if (anyDuplicated(label)) stop("two windows have the same dates", call. = FALSE)
  data.frame(start = start, end = end, label = label, col = paste0("flow_", sub("-", "_", label, fixed = TRUE)))
}

# The weight each month carries in a window's mean flow on the monthly basis: the share of the window's days that
# fall in it. Taken from wet::wet_flow_window() on twelve unit series, one per month, so the window walk's SQL
# (inst/sql/ch_dist_profile_window.sql) weighs months by wet's own count of days, never a second one.
.knw_window_weights <- function(start, end) {
  rlang::check_installed("wet", reason = "to weigh the months of a window")
  unit <- data.frame(series = rep(1:12, each = 12L), month = rep(1:12, times = 12L))
  unit$q_m3s <- as.numeric(unit$series == unit$month)
  w <- wet::wet_flow_window(unit, data.frame(window = "w", start = start, end = end), by = "series")
  wt <- w$q_m3s[match(1:12, w$series)]
  if (anyNA(wt) || abs(sum(wt) - 1) > 1e-9) stop("the window's month weights do not sum to 1", call. = FALSE)
  list(months = which(wt > 0), weights = wt[wt > 0])
}
