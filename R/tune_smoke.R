#' Score a handful of rules and gate the scorer before a full tuning run
#'
#' Twice in #73 a scorer defect showed in the first minutes of a tuning run's
#' output and was found only after hours had been spent on it (#84). This scores
#' the rules a defect shows on, no rule, `default`, link's `default_tuned` row
#' where the grid carries one (`is_link_tuned`), and the previous pick where
#' one is given, on the main fold seed alone, with [knw_tune_score()]'s fold
#' setup and fits, and checks four things, each a hard stop in
#' [knw_tune_run()]:
#'
#' 1. `null_ratio`: the no-rule model's held-out deviance over the in-sample
#'    null deviance on the same visits (each group at its own rate) is at most
#'    `1 + tol_null`. The held-out model refits each group's intercept on its
#'    own visits, so it can exceed the in-sample null only through the nuisance
#'    offsets it takes from training, never by multiples (grayling's no-rule
#'    model scored 8,397.5 held-out against about 848 on 2026-10-23).
#' 2. `clamp`: no visit's held-out deviance sits at the clamp,
#'    `-2 log(1e-12)` = 55.26, which is where a group intercept the search did
#'    not find puts every visit.
#' 3. `behind_null`: no rule's held-out deviance exceeds the no-rule model's by
#'    more than the no-rule deviance itself.
#' 4. `coef`: no training fit's non-group coefficient (the nuisance terms and
#'    the rule, on the cloglog scale) exceeds `coef_max` in size. The training
#'    fit is the same whatever the intercept search does, so this check reads
#'    the model, not the fix: a fold whose `data_set` and `era` coefficients
#'    sat near 13 was where the search stuck. On the eight keys of 2026-10-23
#'    the sound fits' largest coefficient was 3.63 and the separated fits'
#'    smallest 9.65, so the limit is 5: a hazard ratio past e^5 between data
#'    sets or eras is separation, not a measured effect.
#'
#' @inheritParams knw_tune_score
#' @param previous `NULL`, or `character(1)` the rule string of the previous
#'   pick, which must be in `grid`.
#' @param tol_null `numeric(1)` check 1's tolerance.
#' @param coef_max `numeric(1)` check 4's limit.
#' @return A list: `rules`, one row per smoke rule (`role`, `rule`,
#'   `dev_heldout`, `ddev_null`, `n_clamp`, `dev_visit_max`, `converged`,
#'   `coef_max`, `coef_max_term`, `coef_max_fold`); `checks`, one row per check
#'   (`check`, `value`, `limit`, `pass`); `pass`, whether every check passed;
#'   `null_insample` and `null_heldout`; `lines`, the report as text; and
#'   `population`, counts.
#' @export
#' @examples
#' set.seed(1)
#' d <- data.frame(wsg = factor(rep(sprintf("W%02d", 1:8), each = 30)),
#'                 log_area = log(runif(240, 20, 400)), data_set = factor("FDIS"),
#'                 era = factor("2005on"), size = runif(240, 0.05, 3))
#' d$U <- rbinom(240, 1, plogis(-3 + 1.5 * (d$size > 0.5)))
#' grid <- data.frame(rule = c("default", "tuned"), size_var = "mad", size_min = c(0.1, 0.5),
#'                    grad_max = 0.05, exc_q = NA, exc_d = NA, departures = c(0L, 1L),
#'                    is_default = c(TRUE, FALSE))
#' sm <- knw_tune_smoke(d, function(d, r) d$size >= r$size_min, grid, "U", previous = "tuned", seed = 1)
#' sm$checks
#' cat(sm$lines, sep = "\n")
knw_tune_smoke <- function(d, rule_in, grid, resp = "U", previous = NULL, seed = 54L, folds = 5L,
                           tol_null = 0.25, coef_max = 5) {
  chk::chk_data(d)
  chk::check_names(d, c(resp, "wsg", "log_area", "data_set", "era"))
  chk::chk_function(rule_in)
  chk::chk_data(grid)
  chk::check_names(grid, c("rule", "is_default"))
  chk::chk_null_or(previous, vld = chk::vld_string)
  chk::chk_whole_number(folds)
  chk::chk_number(tol_null)
  chk::chk_number(coef_max)
  if (sum(grid$is_default) != 1L) stop("grid must hold exactly one default rule", call. = FALSE)
  if (!is.null(previous) && !previous %in% grid$rule) {
    stop("the previous pick ", previous, " is not in the grid", call. = FALSE)
  }
  if (!is.factor(d$wsg)) d$wsg <- factor(d$wsg)
  if (!is.factor(d$data_set)) d$data_set <- factor(d$data_set)
  if (!is.factor(d$era)) d$era <- factor(d$era)

  n_all <- nrow(d)
  d <- .tune_modelled(d, resp)
  if (nlevels(d$wsg) < folds) {
    stop("only ", nlevels(d$wsg), " groups with both outcomes; ", folds, " folds need at least that many",
         call. = FALSE)
  }
  ix <- c(default = which(grid$is_default))
  if ("is_link_tuned" %in% names(grid) && any(grid$is_link_tuned %in% TRUE)) {
    ix <- c(ix, link_tuned = which(grid$is_link_tuned %in% TRUE))
  }
  if (!is.null(previous)) ix <- c(ix, previous = match(previous, grid$rule))
  pats <- c(list(no_rule = rep(FALSE, nrow(d))),
            lapply(ix, function(i) as.logical(rule_in(d, grid[i, , drop = FALSE]))))
  if (anyNA(unlist(pats))) stop("rule_in returned NA", call. = FALSE)
  # rules with one in/out are one fit, as the scorer fits them
  key <- vapply(pats, function(x) paste(packBits(c(x, logical((8 - length(x) %% 8) %% 8))), collapse = ""), "")
  u <- !duplicated(key)
  fold_of <- .tune_fold_of_wsg(d, resp, seed, folds)
  fs <- .tune_fold_setup(d, resp, fold_of, folds)
  sc <- lapply(pats[u], .tune_score_one, folds = fs)[match(key, key[u])]
  names(sc) <- names(pats)
  y <- d[[resp]]
  null_in <- .tune_null_insample(y, d$wsg)
  null_ho <- sum(sc[["no_rule"]]$dev)
  # a visit at either clamp: -2 log(1e-12) for a detection at p = 1e-12, and in floating point 55.26209 for a
  # non-detection at p = 1 - 1e-12; nothing else reaches 55.26
  clamp <- -2 * log(1e-12)
  at_clamp <- function(dv) sum(dv >= clamp - 1e-3)
  rules <- do.call(rbind, lapply(names(sc), function(nm) {
    s <- sc[[nm]]
    cf <- do.call(rbind, lapply(seq_along(s$coef), function(k) {
      data.frame(fold = k, term = names(s$coef[[k]]), value = unname(s$coef[[k]]))
    }))
    cf <- cf[!is.na(cf$value), , drop = FALSE]
    top <- data.frame(fold = NA_integer_, term = NA_character_, value = NA_real_)
    if (nrow(cf)) top <- cf[which.max(abs(cf$value)), ]
    data.frame(role = nm, rule = if (nm == "no_rule") "none" else grid$rule[ix[[nm]]],
               dev_heldout = sum(s$dev), ddev_null = sum(s$dev) - null_ho,
               n_clamp = at_clamp(s$dev), dev_visit_max = max(s$dev), converged = s$ok,
               coef_max = abs(top$value), coef_max_term = top$term, coef_max_fold = top$fold,
               stringsAsFactors = FALSE)
  }))
  checks <- data.frame(
    check = c("null_ratio", "clamp", "behind_null", "coef"),
    value = c(null_ho / null_in, sum(rules$n_clamp), max(rules$ddev_null), max(rules$coef_max, na.rm = TRUE)),
    limit = c(1 + tol_null, 0, null_ho, coef_max),
    stringsAsFactors = FALSE
  )
  checks$pass <- checks$value <= checks$limit
  worst <- rules[which.max(rules$coef_max), ]
  behind <- rules[which.max(rules$ddev_null), ]
  verdict <- function(k) if (checks$pass[checks$check == k]) "pass" else "FAIL"
  lines <- c(
    sprintf("smoke: %d visits (%d detections) in %d groups with both outcomes; %d rules, %d fits.",
            nrow(d), sum(y), nlevels(d$wsg), length(pats), sum(u)),
    sprintf("  null_ratio: no rule %.1f held-out against %.1f in-sample, ratio %.3f (limit %.2f): %s",
            null_ho, null_in, null_ho / null_in, 1 + tol_null, verdict("null_ratio")),
    sprintf("  clamp: %d visits at %.2f over %d rules (limit 0): %s", sum(rules$n_clamp), clamp, nrow(rules),
            verdict("clamp")),
    sprintf("  behind_null: %s (%s) is %+.1f against no rule (limit %.1f): %s", behind$role, behind$rule,
            behind$ddev_null, null_ho, verdict("behind_null")),
    sprintf("  coef: %s %.2f on fold %d of %s (%s) (limit %.1f): %s", worst$coef_max_term, worst$coef_max,
            worst$coef_max_fold, worst$role, worst$rule, coef_max, verdict("coef")),
    sprintf("  %s: %s held-out %.1f (%+.1f against no rule), converged %s", rules$role, rules$rule, rules$dev_heldout,
            rules$ddev_null, rules$converged)[-1]
  )
  list(rules = tibble::as_tibble(rules), checks = tibble::as_tibble(checks), pass = all(checks$pass),
       null_insample = null_in, null_heldout = null_ho, lines = lines,
       population = c(visits_in = n_all, visits_modelled = nrow(d), detections = sum(y), groups = nlevels(d$wsg)))
}

# the in-sample null deviance over groups: each group at its own rate (the groups have both outcomes)
.tune_null_insample <- function(y, g) {
  p <- stats::ave(y, g)
  sum(-2 * (y * log(p) + (1 - y) * log(1 - p)))
}
