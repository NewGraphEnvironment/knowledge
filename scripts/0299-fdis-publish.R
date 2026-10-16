# scripts/0299-fdis-publish.R
# ---------------------------------------------------------------------------
# Publish the FDIS visit-level tables as Parquet with a manifest, and the FDIS extract's
# provenance note. Issue #56.
#
# WHY / DESIGN NOTES:
#   - The Province agreed (2026-10-16) to the FDIS extract being public provided it carries a
#     note of when and from where it was received. The extract stays as received under
#     s3://fresh-bc/fdis/; data/fdis_README.md is the tracked source of its README.
#   - The tables built from it are ours, so they go under s3://fresh-bc/knowledge/fdis/ (named
#     by producer). The bucket does not list, so readers start from manifest.json.
#   - Only fdis_sites.csv is taken of 0240's two forms: the gpkg is the same rows with a
#     geometry, and a CSV-to-Parquet copy keeps one reading of each table.
#   - Each table is read with arrow's CSV reader, written as Parquet, read back and compared
#     with what was read before anything is uploaded.
#   - The manifest names the knowledge commit that built it, so the working tree must be clean.
#
# INPUT:  data/fdis/derived/{fdis_sites,bt_use_visits,ch_mad_visits,ch_rule_visits,ch_rule_walks}.csv
#         (scripts/0240, 0290, 0294, 0296), data/fdis_README.md
# OUTPUT: data/fdis/publish/ (ignored): <table>.parquet, manifest.json
#         with PUBLISH=TRUE also: s3://fresh-bc/knowledge/fdis/ (the Parquet and manifest.json) and
#         s3://fresh-bc/fdis/README.md
# RUN:    Rscript scripts/0299-fdis-publish.R              (from the repo root; local only)
#         PUBLISH=TRUE Rscript scripts/0299-fdis-publish.R  (uploads; needs write access to fresh-bc)
# ---------------------------------------------------------------------------
suppressMessages({ library(arrow) })

publish <- identical(Sys.getenv("PUBLISH"), "TRUE")
dir_in <- "data/fdis/derived"
dir_out <- "data/fdis/publish"
s3_tables <- "s3://fresh-bc/knowledge/fdis/"
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

sha256 <- function(path) {
  out <- system2("shasum", c("-a", "256", shQuote(path)), stdout = TRUE)
  if (!is.null(attr(out, "status"))) stop("shasum failed on ", path, call. = FALSE)
  strsplit(out, " ")[[1]][1]
}

dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
files <- vector("list", nrow(tables))
for (i in seq_len(nrow(tables))) {
  tb <- tables$table[i]
  src <- file.path(dir_in, paste0(tb, ".csv"))
  dst <- file.path(dir_out, paste0(tb, ".parquet"))
  x <- arrow::read_csv_arrow(src, as_data_frame = FALSE)
  arrow::write_parquet(x, dst, compression = "zstd")
  back <- arrow::read_parquet(dst, as_data_frame = FALSE)
  if (!isTRUE(back$Equals(x)))
    stop(tb, ": the Parquet read back differs from the CSV as read", call. = FALSE)
  message(sprintf("%-15s %8d rows %3d cols  %6.1f MB csv -> %5.1f MB parquet", tb, x$num_rows,
                  x$num_columns, file.size(src) / 1e6, file.size(dst) / 1e6))
  files[[i]] <- list(
    path = basename(dst), table = tb, description = tables$description[i],
    producing_script = tables$script[i], rows = x$num_rows, columns = x$num_columns,
    bytes = file.size(dst), sha256 = sha256(dst))
}

manifest <- list(
  manifest_version = 1L,
  id = "knowledge/fdis",
  built = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  provenance = list(
    knowledge_commit = commit,
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

aws <- function(...) {
  rc <- system2("aws", shQuote(c(...)))   # system2 runs a shell; a content type carries ";"
  if (rc != 0) stop("aws ", paste(c(...), collapse = " "), " failed (exit ", rc, ")", call. = FALSE)
}
# Parquet first, manifest last, so a reader never finds a manifest naming a file not yet there.
for (f in files) aws("s3", "cp", file.path(dir_out, f$path), paste0(s3_tables, f$path), "--only-show-errors")
aws("s3", "cp", path_manifest, paste0(s3_tables, "manifest.json"),
    "--content-type", "application/json", "--only-show-errors")
aws("s3", "cp", path_readme, s3_readme, "--content-type", "text/markdown; charset=utf-8", "--only-show-errors")
message("uploaded to ", s3_tables, " and ", s3_readme)
