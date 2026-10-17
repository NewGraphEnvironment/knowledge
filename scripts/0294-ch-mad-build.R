# scripts/0294-ch-mad-build.R
# ---------------------------------------------------------------------------
# CH electrofishing visits with wet's flow, written from the one evidence build (scripts/0310,
# issue #57). Until #57 this script read the flow, the dams, the barriers and walked the network
# itself (issue #52); the method is now knw_link_flow(), knw_link_regulated(),
# knw_link_barrier_dnstr() and knw_link_walks(), and this script selects CH's rows and the columns
# 0295 reads. 0295 is frozen on the published v2 table (0299 PULL=TRUE VERSION=v2).
#
# POPULATION (0294's): quality-passed placed visits in groups where link's presence rule marks CH
# present, with no code blocking a CH absence. The walk columns are 0310's walk at 10 m3/s on
# `pick`, for visits under 0.5 m3/s (0294 walked only those). Two of 0294's columns are not in the
# build and are derived here: `ambiguous` (a small-stream visit's UTM point within its snap
# distance plus 20 m of a >= 10 m3/s segment on another blue line) and `ch_barrier_dnstr_no_user`
# (the barrier test without USER_DEFINITE), each one database read.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (scripts/0310);
#         fwapg database (PG* env vars)
# OUTPUT: data/fdis/derived/ch_mad_visits.csv  one row per kept visit (ignored; published by 0299)
#         scripts/logs/habitat/<date>_ch_mad_build_ledger.csv
# RUN:    Rscript scripts/0294-ch-mad-build.R   (after 0310, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)

small_max <- 0.5
large_min <- 10
ambig_pad_m <- 20
path_out <- "data/fdis/derived/ch_mad_visits.csv"
path_ledger <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_ch_mad_build_ledger.csv"))
ledger <- tibble(kind = character(), step = character(), n = integer(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.integer(n), note = note))
}
drop <- function(x, keep, step) {
  keep <- coalesce(keep, FALSE)
  add("drop", step, sum(!keep), sprintf("CH caught on %d", sum(x$present_CH[!keep])))
  x[keep, ]
}

vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c")) |> filter(species_code == "CH")
walks <- read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE) |> filter(src == "pick", qmin == large_min)
add("in", "visits_in", nrow(vl), "0310's placed visits")
v <- vl |> inner_join(vs |> select(site_visit, ch_status = status, in_range), by = "site_visit")
v <- drop(v, v$in_range, "wsg_outside_ch_range")
v <- drop(v, v$ch_status != "blocked", "ch_absence_blocked")
v <- drop(v, !is.na(v$mad_pick), "no_flow")
v <- drop(v, !is.na(v$wscode) & !is.na(v$localcode), "no_watershed_code")

conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
pts <- v |> distinct(blue_line_key, downstream_route_measure, wscode, localcode)
nu <- knw_link_barrier_dnstr(conn, pts, "CH", "fresh_default", natural = c("GRADIENT", "FALLS", "SUBSURFACE_FLOW")) |>
  rename(ch_barrier_dnstr_no_user = barrier_dnstr_ch)
v <- v |> left_join(nu, by = c("blue_line_key", "downstream_route_measure"))
sm <- v |> filter(mad_pick < small_max) |> distinct(site_visit, blue_line_key, utm_zone, utm_easting, utm_northing, distance_to_stream)
dbWriteTable(conn, "tmp_ch_mad_small", sm, temporary = TRUE, overwrite = TRUE)
amb <- dbGetQuery(conn, sprintf("
  WITH p AS (
    SELECT site_visit, blue_line_key, coalesce(distance_to_stream, 0) + %1$s AS r,
           ST_Transform(ST_SetSRID(ST_MakePoint(utm_easting, utm_northing), 26900 + utm_zone::int), 3005) AS pt
    FROM tmp_ch_mad_small
    WHERE utm_zone BETWEEN 7 AND 11 AND utm_easting IS NOT NULL AND utm_northing IS NOT NULL)
  SELECT p.site_visit,
         EXISTS (SELECT 1 FROM whse_basemapping.fwa_stream_networks_sp s
                 JOIN discharge.fwa_v1_segment_monthly q
                   ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical'
                  AND q.month = 0 AND q.pick AND q.q_m3s >= %2$s
                 WHERE ST_DWithin(s.geom, p.pt, p.r) AND s.blue_line_key <> p.blue_line_key) AS ambiguous
  FROM p", ambig_pad_m, large_min))
dbDisconnect(conn)
v <- v |> left_join(amb, by = "site_visit")
add("info", "small_visits", nrow(sm), sprintf("picked MAD < %g", small_max))
add("info", "ambiguous_placement", sum(v$ambiguous %in% TRUE))

v <- v |>
  left_join(walks |> select(blue_line_key, downstream_route_measure, walk_status = status, dist_large_m = dist_m,
                            large_mad, large_lfid, large_edge, large_is_lake = target_lake, walk_hops = n_hops,
                            walk_entry_gap_m = max_entry_gap_m),
            by = c("blue_line_key", "downstream_route_measure")) |>
  mutate(across(c(walk_status, dist_large_m, large_mad, large_lfid, large_edge, large_is_lake, walk_hops, walk_entry_gap_m),
                ~ if_else(mad_pick < small_max, .x, NA))) |>
  transmute(site_visit, watershed_group_code, blue_line_key, downstream_route_measure, linear_feature_id,
            distance_to_stream, data_set, agency, year, month, n_pass, fishing_time_s, area_m2, fished_length_m,
            wetted_width_m, edge_type, stream_order, fwa_gradient, side_channel, in_lake = wb_any_lake,
            in_river_poly = wb_river, catch_status, n_caught_all, present_CH, n_ch, flow_from, mad_pick,
            pick_source, mad_routed, mad_balance, mad_fwapg = mad_m3s, regulated, access_covered = TRUE,
            ch_barrier_dnstr = barrier_dnstr_ch, ch_barrier_dnstr_no_user, ambiguous, walk_status, dist_large_m,
            large_mad, large_lfid, large_edge, large_waterbody_key = NA_real_, large_is_lake, walk_hops,
            walk_entry_gap_m)
add("kept", "visits_kept", nrow(v))
add("info", "ch_present_kept", sum(v$present_CH))
if (sum(ledger$n[ledger$kind %in% c("drop", "kept")]) != nrow(vl)) stop("ledger does not partition the input")
write_csv(v, path_out, na = "")
write_csv(ledger, path_ledger, na = "")
print(ledger, n = Inf)
