#' One curve per species and stage: use against size, gradient and distance to a river, together
#'
#' After [knw_tune_score()] has picked a rule, one GAM fits the rule's variables
#' together on the scoring population: a tensor smooth of log size (the pick's
#' size variable, width or MAD) and log distance downstream to the first river of
#' the pick's `exc_q` m³/s, a smooth of gradient, and the same nuisance terms as
#' the scorer (`log_area`, data set, era) with the watershed group as a random
#' effect; binomial with a complementary log-log link, REML. The data-set and
#' era coefficients carry the scorer's normal prior (`prior_sd`): where the two
#' nearly coincide (steelhead's FDIS visits are its 1995-2004 visits) an
#' unpenalised fit sends them to about +-30 with offsetting signs, and a
#' held-out group that mixes the combinations takes one of those offsets. A distance the walk
#' did not find (`Inf`) is censored at `dist_cap_m`, and distance enters as
#' `log(dist + 10)`. The model is one surface, never a product of one-variable
#' curves, so a size effect that only holds far from a river is not counted
#' twice.
#'
#' Its held-out deviance is reported on the scorer's own folds: the fixed terms
#' are refit on the other folds, and each held-out group refits only its own
#' intercept, as the grid's rules did, so the two numbers compare.
#'
#' @param d the scoring population, with `resp`, `wsg`, `log_area`, `data_set`,
#'   `era`, `blue_line_key`, `downstream_route_measure` and the columns `cols`
#'   name.
#' @param pick one row of the scored grid: `size_var`, `size_min`, `grad_max`,
#'   `exc_q`, `exc_d`. With no exception, distance is to a river of `q_default`.
#' @param walks the index [knw_walk_index()] returns.
#' @param folds the named fold of each group, as [knw_tune_score()] returns it.
#' @param resp,cols,src as in [knw_rule_in()].
#' @param dist_cap_m,q_default,k `numeric` the spec's constants: the distance
#'   cap, the river size when the pick has no exception, and the basis sizes
#'   (`size`, `dist`, `grad`).
#' @param edge_stream `integer` or `NULL`: the FWA edge types the visits in `d`
#'   were filtered on, recorded on the result as `edge_stream` so the grade's
#'   reference population can be taken from the curve (#72).
#' @param prior_sd `numeric(1)` the standard deviation, on the cloglog scale,
#'   of a normal prior on the `data_set` and `era` coefficients, as in
#'   [knw_tune_score()]: a fixed penalty `b^2 / prior_sd^2` per coefficient.
#'   `Inf` for none (the curve before #73's Phase 7).
#' @return A list: `model` (the `mgcv::gam`), `data` (the rows fitted, with
#'   `log_size`, `log_dist`, `grad`), `ref` (the reference nuisance values a
#'   segment is predicted at: median `log_area`, modal `data_set`, latest `era`),
#'   `dropped` (visits with no size or gradient), `capped` (visits kept at the
#'   distance cap: no walk, or no river found), `heldout` (summed
#'   held-out deviance), `edf` (the smooths' effective degrees of freedom), and
#'   `curves`, a `tibble` of marginal curves (`curve`, `x`, `rate`, `rel_rate`,
#'   `rel_lo`, `rel_hi`, `threshold`) relative to the pick's thresholds, each
#'   other variable held at its reference; `edge_stream`, as given; `dist_in_model`, `FALSE` when the
#'   distances were too few to carry a smooth and size stood alone; `prior_sd` and `cols`, as given (`cols[["grad"]]`
#'   is the gradient the curve was fitted on, which a grade table records, #92).
#' @export
#' @examples
#' \dontrun{
#' s <- knw_tune_score(d, rule_in, grid, "U")
#' cv <- knw_tune_curve(d, s$rules[s$rules$recommended, ], knw_walk_index(walks), s$folds)
#' cv$heldout; cv$edf
#' }
knw_tune_curve <- function(d, pick, walks, folds, resp = "U",
                           cols = c(grad = "segment_gradient", width = "cw_deploy", mad = "mad_pick"), src = "pick",
                           dist_cap_m = 50000, q_default = 10, k = c(size = 6, dist = 6, grad = 6),
                           edge_stream = NULL, prior_sd = 2.5) {
  chk::chk_data(d)
  chk::chk_number(prior_sd)
  if (prior_sd <= 0) stop("prior_sd must be positive (Inf for no prior)", call. = FALSE)
  chk::check_names(d, c(resp, "wsg", "log_area", "data_set", "era", "blue_line_key", "downstream_route_measure",
                        unname(cols)))
  chk::check_names(pick, c("size_var", "size_min", "grad_max", "exc_q", "exc_d"))
  if (nrow(pick) != 1L) stop("pick must be one row", call. = FALSE)
  if (!requireNamespace("mgcv", quietly = TRUE)) stop("mgcv is needed", call. = FALSE)
  q <- if (is.na(pick$exc_q)) q_default else pick$exc_q
  e <- walks[[paste(src, q, sep = "|")]]
  if (is.null(e)) stop("no walks on ", src, " at ", q, " m3/s", call. = FALSE)
  size_col <- cols[[if (pick$size_var == "width") "width" else "mad"]]
  d$wsg <- factor(d$wsg)
  d$data_set <- factor(d$data_set)
  d$era <- factor(d$era)
  m <- match(paste(d$blue_line_key, d$downstream_route_measure), e$pt)
  dist <- e$dist[m]
  d$log_dist <- log(pmin(ifelse(is.finite(dist), dist, dist_cap_m), dist_cap_m) + 10)
  d$log_size <- log(d[[size_col]])
  d$grad <- pmin(pmax(d[[cols[["grad"]]]], 0), 0.2)
  ok <- is.finite(d$log_size) & !is.na(d$grad) & !is.na(d$log_dist)
  dropped <- c(no_size = sum(!is.finite(d$log_size)), no_gradient = sum(is.na(d$grad)))
  capped <- c(no_walk_at_cap = sum(is.na(m)), no_river_at_cap = sum(!is.na(m) & !is.finite(dist)))
  dd <- .tune_modelled(d[ok, , drop = FALSE], resp)
  nuis <- c("log_area", "data_set", "era")
  nuis <- nuis[vapply(nuis, function(t) length(unique(dd[[t]])) > 1L, logical(1))]
  # the distance smooth needs distinct distances; with too few (every walk the same) size stands alone
  k_dist <- min(k[["dist"]], length(unique(dd$log_dist)) - 1L)
  dist_in_model <- k_dist >= 3L
  smooths <- function(nu) {
    paste0(if (dist_in_model) sprintf("te(log_size, log_dist, k = c(%d, %d))", k[["size"]], k_dist)
           else sprintf("s(log_size, k = %d)", k[["size"]]),
           sprintf(" + s(grad, k = %d)", k[["grad"]]),
           if (length(nu)) paste0(" + ", paste(nu, collapse = " + ")) else "")
  }
  # the prior: a fixed penalty b^2 / prior_sd^2 on each data-set and era coefficient (mgcv's paraPen with its
  # smoothing parameter supplied, so REML estimates only the smooths')
  pen <- function(nu, x) {
    pt <- intersect(c("data_set", "era"), nu)
    if (!is.finite(prior_sd) || !length(pt)) return(NULL)
    stats::setNames(lapply(pt, function(t) list(diag(nlevels(x[[t]]) - 1L), sp = 1 / prior_sd^2)), pt)
  }
  fit <- mgcv::gam(stats::as.formula(paste(resp, "~", smooths(nuis), "+ s(wsg, bs = 're')")),
                   family = stats::binomial(link = "cloglog"), data = dd, method = "REML", paraPen = pen(nuis, dd))
  # the reference era is the latest one present, in the eras' own order where the levels are the
  # scorer's three; otherwise the last level
  era_order <- c("to1994", "1995-2004", "2005on")
  era_ref <- if (all(levels(dd$era) %in% era_order)) {
    era_order[max(match(levels(dd$era), era_order))]
  } else {
    utils::tail(levels(dd$era), 1)
  }
  ref <- list(log_area = stats::median(dd$log_area),
              data_set = names(which.max(table(dd$data_set))),
              era = era_ref)
  edf <- summary(fit)$s.table[, "edf"]

  # held-out deviance on the scorer's folds: fixed terms refit on the other folds, each held-out
  # group its own intercept (`.tune_group_dev()`, as the scorer fits it)
  fo <- folds[as.character(dd$wsg)]
  if (anyNA(fo)) stop("a modelled group has no fold", call. = FALSE)
  dev <- 0
  fam <- stats::binomial(link = "cloglog")
  for (kf in sort(unique(fo))) {
    tr <- dd[fo != kf, , drop = FALSE]
    ho <- dd[fo == kf, , drop = FALSE]
    # the fit knows only the levels the training fold holds, so drop the rest before fitting
    tr$wsg <- droplevels(tr$wsg)
    tr$data_set <- droplevels(tr$data_set)
    tr$era <- droplevels(tr$era)
    nu <- nuis[vapply(nuis, function(t) length(unique(tr[[t]])) > 1L, logical(1))]
    mk <- mgcv::gam(stats::as.formula(paste(resp, "~", smooths(nu), "+ s(wsg, bs = 're')")), family = fam,
                    data = tr, method = "REML", paraPen = pen(nu, tr))
    # a held-out level unseen in training takes the training mode, and the held-out factors carry
    # exactly the training levels
    for (t in c("data_set", "era")) {
      lv <- as.character(ho[[t]])
      lv[!lv %in% levels(tr[[t]])] <- names(which.max(table(tr[[t]])))
      ho[[t]] <- factor(lv, levels = levels(tr[[t]]))
    }
    ho$wsg <- factor(as.character(tr$wsg[1]), levels = levels(tr$wsg))
    eta <- as.numeric(mgcv::predict.gam(mk, newdata = ho, type = "link", exclude = "s(wsg)", newdata.guaranteed = TRUE))
    y <- ho[[resp]]
    for (w in unique(as.character(dd$wsg[fo == kf]))) {
      i <- which(as.character(dd$wsg[fo == kf]) == w)
      dev <- dev + sum(.tune_group_dev(y[i], eta[i], fam))
    }
  }

  # marginal curves at the reference, relative to the pick's thresholds
  thr_size <- pick$size_min
  thr_dist <- if (is.na(pick$exc_d)) 500 else pick$exc_d
  base <- function(n) {
    nd <- data.frame(log_area = rep(ref$log_area, n), data_set = factor(ref$data_set, levels = levels(dd$data_set)),
                     era = factor(ref$era, levels = levels(dd$era)),
                     wsg = factor(levels(dd$wsg)[1], levels = levels(dd$wsg)))
    nd$log_size <- log(thr_size)
    nd$log_dist <- log(dist_cap_m + 10)
    nd$grad <- min(pick$grad_max, 0.2) / 2
    nd
  }
  curve_of <- function(label, var, xs, thr, transform = identity) {
    nd <- base(length(xs))
    nd[[var]] <- xs
    pr <- mgcv::predict.gam(fit, newdata = nd, type = "link", se.fit = TRUE, exclude = "s(wsg)",
                            newdata.guaranteed = TRUE)
    at <- stats::approx(xs, as.numeric(pr$fit), xout = thr)$y
    tibble::tibble(curve = label, x = transform(xs), rate = fam$linkinv(as.numeric(pr$fit)),
                   rel_rate = exp(as.numeric(pr$fit) - at),
                   rel_lo = exp(as.numeric(pr$fit) - 1.96 * as.numeric(pr$se.fit) - at),
                   rel_hi = exp(as.numeric(pr$fit) + 1.96 * as.numeric(pr$se.fit) - at), threshold = transform(thr))
  }
  rs <- range(dd$log_size)
  curves <- rbind(
    curve_of(paste0("size_", pick$size_var), "log_size", seq(rs[1], rs[2], length.out = 120), log(thr_size), exp),
    curve_of("gradient", "grad", seq(0, 0.2, length.out = 120), pick$grad_max),
    curve_of(sprintf("dist_to_Q%g_m", q), "log_dist", seq(log(20), log(dist_cap_m + 10), length.out = 120),
             log(thr_dist + 10), function(x) exp(x) - 10)
  )
  list(model = fit, data = dd, ref = ref, dropped = dropped, capped = capped, heldout = dev, edf = edf, curves = curves,
       size_var = pick$size_var, q = q, dist_cap_m = dist_cap_m, dist_in_model = dist_in_model,
       edge_stream = if (is.null(edge_stream)) NULL else as.integer(edge_stream), prior_sd = prior_sd, cols = cols)
}
