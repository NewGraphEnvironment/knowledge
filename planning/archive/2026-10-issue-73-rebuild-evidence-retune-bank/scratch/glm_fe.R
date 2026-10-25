# a binomial GLM with one intercept per group, the groups absorbed: glm.fit's IRLS, with each weighted least-squares
# step solved by projecting the groups out (weighted group means) and a small QR on the rest
.tune_glm_fe <- function(X, g, y, fam = stats::binomial(link = "cloglog"), maxit = 100L, epsilon = 1e-8) {
  n <- length(y)
  p <- ncol(X)
  G <- max(g)
  nm <- colnames(X)
  # glm.fit's start: mustart from the family, eta from it
  mustart <- (y + 0.5) / 2
  eta <- fam$linkfun(mustart)
  mu <- fam$linkinv(eta)
  devold <- sum(fam$dev.resids(y, mu, rep(1, n)))
  beta <- rep(0, p)
  alpha <- rep(0, G)
  coefold <- NULL
  conv <- FALSE
  iter <- 0L
  dropped <- rep(FALSE, p)
  for (iter in seq_len(maxit)) {
    mu_eta <- fam$mu.eta(eta)
    good <- mu_eta != 0
    z <- eta[good] + (y[good] - mu[good]) / mu_eta[good]
    w <- sqrt(mu_eta[good]^2 / fam$variance(mu[good]))
    w2 <- w^2
    gg <- g[good]
    Xg <- X[good, , drop = FALSE]
    sw <- rowsum(w2, gg)
    grp <- as.integer(rownames(sw))
    gi <- match(gg, grp)
    mX <- rowsum(Xg * w2, gg) / as.vector(sw)
    mz <- rowsum(z * w2, gg) / as.vector(sw)
    Xd <- Xg - mX[gi, , drop = FALSE]
    zd <- z - mz[gi]
    fit <- .lm.fit(Xd * w, zd * w, tol = 1e-11)
    b <- numeric(p)
    b[fit$pivot[seq_len(fit$rank)]] <- fit$coefficients[seq_len(fit$rank)]
    if (fit$rank < p) dropped[fit$pivot[-seq_len(fit$rank)]] <- TRUE
    a <- rep(NA_real_, G)
    a[grp] <- as.vector(mz - mX %*% b)
    # a group with no usable visit this step takes the reference group's effect, as glm.fit's pivoting gives it
    a[is.na(a)] <- a[1]
    start <- c(b, a)
    eta <- drop(X %*% b) + a[g]
    mu <- fam$linkinv(eta)
    dev <- sum(fam$dev.resids(y, mu, rep(1, n)))
    if (!is.finite(dev) || !(fam$valideta(eta) && fam$validmu(mu))) {
      if (is.null(coefold)) stop("no valid set of coefficients has been found: please supply starting values", call. = FALSE)
      ii <- 1
      while (!is.finite(dev) || !(fam$valideta(eta) && fam$validmu(mu))) {
        if (ii > maxit) stop("inner loop; cannot correct step size", call. = FALSE)
        ii <- ii + 1
        start <- (start + coefold) / 2
        b <- start[seq_len(p)]
        a <- start[p + seq_len(G)]
        eta <- drop(X %*% b) + a[g]
        mu <- fam$linkinv(eta)
        dev <- sum(fam$dev.resids(y, mu, rep(1, n)))
      }
    }
    if (abs(dev - devold) / (abs(dev) + 0.1) < epsilon) {
      conv <- TRUE
      break
    }
    devold <- dev
    coefold <- start
  }
  b[dropped] <- NA_real_
  names(b) <- nm
  list(coefficients = b, alpha = a, converged = conv, iter = iter, deviance = dev, dropped = dropped)
}

# check against glm.fit on simulated data, with aliased columns and a separated fit
set.seed(11)
n <- 3000; G <- 40
g <- sample.int(G, n, TRUE)
d <- data.frame(wsg = factor(sprintf("W%02d", g)), log_area = log(runif(n, 20, 400)),
                data_set = factor(sample(c("FDIS", "FDS"), n, TRUE)), era = factor(sample(c("to1994", "1995-2004", "2005on"), n, TRUE)))
ge <- rnorm(G, -2.5, 0.8)
eta_true <- ge[g] + 0.4 * (d$log_area - 5) + 0.6 * (d$data_set == "FDS") - 0.3 * (d$era == "2005on")
d$y <- rbinom(n, 1, 1 - exp(-exp(eta_true)))
rule <- as.numeric(runif(n) < 0.6)
fam <- binomial("cloglog")
Xdense <- model.matrix(~ log_area + data_set + era + wsg, d)
Xn <- model.matrix(~ log_area + data_set + era, d)[, -1]
cmp <- function(Xd_, Xn_, lab) {
  t1 <- system.time(m1 <- suppressWarnings(glm.fit(cbind(Xd_, rule = rule), d$y, family = fam, control = glm.control(maxit = 100))))[["elapsed"]]
  t2 <- system.time(m2 <- .tune_glm_fe(cbind(Xn_, rule = rule), g, d$y, fam))[["elapsed"]]
  cols <- c(colnames(Xn_), "rule")
  b1 <- m1$coefficients[cols]; b2 <- m2$coefficients[cols]
  cat(sprintf("%s: glm.fit dev %.8f conv %s iter %d (%.3fs) | fe dev %.8f conv %s iter %d (%.3fs) | max |db| %.2e | NA same %s\n",
              lab, m1$deviance, m1$converged, m1$iter, t1, m2$deviance, m2$converged, m2$iter, t2,
              max(abs(b1 - b2), na.rm = TRUE), identical(is.na(b1), is.na(b2))))
  # group effects: glm.fit's intercept + dummies vs alpha
  a1 <- c(m1$coefficients[1], m1$coefficients[1] + m1$coefficients[grep("^wsg", names(m1$coefficients))])
  cat(sprintf("   max |dalpha| %.2e\n", max(abs(a1 - m2$alpha), na.rm = TRUE)))
}
cmp(Xdense, Xn, "plain")
# an aliased column: a level absent (all zero) and a rule in for no visit
rule0 <- rule; rule <- rep(0, n); cmp(Xdense, Xn, "rule all zero"); rule <- rule0
Xn2 <- cbind(Xn, dead = 0); Xd2 <- cbind(Xdense, dead = 0); cmp(Xd2, Xn2, "zero column")
# a separated nuisance term: FDS visits never detected
y0 <- d$y; d$y[d$data_set == "FDS"] <- 0L; cmp(Xdense, Xn, "separated data_set"); d$y <- y0
# a nuisance column aliased with the groups: a level present in exactly one group, whose every visit has it
d2 <- d; lev <- d2$wsg == "W05"; d2$data_set <- factor(ifelse(lev, "FDS", "FDIS"))
Xdense2 <- model.matrix(~ log_area + data_set + era + wsg, d2); Xn3 <- model.matrix(~ log_area + data_set + era, d2)[, -1]
m1 <- suppressWarnings(glm.fit(cbind(Xdense2, rule = rule), d2$y, family = fam)); m2 <- .tune_glm_fe(cbind(Xn3, rule = rule), g, d2$y, fam)
cat(sprintf("group-aliased level: glm.fit dev %.6f (data_setFDS %.4f, wsgW05 %s) | fe dev %.6f (data_setFDS %s, dropped %s)\n",
            m1$deviance, m1$coefficients[["data_setFDS"]], m1$coefficients[["wsgW05"]], m2$deviance, m2$coefficients[["data_setFDS"]], paste(names(m2$coefficients)[m2$dropped], collapse = ",")))
# timing at rainbow's size
set.seed(2); n <- 10400; G <- 103; g <- sample.int(G, n, TRUE)
d <- data.frame(wsg = factor(sprintf("W%03d", g)), log_area = log(runif(n, 20, 400)), data_set = factor(sample(c("FDIS", "FDS"), n, TRUE)), era = factor(sample(c("to1994", "1995-2004", "2005on"), n, TRUE)))
d$y <- rbinom(n, 1, 0.25); rule <- as.numeric(runif(n) < 0.6)
Xdense <- model.matrix(~ log_area + data_set + era + wsg, d); Xn <- model.matrix(~ log_area + data_set + era, d)[, -1]
cmp(Xdense, Xn, "rainbow-sized")
