# Probe: the curve's held-out deviance per group, as fitted (no prior on data_set and era) and with a normal prior
# (fixed penalty b^2 / sd^2 on those coefficients, the grid's prior). Usage: KEY=ST_rear Rscript curve_prior_probe.R
suppressMessages(pkgload::load_all(quiet = TRUE))
key <- Sys.getenv("KEY", "ST_rear"); prior_sd <- as.numeric(Sys.getenv("PRIOR_SD", "2.5"))
x <- readRDS(file.path("data/tune", paste0(key, "_curve.rds"))); cv <- x$curve; dd <- cv$data
folds <- readRDS(file.path("data/tune", paste0(key, "_score.rds")))$folds
fam <- stats::binomial(link = "cloglog")
resp <- all.vars(stats::formula(cv$model))[1]
fml_rhs <- deparse(stats::formula(cv$model)[[3]], width.cutoff = 500L)
cat(key, ": ", fml_rhs, "\n", sep = "")
heldout <- function(pen) {
  fo <- folds[as.character(dd$wsg)]
  out <- list(); coefs <- list()
  for (kf in sort(unique(fo))) {
    tr <- dd[fo != kf, , drop = FALSE]; ho <- dd[fo == kf, , drop = FALSE]
    tr$wsg <- droplevels(tr$wsg); tr$data_set <- droplevels(tr$data_set); tr$era <- droplevels(tr$era)
    nu <- c("log_area", "data_set", "era"); nu <- nu[vapply(nu, function(t) length(unique(tr[[t]])) > 1L, logical(1))]
    rhs <- fml_rhs
    for (t in setdiff(c("data_set", "era"), nu)) rhs <- sub(paste0(" \\+ ", t), "", rhs)
    f <- stats::as.formula(paste(resp, "~", rhs))
    pp <- NULL; sp <- NULL
    if (pen) {
      pt <- intersect(c("data_set", "era"), nu)
      if (length(pt)) {
        pp <- stats::setNames(lapply(pt, function(t) list(diag(nlevels(tr[[t]]) - 1L))), pt)
        n_s <- 4L  # te (2), s(grad), s(wsg)
        sp <- c(rep(1 / prior_sd^2, length(pt)), rep(-1, n_s))
      }
    }
    mk <- mgcv::gam(f, family = fam, data = tr, method = "REML", paraPen = pp, sp = sp)
    coefs[[kf]] <- stats::coef(mk)[grepl("^(data_set|era)", names(stats::coef(mk)))]
    for (t in c("data_set", "era")) {
      lv <- as.character(ho[[t]]); lv[!lv %in% levels(tr[[t]])] <- names(which.max(table(tr[[t]])))
      ho[[t]] <- factor(lv, levels = levels(tr[[t]]))
    }
    ho$wsg <- factor(as.character(tr$wsg[1]), levels = levels(tr$wsg))
    eta <- as.numeric(mgcv::predict.gam(mk, newdata = ho, type = "link", exclude = "s(wsg)", newdata.guaranteed = TRUE))
    for (w in unique(as.character(ho$wsg0 <- dd$wsg[fo == kf]))) {
      i <- which(as.character(dd$wsg[fo == kf]) == w)
      out[[w]] <- data.frame(wsg = w, fold = kf, n = length(i), det = sum(ho[[resp]][i]),
                             combos = paste(unique(paste(dd$data_set[fo == kf][i], dd$era[fo == kf][i])), collapse = ";"),
                             dev = sum(.tune_group_dev(ho[[resp]][i], eta[i], fam)))
    }
  }
  list(groups = do.call(rbind, out), coefs = coefs)
}
a <- heldout(FALSE); b <- heldout(TRUE)
g <- merge(a$groups, b$groups[, c("wsg", "dev")], by = "wsg", suffixes = c("_noprior", "_prior"))
print(g[order(-g$dev_noprior), ], row.names = FALSE)
cat(sprintf("%s held-out: as fitted %.1f (cached %.1f), with prior sd %g %.1f\n", key, sum(g$dev_noprior),
            cv$heldout, prior_sd, sum(g$dev_prior)))
cat("fold coefficients, no prior:\n"); print(a$coefs); cat("with prior:\n"); print(b$coefs)
