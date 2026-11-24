# data-raw/nuseds_dates_read.R
# ---------------------------------------------------------------------------
# Reading the published NuSEDS records for timing work: sourced by data-raw/timing_nuseds.R (the windows, #240) and
# data-raw/nuseds_dates_check.R (what each date is made of, #256), so both read one set, one calendar and one
# placement. Defines functions only; it reads nothing when sourced.
#
#   nuseds_read(version, cols)  the published nuseds_records over HTTPS, refused unless its sha256 is the manifest's
#   nuseds_doy(d, format)       day of a leap year for "DD-MON-YY" (format "nuseds") or "MM-DD" (format "mmdd")
#   nuseds_season(day, sp)      that day on the species' season year (1 April; 1 September for steelhead)
#   nuseds_day_str(v)           a season day back to "MM-DD"
#   nuseds_date(d, yr)          "DD-MON-YY" as a Date, its century the one that puts it nearest the record's year
#   nuseds_survey(x)            each record's window and survey as season days, and which edges a survey stands beyond
#   nuseds_mid(from, to, sp)    a date pair's midpoint as a season day
#   nuseds_place(x, reach)      each record's watershed groups by its FWA watershed code (a database holding
#                               whse_basemapping, PG*), and the one group it pools into (wsg; NA on a code crossing
#                               several groups unless the reach table names its reach)
# ---------------------------------------------------------------------------

nuseds_species <- c(Chinook = "CH", Coho = "CO", Sockeye = "SK", Pink = "PK", Chum = "CM", Steelhead = "ST")
nuseds_season_start <- c(CH = "04-01", CO = "04-01", SK = "04-01", PK = "04-01", CM = "04-01", ST = "09-01")

nuseds_read <- function(version = "v1", cols = NULL) {
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
  # col_select is tidy-evaluated: an expression that returns NULL selects no column, so branch the call
  x <- as.data.frame(if (is.null(cols)) arrow::read_parquet(pq) else arrow::read_parquet(pq, col_select = dplyr::all_of(cols)))
  if (!ncol(x)) stop(mf$path, " read with no columns", call. = FALSE)
  cat("NuSEDS", man$id, "release", man$provenance$nuseds_release, "published from knowledge",
      man$provenance$published_from_commit, "\n", mf$path, "sha256", sha, "(the manifest's),", nrow(x), "rows\n")
  x
}

nuseds_doy <- function(d, format) {
  out <- rep(NA_integer_, length(d))
  i <- !is.na(d)
  if (!any(i)) return(out)
  md <- withr::with_locale(c(LC_TIME = "C"), as.Date(paste0(if (format == "nuseds") substr(d[i], 1, 6) else d[i],
                                                            "-2000"),
                                                     format = if (format == "nuseds") "%d-%b-%Y" else "%m-%d-%Y"))
  if (anyNA(md)) stop("dates not ", format, ": ", paste(unique(d[i][is.na(md)]), collapse = ", "), call. = FALSE)
  out[i] <- as.integer(format(md, "%j"))
  out
}

nuseds_season <- function(day, sp) {
  s0 <- nuseds_doy(nuseds_season_start[sp], "mmdd")
  ifelse(!is.na(day) & day < s0, day + 366L, day)
}

nuseds_day_str <- function(v) {
  ifelse(is.na(v), NA_character_, format(as.Date((round(v) - 1) %% 366, origin = "2000-01-01"), "%m-%d"))
}

nuseds_date <- function(d, yr) {
  out <- rep(as.Date(NA), length(d))
  i <- !is.na(d) & !is.na(yr)
  if (!any(i)) return(out)
  yy <- as.integer(substr(d[i], 8, 9))
  y <- as.integer(yr[i])
  full <- ifelse(abs(1900L + yy - y) <= abs(2000L + yy - y), 1900L + yy, 2000L + yy)
  dt <- withr::with_locale(c(LC_TIME = "C"), as.Date(paste0(substr(d[i], 1, 6), "-", full), format = "%d-%b-%Y"))
  if (anyNA(dt)) stop("dates not DD-MON-YY: ", paste(unique(d[i][is.na(dt)]), collapse = ", "), call. = FALSE)
  out[i] <- dt
  out
}

# Each record's window and survey on its season year, and what the survey can say about each edge (#256). Every
# date is read by its month and day alone and placed on the season year of the record's species (nuseds_season), as
# the windows read them: DFO often writes a January-to-March end, or a survey's last day, with the record's own year
# (start 25-SEP-93, end 25-FEB-93), so the written year would put it before the start. Adds, as season days:
# start_lo and start_hi (a start bin's ends, or the single date twice), end_lo and end_hi, peak_lo and peak_hi, s0 and
# s1 (the survey's first and last days, cleared where a written survey year lies over a year from the record's year
# (survey_off_year) or the survey ends before it starts on the season year (survey_reversed), either a slip flagged in
# survey_slip; a survey opening before the season start, its first day written in the record's year or before, is kept
# in the season it opened); visits0
# (no_inspections_used, 0 where blank), backwards (the window ends before it starts on the season year), present
# (adult presence other than NONE OBSERVED or NOT INSPECTED, whose dates are a stream's expected timing; UNKNOWN and
# blank count as present); method (present and not backwards), start_mid, end_mid and peak_mid (nuseds_mid() on
# method records); start_bracket3 and end_bracket3 (the survey began before the recorded start, or ended after the
# recorded end, with at least nuseds_edge_visits visits, the window not backwards); and edge_start and edge_end (a
# present record bracketed at that edge, with a midpoint there). An edge so read is consistent with one someone saw,
# never proof of one: NuSEDS keeps no count per visit.
nuseds_edge_visits <- 3L
nuseds_edge_min <- 5L   # an edge is given for a group and species only with this many qualifying records
nuseds_survey <- function(x) {
  yr <- as.integer(x$analysis_yr)
  sp <- x$species_code
  sday <- function(v) nuseds_season(nuseds_doy(v, "nuseds"), sp)
  or <- function(a, b) ifelse(is.na(a), b, a)
  x$start_lo <- sday(or(x$start_spawn_dt_from, x$start_spawn_dt_to))
  x$start_hi <- sday(or(x$start_spawn_dt_to, x$start_spawn_dt_from))
  x$end_lo <- sday(or(x$end_spawn_dt_from, x$end_spawn_dt_to))
  x$end_hi <- sday(or(x$end_spawn_dt_to, x$end_spawn_dt_from))
  x$peak_lo <- sday(or(x$peak_spawn_dt_from, x$peak_spawn_dt_to))
  x$peak_hi <- sday(or(x$peak_spawn_dt_to, x$peak_spawn_dt_from))
  x$s0 <- sday(x$start_dtt)
  x$s1 <- sday(x$end_dtt)
  wy <- function(v) as.integer(format(nuseds_date(v, yr), "%Y"))   # the year as written
  # a survey that opens before the season start (a whole-year survey from 2 January, a steelhead survey from August)
  # reads past its own last day once moved onto the next season; where its first day is written in the record's
  # year or before, it opened in this season, before its start
  early <- !is.na(x$s0) & !is.na(x$s1) & x$s1 < x$s0 & x$s0 > 366L & !is.na(wy(x$start_dtt)) & wy(x$start_dtt) <= yr
  x$s0[early] <- x$s0[early] - 366L
  off <- function(v) !is.na(v) & abs(wy(v) - yr) > 1L
  x$survey_off_year <- off(x$start_dtt) | off(x$end_dtt)
  x$survey_reversed <- !is.na(x$s0) & !is.na(x$s1) & x$s1 < x$s0
  slip <- x$survey_off_year | x$survey_reversed
  x$s0[slip] <- NA
  x$s1[slip] <- NA
  x$visits <- suppressWarnings(as.integer(x$no_inspections_used))
  x$visits0 <- ifelse(is.na(x$visits), 0L, x$visits)
  x$backwards <- !is.na(x$start_lo) & !is.na(x$end_hi) & x$end_hi < x$start_lo
  x$present <- !x$adult_presence %in% c("NONE OBSERVED", "NOT INSPECTED")
  x$brackets_start <- !is.na(x$start_lo) & !is.na(x$s0) & x$s0 < x$start_lo
  x$brackets_end <- !is.na(x$end_hi) & !is.na(x$s1) & x$s1 > x$end_hi
  # the sets both scripts read, defined here once: the bulk and peak take a record whose adults were present and whose
  # window does not run backwards, each column by itself (a start with no end enters the start's median); an edge
  # takes such a record whose survey stands beyond that edge with enough visits, whatever the other edge gives
  x$method <- x$present & !x$backwards
  mid <- function(from, to) ifelse(x$method, nuseds_mid(from, to, sp), NA_integer_)
  x$start_mid <- mid(x$start_spawn_dt_from, x$start_spawn_dt_to)
  x$end_mid <- mid(x$end_spawn_dt_from, x$end_spawn_dt_to)
  x$peak_mid <- mid(x$peak_spawn_dt_from, x$peak_spawn_dt_to)
  x$start_bracket3 <- !x$backwards & x$brackets_start & x$visits0 >= nuseds_edge_visits
  x$end_bracket3 <- !x$backwards & x$brackets_end & x$visits0 >= nuseds_edge_visits
  x$edge_start <- x$present & x$start_bracket3 & !is.na(x$start_mid)
  x$edge_end <- x$present & x$end_bracket3 & !is.na(x$end_mid)
  x$survey_slip <- slip
  x
}

# A date pair's midpoint as a season day (#256): a bin's two ends converted to the season year, then halved by
# integer division (11-20 August, days 224 and 233, gives 228, 15 August); a single date is itself. A bin that runs
# backwards on the season year (one straddling its start included) or spans over 31 days gives NA.
nuseds_mid <- function(from, to, sp) {
  f <- nuseds_season(nuseds_doy(ifelse(is.na(from), to, from), "nuseds"), sp)
  t <- nuseds_season(nuseds_doy(ifelse(is.na(to), from, to), "nuseds"), sp)
  w <- t - f + 1L
  ifelse(is.na(w) | w < 1L | w > 31L, NA_integer_, f + (t - f) %/% 2L)
}

nuseds_place <- function(x, reach_path = "data/nuseds_reach_groups.csv", dated = rep(TRUE, nrow(x))) {
  con <- DBI::dbConnect(RPostgres::Postgres())
  on.exit(DBI::dbDisconnect(con))
  g <- DBI::dbGetQuery(con, "
    SELECT fwa_watershed_code, array_to_string(array_agg(DISTINCT watershed_group_code ORDER BY watershed_group_code),
      ',') AS groups
    FROM whse_basemapping.fwa_stream_networks_sp WHERE fwa_watershed_code = ANY($1::text[]) GROUP BY 1",
    params = list(paste0("{", paste(unique(x$fwa_watershed_cde), collapse = ","), "}")))
  x$groups <- g$groups[match(x$fwa_watershed_cde, g$fwa_watershed_code)]
  cat(sum(is.na(x$groups) & dated), "dated records carry a watershed code the Atlas does not hold\n")
  x <- x[!is.na(x$groups), , drop = FALSE]
  x$wsg <- ifelse(grepl(",", x$groups), NA_character_, x$groups)
  reach <- utils::read.csv(reach_path, colClasses = "character")
  for (i in seq_len(nrow(reach))) {
    hit <- x$gfe_id == as.numeric(reach$gfe_id[i])
    if (!any(hit)) stop(reach_path, ": gfe_id ", reach$gfe_id[i], " is in no record", call. = FALSE)
    if (!all(x$waterbody[hit] == reach$waterbody[i])) {
      stop(reach_path, ": gfe_id ", reach$gfe_id[i], " is ", paste(unique(x$waterbody[hit]), collapse = ", "),
           ", not ", reach$waterbody[i], call. = FALSE)
    }
    crossed <- unique(unlist(strsplit(x$groups[hit], ",")))
    if (!reach$wsg_code[i] %in% crossed) {
      stop(reach_path, ": ", reach$waterbody[i], "'s code does not cross ", reach$wsg_code[i], " (it crosses ",
           paste(crossed, collapse = ", "), ")", call. = FALSE)
    }
    x$wsg[hit] <- reach$wsg_code[i]
  }
  cat("named reaches (", reach_path, "): ", paste(reach$waterbody, "->", reach$wsg_code, collapse = "; "), "\n",
      sep = "")
  x
}
