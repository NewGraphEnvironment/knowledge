# scripts/0299-fdis-publish.R
# ---------------------------------------------------------------------------
# Publish the FDIS visit-level tables as Parquet with a manifest, and the FDIS extract's
# provenance note. Issue #56.
#
# WHY / DESIGN NOTES:
#   - The Province agreed (2026-10-16) to the FDIS extract being public provided it carries a
#     note of when and from where it was received. The extract stays as received under
#     s3://fresh-bc/fdis/; data/fdis_README.md is the tracked source of its README.
#   - The tables built from it are ours, so they go under s3://fresh-bc/knowledge/fdis/v1/ (named
#     by producer, versioned like discharge/fwa/v1/ so a consumer can pin one). The bucket does
#     not list, so readers start from manifest.json. A change to a table's columns or meaning
#     is a new version, never an overwrite of v1: the manifest records each table's schema, and
#     PUBLISH=TRUE stops when the published manifest's tables or schemas differ (bump s3_id).
#     A change of meaning with the same schema is the one case it cannot see.
#   - Only fdis_sites.csv is taken of 0240's two forms: the gpkg is the same rows with a
#     geometry, and a CSV-to-Parquet copy keeps one reading of each table.
#   - Each table is read with arrow's CSV reader and written as Parquet. The Parquet is then
#     compared column by column with an all-character read of the CSV (numbers within 1e-12), so
#     a type arrow inferred wrongly (an id losing leading zeros, a misread date) stops the run.
#   - The CSVs were built by earlier runs, so the manifest records each source CSV's sha256 and
#     modification time, and the commit it was published from (`published_from_commit`), which
#     needs a clean working tree.
#   - PULL=TRUE is the way back: a machine without the CSVs (0230 no longer syncs them) fetches
#     the Parquet, checks each sha256 against the manifest, and writes data/fdis/derived/*.csv
#     for 0291-0298. NO_SIGN=TRUE reads without AWS credentials once the prefix is public.
#
# INPUT:  data/fdis/derived/{fdis_sites,bt_use_visits,ch_mad_visits,ch_rule_visits,ch_rule_walks}.csv
#         (scripts/0240, 0290, 0294, 0296), data/fdis_README.md
# OUTPUT: data/fdis/publish/ (ignored): <table>.parquet, manifest.json
#         with PUBLISH=TRUE also: s3://fresh-bc/knowledge/fdis/v1/ (the Parquet and manifest.json)
#         and s3://fresh-bc/fdis/README.md
#         with PULL=TRUE instead: data/fdis/derived/<table>.csv from the published Parquet
# RUN:    Rscript scripts/0299-fdis-publish.R              (from the repo root; local only)
#         PUBLISH=TRUE Rscript scripts/0299-fdis-publish.R  (uploads; needs write access to fresh-bc)
#         PULL=TRUE [NO_SIGN=TRUE] Rscript scripts/0299-fdis-publish.R
# ---------------------------------------------------------------------------
suppressMessages({ library(arrow) })

publish <- identical(Sys.getenv("PUBLISH"), "TRUE")
pull <- identical(Sys.getenv("PULL"), "TRUE")
no_sign <- identical(Sys.getenv("NO_SIGN"), "TRUE")
if (publish && pull) stop("PUBLISH and PULL are exclusive", call. = FALSE)
dir_in <- "data/fdis/derived"
dir_out <- "data/fdis/publish"
s3_id <- "knowledge/fdis/v1"
s3_tables <- paste0("s3://fresh-bc/", s3_id, "/")
s3_readme <- "s3://fresh-bc/fdis/README.md"
path_readme <- "data/fdis_README.md"

tables <- data.frame(
  table = c("fdis_sites", "bt_use_visits", "ch_mad_visits", "ch_rule_visits", "ch_rule_walks"),
  script = c("scripts/0240-fdis-evidence.R", "scripts/0290-bt-use-build.R",
             "scripts/0294-ch-mad-build.R", "scripts/0296-ch-rule-build.R",
             "scripts/0296-ch-rule-build.R"),
  description = c(
    "One row per FDIS site visit (passes rolled up): placement on the FWA network, effort, measured habitat and catch. About 2.8 % of visits are one survey loaded under two or three collection ids and are not deduplicated (#35).",
    "FDIS site visits placed on link's segments, with pooled BT presence and the attributes the BT rearing use curve reads (#28).",
    "FDIS site visits with the published annual flow (MAD) on their FWA segment, distance to the first large river, and placement flags (#52).",
    "FDIS site visits with the attributes the tuned CH rearing rule is scored on: flow, width, gradient, barrier status, hydrologic zone (#54).",
    "Downstream walks from each CH visit to rivers of 1-50 m3/s on each flow source, read by the CH rule tuning (#54)."),
  stringsAsFactors = FALSE)

stopifnot("run from the repo root" = file.exists("DESCRIPTION") && dir.exists("scripts"))

aws <- function(...) {
  args <- c(..., if (no_sign) "--no-sign-request")
  rc <- system2("aws", shQuote(args))   # system2 runs a shell; a content type carries ";"
  if (rc != 0) stop("aws ", paste(args, collapse = " "), " failed (exit ", rc, ")", call. = FALSE)
}
sha256 <- function(path) {
  out <- system2("shasum", c("-a", "256", shQuote(path)), stdout = TRUE)
  if (!is.null(attr(out, "status"))) stop("shasum failed on ", path, call. = FALSE)
  strsplit(out, " ")[[1]][1]
}

# ---- pull: published Parquet -> data/fdis/derived/*.csv ------------------------
if (pull) {
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
  dir.create(dir_in, recursive = TRUE, showWarnings = FALSE)
  path_manifest <- file.path(dir_out, "manifest.json")
  aws("s3", "cp", paste0(s3_tables, "manifest.json"), path_manifest, "--only-show-errors")
  man <- jsonlite::read_json(path_manifest)
  for (f in man$files) {
    dst <- file.path(dir_out, f$path)
    aws("s3", "cp", paste0(s3_tables, f$path), dst, "--only-show-errors")
    if (!identical(sha256(dst), f$sha256)) stop(f$path, ": sha256 differs from the manifest", call. = FALSE)
    out <- file.path(dir_in, paste0(f$table, ".csv"))
    if (file.exists(out)) stop(out, " exists; move it aside to pull", call. = FALSE)
    # written aside and moved in once complete, so an interrupted pull leaves no CSV that
    # 0291-0298 would read as whole
    part <- paste0(out, ".part")
    arrow::write_csv_arrow(arrow::read_parquet(dst), part)
    n <- arrow::read_csv_arrow(part, as_data_frame = FALSE)$num_rows
    if (n != f$rows) stop(part, ": ", n, " rows, the manifest says ", f$rows, call. = FALSE)
    if (!file.rename(part, out)) stop("could not move ", part, " into place", call. = FALSE)
    message(sprintf("%-15s %8d rows -> %s", f$table, f$rows, out))
  }
  quit(save = "no", status = 0)
}

missing_in <- file.path(dir_in, paste0(tables$table, ".csv"))
missing_in <- missing_in[!file.exists(missing_in)]
if (length(missing_in)) stop("missing input: ", paste(missing_in, collapse = ", "), call. = FALSE)
if (!file.exists(path_readme)) stop("missing ", path_readme, call. = FALSE)

git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed", call. = FALSE)
  out
}
dirty <- git("status", "--porcelain", "--untracked-files=no")
if (length(dirty) && publish) stop("working tree has uncommitted changes; commit before PUBLISH=TRUE", call. = FALSE)
commit <- git("rev-parse", "--short=7", "HEAD")

# Each column of the Parquet against an all-character read of the CSV: text equal, numbers
# within 1e-12 relative and not zero-padded, an empty or "NA" cell null on both sides.
# Returns the failing columns.
values_differ <- function(src, dst) {
  raw <- utils::read.csv(src, colClasses = "character", na.strings = character(), check.names = FALSE)
  pq <- as.data.frame(arrow::read_parquet(dst))
  if (!identical(names(raw), names(pq)) || nrow(raw) != nrow(pq)) return("<names or rows>")
  bad <- character()
  for (nm in names(raw)) {
    a <- raw[[nm]]
    v <- pq[[nm]]
    na_tok <- a %in% c("", "NA")
    ok <- if (is.numeric(v)) {
      x <- suppressWarnings(as.numeric(a))
      # a zero-padded code ("007") reads back as the same number, so its text is a failure
      (na_tok & is.na(v)) | (!is.na(x) & !is.na(v) & abs(x - v) <= 1e-12 * pmax(1, abs(x)) &
                               !grepl("^[-+]?0[0-9]", a))
    } else {
      b <- if (is.logical(v)) ifelse(v, "TRUE", "FALSE") else as.character(v)
      (na_tok & is.na(v)) | (!is.na(b) & a == b)
    }
    if (!all(ok)) bad <- c(bad, sprintf("%s (%d rows)", nm, sum(!ok)))
  }
  bad
}

dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
files <- vector("list", nrow(tables))
for (i in seq_len(nrow(tables))) {
  tb <- tables$table[i]
  src <- file.path(dir_in, paste0(tb, ".csv"))
  dst <- file.path(dir_out, paste0(tb, ".parquet"))
  x <- arrow::read_csv_arrow(src, as_data_frame = FALSE)
  # arrow reads a zero-padded code ("08", a hydrologic zone) as a number; keep such columns as text
  raw <- utils::read.csv(src, colClasses = "character", na.strings = character(), check.names = FALSE)
  for (nm in names(raw)[vapply(raw, function(a) any(grepl("^[-+]?0[0-9]", a)), logical(1))]) {
    if (inherits(x[[nm]]$type, "StringType")) next
    a <- raw[[nm]]
    a[a %in% c("", "NA")] <- NA
    x[[nm]] <- arrow::Array$create(a, type = arrow::string())
    message("  ", tb, ".", nm, ": zero-padded codes, kept as text")
  }
  arrow::write_parquet(x, dst, compression = "zstd")
  bad <- values_differ(src, dst)
  if (length(bad)) stop(tb, ": Parquet values differ from the CSV in ", paste(bad, collapse = ", "), call. = FALSE)
  message(sprintf("%-15s %8d rows %3d cols  %6.1f MB csv -> %5.1f MB parquet", tb, x$num_rows,
                  x$num_columns, file.size(src) / 1e6, file.size(dst) / 1e6))
  files[[i]] <- list(
    path = basename(dst), table = tb, description = tables$description[i],
    producing_script = tables$script[i], rows = x$num_rows, columns = x$num_columns,
    bytes = file.size(dst), sha256 = sha256(dst),
    schema = stats::setNames(lapply(x$schema$fields, function(fl) fl$type$ToString()),
                             vapply(x$schema$fields, function(fl) fl$name, character(1))),
    source_csv = list(path = src, sha256 = sha256(src),
                      modified = format(file.mtime(src), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")))
}

manifest <- list(
  manifest_version = 1L,
  id = s3_id,
  built = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  provenance = list(
    published_from_commit = commit,
    repository = "https://github.com/NewGraphEnvironment/knowledge",
    source = paste0(
      "Built from the Province of British Columbia's FDIS electrofishing extract (exports of ",
      "2020-11-16 and 2022-03-22), published as received under s3://fresh-bc/fdis/ with its ",
      "provenance note (README.md there).")),
  files = files)
path_manifest <- file.path(dir_out, "manifest.json")
jsonlite::write_json(manifest, path_manifest, auto_unbox = TRUE, pretty = TRUE)
message("wrote ", dir_out, "/ (", nrow(tables), " tables + manifest.json) at ", commit,
        if (length(dirty)) " (working tree dirty: local only)")

if (!publish) {
  message("PUBLISH is not TRUE: nothing uploaded")
  quit(save = "no", status = 0)
}

# ---- refuse to change a published version's tables or schemas ----------------------
prior_path <- file.path(dir_out, "manifest_published.json")
unlink(prior_path)
listed <- suppressWarnings(system2("aws", shQuote(c("s3", "ls", paste0(s3_tables, "manifest.json"))),
                                   stdout = TRUE, stderr = TRUE))
if (!is.null(attr(listed, "status")) && length(listed))
  stop("could not check the published manifest: ", paste(listed, collapse = " "), call. = FALSE)
if (length(listed)) {
  aws("s3", "cp", paste0(s3_tables, "manifest.json"), prior_path, "--only-show-errors")
  prior <- jsonlite::read_json(prior_path)
  key <- function(fs) vapply(fs, function(f) f$table, character(1))
  now_t <- key(files)
  was_t <- key(prior$files)
  changed <- union(setdiff(now_t, was_t), setdiff(was_t, now_t))
  for (f in files) {
    p <- prior$files[[match(f$table, was_t)]]
    if (is.null(p)) next
    same <- if (is.null(p$schema)) identical(as.integer(p$columns), as.integer(f$columns)) else
      identical(lapply(p$schema, as.character), lapply(f$schema, as.character))
    if (!same) changed <- c(changed, f$table)
  }
  if (length(changed))
    stop(s3_id, " is published with different tables or schemas (", paste(unique(changed), collapse = ", "),
         "): publish to a new version (bump s3_id), never over this one", call. = FALSE)
}

# Parquet first, manifest last, so a reader never finds a manifest naming a file not yet there.
for (f in files) aws("s3", "cp", file.path(dir_out, f$path), paste0(s3_tables, f$path), "--only-show-errors")
aws("s3", "cp", path_manifest, paste0(s3_tables, "manifest.json"),
    "--content-type", "application/json", "--only-show-errors")
aws("s3", "cp", path_readme, s3_readme, "--content-type", "text/markdown; charset=utf-8", "--only-show-errors")
message("uploaded to ", s3_tables, " and ", s3_readme)
