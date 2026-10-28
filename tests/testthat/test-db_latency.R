# knw_db_latency_check() stops a database-bound run on a remote link unless REMOTE=TRUE (#110)

# a fake clock: each mocked query advances it by the next of `secs`, so every query takes an exact time
local_query_times <- function(secs, env = parent.frame()) {
  clock <- as.POSIXct(0, origin = "1970-01-01", tz = "UTC")   # near 0, so adding ms stays exact
  calls <- 0L
  testthat::local_mocked_bindings(.knw_now = function() clock, .env = env)
  testthat::local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    calls <<- calls + 1L
    clock <<- clock + secs[[calls]]
    data.frame(x = 1L)
  }, .package = "DBI", .env = env)
  function() calls
}

test_that("the round trip is in ms, over every one of the n queries", {
  n_calls <- local_query_times(rep(0.03, 3))
  expect_equal(knw_db_latency(NULL, n = 3), 30, tolerance = 1e-6)
  expect_identical(n_calls(), 3L)
  expect_error(knw_db_latency(NULL, n = 0))
})

test_that("the round trip is the median of all n queries, with no warm-up dropped", {
  # 100, 5 and 10 ms: the median is 10; the min 5, the mean 38.3, the max and the first 100, the sum 115, and the
  # median without the first query 7.5
  n_calls <- local_query_times(c(0.1, 0.005, 0.01))
  expect_equal(knw_db_latency(NULL, n = 3), 10, tolerance = 1e-6)
  expect_identical(n_calls(), 3L)
})

test_that("a slow connection stops with the round trip and the estimate, unless remote", {
  local_mocked_bindings(knw_db_latency = function(conn, n = 20) 105)
  expect_error(knw_db_latency_check(NULL), "round trip 105.0 ms .*limit 20 ms.*not on the database's host")
  expect_error(knw_db_latency_check(NULL), "GeoPackages 14 min on the host, 197 from a remote link")
  expect_error(knw_db_latency_check(NULL), "set REMOTE=TRUE")
  r <- knw_db_latency_check(NULL, remote = TRUE)
  expect_true(r$over)
  expect_identical(r$ms, 105)
  expect_match(r$line, "round trip 105.0 ms.*over the limit, run anyway on REMOTE=TRUE")
  expect_error(knw_db_latency_check(NULL, remote = "TRUE"))
})

test_that("a fast connection passes and says nothing of an override", {
  local_mocked_bindings(knw_db_latency = function(conn, n = 20) 1.6)
  r <- knw_db_latency_check(NULL)
  expect_false(r$over)
  expect_identical(r$limit_ms, 20)
  expect_identical(r$line, "database round trip 1.6 ms (median of 20 SELECT 1; limit 20 ms)")
  expect_false(grepl("REMOTE", knw_db_latency_check(NULL, remote = TRUE)$line))
})

test_that("the live round trip is measured", {
  conn <- skip_if_no_pg()
  r <- knw_db_latency_check(conn, remote = TRUE, n = 5)
  expect_gt(r$ms, 0)
  message(r$line)
})
