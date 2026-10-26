#' Network distance downstream to the first river of each size, on each flow source
#'
#' `scripts/0296`'s walks. From a point on an FWA blue line, the path is walked
#' downstream on route measures (`inst/sql/ch_dist_profile.sql`, the walk
#' `scripts/0294` fixed for one river size, for an array of sizes) to the first
#' primary-flow segment whose annual flow on `src` is at least each `q` in
#' `q_grid`. One row per start, source and size: `status` is `found`, `none` (the
#' sea first), `no_parent` or `too_many_hops`. Side channels, connectors and other
#' secondary-flow edges are passed over; a lake segment counts, as it would in a
#' link rule.
#'
#' The distance ends at the river's bank, by the rule fresh's `frs_near_river()`
#' applies (#73): where the river found lies in a waterbody polygon, the connector
#' segments (FWA edge types 1400 and 1450) the walk passed inside that polygon and
#' the part of each hop's jump that crosses it are left out, and a connector inside
#' a polygon the walk only passes through stays in. `dist_centre_m` is the distance
#' to the centreline and `bank_m` what the rule took off it, so
#' `dist_m = pmax(dist_centre_m - bank_m, 0)`. What remains different from fresh's
#' walk: this one starts where it is told (a visit's own point; the grade starts it
#' at a segment's downstream end), crosses watershed-group outlets, and walks a
#' line with no local code.
#'
#' Each socket worker opens its own connection through `connector` and installs
#' the walk as a session-temporary function, so a `DBI` connection cannot be
#' passed: it does not serialise to a worker.
#'
#' @param connector a function of no arguments returning a `DBI` connection to a
#'   database holding `discharge` and `whse_basemapping`.
#' @param starts `data.frame` with `blue_line_key` and `downstream_route_measure`.
#' @param q_grid `numeric` river sizes (m³/s), walked to in one pass.
#' @param sources `character` flow sources: `pick` (wet's default per segment),
#'   `pcic_routed`, `wet_balance`.
#' @param workers `integer(1)` socket workers.
#' @return A `tibble`: `blue_line_key`, `downstream_route_measure`, `src`, `qmin`,
#'   `status`, `dist_m`, `large_mad`, `large_lfid`, `large_edge`,
#'   `large_waterbody_key`, `n_hops`, `max_entry_gap_m`, `dist_centre_m`,
#'   `bank_m`; exactly
#'   `nrow(unique(starts)) * length(sources) * length(q_grid)` rows.
#' @export
#' @examples
#' \dontrun{
#' pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' knw_link_walks(pg, data.frame(blue_line_key = 360886335, downstream_route_measure = 1520),
#'                q_grid = c(3, 10), sources = "pick", workers = 1)
#' }
knw_link_walks <- function(connector, starts, q_grid = c(1, 3, 5, 10, 20, 30, 50),
                           sources = c("pick", "pcic_routed", "wet_balance"), workers = 4L) {
  chk::chk_function(connector)
  chk::chk_data(starts)
  chk::check_names(starts, c("blue_line_key", "downstream_route_measure"))
  chk::chk_numeric(q_grid)
  chk::chk_subset(sources, c("pick", "pcic_routed", "wet_balance"))
  chk::chk_whole_number(workers)
  chk::chk_gt(workers, 0)
  starts <- unique(starts[, c("blue_line_key", "downstream_route_measure")])
  if (!nrow(starts)) stop("no starts to walk", call. = FALSE)
  fn_sql <- paste(readLines(system.file("sql/ch_dist_profile.sql", package = "knowledge", mustWork = TRUE)),
                  collapse = "\n")
  qs <- paste0("{", paste(q_grid, collapse = ","), "}")
  walk_chunk <- function(chunk, fn_sql, qs, sources, connector) {
    conn <- connector()
    on.exit(DBI::dbDisconnect(conn))
    DBI::dbExecute(conn, fn_sql)
    out <- lapply(seq_len(nrow(chunk)), function(i) {
      do.call(rbind, lapply(sources, function(src) {
        r <- DBI::dbGetQuery(conn, "SELECT * FROM pg_temp.ch_dist_profile($1::integer, $2, $3::float8[], $4)",
                             params = list(chunk$blue_line_key[i], chunk$downstream_route_measure[i], qs, src))
        cbind(chunk[rep(i, nrow(r)), , drop = FALSE], src = src, r, row.names = NULL)
      }))
    })
    do.call(rbind, out)
  }
  n_chunks <- min(nrow(starts), workers * 8L)
  chunks <- split(starts, rep_len(seq_len(n_chunks), nrow(starts)))
  if (workers > 1L) {
    cl <- parallel::makeCluster(workers)
    w <- tryCatch(parallel::parLapply(cl, chunks, walk_chunk, fn_sql = fn_sql, qs = qs, sources = sources,
                                      connector = connector),
                  finally = parallel::stopCluster(cl))
  } else {
    w <- lapply(chunks, walk_chunk, fn_sql = fn_sql, qs = qs, sources = sources, connector = connector)
  }
  w <- do.call(rbind, w)
  rownames(w) <- NULL
  n_expect <- nrow(starts) * length(sources) * length(q_grid)
  if (nrow(w) != n_expect) stop("walks returned ", nrow(w), " rows, expected ", n_expect, call. = FALSE)
  out <- tibble::as_tibble(w)
  out$blue_line_key <- as.numeric(out$blue_line_key)
  num_cols <- c("qmin", "dist_m", "large_mad", "large_lfid", "large_waterbody_key", "max_entry_gap_m", "dist_centre_m",
                "bank_m")
  for (col in num_cols) {
    out[[col]] <- as.numeric(out[[col]])
  }
  out$large_edge <- as.integer(out$large_edge)
  out$n_hops <- as.integer(out$n_hops)
  out[order(out$blue_line_key, out$downstream_route_measure, out$src, out$qmin), , drop = FALSE]
}
