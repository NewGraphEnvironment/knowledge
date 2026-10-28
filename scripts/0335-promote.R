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
#   - CHECKED AGAINST THIS MACHINE before anything moves: the evidence (data/fdis/derived md5s), the walk (this tree's)
#     and, when the rebuilds run, the live flow load, which 0325 and the bundles hold the grades to.
#   - NOT DONE HERE: the tests that pin the published run's numbers (tests/testthat/test-tune_repick.R's 1.96 picks,
#     test-vignette-data.R's key count and funnel, the articles' inline checks) and the research/ prose that quotes it
#     are revised by hand after a promotion that moves them.
#
# INPUT:  data/tune/candidate/<run>/ (0320), data/compare/candidate/<run>/ (0330); for the rebuilds the fwapg database
#         (PG* env vars; SCHEMA names the run's schema for vignette_chinook.R), LINK_REPO / WET_REPO as those scripts
#         take them, and Zotero running for vignette_bib.R
# OUTPUT: data/tune/<key>_*, data/tune/grad_fwa/<key>_*, data/compare/<key>_*, the rows of data/compare/{compare,change,
#         checks,floodplain}.csv, research/fig/compare_<key>_*.png, the run's logs in scripts/logs/habitat/, then
#         0325's and the bundles' outputs; scripts/logs/habitat/<date>_promote-<run>.txt
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
       "scored on; copy it here, or BUNDLES=FALSE to move the tables only")
}
if (!undo && all(file.exists(derived))) live$evidence_md5 <- paste(unname(tools::md5sum(derived)), collapse = ";")
# a dry run reads the live flow load too, so it refuses what the real run would
if (bundles) {
  conn <- DBI::dbConnect(RPostgres::Postgres())
  live$discharge_load <- knw_discharge_load(conn)
  DBI::dbDisconnect(conn)
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
        "review the articles against the new bundles, then commit with the run's evidence ledger (",
        knw_run_ledger("data/tune"), ").")
