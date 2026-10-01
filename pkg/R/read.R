# Read a hand-edited CSV as all-character columns, refusing any file that is not
# UTF-8. `read.csv(fileEncoding = "UTF-8-BOM")` stops at the first invalid byte
# with only a warning, so a cp1252 degree sign (Excel's plain "CSV" save) used to
# return a silently truncated table that then passed validation.
.knw_read_csv <- function(path) {
  bytes <- readBin(path, "raw", file.size(path))
  if (length(bytes) >= 3 && identical(bytes[1:3], as.raw(c(0xEF, 0xBB, 0xBF)))) {
    bytes <- bytes[-(1:3)]
  }
  if (any(bytes == as.raw(0))) stop(path, " contains NUL bytes; not a text CSV", call. = FALSE)
  txt <- rawToChar(bytes)
  if (!validUTF8(txt)) {
    stop(path, " is not valid UTF-8; re-save it as \"CSV UTF-8\"", call. = FALSE)
  }
  Encoding(txt) <- "UTF-8"
  utils::read.csv(text = txt, colClasses = "character", na.strings = "", check.names = FALSE,
                  encoding = "UTF-8")
}

# Trim every cell (horizontal and vertical whitespace, so a stray non-breaking
# space or line break does not survive) and read an empty one as NA.
.knw_blank_to_na <- function(x) {
  x[] <- lapply(x, function(v) {
    v <- trimws(v, whitespace = "[\\h\\v]")
    v[!is.na(v) & !nzchar(v)] <- NA
    v
  })
  x
}

# A model_id: lower-case letters, digits and underscores, starting with a letter.
.knw_model_id_pattern <- "^[a-z][a-z0-9_]*$"
