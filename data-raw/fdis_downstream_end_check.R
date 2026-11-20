# data-raw/fdis_downstream_end_check.R
# ---------------------------------------------------------------------------
# Where does a bcfishobs record sit against the FDIS site it came from? Issue #23 (cut to what #137 needs, move 6).
#
# A bcfishobs record is one species on one date at one point; the FDIS visit it came from fished a stretch of stream.
# Field crews usually report a site's downstream end, so the visit's span runs upstream from its placed point for the
# fished length (knw_fdis_span(), capped at the blue line's top). This measures, for records matched to one visit:
#   1. match rates by species and class (knw_bcfishobs_match(), regenerated here: the evidence archive does not keep
#      bcfishobs_fdis_match.csv, and the bcfishobs snapshot is logged);
#   2. whether the record's reported UTM is the visit's own (same zone, easting and northing);
#   3. on the same blue line, where the record's measure sits against the visit's span: below its point, at its
#      downstream end (within 5 m), inside the span, or above it, with the offset as a share of the fished length.
# What it can show: where the two placements of one survey agree. A record carrying the visit's own UTM measures how
# two snaps of one point differ, not where a fish was caught; the fished span is the location error #137 weighs.
#
# INPUT:  data/fdis/build/{sites,catch}.rds and data/fdis/derived/fdis_sites.csv, held to the published run's evidence
#         ledger (the one data/tune/CH_rear_grades_record.csv names) and to each other; the database (PG* env vars):
#         bcfishobs.observations and whse_basemapping.fwa_stream_networks_sp (each blue line's top measure)
# OUTPUT: scripts/logs/fdis/<yyyymmdd>_fdis_downstream_end_check[-<n>].txt
# RUN:    Rscript data-raw/fdis_downstream_end_check.R   (from the repo root, on the published build: PULL=TRUE
#         scripts/0336-archive.R restores sites.rds and fdis_sites.csv, and PLACE=FALSE scripts/0230-fdis-load.R adds
#         catch.rds, which the archive does not hold)
# ---------------------------------------------------------------------------
suppressMessages({
  library(dplyr)
  library(DBI)
  library(RPostgres)
})
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

at_end_m <- 5   # a record within this of the visit's point is at the site's downstream end
f_sites <- "data/fdis/build/sites.rds"
f_catch <- "data/fdis/build/catch.rds"
f_table <- "data/fdis/derived/fdis_sites.csv"
path_log <- .knw_free_path(file.path("scripts/logs/fdis",
                                     paste0(format(Sys.Date(), "%Y%m%d"), "_fdis_downstream_end_check.txt")))
log_lines <- character()
say <- function(...) {
  log_lines <<- c(log_lines, sprintf(...))
  message(sprintf(...))
}
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

# the published build: sites.rds is its ledger's, and fdis_sites.csv the table 0240 wrote from it
rec <- knw_grade_record_read("data/tune/CH_rear_grades_record.csv")
led <- utils::read.csv(rec$evidence_ledger, colClasses = "character")
md5_sites <- unname(tools::md5sum(f_sites))
if (!identical(led$note[led$step == "md5_sites"], md5_sites)) {
  stop(f_sites, " (", md5_sites, ") is not the published build's (", rec$evidence_ledger, "): restore it with ",
       "PULL=TRUE scripts/0336-archive.R")
}
if (!identical(led$note[led$step == "md5_catch"], unname(tools::md5sum(f_catch)))) {
  stop(f_catch, " is not the published build's (", rec$evidence_ledger, "): rebuild it with ",
       "PLACE=FALSE scripts/0230-fdis-load.R")
}
.knw_archive_sites_check(f_table, f_sites)
sites <- readRDS(f_sites)
catch <- readRDS(f_catch)
tab <- utils::read.csv(f_table, colClasses = c(site_visit = "character"))
say("FDIS downstream-end check (knowledge#23, move 6), %s UTC.", format(Sys.time(), "%Y-%m-%d %H:%M", tz = "UTC"))
say("Build: %s (sites.rds %s, the ledger of link run %s); %d site visits.", rec$evidence_ledger, md5_sites,
    rec$run_uid, nrow(sites))

conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
snap <- DBI::dbGetQuery(conn, "SELECT count(*) AS n_records,
                                      max(observation_date) FILTER (WHERE observation_date <= now()) AS newest
                                 FROM bcfishobs.observations")
say("bcfishobs.observations: %s records, newest dated %s (the snapshot this database holds).",
    format(snap$n_records, big.mark = ","), as.character(snap$newest))

# ---- 1. match rates -------------------------------------------------------------------------------------------
bm <- knw_bcfishobs_match(conn, sites |> select(site_visit, date), catch |> select(site_visit, species_code))
block("bcfishobs records by species and match class (knw_bcfishobs_match(), knw_species())",
      tidyr::pivot_wider(bm$summary, names_from = match, values_from = n_records, values_fill = 0))
one <- bm$matched |> filter(match == "one")
# an unmatched record's collection may be one the load dropped as a repeat copy of a survey (#35), which the export
# holds
rep_map <- utils::read.csv("data/fdis_repeat_surveys.csv", colClasses = "character")
coll <- function(sv) suppressWarnings(as.integer(sub("_.*$", "", sv)))
coll_dropped <- setdiff(coll(rep_map$site_visit[rep_map$status == "dropped"]), coll(sites$site_visit))
um <- bm$matched |> filter(match == "unmatched", !duplicated(observation_key))
say("Unmatched records: %s; of them on a collection the load dropped as a repeat copy (#35, no kept visit): %s.",
    format(nrow(um), big.mark = ","), format(sum(um$fshclctn_id %in% coll_dropped), big.mark = ","))
say("Records matched to exactly one visit: %s of %s FDIS-keyed records (%.1f %%).", format(nrow(one), big.mark = ","),
    format(sum(bm$matched$match != "not_fdis" & !duplicated(bm$matched$observation_key)), big.mark = ","),
    100 * nrow(one) / sum(bm$matched$match != "not_fdis" & !duplicated(bm$matched$observation_key)))

# ---- 2. the record's UTM against the visit's ---------------------------------------------------------------------
utm <- DBI::dbGetQuery(conn, "SELECT observation_key, utm_zone, utm_easting, utm_northing, distance_to_stream
                                FROM bcfishobs.observations WHERE observation_key = ANY($1::text[])",
                       params = list(paste0("{", paste(unique(one$observation_key), collapse = ","), "}")))
v <- one |>
  left_join(utm, by = "observation_key") |>
  left_join(tab |> select(site_visit, v_zone = utm_zone, v_east = utm_easting, v_north = utm_northing,
                          v_blk = blue_line_key, v_drm = downstream_route_measure, fished_length_m,
                          v_snap = distance_to_stream, flag_not_placed),
            by = "site_visit")
# a record with no UTM, or one in another zone, is not the visit's point
v$same_utm <- dplyr::coalesce(v$utm_zone == v$v_zone & abs(v$utm_easting - v$v_east) < 0.5 &
                                abs(v$utm_northing - v$v_north) < 0.5, FALSE)
v$utm_apart_m <- ifelse(!is.na(v$utm_zone) & v$utm_zone == v$v_zone,
                        sqrt((v$utm_easting - v$v_east)^2 + (v$utm_northing - v$v_north)^2), NA_real_)
block("One-to-one records: is the record's reported UTM the visit's own?",
      v |> summarise(records = n(), n_same_utm = sum(same_utm), share_same = round(mean(same_utm), 3),
                     other_zone_or_missing = sum(is.na(utm_apart_m)),
                     apart_p50_m = round(stats::median(utm_apart_m[!same_utm], na.rm = TRUE), 1),
                     apart_p90_m = round(stats::quantile(utm_apart_m[!same_utm], 0.9, na.rm = TRUE), 1)))

# ---- 3. the record against the visit's span on the same blue line ------------------------------------------------
blk <- unique(stats::na.omit(v$v_blk))
top <- DBI::dbGetQuery(conn, "SELECT blue_line_key, max(upstream_route_measure) AS line_top_m
                                FROM whse_basemapping.fwa_stream_networks_sp
                               WHERE blue_line_key = ANY($1::bigint[]) GROUP BY blue_line_key",
                       params = list(paste0("{", paste(format(blk, scientific = FALSE, trim = TRUE), collapse = ","),
                                            "}")))
DBI::dbDisconnect(conn)
v$line_top_m <- top$line_top_m[match(v$v_blk, top$blue_line_key)]
sp <- knw_fdis_span(v$v_drm, v$fished_length_m, v$line_top_m)
v$v_urm <- sp$upstream_route_measure
v$flag_span_capped <- sp$flag_span_capped
block("Records carrying the visit's own UTM: the line each placement took",
      v |>
        filter(same_utm) |>
        mutate(line = case_when(flag_not_placed ~ "visit not placed", is.na(blue_line_key) ~ "record on no line",
                                blue_line_key == v_blk ~ "the visit's line", TRUE ~ "another line")) |>
        count(line))
s <- v |> filter(!flag_not_placed, !is.na(blue_line_key), !is.na(v_blk))
s$same_line <- s$blue_line_key == s$v_blk
on <- s |> filter(same_line)
on$offset_m <- on$downstream_route_measure - on$v_drm
on$where <- case_when(abs(on$offset_m) <= at_end_m ~ "at the downstream end",
                      on$offset_m < 0 ~ "below the site",
                      is.na(on$v_urm) ~ "above the point, no span",
                      on$downstream_route_measure <= on$v_urm ~ "inside the span",
                      TRUE ~ "above the span")
say("")
s_vis <- s[!duplicated(s$site_visit), ]   # a visit matched by several species' records counts once
say(paste("Placed one-to-one records: %s; on the visit's own blue line: %s (%.1f %%); their visits: %s, %s with a",
          "span capped."),
    format(nrow(s), big.mark = ","), format(nrow(on), big.mark = ","), 100 * nrow(on) / nrow(s),
    format(nrow(s_vis), big.mark = ","), format(sum(s_vis$flag_span_capped), big.mark = ","))
block("Where the record sits against the visit's span (same blue line)",
      on |> count(where, same_utm) |> group_by(same_utm) |> mutate(share = round(n / sum(n), 3)) |> ungroup())
block("Offset (record measure - visit measure, m) where they differ by more than the end window",
      on |>
        filter(abs(offset_m) > at_end_m) |>
        group_by(same_utm) |>
        summarise(n = n(), p10 = round(stats::quantile(offset_m, 0.1), 1), p50 = round(stats::median(offset_m), 1),
                  p90 = round(stats::quantile(offset_m, 0.9), 1),
                  share_of_length_p50 = round(stats::median(offset_m / fished_length_m, na.rm = TRUE), 2)))
block("Fished length of the matched visits (m, each visit once): the stretch a record's fish came from",
      s_vis |> summarise(n = n(), missing = sum(is.na(fished_length_m)),
                         p25 = stats::quantile(fished_length_m, 0.25, na.rm = TRUE),
                         p50 = stats::median(fished_length_m, na.rm = TRUE),
                         p75 = stats::quantile(fished_length_m, 0.75, na.rm = TRUE),
                         p90 = stats::quantile(fished_length_m, 0.9, na.rm = TRUE)))
if (sum(table(on$where)) != nrow(on)) stop("the classes do not partition the records on the visit's line")

dir.create(dirname(path_log), showWarnings = FALSE, recursive = TRUE)
writeLines(log_lines, path_log)
message("Wrote ", path_log)
