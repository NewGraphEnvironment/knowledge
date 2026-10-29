# data-raw/compare_structures_check.R
# ---------------------------------------------------------------------------
# A comparison of `default` and the reported structure alone is the comparison under every structure, less the
# others (#112): knw_compare_rules(structures = "reported"), what scripts/0330-compare.R now runs unless
# STRUCTURES=all, must return the rows the every-structure run returns for `default` and the reported structure. It
# also times both, rule by rule, which is the measurement #112 asked for before the default changed, and reports how
# the every-structure run stands against #92's tracked tables. Three keys: WCT rearing on every group it has a habitat
# table in (16; two structures), the one held to the tracked data/compare/WCT_rear_* tables; CH rearing (three
# structures, and the only species whose `default` walks a near-river pair) and BT rearing (two structures, the
# longest comparison) on their 20 largest groups by segment count, for the minutes.
#
# METHOD: for each key, knw_compare_rules() twice on the same connection settings: structures = NULL (the species'
# own set, today's behaviour) and structures = "reported" (TUNED_AS alone). Every table of the second run must have
# the first run's rows for `default` and TUNED_AS: compare and change filtered to structure == TUNED_AS, checks to
# the rules `default`, TUNED_AS and TUNED_AS_minus_default, segments without the other structures' flag columns.
# Sorted on their keys, character and logical columns identical, numeric columns within a relative 1e-9
# (compare_parallel_check.R's test: the km are float sums over a query with no ORDER BY); a difference stops the
# check. For WCT the every-structure run is also held the same way to the tracked compare, change and checks tables
# and, where it is on disk, the ignored segments table, as a report, not a gate: what made the tracked tables is not
# all pinned here (fresh's version, the bcfishobs load), so each difference is reported beside the flow load,
# evidence, schema run and fresh version. The saving is read from the every-structure run's own minutes per rule,
# summed over workers: the second run reads a cache the first warmed, so the difference of the two wall times
# overstates it (both are logged).
# INPUT:  TUNE_DIR/<key>_{curve.rds,grades.csv} (default data/tune, 0320's promoted run), COMPARE_DIR/WCT_rear_*
#         (default data/compare, 0330's promoted run), EVIDENCE_DIR/{visits_link,visits_species}.csv (default
#         data/fdis/derived), the link repository at LINK_REPO (default ../link), fwapg database (PG* env vars):
#         SCHEMA (default fresh_default_20261017), bcfishobs, whse_basemapping, discharge
# WRITES: schemas knw_strchk_<key>[_w<i>] (scratch; dropped)
# OUTPUT: scripts/logs/habitat/<date>_compare_structures_check[_<n>].txt (a second run of the day numbered;
#         …_refused.txt when the round trip refuses it)
# RUN:    Rscript data-raw/compare_structures_check.R   (from the repo root, on the database's host; WORKERS=6;
#         CONFIG_SHA=102762da; KEYS=WCT_rear,CH_rear,BT_rear; TUNED_AS=door; REMOTE=TRUE to run off the host;
#         TUNE_DIR, COMPARE_DIR and EVIDENCE_DIR where a machine holds the promoted run's inputs elsewhere)
# ---------------------------------------------------------------------------
suppressMessages({ library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

schema <- Sys.getenv("SCHEMA", "fresh_default_20261017")
workers <- as.integer(Sys.getenv("WORKERS", "6"))
config_sha <- Sys.getenv("CONFIG_SHA", "102762da")
link_repo <- Sys.getenv("LINK_REPO", "../link")
keys <- strsplit(Sys.getenv("KEYS", "WCT_rear,CH_rear,BT_rear"), ",")[[1]]
tuned_as <- Sys.getenv("TUNED_AS", "door")
remote <- Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")
tune_dir <- Sys.getenv("TUNE_DIR", "data/tune")
compare_dir <- Sys.getenv("COMPARE_DIR", "data/compare")
evidence_dir <- Sys.getenv("EVIDENCE_DIR", "data/fdis/derived")
n_largest <- c(CH_rear = 20L, BT_rear = 20L)   # keys compared on their largest groups only; the rest on every group
tracked_key <- "WCT_rear"                      # the key held to the tracked tables, on every group
stopifnot(grepl("^[a-z_0-9]+$", schema), workers > 0, grepl("^[0-9a-f]{7,40}$", config_sha),
          tuned_as %in% c("free", "door", "door_wetland"), !tracked_key %in% names(n_largest))
path_txt <- .knw_free_path(file.path("scripts/logs/habitat", paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"),
                                                                    "_compare_structures_check.txt")))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")

conn <- pg()
lat <- tryCatch(knw_db_latency_check(conn, remote = remote), error = function(e) {
  say("%s", conditionMessage(e))
  writeLines(log_lines, sub("\\.txt$", "_refused.txt", path_txt))
  stop(conditionMessage(e), call. = FALSE)
})
load_db <- knw_discharge_load(conn)

# link's configs at CONFIG_SHA, as 0330 reads them
config_sha <- system2("git", c("-C", link_repo, "rev-parse", config_sha), stdout = TRUE)
link_dir <- file.path(tempdir(), paste0("link_default_", substr(config_sha, 1, 7)))
dir.create(file.path(link_dir, "overrides"), showWarnings = FALSE, recursive = TRUE)
for (p in c("parameters_habitat_thresholds.csv", "rules.yaml", "parameters_fresh.csv", "parameters_habitat_method.csv",
            "dimensions.csv", "overrides/user_habitat_classification.csv")) {
  out <- file.path(link_dir, p)
  st <- system2("git", c("-C", link_repo, "show", paste0(config_sha, ":inst/extdata/configs/default/", p)), stdout = out)
  if (!identical(st, 0L) || file.size(out) == 0) stop("could not read ", p, " at link ", config_sha)
}
vl <- read_csv(file.path(evidence_dir, "visits_link.csv"), show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv(file.path(evidence_dir, "visits_species.csv"), show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c"))
head_sha <- substr(system2("git", c("rev-parse", "HEAD"), stdout = TRUE), 1, 7)
say("compare_structures_check on %s; link configs at %s; %d workers; reported structure %s; knowledge %s; %s",
    schema, substr(config_sha, 1, 8), workers, tuned_as, head_sha, lat$line)
md5_here <- unname(tools::md5sum(file.path(evidence_dir, c("visits_link.csv", "visits_species.csv"))))
# the input paths as the log names them: a home directory is written ~, so no log carries a machine's user
home_rel <- function(x) sub(path.expand("~"), "~", x, fixed = TRUE)
say("inputs: %s, %s, %s (visits md5 %s); flow load %s", home_rel(tune_dir), home_rel(compare_dir), home_rel(evidence_dir),
    paste(substr(md5_here, 1, 8), collapse = " "), load_db)

tbl_keys <- list(compare = c("watershed_group_code", "structure"), change = c("structure", "direction", "reason", "order"),
                 checks = c("check", "rule", "segment"), segments = c("id_segment", "watershed_group_code"))
sort_on <- function(x, k) {
  x <- as.data.frame(x)
  x <- x[do.call(order, unname(as.list(x[k]))), , drop = FALSE]
  rownames(x) <- NULL
  x
}
# a against b: same columns, same rows on the keys, characters and logicals identical, numerics within 1e-9 relative
compare_tbl <- function(a, b, what, label) {
  a <- sort_on(a, tbl_keys[[what]])
  b <- sort_on(b, tbl_keys[[what]])
  if (!identical(names(a), names(b))) {
    odd <- setdiff(union(names(a), names(b)), intersect(names(a), names(b)))
    stop(label, " ", what, ": columns differ (", paste(odd, collapse = ", "), ")", call. = FALSE)
  }
  if (nrow(a) != nrow(b)) stop(label, " ", what, ": ", nrow(a), " rows against ", nrow(b), call. = FALSE)
  worst <- 0
  for (c in names(a)) {
    if (is.numeric(a[[c]]) && is.numeric(b[[c]])) {
      if (!identical(is.na(a[[c]]), is.na(b[[c]]))) stop(label, " ", what, ": missing values differ in ", c, call. = FALSE)
      d <- suppressWarnings(max(abs(a[[c]] - b[[c]]) / pmax(1, abs(b[[c]])), na.rm = TRUE))
      if (is.finite(d)) worst <- max(worst, d)
      if (is.finite(d) && d > 1e-9) stop(label, " ", what, ": ", c, " differs by up to ", d, " (relative)", call. = FALSE)
    } else if (!identical(as.character(a[[c]]), as.character(b[[c]]))) {
      stop(label, " ", what, ": ", c, " differs", call. = FALSE)
    }
  }
  say("  %s %s: %d rows x %d columns match; largest relative numeric difference %g.", label, what, nrow(a), ncol(a),
      worst)
}
# the every-structure run's rows for `default` and the reported structure: what a reported-only run must return
reported_rows <- function(cmp, others) {
  flag_cols <- grep(sprintf("^(rearing|spawning)_(pre_)?(%s)$", paste(others, collapse = "|")), names(cmp$segments),
                    value = TRUE)
  list(compare = cmp$compare[cmp$compare$structure == tuned_as, ],
       change = cmp$change[cmp$change$structure == tuned_as, ],
       checks = cmp$checks[cmp$checks$rule %in% c("default", tuned_as, paste0(tuned_as, "_minus_default")), ],
       segments = cmp$segments[, setdiff(names(cmp$segments), flag_cols)])
}
minutes_line <- function(cmp, label, m) {
  wm <- cmp$worker_minutes
  say(paste("  %s: %.1f min; classify, overlay and connect %.1f min;",
            "summed over workers: copies and indexes %.1f, walks %.1f, %s."),
      label, m, cmp$timing[["classify_overlay_connect"]], wm[["setup"]], wm[["walk"]],
      paste(sprintf("%s %.1f", names(wm)[-(1:2)], wm[-(1:2)]), collapse = ", "))
}

# a check that stops still writes what it logged
fail <- function(e) {
  say("STOPPED: %s", conditionMessage(e))
  writeLines(log_lines, path_txt)
  stop(conditionMessage(e), call. = FALSE)
}
tryCatch({
  for (key in keys) {
    r <- readRDS(file.path(tune_dir, paste0(key, "_curve.rds")))
    sp <- r$species_code
    groups <- dbGetQuery(conn, sprintf(
      "SELECT watershed_group_code w, count(*) n FROM %s.streams_habitat_%s GROUP BY 1 ORDER BY 2 DESC, 1", schema,
      tolower(sp)))
    groups <- if (key %in% names(n_largest)) head(groups$w, n_largest[[key]]) else groups$w
    gfile <- file.path(tune_dir, paste0(key, "_grades.csv"))
    gcols <- c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class", "target_in_group")
    grades <- read_csv(gfile, show_col_types = FALSE, col_select = dplyr::all_of(gcols),
                       col_types = cols(id_segment = "d", watershed_group_code = "c", size = "d", dist_m = "d",
                                        grade = "d", grade_class = "c", target_in_group = "l"))
    g1 <- read_csv(gfile, n_max = 1, show_col_types = FALSE, col_types = cols(.default = "c"))
    args <- list(pg, schema, sp, r$stage, r$pick, groups, link_dir, grades, visits = vl, visit_species = vs,
                 scratch = paste0("knw_strchk_", tolower(key)), tuned_as = tuned_as, config_sha = config_sha,
                 workers = workers)
    say("%s: %d groups (%s).", key, length(groups), paste(groups, collapse = " "))
    t0 <- Sys.time()
    all <- do.call(knw_compare_rules, args)
    m_all <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
    structures <- setdiff(unique(all$compare$structure), NA)
    minutes_line(all, sprintf("every structure (%s)", paste(structures, collapse = ", ")), m_all)
    t0 <- Sys.time()
    two <- do.call(knw_compare_rules, c(args, list(structures = "reported")))
    m_rep <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
    minutes_line(two, sprintf("reported only (%s)", tuned_as), m_rep)
    if (!setequal(names(two$worker_minutes)[-(1:2)], c("default", tuned_as))) {
      stop(key, ": the reported-only run regenerated ", paste(names(two$worker_minutes)[-(1:2)], collapse = ", "))
    }
    # the saving, from the every-structure run's own worker minutes: the rules a reported-only run does not regenerate
    wm <- all$worker_minutes
    dropped <- sum(wm[setdiff(structures, tuned_as)])
    say(paste("  %s: the dropped rules (%s) took %.1f of %.1f worker minutes (%.0f %%) in the every-structure run;",
              "wall time %.1f min then %.1f (second, warm)."),
        key, paste(setdiff(structures, tuned_as), collapse = ", "), dropped, sum(wm), 100 * dropped / sum(wm), m_all,
        m_rep)
    want <- reported_rows(all, setdiff(structures, tuned_as))
    for (what in names(tbl_keys)) {
      compare_tbl(two[[what]], want[[what]], what, paste(key, "reported vs every structure:"))
    }
    if (key == tracked_key) {
      rec <- tryCatch(knw_build_record(conn, schema, run_uid = g1$run_uid)$line,
                      error = function(e) conditionMessage(e))
      say(paste("  %s against the tracked tables (a report): flow load %s; evidence %s; schema %s;",
                "fresh %s (#92's comparison ran 0.43.0)."),
          key, if (identical(g1$discharge_load, load_db)) "the grades'" else "NOT the grades'",
          if (startsWith(g1$evidence_md5, paste(md5_here, collapse = ";"))) "the grades'" else "NOT the grades'", rec,
          as.character(utils::packageVersion("fresh")))
      # read as 0330 wrote them (na = ""); a column that is all NA reads as logical, which compares as its characters
      rd <- function(what) {
        read_csv(file.path(compare_dir, paste0(key, "_", what, ".csv")), show_col_types = FALSE, guess_max = Inf,
                 col_types = cols(.default = col_guess()))
      }
      versus <- function(what, b) {
        tryCatch(compare_tbl(all[[what]], b, what, paste(key, "every structure vs tracked:")),
                 error = function(e) say("  DIFFERS: %s", conditionMessage(e)))
      }
      for (what in c("compare", "change", "checks")) versus(what, rd(what))
      f_seg <- file.path(compare_dir, paste0(key, "_segments.rds"))
      if (file.exists(f_seg)) {
        versus("segments", readRDS(f_seg))
      } else {
        say("  %s segments: no %s on this machine, not compared.", key, f_seg)
      }
    }
    rm(all, two, want, grades)
  }
}, error = fail)
dbDisconnect(conn)
writeLines(log_lines, path_txt)
say("written %s", path_txt)
