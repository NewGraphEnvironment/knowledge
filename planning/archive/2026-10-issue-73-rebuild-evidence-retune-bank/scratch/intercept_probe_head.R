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
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (0310), data/fdis/build/fish.rds
#         (0230), data/fdis_species_codes.csv; the link repository at LINK_REPO at the build's link_sha
#         (parameters_habitat_thresholds.csv); fwapg database (PG* env vars): the run's schema (SCHEMA, default
#         fresh_default), discharge
# OUTPUT: data/tune/<sp>_<stage>_tune.csv      every rule's score (the full grid), with pick, recommended, region
#         data/tune/<sp>_<stage>_curves.csv    the marginal curves at the pick
#         data/tune/<sp>_<stage>_grades.csv    one row per segment of the species' groups, each graded segment at
#                                              its own walked distance, with dist_status (ignored; 0325 publishes)
#         data/tune/<sp>_<stage>_groups.csv    the groups modelled, with their fold
#         data/tune/<sp>_<stage>_seeds.csv     the four more fold seeds' best, pick and recommended rules
#         data/tune/<sp>_<stage>_honest.csv    nested selection: each fold's pick and its held-out deviance
#         data/tune/<sp>_<stage>_score.rds     the scored grid, read back on a rerun (ignored)
#         data/tune/<sp>_<stage>_summary.csv   one row: status, population, pick, held-out deviances (0325 binds them)
#         data/tune/<sp>_<stage>_curve.rds     the fitted curve object (ignored; 0330 reads them)
#         scripts/logs/habitat/<date>_tune_run.txt
# RUN:    Rscript scripts/0320-tune-run.R   (from the repo root; SPECIES=CH,BT to restrict; WORKERS=14)
#         Scored grids (<key>_score.rds) and grade tables already in data/tune/ are kept, so a run over a subset of
#         species on another host, with the caches copied, grades only what is missing.
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
dir_out <- "data/tune"
# one log per pass: a pass over a subset of species (SPECIES=) names them, so passes do not overwrite each other
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_tune_run",
                                                     if (nzchar(Sys.getenv("SPECIES"))) paste0("-", tolower(gsub(",", "_", Sys.getenv("SPECIES")))) else "",
                                                     ".txt"))
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}

# ---- inputs and their provenance ------------------------------------------------------
ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
if (is.na(ledger_path)) stop("no evidence build ledger: run scripts/0310 first")
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- led$note[led$step == "run_link_sha"]
say("Tuning run, knowledge#57. Evidence build %s on link run %s (link %s), schema %s.", ledger_path, run_uid, link_sha, schema)
for (f in c("visits_link", "visits_species", "walks")) {
  say("  %s md5 %s", f, unname(tools::md5sum(file.path("data/fdis/derived", paste0(f, ".csv")))))
}
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))
walks <- read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE)
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

