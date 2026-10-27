# scripts/0330-compare.R
# ---------------------------------------------------------------------------
# What a tuning changes on the ground: for each fitted species x stage, link's `default` against the
# recommended rule on link's own segments in every group the species has a habitat table in (km kept,
# lost and gained; graded km; km by grade class; change by reason), under each rule structure (#73), with
# one GeoPackage per species x stage for QGIS (#81); and, as their own step (STAGE=maps), floodplain
# hectares beside each rule's habitat in the groups the floodplain catalog holds and the maps. Issue #57,
# phase 4; #73 for the structures and the baseline; #81 for the split. Successor to 0298 (frozen on v2).
# Input from 0310 and 0320.
#
# WHY / DESIGN NOTES:
#   - BOTH RULES REGENERATED THE SAME WAY (0298): fresh's predicate behind stored access, link's
#     user-habitat overlay, fresh's connectivity pass, on scratch copies; both stages together.
#     knw_compare_rules() carries the method.
#   - THE BASELINE IS LINK'S CURRENT `default` (#73): the configs are read at CONFIG_SHA (default: LINK_REPO's
#     origin/main, as fetched), not at the run's commit, because that is the rule link draws now; the schema's
#     run and its link_sha stay the provenance of the segments and access. Since link 0.67.0 a rule can carry a
#     near-river pair, which knw_compare_rules() walks on the scratch copy with fresh's own walk.
#   - THREE STRUCTURES (#73, link#364): the tuned rule's through-wetland lines free (link before 0.67.0),
#     through the door with the pair everywhere (link's `both`), or through the door with the pair on them
#     only (link's `wetland_flow`); knw_compare_rules() picks which a species runs. `tuned` in the tables and
#     the segments is the `door` structure (TUNED_AS=), the one the maps and the article read.
#   - NO MAPS IN THE DEFAULT RUN (#81, Al 2026-10-20): comparisons are viewed in QGIS from the GeoPackages
#     (data/compare/gpkg/, ignored; GPKG=FALSE skips them); the floodplain table and the maps are STAGE=maps.
#   - FLOODPLAIN AS A UNIT OF MEASURE: the catalog's whole-network floodplain (`<wsg>_all_ff04`) is a
#     fixed input, nothing here models it; knw_floodplain_ha() joins it to the segments by position
#     (one owner per cell) and reports hectares and graded hectares under each rule. Only the groups
#     the catalog holds (23 at 2026-10-17) until whole-network floodplains are published for all
#     (NewGraphEnvironment/floodplains#123).
#   - MAPS: a static three-panel figure (rules, grade, floodplain by grade) for each catalog group and
#     three groups per species x stage chosen by criteria fixed here: the largest share of `default` km gained,
#     the largest share lost, and the most `default` km; in research/fig/; an interactive page per catalog
#     group in data/compare/maps/ (ignored). 0298's criteria (small-stream-heavy, interior, coastal) are not
#     reproduced: they need the visits' hydrologic zones and sea walks per group, which this script does not read.
#   - KEYS IN TURN, GROUPS IN PARALLEL (#87): one species x stage at a time, its groups split across WORKERS
#     socket workers (knw_compare_rules(workers =)), each with its own connection and scratch schema, so one key
#     uses as many database cores as there are workers (one key per worker held BT rearing to one core for two
#     hours). WORKERS is therefore database cores: 6 on the database's host. The GeoPackages are written after
#     every key, in parallel across keys, from the saved segments (GPKG=FALSE skips them while iterating).
#
# INPUT:  data/tune/<sp>_<stage>_{curve.rds,grades.csv} (0320), data/fdis/derived/{visits_link,visits_species}.csv
#         (0310), the link repository at LINK_REPO at the build's link_sha, the stac_floodplains_bc catalog
#         (items read from its public bucket), fwapg database (PG* env vars): the run's schema (SCHEMA, default
#         fresh_default), bcfishobs, whse_basemapping
# WRITES: schemas knw_cmp_<sp>_<stage> and knw_cmp_<sp>_<stage>_w<i> in the fwapg database (scratch; dropped)
# OUTPUT: data/compare/<key>_{compare,change,checks}.csv, <key>_segments.rds  per job, as it finishes (rds ignored)
#         data/compare/gpkg/<key>.gpkg  every segment's verdict under each rule and structure, grade, size, distance,
#                                       and the default branch it lies on (ignored)
#         data/compare/compare.csv     per species x stage x structure x group and total: km by rule, graded km, km by class
#         data/compare/change.csv      km gained and lost by structure, reason and stream order
#         data/compare/checks.csv      FDIS detection on each rule's segments; the bcfishobs lift, per structure
#         scripts/logs/habitat/<date>_compare.txt
#         STAGE=maps: data/compare/floodplain.csv  per species x stage x catalog group: ha, graded ha, ha by class
#                     research/fig/compare_<sp>_<stage>_<wsg>.png, data/compare/maps/*.html (ignored)
# RUN:    Rscript scripts/0330-compare.R   (from the repo root; SPECIES=CH,BT to restrict, and the combined tables then
#         compose with the other species' saved per-key tables; WORKERS=6 database cores; CONFIG_SHA=<link
#         commit> for the configs (default origin/main of LINK_REPO); TUNED_AS=door; GPKG=FALSE skips the GeoPackages;
#         STAGE=maps draws the floodplain table and the maps from the tables the last full run saved; STAGE=gpkg writes
#         the GeoPackages alone from the segments it saved)
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
gpkg <- !identical(Sys.getenv("GPKG"), "FALSE")
if (!stage_only %in% c("", "maps", "gpkg")) stop("STAGE must be unset, 'maps' or 'gpkg', not '", stage_only, "'")
schema <- Sys.getenv("SCHEMA", "fresh_default")  # the run's persist schema, by its current name (renamed after the run, #73)
catalog_bucket <- "https://stac-floodplains-bc.s3.us-west-2.amazonaws.com"
catalog_items <- "../stac_floodplains_bc/data/stac"      # the catalog repo's item records
dir_out <- "data/compare"
dir_cat <- file.path(dir_out, "catalog")
dir_maps <- file.path(dir_out, "maps")
dir_gpkg <- file.path(dir_out, "gpkg")
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_compare",
                                                     if (nzchar(stage_only)) paste0("-", stage_only), ".txt"))
for (d in c(dir_out, dir_cat, dir_maps, dir_gpkg, "research/fig")) dir.create(d, showWarnings = FALSE, recursive = TRUE)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}

# ---- inputs -----------------------------------------------------------------------------
ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]][1]
cf <- list.files("data/tune", "_curve\\.rds$", full.names = TRUE)
curves <- setNames(lapply(cf, readRDS), sub("_curve\\.rds$", "", basename(cf)))
fitted <- Filter(function(r) !is.null(r$pick) && !is.null(r$curve), curves)
if (nzchar(only)) fitted <- fitted[vapply(fitted, function(r) r$species_code %in% strsplit(only, ",")[[1]], logical(1))]
say("Comparison, knowledge#57: %d fitted species x stage; link run %s at %s.", length(fitted), run_uid, link_sha)
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))

# link's configs: the baseline is link's current default (CONFIG_SHA, default origin/main as fetched), not the
# run's commit, which stays the provenance of the schema (#73)
config_sha <- Sys.getenv("CONFIG_SHA", "")
if (!nzchar(config_sha)) {
  config_sha <- suppressWarnings(system2("git", c("-C", link_repo, "rev-parse", "origin/main"), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(config_sha, "status")) || !grepl("^[0-9a-f]{40}$", config_sha)) stop("could not resolve origin/main in ", link_repo, "; set CONFIG_SHA")
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
say("link configs/default at %s (the baseline; the schema %s's run is at %s) read from %s; fresh %s; tuned reported as %s.",
    config_sha, schema, link_sha, link_repo, as.character(packageVersion("fresh")), tuned_as)

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
# the database's build, checked before any work (#87): a schema built by another run than the evidence's is refused
rec <- tryCatch(knw_build_record(conn, schema, run_uid = run_uid), error = function(e) {
  say("%s", conditionMessage(e))
  writeLines(log_lines, path_log)
  stop(conditionMessage(e), call. = FALSE)
})
say("%s", rec$line)
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
  h <- readr::read_csv(file.path("data/tune", paste0(k, "_grades.csv")), n_max = 1, show_col_types = FALSE,
                       col_types = readr::cols(.default = "c"))
  "ref_population" %in% names(h) && identical(h$ref_population, "stream_branch") &&
    "walk" %in% names(h) && identical(h$walk, "bank") &&
    # walked by this tree's walk (#87)
    "walk_md5" %in% names(h) && identical(h$walk_md5, knw_walk_md5()) &&
    # graded under the pick this comparison applies, on this link run and one evidence build (the branch review of
    # 2026-10-25: a 0320 that stopped between scoring and grading leaves a new pick beside an old table)
    identical(h$rule, curves[[k]]$pick$rule) && identical(h$run_uid, run_uid) &&
    "evidence_md5" %in% names(h) && identical(h$evidence_md5, curves[[k]]$evidence_md5) &&
    # graded from a curve with the prior, the withheld-grade record (#73, Phase 7) and the gate's own number (the branch
    # review of 2026-10-25: a verdict written by the gate before it compared like with like is not read back)
    all(c("curve_prior_sd", "grade_withheld", "null_heldout_curve") %in% names(h))
}, logical(1))]
if (length(stale)) stop("grade tables made before #73's curve prior (no ref_population = stream_branch, a walk not ending at the bank, or no curve_prior_sd, grade_withheld, null_heldout_curve and evidence_md5), walked by another walk than this tree's (walk_md5, #87), or graded under another pick, link run or evidence build than the curve record's; rerun 0320: ",
                        paste(stale, collapse = ", "))
# each job writes its own tables as it finishes and returns its error rather than raising it, so one failed
# species cannot discard the others (code-check round 2); the grade table is read with the six columns the
# comparison needs, not its 25 (RB's is 1.5 GB)
run_one <- function(job) {
  t0 <- Sys.time()
  out <- tryCatch({
    gfile <- file.path("data/tune", paste0(job$key, "_grades.csv"))
    gcols <- c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class")
    # target_in_group (#73) rides along where the grade table carries it; a table graded before it does not
    if ("target_in_group" %in% names(readr::read_csv(gfile, n_max = 0, show_col_types = FALSE))) gcols <- c(gcols, "target_in_group")
    grades <- readr::read_csv(gfile, show_col_types = FALSE, col_select = dplyr::all_of(gcols),
                              col_types = readr::cols(id_segment = "d", watershed_group_code = "c", size = "d", dist_m = "d",
                                                      grade = "d", grade_class = "c", target_in_group = "l"))
    cmp <- knw_compare_rules(pg, schema, job$species_code, job$stage, job$pick, job$groups, link_dir, grades,
                             visits = vl, visit_species = vs, scratch = paste0("knw_cmp_", tolower(job$key)),
                             tuned_as = tuned_as, config_sha = config_sha, workers = workers)
    rm(grades)
    readr::write_csv(cmp$compare, file.path("data/compare", paste0(job$key, "_compare.csv")), na = "")
    readr::write_csv(cmp$change, file.path("data/compare", paste0(job$key, "_change.csv")), na = "")
    if (!is.null(cmp$checks)) readr::write_csv(cmp$checks, file.path("data/compare", paste0(job$key, "_checks.csv")), na = "")
    saveRDS(cmp$segments, file.path("data/compare", paste0(job$key, "_segments.rds")))
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
# one GeoPackage per species x stage for QGIS (#81): every segment with its verdict under each rule and structure,
# written group by group from link's geometry and the segments the comparison saved; run on a socket worker per key
gpkg_one <- function(key, schema, dir_gpkg) {
  t1 <- Sys.time()
  tryCatch({
    seg <- readRDS(file.path("data/compare", paste0(key, "_segments.rds")))
    f <- file.path(dir_gpkg, paste0(key, ".gpkg"))
    unlink(f)
    conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
    on.exit(DBI::dbDisconnect(conn))
    for (w in sort(unique(seg$watershed_group_code))) {
      geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
        "SELECT id_segment, geom FROM %s.streams WHERE watershed_group_code = '%s'", schema, w)), drop = TRUE)
      geom$id_segment <- as.numeric(geom$id_segment)
      sg <- dplyr::inner_join(geom, seg[seg$watershed_group_code == w, , drop = FALSE], by = "id_segment")
      sf::st_write(sg, f, layer = "segments", append = file.exists(f), quiet = TRUE)
    }
    sprintf("GeoPackage %s: %d segments in %.1f min.", f, nrow(seg), as.numeric(difftime(Sys.time(), t1, units = "mins")))
  }, error = function(e) sprintf("GeoPackage for %s FAILED: %s", key, conditionMessage(e)))
}
# the GeoPackages of several keys, one key per socket worker (one writer per file)
write_gpkgs <- function(keys) {
  t1 <- Sys.time()
  gl <- if (workers > 1L && length(keys) > 1L) {
    cl <- parallel::makeCluster(min(workers, length(keys)))
    tryCatch(parallel::parLapplyLB(cl, keys, gpkg_one, schema = schema, dir_gpkg = dir_gpkg),
             finally = parallel::stopCluster(cl))
  } else {
    lapply(keys, gpkg_one, schema = schema, dir_gpkg = dir_gpkg)
  }
  names(gl) <- keys
  say("GeoPackages for %d keys in %.1f min on %d workers.", length(keys),
      as.numeric(difftime(Sys.time(), t1, units = "mins")), min(workers, length(keys)))
  gl
}
t0 <- Sys.time()
if (stage_only == "maps") {
  # the floodplain and map stage alone, from the tables and segments the last full run saved per key
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
  if (!length(res)) stop("STAGE=maps: no saved comparison under ", dir_out)
  # the saved segments carry the grade the full run read; one older than its grade table carries a superseded
  # grade (#65), which the guard on the grade tables above cannot see
  old <- names(res)[vapply(names(res), function(k) {
    file.mtime(file.path(dir_out, paste0(k, "_segments.rds"))) < file.mtime(file.path("data/tune", paste0(k, "_grades.csv")))
  }, logical(1))]
  if (length(old)) stop("STAGE=maps: the saved segments predate their grade tables; run the full compare: ",
                        paste(old, collapse = ", "))
  say("STAGE=maps: floodplain and maps from the saved comparison of %s.", paste(names(res), collapse = " "))
} else if (stage_only == "gpkg") {
  # the GeoPackages alone, from the segments the last full run saved per key, refusing segments older than their
  # grade table as STAGE=maps does
  keys <- names(jobs)[file.exists(file.path(dir_out, paste0(names(jobs), "_segments.rds")))]
  if (!length(keys)) stop("STAGE=gpkg: no saved segments under ", dir_out)
  old <- keys[file.mtime(file.path(dir_out, paste0(keys, "_segments.rds"))) <
                file.mtime(file.path("data/tune", paste0(keys, "_grades.csv")))]
  if (length(old)) stop("STAGE=gpkg: the saved segments predate their grade tables; run the full compare: ",
                        paste(old, collapse = ", "))
  gl <- write_gpkgs(keys)
  for (k in keys) say("  %s", gl[[k]])
} else {
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
  write_csv(compare |> mutate(across(where(is.numeric), ~ round(.x, 3))), file.path(dir_out, "compare.csv"), na = "")
  write_csv(change |> mutate(km = round(km, 3)), file.path(dir_out, "change.csv"), na = "")
  write_csv(checks |> mutate(across(where(is.numeric), ~ round(.x, 4))), file.path(dir_out, "checks.csv"), na = "")
}

# ---- floodplain hectares and maps: their own step (STAGE=maps; #81) ------------------------------
if (stage_only == "maps") {
  conn <- pg()
  water_of <- function(w) {
    sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf("
      SELECT waterbody_key, 'lake' AS kind, geom FROM whse_basemapping.fwa_lakes_poly WHERE watershed_group_code = '%1$s' AND area_ha >= 10
      UNION ALL SELECT waterbody_key, 'river', geom FROM whse_basemapping.fwa_rivers_poly WHERE watershed_group_code = '%1$s'", w)), drop = TRUE)
  }
  fp_rows <- list()
  for (k in names(res)) {
    r <- res[[k]]
    stage <- jobs[[k]]$stage
    flag <- if (stage == "rear") "rearing" else "spawning"
    sp <- jobs[[k]]$species_code
    seg_all <- readRDS(file.path("data/compare", paste0(k, "_segments.rds")))
    per <- r$compare |> filter(watershed_group_code != "ALL", structure == tuned_structure)
    # three groups by the criteria in the header: largest gained share, largest lost share, most default km
    crit <- c(per$watershed_group_code[which.max(per$gained_km / pmax(per$default_km, 1))],
              per$watershed_group_code[which.max(per$lost_km / pmax(per$default_km, 1))],
              per$watershed_group_code[which.max(per$default_km)])
    map_wsg <- unique(c(intersect(per$watershed_group_code, cat_wsg), crit))
    for (w in map_wsg) {
      s <- seg_all |> filter(watershed_group_code == w)
      geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
        "SELECT id_segment, geom FROM %s.streams WHERE watershed_group_code = '%s'", schema, w)), drop = TRUE)
      geom$id_segment <- as.numeric(geom$id_segment)
      sg <- geom |> inner_join(s |> transmute(id_segment, blue_line_key, accessible, stream_order, grade, grade_class,
                                              flag_default = .data[[paste0(flag, "_default")]], flag_tuned = .data[[paste0(flag, "_tuned")]]),
                               by = "id_segment")
      fp_cells <- NULL
      if (w %in% cat_wsg) {
        fp <- tryCatch(knw_floodplain_ha(gpkg_of(w), sg, c("flag_default", "flag_tuned", "accessible")), error = function(e) { say("  %s %s floodplain: %s", k, w, conditionMessage(e)); NULL })
        if (!is.null(fp)) {
          fp_rows[[paste(k, w)]] <- fp$summary |> mutate(species_code = sp, stage = stage, watershed_group_code = w,
                                                         floodplain_ha = fp$check[["floodplain_ha"]], ties = fp$check[["ties"]],
                                                         rule = unname(c(flag_default = "default", flag_tuned = "tuned", accessible = "accessible")[fp$summary$flag]))
          # the floodplain cells by the owning segment's grade, for the map
          own <- fp$segments
          own$grade_fp <- ifelse(is.na(own$grade), NA, own$grade)
          fp_cells <- tryCatch({
            bl <- sf::st_read(gpkg_of(w), layer = "all_ff04_by_blue_line_key", quiet = TRUE)
            fpp <- sf::st_read(gpkg_of(w), layer = "all_ff04", quiet = TRUE)
            bb <- sf::st_bbox(fpp)
            tmpl <- terra::rast(xmin = floor(bb[["xmin"]] / 30) * 30, xmax = ceiling(bb[["xmax"]] / 30) * 30,
                                ymin = floor(bb[["ymin"]] / 30) * 30, ymax = ceiling(bb[["ymax"]] / 30) * 30, resolution = 30, crs = "EPSG:3005")
            valleys <- terra::rasterize(terra::vect(fpp), tmpl, field = 1L, background = 0L, touches = FALSE)
            bl$blue_line_key <- as.numeric(bl$blue_line_key)
            j <- flooded::fl_valley_join(valleys, bl, own[own$blue_line_key %in% bl$blue_line_key, ], group = "blue_line_key", cols = "accessible")
            rg <- terra::rast(valleys); terra::values(rg) <- NA
            rg[j$nearest$cell] <- own$grade_fp[own$blue_line_key %in% bl$blue_line_key][j$nearest$seg]
            rg
          }, error = function(e) { say("  %s %s floodplain raster: %s", k, w, conditionMessage(e)); NULL })
        }
      }
      title <- sprintf("%s: %s %s, default against %s (%s)", w, sp, flag, r$compare$tuned_rule[1], r$compare$tuned_structure[1])
      tryCatch(knw_compare_map(sg, water_of(w), title,
                               png = file.path("research/fig", sprintf("compare_%s_%s.png", tolower(k), tolower(w))),
                               html = if (w %in% cat_wsg) file.path(dir_maps, sprintf("compare_%s_%s.html", tolower(k), tolower(w))) else NULL,
                               fp_cells = fp_cells),
               error = function(e) say("  %s %s map: %s", k, w, conditionMessage(e)))
    }
    say("%s: maps for %s.", k, paste(map_wsg, collapse = " "))
  }
  dbDisconnect(conn)
  fpt <- bind_rows(fp_rows)
  if (nrow(fpt)) {
    write_csv(fpt |> mutate(across(where(is.numeric), ~ round(.x, 2))), file.path(dir_out, "floodplain.csv"), na = "")
    tot <- fpt |> group_by(species_code, stage, rule) |> summarise(ha = sum(ha), graded_ha = sum(graded_ha), groups = n(), .groups = "drop")
    for (i in seq_len(nrow(tot))) say("floodplain %s %s %s: %.0f ha, %.0f graded ha over %d groups", tot$species_code[i], tot$stage[i], tot$rule[i], tot$ha[i], tot$graded_ha[i], tot$groups[i])
  }
}
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
