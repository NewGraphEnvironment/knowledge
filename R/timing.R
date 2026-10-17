#' Life stages in the life-history timing table
#'
#' The controlled vocabulary for `life_stage` in a timing table read by
#' [knw_timing_read()]. `fry_migration` is upstream movement of fry;
#' `outmigration` is seaward movement of juveniles.
#'
#' @return `character` life stages.
#' @export
#' @examples
#' knw_timing_stages()
knw_timing_stages <- function() {
  c("migration", "spawning", "incubation", "emergence", "fry_migration",
    "rearing", "overwintering", "outmigration")
}

#' Read the life-history timing table, filtered by group and species
#'
#' One row per watershed group, species, life stage and window. `start` and
#' `end` are month-day (`MM-DD`) with no year, so a window with `start > end`
#' crosses 1 January. A window the source gave only one end of keeps the other
#' as `NA`; a row with neither is an error. `source` holds Zotero citation keys
#' separated by `"; "`.
#'
#' The table is validated before filtering, so a bad row anywhere in the file is
#' an error whichever group is asked for. Within one group, species and stage,
#' windows must not overlap (a half window's known day counts), and a window
#' crossing 1 January is one row: a
#' window ending `12-31` beside one starting `01-01` is refused, because the pair
#' reads as two windows to anything that counts them. `start == end` is refused
#' as ambiguous between one day and a whole year. A requested group or species
#' absent from the table is a warning, so a typo does not read as "no data".
#'
#' @param path `character(1)` path to the timing CSV, with columns `wsg_code`,
#'   `species_code`, `life_stage`, `start`, `end`, `source` and `note`.
#' @param wsg_code `character` watershed group codes to keep, or `NULL` for all.
#' @param species_code `character` species codes to keep, or `NULL` for all.
#' @return A `tibble` with the seven columns, all `character`.
#' @export
#' @examples
#' path <- tempfile(fileext = ".csv")
#' utils::write.csv(data.frame(
#'   wsg_code = c("MORR", "MORR"), species_code = c("CH", "BT"),
#'   life_stage = c("spawning", "incubation"), start = c("09-01", "08-23"),
#'   end = c("10-07", "04-30"), source = c("key_a", "key_b"), note = NA
#' ), path, row.names = FALSE, na = "")
#' knw_timing_read(path, wsg_code = "MORR", species_code = "BT")
knw_timing_read <- function(path, wsg_code = NULL, species_code = NULL) {
  chk::chk_file(path)
  chk::chk_null_or(wsg_code, vld = chk::vld_character)
  chk::chk_null_or(species_code, vld = chk::vld_character)
  if ((!is.null(wsg_code) && !length(wsg_code)) ||
      (!is.null(species_code) && !length(species_code))) {
    stop("an empty filter matches nothing; pass NULL for all", call. = FALSE)
  }
  cols <- c("wsg_code", "species_code", "life_stage", "start", "end", "source", "note")
  x <- .knw_read_csv(path)
  chk::check_names(x, cols)
  x <- x[cols]
  x[] <- lapply(x, function(v) {
    v <- trimws(v, whitespace = "[\\h\\v]")
    v[!is.na(v) & !nzchar(v)] <- NA
    v
  })

  blank <- is.na(x$wsg_code) | is.na(x$species_code)
  if (any(blank)) {
    stop(sum(blank), " row(s) with no wsg_code or species_code", call. = FALSE)
  }
  bad_stage <- setdiff(x$life_stage[!is.na(x$life_stage)], knw_timing_stages())
  if (anyNA(x$life_stage) || length(bad_stage)) {
    stop("life_stage outside knw_timing_stages(): ",
         paste(c(bad_stage, if (anyNA(x$life_stage)) "NA"), collapse = ", "), call. = FALSE)
  }
  day <- c(x$start, x$end)
  day <- day[!is.na(day)]
  ok <- grepl("^[0-9]{2}-[0-9]{2}$", day) &
    !is.na(as.Date(paste0("2000-", day), format = "%Y-%m-%d"))
  if (!all(ok)) {
    stop("start/end must be real dates written MM-DD: ",
         paste(unique(day[!ok]), collapse = ", "), call. = FALSE)
  }
  empty <- is.na(x$start) & is.na(x$end)
  if (any(empty)) {
    stop(sum(empty), " row(s) have neither start nor end (first: ",
         x$species_code[empty][1], " ", x$life_stage[empty][1], ")", call. = FALSE)
  }

  same <- !is.na(x$start) & !is.na(x$end) & x$start == x$end
  if (any(same)) {
    stop("start equals end (one day or a whole year?): ", x$species_code[same][1], " ",
         x$life_stage[same][1], " ", x$start[same][1], call. = FALSE)
  }
  .timing_check_windows(x)

  for (arg in c("wsg_code", "species_code")) {
    miss <- setdiff(get(arg), x[[arg]])
    if (length(miss)) warning(arg, " not in the timing table: ", paste(miss, collapse = ", "),
                              call. = FALSE)
  }
  keep <- rep(TRUE, nrow(x))
  if (!is.null(wsg_code)) keep <- keep & x$wsg_code %in% wsg_code
  if (!is.null(species_code)) keep <- keep & x$species_code %in% species_code
  tibble::as_tibble(x[keep, , drop = FALSE])
}

# Windows per group x species x stage: no day covered twice, and no window split
# at 1 January. Days are counted on a leap year so 02-29 is a day like any other.
.timing_check_windows <- function(x) {
  doy <- function(d) as.integer(format(as.Date(paste0("2000-", d)), "%j"))
  key <- paste(x$wsg_code, x$species_code, x$life_stage)
  for (k in unique(key)) {
    i <- which(key == k)
    days <- unlist(lapply(i, function(j) {
      known <- c(x$start[j], x$end[j])
      if (anyNA(known)) return(doy(known[!is.na(known)]))
      a <- doy(x$start[j])
      b <- doy(x$end[j])
      if (a <= b) a:b else c(a:366, 1:b)
    }))
    if (anyDuplicated(days)) {
      stop("overlapping windows for ", k, call. = FALSE)
    }
    year <- i[x$start[i] %in% "01-01" & x$end[i] %in% "12-31"]
    tail_i <- setdiff(i[x$end[i] %in% "12-31"], year)
    head_i <- setdiff(i[x$start[i] %in% "01-01"], year)
    if (any(outer(tail_i, head_i, `!=`))) {
      stop("window split at 1 January for ", k, "; write it as one row with start > end",
           call. = FALSE)
    }
  }
  invisible(x)
}
