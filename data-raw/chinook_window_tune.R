# data-raw/chinook_window_tune.R
# ---------------------------------------------------------------------------
# #226 (#105 Phase 2): is the chinook rearing rule better tuned on flow in a seasonal window than on MAD?
# research/chinook_window_flow.md ("Phase 2") sets the four readings and the verdict rule; this scores them.
#
# WHY / DESIGN NOTES:
#   - THE RULE COMES FIRST. The script refuses unless the research file, the script and R/ are committed and clean,
#     and logs the commit it read, so the verdict rule is on record before any score is made.
#   - FOUR READINGS, ONE TUNING EACH, AS THE PUBLISHED RULE WAS TUNED: knw_tune_run() for chinook rearing at its
#     defaults (five folds on seed 54, the one-SE region, 200 bootstrap resamples, nested selection, seeds 55 to
#     58, d_floor 200, link's segment gradient), link's thresholds at the published ledger's commit. A reading is
#     the column the size test reads (`cols[["mad"]]`) and the walk the exception reads (`src`): MAD or the rearing
#     window's flow on the stream, the annual walk or the spawning window's on the river.
#   - A CACHE PER READING. knw_tune_run()'s score cache records neither the size column nor the walk source, so
#     two readings in one directory would read each other's scores (the plan review, 2026-11-22). Each reading, and
#     each run without the lower Fraser, has its own directory and its label in the cache's evidence id.
#   - THE CONTROL IS THE PUBLISHED RUN. The MAD reading on the copy must give back data/tune/CH_rear_tune.csv rule
#     by rule (held-out deviance to its six decimals, the pick, the recommended rule, the region) and the summary's
#     nested selection, seeds and bootstrap share, or the script stops.
#   - THE SAME VISITS AND FOLDS. The folds depend on the visits and the seed, never on a rule, and the window flow
#     is present exactly where MAD is; the script checks the four readings scored the same groups in the same folds.
#   - THE PAIRED DIFFERENCE. The scorer's SE is of a rule's difference from the best rule of its grid, so the
#     verdict's difference is scored on a grid of two rows, the control's recommended rule and a window reading's,
#     each reading its own column and walk: the row that is not the best carries the difference and its SE over the
#     groups. Once per seed 54 to 58, and on seed 54 without the lower Fraser, where both readings are tuned again.
#   - NOTHING IS GRADED, COMPARED OR PUBLISHED. Every output is under data/tune/flow_window/, which 0325, 0330 and
#     knw_thresholds_table() never read (they list data/tune/ at its top level).
#
# INPUT:  data/fdis/derived_window/{visits_link,visits_species,walks}.csv and window_run.csv
#         (data-raw/chinook_window_evidence.R); data/tune/CH_rear_{summary,tune,seeds,honest}.csv; the evidence
#         ledger the summary names; the link repository at LINK_REPO at that ledger's commit;
#         research/chinook_window_flow.md committed. No database.
# OUTPUT: data/tune/flow_window/ch_rear_tune_run.csv        the run's record
#         data/tune/flow_window/ch_rear_readings.csv        each reading's tuning, one row each
#         data/tune/flow_window/ch_rear_pairs.csv           each window reading's rule against the control's, by seed
#                                                           and without the lower Fraser
#         data/tune/flow_window/ch_rear_verdict.csv         the three conditions and the verdict, per window reading
#         data/tune/flow_window/<reading>/CH_rear_{region,seeds,honest,groups,smoke}.csv   (region: the rules in the
#                                                           one-SE region, with the default, best and picked rules)
#         data/tune/flow_window/<reading>[_nolfra]/CH_rear_score.rds   the score cache (ignored)
# RUN:    STAGE=smoke Rscript data-raw/chinook_window_tune.R     the smoke gates of all four readings, nothing scored
#         Rscript data-raw/chinook_window_tune.R > scripts/logs/flow_window/<yyyymmdd>_chinook_window_tune.txt 2>&1
#         (repo root; WORKERS=12; the smoke gates run first and a failure stops it)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)

rule_file <- "research/chinook_window_flow.md"
ev_dir <- "data/fdis/derived_window"
out_dir <- "data/tune/flow_window"
key <- "CH_rear"
stage_run <- Sys.getenv("STAGE", "score")
if (!stage_run %in% c("smoke", "score")) stop("STAGE must be smoke or score", call. = FALSE)
workers <- as.integer(Sys.getenv("WORKERS", max(1L, min(12L, parallel::detectCores() - 2L))))
link_repo <- Sys.getenv("LINK_REPO", "../link")
stamp <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
mins <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "mins"))

git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed", call. = FALSE)
  out
}
dirty <- git("status", "--porcelain", "--", rule_file, "data-raw/chinook_window_tune.R", "R", "inst/sql",
             "DESCRIPTION")
if (length(dirty)) {
  stop("commit first, so the run record's HEAD reproduces the run: ", paste(dirty, collapse = "; "), call. = FALSE)
}
rule_commit <- git("log", "-1", "--format=%H", "--", rule_file)
if (!length(rule_commit)) stop(rule_file, " is not committed", call. = FALSE)
if (!any(grepl("^### The verdict rule", readLines(rule_file)))) stop(rule_file, " sets no verdict rule", call. = FALSE)
head_sha <- git("rev-parse", "HEAD")
cat("verdict rule:", rule_file, "at", rule_commit, "\nHEAD:        ", head_sha, "\nstage:       ", stage_run,
    "\nstarted:     ", stamp(), "\n\n")

# ---- the published run, and the copy of its evidence with a window ----
summ <- utils::read.csv(file.path("data/tune", paste0(key, "_summary.csv")), stringsAsFactors = FALSE)
tab_pub <- utils::read.csv(file.path("data/tune", paste0(key, "_tune.csv")), stringsAsFactors = FALSE)
win_run <- utils::read.csv(file.path(ev_dir, "window_run.csv"), stringsAsFactors = FALSE)
tables <- c("visits_link", "visits_species", "walks")
f_ev <- file.path(ev_dir, paste0(tables, ".csv"))
md5_ev <- paste(unname(tools::md5sum(f_ev)), collapse = ";")
if (!identical(win_run$source_md5, summ$evidence_md5)) {
  stop(ev_dir, " was not made from the published run's evidence", call. = FALSE)
}
if (!identical(win_run$out_md5, md5_ev)) stop(ev_dir, " is not the copy its run record describes", call. = FALSE)
col_rear <- win_run$column_stream
src_spawn <- win_run$src_river
cat("published run:", summ$tune_run, "recommended", summ$rule_recommended, "\nevidence:     ", ev_dir, md5_ev,
    "\n               from", summ$evidence_md5, "at", win_run$head, "\n")

vl <- readr::read_csv(f_ev[1], guess_max = 1e5, show_col_types = FALSE, progress = FALSE,
                      col_types = readr::cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c",
                                              hydro_zone = "c"))
vs <- readr::read_csv(f_ev[2], show_col_types = FALSE, progress = FALSE, guess_max = 1e5,
                      col_types = readr::cols(site_visit = "c"))
walks <- readr::read_csv(f_ev[3], show_col_types = FALSE, progress = FALSE)
if (!col_rear %in% names(vl) || !src_spawn %in% walks$src) stop(ev_dir, " carries no window", call. = FALSE)
if (!identical(is.na(vl[[col_rear]]), is.na(vl$mad_pick))) {
  stop("the window flow is not present exactly where mad_pick is", call. = FALSE)
}

# ---- link's thresholds at the published evidence's commit, as 0320 read them ----
led <- utils::read.csv(summ$evidence_ledger, stringsAsFactors = FALSE, colClasses = "character")
shas <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]]
read_thr <- function(sha, bundle) {
  f <- tempfile(fileext = ".csv")
  st <- system2("git", c("-C", link_repo, "show",
                         sprintf("%s:inst/extdata/configs/%s/parameters_habitat_thresholds.csv", sha, bundle)),
                stdout = f)
  if (!identical(st, 0L) || !file.exists(f) || file.size(f) == 0) {
    stop("could not read link's ", bundle, " thresholds at ", sha, " from ", link_repo, call. = FALSE)
  }
  f
}
thr_of <- function(bundle) {
  fs <- vapply(shas, read_thr, character(1), bundle = bundle)
  if (length(unique(unname(tools::md5sum(fs)))) != 1L) {
    stop("link's ", bundle, " thresholds differ between the run's commits", call. = FALSE)
  }
  utils::read.csv(fs[1], stringsAsFactors = FALSE)
}
thr <- thr_of("default")
thr_tuned <- thr_of("default_tuned")
cat("link thresholds at", paste(shas, collapse = ";"), "(ledger", summ$evidence_ledger, ")\n")
cat("workers:", workers, "\n\n")

# ---- the readings ----
readings <- list(
  control = c(mad = "mad_pick", src = "pick"),
  stream = c(mad = col_rear, src = "pick"),
  river = c(mad = "mad_pick", src = src_spawn),
  both = c(mad = col_rear, src = src_spawn)
)
cols_of <- function(rd) c(grad = "segment_gradient", width = "cw_deploy", mad = readings[[rd]][["mad"]])
previous <- stats::setNames(summ$rule_recommended, key)
tune <- function(rd, visits, tag = "", ...) {
  dir_rd <- file.path(out_dir, paste0(rd, tag))
  dir.create(dir_rd, showWarnings = FALSE, recursive = TRUE)
  knw_tune_run(visits, vs, walks, thr, species = "CH", stages = "rear", workers = workers,
               thresholds_extra = thr_tuned, cols = cols_of(rd), src = readings[[rd]][["src"]],
               evidence_id = paste0(md5_ev, "|", rd, tag), previous = previous, cache_dir = dir_rd, ...)[[key]]
}

# ---- the smoke gates of every reading, before any grid is scored (#84) ----
smoke_failed <- character()
for (rd in names(readings)) {
  s <- tune(rd, vl, smoke_only = TRUE)$smoke
  dir_rd <- file.path(out_dir, rd)
  utils::write.csv(cbind(species_code = "CH", stage = "rear", reading = rd,
                         dplyr::bind_rows(cbind(s$checks, table = "checks"), cbind(s$rules, table = "rules"))),
                   file.path(dir_rd, paste0(key, "_smoke.csv")), row.names = FALSE, na = "")
  if (!s$pass) smoke_failed <- c(smoke_failed, rd)
}
if (length(smoke_failed)) {
  stop("the smoke run failed on ", paste(smoke_failed, collapse = ", "), "; nothing is scored", call. = FALSE)
}
cat("\nsmoke gates passed on every reading:", paste(names(readings), collapse = ", "), "\n")
if (stage_run == "smoke") {
  cat("finished:", stamp(), "\n")
  quit(save = "no")
}

# ---- score each reading ----
parts <- function(r) {
  data.frame(size = paste0(r$size_var, ">=", r$size_min), grad = r$grad_max,
             exc = ifelse(is.na(r$exc_q), "none", sprintf("Q%g@D%g", r$exc_q, r$exc_d)))
}
runs <- list()
for (rd in names(readings)) {
  cached <- file.exists(file.path(out_dir, rd, paste0(key, "_score.rds")))
  t0 <- Sys.time()
  r <- tune(rd, vl, smoke = FALSE)
  if (is.null(r$score) || is.null(r$curve)) {
    stop(rd, ": not fitted (", r$status, "; ", r$curve_error, ")", call. = FALSE)
  }
  runs[[rd]] <- r
  cat(sprintf("%s: scored in %.1f min%s. %d rules; recommended %s (held-out %.3f); best %s (%.3f); %d in the region\n",
              rd, mins(t0), if (cached) " (a score cache was on file: read back if its settings match)" else "",
              nrow(r$score$rules), r$pick$rule, r$score$rules$dev_heldout[r$score$rules$recommended],
              r$score$rules$rule[which.min(r$score$rules$dev_heldout)], min(r$score$rules$dev_heldout),
              sum(r$score$rules$in_region)))
}

# ---- the control is the published run ----
ctl <- runs$control$score$rules
if (!identical(ctl$rule, tab_pub$rule) || max(abs(round(ctl$dev_heldout, 6) - tab_pub$dev_heldout)) > 1e-6 ||
      !identical(ctl$rule[ctl$recommended], tab_pub$rule[tab_pub$recommended]) ||
      !identical(ctl$rule[ctl$pick], tab_pub$rule[tab_pub$pick]) ||
      !identical(ctl$in_region, as.logical(tab_pub$in_region))) {
  stop("the control reading does not give the published table back", call. = FALSE)
}
ctl_summ <- c(honest = sum(runs$control$score$honest$dev_rec),
              seeds = sum(runs$control$score$seeds$recommended == runs$control$pick$rule),
              boot = ctl$boot_rec_share[ctl$recommended])
pub_summ <- c(honest = summ$honest_dev_rec, seeds = summ$seeds_same_rec, boot = summ$boot_rec_share)
if (any(abs(ctl_summ - pub_summ) > 1e-3)) {
  stop("the control's nested selection, seeds or bootstrap share are not the published summary's: ",
       paste(names(ctl_summ), signif(ctl_summ, 7), collapse = ", "), call. = FALSE)
}
cat(sprintf(paste("\ncontrol = published run %s: %d rules' held-out deviance equal to 1e-6, the same pick,",
                  "recommended rule and region; nested selection %.3f, %d of %d seeds on the same rule,",
                  "bootstrap share %.3f\n"),
            summ$tune_run, nrow(ctl), ctl_summ[["honest"]], as.integer(ctl_summ[["seeds"]]),
            nrow(runs$control$score$seeds), ctl_summ[["boot"]]))

# ---- the same visits, groups and folds on every reading ----
pop0 <- runs$control$score$population
for (rd in names(readings)) {
  r <- runs[[rd]]
  if (!identical(r$score$folds, runs$control$score$folds) ||
        !identical(r$score$population[c("visits_in", "visits_modelled")], pop0[c("visits_in", "visits_modelled")]) ||
        !identical(r$score$rules$n_detect[1], ctl$n_detect[1])) {
    stop(rd, " did not score the control's visits in the control's folds", call. = FALSE)
  }
}
cat(sprintf("every reading scored the same %d visits (%d with CH) of %d groups, in the same folds\n",
            ctl$n_visits[1], ctl$n_detect[1], ctl$n_wsg[1]))

# ---- each reading's tables ----
nz <- function(x) if (is.null(x)) NA else x   # a run whose curve did not fit still has its scores
reading_row <- function(rd, r) {
  rules <- r$score$rules
  rec <- rules[rules$recommended, , drop = FALSE]
  best <- rules[which.min(rules$dev_heldout), , drop = FALSE]
  dflt <- rules[rules$is_default, , drop = FALSE]
  by_rule <- function(x) rules[match(x, rules$rule), , drop = FALSE]
  share <- function(x) {   # of a set of picked rules, the share on the recommended rule, and on each of its parts
    p <- parts(x)
    c(rule = mean(x$rule == rec$rule), size = mean(p$size == parts(rec)$size), grad = mean(p$grad == parts(rec)$grad),
      exc = mean(p$exc == parts(rec)$exc))
  }
  out <- data.frame(
    reading = rd, size_column = readings[[rd]][["mad"]], walk_src = readings[[rd]][["src"]], status = r$status,
    visits_in = r$population[["visits_in"]], detections = r$population[["detections"]],
    groups = r$population[["groups"]], visits_scored = rec$n_visits, detections_scored = rec$n_detect,
    groups_scored = rec$n_wsg, rules = nrow(rules), patterns = r$score$population[["patterns"]],
    rule_recommended = rec$rule, dev_recommended = rec$dev_heldout, n_in = rec$n_in, n_detect_in = rec$n_detect_in,
    rule_best = best$rule, dev_best = best$dev_heldout, recommended_behind_best = rec$ddev_best,
    recommended_se = rec$se_diff, region_n = sum(rules$in_region),
    default_in_region = dflt$in_region, dev_default = dflt$dev_heldout,
    dev_null = best$dev_heldout - best$ddev_null,
    dev_curve = nz(r$curve$heldout), null_heldout_curve = nz(r$null_heldout_curve),
    curve_visits = if (is.null(r$curve)) NA_integer_ else nrow(r$curve$data), grade_withheld = nz(r$grade_withheld)
  )
  if (!is.null(r$score$honest)) {
    h <- share(by_rule(r$score$honest$rule))
    s <- share(by_rule(r$score$seeds$recommended))
    b <- share(r$score$boot_recs)
    out <- cbind(out, data.frame(
      honest_dev_rec = sum(r$score$honest$dev_rec), honest_dev_default = sum(r$score$honest$dev_default),
      honest_dev_null = sum(r$score$honest$dev_null),
      honest_folds = nrow(r$score$honest), honest_same_rule = h[["rule"]] * nrow(r$score$honest),
      honest_same_size = h[["size"]] * nrow(r$score$honest), honest_same_grad = h[["grad"]] * nrow(r$score$honest),
      honest_same_exc = h[["exc"]] * nrow(r$score$honest),
      seeds_n = nrow(r$score$seeds), seeds_same_rule = s[["rule"]] * nrow(r$score$seeds),
      seeds_same_size = s[["size"]] * nrow(r$score$seeds), seeds_same_grad = s[["grad"]] * nrow(r$score$seeds),
      seeds_same_exc = s[["exc"]] * nrow(r$score$seeds),
      seeds_rec_in_region = sum(r$score$seeds$main_rec_in_region),
      boot_n = nrow(r$score$boot_recs), boot_share_rule = b[["rule"]], boot_share_size = b[["size"]],
      boot_share_grad = b[["grad"]], boot_share_exc = b[["exc"]]
    ))
  }
  out
}
rows <- list()
for (rd in names(readings)) {
  r <- runs[[rd]]
  dir_rd <- file.path(out_dir, rd)
  rules <- r$score$rules
  keep <- rules$in_region | rules$is_default | rules$ddev_best == 0 | rules$pick | rules$recommended |
    rules$is_link_tuned %in% TRUE | rules$pick_flow %in% TRUE | rules$recommended_flow %in% TRUE
  num <- vapply(rules, is.double, logical(1))
  region <- rules[keep, , drop = FALSE]
  region[num] <- lapply(region[num], round, 6)
  utils::write.csv(cbind(reading = rd, region[order(region$ddev_best), ]),
                   file.path(dir_rd, paste0(key, "_region.csv")), row.names = FALSE, na = "")
  utils::write.csv(cbind(reading = rd, r$score$seeds), file.path(dir_rd, paste0(key, "_seeds.csv")),
                   row.names = FALSE, na = "")
  honest <- as.data.frame(r$score$honest)
  hnum <- vapply(honest, is.double, logical(1))
  honest[hnum] <- lapply(honest[hnum], round, 6)
  utils::write.csv(cbind(reading = rd, honest), file.path(dir_rd, paste0(key, "_honest.csv")), row.names = FALSE,
                   na = "")
  utils::write.csv(data.frame(reading = rd, watershed_group_code = names(r$score$folds),
                              fold = as.integer(r$score$folds)),
                   file.path(dir_rd, paste0(key, "_groups.csv")), row.names = FALSE, na = "")
  rows[[rd]] <- reading_row(rd, r)
}
readings_tab <- do.call(rbind, rows)

# ---- the paired difference: a window reading's recommended rule against the control's ----
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
wi <- knw_walk_index(walks)
pop_of <- function(visits) .tune_population(.tune_base(visits, edge_stream, eval(fm$area_range)), vs, "CH", "rear")$d
rule_in_pair <- function(dd, r) {
  knw_rule_in(dd, r, walks = wi, cols = c(grad = "segment_gradient", width = "cw_deploy", mad = r$size_column),
              src = r$walk_src, edge_stream = edge_stream)
}
pair_grid <- function(rd, rec_ctl, rec_win) {
  g <- rbind(rec_ctl, rec_win)[, c("size_var", "size_min", "grad_max", "exc_q", "exc_d")]
  g$reading <- c("control", rd)
  g$rule <- paste0(g$reading, ": ", c(rec_ctl$rule, rec_win$rule))
  g$size_column <- c(readings$control[["mad"]], readings[[rd]][["mad"]])
  g$walk_src <- c(readings$control[["src"]], readings[[rd]][["src"]])
  g$departures <- 0:1
  g$is_default <- c(TRUE, FALSE)
  g
}
# the difference (window less control; negative favours the window) and its SE over the groups
pair <- function(rd, d, rec_ctl, rec_win, seed, population) {
  g <- pair_grid(rd, rec_ctl, rec_win)
  s <- knw_tune_score(d, rule_in_pair, g, "U", seed = seed, folds = eval(fm$folds), d_floor = eval(fm$d_floor),
                      workers = 1L, extra = FALSE, fit = eval(fm$fit)[1], prior_sd = eval(fm$prior_sd))$rules
  data.frame(reading = rd, population = population, seed = seed, groups = s$n_wsg[1], visits = s$n_visits[1],
             rule_control = rec_ctl$rule, rule_window = rec_win$rule,
             dev_control = s$dev_heldout[1], dev_window = s$dev_heldout[2],
             difference = s$dev_heldout[2] - s$dev_heldout[1], se = max(s$se_diff),
             converged = all(s$converged))
}
rec_of <- function(r) r$score$rules[r$score$rules$recommended, , drop = FALSE]
d_all <- pop_of(vl)
windows_rd <- setdiff(names(readings), "control")
pairs <- list()
for (rd in windows_rd) {
  for (seed in c(eval(fm$seed), eval(fm$seeds_more))) {
    pairs[[length(pairs) + 1L]] <- pair(rd, d_all, rec_of(runs$control), rec_of(runs[[rd]]), seed, "all groups")
  }
  # on the main seed the pair's scores are the readings' own
  p54 <- pairs[[length(pairs) - length(eval(fm$seeds_more))]]
  if (abs(p54$dev_control - rec_of(runs$control)$dev_heldout) > 1e-6 ||
        abs(p54$dev_window - rec_of(runs[[rd]])$dev_heldout) > 1e-6) {
    stop(rd, ": the pair's held-out deviance on seed ", p54$seed, " is not the readings' own", call. = FALSE)
  }
}

# ---- without the lower Fraser: every reading tuned again on the main seed ----
vl_no <- vl[vl$watershed_group_code != "LFRA", , drop = FALSE]
d_no <- pop_of(vl_no)
runs_no <- list()
for (rd in names(readings)) {
  t0 <- Sys.time()
  runs_no[[rd]] <- tune(rd, vl_no, tag = "_nolfra", smoke = FALSE, extra = FALSE)
  if (is.null(runs_no[[rd]]$score)) stop(rd, " without LFRA: not fitted (", runs_no[[rd]]$status, ")", call. = FALSE)
  rn <- rec_of(runs_no[[rd]])
  cat(sprintf(paste("%s without LFRA: scored in %.1f min; %d visits (%d with CH) of %d groups;",
                    "recommended %s (held-out %.3f)\n"),
              rd, mins(t0), rn$n_visits, rn$n_detect, rn$n_wsg, rn$rule, rn$dev_heldout))
  rows[[paste0(rd, "_nolfra")]] <- cbind(reading_row(rd, runs_no[[rd]]), population = "without LFRA")
}
for (rd in windows_rd) {
  pairs[[length(pairs) + 1L]] <- pair(rd, d_no, rec_of(runs_no$control), rec_of(runs_no[[rd]]), eval(fm$seed),
                                      "without LFRA")
}
pairs <- do.call(rbind, pairs)

# ---- the verdict, by the rule set before the run ----
verdict <- do.call(rbind, lapply(windows_rd, function(rd) {
  p <- pairs[pairs$reading == rd, , drop = FALSE]
  main <- p[p$population == "all groups" & p$seed == eval(fm$seed), ]
  more <- p[p$population == "all groups" & p$seed != eval(fm$seed), ]
  no <- p[p$population == "without LFRA", ]
  c1 <- main$difference < 0 && abs(main$difference) > main$se
  c2 <- sum(more$difference < 0) >= 3L
  c3 <- no$difference < 0
  data.frame(reading = rd, difference = main$difference, se = main$se, main_seed_beyond_one_se = c1,
             other_seeds_negative = sum(more$difference < 0), other_seeds = nrow(more), other_seeds_hold = c2,
             difference_without_lfra = no$difference, without_lfra_holds = c3, beats_mad = c1 && c2 && c3)
}))
cat("\n## each reading's tuning\n")
print(readings_tab[, c("reading", "rule_recommended", "dev_recommended", "rule_best", "dev_best", "region_n",
                       "dev_curve", "honest_dev_rec", "seeds_same_rule", "boot_share_rule")], row.names = FALSE)
cat("\n## a window reading's recommended rule less the control's (held-out deviance; negative favours the window)\n")
print(pairs, row.names = FALSE)
cat("\n## the verdict\n")
print(verdict, row.names = FALSE)
cat("\nverdict:", if (any(verdict$beats_mad)) {
  paste("BEATS MAD:", paste(verdict$reading[verdict$beats_mad][order(verdict$difference[verdict$beats_mad])],
                            collapse = ", "))
} else {
  "NO WINDOW READING BEATS MAD by the rule set before the run"
}, "\n")

# ---- write ----
num_round <- function(x) {
  num <- vapply(x, is.double, logical(1))
  x[num] <- lapply(x[num], round, 6)
  x
}
readings_tab$population <- "all groups"
all_rows <- dplyr::bind_rows(c(list(readings_tab), rows[grepl("_nolfra$", names(rows))]))
utils::write.csv(num_round(all_rows), file.path(out_dir, "ch_rear_readings.csv"), row.names = FALSE, na = "")
utils::write.csv(num_round(pairs), file.path(out_dir, "ch_rear_pairs.csv"), row.names = FALSE, na = "")
utils::write.csv(num_round(verdict), file.path(out_dir, "ch_rear_verdict.csv"), row.names = FALSE, na = "")
run <- data.frame(
  rule_file = rule_file, rule_commit = rule_commit, head = head_sha, tune_run = summ$tune_run,
  evidence_dir = ev_dir, evidence_md5 = md5_ev, source_md5 = summ$evidence_md5, evidence_head = win_run$head,
  evidence_ledger = summ$evidence_ledger, link_sha = paste(shas, collapse = ";"),
  size_column = col_rear, walk_src = src_spawn, seed = eval(fm$seed), folds = eval(fm$folds),
  n_boot = eval(fm$n_boot), seeds_more = paste(eval(fm$seeds_more), collapse = ";"), d_floor = eval(fm$d_floor),
  prior_sd = eval(fm$prior_sd), visits = ctl$n_visits[1], ch = ctl$n_detect[1], groups = ctl$n_wsg[1],
  rules = nrow(ctl), control_is_published = TRUE,
  verdict = if (any(verdict$beats_mad)) paste(verdict$reading[verdict$beats_mad], collapse = ";") else "none",
  workers = workers, wet_version = as.character(utils::packageVersion("wet")),
  mgcv_version = as.character(utils::packageVersion("mgcv")), r_version = as.character(getRversion())
)
utils::write.csv(run, file.path(out_dir, "ch_rear_tune_run.csv"), row.names = FALSE, na = "")
cat("\nwrote", out_dir, "\nfinished:", stamp(), "\n")
