# scripts/0296-ch-rule-build.R
# ---------------------------------------------------------------------------
# What a CH rearing rule needs at each visit, written from the one evidence build (scripts/0310,
# issue #57). Until #57 this script walked the network, recomputed fwapg's width model, read the
# waterbody tests, the link segment and the hydrologic zone itself (issue #54); that method is now
# knw_link_walks(), knw_link_width() and knw_link_place(), and this script selects CH's rows and the
# columns 0297/0298 read. Those two are frozen on the published v2 tables (0299 PULL=TRUE
# VERSION=v2); scripts/0320 and 0330 are their successors.
#
# INPUT:  data/fdis/derived/{ch_mad_visits,visits_link,walks}.csv (scripts/0294, 0310)
# OUTPUT: data/fdis/derived/ch_rule_visits.csv  one row per 0294 visit (ignored; published by 0299)
#         data/fdis/derived/ch_rule_walks.csv   one row per start x source x river size (same)
#         scripts/logs/habitat/<date>_ch_rule_build_ledger.csv
# RUN:    Rscript scripts/0296-ch-rule-build.R   (after 0294, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })

path_out <- "data/fdis/derived/ch_rule_visits.csv"
path_walks <- "data/fdis/derived/ch_rule_walks.csv"
path_ledger <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_ch_rule_build_ledger.csv"))
ledger <- tibble(kind = character(), step = character(), n = integer(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.integer(n), note = note))
}

v <- read_csv("data/fdis/derived/ch_mad_visits.csv", show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
walks <- read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE)
add("in", "visits_in", nrow(v), "0294's kept visits")
if (anyDuplicated(v$site_visit)) stop("a visit appears twice in ch_mad_visits.csv")

v <- v |>
  inner_join(vl |> transmute(site_visit, fwa_waterbody_key, fwa_channel_width, fwa_cw_source, wb_river, wb_wetland,
                             wb_lake, fwa_stream_order, cw_model, cw_deploy,
                             link_ch_classified = !is.na(ch_rearing_stored), link_id_segment = id_segment,
                             link_start_offset_m = segment_start_offset_m, link_gradient = segment_gradient,
                             link_channel_width = segment_channel_width, link_cw_source = segment_cw_source,
                             link_edge_type = segment_edge_type, link_length_m = segment_length_m,
                             link_accessible = ch_accessible_stored, link_spawning = ch_spawning_stored,
                             link_rearing = ch_rearing_stored, link_lake_rearing = ch_lake_rearing_stored,
                             link_wetland_rearing = ch_wetland_rearing_stored,
                             natural_barrier_dnstr = barrier_dnstr_ch, barrier_schema = "fresh_default", hydro_zone),
             by = "site_visit")
w <- walks |> semi_join(v, by = c("blue_line_key", "downstream_route_measure")) |>
  select(blue_line_key, downstream_route_measure, src, qmin, status, dist_m, large_mad, large_lfid, large_edge,
         target_lake, target_regulated, n_hops, max_entry_gap_m)
add("info", "walk_rows", nrow(w))
add("info", "link_ch_visits", sum(v$link_ch_classified), "in a group where fresh_default classified CH")
add("info", "barrier_dnstr", sum(v$natural_barrier_dnstr %in% TRUE),
    sprintf("CH caught on %d", sum(v$present_CH & v$natural_barrier_dnstr %in% TRUE)))
add("info", "zone_unmatched", sum(is.na(v$hydro_zone)))
add("kept", "visits_kept", nrow(v))
if (sum(ledger$n[ledger$kind %in% c("drop", "kept")]) != sum(ledger$n[ledger$kind == "in"])) stop("ledger does not partition the input")
write_csv(v, path_out, na = "")
write_csv(w, path_walks, na = "")
write_csv(ledger, path_ledger, na = "")
print(ledger, n = Inf)
