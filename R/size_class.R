#' Size class of each fish from a table of length breaks
#'
#' Each break row covers `[length_min_mm, length_max_mm)` for one species group,
#' so a fish exactly on a break takes the upper class. The breaks must tile every
#' group that has a measured fish: a fish with a positive length that falls in no
#' class, or in more than one, is an error rather than an `NA`, because a gap or
#' an overlap in the table would otherwise read as "unmeasured".
#'
#' @param species_group `character` species group per fish, matched against
#'   `breaks$species_group`.
#' @param length_mm `numeric` length per fish, same length as `species_group`.
#'   `NA`, zero and negative lengths are unmeasured and return `NA`.
#' @param breaks `data.frame` with columns `species_group`, `size_class`,
#'   `length_min_mm` and `length_max_mm` (use `Inf` for an open top class).
#' @return `character` size class per fish, `NA` where unmeasured.
#' @export
#' @examples
#' breaks <- data.frame(
#'   species_group = c("CH", "CH"),
#'   size_class    = c("fry", "parr"),
#'   length_min_mm = c(0, 70),
#'   length_max_mm = c(70, Inf)
#' )
#' knw_size_class(c("CH", "CH", "CH"), c(45, 70, NA), breaks)
knw_size_class <- function(species_group, length_mm, breaks) {
  chk::chk_character(species_group)
  chk::chk_numeric(length_mm)
  chk::chk_equal(length(species_group), length(length_mm))
  chk::chk_data(breaks)
  chk::check_names(breaks, c("species_group", "size_class", "length_min_mm", "length_max_mm"))
  lo <- as.numeric(breaks$length_min_mm)
  hi <- as.numeric(breaks$length_max_mm)
  measured <- !is.na(length_mm) & length_mm > 0
  out <- rep(NA_character_, length(length_mm))
  hits <- integer(length(length_mm))
  for (i in seq_len(nrow(breaks))) {
    hit <- measured & !is.na(species_group) & species_group == breaks$species_group[i] &
      length_mm >= lo[i] & length_mm < hi[i]
    out[hit] <- breaks$size_class[i]
    hits <- hits + hit
  }
  bad <- measured & hits != 1L
  if (any(bad)) {
    stop("size breaks overlap or leave gaps: ", sum(bad), " measured fish in ",
         "zero or several classes (first: ", species_group[bad][1], " at ",
         length_mm[bad][1], " mm)", call. = FALSE)
  }
  out
}
