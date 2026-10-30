# scripts/0335-promote.R
# ---------------------------------------------------------------------------
# Promote a candidate run into the tracked tables and the articles, on the operator's word (#111). 0320 writes a full
# run to data/tune/candidate/<run>/ and 0330 compares it into data/compare/candidate/<run>/, both ignored, so a run
# changes nothing tracked and no test. This is the one step that does: it moves the run in (knw_tune_promote(), whole
# or by key; the logs are copied), then rebuilds what reads the tracked tables, in order: 0325 (local only:
# data/thresholds.csv and data/thresholds_groups.csv; PUBLISH stays a separate step), data-raw/vignette_chinook.R
# (reads the thresholds), data-raw/vignette_method.R (reads the chinook bundle; refuses uncommitted code),
# data-raw/vignette_bib.R (Zotero running; the software versions come from the run's ledger) and
# data-raw/readme_figure.R. The articles and their
# review follow a promotion, and nothing else.
#
# WHY / DESIGN NOTES:
#   - BY KEY (Al, 2026-10-28): SPECIES=CH promotes CH's keys alone, so one species can be retuned and published while
#     the rest stay. What 0325 and the bundles require of the whole set (one evidence build, link run and gradient) is
#     checked before anything is copied, and a refusal names the kept keys that would have to come along.
#   - EVERY FILE OF A KEY: its tracked tables and the ignored grades, curve, score cache, segments and GeoPackage, which
#     0325, the bundles and a later rerun read; a tracked file of a promoted key the run did not write is removed.
#     Everything replaced or removed is first moved to data/{tune,compare}/candidate/replaced_<stamp>/, a candidate
#     itself: RUN=replaced_<stamp> undoes the promotion (the ignored files git cannot restore included).
#   - CHECKED AGAINST THIS MACHINE before anything moves: the walk (this tree's), the evidence (data/fdis/derived
#     md5s, where the tables are here; required when the rebuilds run) and, when they run, the live flow load, which
#     0325 and the bundles hold the grades to.
#   - ARCHIVED (#119): the promoted keys' grade tables, curves and segments, and the evidence they were graded on, go
#     to the bucket's versioned archive (knw_archive_put(), as scripts/0336-archive.R runs it) after the move and before
#     the rebuilds; whether it can is checked before anything moves (bucket credentials, versioning on, every file
#     against its record and the evidence). A failure stops the chain and names the 0336 command that finishes it. An
#     undo sends nothing and appends the index's undone/promoted events.
#   - NOT DONE HERE: the tests that pin the published run's numbers (tests/testthat/test-tune_repick.R's 1.96 picks,
#     test-vignette-data.R's key count and funnel, the articles' inline checks) and the research/ prose that quotes it
#     are revised by hand after a promotion that moves them.
#
# INPUT:  data/tune/candidate/<run>/ (0320), data/compare/candidate/<run>/ (0330); for the rebuilds the fwapg database
#         (PG* env vars; SCHEMA names the run's schema for vignette_chinook.R), LINK_REPO / WET_REPO as those scripts
#         take them, and Zotero running for vignette_bib.R
# OUTPUT: data/tune/<key>_*, data/tune/grad_fwa/<key>_*, data/compare/<key>_*, the rows of data/compare/{compare,change,
#         checks,floodplain}.csv, research/fig/compare_<key>_*.png, the run's logs in scripts/logs/habitat/, then
#         0325's and the bundles' outputs; scripts/logs/habitat/<date>_promote-<run>.txt; the archive's objects under
#         s3://fresh-bc/archive/knowledge/ and rows of data/archive_index.csv (#119; AWS credentials for the bucket)
# RUN:    RUN=<run> Rscript scripts/0335-promote.R   (from the repo root; SPECIES=CH,BT to promote those species' keys;
#         DRY=1 lists what would be moved and removed and writes nothing; BUNDLES=FALSE moves and stops;
#         RUN=replaced_<stamp> undoes a promotion: moves back only, unchecked against this machine's evidence)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)

run <- Sys.getenv("RUN")
if (!nzchar(run)) stop("RUN names the candidate run to promote (a directory under data/tune/candidate/)")
dry <- Sys.getenv("DRY") %in% c("1", "TRUE", "true")
bundles <- !identical(Sys.getenv("BUNDLES"), "FALSE")
# an undo puts back the tables a promotion replaced; when that promotion moved the evidence or the walk, this machine
# holds the new ones, so the old set is moved back unchecked against them and the rebuilds, which would refuse, wait
undo <- startsWith(run, "replaced_")
if (undo && bundles) {
  message("RUN=", run, " is an undo: the tables are moved back and nothing is rebuilt (BUNDLES=FALSE). Rebuild where ",
          "the evidence the restored tables name is in data/fdis/derived.")
  bundles <- FALSE
}
only <- Sys.getenv("SPECIES")
keys <- NULL
if (nzchar(only)) {
  sp <- strsplit(only, ",")[[1]]
  have <- sub("_summary\\.csv$", "", list.files(file.path("data/tune/candidate", run), "_summary\\.csv$"))
  keys <- have[sub("_[^_]+$", "", have) %in% sp]
  if (!length(keys)) stop("run ", run, " holds no key of ", only)
}

# what the next readers will hold the promoted set to, on this machine and tree
derived <- file.path("data/fdis/derived", c("visits_link.csv", "visits_species.csv", "walks.csv"))
live <- if (undo) NULL else list(walk_md5 = knw_walk_md5())
# the bundles read the evidence, so a machine without it cannot rebuild them: refused before anything moves
if (!undo && bundles && !all(file.exists(derived))) {
  stop("no ", paste(derived[!file.exists(derived)], collapse = ", "), ": the rebuilds need the evidence the run was ",
       "scored on; copy it here, or BUNDLES=FALSE to move the tables only (unarchived: 0336 archives them later)")
}
if (!undo && all(file.exists(derived))) live$evidence_md5 <- paste(unname(tools::md5sum(derived)), collapse = ";")
# a dry run reads the live flow load too, so it refuses what the real run would
if (bundles) {
  conn <- DBI::dbConnect(RPostgres::Postgres())
  live$discharge_load <- knw_discharge_load(conn)
  DBI::dbDisconnect(conn)
}
# the archive (#119): the promoted keys' grade tables, curves and segments, and their evidence, go to the bucket's
# versioned archive once moved. Checked before anything moves (credentials, versioning, every file against its record
# and the evidence), so a promotion that could not be archived is refused, not half done. An undo uploads nothing: it
# records in the index which run is published again, and makes that run's objects current where a shared folder holds
# them (knw_archive_undo())
build_dir <- "data/fdis/build"
archive_keys <- function(dir_t) {
  k <- sub("_grades_record\\.csv$", "", list.files(dir_t, "_grades_record\\.csv$"))
  if (is.null(keys)) k else intersect(k, keys)
}
# the archive needs the evidence the run was graded on; with BUNDLES=FALSE on a machine without it the tables move
# unarchived, and the 0336 command that archives them where the evidence is is named (round 1 of the review)
ev_here <- all(file.exists(c(file.path("data/fdis/derived", c("visits_link.csv", "visits_species.csv", "walks.csv",
                                                               "fdis_sites.csv")),
                             file.path(build_dir, c("reconcile.csv", "sites.rds")))))
archive_now <- undo || ev_here || bundles
if (!undo && archive_now) {
  ak <- archive_keys(file.path("data/tune/candidate", run))
  if (length(ak)) {
    ver <- tryCatch(.knw_aws(c("s3api", "get-bucket-versioning", "--bucket", .knw_archive_bucket, "--query", "Status",
                               "--output", "text")), error = function(e) conditionMessage(e))
    if (!identical(trimws(ver[length(ver)]), "Enabled")) {
      stop("the archive cannot take this promotion (bucket credentials and versioning; #119): ", paste(ver, collapse = " "))
    }
    knw_archive_plan(ak, file.path("data/tune/candidate", run), file.path("data/compare/candidate", run),
                     "data/fdis/derived", build_dir)
  }
}
p <- knw_tune_promote(run, keys, live = live, dry_run = dry)
lines <- c(sprintf("Promotion of candidate run %s%s: %s.", run, if (dry) " (DRY=1: nothing written)" else "",
                   paste(p$keys, collapse = ", ")),
           sprintf("%d files written, %d removed; what they replaced is in candidate run %s.", length(p$written),
                   length(p$removed), p$archive),
           if (length(p$notes)) c("", "## kept as they were (the run did not bring them)", p$notes),
           "", "## written", p$written, "", "## removed", if (length(p$removed)) p$removed else "(none)")
message(paste(lines, collapse = "\n"))
if (dry) quit(save = "no", status = 0)
path_log <- .knw_free_path(file.path("scripts/logs/habitat",
                                     paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_promote-", run, ".txt")))
writeLines(lines, path_log)
ak <- archive_keys("data/tune")
ak <- intersect(ak, p$keys)
if (length(ak) && undo) {
  tryCatch(knw_archive_undo(ak), error = function(e) {
    stop("the tables are moved back but the archive does not yet say so (", conditionMessage(e), "): rerun ",
         "Rscript -e 'pkgload::load_all(); knw_archive_undo(c(\"", paste(ak, collapse = "\", \""), "\"))'",
         call. = FALSE)
  })
  message("Recorded in data/archive_index.csv: ", paste(ak, collapse = ", "), " published again from run ", run, ".")
} else if (length(ak) && !archive_now) {
  message("BUNDLES=FALSE without the evidence here: ", paste(ak, collapse = ", "), " moved but NOT archived. Where the ",
          "evidence is, run KEYS=", paste(ak, collapse = ","), " PROMOTED=TRUE Rscript scripts/0336-archive.R.")
} else if (length(ak)) {
  tryCatch({
    knw_archive_put(knw_archive_plan(ak, "data/tune", "data/compare", "data/fdis/derived", build_dir), promoted = TRUE)
  }, error = function(e) {
    stop("the tables are promoted but not archived (", conditionMessage(e), "): rerun KEYS=",
         paste(ak, collapse = ","), " PROMOTED=TRUE Rscript scripts/0336-archive.R before anything else", call. = FALSE)
  })
  message("Archived ", paste(ak, collapse = ", "), " and their evidence; data/archive_index.csv appended.")
}
if (!bundles) {
  message("BUNDLES=FALSE: moved only. Rerun 0325, data-raw/vignette_chinook.R and data-raw/vignette_method.R before ",
          "committing, or tests/testthat/test-vignette-data.R fails.")
  quit(save = "no", status = 0)
}
# each rebuild in its own process, as it is run by hand, and the chain stops at a failed step
Sys.unsetenv(c("PUBLISH", "REPUBLISH"))
for (s in c("scripts/0325-publish.R", "data-raw/vignette_chinook.R", "data-raw/vignette_method.R",
            "data-raw/vignette_bib.R", "data-raw/readme_figure.R")) {
  message("---- ", s)
  st <- system2("Rscript", s)
  if (!identical(st, 0L)) stop(s, " failed (exit ", st, "): the tables are promoted, the rebuilds after it are not run")
}
message("Promoted ", run, ". Run devtools::test(), revise the pins and research/ prose that quote the published run, ",
        "review the articles against the new bundles, then commit with the run's evidence ledger and ",
        "data/archive_index.csv (",
        knw_run_ledger("data/tune"), ").")
