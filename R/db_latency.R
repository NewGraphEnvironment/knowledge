# What a remote link cost #92's comparison (`0330`, every key): on the database's host
# (scripts/logs/habitat/20261026_compare*.txt, 2026-10-26) and from a machine on a remote link
# (scripts/logs/habitat/20261027_compare.txt, 2026-10-27). Different runs, so the ratios are approximate.
.knw_remote_cost <- data.frame(
  part = c("classify, overlay and connect", "the rest of the comparison", "GeoPackages"),
  host_min = c(115, 48, 14),
  remote_min = c(164, 105, 197)
)

#' The database's round trip, and the check that a database-bound run is on its host
#'
#' A grade, a comparison and the visit walks are bound by the database, so `CLAUDE.md` runs them on the database's
#' own host. `knw_db_latency()` measures the connection: the median wall time of `n` `SELECT 1` queries through
#' [DBI::dbGetQuery()], with no warm-up, which is the path the host's 1.6 ms and a remote link's 104 to 110 ms were
#' measured on (2026-10-24, 2026-10-26). `knw_db_latency_check()` measures it and, over `limit_ms`, stops with the
#' round trip and what a remote link cost #92's comparison, unless `remote` is `TRUE`. `0310`, `0320` and `0330`
#' call it at connect, before any work, and set `remote` from `REMOTE=TRUE`; each logs the returned `line`.
#'
#' What the remote link cost #92's `0330` (every key; the host on 2026-10-26, the remote link on 2026-10-27, so the
#' ratios are approximate):
#'
#' | part of `0330` | host | remote link |
#' |---|---|---|
#' | classify, overlay and connect | 115 min | 164 min |
#' | the rest of the comparison | 48 min | 105 min |
#' | GeoPackages | 14 min | 197 min |
#'
#' @param conn a `DBI` connection.
#' @param n `integer(1)` how many queries to time.
#' @param remote `logical(1)`: run over the limit anyway, and say so in `line`.
#' @param limit_ms `numeric(1)` the round trip, in ms, above which the connection is taken to be off the host.
#' @return `knw_db_latency()`: the median round trip in ms. `knw_db_latency_check()`: a list of `ms`, `limit_ms`,
#'   `remote`, `over` (the round trip is above the limit) and `line`, the measurement as one line for a log.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_db_latency(conn)
#' knw_db_latency_check(conn)$line
#' }
knw_db_latency <- function(conn, n = 20) {
  chk::chk_whole_number(n)
  chk::chk_gte(n, 1)
  ms <- vapply(seq_len(n), function(i) {
    t0 <- .knw_now()
    DBI::dbGetQuery(conn, "SELECT 1")
    as.numeric(difftime(.knw_now(), t0, units = "secs")) * 1000
  }, numeric(1))
  stats::median(ms)
}

# the clock knw_db_latency() reads, so a test can give each query an exact time
.knw_now <- function() Sys.time()

#' @rdname knw_db_latency
#' @export
knw_db_latency_check <- function(conn, remote = FALSE, limit_ms = 20, n = 20) {
  chk::chk_flag(remote)
  chk::chk_number(limit_ms)
  chk::chk_gt(limit_ms, 0)
  ms <- knw_db_latency(conn, n = n)
  over <- ms > limit_ms
  line <- sprintf("database round trip %.1f ms (median of %d SELECT 1; limit %g ms)", ms, as.integer(n), limit_ms)
  if (over && remote) line <- paste0(line, "; over the limit, run anyway on REMOTE=TRUE")
  if (over && !remote) {
    cost <- .knw_remote_cost
    est <- paste(sprintf("%s %g min on the host, %g from a remote link", cost$part, cost$host_min, cost$remote_min),
                 collapse = "; ")
    stop(line, ": this connection is not on the database's host, where a round trip takes about 1.6 ms. ",
         "A remote link cost #92's comparison: ", est, ". ",
         "Run on the database's host, or set REMOTE=TRUE to run here anyway.", call. = FALSE)
  }
  list(ms = ms, limit_ms = limit_ms, remote = remote, over = over, line = line)
}
