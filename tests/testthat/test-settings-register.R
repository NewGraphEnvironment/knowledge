# The settings register documents every number that shapes a tuning result; the code keeps the values. These tests
# hold the two together (#93): a value changed in code without the register, or in the register without the code,
# fails here. They cannot see a new number added to code with no row.

reg <- function() {
  utils::read.csv(system.file("method", "settings.csv", package = "knowledge"),
                  colClasses = "character", na.strings = character())
}
root <- testthat::test_path("..", "..")
has_src <- dir.exists(file.path(root, "scripts"))

test_that("the register and the pipeline table ship with the package", {
  expect_true(nzchar(system.file("method", "settings.csv", package = "knowledge")))
  expect_true(nzchar(system.file("method", "pipeline.csv", package = "knowledge")))
})

test_that("every register row is well formed and names a step of the pipeline", {
  r <- reg()
  steps <- utils::read.csv(system.file("method", "pipeline.csv", package = "knowledge"))$step
  expect_false(anyDuplicated(r$key) > 0)
  expect_true(all(as.integer(r$step) %in% steps), info = paste(r$key[!as.integer(r$step) %in% steps], collapse = ", "))
  expect_true(all(r$source %in% c("source", "convention", "inherited", "measured")))
  expect_true(all(r$tested %in% c("yes", "no")))
  expect_true(all(nzchar(r$value) & nzchar(r$where)))
  for (w in unlist(strsplit(r$where, ";", fixed = TRUE))) expect_no_error(.knw_where_parse(w))
})

test_that("every function default the register names holds the register's value", {
  r <- reg()
  n <- 0L
  for (i in seq_len(nrow(r))) {
    for (w in grep("^fn:", strsplit(r$where[i], ";", fixed = TRUE)[[1]], value = TRUE)) {
      expect_identical(.knw_where_value(w), .knw_setting_parse(r$value[i]), info = paste(r$key[i], w))
      n <- n + 1L
    }
  }
  expect_gt(n, 0)
})

test_that("every script constant the register names holds the register's value", {
  skip_if_not(has_src, "no source-tree scripts/ (installed package)")
  r <- reg()
  n <- 0L
  for (i in seq_len(nrow(r))) {
    for (w in grep("^script:", strsplit(r$where[i], ";", fixed = TRUE)[[1]], value = TRUE)) {
      expect_identical(.knw_where_value(w, root), .knw_setting_parse(r$value[i]), info = paste(r$key[i], w))
      n <- n + 1L
    }
  }
  expect_gt(n, 0)
})

test_that("every code literal the register names occurs in its file with the register's value", {
  skip_if_not(has_src, "no source-tree R/, scripts/ and inst/ (installed package)")
  r <- reg()
  n <- 0L
  for (i in seq_len(nrow(r))) {
    for (w in grep("^code:", strsplit(r$where[i], ";", fixed = TRUE)[[1]], value = TRUE)) {
      expect_gte(.knw_where_count(w, r$value[i], root), 1, label = paste(r$key[i], w))
      n <- n + 1L
    }
  }
  expect_gt(n, 0)
})

test_that("the scorer's region is the register's number of SEs from the best", {
  # .tune_sel fixes the region in its body, where no fn: row can see it; a toy score matrix pins it
  r <- reg()
  k <- .knw_setting_parse(r$value[r$key == "se_region"])
  sw <- matrix(c(10, 9, 14, 12, 11, 15, 8, 9.5, 13), nrow = 3, byrow = TRUE)   # rule 1 is 0.5 from the best, 2.5 SE
  s <- .tune_sel(sw, 1:3)
  expect_identical(s$region, unname(s$tot - s$tot[s$best] <= k * s$se))
  expect_false(all(s$region))
  expect_true(any(s$region[-s$best]))
})

test_that("every setting #93 names has a row", {
  need <- c("snap_search", "snap_limit", "ws50_code_length", "flow_far_low", "prior_sd", "se_region", "se_strict",
            "folds", "seeds_more", "bridge_distance", "bridge_gradient", "walk_q", "grade_ref", "gradient_col")
  expect_true(all(need %in% reg()$key), info = paste(setdiff(need, reg()$key), collapse = ", "))
})

test_that("a where naming nothing is an error, not a pass", {
  expect_error(.knw_where_value("fn:knw_tune_run:no_such_arg"), "no argument")
  expect_error(.knw_where_value("fn:no_such_fn:x"), "no function")
  expect_error(.knw_where_parse("bogus:x:y"), "unknown kind")
  skip_if_not(has_src, "no source-tree scripts/ (installed package)")
  expect_error(.knw_where_value("script:scripts/0230-fdis-load.R:no_such_name", root), "0 times")
  expect_error(.knw_where_value("script:scripts/0320-tune-run.R:link_sha", root), "2 times")
  expect_error(.knw_where_value("script:scripts/no_such_script.R:x", root), "no script")
  expect_identical(.knw_where_count("code:scripts/0230-fdis-load.R:year < {value} |", "1949", root), 0L)
})
