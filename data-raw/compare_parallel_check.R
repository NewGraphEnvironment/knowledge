# data-raw/compare_parallel_check.R
# ---------------------------------------------------------------------------
# A comparison run with its groups on several workers is the comparison (#87): knw_compare_rules()
# splitting a key's groups across socket workers, each with its own connection and scratch schema, must
# return the tables the one-connection loop returned. Two keys: WCT rearing on every group it has a habitat
# table in (16), and CH rearing on its 20 largest groups by segment count, because chinook is the only
# species whose `default` resolves a near-river pair, so its groups exercise fresh's walk on each worker's
# scratch copy.
#
# METHOD: REF=1 runs the comparison with the code as it stood before #87 (the script refuses a
# knw_compare_rules() that already takes `workers`) and writes compare, change, checks and segments, as
# returned (rds, so exact), to data/compare/ref_<key>/ (ignored). The default mode runs the current code with
# WORKERS workers and refuses any difference: every table must have the reference's rows and columns after
# sorting on its keys, character and logical columns identical, numeric columns within 1e-9 (the largest
# difference is reported; the seg query's order and the seeded bootstrap are the master's in both, so
# identity is expected).
# INPUT:  data/tune/<key>_{curve.rds,grades.csv} (0320), data/fdis/derived/{visits_link,visits_species}.csv,
#         the link repository at LINK_REPO (default ../link), fwapg database (PG* env vars): SCHEMA (default
#         fresh_default_20261017), bcfishobs, whse_basemapping, discharge
# WRITES: schemas knw_cmpchk_<key>[_w<i>] (scratch; dropped)
# OUTPUT: data/compare/ref_<key>/{compare,change,checks,segments}.rds    REF=1 (ignored)
#         scripts/logs/habitat/<date>_compare_parallel_check[-ref].txt
# RUN:    Rscript data-raw/compare_parallel_check.R   (from the repo root, on the database's host; REF=1 for the
#         references; WORKERS=6; CONFIG_SHA=102762da; KEYS=WCT_rear,CH_rear)
# ---------------------------------------------------------------------------
suppressMessages({ library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

ref_mode <- identical(Sys.getenv("REF"), "1")
schema <- Sys.getenv("SCHEMA", "fresh_default_20261017")
workers <- as.integer(Sys.getenv("WORKERS", "6"))
config_sha <- Sys.getenv("CONFIG_SHA", "102762da")
link_repo <- Sys.getenv("LINK_REPO", "../link")
keys <- strsplit(Sys.getenv("KEYS", "WCT_rear,CH_rear"), ",")[[1]]
n_largest <- c(CH_rear = 20L)   # keys compared on their largest groups only; the rest on every group
stopifnot(grepl("^[a-z_0-9]+$", schema), workers > 0, grepl("^[0-9a-f]{7,40}$", config_sha))
stamp <- format(Sys.Date(), "%Y%m%d")
path_txt <- file.path("scripts/logs/habitat", paste0(stamp, "_compare_parallel_check", if (ref_mode) "-ref", ".txt"))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
has_workers <- "workers" %in% names(formals(knw_compare_rules))
if (ref_mode && has_workers) stop("REF=1 needs the comparison as it stood before #87; this knw_compare_rules() takes workers")
if (!ref_mode && !has_workers) stop("this knw_compare_rules() has no workers: run REF=1 for the references")
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")

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
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c"))
say("compare_parallel_check %s on %s; link configs at %s; %s; knowledge %s", if (ref_mode) "REF" else "CHECK", schema,
    substr(config_sha, 1, 8), if (ref_mode) "one connection" else sprintf("%d workers", workers),
    substr(system2("git", c("rev-parse", "HEAD"), stdout = TRUE), 1, 7))

tbl_keys <- list(compare = c("watershed_group_code", "structure"), change = c("structure", "direction", "reason", "order"),
                 checks = c("check", "rule", "segment"), segments = c("id_segment", "watershed_group_code"))
sort_on <- function(x, k) {
  x <- as.data.frame(x)
  x <- x[do.call(order, unname(as.list(x[k]))), , drop = FALSE]
  rownames(x) <- NULL
  x
}
compare_tbl <- function(a, b, what, key) {
  a <- sort_on(a, tbl_keys[[what]])
  b <- sort_on(b, tbl_keys[[what]])
  if (!identical(names(a), names(b))) stop(key, " ", what, ": columns differ from the reference", call. = FALSE)
  if (nrow(a) != nrow(b)) stop(key, " ", what, ": ", nrow(a), " rows against ", nrow(b), call. = FALSE)
  worst <- 0
  for (c in names(a)) {
    if (is.numeric(a[[c]]) && is.numeric(b[[c]])) {
      if (!identical(is.na(a[[c]]), is.na(b[[c]]))) stop(key, " ", what, ": missing values differ in ", c, call. = FALSE)
      d <- suppressWarnings(max(abs(a[[c]] - b[[c]]), na.rm = TRUE))
      if (is.finite(d)) worst <- max(worst, d)
      if (is.finite(d) && d > 1e-9) stop(key, " ", what, ": ", c, " differs by up to ", d, call. = FALSE)
    } else if (!identical(as.character(a[[c]]), as.character(b[[c]]))) {
      stop(key, " ", what, ": ", c, " differs from the reference", call. = FALSE)
    }
  }
  say("  %s %s: %d rows x %d columns match the reference; largest numeric difference %g.", key, what, nrow(a),
      ncol(a), worst)
}

conn <- pg()
for (key in keys) {
  r <- readRDS(file.path("data/tune", paste0(key, "_curve.rds")))
  sp <- r$species_code
  groups <- dbGetQuery(conn, sprintf(
    "SELECT watershed_group_code w, count(*) n FROM %s.streams_habitat_%s GROUP BY 1 ORDER BY 2 DESC, 1", schema,
    tolower(sp)))
  groups <- if (key %in% names(n_largest)) head(groups$w, n_largest[[key]]) else groups$w
  gfile <- file.path("data/tune", paste0(key, "_grades.csv"))
  gcols <- c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class", "target_in_group")
  grades <- read_csv(gfile, show_col_types = FALSE, col_select = dplyr::all_of(gcols),
                     col_types = cols(id_segment = "d", watershed_group_code = "c", size = "d", dist_m = "d",
                                      grade = "d", grade_class = "c", target_in_group = "l"))
  args <- list(pg, schema, sp, r$stage, r$pick, groups, link_dir, grades, visits = vl, visit_species = vs,
               scratch = paste0("knw_cmpchk_", tolower(key)), tuned_as = "door", config_sha = config_sha)
  if (!ref_mode) args$workers <- workers
  t0 <- Sys.time()
  cmp <- do.call(knw_compare_rules, args)
  say("%s: %d groups (%s) in %.1f min.", key, length(groups), paste(groups, collapse = " "),
      as.numeric(difftime(Sys.time(), t0, units = "mins")))
  d <- file.path("data/compare", paste0("ref_", key))
  if (ref_mode) {
    dir.create(d, showWarnings = FALSE, recursive = TRUE)
    for (what in names(tbl_keys)) saveRDS(cmp[[what]], file.path(d, paste0(what, ".rds")))
    say("  reference written to %s (%d segments).", d, nrow(cmp$segments))
  } else {
    if (!dir.exists(d)) stop("no reference at ", d, ": run REF=1 first")
    for (what in names(tbl_keys)) compare_tbl(cmp[[what]], readRDS(file.path(d, paste0(what, ".rds"))), what, key)
  }
}
dbDisconnect(conn)
writeLines(log_lines, path_txt)
say("written %s", path_txt)
