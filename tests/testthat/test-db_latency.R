# knw_db_latency_check() stops a database-bound run on a remote link unless REMOTE=TRUE (#110)

test_that("the round trip is the median wall time of the queries", {
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    Sys.sleep(0.03)
    data.frame(x = 1L)
  }, .package = "DBI")
  ms <- knw_db_latency(NULL, n = 3)
  expect_gt(ms, 20)
  expect_lt(ms, 1000)
  expect_error(knw_db_latency(NULL, n = 0))
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
