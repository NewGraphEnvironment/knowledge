test_that("one run covers fitted, no-stream-rule and too-few-groups species, and records why", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  out <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = c("CH", "KO", "BT"), stages = "rear",
                      n_boot = 10L, seeds_more = 55L, workers = 1L)
  expect_named(out, c("CH_rear", "KO_rear", "BT_rear"))
  expect_true(out$CH_rear$status %in% c("fitted", "underpowered"))
  expect_equal(nrow(out$CH_rear$score$rules), 6149)   # the default's own values are on the ladders (#68: 11 gradients)
  expect_equal(sum(out$CH_rear$score$rules$recommended), 1)
  expect_equal(sum(out$CH_rear$score$rules$recommended_flow), 1)
  expect_equal(nrow(out$CH_rear$pick_flow), 1)
  expect_true(all(out$CH_rear$score$rules$boot_rec_share_flow >= 0))
  expect_s3_class(out$CH_rear$curve$model, "gam")
  expect_equal(out$KO_rear$status, "no_stream_rule")
  expect_equal(out$BT_rear$status, "too_few_groups")
  expect_equal(unname(out$BT_rear$population[["groups"]]), 2)
})

test_that("spawning without spawner evidence is no_response, and with it fits on S", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  out <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "spawn", workers = 1L)
  expect_equal(out$CH_spawn$status, "no_response")
  set.seed(2)
  spawner <- data.frame(site_visit = s$v$site_visit, species_code = "CH",
                        S = stats::rbinom(nrow(s$v), 1, stats::plogis(-1 + log(s$v$mad_pick))))
  out <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "spawn", spawner = spawner,
                      n_boot = 5L, seeds_more = integer(), workers = 1L)
  expect_true(out$CH_spawn$status %in% c("fitted", "underpowered"))
  expect_equal(out$CH_spawn$response, "S")
  expect_equal(out$CH_spawn$score$rules$rule[out$CH_spawn$score$rules$is_default], "width>=4|g<=0.0449|none")
})

test_that("grid_args reaches knw_tune_grid: the ladder above 9 % gives 559 rules per gradient", {
  s <- sim_build()
  g8 <- c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15)
  expect_equal(nrow(knw_tune_grid(s$thr[1, ], "rear", grid_grad = g8)), 4472)
  local_mocked_bindings(knw_tune_score = function(d, rule_in, grid, ...) stop("rules=", nrow(grid)))
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear",
                            grid_args = list(grid_grad = g8)), "rules=4472")
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear"), "rules=6149")   # the 30 % ladder (#68)
})

test_that("a cached score is read back only for the grid it was scored on", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  dir <- withr::local_tempdir()
  small <- list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000)
  wider <- list(grid_grad = c(0.0549, 0.09), grid_q = 3, grid_d = 1000)
  run <- function(ga) {
    knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L,
                 seeds_more = integer(), grid_args = ga, cache_dir = dir)
  }
  first <- run(small)
  expect_equal(nrow(first$CH_rear$score$rules), 26)
  expect_true(file.exists(file.path(dir, "CH_rear_score.rds")))
  # from here a rescore errors, so a run that returns read the cache
  local_mocked_bindings(knw_tune_score = function(...) stop("rescored"))
  expect_equal(run(small)$CH_rear$score$rules$rule, first$CH_rear$score$rules$rule)
  expect_error(run(wider), "rescored")
  # the settings the score depends on are compared too (the branch review of 2026-10-25): another prior or seed is
  # another score, and a cache from before the record is read back with a message rather than thrown away
  expect_equal(first$CH_rear$score$spec$prior_sd, 2.5)
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L, seeds_more = integer(),
                            grid_args = small, cache_dir = dir, prior_sd = 5), "rescored")
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L, seeds_more = integer(),
                            grid_args = small, cache_dir = dir, seed = 55L), "rescored")
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L, seeds_more = integer(),
                            grid_args = small, cache_dir = dir, evidence_id = "another build"), "rescored")
  # a score made on another gradient is another score (#92): the record names the column the rules read
  expect_equal(first$CH_rear$score$spec$grad, "segment_gradient")
  expect_error(knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L, seeds_more = integer(),
                            grid_args = small, cache_dir = dir,
                            cols = c(grad = "fwa_gradient", width = "cw_deploy", mad = "mad_pick")), "rescored")
  # a cache from before the gradient was recorded was scored on the Atlas line's, so it is rescored too
  pre92 <- readRDS(file.path(dir, "CH_rear_score.rds"))
  pre92$spec$grad <- NULL
  saveRDS(pre92, file.path(dir, "CH_rear_score.rds"))
  expect_error(run(small), "rescored")
  saveRDS(first$CH_rear$score, file.path(dir, "CH_rear_score.rds"))
  no_spec <- readRDS(file.path(dir, "CH_rear_score.rds"))
  no_spec$spec <- NULL
  saveRDS(no_spec, file.path(dir, "CH_rear_score.rds"))
  # it was scored on the Atlas line's gradient, the only one before #92: read back for that reading alone
  expect_error(run(small), "rescored")
  expect_message(fwa_run <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L,
                                         seeds_more = integer(), grid_args = small, cache_dir = dir,
                                         cols = c(grad = "fwa_gradient", width = "cw_deploy", mad = "mad_pick")),
                 "records no settings")
  expect_equal(fwa_run$CH_rear$score$rules$rule, first$CH_rear$score$rules$rule)
  saveRDS(first$CH_rear$score, file.path(dir, "CH_rear_score.rds"))
  # a cache written before a grid column existed is rescored, not read as this grid's (it stopped 0320 on 2026-10-22)
  old_cache <- readRDS(file.path(dir, "CH_rear_score.rds"))
  old_cache$rules$departures_flow <- NULL
  old_cache$rules$is_link_tuned <- NULL
  saveRDS(old_cache, file.path(dir, "CH_rear_score.rds"))
  expect_error(run(small), "rescored")
  # link's default width moving to another value on the ladder leaves every rule string as it was, but not the
  # grid's default
  thr2 <- s$thr
  thr2$rear_channel_width_min[thr2$species_code == "CH"] <- 2
  expect_identical(knw_tune_grid(thr2[1, ], "rear", grid_grad = 0.0549, grid_q = 3, grid_d = 1000)$rule,
                   first$CH_rear$score$rules$rule)
  expect_error(knw_tune_run(s$v, s$sp, s$walks, thr2, species = "CH", stages = "rear", n_boot = 5L,
                            seeds_more = integer(), grid_args = small, cache_dir = dir), "rescored")
})

test_that("thresholds_extra puts another bundle's rule in the grid, and a species it lacks is unaffected", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  extra <- data.frame(species_code = "CH", rear_gradient_max = 0.0549, rear_channel_width_min = 1.5, rear_mad_min = 0.043,
                      spawn_gradient_max = 0.0449, spawn_channel_width_min = 4, spawn_mad_min = 0.46)
  out <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L, seeds_more = integer(),
                      workers = 1L, grid_args = list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000),
                      thresholds_extra = extra)
  r <- out$CH_rear$score$rules
  expect_equal(sum(r$is_link_tuned), 1)
  expect_equal(r$rule[r$is_link_tuned], "mad>=0.043|g<=0.0549|none")
  out2 <- knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", n_boot = 5L, seeds_more = integer(),
                       workers = 1L, grid_args = list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000),
                       thresholds_extra = extra[extra$species_code == "BT", ])
  expect_false(any(out2$CH_rear$score$rules$is_link_tuned))
})

test_that("a curve no better than no rule on held-out groups has its grades withheld", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  small <- list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000)
  run <- function() knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small,
                                 extra = FALSE, smoke = FALSE)$CH_rear
  r <- run()
  rules <- r$score$rules
  expect_equal(r$null_heldout, rules$dev_heldout[2] - rules$ddev_null[2])
  # the simulated visits all carry a size, so the curve's population is the grid's and the two no-rule scores agree
  expect_equal(nrow(r$curve$data), unname(r$score$population[["visits_modelled"]]))
  expect_equal(r$null_heldout_curve, r$null_heldout)
  expect_equal(r$grade_withheld, r$curve$heldout >= r$null_heldout_curve)
  # the gate reads the curve's own held-out deviance against no rule's, on either side
  local_mocked_bindings(knw_tune_curve = function(...) list(heldout = r$null_heldout_curve, data = r$curve$data))
  expect_true(run()$grade_withheld)
  local_mocked_bindings(knw_tune_curve = function(...) list(heldout = r$null_heldout_curve - 0.01, data = r$curve$data))
  expect_false(run()$grade_withheld)
  # no rule is scored on the curve's own visits (the branch review of 2026-10-25): a curve fitted on four visits in
  # five, scoring between no rule's deviance on those visits and on all of them, is withheld; against the grid's
  # no-rule score it would have been published, which is how bull trout spawning's grade passed the gate
  sub <- .tune_modelled(r$curve$data[seq_len(nrow(r$curve$data)) %% 5 != 0, , drop = FALSE], "U")
  null_sub <- .tune_null_heldout(sub, "U", r$score$folds, 5L)
  expect_lt(null_sub, r$null_heldout)
  mid <- (null_sub + r$null_heldout) / 2
  local_mocked_bindings(knw_tune_curve = function(...) list(heldout = mid, data = sub))
  g <- run()
  expect_equal(g$null_heldout_curve, null_sub)
  expect_true(g$grade_withheld)
  expect_false(mid >= r$null_heldout)
  local_mocked_bindings(knw_tune_curve = function(...) stop("no fit"))
  failed <- run()
  expect_equal(failed$status, "curve_failed")
  expect_false(failed$grade_withheld)
})

test_that("the gradient the rules and the curve read is link's segment gradient unless cols names another (#92)", {
  skip_if_not_installed("mgcv")
  s <- sim_build()
  small <- list(grid_grad = 0.0549, grid_q = 3, grid_d = 1000)
  cols_fwa <- c(grad = "fwa_gradient", width = "cw_deploy", mad = "mad_pick")
  expect_identical(eval(formals(knw_tune_run)$cols)[["grad"]], "segment_gradient")
  expect_identical(eval(formals(knw_rule_in)$cols)[["grad"]], "segment_gradient")
  expect_identical(eval(formals(knw_tune_curve)$cols)[["grad"]], "segment_gradient")
  run <- function(...) knw_tune_run(s$v, s$sp, s$walks, s$thr, species = "CH", stages = "rear", grid_args = small,
                                    extra = FALSE, smoke = FALSE, ...)$CH_rear
  seg <- run()
  fwa <- run(cols = cols_fwa)
  # the curve fits the named column and says which
  expect_identical(seg$curve$cols[["grad"]], "segment_gradient")
  expect_identical(fwa$curve$cols[["grad"]], "fwa_gradient")
  d <- seg$curve$data
  expect_equal(d$grad, pmin(pmax(s$v$segment_gradient[match(d$site_visit, s$v$site_visit)], 0), 0.2))
  expect_equal(fwa$curve$data$grad,
               pmin(pmax(s$v$fwa_gradient[match(fwa$curve$data$site_visit, s$v$site_visit)], 0), 0.2))
  # the rules read it: the scorer's rule_in agrees with knw_rule_in on the named column and not on the other
  got <- NULL
  local_mocked_bindings(knw_tune_score = function(d, rule_in, grid, ...) {
    got <<- list(d = d, rule_in = rule_in, grid = grid)
    stop("captured")
  })
  wi <- knw_walk_index(s$walks)
  r <- data.frame(size_var = "mad", size_min = 0.28, grad_max = 0.0549, exc_q = NA_real_, exc_d = NA_real_)
  expect_error(run(), "captured")
  expect_identical(got$rule_in(got$d, r), knw_rule_in(got$d, r, walks = wi))
  expect_false(identical(got$rule_in(got$d, r), knw_rule_in(got$d, r, walks = wi, cols = cols_fwa)))
  expect_error(run(cols = cols_fwa), "captured")
  expect_identical(got$rule_in(got$d, r), knw_rule_in(got$d, r, walks = wi, cols = cols_fwa))
  # a column the visits lack is refused before any work
  v2 <- s$v
  v2$segment_gradient <- NULL
  expect_error(knw_tune_run(v2, s$sp, s$walks, s$thr, species = "CH", stages = "rear"), "segment_gradient")
})
