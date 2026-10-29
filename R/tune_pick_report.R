#' Set a tuning run's pick beside the published one
#'
#' After a change upstream (a link build, placement, a flow reload) the first
#' question is whether the pick moved. This answers it for one species x stage
#' from two tuning tables: the run's ([knw_tune_score()] or
#' `data/tune/dev/<key>_tune.csv`) and the published one
#' (`data/tune/<key>_tune.csv`). It says which rule each recommends and at what
#' gradient limit, whether the published rule is still in the run's one-SE
#' region, and how far its score sits behind the run's best, beside where it sat
#' in the published table. Deviances are compared only in units of their own
#' run: a rebuilt evidence changes the visits, so raw held-out deviances of the
#' two runs are not on one scale.
#'
#' @param tune the run's tuning table: `rule`, `grad_max`, `recommended`,
#'   `in_region`, `ddev_best`, `se_diff` and `n_visits`.
#' @param published the published tuning table for the same species x stage,
#'   with the same columns, or `NULL` where none is published.
#' @return One row: `rule_run` and `grad_max_run` (the run's recommended rule),
#'   `rule_published` and `grad_max_published`, `same_pick`,
#'   `published_in_grid` (the published rule was scored in this run),
#'   `published_in_region` (`NA` when not in the grid), `published_ddev` and
#'   `published_se` (its distance behind the run's best and that distance's
#'   standard error, in this run), `published_ddev_was` and `published_se_was`
#'   (the same in the published table), `n_visits_run` and `n_visits_published`.
#' @export
#' @examples
#' pub <- data.frame(rule = c("mad>=0.5|g<=0.07|none", "mad>=0.75|g<=0.09|none"),
#'                   grad_max = c(0.07, 0.09),
#'                   recommended = c(FALSE, TRUE), in_region = c(TRUE, TRUE), ddev_best = c(4, 0),
#'                   se_diff = c(6, 0), n_visits = 4858)
#' run <- transform(pub, recommended = c(TRUE, FALSE), ddev_best = c(0, 9), se_diff = c(0, 5))
#' knw_tune_pick_report(run, pub)   # the pick moved to 7 %, and the published 9 % rule left the region
knw_tune_pick_report <- function(tune, published = NULL) {
  cols <- c("rule", "grad_max", "recommended", "in_region", "ddev_best", "se_diff", "n_visits")
  chk::chk_data(tune)
  chk::check_names(tune, cols)
  # a saved table read as text carries "TRUE"; a scored one carries TRUE
  is_true <- function(x) x %in% c(TRUE, "TRUE")
  num <- function(x) as.numeric(x)
  rec <- which(is_true(tune$recommended))
  if (length(rec) != 1) stop("tune has ", length(rec), " recommended rules, not 1", call. = FALSE)
  out <- data.frame(rule_run = tune$rule[rec], grad_max_run = num(tune$grad_max[rec]),
                    rule_published = NA_character_, grad_max_published = NA_real_, same_pick = NA,
                    published_in_grid = NA, published_in_region = NA,
                    published_ddev = NA_real_, published_se = NA_real_,
                    published_ddev_was = NA_real_, published_se_was = NA_real_,
                    n_visits_run = num(tune$n_visits[rec]), n_visits_published = NA_real_, stringsAsFactors = FALSE)
  if (is.null(published)) return(out)
  chk::chk_data(published)
  chk::check_names(published, cols)
  p <- which(is_true(published$recommended))
  if (length(p) != 1) stop("published has ", length(p), " recommended rules, not 1", call. = FALSE)
  out$rule_published <- published$rule[p]
  out$grad_max_published <- num(published$grad_max[p])
  out$same_pick <- identical(out$rule_run, out$rule_published)
  out$published_ddev_was <- num(published$ddev_best[p])
  out$published_se_was <- num(published$se_diff[p])
  out$n_visits_published <- num(published$n_visits[p])
  i <- match(out$rule_published, tune$rule)
  out$published_in_grid <- !is.na(i)
  if (!is.na(i)) {
    out$published_in_region <- is_true(tune$in_region[i])
    out$published_ddev <- num(tune$ddev_best[i])
    out$published_se <- num(tune$se_diff[i])
  }
  out
}
