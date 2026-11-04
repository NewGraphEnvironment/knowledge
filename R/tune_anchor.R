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
#' pick's distance to the best is its fewest departures from any of them, the
#' first such rule in grid order naming the parts. Two rules depart in the three
#' parts the grid counts ([knw_tune_grid()]): the size test (its variable or
#' floor), the gradient maximum and the exception (its river size or distance,
#' or one having it and the other not).
#'
#' No pick may carry an exception closer than `d_floor`, but the best may, and
#' then no start could reach it: part of the distance is the floor's, not the
#' start's. So each pick is also measured against the **best allowed** rule, the
#' best-scoring rule a pick may be: the lowest-scoring rule in the region (which
#' holds converged rules only) with no exception or one at `d_floor` or more
#' (ties as above). It is the best itself wherever `best_is_allowed`; the best is
#' not allowed when its exception is under the floor, or when it did not
#' converge (the best is the lowest score over every rule).
#'
#' @param tune a tuning table as [knw_tune_score()] returns it or
#'   `scripts/0320` saves it (`<sp>_<stage>_tune.csv`, read as text or typed):
#'   `rule`, `size_var`, `size_min`, `grad_max`, `exc_q`, `exc_d`,
#'   `in_region`, `recommended`, `ddev_best` and `se_diff`; and `departures_flow` with
#'   `recommended_flow` where the table has a flow start (a table from before
#'   #80, or a species with no flow start, has none).
#' @param d_floor `numeric(1)` the shortest exception distance (m) a pick may
#'   carry; [knw_tune_score()]'s own by default, so the register's one value
#'   (`inst/method/settings.csv`) holds for both.
#' @return One row: `rule_recommended`, `recommended_ddev` and `recommended_se`
#'   (the pick from `default`, its distance behind the best and that distance's
#'   SE); the same for the flow start (`rule_recommended_flow`,
#'   `recommended_flow_ddev`, `recommended_flow_se`; `NA` with no flow start);
#'   `rule_best` and `best_n`; `rule_best_allowed`, `best_allowed_ddev` and
#'   `best_is_allowed`; `rec_moved` and `flow_moved` (each pick's departures from
#'   the best, 0 to 3), `rec_moved_allowed` and `flow_moved_allowed` (from the
#'   best allowed) and `starts_apart` (between the two picks), each with its
#'   parts (`rec_moved_parts` and so on: `size`, `gradient` and `exception`
#'   joined by `+`, or `none`); `rec_is_best`, `flow_is_best` (the pick is tied
#'   at the best) and `starts_agree`.
#' @export
#' @examples
#' tune <- data.frame(
#'   rule = c("width>=1.5|g<=0.0549|none", "width>=2|g<=0.0549|none", "mad>=0.5|g<=0.0549|none",
#'            "width>=1|g<=0.0549|Q50@D500"),
#'   size_var = c("width", "width", "mad", "width"), size_min = c(1.5, 2, 0.5, 1), grad_max = 0.0549,
#'   exc_q = c(NA, NA, NA, 50), exc_d = c(NA, NA, NA, 500),
#'   departures_flow = c(1L, 1L, 0L, 2L), in_region = c(FALSE, TRUE, TRUE, TRUE),
#'   recommended = c(FALSE, TRUE, FALSE, FALSE), recommended_flow = c(FALSE, FALSE, TRUE, FALSE),
#'   ddev_best = c(20, 5.7, 11.6, 0), se_diff = c(9, 10.4, 13.9, 0)
#' )
#' # from default the pick is two parts from the best (its width floor and the exception),
#' # and the flow start picks another rule, one part from it
#' knw_tune_anchor(tune)[, c("rule_recommended", "rec_moved", "rec_moved_parts", "rule_recommended_flow",
#'                           "starts_apart", "starts_apart_parts")]
knw_tune_anchor <- function(tune, d_floor = formals(knw_tune_score)$d_floor) {
  chk::chk_data(tune)
  chk::check_names(tune, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d", "in_region", "recommended",
                           "ddev_best", "se_diff"))
  chk::chk_number(d_floor)
  # a saved table read as text carries "TRUE"; a scored one carries TRUE
  is_true <- function(x) x %in% c(TRUE, "TRUE")
  num <- function(x) as.numeric(x)
  rec <- which(is_true(tune$recommended))
  if (length(rec) != 1) stop("tune has ", length(rec), " recommended rules, not 1", call. = FALSE)
  # a flow start is a departures_flow column with values (knw_tune_repick()'s test); it then names one pick
  flow_start <- "departures_flow" %in% names(tune) && !all(is.na(tune$departures_flow))
  flow <- integer()
  if (flow_start) {
    flow <- if ("recommended_flow" %in% names(tune)) which(is_true(tune$recommended_flow)) else integer()
    if (length(flow) != 1) stop("tune has a flow start and ", length(flow), " recommended_flow rules, not 1", call. = FALSE)
  }
  ddev <- num(tune$ddev_best)
  best <- which(ddev %in% 0)
  if (!length(best)) stop("tune has no rule at ddev_best 0", call. = FALSE)
  exc_d <- num(tune$exc_d)
  # the rules a pick may be (.tune_pick()): in the region (which carries convergence) and clear of the floor; the
  # recommended rule is always one, so the set is never empty
  allowed <- which(is_true(tune$in_region) & (is.na(exc_d) | exc_d >= d_floor))
  if (!rec %in% allowed) stop("tune's recommended rule is outside the region or under d_floor", call. = FALSE)
  allowed <- allowed[ddev[allowed] %in% min(ddev[allowed])]
  label <- function(p) if (any(p)) paste(names(p)[p], collapse = "+") else "none"
  # fewest departures from any rule of a tied set, the first such rule in grid order naming the parts
  to_set <- function(i, set) {
    ps <- lapply(set, function(b) .knw_rule_parts(tune, i, b))
    p <- ps[[which.min(vapply(ps, sum, numeric(1)))]]
    list(n = as.integer(sum(p)), parts = label(p))
  }
  rb <- to_set(rec, best)
  ra <- to_set(rec, allowed)
  out <- data.frame(rule_recommended = tune$rule[rec], recommended_ddev = ddev[rec],
                    recommended_se = num(tune$se_diff[rec]),
                    rule_recommended_flow = NA_character_, recommended_flow_ddev = NA_real_,
                    recommended_flow_se = NA_real_,
                    rule_best = tune$rule[best[1]], best_n = length(best),
                    rule_best_allowed = tune$rule[allowed[1]], best_allowed_ddev = ddev[allowed[1]],
                    best_is_allowed = ddev[allowed[1]] == 0,
                    rec_moved = rb$n, rec_moved_parts = rb$parts,
                    rec_moved_allowed = ra$n, rec_moved_allowed_parts = ra$parts,
                    flow_moved = NA_integer_, flow_moved_parts = NA_character_,
                    flow_moved_allowed = NA_integer_, flow_moved_allowed_parts = NA_character_,
                    starts_apart = NA_integer_, starts_apart_parts = NA_character_,
                    rec_is_best = ddev[rec] == 0, flow_is_best = NA, starts_agree = NA,
                    stringsAsFactors = FALSE)
  if (flow_start) {
    fb <- to_set(flow, best)
    fa <- to_set(flow, allowed)
    pa <- .knw_rule_parts(tune, rec, flow)
    out$rule_recommended_flow <- tune$rule[flow]
    out$recommended_flow_ddev <- ddev[flow]
    out$recommended_flow_se <- num(tune$se_diff[flow])
    out$flow_moved <- fb$n
    out$flow_moved_parts <- fb$parts
    out$flow_moved_allowed <- fa$n
    out$flow_moved_allowed_parts <- fa$parts
    out$starts_apart <- as.integer(sum(pa))
    out$starts_apart_parts <- label(pa)
    out$flow_is_best <- ddev[flow] == 0
    out$starts_agree <- rec == flow
  }
  out
}

# which of the three parts rules i and j of a grid differ in, as knw_tune_grid() counts departures: the size test (its
# variable or floor), the gradient maximum, and the exception (its river size or distance, or one having it)
.knw_rule_parts <- function(g, i, j) {
  num <- function(x) as.numeric(x)
  same <- function(a, b) (is.na(a) && is.na(b)) || (!is.na(a) && !is.na(b) && a == b)
  c(size = g$size_var[i] != g$size_var[j] || num(g$size_min[i]) != num(g$size_min[j]),
    gradient = num(g$grad_max[i]) != num(g$grad_max[j]),
    exception = !(same(num(g$exc_q[i]), num(g$exc_q[j])) && same(num(g$exc_d[i]), num(g$exc_d[j]))))
}
