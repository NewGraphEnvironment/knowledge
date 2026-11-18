#' NuSEDS escapement records, each with the kind of evidence it is
#'
#' Reads a NuSEDS All Areas release ([knw_nuseds_fetch()]) through crate
#' (`crate::crt_ingest("dfo", "nuseds_all_areas")`), which reads whichever
#' registered release shape arrives into one set of lower-case columns, and
#' adds `evidence_kind`. Every column NuSEDS carries is kept as DFO wrote it:
#' counts, presence, survey methods, inspections, estimate method and quality,
#' and the arrival and spawn dates (`DD-MON-YY`, as written).
#'
#' One row is one estimate (`act_id`): a population (`pop_id`) on one stream
#' (`gfe_id`, `waterbody_id`, `fwa_watershed_cde`) in one year. A population can
#' be counted on several streams in a year, so a population, species and year
#' is not a key; a population, stream and year is, and both keys are checked.
#'
#' `evidence_kind` says what each record shows, so a reader can tell counts
#' from judgements. It is decided from `adult_presence` first, then for a
#' present population by the first of these that holds:
#'
#' - `count_expert`: a spawner or return number greater than 0, with the estimate
#'   method "Expert Opinion" and no survey recorded;
#' - `count`: a spawner or return number greater than 0;
#' - `presence_expert`: present by expert opinion, with no number and no survey
#'   recorded;
#' - `presence_survey`: present, with a survey method or a number of inspections
#'   recorded;
#' - `presence_unrecorded`: present, with none of the above recorded.
#'
#' The other presence values give `none_observed` (NONE OBSERVED),
#' `not_inspected` (NOT INSPECTED) and `unknown` (UNKNOWN or blank). A survey is
#' recorded where `enumeration_methods` or `no_inspections_used` is filled; the
#' number is the larger of `natural_adult_spawners` and `total_return_to_river`.
#'
#' @param path `character(1)` a NuSEDS All Areas zip or CSV.
#' @return A `tibble`: crate's canonical NuSEDS columns and `evidence_kind`.
#' @export
#' @examples
#' f <- system.file("extdata/examples/dfo/nuseds_all_areas_2026-06-01.csv", package = "crate")
#' if (nzchar(f)) {
#'   x <- knw_nuseds_records(f)
#'   table(x$evidence_kind)
#'   x[x$waterbody == "MAXAN CREEK" & x$evidence_kind != "not_inspected",
#'     c("analysis_yr", "evidence_kind", "total_return_to_river", "enumeration_methods")]
#' }
knw_nuseds_records <- function(path) {
  chk::chk_file(path)
  x <- crate::crt_ingest("dfo", "nuseds_all_areas", path)
  if (anyDuplicated(x$act_id)) stop(sum(duplicated(x$act_id)), " act_id values repeat", call. = FALSE)
  key <- paste(x$pop_id, x$gfe_id, x$analysis_yr)
  if (anyDuplicated(key)) {
    stop(sum(duplicated(key)), " rows repeat a population, stream (gfe_id) and year", call. = FALSE)
  }
  x$evidence_kind <- .knw_nuseds_kind(x)
  x
}

#' The evidence classes [knw_nuseds_records()] assigns
#'
#' @return `character` the values of `evidence_kind`.
#' @export
#' @examples
#' knw_nuseds_kinds()
knw_nuseds_kinds <- function() {
  c("count", "count_expert", "presence_survey", "presence_expert", "presence_unrecorded", "none_observed",
    "not_inspected", "unknown")
}

# evidence_kind by the precedence knw_nuseds_records() documents
.knw_nuseds_kind <- function(x) {
  filled <- function(v) !is.na(v) & nzchar(trimws(as.character(v)))
  n <- suppressWarnings(pmax(x$natural_adult_spawners, x$total_return_to_river, na.rm = TRUE))
  has_n <- !is.na(n) & n > 0
  surveyed <- filled(x$enumeration_methods) | filled(x$no_inspections_used)
  expert <- x$estimate_method %in% "Expert Opinion" & !surveyed
  pres <- toupper(trimws(as.character(x$adult_presence)))
  out <- rep("unknown", nrow(x))
  present <- pres %in% "PRESENT"
  out[present] <- "presence_unrecorded"
  out[present & surveyed] <- "presence_survey"
  out[present & expert] <- "presence_expert"
  out[present & has_n] <- "count"
  out[present & has_n & expert] <- "count_expert"
  out[pres %in% "NONE OBSERVED"] <- "none_observed"
  out[pres %in% "NOT INSPECTED"] <- "not_inspected"
  out
}
