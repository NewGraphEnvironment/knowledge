# the simulated evidence build the tune_run and tune_smoke tests share
sim_build <- function(seed = 11, n_wsg = 8, per = 50) {
  set.seed(seed)
  n <- n_wsg * per
  wsg <- rep(sprintf("W%02d", seq_len(n_wsg)), each = per)
  v <- data.frame(
    site_visit = sprintf("v%04d", seq_len(n)), watershed_group_code = wsg, blue_line_key = 1,
    downstream_route_measure = seq_len(n), edge_type = 1000L, wb_river = FALSE, wb_wetland = FALSE, wb_lake = FALSE,
    area_m2 = stats::runif(n, 20, 400), year = sample(1985:2015, n, TRUE), data_set = sample(c("FDS", "FDIS"), n, TRUE),
    segment_gradient = stats::runif(n, 0, 0.12), fwa_gradient = stats::runif(n, 0, 0.12),
    cw_deploy = exp(stats::runif(n, log(0.5), log(15))),
    mad_pick = exp(stats::runif(n, log(0.02), log(20))), barrier_dnstr_ch = FALSE, barrier_dnstr_ko = FALSE,
    barrier_dnstr_bt = FALSE, stringsAsFactors = FALSE
  )
  # use follows link's segment gradient, the one scored since #92; the Atlas line's is unrelated noise here, so a
  # run that reads the wrong column scores differently
  p <- stats::plogis(-2.5 + 1.2 * log(v$mad_pick) - 12 * v$segment_gradient)
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
