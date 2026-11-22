# data-raw/chinook_window_evidence.R
# ---------------------------------------------------------------------------
# #226 (#105 Phase 2): the published evidence with a window. A copy of the tuning's three tables in which every
# visit also carries its stream's flow in the rearing window, and every start a walk to the first river of each
# size by its flow in the spawning window. data-raw/chinook_window_tune.R scores chinook rearing on it.
#
# WHY / DESIGN NOTES:
#   - THE PUBLISHED TABLES, PLUS. data/fdis/derived must be the evidence the published chinook rearing rule was
#     scored on (its md5s are the summary's), and the flow load the grade record's. The copy adds one column to the
#     visits and rows to the walks and changes nothing else, which the script checks by reading the copy back, so
#     the control reading on the copy is the published run. scripts/0310 is not run and not changed (the plan gate,
#     2026-11-21): it learns the column only if a window wins.
#   - THE WINDOW FLOW ON THE SEGMENT MAD CAME FROM (knw_link_flow_window()): its own segment, or the parent
#     knw_link_flow() fell back to, on that segment's pick source. So it is present exactly where mad_pick is and
#     every reading scores the same visits. The annual flow read with it must equal the evidence's mad_pick at
#     every visit with a flow of its own and at every scored visit; a visit on a tied parent may hold the other
#     parent's flow, from before #161, and is counted.
#   - THE WINDOW WALK (knw_link_walks(window = )): inst/sql/ch_dist_profile_window.sql, the annual walk but for
#     the flow it reads. Its rows carry src `pick@0815-0915`, beside the published rows on `pick`. It passes over
#     a segment that lacks one of the window's months on its source, so before any walk the script counts such
#     segments over the whole load and stops unless there are none.
#   - TARGET FLAGS ARE LEFT EMPTY on the window rows. The tuning never reads them (knw_rule_in()'s no_lake_target
#     and no_reg_target are off), and knw_walk_index() reads an empty flag as FALSE.
#   - AGAINST PHASE 1: the median window share of MAD at the scored visits, and each group's, must be Phase 1's
#     (data/tune/flow_window/ch_rear_run.csv, ch_rear_ratio_by_group.csv). And Phase 1 read the river off the annual
#     walk's ladder; the log counts the scored visits whose river within reach differs on the exact walk.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (PULL=TRUE KEYS=CH_rear scripts/0336-archive.R),
#         data/tune/CH_rear_{summary,tune,grades_record}.csv, data/tune/flow_window/ch_rear_{run,ratio_by_group}.csv,
#         a database holding whse_basemapping and the grade record's flow load (PG* or PGSERVICE).
# WRITES: knw.walk_cache_window in the database (the window walks; the published knw.walk_cache is not touched).
# OUTPUT: data/fdis/derived_window/{visits_link,visits_species,walks}.csv and window_run.csv (ignored);
#         data/tune/flow_window/ch_rear_window_evidence_run.csv (tracked: the run's record)
# RUN:    Rscript data-raw/chinook_window_evidence.R 2>&1 |
#           tee scripts/logs/flow_window/<yyyymmdd>_chinook_window_evidence.txt
#         (repo root, on the database's host; WORKERS=8)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

src_dir <- "data/fdis/derived"
out_dir <- "data/fdis/derived_window"
run_dir <- "data/tune/flow_window"
tables <- c("visits_link", "visits_species", "walks")
rear <- data.frame(start = "08-01", end = "09-30")     # the stream's size, where the visit is
spawn <- data.frame(start = "08-15", end = "09-15")    # the river's size, downstream
q_grid <- c(1, 3, 5, 10, 20, 30, 50)                   # 0310's ladder
walk_cache <- "knw.walk_cache_window"
workers <- as.integer(Sys.getenv("WORKERS", "4"))
stamp <- function() format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
secs <- function(t0) as.numeric(difftime(Sys.time(), t0, units = "secs"))

git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed", call. = FALSE)
  out
}
dirty <- git("status", "--porcelain", "--", "data-raw/chinook_window_evidence.R", "R", "inst/sql", "DESCRIPTION")
if (length(dirty)) {
  stop("commit first, so the run record's commit reproduces the run: ", paste(dirty, collapse = "; "), call. = FALSE)
}
head_sha <- git("rev-parse", "HEAD")
cat("HEAD:   ", head_sha, "\nstarted:", stamp(), "\n\n")

# ---- the published run's record, and its evidence ----
summ <- utils::read.csv("data/tune/CH_rear_summary.csv", stringsAsFactors = FALSE)
rec <- utils::read.csv("data/tune/CH_rear_grades_record.csv", stringsAsFactors = FALSE)
tune <- utils::read.csv("data/tune/CH_rear_tune.csv", stringsAsFactors = FALSE)
p1 <- utils::read.csv(file.path(run_dir, "ch_rear_run.csv"), stringsAsFactors = FALSE)
p1_group <- utils::read.csv(file.path(run_dir, "ch_rear_ratio_by_group.csv"), stringsAsFactors = FALSE)
f_src <- stats::setNames(file.path(src_dir, paste0(tables, ".csv")), tables)
md5_src <- stats::setNames(unname(tools::md5sum(f_src)), tables)   # md5sum() names by path
if (!identical(paste(unname(md5_src), collapse = ";"), summ$evidence_md5)) {
  stop("the evidence in ", src_dir, " is not the published run's: ", paste(md5_src, collapse = ";"), call. = FALSE)
}
pub <- tune[tune$rule == summ$rule_recommended, , drop = FALSE]
if (nrow(pub) != 1L) stop("the recommended rule is not one row of CH_rear_tune.csv", call. = FALSE)
cat("published run:", summ$tune_run, "rule", pub$rule, "\nevidence:     ", summ$evidence_md5, "\n")

pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
conn <- pg()
lat <- knw_db_latency_check(conn, remote = Sys.getenv("REMOTE") %in% c("1", "TRUE", "true"))
cat(lat$line, "\n")
load <- knw_discharge_load(conn)
if (!identical(load, rec$discharge_load)) {
  stop("the database's flow load is not the grade record's:\n  ", load, call. = FALSE)
}
if (!identical(knw_walk_md5(), rec$walk_md5)) stop("the annual walk is not the grade record's", call. = FALSE)
busy <- DBI::dbGetQuery(conn, "SELECT count(*) AS n FROM pg_stat_activity
                               WHERE datname = current_database() AND state <> 'idle' AND pid <> pg_backend_pid()")$n
cat("flow load:    ", load, "\nother active sessions on the database:", busy, "\n")
cat("walks:         annual", knw_walk_md5(), "window", knw_walk_md5(window = TRUE), "\n")
cat("wet:          ", as.character(utils::packageVersion("wet")), "\n\n")

# ---- every picked segment carries the windows' months, on one source ----
# the window walk passes over a segment that lacks a month, and says nothing; so the load is counted first
wts <- .knw_window_weights(spawn$start, spawn$end)
months <- sort(unique(c(wts$months, .knw_window_weights(rear$start, rear$end)$months)))
t0 <- Sys.time()
short <- DBI::dbGetQuery(conn, sprintf("
  SELECT count(*) AS segments,
         count(*) FILTER (WHERE n_src <> 1) AS two_sources,
         count(*) FILTER (WHERE n_annual <> 1) AS annual_not_once,
         count(*) FILTER (WHERE n_win <> %d) AS window_short
  FROM (SELECT linear_feature_id, count(DISTINCT source) AS n_src,
               count(*) FILTER (WHERE month = 0) AS n_annual,
               count(*) FILTER (WHERE month IN (%s)) AS n_win
        FROM discharge.fwa_v1_segment_monthly
        WHERE scenario = 'historical' AND pick GROUP BY 1) x", length(months), paste(months, collapse = ", ")))
cat(sprintf(paste("picked segments in the load: %.0f; on two sources %.0f; annual flow not once %.0f;",
                  "a window month (%s) short %.0f (%.0f s)\n"),
            short$segments, short$two_sources, short$annual_not_once, paste(months, collapse = ", "),
            short$window_short, secs(t0)))
if (short$two_sources + short$annual_not_once + short$window_short > 0) {
  stop("a picked segment lacks a window month, or is picked on two sources: the window walk would pass over it",
       call. = FALSE)
}

# ---- the visits, as 0320 reads them ----
read_visits <- function(f) {
  readr::read_csv(f, guess_max = 1e5, show_col_types = FALSE, progress = FALSE,
                  col_types = readr::cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c",
                                          hydro_zone = "c"))
}
vl <- read_visits(f_src[["visits_link"]])
vs <- readr::read_csv(f_src[["visits_species"]], show_col_types = FALSE, progress = FALSE, guess_max = 1e5,
                      col_types = readr::cols(site_visit = "c"))
walks <- readr::read_csv(f_src[["walks"]], show_col_types = FALSE, progress = FALSE)
col_rear <- .knw_windows(rear)$col
src_spawn <- paste0("pick@", .knw_windows(spawn)$label)
if (col_rear %in% names(vl) || src_spawn %in% walks$src) stop(src_dir, " already carries a window", call. = FALSE)

# ---- the window flow, on the segment MAD came from ----
t0 <- Sys.time()
fl <- knw_link_flow_window(conn, unique(vl$linear_feature_id), rear)
m <- match(vl$linear_feature_id, fl$linear_feature_id)
if (anyNA(m)) stop(sum(is.na(m)), " visits' segments are not in the Atlas", call. = FALSE)
same <- (is.na(fl$mad_pick[m]) & is.na(vl$mad_pick)) |
  (!is.na(fl$mad_pick[m]) & !is.na(vl$mad_pick) & abs(fl$mad_pick[m] - vl$mad_pick) < 1e-9)
# A visit whose flow is a parent's can differ: the published evidence was built before the parent tie went to the
# lower id (#161, knowledge 0.4.32), so where two parents are equally near it may hold the other one's flow. Such a
# visit keeps its published mad_pick, and its window flow is read on the parent the query takes now. A visit with a
# flow of its own must agree, and so must every visit the tuning scores (checked below, once they are cut).
if (any(!same & !vl$flow_from %in% "parent")) {
  stop(sum(!same & !vl$flow_from %in% "parent"), " visits' own MAD, read again, is not the evidence's mad_pick",
       call. = FALSE)
}
tied <- vl$site_visit[!same]
win_flow <- fl[[col_rear]][m]
if (!identical(is.na(win_flow), is.na(vl$mad_pick))) {
  stop(sum(is.na(win_flow) != is.na(vl$mad_pick)), " visits carry one of MAD and the window flow, not both",
       call. = FALSE)
}
has <- !is.na(win_flow)
# a stream with a MAD and no flow in the window is a dry stream, not an error: a rule's size test fails it, and
# the curve, which reads log size, leaves it out. Counted, so a reading's curve is read knowing how many it lost
n_dry <- sum(win_flow[has] <= 0 & vl$mad_pick[has] > 0)
cat(sprintf(paste("\nwindow flow %s to %s (%s): %d visits on %d segments, %d with a flow, %d without (as mad_pick);",
                  "MAD read again equal at %d visits, and at %d of the %d whose flow is a parent's (the rest hold a",
                  "tied parent's, from before #161: %s); %d with a MAD and no window flow above zero; %d with no MAD",
                  "above zero (%.0f s)\n"),
            rear$start, rear$end, col_rear, nrow(vl), nrow(fl), sum(has), sum(!has), sum(same),
            sum(same & vl$flow_from %in% "parent"), sum(vl$flow_from %in% "parent"),
            if (length(tied)) paste(tied, collapse = ", ") else "none", n_dry, sum(vl$mad_pick[has] <= 0), secs(t0)))

# ---- against Phase 1: the scored visits' window share of MAD ----
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
vl_win <- vl
vl_win[[col_rear]] <- win_flow
pop <- .tune_population(.tune_base(vl_win, edge_stream, eval(fm$area_range)), vs, "CH", "rear")
d <- .tune_modelled(pop$d, "U")
n_mod <- c(nrow(d), sum(d$U), nlevels(d$wsg))
if (!identical(n_mod, c(as.integer(pub$n_visits), as.integer(pub$n_detect), as.integer(pub$n_wsg)))) {
  stop("the scored visits are not the tune table's: ", paste(n_mod, collapse = " / "), call. = FALSE)
}
if (any(d$site_visit %in% tied)) {
  stop(sum(d$site_visit %in% tied), " scored visits' MAD, read again, is not the evidence's mad_pick", call. = FALSE)
}
ratio <- d[[col_rear]] / d$mad_pick
med <- stats::median(ratio[is.finite(ratio)])
by_group <- tapply(ratio, d$watershed_group_code, function(x) stats::median(x[is.finite(x)]))
gap_group <- max(abs(by_group[p1_group$watershed_group_code] - p1_group$rear_q50), na.rm = TRUE)
cat(sprintf(paste("scored visits %s (visits / with CH / groups); median window share of MAD %.6f (Phase 1 %.6f);",
                  "largest gap in a group's median %.2e over %d groups\n"),
            paste(n_mod, collapse = " / "), med, p1$med_rear_visit, gap_group, nrow(p1_group)))
if (abs(med - p1$med_rear_visit) > 1e-9 || !is.finite(gap_group) || gap_group > 1e-9 ||
      !setequal(names(by_group), p1_group$watershed_group_code)) {
  stop("the window share of MAD is not Phase 1's", call. = FALSE)
}

# ---- the window walk ----
starts <- unique(vl[, c("blue_line_key", "downstream_route_measure")])
starts_pub <- unique(walks[, c("blue_line_key", "downstream_route_measure")])
if (nrow(starts) != nrow(starts_pub) ||
      !setequal(paste(starts$blue_line_key, starts$downstream_route_measure),
                paste(starts_pub$blue_line_key, starts_pub$downstream_route_measure))) {
  stop("the visits' starts are not the published walks' starts", call. = FALSE)
}
DBI::dbDisconnect(conn)
t0 <- Sys.time()
trial <- knw_link_walks(pg, starts[seq_len(min(500L, nrow(starts))), ], q_grid = q_grid, sources = "pick",
                        workers = workers, window = spawn)
t_trial <- secs(t0)
cat(sprintf("\nwindow walk %s to %s: %d starts x %d sizes in %.1f s on %d workers, uncached; %d starts to walk\n",
            spawn$start, spawn$end, nrow(trial) / length(q_grid), length(q_grid), t_trial, workers, nrow(starts)))
t0 <- Sys.time()
w <- knw_link_walks(pg, starts, q_grid = q_grid, sources = "pick", workers = workers, cache = walk_cache,
                    window = spawn)
t_walk <- secs(t0)
wc <- attr(w, "cache")
if (nrow(w) != nrow(starts) * length(q_grid) || !identical(unique(w$src), src_spawn)) {
  stop("the window walk did not return one row per start and size on ", src_spawn, call. = FALSE)
}
# the trial, walked without the cache, is the same walk as the kept one
tk <- paste(trial$blue_line_key, trial$downstream_route_measure, trial$qmin)
wk_ <- w[match(tk, paste(w$blue_line_key, w$downstream_route_measure, w$qmin)), , drop = FALSE]
if (!isTRUE(all.equal(as.data.frame(trial), as.data.frame(wk_), check.attributes = FALSE))) {
  stop("the trial walk and the kept walk differ", call. = FALSE)
}
status <- table(w$status)
cat(sprintf("walked %d starts x %d sizes in %.1f min (%d start-and-source pairs read from %s, %d walked): %s\n",
            nrow(starts), length(q_grid), t_walk / 60, wc[["hit"]], walk_cache, wc[["miss"]],
            paste(names(status), status, sep = " ", collapse = ", ")))
pub_pick <- walks[walks$src == "pick", , drop = FALSE]
pub_status <- table(pub_pick$status)
cat("the annual walk on pick, for the same starts:",
    paste(names(pub_status), pub_status, sep = " ", collapse = ", "), "\n")
found <- w$status == "found"
if (anyNA(w$large_mad[found]) || any(w$large_mad[found] < w$qmin[found])) {
  stop("a river found carries a window flow under its size", call. = FALSE)
}
w$target_lake <- NA
w$target_regulated <- NA
if (!setequal(names(w), names(walks))) stop("the window walk's columns are not the published walks'", call. = FALSE)
w <- as.data.frame(w)[, names(walks)]

# ---- Phase 1's river reading against the exact walk ----
# Phase 1: the nearest river on the annual walk's ladder whose spawning window flow reaches the matched threshold.
# Exact: the window walk to that threshold. A visit is counted where one has a river within the rule's distance and
# the other has none.
thr <- p1$thr_river
pt <- paste(d$blue_line_key, d$downstream_route_measure)
ladder <- pub_pick[pub_pick$status == "found" &
                     paste(pub_pick$blue_line_key, pub_pick$downstream_route_measure) %in% pt, , drop = FALSE]
conn <- pg()
riv <- knw_link_flow_window(conn, unique(ladder$large_lfid), spawn)
DBI::dbDisconnect(conn)
riv_q <- riv[[.knw_windows(spawn)$col]][match(ladder$large_lfid, riv$linear_feature_id)]
approx <- tapply(ifelse(!is.na(riv_q) & riv_q >= thr, ladder$dist_m, Inf),
                 paste(ladder$blue_line_key, ladder$downstream_route_measure), min)
approx <- unname(ifelse(is.na(approx[pt]), Inf, approx[pt]))
ex <- knw_link_walks(pg, unique(d[, c("blue_line_key", "downstream_route_measure")]), q_grid = thr,
                     sources = "pick", workers = workers, window = spawn)
exact <- ifelse(ex$status == "found", ex$dist_m, Inf)
exact <- exact[match(pt, paste(ex$blue_line_key, ex$downstream_route_measure))]
in_a <- approx <= pub$exc_d
in_e <- exact <= pub$exc_d
cat(sprintf("\nPhase 1's river reading against the exact walk, at %.4f m3/s within %g m, over the %d scored visits:\n",
            thr, pub$exc_d, nrow(d)))
cat(sprintf(paste("  a river within reach: ladder %d, exact %d; ladder only %d, exact only %d",
                  "(%d with CH among the %d that differ)\n"),
            sum(in_a), sum(in_e), sum(in_a & !in_e), sum(!in_a & in_e), sum((in_a != in_e) & d$U == 1L),
            sum(in_a != in_e)))

# ---- write the copy ----
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
f_out <- stats::setNames(file.path(out_dir, paste0(tables, ".csv")), tables)
unlink(c(f_out, file.path(out_dir, "window_run.csv")))
# the visits, every field as its own text, with the window flow beside them at 15 significant digits, as readr
# wrote every other number of the table (0310's write_csv). readr neither writes a double's every digit nor reads
# 17 digits back to the same bits, so the window flow is held to what it reads back as, within 1e-12 of itself
raw <- readr::read_csv(f_src[["visits_link"]], col_types = readr::cols(.default = "c"), na = character(),
                       show_col_types = FALSE, progress = FALSE)
if (nrow(raw) != nrow(vl) || !identical(raw$site_visit, vl$site_visit)) {
  stop("the visits read as text are not the visits", call. = FALSE)
}
raw[[col_rear]] <- ifelse(is.na(win_flow), "", sprintf("%.15g", win_flow))
readr::write_csv(raw, f_out[["visits_link"]], na = "", progress = FALSE)
if (!file.copy(f_src[["visits_species"]], f_out[["visits_species"]])) {
  stop("could not copy visits_species.csv", call. = FALSE)
}
# the walks: the published file's bytes, then the window rows
if (!file.copy(f_src[["walks"]], f_out[["walks"]])) stop("could not copy walks.csv", call. = FALSE)
readr::write_csv(w, f_out[["walks"]], na = "", append = TRUE, progress = FALSE)

# ---- read the copy back: the published values are unchanged, and the window is there ----
# column by column, through the reader the tuning uses: a reader's own attributes (its column spec) differ between
# two files, the values must not. `exact` holds each column to the same type and bits, which the published values
# must keep, their text being unchanged. What this run computed was written at 15 digits and is held to the same
# numbers within 1e-12 of their size
near <- function(a, b) {
  if (!is.numeric(a) || !is.numeric(b)) return(identical(as.character(a), as.character(b)))
  identical(is.na(a), is.na(b)) && all(abs(a - b) <= 1e-12 * pmax(1, abs(b)), na.rm = TRUE)
}
same_cols <- function(a, b, exact = TRUE) {
  identical(names(a), names(b)) && nrow(a) == nrow(b) &&
    all(vapply(names(a), function(n) if (exact) identical(a[[n]], b[[n]]) else near(a[[n]], b[[n]]), logical(1)))
}
vl2 <- read_visits(f_out[["visits_link"]])
if (!identical(names(vl2), c(names(vl), col_rear)) || !same_cols(vl2[names(vl)], vl)) {
  stop("the copy's visits do not read back as the published visits", call. = FALSE)
}
if (!near(vl2[[col_rear]], win_flow) || !identical(vl2[[col_rear]] > 0, win_flow > 0)) {
  stop("the window flow does not read back as it was computed", call. = FALSE)
}
walks2 <- readr::read_csv(f_out[["walks"]], show_col_types = FALSE, progress = FALSE)
n_pub <- nrow(walks)
cols_walk <- setdiff(names(w), c("target_lake", "target_regulated"))
if (nrow(walks2) != n_pub + nrow(w) || !same_cols(walks2[seq_len(n_pub), ], walks) ||
      !identical(unique(walks2$src[-seq_len(n_pub)]), src_spawn) ||
      !same_cols(walks2[-seq_len(n_pub), cols_walk], w[, cols_walk], exact = FALSE) ||
      !all(is.na(walks2$target_lake[-seq_len(n_pub)]))) {
  stop("the copy's walks do not read back as the published walks and the window walk", call. = FALSE)
}
md5_out <- stats::setNames(unname(tools::md5sum(f_out)), tables)
if (!identical(md5_out[["visits_species"]], md5_src[["visits_species"]])) {
  stop("visits_species.csv changed in the copy", call. = FALSE)
}
cat(sprintf("\nwrote %s: %d visits (%d columns, one new), %d walk rows (%d published, %d on %s); read back equal\n",
            out_dir, nrow(vl2), ncol(vl2), nrow(walks2), n_pub, nrow(w), src_spawn))

run <- data.frame(
  head = head_sha, tune_run = summ$tune_run, source_dir = src_dir, source_md5 = summ$evidence_md5,
  out_dir = out_dir, out_md5 = paste(unname(md5_out), collapse = ";"), discharge_load = load,
  walk_md5 = knw_walk_md5(), walk_md5_window = knw_walk_md5(window = TRUE), walk_cache = walk_cache,
  window_stream = paste(rear$start, rear$end), column_stream = col_rear,
  window_river = paste(spawn$start, spawn$end), src_river = src_spawn,
  months_river = paste(wts$months, collapse = ";"),
  weights_river = paste(sprintf("%.17g", wts$weights), collapse = ";"),
  q_grid = paste(q_grid, collapse = ";"), picked_segments = short$segments,
  picked_segments_short = short$window_short,
  visits = nrow(vl), visits_with_flow = sum(has), visits_dry_in_window = n_dry,
  visits_tied_parent_differs = length(tied), starts = nrow(starts),
  walk_found = unname(status["found"]), walk_rows = nrow(w), walk_trial_s = round(t_trial, 1),
  walk_min = round(t_walk / 60, 2), workers = workers,
  scored_visits = nrow(d), med_rear_visit = med, river_ladder_only = sum(in_a & !in_e),
  river_exact_only = sum(!in_a & in_e), target_flags = "empty on the window rows",
  wet_version = as.character(utils::packageVersion("wet")), round_trip_ms = round(lat$ms, 1)
)
utils::write.csv(run, file.path(out_dir, "window_run.csv"), row.names = FALSE, na = "")
utils::write.csv(run, file.path(run_dir, "ch_rear_window_evidence_run.csv"), row.names = FALSE, na = "")
cat("wrote", file.path(run_dir, "ch_rear_window_evidence_run.csv"), "\nfinished:", stamp(), "\n")
