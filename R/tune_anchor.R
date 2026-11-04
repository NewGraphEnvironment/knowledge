#' How far each starting point moved the pick from the best-scoring rule
#'
#' The pick is the one-SE region's rule with the fewest departures from a
#' starting point ([knw_tune_score()]), so where the data cannot rank several
#' rules apart, the start chooses between them. This sets the two picks a
#' tuning table holds beside the rule the data score best, and counts how far
#' apart they are, so how much a baseline steered a published rule is a number
#' rather than a reading (#141, #139).
#'
#' The picks are the `recommended` rules, the ones published: from link's
#' `default` (`recommended`) and from its flow version (`recommended_flow`,
#' #80). The best is every rule at `ddev_best == 0`: rules with the same in/out
#' on every visit are one fit and tie, so `rule_best` is the first of them in
#' grid order (as `scripts/0320`'s summary names it), `best_n` counts them, and a
#' pick's distance to the best is its fewest departures from any of them. Two
#' rules depart in the three parts the grid counts ([knw_tune_grid()]): the size
#' test (its variable or floor), the gradient maximum and the exception (its
#' river size or distance, or one having it and the other not).
#'
#' @param tune a tuning table as [knw_tune_score()] returns it or
#'   `scripts/0320` saves it (`<sp>_<stage>_tune.csv`, read as text or typed):
#'   `rule`, `size_var`, `size_min`, `grad_max`, `exc_q`, `exc_d`,
#'   `recommended`, `ddev_best` and `se_diff`, and `recommended_flow` where the
#'   table has a flow start.
#' @return One row: `rule_recommended`, `recommended_ddev` and `recommended_se`
#'   (the pick from `default`, its distance behind the best and that distance's
#'   SE); the same for the flow start (`rule_recommended_flow`,
#'   `recommended_flow_ddev`, `recommended_flow_se`; `NA` with no flow start);
#'   `rule_best` and `best_n`; `rec_moved` and `flow_moved` (each pick's
#'   departures from the best, 0 to 3) and `starts_apart` (between the two
#'   picks), each with its parts (`rec_moved_parts` and so on: `size`,
#'   `gradient` and `exception` joined by `+`, or `none`); `rec_is_best`,
#'   `flow_is_best` and `starts_agree`.
#' @export
#' @examples
#' tune <- data.frame(
#'   rule = c("width>=1.5|g<=0.0549|none", "width>=2|g<=0.0549|none", "mad>=0.5|g<=0.0549|none",
#'            "width>=1|g<=0.0549|Q50@D500"),
#'   size_var = c("width", "width", "mad", "width"), size_min = c(1.5, 2, 0.5, 1), grad_max = 0.0549,
#'   exc_q = c(NA, NA, NA, 50), exc_d = c(NA, NA, NA, 500),
#'   recommended = c(FALSE, TRUE, FALSE, FALSE), recommended_flow = c(FALSE, FALSE, TRUE, FALSE),
#'   ddev_best = c(20, 5.7, 11.6, 0), se_diff = c(9, 10.4, 13.9, 0)
#' )
#' # from default the pick is two parts from the best (its width floor and the exception),
#' # and the flow start picks another rule, one part from it
#' knw_tune_anchor(tune)[, c("rule_recommended", "rec_moved", "rec_moved_parts", "rule_recommended_flow",
#'                           "starts_apart", "starts_apart_parts")]
knw_tune_anchor <- function(tune) {
  chk::chk_data(tune)
  chk::check_names(tune, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d", "recommended",
                           "ddev_best", "se_diff"))
  # a saved table read as text carries "TRUE"; a scored one carries TRUE
  is_true <- function(x) x %in% c(TRUE, "TRUE")
  num <- function(x) as.numeric(x)
  rec <- which(is_true(tune$recommended))
  if (length(rec) != 1) stop("tune has ", length(rec), " recommended rules, not 1", call. = FALSE)
  flow <- if ("recommended_flow" %in% names(tune)) which(is_true(tune$recommended_flow)) else integer()
  if (length(flow) > 1) stop("tune has ", length(flow), " recommended_flow rules, not 0 or 1", call. = FALSE)
  ddev <- num(tune$ddev_best)
  best <- which(ddev %in% 0)
  if (!length(best)) stop("tune has no rule at ddev_best 0", call. = FALSE)
  size_min <- num(tune$size_min)
  grad_max <- num(tune$grad_max)
  exc_q <- num(tune$exc_q)
  exc_d <- num(tune$exc_d)
  same <- function(a, b) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & a == b)
  parts <- function(i, j) {
    c(size = tune$size_var[i] != tune$size_var[j] || size_min[i] != size_min[j],
      gradient = grad_max[i] != grad_max[j],
      exception = !(same(exc_q[i], exc_q[j]) && same(exc_d[i], exc_d[j])))
  }
  label <- function(p) if (any(p)) paste(names(p)[p], collapse = "+") else "none"
  # fewest departures from any rule tied at the best, the first such rule in grid order naming the parts
  to_best <- function(i) {
    ps <- lapply(best, function(b) parts(i, b))
    p <- ps[[which.min(vapply(ps, sum, numeric(1)))]]
    list(n = as.integer(sum(p)), parts = label(p))
  }
  rb <- to_best(rec)
  out <- data.frame(rule_recommended = tune$rule[rec], recommended_ddev = ddev[rec],
                    recommended_se = num(tune$se_diff[rec]),
                    rule_recommended_flow = NA_character_, recommended_flow_ddev = NA_real_,
                    recommended_flow_se = NA_real_,
                    rule_best = tune$rule[best[1]], best_n = length(best),
                    rec_moved = rb$n, rec_moved_parts = rb$parts,
                    flow_moved = NA_integer_, flow_moved_parts = NA_character_,
                    starts_apart = NA_integer_, starts_apart_parts = NA_character_,
                    rec_is_best = ddev[rec] == 0, flow_is_best = NA, starts_agree = NA,
                    stringsAsFactors = FALSE)
  if (length(flow)) {
    fb <- to_best(flow)
    pa <- parts(rec, flow)
    out$rule_recommended_flow <- tune$rule[flow]
    out$recommended_flow_ddev <- ddev[flow]
    out$recommended_flow_se <- num(tune$se_diff[flow])
    out$flow_moved <- fb$n
    out$flow_moved_parts <- fb$parts
    out$starts_apart <- as.integer(sum(pa))
    out$starts_apart_parts <- label(pa)
    out$flow_is_best <- ddev[flow] == 0
    out$starts_agree <- rec == flow
  }
  out
}
