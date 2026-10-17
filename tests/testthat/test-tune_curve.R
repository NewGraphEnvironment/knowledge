sim <- function(seed = 3, n_wsg = 10, per = 60) {
  set.seed(seed)
  n <- n_wsg * per
  d <- data.frame(wsg = factor(rep(sprintf("W%02d", seq_len(n_wsg)), each = per)),
                  log_area = log(stats::runif(n, 20, 400)), data_set = factor(sample(c("FDS", "FDIS"), n, TRUE)),
                  era = factor(sample(c("to1994", "1995-2004", "2005on"), n, TRUE)),
                  blue_line_key = 1, downstream_route_measure = seq_len(n),
                  edge_type = 1000, mad_pick = exp(stats::runif(n, log(0.02), log(20))),
                  cw_deploy = exp(stats::runif(n, log(0.5), log(20))), fwa_gradient = stats::runif(n, 0, 0.15))
  dist <- exp(stats::runif(n, log(20), log(40000)))
  d$U <- stats::rbinom(n, 1, stats::plogis(-2 + 0.8 * log(d$mad_pick) - 10 * d$fwa_gradient - 0.3 * log(dist)))
  w <- data.frame(blue_line_key = 1, downstream_route_measure = seq_len(n), src = "pick", qmin = 3,
                  status = ifelse(dist > 30000, "none", "found"), dist_m = ifelse(dist > 30000, NA, dist))
  list(d = d, walks = knw_walk_index(w))
}

test_that("the joint curve fits, reports its held-out deviance, and rises with size", {
  s <- sim()
  pick <- data.frame(size_var = "mad", size_min = 0.5, grad_max = 0.07, exc_q = 3, exc_d = 1000)
  folds <- knowledge:::.tune_fold_of_wsg(s$d, "U", 1, 5)
  cv <- knw_tune_curve(s$d, pick, s$walks, folds)
  expect_s3_class(cv$model, "gam")
  expect_true(is.finite(cv$heldout) && cv$heldout > 0)
  expect_equal(unname(cv$dropped), c(0, 0))
  expect_named(cv$capped, c("no_walk_at_cap", "no_river_at_cap"))
  expect_equal(unname(cv$capped[["no_walk_at_cap"]]), 0)
  expect_true(cv$capped[["no_river_at_cap"]] > 0)   # the fixture's walks past 30 km found no river
  expect_setequal(unique(cv$curves$curve), c("size_mad", "gradient", "dist_to_Q3_m"))
  sz <- cv$curves[cv$curves$curve == "size_mad", ]
  expect_true(sz$rate[nrow(sz)] > sz$rate[1])
  expect_equal(cv$curves$threshold[cv$curves$curve == "gradient"][1], 0.07)
  expect_equal(cv$ref$era, "2005on")
})

test_that("a constant distance leaves size to stand alone", {
  s <- sim()
  s$walks <- knw_walk_index(data.frame(blue_line_key = 1, downstream_route_measure = seq_len(nrow(s$d)), src = "pick",
                                       qmin = 3, status = "found", dist_m = 500))
  pick <- data.frame(size_var = "mad", size_min = 0.5, grad_max = 0.07, exc_q = 3, exc_d = 1000)
  cv <- knw_tune_curve(s$d, pick, s$walks, knowledge:::.tune_fold_of_wsg(s$d, "U", 1, 5))
  expect_false(cv$dist_in_model)
  expect_true(is.finite(cv$heldout))
})

test_that("a pick without an exception reads distance to the default river size, and NA sizes are counted", {
  s <- sim()
  s$walks <- knw_walk_index(data.frame(blue_line_key = 1, downstream_route_measure = seq_len(nrow(s$d)), src = "pick",
                                       qmin = 10, status = "found", dist_m = stats::runif(nrow(s$d), 20, 20000)))
  s$d$cw_deploy[1:7] <- NA
  pick <- data.frame(size_var = "width", size_min = 1.5, grad_max = 0.0549, exc_q = NA, exc_d = NA)
  folds <- knowledge:::.tune_fold_of_wsg(s$d, "U", 1, 5)
  cv <- knw_tune_curve(s$d, pick, s$walks, folds)
  expect_equal(unname(cv$dropped[["no_size"]]), 7)
  expect_true("dist_to_Q10_m" %in% cv$curves$curve)
  expect_equal(cv$q, 10)
})

test_that("grades are 0-1, the top of the accessible network reads 1, and missing inputs are NA", {
  s <- sim()
  pick <- data.frame(size_var = "mad", size_min = 0.5, grad_max = 0.07, exc_q = 3, exc_d = 1000)
  folds <- knowledge:::.tune_fold_of_wsg(s$d, "U", 1, 5)
  cv <- knw_tune_curve(s$d, pick, s$walks, folds)
  seg <- data.frame(accessible = c(rep(TRUE, 200), rep(FALSE, 20)),
                    mad_pick = exp(stats::runif(220, log(0.02), log(20))), gradient = stats::runif(220, 0, 0.15),
                    dist_m = c(rep(NA, 110), stats::runif(110, 20, 5000)))
  seg$mad_pick[1:3] <- NA
  seg$gradient[4] <- NA
  g <- knw_grade(cv, seg)
  expect_equal(nrow(g$grades), 220)
  expect_true(all(is.na(g$grades$grade[1:4])))
  expect_equal(unname(g$dropped), c(3, 1))
  gr <- g$grades$grade[-(1:4)]
  expect_true(all(gr >= 0 & gr <= 1))
  expect_true(any(gr == 1))
  expect_true(g$reference > 0)
  expect_true(all(g$grades$grade_class[!is.na(g$grades$grade)] %in% c("0-0.2", "0.2-0.4", "0.4-0.6", "0.6-0.8", "0.8-1")))
  # a segment near a river grades at least as well as the same segment far from one
  near <- knw_grade(cv, data.frame(accessible = TRUE, mad_pick = c(0.1, 0.1), gradient = 0.02, dist_m = c(100, NA)))
  expect_true(near$grades$rate[1] >= near$grades$rate[2] || abs(near$grades$rate[1] - near$grades$rate[2]) < 1e-6)
})
