# data-raw/timing_nuseds.R
# ---------------------------------------------------------------------------
# #96: chinook spawning windows for UFRA and COTR from DFO's NuSEDS spawn dates, printed for the timing table's rows,
# which are entered by hand (data/life_history_timing.csv), as its other rows are.
#
# WHY / DESIGN NOTES:
#   - POPULATIONS BY WATERSHED CODE. A NuSEDS record's FWA_WATERSHED_CDE is matched to the Freshwater Atlas, and a
#     population belongs to a group when every Atlas line with its code lies in that group. The Fraser mainstem's code
#     runs through every Fraser group, so a mainstem reach is placed by the reach DFO names: "FRASER RIVER - ABOVE
#     TETE JAUNE" is in UFRA (Tete Jaune Cache lies in UFRA). No tributary is placed by name.
#   - THE WINDOW. For each population and year: spawning starts at START_SPAWN_DT_FROM and ends at END_SPAWN_DT_TO,
#     or END_SPAWN_DT_FROM where DFO gives no END_SPAWN_DT_TO. Dates are DD-MON-YY; only the month and day are read.
#     The group's window runs from the median start to the median end over its population-years with dates. Each
#     population's own medians and year counts are printed beside it, so a reader sees where one stream sets the
#     window and where streams disagree. Stream arrival dates are printed too, for the migration row's note.
#
# INPUT:  data/nuseds/<release>/nuseds_records.csv (scripts/0340), a database holding whse_basemapping (PG*)
# OUTPUT: the windows, printed
# RUN:    Rscript data-raw/timing_nuseds.R 2>&1 | tee scripts/logs/timing/<yyyymmdd>_timing_nuseds.txt   (repo root)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1, width = 160)

rel <- utils::read.csv("data/nuseds_release.csv", colClasses = "character")
rel <- rel$release[nrow(rel)]
x <- readr::read_csv(file.path("data/nuseds", rel, "nuseds_records.csv"), col_types = readr::cols(.default = "c"),
                     progress = FALSE)
cat("NuSEDS release", rel, "\n")
groups <- c("UFRA", "COTR")
mainstem <- c("FRASER RIVER - ABOVE TETE JAUNE" = "UFRA")

ch <- x[x$species == "Chinook" & !is.na(x$fwa_watershed_cde), , drop = FALSE]
con <- DBI::dbConnect(RPostgres::Postgres())
g <- DBI::dbGetQuery(con, "
  SELECT fwa_watershed_code, array_agg(DISTINCT watershed_group_code ORDER BY watershed_group_code) AS groups
  FROM whse_basemapping.fwa_stream_networks_sp WHERE fwa_watershed_code = ANY($1::text[]) GROUP BY 1",
  params = list(paste0("{", paste(unique(ch$fwa_watershed_cde), collapse = ","), "}")))
DBI::dbDisconnect(con)
grp <- vapply(g$groups, function(v) {
  v <- gsub("[{}]", "", v)
  v <- strsplit(v, ",")[[1]]
  if (length(v) == 1L) v else NA_character_
}, character(1))
ch$wsg <- grp[match(ch$fwa_watershed_cde, g$fwa_watershed_code)]
ms <- ch$waterbody %in% names(mainstem)
ch$wsg[ms] <- mainstem[ch$waterbody[ms]]
ch <- ch[ch$wsg %in% groups, , drop = FALSE]

doy <- function(d) {
  d <- d[!is.na(d)]
  if (!length(d)) return(integer())
  md <- as.Date(paste0(substr(d, 1, 6), "-2000"), format = "%d-%b-%Y")
  if (anyNA(md)) stop("dates not DD-MON-YY: ", paste(unique(d[is.na(md)]), collapse = ", "), call. = FALSE)
  as.integer(format(md, "%j"))
}
withr::with_locale(c(LC_TIME = "C"), {
  ch$start_doy <- NA_integer_
  ch$end_doy <- NA_integer_
  ch$arr_doy <- NA_integer_
  i <- !is.na(ch$start_spawn_dt_from)
  ch$start_doy[i] <- doy(ch$start_spawn_dt_from[i])
  end <- ifelse(is.na(ch$end_spawn_dt_to), ch$end_spawn_dt_from, ch$end_spawn_dt_to)
  j <- !is.na(end)
  ch$end_doy[j] <- doy(end[j])
  k <- !is.na(ch$stream_arrival_dt_from)
  ch$arr_doy[k] <- doy(ch$stream_arrival_dt_from[k])
})
md <- function(v) if (all(is.na(v))) NA_character_ else format(as.Date(round(stats::median(v, na.rm = TRUE)) - 1,
                                                                  origin = "2000-01-01"), "%m-%d")
q <- function(v, p) if (all(is.na(v))) NA_character_ else format(as.Date(round(stats::quantile(v, p, na.rm = TRUE,
                                                                  names = FALSE)) - 1, origin = "2000-01-01"), "%m-%d")
summ <- function(d) data.frame(
  records = nrow(d), years_start = sum(!is.na(d$start_doy)), years_end = sum(!is.na(d$end_doy)),
  first_year = min(as.integer(d$analysis_yr[!is.na(d$start_doy) | !is.na(d$end_doy)]), na.rm = FALSE),
  last_year = max(as.integer(d$analysis_yr[!is.na(d$start_doy) | !is.na(d$end_doy)])),
  start_median = md(d$start_doy), start_q10 = q(d$start_doy, 0.1), start_q90 = q(d$start_doy, 0.9),
  end_median = md(d$end_doy), end_q10 = q(d$end_doy, 0.1), end_q90 = q(d$end_doy, 0.9),
  arrival_median = md(d$arr_doy), years_arrival = sum(!is.na(d$arr_doy)))

for (w in groups) {
  d <- ch[ch$wsg == w, , drop = FALSE]
  cat("\n====", w, "chinook:", length(unique(d$pop_id)), "populations,", nrow(d), "records\n")
  pops <- split(d, paste(d$waterbody, "| pop", d$pop_id))
  per <- do.call(rbind, lapply(names(pops), function(p) {
    s <- suppressWarnings(summ(pops[[p]]))
    cbind(stream = p, s)
  }))
  print(per[order(-per$years_start), ], row.names = FALSE)
  cat("\n", w, "group window (pooled population-years):\n")
  print(suppressWarnings(summ(d)), row.names = FALSE)
}
