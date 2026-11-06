# data-raw/database_walk_check.R
# ---------------------------------------------------------------------------
# Walk on this database without the walk cache, and compare with the walks the published run made (#158). A
# database loaded with the published build's walk cache answers 0310's visit walks and the grade's segment walks
# from the cache, so a run there reads walks without computing one, and a reproduced run cannot show whether this
# database walks as the host did. This walks them cold (knw_link_walks(cache = FALSE)) and compares:
#   visits  every visit start in the reference walks.csv, on 0310's three sources and seven river sizes, against
#           that table (the 14 columns the walk returns; 0310 adds target_lake and target_regulated after it)
#   grade   N_GRADE segment starts drawn at random (SEED) from a grade table's walked segments (dist_status not no_walk), at its record's
#           river size on wet's pick, against the table's dist_status and dist_m
# Distances are held to 0.005 m, a chosen tolerance: a walk sums segment lengths in the order the database returns them,
# and the first run of this check moved distances by up to 3.5 mm where nothing else moved. Nothing is written to the database:
# cache = FALSE neither reads nor keeps a walk.
#
# INPUT:  REF_WALKS (default data/fdis/derived/walks.csv); GRADES (default data/tune/CH_rear_grades.csv) and its
#         record (<key>_grades_record.csv beside it, for q_walk); N_GRADE (20000), SEED (158), WORKERS (8);
#         fwapg database (PG* env vars) holding discharge and whse_basemapping; PART=visits|grade|both (both)
# OUTPUT: OUT (default scripts/logs/habitat/<date>_database_compare-walks.csv): one verdict row per part, in
#         data-raw/database_compare.R's shape, with the minutes each walk took in its note
# RUN:    Rscript data-raw/database_walk_check.R   (from the repo root, on the database's host)
# ---------------------------------------------------------------------------
suppressMessages({ library(data.table) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")
source("data-raw/database_compare.R")  # compare_tables(), row_out(), self_test()
self_test()

ref_walks <- Sys.getenv("REF_WALKS", "data/fdis/derived/walks.csv")
grades_path <- Sys.getenv("GRADES", "data/tune/CH_rear_grades.csv")
n_grade <- as.integer(Sys.getenv("N_GRADE", "20000"))
seed <- as.integer(Sys.getenv("SEED", "158"))
workers <- as.integer(Sys.getenv("WORKERS", "8"))
part <- Sys.getenv("PART", "both")
dest <- Sys.getenv("OUT", file.path("scripts/logs/habitat",
                                    sprintf("%s_database_compare-walks.csv", format(Sys.time(), "%Y%m%d", tz = "UTC"))))
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
con <- pg()
cat(knw_db_latency_check(con, remote = FALSE)$line, "\n")
cat("Flow load: ", knw_discharge_load(con), "\n")
DBI::dbDisconnect(con)
out <- list()

if (part %in% c("visits", "both")) {
  ref <- fread(ref_walks, na.strings = c("", "NA"), integer64 = "double", showProgress = FALSE)
  starts <- unique(ref[, .(blue_line_key, downstream_route_measure)])
  t0 <- Sys.time()
  w <- knw_link_walks(pg, as.data.frame(starts), q_grid = c(1, 3, 5, 10, 20, 30, 50),
                      sources = c("pick", "pcic_routed", "wet_balance"), workers = workers, cache = FALSE)
  mins <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  w <- as.data.table(w)
  cols <- intersect(names(w), names(ref))
  r <- compare_tables(ref[, cols, with = FALSE], w[, cols, with = FALSE], "walks.csv (visit starts, uncached)",
                      key = c("blue_line_key", "downstream_route_measure", "src", "qmin"), tol = 0.005,
                      decision_read = TRUE)
  r$note <- paste(c(if (nzchar(r$note)) r$note, sprintf("%d starts x 3 sources x 7 sizes walked cold in %.1f min on %d workers",
                                                       nrow(starts), mins, workers)), collapse = "; ")
  print(r)
  out[[length(out) + 1]] <- r
}

if (part %in% c("grade", "both")) {
  rec <- fread(sub("_grades\\.csv$", "_grades_record.csv", grades_path))
  g <- fread(grades_path, select = c("blue_line_key", "downstream_route_measure", "dist_status", "dist_m"),
             na.strings = c("", "NA"), integer64 = "double", showProgress = FALSE)
  # walked segments only (no_walk marks an inaccessible one); a start shared by two rows is one walk
  g <- unique(g[dist_status != "no_walk"])
  set.seed(seed)
  s <- g[sort(sample.int(nrow(g), min(n_grade, nrow(g))))]
  t0 <- Sys.time()
  w <- as.data.table(knw_link_walks(pg, as.data.frame(s[, .(blue_line_key, downstream_route_measure)]),
                                    q_grid = rec$q_walk, sources = "pick", workers = workers, cache = FALSE))
  mins <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  # the grade keeps a distance only where the walk found a river (R/grade_species.R)
  w <- w[, .(blue_line_key, downstream_route_measure, dist_status = status,
             dist_m = ifelse(status == "found", dist_m, NA_real_))]
  r <- compare_tables(s, w, sprintf("%s (%d sampled grade starts, uncached)", basename(grades_path), nrow(s)),
                      key = c("blue_line_key", "downstream_route_measure"), tol = 0.005, decision_read = TRUE)
  r$note <- paste(c(if (nzchar(r$note)) r$note, sprintf("seed %d; q %s on pick; walked cold in %.1f min on %d workers",
                                                       seed, rec$q_walk, mins, workers)), collapse = "; ")
  print(r)
  out[[length(out) + 1]] <- r
}

out <- cbind(data.table(label = "walks"), rbindlist(out))
fwrite(out, dest, na = "NA")
cat("Written to", dest, "\n")
