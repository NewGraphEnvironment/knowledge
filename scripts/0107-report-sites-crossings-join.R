# scripts/0107-report-sites-crossings-join.R
# ---------------------------------------------------------------------------
# Attach bcfishpass modelled habitat to the report-derived findings: for each site in
# data/<region>/report_sites.geojson, the nearest crossing in a bcfishpass crossings_vw
# extract, with the match distance kept so a weak match is visible rather than implied.
# Issue NewGraphEnvironment/knowledge#11.
#
# WHY the distance column is load-bearing: crossings_vw carries modelled crossings as well
# as PSCIS ones (19,628 in the Thompson extract), so st_nearest_feature ALWAYS returns
# something. Two sites in this set are placed on a stream mouth rather than at the
# structure, and their nearest crossing was on a different stream entirely (Dora Creek's
# nearest was the Yellowhead Highway culvert on the Albreda River, 340 m away). Anything
# over ~50 m is checked by stream name before it is believed.
#
# INPUT:  REGION (default "thompson"); CROSSINGS_GPKG (default: the sern_thompson_2026
#         project's background layer). Both read-only.
# OUTPUT: data/<region>/report_sites_crossings.csv
# ---------------------------------------------------------------------------

suppressMessages({ library(sf); library(dplyr); library(readr); library(stringr) })
sf::sf_use_s2(FALSE)

region <- Sys.getenv("REGION", unset = "thompson")
gpkg   <- Sys.getenv("CROSSINGS_GPKG",
  unset = "/Users/airvine/Projects/gis/sern_thompson_2026/background_layers/bcfishpass.crossings_vw.gpkg")
in_gj  <- file.path("data", region, "report_sites.geojson")
out_csv <- file.path("data", region, "report_sites_crossings.csv")
stopifnot("report_sites.geojson not found — run 0106 first" = file.exists(in_gj),
          "crossings gpkg not found — set CROSSINGS_GPKG" = file.exists(gpkg))

sites <- st_read(in_gj, quiet = TRUE) |> st_transform(3005)
cx    <- st_read(gpkg,  quiet = TRUE) |> st_transform(3005)
message(sprintf("%d sites against %d crossings", nrow(sites), nrow(cx)))

want <- c("stream_crossing_id", "modelled_crossing_id", "pscis_status", "barrier_status",
          "crossing_subtype_code", "pscis_road_name", "gnis_stream_name", "stream_order",
          "channel_width", "upstream_area_ha", "watershed_group_code",
          "access_bt", "access_co", "bt_rearing_km", "bt_spawning_km",
          "co_rearing_km", "co_spawning_km", "observedspp_upstr")
missing <- setdiff(want, names(cx))
stopifnot("crossings layer is missing expected columns" = length(missing) == 0)

i <- st_nearest_feature(sites, cx)
d <- as.numeric(st_distance(sites, cx[i, ], by_element = TRUE))
out <- bind_cols(
  st_drop_geometry(sites)[, c("site_id", "name", "watershed_group", "category", "status",
                              "fpci_score", "habitat_gain_m", "species", "year_found",
                              "year_fixed", "stream", "road", "report_id", "location_quality")],
  tibble(match_dist_m = round(d, 0),
         # a match is only as good as the placement it started from
         match_confidence = case_when(d <= 50 ~ "good", d <= 300 ~ "fair", TRUE ~ "poor")),
  st_drop_geometry(cx[i, want])) |>
  rename(crossing_wsg = watershed_group_code) |>
  mutate(crossing_id = coalesce(as.character(stream_crossing_id), paste0("mod ", modelled_crossing_id)),
         rearing_km_total = round(bt_rearing_km + co_rearing_km, 2), .after = match_confidence)

# the crossing must be in the same watershed group as the site, or the match crossed a divide
odd <- out |> filter(match_confidence != "poor", crossing_wsg != watershed_group)
if (nrow(odd)) message("  note: ", nrow(odd), " match(es) land in a different watershed group: ",
                       paste(odd$site_id, collapse = ", "))
write_csv(out, out_csv)
message("Wrote ", out_csv)
print(as.data.frame(out |> count(match_confidence)), right = FALSE)
message(sprintf("sites with modelled rearing habitat upstream: %d of %d",
                sum(out$rearing_km_total > 0), nrow(out)))
