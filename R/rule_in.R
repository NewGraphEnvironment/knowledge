#' Index the walks by source and river size, for the exception test
#'
#' [knw_rule_in()] tests a rule's exception by looking up, for each visit, the
#' distance downstream to the first river of at least `exc_q` m³/s on one flow
#' source. This turns [knw_link_walks()]'s long table into that lookup once, so a
#' grid of thousands of rules does not re-filter it.
#'
#' @param walks the table [knw_link_walks()] returns, with the target flags
#'   `target_lake` and `target_regulated` where the caller has them (absent
#'   columns read as `FALSE`).
#' @return A named list, one element per `src|qmin`, each a list of `pt` (the
#'   start key `"<blue_line_key> <downstream_route_measure>"`), `dist` (`Inf`
#'   where the walk did not find a river), `lake` and `reg`.
#' @export
#' @examples
#' w <- data.frame(blue_line_key = 1, downstream_route_measure = c(10, 10), src = "pick",
#'                 qmin = c(3, 10), status = c("found", "none"), dist_m = c(400, NA))
#' names(knw_walk_index(w))
knw_walk_index <- function(walks) {
  chk::chk_data(walks)
  chk::check_names(walks, c("blue_line_key", "downstream_route_measure", "src", "qmin", "status", "dist_m"))
  if (!"target_lake" %in% names(walks)) walks$target_lake <- FALSE
  if (!"target_regulated" %in% names(walks)) walks$target_regulated <- FALSE
  key <- paste(walks$src, walks$qmin, sep = "|")
  pt <- paste(walks$blue_line_key, walks$downstream_route_measure)
  lapply(split(seq_len(nrow(walks)), key), function(i) {
    list(pt = pt[i], dist = ifelse(walks$status[i] == "found", walks$dist_m[i], Inf),
         lake = walks$target_lake[i] %in% TRUE, reg = walks$target_regulated[i] %in% TRUE)
  })
}

#' Whether each visit is in under one rule, on the stream branch
#'
#' `scripts/0297`'s rule: a visit on a stream edge is in when its gradient lies in
#' `[0, grad_max]` and either the size test holds (width in
#' `[size_min, 9999]`, or MAD at least `size_min`) or the exception does (a river
#' of at least `exc_q` m³/s within `exc_d` m downstream on the flow source
#' `src`). A `NA` gradient, width or MAD fails its test. The river, wetland and
#' lake branches of link's rules are constant across the rules a grid varies, so
#' a scoring population holds stream-branch visits only, and a visit off the
#' stream edges is out here.
#'
#' @param d `data.frame` of visits with `edge_type`, `blue_line_key`,
#'   `downstream_route_measure` and the columns named by `cols`.
#' @param rule one row of [knw_tune_grid()]'s table.
#' @param walks the index [knw_walk_index()] returns, or `NULL` when no rule in
#'   play has an exception.
#' @param cols named `character`: which columns of `d` carry `grad`, `width`
#'   and `mad`.
#' @param src `character(1)` the flow source the exception reads.
#' @param edge_stream `integer` the stream-branch edge types.
#' @param no_lake_target,no_reg_target `logical(1)` fail the exception where the
#'   river found is a lake segment, or lies on a regulated reach.
#' @return `logical` of `nrow(d)`.
#' @export
#' @examples
#' d <- data.frame(edge_type = c(1000, 1000, 1250), blue_line_key = 1, downstream_route_measure = 1:3,
#'                 segment_gradient = c(0.02, 0.02, 0.01), cw_deploy = c(2, 1, 50), mad_pick = c(0.3, 0.1, 40))
#' r <- data.frame(size_var = "width", size_min = 1.5, grad_max = 0.0549, exc_q = NA, exc_d = NA)
#' knw_rule_in(d, r)
knw_rule_in <- function(d, rule, walks = NULL,
                        cols = c(grad = "segment_gradient", width = "cw_deploy", mad = "mad_pick"),
                        src = "pick", edge_stream = c(1000L, 1100L, 2000L, 2300L),
                        no_lake_target = FALSE, no_reg_target = FALSE) {
  chk::chk_data(d)
  chk::check_names(d, c("edge_type", "blue_line_key", "downstream_route_measure", unname(cols)))
  chk::check_names(rule, c("size_var", "size_min", "grad_max", "exc_q", "exc_d"))
  if (nrow(rule) != 1L) stop("rule must be one row", call. = FALSE)
  g <- d[[cols[["grad"]]]]
  grad_ok <- !is.na(g) & g >= 0 & g <= rule$grad_max
  size_ok <- if (rule$size_var == "width") {
    wd <- d[[cols[["width"]]]]
    !is.na(wd) & wd >= rule$size_min & wd <= 9999
  } else {
    m <- d[[cols[["mad"]]]]
    !is.na(m) & m >= rule$size_min
  }
  ex <- FALSE
  if (!is.na(rule$exc_q)) {
    if (is.null(walks)) stop("the rule has an exception but no walks were given", call. = FALSE)
    e <- walks[[paste(src, rule$exc_q, sep = "|")]]
    if (is.null(e)) stop("no walks on ", src, " at ", rule$exc_q, " m3/s", call. = FALSE)
    m <- match(paste(d$blue_line_key, d$downstream_route_measure), e$pt)
    if (anyNA(m)) stop(sum(is.na(m)), " visits have no walk on ", src, " at ", rule$exc_q, call. = FALSE)
    ok <- e$dist[m] <= rule$exc_d
    if (no_lake_target) ok <- ok & !e$lake[m]
    if (no_reg_target) ok <- ok & !e$reg[m]
    ex <- ok
  }
  d$edge_type %in% edge_stream & grad_ok & (size_ok | ex)
}
