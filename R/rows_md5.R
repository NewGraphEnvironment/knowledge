# The md5 of a CSV's header and the rows of one species and stage, so a guard on a table that holds every
# species fires only when that species' rows change (#62). Each row must sit on one line.
.knw_rows_md5 <- function(path, species_code, stage) {
  l <- readLines(path)
  d <- utils::read.csv(path, colClasses = "character", check.names = FALSE)
  if (length(l) != nrow(d) + 1L) stop(path, ": a quoted field spans lines; rows cannot be told from lines", call. = FALSE)
  keep <- c(1L, which(d$species_code == species_code & d$stage == stage) + 1L)
  if (length(keep) < 2L) stop(path, " has no ", species_code, " ", stage, " rows", call. = FALSE)
  tf <- tempfile(fileext = ".csv")
  on.exit(unlink(tf))
  writeLines(l[keep], tf)
  unname(tools::md5sum(tf))
}
