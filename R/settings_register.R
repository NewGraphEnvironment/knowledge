# The settings register (`inst/method/settings.csv`, #93) names where each value lives. These resolve one `where`
# entry to the value the code holds, so the register test and data-raw/vignette_method.R compare the same thing.
# `fn:<function>:<argument>[<name or position>]` is a knowledge function's default; `script:<path>:<name>` a
# top-level constant assignment in a script under `root`. `ext:` (another repo's file) and `record:` (a value a run
# recorded) are read by data-raw/vignette_method.R against the run, not here.
.knw_where_kinds <- c("fn", "script", "ext", "record")

.knw_where_parse <- function(where) {
  parts <- strsplit(where, ":", fixed = TRUE)[[1]]
  kind <- parts[1]
  if (!kind %in% .knw_where_kinds) stop("unknown kind in `", where, "`", call. = FALSE)
  n_parts <- c(fn = 3L, script = 3L, ext = 4L, record = 2L)[[kind]]
  if (length(parts) != n_parts) stop("`", where, "` needs ", n_parts, " parts separated by ':'", call. = FALSE)
  sel <- NA_character_
  last <- parts[n_parts]
  if (grepl("\\[[^]]+\\]$", last)) {
    sel <- sub("^.*\\[([^]]+)\\]$", "\\1", last)
    parts[n_parts] <- sub("\\[[^]]+\\]$", "", last)
  }
  list(kind = kind, parts = parts[-1], sel = sel)
}

# A register value as written: `;`-separated, numeric when every piece is a number.
.knw_setting_parse <- function(value) {
  v <- strsplit(value, ";", fixed = TRUE)[[1]]
  num <- suppressWarnings(as.numeric(v))
  if (all(!is.na(num))) num else v
}

.knw_where_value <- function(where, root = ".") {
  w <- .knw_where_parse(where)
  if (w$kind == "fn") {
    ns <- asNamespace("knowledge")
    if (!exists(w$parts[1], envir = ns, inherits = FALSE)) stop("no function ", w$parts[1], call. = FALSE)
    f <- formals(get(w$parts[1], envir = ns))
    if (!w$parts[2] %in% names(f)) stop(w$parts[1], "() has no argument ", w$parts[2], call. = FALSE)
    x <- eval(f[[w$parts[2]]], baseenv())
  } else if (w$kind == "script") {
    path <- file.path(root, w$parts[1])
    if (!file.exists(path)) stop("no script ", w$parts[1], call. = FALSE)
    hit <- Filter(function(e) is.call(e) && identical(e[[1]], as.name("<-")) && identical(e[[2]], as.name(w$parts[2])),
                  as.list(parse(path, keep.source = FALSE)))
    if (length(hit) != 1L) stop(w$parts[1], " assigns ", w$parts[2], " at its top level ", length(hit), " times",
                                call. = FALSE)
    x <- eval(hit[[1]][[3]], baseenv())
  } else {
    stop("`", where, "` is read against the run, not here", call. = FALSE)
  }
  if (!is.na(w$sel)) {
    i <- suppressWarnings(as.integer(w$sel))
    x <- if (is.na(i)) x[[w$sel]] else x[[i]]
  }
  x <- unname(x)
  if (is.numeric(x)) as.numeric(x) else as.character(x)
}
