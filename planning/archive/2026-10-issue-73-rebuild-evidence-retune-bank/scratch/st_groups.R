# per group, the held-out deviance of ST rearing's no-rule model and previous pick under the three intercept searches, from
# 0320's inputs: the replay that found where ca78ca6's centred search still stopped on the clamp's plateau (#84, 2026-10-23)
# run from the repo root: SCHEMA=fresh_default_20261017 Rscript planning/active/scratch/st_groups.R
Sys.setenv(SPECIES = "ST")
source("planning/active/scratch/intercept_probe_head.R")
ns <- asNamespace("knowledge")
cap <- new.env()
unlockBinding("knw_tune_smoke", ns)
assign("knw_tune_smoke", function(d, rule_in, grid, resp, ...) { cap$d <- d; cap$rule_in <- rule_in; cap$grid <- grid; cap$resp <- resp; stop("captured") }, envir = ns)
try(knw_tune_run(vl, vs, walks, thr, species = "ST", spawner = spawner, workers = 1L, thresholds_extra = thr_tuned, smoke_only = TRUE), silent = TRUE)
d <- ns$.tune_modelled(cap$d, "U"); resp <- "U"
fo <- ns$.tune_fold_of_wsg(d, resp, 54L, 5L); fs <- ns$.tune_fold_setup(d, resp, fo, 5L)
fam <- stats::binomial(link = "cloglog")
dev_at <- function(y, eta, b) { p <- pmin(pmax(fam$linkinv(eta + b), 1e-12), 1 - 1e-12); -2 * (y * log(p) + (1 - y) * log(1 - p)) }
s_old <- function(y, eta) dev_at(y, eta, stats::optimize(function(b) sum(dev_at(y, eta, b)), c(-30, 30), tol = 1e-8)$minimum)
s_ca <- function(y, eta) dev_at(y, eta, stats::optimize(function(b) sum(dev_at(y, eta, b)), -stats::median(eta) + c(-30, 30), tol = 1e-8)$minimum)
s_now <- function(y, eta) ns$.tune_group_dev(y, eta, fam)
prev <- "mad>=1|g<=0.0849|none"
pats <- list(no_rule = rep(FALSE, nrow(d)), previous = as.logical(cap$rule_in(d, cap$grid[cap$grid$rule == prev, ])))
for (nm in names(pats)) {
  x <- pats[[nm]]
  for (k in seq_along(fs)) {
    f <- fs[[k]]
    m <- suppressWarnings(stats::glm.fit(cbind(f$X, rule = as.numeric(x[f$tr])), f$y, family = fam, control = stats::glm.control(maxit = 100)))
    b <- m$coefficients; br <- if (is.na(b[["rule"]])) 0 else b[["rule"]]; bn <- b[f$cols]; bn[is.na(bn)] <- 0
    eta <- (if (length(f$cols)) drop(f$Xh %*% bn) else 0) + br * as.numeric(x[f$ho])
    big <- bn[abs(bn) > 5]
    if (length(big)) cat(sprintf("%s fold %d: %s\n", nm, k, paste(sprintf("%s=%.2f", names(big), big), collapse = " ")))
    for (w in levels(f$wh)) {
      i <- which(f$wh == w)
      a <- sum(s_old(f$yh[i], eta[i])); bb <- sum(s_ca(f$yh[i], eta[i])); cc <- sum(s_now(f$yh[i], eta[i]))
      if (max(a, bb, cc) - min(a, bb, cc) > 0.01)
        cat(sprintf("  %s fold %d %s: n %d det %d eta [%.1f, %.1f] median %.1f | old %.1f ca78ca6 %.1f root %.1f\n",
                    nm, k, w, length(i), sum(f$yh[i]), min(eta[i]), max(eta[i]), median(eta[i]), a, bb, cc))
    }
  }
}
