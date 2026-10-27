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

test_that("every code literal the register names carries the register's value wherever it occurs", {
  skip_if_not(has_src, "no source-tree R/, scripts/ and inst/ (installed package)")
  r <- reg()
  n <- 0L
  for (i in seq_len(nrow(r))) {
    for (w in grep("^code:", strsplit(r$where[i], ";", fixed = TRUE)[[1]], value = TRUE)) {
      got <- .knw_where_values(w, root)
      expect_gt(length(got), 0, label = paste(r$key[i], w))
      expect_true(all(got == paste(strsplit(r$value[i], ";", fixed = TRUE)[[1]], collapse = ", ")),
                  info = paste(r$key[i], w, "holds", paste(unique(got), collapse = " / ")))
      n <- n + 1L
    }
  }
  expect_gt(n, 0)
})

test_that("the scorer's region is the register's number of SEs from the best", {
  # .tune_sel fixes the region in its body, where no fn: row can see it. Two rules sit 0.9 and 1.1 SE from the
  # best, so any multiplier outside (0.9, 1.1) changes the region the scorer returns.
  r <- reg()
  k <- .knw_setting_parse(r$value[r$key == "se_region"])
  base <- c(10, 11, 9, 12)
  at <- function(ratio) {
    a <- 1:4
    a + (ratio * sqrt(4) * stats::sd(a) - sum(a)) / 4
  }
  ratios <- c(0, 0.9, 1.1)
  sw <- cbind(base, base + at(0.9), base + at(1.1))
  s <- .tune_sel(sw, 1:4)
  expect_equal(unname((s$tot - s$tot[s$best]) / pmax(s$se, 1e-12))[-1], ratios[-1], tolerance = 1e-9)
  expect_identical(unname(s$region), ratios <= k)
})

test_that("the 1:50k check's zero run is the code's length less its 3-digit basin", {
  r <- reg()
  expect_identical(as.numeric(r$value[r$key == "ws50_code_zeros"]), as.numeric(r$value[r$key == "ws50_code_length"]) - 3)
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
  expect_false(.knw_where_holds("code:scripts/0230-fdis-load.R:year < {value} |", "1949", root))
  expect_length(.knw_where_values("code:scripts/0230-fdis-load.R:no such text {value} here", root), 0)
  expect_error(.knw_where_parse("code:R/grade.R:ends with {value}"), "followed by more text")
})
