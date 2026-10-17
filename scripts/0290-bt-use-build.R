# scripts/0290-bt-use-build.R
# ---------------------------------------------------------------------------
# BT electrofishing visits on link's segments, written from the one evidence build (scripts/0310,
# issue #57). Until #57 this script built the table itself from fresh_default and score284_default
# (issue #28); the method is now knw_fdis_quality(), knw_fdis_species() and knw_link_place(), and
# this script selects BT's rows and the columns 0291-0293 read.
#
# WHAT CHANGED WITH #57 (decided 2026-10-17): one schema holds every group, so there is no held-out
# schema and no step-5 class; `role`, `link_schema`, `step5_class`, `*_score284` and the elevation
# terciles are gone. 0291-0293 are frozen on the published v2 tables (0299 PULL=TRUE VERSION=v2)
# and are not run on this table; scripts/0320 is their successor.
#
# POPULATION (0290's): quality-passed visits placed on a fresh_default segment, in groups where
# link's presence rule marks BT present, with no code blocking a BT absence (DV pooled into BT where
# link's tracker says so), on segments with access_bt 1 or 2.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species}.csv (scripts/0310), data/fdis/derived/fdis_sites.csv (0240)
# OUTPUT: data/fdis/derived/bt_use_visits.csv  one row per kept visit (ignored; published by 0299)
#         scripts/logs/habitat/<date>_bt_use_build_ledger.csv
# RUN:    Rscript scripts/0290-bt-use-build.R   (after 0310, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })

path_out <- "data/fdis/derived/bt_use_visits.csv"
path_ledger <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_bt_use_build_ledger.csv"))
ledger <- tibble(kind = character(), step = character(), n = integer(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.integer(n), note = note))
}
drop <- function(x, keep, step) {
  keep <- coalesce(keep, FALSE)
  add("drop", step, sum(!keep))
  x[keep, ]
}

vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c")) |> filter(species_code == "BT")
add("in", "visits_in", nrow(vl), "0310's placed visits")
v <- vl |> inner_join(vs |> select(site_visit, pooling, bt_present = present, bt_status = status, in_range),
                      by = "site_visit")
v <- drop(v, v$in_range, "bt_absent_from_wsg")
v <- drop(v, v$bt_status != "blocked", "bt_absence_blocked")
add("info", "bt_present_on_access_bt_0", sum(v$bt_present & v$access_bt %in% 0L), "BT caught on a segment link models as blocked")
v <- drop(v, v$access_bt %in% c(1L, 2L), "not_bt_accessible")
v <- v |>
  transmute(site_visit, watershed_group_code, blue_line_key, downstream_route_measure, segment_start_offset_m,
            id_segment, data_set, agency, year, month, n_pass, fishing_time_s, area_m2, fished_length_m,
            catch_status, n_caught_all, pooling, bt_present, n_bt, n_dv, n_char, segment_gradient, gradient_pct,
            fwa_gradient_pct, segment_channel_width, segment_cw_source, channel_width_m, wetted_width_m, mad_m3s,
            segment_stream_order, segment_edge_type, segment_length_m, elevation_m, access_bt,
            accessible = bt_accessible, spawning = bt_spawning, rearing = bt_rearing)
add("kept", "visits_kept", nrow(v))
if (sum(ledger$n[ledger$kind %in% c("drop", "kept")]) != nrow(vl)) stop("ledger does not partition the input")
write_csv(v, path_out, na = "")
write_csv(ledger, path_ledger, na = "")
print(as.data.frame(ledger))
message(sprintf("%d visits, %d with BT", nrow(v), sum(v$bt_present)))
