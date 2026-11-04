# grayling rearing's shape on the published tables: the best has an exception, the pick from default
# moves the width floor and drops it, the flow start picks a MAD rule
anchor_fx <- function() {
  data.frame(
    rule = c("width>=1.5|g<=0.0549|none", "width>=2|g<=0.0549|none", "mad>=0.021|g<=0.0549|none",
             "width>=1|g<=0.0549|Q50@D500", "width>=1|g<=0.0549|Q50@D1000", "width>=1|g<=0.09|none"),
    size_var = c("width", "width", "mad", "width", "width", "width"),
    size_min = c(1.5, 2, 0.021, 1, 1, 1), grad_max = c(0.0549, 0.0549, 0.0549, 0.0549, 0.0549, 0.09),
    exc_q = c(NA, NA, NA, 50, 50, NA), exc_d = c(NA, NA, NA, 500, 1000, NA),
    recommended = c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE),
    recommended_flow = c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE),
    ddev_best = c(20, 5.7, 11.6, 0, 0, 30), se_diff = c(9, 10.4, 13.9, 0, 0, 12),
    stringsAsFactors = FALSE
  )
}

test_that("a pick away from the best names the best, its distance and the parts that differ", {
  a <- knw_tune_anchor(anchor_fx())
  expect_identical(nrow(a), 1L)
  expect_identical(a$rule_recommended, "width>=2|g<=0.0549|none")
  expect_equal(c(a$recommended_ddev, a$recommended_se), c(5.7, 10.4))
  expect_identical(a$rule_best, "width>=1|g<=0.0549|Q50@D500")
  expect_identical(a$best_n, 2L)
  expect_identical(a$rec_moved, 2L)
  expect_identical(a$rec_moved_parts, "size+exception")
  expect_false(a$rec_is_best)
  expect_identical(a$rule_recommended_flow, "mad>=0.021|g<=0.0549|none")
  expect_equal(c(a$recommended_flow_ddev, a$recommended_flow_se), c(11.6, 13.9))
  expect_identical(a$flow_moved, 2L)
  expect_identical(a$flow_moved_parts, "size+exception")
  expect_identical(a$starts_apart, 1L)
  expect_identical(a$starts_apart_parts, "size")
  expect_false(a$flow_is_best)
  expect_false(a$starts_agree)
})

test_that("a pick that is the best reads 0 departures from both starts", {
  t <- anchor_fx()
  t$recommended <- t$recommended_flow <- c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE)
  a <- knw_tune_anchor(t)
  expect_identical(c(a$rec_moved, a$flow_moved, a$starts_apart), c(0L, 0L, 0L))
  expect_identical(c(a$rec_moved_parts, a$flow_moved_parts, a$starts_apart_parts), c("none", "none", "none"))
  expect_true(a$rec_is_best && a$flow_is_best && a$starts_agree)
})

test_that("a pick tied at the best but not first in grid order is the best, 0 departures away", {
  t <- anchor_fx()
  t$recommended <- c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE)
  a <- knw_tune_anchor(t)
  expect_identical(a$rule_best, "width>=1|g<=0.0549|Q50@D500")
  expect_identical(a$rec_moved, 0L)
  expect_true(a$rec_is_best)
  # against the flow pick, the exception's distance alone does not count; its presence does
  expect_identical(a$starts_apart_parts, "size+exception")
})

test_that("rules that differ only in the exception's distance depart in the exception", {
  t <- anchor_fx()[4:5, ]
  t$recommended <- c(FALSE, TRUE)
  t$recommended_flow <- c(TRUE, FALSE)
  t$ddev_best <- c(0, 3)
  a <- knw_tune_anchor(t)
  expect_identical(c(a$rec_moved, a$starts_apart), c(1L, 1L))
  expect_identical(a$rec_moved_parts, "exception")
})

test_that("a pick nearest one tied best rule counts the nearest, not the first", {
  t <- anchor_fx()
  t$ddev_best[6] <- 0
  t$recommended <- c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE)
  # width>=1.5|g<=0.0549|none is two parts from every best: size and exception, or size and gradient
  a <- knw_tune_anchor(t)
  expect_identical(a$best_n, 3L)
  expect_identical(a$rec_moved, 2L)
  t$grad_max[6] <- 0.0549
  t$rule[6] <- "width>=1|g<=0.0549|none"
  a <- knw_tune_anchor(t)
  expect_identical(a$rec_moved, 1L)
  expect_identical(a$rec_moved_parts, "size")
})

test_that("a table with no flow start leaves the flow columns NA", {
  t <- anchor_fx()
  t$recommended_flow <- NA
  a <- knw_tune_anchor(t)
  expect_true(all(is.na(a[c("rule_recommended_flow", "recommended_flow_ddev", "flow_moved", "flow_moved_parts",
                            "starts_apart", "starts_apart_parts", "flow_is_best", "starts_agree")])))
  expect_identical(a$rec_moved, 2L)
  t$recommended_flow <- NULL
  expect_identical(knw_tune_anchor(t), a)
})

test_that("a table read back as text gives the same row (the saved csv)", {
  f <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(anchor_fx(), f, row.names = FALSE, na = "")
  txt <- utils::read.csv(f, colClasses = "character", na.strings = "")
  expect_identical(knw_tune_anchor(txt), knw_tune_anchor(anchor_fx()))
})

test_that("a table without one recommended rule, or with two flow picks or no best, is refused", {
  t <- anchor_fx()
  t$recommended <- FALSE
  expect_error(knw_tune_anchor(t), "0 recommended rules")
  t <- anchor_fx()
  t$recommended_flow[1] <- TRUE
  expect_error(knw_tune_anchor(t), "2 recommended_flow rules")
  t <- anchor_fx()
  t$ddev_best[4:5] <- 1
  expect_error(knw_tune_anchor(t), "no rule at ddev_best 0")
})
