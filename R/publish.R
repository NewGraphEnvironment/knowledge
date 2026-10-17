#' Write a set of tables as Parquet with a manifest, and upload them
#'
#' `scripts/0299`'s pattern as a function: each table is written as zstd
#' Parquet, compared column by column with an all-character read of its CSV
#' (numbers within 1e-12, zero-padded codes kept as text, an empty or `"NA"`
#' cell null on both sides), and described in a `manifest.json` that carries each
#' file's rows, columns, bytes, sha256 and schema, the source CSV's sha256 and
#' modification time, and the commit the set was published from. The bucket does
#' not list, so a reader starts from the manifest.
#'
#' With `s3 = NULL` nothing is uploaded. With an `s3://` prefix the published
#' manifest is read first: a published version with different tables or schemas
#' refuses (a change of columns or meaning is a new version), and one with the
#' same tables but different contents refuses unless `republish = TRUE`. Parquet
#' is uploaded before the manifest, so a reader never finds a manifest naming a
#' file not yet there.
#'
#' @param tables `data.frame` with `table`, `source` (CSV path), `script` and
#'   `description`.
#' @param dir_out `character(1)` where the Parquet and manifest are written.
#' @param id `character(1)` the dataset id, e.g. `"knowledge/thresholds/v1"`.
#' @param note `character(1)` a sentence on what this version is.
#' @param provenance a named `list` carried into the manifest (the link run,
#'   the evidence version, the commit).
#' @param supersedes `character(1)` or `NULL` the id this version replaces.
#' @param s3 `NULL`, or the `s3://bucket/` the id is published under.
#' @param republish `logical(1)` allow replacing a published version's contents.
#' @param no_sign `logical(1)` read the published manifest without credentials.
#' @param hive `NULL`, or a `character` of table names whose Parquet is written
#'   under a Hive path `<table>/<key>=<value>/part.parquet` from the columns
#'   `hive_keys` (one part per distinct key combination).
#' @param hive_keys `character` the Hive key columns.
#' @return The manifest, invisibly.
#' @export
#' @examples
#' tmp <- tempfile()
#' dir.create(tmp)
#' csv <- file.path(tmp, "t.csv")
#' utils::write.csv(data.frame(a = 1:3, code = c("08", "09", "10")), csv, row.names = FALSE)
#' tables <- data.frame(table = "t", source = csv, script = "example", description = "three rows")
#' m <- knw_publish(tables, file.path(tmp, "out"), id = "example/v1", note = "an example",
#'                  provenance = list(commit = "none"))
#' m$files[[1]]$rows
knw_publish <- function(tables, dir_out, id, note, provenance = list(), supersedes = NULL, s3 = NULL,
                        republish = FALSE, no_sign = FALSE, hive = NULL, hive_keys = c("species_code", "stage")) {
  chk::chk_data(tables)
  chk::check_names(tables, c("table", "source", "script", "description"))
  chk::chk_string(dir_out)
  chk::chk_string(id)
  chk::chk_string(note)
  chk::chk_list(provenance)
  chk::chk_null_or(s3, vld = chk::vld_string)
  chk::chk_null_or(hive, vld = chk::vld_character)
  if (!requireNamespace("arrow", quietly = TRUE) || !requireNamespace("jsonlite", quietly = TRUE)) {
    stop("arrow and jsonlite are needed", call. = FALSE)
  }
  missing_in <- tables$source[!file.exists(tables$source)]
  if (length(missing_in)) stop("missing input: ", paste(missing_in, collapse = ", "), call. = FALSE)
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
  files <- vector("list", nrow(tables))
  for (i in seq_len(nrow(tables))) {
    tb <- tables$table[i]
    src <- tables$source[i]
    x <- arrow::read_csv_arrow(src, as_data_frame = FALSE)
    raw <- utils::read.csv(src, colClasses = "character", na.strings = character(), check.names = FALSE)
    for (nm in names(raw)[vapply(raw, function(a) any(grepl("^[-+]?0[0-9]", a)), logical(1))]) {
      if (inherits(x[[nm]]$type, "StringType")) next
      a <- raw[[nm]]
      a[a %in% c("", "NA")] <- NA
      x[[nm]] <- arrow::Array$create(a, type = arrow::string())
    }
    if (!is.null(hive) && tb %in% hive) {
      df <- as.data.frame(x)
      chk::check_names(df, hive_keys)
      keys <- unique(df[, hive_keys, drop = FALSE])
      parts <- list()
      for (j in seq_len(nrow(keys))) {
        sel <- Reduce(`&`, lapply(hive_keys, function(kk) df[[kk]] == keys[[kk]][j]))
        rel <- file.path(tb, paste(paste0(hive_keys, "=", unlist(keys[j, ])), collapse = "/"), "part.parquet")
        dst <- file.path(dir_out, rel)
        dir.create(dirname(dst), recursive = TRUE, showWarnings = FALSE)
        part <- arrow::Table$create(df[sel, , drop = FALSE])
        arrow::write_parquet(part, dst, compression = "zstd")
        # the same column-by-column check the flat tables get, on this part against the CSV rows it holds
        bad <- .knw_values_differ_df(raw[sel, , drop = FALSE], as.data.frame(arrow::read_parquet(dst)))
        if (length(bad)) stop(tb, " (", rel, "): Parquet values differ from the CSV in ", paste(bad, collapse = ", "), call. = FALSE)
        parts[[j]] <- list(path = rel, rows = part$num_rows, bytes = file.size(dst), sha256 = .knw_sha256(dst),
                           keys = as.list(keys[j, , drop = FALSE]))
      }
      files[[i]] <- list(
        table = tb, description = tables$description[i], producing_script = tables$script[i], rows = x$num_rows,
        columns = x$num_columns, hive_keys = hive_keys, parts = parts,
        schema = stats::setNames(lapply(x$schema$fields, function(fl) fl$type$ToString()),
                                 vapply(x$schema$fields, function(fl) fl$name, character(1))),
        source_csv = list(path = src, sha256 = .knw_sha256(src),
                          modified = format(file.mtime(src), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")))
      next
    }
    dst <- file.path(dir_out, paste0(tb, ".parquet"))
    arrow::write_parquet(x, dst, compression = "zstd")
    bad <- .knw_values_differ(src, dst)
    if (length(bad)) stop(tb, ": Parquet values differ from the CSV in ", paste(bad, collapse = ", "), call. = FALSE)
    files[[i]] <- list(
      path = basename(dst), table = tb, description = tables$description[i], producing_script = tables$script[i],
      rows = x$num_rows, columns = x$num_columns, bytes = file.size(dst), sha256 = .knw_sha256(dst),
      schema = stats::setNames(lapply(x$schema$fields, function(fl) fl$type$ToString()),
                               vapply(x$schema$fields, function(fl) fl$name, character(1))),
      source_csv = list(path = src, sha256 = .knw_sha256(src),
                        modified = format(file.mtime(src), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")))
  }
  manifest <- list(manifest_version = 1L, id = id, supersedes = supersedes, note = note,
                   built = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), provenance = provenance, files = files)
  path_manifest <- file.path(dir_out, "manifest.json")
  jsonlite::write_json(manifest, path_manifest, auto_unbox = TRUE, pretty = TRUE, null = "null", na = "null")
  if (is.null(s3)) return(invisible(manifest))

  s3_prefix <- paste0(sub("/$", "", s3), "/", id, "/")
  aws <- function(...) {
    args <- c(..., if (no_sign) "--no-sign-request")
    rc <- system2("aws", shQuote(args))
    if (rc != 0) stop("aws ", paste(args, collapse = " "), " failed (exit ", rc, ")", call. = FALSE)
  }
  listed <- suppressWarnings(system2("aws", shQuote(c("s3", "ls", paste0(s3_prefix, "manifest.json"),
                                                      if (no_sign) "--no-sign-request")), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(listed, "status")) && length(listed)) {
    stop("could not check the published manifest: ", paste(listed, collapse = " "), call. = FALSE)
  }
  if (length(listed)) {
    prior_path <- file.path(dir_out, "manifest_published.json")
    aws("s3", "cp", paste0(s3_prefix, "manifest.json"), prior_path, "--only-show-errors")
    prior <- jsonlite::read_json(prior_path)
    key <- function(fs) vapply(fs, function(f) f$table, character(1))
    now_t <- key(files)
    was_t <- key(prior$files)
    changed <- union(setdiff(now_t, was_t), setdiff(was_t, now_t))
    for (f in files) {
      p <- prior$files[[match(f$table, was_t)]]
      if (is.null(p)) next
      same <- identical(lapply(p$schema, as.character), lapply(f$schema, as.character))
      if (!same) changed <- c(changed, f$table)
      sha_now <- if (is.null(f$parts)) f$sha256 else paste(vapply(f$parts, `[[`, character(1), "sha256"), collapse = "")
      sha_was <- if (is.null(p$parts)) p$sha256 else paste(vapply(p$parts, `[[`, character(1), "sha256"), collapse = "")
      if (same && !republish && (!identical(sha_was, sha_now) || !identical(as.integer(p$rows), as.integer(f$rows)))) {
        stop(id, " is published with different contents in ", f$table,
             ": set republish = TRUE to replace them, or publish to a new version", call. = FALSE)
      }
    }
    if (length(changed)) {
      stop(id, " is published with different tables or schemas (", paste(unique(changed), collapse = ", "),
           "): publish to a new version, never over this one", call. = FALSE)
    }
  }
  for (f in files) {
    paths <- if (is.null(f$parts)) f$path else vapply(f$parts, `[[`, character(1), "path")
    for (p in paths) aws("s3", "cp", file.path(dir_out, p), paste0(s3_prefix, p), "--only-show-errors")
  }
  aws("s3", "cp", path_manifest, paste0(s3_prefix, "manifest.json"), "--content-type", "application/json",
      "--only-show-errors")
  message("uploaded ", length(files), " tables and manifest.json to ", s3_prefix)
  invisible(manifest)
}

.knw_sha256 <- function(path) {
  out <- system2("shasum", c("-a", "256", shQuote(path)), stdout = TRUE)
  if (!is.null(attr(out, "status"))) stop("shasum failed on ", path, call. = FALSE)
  strsplit(out, " ")[[1]][1]
}

# Each column of the Parquet against an all-character read of the CSV. Returns the failing columns.
.knw_values_differ <- function(src, dst) {
  raw <- utils::read.csv(src, colClasses = "character", na.strings = character(), check.names = FALSE)
  pq <- as.data.frame(arrow::read_parquet(dst))
  .knw_values_differ_df(raw, pq)
}

.knw_values_differ_df <- function(raw, pq) {
  if (!identical(names(raw), names(pq)) || nrow(raw) != nrow(pq)) return("<names or rows>")
  bad <- character()
  for (nm in names(raw)) {
    a <- raw[[nm]]
    v <- pq[[nm]]
    na_tok <- a %in% c("", "NA")
    ok <- if (is.numeric(v)) {
      x <- suppressWarnings(as.numeric(a))
      (na_tok & is.na(v)) | (!is.na(x) & !is.na(v) & abs(x - v) <= 1e-12 * pmax(1, abs(x)) & !grepl("^[-+]?0[0-9]", a))
    } else {
      b <- if (is.logical(v)) ifelse(v, "TRUE", "FALSE") else as.character(v)
      (na_tok & is.na(v)) | (!is.na(b) & a == b)
    }
    if (!all(ok)) bad <- c(bad, sprintf("%s (%d rows)", nm, sum(!ok)))
  }
  bad
}
