# knw_build_record() refuses a schema built by another run than the evidence's, before a run does any work (#87)

test_that("the build record names the schema's run, the flows and the walk, and refuses another run", {
  runs <- "20261017_004619-3f4c713b"
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    if (grepl("to_regclass", sql)) data.frame(ok = TRUE)
    else if (grepl("information_schema", sql)) data.frame(column_name = character())
    else if (grepl("GROUP BY run_uid", sql)) data.frame(run_uid = strsplit(runs, ";")[[1]], n = 1L, a = 1, b = 1)
    else if (grepl("SELECT DISTINCT run_uid", sql)) data.frame(run_uid = strsplit(runs, ";")[[1]])
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

test_that("a build's tokens are read from `log`, one per axis, and two on one axis refused", {
  # link writes the tokens on `<schema>.log` (one row per pipeline call and group), never on `log_recompute`; the mock
  # answers by table name, so a reader that asks `log_recompute` for them gets nothing
  tok <- list(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  n_rows <- 4L
  n_val <- c(cut = 4L, acc = 4L, grad = 4L, flow = 4L)
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    if (grepl("to_regclass", sql)) return(data.frame(ok = TRUE))
    if (grepl("information_schema", sql)) {
      cols <- if (grepl("table_name = 'log'", sql, fixed = TRUE)) paste0("token_", names(tok)) else character()
      return(data.frame(column_name = cols))
    }
    a <- regmatches(sql, regexpr("(?<=count\\(token_)[a-z]+", sql, perl = TRUE))
    if (length(a)) {
      if (!grepl("\\.log(\\s|$)", sql)) return(data.frame(n = 0L, n_val = 0L, v = NA_character_))
      return(data.frame(n = n_rows, n_val = n_val[[a]], v = paste(sort(tok[[a]]), collapse = ";")))
    }
    if (grepl("GROUP BY run_uid", sql)) return(data.frame(run_uid = "r1", n = n_rows, a = 1, b = 1))
    if (grepl("SELECT DISTINCT run_uid", sql)) return(data.frame(run_uid = "r1"))
    data.frame(u = "r1")
  }, .package = "DBI")
  local_mocked_bindings(knw_discharge_load = function(conn) "wet load")
  r <- knw_build_record(NULL, "fresh_default")
  expect_identical(r$tokens, c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill"))
  expect_match(r$line, "tokens cut-full-top.acc-v1.grad-seg.q-wet-fill$")
  # rows with a token beside rows without one are not one build
  n_val[["grad"]] <- 3L
  expect_error(knw_build_record(NULL, "fresh_default"), "1 of 4 log rows carry no grad token: not one build")
  n_val[["grad"]] <- 4L
  tok$acc <- c("acc-bcfp", "acc-v1")
  expect_error(knw_build_record(NULL, "fresh_default"), "logged 2 acc tokens \\(acc-bcfp, acc-v1\\)")
  # an axis whose column holds no value at all (a build before the axis existed) stays NA
  tok$acc <- "acc-v1"
  n_val[["flow"]] <- 0L
  expect_identical(knw_build_record(NULL, "fresh_default")$tokens[["flow"]], NA_character_)
})

test_that("a schema whose `log` keeps an earlier run reads the tokens of the runs `log_recompute` names (#145)", {
  # a provincial run leaves the previous run's `log` rows in place: link 0.68.0's rows, with no tokens, beside the new
  # run's. The mock holds the rows and answers every query from them, so the reader is held to which rows it filters
  lg <- data.frame(run_uid = c(rep("old", 3), rep("new", 2)), token_cut = c(NA, NA, NA, "cut-full-top", "cut-full-top"),
                   token_acc = c(NA, NA, NA, "acc-v5", "acc-v5"), t = c(1, 2, 3, 10, 11), stringsAsFactors = FALSE)
  rec_runs <- "new"
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    p <- list(...)$params
    if (grepl("to_regclass", sql)) return(data.frame(ok = TRUE))
    if (grepl("information_schema", sql)) return(data.frame(column_name = c("token_cut", "token_acc")))
    if (grepl("string_agg\\(DISTINCT run_uid", sql)) return(data.frame(u = paste(sort(rec_runs), collapse = ";")))
    if (grepl("FROM \\S+\\.log_recompute", sql)) return(data.frame(run_uid = rec_runs))
    rows <- lg
    if (grepl("ANY(", sql, fixed = TRUE)) {
      rows <- rows[rows$run_uid %in% strsplit(gsub('[{}"]', "", p[[1]]), ",")[[1]], ]
    }
    if (grepl("GROUP BY run_uid", sql)) {
      g <- split(rows$t, factor(rows$run_uid, exclude = NULL))
      return(data.frame(run_uid = names(g), n = lengths(g), a = vapply(g, min, 0), b = vapply(g, max, 0),
                        row.names = NULL, stringsAsFactors = FALSE))
    }
    a <- regmatches(sql, regexpr("(?<=count\\(token_)[a-z]+", sql, perl = TRUE))
    x <- rows[[paste0("token_", a)]]
    v <- sort(unique(x[!is.na(x)]))
    data.frame(n = nrow(rows), n_val = sum(!is.na(x)), v = if (length(v)) paste(v, collapse = ";") else NA_character_)
  }, .package = "DBI")
  local_mocked_bindings(knw_discharge_load = function(conn) "wet load")
  r <- knw_build_record(NULL, "fresh_default", run_uid = "new")
  expect_identical(r$tokens, c(cut = "cut-full-top", acc = "acc-v5", grad = NA_character_, flow = NA_character_))
  expect_identical(r$log_run_uid, "new")
  expect_match(r$line, "; log rows of run old set aside \\(not in log_recompute\\)$")
  b <- .knw_build_log_runs(NULL, "fresh_default")
  expect_identical(b$runs, "new")
  expect_identical(b$aside, "old")
  # the recompute run's own rows still have to be one build: one of them without a token is refused
  lg$token_cut[5] <- NA
  expect_error(knw_build_record(NULL, "fresh_default"), "1 of 2 log rows carry no cut token: not one build")
  lg$token_cut[5] <- "cut-full-top"
  # a set-aside run that started after the kept one began is link writing after the build: refused, not set aside
  lg$t[1] <- 12
  expect_error(knw_build_record(NULL, "fresh_default"), "run old logged at or after the run log_recompute names")
  lg$t[1] <- 1
  # rows with no run id are set aside under that name
  lg$run_uid[1:3] <- NA
  expect_match(knw_build_record(NULL, "fresh_default")$line, "log rows of run \\(no run id\\) set aside")
  lg$run_uid[1:3] <- "old"
  # no run log_recompute names is in `log`, and `log` holds two runs: which one is the build is not known, so refused
  rec_runs <- "recompute_id"
  expect_error(knw_build_record(NULL, "fresh_default"), "log holds runs new, old: not one build")
  rec_runs <- "new"
  # link's four-group proofs: `log` and `log_recompute` carry different run ids, so every `log` row is read and none
  # is set aside
  rec_runs <- "proof_recompute"
  lg$run_uid <- c(rep("proof", 5))
  lg$token_cut[1:3] <- "cut-full-top"
  lg$token_acc[1:3] <- "acc-v5"
  r <- knw_build_record(NULL, "fresh_default")
  expect_identical(r$log_run_uid, "proof")
  expect_identical(r$tokens[["cut"]], "cut-full-top")
  expect_false(grepl("set aside", r$line))
  expect_identical(.knw_build_log_runs(NULL, "fresh_default")$aside, character())
  # and there a row without a token is refused over the whole log, as before
  lg$token_cut[1] <- NA
  expect_error(knw_build_record(NULL, "fresh_default"), "1 of 5 log rows carry no cut token")
  # a run id that is not an identifier never reaches the array literal
  lg$run_uid <- c(rep("new", 4), "x\",y")
  lg$t <- 1:5
  rec_runs <- c("new", "x\",y")
  expect_error(.knw_build_log_runs(NULL, "fresh_default"), "not a run id")
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
