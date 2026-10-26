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
#   - SMOKE RUN FIRST (#84): before any grid is scored, every key that would be fitted scores no rule,
#     `default`, link's `default_tuned` row and the previous pick (the `recommended` rule of the committed
#     data/tune/<key>_tune.csv) on the main fold seed, and four checks gate the scorer (knw_tune_smoke()). One
#     failed check on any key ends the run with every key's report in the log, and nothing is scored.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (0310), data/fdis/build/fish.rds
#         (0230), data/fdis_species_codes.csv; the link repository at LINK_REPO at the build's link_sha
#         (parameters_habitat_thresholds.csv); fwapg database (PG* env vars): the run's schema (SCHEMA, default
#         fresh_default), discharge; data/tune/<sp>_<stage>_tune.csv where one exists (the previous pick)
# OUTPUT: data/tune/<sp>_<stage>_smoke.csv     the smoke run's four checks (value, limit, pass) and its rules' scores
#         data/tune/<sp>_<stage>_tune.csv      every rule's score (the full grid), with pick, recommended, region
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
#         species on another host, with the caches copied, grades only what is missing. The cache is keyed on the
#         population and the grid, not the scorer's code: remove <key>_score.rds after a change to R/tune_score.R.
#         DEV=1 is the development setting (#84): the smoke run and the full grid on the main fold seed only (no
#         bootstrap, nested selection or extra seeds), the curve and the summary, no grades, every output under
#         data/tune/dev/ (ignored), so a scorer change is proved on every species before a full run.
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
dir_out <- if (dev) "data/tune/dev" else "data/tune"
# one log per pass: a pass over a subset of species (SPECIES=) names them, so passes do not overwrite each other
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_tune_run",
                                                     if (nzchar(Sys.getenv("SPECIES"))) paste0("-", tolower(gsub(",", "_", Sys.getenv("SPECIES")))) else "",
                                                     if (dev) "-dev" else "", ".txt"))
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
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

# ---- inputs and their provenance ------------------------------------------------------
ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
if (is.na(ledger_path)) stop("no evidence build ledger: run scripts/0310 first")
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- led$note[led$step == "run_link_sha"]
say("Tuning run, knowledge#57. Evidence build %s on link run %s (link %s), schema %s.", ledger_path, run_uid, link_sha, schema)
# the evidence's identity: the md5 of each derived table, logged, carried into the score cache's settings and written
# on every grade table, so a rebuilt evidence of the same visit count is neither read back from the cache nor kept as
# a grade (the branch review of 2026-10-25)
evidence_md5s <- vapply(c("visits_link", "visits_species", "walks"), function(f) {
  unname(tools::md5sum(file.path("data/fdis/derived", paste0(f, ".csv"))))
}, character(1))
for (f in names(evidence_md5s)) say("  %s md5 %s", f, evidence_md5s[[f]])
evidence_md5 <- paste(unname(evidence_md5s), collapse = ";")
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
    format(formals(knw_tune_score)$prior_sd))
say("Smoke run first%s: previous picks on file for %s.", if (dev) " (DEV=1: the main seed only, no grades, outputs under data/tune/dev)" else "",
    paste(names(previous), collapse = ", "))
t0 <- Sys.time()
sm <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = workers, thresholds_extra = thr_tuned, evidence_id = evidence_md5,
                   previous = if (length(previous)) previous else NULL, smoke_only = TRUE)
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
t0 <- Sys.time()
out <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = workers, cache_dir = dir_out,
                    thresholds_extra = thr_tuned, smoke = FALSE, extra = !dev, evidence_id = evidence_md5)
say("Scored %d species x stage in %.1f min on %d workers%s.", length(out), as.numeric(difftime(Sys.time(), t0, units = "mins")), workers,
    if (dev) " (DEV=1: the main seed only)" else "")

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
    if (!dev) {
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
      rule_recommended_196 = rep_of(1.96, "default"),
      rule_recommended_flow = if (is.null(r$pick_flow)) NA_character_ else r$pick_flow$rule,
      rule_recommended_flow_196 = rep_of(1.96, "flow"),
      rule_link_tuned = if (nrow(ltn)) ltn$rule else NA_character_,
      link_tuned_ddev = if (nrow(ltn)) ltn$ddev_best else NA_real_, link_tuned_se = if (nrow(ltn)) ltn$se_diff else NA_real_,
      link_tuned_in_region = if (nrow(ltn)) ltn$in_region else NA,
      default_in_region = dflt$in_region, default_ddev = dflt$ddev_best, default_se = dflt$se_diff,
      region_n = sum(rules$in_region), patterns = r$score$population[["patterns"]],
      dev_default = dflt$dev_heldout, dev_best = best$dev_heldout, dev_null = best$dev_heldout - best$ddev_null,
      dev_curve = r$curve$heldout, null_heldout_curve = r$null_heldout_curve, curve_prior_sd = r$curve$prior_sd,
      grade_withheld = r$grade_withheld,
      # the evidence and the link run the pick was scored on, so a grade can be held to its pick's evidence as well as its
      # rule (the branch review of 2026-10-25)
      evidence_md5 = evidence_md5, run_uid = run_uid,
      curve_dist_in_model = r$curve$dist_in_model,
      curve_edf = paste(sprintf("%s=%.2f", names(r$curve$edf), r$curve$edf), collapse = "; "),
      # NA under DEV=1, which runs the main seed alone
      honest_dev_rec = if (dev) NA_real_ else sum(r$score$honest$dev_rec),
      honest_dev_default = if (dev) NA_real_ else sum(r$score$honest$dev_default),
      honest_dev_null = if (dev) NA_real_ else sum(r$score$honest$dev_null),
      seeds_same_rec = if (dev) NA_integer_ else sum(r$score$seeds$recommended == r$pick$rule),
      seeds_default_in_region = if (dev) NA_integer_ else sum(r$score$seeds$default_in_region),
      seeds_rec_in_region = if (dev) NA_integer_ else sum(r$score$seeds$main_rec_in_region),
      seeds_n = if (dev) 0L else nrow(r$score$seeds),
      boot_rec_share = if (dev) NA_real_ else rules$boot_rec_share[rules$recommended])
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
    say("%s: from the flow start %s (1.96 SE: %s); from the width start at 1.96 SE %s; link's default_tuned rule %s %s.",
        k, row$rule_recommended_flow, row$rule_recommended_flow_196, row$rule_recommended_196,
        row$rule_link_tuned, if (nrow(ltn)) sprintf("%s the region (+%.1f, SE %.1f)", if (ltn$in_region) "in" else "outside", ltn$ddev_best, ltn$se_diff) else "(none)")
    block(paste(k, "region"), rules |> filter(in_region) |> arrange(ddev_best) |>
            select(rule, departures, ddev_best, se_diff, n_wsg_varies, n_in, n_detect_in, raw_rate_in, raw_rate_out, any_of("boot_region_share")))
    if (!dev) {
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

# ---- grade every segment of each fitted species' groups ----------------------------------
if (dev) {
  say("DEV=1: no grades. Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
  writeLines(log_lines, path_log)
  quit(save = "no", status = 0)
}
conn <- pg()
groups_sp <- function(sp) dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_%s ORDER BY 1", schema, tolower(sp)))$w
# the flow build the grade reads (#72): wet can reload discharge.fwa_v1_segment_monthly between runs (wet#103 did on
# 2026-10-19, after #57 tuned), so the table's comment, which names the build, goes into every grade table and 0325
# refuses to publish a grade whose build is not the live one
discharge_load <- dbGetQuery(conn, "SELECT obj_description('discharge.fwa_v1_segment_monthly'::regclass) AS d")$d
if (length(discharge_load) != 1 || is.na(discharge_load) || !nzchar(discharge_load)) stop("discharge.fwa_v1_segment_monthly carries no load comment")
say("Grading on the flow build: %s", discharge_load)
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
      "ref_edge" %in% names(head1) && identical(head1$ref_edge, ref_edge_txt) &&
      "discharge_load" %in% names(head1) && identical(head1$discharge_load, discharge_load) &&
      "curve_prior_sd" %in% names(head1) && identical(head1$curve_prior_sd, curve_prior_txt) &&
      "grade_withheld" %in% names(head1) && identical(head1$grade_withheld, withheld_txt) &&
      "null_heldout_curve" %in% names(head1) &&
      "evidence_md5" %in% names(head1) && identical(head1$evidence_md5, evidence_md5)
    if (same) {
      # not "<key> grades: <n> groups", the result line data-raw/vignette_chinook.R reads
      say("%s: grades already written under %s on %s, kept.", k, r$pick$rule, run_uid)
      next
    }
    # not "<key> grades:", which data-raw/vignette_chinook.R reads as the one result line
    say("%s: grades on file for %s / %s (walk %s, reference over %s, flows %s, curve prior %s), regraded for %s / %s.",
        k, head1$rule,
        head1$run_uid, if ("walk" %in% names(head1)) head1$walk else "centreline",
        if ("ref_edge" %in% names(head1)) head1$ref_edge else if ("ref_population" %in% names(head1)) head1$ref_population else "every accessible segment",
        if ("discharge_load" %in% names(head1)) head1$discharge_load else "unrecorded",
        if ("curve_prior_sd" %in% names(head1)) head1$curve_prior_sd else "none recorded", r$pick$rule, run_uid)
  }
  wsg <- groups_sp(r$species_code)
  t1 <- Sys.time()
  g <- knw_grade_species(pg, schema, r$species_code, wsg, r$curve, r$pick, stage = r$stage, workers = min(workers, 8L))
  if (!identical(as.integer(g$ref_edge), as.integer(ref_edge_curve))) stop(k, ": the grade's reference edge types are not the curve's")
  if (isTRUE(r$grade_withheld)) g$grades <- g$grades |> mutate(rate = NA_real_, grade = NA_real_, grade_class = NA_character_)
  # ref_population is kept as the name 0325, 0330 and the article read; ref_edge, q_walk, walk and discharge_load
  # are the record (#72), written from what knw_grade_species() returns, not from a literal beside the call
  write_csv(g$grades |> mutate(species_code = r$species_code, stage = r$stage, rule = r$pick$rule, run_uid = run_uid,
                               ref_population = "stream_branch", ref_edge = paste(g$ref_edge, collapse = ";"),
                               q_walk = g$q, walk = g$walk, discharge_load = discharge_load,
                               curve_prior_sd = curve_prior_txt, grade_withheld = withheld_txt, null_heldout_curve = nhc_txt,
                               evidence_md5 = evidence_md5,
                               across(c(rate, grade), ~ signif(.x, 5))),
            file.path(dir_out, paste0(k, "_grades.csv")), na = "")
  say("%s grades: %d groups, %s; reference rate %.4f over edge types %s; walks to %g m3/s, to the bank, %.1f min; %d of %d found rivers lie in another group; total %.1f min.",
      k, length(wsg), paste(names(g$counts), g$counts, sep = "=", collapse = ", "), g$reference,
      paste(g$ref_edge, collapse = ","), g$q, g$walk_minutes, sum(g$grades$target_in_group %in% FALSE),
      sum(!is.na(g$grades$target_in_group)), as.numeric(difftime(Sys.time(), t1, units = "mins")))
  grade_rows[[k]] <- tibble(key = k, groups = length(wsg), reference_rate = g$reference, ref_edge = paste(g$ref_edge, collapse = ";"),
                            q_walk = g$q, target_other_group = sum(g$grades$target_in_group %in% FALSE), as_tibble(as.list(g$counts)))
}
dbDisconnect(conn)
block("grades", bind_rows(grade_rows))
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
