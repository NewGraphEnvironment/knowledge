# data-raw/archive_seed.R
# ---------------------------------------------------------------------------
# Backfill the grade records of the published run, the one the article bundles were built on (written 2026-10-28 from
# #92's tables), so it can be archived (#119). That run predates the record: its grade tables survived on one machine,
# were compressed there and copied to a staging tree here (outside the repo, never this checkout's ignored data/,
# which holds another build). This writes each table's record from the staged table and checks, before writing any:
#   - every staged table's md5 against the source machine's (its manifest), and the seven the methodology bundle pins
#     against the bundle (meta$md5_local); CH rearing's curve and segments against the chinook bundle's pins;
#   - every staged first row against the first rows rescued on 2026-10-29, column by column;
#   - each table's run columns against the tracked summary (run, evidence, gradient, withheld), as promotion does.
# The records name the run `published_20261028` (it had no run name: it predates #111's candidates), the 2026-10-27
# evidence ledger, link's version and commit from that ledger, no knowledge commit (the run's log names none), no tokens
# (link 0.66.0 predates the vocabulary, link#420), and record_source `backfill`.
#
# INPUT:  STAGE/data/{tune,compare}/ (the decompressed grade tables, curves and segments), STAGE/manifest.tsv (the
#         source machine's md5s, sizes and row counts), RESCUED/data/tune/<key>_grades_head.csv, the tracked
#         data/tune/<key>_summary.csv and inst/vignette-data/{method,chinook_rearing}.rds
# OUTPUT: STAGE/data/tune/<key>_grades_record.csv and the same bytes in data/tune/ (tracked)
# RUN:    STAGE=<dir> RESCUED=<dir> Rscript data-raw/archive_seed.R   (from the repo root)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)

stage <- Sys.getenv("STAGE")
rescued <- Sys.getenv("RESCUED")
if (!dir.exists(stage) || !dir.exists(rescued)) stop("STAGE and RESCUED name the staging tree and the rescued copy")
keys <- c("BT_rear", "BT_spawn", "CH_rear", "CO_rear", "GR_rear", "RB_rear", "ST_rear", "WCT_rear")
ledger <- "scripts/logs/habitat/20261027_evidence_build_ledger.csv"
led <- utils::read.csv(ledger, colClasses = "character")
link <- c(version = led$note[led$step == "run_link_version"], sha = led$note[led$step == "run_link_sha"])

man <- utils::read.delim(file.path(stage, "manifest.tsv"), header = FALSE, colClasses = "character",
                         col.names = c("key", "what", "md5", "bytes", "rows"), na.strings = "")
pin_m <- readRDS("inst/vignette-data/method.rds")$meta$md5_local
pin_c <- readRDS("inst/vignette-data/chinook_rearing.rds")$meta$md5_local
md5 <- function(f) unname(tools::md5sum(f))

for (k in keys) {
  g <- file.path(stage, "data/tune", paste0(k, "_grades.csv"))
  src <- man[man$key == k & man$what == "grades", ]
  if (nrow(src) != 1 || !identical(md5(g), src$md5)) stop(k, ": the staged table is not the source machine's")
  pin <- pin_m[paste0("data/tune/", k, "_grades.csv")]
  if (!is.na(pin) && !identical(md5(g), unname(pin))) stop(k, ": the staged table is not the one method.rds pins")
  if (is.na(pin) && k != "WCT_rear") stop(k, ": method.rds pins no table for it")
  for (f in c(file.path("data/tune", paste0(k, "_curve.rds")), file.path("data/compare", paste0(k, "_segments.rds")))) {
    m <- man[man$key == k & man$what == basename(f), ]
    if (nrow(m) != 1 || !identical(md5(file.path(stage, f)), m$md5)) stop(f, ": the staged copy is not the source's")
    if (f %in% names(pin_c) && !identical(md5(file.path(stage, f)), unname(pin_c[[f]]))) {
      stop(f, ": not the copy chinook_rearing.rds pins")
    }
  }
  # the first row, column by column, as rescued on 2026-10-29
  h_stage <- utils::read.csv(g, nrows = 1, colClasses = "character", na.strings = "")
  h_resc <- utils::read.csv(file.path(rescued, "data/tune", paste0(k, "_grades_head.csv")), nrows = 1,
                            colClasses = "character", na.strings = "")
  if (!identical(h_stage, h_resc)) stop(k, ": the staged first row is not the rescued one")
  # the table's run against the tracked summary, as knw_tune_promote() holds a promoted key
  s <- utils::read.csv(file.path("data/tune", paste0(k, "_summary.csv")), colClasses = "character", na.strings = "")
  for (f in c("run_uid", "evidence_md5", "curve_grad", "grade_withheld")) {
    if (!identical(toupper(h_stage[[f]]), toupper(s[[f]]))) stop(k, ": the table's ", f, " is not the summary's")
  }
  if (!identical(h_stage$rule, s$rule_recommended)) stop(k, ": graded under ", h_stage$rule, ", not the published pick")
  rec <- knw_grade_record_write(g, tune_run = "published_20261028", evidence_ledger = ledger, knowledge_commit = NA,
                                link = link, tokens = c(cut = NA, acc = NA, grad = NA, flow = NA),
                                rows = as.numeric(src$rows), record_source = "backfill")
  if (!identical(rec$grades_bytes, src$bytes)) stop(k, ": size differs from the source machine's")
  out <- file.path("data/tune", paste0(k, "_grades_record.csv"))
  file.copy(.knw_grade_record_path(g), out, overwrite = TRUE)
  message(sprintf("%-9s %s  %s rows  %s", k, rec$grades_md5, src$rows, rec$rule))
}
message("Wrote ", length(keys), " records into data/tune/ and ", stage, ": commit them before archiving (0336).")
