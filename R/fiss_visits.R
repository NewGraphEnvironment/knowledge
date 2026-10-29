#' Fish Data Submission workbook sites as visits, with the effort they recorded
#'
#' The FDIS export covers electrofishing to about 2022; the workbooks `0220`
#' parses cover later years and other methods (issue #23). `0250` already
#' dedupes their fish against the export and writes `data/fiss_evidence.csv` at
#' the site × species × size-class grain, keyed by `site_key`
#' (`report_id:reference_number`). This turns those rows into one row per site,
#' species and method (a site records each method's catch on its own), and takes
#' the site's electrofishing effort from the step-2 collection form where
#' the group's `fiss_step2_fishcoll_<wsg>.csv` holds it: electrofishing seconds
#' summed over passes, and the fished area as the first pass's length × width.
#' A site enters the scoring only with an effort (`scores`); the rest are
#' presence-only, which choose groups and feed the outside check but never score
#' a rule.
#'
#' @param evidence `data.frame`, `data/fiss_evidence.csv` as written by `0250`.
#' @param step2 `data.frame`, the step-2 rows of the groups (`0220`), bound
#'   together; `NULL` when none are held.
#' @return A `tibble`, one row per site, species and method: `site_visit` (the
#'   `site_key`), `watershed_group_code`, `blue_line_key`,
#'   `downstream_route_measure`, `year`, `month`, `method`, `species_code`,
#'   `n_caught`, `fishing_time_s`, `area_m2`, `fished_length_m`, `scores`,
#'   `data_set = "FISS_WORKBOOK"`.
#' @export
#' @examples
#' ev <- data.frame(site_visit = "17491:1", species_code = c("BT", "BT"),
#'                  size_class = c("fry", "adult"), n = c(2, 1), n_caught = 3,
#'                  watershed_group_code = "COTR", blue_line_key = 1,
#'                  downstream_route_measure = 10, month = 8, year = 2015,
#'                  method = "electrofishing")
#' s2 <- data.frame(site_key = "17491:1", sampling_method = "EF", haul_pass = c(1, 2),
#'                  ef_seconds = c(300, 250), length_m = 50, width_m = 2,
#'                  ef_length_m = NA, ef_width_m = NA)
#' knw_fiss_visits(ev, s2)
knw_fiss_visits <- function(evidence, step2 = NULL) {
  chk::chk_data(evidence)
  chk::check_names(evidence, c("site_visit", "species_code", "n_caught", "watershed_group_code", "blue_line_key",
                               "downstream_route_measure", "month", "year", "method"))
  chk::chk_null_or(step2, vld = chk::vld_data)
  ev <- unique(evidence[, c("site_visit", "watershed_group_code", "blue_line_key", "downstream_route_measure",
                            "year", "month", "method", "species_code", "n_caught")])
  # a site records each method's catch on its own: one row per site, species and method
  if (anyDuplicated(ev[, c("site_visit", "species_code", "method")])) {
    stop("a site, species and method carries two counts in evidence", call. = FALSE)
  }
  eff <- NULL
  if (!is.null(step2) && nrow(step2)) {
    chk::check_names(step2, c("site_key", "sampling_method", "haul_pass", "ef_seconds", "length_m", "width_m"))
    s2 <- step2[step2$sampling_method %in% "EF", , drop = FALSE]
    num <- function(x) suppressWarnings(as.numeric(x))
    s2$ef_seconds <- num(s2$ef_seconds)
    pick_measure <- function(ef, plain) {
      if (is.null(ef)) return(num(plain))
      ifelse(is.na(num(ef)), num(plain), num(ef))
    }
    len <- pick_measure(s2[["ef_length_m"]], s2$length_m)
    wid <- pick_measure(s2[["ef_width_m"]], s2$width_m)
    s2$len <- len
    s2$wid <- wid
    s2$pass <- num(s2$haul_pass)
    first <- s2[order(s2$site_key, s2$pass), ]
    first <- first[!duplicated(first$site_key), ]
    secs <- tapply(s2$ef_seconds, s2$site_key, function(x) if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE))
    eff <- data.frame(site_visit = names(secs), fishing_time_s = as.numeric(secs),
                      fished_length_m = first$len[match(names(secs), first$site_key)],
                      area_m2 = (first$len * first$wid)[match(names(secs), first$site_key)],
                      stringsAsFactors = FALSE)
  }
  out <- tibble::tibble(
    site_visit = ev$site_visit, watershed_group_code = ev$watershed_group_code,
    blue_line_key = as.numeric(ev$blue_line_key), downstream_route_measure = as.numeric(ev$downstream_route_measure),
    year = as.integer(ev$year), month = as.integer(ev$month), method = ev$method, species_code = ev$species_code,
    n_caught = as.numeric(ev$n_caught)
  )
  i <- if (is.null(eff)) rep(NA_integer_, nrow(out)) else match(out$site_visit, eff$site_visit)
  out$fishing_time_s <- if (is.null(eff)) NA_real_ else eff$fishing_time_s[i]
  out$area_m2 <- if (is.null(eff)) NA_real_ else eff$area_m2[i]
  out$fished_length_m <- if (is.null(eff)) NA_real_ else eff$fished_length_m[i]
  ef <- out$method %in% "electrofishing"
  out$fishing_time_s[!ef] <- NA_real_
  out$area_m2[!ef] <- NA_real_
  out$fished_length_m[!ef] <- NA_real_
  out$scores <- ef & (!is.na(out$fishing_time_s) | !is.na(out$area_m2))
  out$data_set <- "FISS_WORKBOOK"
  out[order(out$site_visit, out$species_code, out$method), , drop = FALSE]
}
