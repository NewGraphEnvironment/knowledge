#' Pick a rule again from a tuning table, at another width of the region
#'
#' [knw_tune_score()] keeps every rule whose held-out score is within one
#' standard error of the best (the region) and picks the region rule with the
#' fewest departures from `default`, ties to the lower score, moving off a pick
#' whose exception distance is under `d_floor`. One standard error is a
#' parsimony rule of thumb fixed before the run, not a boundary of noise; this
#' replays the same pick from the saved table at any multiple of the standard
#' error, so a reader can see which picks hold under a stricter bar (1.96).
#'
#' The region is `converged & ddev_best <= se_mult * se_diff`, which at
#' `se_mult = 1` is the table's own `in_region`, so the pick at 1 is the
#' table's `recommended` rule.
#'
#' @param tune a tuning table as [knw_tune_score()] returns it and `scripts/0320`
#'   saves it (`<sp>_<stage>_tune.csv`), in grid order: `rule`, `departures`,
#'   `exc_d`, `converged`, `dev_heldout`, `ddev_best` and `se_diff`.
#' @param se_mult `numeric(1)` the region's width in standard errors.
#' @param d_floor `numeric(1)` the shortest exception distance (m) a
#'   recommended rule may carry, as in [knw_tune_score()].
#' @param start `"default"` counts departures from link's `default` (the
#'   table's `departures`); `"flow"` from its flow version (`departures_flow`,
#'   [knw_tune_grid()]; #80), and is refused on a table without that column or
#'   whose species has no flow start.
#' @return The recommended row of `tune` (one row), with `n_region`, the number
#'   of rules in the region at `se_mult`.
#' @export
#' @examples
#' tune <- data.frame(
#'   rule = c("width>=1.5|g<=0.0549|none", "mad>=0.75|g<=0.09|Q3@D1000", "mad>=0.75|g<=0.0549|none"),
#'   departures = c(0L, 3L, 1L), exc_d = c(NA, 1000, NA), converged = TRUE,
#'   dev_heldout = c(1150, 1000, 1040), ddev_best = c(150, 0, 40), se_diff = c(60, 0, 25)
#' )
#' knw_tune_repick(tune)$rule              # 1 SE: only the best rule is close enough
#' knw_tune_repick(tune, se_mult = 1.96)$rule  # 1.96 SE: the one-departure rule joins, and is picked
knw_tune_repick <- function(tune, se_mult = 1, d_floor = 200, start = c("default", "flow")) {
  start <- match.arg(start)
  chk::chk_data(tune)
  chk::check_names(tune, c("rule", "departures", "exc_d", "converged", "dev_heldout", "ddev_best", "se_diff"))
  chk::chk_number(se_mult)
  chk::chk_gte(se_mult, 0)
  chk::chk_number(d_floor)
  dep <- tune$departures
  if (start == "flow") {
    if (!"departures_flow" %in% names(tune) || all(is.na(tune$departures_flow))) {
      stop("tune carries no departures_flow: the table predates #80 or the species has no flow start", call. = FALSE)
    }
    dep <- tune$departures_flow
  }
  rr <- which(tune$converged %in% TRUE & tune$ddev_best <= se_mult * tune$se_diff)
  if (!length(rr)) stop("no converged rule in the region", call. = FALSE)
  rr <- rr[order(dep[rr], tune$dev_heldout[rr])]
  p <- rr[1]
  ok_d <- rr[is.na(tune$exc_d[rr]) | tune$exc_d[rr] >= d_floor]
  rec <- if (!is.na(tune$exc_d[p]) && tune$exc_d[p] < d_floor) ok_d[1] else p
  if (is.na(rec)) stop("every region rule carries an exception under d_floor", call. = FALSE)
  out <- tune[rec, , drop = FALSE]
  out$n_region <- length(rr)
  out
}
