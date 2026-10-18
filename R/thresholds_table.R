#' The published thresholds table, from a tuning run's outputs
#'
#' One row per species × stage × component of the joint pick, in the columns
#' link's calibration reads (link#346): `rule_id` ties the components of one
#' rule; `link_parameter` is the column of link's `parameters_habitat_thresholds.csv`
#' the value fills, where one exists (the near-a-river exception has none in link
#' and is `NA`); `model` says whether the size test is a width (`cw`) or a MAD
#' (`mad`) floor; `range_lo` and `range_hi` are the smallest and largest value of
#' the component among the rules inside the one-SE region on the main reading;
#' `readings_in` is the number of fold seeds (the main one and the extra seeds) in
#' whose region the recommended rule sits, of `readings`. A species × stage that
#' was not fitted (no stream rule, no response, too few groups) gets one row
#' per stage with `status` saying why and no values.
#'
#' @param tune_dir `character(1)` the directory `scripts/0320` wrote (one
#'   `<sp>_<stage>_summary.csv` per species × stage, bound here).
#' @param evidence_version,link_run_uid,link_sha,config `character(1)` the
#'   provenance every row carries.
#' @return A list: `thresholds` and `groups` (one row per `rule_id` and
#'   watershed group the rule was scored on), both `tibble`s.
#' @export
#' @examples
#' \dontrun{
#' t <- knw_thresholds_table("data/tune", "knowledge/fdis/v3", "20261017_004619-3f4c713b", "a17e9177", "default")
#' t$thresholds
#' }
knw_thresholds_table <- function(tune_dir, evidence_version, link_run_uid, link_sha, config = "default") {
  chk::chk_dir(tune_dir)
  chk::chk_string(evidence_version)
  chk::chk_string(link_run_uid)
  chk::chk_string(link_sha)
  files <- list.files(tune_dir, "_summary\\.csv$", full.names = TRUE)
  if (!length(files)) stop("no *_summary.csv in ", tune_dir, call. = FALSE)
  parts <- lapply(files, utils::read.csv, stringsAsFactors = FALSE)
  # a species x stage that was not fitted has fewer columns: bind on the union
  cols <- unique(unlist(lapply(parts, names)))
  parts <- lapply(parts, function(x) {
    x[setdiff(cols, names(x))] <- NA
    x[cols]
  })
  summ <- do.call(rbind, parts)
  summ <- summ[order(summ$species_code, summ$stage), , drop = FALSE]
  rows <- list()
  groups <- list()
  for (i in seq_len(nrow(summ))) {
    sp <- summ$species_code[i]
    stage <- summ$stage[i]
    key <- paste(sp, stage, sep = "_")
    rule_id <- paste(key, "v1", sep = "_")
    base <- tibble::tibble(rule_id = rule_id, species_code = sp, stage = stage, response = summ$response[i],
                           status = summ$status[i])
    if (!summ$status[i] %in% c("fitted", "underpowered")) {
      rows[[key]] <- cbind(base, tibble::tibble(
        component = NA_character_, link_parameter = NA_character_, model = NA_character_, value = NA_real_,
        unit = NA_character_, range_lo = NA_real_, range_hi = NA_real_, readings_in = NA_integer_,
        readings = NA_integer_,
        default_value = NA_real_, default_in_region = NA, rule = NA_character_, n_visits = summ$visits_in[i],
        n_detect = summ$detections[i], n_wsg = summ$groups_both[i], power = summ$status[i]))
      next
    }
    tune <- utils::read.csv(file.path(tune_dir, paste0(key, "_tune.csv")), stringsAsFactors = FALSE)
    g <- utils::read.csv(file.path(tune_dir, paste0(key, "_groups.csv")), stringsAsFactors = FALSE)
    rec <- tune[tune$recommended %in% TRUE, , drop = FALSE]
    dflt <- tune[tune$is_default %in% TRUE, , drop = FALSE]
    region <- tune[tune$in_region %in% TRUE, , drop = FALSE]
    same_size <- region[region$size_var == rec$size_var, , drop = FALSE]
    readings <- summ$seeds_n[i] + 1L
    readings_in <- summ$seeds_rec_in_region[i] + 1L
    model <- if (rec$size_var == "width") "cw" else "mad"
    comp <- tibble::tibble(
      component = c("size", "gradient", "exception_q", "exception_d"),
      link_parameter = c(paste0(stage, if (rec$size_var == "width") "_channel_width_min" else "_mad_min"),
                         paste0(stage, "_gradient_max"), NA_character_, NA_character_),
      model = model,
      value = c(rec$size_min, rec$grad_max, rec$exc_q, rec$exc_d),
      unit = c(if (rec$size_var == "width") "m" else "m3/s", "fraction", "m3/s", "m"),
      range_lo = c(if (nrow(same_size)) min(same_size$size_min) else NA, min(region$grad_max),
                   if (any(!is.na(region$exc_q))) min(region$exc_q, na.rm = TRUE) else NA,
                   if (any(!is.na(region$exc_d))) min(region$exc_d, na.rm = TRUE) else NA),
      range_hi = c(if (nrow(same_size)) max(same_size$size_min) else NA, max(region$grad_max),
                   if (any(!is.na(region$exc_q))) max(region$exc_q, na.rm = TRUE) else NA,
                   if (any(!is.na(region$exc_d))) max(region$exc_d, na.rm = TRUE) else NA),
      readings_in = readings_in, readings = readings,
      default_value = c(dflt$size_min, dflt$grad_max, NA_real_, NA_real_),
      default_in_region = dflt$in_region %in% TRUE, rule = rec$rule,
      n_visits = rec$n_visits, n_detect = rec$n_detect, n_wsg = rec$n_wsg, power = summ$status[i]
    )
    # default's size test is a width floor where link's is; a MAD pick has no default value in its unit
    if (rec$size_var != dflt$size_var) comp$default_value[1] <- NA_real_
    rows[[key]] <- cbind(base[rep(1, nrow(comp)), ], comp)
    groups[[key]] <- tibble::tibble(rule_id = rule_id, species_code = sp, stage = stage,
                                    watershed_group_code = g$watershed_group_code, fold = g$fold)
  }
  thr <- do.call(rbind, rows)
  thr$evidence_version <- evidence_version
  thr$link_run_uid <- link_run_uid
  thr$link_sha <- link_sha
  thr$config <- config
  gr <- do.call(rbind, groups)
  list(thresholds = tibble::as_tibble(thr), groups = tibble::as_tibble(gr))
}
