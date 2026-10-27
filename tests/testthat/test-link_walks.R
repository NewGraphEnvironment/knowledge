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
