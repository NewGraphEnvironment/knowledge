pop <- function(n_wsg = 8, per = 40, seed = 1) {
  set.seed(seed)
  d <- data.frame(wsg = factor(rep(sprintf("W%02d", seq_len(n_wsg)), each = per)),
                  log_area = log(stats::runif(n_wsg * per, 20, 400)), data_set = factor("FDIS"),
                  era = factor(sample(c("to1994", "2005on"), n_wsg * per, replace = TRUE)),
                  size = stats::runif(n_wsg * per, 0.05, 3))
  d$U <- stats::rbinom(nrow(d), 1, stats::plogis(-2.5 + 2 * (d$size > 0.5)))
  d
}
grid3 <- data.frame(rule = c("default", "tuned", "loose"), size_var = "mad", size_min = c(0.1, 0.5, 0.05),
                    grad_max = 0.05, exc_q = NA, exc_d = NA, departures = c(0L, 1L, 1L), is_default = c(TRUE, FALSE, FALSE))
rin <- function(d, r) d$size >= r$size_min

test_that("the rule that generated the data scores best and the region is reported", {
  s <- knw_tune_score(pop(), rin, grid3, "U", seed = 1)
  r <- s$rules
  expect_equal(nrow(r), 3)
  expect_equal(r$rule[r$ddev_best == 0], "tuned")
  expect_true(all(r$dev_heldout > 0))
  expect_true(r$in_region[r$rule == "tuned"])
  expect_equal(sum(r$pick), 1)
  expect_equal(sum(r$recommended), 1)
  expect_equal(unname(s$population[["groups"]]), 8)
  expect_equal(length(s$folds), 8)
  expect_setequal(unique(unname(s$folds)), 1:5)
})

test_that("identical in/out patterns are one fit, and a visit-wide rule counts no varying group", {
  g <- rbind(grid3, data.frame(rule = "same_as_default", size_var = "mad", size_min = 0.1, grad_max = 0.05,
                               exc_q = NA, exc_d = NA, departures = 1L, is_default = FALSE))
  s <- knw_tune_score(pop(), rin, g, "U", seed = 1)
  expect_equal(unname(s$population[["patterns"]]), 3)
  expect_equal(s$rules$dev_heldout[1], s$rules$dev_heldout[4])
  expect_equal(s$rules$n_wsg_varies[s$rules$rule == "loose"], 0)
})

test_that("groups with one outcome are left out and counted", {
  d <- pop()
  d$U[d$wsg == "W01"] <- 0L
  s <- knw_tune_score(d, rin, grid3, "U", seed = 1)
  expect_equal(unname(s$population[["groups"]]), 7)
  expect_equal(unname(s$population[["visits_in"]]), nrow(d))
  expect_equal(unname(s$population[["visits_modelled"]]), nrow(d) - 40)
})

test_that("the recommended rule respects the distance floor", {
  g <- rbind(grid3, data.frame(rule = "near", size_var = "mad", size_min = 0.5, grad_max = 0.05,
                               exc_q = 3, exc_d = 100, departures = 1L, is_default = FALSE))
  # the exception never fires here, so "near" ties "tuned" exactly and sorts after it by score tie
  s <- knw_tune_score(pop(), rin, g, "U", seed = 1, d_floor = 200)
  rec <- s$rules$rule[s$rules$recommended]
  expect_false(rec == "near")
})

test_that("extra gives the bootstrap, nested selection and extra seeds", {
  s <- knw_tune_score(pop(), rin, grid3, "U", seed = 1, n_boot = 20, seeds_more = 2:3, extra = TRUE)
  expect_true(all(c("boot_region_share", "boot_rec_share") %in% names(s$rules)))
  expect_equal(sum(s$rules$boot_rec_share), 1)
  expect_equal(nrow(s$honest), 5)
  expect_equal(nrow(s$seeds), 2)
  expect_equal(nrow(s$boot_recs), 20)
})

test_that("too few groups for the folds is refused", {
  expect_error(knw_tune_score(pop(n_wsg = 3), rin, grid3, "U", seed = 1), "3 groups")
})

test_that("two re-runs are identical", {
  a <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, extra = TRUE)
  b <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, extra = TRUE)
  expect_identical(a$rules, b$rules)
})

test_that("a grid with departures_flow gives a second pick from the flow start; without it the columns are NA", {
  s <- knw_tune_score(pop(), rin, grid3, "U", seed = 1)
  expect_true(all(is.na(s$rules$pick_flow)) && all(is.na(s$rules$recommended_flow)))
  g <- grid3
  g$departures_flow <- c(1L, 0L, 1L)   # the "tuned" rule is the flow start
  s2 <- knw_tune_score(pop(), rin, g, "U", seed = 1, extra = TRUE, n_boot = 5L)
  expect_equal(sum(s2$rules$pick_flow), 1)
  expect_equal(sum(s2$rules$recommended_flow), 1)
  expect_equal(s2$rules$rule[s2$rules$recommended_flow], "tuned")
  expect_equal(sum(s2$rules$boot_rec_share_flow), 1)
  # the region is the same whichever start reads it
  expect_identical(s2$rules$in_region, s$rules$in_region)
})

test_that("a held-out group's intercept is fit where glm.fit's IRLS runs away", {
  fam <- stats::binomial(link = "cloglog")
  # a held-out fold of the joint curve: detections at a middling offset, non-detections spread far below
  y <- c(rep(1L, 12), rep(0L, 154))
  eta <- c(rep(-2, 12), seq(-13, -1.7, length.out = 154))
  a <- suppressWarnings(stats::glm.fit(matrix(1, length(y), 1), y, family = fam, offset = eta,
                                      control = stats::glm.control(maxit = 100)))
  p_glm <- pmin(pmax(a$fitted.values, 1e-12), 1 - 1e-12)
  dev_glm <- sum(-2 * (y * log(p_glm) + (1 - y) * log(1 - p_glm)))
  dev_null <- {
    pn <- mean(y)
    sum(-2 * (y * log(pn) + (1 - y) * log(1 - pn)))
  }
  expect_true(all(a$fitted.values[y == 1L] < 1e-12)) # the defect: every detection's chance under 1e-12
  expect_gt(dev_glm, dev_null)
  dv <- knowledge:::.tune_group_dev(y, eta, fam)
  expect_length(dv, length(y))
  expect_true(all(is.finite(dv)))
  expect_lt(sum(dv), dev_null)
  # where IRLS is safe the two agree
  y2 <- c(rep(1L, 5), rep(0L, 20))
  eta2 <- seq(-3, -1, length.out = 25)
  a2 <- stats::glm.fit(matrix(1, 25, 1), y2, family = fam, offset = eta2)
  dev2 <- sum(-2 * (y2 * log(a2$fitted.values) + (1 - y2) * log(1 - a2$fitted.values)))
  expect_equal(sum(knowledge:::.tune_group_dev(y2, eta2, fam)), dev2, tolerance = 1e-6)
})
