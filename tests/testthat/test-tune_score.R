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
