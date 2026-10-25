# reproduce the scorer's no-rule held-out deviance per visit for one key, from the inputs 0320 builds
# run from the repo root: SCHEMA=fresh_default_20261017 PSP=GR Rscript planning/active/scratch/intercept_probe.R (#73, #84)
key_sp <- Sys.getenv("PSP", "GR")
Sys.setenv(SPECIES = key_sp)
source("planning/active/scratch/intercept_probe_head.R")
ns <- asNamespace("knowledge")
cap <- new.env()
unlockBinding("knw_tune_score", ns)
assign("knw_tune_score", function(d, rule_in, grid, resp, ...) { cap$d <- d; cap$resp <- resp; cap$rule_in <- rule_in; cap$grid <- grid; stop("captured") }, envir = ns)
try(knw_tune_run(vl, vs, walks, thr, species = key_sp, spawner = spawner, workers = 1L, cache_dir = NULL, thresholds_extra = thr_tuned), silent = TRUE)
d <- cap$d; resp <- cap$resp
cat("captured d:", nrow(d), "rows; resp", resp, "\n")
# the scorer's modelled set: knw_tune_score keeps groups with both outcomes; mimic via its own helpers
both <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
dm <- d[d$wsg %in% names(both)[both %in% TRUE], ]; dm$wsg <- droplevels(dm$wsg)
cat("modelled:", nrow(dm), " groups", nlevels(dm$wsg), "\n")
print(summary(dm[, c("log_area")])); print(table(dm$data_set, useNA = "ifany")); print(table(dm$era, useNA = "ifany"))
fo <- ns$.tune_fold_of_wsg(dm, resp, 54L, 5L)
fs <- ns$.tune_fold_setup(dm, resp, fo, 5L)
fam <- stats::binomial(link = "cloglog")
for (k in seq_along(fs)) {
  f <- fs[[k]]
  m <- suppressWarnings(stats::glm.fit(cbind(f$X, rule = 0), f$y, family = fam, control = stats::glm.control(maxit = 100)))
  b <- m$coefficients; bn <- b[f$cols]; bn[is.na(bn)] <- 0
  eta <- if (length(f$cols)) drop(f$Xh %*% bn) else rep(0, length(f$ho))
  cat(sprintf("\nfold %d: converged %s, iter %d; nuisance coefs: %s\n", k, m$converged, m$iter, paste(sprintf("%s=%.2f", names(bn), bn), collapse = " ")))
  cat("  held-out eta range:", round(range(eta), 2), "\n")
  for (w in levels(f$wh)) {
    i <- which(f$wh == w)
    dv <- ns$.tune_group_dev(f$yh[i], eta[i], fam)
    if (sum(dv) > 60 * 1 && max(dv) > 20) cat(sprintf("  %s: n %d, det %d, dev %.1f, max per-visit %.1f, eta %.2f..%.2f\n", w, length(i), sum(f$yh[i]), sum(dv), max(dv), min(eta[i]), max(eta[i])))
  }
  tot <- 0; for (w in levels(f$wh)) { i <- which(f$wh == w); tot <- tot + sum(ns$.tune_group_dev(f$yh[i], eta[i], fam)) }
  cat("  fold null dev", round(tot, 1), "\n")
}
# the same fold with the search centred on the group's own offsets
gd2 <- function(y, eta, fam = stats::binomial(link = "cloglog"), bound = 30) {
  dev_at <- function(b) { p <- pmin(pmax(fam$linkinv(eta + b), 1e-12), 1 - 1e-12); -2 * (y * log(p) + (1 - y) * log(1 - p)) }
  c0 <- -stats::median(eta)
  b <- stats::optimize(function(b) sum(dev_at(b)), c0 + c(-bound, bound), tol = 1e-8)$minimum
  dev_at(b)
}
cat("\ncentred search:\n")
for (k in seq_along(fs)) {
  f <- fs[[k]]
  m <- suppressWarnings(stats::glm.fit(cbind(f$X, rule = 0), f$y, family = fam, control = stats::glm.control(maxit = 100)))
  b <- m$coefficients; bn <- b[f$cols]; bn[is.na(bn)] <- 0
  eta <- if (length(f$cols)) drop(f$Xh %*% bn) else rep(0, length(f$ho))
  t_old <- 0; t_new <- 0
  for (w in levels(f$wh)) { i <- which(f$wh == w); t_old <- t_old + sum(ns$.tune_group_dev(f$yh[i], eta[i], fam)); t_new <- t_new + sum(gd2(f$yh[i], eta[i], fam)) }
  cat(sprintf("fold %d: old %.3f  centred %.3f\n", k, t_old, t_new))
}
