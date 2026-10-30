# knw_build_record() refuses a schema built by another run than the evidence's, before a run does any work (#87)

test_that("the build record names the schema's run, the flows and the walk, and refuses another run", {
  runs <- "20261017_004619-3f4c713b"
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    if (grepl("to_regclass", sql)) data.frame(ok = TRUE)
    else if (grepl("information_schema", sql)) data.frame(column_name = character())
    else data.frame(u = runs)
  }, .package = "DBI")
  local_mocked_bindings(knw_discharge_load = function(conn) "wet load 2026-10-19")
  r <- knw_build_record(NULL, "fresh_default_20261017")
  expect_identical(r$run_uid, runs)
  expect_identical(r$walk_md5, knw_walk_md5())
  expect_match(r$line, "schema fresh_default_20261017, run 20261017_004619-3f4c713b; flows wet load 2026-10-19; walk ")
  expect_identical(knw_build_record(NULL, "fresh_default_20261017", run_uid = runs)$run_uid, runs)
  # a build before link 0.70.0 logs no tokens
  expect_identical(r$tokens, c(cut = NA_character_, acc = NA_character_, grad = NA_character_, flow = NA_character_))
  expect_match(r$line, "tokens none \\(before link 0.70.0\\)$")
  expect_error(knw_build_record(NULL, "fresh_default_20261017", run_uid = "20261023_074321-24d85e8c"),
               "built by run 20261017_004619-3f4c713b, not the evidence's 20261023_074321-24d85e8c")
  runs <- "a;b"
  expect_error(knw_build_record(NULL, "fresh_default", run_uid = "a"), "built by run a;b")
  expect_error(knw_build_record(NULL, "Fresh-default"), "lower-case")
})

test_that("a build's tokens are read one per axis, and two on one axis refused", {
  tok <- list(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = c("q-wet-fill"))
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    if (grepl("to_regclass", sql)) return(data.frame(ok = TRUE))
    if (grepl("information_schema", sql)) return(data.frame(column_name = paste0("token_", names(tok))))
    a <- regmatches(sql, regexpr("(?<=DISTINCT token_)[a-z]+", sql, perl = TRUE))
    if (length(a)) return(data.frame(v = tok[[a]]))
    data.frame(u = "r1")
  }, .package = "DBI")
  local_mocked_bindings(knw_discharge_load = function(conn) "wet load")
  r <- knw_build_record(NULL, "fresh_default")
  expect_identical(r$tokens, c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill"))
  expect_match(r$line, "tokens cut-full-top.acc-v1.grad-seg.q-wet-fill$")
  tok$acc <- c("acc-bcfp", "acc-v1")
  expect_error(knw_build_record(NULL, "fresh_default"), "logged 2 acc tokens \\(acc-bcfp, acc-v1\\)")
})

test_that("a schema with no run log is refused", {
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) data.frame(ok = FALSE), .package = "DBI")
  expect_error(knw_build_record(NULL, "public"), "no log_recompute table")
})

test_that("the live build record reads a link schema", {
  conn <- skip_if_no_pg("fresh_default_20261017")
  r <- knw_build_record(conn, "fresh_default_20261017")
  expect_match(r$run_uid, "^[0-9]{8}_[0-9]{6}-[0-9a-f]{8}$")
  expect_true(nzchar(r$discharge_load))
})

test_that("the walk's md5 is the md5 of the walk the package installs", {
  expect_identical(knw_walk_md5(),
                   unname(tools::md5sum(system.file("sql/ch_dist_profile.sql", package = "knowledge"))))
  expect_match(knw_walk_md5(), "^[0-9a-f]{32}$")
})
