pop_s <- function(n_wsg = 8, per = 40, seed = 1) {
  set.seed(seed)
  d <- data.frame(wsg = factor(rep(sprintf("W%02d", seq_len(n_wsg)), each = per)),
                  log_area = log(stats::runif(n_wsg * per, 20, 400)), data_set = factor("FDIS"),
                  era = factor(sample(c("to1994", "2005on"), n_wsg * per, replace = TRUE)),
                  size = stats::runif(n_wsg * per, 0.05, 3))
  d$U <- stats::rbinom(nrow(d), 1, stats::plogis(-2.5 + 2 * (d$size > 0.5)))
  d
}
grid_s <- data.frame(rule = c("default", "tuned", "loose"), size_var = "mad", size_min = c(0.1, 0.5, 0.05),
                     grad_max = 0.05, exc_q = NA, exc_d = NA, departures = c(0L, 1L, 1L),
                     is_default = c(TRUE, FALSE, FALSE), is_link_tuned = c(FALSE, FALSE, TRUE))
rin_s <- function(d, r) d$size >= r$size_min

# the intercept search as committed at 84c3c78: a range fixed on [-30, 30], which finds the clamp's plateau
# when a fold's offsets are large (GR rearing, 2026-10-23; #84)
group_dev_84c3c78 <- function(y, eta, fam = stats::binomial(link = "cloglog"), bound = 30) {
  dev_at <- function(b) {
    p <- pmin(pmax(fam$linkinv(eta + b), 1e-12), 1 - 1e-12)
    -2 * (y * log(p) + (1 - y) * log(1 - p))
  }
  b <- stats::optimize(function(b) sum(dev_at(b)), c(-bound, bound), tol = 1e-8)$minimum
  dev_at(b)
}

test_that("the smoke run scores no rule, default, link's tuned row and the previous pick, and passes on sound data", {
  sm <- knw_tune_smoke(pop_s(), rin_s, grid_s, "U", previous = "tuned", seed = 1)
  expect_equal(sm$rules$role, c("no_rule", "default", "link_tuned", "previous"))
  expect_equal(sm$rules$rule, c("none", "default", "loose", "tuned"))
  expect_equal(sm$checks$check, c("null_ratio", "clamp", "behind_null", "coef"))
  expect_true(sm$pass)
  expect_true(all(sm$checks$pass))
  expect_equal(sm$rules$ddev_null[1], 0)
  expect_equal(sm$rules$dev_heldout[-1] - sm$null_heldout, sm$rules$ddev_null[-1])
  expect_true(all(sm$rules$n_clamp == 0))
  expect_true(all(sm$rules$converged))
  expect_equal(sm$checks$value[sm$checks$check == "null_ratio"], sm$null_heldout / sm$null_insample)
  expect_equal(sm$checks$limit[sm$checks$check == "behind_null"], sm$null_heldout)
  expect_length(sm$lines, 5 + 3)
  expect_match(sm$lines[2], "null_ratio: .* pass$")
  expect_equal(unname(sm$population[["groups"]]), 8)
  # the smoke scores exactly as the full scorer does on the same seed
  s <- knw_tune_score(pop_s(), rin_s, grid_s, "U", seed = 1)
  expect_equal(sm$rules$dev_heldout[sm$rules$role == "default"], s$rules$dev_heldout[s$rules$is_default])
  expect_equal(sm$rules$dev_heldout[sm$rules$role == "previous"], s$rules$dev_heldout[s$rules$rule == "tuned"])
  expect_equal(sm$null_heldout, s$rules$dev_heldout[1] - s$rules$ddev_null[1])
})

test_that("a previous pick with default's in/out is one fit, and one outside the grid is refused", {
  g <- grid_s
  g$is_link_tuned <- FALSE
  sm <- knw_tune_smoke(pop_s(), rin_s, g, "U", previous = "default", seed = 1)
  expect_equal(sm$rules$role, c("no_rule", "default", "previous"))
  expect_equal(sm$rules$dev_heldout[2], sm$rules$dev_heldout[3])
  expect_match(sm$lines[1], "3 rules, 2 fits")
  expect_error(knw_tune_smoke(pop_s(), rin_s, g, "U", previous = "mad>=9|g<=0.3|none", seed = 1), "not in the grid")
  expect_error(knw_tune_smoke(pop_s(), rin_s, g, "U", previous = NA_character_, seed = 1))
})

test_that("the null_ratio and clamp checks fire on the 84c3c78 search and pass on the current one", {
  # the mechanism the probe found: a held-out group whose offsets from training sit far from zero. Area is
  # informative in seven groups, and the eighth has one area far outside their range and a rate of its own,
  # so its held-out offsets are about +15 while the training fit's coefficients are ordinary
  d <- pop_s()
  far <- d$wsg == "W08"
  d$log_area[far] <- 40
  set.seed(3)
  d$U[!far] <- stats::rbinom(sum(!far), 1, stats::plogis(-4.5 + 0.5 * d$log_area[!far] + 1.5 * (d$size[!far] > 0.5)))
  d$U[far] <- stats::rbinom(sum(far), 1, 0.3)
  # a default that leaves out a few visits with no detection separates on the rule term (15.7 on fold 1 with
  # size >= 0.1), which the coef check reads as it should; this test is about the search, so default leaves
  # out more
  g <- grid_s
  g$size_min[1] <- 0.3
  now <- knw_tune_smoke(d, rin_s, g, "U", previous = "tuned", seed = 1)
  expect_true(now$pass, info = paste(now$lines, collapse = "\n"))
  expect_true(all(now$rules$n_clamp == 0))
  local_mocked_bindings(.tune_group_dev = group_dev_84c3c78)
  old <- knw_tune_smoke(d, rin_s, g, "U", previous = "tuned", seed = 1)
  expect_false(old$pass)
  expect_equal(old$checks$check[!old$checks$pass], c("null_ratio", "clamp"))
  expect_gt(old$checks$value[old$checks$check == "null_ratio"], 2)
  expect_true(all(old$rules$n_clamp > 0))
  expect_true(all(old$rules$dev_visit_max > 55.26))
  expect_true(all(now$rules$dev_visit_max < 55))
  expect_match(old$lines[2], "FAIL$")
  expect_match(old$lines[3], "FAIL$")
  # the training fits are the same under either search, so the coefficient check reads the same numbers
  expect_equal(old$rules$coef_max, now$rules$coef_max)
})

test_that("the behind_null and coef checks fire on what the fits return", {
  n <- nrow(pop_s())
  fake <- function(x, folds, fit = "fe", prior_sd = 2.5) {
    in_rule <- any(x)
    list(dev = rep(if (in_rule) 3 else 1, n), ok = TRUE,
         coef = lapply(1:5, function(k) c(log_area = 0.2, rule = if (in_rule) 13 else NA_real_)))
  }
  local_mocked_bindings(.tune_score_one = fake)
  sm <- knw_tune_smoke(pop_s(), rin_s, grid_s, "U", seed = 1)
  expect_equal(sm$checks$check[!sm$checks$pass], c("behind_null", "coef"))
  expect_equal(sm$checks$value[sm$checks$check == "behind_null"], 2 * n)
  expect_equal(sm$checks$limit[sm$checks$check == "behind_null"], n)
  expect_equal(sm$checks$value[sm$checks$check == "coef"], 13)
  expect_equal(sm$rules$coef_max_term[-1], rep("rule", 2))
  expect_match(sm$lines[5], "coef: rule 13.00 on fold 1 of default .*FAIL$")
  # the limits are arguments
  sm2 <- knw_tune_smoke(pop_s(), rin_s, grid_s, "U", seed = 1, coef_max = 20)
  expect_equal(sm2$checks$check[!sm2$checks$pass], "behind_null")
})

test_that("knw_tune_run smokes every key first and refuses the grid on a failure; smoke_only scores nothing", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  small <- list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000)
  so <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = c("CH", "KO", "BT"), stages = "rear", grid_args = small,
                     smoke_only = TRUE, previous = c(CH_rear = "mad>=0.28|g<=0.0549|none"))
  expect_equal(so$CH_rear$status, "smoke")
  expect_null(so$CH_rear$score)
  expect_true(so$CH_rear$smoke$pass)
  expect_equal(so$CH_rear$smoke$rules$role, c("no_rule", "default", "previous"))
  expect_equal(so$KO_rear$status, "no_stream_rule")
  expect_equal(so$BT_rear$status, "too_few_groups")
  expect_null(so$BT_rear$smoke)
  # a previous pick for another key is not CH's
  so2 <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small,
                      smoke_only = TRUE, previous = c(BT_rear = "mad>=0.28|g<=0.0549|none"))
  expect_equal(so2$CH_rear$smoke$rules$role, c("no_rule", "default"))
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small,
                            previous = "mad>=0.28|g<=0.0549|none"), "named")
  # a failed check stops the run before any grid is scored
  local_mocked_bindings(knw_tune_score = function(...) stop("scored"))
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small),
               "scored")
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small,
                            smoke_args = list(coef_max = 0.01)),
               "smoke run failed on CH_rear \\(coef\\).*Nothing was scored")
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small,
                            smoke = FALSE), "scored")
})

test_that("extra = FALSE is the development setting: no bootstrap, nested selection or extra seeds", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  small <- list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000)
  out <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small, extra = FALSE)
  expect_true(out$CH_rear$status %in% c("fitted", "underpowered"))
  expect_null(out$CH_rear$score$honest)
  expect_null(out$CH_rear$score$seeds)
  expect_false("boot_rec_share" %in% names(out$CH_rear$score$rules))
  expect_s3_class(out$CH_rear$smoke$checks, "data.frame")
})
