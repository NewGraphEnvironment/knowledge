#' The published thresholds table, from a tuning run's outputs
#'
#' One row per species × stage × component of the joint pick, in the columns
#' link's calibration reads (link#346): `rule_id` ties the components of one
#' rule; `link_parameter` is the column of link's `parameters_habitat_thresholds.csv`
#' the value fills: since link 0.67.0 (fresh 0.42.0) the near-a-river exception
#' fills `<stage>_river_discharge_min` and `<stage>_river_distance_max`, with
#' `river_measure = discharge` saying which of fresh's three measures of a river
#' the value is in (link converts to width where a group sizes streams by width);
#' `model` says whether the size test is a width (`cw`) or a MAD
#' (`mad`) floor; `range_lo` and `range_hi` are the smallest and largest value of
#' the component among the rules inside the one-SE region on the main reading;
#' `readings_in` is the number of fold seeds (the main one and the extra seeds) in
#' whose region the recommended rule sits, of `readings`; `rule_196` is the rule
#' the same pick makes from a region 1.96 standard errors wide
#' ([knw_tune_repick()]), and `holds_196` is `TRUE` where that rule keeps the
#' row's value (a size row also needs the same size variable; a component the
#' recommended rule lacks holds when the 1.96 rule lacks it too). `rule_flow` and
#' `rule_flow_196` are the same picks read from link's flow version of `default`
#' as the starting point (#80; `NA` on a table scored before that, or for a
#' species whose `default` has no MAD floor). A species × stage that
#' was not fitted (no stream rule, no response, too few groups) gets one row
#' per stage with `status` saying why and no values.
#'
#' @param tune_dir `character(1)` the directory `scripts/0320` wrote (one
#'   `<sp>_<stage>_summary.csv` per species × stage, bound here).
#' @param evidence_version,link_run_uid,link_sha,config `character(1)` the
#'   provenance every row carries.
#' @param d_floor `numeric(1)` the run's shortest exception distance (m), as given
#'   to [knw_tune_run()], so the 1.96 replay picks as the run did.
#' @return A list: `thresholds` and `groups` (one row per `rule_id` and
#'   watershed group the rule was scored on), both `tibble`s.
#' @export
#' @examples
#' \dontrun{
#' t <- knw_thresholds_table("data/tune", "knowledge/fdis/v3", "20261017_004619-3f4c713b", "a17e9177", "default")
#' t$thresholds
#' }
knw_thresholds_table <- function(tune_dir, evidence_version, link_run_uid, link_sha, config = "default",
                                 d_floor = 200) {
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
        component = NA_character_, link_parameter = NA_character_, river_measure = NA_character_,
        model = NA_character_, value = NA_real_,
        unit = NA_character_, range_lo = NA_real_, range_hi = NA_real_, readings_in = NA_integer_,
        readings = NA_integer_, rule_196 = NA_character_, holds_196 = NA, rule_flow = NA_character_,
        rule_flow_196 = NA_character_,
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
    # the replay must make the run's own pick at one SE before its 1.96 pick means anything
    if (!identical(knw_tune_repick(tune, se_mult = 1, d_floor = d_floor)$rule, rec$rule)) {
      stop(key, ": replaying the pick at one SE does not give the recommended rule", call. = FALSE)
    }
    r196 <- knw_tune_repick(tune, se_mult = 1.96, d_floor = d_floor)
    flow_start <- "departures_flow" %in% names(tune) && !all(is.na(tune$departures_flow))
    flow_pick <- function(se) {
      if (!flow_start) return(NA_character_)
      knw_tune_repick(tune, se_mult = se, d_floor = d_floor, start = "flow")$rule
    }
    rule_flow <- flow_pick(1)
    rule_flow_196 <- flow_pick(1.96)
    same <- function(a, b) (is.na(a) & is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) < 1e-9)
    holds <- c(rec$size_var == r196$size_var && same(rec$size_min, r196$size_min), same(rec$grad_max, r196$grad_max),
               same(rec$exc_q, r196$exc_q), same(rec$exc_d, r196$exc_d))
    comp <- tibble::tibble(
      component = c("size", "gradient", "exception_q", "exception_d"),
      link_parameter = c(paste0(stage, if (rec$size_var == "width") "_channel_width_min" else "_mad_min"),
                         paste0(stage, "_gradient_max"), paste0(stage, "_river_discharge_min"),
                         paste0(stage, "_river_distance_max")),
      river_measure = c(NA_character_, NA_character_, "discharge", "discharge"),
      model = model,
      value = c(rec$size_min, rec$grad_max, rec$exc_q, rec$exc_d),
      unit = c(if (rec$size_var == "width") "m" else "m3/s", "fraction", "m3/s", "m"),
      range_lo = c(if (nrow(same_size)) min(same_size$size_min) else NA, min(region$grad_max),
                   if (any(!is.na(region$exc_q))) min(region$exc_q, na.rm = TRUE) else NA,
                   if (any(!is.na(region$exc_d))) min(region$exc_d, na.rm = TRUE) else NA),
      range_hi = c(if (nrow(same_size)) max(same_size$size_min) else NA, max(region$grad_max),
                   if (any(!is.na(region$exc_q))) max(region$exc_q, na.rm = TRUE) else NA,
                   if (any(!is.na(region$exc_d))) max(region$exc_d, na.rm = TRUE) else NA),
      readings_in = readings_in, readings = readings, rule_196 = r196$rule, holds_196 = holds,
      rule_flow = rule_flow, rule_flow_196 = rule_flow_196,
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
