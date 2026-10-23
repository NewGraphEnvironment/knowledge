#' Score candidate rules on held-out watershed groups
#'
#' `scripts/0297`'s scoring spec, fixed for CH before its first fit and applied
#' here to any species × stage. Each rule's in/out on every visit enters a
#' binomial model with a complementary log-log link beside `log(area)`, data set,
#' era and the watershed group. The modelled groups go into `folds` folds,
#' stratified: groups are ranked by detections and dealt in shuffled blocks, with
#' a fixed seed. Each fold is scored from a fit on the other folds: the held-out
#' visits take that fit's rule, area, data-set and era coefficients, and each
#' held-out group refits only its own intercept on its own visits (one parameter
#' per group for every rule). A level unseen in training takes the reference and
#' is counted. The score is the summed binomial deviance of the held-out visits.
#' Rules with the same in/out on every visit are one fit.
#'
#' The **best** rule has the lowest score. A rule is in the **region** when its
#' score is within one SE of the best, the SE being `sqrt(n groups)` × the sd of
#' the per-group differences from the best (the group is the unit). The **pick**
#' is the region rule with the fewest departures from `default`, ties to the
#' lower score. If the pick's exception distance is under `d_floor` (where
#' mainstem catches snapped to a tributary mouth cannot be told apart),
#' **recommended** is the pick among region rules with `exc_d >= d_floor` or no
#' exception; otherwise it is the pick. Where the grid carries
#' `departures_flow` (the departures from link's flow version of `default`,
#' [knw_tune_grid()]), the same pick is made from that starting point too
#' (`pick_flow`, `recommended_flow`; #80), on the same region: the region does
#' not depend on the start, only which of its rules is nearest. With `extra = TRUE` the call also runs
#' `n_boot` bootstrap resamples of groups (each rule's share in the region, and
#' the share of resamples recommending each rule), a nested selection (the pick
#' chosen on the other folds' held-out deviance and scored on each fold, against
#' `default` and against the no-rule model) and the grid on `seeds_more` more
#' fold seeds (each reporting its best, pick and recommended rule, whether
#' `default` and the main reading's recommended rule are in its region, and the
#' region's size).
#'
#' Groups where the response never or always occurs are left out (they inform no
#' contrast) and counted.
#'
#' @param d `data.frame` of visits with the response column `resp` (0/1),
#'   `wsg` (factor), `log_area`, `data_set` (factor), `era` (factor), and the
#'   columns `rule_in` reads.
#' @param rule_in a function `(d, rule)` returning a logical of `nrow(d)`:
#'   whether each visit is in under one row of `grid` (see [knw_rule_in()]).
#' @param grid the rules, as [knw_tune_grid()] returns them.
#' @param resp `character(1)` the response column.
#' @param seed `integer(1)` fold seed.
#' @param folds,n_boot,seed_boot,seeds_more,d_floor the spec's constants.
#' @param workers `integer(1)` socket workers for the pattern fits.
#' @param extra `logical(1)` run the bootstrap, nested selection and extra seeds.
#' @param fit `"fe"` fits each pattern with the groups absorbed (one intercept
#'   per group found by projection, so a fit's cost grows with the nuisance
#'   columns, not the groups; #83), `"dense"` with one model-matrix column per
#'   group (`stats::glm.fit()`). They give the same coefficients and deviances to
#'   numerical tolerance; `"fe"` falls back to `"dense"` on a fold where a
#'   nuisance level is a combination of groups.
#' @return A list: `rules`, the grid with `n_visits`, `n_detect`, `n_wsg`,
#'   `unseen_level_visits`, `n_wsg_varies`, `converged`, `dev_heldout`,
#'   `ddev_best`, `se_diff`, `ddev_null`, `in_region`, `n_in`, `n_detect_in`,
#'   `raw_rate_in`, `raw_rate_out`, `pick`, `recommended`, `pick_flow`,
#'   `recommended_flow` (`NA` with no flow start), and with `extra`
#'   `boot_region_share`, `boot_rec_share` and `boot_rec_share_flow`; `folds`, the fold of each group;
#'   `honest`, `seeds`, `boot_recs` (with `extra`), and `population`, counts.
#' @export
#' @examples
#' # a small made-up population: two "rules", eight groups
#' set.seed(1)
#' d <- data.frame(wsg = factor(rep(sprintf("W%02d", 1:8), each = 30)),
#'                 log_area = log(runif(240, 20, 400)), data_set = factor("FDIS"),
#'                 era = factor("2005on"), size = runif(240, 0.05, 3))
#' d$U <- rbinom(240, 1, plogis(-3 + 1.5 * (d$size > 0.5)))
#' grid <- data.frame(rule = c("default", "tuned"), size_var = "mad", size_min = c(0.1, 0.5),
#'                    grad_max = 0.05, exc_q = NA, exc_d = NA, departures = c(0L, 1L),
#'                    is_default = c(TRUE, FALSE))
#' rule_in <- function(d, r) d$size >= r$size_min
#' s <- knw_tune_score(d, rule_in, grid, "U", seed = 1, workers = 1)
#' s$rules[, c("rule", "dev_heldout", "ddev_best", "se_diff", "in_region", "pick")]
knw_tune_score <- function(d, rule_in, grid, resp = "U", seed = 54L, folds = 5L, n_boot = 200L,
                           seed_boot = 541L, seeds_more = integer(), d_floor = 200, workers = 1L,
                           extra = FALSE, fit = c("fe", "dense")) {
  fit <- match.arg(fit)
  chk::chk_data(d)
  chk::check_names(d, c(resp, "wsg", "log_area", "data_set", "era"))
  chk::chk_function(rule_in)
  chk::chk_data(grid)
  chk::check_names(grid, c("rule", "departures", "is_default", "exc_d"))
  chk::chk_whole_number(folds)
  chk::chk_whole_number(workers)
  if (sum(grid$is_default) != 1L) stop("grid must hold exactly one default rule", call. = FALSE)
  if (!is.factor(d$wsg)) d$wsg <- factor(d$wsg)
  if (!is.factor(d$data_set)) d$data_set <- factor(d$data_set)
  if (!is.factor(d$era)) d$era <- factor(d$era)
  default_ix <- which(grid$is_default)

  n_all <- nrow(d)
  d <- .tune_modelled(d, resp)
  if (nlevels(d$wsg) < folds) {
    stop("only ", nlevels(d$wsg), " groups with both outcomes; ", folds, " folds need at least that many",
         call. = FALSE)
  }
  X <- vapply(seq_len(nrow(grid)), function(i) as.logical(rule_in(d, grid[i, , drop = FALSE])), logical(nrow(d)))
  if (anyNA(X)) stop("rule_in returned NA", call. = FALSE)
  key <- apply(X, 2, function(x) paste(packBits(c(x, logical((8 - length(x) %% 8) %% 8))), collapse = ""))
  u <- !duplicated(key)
  pats <- lapply(which(u), function(i) X[, i])
  col <- match(key, key[u])

  cl <- NULL
  if (workers > 1L) {
    cl <- parallel::makeCluster(workers)
    on.exit(parallel::stopCluster(cl), add = TRUE)
  }
  sw <- .tune_score_wsg(d, resp, pats, seed, folds, cl, fit)
  s0 <- .tune_sel(sw$Sw, seq_len(nrow(sw$Sw)))
  pk <- .tune_pick(s0, col, sw$conv, grid, d_floor)
  flow_start <- "departures_flow" %in% names(grid) && !all(is.na(grid$departures_flow))
  pkf <- if (flow_start) .tune_pick(s0, col, sw$conv, grid, d_floor, dep = grid$departures_flow) else NULL
  R <- rowsum(X * 1, d$wsg)
  N <- as.vector(table(d$wsg)[rownames(R)])
  y <- d[[resp]]
  res <- tibble::as_tibble(grid)
  res$n_visits <- nrow(d)
  res$n_detect <- sum(y)
  res$n_wsg <- nlevels(d$wsg)
  res$unseen_level_visits <- sw$unseen
  res$n_wsg_varies <- colSums(R > 0 & R < N)
  res$converged <- sw$conv[col]
  res$dev_heldout <- s0$tot[col]
  res$ddev_best <- s0$tot[col] - s0$tot[s0$best]
  res$se_diff <- s0$se[col]
  res$ddev_null <- s0$tot[col] - sum(sw$null)
  res$in_region <- s0$region[col] & sw$conv[col]
  res$n_in <- colSums(X)
  res$n_detect_in <- colSums(X * y)
  res$raw_rate_in <- res$n_detect_in / res$n_in
  res$raw_rate_out <- (sum(y) - res$n_detect_in) / (nrow(d) - res$n_in)
  res$pick <- seq_len(nrow(grid)) == pk[["pick"]]
  res$recommended <- seq_len(nrow(grid)) == pk[["recommended"]]
  res$pick_flow <- if (flow_start) seq_len(nrow(grid)) == pkf[["pick"]] else NA
  res$recommended_flow <- if (flow_start) seq_len(nrow(grid)) == pkf[["recommended"]] else NA
  out <- list(rules = res, folds = sw$fold,
              population = c(visits_in = n_all, visits_modelled = nrow(d), detections = sum(y),
                             groups = nlevels(d$wsg), patterns = sum(u), not_converged = sum(!sw$conv)))
  if (extra) {
    set.seed(seed_boot)
    nw <- nrow(sw$Sw)
    reg_n <- numeric(ncol(sw$Sw))
    recs <- integer(n_boot)
    recs_flow <- integer(n_boot)
    for (b in seq_len(n_boot)) {
      s <- .tune_sel(sw$Sw, sample.int(nw, nw, replace = TRUE))
      reg_n <- reg_n + (s$region & sw$conv)
      recs[b] <- .tune_pick(s, col, sw$conv, grid, d_floor)[["recommended"]]
      if (flow_start) {
        recs_flow[b] <- .tune_pick(s, col, sw$conv, grid, d_floor, dep = grid$departures_flow)[["recommended"]]
      }
    }
    out$rules$boot_region_share <- reg_n[col] / n_boot
    out$rules$boot_rec_share <- tabulate(recs, nrow(grid)) / n_boot
    out$rules$boot_rec_share_flow <- if (flow_start) tabulate(recs_flow, nrow(grid)) / n_boot else NA_real_
    out$boot_recs <- grid[recs, , drop = FALSE]
    out$honest <- do.call(rbind, lapply(seq_len(folds), function(k) {
      out_k <- which(sw$fold != k)
      in_k <- which(sw$fold == k)
      pk_k <- .tune_pick(.tune_sel(sw$Sw, out_k), col, sw$conv, grid, d_floor)
      data.frame(fold = k, rule = grid$rule[pk_k[["recommended"]]], n_wsg = length(in_k),
                 dev_rec = sum(sw$Sw[in_k, col[pk_k[["recommended"]]]]),
                 dev_default = sum(sw$Sw[in_k, col[default_ix]]), dev_null = sum(sw$null[in_k]))
    }))
    out$seeds <- do.call(rbind, lapply(seeds_more, function(sd_) {
      s2 <- .tune_score_wsg(d, resp, pats, sd_, folds, cl, fit)
      ss <- .tune_sel(s2$Sw, seq_len(nrow(s2$Sw)))
      p2 <- .tune_pick(ss, col, s2$conv, grid, d_floor)
      data.frame(seed = sd_, best = grid$rule[which(col == ss$best)[1]], pick = grid$rule[p2[["pick"]]],
                 recommended = grid$rule[p2[["recommended"]]], default_in_region = ss$region[col[default_ix]],
                 main_rec_in_region = ss$region[col[pk[["recommended"]]]] & s2$conv[col[pk[["recommended"]]]],
                 region_n = sum(ss$region[col] & s2$conv[col]))
    }))
  }
  out
}

# groups with both outcomes, and dropped levels
.tune_modelled <- function(d, resp) {
  keep <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
  d <- d[d$wsg %in% names(keep)[keep %in% TRUE], , drop = FALSE]
  d$wsg <- droplevels(d$wsg)
  d
}

# stratified folds: groups ranked by detections, dealt in shuffled blocks of `folds`
.tune_fold_of_wsg <- function(d, resp, seed, folds) {
  set.seed(seed)
  cnt <- tapply(d[[resp]], d$wsg, sum)
  w <- names(cnt)[order(-cnt, stats::runif(length(cnt)))]
  blk <- ceiling(seq_along(w) / folds)
  f <- unlist(lapply(split(seq_along(w), blk), function(i) sample(seq_len(folds))[seq_along(i)]))
  stats::setNames(f, w)
}

.tune_fold_setup <- function(d, resp, fold_of, folds) {
  f <- unname(fold_of[as.character(d$wsg)])
  lapply(seq_len(folds), function(k) {
    tr <- which(f != k)
    ho <- which(f == k)
    dtr <- d[tr, , drop = FALSE]
    dtr$wsg <- droplevels(dtr$wsg)
    nuis <- c("log_area", "data_set", "era")
    nuis <- nuis[vapply(nuis, function(t) length(unique(dtr[[t]])) > 1L, logical(1))]
    X <- stats::model.matrix(stats::as.formula(paste("~", paste(c(nuis, "wsg"), collapse = " + "))), dtr)
    # every factor level is kept, so a held-out level absent from training has a column that is
    # not in the fit and contributes 0 (the reference)
    Xh <- if (length(nuis)) {
      stats::model.matrix(stats::as.formula(paste("~ 0 +", paste(nuis, collapse = " + "))), d[ho, , drop = FALSE])
    } else {
      matrix(numeric(0), nrow = length(ho), ncol = 0)
    }
    cols <- intersect(colnames(Xh), colnames(X))
    unseen <- sum(!(d$data_set[ho] %in% dtr$data_set) | !(d$era[ho] %in% dtr$era))
    # the same nuisance columns without the intercept, and each training visit's group, for the fit that absorbs
    # the groups (#83); the first level is the reference the dense fit's intercept carries
    Xn <- if (length(nuis)) {
      stats::model.matrix(stats::as.formula(paste("~", paste(nuis, collapse = " + "))), dtr)[, -1, drop = FALSE]
    } else {
      matrix(numeric(0), nrow = length(tr), ncol = 0)
    }
    list(tr = tr, ho = ho, X = X, Xn = Xn, g = as.integer(dtr$wsg), y = d[[resp]][tr], Xh = Xh[, cols, drop = FALSE],
         cols = cols, yh = d[[resp]][ho], wh = droplevels(d$wsg[ho]), unseen = unseen)
  })
}

# held-out deviance per visit for one in/out pattern, with each fold's non-group training coefficients
# (the nuisance terms and the rule; `NA` where aliased), which the smoke run's coefficient gate reads (#84).
# `fit = "fe"` absorbs the groups (`.tune_glm_fe()`, #83) and falls back to the dense `glm.fit()` on a fold where
# the two would drop different columns; `"dense"` is the model matrix with one column per group.
.tune_score_one <- function(x, folds, fit = "fe") {
  fam <- stats::binomial(link = "cloglog")
  n <- sum(vapply(folds, function(f) length(f$ho), integer(1)))
  dv <- rep(NA_real_, n)
  ok <- TRUE
  cf <- vector("list", length(folds))
  for (k in seq_along(folds)) {
    f <- folds[[k]]
    xt <- as.numeric(x[f$tr])
    m <- if (fit == "fe") .tune_glm_fe(cbind(f$Xn, rule = xt), f$g, f$y, fam) else NULL
    if (is.null(m) || m$fallback) {
      m <- suppressWarnings(stats::glm.fit(cbind(f$X, rule = xt), f$y, family = fam,
                                           control = stats::glm.control(maxit = 100)))
    }
    if (!m$converged) ok <- FALSE
    b <- m$coefficients
    cf[[k]] <- b[c(f$cols, "rule")]
    br <- if (is.na(b[["rule"]])) 0 else b[["rule"]]
    bn <- b[f$cols]
    bn[is.na(bn)] <- 0
    eta <- (if (length(f$cols)) drop(f$Xh %*% bn) else 0) + br * as.numeric(x[f$ho])
    for (w in levels(f$wh)) {
      i <- which(f$wh == w)
      dv[f$ho[i]] <- .tune_group_dev(f$yh[i], eta[i], fam)
    }
  }
  if (anyNA(dv)) stop("a visit was in no held-out fold", call. = FALSE)
  list(dev = dv, ok = ok, coef = cf)
}

# a binomial GLM with one intercept per group, the groups absorbed (#83): `stats::glm.fit()`'s IRLS, start,
# step halving and convergence test, with each weighted least-squares step solved by projecting the groups
# out (the weighted group means of the working response and the other columns) and a pivoted QR on what is
# left, so a step costs n x p^2 in the nuisance columns rather than in the groups. The nuisance coefficients
# are the dense fit's; each group's effect is its weighted mean residual, the first group's being the dense
# fit's intercept. A column that is zero, or a combination of earlier columns, is dropped as the dense fit's
# QR drops it (`NA`); a nuisance column that is a combination of the groups, but not of the intercept and the
# nuisance columns before it, is dropped here but kept by the dense fit, which drops a group column instead, so
# `fallback` says the caller should use the dense fit.
.tune_glm_fe <- function(X, g, y, fam = stats::binomial(link = "cloglog"), maxit = 100L, epsilon = 1e-8) {
  n <- length(y)
  p <- ncol(X)
  G <- max(g)
  mustart <- (y + 0.5) / 2
  eta <- fam$linkfun(mustart)
  mu <- fam$linkinv(eta)
  w1 <- rep(1, n)
  devold <- sum(fam$dev.resids(y, mu, w1))
  b <- rep(0, p)
  a <- rep(0, G)
  coefold <- NULL
  conv <- FALSE
  iter <- 0L
  dropped <- rep(FALSE, p)
  valid <- function() is.finite(dev) && fam$valideta(eta) && fam$validmu(mu)
  for (iter in seq_len(maxit)) {
    mu_eta <- fam$mu.eta(eta)
    good <- mu_eta != 0
    z <- eta[good] + (y[good] - mu[good]) / mu_eta[good]
    w <- sqrt(mu_eta[good]^2 / fam$variance(mu[good]))
    w2 <- w^2
    gg <- g[good]
    Xg <- X[good, , drop = FALSE]
    sw <- as.vector(rowsum(w2, gg))
    grp <- sort(unique(gg))
    gi <- match(gg, grp)
    mX <- rowsum(Xg * w2, gg) / sw
    mz <- as.vector(rowsum(z * w2, gg)) / sw
    ls <- .lm.fit((Xg - mX[gi, , drop = FALSE]) * w, (z - mz[gi]) * w, tol = 1e-11)
    b <- numeric(p)
    b[ls$pivot[seq_len(ls$rank)]] <- ls$coefficients[seq_len(ls$rank)]
    if (ls$rank < p) dropped[ls$pivot[-seq_len(ls$rank)]] <- TRUE
    a <- rep(NA_real_, G)
    a[grp] <- as.vector(mz - mX %*% b)
    a[is.na(a)] <- a[1]
    start <- c(b, a)
    eta <- drop(X %*% b) + a[g]
    mu <- fam$linkinv(eta)
    dev <- sum(fam$dev.resids(y, mu, w1))
    if (!valid()) {
      if (is.null(coefold)) stop("no valid set of coefficients has been found", call. = FALSE)
      ii <- 1L
      while (!valid()) {
        if (ii > maxit) stop("inner loop; cannot correct step size", call. = FALSE)
        ii <- ii + 1L
        start <- (start + coefold) / 2
        b <- start[seq_len(p)]
        a <- start[p + seq_len(G)]
        eta <- drop(X %*% b) + a[g]
        mu <- fam$linkinv(eta)
        dev <- sum(fam$dev.resids(y, mu, w1))
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
  names(b) <- colnames(X)
  # the rule is the last column, and is dropped by both fits when aliased. A dropped nuisance column is one the
  # dense fit keeps unless it is zero or its own QR (the intercept, then the nuisance columns, before the groups)
  # drops it as a combination of the intercept and the columns before it: an era dummy on a fold with no visit in
  # the reference era is, and the fall-back on it cost chinook every fit twice over (2026-10-23)
  cand <- (dropped & colSums(X != 0) > 0)[-p]
  fallback <- FALSE
  if (any(cand)) {
    q <- qr(cbind(1, X[, -p, drop = FALSE]), tol = 1e-11)
    dense_drop <- logical(p - 1L)
    if (q$rank < p) dense_drop[q$pivot[-seq_len(q$rank)] - 1L] <- TRUE
    fallback <- any(cand & !dense_drop)
  }
  list(coefficients = b, alpha = a, converged = conv, iter = iter, deviance = dev, fallback = fallback)
}

# a held-out group's deviance per visit, its own intercept fitted over the visits' offsets. The
# intercept is the minimiser of the binomial deviance, which is convex in it under cloglog (the
# log-likelihood is concave in the linear predictor), so it is the root of the deviance's derivative,
# which is monotone. `stats::glm.fit()`'s IRLS is not safe here: with offsets spread over twelve units
# (the joint curve's surface on a held-out fold) it reported convergence at an intercept where every
# detection's chance was under 1e-12, 55.3 deviance each, which put CH rearing's curve at 2,434
# held-out against 1,383 for no rule (2026-10-22, #73). Nor is a golden-section search of the deviance
# itself: the clamp at 1e-12 makes it flat far from its minimum, and the search stops on the plateau
# wherever its first probes land there. On a range fixed at [-30, 30] that scored every visit of a fold
# 55.3 when the training fit put its offsets at +15 to +20 (GR rearing's no-rule model 8,397 against 848,
# 2026-10-23); centred on the group's own offsets it still did on ST rearing, whose previous pick scored
# 810 against 587 on the fixed range (#84's smoke run, 2026-10-23). The derivative has no plateau.
.tune_group_dev <- function(y, eta, fam = stats::binomial(link = "cloglog")) {
  dev_at <- function(b) {
    p <- pmin(pmax(fam$linkinv(eta + b), 1e-12), 1 - 1e-12)
    -2 * (y * log(p) + (1 - y) * log(1 - p))
  }
  # d/db of the unclamped deviance: 2 * (sum over non-detections of exp(x) - sum over detections of
  # exp(x) / expm1(exp(x))), x = eta + b; a non-detection's term grows without bound and a detection's
  # falls from 1 to 0, so the slope is increasing, negative where every chance is small and positive
  # where every chance is near 1. exp(x) is held at exp(700) so the slope stays finite.
  slope <- function(b) {
    u <- exp(pmin(eta + b, 700))
    r <- u / expm1(u)
    r[u == 0] <- 1
    2 * (sum(u[y == 0L]) - sum(r[y == 1L]))
  }
  b <- stats::uniroot(slope, c(-max(eta) - 30, -min(eta) + 30), tol = 1e-10)$root
  dev_at(b)
}

# per-group held-out deviance for every distinct pattern, plus the no-rule model
.tune_score_wsg <- function(d, resp, pats, seed, folds, cl, fit = "fe") {
  fold_of <- .tune_fold_of_wsg(d, resp, seed, folds)
  fs <- .tune_fold_setup(d, resp, fold_of, folds)
  sc <- if (is.null(cl)) {
    lapply(pats, .tune_score_one, folds = fs, fit = fit)
  } else {
    # every function a worker calls goes by name: a worker loads no package
    parallel::clusterExport(cl, c(".tune_score_one", ".tune_group_dev", ".tune_glm_fe"), envir = environment())
    parallel::parLapply(cl, pats, .tune_score_one, folds = fs, fit = fit)
  }
  devm <- vapply(sc, `[[`, numeric(nrow(d)), "dev")
  Sw <- rowsum(devm, d$wsg)
  list(Sw = Sw, conv = vapply(sc, `[[`, logical(1), "ok"),
       null = rowsum(.tune_score_one(rep(FALSE, nrow(d)), fs, fit = fit)$dev, d$wsg)[, 1],
       unseen = sum(vapply(fs, `[[`, numeric(1), "unseen")),
       fold = fold_of[rownames(Sw)])
}

# best, SE and region over a set of groups (rows of Sw)
.tune_sel <- function(Sw, ix) {
  M <- Sw[ix, , drop = FALSE]
  tot <- colSums(M)
  best <- which.min(tot)
  se <- sqrt(length(ix)) * apply(M - M[, best], 2, stats::sd)
  list(tot = tot, best = best, se = se, region = tot - tot[best] <= se)
}

# grid indices of the pick and the recommended rule, counting departures from `dep`'s starting point
.tune_pick <- function(s, col, conv, grid, d_floor, dep = grid$departures) {
  rr <- which(s$region[col] & conv[col])
  rr <- rr[order(dep[rr], s$tot[col[rr]])]
  p <- rr[1]
  ok_d <- rr[is.na(grid$exc_d[rr]) | grid$exc_d[rr] >= d_floor]
  c(pick = p, recommended = if (!is.na(grid$exc_d[p]) && grid$exc_d[p] < d_floor) ok_d[1] else p)
}
