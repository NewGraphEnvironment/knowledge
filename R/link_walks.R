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
#' passed: it does not serialise to a worker. A worker sends one query per
#' `batch` starts and source (#87): the starts go to the server as two arrays,
#' unnested with their position and walked laterally, and each row comes back
#' tagged with its start's position, so the start's own values are attached in R
#' and no key or measure is matched by its printed form. Every start must come
#' back with one row per size. The result does not depend on `batch`: each start
#' is walked alone, as before.
#'
#' With `cache` a table name, every walk is kept (#87): a walk depends only on
#' its start, the river size, the flow source, the flow load
#' ([knw_discharge_load()], by its md5) and the walk's code ([knw_walk_md5()]),
#' so a row keyed on all six is the walk's own for as long as those hold. The
#' starts go to a temporary table and the rows already kept are read with one
#' join per 500,000 starts; a start missing any size on a source is walked for
#' every size on that source (each size's result is independent of the others),
#' and each batch's rows are inserted by the same query that walks them. The
#' cache and its table of flow loads (`<cache>_load`) are created when absent.
#' Rows under another load or walk are never read, and nothing prunes them.
#' The FWA tables the walk reads carry no load record, so a reload of
#' `whse_basemapping.fwa_stream_networks_sp` (fwapg#43 moves measures by
#' millimetres) or of the river, lake, manmade waterbody and wetland polygons
#' it measures the bank on needs the cache truncated by hand.
#'
#' With `window`, a river's size is its flow in that window of the year, not its
#' annual flow (#226): the walk is `inst/sql/ch_dist_profile_window.sql`, the same
#' path, statuses and bank rule, reading for each segment the mean of wet's monthly
#' flow over the window's days (each month weighted by the days the window takes
#' from it, as `wet::wet_flow_window()` weighs them). A segment with no flow in
#' one of the window's months on the source is passed over. Each row's `src` then
#' carries the window, `<source>@<mmdd>-<mmdd>` (`pick@0815-0915`), and `large_mad`
#' is the river's window flow. A window walk is another walk: its cache rows are
#' keyed on that `src` and on the window walk's own md5
#' (`knw_walk_md5(window = TRUE)`) with the months and weights it was walked on,
#' so no row of one window, of other weights, or of the annual walk, is read as
#' another's.
#'
#' @param connector a function of no arguments returning a `DBI` connection to a
#'   database holding `discharge` and `whse_basemapping`.
#' @param starts `data.frame` with `blue_line_key` and `downstream_route_measure`.
#' @param q_grid `numeric` river sizes (m³/s), walked to in one pass.
#' @param sources `character` flow sources: `pick` (wet's default per segment),
#'   `pcic_routed`, `wet_balance`.
#' @param workers `integer(1)` socket workers.
#' @param batch `integer(1)` starts per query. On the database's host a batch of
#'   500 removes the round trip and R's per-row binding; over a remote link it
#'   removes almost all of a walk's time.
#' @param cache `FALSE` (the default: walk everything), or a table name,
#'   `schema.table`, to read walks from and keep them in (see above).
#' @param window `NULL` (the default: the annual flow), or a one-row `data.frame`
#'   with `start` and `end`, each `"MM-DD"`: the window whose flow sizes a river.
#' @return A `tibble`: `blue_line_key`, `downstream_route_measure`, `src`, `qmin`,
#'   `status`, `dist_m`, `large_mad`, `large_lfid`, `large_edge`,
#'   `large_waterbody_key`, `n_hops`, `max_entry_gap_m`, `dist_centre_m`,
#'   `bank_m`; exactly
#'   `nrow(unique(starts)) * length(sources) * length(q_grid)` rows. With a
#'   cache, attribute `cache` holds the start-and-source pairs read (`hit`) and
#'   walked (`miss`). With `window`, `src` is `<source>@<mmdd>-<mmdd>`.
#' @export
#' @examples
#' \dontrun{
#' pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' knw_link_walks(pg, data.frame(blue_line_key = 360886335, downstream_route_measure = 1520),
#'                q_grid = c(3, 10), sources = "pick", workers = 1)
#' }
knw_link_walks <- function(connector, starts, q_grid = c(1, 3, 5, 10, 20, 30, 50),
                           sources = c("pick", "pcic_routed", "wet_balance"), workers = 4L, batch = 500L,
                           cache = FALSE, window = NULL) {
  chk::chk_function(connector)
  chk::chk_data(starts)
  chk::check_names(starts, c("blue_line_key", "downstream_route_measure"))
  chk::chk_numeric(q_grid)
  chk::chk_unique(q_grid)
  chk::chk_subset(sources, c("pick", "pcic_routed", "wet_balance"))
  chk::chk_whole_number(workers)
  chk::chk_gt(workers, 0)
  chk::chk_whole_number(batch)
  chk::chk_gt(batch, 0)
  cache_on <- !isFALSE(cache)
  cache_ok <- is.character(cache) && length(cache) == 1L && grepl("^[a-z_][a-z0-9_]*\\.[a-z_][a-z0-9_]*$", cache)
  if (cache_on && !cache_ok) {
    stop("cache must be FALSE or a lower-case table name, schema.table", call. = FALSE)
  }
  starts <- unique(starts[, c("blue_line_key", "downstream_route_measure")])
  rownames(starts) <- NULL
  if (!nrow(starts)) stop("no starts to walk", call. = FALSE)
  # a window walk (#226) is the other SQL file, its months and weights written into the query, and its rows'
  # `src` carries the window: `label()` is the identity for the annual walk
  win <- NULL
  if (!is.null(window)) {
    win <- .knw_windows(window)
    if (nrow(win) != 1L) stop("window must be one row: one walk reads one window", call. = FALSE)
    win <- c(as.list(win), .knw_window_weights(win$start, win$end))
  }
  label <- function(src) if (is.null(win)) src else paste0(src, "@", win$label)
  fn_sql <- paste(readLines(.knw_walk_file(window = !is.null(win))), collapse = "\n")
  walk_cols <- .knw_walk_cols()
  sql <- .knw_walk_sql(walk_cols, win = win)
  out <- list()
  todo <- stats::setNames(rep(list(seq_len(nrow(starts))), length(sources)), sources)
  if (cache_on) {
    conn <- connector()
    on.exit(DBI::dbDisconnect(conn), add = TRUE)
    meta <- .knw_walk_cache_prepare(conn, cache, walk_md5 = .knw_walk_key(win))
    # each batch's rows are inserted by the query that walks them, so a worker's walk is kept as it is made
    sql <- .knw_walk_sql(walk_cols, win = win, cache = cache, meta = meta)
    DBI::dbWriteTable(conn, "tmp_knw_walk_starts",
                      data.frame(ord = seq_len(nrow(starts)), blue_line_key = starts$blue_line_key,
                                 downstream_route_measure = starts$downstream_route_measure),
                      temporary = TRUE, overwrite = TRUE,
                      field.types = c(ord = "integer", blue_line_key = "integer",
                                      downstream_route_measure = "double precision"))
    DBI::dbExecute(conn, "ANALYZE tmp_knw_walk_starts")
    hit_sql <- sprintf(paste("SELECT t.ord, c.src, %s FROM tmp_knw_walk_starts t JOIN %s c",
                             "ON c.blue_line_key = t.blue_line_key",
                             "AND c.downstream_route_measure = t.downstream_route_measure",
                             "WHERE t.ord BETWEEN $1 AND $2 AND c.src = ANY($3::text[]) AND c.qmin = ANY($4::float8[])",
                             "AND c.load_md5 = $5 AND c.walk_md5 = $6"),
                       paste0("c.", walk_cols, collapse = ", "), cache)
    lo <- seq(1L, nrow(starts), by = 500000L)
    hits <- do.call(rbind, lapply(lo, function(l) {
      DBI::dbGetQuery(conn, hit_sql, params = list(l, min(l + 499999L, nrow(starts)),
                                                   paste0("{", paste(label(sources), collapse = ","), "}"),
                                                   .knw_pg_array(q_grid), meta$load_md5, meta$walk_md5))
    }))
    hits$ord <- as.integer(hits$ord)
    # a start is read from the cache on a source only when every size is there; otherwise it is walked whole
    n_have <- table(factor(paste(hits$ord, hits$src), levels = outer(seq_len(nrow(starts)), label(sources), paste)))
    full <- n_have == length(q_grid)
    hits <- hits[full[paste(hits$ord, hits$src)], , drop = FALSE]
    if (nrow(hits)) {
      out$hits <- cbind(starts[hits$ord, , drop = FALSE], hits[, c("src", walk_cols), drop = FALSE], row.names = NULL)
    }
    for (src in sources) todo[[src]] <- which(!full[paste(seq_len(nrow(starts)), label(src))])
    n_hit <- sum(full)
    n_miss <- length(full) - n_hit
    message(sprintf("walk cache %s: %d of %d start-and-source pairs read, %d to walk", cache, n_hit, length(full),
                    n_miss))
  }
  # the helpers travel as arguments: a socket worker resolves the package's own names in the installed
  # package, or in none, never in the source tree a session loaded
  walk_set <- function(st, srcs) {
    n_chunks <- min(nrow(st), workers * 8L)
    chunks <- split(st, rep_len(seq_len(n_chunks), nrow(st)))
    args <- list(fn_sql = fn_sql, sql = sql, q_grid = q_grid, sources = srcs, connector = connector,
                 batch = as.integer(batch), pg_array = .knw_pg_array, batches = .knw_walk_batches)
    if (workers > 1L && n_chunks > 1L) {
      cl <- parallel::makeCluster(min(workers, n_chunks))
      on.exit(parallel::stopCluster(cl))
      w <- do.call(parallel::parLapply, c(list(cl, chunks, .knw_walk_chunk), args))
    } else {
      w <- lapply(chunks, function(ch) do.call(.knw_walk_chunk, c(list(ch), args)))
    }
    w <- do.call(rbind, w)
    w$src <- label(w$src)   # the worker stamps the bare source it gave the SQL
    w
  }
  if (!cache_on) {
    out$walked <- walk_set(starts, sources)
  } else {
    for (src in sources) {
      if (length(todo[[src]])) out[[paste0("walked_", src)]] <- walk_set(starts[todo[[src]], , drop = FALSE], src)
    }
  }
  w <- do.call(rbind, unname(out))
  rownames(w) <- NULL
  n_expect <- nrow(starts) * length(sources) * length(q_grid)
  if (nrow(w) != n_expect) stop("walks returned ", nrow(w), " rows, expected ", n_expect, call. = FALSE)
  # every start on every source and size exactly once, whether read or walked
  if (anyDuplicated(w[, c("blue_line_key", "downstream_route_measure", "src", "qmin")])) {
    stop("a start came back twice on one source and size", call. = FALSE)
  }
  out <- tibble::as_tibble(w)
  out$blue_line_key <- as.numeric(out$blue_line_key)
  num_cols <- c("qmin", "dist_m", "large_mad", "large_lfid", "large_waterbody_key", "max_entry_gap_m", "dist_centre_m",
                "bank_m")
  for (col in num_cols) {
    out[[col]] <- as.numeric(out[[col]])
  }
  out$large_edge <- as.integer(out$large_edge)
  out$n_hops <- as.integer(out$n_hops)
  out <- out[order(out$blue_line_key, out$downstream_route_measure, out$src, out$qmin), , drop = FALSE]
  if (cache_on) attr(out, "cache") <- c(hit = n_hit, miss = n_miss)
  out
}

# One worker's starts: one connection, the walk installed once, one query per batch and source (`sql`: the walk,
# or the walk that also inserts into the cache). Self-contained (every helper is an argument) because it runs on a
# socket worker.
.knw_walk_chunk <- function(chunk, fn_sql, sql, q_grid, sources, connector, batch, pg_array, batches) {
  conn <- connector()
  on.exit(DBI::dbDisconnect(conn))
  DBI::dbExecute(conn, fn_sql)
  qs <- pg_array(q_grid)
  out <- list()
  for (src in sources) {
    for (b in batches(nrow(chunk), batch)) {
      r <- DBI::dbGetQuery(conn, sql, params = list(pg_array(chunk$blue_line_key[b]),
                                                    pg_array(chunk$downstream_route_measure[b]), qs, src))
      ord <- as.integer(r$ord)
      if (length(ord) != length(b) * length(q_grid) || any(tabulate(ord, length(b)) != length(q_grid))) {
        stop("a batch of ", length(b), " starts on ", src, " came back with ", length(ord), " rows, not one per start ",
             "and size", call. = FALSE)
      }
      out[[length(out) + 1L]] <- cbind(chunk[b[ord], , drop = FALSE], src = src,
                                       r[, setdiff(names(r), "ord"), drop = FALSE], row.names = NULL)
    }
  }
  do.call(rbind, out)
}

# A Postgres array literal of doubles that reads back exactly: %.17g is R's double to the last bit, and writes a
# whole number below 1e17 without an exponent (a round key such as 356000000), where paste() writes 3.56e+08
.knw_pg_array <- function(x) {
  if (!length(x) || any(!is.finite(x))) stop("an array element is missing or not finite", call. = FALSE)
  paste0("{", paste(sprintf("%.17g", x), collapse = ","), "}")
}

# positions 1..n in consecutive runs of at most `batch`
.knw_walk_batches <- function(n, batch) {
  if (n == 0L) return(list())
  unname(split(seq_len(n), ceiling(seq_len(n) / batch)))
}

# the walk's output columns, in ch_dist_profile()'s order: the cache's columns less its key and its timestamp
.knw_walk_cols <- function() {
  setdiff(names(.knw_walk_cache_cols), c("blue_line_key", "downstream_route_measure", "src", "load_md5", "walk_md5",
                                         "walked_at"))
}

# What a kept walk is keyed on beside its start, source, size and flow load (the cache's `walk_md5` column): the
# annual walk's md5, or for a window walk its file's md5 with the months and weights the query carries. The weights
# come from wet, which the window's dates in `src` do not pin: were wet to count a window's days another way, rows
# walked on the old weights would otherwise be read as the new ones'.
.knw_walk_key <- function(win = NULL) {
  if (is.null(win)) return(knw_walk_md5())
  paste(knw_walk_md5(window = TRUE), paste(as.integer(win$months), collapse = ","), .knw_pg_array(win$weights),
        sep = "|")
}

# the file a walk is installed from: the annual walk, or the window walk (#226)
.knw_walk_file <- function(window = FALSE) {
  system.file(if (window) "sql/ch_dist_profile_window.sql" else "sql/ch_dist_profile.sql", package = "knowledge",
              mustWork = TRUE)
}

# The query one batch of starts runs: $1 and $2 the starts' keys and measures, $3 the river sizes, $4 the flow
# source. With `cache` it also inserts the rows it walks. With `win` (a window's `label`, `months` and `weights`)
# it calls the window walk, the months and weights written in as literals that read back exactly, and a kept row's
# `src` is the source with the window's label. Without `win` the text is the annual walk's, which
# tests/testthat/test-link_walks.R holds to the strings it was before a window existed.
.knw_walk_sql <- function(walk_cols, win = NULL, cache = NULL, meta = NULL) {
  fn <- if (is.null(win)) {
    "pg_temp.ch_dist_profile(s.blk, s.m, $3::float8[], $4)"
  } else {
    sprintf("pg_temp.ch_dist_profile_window(s.blk, s.m, $3::float8[], $4, '{%s}'::integer[], '%s'::float8[])",
            paste(as.integer(win$months), collapse = ","), .knw_pg_array(win$weights))
  }
  from <- paste("unnest($1::integer[], $2::float8[]) WITH ORDINALITY AS s(blk, m, ord)",
                "CROSS JOIN LATERAL", fn, "p")
  if (is.null(cache)) {
    return(sprintf("SELECT s.ord, %s FROM %s ORDER BY s.ord", paste0("p.", walk_cols, collapse = ", "), from))
  }
  src <- if (is.null(win)) "$4" else sprintf("$4 || '@%s'", win$label)
  sprintf(paste("WITH w AS (SELECT s.blk, s.m, s.ord, %1$s FROM %2$s),",
                "ins AS (INSERT INTO %3$s",
                "(blue_line_key, downstream_route_measure, src, load_md5, walk_md5, %4$s)",
                "SELECT blk, m, %7$s, '%5$s', '%6$s', %4$s FROM w ON CONFLICT DO NOTHING)",
                "SELECT ord, %4$s FROM w ORDER BY ord"),
          paste0("p.", walk_cols, collapse = ", "), from, cache, paste(walk_cols, collapse = ", "),
          meta$load_md5, meta$walk_md5, src)
}

# the walk cache's columns, the one source for its DDL and the walk's column list (#87): the key, then the walk's
# output in ch_dist_profile()'s order
.knw_walk_cache_cols <- c(
  blue_line_key = "integer NOT NULL", downstream_route_measure = "double precision NOT NULL", src = "text NOT NULL",
  load_md5 = "text NOT NULL", walk_md5 = "text NOT NULL",
  qmin = "double precision NOT NULL", dist_m = "double precision", large_mad = "double precision",
  large_lfid = "bigint", large_edge = "integer", large_waterbody_key = "integer", n_hops = "integer",
  max_entry_gap_m = "double precision", status = "text NOT NULL", dist_centre_m = "double precision",
  bank_m = "double precision", walked_at = "timestamptz NOT NULL DEFAULT now()"
)

# create the cache and its load table when absent, record the live flow load, and return the two md5s a row is keyed
# on: the load's, and the md5 of the walk that makes the rows (the annual walk's unless a window walk gives its own)
.knw_walk_cache_prepare <- function(conn, cache, walk_md5 = knw_walk_md5()) {
  sch <- sub("\\..*$", "", cache)
  DBI::dbExecute(conn, sprintf("CREATE SCHEMA IF NOT EXISTS %s", sch))
  ddl <- paste("CREATE TABLE IF NOT EXISTS %s (%s,",
               "PRIMARY KEY (blue_line_key, downstream_route_measure, src, qmin, load_md5, walk_md5))")
  DBI::dbExecute(conn, sprintf(ddl, cache, paste(names(.knw_walk_cache_cols), .knw_walk_cache_cols, collapse = ", ")))
  ddl_load <- paste("CREATE TABLE IF NOT EXISTS %s_load (load_md5 text PRIMARY KEY,",
                    "discharge_load text NOT NULL, first_seen timestamptz NOT NULL DEFAULT now())")
  DBI::dbExecute(conn, sprintf(ddl_load, cache))
  load <- knw_discharge_load(conn)
  load_md5 <- .knw_load_md5(conn, load)
  DBI::dbExecute(conn, sprintf("INSERT INTO %s_load (load_md5, discharge_load) VALUES ($1, $2) ON CONFLICT DO NOTHING",
                               cache), params = list(load_md5, load))
  list(load = load, load_md5 = load_md5, walk_md5 = walk_md5)
}

# the flow load's md5, taken by Postgres, so the key is the same from any R. `load` is forced first: passed as a
# query on the same connection (`knw_discharge_load(conn)`), a promise would run that query after this one is
# prepared, which cancels it ("bind message supplies 1 parameters")
.knw_load_md5 <- function(conn, load) {
  force(load)
  DBI::dbGetQuery(conn, "SELECT md5($1) AS m", params = list(load))$m
}

#' The flow load the database serves, by its table comment
#'
#' wet can reload `discharge.fwa_v1_segment_monthly` between two runs
#' (NewGraphEnvironment/wet#103 did on 2026-10-19), and the table's comment
#' names the build. A grade records it, a publish compares it, and the walk
#' cache keys every row on its md5 (#72, #87). Refuses a table with no comment.
#'
#' wet writes one comment per table, naming only the scenario loaded last, and
#' the walk and the grade read only `historical`. Once another scenario is
#' loaded, the comment no longer names the historical rows' build, so two
#' different historical loads could share it and the walk cache would serve
#' walks made on the older one. So this refuses a comment that does not name
#' `scenario historical`.
#'
#' @param conn a `DBI` connection to a database holding `discharge`.
#' @return `character(1)`, the comment.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_discharge_load(conn)
#' }
knw_discharge_load <- function(conn) {
  d <- DBI::dbGetQuery(conn, "SELECT obj_description('discharge.fwa_v1_segment_monthly'::regclass) AS d")$d
  if (length(d) != 1L || is.na(d) || !nzchar(d)) {
    stop("discharge.fwa_v1_segment_monthly carries no load comment", call. = FALSE)
  }
  if (!grepl("scenario historical ", d, fixed = TRUE)) {
    stop("discharge.fwa_v1_segment_monthly's comment does not name the historical load the walk reads: ", d,
         call. = FALSE)
  }
  d
}

#' The walk's code, by its md5
#'
#' The md5 of the walk [knw_link_walks()] installs (`inst/sql/ch_dist_profile.sql`).
#' A change to the walk changes every distance it can return, so the walk cache
#' keys every row on it, and every grade table records it as `walk_md5`, which
#' `0320`, `0325` and `0330` compare with this value (#87).
#'
#' The window walk (`inst/sql/ch_dist_profile_window.sql`, #226) is another
#' file with its own md5, which only its own cache rows are keyed on: no grade
#' is walked by it, so nothing compares a grade with it.
#'
#' @param window `logical(1)` the window walk's md5 instead of the annual walk's.
#' @return `character(1)`, an md5 in hex.
#' @export
#' @examples
#' knw_walk_md5()
knw_walk_md5 <- function(window = FALSE) {
  chk::chk_flag(window)
  unname(tools::md5sum(.knw_walk_file(window)))
}
