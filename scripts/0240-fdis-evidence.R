# scripts/0240-fdis-evidence.R
# ---------------------------------------------------------------------------
# FDIS electrofishing export: size classes and the CH / char evidence tables. Issue #18.
# Consumer: NewGraphEnvironment/link#284 (CH and BT habitat-threshold calibration).
#
# WHY / DESIGN NOTES (measurements in research/fdis_export.md):
#   - Size classes come from data/fdis_size_breaks.csv, one row per class with its basis.
#     They are set from the FDIS length distributions and checked against maturity codes.
#   - CHAR GROUP: BT, DV and the recorded hybrids/ambiguities (BT/DV, DV/BT, DVxBT) are kept
#     as recorded AND summed into `char`. Juveniles cannot be told apart in the field, and
#     much interior "DV" is bull trout. Which rule applies where is link#284's decision, not
#     this script's; both columns are here so it can be made.
#   - CH gives REARING evidence only: EF catches no adult CH.
#   - SPAWNER EVIDENCE for char is maturity, not length: SP or ST at any date, or M in
#     Aug-Oct. Length >= 350 mm alone is a migratory adult, which may be foraging.
#   - Rows are SITE VISITS, so a multi-pass site counts once. Absence of a focal species
#     is asserted only where the visit has a known catch (fish of other species, or NFC).
#   - measured_vs_modelled is reported only where the FWA width is MODELLED: FWA's
#     FIELD_MEASUREMENT widths are these same FISS sites.
#
# INPUT:  data/fdis/build/{sites,catch,fish}.rds (from 0230), data/fdis_size_breaks.csv
# OUTPUT: data/fdis/derived/fdis_sites.{csv,gpkg}  one row per site visit: placement, measured
#                                        and modelled habitat, effort, catch status, focal
#                                        counts (ignored; pushed to s3://fresh-bc/fdis/derived/)
#         data/fdis_evidence.csv         site visit x focal species x size class (measured
#                                        fish), plus counted-but-unmeasured and spawner rows
#         data/fdis_summary_ch_bt.csv    site-level distributions of measured gradient and
#                                        width by species x class, against current thresholds
#         data/fdis_maturity_check.csv   size class x maturity code agreement
# RUN:    Rscript scripts/0240-fdis-evidence.R   (after 0230, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(tidyr); library(DBI); library(RPostgres) })

build <- "data/fdis/build"
sites <- readRDS(file.path(build, "sites.rds"))
catch <- readRDS(file.path(build, "catch.rds"))
fish  <- readRDS(file.path(build, "fish.rds"))
breaks <- read_csv("data/fdis_size_breaks.csv", col_types = "cccccc") |>
  mutate(length_min_mm = as.numeric(length_min_mm), length_max_mm = as.numeric(length_max_mm))

char_codes <- c("BT", "DV", "BT/DV", "DV/BT", "DVxBT")
group_of <- function(sp) case_when(sp %in% char_codes ~ "char", sp == "CH" ~ "CH", TRUE ~ NA_character_)

# thresholds in force (fresh parameters_habitat_thresholds.csv, bcfishpass values)
thresholds <- tribble(
  ~species_group, ~spawn_gradient_max_pct, ~spawn_cw_min_m, ~rear_gradient_max_pct, ~rear_cw_min_m,
  "CH",           4.49,                    4,               5.49,                   1.5,
  "char",         5.49,                    2,               10.49,                  1.5
)

# ---- major drainage (first FWA watershed-code segment) ----------------------
conn <- DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 5432,
                       dbname = "fwapg", user = "postgres", password = "postgres")
lf <- unique(na.omit(sites$linear_feature_id))
basin <- DBI::dbGetQuery(conn, "SELECT linear_feature_id, left(fwa_watershed_code, 3) AS fwa_basin
                                  FROM whse_basemapping.fwa_stream_networks_sp
                                 WHERE linear_feature_id = ANY($1::bigint[])",
                         params = list(paste0("{", paste(lf, collapse = ","), "}")))
DBI::dbDisconnect(conn)
sites <- sites |> left_join(basin, by = "linear_feature_id")

# ---- measured fish -> size class --------------------------------------------
classify <- function(grp, len) {
  out <- rep(NA_character_, length(len)); hits <- integer(length(len))
  for (i in seq_len(nrow(breaks))) {
    b <- breaks[i, ]
    hit <- grp == b$species_group & !is.na(len) & len > 0 & len >= b$length_min_mm & len < b$length_max_mm
    out[hit] <- b$size_class; hits <- hits + hit
  }
  # the breaks must tile each group: every measured fish in exactly one class
  if (any(hits[!is.na(len) & len > 0] != 1)) stop("size breaks overlap or leave gaps")
  out
}
ff <- fish |>
  mutate(species_group = group_of(species_code)) |>
  filter(!is.na(species_group)) |>
  left_join(sites |> select(site_visit, month), by = "site_visit") |>
  mutate(size_class = classify(species_group, length_mm),
         spawner = species_group == "char" &
           (maturity_code %in% c("SP", "ST") | (maturity_code == "M" & month %in% 8:10)))

# ---- maturity check (SP/ST vs IM only: MT median is 135 mm, so MT is not "mature") ----
mat <- ff |>
  filter(species_group == "char", maturity_code %in% c("IM", "SP", "ST"), !is.na(size_class)) |>
  count(maturity = if_else(maturity_code == "IM", "IM", "SP/ST"), size_class) |>
  group_by(maturity) |> mutate(share = round(n / sum(n), 3)) |> ungroup()
write_csv(mat, "data/fdis_maturity_check.csv", na = "")
print(mat)

# ---- evidence: site visit x species x class ---------------------------------
by_class <- ff |>
  filter(!is.na(size_class)) |>
  count(site_visit, species_code, species_group, size_class, name = "n")
spawners <- ff |> filter(spawner) |>
  count(site_visit, species_code, species_group, name = "n") |>
  mutate(size_class = "spawner_evidence")
unmeasured <- catch |>
  mutate(species_group = group_of(species_code)) |>
  filter(!is.na(species_group)) |>
  left_join(ff |> filter(is.na(size_class)) |> count(site_visit, species_code, name = "n_nolength"),
            by = c("site_visit", "species_code")) |>
  transmute(site_visit, species_code, species_group, size_class = "unmeasured",
            # counted fish with no length, plus measured rows whose length is missing
            n = pmax(n_caught - n_measured, 0) + coalesce(n_nolength, 0L)) |>
  filter(n > 0)
evidence <- bind_rows(by_class, unmeasured, spawners) |>
  left_join(catch |> select(site_visit, species_code, n_caught, n_measured, min_length_mm,
                            max_length_mm, flag_counts_lt_measured),
            by = c("site_visit", "species_code")) |>
  arrange(site_visit, species_code, size_class)

n_focal_measured <- nrow(ff)

# ---- site table -------------------------------------------------------------
focal <- catch |>
  mutate(col = case_when(species_code == "CH" ~ "n_ch", species_code == "BT" ~ "n_bt",
                         species_code == "DV" ~ "n_dv",
                         species_code %in% char_codes ~ "n_char_other", TRUE ~ NA_character_)) |>
  filter(!is.na(col)) |>
  # NA = caught but the count was a sentinel; presence is carried separately below
  group_by(site_visit, col) |>
  summarise(n = if (all(is.na(n_caught))) NA_real_ else sum(n_caught, na.rm = TRUE), .groups = "drop") |>
  pivot_wider(names_from = col, values_from = n, values_fill = 0)
presence <- catch |>
  mutate(species_group = group_of(species_code)) |>
  filter(!is.na(species_group)) |>
  distinct(site_visit, species_group) |>
  mutate(v = TRUE) |>
  pivot_wider(names_from = species_group, values_from = v, names_prefix = "present_", values_fill = FALSE)
site_out <- sites |>
  left_join(focal, by = "site_visit") |>
  left_join(presence, by = "site_visit") |>
  mutate(across(any_of(c("n_ch", "n_bt", "n_dv", "n_char_other")), ~ if_else(is.na(.x) & site_visit %in% focal$site_visit, .x, coalesce(.x, 0))),
         n_char = n_bt + n_dv + n_char_other,
         across(c(present_CH, present_char), ~ coalesce(.x, FALSE)),
         cw_comparable = channel_width_source == "MODELLED" & !is.na(channel_width_m)) |>
  select(site_visit, watershed_group_code, fwa_basin, blue_line_key, downstream_route_measure,
         linear_feature_id, distance_to_stream, gnis_name, utm_zone, utm_easting, utm_northing,
         date, year, month, n_pass, fishing_time_s, area_m2, fished_length_m, agency, data_set,
         gradient_pct, gradient2_pct, channel_width_m, wetted_width_m, n_cw_measures, bed_dominant,
         water_temp_c, fwa_gradient_pct, stream_order, edge_type, modelled_channel_width_m,
         channel_width_source, cw_comparable, mad_m3s,
         catch_status, n_caught_all, species_caught, unidentified_fish, present_CH, present_char,
         n_ch, n_bt, n_dv, n_char_other, n_char,
         starts_with("flag_"), habitat_conflict, grad_sentinel, cw_sentinel, has_habitat,
         ws50_checked)
# the site table (~17 MB) and its points are too large to churn in git: they go to
# data/fdis/derived/ (ignored) and s3://fresh-bc/fdis/derived/ (see scripts/README.md)
derived <- "data/fdis/derived"
dir.create(derived, showWarnings = FALSE)
write_csv(site_out, file.path(derived, "fdis_sites.csv"), na = "")
site_pts <- site_out |> filter(!flag_no_utm) |> group_split(utm_zone) |>
  lapply(\(d) sf::st_transform(sf::st_as_sf(d, coords = c("utm_easting", "utm_northing"),
                                           crs = 32600 + d$utm_zone[1], remove = FALSE), 3005)) |>
  dplyr::bind_rows()
sf::st_write(site_pts, file.path(derived, "fdis_sites.gpkg"), layer = "fdis_sites",
             delete_dsn = TRUE, quiet = TRUE)
# evidence carries the site attributes a calibration needs, so it stands alone for presence;
# absence needs the site table
evidence <- evidence |>
  left_join(site_out |> select(site_visit, watershed_group_code, fwa_basin, blue_line_key,
                               downstream_route_measure, month, year, gradient_pct,
                               channel_width_m, fwa_gradient_pct, modelled_channel_width_m,
                               channel_width_source, flag_far_snap, flag_ws50_mismatch),
            by = "site_visit")
write_csv(evidence, "data/fdis_evidence.csv", na = "")

# ---- summary for link#284: one value per site, not per fish ------------------
usable <- site_out |> filter(!flag_not_placed, !flag_junk_date, catch_status != "unknown")
present <- bind_rows(
  evidence |> filter(size_class != "unmeasured") |> distinct(site_visit, species_group, size_class),
  # 87% of counted CH carry no length, so presence at any size is its own row
  usable |> transmute(site_visit, CH = present_CH, char = present_char) |>
    pivot_longer(c(CH, char), names_to = "species_group", values_to = "present") |>
    filter(present) |> transmute(site_visit, species_group, size_class = "present_any_size")
)
# absence needs a known catch: not where an unidentified fish could have been the species
absent <- usable |>
  filter(!unidentified_fish) |>
  transmute(site_visit, CH = !present_CH, char = !present_char) |>
  pivot_longer(c(CH, char), names_to = "species_group", values_to = "absent") |>
  filter(absent) |> transmute(site_visit, species_group, size_class = "absent")
q <- function(v, p) if (sum(!is.na(v)) >= 5) unname(quantile(v, p, na.rm = TRUE)) else NA_real_
summ <- bind_rows(present, absent) |>
  inner_join(usable, by = "site_visit") |>
  left_join(thresholds, by = "species_group") |>
  group_by(species_group, size_class) |>
  summarise(
    sites = n(),
    sites_measured_gradient = sum(!is.na(gradient_pct)),
    gradient_q10 = q(gradient_pct, .1), gradient_q50 = q(gradient_pct, .5), gradient_q90 = q(gradient_pct, .9),
    share_above_rear_gradient_max = round(mean(gradient_pct > rear_gradient_max_pct, na.rm = TRUE), 3),
    share_above_spawn_gradient_max = round(mean(gradient_pct > spawn_gradient_max_pct, na.rm = TRUE), 3),
    sites_measured_cw = sum(!is.na(channel_width_m)),
    cw_q10 = q(channel_width_m, .1), cw_q50 = q(channel_width_m, .5), cw_q90 = q(channel_width_m, .9),
    share_below_rear_cw_min = round(mean(channel_width_m < rear_cw_min_m, na.rm = TRUE), 3),
    share_below_spawn_cw_min = round(mean(channel_width_m < spawn_cw_min_m, na.rm = TRUE), 3),
    fwa_gradient_q50 = q(fwa_gradient_pct, .5), fwa_gradient_q90 = q(fwa_gradient_pct, .9),
    .groups = "drop"
  ) |>
  mutate(across(where(is.double), ~ round(.x, 2)))
write_csv(summ, "data/fdis_summary_ch_bt.csv", na = "")
print(summ, width = 250, n = Inf)

message(sprintf("fdis_sites: %d rows | fdis_evidence: %d rows | focal measured fish: %d",
                nrow(site_out), nrow(evidence), n_focal_measured))
