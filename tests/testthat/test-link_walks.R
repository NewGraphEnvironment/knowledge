# knw_link_walks() walks the live network, so its contract is pinned on one start in the database
# (skipped without one). The bank rule itself (#73) is proved by data-raw/walk_bank_check.R against
# fresh's frs_near_river() on a whole watershed group, which no fixture can stand in for: the walk
# reads whse_basemapping and discharge by name.

test_that("the walk returns the bank distance beside the centreline distance, and never stops on a connector", {
  conn <- skip_if_no_pg("discharge")
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  # the roxygen example's start, a Bulkley tributary found on its own line, and a start at the mouth of a
  # Bulkley line that must hop to its parent (the plan review's probe: a hop is where the walk's path
  # rules run, and where the first draft failed)
  w <- knw_link_walks(pg, data.frame(blue_line_key = c(360886335, 360873822), downstream_route_measure = c(1520, 0)),
                      q_grid = c(3, 10), sources = "pick", workers = 1L)
  expect_identical(nrow(w), 4L)
  expect_true(any(w$n_hops > 0 & w$status == "found"))
  expect_true(all(c("dist_m", "dist_centre_m", "bank_m", "large_edge") %in% names(w)))
  f <- w[w$status == "found", ]
  expect_gt(nrow(f), 0)
  expect_true(all(f$bank_m >= 0))
  expect_equal(f$dist_m, pmax(f$dist_centre_m - f$bank_m, 0))
  expect_false(any(f$large_edge %in% c(1400L, 1450L)))
  nf <- w[w$status != "found", ]
  expect_true(all(is.na(nf$dist_centre_m)) && all(is.na(nf$bank_m)))
})

test_that("a batched walk returns what a walk one start at a time returns, on every source (#87)", {
  conn <- skip_if_no_pg("discharge")
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  # three starts, so a batch of 2 splits them unevenly; one at a fractional measure
  starts <- data.frame(blue_line_key = c(360886335, 360873822, 360886335),
                       downstream_route_measure = c(1520, 0, 2040.5))
  w1 <- knw_link_walks(pg, starts, q_grid = c(3, 10), sources = c("pick", "pcic_routed"), workers = 1L, batch = 1L)
  w2 <- knw_link_walks(pg, starts, q_grid = c(3, 10), sources = c("pick", "pcic_routed"), workers = 1L, batch = 2L)
  w500 <- knw_link_walks(pg, starts, q_grid = c(3, 10), sources = c("pick", "pcic_routed"), workers = 1L)
  expect_identical(nrow(w1), 12L)
  expect_identical(w2, w1)
  expect_identical(w500, w1)
  # the start's own values come back, not a printed copy of them
  expect_true(2040.5 %in% w1$downstream_route_measure)
})

test_that("batches cover every start once, none larger than the batch", {
  for (n in c(1L, 2L, 499L, 500L, 501L, 1001L)) {
    for (b in c(1L, 2L, 500L)) {
      bs <- .knw_walk_batches(n, b)
      expect_identical(unlist(bs), seq_len(n))
      expect_true(all(lengths(bs) <= b))
    }
  }
  expect_identical(.knw_walk_batches(0L, 500L), list())
})

test_that("an array literal reads back as the doubles it was written from", {
  x <- c(356000000, 360886335, 1520.1234567890123, 0.1, 2040.5)
  a <- .knw_pg_array(x)
  expect_false(grepl("e", a, fixed = TRUE))           # a round key keeps its digits (paste() writes 3.56e+08)
  expect_identical(as.numeric(strsplit(gsub("[{}]", "", a), ",")[[1]]), x)
  expect_error(.knw_pg_array(c(1, NA)), "missing")
  expect_error(.knw_pg_array(Inf), "not finite")
  expect_error(.knw_pg_array(numeric()), "missing")
})

test_that("a batch that comes back short of a start is refused, though the row count could still add up", {
  chunk <- data.frame(blue_line_key = c(1, 2), downstream_route_measure = c(0, 0))
  row <- function(ord) data.frame(ord = ord, qmin = 3, status = "found")
  local_mocked_bindings(dbExecute = function(...) 0L, dbDisconnect = function(...) TRUE, .package = "DBI")
  run <- function(res) {
    local_mocked_bindings(dbGetQuery = function(...) res, .package = "DBI")
    .knw_walk_chunk(chunk, fn_sql = "", sql = "", q_grid = 3, sources = "pick", connector = function() NULL,
                    batch = 500L, pg_array = .knw_pg_array, batches = .knw_walk_batches)
  }
  expect_identical(nrow(run(row(c(1, 2)))), 2L)
  expect_error(run(row(c(1, 1))), "not one per start")   # two rows, but the second start's is missing
  expect_error(run(row(1)), "not one per start")
})

test_that("the walk cache misses, then reads back what was walked, and misses under another load or walk", {
  conn <- skip_if_no_pg("discharge")
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  tbl <- paste0("public.knw_walk_cache_test_", Sys.getpid())
  on.exit({
    DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s", tbl))
    DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s_load", tbl))
  }, add = TRUE)
  starts <- data.frame(blue_line_key = c(360886335, 360873822, 360886335),
                       downstream_route_measure = c(1520, 0, 2040.5))
  walk_cached <- function() knw_link_walks(pg, starts, q_grid = c(3, 10), sources = "pick", workers = 1L, cache = tbl)
  expect_message(cold <- walk_cached(), "0 of 3 start-and-source pairs read, 3 to walk")
  expect_identical(attr(cold, "cache"), c(hit = 0L, miss = 3L))
  expect_identical(as.integer(DBI::dbGetQuery(conn, sprintf("SELECT count(*) AS n FROM %s", tbl))$n), 6L)
  expect_message(warm <- walk_cached(), "3 of 3 start-and-source pairs read, 0 to walk")
  plain <- knw_link_walks(pg, starts, q_grid = c(3, 10), sources = "pick", workers = 1L)
  attr(cold, "cache") <- NULL
  attr(warm, "cache") <- NULL
  expect_identical(warm, plain)
  expect_identical(cold, plain)
  # a size not yet kept walks the start again, whole, and keeps the new size
  expect_message(knw_link_walks(pg, starts[1, ], q_grid = c(3, 5), sources = "pick", workers = 1L, cache = tbl),
                 "0 of 1 start-and-source pairs read, 1 to walk")
  # rows under another flow load or another walk are never read
  DBI::dbExecute(conn, sprintf("UPDATE %s SET load_md5 = 'other'", tbl))
  expect_message(walk_cached(), "0 of 3 start-and-source pairs read")
  DBI::dbExecute(conn, sprintf("UPDATE %s SET walk_md5 = 'other' WHERE load_md5 <> 'other'", tbl))
  expect_message(walk_cached(), "0 of 3 start-and-source pairs read")
  expect_error(knw_link_walks(pg, starts, cache = "knw walk"), "schema.table")
  # the load's md5 taken from a query passed straight in, as data-raw/walk_batch_check.R passes it
  load <- knw_discharge_load(conn)
  expect_identical(.knw_load_md5(conn, knw_discharge_load(conn)), .knw_load_md5(conn, load))
})

test_that("the flow load is refused unless its comment names the historical load the walk reads", {
  load_of <- function(comment) {
    local_mocked_bindings(dbGetQuery = function(...) data.frame(d = comment), .package = "DBI")
    knw_discharge_load(NULL)
  }
  hist <- "wet_db_load(): discharge/fwa/v1/segment_monthly, scenario historical last loaded from m (built b, wet w)"
  expect_identical(load_of(hist), hist)
  expect_error(load_of(sub("historical", "ssp245", hist)), "does not name the historical load")
  expect_error(load_of(NA_character_), "no load comment")
  expect_error(load_of(""), "no load comment")
})

# ---- the window walk (#226): another file, the same walk but for the flow it reads --------------------------------

# a region marker is a line holding nothing else; the header's prose names the markers without being one
walk_mark <- function(x, which) trimws(x) == paste("-- window flow:", which)
# a walk file's lines after its leading comment block (a region marker is not part of that block)
walk_body <- function(window) {
  x <- readLines(.knw_walk_file(window))
  head_line <- startsWith(x, "--") & !walk_mark(x, "begin") & !walk_mark(x, "end")
  x[seq_along(x) > max(which(cumsum(!head_line) == 0L))]
}

test_that("the window walk's file is the annual walk's text outside its three marked regions", {
  pub <- walk_body(FALSE)
  win <- walk_body(TRUE)
  mark <- cumsum(walk_mark(win, "begin")) - cumsum(c(FALSE, head(walk_mark(win, "end"), -1L)))
  expect_setequal(mark, c(0L, 1L))                       # the markers pair up and never nest
  expect_identical(c(sum(walk_mark(win, "begin")), sum(walk_mark(win, "end"))), c(3L, 3L))
  expect_false(any(walk_mark(pub, "begin") | walk_mark(pub, "end")))
  core <- win[mark == 0L]
  # walk the annual file: each of its lines is the window file's next unmarked line, or belongs to the annual
  # walk alone
  only_pub <- character()
  k <- 1L
  for (line in pub) {
    if (k <= length(core) && identical(line, core[k])) k <- k + 1L else only_pub <- c(only_pub, line)
  }
  expect_identical(k, length(core) + 1L)                 # every unmarked line of the window file was met, in order
  # what the annual walk alone holds: its signature, and its read of the annual flow
  expect_identical(only_pub, c(
    "CREATE OR REPLACE FUNCTION pg_temp.ch_dist_profile(start_blk integer, start_m double precision,",
    "                                                   qmins double precision[], src text)",
    "            JOIN discharge.fwa_v1_segment_monthly q",
    "              ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical'",
    "             AND q.month = 0 AND ((src = 'pick' AND q.pick) OR q.source = src)"
  ))
  # so the edge types a river may be, the path and the bank rule are one text
  expect_true(any(grepl("s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300, 1400, 1450)", core, fixed = TRUE)))
})

test_that("the annual walk is the walk every grade was walked by, and the window walk is another", {
  expect_match(knw_walk_md5(window = TRUE), "^[0-9a-f]{32}$")
  expect_false(identical(knw_walk_md5(window = TRUE), knw_walk_md5()))
  expect_identical(knw_walk_md5(window = FALSE), knw_walk_md5())
  # the tracked grade records name the annual walk's md5 (the source tree only: data/ is not in the build)
  recs <- list.files(test_path("..", "..", "data", "tune"), "_grades_record\\.csv$", full.names = TRUE)
  skip_if(length(recs) == 0L, "no tracked grade records beside the tests (an installed package)")
  md5 <- unique(unlist(lapply(recs, function(f) utils::read.csv(f, stringsAsFactors = FALSE)$walk_md5)))
  expect_identical(md5, knw_walk_md5())
})

test_that("the annual walk's query is the text it was before a window existed", {
  walk_cols <- c("qmin", "dist_m", "large_mad", "large_lfid", "large_edge", "large_waterbody_key", "n_hops",
                 "max_entry_gap_m", "status", "dist_centre_m", "bank_m")
  expect_identical(.knw_walk_cols(), walk_cols)
  # knw_link_walks()'s own construction before #226, kept here as it was written
  from <- paste("unnest($1::integer[], $2::float8[]) WITH ORDINALITY AS s(blk, m, ord)",
                "CROSS JOIN LATERAL pg_temp.ch_dist_profile(s.blk, s.m, $3::float8[], $4) p")
  expect_identical(.knw_walk_sql(walk_cols),
                   sprintf("SELECT s.ord, %s FROM %s ORDER BY s.ord", paste0("p.", walk_cols, collapse = ", "), from))
  meta <- list(load_md5 = "aa", walk_md5 = "bb")
  expect_identical(.knw_walk_sql(walk_cols, cache = "knw.walk_cache", meta = meta),
                   sprintf(paste("WITH w AS (SELECT s.blk, s.m, s.ord, %1$s FROM %2$s),",
                                 "ins AS (INSERT INTO %3$s",
                                 "(blue_line_key, downstream_route_measure, src, load_md5, walk_md5, %4$s)",
                                 "SELECT blk, m, $4, '%5$s', '%6$s', %4$s FROM w ON CONFLICT DO NOTHING)",
                                 "SELECT ord, %4$s FROM w ORDER BY ord"),
                           paste0("p.", walk_cols, collapse = ", "), from, "knw.walk_cache",
                           paste(walk_cols, collapse = ", "), "aa", "bb"))
  # a window's query calls the other function and keeps the window in the row's source
  skip_if_not_installed("wet")
  win <- c(list(label = "0815-0915"), .knw_window_weights("08-15", "09-15"))
  q <- .knw_walk_sql(walk_cols, win = win, cache = "knw.walk_cache_window", meta = meta)
  expect_match(q, paste0("pg_temp.ch_dist_profile_window(s.blk, s.m, $3::float8[], $4, '{8,9}'::integer[], ",
                         "'{0.53125,0.46875}'::float8[])"), fixed = TRUE)
  expect_match(q, "SELECT blk, m, $4 || '@0815-0915', 'aa', 'bb',", fixed = TRUE)
})

test_that("the window walk given the annual flow as its window is the annual walk, row for row", {
  conn <- skip_if_no_pg("discharge")
  for (w in c(FALSE, TRUE)) DBI::dbExecute(conn, paste(readLines(.knw_walk_file(w)), collapse = "\n"))
  starts <- data.frame(blk = c(360886335, 360873822, 360886335), m = c(1520, 0, 2040.5))
  for (src in c("pick", "pcic_routed", "wet_balance")) {
    for (i in seq_len(nrow(starts))) {
      p <- list(starts$blk[i], starts$m[i], src)
      a <- DBI::dbGetQuery(conn, "SELECT * FROM pg_temp.ch_dist_profile($1::integer, $2::float8, '{1,3,10,50}', $3)
                                  ORDER BY qmin", params = p)
      b <- DBI::dbGetQuery(conn, "SELECT * FROM pg_temp.ch_dist_profile_window($1::integer, $2::float8,
                                  '{1,3,10,50}', $3, '{0}', '{1}') ORDER BY qmin", params = p)
      expect_identical(nrow(a), 4L)
      expect_identical(b, a)
    }
  }
  expect_true(TRUE)
  expect_error(DBI::dbGetQuery(conn, "SELECT * FROM pg_temp.ch_dist_profile_window(360886335, 1520, '{3}', 'pick',
                                      '{8,9}', '{1}')"), "one length")
})

test_that("a window walk finds rivers by their window flow, and says so in the source", {
  skip_if_not_installed("wet")
  conn <- skip_if_no_pg("discharge")
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  starts <- data.frame(blue_line_key = c(360886335, 360873822, 360886335),
                       downstream_route_measure = c(1520, 0, 2040.5))
  win <- data.frame(start = "08-15", end = "09-15")
  w <- knw_link_walks(pg, starts, q_grid = c(1, 3, 10), sources = c("pick", "wet_balance"), workers = 1L, window = win)
  expect_identical(nrow(w), 18L)
  expect_setequal(w$src, c("pick@0815-0915", "wet_balance@0815-0915"))
  f <- w[w$status == "found" & w$src == "pick@0815-0915", ]
  expect_gt(nrow(f), 0)
  # the river found carries the window flow knw_link_flow_window() reads on it, and that flow reaches the size
  fl <- knw_link_flow_window(conn, unique(f$large_lfid), win)
  expect_false(anyNA(fl$flow_0815_0915))
  expect_equal(f$large_mad, fl$flow_0815_0915[match(f$large_lfid, fl$linear_feature_id)], tolerance = 1e-12)
  expect_true(all(f$large_mad >= f$qmin))
  # and it is a different walk from the annual one somewhere on these starts: a river's September is not its year
  a <- knw_link_walks(pg, starts, q_grid = c(1, 3, 10), sources = "pick", workers = 1L)
  expect_false(isTRUE(all.equal(f$large_mad, a$large_mad[a$status == "found"])))
  expect_error(knw_link_walks(pg, starts, window = data.frame(start = c("08-01", "08-15"), end = c("09-30", "09-15"))),
               "one row")
})

test_that("a window's cache rows are its own: no other window, and not the annual walk, reads them", {
  skip_if_not_installed("wet")
  conn <- skip_if_no_pg("discharge")
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  tbl <- paste0("public.knw_walk_cache_wintest_", Sys.getpid())
  on.exit({
    DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s", tbl))
    DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s_load", tbl))
  }, add = TRUE)
  starts <- data.frame(blue_line_key = c(360886335, 360873822), downstream_route_measure = c(1520, 0))
  spawn <- data.frame(start = "08-15", end = "09-15")
  rear <- data.frame(start = "08-01", end = "09-30")
  walk <- function(window = NULL, cache = tbl) {
    knw_link_walks(pg, starts, q_grid = c(3, 10), sources = "pick", workers = 1L, cache = cache, window = window)
  }
  expect_message(cold <- walk(spawn), "0 of 2 start-and-source pairs read, 2 to walk")
  expect_message(warm <- walk(spawn), "2 of 2 start-and-source pairs read, 0 to walk")
  plain <- walk(spawn, cache = FALSE)
  attr(cold, "cache") <- NULL
  attr(warm, "cache") <- NULL
  expect_identical(warm, plain)
  expect_identical(cold, plain)
  kept <- DBI::dbGetQuery(conn, sprintf("SELECT DISTINCT src, walk_md5 FROM %s", tbl))
  expect_identical(kept$src, "pick@0815-0915")
  expect_identical(kept$walk_md5, knw_walk_md5(window = TRUE))
  # another window, and the annual walk, each start cold in the same table
  expect_message(walk(rear), "0 of 2 start-and-source pairs read, 2 to walk")
  expect_message(annual <- walk(), "0 of 2 start-and-source pairs read, 2 to walk")
  # and the annual walk's rows, kept beside the windows', are the annual walk's
  expect_message(annual_warm <- walk(), "2 of 2 start-and-source pairs read, 0 to walk")
  annual_plain <- walk(cache = FALSE)
  attr(annual_warm, "cache") <- NULL
  expect_identical(annual_warm, annual_plain)
  expect_setequal(DBI::dbGetQuery(conn, sprintf("SELECT DISTINCT src FROM %s", tbl))$src,
                  c("pick@0815-0915", "pick@0801-0930", "pick"))
})
