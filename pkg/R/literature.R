#' Controlled vocabularies of the literature evidence table
#'
#' The values each controlled column of a table read by [knw_literature_read()]
#' may take. `life_stage` is [knw_timing_stages()] plus `access`.
#' `life_history_form` separates stream- and ocean-type Chinook and resident,
#' fluvial and adfluvial bull trout; `migratory` is for a source that says
#' "migratory" without separating fluvial from adfluvial. Width units say
#' which width a source measured, because bankfull and wetted width are not
#' interchangeable. `kind` says what sort of number a row is: a parameter
#' someone chose, a habitat-suitability breakpoint, the largest value observed,
#' a statistic of where fish were found, a preference, expert opinion, a
#' qualitative statement, or `none`, a search that found nothing.
#'
#' @return A named `list` of `character` vectors, one per controlled column.
#' @export
#' @examples
#' knw_literature_vocab()$variable
knw_literature_vocab <- function() {
  list(
    life_stage = c(knw_timing_stages(), "access"),
    life_history_form = c("stream_type", "ocean_type", "resident", "fluvial", "adfluvial",
                          "migratory"),
    variable = c("gradient", "channel_width", "stream_order", "discharge", "lake_area",
                 "wetland_area", "bridge_distance", "temperature", "substrate", "depth",
                 "velocity", "timing"),
    bound = c("min", "max", "range", "optimum"),
    unit = c("percent", "m bankfull", "m wetted", "m", "order", "m3/s", "ha", "km", "degC",
             "mm", "m/s", "MM-DD"),
    kind = c("param", "hsi", "max_obs", "dist", "pref", "expert", "qual", "none")
  )
}

#' Read the literature evidence table, filtered by species and variable
#'
#' One row per value a source gives for a habitat variable: species, life
#' stage, life-history form, variable, the model parameter it bears on
#' (`parameter`, e.g. `spawn_gradient_max`), bound, value, unit, kind, region,
#' citation key, page and a verbatim quote. `value_min` and `value_max` are
#' numbers written as text, or `MM-DD` for `timing`, where a range with
#' `value_min > value_max` crosses 1 January.
#'
#' A row of kind `none` records a search that found no value: it carries a
#' `note` saying what was searched and no value, key or quote. Every other row
#' needs a `citation_key` and a `quote`. A row with a value needs a `unit`.
#'
#' The table is validated before filtering, so a bad row anywhere in the file is
#' an error whichever species is asked for. A requested species or variable
#' absent from the table is a warning, so a typo does not read as "no evidence".
#'
#' @param path `character(1)` path to the evidence CSV.
#' @param species_code `character` species codes to keep, or `NULL` for all.
#' @param variable `character` variables to keep (see [knw_literature_vocab()]),
#'   or `NULL` for all.
#' @return A `tibble` with the fifteen columns, all `character`.
#' @export
#' @examples
#' path <- tempfile(fileext = ".csv")
#' utils::write.csv(data.frame(
#'   species_code = "BT", life_stage = "spawning", life_history_form = "migratory",
#'   variable = "channel_width", parameter = "spawn_channel_width_min", bound = "min",
#'   value_min = "2", value_max = NA, unit = "m wetted", kind = "expert",
#'   region = "Parsnip, BC", citation_key = "key_a", page = "22",
#'   quote = "No streams of <2 m wetted width were surveyed", note = NA
#' ), path, row.names = FALSE, na = "")
#' knw_literature_read(path, species_code = "BT", variable = "channel_width")
knw_literature_read <- function(path, species_code = NULL, variable = NULL) {
  chk::chk_file(path)
  chk::chk_null_or(species_code, vld = chk::vld_character)
  chk::chk_null_or(variable, vld = chk::vld_character)
  if ((!is.null(species_code) && !length(species_code)) ||
      (!is.null(variable) && !length(variable))) {
    stop("an empty filter matches nothing; pass NULL for all", call. = FALSE)
  }
  cols <- c("species_code", "life_stage", "life_history_form", "variable", "parameter",
            "bound", "value_min", "value_max", "unit", "kind", "region", "citation_key",
            "page", "quote", "note")
  x <- .knw_read_csv(path)
  chk::check_names(x, cols)
  x <- x[cols]
  x[] <- lapply(x, function(v) {
    v <- trimws(v, whitespace = "[\\h\\v]")
    v[!is.na(v) & !nzchar(v)] <- NA
    v
  })
  .literature_check(x)

  for (arg in c("species_code", "variable")) {
    miss <- setdiff(get(arg), x[[arg]])
    if (length(miss)) warning(arg, " not in the evidence table: ", paste(miss, collapse = ", "),
                              call. = FALSE)
  }
  keep <- rep(TRUE, nrow(x))
  if (!is.null(species_code)) keep <- keep & x$species_code %in% species_code
  if (!is.null(variable)) keep <- keep & x$variable %in% variable
  tibble::as_tibble(x[keep, , drop = FALSE])
}

# Row-level rules. Each stop() names the column and the first offending value so
# a hand edit can be found without re-reading the whole table.
.literature_check <- function(x) {
  # The data row only: its file line depends on blank lines and quoted line breaks,
  # which read.csv() absorbs, so a line number here would be a guess.
  first <- function(i) paste0(" (data row ", which(i)[1], ")")
  if (anyNA(x$species_code)) {
    stop("species_code is blank", first(is.na(x$species_code)), call. = FALSE)
  }
  vocab <- knw_literature_vocab()
  required <- c("life_stage", "variable", "kind")
  for (col in names(vocab)) {
    v <- x[[col]]
    bad <- if (col %in% required) is.na(v) | !v %in% vocab[[col]] else !is.na(v) & !v %in% vocab[[col]]
    if (any(bad)) {
      stop(col, " outside knw_literature_vocab(): ", v[bad][1], first(bad), call. = FALSE)
    }
  }

  none <- x$kind == "none"
  has_value <- !is.na(x$value_min) | !is.na(x$value_max)
  if (any(none & (has_value | !is.na(x$unit)))) {
    stop("a 'none' row carries no value or unit", first(none & (has_value | !is.na(x$unit))),
         call. = FALSE)
  }
  cited <- !is.na(x$citation_key) | !is.na(x$quote)
  if (any(none & cited)) {
    stop("a 'none' row carries no citation_key or quote", first(none & cited), call. = FALSE)
  }
  if (any(none & is.na(x$note))) {
    stop("a 'none' row needs a note saying what was searched", first(none & is.na(x$note)),
         call. = FALSE)
  }
  for (col in c("citation_key", "quote")) {
    miss <- !none & is.na(x[[col]])
    if (any(miss)) stop(col, " is blank on a cited row", first(miss), call. = FALSE)
  }
  no_unit <- has_value & is.na(x$unit)
  if (any(no_unit)) stop("a value needs a unit", first(no_unit), call. = FALSE)

  timing <- x$variable == "timing"
  day <- c(x$value_min[timing], x$value_max[timing])
  day <- day[!is.na(day)]
  ok <- grepl("^[0-9]{2}-[0-9]{2}$", day) &
    !is.na(as.Date(paste0("2000-", day), format = "%Y-%m-%d"))
  if (!all(ok)) {
    stop("timing values must be real dates written MM-DD: ", day[!ok][1], call. = FALSE)
  }
  # MM-DD on a numeric variable, or a number on a timing row, is a unit mix-up.
  unit_bad <- (timing & has_value & !x$unit %in% "MM-DD") | (!timing & x$unit %in% "MM-DD")
  if (any(unit_bad)) {
    stop("unit MM-DD belongs to timing rows only", first(unit_bad), call. = FALSE)
  }

  num <- lapply(c("value_min", "value_max"), function(col) {
    v <- x[[col]]
    n <- suppressWarnings(as.numeric(v))
    bad <- !timing & !is.na(v) & !is.finite(n)
    if (any(bad)) stop(col, " must be numeric: ", v[bad][1], first(bad), call. = FALSE)
    n
  })
  flip <- !timing & !is.na(num[[1]]) & !is.na(num[[2]]) & num[[1]] > num[[2]]
  if (any(flip)) stop("value_min > value_max", first(flip), call. = FALSE)
  invisible(x)
}
