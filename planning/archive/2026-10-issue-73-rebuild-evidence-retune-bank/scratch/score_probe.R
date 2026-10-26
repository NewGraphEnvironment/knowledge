suppressPackageStartupMessages(pkgload::load_all(quiet = TRUE))
for (sp in c("CH", "CO")) {
  cv <- readRDS(sprintf("data/tune/%s_rear_curve.rds", sp))$curve; sc <- readRDS(sprintf("data/tune/%s_rear_score.rds", sp))
  dd <- cv$data; resp <- all.vars(formula(cv$model))[1]
  dd$mad <- exp(dd$log_size); dd$dist <- exp(dd$log_dist) - 10
  fs <- knowledge:::.tune_fold_setup(dd, resp, sc$folds, 5L)
  pats <- list(null = rep(FALSE, nrow(dd)))
  if (sp == "CH") { pats$rec <- (dd$mad >= 0.5 | dd$dist <= 1000) & dd$grad <= 0.15; pats$flow_def <- dd$mad >= 0.28 & dd$grad <= 0.0549 }
  else { pats$rec <- dd$mad >= 0.03 & dd$grad <= 0.04; pats$flow_def <- dd$mad >= 0.03 & dd$grad <= 0.0549 }
  for (nm in names(pats)) {
    r <- knowledge:::.tune_score_one(pats[[nm]], fs)
    cat(sp, nm, "sum dev", round(sum(r$dev), 2), "ok", r$ok, " visits with dev > 20:", sum(r$dev > 20), " pinned (>55):", sum(r$dev > 55), "\n")
  }
  t <- readr::read_csv(sprintf("data/tune/%s_rear_tune.csv", sp), show_col_types = FALSE)
  cat("  table: null", unique(round(t$dev_heldout + t$ddev_null, 2))[1], " rec", t$dev_heldout[t$recommended], " flow_def", t$dev_heldout[t$departures_flow == 0 & is.na(t$exc_q)], "\n")
}
