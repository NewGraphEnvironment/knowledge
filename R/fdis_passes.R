#' FDIS electrofishing passes and the catch on each
#'
#' The FDIS load (`scripts/0230-fdis-load.R`) takes the site visit as its grain, so its visit tables sum
#' catch and effort over a visit's passes. This keeps the passes: one row per pass of a kept visit, and
#' one row per pass and species code caught, for a removal estimate or an occupancy model that treats
#' passes as repeat surveys (#225). A pass is one row of the export's `visits.csv`, one method number
#' and haul; `pass_index` orders a visit's passes by method, then haul.
#'
#' The catch on a pass follows the visit table's rule, applied per pass: the counted number (age rows
#' summed), or the measured fish where the count is missing or short of them; a sentinel count with
#' nothing measured is a catch of unknown size (`NA`, never 0); a row with 0 caught and nothing
#' measured is not a catch. Because the larger of the counted and measured numbers is taken per pass,
#' a visit's catch summed over its passes can exceed the visit table's `n_caught`, which takes it once
#' over the summed passes. Codes are kept as recorded: a code that blocks a species' absence (such as
#' "all fish") is a catch row, and which passes form one closed population is the caller's choice.
#'
#' `pass_status` is `"fish"` where a fish code was caught on the pass, `"nfc"` where only a
#' no-fish-caught code was recorded, and `"no_record"` where the pass has neither, which is unknown,
#' never zero. `flag_nfc_conflict` marks a pass recording both.
#'
#' @param passes `data.frame`, one row per pass: `KEY`, `site_visit`, `method_number`, `haul_or_pass`,
#'   `date`, `fishing_time_s`, `fished_length_m`, `fished_width_m`, `area_m2`, `flag_effort_sentinel`.
#' @param counts `data.frame`, the export's counts as `0230` reads them: `KEY`, `site_visit`,
#'   `species_code`, `n` (`NA` for a sentinel), `flag_count_sentinel`.
#' @param fish `data.frame`, one row per measured fish: `KEY`, `species_code`, `is_nfc`.
#' @param keep `character`, the site visits kept (the load drops repeat copies of one survey, #35).
#' @param codes `data.frame`, `data/fdis_species_codes.csv`: `code`, `catch_class` (`"fish"`,
#'   `"zero_catch"` or `"not_fish"`). Every code in `counts` and `fish` must be in it.
#' @return A list of two tibbles. `passes`: `KEY`, `site_visit`, `pass_index`, `n_pass`,
#'   `method_number`, `haul_or_pass`, `date`, `fishing_time_s`, `fished_length_m`, `fished_width_m`,
#'   `area_m2`, `flag_effort_sentinel`, `pass_status`, `flag_nfc_conflict`. `pass_catch`: `KEY`,
#'   `site_visit`, `species_code`, `n_counted`, `n_measured`, `n_caught`, `flag_count_sentinel`,
#'   `flag_counts_lt_measured`, for the kept passes only.
#' @export
#' @examples
#' passes <- data.frame(KEY = c("1_1_1_1_1", "1_1_1_1_2"), site_visit = "1_1_1",
#'                      method_number = 1L, haul_or_pass = 1:2, date = as.Date("2005-08-01"),
#'                      fishing_time_s = c(300, 250), fished_length_m = 50, fished_width_m = 4,
#'                      area_m2 = 200, flag_effort_sentinel = FALSE)
#' counts <- data.frame(KEY = c("1_1_1_1_1", "1_1_1_1_2"), site_visit = "1_1_1",
#'                      species_code = "BT", n = c(6, 2), flag_count_sentinel = FALSE)
#' fish <- data.frame(KEY = character(), species_code = character(), is_nfc = logical())
#' codes <- data.frame(code = c("BT", "NFC"), catch_class = c("fish", "zero_catch"))
#' # depletion from 6 to 2 over two passes: what a removal estimate reads
#' knw_fdis_passes(passes, counts, fish, keep = "1_1_1", codes)
knw_fdis_passes <- function(passes, counts, fish, keep, codes) {
  chk::chk_data(passes)
  chk::check_names(passes, c("KEY", "site_visit", "method_number", "haul_or_pass", "date", "fishing_time_s",
                             "fished_length_m", "fished_width_m", "area_m2", "flag_effort_sentinel"))
  chk::chk_data(counts)
  chk::check_names(counts, c("KEY", "site_visit", "species_code", "n", "flag_count_sentinel"))
  chk::chk_data(fish)
  chk::check_names(fish, c("KEY", "species_code", "is_nfc"))
  chk::chk_character(keep)
  chk::chk_data(codes)
  chk::check_names(codes, c("code", "catch_class"))
  if (anyDuplicated(passes$KEY)) stop("passes has a KEY more than once", call. = FALSE)
  unclassified <- setdiff(unique(c(counts$species_code, fish$species_code)), codes$code)
  if (length(unclassified)) {
    stop("species codes not in the code table: ", paste(sort(unclassified), collapse = ", "), call. = FALSE)
  }
  fish_codes <- codes$code[codes$catch_class == "fish"]
  zero_codes <- codes$code[codes$catch_class == "zero_catch"]

  p <- passes[passes$site_visit %in% keep, , drop = FALSE]
  p <- p[order(p$site_visit, p$method_number, p$haul_or_pass, method = "radix"), , drop = FALSE]
  p$pass_index <- stats::ave(seq_len(nrow(p)), p$site_visit, FUN = seq_along)
  p$n_pass <- stats::ave(seq_len(nrow(p)), p$site_visit, FUN = length)

  cnt <- counts[counts$species_code %in% fish_codes & counts$KEY %in% p$KEY, , drop = FALSE] |>
    dplyr::group_by(.data$KEY, .data$species_code) |>
    dplyr::summarise(n_counted = if (all(is.na(.data$n))) NA_real_ else sum(.data$n, na.rm = TRUE),
                     flag_count_sentinel = any(.data$flag_count_sentinel), .groups = "drop")
  mea <- fish[!fish$is_nfc & fish$species_code %in% fish_codes & fish$KEY %in% p$KEY, , drop = FALSE] |>
    dplyr::count(.data$KEY, .data$species_code, name = "n_measured")
  pc <- dplyr::full_join(cnt, mea, by = c("KEY", "species_code")) |>
    dplyr::mutate(
      n_measured = dplyr::coalesce(.data$n_measured, 0L),
      flag_count_sentinel = dplyr::coalesce(.data$flag_count_sentinel, FALSE),
      flag_counts_lt_measured = !is.na(.data$n_counted) & .data$n_counted < .data$n_measured,
      n_caught = dplyr::if_else(is.na(.data$n_counted) & .data$flag_count_sentinel & .data$n_measured == 0,
                                NA_real_, pmax(dplyr::coalesce(.data$n_counted, 0), .data$n_measured))
    ) |>
    dplyr::filter(is.na(.data$n_caught) | .data$n_caught > 0)
  pc$site_visit <- p$site_visit[match(pc$KEY, p$KEY)]
  pc <- pc[order(pc$site_visit, match(pc$KEY, p$KEY), pc$species_code, method = "radix"),
           c("KEY", "site_visit", "species_code", "n_counted", "n_measured", "n_caught", "flag_count_sentinel",
             "flag_counts_lt_measured")]

  nfc_keys <- unique(c(counts$KEY[counts$species_code %in% zero_codes], fish$KEY[fish$is_nfc]))
  p$pass_status <- ifelse(p$KEY %in% pc$KEY, "fish", ifelse(p$KEY %in% nfc_keys, "nfc", "no_record"))
  p$flag_nfc_conflict <- p$KEY %in% pc$KEY & p$KEY %in% nfc_keys
  p <- p[, c("KEY", "site_visit", "pass_index", "n_pass", "method_number", "haul_or_pass", "date",
             "fishing_time_s", "fished_length_m", "fished_width_m", "area_m2", "flag_effort_sentinel",
             "pass_status", "flag_nfc_conflict")]
  rownames(p) <- NULL
  list(passes = dplyr::as_tibble(p), pass_catch = dplyr::as_tibble(pc))
}
