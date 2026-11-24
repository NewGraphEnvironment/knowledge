# data-raw/timing_nuseds.R
# ---------------------------------------------------------------------------
# NuSEDS spawning windows for every watershed group and species with dated spawner records (#96, #240, #256), each
# set beside the rows of the timing table (data/life_history_timing.csv). The table's rows are entered by hand, as
# its other rows are; this script writes no row.
#
# WHY / DESIGN NOTES:
#   - THE PUBLISHED RECORDS. It reads knowledge/nuseds/<VERSION> over HTTPS (the objects are public) through
#     data-raw/nuseds_dates_read.R, which refuses a Parquet whose sha256 is not the manifest's, so a run names the set
#     it read: the release, the sha256 and the commit that published it are printed first.
#   - POPULATIONS BY WATERSHED CODE. A record's FWA_WATERSHED_CDE is matched to the Freshwater Atlas. A population
#     whose code lies in one group pools into that group's window. A code that runs through several groups (a
#     mainstem: the Bulkley, the Morice, the Skeena) says nothing about where on it the fish spawn, so such a
#     population is kept out of every group's window and listed under each group its code crosses ("apart"), unless
#     data/nuseds_reach_groups.csv names its reach (DFO's gfe_id) and the group that reach lies in. That table is
#     added to as the reviews place reaches (#241, #242); the script refuses an entry whose name is not the reach's
#     or whose group the code does not cross. A named reach belongs to its group alone and is not listed apart under
#     the other groups its code crosses. The table is keyed by reach, not code: the Fraser's one code runs through
#     every Fraser group. DFO's census-site points cannot place a reach: Morice River's lies in BULK (#244's
#     exploration).
#   - WHAT A NUSEDS DATE IS (#256, research/nuseds_timing.md, data-raw/nuseds_dates_check.R). A start, peak or end
#     of spawning is an estimate: a date on the five-day grid before the 1990s, a ten-day bin after, often recorded
#     before the survey began, and written on records whose survey saw no spawner at all. So the window is read for
#     its middle, and an edge only where a survey stands behind it. Each window carries four readings:
#       rec_*   AS RECORDED, #240's window: spawning starts at START_SPAWN_DT_FROM and ends at END_SPAWN_DT_TO, or
#               END_SPAWN_DT_FROM where DFO gives no END_SPAWN_DT_TO, over every dated record. Kept so the windows
#               the published rows rest on (#96's UFRA and COTR) stay reproducible.
#       bulk_*  THE BULK OF SPAWNING: the median start to the median end, a bin entering as its midpoint (a bin over 31
#               days, or one running backwards, gives none), over records whose adults were present (adult presence
#               other than NONE OBSERVED or NOT INSPECTED) and whose window does not end before it starts, each edge
#               over the records that give it, so it carries its own years (a start given only as START_SPAWN_DT_TO,
#               which the as-recorded reading skips, enters it). The sets are nuseds_survey()'s.
#       peak_*  THE PEAK, read the same way over present records that give a peak, some of which give no start or
#               end (UFRA's chinook peaks run to 2014, its starts to 2000), so it carries its own years.
#       edge_*  AN EDGE CONSISTENT WITH ONE SOMEONE SAW: the median start over present records whose survey began
#               before the recorded start with at least 3 visits, and the median end over present records whose survey
#               ended after the recorded end with at least 3 visits (whatever the other edge gives), each given only where 5 or more records qualify (its n is
#               always given). NuSEDS keeps no count per visit, so this is never proof of an edge.
#     Dates are DD-MON-YY; only the month and day are read for a day. Medians come with the 10th and 90th
#     percentiles. A record is one population, stream (gfe_id) and year, so n counts population-years except where a
#     population was counted on two streams in one year (16 dated records with a watershed code, of two populations,
#     in the 2026-06-01 release). Days are counted on a season year that starts on 1 April (1 September for
#     steelhead, which spawn in spring), so a coho or chum spawning end in January counts after December, not before
#     August. Each population's own window and run type are printed beside the group's, and a window per run type
#     where a group holds more than one, so a reader sees where one stream sets the window and where runs differ.
#     Stream arrival (as recorded, every dated record) is printed for the migration rows.
#   - THE COMPARISON. Every row of the timing table is set beside its group's window, estimate against estimate: a
#     spawning row's start and end beside NuSEDS's bulk, its middle beside NuSEDS's peak, and its start and end beside
#     an edge where one is given; a migration row's end beside the day before the bulk's median start (the table's
#     convention that migration ends where spawning starts). Each is a difference in days (NuSEDS minus the row).
#     Other stages have no NuSEDS measure. The group's apart populations are listed under each compared row. No
#     threshold: every difference is printed, largest first.
#   - A CHECK. The UFRA and COTR chinook rows rest on #96's windows (scripts/logs/timing/20261118_timing_nuseds.txt):
#     the script stops unless the as-recorded reading reproduces them, and BULK chinook's pooled window as #240
#     measured it.
#
# INPUT:  https://fresh-bc.s3.us-west-2.amazonaws.com/knowledge/nuseds/<VERSION>/ (manifest.json,
#         nuseds_records.parquet), data/nuseds_reach_groups.csv, data/life_history_timing.csv, a database holding
#         whse_basemapping (PG*)
# OUTPUT: the windows and the comparison, printed; with OUT= the windows as a CSV, one row per window: per group and
#         species with pooled records its window (scope group), one per run type where it holds several (run_type),
#         and one per population pooled (population) or listed apart (apart); its columns are the four readings above
# RUN:    d=$(date -u +%Y%m%d); t=${TMPDIR:-/tmp}/${d}_timing_nuseds
#         (set -o pipefail; OUT=${t}_windows.csv Rscript data-raw/timing_nuseds.R 2>&1 | tee ${t}.txt) &&
#           cp ${t}.txt ${t}_windows.csv scripts/logs/timing/   (repo root)
#         Written outside the repo and copied in after a run that succeeded, as 0340's log is (#230): a tee into a
#         tracked log truncates it at launch. Only a full run takes OUT, so only it reaches the copy.
#         WSG=BULK,MORR SPECIES=CH Rscript data-raw/timing_nuseds.R   (a run to read: comma lists, else every group
#                                           and species with dated records; it refuses OUT, and a group with no dated
#                                           record; not GROUPS, which bash keeps for itself)
#         VERSION=v1 before Rscript         (the published set, else v1)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1, width = 200)
source("data-raw/nuseds_dates_read.R")

env_list <- function(v) {
  v <- toupper(trimws(strsplit(Sys.getenv(v), ",")[[1]]))
  v[nzchar(v)]
}
want_groups <- env_list("WSG")
want_species <- env_list("SPECIES")
version <- Sys.getenv("VERSION", "v1")
out <- Sys.getenv("OUT")
species_codes <- nuseds_species
if (length(bad <- setdiff(want_species, species_codes))) {
  stop("SPECIES outside ", paste(species_codes, collapse = ", "), ": ", paste(bad, collapse = ", "), call. = FALSE)
}
filtered <- length(want_groups) > 0L || length(want_species) > 0L
if (filtered && nzchar(out)) {
  stop("OUT is the full run's table: a run with WSG or SPECIES prints only, so it never replaces it", call. = FALSE)
}
edge_min <- 5L

# ---- the published records ----
cols <- c("pop_id", "gfe_id", "waterbody", "species", "run_type", "analysis_yr", "fwa_watershed_cde",
          "stream_arrival_dt_from", "start_spawn_dt_from", "start_spawn_dt_to", "peak_spawn_dt_from",
          "peak_spawn_dt_to", "end_spawn_dt_from", "end_spawn_dt_to", "start_dtt", "end_dtt", "no_inspections_used",
          "adult_presence")
x <- nuseds_read(version, cols)
x$species_code <- unname(species_codes[x$species])
x <- x[!is.na(x$species_code), , drop = FALSE]
x$end_dt <- ifelse(is.na(x$end_spawn_dt_to), x$end_spawn_dt_from, x$end_spawn_dt_to)
dated <- !is.na(x$start_spawn_dt_from) | !is.na(x$end_dt)
cat(sum(dated), "dated records of", length(unique(x$pop_id[dated])), "populations;",
    sum(dated & is.na(x$fwa_watershed_cde)), "dated records carry no FWA watershed code\n")
x <- x[!is.na(x$fwa_watershed_cde), , drop = FALSE]

# ---- days on the season year ----
x$start_day <- nuseds_season(nuseds_doy(x$start_spawn_dt_from, "nuseds"), x$species_code)
x$end_day <- nuseds_season(nuseds_doy(x$end_dt, "nuseds"), x$species_code)
x$arrival_day <- nuseds_season(nuseds_doy(x$stream_arrival_dt_from, "nuseds"), x$species_code)
x <- nuseds_survey(x)
# nuseds_survey() defines the bulk, peak and edge sets (method, start_mid, end_mid, peak_mid, edge_start, edge_end)
x$edge_start_day <- ifelse(x$edge_start, x$start_mid, NA_integer_)
x$edge_end_day <- ifelse(x$edge_end, x$end_mid, NA_integer_)
has_start <- !is.na(x$start_spawn_dt_from) | !is.na(x$start_spawn_dt_to)
has_end <- !is.na(x$end_spawn_dt_from) | !is.na(x$end_spawn_dt_to)
cat("the bulk and peak leave out", sum(!x$present & (has_start | has_end)), "records giving a start or end whose adults were NONE",
    "OBSERVED or NOT INSPECTED and", sum(x$present & x$backwards), "that end before they start;",
    sum(x$method & has_start & is.na(x$start_mid)), "starts and", sum(x$method & has_end & is.na(x$end_mid)),
    "ends are bins over 31 days or running backwards (no midpoint);", sum(x$survey_slip & (has_start | has_end)),
    "such records' surveys, with a date over a year from the record's or ending before they start, are not compared\n")

# ---- watershed groups ----
x <- nuseds_place(x, dated = !is.na(x$start_day) | !is.na(x$end_day))
if (length(want_species)) x <- x[x$species_code %in% want_species, , drop = FALSE]

# ---- windows ----
qd <- function(v, p) if (all(is.na(v))) NA_real_ else stats::quantile(v, p, na.rm = TRUE, names = FALSE, type = 7)
ds <- function(v, p) nuseds_day_str(qd(v, p))
yr <- function(d, f) {
  y <- as.integer(d$analysis_yr[!is.na(d$start_day) | !is.na(d$end_day)])
  if (length(y)) f(y) else NA_integer_
}
yrs <- function(d, i, f) if (any(i)) f(as.integer(d$analysis_yr[i])) else NA_integer_
edge <- function(v) if (sum(!is.na(v)) >= edge_min) ds(v, 0.5) else NA_character_
summ <- function(d) data.frame(
  records = nrow(d), first_year = yr(d, min), last_year = yr(d, max),
  rec_n_start = sum(!is.na(d$start_day)), rec_n_end = sum(!is.na(d$end_day)),
  rec_start_median = ds(d$start_day, 0.5), rec_start_q10 = ds(d$start_day, 0.1), rec_start_q90 = ds(d$start_day, 0.9),
  rec_end_median = ds(d$end_day, 0.5), rec_end_q10 = ds(d$end_day, 0.1), rec_end_q90 = ds(d$end_day, 0.9),
  bulk_n_start = sum(!is.na(d$start_mid)), bulk_n_end = sum(!is.na(d$end_mid)),
  bulk_first_year = yrs(d, !is.na(d$start_mid) | !is.na(d$end_mid), min),
  bulk_last_year = yrs(d, !is.na(d$start_mid) | !is.na(d$end_mid), max),
  bulk_start_median = ds(d$start_mid, 0.5), bulk_start_q10 = ds(d$start_mid, 0.1),
  bulk_start_q90 = ds(d$start_mid, 0.9), bulk_end_median = ds(d$end_mid, 0.5), bulk_end_q10 = ds(d$end_mid, 0.1),
  bulk_end_q90 = ds(d$end_mid, 0.9),
  peak_n = sum(!is.na(d$peak_mid)),
  peak_first_year = yrs(d, !is.na(d$peak_mid), min), peak_last_year = yrs(d, !is.na(d$peak_mid), max),
  peak_median = ds(d$peak_mid, 0.5), peak_q10 = ds(d$peak_mid, 0.1),
  peak_q90 = ds(d$peak_mid, 0.9),
  edge_n_start = sum(!is.na(d$edge_start_day)), edge_start_median = edge(d$edge_start_day),
  edge_n_end = sum(!is.na(d$edge_end_day)), edge_end_median = edge(d$edge_end_day),
  arrival_median = ds(d$arrival_day, 0.5), n_arrival = sum(!is.na(d$arrival_day)),
  rec_start_day = round(qd(d$start_day, 0.5)), rec_end_day = round(qd(d$end_day, 0.5)),
  bulk_start_day = round(qd(d$start_mid, 0.5)), bulk_end_day = round(qd(d$end_mid, 0.5)),
  peak_day = round(qd(d$peak_mid, 0.5)),
  edge_start_day = if (sum(!is.na(d$edge_start_day)) >= edge_min) round(qd(d$edge_start_day, 0.5)) else NA_real_,
  edge_end_day = if (sum(!is.na(d$edge_end_day)) >= edge_min) round(qd(d$edge_end_day, 0.5)) else NA_real_,
  arrival_day = round(qd(d$arrival_day, 0.5)))
x$run <- ifelse(is.na(x$run_type), "none", x$run_type)
pop_rows <- function(d, scope, w, sp) {
  if (!nrow(d)) return(NULL)
  do.call(rbind, lapply(split(d, d$pop_id), function(p) {
    cbind(wsg_code = w, species_code = sp, scope = scope, run_type = paste(sort(unique(p$run)), collapse = "; "),
          pop_id = p$pop_id[1], waterbody = paste(sort(unique(p$waterbody)), collapse = "; "), groups = p$groups[1],
          summ(p))
  }))
}
has_date <- !is.na(x$start_day) | !is.na(x$end_day)
pooled_keys <- unique(x[has_date & !is.na(x$wsg), c("wsg", "species_code")])
apart_x <- x[is.na(x$wsg), , drop = FALSE]
apart_keys <- if (nrow(apart_x)) {
  unique(do.call(rbind, lapply(which(!is.na(apart_x$start_day) | !is.na(apart_x$end_day)), function(i) {
    data.frame(wsg = strsplit(apart_x$groups[i], ",")[[1]], species_code = apart_x$species_code[i])
  })))
} else pooled_keys[0, ]
keys <- unique(rbind(pooled_keys, apart_keys))
if (length(want_groups)) {
  if (length(miss <- setdiff(want_groups, keys$wsg))) {
    stop("no dated records in WSG ", paste(miss, collapse = ", "), " for the species asked", call. = FALSE)
  }
  keys <- keys[keys$wsg %in% want_groups, , drop = FALSE]
}
keys <- keys[order(keys$wsg, match(keys$species_code, species_codes)), , drop = FALSE]
if (!nrow(keys)) stop("no dated records for the groups and species asked", call. = FALSE)
cat(nrow(keys), "group x species keys in", length(unique(keys$wsg)), "groups\n")

win <- list()
for (k in seq_len(nrow(keys))) {
  w <- keys$wsg[k]
  sp <- keys$species_code[k]
  d <- x[!is.na(x$wsg) & x$wsg == w & x$species_code == sp, , drop = FALSE]
  a <- apart_x[apart_x$species_code == sp & vapply(strsplit(apart_x$groups, ","), function(v) w %in% v, logical(1)) &
                 (!is.na(apart_x$start_day) | !is.na(apart_x$end_day)), , drop = FALSE]
  rows <- list()
  if (any(!is.na(d$start_day) | !is.na(d$end_day))) {
    rows$group <- cbind(wsg_code = w, species_code = sp, scope = "group",
                        run_type = paste(sort(unique(d$run)), collapse = "; "), pop_id = NA, waterbody = NA,
                        groups = w, summ(d))
    runs <- unique(d$run[!is.na(d$start_day) | !is.na(d$end_day)])
    if (length(runs) > 1L) {
      rows$run_type <- do.call(rbind, lapply(sort(runs), function(r) {
        cbind(wsg_code = w, species_code = sp, scope = "run_type", run_type = r, pop_id = NA, waterbody = NA,
              groups = w, summ(d[d$run == r, , drop = FALSE]))
      }))
    }
    dd <- d[d$pop_id %in% d$pop_id[!is.na(d$start_day) | !is.na(d$end_day)], , drop = FALSE]
    rows$population <- pop_rows(dd, "population", w, sp)
  }
  rows$apart <- pop_rows(apart_x[apart_x$pop_id %in% a$pop_id & apart_x$species_code == sp, , drop = FALSE],
                         "apart", w, sp)
  win[[k]] <- do.call(rbind, rows)
}
win <- do.call(rbind, win)
rownames(win) <- NULL
cols_csv <- c("scope", "run_type", "pop_id", "waterbody", "groups", "records", "first_year", "last_year",
              "rec_n_start", "rec_n_end", "rec_start_median", "rec_start_q10", "rec_start_q90", "rec_end_median",
              "rec_end_q10", "rec_end_q90", "bulk_n_start", "bulk_n_end", "bulk_first_year", "bulk_last_year", "bulk_start_median", "bulk_start_q10",
              "bulk_start_q90", "bulk_end_median", "bulk_end_q10", "bulk_end_q90", "peak_n", "peak_median",
              "peak_q10", "peak_q90", "peak_first_year", "peak_last_year", "edge_n_start", "edge_start_median", "edge_n_end", "edge_end_median",
              "arrival_median", "n_arrival")
show <- c("scope", "run_type", "pop_id", "waterbody", "groups", "records", "first_year", "last_year", "rec_n_start",
          "rec_start_median", "rec_end_median", "bulk_n_start", "bulk_start_median", "bulk_end_median", "peak_n",
          "peak_median", "edge_n_start", "edge_start_median", "edge_n_end", "edge_end_median", "arrival_median")
cat("\nreadings: rec_ as recorded (#240), bulk_ the bulk of spawning (bins as midpoints, present records), peak_ the",
    "peak, edge_ an edge a survey of 3+ visits stood beyond (given with", edge_min, "or more records)\n")
gw <- win[win$scope == "group", , drop = FALSE]
cat("group windows:", nrow(gw), "; with a start edge", sum(!is.na(gw$edge_start_median)), ", an end edge",
    sum(!is.na(gw$edge_end_median)), "; chinook", sum(gw$species_code == "CH"), "of which",
    sum(gw$species_code == "CH" & (!is.na(gw$edge_start_median) | !is.na(gw$edge_end_median))), "have either\n")
for (k in seq_len(nrow(keys))) {
  w <- keys$wsg[k]
  sp <- keys$species_code[k]
  d <- win[win$wsg_code == w & win$species_code == sp, , drop = FALSE]
  d <- d[order(match(d$scope, c("group", "run_type", "population", "apart")), -d$rec_n_start), , drop = FALSE]
  cat("\n====", w, sp, ":", sum(d$scope == "population"), "populations pooled,", sum(d$scope == "apart"),
      "apart (on a stream crossing several groups)\n")
  print(d[, show], row.names = FALSE)
}

# ---- the windows the published rows rest on (as recorded) ----
check <- function(w, sp, start, end, ys = NULL, ye = NULL) {
  r <- win[win$wsg_code == w & win$species_code == sp & win$scope == "group", , drop = FALSE]
  if (!nrow(r) && filtered) return(invisible(cat("check skipped:", w, sp, "not in this run\n")))
  if (!nrow(r)) stop("a full run has no ", w, " ", sp, " group window", call. = FALSE)
  got <- c(r$rec_start_median, r$rec_end_median, r$rec_n_start, r$rec_n_end)
  ok <- identical(got[1:2], c(start, end)) && (is.null(ys) || identical(as.integer(got[3:4]), c(ys, ye)))
  if (!ok) stop(w, " ", sp, " window is ", paste(got, collapse = " "), ", not ", start, " ", end, " ", ys, " ", ye,
                call. = FALSE)
  cat("check:", w, sp, start, "to", end, "as published (as recorded)\n")
}
check("UFRA", "CH", "08-11", "09-05", 123L, 126L)
check("COTR", "CH", "08-10", "09-06", 35L, 36L)
check("BULK", "CH", "08-15", "09-10", 28L, 27L)

if (nzchar(out)) {
  utils::write.csv(win[, c("wsg_code", "species_code", cols_csv)], out, row.names = FALSE, na = "")
  cat("\nwrote", nrow(win), "windows to", basename(out), "\n")
}

# ---- the timing table beside NuSEDS ----
tt <- as.data.frame(knw_timing_read("data/life_history_timing.csv"))
if (length(want_groups)) tt <- tt[tt$wsg_code %in% want_groups, , drop = FALSE]
if (length(want_species)) tt <- tt[tt$species_code %in% want_species, , drop = FALSE]
if (!nrow(tt)) {
  cat("\nthe timing table has no row for the groups and species asked: nothing to compare\n")
  quit(save = "no", status = 0)
}
cmp <- do.call(rbind, lapply(seq_len(nrow(tt)), function(i) {
  r <- tt[i, ]
  g1 <- win[win$wsg_code == r$wsg_code & win$species_code == r$species_code & win$scope == "group", , drop = FALSE]
  v <- data.frame(bulk = NA_character_, peak = NA_character_, edges = NA_character_, d_start = NA_real_,
                  d_end = NA_real_, d_mid = NA_real_, d_edge_start = NA_real_, d_edge_end = NA_real_)
  verdict <- if (!r$species_code %in% species_codes) "no NuSEDS species"
             else if (!nrow(g1)) "no NuSEDS window for the group"
             else if (r$life_stage == "spawning") "spawning window"
             else if (r$life_stage == "migration" && is.na(r$end)) "migration row has no end"
             else if (r$life_stage == "migration") "migration end vs the day before the bulk starts"
             else "no NuSEDS measure"
  if (verdict == "spawning window") {
    rs <- nuseds_season(nuseds_doy(r$start, "mmdd"), r$species_code)
    re <- nuseds_season(nuseds_doy(r$end, "mmdd"), r$species_code)
    v <- data.frame(bulk = paste(g1$bulk_start_median, "to", g1$bulk_end_median), peak = g1$peak_median,
                    edges = paste(ifelse(is.na(g1$edge_start_median), "-", g1$edge_start_median), "to",
                                  ifelse(is.na(g1$edge_end_median), "-", g1$edge_end_median)),
                    d_start = g1$bulk_start_day - rs, d_end = g1$bulk_end_day - re, d_mid = g1$peak_day - (rs + re) / 2,
                    d_edge_start = g1$edge_start_day - rs, d_edge_end = g1$edge_end_day - re)
  } else if (startsWith(verdict, "migration")) {
    v$bulk <- paste("arrival", g1$arrival_median, "; bulk starts", g1$bulk_start_median)
    v$d_end <- (g1$bulk_start_day - 1) - nuseds_season(nuseds_doy(r$end, "mmdd"), r$species_code)
  }
  cbind(r[, c("wsg_code", "species_code", "life_stage", "start", "end", "source")], v, compared = verdict)
}))
cmp$largest <- pmax(abs(cmp$d_start), abs(cmp$d_end), abs(cmp$d_mid), na.rm = TRUE)
cat("\n==== the timing table beside NuSEDS, estimate against estimate (days: NuSEDS minus the row; pooled group",
    "windows; d_start and d_end against the bulk, d_mid the peak against the row's middle, d_edge_ against an edge)\n")
done <- cmp[!is.na(cmp$largest), , drop = FALSE]
print(done[order(-done$largest), setdiff(names(done), "largest")], row.names = FALSE)
for (i in which(!is.na(cmp$largest))) {
  a <- win[win$wsg_code == cmp$wsg_code[i] & win$species_code == cmp$species_code[i] & win$scope == "apart", ,
           drop = FALSE]
  if (!nrow(a)) next
  cat("\n", cmp$wsg_code[i], cmp$species_code[i], cmp$life_stage[i], "row: apart populations in", cmp$wsg_code[i], "\n")
  print(a[order(-a$rec_n_start), c("pop_id", "waterbody", "groups", "rec_n_start", "first_year", "last_year",
                                   "bulk_start_median", "bulk_end_median", "peak_median", "edge_start_median",
                                   "edge_end_median", "arrival_median")], row.names = FALSE)
}
cat("\nrows not compared:\n")
print(as.data.frame(table(compared = cmp$compared[is.na(cmp$largest)])), row.names = FALSE)
