# grayling rearing's shape on the published tables: the best has an exception, the pick from default
# moves the width floor and drops it, the flow start picks a MAD rule
anchor_fx <- function() {
  data.frame(
    rule = c("width>=1.5|g<=0.0549|none", "width>=2|g<=0.0549|none", "mad>=0.021|g<=0.0549|none",
             "width>=1|g<=0.0549|Q50@D500", "width>=1|g<=0.0549|Q50@D1000", "width>=1|g<=0.09|none"),
    size_var = c("width", "width", "mad", "width", "width", "width"),
    size_min = c(1.5, 2, 0.021, 1, 1, 1), grad_max = c(0.0549, 0.0549, 0.0549, 0.0549, 0.0549, 0.09),
    exc_q = c(NA, NA, NA, 50, 50, NA), exc_d = c(NA, NA, NA, 500, 1000, NA),
    departures_flow = c(1L, 1L, 0L, 2L, 2L, 2L),
    in_region = c(FALSE, TRUE, TRUE, TRUE, TRUE, FALSE),
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
  t$in_region[c(1, 6)] <- TRUE
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
  t$departures_flow <- NA
  t$recommended_flow <- NA
  a <- knw_tune_anchor(t)
  expect_true(all(is.na(a[c("rule_recommended_flow", "recommended_flow_ddev", "flow_moved", "flow_moved_parts",
                            "flow_moved_allowed", "starts_apart", "starts_apart_parts", "flow_is_best",
                            "starts_agree")])))
  expect_identical(a$rec_moved, 2L)
  # a table from before #80 has neither column
  t$departures_flow <- t$recommended_flow <- NULL
  expect_identical(knw_tune_anchor(t), a)
})

test_that("a best under d_floor, which no pick may be, is measured beside the best a pick may be", {
  t <- anchor_fx()
  t$exc_d[4:5] <- 100
  t$exc_q[5] <- 30
  t$rule[4:5] <- c("width>=1|g<=0.0549|Q50@D100", "width>=1|g<=0.0549|Q30@D100")
  t$ddev_best[2] <- 4
  a <- knw_tune_anchor(t)
  expect_false(a$best_is_allowed)
  expect_identical(a$rule_best_allowed, "width>=2|g<=0.0549|none")
  expect_equal(a$best_allowed_ddev, 4)
  expect_identical(c(a$rec_moved, a$rec_moved_allowed), c(2L, 0L))
  expect_identical(a$rec_moved_allowed_parts, "none")
  expect_identical(c(a$flow_moved_allowed, a$starts_apart), c(1L, 1L))
  # the floor is the scorer's: at 50 m the best is allowed
  expect_true(knw_tune_anchor(t, d_floor = 50)$best_is_allowed)
  expect_true(knw_tune_anchor(anchor_fx())$best_is_allowed)
})

test_that("a best that did not converge is not allowed either, though it carries no exception", {
  t <- anchor_fx()
  t$in_region[4:5] <- FALSE
  t$ddev_best[2] <- 2
  a <- knw_tune_anchor(t)
  expect_false(a$best_is_allowed)
  expect_identical(a$rule_best, "width>=1|g<=0.0549|Q50@D500")
  expect_identical(a$rule_best_allowed, "width>=2|g<=0.0549|none")
  expect_identical(knw_tune_anchor(anchor_fx())$rule_best_allowed, knw_tune_anchor(anchor_fx())$rule_best)
})

test_that("the best a pick may be is a region rule, not a lower score outside the region", {
  # steelhead rearing's shape on the published tables: the lowest-scoring rules clear of the floor are outside the
  # region (their SE is small), so the best a pick may be scores worse than they do
  t <- anchor_fx()
  t$exc_d[4:5] <- 100
  t$ddev_best[1] <- 3
  t$se_diff[1] <- 1
  t$ddev_best[2] <- 4
  a <- knw_tune_anchor(t)
  expect_identical(a$rule_best_allowed, "width>=2|g<=0.0549|none")
  expect_identical(a$rec_moved_allowed, 0L)
  # a table whose recommended rule a pick could not be is refused
  t$in_region[2] <- FALSE
  expect_error(knw_tune_anchor(t), "outside the region or under d_floor")
})

test_that("the pick read is the recommended rule, not a pick d_floor moved it off", {
  t <- anchor_fx()
  t$exc_d[5] <- 100
  t$pick <- c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE)
  a <- knw_tune_anchor(t)
  expect_identical(a$rule_recommended, "width>=2|g<=0.0549|none")
  expect_identical(a$rec_moved, 2L)
})

test_that("a table read back as text gives the same row (the saved csv)", {
  f <- withr::local_tempfile(fileext = ".csv")
  utils::write.csv(anchor_fx(), f, row.names = FALSE, na = "")
  txt <- utils::read.csv(f, colClasses = "character", na.strings = "")
  expect_identical(knw_tune_anchor(txt), knw_tune_anchor(anchor_fx()))
})

test_that("the parts count departures as knw_tune_grid() does, from both starts", {
  thr <- data.frame(species_code = "GR", rear_gradient_max = 0.0349, rear_channel_width_min = 1.5, rear_mad_min = 0.021)
  g <- knw_tune_grid(thr, "rear", grid_mad = c(0.021, 0.5), grid_width = c(1, 1.5), grid_grad = c(0.0349, 0.09),
                     grid_q = c(5, 50), grid_d = c(500, 1000))
  d0 <- which(g$is_default)
  f0 <- which(g$departures_flow == 0L)
  expect_length(f0, 1)
  expect_identical(vapply(seq_len(nrow(g)), function(i) as.integer(sum(.knw_rule_parts(g, i, d0))), 1L), g$departures)
  expect_identical(vapply(seq_len(nrow(g)), function(i) as.integer(sum(.knw_rule_parts(g, i, f0))), 1L),
                   g$departures_flow)
})

test_that("a table without one recommended rule, or with two flow picks or no best, is refused", {
  t <- anchor_fx()
  t$recommended <- FALSE
  expect_error(knw_tune_anchor(t), "0 recommended rules")
  t <- anchor_fx()
  t$recommended_flow[1] <- TRUE
  expect_error(knw_tune_anchor(t), "2 recommended_flow rules")
  # a flow start that names no pick is refused, not read as no flow start
  t$recommended_flow <- FALSE
  expect_error(knw_tune_anchor(t), "flow start and 0 recommended_flow")
  t$recommended_flow <- NULL
  expect_error(knw_tune_anchor(t), "flow start and 0 recommended_flow")
  t <- anchor_fx()
  t$ddev_best[4:5] <- 1
  expect_error(knw_tune_anchor(t), "no rule at ddev_best 0")
})
