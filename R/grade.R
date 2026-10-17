#' Grade segments by expected use, 0 to 1
#'
#' A segment's grade is the curve's predicted detection rate at the segment's
#' size, gradient and distance to a river, at the reference nuisance values and
#' with the group random effect excluded (so grades compare across groups),
#' divided by the `ref_quantile` of that rate over the species' accessible
#' segments, and capped at 1. The top of the accessible network reads 1, and a
#' segment at a third of that rate reads about 0.3. It is expected use per
#' standard electrofishing visit, not habitat quality, and is labelled so.
#'
#' A segment whose size variable is missing (an unmeasured first-order stream
#' under a width model; a segment with no flow even from a parent under a MAD
#' model) or whose gradient is missing gets `NA`, and the counts come back. A
#' distance the walk did not find, or a segment with no walk, is the cap
#' (`dist_cap_m`): far from any river.
#'
#' @param curve the list [knw_tune_curve()] returns.
#' @param segments `data.frame` with `accessible` (logical) and the columns
#'   `cols` name: the size variable the curve was fit on, the gradient, and
#'   `dist_m` (metres to the first river of the curve's `q`; `NA` or `Inf` where
#'   none).
#' @param cols named `character`: `size`, `grad`, `dist`.
#' @param ref_quantile `numeric(1)` the quantile of accessible segments' rate
#'   that reads 1.
#' @param classes `numeric` the class breaks on the grade.
#' @return A list: `grades`, a `tibble` of `nrow(segments)` with `rate`,
#'   `grade`, `grade_class`; `reference`, the rate that reads 1; `dropped`,
#'   counts of segments with no size or gradient.
#' @export
#' @examples
#' \dontrun{
#' g <- knw_grade(cv, seg, cols = c(size = "mad_pick", grad = "gradient", dist = "dist_m"))
#' table(g$grades$grade_class, useNA = "ifany")
#' }
knw_grade <- function(curve, segments, cols = c(size = "mad_pick", grad = "gradient", dist = "dist_m"),
                      ref_quantile = 0.95, classes = c(0, 0.2, 0.4, 0.6, 0.8, 1)) {
  chk::chk_list(curve)
  chk::check_names(curve, c("model", "ref", "data", "dist_cap_m"))
  chk::chk_data(segments)
  chk::check_names(segments, c("accessible", unname(cols)))
  chk::chk_number(ref_quantile)
  chk::chk_range(ref_quantile, c(0.5, 1))
  dd <- curve$data
  size <- segments[[cols[["size"]]]]
  grad <- segments[[cols[["grad"]]]]
  dist <- segments[[cols[["dist"]]]]
  dist <- ifelse(is.na(dist) | !is.finite(dist), curve$dist_cap_m, pmin(dist, curve$dist_cap_m))
  ok <- !is.na(size) & size > 0 & !is.na(grad)
  dropped <- c(no_size = sum(is.na(size) | size <= 0), no_gradient = sum(is.na(grad)))
  rate <- rep(NA_real_, nrow(segments))
  if (any(ok)) {
    nd <- data.frame(log_size = log(size[ok]), log_dist = log(dist[ok] + 10), grad = pmin(pmax(grad[ok], 0), 0.2),
                     log_area = curve$ref$log_area,
                     data_set = factor(curve$ref$data_set, levels = levels(dd$data_set)),
                     era = factor(curve$ref$era, levels = levels(dd$era)),
                     wsg = factor(levels(dd$wsg)[1], levels = levels(dd$wsg)))
    rate[ok] <- as.numeric(mgcv::predict.gam(curve$model, newdata = nd, type = "response", exclude = "s(wsg)",
                                              newdata.guaranteed = TRUE))
  }
  acc <- rate[segments$accessible %in% TRUE & !is.na(rate)]
  if (!length(acc)) stop("no accessible segment has a rate; nothing to grade against", call. = FALSE)
  reference <- unname(stats::quantile(acc, ref_quantile))
  grade <- pmin(rate / reference, 1)
  grade_class <- cut(grade, classes, include.lowest = TRUE, right = TRUE,
                     labels = paste0(utils::head(classes, -1), "-", classes[-1]))
  list(grades = tibble::tibble(rate = rate, grade = grade, grade_class = as.character(grade_class)),
       reference = reference, dropped = dropped)
}
