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

test_that("two re-runs are identical, and socket workers score as the main process does", {
  a <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, extra = TRUE)
  b <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, extra = TRUE)
  expect_identical(a$rules, b$rules)
  # a worker loads no package, so every function it calls must be exported to it by name
  w <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, extra = TRUE, workers = 2L)
  expect_equal(w$rules, a$rules)
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

test_that("a constant added to a held-out group's offsets changes nothing: the intercept absorbs it", {
  fam <- stats::binomial(link = "cloglog")
  # a fold whose training fit sent two nuisance terms to 13 and 14 put every held-out offset at +15 to +20
  # (GR rearing, 2026-10-23); the deviance is clamped at 1e-12 and so flat far from the minimum, and a
  # search fixed on [-30, 30] found the plateau there and scored every visit 55.3
  y <- c(rep(1L, 8), rep(0L, 69))
  eta <- seq(-1.5, 2.5, length.out = 77)
  base <- sum(knowledge:::.tune_group_dev(y, eta, fam))
  for (shift in c(-25, -12, 12, 18, 25)) {
    expect_equal(sum(knowledge:::.tune_group_dev(y, eta + shift, fam)), base, tolerance = 1e-6,
                 info = paste("shift", shift))
  }
  expect_lt(base, 8 * 55.3)
})

test_that("the intercept is the exact minimiser where both golden-section searches stopped on the clamp's plateau", {
  fam <- stats::binomial(link = "cloglog")
  dev_at <- function(y, eta, b) {
    p <- pmin(pmax(fam$linkinv(eta + b), 1e-12), 1 - 1e-12)
    sum(-2 * (y * log(p) + (1 - y) * log(1 - p)))
  }
  search_84c3c78 <- function(y, eta) stats::optimize(function(b) dev_at(y, eta, b), c(-30, 30), tol = 1e-8)$minimum
  search_ca78ca6 <- function(y, eta) {
    stats::optimize(function(b) dev_at(y, eta, b), -stats::median(eta) + c(-30, 30), tol = 1e-8)$minimum
  }
  brute <- function(y, eta) {
    bs <- seq(-max(eta) - 30, -min(eta) + 30, by = 0.001)
    min(vapply(bs, function(b) dev_at(y, eta, b), 0))
  }
  # ST rearing's fold 1 (2026-10-23): a training coefficient of 19.6 on a data set puts that data set's held-out
  # visits twenty units above the rest of their group (BABR: 108 visits, one detection, offsets 0.4 to 20.4), and
  # both searches scored the group 1,392 where its minimum is 47
  set.seed(7)
  y <- c(1L, rep(0L, 107))
  eta <- c(stats::runif(100, 0.4, 0.8), stats::runif(8, 20.0, 20.4))
  now <- sum(knowledge:::.tune_group_dev(y, eta, fam))
  expect_equal(now, brute(y, eta), tolerance = 1e-6)
  expect_lt(now, 60)
  expect_gt(dev_at(y, eta, search_84c3c78(y, eta)), 400)
  expect_gt(dev_at(y, eta, search_ca78ca6(y, eta)), 400)
  # the fold that stuck the fixed range: every offset at +15 to +20 and the minimum near -18
  y2 <- c(rep(1L, 8), rep(0L, 69))
  eta2 <- seq(15, 20, length.out = 77)
  now2 <- sum(knowledge:::.tune_group_dev(y2, eta2, fam))
  expect_equal(now2, brute(y2, eta2), tolerance = 1e-6)
  expect_lt(now2, dev_at(y2, eta2, search_84c3c78(y2, eta2)))
  # a spread past the exponent's range: the slope stays finite and the minimiser is found
  y3 <- c(1L, 1L, 0L, 0L, 0L)
  eta3 <- c(-400, -399, 400, 401, 0)
  expect_true(all(is.finite(knowledge:::.tune_group_dev(y3, eta3, fam))))
})

test_that("the group-absorbing fit is glm.fit's: coefficients, deviance, iterations, convergence and aliasing", {
  fam <- stats::binomial(link = "cloglog")
  set.seed(11)
  n <- 900
  n_g <- 12
  g <- sample.int(n_g, n, TRUE)
  d <- data.frame(wsg = factor(sprintf("W%02d", g)), log_area = log(stats::runif(n, 20, 400)),
                  data_set = factor(sample(c("FDIS", "FDS"), n, TRUE)),
                  era = factor(sample(c("to1994", "1995-2004", "2005on"), n, TRUE)))
  eta <- stats::rnorm(n_g, -2.5, 0.8)[g] + 0.4 * (d$log_area - 5) + 0.6 * (d$data_set == "FDS") - 0.3 * (d$era == "2005on")
  d$y <- stats::rbinom(n, 1, 1 - exp(-exp(eta)))
  rule <- as.numeric(stats::runif(n) < 0.6)
  dense <- function(d, rule) {
    suppressWarnings(stats::glm.fit(cbind(stats::model.matrix(~ log_area + data_set + era + wsg, d), rule = rule), d$y,
                                    family = fam, control = stats::glm.control(maxit = 100)))
  }
  fe <- function(d, rule) {
    knowledge:::.tune_glm_fe(cbind(stats::model.matrix(~ log_area + data_set + era, d)[, -1], rule = rule),
                             as.integer(d$wsg), d$y, fam)
  }
  # the era levels sort as 1995-2004 (the reference), 2005on, to1994
  cols <- c("log_area", "data_setFDS", "era2005on", "erato1994", "rule")
  expect_true(all(cols %in% names(dense(d, rule)$coefficients)))
  same <- function(m1, m2) {
    expect_equal(m2$coefficients[cols], m1$coefficients[cols], tolerance = 1e-9)
    expect_identical(is.na(m2$coefficients[cols]), is.na(m1$coefficients[cols]))
    expect_equal(m2$deviance, m1$deviance, tolerance = 1e-10)
    expect_identical(m2$converged, m1$converged)
    expect_identical(m2$iter, m1$iter)
    # the group effects: the dense fit's intercept and its contrasts
    a1 <- unname(m1$coefficients[1] + c(0, m1$coefficients[grep("^wsg", names(m1$coefficients))]))
    expect_equal(m2$alpha, a1, tolerance = 1e-8)
    expect_false(m2$fallback)
  }
  same(dense(d, rule), fe(d, rule))
  # a rule in for no training visit, and a level with no visit: zero columns both fits drop
  same(dense(d, rep(0, n)), fe(d, rep(0, n)))
  d0 <- d
  d0$era <- factor(as.character(d0$era), levels = c("to1994", "1995-2004", "2005on", "later"))
  same(dense(d0, rule), fe(d0, rule))
  # a separated data set: the coefficient runs to about 20 in both, over the same iterations
  ds <- d
  ds$y[ds$data_set == "FDS"] <- 0L
  m1 <- dense(ds, rule)
  m2 <- fe(ds, rule)
  expect_lt(m1$coefficients[["data_setFDS"]], -8)
  same(m1, m2)
  # a rule in for whole groups only is aliased with them: both drop the rule
  rg <- as.numeric(d$wsg %in% c("W03", "W07"))
  m1 <- dense(d, rg)
  m2 <- fe(d, rg)
  expect_true(is.na(m1$coefficients[["rule"]]))
  same(m1, m2)
  # no training visit in the reference era: the era dummies sum to the intercept, which the groups carry, and
  # both fits drop the last one; no fall-back (every chinook fold did, 2026-10-23)
  de <- d
  de$era <- factor(ifelse(de$era == "1995-2004", "2005on", as.character(de$era)), levels = levels(d$era))
  m1 <- dense(de, rule)
  m2 <- fe(de, rule)
  expect_true(is.na(m1$coefficients[["erato1994"]]))
  expect_false(is.na(m1$coefficients[["era2005on"]]))
  same(m1, m2)
  # a data-set level carried by one whole group: the dense fit keeps the level and drops the group, so the
  # projection asks for the dense fit
  da <- d
  da$data_set <- factor(ifelse(da$wsg == "W05", "FDS", "FDIS"))
  m2 <- fe(da, rule)
  expect_true(m2$fallback)
  expect_true(is.na(m2$coefficients[["data_setFDS"]]))
  m1 <- dense(da, rule)
  expect_false(is.na(m1$coefficients[["data_setFDS"]]))
  expect_equal(m2$deviance, m1$deviance, tolerance = 1e-10)
})

test_that("the ridge is a normal prior on the named columns: the penalised maximum, bounded where separated", {
  fam <- stats::binomial(link = "cloglog")
  set.seed(12)
  n <- 400
  n_g <- 6
  g <- sample.int(n_g, n, TRUE)
  d <- data.frame(log_area = log(stats::runif(n, 20, 400)), data_set = factor(sample(c("FDIS", "FDS"), n, TRUE)),
                  era = factor(sample(c("to1994", "2005on"), n, TRUE)))
  eta <- stats::rnorm(n_g, -2, 0.5)[g] + 0.4 * (d$log_area - 5) + 0.8 * (d$data_set == "FDS")
  d$y <- stats::rbinom(n, 1, 1 - exp(-exp(eta)))
  rule <- as.numeric(stats::runif(n) < 0.5)
  X <- cbind(stats::model.matrix(~ log_area + data_set + era, d)[, -1], rule = rule)
  ridge <- c(0, 1 / 2.5^2, 1 / 2.5^2, 0)
  m <- knowledge:::.tune_glm_fe(X, g, d$y, fam, ridge = ridge)
  expect_true(m$converged)
  # the objective the fit minimises, over every coefficient, found by a general optimiser from the fit's answer
  # shifted and from zero
  obj <- function(th) {
    e <- drop(X %*% th[1:4]) + th[4 + g]
    sum(fam$dev.resids(d$y, fam$linkinv(e), rep(1, n))) + sum(ridge * th[1:4]^2)
  }
  th0 <- c(m$coefficients, m$alpha)
  expect_equal(m$penalty, sum(ridge * m$coefficients^2))
  o1 <- stats::optim(th0 + 0.3, obj, method = "BFGS", control = list(reltol = 1e-14, maxit = 2000))
  expect_lt(abs(o1$value - obj(th0)), 1e-6)
  expect_equal(unname(o1$par[1:4]), unname(m$coefficients), tolerance = 1e-4)
  # no weight on any column is the unpenalised fit exactly
  m0 <- knowledge:::.tune_glm_fe(X, g, d$y, fam)
  expect_identical(knowledge:::.tune_glm_fe(X, g, d$y, fam, ridge = rep(0, 4)), m0)
  expect_gt(abs(m0$coefficients[["data_setFDS"]] - m$coefficients[["data_setFDS"]]), 0)
  expect_lt(abs(m0$coefficients[["data_setFDS"]] - m$coefficients[["data_setFDS"]]), 0.15)
  # a separated data set: the unpenalised coefficient runs past 8; the prior holds it to a few units, converged
  ds <- d
  ds$y[ds$data_set == "FDS"] <- 0L
  m1 <- knowledge:::.tune_glm_fe(X, g, ds$y, fam)
  m2 <- knowledge:::.tune_glm_fe(X, g, ds$y, fam, ridge = ridge)
  expect_lt(m1$coefficients[["data_setFDS"]], -8)
  expect_gt(m2$coefficients[["data_setFDS"]], -6)
  expect_lt(m2$coefficients[["data_setFDS"]], -2)
  expect_true(m2$converged)
  expect_lt(m2$iter, m1$iter)
  # a level the groups carry is not aliased under the prior: it gets 0 and the groups take it, no fall-back
  da <- X
  da[, "data_setFDS"] <- as.numeric(g == 3)
  m3 <- knowledge:::.tune_glm_fe(da, g, d$y, fam, ridge = ridge)
  expect_equal(m3$coefficients[["data_setFDS"]], 0, tolerance = 1e-10)
  expect_false(m3$fallback)
  # a zero column is NA under the prior as without it
  dz <- X
  dz[, "erato1994"] <- 0
  expect_true(is.na(knowledge:::.tune_glm_fe(dz, g, d$y, fam, ridge = ridge)$coefficients[["erato1994"]]))
  expect_error(knowledge:::.tune_glm_fe(X, g, d$y, fam, ridge = c(1, 1)), "one non-negative weight")
})

test_that("the scorer gives the same table with the groups absorbed as with one column per group", {
  expect_error(knw_tune_score(pop(), rin, grid3, "U", seed = 7, fit = "dense"), "takes no prior")
  expect_error(knw_tune_score(pop(), rin, grid3, "U", seed = 7, prior_sd = 0), "positive")
  a <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, seeds_more = 8L, extra = TRUE, fit = "dense",
                      prior_sd = Inf)
  b <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, seeds_more = 8L, extra = TRUE, fit = "fe",
                      prior_sd = Inf)
  expect_equal(b$rules, a$rules, tolerance = 1e-9)
  expect_identical(b$rules$converged, a$rules$converged)
  expect_equal(b$honest, a$honest, tolerance = 1e-9)
  expect_equal(b$seeds, a$seeds)
  # socket workers carry the solver
  w <- knw_tune_score(pop(), rin, grid3, "U", seed = 7, n_boot = 10, extra = TRUE, workers = 2L, fit = "fe",
                      prior_sd = Inf)
  expect_equal(w$rules, b$rules[names(w$rules)], tolerance = 1e-9)
  # the fall-back reaches the scorer: a data set carried by one whole group
  d <- pop()
  d$data_set <- factor(ifelse(d$wsg == "W02", "FDS", "FDIS"))
  expect_equal(knw_tune_score(d, rin, grid3, "U", seed = 7, fit = "fe", prior_sd = Inf)$rules,
               knw_tune_score(d, rin, grid3, "U", seed = 7, fit = "dense", prior_sd = Inf)$rules, tolerance = 1e-9)
  sm_a <- knw_tune_smoke(pop(), rin, grid3, "U", previous = "tuned", seed = 7, fit = "dense", prior_sd = Inf)
  sm_b <- knw_tune_smoke(pop(), rin, grid3, "U", previous = "tuned", seed = 7, prior_sd = Inf)
  expect_equal(sm_b$rules, sm_a$rules, tolerance = 1e-9)
  expect_equal(sm_b$checks, sm_a$checks, tolerance = 1e-9)
  # the prior reaches the scorer: the same picks on sound data, every coefficient a little nearer zero
  p <- knw_tune_score(pop(), rin, grid3, "U", seed = 7)
  expect_equal(p$rules$recommended, b$rules$recommended)
  expect_false(isTRUE(all.equal(p$rules$dev_heldout, b$rules$dev_heldout)))
  expect_lt(max(abs(p$rules$dev_heldout - b$rules$dev_heldout)), 2)
  sm_p <- knw_tune_smoke(pop(), rin, grid3, "U", previous = "tuned", seed = 7)
  expect_equal(sm_p$rules$coef_max_term, sm_b$rules$coef_max_term)
  expect_equal(sm_p$rules$coef_max, sm_b$rules$coef_max, tolerance = 1e-2)
})
