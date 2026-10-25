suppressPackageStartupMessages(library(dplyr))
for (sp in strsplit(Sys.getenv("KEYS"), ",")[[1]]) {
  t <- readr::read_csv(sprintf("data/tune/%s_tune.csv", sp), show_col_types = FALSE)
  cat("\n=====", sp, "rules", nrow(t), "\n")
  best <- t[which.min(t$dev_heldout), ]
  r <- t[t$in_region, ]
  cat("best", best$rule, best$dev_heldout, " region n", nrow(r), " shapes:\n")
  print(as.data.frame(r %>% count(size_var, has_exc = !is.na(exc_q))))
  cat("size values in region:", sort(unique(r$size_min[r$size_var == "mad"])), "| width:", sort(unique(r$size_min[r$size_var == "width"])), "\n")
  cat("grad in region:", sort(unique(r$grad_max)), "\n")
  cat("Q in region:", sort(unique(r$exc_q)), " D:", sort(unique(r$exc_d)), "\n")
  cat("departures in region:"); print(table(r$departures)); cat("departures_flow:"); print(table(r$departures_flow))
  prof <- function(v) as.data.frame(t %>% group_by(.data[[v]]) %>% summarise(ddev = min(ddev_best), se = se_diff[which.min(ddev_best)], n_region = sum(in_region), .groups = "drop") %>% arrange(ddev))
  cat("-- size profile\n"); print(as.data.frame(t %>% group_by(size_var, size_min) %>% summarise(ddev = min(ddev_best), se = se_diff[which.min(ddev_best)], n_region = sum(in_region), .groups = "drop") %>% arrange(ddev)))
  cat("-- grad profile\n"); print(prof("grad_max"))
  cat("-- Q profile\n"); print(prof("exc_q"))
  cat("-- D profile\n"); print(prof("exc_d"))
  cat("-- best rule without exception:\n"); print(as.data.frame(t %>% filter(is.na(exc_q)) %>% slice_min(dev_heldout, n = 1) %>% select(rule, ddev_best, se_diff, in_region)))
  cat("-- best width rule:\n"); print(as.data.frame(t %>% filter(size_var == "width") %>% slice_min(dev_heldout, n = 1) %>% select(rule, ddev_best, se_diff, in_region)))
  cat("-- default, default flow form, link_tuned, picks:\n")
  print(as.data.frame(t %>% filter(is_default | departures_flow == 0 | is_link_tuned | recommended | recommended_flow | pick | pick_flow) %>%
    select(rule, dev_heldout, ddev_best, se_diff, in_region, is_default, departures_flow, is_link_tuned, recommended, recommended_flow, boot_rec_share, boot_rec_share_flow, boot_region_share, n_in, n_detect_in, raw_rate_in, raw_rate_out)))
  r2 <- t[t$ddev_best <= 1.96 * t$se_diff | t$ddev_best == 0, ]
  cat("1.96 region n", nrow(r2), "; default in it:", any(r2$is_default), "; default ddev/se:", t$ddev_best[t$is_default] / t$se_diff[t$is_default], "\n")
  cat("-- best at each gradient (ddev, se, region n, boot share):\n")
  print(as.data.frame(t %>% group_by(grad_max) %>% summarise(best = rule[which.min(dev_heldout)], ddev = min(ddev_best), se = se_diff[which.min(dev_heldout)], n_region = sum(in_region), boot = sum(boot_rec_share), boot_flow = sum(boot_rec_share_flow), .groups = "drop")))
  cat("-- bootstrap: share of resamples recommending each value (width start | flow start)\n")
  for (v in c("size_var", "size_min", "grad_max", "exc_q", "exc_d")) {
    s <- t %>% group_by(.data[[v]]) %>% summarise(share = sum(boot_rec_share), share_flow = sum(boot_rec_share_flow), .groups = "drop") %>% arrange(-share)
    cat(v, ":", paste(sprintf("%s=%.3f|%.3f", s[[1]], s$share, s$share_flow), collapse = ", "), "\n")
  }
  cat("converged FALSE:", sum(!t$converged), " n_wsg_varies range:", range(t$n_wsg_varies), "\n")
}
