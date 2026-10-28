# data-raw/compare_stage_time.R
# ---------------------------------------------------------------------------
# What each rule costs in the comparison (#101, #112): knw_compare_rules() on chinook rearing (four rules, the only
# key whose `default` walks a near-river pair) and bull trout rearing (the slowest) on every group, on the published
# comparison's setting, logging each rule's worker-minutes by step (classify, user-habitat overlay, connect, read)
# beside the steps the rules share (the scratch copy, the near-river walk, the default check). #101 asks what a cache
# of `default`'s flags would spare; #112 what dropping `free` and `door_wetland` would.
#
# METHOD: the curves and grades on disk in data/tune/ (ignored; on the host they are 0320's run of 2026-10-25, the
# picks before #92's, which was graded on another machine), link's configs at CONFIG_SHA (the published comparison's),
# the schema the tuning was built on (refused if another run built it), WORKERS socket workers as 0330 runs them. The
# pick sets what the tuned rules keep, not what a rule's steps cost, so the minutes stand for any pick. Each key's
# pick-independent columns (accessible, stored and `default` km, by group and structure) are then held to the tracked
# data/compare/<key>_compare.csv within a relative 1e-9: where the flow load and fresh's version are the published
# run's, a difference means the timing moved a result; where either differs, a difference is expected and is reported,
# not raised. Run it with nothing else on the database: the minutes are the point.
# INPUT:  data/tune/<key>_{curve.rds,grades.csv}, data/compare/<key>_compare.csv, data/fdis/derived/{visits_link,
#         visits_species}.csv, the link repository at LINK_REPO (default ../link), fwapg database (PG* env vars): SCHEMA
#         (default fresh_default_20261017), bcfishobs, whse_basemapping, discharge
# WRITES: schemas knw_stage_<key>[_w<i>] (scratch; dropped)
# OUTPUT: scripts/logs/habitat/<date>_compare_stage_time.txt, the log, written after each key
#         scripts/logs/habitat/<date>_compare_stage_time.csv, every key's rule x step minutes
# RUN:    Rscript data-raw/compare_stage_time.R   (from the repo root, on the database's host; KEYS=CH_rear,BT_rear;
#         WORKERS=6; CONFIG_SHA=102762da; SCHEMA=fresh_default_20261017; REMOTE=TRUE to run off the host anyway)
# ---------------------------------------------------------------------------
suppressMessages({ library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

schema <- Sys.getenv("SCHEMA", "fresh_default_20261017")
workers <- as.integer(Sys.getenv("WORKERS", "6"))
config_ref <- Sys.getenv("CONFIG_SHA", "102762da")
link_repo <- Sys.getenv("LINK_REPO", "../link")
keys <- strsplit(Sys.getenv("KEYS", "CH_rear,BT_rear"), ",")[[1]]
remote <- Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")
stopifnot(grepl("^[a-z_0-9]+$", schema), workers > 0, grepl("^[0-9a-f]{7,40}$", config_ref))
stamp <- format(Sys.time(), "%Y%m%d", tz = "UTC")
path_txt <- .knw_free_path(file.path("scripts/logs/habitat", paste0(stamp, "_compare_stage_time.txt")))
path_csv <- sub("\\.txt$", ".csv", path_txt)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")

# link's configs at CONFIG_SHA, as 0330 reads them
config_sha <- suppressWarnings(system2("git", c("-C", link_repo, "rev-parse", "--verify",
                                                paste0(config_ref, "^{commit}")), stdout = TRUE, stderr = TRUE))
if (!is.null(attr(config_sha, "status")) || length(config_sha) != 1 || !grepl("^[0-9a-f]{40}$", config_sha)) {
  stop("could not resolve ", config_ref, " to a commit in ", link_repo)
}
link_dir <- file.path(tempdir(), paste0("link_default_", substr(config_sha, 1, 7)))
dir.create(file.path(link_dir, "overrides"), showWarnings = FALSE, recursive = TRUE)
for (p in c("parameters_habitat_thresholds.csv", "rules.yaml", "parameters_fresh.csv", "parameters_habitat_method.csv",
            "dimensions.csv", "overrides/user_habitat_classification.csv")) {
  out <- file.path(link_dir, p)
  st <- system2("git", c("-C", link_repo, "show", paste0(config_sha, ":inst/extdata/configs/default/", p)), stdout = out)
  if (!identical(st, 0L) || !file.exists(out) || file.size(out) == 0) stop("could not read ", p, " at link ", config_sha)
}
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c",
                                hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c"))

# on the database's host, on the schema the published tuning was built on
conn <- pg()
lat <- knw_db_latency_check(conn, remote = remote)
led <- read_csv(knw_run_ledger("data/tune"), show_col_types = FALSE, col_types = cols(.default = "c"))
rec <- knw_build_record(conn, schema, run_uid = led$note[led$step == "link_run_uid"])
say("compare_stage_time on %s; link configs at %s; %d workers; knowledge %s; %s", schema, substr(config_sha, 1, 8),
    workers, substr(system2("git", c("rev-parse", "HEAD"), stdout = TRUE), 1, 7), lat$line)
say("%s", rec$line)

# each key's pick-independent columns against the tracked table's; returns the verdict as a line, never raises
cols_fixed <- c("watershed_group_code", "structure", "accessible_km", "access_gate_differ_km", "stored_km",
                "default_km", "stored_vs_default_differ_km", "default_rule", "config_sha")
hold_to_tracked <- function(cmp, key, expect_same) {
  b <- as.data.frame(read_csv(file.path("data/compare", paste0(key, "_compare.csv")), show_col_types = FALSE,
                              col_types = cols(watershed_group_code = "c", species_code = "c", stage = "c",
                                               structure = "c", default_rule = "c", tuned_rule = "c",
                                               tuned_structure = "c", config_sha = "c", .default = "d")))[cols_fixed]
  a <- as.data.frame(cmp)[cols_fixed]
  # a structure one pick runs and the other does not (an exception adds door_wetland) has nothing to hold to
  st <- intersect(a$structure, b$structure)
  a <- a[a$structure %in% st, , drop = FALSE]
  b <- b[b$structure %in% st, , drop = FALSE]
  k <- c("watershed_group_code", "structure")
  a <- a[do.call(order, unname(as.list(a[k]))), , drop = FALSE]
  b <- b[do.call(order, unname(as.list(b[k]))), , drop = FALSE]
  why <- NULL
  if (!identical(sort(names(a)), sort(names(b)))) {
    why <- "columns differ"
  } else if (nrow(a) != nrow(b)) {
    why <- sprintf("%d rows against %d", nrow(a), nrow(b))
  } else if (!identical(a[k], b[k])) {
    why <- "groups or structures differ"
  }
  worst <- 0
  worst_col <- NA_character_
  if (is.null(why)) {
    for (c in names(b)) {
      if (is.numeric(b[[c]])) {
        if (!identical(is.na(a[[c]]), is.na(b[[c]]))) {
          why <- paste("missing values differ in", c)
          break
        }
        d <- suppressWarnings(max(abs(a[[c]] - b[[c]]) / pmax(1, abs(b[[c]])), na.rm = TRUE))
        if (is.finite(d) && d > worst) {
          worst <- d
          worst_col <- c
        }
      } else if (!identical(as.character(a[[c]]), as.character(b[[c]]))) {
        why <- paste(c, "differs")
        break
      }
    }
  }
  same <- is.null(why) && worst <= 1e-9
  sprintf("%s pick-independent columns against data/compare/%s_compare.csv: %s%s.", key, key,
          if (same) sprintf("matches (largest relative difference %g)", worst) else
            if (is.null(why)) sprintf("differs, up to %g relative in %s", worst, worst_col) else why,
          if (same || !expect_same) "" else " -- UNEXPECTED: the inputs are the published run's")
}

timed <- list()
for (key in keys) {
  r <- readRDS(file.path("data/tune", paste0(key, "_curve.rds")))
  sp <- r$species_code
  groups <- dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_%s ORDER BY 1",
                                     schema, tolower(sp)))$w
  gfile <- file.path("data/tune", paste0(key, "_grades.csv"))
  h <- read_csv(gfile, n_max = 1, show_col_types = FALSE, col_types = cols(.default = "c"))
  gcols <- c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class", "target_in_group")
  grades <- read_csv(gfile, show_col_types = FALSE, col_select = dplyr::all_of(gcols),
                     col_types = cols(id_segment = "d", watershed_group_code = "c", size = "d", dist_m = "d",
                                      grade = "d", grade_class = "c", target_in_group = "l"))
  t0 <- Sys.time()
  cmp <- knw_compare_rules(pg, schema, sp, r$stage, r$pick, groups, link_dir, grades, visits = vl, visit_species = vs,
                           scratch = paste0("knw_stage_", tolower(key)), tuned_as = "door", config_sha = config_sha,
                           workers = workers)
  rm(grades)
  say("%s: %d groups in %.1f min.", key, length(groups), as.numeric(difftime(Sys.time(), t0, units = "mins")))
  for (l in cmp$log) say("   %s", l)
  # the published comparison ran on this flow load and fresh 0.43.0 (scripts/logs/habitat/20261027_compare.txt)
  same_inputs <- identical(h$discharge_load, rec$discharge_load) && identical(rec$fresh_version, "0.43.0")
  say("%s", hold_to_tracked(cmp$compare, key, same_inputs))
  if (!same_inputs) {
    say("   (inputs differ from the published run's: flow load %s, fresh %s)",
        if (identical(h$discharge_load, rec$discharge_load)) "same" else "differs", rec$fresh_version)
  }
  timed[[key]] <- cbind(key = key, cmp$stage_minutes)
  write_csv(do.call(rbind, timed), path_csv)
  writeLines(log_lines, path_txt)
}
dbDisconnect(conn)
say("written %s and %s", path_txt, path_csv)
writeLines(log_lines, path_txt)
