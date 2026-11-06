# scripts/0320-tune-run.R
# ---------------------------------------------------------------------------
# One tuning run across species and stages: every rule in each species' grid scored on held-out
# watershed groups, the pick, the joint use curve, and a grade for every segment of the species'
# groups. Issue #57, phase 2. Successor to 0291/0292 (BT) and 0297 (CH), which stay frozen on the
# v2 tables. Input from 0310; consumers 0325 (publish) and 0330 (comparison).
#
# ANALYSIS SPEC (0297's, fixed before its first fit and carried to every species; the parts
# #57 settled are marked):
#   - POPULATION: stream-branch visits (FWA edges 1000/1100/2000/2300, not in a river polygon, a
#     wetland >= 1 ha or a lake >= 100 ha), fished area 10-10,000 m2, in groups where link marks
#     the species present, no code blocking its absence, no natural barrier to it downstream.
#   - RESPONSE: rearing U = the species caught; spawning S = spawner evidence (0293's maturity
#     rule), which only char carry (#57: every other species' spawning row says `no_response`).
#   - GRID per species x stage around link's own default thresholds (0297's ladders; the species'
#     own default width, MAD and gradient join them). KO and SK rear in lakes only: no stream rule.
#   - SCORE: 0297's held-out deviance on five stratified WSG folds, each group held out once (#57:
#     #28's fixed split is not carried), the one-SE region, the fewest-departures pick, the
#     200-resample WSG bootstrap, nested selection and four more fold seeds.
#   - FLOORS (#57): a species x stage is fitted with >= 5 groups having both outcomes, and
#     labelled `underpowered` under 10.
#   - CURVE (#57): one GAM per species x stage, te(log size, log distance to the pick's Q) +
#     s(gradient) + the nuisance terms + s(wsg, re), distance censored at 50 km; its held-out
#     deviance on the same folds beside the grid's.
#   - GRADE (#57, decided 2026-10-17): predicted rate at the reference nuisance values with the
#     group effect excluded, over the 95th percentile of accessible segments' rate, capped at 1,
#     in fifths (the percentile over the stream branch's edge types since #65: for CH, CO, ST and WCT,
#     river polygons near 0 m otherwise set it). Expected use, not habitat quality. Walks for the grade run from the segment's
#     downstream end, for every accessible segment with a gradient, since the curve reads size and
#     distance jointly (#65; #57's grades walked only the exception's candidates and read the
#     rest at the 50 km cap).
#   - CH's size floor (0.75 against 0.5 m3/s) is read off CH rearing's pick on all CH groups.
#   - LADDER (#68): the gradient ladder runs to 30 % for every species (knw_tune_grid()'s default since
#     #68; #67 ran it for CH alone), on the evidence build of #73, whose walks end at the river's bank.
#   - TWO STARTS (#80): the pick is read from link's width `default` (`recommended`, as before) and from
#     its flow version (`recommended_flow`), at 1 and 1.96 SE; link's `default_tuned` row joins each grid
#     as a scored candidate (`is_link_tuned`), so the table says how link's own flow floors score.
#   - ANCHORING (#141): each start's recommended rule beside the best-scoring one (knw_tune_anchor()): how far each sits
#     behind the best, in deviance and SE, and how many parts (size test, gradient, exception) separate the two picks
#     from the best and from each other, so how much a baseline chose the pick is a number. Rules tied at the best are
#     one fit, and a pick's distance is to the nearest of them. Each pick is also read against the best rule a pick may
#     be, which is not the best where the best's exception is under d_floor or it did not converge. In each summary and
#     the pick report.
#   - GRADIENT (#92): rules and curves read link's segment gradient (`segment_gradient`), the gradient link applies a
#     rule to and the grade reads, where #57 to #91 read the whole Atlas line's (`fwa_gradient`). link cuts a stream at
#     the observations of the species it models, so a visit with fish usually sits on a short segment starting at it
#     (data-raw/segment_gradient_check.R). GRADIENT=fwa_gradient is the sensitivity: the main fold seed, no grades,
#     outputs under data/tune/grad_fwa/, which 0325, 0330 and knw_thresholds_table() do not read (the methodology
#     bundle does, for its sensitivity sentence). The column is recorded in the score cache, the summary and every grade table.
#   - SMOKE RUN FIRST (#84): before any grid is scored, every key that would be fitted scores no rule,
#     `default`, link's `default_tuned` row and the previous pick (the `recommended` rule of the committed
#     data/tune/<key>_tune.csv) on the main fold seed, and four checks gate the scorer (knw_tune_smoke()). One
#     failed check on any key ends the run with every key's report in the log, and nothing is scored.
#
# INPUT:  EVIDENCE_DIR/{visits_link,visits_species,walks}.csv (0310; default data/fdis/derived) and the newest ledger 0310
#         wrote for that directory (#120), data/fdis/build/fish.rds
#         (0230), data/fdis_species_codes.csv; the link repository at LINK_REPO at the build's link_sha
#         (parameters_habitat_thresholds.csv); fwapg database (PG* env vars): the run's schema (SCHEMA, default
#         fresh_default), discharge; data/tune/<sp>_<stage>_tune.csv where one exists (the previous pick)
# OUTPUT: every file below is written under data/tune/candidate/<run>/ (ignored; #111), which scripts/0335-promote.R
#         copies into data/tune/ on the operator's word; the names are the tracked ones it becomes:
#         data/tune/<sp>_<stage>_smoke.csv     the smoke run's four checks (value, limit, pass) and its rules' scores
#         data/tune/<sp>_<stage>_tune.csv      every rule's score (the full grid), with pick, recommended, region
#         data/tune/<sp>_<stage>_curves.csv    the marginal curves at the pick
#         data/tune/<sp>_<stage>_grades.csv    one row per segment of the species' groups, each graded segment at
#                                              its own walked distance, with dist_status (ignored; 0325 publishes)
#         data/tune/<sp>_<stage>_grades_record.csv  the grade table's record: its run columns, md5, size and rows, the
#                                              run, ledger, commit and link build (tracked; the bundles pin it, #119)
#         data/tune/<sp>_<stage>_grades_receipt.json  its provenance receipt in crate's shape (#154): the recipe, the
#                                              pick and the table's summaries, compared with a rebuild's (tracked)
#         data/tune/<sp>_<stage>_groups.csv    the groups modelled, with their fold
#         data/tune/<sp>_<stage>_seeds.csv     the four more fold seeds' best, pick and recommended rules
#         data/tune/<sp>_<stage>_honest.csv    nested selection: each fold's pick and its held-out deviance
#         data/tune/<sp>_<stage>_score.rds     the scored grid, read back on a rerun (ignored)
#         data/tune/<sp>_<stage>_summary.csv   one row: status, population, pick, held-out deviances, how far each
#                                              start moved the pick from the best (#141) (0325 binds them)
#         data/tune/<sp>_<stage>_curve.rds     the fitted curve object (ignored; 0330 reads them)
#         <date>_tune_run-<run>.txt (the log, in the run directory; promoted to scripts/logs/habitat/)
# RUN:    Rscript scripts/0320-tune-run.R   (from the repo root; SPECIES=CH,BT to restrict; WORKERS=14; RUN=<name> names
#         the candidate, a UTC stamp YYYYMMDD_HHMM (the default, and the only form taken))
#         Scored grids (<key>_score.rds) and grade tables already in the run directory are kept, so RUN=<name> resumes
#         a run, and a run over a subset of species on another host, with the caches copied, grades only what is missing. The cache is keyed on the
#         population and the grid, not the scorer's code: remove <key>_score.rds after a change to R/tune_score.R.
#         DEV=1 is the development setting (#84): the smoke run and the full grid on the main fold seed only (no
#         bootstrap, nested selection or extra seeds), the curve and the summary, no grades, every output under
#         DEV_DIR (default data/tune/dev/; ignored), log included, so a scorer change is proved on every species before a
#         full run. EVIDENCE_DIR=data/fdis/derived_<name> DEV_DIR=data/tune/dev_<name> scores a test build (#120).
#         It ends in the pick report (#111): data/tune/dev/pick_report.csv, each key's pick beside the published one
#         (knw_tune_pick_report()), the run to make after a change upstream (a link build, placement, a flow reload).
#         A candidate writes its own <run>/pick_report.csv, before it grades.
#         GRADIENT=fwa_gradient scores the Atlas line's gradient on the main fold seed, no grades, into <run>/grad_fwa/
#         (data/tune/dev/grad_fwa/ with DEV=1; promoted to data/tune/grad_fwa/), its log suffixed -grad_fwa. Without
#         DEV it needs RUN=<the main run's name>, whose candidate it joins and is promoted with.
#         GRADIENT=parent_gradient (#120) does the same with the minimal parent's gradient on a full segment (0310's
#         PARENT_DIR or PARENT=TRUE) into grad_parent/, which is never promoted.
#         SETUP=1 GRADIENT=parent_gradient|segment_fwa_gradient (#120) makes a setup: a full candidate of its own on that
#         gradient (every seed and check, graded, the segments read with the same gradient by knw_grade_species()),
#         written to the run's root (marked with setup.txt) with a -setup_<parent|fwa> log, its grade records carrying the setup's grad token
#         (grad-parent, grad-fwa) in place of the build's. 0330 compares it; promotion refuses it.
#         MIN_WSG= and FOLDS= (default 5 and 5, the tuning's floors) lower them for a test on a few groups (#120): named
#         in the log and each summary, and refused by knw_tune_promote().
#         A grading run checks the database's round trip at connect and stops off its host (over 20 ms) unless
#         REMOTE=TRUE; DEV=1 and GRADIENT=fwa_gradient grade nothing and skip the check (#110).
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
# an unreachable or saturated server hangs a connection attempt forever without this (CLAUDE.md)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

link_repo <- Sys.getenv("LINK_REPO", "../link")
workers <- as.integer(Sys.getenv("WORKERS", max(1L, min(14L, parallel::detectCores() - 2L))))
species <- strsplit(Sys.getenv("SPECIES", paste(knw_species(), collapse = ",")), ",")[[1]]
schema <- Sys.getenv("SCHEMA", "fresh_default")  # the run's persist schema, by its current name (renamed after the run, #73)
dev <- Sys.getenv("DEV", "") %in% c("1", "TRUE", "true")
remote <- Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")   # grade off the database's host anyway (#110)
# the gradient the rules and the curve read (#92): link's segment gradient, the one link applies a rule to; the Atlas
# line's is the sensitivity, scored on the main fold seed alone into its own directory and never graded
gradient <- Sys.getenv("GRADIENT", "segment_gradient")
# parent_gradient (#120) is the minimal parent's gradient on a full segment, which 0310 joins with PARENT_DIR: scored as
# the Atlas line's is, into grad_parent/, and never promoted (knw_tune_promote() moves grad_fwa/ alone)
# segment_fwa_gradient (#120) is the Atlas gradient of the line the visit's segment lies on, which a setup grades on
grad_dirs <- c(segment_gradient = "", fwa_gradient = "grad_fwa", parent_gradient = "grad_parent",
               segment_fwa_gradient = "grad_fwa_seg")
if (!gradient %in% names(grad_dirs)) stop("GRADIENT must be one of ", paste(names(grad_dirs), collapse = ", "), ": ", gradient)
cols_run <- c(grad = gradient, width = "cw_deploy", mad = "mad_pick")
# the floors (#120): a key is fitted with at least max(MIN_WSG, FOLDS) groups having both outcomes, on FOLDS folds.
# The tuning's are 5 and 5 (knw_tune_run()'s defaults); a test on fewer groups lowers them, and every log line and
# summary says so, and knw_tune_promote() refuses a summary scored on any other
floor_default <- c(min_wsg = eval(formals(knw_tune_run)$min_wsg), folds = eval(formals(knw_tune_run)$folds))
min_wsg <- as.integer(Sys.getenv("MIN_WSG", floor_default[["min_wsg"]]))
folds <- as.integer(Sys.getenv("FOLDS", floor_default[["folds"]]))
if (is.na(min_wsg) || is.na(folds) || min_wsg < 2L || folds < 2L) stop("MIN_WSG and FOLDS must be integers of 2 or more")
floors_test <- min_wsg != floor_default[["min_wsg"]] || folds != floor_default[["folds"]]
# the main seed alone, no grades: the development setting and the sensitivity
# a setup (#120): a graded candidate on another gradient than the segment's own, compared beside the published run and
# never promoted; its grade records carry the setup's own grad token
setup <- Sys.getenv("SETUP") %in% c("1", "TRUE", "true")
setup_tokens <- .knw_grade_grad_tokens
setup_names <- c(parent_gradient = "parent", segment_fwa_gradient = "fwa")   # the log's -setup_<name>
if (setup && (dev || !gradient %in% names(setup_tokens))) {
  stop("SETUP=1 is a graded candidate on GRADIENT=", paste(names(setup_tokens), collapse = " or "), ", without DEV=1")
}
main_only <- dev || (gradient != "segment_gradient" && !setup)
se_strict <- 1.96   # the stricter reading of the region, in SE, beside the one-SE pick (#79)
# a full run is a candidate (#111): it writes data/tune/candidate/<run>/ (ignored), never the tracked data/tune/, which
# only scripts/0335-promote.R writes, on the operator's word. RUN names the run (a UTC stamp at launch by default);
# giving an existing run's name resumes it on its cached scores and grades
run <- Sys.getenv("RUN", format(Sys.time(), "%Y%m%d_%H%M", tz = "UTC"))
# a stamp, so a log name says which run it is and sorts by date: the logs add -<species>, -grad_fwa and a pass number,
# and data-raw/vignette_chinook.R matches a run's logs by that form
if (!grepl("^[0-9]{8}_[0-9]{4}([0-9]{2})?$", run)) stop("RUN must be a UTC stamp YYYYMMDD_HHMM, as the default is: ", run)
# the build the run scores (#120): EVIDENCE_DIR, as 0310 wrote it, found with its own ledger; a DEV=1 run writes
# DEV_DIR (default data/tune/dev), so two DEV runs on two builds keep their tables
evidence_dir <- Sys.getenv("EVIDENCE_DIR", .knw_evidence_dir_default)
dev_dir <- Sys.getenv("DEV_DIR", "data/tune/dev")
if (nzchar(Sys.getenv("DEV_DIR")) && !dev) stop("DEV_DIR names a DEV=1 run's directory: give DEV=1 with it")
# data/tune/dev or data/tune/dev_<name>, the two forms .gitignore keeps out of the tracked tables
if (dev && !grepl("^dev(_[A-Za-z0-9][A-Za-z0-9_.]*)?$", basename(dev_dir)) ||
      dev && !identical(.knw_path_key(dirname(dev_dir)), .knw_path_key("data/tune"))) {
  stop("DEV_DIR must be data/tune/dev or data/tune/dev_<name> (ignored): ", dev_dir)
}
dev_dir <- .knw_path_rel(dev_dir)   # written into the log: relative, never a home path
dir_run <- if (dev) dev_dir else file.path("data/tune/candidate", run)
# the gradient a run's summaries were scored on: a setup and a main run never share a directory (#120), so a setup is not
# resumed over a main run, nor a main run's sensitivity scored inside a setup
# a key with no fit records no gradient on its summary, so a setup also marks its run with setup.txt, naming the gradient,
# before any key is scored; promotion and these guards read both (round 2 of the branch review)
f_setup <- file.path(dir_run, .knw_setup_marker)
run_grads <- unique(c(if (file.exists(f_setup)) readLines(f_setup, n = 1),
                      unlist(lapply(list.files(dir_run, "_summary\\.csv$", full.names = TRUE), function(f) {
                        x <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
                        if ("curve_grad" %in% names(x)) x$curve_grad else NA_character_
                      }))))
# a key with no fit records no gradient (NA), in a setup and a main run alike
if (setup && length(setdiff(run_grads, c(gradient, NA)))) {
  stop("RUN=", run, " holds summaries scored on ", paste(setdiff(run_grads, c(gradient, NA)), collapse = ", "),
       ": a setup on ", gradient, " needs a run of its own")
}
if (!dev && !setup && gradient == "segment_gradient" && length(setdiff(run_grads, c("segment_gradient", NA)))) {
  stop("RUN=", run, " is a setup on ", paste(setdiff(run_grads, c("segment_gradient", NA)), collapse = ", "),
       " (#120): a main run needs a run of its own")
}
# the Atlas-gradient sensitivity belongs to a main run, which promotes it with its own tables: name that run
if (!dev && !setup && gradient != "segment_gradient" &&
      (!nzchar(Sys.getenv("RUN")) || !length(list.files(dir_run, "_summary\\.csv$")))) {
  stop("GRADIENT=", gradient, " is the sensitivity of a main run: give it RUN=<that run's name> (data/tune/candidate/)")
}
if (!dev && !setup && gradient != "segment_gradient" && length(setdiff(run_grads, c("segment_gradient", NA)))) {
  stop("RUN=", run, " is a setup on ", paste(setdiff(run_grads, c("segment_gradient", NA)), collapse = ", "),
       " (#120), not a main run: its sensitivity is not scored")
}
dir_out <- dir_run
if (nzchar(grad_dirs[[gradient]]) && !setup) dir_out <- file.path(dir_out, grad_dirs[[gradient]])
# one log per pass: a pass over a subset of species (SPECIES=) names them, so passes do not overwrite each other. A DEV=1
# log stays beside its outputs in the ignored data/tune/dev/, and a candidate's in its run directory, named for the run,
# so a promotion can copy it to scripts/logs/habitat/ beside the others (#111)
# A candidate's passes are named by their UTC start (p<YYYYMMDDHHMMSS>), so the pass that graded a key last sorts last
# whatever the day, the species or the host it ran on; data-raw/vignette_chinook.R reads it by that
pass <- format(Sys.time(), "%Y%m%d%H%M%S", tz = "UTC")
path_log <- file.path(dir_run, paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_tune_run",
                                      if (!dev) sprintf("-%s-p%s", run, pass) else "",
                                                     if (nzchar(Sys.getenv("SPECIES"))) paste0("-", tolower(gsub(",", "_", Sys.getenv("SPECIES")))) else "",
                                                     if (dev) "-dev" else "",
                                                     if (setup) paste0("-setup_", setup_names[[gradient]])
                                                     else if (nzchar(grad_dirs[[gradient]])) paste0("-", grad_dirs[[gradient]])
                                                     else "", ".txt"))
# a resumed candidate keeps the log of the pass that graded (data-raw/vignette_chinook.R reads its grade lines): a later
# pass under the same name is numbered, never written over it
if (!dev) path_log <- .knw_free_path(path_log)
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
if (setup) writeLines(gradient, f_setup)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}
# a refusal writes the log first: the numbers it names are the point of stopping
fail <- function(...) { say(...); writeLines(log_lines, path_log); stop(sprintf(...), call. = FALSE) }
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}

# the commit the run ran at, read at its start, for each grade record (#119): +dirty when a tracked file of the package
# or a script differs from it (untracked files, such as the ledger 0310 has just written, do not count)
git1 <- function(...) suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = FALSE))
knowledge_commit <- paste0(git1("rev-parse", "--short", "HEAD")[1],
                           if (length(git1("status", "--porcelain", "--untracked-files=no", "--", "R", "scripts", "inst")))
                             "+dirty" else "")
# the same state in full, for each grade table's receipt (#154): crate names code by its 40-character commit. And the
# crate that writes the receipts must name their files, checked before hours of scoring rather than at the first grade
knowledge_git <- .knw_git_state()
if (!main_only) .knw_receipt_crate_check()

# ---- inputs and their provenance ------------------------------------------------------
ledger_path <- .knw_evidence_ledger(evidence_dir)
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- led$note[led$step == "run_link_sha"]
# the first line's shape is read by data-raw/vignette_chinook.R ("Evidence build <ledger> on link run"): keep the
# ledger path directly before " on link run"
say("Tuning run, knowledge#57. Evidence build %s on link run %s (link %s), schema %s; evidence directory %s.", ledger_path,
    run_uid, link_sha, schema, .knw_path_rel(evidence_dir))
say("%s: outputs under %s (ignored)%s.", if (dev) "DEV=1" else paste("Candidate run", run), dir_out,
    if (dev) "" else sprintf("; compare it with TUNE_DIR=%s scripts/0330, promote it with RUN=%s scripts/0335", dir_run, run))
# the evidence's identity: the md5 of each derived table, logged, carried into the score cache's settings and written
# on every grade table, so a rebuilt evidence of the same visit count is neither read back from the cache nor kept as
# a grade (the branch review of 2026-10-25)
evidence_md5s <- vapply(c("visits_link", "visits_species", "walks"), function(f) {
  unname(tools::md5sum(file.path(evidence_dir, paste0(f, ".csv"))))
}, character(1))
for (f in names(evidence_md5s)) say("  %s md5 %s", f, evidence_md5s[[f]])
evidence_md5 <- paste(unname(evidence_md5s), collapse = ";")
# the database's build, checked before any work (#87): a schema built by another run than the evidence's is refused
# here, not after the scoring, so the same command runs on any machine whose database holds the build. DEV=1 grades
# nothing and needs no database
if (!dev) {
  conn <- pg()
  rec <- tryCatch(knw_build_record(conn, schema, run_uid = run_uid), error = function(e) fail("%s", conditionMessage(e)))
  say("%s", rec$line)
  # a setup's run-level preconditions, before any scoring (#120; round 3 of the branch review): it re-reads the gradient
  # of a build whose own is grad-seg, and a setup on the parent's gradient grades on the parent table the evidence
  # recorded. A refusal writes <date>_tune_refused-<run>…txt, as the latency check's does
  refuse <- function(msg) {
    say("%s", msg)
    path_refused <- .knw_free_path(sub("_tune_run", "_tune_refused", path_log, fixed = TRUE))
    writeLines(log_lines, path_refused)
    stop(msg, " (log ", path_refused, ")", call. = FALSE)
  }
  if (setup && (anyNA(rec$tokens) || !identical(rec$tokens[["grad"]], "grad-seg"))) {
    refuse(paste0("a setup re-reads the gradient of a build whose own is grad-seg; this build's tokens are ",
                  paste(rec$tokens, collapse = ".")))
  }
  if (setup && gradient == "parent_gradient") {
    held <- tryCatch(.knw_parent_held(conn, schema, led), error = function(e) refuse(conditionMessage(e)))
    say("Parent table held to the evidence's: %s", held)
  }
  # the grade is bound by the database: refuse a connection off its host unless REMOTE=TRUE (#110). DEV=1 and
  # GRADIENT=fwa_gradient write no grades, so they are not checked. A refused run's log is <date>_tune_refused-<run>…txt
  # in the run's directory, so it neither overwrites the run's log nor matches the _tune_run*.txt that 0335 promotes and
  # vignette_chinook.R reads
  if (!main_only) {
    lat <- tryCatch(knw_db_latency_check(conn, remote = remote), error = function(e) {
      say("%s", conditionMessage(e))
      path_refused <- .knw_free_path(sub("_tune_run", "_tune_refused", path_log, fixed = TRUE))
      writeLines(log_lines, path_refused)
      stop(conditionMessage(e), " (log ", path_refused, ")", call. = FALSE)
    })
    say("%s", lat$line)
  }
  dbDisconnect(conn)
}
vl <- read_csv(file.path(evidence_dir, "visits_link.csv"), show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv(file.path(evidence_dir, "visits_species.csv"), show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))
walks <- read_csv(file.path(evidence_dir, "walks.csv"), show_col_types = FALSE)
if (!gradient %in% names(vl)) {
  stop("GRADIENT=", gradient, ": ", evidence_dir, "/visits_link.csv has no such column",
       if (gradient == "parent_gradient") " (0310 joins it with PARENT_DIR)" else "")
}
# the species link models on the build: those with any access value at a visit. link writes an access column for a
# species it does not model and leaves it empty, so a rule for it could be neither graded nor applied (#145). A
# missing column is an evidence build that did not read the species, not a species link left out: refused, since its
# keys would otherwise be not_modelled and a promotion would retire their published rules
no_col <- species[!paste0("access_", tolower(species)) %in% names(vl)]
if (length(no_col)) {
  stop(evidence_dir, "/visits_link.csv has no access column for ", paste(no_col, collapse = ", "),
       ": rebuild the evidence with 0310, or restrict SPECIES")
}
modelled <- species[vapply(species, function(sp) any(!is.na(vl[[paste0("access_", tolower(sp))]])), logical(1))]
if (length(setdiff(species, modelled))) {
  say("Not modelled on this build (no access value at any visit): %s; their keys are not_modelled.",
      paste(setdiff(species, modelled), collapse = ", "))
}
codes <- read_csv("data/fdis_species_codes.csv", col_types = cols(.default = "c"), na = "")
fish <- readRDS("data/fdis/build/fish.rds")
spawner <- knw_spawner_evidence(fish, vl |> inner_join(vs |> filter(species_code == "BT") |> select(site_visit, pooling), by = "site_visit") |>
                                  select(site_visit, month, pooling), codes)
say("Spawner evidence: %d BT visits with a coded fish, %d with evidence.", sum(!is.na(spawner$S)), sum(spawner$S %in% 1L))

# link's thresholds at the build's commit(s): a run whose groups were fixed at a later commit logs two
# SHAs; the thresholds must be the same text at each, and the first (HEAD of the run) is the one named.
# default_tuned's row joins each grid as the is_link_tuned candidate (#80), read at the same commits.
shas <- strsplit(link_sha, ";", fixed = TRUE)[[1]]
read_thr <- function(sha, bundle = "default") {
  f <- tempfile(fileext = ".csv")
  st <- system2("git", c("-C", link_repo, "show", sprintf("%s:inst/extdata/configs/%s/parameters_habitat_thresholds.csv", sha, bundle)), stdout = f)
  if (!identical(st, 0L) || !file.exists(f) || file.size(f) == 0) stop("could not read link's ", bundle, " thresholds at ", sha, " from ", link_repo)
  f
}
thr_of <- function(bundle) {
  fs <- vapply(shas, read_thr, character(1), bundle = bundle)
  if (length(fs) > 1 && length(unique(unname(tools::md5sum(fs)))) != 1) {
    stop("link's ", bundle, " thresholds differ between the run's commits ", link_sha)
  }
  read.csv(fs[1], stringsAsFactors = FALSE)
}
thr <- thr_of("default")
thr_tuned <- thr_of("default_tuned")
link_sha <- shas[1]
say("link default thresholds at %s (same at %s): %d species; default_tuned: %d species (its MAD floors join the grids).",
    shas[1], paste(shas[-1], collapse = ","), nrow(thr), nrow(thr_tuned))

# ---- the smoke run and its gates on every key, before any grid is scored (#84) ----------------
# the previous pick is the committed table's recommended rule, read from data/tune whatever dir_out is
previous <- character()
for (f in list.files("data/tune", "_tune\\.csv$", full.names = TRUE)) {
  r <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
  if ("recommended" %in% names(r) && sum(r$recommended == "TRUE") == 1L) {
    previous[sub("_tune\\.csv$", "", basename(f))] <- r$rule[r$recommended == "TRUE"]
  }
}
say("Fit: group intercepts absorbed (#83); normal prior SD %s on the data_set and era coefficients, cloglog scale (#84).",
    format(formals(knw_tune_run)$prior_sd))   # knw_tune_run's default is what runs: it is not passed below
say("Floors: MIN_WSG %d, FOLDS %d%s.", min_wsg, folds,
    if (floors_test) sprintf(" (a test: the tuning's are %d and %d; never promoted)", floor_default[["min_wsg"]],
                             floor_default[["folds"]]) else " (the tuning's)")
say("Rules and curves read the gradient from %s%s.", gradient,
    if (setup) sprintf(" (a setup, #120: graded on the same gradient, compared and archived, never promoted; outputs under %s)", dir_out)
    else if (main_only && !dev) sprintf(" (the sensitivity: the main seed only, no grades, outputs under %s)", dir_out) else "")
say("Smoke run first%s: previous picks on file for %s.", if (dev) sprintf(" (DEV=1: the main seed only, no grades, outputs under %s)", dir_out) else "",
    paste(names(previous), collapse = ", "))
# what a pass writes for a key replaces what an earlier pass of the run wrote, so a key's files in the run are this
# pass's (#111): clear them first, all but the score cache and the grade table, which are kept only when they pass
# their checks below (a key this pass does not fit loses its grades after scoring)
# The smoke tables go before the smoke run, the rest once it has passed, so a refused smoke run leaves the last
# pass's fit as it was
pat_keys <- sprintf("^(%s)_(rear|spawn)_", paste(species, collapse = "|"))
# a kept grade table keeps its record (#119) and its receipt (#154)
caches <- "_(score\\.rds|grades\\.csv|grades_record\\.csv|grades_receipt\\.json)$"
old_files <- list.files(dir_out, pat_keys, full.names = TRUE)
unlink(old_files[grepl("_smoke\\.csv$", old_files)])
t0 <- Sys.time()
sm <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = workers, thresholds_extra = thr_tuned, evidence_id = evidence_md5,
                   cols = cols_run, min_wsg = min_wsg, folds = folds,
                   previous = if (length(previous)) previous else NULL, smoke_only = TRUE, modelled = modelled)
smoke_failed <- character()
for (k in names(sm)) {
  s <- sm[[k]]$smoke
  if (is.null(s)) next
  say("%s %s", k, paste(s$lines, collapse = "\n  "))
  write_csv(bind_rows(s$checks |> mutate(table = "checks"),
                      s$rules |> mutate(table = "rules", across(where(is.numeric), ~ round(.x, 6)))) |>
              mutate(species_code = sm[[k]]$species_code, stage = sm[[k]]$stage, .before = 1),
            file.path(dir_out, paste0(k, "_smoke.csv")), na = "")
  if (!s$pass) smoke_failed <- c(smoke_failed, k)
}
say("Smoke run over %d keys in %.1f min.", sum(!vapply(sm, function(x) is.null(x$smoke), logical(1))),
    as.numeric(difftime(Sys.time(), t0, units = "mins")))
if (length(smoke_failed)) {
  fail("The smoke run failed on %s; nothing is scored. Each key's checks are above and in %s/<key>_smoke.csv.",
       paste(smoke_failed, collapse = ", "), dir_out)
}

# ---- score, pick, curve ------------------------------------------------------------------
unlink(old_files[file.exists(old_files) & !grepl(caches, old_files) & !grepl("_smoke\\.csv$", old_files)])
t0 <- Sys.time()
out <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = workers, cache_dir = dir_out,
                    thresholds_extra = thr_tuned, smoke = FALSE, extra = !main_only, evidence_id = evidence_md5, cols = cols_run,
                    min_wsg = min_wsg, folds = folds, modelled = modelled)
say("Scored %d species x stage in %.1f min on %d workers%s.", length(out), as.numeric(difftime(Sys.time(), t0, units = "mins")), workers,
    if (main_only) " (the main seed only)" else "")

for (k in names(out)) if (is.null(out[[k]]$curve)) {
  unlink(file.path(dir_out, paste0(k, c("_grades.csv", "_grades_record.csv", "_grades_receipt.json"))))
}
summ <- list()
# the d_floor a key was scored at (#141's anchoring reads its picks at it): a score cache from before the settings were
# recorded, which only GRADIENT=fwa_gradient reads back, was scored at knw_tune_run()'s default
d_floor_of <- function(sc) if (is.null(sc$spec$d_floor)) eval(formals(knw_tune_run)$d_floor) else sc$spec$d_floor
for (k in names(out)) {
  r <- out[[k]]
  row <- tibble(species_code = r$species_code, stage = r$stage, response = r$response, status = r$status,
                visits_in = r$population[["visits_in"]], detections = r$population["detections"],
                groups = r$population["groups"], groups_both = r$population["groups_both"],
                # the floors it was scored under (#120): knw_tune_promote() refuses any but the tuning's
                min_wsg = min_wsg, folds = folds)
  if (!is.null(r$score) && is.null(r$curve)) say("%s: curve failed: %s", k, r$curve_error)
  if (!is.null(r$score) && !is.null(r$curve)) {
    rules <- r$score$rules |> mutate(species_code = r$species_code, stage = r$stage, response = r$response, status = r$status)
    # how far each start moved the pick from the best (#141), at the run's own d_floor, checked before any of the key's
    # tables is written: its rule names are the ones the summary writes below
    anc <- knw_tune_anchor(rules, d_floor = d_floor_of(r$score))
    names_summ <- c(r$pick$rule, filter(rules, ddev_best == 0)$rule[1],
                    if (is.null(r$pick_flow)) NA_character_ else r$pick_flow$rule)
    if (!identical(c(anc$rule_recommended, anc$rule_best, anc$rule_recommended_flow), names_summ)) {
      # a code fault, not a refusal: no log is written under the name 0335 promotes
      stop(sprintf("%s: knw_tune_anchor() names %s where the summary names %s (recommended, best, flow)", k,
                   paste(anc$rule_recommended, anc$rule_best, anc$rule_recommended_flow, sep = " / "),
                   paste(names_summ, collapse = " / ")), call. = FALSE)
    }
    write_csv(rules |> mutate(across(where(is.numeric), ~ round(.x, 6))), file.path(dir_out, paste0(k, "_tune.csv")), na = "")
    write_csv(r$curve$curves |> mutate(across(where(is.numeric), ~ signif(.x, 5)), species_code = r$species_code, stage = r$stage,
                                       rule = r$pick$rule),
              file.path(dir_out, paste0(k, "_curves.csv")), na = "")
    write_csv(tibble(species_code = r$species_code, stage = r$stage, watershed_group_code = names(r$score$folds),
                     fold = as.integer(r$score$folds)), file.path(dir_out, paste0(k, "_groups.csv")), na = "")
    # the stability tables the score object holds, so a reader of the tables needs no rds (#62)
    if (!main_only) {
      write_csv(as_tibble(r$score$seeds) |> mutate(species_code = r$species_code, stage = r$stage),
                file.path(dir_out, paste0(k, "_seeds.csv")), na = "")
      write_csv(as_tibble(r$score$honest) |> mutate(across(where(is.double), ~ round(.x, 6)),
                                                    species_code = r$species_code, stage = r$stage),
                file.path(dir_out, paste0(k, "_honest.csv")), na = "")
    }
    dflt <- rules |> filter(is_default)
    best <- rules |> filter(ddev_best == 0) |> slice(1)
    ltn <- rules |> filter(is_link_tuned %in% TRUE)
    rep_of <- function(se, start) tryCatch(knw_tune_repick(rules, se_mult = se, start = start)$rule, error = function(e) NA_character_)
    row <- row |> mutate(
      rule_recommended = r$pick$rule, rule_pick = rules$rule[rules$pick], rule_best = best$rule,
      rule_recommended_196 = rep_of(se_strict, "default"),
      rule_recommended_flow = if (is.null(r$pick_flow)) NA_character_ else r$pick_flow$rule,
      rule_recommended_flow_196 = rep_of(se_strict, "flow"),
      rule_link_tuned = if (nrow(ltn)) ltn$rule else NA_character_,
      link_tuned_ddev = if (nrow(ltn)) ltn$ddev_best else NA_real_, link_tuned_se = if (nrow(ltn)) ltn$se_diff else NA_real_,
      link_tuned_in_region = if (nrow(ltn)) ltn$in_region else NA,
      default_in_region = dflt$in_region, default_ddev = dflt$ddev_best, default_se = dflt$se_diff,
      region_n = sum(rules$in_region), patterns = r$score$population[["patterns"]],
      dev_default = dflt$dev_heldout, dev_best = best$dev_heldout, dev_null = best$dev_heldout - best$ddev_null,
      dev_curve = r$curve$heldout, null_heldout_curve = r$null_heldout_curve, curve_prior_sd = r$curve$prior_sd,
      # the gradient the rule and the curve read (#92), which every grade table records and 0320's keep-check, 0325,
      # 0330 and the two data-raw/vignette_*.R scripts compare
      curve_grad = r$curve$cols[["grad"]],
      grade_withheld = r$grade_withheld,
      # the evidence and the link run the pick was scored on, so a grade can be held to its pick's evidence as well as its
      # rule (the branch review of 2026-10-25)
      evidence_md5 = evidence_md5, run_uid = run_uid,
      # the candidate run and the evidence ledger it read (#111): a promoted table names the log that graded it and the
      # build it was scored on, so its readers take them rather than the newest on disk
      tune_run = if (dev) NA_character_ else run, evidence_ledger = ledger_path,
      # the directory those tables were read from (#120); the summary only, since a grade record must keep its columns
      evidence_dir = .knw_path_rel(evidence_dir),
      curve_dist_in_model = r$curve$dist_in_model,
      curve_edf = paste(sprintf("%s=%.2f", names(r$curve$edf), r$curve$edf), collapse = "; "),
      # NA under DEV=1 and on the sensitivity, which run the main seed alone
      honest_dev_rec = if (main_only) NA_real_ else sum(r$score$honest$dev_rec),
      honest_dev_default = if (main_only) NA_real_ else sum(r$score$honest$dev_default),
      honest_dev_null = if (main_only) NA_real_ else sum(r$score$honest$dev_null),
      seeds_same_rec = if (main_only) NA_integer_ else sum(r$score$seeds$recommended == r$pick$rule),
      seeds_default_in_region = if (main_only) NA_integer_ else sum(r$score$seeds$default_in_region),
      seeds_rec_in_region = if (main_only) NA_integer_ else sum(r$score$seeds$main_rec_in_region),
      seeds_n = if (main_only) 0L else nrow(r$score$seeds),
      boot_rec_share = if (main_only) NA_real_ else rules$boot_rec_share[rules$recommended])
    row <- bind_cols(row, select(anc, -c(rule_recommended, rule_best, rule_recommended_flow)))
    say("%s: %s. %d visits (%d detections) in %d groups (%d both). Recommended %s; default %s the region (+%.1f, SE %.1f). Curve held-out %.1f vs grid best %.1f.",
        k, r$status, row$visits_in, row$detections, row$groups, row$groups_both, r$pick$rule,
        if (dflt$in_region) "in" else "outside", dflt$ddev_best, dflt$se_diff, r$curve$heldout, best$dev_heldout)
    say("%s: no rule scores %.1f held-out on the grid's %d visits and %.1f on the curve's %d; the curve %.1f, so grades are %s.",
        k, r$null_heldout, r$score$population[["visits_modelled"]], r$null_heldout_curve, nrow(r$curve$data), r$curve$heldout,
        if (isTRUE(r$grade_withheld)) "withheld" else "published")
    if (isTRUE(r$grade_withheld)) {
      say("%s: grades withheld: the curve's held-out %.1f is no better than no rule's %.1f on the curve's own visits.", k,
          r$curve$heldout, r$null_heldout_curve)
    }
    say("%s: from the flow start %s (%s SE: %s); from the width start at %s SE %s; link's default_tuned rule %s %s.",
        k, row$rule_recommended_flow, se_strict, row$rule_recommended_flow_196, se_strict, row$rule_recommended_196,
        row$rule_link_tuned, if (nrow(ltn)) sprintf("%s the region (+%.1f, SE %.1f)", if (ltn$in_region) "in" else "outside", ltn$ddev_best, ltn$se_diff) else "(none)")
    block(paste(k, "region"), rules |> filter(in_region) |> arrange(ddev_best) |>
            select(rule, departures, ddev_best, se_diff, n_wsg_varies, n_in, n_detect_in, raw_rate_in, raw_rate_out, any_of("boot_region_share")))
    if (!main_only) {
      block(paste(k, "nested selection"), r$score$honest)
      block(paste(k, "more seeds"), r$score$seeds)
    }
  } else {
    say("%s: %s (%s).", k, r$status, paste(names(r$population), r$population, sep = "=", collapse = ", "))
  }
  summ[[k]] <- row
}
summ <- bind_rows(summ)
# per species x stage, so runs on several hosts over different species merge by file (0325 and 0330 bind them)
for (k in names(out)) {
  write_csv(summ |> filter(species_code == out[[k]]$species_code, stage == out[[k]]$stage) |>
              mutate(across(where(is.numeric), ~ round(.x, 4))), file.path(dir_out, paste0(k, "_summary.csv")), na = "")
  out[[k]]$evidence_md5 <- evidence_md5
  out[[k]]$run_uid <- run_uid
  saveRDS(out[[k]][intersect(c("species_code", "stage", "response", "status", "pick", "curve", "null_heldout", "null_heldout_curve", "grade_withheld",
                               "evidence_md5", "run_uid"),
                             names(out[[k]]))], file.path(dir_out, paste0(k, "_curve.rds")))
}

# ---- the pick report (#111): the run's pick beside the published one, per key ------------------------------
# what a DEV=1 run after a change upstream is for, and what a candidate is promoted on: the published side is the
# tracked table dir_out stands in for (data/tune, or data/tune/grad_fwa for the sensitivity), never another run's
dir_pub <- if (nzchar(grad_dirs[[gradient]]) && !setup) file.path("data/tune", grad_dirs[[gradient]]) else "data/tune"
pr <- bind_rows(lapply(names(out), function(k) {
  r <- out[[k]]
  if (is.null(r$score)) return(NULL)
  f <- file.path(dir_pub, paste0(k, "_tune.csv"))
  pub <- if (file.exists(f)) read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c")) else NULL
  tibble(key = k, species_code = r$species_code, stage = r$stage, status = r$status,
         knw_tune_pick_report(r$score$rules, pub),
         # the run's anchoring (#141); its default pick is rule_run
         select(knw_tune_anchor(r$score$rules, d_floor = d_floor_of(r$score)), -rule_recommended))
}))
if (nrow(pr)) {
  write_csv(pr |> mutate(across(where(is.double), ~ round(.x, 4))), file.path(dir_out, "pick_report.csv"), na = "")
  moved <- pr$key[pr$same_pick %in% FALSE]
  say("Pick report against %s: %d of %d keys keep the published pick%s; written to %s.", dir_pub,
      sum(pr$same_pick %in% TRUE), nrow(pr),
      if (length(moved)) sprintf(" (moved: %s)", paste(moved, collapse = ", ")) else "", file.path(dir_out, "pick_report.csv"))
  block("pick report", pr |> select(key, rule_run, rule_published, same_pick, published_in_region, published_ddev,
                                    published_se, published_ddev_was, n_visits_run, n_visits_published))
  block("anchoring (#141)", pr |> select(key, rule_run, recommended_ddev, recommended_se, rec_moved, rec_moved_allowed,
                                         rule_recommended_flow, flow_moved, flow_moved_allowed, starts_apart, rule_best,
                                         best_is_allowed))
}

# ---- grade every segment of each fitted species' groups ----------------------------------
if (main_only) {
  say("%s: no grades. Done in %.1f min.", if (dev) "DEV=1" else paste("GRADIENT", gradient), as.numeric(difftime(Sys.time(), t0, units = "mins")))
  writeLines(log_lines, path_log)
  quit(save = "no", status = 0)
}
conn <- pg()
groups_sp <- function(sp) dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_%s ORDER BY 1", schema, tolower(sp)))$w
# the flow build the grade reads (#72): wet can reload discharge.fwa_v1_segment_monthly between runs (wet#103 did on
# 2026-10-19, after #57 tuned), so the table's comment, which names the build, goes into every grade table and 0325
# refuses to publish a grade whose build is not the live one
discharge_load <- knw_discharge_load(conn)
# the walk's code (#87): the walk cache keys every row on it, and a grade walked by other code is regraded
walk_md5 <- knw_walk_md5()
say("Grading on the flow build: %s; walk %s, cached in knw.walk_cache.", discharge_load, walk_md5)
# each grade table's record (#119): its constant columns, md5 and size beside the run, the evidence ledger, this commit
# and link's build, tracked, so the bundles pin it rather than the table and the archive restores the table against it.
# The commit (knowledge_commit) is read at the run's start
# a setup's grades read another gradient than the build's own (#120): its records carry the setup's grad token, so the
# archive files it under the setup it is (tune/<key>/<cut>.<acc>.grad-parent.<flow>/), on a build that names its own
tokens_rec <- rec$tokens
if (setup) tokens_rec[["grad"]] <- setup_tokens[[gradient]]   # the build's own grad-seg, checked at connect
write_record <- function(gpath, rows) {
  knw_grade_record_write(gpath, tune_run = run, evidence_ledger = ledger_path, knowledge_commit = knowledge_commit,
                         link = c(version = led$note[led$step == "run_link_version"], sha = link_sha),
                         tokens = tokens_rec, rows = rows)
}
# and its receipt (#154), written after the record and read from it: how the table was made (this commit, the run's
# settings and fold seed, link's build, the flow load, the evidence) and what came out (the pick, the rows, graded
# km and grade sum of the table as written), with no host
write_receipt <- function(gpath, grades, r) {
  knw_grade_receipt_write(gpath, grades, spec = r$score$spec, min_wsg = min_wsg, evidence_dir = evidence_dir,
                          knowledge = knowledge_git)
}
grade_rows <- list()
for (k in names(out)) {
  r <- out[[k]]
  if (is.null(r$curve)) next
  gpath <- file.path(dir_out, paste0(k, "_grades.csv"))
  ref_edge_curve <- if (!is.null(r$curve$edge_stream)) r$curve$edge_stream else eval(formals(knw_tune_run)$edge_stream)
  ref_edge_txt <- paste(ref_edge_curve, collapse = ";")
  # the curve's prior on its data-set and era terms (#73, Phase 7): a curve refit with another prior grades differently
  curve_prior_txt <- format(if (is.null(r$curve$prior_sd)) Inf else r$curve$prior_sd)
  # a withheld key is still walked and written: 0330 reads its sizes and distances to apply the rule. The gate's own
  # number is written beside the verdict (the branch review of 2026-10-25): a table graded before the gate compared no
  # rule on the curve's own visits has no null_heldout_curve, and 0325 and 0330 refuse it rather than publish a
  # verdict the code no longer makes
  withheld_txt <- format(isTRUE(r$grade_withheld))
  nhc_txt <- format(round(r$null_heldout_curve, 4), nsmall = 4)
  if (file.exists(gpath)) {
    # kept only when it was graded under this pick on this link run and this flow build, with every graded segment
    # walked to the bank (#73), and the reference taken over the curve's own edge types (#72): the table records all
    # of it from the call that made it, and a table that predates the record (#57, #65) is regraded
    head1 <- readr::read_csv(gpath, n_max = 1, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
    same <- identical(head1$rule, r$pick$rule) && identical(head1$run_uid, run_uid) &&
      "walk" %in% names(head1) && identical(head1$walk, "bank") &&
      "walk_md5" %in% names(head1) && identical(head1$walk_md5, walk_md5) &&
      "ref_edge" %in% names(head1) && identical(head1$ref_edge, ref_edge_txt) &&
      "discharge_load" %in% names(head1) && identical(head1$discharge_load, discharge_load) &&
      "curve_prior_sd" %in% names(head1) && identical(head1$curve_prior_sd, curve_prior_txt) &&
      "grade_withheld" %in% names(head1) && identical(head1$grade_withheld, withheld_txt) &&
      "null_heldout_curve" %in% names(head1) &&
      "evidence_md5" %in% names(head1) && identical(head1$evidence_md5, evidence_md5) &&
      # graded from a curve fitted on the gradient the segments carry (#92); a table from before the record was not
      .knw_grade_grad_ok(head1, r$curve$cols[["grad"]])
    # its record (#119) and its receipt (#154) describe it, or it is regraded, so a record, a receipt and their table
    # are never two passes'. A receipt names the record's md5; a kept table with none, or one naming another table
    # (written before receipts, or a pass that stopped between its record and its receipt), is regraded rather than
    # given one now: the receipt records the run's settings, seed and code, which the table does not, so they cannot
    # be recovered after the pass that graded it (the branch review of #154, round 2)
    grec <- .knw_grade_record_path(gpath)
    grec_ok <- file.exists(grec) &&
      isTRUE(tryCatch(knw_grade_record_check(knw_grade_record_read(grec), gpath), error = function(e) FALSE))
    grcp <- file.path(dir_out, .knw_grade_receipt_name(gpath))
    grcp_ok <- grec_ok && file.exists(grcp) && identical(
      tryCatch(crate::crt_receipt_read(grcp)$context$run$grades_md5, error = function(e) NULL),
      knw_grade_record_read(grec)$grades_md5)
    if (same && !grec_ok) say("%s: the grade table has no record, or one that describes another table; regraded.", k)
    if (same && grec_ok && !grcp_ok) say("%s: the grade table has no receipt naming its record; regraded.", k)
    if (same && grcp_ok) {
      # not "<key> grades: <n> groups", the result line data-raw/vignette_chinook.R reads
      say("%s: grades already written under %s on %s, kept.", k, r$pick$rule, run_uid)
      next
    }
    # not "<key> grades:", which data-raw/vignette_chinook.R reads as the one result line
    say("%s: grades on file for %s / %s (walk %s %s, reference over %s, flows %s, curve prior %s), regraded for %s / %s.",
        k, head1$rule,
        head1$run_uid, if ("walk" %in% names(head1)) head1$walk else "centreline",
        if ("walk_md5" %in% names(head1)) head1$walk_md5 else "unrecorded",
        if ("ref_edge" %in% names(head1)) head1$ref_edge else if ("ref_population" %in% names(head1)) head1$ref_population else "every accessible segment",
        if ("discharge_load" %in% names(head1)) head1$discharge_load else "unrecorded",
        if ("curve_prior_sd" %in% names(head1)) head1$curve_prior_sd else "none recorded", r$pick$rule, run_uid)
  }
  wsg <- groups_sp(r$species_code)
  t1 <- Sys.time()
  g <- knw_grade_species(pg, schema, r$species_code, wsg, r$curve, r$pick, stage = r$stage, workers = min(workers, 8L))
  if (!identical(as.integer(g$ref_edge), as.integer(ref_edge_curve))) stop(k, ": the grade's reference edge types are not the curve's")
  if (!identical(g$walk_md5, walk_md5)) stop(k, ": the grade was walked by another walk than this run's")
  if (isTRUE(r$grade_withheld)) g$grades <- g$grades |> mutate(rate = NA_real_, grade = NA_real_, grade_class = NA_character_)
  # ref_population is kept as the name 0325, 0330 and the article read; ref_edge, q_walk, walk and discharge_load
  # are the record (#72), written from what knw_grade_species() returns, not from a literal beside the call
  # written whole (a sibling renamed into place): a pass killed mid-write leaves no grade table that reads as one
  # the frame as written, built once: the receipt's summaries describe the table on disk, rounding included
  g_written <- g$grades |> mutate(species_code = r$species_code, stage = r$stage, rule = r$pick$rule, run_uid = run_uid,
                               ref_population = "stream_branch", ref_edge = paste(g$ref_edge, collapse = ";"),
                               q_walk = g$q, walk = g$walk, walk_md5 = g$walk_md5, discharge_load = discharge_load,
                               curve_prior_sd = curve_prior_txt, grade_withheld = withheld_txt, null_heldout_curve = nhc_txt,
                               evidence_md5 = evidence_md5, curve_grad = r$curve$cols[["grad"]],
                               across(c(rate, grade), ~ signif(.x, 5)))
  # an earlier pass's receipt goes first, so a pass that stops before writing its own leaves none rather than a stale one
  unlink(file.path(dir_out, .knw_grade_receipt_name(gpath)))
  .knw_write_whole(file.path(dir_out, paste0(k, "_grades.csv")), function(p) write_csv(g_written, p, na = ""))
  write_record(gpath, rows = nrow(g$grades))
  write_receipt(gpath, g_written, r)
  say("%s grades: %d groups, %s; reference rate %.4f over edge types %s; walks to %g m3/s, to the bank, %.1f min; %d of %d found rivers lie in another group; total %.1f min.",
      k, length(wsg), paste(names(g$counts), g$counts, sep = "=", collapse = ", "), g$reference,
      paste(g$ref_edge, collapse = ","), g$q, g$walk_minutes, sum(g$grades$target_in_group %in% FALSE),
      sum(!is.na(g$grades$target_in_group)), as.numeric(difftime(Sys.time(), t1, units = "mins")))
  grade_rows[[k]] <- tibble(key = k, groups = length(wsg), reference_rate = g$reference, ref_edge = paste(g$ref_edge, collapse = ";"),
                            q_walk = g$q, target_other_group = sum(g$grades$target_in_group %in% FALSE), as_tibble(as.list(g$counts)))
  # the log so far, after every key: a pass that dies later still says which grades it made (#111)
  writeLines(log_lines, path_log)
}
dbDisconnect(conn)
block("grades", bind_rows(grade_rows))
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
