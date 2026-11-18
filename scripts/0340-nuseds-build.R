# scripts/0340-nuseds-build.R
# ---------------------------------------------------------------------------
# DFO's NuSEDS escapement records, one table with the kind of evidence each record is (#108). Fetches a release of
# the All Areas file, reads it through crate, writes the records, records the release, and with PUBLISH=TRUE publishes
# the set to s3://fresh-bc/knowledge/nuseds/<version>/ with its receipt and README.
#
# WHY / DESIGN NOTES:
#   - ONE RELEASE, NAMED. knw_nuseds_fetch() keeps each release in its own directory and never overwrites one; the
#     tracked data/nuseds_release.csv records each release built (date, the zip's md5, rows), and this script stops
#     when a release it has recorded arrives with other bytes (DFO replaced it in place).
#   - CRATE READS IT. knw_nuseds_records() reads through crate::crt_ingest("dfo", "nuseds_all_areas"), so a release
#     in a shape crate has not registered stops here with the columns it found, rather than reading wrongly.
#   - NOTHING ALTERED. Every column is DFO's, typed by crate; evidence_kind is the one column added.
#   - PUBLISH IS A SEPARATE WORD. Without PUBLISH=TRUE nothing leaves the machine. A publish needs a clean tree,
#     because the receipt names the commit; the Parquet, then the receipt, then the manifest are uploaded by
#     knw_publish(), and the README last.
#   - MAXAN CREEK, as a check: #108 measured Maxan Creek chinook's records in the 2026-06-01 release by hand; the
#     script prints them and stops if a 2026-06-01 build does not give them.
#
# INPUT:  the NuSEDS record on the Open Government Portal (ckanr, curl), data/nuseds_release.csv, data/nuseds_README.md
# OUTPUT: data/nuseds/<release>/ (ignored): the zip, nuseds_records.csv, publish/ (Parquet, manifest.json,
#         receipt.json); data/nuseds_release.csv (tracked); with PUBLISH=TRUE s3://fresh-bc/knowledge/nuseds/<version>/
#         (the Parquet, receipt, manifest and README.md)
# RUN:    Rscript scripts/0340-nuseds-build.R 2>&1 | tee scripts/logs/nuseds/<yyyymmdd>_nuseds_build.txt   (repo root)
#         RELEASE=20260601 ...            (a named release, else the newest the record lists)
#         PUBLISH=TRUE Rscript scripts/0340-nuseds-build.R   (uploads; needs write access to fresh-bc)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)

publish <- identical(Sys.getenv("PUBLISH"), "TRUE")
republish <- identical(Sys.getenv("REPUBLISH"), "TRUE")
release <- if (nzchar(Sys.getenv("RELEASE"))) Sys.getenv("RELEASE") else NULL
version <- Sys.getenv("VERSION", "v1")
s3_id <- paste0("knowledge/nuseds/", version)
path_record <- "data/nuseds_release.csv"
path_readme <- "data/nuseds_README.md"
cat("started:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n")

# every run, untracked files included: the release record and the receipt name this commit, so the code they ran
# (R/, which load_all() sources whole, this script, the receipt declaration and the README) must be that commit's
dirty <- .knw_git(".", "status", "--porcelain", "--", "R", "scripts/0340-nuseds-build.R", "inst/receipt",
                  path_readme, path_record)
if (length(dirty)) stop("commit first, so the record names the code that ran: ", paste(dirty, collapse = "; "),
                        call. = FALSE)
if (publish && length(.knw_git(".", "status", "--porcelain", "--untracked-files=no"))) {
  stop("working tree has uncommitted changes; commit before PUBLISH=TRUE", call. = FALSE)
}
knowledge_git <- .knw_git_state()
# crate's registration decides every type and how the file is decoded, so its identity is part of the recipe: the
# installed crate's version and the md5 of the schema it read
crate_yaml <- system.file("extdata/schemas/dfo/nuseds_all_areas.yaml", package = "crate")
if (!nzchar(crate_yaml)) stop("the installed crate has no dfo/nuseds_all_areas registration (crate#74)", call. = FALSE)
# a version string names a release, not the code that read the file (a branch build carries the last release's
# number), so crate is named by its commit too; a publish refuses a crate with none (a local R CMD INSTALL)
crate_sha <- utils::packageDescription("crate")$RemoteSha
if (is.null(crate_sha) || !nzchar(crate_sha)) {
  if (publish) stop("the installed crate has no RemoteSha: install it from GitHub before PUBLISH=TRUE", call. = FALSE)
  crate_sha <- "none (a local build)"
}
crate_schema <- paste0("crate ", utils::packageVersion("crate"), " commit ", crate_sha, " schema md5 ",
                       unname(tools::md5sum(crate_yaml)))
cat("crate:", crate_schema, "\n")

# ---- the release ----
f <- knw_nuseds_fetch(release = release)
cat("release:", f$release, if (f$downloaded) "(downloaded)" else "(held)", "\nzip md5:", f$md5, "\n")
rec <- if (file.exists(path_record)) utils::read.csv(path_record, colClasses = "character") else NULL
if (!is.null(rec) && nrow(rec) && f$release %in% rec$release &&
    !all(rec$zip_md5[rec$release == f$release] == f$md5)) {
  stop("release ", f$release, " is recorded with another zip md5 than the zip held (", f$md5, "): DFO may have ",
       "replaced it in place; keep both and name the new one", call. = FALSE)
}

# ---- the records ----
x <- knw_nuseds_records(f$path)
cat("records:", nrow(x), "rows,", ncol(x), "columns;", length(unique(x$pop_id)), "populations\n")
print(table(evidence_kind = x$evidence_kind))

m <- x[x$waterbody == "MAXAN CREEK" & x$species == "Chinook" & x$evidence_kind != "not_inspected",
       c("analysis_yr", "adult_presence", "evidence_kind", "total_return_to_river", "enumeration_methods",
         "no_inspections_used", "estimate_method")]
m <- m[order(m$analysis_yr), , drop = FALSE]
cat("\nMaxan Creek chinook, every year inspected:\n")
print(as.data.frame(m), row.names = FALSE)
if (f$release == "20260601") {
  want <- data.frame(analysis_yr = c(1986L, 1988L, 1993L, 2003L, 2007L, 2008L),
                     evidence_kind = c("none_observed", "count", "count", "presence_survey", "none_observed",
                                       "presence_expert"))
  if (!identical(as.data.frame(m[, c("analysis_yr", "evidence_kind")]), want) ||
      !identical(m$total_return_to_river[m$analysis_yr == 1988L], 50)) {
    stop("Maxan Creek chinook in release 20260601 is not what #108 measured", call. = FALSE)
  }
  cat("(as #108 measured)\n")
}

# ---- write, and record the release ----
dir_rel <- dirname(f$path)
csv <- file.path(dir_rel, "nuseds_records.csv")
utils::write.csv(x, csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
# one row per release, rewritten on every run so it names the code that ran last (this commit, this crate); the
# download's URL and date come from source.dcf beside the zip (knw_nuseds_fetch()), else from the row before
row <- data.frame(release = f$release, zip_md5 = f$md5, zip_url = if (is.na(f$url)) "" else f$url,
                  rows = as.character(nrow(x)), crate_schema = crate_schema,
                  fetched = if (is.na(f$fetched)) "" else substr(f$fetched, 1, 10),
                  knowledge_commit = knowledge_git$commit, stringsAsFactors = FALSE)
old <- if (is.null(rec) || !nrow(rec)) rec[0, , drop = FALSE] else rec[rec$release == f$release, , drop = FALSE]
if (nrow(old) > 1L) stop(path_record, " holds release ", f$release, " twice", call. = FALSE)
if (nrow(old)) {
  if (!identical(old$rows, row$rows)) {
    stop("release ", f$release, " gave ", row$rows, " rows; recorded ", old$rows, call. = FALSE)
  }
  # a zip held from before the fetcher kept source.dcf: the row before is the only record of where and when
  if (!nzchar(row$zip_url)) row$zip_url <- old$zip_url
  if (!nzchar(row$fetched)) row$fetched <- old$fetched
}
rec <- rbind(if (is.null(rec)) NULL else rec[rec$release != f$release, , drop = FALSE], row)
rec <- rec[order(rec$release), , drop = FALSE]
utils::write.csv(rec, path_record, row.names = FALSE, na = "")
cat("\nrecorded release", f$release, "in", path_record, "(", knowledge_git$commit, ")\n")

# ---- the published set ----
tables <- data.frame(table = "nuseds_records", source = csv, script = "scripts/0340-nuseds-build.R",
                     description = paste("Fisheries and Oceans Canada's NuSEDS All Areas file, release", f$release,
                                         "read through crate (dfo/nuseds_all_areas): one row per estimate, every",
                                         "column as DFO wrote it with lower-case names, and evidence_kind added",
                                         "(#108; README.md)."))
receipt <- list(output = "nuseds",
                recipe = list(code = .knw_receipt_code(knowledge_git),
                              config = list(settings = list(version = version, release = f$release,
                                                            crate_schema = crate_schema)),
                              inputs = list(nuseds_zip = list(sha256 = .knw_sha256(f$path))), seed = NULL),
                summary = list(rows = nrow(x)))
# the published types are crate's, never a guess from the CSV: the ids and dates as text, counts as double
sc <- crate::crt_schema_cols("dfo", "nuseds_all_areas")
types <- c(stats::setNames(sc$type, sc$name), evidence_kind = "string")
manifest <- knw_publish(
  tables, file.path(dir_rel, "publish"), id = s3_id,
  note = paste("NuSEDS release", f$release, "with evidence_kind (knowledge#108)."),
  provenance = list(
    published_from_commit = substr(knowledge_git$commit, 1, 7),
    repository = "https://github.com/NewGraphEnvironment/knowledge",
    nuseds_release = f$release, nuseds_zip_md5 = f$md5,
    source = paste("Fisheries and Oceans Canada, NuSEDS (New Salmon Escapement Database System), All Areas file,",
                   "https://open.canada.ca/data/en/dataset/c48669a3-045b-400d-b730-48aafe8c5ee6. Contains",
                   "information licensed under the Open Government Licence - Canada.")),
  s3 = if (publish) "s3://fresh-bc/" else NULL, republish = republish, receipt = receipt,
  types = list(nuseds_records = types))
sch <- manifest$files[[1]]$schema
wrong <- names(types)[vapply(names(types), function(n) {
  !identical(sch[[n]], c(string = "string", double = "double", integer = "int32")[[types[[n]]]])
}, logical(1))]
if (length(wrong)) stop("published types differ from crate's in ", paste(wrong, collapse = ", "), call. = FALSE)
for (mf in manifest$files) cat(sprintf("%-16s %8d rows %3d cols %6.1f MB parquet\n", mf$table, mf$rows, mf$columns,
                                       mf$bytes / 1e6))
if (!publish) {
  cat("PUBLISH is not TRUE: nothing uploaded\nfinished:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n")
  quit(save = "no", status = 0)
}
s3_readme <- paste0("s3://fresh-bc/", s3_id, "/README.md")
rc <- system2("aws", shQuote(c("s3", "cp", path_readme, s3_readme, "--content-type", "text/markdown; charset=utf-8",
                               "--only-show-errors")))
if (rc != 0) stop("upload of ", s3_readme, " failed (exit ", rc, ")", call. = FALSE)
cat("uploaded", s3_readme, "\nfinished:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n")
