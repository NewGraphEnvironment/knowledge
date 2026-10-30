#' How a measured site gradient compares with a modelled one
#'
#' FDIS crews measured the channel's slope at the site (`gradient_pct`, and a
#' second reading, `gradient2_pct`); every gradient limit the tuning publishes
#' is a limit on a Freshwater Atlas average (link's segment gradient, or the
#' whole Atlas line's). These measure how far apart the two are (#121), as
#' `data-raw/site_gradient_check.R` reports them and the methodology article
#' quotes them, from one code path.
#'
#' `knw_site_gradient_visits()` reads the visit table onto the rules' scale
#' (percent / 100, `meas` and `meas2`) and marks the tuning's stream branch
#' (`knw_tune_run()`'s edge types and fished area, no river, wetland or lake).
#' `knw_site_gradient_population()` is a key's scored visits on it: in the
#' species' range, not blocked, no barrier downstream, and for rearing the
#' groups that hold both outcomes (`knw_tune_score()`); a spawning key's is
#' before the spawner-evidence and groups filters, which need tables not read
#' here. `knw_gradient_agree()` is the agreement of two gradients: rank
#' correlation over every pair; over pairs both above 0, the correlation of
#' the logs and the measured/modelled ratio's p10, p50 and p90; the absolute
#' difference's median and p90; the share where the model is higher.
#' `knw_gradient_flips()` counts visits whose measured and modelled gradients
#' lie on opposite sides of a limit (a reading on the limit is in, as a rule's
#' `<=` has it), over every visit and within one step of the key's own ladder
#' either side of the limit (`band`, mirrored at the ladder's ends; and the
#' same window on the measured gradient).
#'
#' @param visits_link `0310`'s `visits_link.csv`.
#' @param v from `knw_site_gradient_visits()`.
#' @param visits_species `0310`'s `visits_species.csv`.
#' @param species_code,stage the key.
#' @param measured,modelled numeric gradients on one scale.
#' @param d a population with `meas` and the modelled gradient column.
#' @param limit `numeric(1)` the published limit.
#' @param against the modelled gradient column (`"segment_gradient"`,
#'   `"fwa_gradient"`).
#' @param ladder the key's gradient ladder (its tune table's `grad_max`).
#' @return `knw_site_gradient_visits()`: the visits with `meas`, `meas2`,
#'   `at_visit` and `stream_branch`. `knw_site_gradient_population()`: the key's
#'   visits. `knw_gradient_agree()` and `knw_gradient_flips()`: a one-row
#'   tibble.
#' @export
#' @examples
#' knw_gradient_agree(c(0.01, 0.02, 0.05, 0.10), c(0.012, 0.03, 0.04, 0.08))
#' d <- data.frame(meas = c(0.10, 0.12, 0.05), segment_gradient = c(0.12, 0.10, 0.06))
#' knw_gradient_flips(d, 0.11, "segment_gradient", c(0.07, 0.09, 0.11, 0.13, 0.15))
knw_site_gradient_visits <- function(visits_link) {
  fm <- formals(knw_tune_run)
  edge_stream <- eval(fm$edge_stream)
  area_range <- eval(fm$area_range)
  v <- visits_link
  v$meas <- v$gradient_pct / 100
  v$meas2 <- v$gradient2_pct / 100
  v$at_visit <- v$segment_start_offset_m >= -1 & v$segment_start_offset_m <= 5
  v$stream_branch <- v$edge_type %in% edge_stream & !(v$wb_river %in% TRUE) & !(v$wb_wetland %in% TRUE) &
    !(v$wb_lake %in% TRUE) & !is.na(v$area_m2) & v$area_m2 >= area_range[1] & v$area_m2 <= area_range[2]
  v
}

#' @rdname knw_site_gradient_visits
#' @export
knw_site_gradient_population <- function(v, visits_species, species_code, stage) {
  st <- visits_species[visits_species$species_code == species_code, c("site_visit", "present", "status", "in_range")]
  d <- merge(v[v$stream_branch, , drop = FALSE], st, by = "site_visit")
  d <- d[d$in_range %in% TRUE & d$status != "blocked", , drop = FALSE]
  bcol <- paste0("barrier_dnstr_", tolower(species_code))
  if (bcol %in% names(d)) d <- d[d[[bcol]] %in% FALSE, , drop = FALSE]
  if (stage != "rear") return(d)
  d$wsg <- factor(d$watershed_group_code)
  d$U <- as.integer(d$present)
  .tune_modelled(d, "U")
}

#' @rdname knw_site_gradient_visits
#' @export
knw_gradient_agree <- function(measured, modelled) {
  ok <- !is.na(measured) & !is.na(modelled)
  m <- measured[ok]
  g <- modelled[ok]
  pos <- m > 0 & g > 0
  r <- m[pos] / g[pos]
  q <- if (length(r)) stats::quantile(r, c(0.1, 0.5, 0.9), names = FALSE) else rep(NA_real_, 3)
  tibble::tibble(pairs = length(m), zero_pairs = sum(!pos),
                 spearman = round(suppressWarnings(stats::cor(m, g, method = "spearman")), 3),
                 log_r = round(if (sum(pos) > 2) stats::cor(log(m[pos]), log(g[pos])) else NA_real_, 3),
                 ratio_p10 = round(q[1], 2), ratio_p50 = round(q[2], 2), ratio_p90 = round(q[3], 2),
                 absdiff_p50 = round(stats::median(abs(m - g)), 4),
                 absdiff_p90 = round(stats::quantile(abs(m - g), 0.9, names = FALSE), 4),
                 model_higher_pct = round(100 * mean(g > m), 1))
}

#' @rdname knw_site_gradient_visits
#' @export
knw_gradient_flips <- function(d, limit, against, ladder) {
  ladder <- sort(unique(ladder))
  i <- match(TRUE, abs(ladder - limit) < 1e-9)
  if (is.na(i)) stop("limit ", limit, " is not on its key's ladder", call. = FALSE)
  lo <- if (i == 1L) limit - (ladder[2] - ladder[1]) else ladder[i - 1L]
  hi <- if (i == length(ladder)) limit + (limit - lo) else ladder[i + 1L]
  g <- d[[against]]
  ok <- !is.na(d$meas) & !is.na(g)
  inb <- ok & g > lo & g <= hi
  inm <- ok & d$meas > lo & d$meas <= hi
  fl <- (d$meas <= limit) != (g <= limit)
  tibble::tibble(against = against, visits = sum(ok), flips_pct = round(100 * mean(fl[ok]), 1),
                 band = sprintf("(%g, %g]", lo, hi), band_visits = sum(inb),
                 band_flips_pct = round(100 * mean(fl[inb]), 1),
                 meas_band_visits = sum(inm), meas_band_flips_pct = round(100 * mean(fl[inm]), 1),
                 meas_on_limit = sum(ok & abs(d$meas - limit) < 1e-9),
                 meas_above_model_below = sum(ok & d$meas > limit & g <= limit),
                 meas_below_model_above = sum(ok & d$meas <= limit & g > limit))
}
