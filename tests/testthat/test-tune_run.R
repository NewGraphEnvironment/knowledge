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
  expect_equal(nrow(out$CH_rear$score$rules), 2795 + 0)   # the default's own values are on 0297's ladders
  expect_equal(sum(out$CH_rear$score$rules$recommended), 1)
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
