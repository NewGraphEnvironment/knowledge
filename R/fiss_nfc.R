#' Roll Fish Data Submission Step 2 records up to sites, flagging no fish caught
#'
#' Step 2 of the provincial workbook carries one row per method, pass or trap and species: the effort and the
#' number caught. The workbook has no no-fish field of its own. The submitter records "No Fish Caught" (the
#' picklist from 2016) or a zero-catch code such as `NFC` (earlier editions), which is their own call; this takes
#' it as given and invents no effort threshold. A site is flagged `nfc` when nothing at it was caught and either
#' the submitter recorded no fish (`nfc_source = "submitted"`) or a count of 0 was entered with effort recorded
#' (`"derived"`). Blank counts are never read as zero: the derived branch needs a count to have been entered.
#' Editions record no fish per trap or pass, so one empty trap beside a full one is not a no-fish site;
#' `nfc_conflict` keeps that case visible. A site with no Step 2 record gets no row here, so joined to the site
#' table its `nfc` is `NA`, unknown rather than no fish.
#'
#' A record caught something when it names a species that is not a no-fish entry, unless its count is an explicit
#' 0, or when its count is above 0. `species_list` names every species entered and `species_caught` only those
#' caught, so an empty trap recorded as "RB, 0" lists RB without catching it. Effort and comments ride along, so
#' a reader can weigh a no-fish site ("electrofished 1200 m, nothing" against a brief dip net).
#'
#' Moved from `scripts/0220-fiss-xls-parse-nfc.R` (#7).
#'
#' @param step2 `data.frame`, Step 2 rows as [knw_fiss_parse_step()] returns them, bound over workbooks:
#'   `site_key`, `sampling_method`, `species`, `total_number`, `ef_seconds`, `ef_length_m`, `soak_time`,
#'   `comments`. Cells may be character, as the sheets give them.
#' @param codes `data.frame`, `data/fdis_species_codes.csv`: `code`, `catch_class`. The codes whose class is
#'   `"zero_catch"` are the no-fish entries.
#' @return A tibble, one row per `site_key`: `methods_used`, `n_records`, `total_ef_secs`, `total_ef_len_m`,
#'   `max_soak_time`, `total_fish`, `fish_counted`, `species_list`, `any_no_fish`, `any_caught`,
#'   `species_caught`, `effort_recorded`, `comments_fish`, `nfc_conflict`, `nfc`, `nfc_source`.
#' @export
#' @examples
#' step2 <- data.frame(
#'   site_key        = c("1:1", "1:1", "1:2", "1:3", "1:4"),
#'   sampling_method = "EF",
#'   species         = c("Rainbow Trout", "No Fish Caught", "No Fish Caught", NA, NA),
#'   total_number    = c("4", NA, NA, "0", NA),
#'   ef_seconds      = c("300", "200", "450", "600", "500"),
#'   ef_length_m = NA, soak_time = NA, comments = NA)
#' codes <- data.frame(code = c("RB", "NFC"), catch_class = c("fish", "zero_catch"))
#' # 1:1 a pass with fish beside an empty one, 1:2 submitted no fish, 1:3 a zero count with effort,
#' # 1:4 effort and no count at all: not a no-fish site
#' knw_fiss_nfc(step2, codes)[, c("site_key", "any_caught", "nfc_conflict", "nfc", "nfc_source")]
knw_fiss_nfc <- function(step2, codes) {
  chk::chk_data(step2)
  chk::check_names(step2, c("site_key", "sampling_method", "species", "total_number", "ef_seconds",
                            "ef_length_m", "soak_time", "comments"))
  chk::chk_data(codes)
  chk::check_names(codes, c("code", "catch_class"))
  zero_catch_codes <- codes$code[codes$catch_class %in% "zero_catch"]
  if (!length(zero_catch_codes)) stop("codes has no zero_catch code", call. = FALSE)
  num <- function(x) .knw_fiss_num(x)
  s2 <- dplyr::mutate(
    step2,
    total_number = num(.data$total_number),
    ef_seconds   = num(.data$ef_seconds),
    ef_length_m  = num(.data$ef_length_m),
    soak_time    = num(.data$soak_time),
    is_no_fish   = stringr::str_detect(tolower(dplyr::coalesce(.data$species, "")), "no fish") |
      toupper(trimws(dplyr::coalesce(.data$species, ""))) %in% zero_catch_codes,
    caught       = !.data$is_no_fish & ((nzchar(trimws(dplyr::coalesce(.data$species, ""))) &
                                           (is.na(.data$total_number) | .data$total_number > 0)) |
                                          dplyr::coalesce(.data$total_number, 0) > 0)
  )
  s2 <- dplyr::group_by(s2, .data$site_key)
  out <- dplyr::summarise(
    s2,
    methods_used    = paste(sort(unique(stats::na.omit(.data$sampling_method))), collapse = "; "),
    n_records       = dplyr::n(),
    total_ef_secs   = sum(.data$ef_seconds, na.rm = TRUE),
    total_ef_len_m  = sum(.data$ef_length_m, na.rm = TRUE),
    max_soak_time   = suppressWarnings(max(.data$soak_time, na.rm = TRUE)),
    total_fish      = sum(.data$total_number, na.rm = TRUE),
    fish_counted    = any(!is.na(.data$total_number)),
    species_list    = paste(sort(unique(stats::na.omit(.data$species[!.data$is_no_fish]))), collapse = "; "),
    any_no_fish     = any(.data$is_no_fish, na.rm = TRUE),
    any_caught      = any(.data$caught, na.rm = TRUE),
    species_caught  = paste(sort(unique(stats::na.omit(.data$species[.data$caught]))), collapse = "; "),
    effort_recorded = any(!is.na(.data$ef_seconds) | !is.na(.data$soak_time) | !is.na(.data$ef_length_m)),
    comments_fish   = paste(unique(stats::na.omit(as.character(.data$comments))), collapse = " | "),
    .groups = "drop"
  )
  dplyr::mutate(
    out,
    max_soak_time = ifelse(is.infinite(.data$max_soak_time), NA_real_, .data$max_soak_time),
    nfc_conflict  = .data$any_no_fish & .data$any_caught,
    nfc           = !.data$any_caught & (.data$any_no_fish |
                                           (.data$fish_counted & .data$total_fish == 0 & .data$effort_recorded)),
    nfc_source    = ifelse(.data$nfc & .data$any_no_fish, "submitted",
                           ifelse(.data$nfc, "derived", NA_character_))
  )
}
