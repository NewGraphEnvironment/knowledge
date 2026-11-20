# The provincial Fish Data Submission workbook: which sheet is which step, where its header row sits, and which
# columns are read. Moved from scripts/0220-fiss-xls-parse-nfc.R (#7); 0220 is now the driver over these.

# Columns read per step, as janitor::make_clean_names() writes the template's labels. A name a sheet lacks is
# filled NA.
.knw_fiss_wanted <- list(
  keys = c("reference_number", "reach_number", "site_number",
           "gazetted_name", "local_name", "waterbody_id"),
  step1_ref_loc = c("survey_date", "utm_zone", "utm_easting", "utm_northing"),
  step2_fish_coll = c(
    "sampling_method", "method_number",
    "ef_seconds", "ef_length_m", "ef_width_m",
    "soak_time", "date_in", "date_out", "time_in", "time_out",
    "length_m", "width_m",
    "temperature_c", "conductivity_m_s_cm", "turbidity", "haul_pass",
    "species", "stage", "total_number", "min_length_mm", "max_length_mm", "comments"
  ),
  # Step 3 is one row per fish. It carries no date or coordinates: those come from the
  # Step 1 site through site_key, and the sampling event from method_number + haul_pass.
  step3_indiv_fish = c(
    "sampling_method", "method_number", "haul_pass",
    "species", "length_mm", "weight_g", "sex", "maturity", "age", "comments"
  ),
  step4_site_data = c(
    "utm_zone", "utm_easting", "utm_northing",
    "channel_width_m", "channel_width_m_2", "channel_width_m_3", "channel_width_m_4",
    "channel_width_m_5", "channel_width_m_6", "channel_width_m_7", "avg_channel_width_m",
    "wetted_width_m", "wetted_width_m_2", "wetted_width_m_3", "wetted_width_m_4",
    "wetted_width_m_5", "wetted_width_m_6", "wetted_width_m_7", "avg_wetted_width_m",
    "average_gradient_percent",
    "temperature_c", "conductivity_m_s_cm", "comments"
  )
)

# Name variants across template editions -> canonical. The pre-2012 edition writes species as a code under
# `species_code`, the method under `method` and the pass under `haul_or_pass`; without the first two, 82 of 232
# Step 2 sheets (5 groups, 2026-09-28) parsed with no species at all. `date_yyyy_mm_day` is its Step 1 date
# (23 of 45 UPCE workbooks parsed undated without it).
.knw_fiss_variants <- c(
  gazetted_names          = "gazetted_name",
  alias_local_name        = "local_name",
  waterbody_id_identifier = "waterbody_id",
  species_code            = "species",
  method                  = "sampling_method",
  haul_or_pass            = "haul_pass",
  haul_number_pass_number = "haul_pass",
  date_yyyy_mm_day        = "survey_date"
)

# Sheet names drift across editions; each step is found by pattern, lower-cased.
.knw_fiss_step_pat <- c(
  step1_ref_loc    = "step.?1|ref.*loc|location",
  step2_fish_coll  = "step.?2|fish.?coll|collection.?form",
  step3_indiv_fish = "step.?3|indiv",
  step4_site_data  = "step.?4|stream.?site|site.?data|site.?card|site.?coll"
)

.knw_fiss_num <- function(x) suppressWarnings(as.numeric(as.character(x)))

.knw_fiss_first_nonempty <- function(v) {
  v <- v[!is.na(v) & nchar(trimws(v)) > 0]
  if (length(v)) trimws(v[1]) else NA_character_
}

.knw_fiss_chk_cols <- function(cols, step) {
  chk::chk_list(cols)
  if (!is.character(cols[["keys"]]) || !"reference_number" %in% cols[["keys"]]) {
    stop("cols must hold a character vector `keys` naming reference_number", call. = FALSE)
  }
  if (!is.character(cols[[step]])) stop("cols has no character vector for ", step, call. = FALSE)
}

# a sheet laid out one row per fish, whatever it is named
.knw_fiss_is_fish_layout <- function(nm) "length_mm" %in% nm && !"total_number" %in% nm

.knw_fiss_chk_step <- function(step) {
  chk::chk_string(step)
  chk::chk_subset(step, names(.knw_fiss_step_pat))
}

#' The columns, name variants and sheet patterns the workbook parser reads
#'
#' The provincial Fish Data Submission workbook has four step sheets: Step 1 (reference and location), Step 2
#' (fish collection: effort and the catch per species), Step 3 (individual fish) and Step 4 (stream site). Its
#' editions name the sheets and some columns differently. This returns what [knw_fiss_parse_step()] reads, so a
#' caller can see it without reading the code.
#'
#' @return A list: `wanted`, the columns read per step (plus `keys`, read on every step), in
#'   `janitor::make_clean_names()` form; `variants`, a named character vector mapping an edition's column name to
#'   the canonical one; `step_pattern`, the regular expression that finds each step's sheet by its lower-cased
#'   name.
#' @export
#' @examples
#' cols <- knw_fiss_columns()
#' cols$step_pattern
#' # the pre-2012 edition's names and the ones they are read as
#' cols$variants
knw_fiss_columns <- function() {
  list(wanted = .knw_fiss_wanted, variants = .knw_fiss_variants, step_pattern = .knw_fiss_step_pat)
}

#' Find a workbook's sheet for one step
#'
#' Sheet names drift across the template's editions ("Step 4 (Stream Site Data)", "Step 4 (Site Card Data)",
#' "Fish collection"), so each step is found by a pattern on the lower-cased name (see [knw_fiss_columns()]).
#'
#' @param sheets `character`, the workbook's sheet names (`readxl::excel_sheets()`).
#' @param step `string`, one of `"step1_ref_loc"`, `"step2_fish_coll"`, `"step3_indiv_fish"`,
#'   `"step4_site_data"`.
#' @return `string`, the first sheet that matches, or `NA` when none does (a tissue-data workbook or a reach
#'   summary).
#' @export
#' @examples
#' sheets <- c("INSTRUCTIONS", "Step 1 (Ref. and Loc. Info)", "Step 2 (Fish Coll. Data)",
#'             "Step 3 (Individual Fish Data)", "Step 4 (Site Card Data)")
#' knw_fiss_match_sheet(sheets, "step4_site_data")
#' knw_fiss_match_sheet("Tissue", "step2_fish_coll")
knw_fiss_match_sheet <- function(sheets, step) {
  chk::chk_character(sheets)
  .knw_fiss_chk_step(step)
  hit <- sheets[stringr::str_detect(tolower(sheets), .knw_fiss_step_pat[[step]])]
  if (length(hit)) hit[1] else NA_character_
}

#' Read one step sheet, finding its header row
#'
#' The header is not row 1: title, instruction and section rows sit above the field labels, and how many
#' depends on the edition and the step (rows 17, 26 and 31 for Step 1, 4 to 23 for the others). The label row is
#' the first within the top 40 whose first non-empty cell starts with "REFERENCE NUMBER". Its labels become
#' `janitor::make_clean_names()` names, and an edition's variant name is renamed to the canonical one unless the
#' sheet already carries the canonical name. A data row must carry a reference number, which drops the
#' template's pre-formatted blank entry rows.
#'
#' @param path `string`, a workbook (`.xls` or `.xlsx`).
#' @param sheet `string`, the sheet to read.
#' @return A list: `status` (`"ok"`, `"empty_sheet"` or `"no_header"`), `header_row`, `banner` (the first
#'   non-empty cell of row 1, which names the template edition), `rows_raw` (rows under the header before
#'   filtering) and `data` (a tibble of the rows kept, every cell as `readxl` returned it, or `NULL`).
#' @export
#' @examples
#' f <- system.file("testdata", "fiss", "template_v2.xls", package = "knowledge")
#' s <- knw_fiss_read_step(f, "Step 1 (Ref. and Loc. Info)")
#' s$header_row
#' s$banner
#' s$data[, c("reference_number", "utm_zone", "utm_easting", "utm_northing")]
knw_fiss_read_step <- function(path, sheet) {
  chk::chk_file(path)
  chk::chk_string(sheet)
  read <- function() readxl::read_excel(path, sheet = sheet, col_names = FALSE, .name_repair = "minimal")
  raw <- as.data.frame(suppressWarnings(suppressMessages(read())))
  out <- list(status = "ok", header_row = NA_integer_, banner = NA_character_,
              rows_raw = 0L, data = NULL)
  if (!nrow(raw)) {
    out$status <- "empty_sheet"
    return(out)
  }
  out$banner <- .knw_fiss_first_nonempty(as.character(unlist(raw[1, ])))
  hdr <- NA_integer_
  for (r in seq_len(min(nrow(raw), 40L))) {
    fc <- .knw_fiss_first_nonempty(as.character(unlist(raw[r, ])))
    if (!is.na(fc) && stringr::str_detect(tolower(fc), "^reference number")) {
      hdr <- r
      break
    }
  }
  if (is.na(hdr) || hdr >= nrow(raw)) {
    out$status <- "no_header"
    return(out)
  }
  out$header_row <- hdr
  out$rows_raw   <- nrow(raw) - hdr
  # janitor warns on every "µS/cm" label; it writes "m" for the "µ", which is the name the column list reads
  # (`conductivity_m_s_cm`), so that one warning is muffled and any other passes through
  labels <- as.character(unlist(raw[hdr, ]))
  labels[is.na(labels)] <- ""
  muffle_mu <- function(w) {
    if (grepl("mu or micro symbol", conditionMessage(w))) invokeRestart("muffleWarning")
  }
  nm <- withCallingHandlers(janitor::make_clean_names(labels), warning = muffle_mu)
  dat <- raw[(hdr + 1L):nrow(raw), , drop = FALSE]
  names(dat) <- nm
  dat <- dat[, nm != "" & !stringr::str_detect(nm, "^x(_[0-9]+)?$"), drop = FALSE]
  # an edition's variant is renamed only when the canonical name is NOT already present: a sheet carrying both
  # would otherwise hold one name twice, and tibble's uniqueness check would drop the whole step
  for (v in names(.knw_fiss_variants)) {
    canon <- .knw_fiss_variants[[v]]
    if (v %in% names(dat) && !(canon %in% names(dat))) names(dat)[names(dat) == v] <- canon
  }
  # a real data row carries the reference_number key; this also drops the hundreds of pre-formatted blank entry
  # rows the template ships, whose stray non-empty cells defeat a plain all-empty filter
  if ("reference_number" %in% names(dat)) {
    rn <- trimws(as.character(dat$reference_number))
    dat <- dat[!is.na(rn) & rn != "" & tolower(rn) != "na", , drop = FALSE]
  } else {
    dat <- dat[rowSums(!is.na(dat) & dat != "") > 0, , drop = FALSE]
  }
  out$data <- tibble::as_tibble(dat)
  out
}

#' Keep a step's wanted columns and drop rows that carry only keys
#'
#' Takes the key columns, the step's columns (see [knw_fiss_columns()]) and every column whose name contains
#' "comment", and adds a wanted column the sheet lacks as `NA`. The template pre-fills the reference number and
#' names on hundreds of blank entry rows, so a row is kept only when at least one non-key cell is filled.
#'
#' @param df `data.frame`, a step's rows as [knw_fiss_read_step()] returns them in `data`.
#' @param step `string`, the step (see [knw_fiss_match_sheet()]).
#' @param cols `list`, the columns read per step, with `keys` read on every step; by default
#'   `knw_fiss_columns()$wanted`. Add a name to read a column the default does not.
#' @return `df`'s wanted columns, then any other comment columns, with the key-only rows dropped.
#' @export
#' @examples
#' df <- data.frame(reference_number = c("1", "2"), gazetted_name = "Test Creek",
#'                  utm_zone = c("10", NA), utm_easting = c("612000", NA),
#'                  utm_northing = c("5980000", NA), site_comments = c(NA, NA))
#' # row 2 carries only keys
#' knw_fiss_select(df, "step1_ref_loc")
knw_fiss_select <- function(df, step, cols = knw_fiss_columns()$wanted) {
  chk::chk_data(df)
  .knw_fiss_chk_step(step)
  .knw_fiss_chk_cols(cols, step)
  want <- unique(c(cols[["keys"]], cols[[step]]))
  present   <- intersect(want, names(df))
  comment_c <- setdiff(names(df)[stringr::str_detect(names(df), "comment")], present)
  out <- df[, c(present, comment_c), drop = FALSE]
  for (m in setdiff(want, present)) out[[m]] <- NA
  payload <- setdiff(names(out), cols[["keys"]])
  if (length(payload) && nrow(out)) {
    mat <- sapply(out[payload], function(c) {
      v <- trimws(as.character(c))
      !is.na(v) & v != "" & tolower(v) != "na"
    })
    if (is.null(dim(mat))) mat <- matrix(mat, nrow = nrow(out))
    out <- out[rowSums(mat) > 0, , drop = FALSE]
  }
  out
}

#' Parse one step of one workbook, naming why it yielded nothing
#'
#' Finds the step's sheet, reads it and keeps its wanted rows, keyed by `site_key` (`report_id:reference_number`:
#' a reference number is unique only within one submission). Every way a step can yield nothing has a status of
#' its own, so a group's parse log shows each one by name:
#'
#' - `sheets_error`: the workbook's sheets could not be listed;
#' - `no_sheet_match`: no sheet matches the step (tissue data, reach summaries);
#' - `read_error`: reading the sheet failed;
#' - `empty_sheet`: the sheet has no rows;
#' - `no_header`: no "REFERENCE NUMBER" label row in the top 40;
#' - `no_rows`: a header, but no row kept;
#' - `fish_layout`: a Step 2 sheet laid out one row per fish (`length_mm` and no `total_number`), whose rows are
#'   read as Step 3 instead;
#' - `ok`: rows kept.
#'
#' Step 3 falls back to the Step 2 sheet when its own sheet gives no rows and the Step 2 sheet is in fish layout:
#' the template ships an empty Step 3 beside whatever was filled in.
#'
#' @param path `string`, a workbook (`.xls` or `.xlsx`).
#' @param report_id `string`, the submission's EcoCat report id.
#' @param step `string`, the step (see [knw_fiss_match_sheet()]).
#' @param cols `list`, the columns read per step (see [knw_fiss_select()]).
#' @return A list: `data`, a tibble led by `report_id` and `site_key` (`NULL` unless the status is `"ok"`), and
#'   `log`, a one-row tibble: `report_id`, `path`, `step`, `status`, `sheet_matched`, `n_sheet_hits`,
#'   `header_row`, `banner`, `rows_raw`, `rows_after_filter`.
#' @export
#' @examples
#' f <- system.file("testdata", "fiss", "individual_fish.xls", package = "knowledge")
#' # a per-fish sheet named like Step 2 is set aside there and read as Step 3
#' knw_fiss_parse_step(f, "16389", "step2_fish_coll")$log$status
#' s3 <- knw_fiss_parse_step(f, "16389", "step3_indiv_fish")
#' s3$log[, c("status", "sheet_matched", "header_row")]
#' s3$data[, c("site_key", "species", "length_mm")]
knw_fiss_parse_step <- function(path, report_id, step, cols = knw_fiss_columns()$wanted) {
  chk::chk_string(path)
  chk::chk_string(report_id)
  .knw_fiss_chk_step(step)
  .knw_fiss_chk_cols(cols, step)
  lg <- tibble::tibble(report_id = report_id, path = path, step = step,
                       status = NA_character_, sheet_matched = NA_character_, n_sheet_hits = 0L,
                       header_row = NA_integer_, banner = NA_character_,
                       rows_raw = 0L, rows_after_filter = 0L)
  done <- function(status, data = NULL) {
    lg$status <- status
    list(data = data, log = lg)
  }
  sheets <- tryCatch(readxl::excel_sheets(path), error = function(e) NULL)
  if (is.null(sheets)) return(done("sheets_error"))
  sh <- knw_fiss_match_sheet(sheets, step)
  lg$n_sheet_hits <- sum(stringr::str_detect(tolower(sheets), .knw_fiss_step_pat[[step]]))
  rs <- if (is.na(sh)) NULL else tryCatch(knw_fiss_read_step(path, sh), error = function(e) NULL)
  # per-fish rows filed under a Step 2 name (UNTH 16389, LNTH 16393: "Fish collection") are Step 3. Fall back to
  # that sheet whenever the Step 3 sheet gives no rows, not only when there is none
  if (step == "step3_indiv_fish" && (is.null(rs) || rs$status != "ok" || !nrow(rs$data))) {
    alt <- knw_fiss_match_sheet(sheets, "step2_fish_coll")
    if (!is.na(alt)) {
      r <- tryCatch(knw_fiss_read_step(path, alt), error = function(e) NULL)
      if (!is.null(r) && r$status == "ok" && .knw_fiss_is_fish_layout(names(r$data))) {
        sh <- alt
        rs <- r
      }
    }
  }
  if (is.na(sh)) return(done("no_sheet_match"))
  lg$sheet_matched <- sh
  if (is.null(rs)) return(done("read_error"))
  lg$header_row <- rs$header_row
  lg$banner <- rs$banner
  lg$rows_raw <- rs$rows_raw
  if (rs$status != "ok") return(done(rs$status))
  if (step == "step2_fish_coll" && .knw_fiss_is_fish_layout(names(rs$data))) return(done("fish_layout"))
  if (!nrow(rs$data)) return(done("no_rows"))
  df <- knw_fiss_select(rs$data, step, cols)
  df <- dplyr::mutate(df, report_id = report_id,
                      site_key = paste(report_id, .data$reference_number, sep = ":"), .before = 1)
  lg$rows_after_filter <- nrow(df)
  if (!nrow(df)) return(done("no_rows"))
  done("ok", df)
}

#' Read a UTM zone as entered
#'
#' Submitters write the zone as "10", "11U", "10 U" or "zone 11". The letter is the latitude band (all of BC is U
#' or V), so the zone is the leading digits. Read as a plain number, "11U" was `NA` on 116 sites each in two
#' North Thompson groups, which were then never placed.
#'
#' @param x a vector of zones as entered.
#' @return `numeric`, the zone, or `NA` where `x` carries no digits.
#' @export
#' @examples
#' knw_fiss_utm_zone(c("10", "11U", "10 U", "zone 11", "", NA))
knw_fiss_utm_zone <- function(x) {
  .knw_fiss_num(stringr::str_extract(trimws(as.character(x)), "[0-9]+"))
}
