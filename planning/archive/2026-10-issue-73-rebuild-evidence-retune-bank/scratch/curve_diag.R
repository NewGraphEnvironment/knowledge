# Per-fold and per-group held-out deviance of the CH rearing curve, replaying knw_tune_curve()'s loop.
suppressPackageStartupMessages({library(mgcv); pkgload::load_all(quiet = TRUE)})
cv <- readRDS("data/tune/CH_rear_curve.rds")$curve; sc <- readRDS("data/tune/CH_rear_score.rds")
cat("score names:", names(sc), "\n"); cat("curve names:", names(cv), "\n")
dd <- cv$data; resp <- all.vars(formula(cv$model))[1]
folds <- sc$folds; if (is.null(folds)) folds <- sc$fold
str(folds)
fo <- folds[as.character(dd$wsg)]
cat("n", nrow(dd), "detections", sum(dd[[resp]]), "heldout stored", cv$heldout, "\n")
cat("log_dist quantiles:\n"); print(quantile(exp(dd$log_dist) - 10, c(0, .01, .05, .1, .25, .5, .75, .9, 1)))
cat("dist < 20 m:", sum(exp(dd$log_dist) - 10 < 20), " at cap:", sum(exp(dd$log_dist) - 10 >= cv$dist_cap_m), "\n")
fam <- binomial(link = "cloglog")
k <- c(size = 6, dist = 6, grad = 6); k_dist <- min(6, length(unique(dd$log_dist)) - 1L)
nuis <- c("log_area", "data_set", "era"); nuis <- nuis[vapply(nuis, function(t) length(unique(dd[[t]])) > 1L, logical(1))]
smooths <- function(nu) paste0(sprintf("te(log_size, log_dist, k = c(%d, %d))", 6, k_dist), " + s(grad, k = 6)",
                               if (length(nu)) paste0(" + ", paste(nu, collapse = " + ")) else "")
out <- list()
for (kf in sort(unique(fo))) {
  tr <- dd[fo != kf, , drop = FALSE]; ho <- dd[fo == kf, , drop = FALSE]
  tr$wsg <- droplevels(tr$wsg); tr$data_set <- droplevels(tr$data_set); tr$era <- droplevels(tr$era)
  nu <- nuis[vapply(nuis, function(t) length(unique(tr[[t]])) > 1L, logical(1))]
  mk <- gam(as.formula(paste(resp, "~", smooths(nu), "+ s(wsg, bs = 're')")), family = fam, data = tr, method = "REML")
  for (t in c("data_set", "era")) { lv <- as.character(ho[[t]]); lv[!lv %in% levels(tr[[t]])] <- names(which.max(table(tr[[t]]))); ho[[t]] <- factor(lv, levels = levels(tr[[t]])) }
  ho$wsg <- factor(as.character(tr$wsg[1]), levels = levels(tr$wsg))
  eta <- as.numeric(predict.gam(mk, newdata = ho, type = "link", exclude = "s(wsg)", newdata.guaranteed = TRUE))
  y <- ho[[resp]]; w_all <- as.character(dd$wsg[fo == kf])
  for (w in unique(w_all)) {
    i <- which(w_all == w)
    dvi <- knowledge:::.tune_group_dev(y[i], eta[i], fam); dev <- sum(dvi); a <- list(converged = TRUE)
    p <- 0.5
    pn <- mean(y[i]); null <- if (pn > 0 && pn < 1) sum(-2 * (y[i] * log(pn) + (1 - y[i]) * log(1 - pn))) else 0
    out[[length(out) + 1]] <- data.frame(fold = kf, wsg = w, n = length(i), det = sum(y[i]), dev = dev, null = null,
                                         eta_min = min(eta[i]), eta_max = max(eta[i]), conv = a$converged,
                                         worst = max(dvi))
  }
}
o <- do.call(rbind, out); o$excess <- o$dev - o$null
cat("total dev", sum(o$dev), "null", sum(o$null), "\n")
print(aggregate(cbind(dev, null, n, det) ~ fold, o, sum))
cat("worst groups by excess:\n"); print(head(o[order(-o$excess), ], 15), row.names = FALSE)
cat("not converged:", sum(!o$conv), "\n")
# where the blow-ups sit: held-out points with huge per-point deviance, their distance and size

