sim_build <- function(seed = 11, n_wsg = 8, per = 50) {
  set.seed(seed)
  n <- n_wsg * per
  wsg <- rep(sprintf("W%02d", seq_len(n_wsg)), each = per)
  v <- data.frame(
    site_visit = sprintf("v%04d", seq_len(n)), watershed_group_code = wsg, blue_line_key = 1,
    downstream_route_measure = seq_len(n), edge_type = 1000L, wb_river = FALSE, wb_wetland = FALSE, wb_lake = FALSE,
    area_m2 = stats::runif(n, 20, 400), year = sample(1985:2015, n, TRUE), data_set = sample(c("FDS", "FDIS"), n, TRUE),
    fwa_gradient = stats::runif(n, 0, 0.12), cw_deploy = exp(stats::runif(n, log(0.5), log(15))),
    mad_pick = exp(stats::runif(n, log(0.02), log(20))), barrier_dnstr_ch = FALSE, barrier_dnstr_ko = FALSE,
    barrier_dnstr_bt = FALSE, stringsAsFactors = FALSE
  )
  p <- stats::plogis(-2.5 + 1.2 * log(v$mad_pick) - 12 * v$fwa_gradient)
  present_ch <- stats::rbinom(n, 1, p) == 1
  sp <- rbind(
    data.frame(site_visit = v$site_visit, species_code = "CH", present = present_ch,
               status = ifelse(present_ch, "present", "absent"), in_range = TRUE),
    data.frame(site_visit = v$site_visit, species_code = "KO", present = FALSE, status = "absent", in_range = TRUE),
    data.frame(site_visit = v$site_visit, species_code = "BT", present = c(TRUE, rep(FALSE, n - 1)),
               status = c("present", rep("absent", n - 1)), in_range = wsg %in% c("W01", "W02"))
  )
  dist <- exp(stats::runif(n, log(50), log(30000)))
  walks <- do.call(rbind, lapply(c(1, 3, 5, 10, 20, 30, 50), function(q) {
    data.frame(blue_line_key = 1, downstream_route_measure = seq_len(n), src = "pick", qmin = q,
               status = "found", dist_m = dist * q / 3)
  }))
  thr <- data.frame(species_code = c("CH", "KO", "BT"), rear_gradient_max = c(0.0549, NA, 0.1049),
                    rear_channel_width_min = c(1.5, 1.5, 1.5), rear_mad_min = c(0.28, NA, 0.021),
                    spawn_gradient_max = c(0.0449, 0.0249, 0.0549), spawn_channel_width_min = c(4, 2, 2),
                    spawn_mad_min = c(0.46, 0.041, 0.041))
  list(v = v, sp = sp, walks = walks, thr = thr)
}

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
