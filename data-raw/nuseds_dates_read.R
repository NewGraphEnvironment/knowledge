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
