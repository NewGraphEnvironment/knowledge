#' The candidate rules for one species and stage, around link's own thresholds
#'
#' `scripts/0297` tuned CH rearing over a grid of three components; this builds
#' that grid for any species and stage from link's `default` thresholds. A rule
#' is a stream-branch test with three parts: a size test (a MAD floor in m³/s
#' with no maximum, or a channel-width floor in m), a gradient maximum, and an
#' exception admitting a segment that fails the size test when a river of at
#' least `exc_q` m³/s lies within `exc_d` m downstream. `default` is the member
#' with link's own width floor and gradient maximum and no exception;
#' `departures` counts how many parts differ from it (a size test that differs in
#' variable or value: 1; a gradient that differs: 1; an exception: 1).
#' `departures_flow` counts the same from link's *flow* version of `default`
#' (its MAD floor, its gradient maximum, no exception), the starting point #80
#' asks the pick to be read from as well; `NA` where `default` has no MAD floor.
#'
#' The size and gradient grids are the species' `default` values and the fixed
#' steps around them, so every species is tuned against the same ladder; the
#' gradient ladder runs to 30 % since #68 (#67 found CH rearing's best rule at
#' the top of the 9 % ladder). A species whose `default` has no stream rule for
#' the stage (KO and SK rear in lakes only) gets an empty grid, and the caller
#' says so.
#'
#' `extra` adds one more candidate: the rule of another bundle's thresholds row
#' (link's `default_tuned`, whose MAD floors were set by a use rate on wet's
#' flows, link#331), its MAD floor and gradient maximum joining the ladders and
#' the rule flagged `is_link_tuned`, so the table shows how link's own flow
#' numbers score beside the grid. A row with no MAD floor for the stage adds
#' nothing.
#'
#' @param thresholds one row of link's `parameters_habitat_thresholds.csv` for the
#'   species (a `data.frame` with `species_code`, `<stage>_gradient_max`,
#'   `<stage>_channel_width_min`, `<stage>_mad_min`).
#' @param stage `"rear"` or `"spawn"`.
#' @param grid_mad,grid_width,grid_grad,grid_q,grid_d `numeric` candidate values;
#'   the species' own `default` width, MAD and gradient are added when absent.
#' @param extra `NULL`, or one row of another bundle's thresholds for the same
#'   species, in the same columns.
#' @return A `tibble` with `rule`, `size_var`, `size_min`, `grad_max`, `exc_q`,
#'   `exc_d`, `departures`, `departures_flow`, `is_default`, `is_link_tuned`;
#'   zero rows when the species has no stream rule for the stage.
#' @export
#' @examples
#' thr <- data.frame(species_code = "CH", rear_gradient_max = 0.0549, rear_channel_width_min = 1.5,
#'                   rear_mad_min = 0.28)
#' g <- knw_tune_grid(thr, "rear")
#' nrow(g)
#' g[g$is_default, ]
#' g[g$departures_flow == 0, ]
knw_tune_grid <- function(thresholds, stage = c("rear", "spawn"),
                          grid_mad = c(0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1),
                          grid_width = c(1, 1.5, 2, 3, 4),
                          grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15, 0.20, 0.25, 0.30),
                          grid_q = c(1, 3, 5, 10, 20, 30, 50),
                          grid_d = c(100, 250, 500, 1000, 2000, 5000),
                          extra = NULL) {
  stage <- match.arg(stage)
  chk::chk_data(thresholds)
  if (nrow(thresholds) != 1L) stop("thresholds must be one species' row", call. = FALSE)
  cols <- paste0(stage, c("_gradient_max", "_channel_width_min", "_mad_min"))
  chk::check_names(thresholds, c("species_code", cols))
  g_def <- as.numeric(thresholds[[cols[1]]])
  w_def <- as.numeric(thresholds[[cols[2]]])
  m_def <- as.numeric(thresholds[[cols[3]]])
  empty <- tibble::tibble(rule = character(), size_var = character(), size_min = numeric(), grad_max = numeric(),
                          exc_q = numeric(), exc_d = numeric(), departures = integer(), departures_flow = integer(),
                          is_default = logical(), is_link_tuned = logical())
  if (is.na(g_def) || (is.na(w_def) && is.na(m_def))) return(empty)
  g_x <- m_x <- NA_real_
  if (!is.null(extra)) {
    chk::chk_data(extra)
    if (nrow(extra) != 1L) stop("extra must be one species' row", call. = FALSE)
    chk::check_names(extra, c("species_code", cols))
    if (!identical(as.character(extra$species_code), as.character(thresholds$species_code))) {
      stop("extra is another species' row", call. = FALSE)
    }
    m_x <- as.numeric(extra[[cols[3]]])
    g_x <- as.numeric(extra[[cols[1]]])
    if (is.na(g_x)) m_x <- NA_real_
  }
  grid_grad <- sort(unique(c(grid_grad, g_def, if (!is.na(m_x)) g_x)))
  if (!is.na(w_def)) grid_width <- sort(unique(c(grid_width, w_def)))
  grid_mad <- sort(unique(c(grid_mad, if (!is.na(m_def)) m_def, if (!is.na(m_x)) m_x)))
  size <- rbind(
    if (length(grid_mad)) data.frame(size_var = "mad", size_min = grid_mad),
    if (length(grid_width)) data.frame(size_var = "width", size_min = grid_width)
  )
  exc <- rbind(data.frame(exc_q = NA_real_, exc_d = NA_real_), expand.grid(exc_q = grid_q, exc_d = grid_d))
  g <- merge(merge(size, data.frame(grad_max = grid_grad), by = NULL), exc, by = NULL)
  # default's size test is the width floor where link's default has one, else its MAD floor
  def_var <- if (!is.na(w_def)) "width" else "mad"
  def_min <- if (!is.na(w_def)) w_def else m_def
  g$departures <- as.integer((g$size_var != def_var | g$size_min != def_min) + (g$grad_max != g_def) + !is.na(g$exc_q))
  g$departures_flow <- if (is.na(m_def)) NA_integer_ else {
    as.integer((g$size_var != "mad" | g$size_min != m_def) + (g$grad_max != g_def) + !is.na(g$exc_q))
  }
  g$is_default <- g$departures == 0L
  if (sum(g$is_default) != 1L) stop("the grid holds ", sum(g$is_default), " default rules", call. = FALSE)
  g$is_link_tuned <- if (is.na(m_x)) FALSE else g$size_var == "mad" & g$size_min == m_x & g$grad_max == g_x & is.na(g$exc_q)
  if (!is.na(m_x) && sum(g$is_link_tuned) != 1L) stop("the grid holds ", sum(g$is_link_tuned), " link_tuned rules", call. = FALSE)
  g$rule <- sprintf("%s>=%g|g<=%g|%s", g$size_var, g$size_min, g$grad_max,
                    ifelse(is.na(g$exc_q), "none", sprintf("Q%g@D%g", g$exc_q, g$exc_d)))
  tibble::as_tibble(g[, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d", "departures", "departures_flow",
                          "is_default", "is_link_tuned")])
}
