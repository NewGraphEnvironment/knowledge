# data-raw/timing_nuseds.R
# ---------------------------------------------------------------------------
# NuSEDS spawning windows for every watershed group and species with dated spawner records (#96, #240), each set
# beside the rows of the timing table (data/life_history_timing.csv). The table's rows are entered by hand, as its
# other rows are; this script writes no row.
#
# WHY / DESIGN NOTES:
#   - THE PUBLISHED RECORDS. It reads knowledge/nuseds/<VERSION> over HTTPS (the objects are public) and refuses a
#     Parquet whose sha256 is not the manifest's, so a run names the set it read: the release, the sha256 and the
#     commit that published it are printed first.
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
#   - THE WINDOW. For each population and year: spawning starts at START_SPAWN_DT_FROM and ends at END_SPAWN_DT_TO,
#     or END_SPAWN_DT_FROM where DFO gives no END_SPAWN_DT_TO. Dates are DD-MON-YY; only the month and day are read.
#     A group's window runs from the median start to the median end over its population-years with dates, with the
#     10th and 90th percentiles. Days are counted on a season year that starts on 1 April (1 September for
#     steelhead, which spawn in spring), so a coho or chum spawning end in January counts after December, not before
#     August. Each population's own window and run type are printed beside the group's, and a window per run type
#     where a group holds more than one, so a reader sees where one stream sets the window and where runs differ.
#     Stream arrival is printed for the migration rows.
#   - THE COMPARISON. Every row of the timing table is set beside its group's window: a spawning row's start and end,
#     and a migration row's end against the day before NuSEDS's median start (the table's convention that migration
#     ends where spawning starts), each as a difference in days (NuSEDS minus the row). Other stages have no NuSEDS
#     measure. The group's apart populations are listed under each compared row. No threshold: every difference is
#     printed, largest first.
#   - A CHECK. The UFRA and COTR chinook rows rest on #96's windows (scripts/logs/timing/20261118_timing_nuseds.txt):
#     the script stops unless it reproduces them, and BULK chinook's pooled window as #240 measured it.
#
# INPUT:  https://fresh-bc.s3.us-west-2.amazonaws.com/knowledge/nuseds/<VERSION>/ (manifest.json,
#         nuseds_records.parquet), data/nuseds_reach_groups.csv, data/life_history_timing.csv, a database holding
#         whse_basemapping (PG*)
# OUTPUT: the windows and the comparison, printed; with OUT= the windows as a CSV, one row per group x species x
#         scope (group, run_type, population, apart)
# RUN:    d=$(date -u +%Y%m%d); OUT=scripts/logs/timing/${d}_timing_nuseds_windows.csv Rscript data-raw/timing_nuseds.R \
#           2>&1 | tee scripts/logs/timing/${d}_timing_nuseds.txt   (repo root)
#         GROUPS=BULK,MORR SPECIES=CH ...   (comma lists, else every group and species with dated records)
#         VERSION=v1 ...                    (the published set, else v1)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1, width = 200)

env_list <- function(v) {
  v <- toupper(trimws(strsplit(Sys.getenv(v), ",")[[1]]))
  v[nzchar(v)]
}
want_groups <- env_list("GROUPS")
want_species <- env_list("SPECIES")
version <- Sys.getenv("VERSION", "v1")
out <- Sys.getenv("OUT")
species_codes <- c(Chinook = "CH", Coho = "CO", Sockeye = "SK", Pink = "PK", Chum = "CM", Steelhead = "ST")
if (length(bad <- setdiff(want_species, species_codes))) {
  stop("SPECIES outside ", paste(species_codes, collapse = ", "), ": ", paste(bad, collapse = ", "), call. = FALSE)
}
season_start <- c(CH = "04-01", CO = "04-01", SK = "04-01", PK = "04-01", CM = "04-01", ST = "09-01")

# ---- the published records ----
base <- paste0("https://fresh-bc.s3.us-west-2.amazonaws.com/knowledge/nuseds/", version, "/")
fetch <- function(name) {
  dest <- tempfile(fileext = paste0(".", tools::file_ext(name)))
  r <- curl::curl_fetch_disk(paste0(base, name), dest)
  if (r$status_code != 200L) stop("GET ", base, name, " returned HTTP ", r$status_code, call. = FALSE)
  dest
}
man <- jsonlite::read_json(fetch("manifest.json"))
mf <- Filter(function(f) identical(f$table, "nuseds_records"), man$files)
if (length(mf) != 1L) stop(base, "manifest.json lists nuseds_records ", length(mf), " times", call. = FALSE)
mf <- mf[[1]]
pq <- fetch(mf$path)
sha <- .knw_sha256(pq)
if (!identical(sha, mf$sha256)) stop(mf$path, " sha256 ", sha, " is not the manifest's ", mf$sha256, call. = FALSE)
cols <- c("pop_id", "gfe_id", "waterbody", "species", "run_type", "analysis_yr", "fwa_watershed_cde",
          "stream_arrival_dt_from", "start_spawn_dt_from", "end_spawn_dt_from", "end_spawn_dt_to")
x <- as.data.frame(arrow::read_parquet(pq, col_select = dplyr::all_of(cols)))
cat("NuSEDS", man$id, "release", man$provenance$nuseds_release, "published from knowledge",
    man$provenance$published_from_commit, "\n", mf$path, "sha256", sha, "(the manifest's),", nrow(x), "rows\n")

x$species_code <- unname(species_codes[x$species])
x <- x[!is.na(x$species_code) & (!length(want_species) | x$species_code %in% want_species), , drop = FALSE]
x$end_dt <- ifelse(is.na(x$end_spawn_dt_to), x$end_spawn_dt_from, x$end_spawn_dt_to)
dated <- !is.na(x$start_spawn_dt_from) | !is.na(x$end_dt)
cat(sum(dated), "dated records of", length(unique(x$pop_id[dated])), "populations;",
    sum(dated & is.na(x$fwa_watershed_cde)), "dated records carry no FWA watershed code\n")
x <- x[!is.na(x$fwa_watershed_cde), , drop = FALSE]

# ---- days on the season year ----
# day of a leap year (2000) for "DD-MON-YY" or "MM-DD"; a day before the species' season start counts in the next year
doy <- function(d, format) {
  out <- rep(NA_integer_, length(d))
  i <- !is.na(d)
  if (!any(i)) return(out)
  md <- withr::with_locale(c(LC_TIME = "C"), as.Date(paste0(if (format == "nuseds") substr(d[i], 1, 6) else d[i],
                                                            if (format == "nuseds") "-2000" else "-2000"),
                                                     format = if (format == "nuseds") "%d-%b-%Y" else "%m-%d-%Y"))
  if (anyNA(md)) stop("dates not ", format, ": ", paste(unique(d[i][is.na(md)]), collapse = ", "), call. = FALSE)
  out[i] <- as.integer(format(md, "%j"))
  out
}
season <- function(day, sp) {
  s0 <- doy(season_start[sp], "mmdd")
  ifelse(!is.na(day) & day < s0, day + 366L, day)
}
day_str <- function(v) ifelse(is.na(v), NA_character_,
                              format(as.Date((round(v) - 1) %% 366, origin = "2000-01-01"), "%m-%d"))
x$start_day <- season(doy(x$start_spawn_dt_from, "nuseds"), x$species_code)
x$end_day <- season(doy(x$end_dt, "nuseds"), x$species_code)
x$arrival_day <- season(doy(x$stream_arrival_dt_from, "nuseds"), x$species_code)

# ---- watershed groups ----
con <- DBI::dbConnect(RPostgres::Postgres())
g <- DBI::dbGetQuery(con, "
  SELECT fwa_watershed_code, array_to_string(array_agg(DISTINCT watershed_group_code ORDER BY watershed_group_code), ',')
    AS groups
  FROM whse_basemapping.fwa_stream_networks_sp WHERE fwa_watershed_code = ANY($1::text[]) GROUP BY 1",
  params = list(paste0("{", paste(unique(x$fwa_watershed_cde), collapse = ","), "}")))
DBI::dbDisconnect(con)
x$groups <- g$groups[match(x$fwa_watershed_cde, g$fwa_watershed_code)]
cat(sum(is.na(x$groups) & (!is.na(x$start_day) | !is.na(x$end_day))),
    "dated records carry a watershed code the Atlas does not hold\n")
x <- x[!is.na(x$groups), , drop = FALSE]
x$wsg <- ifelse(grepl(",", x$groups), NA_character_, x$groups)

reach <- utils::read.csv("data/nuseds_reach_groups.csv", colClasses = "character")
for (i in seq_len(nrow(reach))) {
  hit <- x$gfe_id == as.numeric(reach$gfe_id[i])
  if (!any(hit)) stop("data/nuseds_reach_groups.csv: gfe_id ", reach$gfe_id[i], " is in no record", call. = FALSE)
  if (!all(x$waterbody[hit] == reach$waterbody[i])) {
    stop("data/nuseds_reach_groups.csv: gfe_id ", reach$gfe_id[i], " is ", paste(unique(x$waterbody[hit]),
         collapse = ", "), ", not ", reach$waterbody[i], call. = FALSE)
  }
  crossed <- unique(unlist(strsplit(x$groups[hit], ",")))
  if (!reach$wsg_code[i] %in% crossed) {
    stop("data/nuseds_reach_groups.csv: ", reach$waterbody[i], "'s code does not cross ", reach$wsg_code[i],
         " (it crosses ", paste(crossed, collapse = ", "), ")", call. = FALSE)
  }
  x$wsg[hit] <- reach$wsg_code[i]
}
cat("named reaches (data/nuseds_reach_groups.csv):", paste(reach$waterbody, "->", reach$wsg_code, collapse = "; "),
    "\n")

# ---- windows ----
qd <- function(v, p) if (all(is.na(v))) NA_real_ else stats::quantile(v, p, na.rm = TRUE, names = FALSE, type = 7)
yr <- function(d, f) {
  y <- as.integer(d$analysis_yr[!is.na(d$start_day) | !is.na(d$end_day)])
  if (length(y)) f(y) else NA_integer_
}
summ <- function(d) data.frame(
  records = nrow(d), years_start = sum(!is.na(d$start_day)), years_end = sum(!is.na(d$end_day)),
  first_year = yr(d, min), last_year = yr(d, max),
  start_median = day_str(qd(d$start_day, 0.5)), start_q10 = day_str(qd(d$start_day, 0.1)),
  start_q90 = day_str(qd(d$start_day, 0.9)), end_median = day_str(qd(d$end_day, 0.5)),
  end_q10 = day_str(qd(d$end_day, 0.1)), end_q90 = day_str(qd(d$end_day, 0.9)),
  arrival_median = day_str(qd(d$arrival_day, 0.5)), years_arrival = sum(!is.na(d$arrival_day)),
  start_day = round(qd(d$start_day, 0.5)), end_day = round(qd(d$end_day, 0.5)), arrival_day = round(qd(d$arrival_day, 0.5)))
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
if (length(want_groups)) keys <- keys[keys$wsg %in% want_groups, , drop = FALSE]
keys <- keys[order(keys$wsg, match(keys$species_code, species_codes)), , drop = FALSE]
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
show <- c("scope", "run_type", "pop_id", "waterbody", "groups", "records", "years_start", "years_end", "first_year",
          "last_year", "start_median", "start_q10", "start_q90", "end_median", "end_q10", "end_q90", "arrival_median",
          "years_arrival")
for (k in seq_len(nrow(keys))) {
  w <- keys$wsg[k]
  sp <- keys$species_code[k]
  d <- win[win$wsg_code == w & win$species_code == sp, , drop = FALSE]
  d <- d[order(match(d$scope, c("group", "run_type", "population", "apart")), -d$years_start), , drop = FALSE]
  cat("\n====", w, sp, ":", sum(d$scope == "population"), "populations pooled,", sum(d$scope == "apart"),
      "apart (on a stream crossing several groups)\n")
  print(d[, show], row.names = FALSE)
}

# ---- the windows the published rows rest on ----
check <- function(w, sp, start, end, ys = NULL, ye = NULL) {
  r <- win[win$wsg_code == w & win$species_code == sp & win$scope == "group", , drop = FALSE]
  if (!nrow(r)) return(invisible(cat("check skipped:", w, sp, "not in this run\n")))
  got <- c(r$start_median, r$end_median, r$years_start, r$years_end)
  ok <- identical(got[1:2], c(start, end)) && (is.null(ys) || identical(as.integer(got[3:4]), c(ys, ye)))
  if (!ok) stop(w, " ", sp, " window is ", paste(got, collapse = " "), ", not ", start, " ", end, " ", ys, " ", ye,
                call. = FALSE)
  cat("check:", w, sp, start, "to", end, "as published\n")
}
check("UFRA", "CH", "08-11", "09-05", 123L, 126L)
check("COTR", "CH", "08-10", "09-06", 35L, 36L)
check("BULK", "CH", "08-15", "09-10", 28L, 27L)

# ---- the timing table beside NuSEDS ----
tt <- as.data.frame(knw_timing_read("data/life_history_timing.csv"))
if (length(want_groups)) tt <- tt[tt$wsg_code %in% want_groups, , drop = FALSE]
if (length(want_species)) tt <- tt[tt$species_code %in% want_species, , drop = FALSE]
cmp <- do.call(rbind, lapply(seq_len(nrow(tt)), function(i) {
  r <- tt[i, ]
  g1 <- win[win$wsg_code == r$wsg_code & win$species_code == r$species_code & win$scope == "group", , drop = FALSE]
  na <- data.frame(start_nuseds = NA_character_, end_nuseds = NA_character_, d_start = NA_real_, d_end = NA_real_)
  verdict <- if (!r$species_code %in% species_codes) "no NuSEDS species"
             else if (!nrow(g1)) "no NuSEDS window for the group"
             else if (r$life_stage == "spawning") "spawning window"
             else if (r$life_stage == "migration" && is.na(r$end)) "migration row has no end"
             else if (r$life_stage == "migration") "migration end vs the day before spawning starts"
             else "no NuSEDS measure"
  v <- na
  if (verdict == "spawning window") {
    v <- data.frame(start_nuseds = g1$start_median, end_nuseds = g1$end_median,
                    d_start = g1$start_day - season(doy(r$start, "mmdd"), r$species_code),
                    d_end = g1$end_day - season(doy(r$end, "mmdd"), r$species_code))
  } else if (startsWith(verdict, "migration")) {
    v <- data.frame(start_nuseds = paste("arrival", g1$arrival_median), end_nuseds = day_str(g1$start_day - 1),
                    d_start = NA_real_, d_end = (g1$start_day - 1) - season(doy(r$end, "mmdd"), r$species_code))
  }
  cbind(r[, c("wsg_code", "species_code", "life_stage", "start", "end", "source")], v, compared = verdict)
}))
cmp$largest <- pmax(abs(cmp$d_start), abs(cmp$d_end), na.rm = TRUE)
cat("\n==== the timing table beside NuSEDS (days: NuSEDS minus the row; pooled group windows)\n")
done <- cmp[!is.na(cmp$largest), , drop = FALSE]
print(done[order(-done$largest), setdiff(names(done), "largest")], row.names = FALSE)
for (i in which(!is.na(cmp$largest))) {
  a <- win[win$wsg_code == cmp$wsg_code[i] & win$species_code == cmp$species_code[i] & win$scope == "apart", ,
           drop = FALSE]
  if (!nrow(a)) next
  cat("\n", cmp$wsg_code[i], cmp$species_code[i], cmp$life_stage[i], "row: apart populations in", cmp$wsg_code[i], "\n")
  print(a[order(-a$years_start), c("pop_id", "waterbody", "groups", "years_start", "first_year", "last_year",
                                   "start_median", "end_median", "arrival_median")], row.names = FALSE)
}
cat("\nrows not compared:\n")
print(as.data.frame(table(compared = cmp$compared[is.na(cmp$largest)])), row.names = FALSE)

if (nzchar(out)) {
  utils::write.csv(win[, c("wsg_code", "species_code", show)], out, row.names = FALSE, na = "")
  cat("\nwrote", nrow(win), "windows to", out, "\n")
}
