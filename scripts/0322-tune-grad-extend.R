# scripts/0322-tune-grad-extend.R
# ---------------------------------------------------------------------------
# CH rearing's recommended rule (mad>=0.75|g<=0.09|Q3@D1000) takes the steepest gradient maximum 0320
# scored, so its tuning could not say whether a steeper limit scores as well. This run scores CH rearing
# again with the gradient ladder extended to 11, 13 and 15 %, and sets the steeper rules beside the
# recommended one on link's segments. Issue #67. Input from 0310 and 0320; nothing downstream reads it
# (0325 and 0330 list data/tune/ and data/compare/ non-recursively).
#
# WHY / DESIGN NOTES:
#   - SAME SPEC AS 0320 except the ladder: the same evidence build, link's thresholds at the ledger's
#     commit, knw_tune_run()'s defaults for seed (54), folds (5), bootstrap (200), more seeds (55-58)
#     and d_floor (200). Folds and the bootstrap depend on the visits and the seeds, not on the grid, so
#     the 2,795 rules the two grids share must score the same; the log checks it.
#   - EVERY SPECIES IS TUNED ON ONE SHARED LADDER (knw_tune_grid()), so this run measures and records:
#     it writes no thresholds and changes no published rule (#67's plan gate, 2026-10-18).
#   - COMPARE (STAGE=compare): for each steeper gradient, the recommended rule's size test and exception
#     with that gradient maximum. knw_grade_species() walks the exception's distance only for segments
#     inside the pick's gradient maximum, so each candidate is graded at its own rule before its
#     comparison; the curve is 0320's (fitted at the 9 % pick), so graded km above 9 % reads the curve
#     past the gradients its pick admitted and is provisional. The candidate's segments are then joined
#     to 0330's recommended-rule segments on (id_segment, watershed_group_code): id_segment repeats
#     across groups.
#   - The extended run's own curve (grad_ext/CH_rear_curve.rds) is written for the record; the compare
#     does not read it. Regrading moves the grades' 95th-percentile reference, so every segment's grade
#     shifts a little, not only the band's: graded km here is provisional on that count too.
#   - "Stream edges" are the comparison's own test (FWA edge types 1000/1100/2000/2300); the segments
#     carry no waterbody key, so added km off them is logged by edge type.
#   - RIVER POLYGONS: link applies the stream gradient maximum to river polygons too; the scoring sees no
#     river-polygon visit. The km a steeper maximum adds off the stream edges is reported on its own.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (0310); the evidence build ledger;
#         the link repository at LINK_REPO at the build's link_sha; for STAGE=compare also
#         data/tune/CH_rear_curve.rds (0320), data/compare/CH_rear_segments.rds (0330) and the fwapg
#         database (PG* env vars): fresh_default
# WRITES: (STAGE=compare) schemas knw_gx_ch_rear_g<pct> in the fwapg database (scratch; dropped)
# OUTPUT: data/tune/grad_ext/CH_rear_{tune,seeds,honest,groups,summary}.csv   the extended grid's scores
#         data/tune/grad_ext/CH_rear_by_grad.csv     per gradient maximum: best rule, its deviance behind the
#                                                    best and SE, region rules, bootstrap shares (the article)
#         data/tune/grad_ext/CH_rear_{score,curve}.rds                         (ignored)
#         data/compare/grad_ext/CH_rear_g<pct>_{compare,change,checks}.csv     each steeper rule beside default
#         data/compare/grad_ext/CH_rear_g<pct>_segments.rds                    (ignored)
#         data/compare/grad_ext/CH_rear_beside_recommended.csv                 km added and removed beside the
#                                                                              recommended rule, by reason
#         scripts/logs/habitat/<date>_tune_grad_extend.txt, <date>_tune_grad_extend-compare.txt
# RUN:    Rscript scripts/0322-tune-grad-extend.R                  (from the repo root; WORKERS=8)
#         STAGE=compare Rscript scripts/0322-tune-grad-extend.R    (after the scoring; WORKERS=3 jobs)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

link_repo <- Sys.getenv("LINK_REPO", "../link")
stage_run <- Sys.getenv("STAGE", "score")
if (!stage_run %in% c("score", "compare")) stop("STAGE must be 'score' or 'compare', not '", stage_run, "'")
workers <- as.integer(Sys.getenv("WORKERS", if (stage_run == "score") max(1L, min(8L, parallel::detectCores() - 2L)) else 3L))
schema <- "fresh_default"
key <- "CH_rear"
grid_grad <- c(0.03, 0.04, 0.0549, 0.07, 0.09, 0.11, 0.13, 0.15)
grad_new <- c(0.11, 0.13, 0.15)
dir_tune <- "data/tune/grad_ext"
dir_cmp <- "data/compare/grad_ext"
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_tune_grad_extend",
                                                     if (stage_run == "compare") "-compare", ".txt"))
for (d in c(dir_tune, dir_cmp)) dir.create(d, showWarnings = FALSE, recursive = TRUE)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}
pct <- function(g) sprintf("g%02d", round(100 * g))

# ---- inputs and their provenance ------------------------------------------------------
ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
if (is.na(ledger_path)) stop("no evidence build ledger: run scripts/0310 first")
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
shas <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]]
link_sha <- shas[1]
say("CH rearing, gradient ladder extended (knowledge#67), stage %s. Evidence build %s on link run %s (link %s).",
    stage_run, ledger_path, run_uid, paste(shas, collapse = ";"))
# the inputs must be the ones 0320 scored on, or the comparison with its grid means nothing
log_0320 <- readLines("scripts/logs/habitat/20261017_tune_run-bt_ch_co_st.txt", n = 6)
for (f in c("visits_link", "visits_species", "walks")) {
  m <- unname(tools::md5sum(file.path("data/fdis/derived", paste0(f, ".csv"))))
  say("  %s md5 %s", f, m)
  if (!any(grepl(paste(f, "md5", m), log_0320, fixed = TRUE))) stop(f, " is not the table 0320 scored CH rearing on")
}
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))

# link's configs at the run's commit (0320 checks the thresholds are the same text at each logged commit)
link_dir <- file.path(tempdir(), paste0("link_default_", substr(link_sha, 1, 7)))
dir.create(file.path(link_dir, "overrides"), showWarnings = FALSE, recursive = TRUE)
cfgs <- c("parameters_habitat_thresholds.csv", "rules.yaml", "parameters_fresh.csv", "overrides/user_habitat_classification.csv")
for (p in if (stage_run == "score") cfgs[1] else cfgs) {
  out <- file.path(link_dir, p)
  st <- system2("git", c("-C", link_repo, "show", paste0(link_sha, ":inst/extdata/configs/default/", p)), stdout = out)
  if (!identical(st, 0L) || !file.exists(out) || file.size(out) == 0) stop("could not read ", p, " at link ", link_sha, " from ", link_repo)
}
thr <- read.csv(file.path(link_dir, "parameters_habitat_thresholds.csv"), stringsAsFactors = FALSE)
say("link configs/default at %s read from %s.", link_sha, link_repo)

if (stage_run == "score") {
  # ---- score the extended grid -------------------------------------------------------------
  walks <- read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE)
  t0 <- Sys.time()
  out <- knw_tune_run(vl, vs, walks, thr, species = "CH", stages = "rear", workers = workers,
                      grid_args = list(grid_grad = grid_grad), cache_dir = dir_tune)
  r <- out[[key]]
  say("Scored %s in %.1f min on %d workers: %s, %d rules, %s.", key, as.numeric(difftime(Sys.time(), t0, units = "mins")),
      workers, r$status, nrow(r$score$rules), paste(names(r$score$population), r$score$population, sep = "=", collapse = ", "))
  if (is.null(r$curve)) stop(key, ": no curve (", r$status, "): ", r$curve_error)
  rules <- r$score$rules |> mutate(species_code = r$species_code, stage = r$stage, response = r$response, status = r$status)
  write_csv(rules |> mutate(across(where(is.numeric), ~ round(.x, 6))), file.path(dir_tune, paste0(key, "_tune.csv")), na = "")
  write_csv(tibble(species_code = r$species_code, stage = r$stage, watershed_group_code = names(r$score$folds),
                   fold = as.integer(r$score$folds)), file.path(dir_tune, paste0(key, "_groups.csv")), na = "")
  write_csv(as_tibble(r$score$seeds) |> mutate(species_code = r$species_code, stage = r$stage),
            file.path(dir_tune, paste0(key, "_seeds.csv")), na = "")
  write_csv(as_tibble(r$score$honest) |> mutate(across(where(is.double), ~ round(.x, 6)),
                                                species_code = r$species_code, stage = r$stage),
            file.path(dir_tune, paste0(key, "_honest.csv")), na = "")
  dflt <- rules |> filter(is_default)
  best <- rules |> filter(ddev_best == 0) |> slice(1)
  summ <- tibble(species_code = r$species_code, stage = r$stage, response = r$response, status = r$status,
                 visits_in = r$population[["visits_in"]], detections = r$population[["detections"]],
                 groups = r$population[["groups"]], groups_both = r$population[["groups_both"]],
                 grid_grad = paste(grid_grad, collapse = ";"), rules_n = nrow(rules),
                 rule_recommended = r$pick$rule, rule_pick = rules$rule[rules$pick], rule_best = best$rule,
                 default_in_region = dflt$in_region, default_ddev = dflt$ddev_best, default_se = dflt$se_diff,
                 region_n = sum(rules$in_region), patterns = r$score$population[["patterns"]],
                 dev_default = dflt$dev_heldout, dev_best = best$dev_heldout, dev_curve = r$curve$heldout,
                 honest_dev_rec = sum(r$score$honest$dev_rec), honest_dev_default = sum(r$score$honest$dev_default),
                 seeds_same_rec = sum(r$score$seeds$recommended == r$pick$rule), seeds_n = nrow(r$score$seeds),
                 boot_rec_share = rules$boot_rec_share[rules$recommended])
  write_csv(summ |> mutate(across(where(is.numeric), ~ round(.x, 4))), file.path(dir_tune, paste0(key, "_summary.csv")), na = "")
  saveRDS(r[c("species_code", "stage", "response", "status", "pick", "curve")], file.path(dir_tune, paste0(key, "_curve.rds")))
  say("%s: recommended %s; pick %s; best %s (held-out deviance %.2f); %d rules in the region.",
      key, r$pick$rule, rules$rule[rules$pick], best$rule, best$dev_heldout, sum(rules$in_region))

  # ---- what the extended ladder says, by gradient --------------------------------------------
  by_grad <- rules |> group_by(grad_max) |> arrange(dev_heldout, .by_group = TRUE) |>
    summarise(rules = n(), best_rule = first(rule), ddev_best = first(ddev_best), se_diff = first(se_diff),
              in_region = sum(in_region), boot_rec_share = sum(boot_rec_share),
              boot_region_share_max = max(boot_region_share), .groups = "drop")
  boot_grad <- as.data.frame(table(grad_max = r$score$boot_recs$grad_max) / nrow(r$score$boot_recs))
  # a steeper rule that admits no visit the 9 % one does not ties it, and ties go to the lower gradient
  at9 <- rules |> filter(grad_max == 0.09) |> select(size_var, size_min, exc_q, exc_d, dev_9 = dev_heldout)
  ties <- rules |> filter(grad_max > 0.09) |> left_join(at9, by = c("size_var", "size_min", "exc_q", "exc_d")) |>
    group_by(grad_max) |> summarise(rules = n(), tie_with_9 = sum(abs(dev_heldout - dev_9) < 1e-8),
                                    better_than_9 = sum(dev_heldout < dev_9 - 1e-8), .groups = "drop")
  write_csv(by_grad |> mutate(across(where(is.double), ~ round(.x, 6)), species_code = r$species_code, stage = r$stage),
            file.path(dir_tune, paste0(key, "_by_grad.csv")), na = "")
  block("rules above 9 % against the same rule at 9 %: ties and rules scoring better", ties)
  block("best rule per gradient maximum (held-out deviance behind the best, SE of the difference; region rules; bootstrap shares)", by_grad)
  block("bootstrap: share of the 200 draws whose recommended rule has each gradient maximum", boot_grad)
  block("region", rules |> filter(in_region) |> arrange(ddev_best) |>
          select(rule, departures, ddev_best, se_diff, n_wsg_varies, n_in, n_detect_in, raw_rate_in, boot_region_share, boot_rec_share))
  block("nested selection", r$score$honest)
  block("more seeds", r$score$seeds)
  say("More seeds: recommended has a gradient maximum above 9 %% on %d of %d; best above 9 %% on %d of %d.",
      sum(as.numeric(sub(".*\\|g<=([0-9.]+)\\|.*", "\\1", r$score$seeds$recommended)) > 0.09), nrow(r$score$seeds),
      sum(as.numeric(sub(".*\\|g<=([0-9.]+)\\|.*", "\\1", r$score$seeds$best)) > 0.09), nrow(r$score$seeds))

  # ---- regression: the rules both grids hold score the same ------------------------------------
  # against 0320's unrounded scores, by rule (the two grids order their rules differently); 0320 scored on
  # another host, so equal means within 1e-8, not bit-identical
  old <- readRDS(file.path("data/tune", paste0(key, "_score.rds")))$rules
  both <- inner_join(old |> select(rule, dev_old = dev_heldout, region_old = in_region, rec_old = recommended),
                     rules |> select(rule, dev_heldout, in_region, recommended), by = "rule")
  dmax <- max(abs(both$dev_old - both$dev_heldout))
  say("Regression: %d of %d rules of 0320's grid are in this one; %d equal in dev_heldout within 1e-8 (largest difference %.2g).",
      nrow(both), nrow(old), sum(abs(both$dev_old - both$dev_heldout) < 1e-8), dmax)
  say("Regression: region membership on the shared rules moved for %d; recommended was %s, is %s; best was %s, is %s.",
      sum(both$region_old != both$in_region), old$rule[old$recommended], r$pick$rule, old$rule[old$ddev_best == 0][1], best$rule)
  if (nrow(both) != nrow(old) || dmax >= 1e-8) say("REGRESSION FAILED: shared rules scored differently.")
  say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
  writeLines(log_lines, path_log)
  quit(save = "no")
}

# ---- STAGE=compare: each steeper rule beside default, then beside the recommended rule --------------
t0 <- Sys.time()
tune <- read_csv(file.path(dir_tune, paste0(key, "_tune.csv")), show_col_types = FALSE)
rec <- tune |> filter(recommended)
cands <- lapply(grad_new, function(g) {
  x <- tune |> filter(size_var == rec$size_var, size_min == rec$size_min, grad_max == g,
                      (is.na(exc_q) & is.na(rec$exc_q)) | (exc_q %in% rec$exc_q & exc_d %in% rec$exc_d))
  if (nrow(x) != 1L) stop("no single rule with ", rec$rule, "'s parts at gradient ", g)
  x
})
names(cands) <- vapply(grad_new, pct, character(1))
say("Recommended rule on the extended grid: %s. Candidates: %s.", rec$rule,
    paste(vapply(cands, `[[`, character(1), "rule"), collapse = ", "))
main <- readRDS(file.path("data/tune", paste0(key, "_curve.rds")))
say("Curve: 0320's, fitted at %s (graded km above its gradient maximum is provisional).", main$pick$rule)
conn <- pg()
wsg <- dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_ch ORDER BY 1", schema))$w
dbDisconnect(conn)
say("%d CH groups.", length(wsg))

# grade each candidate at its own rule, one at a time (each walk already runs on several workers)
for (k in names(cands)) {
  gpath <- file.path(dir_cmp, paste0(key, "_", k, "_grades.rds"))
  if (file.exists(gpath)) { say("%s grades: on file, kept.", k); next }
  t1 <- Sys.time()
  g <- knw_grade_species(pg, schema, "CH", wsg, main$curve, cands[[k]], stage = "rear", workers = 8L)
  saveRDS(g$grades[, c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class")], gpath)
  say("%s grades: %s; walks %.1f min; total %.1f min.", k, paste(names(g$counts), g$counts, sep = "=", collapse = ", "),
      g$walk_minutes, as.numeric(difftime(Sys.time(), t1, units = "mins")))
}

# compare the candidates against default, in parallel, each in its own scratch schema
run_one <- function(k, cand, schema, wsg, link_dir, vl, vs, key, dir_cmp) {
  pkgload::load_all(quiet = TRUE)
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  t1 <- Sys.time()
  tryCatch({
    grades <- readRDS(file.path(dir_cmp, paste0(key, "_", k, "_grades.rds")))
    cmp <- knw_compare_rules(pg, schema, "CH", "rear", cand, wsg, link_dir, grades, visits = vl, visit_species = vs,
                             scratch = paste0("knw_gx_", tolower(key), "_", k))
    for (t in c("compare", "change", "checks")) {
      if (!is.null(cmp[[t]])) readr::write_csv(cmp[[t]], file.path(dir_cmp, paste0(key, "_", k, "_", t, ".csv")), na = "")
    }
    saveRDS(cmp$segments, file.path(dir_cmp, paste0(key, "_", k, "_segments.rds")))
    list(key = k, minutes = as.numeric(difftime(Sys.time(), t1, units = "mins")), log = cmp$log, error = NULL)
  }, error = function(e) list(key = k, error = conditionMessage(e)))
}
todo <- names(cands)[!file.exists(file.path(dir_cmp, paste0(key, "_", names(cands), "_segments.rds")))]
if (length(todo)) {
  cl <- parallel::makeCluster(min(workers, length(todo)))
  res <- parallel::clusterMap(cl, run_one, todo, cands[todo],
                              MoreArgs = list(schema = schema, wsg = wsg, link_dir = link_dir, vl = vl, vs = vs,
                                              key = key, dir_cmp = dir_cmp), .scheduling = "dynamic")
  parallel::stopCluster(cl)
  for (x in res) {
    if (!is.null(x$error)) say("%s compare FAILED: %s", x$key, x$error) else say("%s compare: %.1f min.", x$key, x$minutes)
  }
  if (any(vapply(res, function(x) !is.null(x$error), logical(1)))) { writeLines(log_lines, path_log); stop("a comparison failed") }
}
# fresh_default must still hold the link run 0330 compared on: regenerated default, per group, as 0330's
cmp0 <- read_csv(file.path("data/compare", paste0(key, "_compare.csv")), show_col_types = FALSE)
for (k in names(cands)) {
  ck <- read_csv(file.path(dir_cmp, paste0(key, "_", k, "_compare.csv")), show_col_types = FALSE) |>
    inner_join(cmp0 |> select(watershed_group_code, default_0330 = default_km), by = "watershed_group_code")
  dd <- max(abs(ck$default_km - ck$default_0330))
  say("%s: regenerated default against 0330's, %d groups, largest difference %.3g km.", k, nrow(ck), dd)
  if (nrow(ck) != nrow(cmp0) || dd > 1e-6) stop(k, ": default differs from 0330's; fresh_default has moved since 0330")
}
for (k in names(cands)) {
  tot <- read_csv(file.path(dir_cmp, paste0(key, "_", k, "_compare.csv")), show_col_types = FALSE) |> filter(watershed_group_code == "ALL")
  say("%s (%s) beside default: default %.0f km, tuned %.0f km; gained %.0f, lost %.0f.", k, cands[[k]]$rule,
      tot$default_km, tot$tuned_km, tot$gained_km, tot$lost_km)
}

# ---- beside the recommended rule ---------------------------------------------------------------
cols_seg <- c("id_segment", "watershed_group_code", "edge_type", "stream_order", "length_metre", "gradient", "knw_size",
              "knw_dist", "rearing_pre_tuned", "rearing_tuned")
base <- readRDS(file.path("data/compare", paste0(key, "_segments.rds")))[, cols_seg]
if (!identical(unique(read_csv(file.path("data/compare", paste0(key, "_change.csv")), show_col_types = FALSE)$tuned_rule), rec$rule)) {
  stop("data/compare/", key, "_segments.rds is not the recommended rule's (", rec$rule, ")")
}
edge_stream <- c(1000L, 1100L, 2000L, 2300L)
fv <- vs |> filter(species_code == "CH", status %in% c("present", "absent")) |> select(site_visit, present) |>
  inner_join(vl |> filter(!is.na(area_m2), area_m2 >= 10, area_m2 <= 10000) |>
               select(site_visit, id_segment, watershed_group_code, edge_type, wb_river), by = "site_visit")
beside <- list()
for (k in names(cands)) {
  cand <- cands[[k]]
  s <- readRDS(file.path(dir_cmp, paste0(key, "_", k, "_segments.rds")))[, cols_seg]
  j <- inner_join(base, s, by = c("id_segment", "watershed_group_code"), suffix = c("_rec", "_new"))
  if (nrow(j) != nrow(base) || nrow(j) != nrow(s)) stop(k, ": segments do not match the recommended rule's one to one")
  j <- j |> filter(rearing_tuned_rec != rearing_tuned_new) |>
    mutate(direction = if_else(rearing_tuned_new, "added", "removed"),
           band = !is.na(gradient_new) & gradient_new > rec$grad_max & gradient_new <= cand$grad_max,
           stream = edge_type_new %in% edge_stream,
           size_ok = !is.na(knw_size_new) & knw_size_new >= cand$size_min,
           exc_ok = !is.na(cand$exc_q) & !is.na(knw_dist_new) & knw_dist_new <= cand$exc_d,
           reason = case_when(rearing_pre_tuned_rec == rearing_pre_tuned_new ~ "connectivity or overlay",
                              band & stream & size_ok ~ "stream edge in the band, size passes",
                              band & stream & exc_ok ~ "stream edge in the band, exception",
                              band & !stream ~ "off the stream edges in the band (river-polygon branch and others)",
                              TRUE ~ "other"))
  vis <- fv |> inner_join(j |> select(id_segment, watershed_group_code, direction, reason), by = c("id_segment", "watershed_group_code"))
  tab <- j |> group_by(direction, reason) |> summarise(n_segments = n(), km = sum(length_metre_new) / 1000, .groups = "drop") |>
    left_join(vis |> group_by(direction, reason) |> summarise(visits = n(), detections = sum(present), .groups = "drop"),
              by = c("direction", "reason")) |>
    mutate(rule = cand$rule, recommended = rec$rule, .before = 1)
  beside[[k]] <- tab
  edges <- j |> filter(direction == "added", band, !stream) |> count(edge_type = edge_type_new, wt = length_metre_new / 1000, name = "km")
  say("%s beside %s: added %.0f km, removed %.0f km.", cand$rule, rec$rule, sum(tab$km[tab$direction == "added"]),
      sum(tab$km[tab$direction == "removed"]))
  block(paste(k, "beside the recommended rule, by reason (km; FDIS visits and CH detections on those segments)"), tab)
  block(paste(k, "added km off the stream edges in the band, by FWA edge type"), edges)
}
beside <- bind_rows(beside) |> mutate(across(where(is.double), ~ round(.x, 3)))
write_csv(beside, file.path(dir_cmp, paste0(key, "_beside_recommended.csv")), na = "")
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
