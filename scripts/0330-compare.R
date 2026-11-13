# scripts/0330-compare.R
# ---------------------------------------------------------------------------
# What a tuning changes on the ground: for each fitted species x stage, link's `default` against the
# recommended rule on link's own segments in every group the species has a habitat table in (km kept,
# lost and gained; graded km; km by grade class; change by reason), under the reported structure (every structure on
# STRUCTURES=all; #73, #112), with
# one GeoPackage per species x stage for QGIS when asked (GPKG=TRUE or STAGE=gpkg; #81, #173); and, as its own step
# (STAGE=floodplain), floodplain hectares beside each rule's habitat in the groups the floodplain catalog holds. Issue
# #57, phase 4; #73 for the structures and the baseline; #81 and #173 for the split. Successor to 0298 (frozen on v2).
# Input from 0310 and 0320.
#
# WHY / DESIGN NOTES:
#   - BOTH RULES REGENERATED THE SAME WAY (0298): fresh's predicate behind stored access, link's
#     user-habitat overlay, fresh's connectivity pass, on scratch copies; both stages together.
#     knw_compare_rules() carries the method.
#   - ON THE RUN'S GRADIENT (#120): the scratch copies read the gradient the run's curves were fitted on, link's segment
#     gradient for a main run, or a setup's (0320 SETUP=1: the minimal parent's or the Atlas segment's), so `default`
#     and the tuned rule are both drawn as a build reading that gradient would draw them. Its stored-against-default
#     residue is then the gradient's doing, not a regression; a setup's comparison is never promoted.
#   - THE BASELINE IS LINK'S CURRENT `default` (#73): the configs are read at CONFIG_SHA (default: LINK_REPO's
#     origin/main, as fetched), not at the run's commit, because that is the rule link draws now; the schema's
#     run and its link_sha stay the provenance of the segments and access. Since link 0.67.0 a rule can carry a
#     near-river pair, which knw_compare_rules() walks on the scratch copy with fresh's own walk.
#   - THREE STRUCTURES (#73, link#364): the tuned rule's through-wetland lines free (link before 0.67.0),
#     through the door with the pair everywhere (link's `both`), or through the door with the pair on them
#     only (link's `wetland_flow`); knw_compare_rules() picks which a species can run. `tuned` in the tables and
#     the segments is the `door` structure (TUNED_AS=), the one the GeoPackages and the article read.
#   - THE REPORTED STRUCTURE ALONE BY DEFAULT (#112): every structure is one more rule regenerated on every group, and
#     nothing published reads any but TUNED_AS, so a run compares `default` and TUNED_AS; STRUCTURES=all adds the
#     species' other structures (`free`, `door_wetland`), which the research files' structure figures came from (#92).
#   - NO MAPS, AND GEOPACKAGES ONLY WHEN ASKED (#81, Al 2026-10-20; #173, 2026-11-12): comparisons are viewed in QGIS
#     from the GeoPackages (data/compare/gpkg/, ignored), which a run writes only with GPKG=TRUE, because retunes
#     iterate and the GeoPackages are wanted once per settled result (196.9 min on #92's run from the remote link).
#     STAGE=gpkg writes them alone, from a candidate's saved segments or, with TUNE_DIR=data/tune, the promoted run's.
#     The floodplain table is STAGE=floodplain. The few maps a reader sees are drawn by data-raw/readme_figure.R and
#     the chinook article, not here.
#   - FLOODPLAIN AS A UNIT OF MEASURE: the catalog's whole-network floodplain (`<wsg>_all_ff04`) is a
#     fixed input, nothing here models it; knw_floodplain_ha() joins it to the segments by position
#     (one owner per cell) and reports hectares and graded hectares under each rule. Only the groups
#     the catalog holds (23 at 2026-10-17) until whole-network floodplains are published for all
#     (NewGraphEnvironment/floodplains#123).
#   - KEYS IN TURN, GROUPS IN PARALLEL (#87): one species x stage at a time, its groups split across WORKERS
#     socket workers (knw_compare_rules(workers =)), each with its own connection and scratch schema, so one key
#     uses as many database cores as there are workers (one key per worker held BT rearing to one core for two
#     hours). WORKERS is therefore database cores: 6 on the database's host. The GeoPackages, when asked, are written
#     after every key, in parallel across keys, from the saved segments.
#
# INPUT:  TUNE_DIR/<sp>_<stage>_{curve.rds,grades.csv} (0320's candidate run),
#         EVIDENCE_DIR/{visits_link,visits_species,walks}.csv (0310; default the directory the run's summaries name, else
#         data/fdis/derived; any directory, a staged copy included, refused unless its md5s are the curves' evidence_md5,
#         #120), the link repository at LINK_REPO at the build's link_sha, the stac_floodplains_bc catalog
#         (items read from its public bucket), fwapg database (PG* env vars): the run's schema (SCHEMA, default
#         fresh_default), bcfishobs, whse_basemapping
# WRITES: schemas knw_cmp_<sp>_<stage> and knw_cmp_<sp>_<stage>_w<i> in the fwapg database (scratch; dropped)
# OUTPUT: every file below is written under data/compare/candidate/<run>/ (ignored; #111), which scripts/0335-promote.R
#         copies into data/compare/; the names are the tracked ones it becomes:
#         data/compare/<key>_{compare,change,checks}.csv, <key>_segments.rds  per job, as it finishes (rds ignored)
#         data/compare/gpkg/<key>.gpkg  GPKG=TRUE: every segment's verdict under each rule and structure, its class
#                                       (rule_class), grade, size, distance, the default branch it lies on, and the
#                                       waterbody it runs through with its area (water, water_ha); a `run` table names
#                                       the run (ignored)
#         data/compare/compare.csv     per species x stage x structure x group and total: km by rule, graded km, km by class
#         data/compare/change.csv      km gained and lost by structure, reason and stream order
#         data/compare/checks.csv      FDIS detection on each rule's segments; the bcfishobs lift, per structure
#         <date>_compare-<run>.txt (the log, in the run directory; promoted to scripts/logs/habitat/)
#         STAGE=floodplain: data/compare/floodplain.csv  per species x stage x catalog group: ha, graded ha, ha by
#                     class, with the run, the baseline's link commit and the tuned rule each row was drawn under
# RUN:    TUNE_DIR=data/tune/candidate/<run> Rscript scripts/0330-compare.R   (from the repo root; SPECIES=CH,BT to restrict, and the combined tables then
#         compose with the other species' saved per-key tables; WORKERS=6 database cores; CONFIG_SHA=<link
#         commit> for the configs (default origin/main of LINK_REPO); TUNED_AS=door; STRUCTURES=all for every structure
#         a species has (default: TUNED_AS alone); GPKG=TRUE writes the GeoPackages too (default off; FALSE accepted);
#         STAGE=floodplain draws the floodplain table from the tables the last full run saved; STAGE=gpkg writes the
#         GeoPackages alone from the segments it saved, or with TUNE_DIR=data/tune from the promoted run's, into
#         data/compare/gpkg/; STAGE=maps is gone and says so). Every STAGE checks the database's round trip at connect
#         and stops off its host (over 20 ms) unless REMOTE=TRUE (#110). Each key's log lines give its stages' minutes
#         (#110) and, under classify, overlay and connect, the worker-minutes of each rule beside the copies and walks
#         the rules share (#112), which rules' predicates read the near-river table, and the projected saving of
#         reading default's flags rather than making them (#101; `bin_minutes` in ?knw_compare_rules says how).
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

link_repo <- Sys.getenv("LINK_REPO", "../link")
workers <- as.integer(Sys.getenv("WORKERS", "6"))
only <- Sys.getenv("SPECIES", "")
stage_only <- Sys.getenv("STAGE", "")
tuned_as <- Sys.getenv("TUNED_AS", "door")
structures <- Sys.getenv("STRUCTURES", "reported")   # "all": every structure the species has, not TUNED_AS alone (#112)
gpkg <- .knw_env_flag("GPKG")
remote <- Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")   # compare off the database's host anyway (#110)
if (identical(stage_only, "maps")) {
  stop("STAGE=maps is gone (#173): STAGE=floodplain writes the floodplain table, STAGE=gpkg the GeoPackages for QGIS, ",
       "and data-raw/readme_figure.R and the chinook article draw the example maps")
}
if (!stage_only %in% c("", "floodplain", "gpkg")) {
  stop("STAGE must be unset, 'floodplain' or 'gpkg', not '", stage_only, "'")
}
if (!structures %in% c("", "reported", "all")) stop("STRUCTURES must be unset, 'reported' or 'all', not '", structures, "'")
# the GeoPackages' QGIS styles, built before any work: a gq without the QML writer (gq#115) found only after every
# key's comparison stopped the run after its tables were cleared, with nothing written (#173's review, round 1)
gpkg_styles <- if (gpkg || identical(stage_only, "gpkg")) .compare_qgis_styles() else NULL
schema <- Sys.getenv("SCHEMA", "fresh_default")  # the run's persist schema, by its current name (renamed after the run, #73)
catalog_bucket <- "https://stac-floodplains-bc.s3.us-west-2.amazonaws.com"
catalog_items <- "../stac_floodplains_bc/data/stac"      # the catalog repo's item records
# a comparison is of a candidate run (#111): TUNE_DIR=data/tune/candidate/<run> is read, and everything is written under
# data/compare/candidate/<run>/ (ignored), figures and log included; scripts/0335-promote.R copies it into the tracked
# data/compare/ and research/fig/ on the operator's word. The floodplain catalog is a cache shared by every run
tune_dir <- sub("/+$", "", Sys.getenv("TUNE_DIR"))
# STAGE=gpkg also takes the promoted run (TUNE_DIR=data/tune, #173): with GPKG off by default, that is how the published
# comparison reaches QGIS without a promotion. It reads data/compare/<key>_segments.rds and writes only into the ignored
# data/compare/gpkg/, its log beside the GeoPackages; nothing tracked is written
promoted <- identical(stage_only, "gpkg") && identical(tune_dir, "data/tune")
if (!promoted && (!grepl("^data/tune/candidate/[A-Za-z0-9][A-Za-z0-9_.]*$", tune_dir) || !dir.exists(tune_dir))) {
  stop("TUNE_DIR must name a candidate run of scripts/0320, data/tune/candidate/<run> (relative, from the repo root), ",
       "or data/tune for STAGE=gpkg on the promoted run: '", tune_dir, "'")
}
if (promoted) {
  # the promoted run's name is the tuning run its summaries record
  run <- unique(unlist(lapply(list.files(tune_dir, "_summary\\.csv$", full.names = TRUE), function(f) {
    x <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
    if ("tune_run" %in% names(x)) stats::na.omit(x$tune_run) else character()
  })))
  if (length(run) != 1L) {
    stop("data/tune's summaries name ", length(run), " tuning runs (", paste(run, collapse = ", "), "), not one")
  }
  dir_out <- "data/compare"
} else {
  run <- basename(tune_dir)
  dir_out <- file.path("data/compare/candidate", run)
}
dir_gpkg <- file.path(dir_out, "gpkg")
dir_cat <- "data/compare/catalog"
# a pass over some species names them, and a second pass of the day is numbered: a log is never written over
path_log <- .knw_free_path(file.path(if (promoted) dir_gpkg else dir_out,
                                     paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_compare-", run,
                                            if (nzchar(only)) paste0("-", tolower(gsub(",", "_", only))),
                                            if (nzchar(stage_only)) paste0("-", stage_only), ".txt")))
for (d in c(dir_out, dir_cat, dir_gpkg)) dir.create(d, showWarnings = FALSE, recursive = TRUE)
# the run's floodplain table holds every key a drawing has reached: `drop` takes the given keys' rows out and `new`
# (a drawing's rows) goes in, written to a sibling and moved over, so a pass never leaves half a table (#111)
floodplain_write <- function(new, drop) {
  f <- file.path(dir_out, "floodplain.csv")
  old <- NULL
  if (file.exists(f)) old <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"), na = character())
  if (!is.null(old)) old <- old[!paste(old$species_code, old$stage, sep = "_") %in% drop, , drop = FALSE]
  if (!is.null(new)) new <- mutate(new, across(everything(), ~ ifelse(is.na(.x), "", as.character(.x))))
  out <- bind_rows(old, new)
  if (!nrow(out) && is.null(new)) { unlink(f); return(invisible()) }
  if (!is.null(new)) out <- out[, names(new)]
  out <- mutate(out, across(everything(), ~ na_if(.x, "")))
  .knw_write_whole(f, function(p) write_csv(out, p, na = ""))
}
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}

# ---- inputs -----------------------------------------------------------------------------
ledger_path <- knw_run_ledger(tune_dir)   # the candidate's build, not the newest on disk (#111)
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]][1]
cf <- list.files(tune_dir, "_curve\\.rds$", full.names = TRUE)
curves <- setNames(lapply(cf, readRDS), sub("_curve\\.rds$", "", basename(cf)))
fitted <- Filter(function(r) !is.null(r$pick) && !is.null(r$curve), curves)
if (nzchar(only)) fitted <- fitted[vapply(fitted, function(r) r$species_code %in% strsplit(only, ",")[[1]], logical(1))]
say("Comparison, knowledge#57: %d fitted species x stage; link run %s at %s.", length(fitted), run_uid, link_sha)
# the gradient the run's curves were fitted on, which the segments are compared on (#120): link's segment gradient for a
# main run, or a setup's (0320 SETUP=1: the minimal parent's, the Atlas segment's), read by every rule and stage alike
run_grad <- unique(vapply(fitted, function(r) {
  g <- if (is.null(r$curve$cols)) NA_character_ else r$curve$cols[["grad"]]
  if (is.null(g)) NA_character_ else g
}, character(1)))
if (length(fitted) && (length(run_grad) != 1L || !run_grad %in% names(.knw_grade_grads))) {
  stop(tune_dir, "'s curves were fitted on ", paste(run_grad, collapse = ", "), ": one of ",
       paste(names(.knw_grade_grads), collapse = ", "), " per run")
}
if (!length(fitted)) run_grad <- .knw_grade_grad
say("Segments read with the gradient the curves were fitted on: %s (%s)%s.", run_grad, .knw_grade_grads[[run_grad]],
    if (!identical(run_grad, .knw_grade_grad)) "; a setup of #120, never promoted" else "")
if (promoted) {
  say("Promoted run %s: read from %s and %s, GeoPackages written to %s (ignored).", run, tune_dir, dir_out, dir_gpkg)
} else {
  say("Candidate run %s: read from %s, written under %s (ignored); promote it with RUN=%s scripts/0335.", run, tune_dir, dir_out, run)
}
# the build the run was scored on (#120): EVIDENCE_DIR (a staged copy on another machine), else the directory the run's
# summaries name (0320 writes it from #120), else the default. Its tables must be the ones the curves were fitted on,
# held by md5, not by path: a directory of the same name can hold another build, and a staged copy elsewhere the right one
sum_dirs <- unique(stats::na.omit(unlist(lapply(list.files(tune_dir, "_summary\\.csv$", full.names = TRUE), function(f) {
  x <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
  if ("evidence_dir" %in% names(x)) x$evidence_dir else NA_character_
}))))
if (length(sum_dirs) > 1) stop(tune_dir, "'s summaries name ", length(sum_dirs), " evidence directories: ", paste(sum_dirs, collapse = ", "))
evidence_dir <- Sys.getenv("EVIDENCE_DIR", if (length(sum_dirs)) sum_dirs else .knw_evidence_dir_default)
ev_md5 <- paste(unname(tools::md5sum(file.path(evidence_dir, paste0(c("visits_link", "visits_species", "walks"), ".csv")))),
                collapse = ";")
fit_md5 <- unique(vapply(fitted, function(r) if (is.null(r$evidence_md5)) NA_character_ else r$evidence_md5, character(1)))
if (length(fitted) && !identical(fit_md5, ev_md5)) {
  stop(evidence_dir, "'s tables (md5 ", ev_md5, ") are not the evidence the curves were fitted on (",
       paste(fit_md5, collapse = ", "), "): set EVIDENCE_DIR to a directory holding that build's tables")
}
say("Evidence %s (%s), the curves' own%s.", .knw_path_rel(evidence_dir), ledger_path,
    if (length(sum_dirs) && !identical(.knw_path_key(evidence_dir), .knw_path_key(sum_dirs)))
      sprintf(", staged: the summaries name %s", sum_dirs) else "")
vl <- read_csv(file.path(evidence_dir, "visits_link.csv"), show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv(file.path(evidence_dir, "visits_species.csv"), show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))

# link's configs: the baseline is link's current default (CONFIG_SHA, default origin/main as fetched), not the
# run's commit, which stays the provenance of the schema (#73)
# resolved to the full commit, so the tables record one spelling whether CONFIG_SHA was given short, long or not at
# all (a short one was recorded as given, and the composed-table check compares the strings)
config_ref <- Sys.getenv("CONFIG_SHA")
if (!nzchar(config_ref)) config_ref <- "origin/main"
config_sha <- suppressWarnings(system2("git", c("-C", link_repo, "rev-parse", "--verify", paste0(config_ref, "^{commit}")),
                                       stdout = TRUE, stderr = TRUE))
if (!is.null(attr(config_sha, "status")) || length(config_sha) != 1 || !grepl("^[0-9a-f]{40}$", config_sha)) {
  stop("could not resolve ", config_ref, " to a commit in ", link_repo, "; set CONFIG_SHA")
}
link_dir <- file.path(tempdir(), paste0("link_default_", substr(config_sha, 1, 7)))
dir.create(file.path(link_dir, "overrides"), showWarnings = FALSE, recursive = TRUE)
for (p in c("parameters_habitat_thresholds.csv", "rules.yaml", "parameters_fresh.csv", "parameters_habitat_method.csv",
            "dimensions.csv", "overrides/user_habitat_classification.csv")) {
  out <- file.path(link_dir, p)
  st <- system2("git", c("-C", link_repo, "show", paste0(config_sha, ":inst/extdata/configs/default/", p)), stdout = out)
  if (!identical(st, 0L) || !file.exists(out) || file.size(out) == 0) stop("could not read ", p, " at link ", config_sha, " from ", link_repo)
}
if (!file.exists(file.path(link_dir, "parameters_habitat_thresholds.csv")) ||
      !any(grepl("rear_river_distance_max", readLines(file.path(link_dir, "parameters_habitat_thresholds.csv"), n = 1)))) {
  stop("link's thresholds at ", config_sha, " carry no near-river columns: the baseline needs link >= 0.67.0 (#73)")
}
say("link configs/default at %s (the baseline; the schema %s's run is at %s) read from %s; fresh %s; tuned reported as %s; %s.",
    config_sha, schema, link_sha, link_repo, as.character(packageVersion("fresh")), tuned_as,
    if (structures == "all") "every structure a species has (STRUCTURES=all)" else "compared under it alone")

# the catalog's groups
items <- list.files(catalog_items, "_all_ff04\\.json$", full.names = TRUE)
cat_wsg <- toupper(sub("_all_ff04\\.json$", "", basename(items)))
say("Floodplain catalog: %d whole-network groups (%s).", length(cat_wsg), paste(cat_wsg, collapse = " "))
gpkg_of <- function(w) {
  f <- file.path(dir_cat, paste0(tolower(w), "_floodplain.gpkg"))
  # an empty file is a download that died (a timeout raises before the status is read and leaves one behind,
  # which every later call would take as a cache hit): fetch to a sibling and move it in only on 200
  if (file.exists(f) && file.size(f) == 0) unlink(f)
  if (!file.exists(f)) {
    part <- paste0(f, ".part")
    on.exit(unlink(part), add = TRUE)
    h <- curl::curl_fetch_disk(sprintf("%s/%s_all_ff04/floodplain.gpkg", catalog_bucket, tolower(w)), part,
                               handle = curl::new_handle(timeout = 600, followlocation = TRUE))
    if (h$status_code != 200) stop("catalog item ", w, ": HTTP ", h$status_code)
    if (!file.rename(part, f)) stop("could not move the download of ", w, " into place")
  }
  f
}

# ---- compare, per species x stage (species in parallel) ------------------------------------
conn <- pg()
# the comparison is bound by the database: refuse a connection off its host unless REMOTE=TRUE, at every STAGE (#110).
# A refused run's log is <date>_compare_refused-<run>…txt in the run's directory, so it does not overwrite the run's log
lat <- tryCatch(knw_db_latency_check(conn, remote = remote), error = function(e) {
  say("%s", conditionMessage(e))
  path_refused <- .knw_free_path(sub("_compare-", "_compare_refused-", path_log, fixed = TRUE))
  writeLines(log_lines, path_refused)
  stop(conditionMessage(e), " (log ", path_refused, ")", call. = FALSE)
})
say("%s", lat$line)
# the database's build, checked before any work (#87): a schema built by another run than the evidence's is refused
rec <- tryCatch(knw_build_record(conn, schema, run_uid = run_uid), error = function(e) {
  say("%s", conditionMessage(e))
  writeLines(log_lines, path_log)
  stop(conditionMessage(e), call. = FALSE)
})
say("%s", rec$line)
# a setup on the parent's gradient is compared on link's parent table: the one the evidence recorded, or none (#120)
if (identical(run_grad, "parent_gradient")) {
  held <- tryCatch(.knw_parent_held(conn, schema, led), error = function(e) {
    say("%s", conditionMessage(e))
    path_refused <- .knw_free_path(sub("_compare-", "_compare_refused-", path_log, fixed = TRUE))
    writeLines(log_lines, path_refused)
    stop(conditionMessage(e), " (log ", path_refused, ")", call. = FALSE)
  })
  say("Parent table held to the evidence's: %s", held)
}
groups_sp <- function(sp) dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_%s ORDER BY 1", schema, tolower(sp)))$w
jobs <- lapply(names(fitted), function(k) {
  r <- fitted[[k]]
  list(key = k, species_code = r$species_code, stage = r$stage, pick = r$pick, groups = groups_sp(r$species_code))
})
dbDisconnect(conn)
# largest species first (a failure in the longest key shows soonest); named by key, because the results are
# filtered to the jobs that succeeded and every later lookup goes by key, not position
jobs <- jobs[order(-vapply(jobs, function(j) length(j$groups), integer(1)))]
names(jobs) <- vapply(jobs, `[[`, character(1), "key")
# the graded km read the grade tables 0320 wrote; refuse one made before #65 (every segment walked, the reference
# over the stream branch), which would put the old grades under the new run's numbers
stale <- names(jobs)[!vapply(names(jobs), function(k) {
  h <- readr::read_csv(file.path(tune_dir, paste0(k, "_grades.csv")), n_max = 1, show_col_types = FALSE,
                       col_types = readr::cols(.default = "c"))
  "ref_population" %in% names(h) && identical(h$ref_population, "stream_branch") &&
    "walk" %in% names(h) && identical(h$walk, "bank") &&
    # walked by this tree's walk (#87)
    "walk_md5" %in% names(h) && identical(h$walk_md5, knw_walk_md5()) &&
    # graded on the flow load the database holds now (#87): a wet reload between 0320 and 0330 moves the flows the
    # regenerated flags read under grades walked on the old ones
    "discharge_load" %in% names(h) && identical(h$discharge_load, rec$discharge_load) &&
    # graded under the pick this comparison applies, on this link run and one evidence build (the branch review of
    # 2026-10-25: a 0320 that stopped between scoring and grading leaves a new pick beside an old table)
    identical(h$rule, curves[[k]]$pick$rule) && identical(h$run_uid, run_uid) &&
    "evidence_md5" %in% names(h) && identical(h$evidence_md5, curves[[k]]$evidence_md5) &&
    # graded from a curve with the prior, the withheld-grade record (#73, Phase 7) and the gate's own number (the branch
    # review of 2026-10-25: a verdict written by the gate before it compared like with like is not read back)
    all(c("curve_prior_sd", "grade_withheld", "null_heldout_curve") %in% names(h)) &&
    # graded from a curve fitted on the run's gradient, the curve this comparison reads (#92, #120)
    .knw_grade_grad_ok(h, run_grad) && identical(curves[[k]]$curve$cols[["grad"]], h$curve_grad)
}, logical(1))]
if (length(stale)) stop("grade tables made before #73's curve prior (no ref_population = stream_branch, a walk not ending at the bank, or no curve_prior_sd, grade_withheld, null_heldout_curve and evidence_md5), graded from a curve on another gradient than the run's (curve_grad, #92, #120), walked by another walk than this tree's (walk_md5, #87) or on another flow load than the database's, or graded under another pick, link run or evidence build than the curve record's; rerun 0320: ",
                        paste(stale, collapse = ", "))
# each job writes its own tables as it finishes and returns its error rather than raising it, so one failed
# species cannot discard the others (code-check round 2); the grade table is read with the six columns the
# comparison needs, not its 25 (RB's is 1.5 GB)
run_one <- function(job) {
  t0 <- Sys.time()
  # a key's comparison replaces an earlier pass's whole, its GeoPackage included (#111): what the run holds for a key
  # is then this pass's, which is what scripts/0335 promotes
  unlink(c(file.path(dir_out, paste0(job$key, c("_compare.csv", "_change.csv", "_checks.csv", "_segments.rds"))),
           file.path(dir_gpkg, paste0(job$key, ".gpkg"))))
  out <- tryCatch({
    gfile <- file.path(tune_dir, paste0(job$key, "_grades.csv"))
    gcols <- c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class")
    # target_in_group (#73) rides along where the grade table carries it; a table graded before it does not
    if ("target_in_group" %in% names(readr::read_csv(gfile, n_max = 0, show_col_types = FALSE))) gcols <- c(gcols, "target_in_group")
    grades <- readr::read_csv(gfile, show_col_types = FALSE, col_select = dplyr::all_of(gcols),
                              col_types = readr::cols(id_segment = "d", watershed_group_code = "c", size = "d", dist_m = "d",
                                                      grade = "d", grade_class = "c", target_in_group = "l"))
    m_read <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
    cmp <- knw_compare_rules(pg, schema, job$species_code, job$stage, job$pick, job$groups, link_dir, grades,
                             visits = vl, visit_species = vs, scratch = paste0("knw_cmp_", tolower(job$key)),
                             tuned_as = tuned_as, structures = if (structures == "all") NULL else "reported",
                             config_sha = config_sha, workers = workers, gradient = .knw_grade_grads[[run_grad]])
    rm(grades)
    # the key's stage lines (#110): the grade table read here first, then knw_compare_rules()'s, then the writes
    cmp$log <- c(sprintf("Grade table read: %.1f min.", m_read), cmp$log)
    t_write <- Sys.time()
    # each written whole (a sibling renamed into place), the segments first: a job killed part way leaves no table that
    # reads as complete, and no _compare.csv without the segments it summarises (#111)
    out_of <- function(what) file.path(dir_out, paste0(job$key, what))
    .knw_write_whole(out_of("_segments.rds"), function(p) saveRDS(cmp$segments, p))
    if (!is.null(cmp$checks)) {
      .knw_write_whole(out_of("_checks.csv"), function(p) readr::write_csv(cmp$checks, p, na = ""))
    }
    .knw_write_whole(out_of("_change.csv"), function(p) readr::write_csv(cmp$change, p, na = ""))
    .knw_write_whole(out_of("_compare.csv"), function(p) readr::write_csv(cmp$compare, p, na = ""))
    cmp$log <- c(cmp$log, sprintf("Writes (segments, checks, change, compare): %.1f min.",
                                  as.numeric(difftime(Sys.time(), t_write, units = "mins"))))
    # the through-wetland quantity link#364 measured, for the write-up: CH rearing on its five groups and on all
    if (job$key == "CH_rear") {
      wl <- cmp$segments |> dplyr::filter(edge_type %in% c(1050L, 1150L))
      five <- c("ADMS", "BULK", "CHWK", "CLWR", "SQAM")
      km_of <- function(col, groups_) sum(wl$length_metre[wl[[col]] %in% TRUE & wl$watershed_group_code %in% groups_]) / 1000
      cols <- grep("^rearing_(pre_)?(default|free|door|door_wetland)$", names(wl), value = TRUE)
      cmp$log <- c(cmp$log, sprintf("Through-wetland CH km (edge 1050/1150), link#364's five groups | all groups: %s.",
                                    paste(sprintf("%s %.1f | %.1f", cols, vapply(cols, km_of, numeric(1), groups_ = five),
                                                  vapply(cols, km_of, numeric(1), groups_ = unique(wl$watershed_group_code))),
                                          collapse = "; ")))
    }
    cmp$segments <- NULL
    cmp
  }, error = function(e) list(error = conditionMessage(e), compare = NULL, change = NULL, checks = NULL, log = character()))
  out$minutes <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  out$key <- job$key
  say("%s: compared in %.1f min%s.", job$key, out$minutes, if (!is.null(out$error)) " (FAILED)" else "")
  out
}
# one GeoPackage per species x stage for QGIS (#81): every segment with its verdict under each rule and structure, its
# class under the reported structure (kept, lost, gained, neither; `rule_class`, the registry's labels) and the
# waterbody it runs through with that waterbody's area (`water`, `water_ha`, #173), so a kept stretch with a low grade
# explains itself; written group by group from link's geometry and the segments the comparison saved, with a `run` table naming
# the run, so a GeoPackage left from an older run says so, and QGIS styles for the rule and grade classes in its
# layer_styles table (gq#115). Run on a socket worker per key, so the package's helpers come in as arguments
gpkg_one <- function(key, schema, dir_gpkg, dir_seg, flag, rule_labels, rule_class_fun, water_fun, run_info, styles) {
  t1 <- Sys.time()
  tryCatch({
    seg <- readRDS(file.path(dir_seg, paste0(key, "_segments.rds")))
    seg$rule_class <- rule_class_fun(seg[[paste0(flag[[key]], "_default")]], seg[[paste0(flag[[key]], "_tuned")]],
                                     rule_labels, accessible = seg$accessible)
    # a reachable segment with no grade reads "not graded", the class the maps and the GeoPackage's style give it
    seg$grade_class[is.na(seg$grade_class) & seg$accessible %in% TRUE] <- "not graded"
    # written as <key>.part.gpkg and renamed when every group is in (#111): a pass killed part way leaves a part file,
    # never a <key>.gpkg holding some groups, and the last complete one stands until then
    f <- file.path(dir_gpkg, paste0(key, ".gpkg"))
    f_part <- file.path(dir_gpkg, paste0(key, ".part.gpkg"))
    unlink(f_part)
    conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
    on.exit(DBI::dbDisconnect(conn))
    for (w in sort(unique(seg$watershed_group_code))) {
      q <- sprintf("SELECT id_segment, waterbody_key, geom FROM %s.streams WHERE watershed_group_code = '%s'",
                   schema, w)
      geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = q), drop = TRUE)
      geom$id_segment <- as.numeric(geom$id_segment)
      geom$waterbody_key <- as.numeric(geom$waterbody_key)
      wb <- water_fun(conn, schema, w)
      i <- match(geom$waterbody_key, wb$waterbody_key)
      if (any(!is.na(geom$waterbody_key) & is.na(i))) stop(w, ": a segment's waterbody is not in fwa_waterbodies")
      geom$water <- ifelse(is.na(geom$waterbody_key), "stream", wb$water[i])
      geom$water_ha <- wb$water_ha[i]
      sg <- dplyr::inner_join(geom, seg[seg$watershed_group_code == w, , drop = FALSE], by = "id_segment")
      sf::st_write(sg, f_part, layer = "segments", append = file.exists(f_part), quiet = TRUE)
    }
    sf::st_write(data.frame(run_info, key = key, written_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")),
                 f_part, layer = "run", quiet = TRUE)
    # the QGIS styles, from the registry the maps read (gq#115): rule class the default, grade class the second
    gq::gq_gpkg_style_write(f_part, "segments", styles)
    unlink(f)
    if (!file.rename(f_part, f)) stop("could not move ", f_part, " to ", f)
    sprintf("GeoPackage %s: %d segments in %.1f min.", f, nrow(seg), as.numeric(difftime(Sys.time(), t1, units = "mins")))
  }, error = function(e) {
    unlink(file.path(dir_gpkg, paste0(key, ".part.gpkg")))
    sprintf("GeoPackage for %s FAILED: %s", key, conditionMessage(e))
  })
}
# the GeoPackages of several keys, one key per socket worker (one writer per file)
write_gpkgs <- function(keys) {
  t1 <- Sys.time()
  flag <- vapply(jobs, function(j) if (j$stage == "rear") "rearing" else "spawning", character(1))
  rule_class_fun <- .knw_rule_class
  environment(rule_class_fun) <- globalenv()
  water_fun <- .knw_segment_water
  environment(water_fun) <- globalenv()
  args <- list(schema = schema, dir_gpkg = dir_gpkg, dir_seg = dir_out, flag = flag,
               rule_labels = .compare_rule_labels(),
               rule_class_fun = rule_class_fun, water_fun = water_fun,
               run_info = data.frame(tune_run = run, link_run_uid = run_uid, schema = schema, promoted = promoted),
               styles = gpkg_styles)
  gl <- if (workers > 1L && length(keys) > 1L) {
    cl <- parallel::makeCluster(min(workers, length(keys)))
    tryCatch(do.call(parallel::parLapplyLB, c(list(cl, keys, gpkg_one), args)), finally = parallel::stopCluster(cl))
  } else {
    do.call(lapply, c(list(keys, gpkg_one), args))
  }
  names(gl) <- keys
  say("GeoPackages for %d keys in %.1f min on %d workers.", length(keys),
      as.numeric(difftime(Sys.time(), t1, units = "mins")), min(workers, length(keys)))
  gl
}
t0 <- Sys.time()
if (stage_only == "floodplain") {
  # the floodplain stage alone, from the tables and segments the last full run saved per key
  res <- lapply(names(jobs), function(k) {
    f <- file.path(dir_out, paste0(k, "_compare.csv"))
    if (!file.exists(f) || !file.exists(file.path(dir_out, paste0(k, "_segments.rds")))) return(NULL)
    list(compare = read_csv(f, show_col_types = FALSE,
                            col_types = cols(watershed_group_code = "c", species_code = "c", stage = "c", structure = "c",
                                             default_rule = "c", tuned_rule = "c", tuned_structure = "c", config_sha = "c",
                                             .default = "d")))
  })
  names(res) <- names(jobs)
  res <- Filter(Negate(is.null), res)
  if (!length(res)) stop("STAGE=floodplain: no saved comparison under ", dir_out)
  # the saved segments carry the grade the full run read; one older than its grade table carries a superseded
  # grade (#65), which the guard on the grade tables above cannot see
  old <- names(res)[vapply(names(res), function(k) {
    file.mtime(file.path(dir_out, paste0(k, "_segments.rds"))) < file.mtime(file.path(tune_dir, paste0(k, "_grades.csv")))
  }, logical(1))]
  if (length(old)) stop("STAGE=floodplain: the saved segments predate their grade tables; run the full compare: ",
                        paste(old, collapse = ", "))
  say("STAGE=floodplain: floodplain hectares from the saved comparison of %s.", paste(names(res), collapse = " "))
} else if (stage_only == "gpkg") {
  # the GeoPackages alone, from the segments the last full run saved per key, refusing segments older than their
  # grade table as STAGE=floodplain does
  keys <- names(jobs)[file.exists(file.path(dir_out, paste0(names(jobs), "_segments.rds")))]
  if (!length(keys)) stop("STAGE=gpkg: no saved segments under ", dir_out)
  old <- keys[file.mtime(file.path(dir_out, paste0(keys, "_segments.rds"))) <
                file.mtime(file.path(tune_dir, paste0(keys, "_grades.csv")))]
  if (length(old)) stop("STAGE=gpkg: the saved segments predate their grade tables; run the full compare: ",
                        paste(old, collapse = ", "))
  gl <- write_gpkgs(keys)
  for (k in keys) say("  %s", gl[[k]])
} else {
  # the tables of every key are written when the pass ends, from every key it and earlier passes saved; until then the
  # run holds none, so a pass that dies cannot leave the last pass's beside this one's per-key tables (#111). The keys
  # compared here lose their floodplain rows, which STAGE=floodplain redraws; the other keys keep theirs
  unlink(file.path(dir_out, c("compare.csv", "change.csv", "checks.csv")))
  floodplain_write(NULL, drop = names(jobs))
  res <- lapply(jobs, run_one)
  if (gpkg) {
    ok <- names(jobs)[vapply(res, function(x) is.null(x$error), logical(1))]
    gl <- write_gpkgs(ok)
    for (k in ok) res[[match(k, names(jobs))]]$log <- c(res[[match(k, names(jobs))]]$log, gl[[k]])
  }
}
if (stage_only == "") {
  names(res) <- vapply(jobs, `[[`, character(1), "key")
  say("Compared %d species x stage in %.1f min, each on %d workers.", length(res), as.numeric(difftime(Sys.time(), t0, units = "mins")), workers)
  failed <- names(res)[vapply(res, function(x) !is.null(x$error), logical(1))]
  for (k in failed) say("%s FAILED after %.1f min: %s", k, res[[k]]$minutes, res[[k]]$error)
  res <- res[setdiff(names(res), failed)]
  if (!length(res)) { writeLines(log_lines, path_log); stop("every comparison job failed: ", paste(failed, collapse = ", ")) }
  for (k in names(res)) {
    tots <- res[[k]]$compare |> filter(watershed_group_code == "ALL")
    n_groups <- n_distinct(res[[k]]$compare$watershed_group_code) - 1
    say("%s: %d groups, %.1f min; default %.0f km (%s).", k, n_groups, res[[k]]$minutes, tots$default_km[1], tots$default_rule[1])
    for (i in seq_len(nrow(tots))) {
      tot <- tots[i, ]
      say("  %s%s: tuned %.0f km (%+.1f %%); graded km %.0f -> %.0f; lost %.0f, gained %.0f (%.0f by the exception, %.0f of it through a river in another group).",
          tot$structure, if (tot$structure == tot$tuned_structure) " (= tuned)" else "", tot$tuned_km, tot$change_pct,
          tot$default_graded_km, tot$tuned_graded_km, tot$lost_km, tot$gained_km, tot$gained_exception_km,
          tot$gained_exception_other_group_km)
    }
    log_lines <- c(log_lines, paste("  ", res[[k]]$log))
  }
  # the combined tables take every per-key table on disk made under this comparison, so a run restricted by
  # SPECIES composes with the species an earlier run wrote instead of replacing them (#73: CH and CO, then BT, then
  # the rest, each its own run); a saved table whose columns differ from this run's (one made before the structures)
  # is left out and named. The saved tables are read as text and given this run's column types.
  as_like <- function(x, tpl) {
    for (nm in names(tpl)) {
      if (is.numeric(tpl[[nm]])) x[[nm]] <- as.numeric(x[[nm]]) else if (is.logical(tpl[[nm]])) x[[nm]] <- as.logical(x[[nm]])
    }
    x
  }
  read_saved <- function(k, what, tpl) {
    f <- file.path(dir_out, paste0(k, "_", what, ".csv"))
    if (!file.exists(f) || is.null(tpl)) return(NULL)
    x <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
    if (!identical(names(x), names(tpl))) return(structure(list(), class = "other_comparison"))
    as_like(x, tpl)
  }
  # a key that failed this run is not read back from its saved table: that table is an older run's, and composing it
  # under a line that reads as success is how a stale comparison would publish (the branch review of 2026-10-25)
  saved <- setdiff(names(Filter(function(r) !is.null(r$pick) && !is.null(r$curve), curves)), c(names(res), failed))
  if (length(failed)) say("Not composed (failed this run; their saved tables, if any, are not read back): %s.", paste(failed, collapse = " "))
  tpl <- function(what) { for (x in res) if (!is.null(x[[what]])) return(x[[what]]); NULL }
  saved_tbl <- lapply(c(compare = "compare", change = "change", checks = "checks"), function(what) {
    out <- lapply(saved, read_saved, what = what, tpl = tpl(what))
    names(out) <- saved
    out
  })
  other <- saved[vapply(saved_tbl$compare, inherits, logical(1), "other_comparison")]
  # a saved table with this run's columns but another baseline or structure is another comparison too (the branch
  # review of 2026-10-25): composing it would put two baselines in one compare.csv, told apart only by a column
  # nothing reads
  mismatch <- vapply(saved, function(k) {
    x <- saved_tbl$compare[[k]]
    if (is.null(x) || inherits(x, "other_comparison")) return("")
    cs <- unique(x$config_sha)
    ts <- unique(x$tuned_structure)
    tr <- unique(x$tuned_rule)
    paste(c(if (!identical(cs, config_sha)) sprintf("config %s", paste(substr(cs, 1, 8), collapse = "/")),
            if (!identical(ts, tuned_as)) sprintf("tuned_as %s", paste(ts, collapse = "/")),
            if (!identical(tr, curves[[k]]$pick$rule)) sprintf("rule %s", paste(tr, collapse = "/"))), collapse = ", ")
  }, character(1))
  for (k in saved[nzchar(mismatch)]) {
    say("Left out of the combined tables (%s was saved under another %s; this run: config %s, tuned_as %s, rule %s): rerun it.",
        k, mismatch[[k]], substr(config_sha, 1, 8), tuned_as, curves[[k]]$pick$rule)
  }
  other <- union(other, saved[nzchar(mismatch)])
  composed <- setdiff(saved[!vapply(saved_tbl$compare, is.null, logical(1))], other)
  if (length(composed)) {
    say("Composed with the saved comparison of %s.", paste(composed, collapse = " "))
    for (k in composed) {
      tots <- saved_tbl$compare[[k]] |> filter(watershed_group_code == "ALL")
      for (i in seq_len(nrow(tots))) {
        say("  %s %s: default %.0f km (%s); tuned %.0f km (%+.1f %%, %s).", k, tots$structure[i], tots$default_km[i],
            tots$default_rule[i], tots$tuned_km[i], tots$change_pct[i], tots$tuned_rule[i])
      }
    }
  }
  if (length(other)) say("Left out of the combined tables (saved under another comparison; rerun them): %s.", paste(other, collapse = " "))
  keep <- function(what) c(lapply(res, `[[`, what), lapply(saved_tbl[[what]][composed], function(x) if (inherits(x, "other_comparison")) NULL else x))
  compare <- bind_rows(keep("compare"))
  change <- bind_rows(keep("change"))
  checks <- bind_rows(keep("checks"))
  # each written whole, compare.csv last: its presence says the pass composed all three (#111)
  .knw_write_whole(file.path(dir_out, "checks.csv"),
                   function(p) write_csv(checks |> mutate(across(where(is.numeric), ~ round(.x, 4))), p, na = ""))
  .knw_write_whole(file.path(dir_out, "change.csv"),
                   function(p) write_csv(change |> mutate(km = round(km, 3)), p, na = ""))
  .knw_write_whole(file.path(dir_out, "compare.csv"),
                   function(p) write_csv(compare |> mutate(across(where(is.numeric), ~ round(.x, 3))), p, na = ""))
}

# ---- floodplain hectares: their own step (STAGE=floodplain; #81, #173) --------------------------------
# each rule's habitat and graded habitat in hectares of the catalog's whole-network floodplain, per catalog group. The
# rows carry the run, the baseline's link commit and the tuned rule they were drawn under, so a row left from an older
# comparison can be told from this one's (#173: the #145 promotion kept #65's chinook rows, from a rule since replaced)
if (stage_only == "floodplain") {
  fp_rows <- list()
  for (k in names(res)) {
    r <- res[[k]]
    stage <- jobs[[k]]$stage
    flag <- if (stage == "rear") "rearing" else "spawning"
    sp <- jobs[[k]]$species_code
    seg_all <- readRDS(file.path(dir_out, paste0(k, "_segments.rds")))
    per <- r$compare |> filter(watershed_group_code != "ALL", structure == tuned_structure)
    fp_wsg <- intersect(per$watershed_group_code, cat_wsg)
    conn <- pg()
    for (w in fp_wsg) {
      s <- seg_all |> filter(watershed_group_code == w)
      geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
        "SELECT id_segment, geom FROM %s.streams WHERE watershed_group_code = '%s'", schema, w)), drop = TRUE)
      geom$id_segment <- as.numeric(geom$id_segment)
      sg <- geom |> inner_join(s |> transmute(id_segment, blue_line_key, accessible, stream_order, grade, grade_class,
                                              flag_default = .data[[paste0(flag, "_default")]], flag_tuned = .data[[paste0(flag, "_tuned")]]),
                               by = "id_segment")
      fp <- tryCatch(knw_floodplain_ha(gpkg_of(w), sg, c("flag_default", "flag_tuned", "accessible")),
                     error = function(e) {
                       say("  %s %s floodplain: %s", k, w, conditionMessage(e))
                       NULL
                     })
      if (!is.null(fp)) {
        fp_rows[[paste(k, w)]] <- fp$summary |>
          mutate(species_code = sp, stage = stage, watershed_group_code = w,
                 floodplain_ha = fp$check[["floodplain_ha"]], ties = fp$check[["ties"]],
                 rule = unname(c(flag_default = "default", flag_tuned = "tuned",
                                 accessible = "accessible")[fp$summary$flag]),
                 tune_run = run, config_sha = r$compare$config_sha[1], tuned_rule = r$compare$tuned_rule[1])
      }
    }
    dbDisconnect(conn)
    say("%s: floodplain hectares for %s.", k, if (length(fp_wsg)) paste(fp_wsg, collapse = " ") else "no catalog group")
  }
  fpt <- bind_rows(fp_rows)
  if (nrow(fpt)) {
    # this drawing's keys replace their own rows; a key drawn by another pass keeps its rows (#111)
    floodplain_write(fpt |> mutate(across(where(is.numeric), ~ round(.x, 2))), drop = names(res))
    tot <- fpt |> group_by(species_code, stage, rule) |> summarise(ha = sum(ha), graded_ha = sum(graded_ha), groups = n(), .groups = "drop")
    for (i in seq_len(nrow(tot))) say("floodplain %s %s %s: %.0f ha, %.0f graded ha over %d groups", tot$species_code[i], tot$stage[i], tot$rule[i], tot$ha[i], tot$graded_ha[i], tot$groups[i])
  }
}
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
