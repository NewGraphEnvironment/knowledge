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
#     in fifths. Expected use, not habitat quality. Walks for the grade run from the segment's
#     downstream end, for every gradable accessible segment, since the curve reads size and
#     distance jointly (#65; #57's grades walked only the exception's candidates and read the
#     rest at the 50 km cap).
#   - CH's size floor (0.75 against 0.5 m3/s) is read off CH rearing's pick on all CH groups.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (0310), data/fdis/build/fish.rds
#         (0230), data/fdis_species_codes.csv; the link repository at LINK_REPO at the build's link_sha
#         (parameters_habitat_thresholds.csv); fwapg database (PG* env vars): fresh_default, discharge
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
schema <- "fresh_default"
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
say("Tuning run, knowledge#57. Evidence build %s on link run %s (link %s).", ledger_path, run_uid, link_sha)
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
# SHAs; the thresholds must be the same text at each, and the first (HEAD of the run) is the one named
shas <- strsplit(link_sha, ";", fixed = TRUE)[[1]]
read_thr <- function(sha) {
  f <- tempfile(fileext = ".csv")
  st <- system2("git", c("-C", link_repo, "show", paste0(sha, ":inst/extdata/configs/default/parameters_habitat_thresholds.csv")), stdout = f)
  if (!identical(st, 0L) || !file.exists(f) || file.size(f) == 0) stop("could not read link's thresholds at ", sha, " from ", link_repo)
  f
}
thr_files <- vapply(shas, read_thr, character(1))
if (length(thr_files) > 1 && length(unique(unname(tools::md5sum(thr_files)))) != 1) {
  stop("link's thresholds differ between the run's commits ", link_sha)
}
link_sha <- shas[1]
thr <- read.csv(thr_files[1], stringsAsFactors = FALSE)
say("link default thresholds at %s (same at %s): %d species.", shas[1], paste(shas[-1], collapse = ","), nrow(thr))

# ---- score, pick, curve ------------------------------------------------------------------
t0 <- Sys.time()
out <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = workers, cache_dir = dir_out)
say("Scored %d species x stage in %.1f min on %d workers.", length(out), as.numeric(difftime(Sys.time(), t0, units = "mins")), workers)

summ <- list()
for (k in names(out)) {
  r <- out[[k]]
  row <- tibble(species_code = r$species_code, stage = r$stage, response = r$response, status = r$status,
                visits_in = r$population[["visits_in"]], detections = r$population["detections"],
                groups = r$population["groups"], groups_both = r$population["groups_both"])
  if (!is.null(r$score) && is.null(r$curve)) say("%s: curve failed: %s", k, r$curve_error)
  if (!is.null(r$score) && !is.null(r$curve)) {
    rules <- r$score$rules |> mutate(species_code = r$species_code, stage = r$stage, response = r$response, status = r$status)
    write_csv(rules |> mutate(across(where(is.numeric), ~ round(.x, 6))), file.path(dir_out, paste0(k, "_tune.csv")), na = "")
    write_csv(r$curve$curves |> mutate(across(where(is.numeric), ~ signif(.x, 5)), species_code = r$species_code, stage = r$stage,
                                       rule = r$pick$rule),
              file.path(dir_out, paste0(k, "_curves.csv")), na = "")
    write_csv(tibble(species_code = r$species_code, stage = r$stage, watershed_group_code = names(r$score$folds),
                     fold = as.integer(r$score$folds)), file.path(dir_out, paste0(k, "_groups.csv")), na = "")
    # the stability tables the score object holds, so a reader of the tables needs no rds (#62)
    write_csv(as_tibble(r$score$seeds) |> mutate(species_code = r$species_code, stage = r$stage),
              file.path(dir_out, paste0(k, "_seeds.csv")), na = "")
    write_csv(as_tibble(r$score$honest) |> mutate(across(where(is.double), ~ round(.x, 6)),
                                                  species_code = r$species_code, stage = r$stage),
              file.path(dir_out, paste0(k, "_honest.csv")), na = "")
    dflt <- rules |> filter(is_default)
    best <- rules |> filter(ddev_best == 0) |> slice(1)
    row <- row |> mutate(
      rule_recommended = r$pick$rule, rule_pick = rules$rule[rules$pick], rule_best = best$rule,
      default_in_region = dflt$in_region, default_ddev = dflt$ddev_best, default_se = dflt$se_diff,
      region_n = sum(rules$in_region), patterns = r$score$population[["patterns"]],
      dev_default = dflt$dev_heldout, dev_best = best$dev_heldout, dev_null = best$dev_heldout - best$ddev_null,
      dev_curve = r$curve$heldout, curve_dist_in_model = r$curve$dist_in_model,
      curve_edf = paste(sprintf("%s=%.2f", names(r$curve$edf), r$curve$edf), collapse = "; "),
      honest_dev_rec = sum(r$score$honest$dev_rec), honest_dev_default = sum(r$score$honest$dev_default),
      honest_dev_null = sum(r$score$honest$dev_null),
      seeds_same_rec = sum(r$score$seeds$recommended == r$pick$rule), seeds_default_in_region = sum(r$score$seeds$default_in_region),
      seeds_rec_in_region = sum(r$score$seeds$main_rec_in_region), seeds_n = nrow(r$score$seeds),
      boot_rec_share = rules$boot_rec_share[rules$recommended])
    say("%s: %s. %d visits (%d detections) in %d groups (%d both). Recommended %s; default %s the region (+%.1f, SE %.1f). Curve held-out %.1f vs grid best %.1f.",
        k, r$status, row$visits_in, row$detections, row$groups, row$groups_both, r$pick$rule,
        if (dflt$in_region) "in" else "outside", dflt$ddev_best, dflt$se_diff, r$curve$heldout, best$dev_heldout)
    block(paste(k, "region"), rules |> filter(in_region) |> arrange(ddev_best) |>
            select(rule, departures, ddev_best, se_diff, n_wsg_varies, n_in, n_detect_in, raw_rate_in, raw_rate_out, boot_region_share))
    block(paste(k, "nested selection"), r$score$honest)
    block(paste(k, "more seeds"), r$score$seeds)
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
  saveRDS(out[[k]][c("species_code", "stage", "response", "status", "pick", "curve")], file.path(dir_out, paste0(k, "_curve.rds")))
}

# ---- grade every segment of each fitted species' groups ----------------------------------
conn <- pg()
groups_sp <- function(sp) dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_%s ORDER BY 1", schema, tolower(sp)))$w
grade_rows <- list()
for (k in names(out)) {
  r <- out[[k]]
  if (is.null(r$curve)) next
  gpath <- file.path(dir_out, paste0(k, "_grades.csv"))
  if (file.exists(gpath)) {
    # kept only when it was graded under this pick on this link run with every graded segment walked
    # (dist_status, #65); #57's tables walked only the exception's candidates and are regraded
    head1 <- readr::read_csv(gpath, n_max = 1, show_col_types = FALSE, col_types = readr::cols(.default = "c"))
    if (identical(head1$rule, r$pick$rule) && identical(head1$run_uid, run_uid) && "dist_status" %in% names(head1)) {
      say("%s grades: already written under %s on %s, kept.", k, r$pick$rule, run_uid)
      next
    }
    # not "<key> grades:", which data-raw/vignette_chinook.R reads as the one result line
    say("%s: grades on file for %s / %s%s, regraded for %s / %s.", k, head1$rule, head1$run_uid,
        if ("dist_status" %in% names(head1)) "" else " (walked only the exception's candidates)", r$pick$rule, run_uid)
  }
  wsg <- groups_sp(r$species_code)
  t1 <- Sys.time()
  g <- knw_grade_species(pg, schema, r$species_code, wsg, r$curve, r$pick, stage = r$stage, workers = min(workers, 8L))
  write_csv(g$grades |> mutate(species_code = r$species_code, stage = r$stage, rule = r$pick$rule, run_uid = run_uid,
                               across(c(rate, grade), ~ signif(.x, 5))),
            file.path(dir_out, paste0(k, "_grades.csv")), na = "")
  say("%s grades: %d groups, %s; reference rate %.4f; walks %.1f min; total %.1f min.", k, length(wsg),
      paste(names(g$counts), g$counts, sep = "=", collapse = ", "), g$reference, g$walk_minutes,
      as.numeric(difftime(Sys.time(), t1, units = "mins")))
  grade_rows[[k]] <- tibble(key = k, groups = length(wsg), reference_rate = g$reference, as_tibble(as.list(g$counts)))
}
dbDisconnect(conn)
block("grades", bind_rows(grade_rows))
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
