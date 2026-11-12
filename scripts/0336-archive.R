# scripts/0336-archive.R
# ---------------------------------------------------------------------------
# Keep a tuning run's ignored files in durable storage, and restore them on any machine (#119). A run's grade tables
# (0.3 to 2.5 GB each), curves and segments are ignored, so until this step they lived only on the machine that ran
# it, and an article bundle that pins them could be rebuilt there alone. This sends them to the bucket's private
# archive (s3://fresh-bc/archive/knowledge/, versioned) with the evidence build they were graded on, and records where
# in data/archive_index.csv (tracked); PULL=TRUE fills a checkout's ignored data/ back from it.
#
# WHY / DESIGN NOTES:
#   - THE RECORD IS THE KEY. Each grade table's tracked record (<key>_grades_record.csv, written by 0320) names the run
#     and the table's md5. A restore fetches the run its checkout's records name, by version id, so a checkout gets
#     the files its tracked tables were made from even after a later run overwrote the folder.
#   - ONE FOLDER PER SETUP COMPARED: tune/<key>/<cut>.<acc>.<grad>.<flow>/ from link's output-vocabulary tokens; a
#     build older than the vocabulary (link 0.70.0) goes under tune/<key>/untokened/<tune run>/ until link#420 names
#     it, and its folder is never renamed. The evidence is stored once per build, under evidence/<MANIFEST md5>/.
#   - NOTHING UNCHECKED IS SENT: each grade table against its record, the evidence against the grades' evidence_md5,
#     the compressed table round-tripped; each stored object carries its md5 and is read back. An object whose
#     current version already has the same md5 is not sent again. Refused: a bucket whose versioning is off, and an
#     unpromoted run over the folder of a promoted one.
#   - 0335 RUNS THIS on the promoted keys (PROMOTED=TRUE), and stops when it fails.
#
# INPUT:  archive: a run's TUNE_DIR and COMPARE_DIR (default data/tune and data/compare; RUN=<run> takes the
#         candidate's), EVIDENCE_DIR (data/fdis/derived, or a tagged build's) and BUILD_DIR (data/fdis/build);
#         fdis_sites.csv from SITES_DIR (data/fdis/derived, where 0240 writes it, whatever EVIDENCE_DIR: #136), held
#         to BUILD_DIR's sites.rds; link's vocabulary from LINK_REPO (../link) where it has one; AWS credentials for
#         the bucket. PULL: the checkout's records and data/archive_index.csv.
# OUTPUT: archive: the objects under s3://fresh-bc/archive/knowledge/, rows appended to data/archive_index.csv.
#         PULL: data/tune/<key>_{curve.rds,grades.csv}, data/compare/<key>_segments.rds, data/fdis/derived/*.csv and
#         data/fdis/build/{reconcile.csv,sites.rds}, each md5-checked.
# RUN:    Rscript scripts/0336-archive.R                  (from the repo root: the published tables, every key with a
#                                                          record; KEYS=CH_rear,BT_rear for some; DRY=1 lists)
#         RUN=<run> Rscript scripts/0336-archive.R        (a candidate under data/{tune,compare}/candidate/<run>/)
#         TUNE_DIR=… COMPARE_DIR=… EVIDENCE_DIR=… BUILD_DIR=… SITES_DIR=… Rscript scripts/0336-archive.R
#                                                         (a staged copy: a BUILD_DIR other than data/fdis/build
#                                                          refuses without SITES_DIR)
#         PULL=TRUE [GRADES=TRUE] [KEYS=…] [DEST=<checkout>] [BATCH=<key>=<batch>,…] Rscript scripts/0336-archive.R
#                                                         (BATCH: only where several archives hold one record with
#                                                          other curves or segments, which the restore names)
#         SCHEMA=<schema> with either: says whether the database still holds the run's build (run, flows, walk)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)

flag <- function(x) Sys.getenv(x) %in% c("1", "TRUE", "true")
pull <- flag("PULL")
dry <- flag("DRY")
run <- Sys.getenv("RUN")
tune_dir <- Sys.getenv("TUNE_DIR", if (nzchar(run)) file.path("data/tune/candidate", run) else "data/tune")
compare_dir <- Sys.getenv("COMPARE_DIR", if (nzchar(run)) file.path("data/compare/candidate", run) else "data/compare")
evidence_dir <- Sys.getenv("EVIDENCE_DIR", "data/fdis/derived")
build_dir <- Sys.getenv("BUILD_DIR", "data/fdis/build")
sites_dir <- Sys.getenv("SITES_DIR", "data/fdis/derived")
# a staged build's fdis_sites.csv is its own, not the one 0240 last wrote here (review of #170, round 1)
if (!pull && build_dir != "data/fdis/build" && !nzchar(Sys.getenv("SITES_DIR"))) {
  stop("BUILD_DIR is a staged build (", build_dir, "): set SITES_DIR to the directory holding the fdis_sites.csv ",
       "0240 made from its sites.rds")
}
dest <- Sys.getenv("DEST", ".")
index <- "data/archive_index.csv"

recs_dir <- if (pull) file.path(dest, "data/tune") else tune_dir
keys <- if (nzchar(Sys.getenv("KEYS"))) strsplit(Sys.getenv("KEYS"), ",")[[1]] else
  sub("_grades_record\\.csv$", "", list.files(recs_dir, "_grades_record\\.csv$"))
if (!length(keys)) stop("no grade records in ", recs_dir, ": nothing to ", if (pull) "restore" else "archive")
records <- lapply(stats::setNames(keys, keys), function(k) {
  knw_grade_record_read(file.path(recs_dir, paste0(k, "_grades_record.csv")))
})

# can the database still recreate the run? Its build (link's run, the flow load, the walk) against the records
schema <- Sys.getenv("SCHEMA")
if (nzchar(schema)) {
  conn <- DBI::dbConnect(RPostgres::Postgres())
  live <- knw_build_record(conn, schema)
  DBI::dbDisconnect(conn)
  for (k in keys) {
    r <- records[[k]]
    off <- c(run = !identical(r$run_uid, live$run_uid), flows = !identical(r$discharge_load, live$discharge_load),
             walk = !identical(r$walk_md5, live$walk_md5))
    message(k, ": ", if (!any(off)) sprintf("the database (%s) still holds this run's build", schema) else
      sprintf("the database (%s) differs in %s: the run can no longer be regraded there", schema,
              paste(names(off)[off], collapse = ", ")))
  }
}

if (pull) {
  # BATCH=CH_rear=<batch>,BT_rear=<batch>: for a record several archives hold with other curves or segments
  bt <- if (nzchar(Sys.getenv("BATCH"))) strsplit(strsplit(Sys.getenv("BATCH"), ",")[[1]], "=") else list()
  if (!all(lengths(bt) == 2) || any(!nzchar(unlist(bt)))) stop("BATCH takes <key>=<batch>[,<key>=<batch>]")
  batch <- if (length(bt)) stats::setNames(vapply(bt, `[`, "", 2), vapply(bt, `[`, "", 1)) else NULL
  if (length(setdiff(names(batch), keys))) stop("BATCH names keys not restored: ", paste(setdiff(names(batch), keys), collapse = ", "))
  got <- knw_archive_pull(keys, dest = dest, grades = flag("GRADES"), index = index, batch = batch)
  message("Restored or kept ", length(got), " files into ", normalizePath(dest), ":\n  ",
          paste(sub(paste0("^", dest, "/"), "", got), collapse = "\n  "))
  quit(save = "no", status = 0)
}

link_repo <- Sys.getenv("LINK_REPO", "../link")
f_voc <- file.path(link_repo, "inst/extdata/vocabulary.csv")
voc <- if (file.exists(f_voc)) utils::read.csv(f_voc, colClasses = "character") else NULL
plan <- knw_archive_plan(keys, tune_dir, compare_dir, evidence_dir, build_dir, vocabulary = voc, sites_dir = sites_dir)
message(sprintf("%s %d objects (%s; evidence build %s):\n  %s", if (dry) "Would archive" else "Archiving", nrow(plan) + 1,
                paste(unique(paste(plan$key, plan$setup)[plan$kind == "tune"]), collapse = ", "), plan$evidence_id[1],
                paste(plan$object, collapse = "\n  ")))
rows <- knw_archive_put(plan, index = index, promoted = flag("PROMOTED"), dry_run = dry)
if (dry) quit(save = "no", status = 0)
sent <- rows[rows$event == "archived", ]
message(sprintf("Archived %d objects (%.0f MB stored); %s appended to %s. Commit it with the run.", nrow(sent),
                sum(as.numeric(sent$bytes)) / 1e6, nrow(rows), index))
