# scripts/0230-fdis-load.R
# ---------------------------------------------------------------------------
# FDIS electrofishing export: load, QA, and place on the FWA network. Issue #18.
#
# WHY / DESIGN NOTES (research/fdis_export.md has the measurements behind each):
#   - Source is the province-supplied FDIS export at s3://fresh-bc/fdis/ (as received; see its README.md).
#   - GRAIN IS THE SITE VISIT (first three KEY parts). KEY is one electrofishing pass,
#     and 5,748 of 53,018 site visits have 2-8 depletion passes of the same population,
#     so per-pass rows would weight those sites up to 8x. Catch and effort sum over passes.
#   - ABUNDANCE COMES FROM `counts`, NOT `details`. `details` is a length subsample:
#     36,446 of 41,916 CH counted are in pass x species pairs with no measured fish.
#     Measured fish give size-class proportions only (0240).
#   - FISH TABLE: the 2022 `Details*` files, used whole. They contain every 2020 fish row
#     (multiset check) plus 305 keys with no visit. Exact duplicate rows are distinct fish:
#     the FDIS fish sequence number was not exported. Do not dedupe.
#   - ZERO CATCH IS EXPLICIT: `counts` carries SPECIES_CODE = 'NFC' ("no fish caught").
#     A site visit is zero-catch when every counts row is NFC and no fish are in details.
#     NFC alongside fish (in details or counts) is flagged as a conflict. Visits with neither
#     counts nor details are "unknown", never zero.
#   - HABITAT is joined at SITE level. It fans out to passes, and some sites carry several
#     differing survey rows; the median of those rows is used, and the site is flagged.
#     GRADIENT11/12 are the primary measurement, 21/22 a second one (a separate method code
#     not exported, and it runs higher), so they are kept apart. Sentinels (width >= 500 m,
#     gradient > 100 %) are flagged and excluded.
#   - REPEATED SURVEYS (#35): one survey loaded under two to four collection ids is kept once.
#     The signature is UTM, date, pass count, per-pass fished length and width and per-species
#     catch; every member of a group needs its own collection id, and the members share a site
#     number or identical measured fish. The copy kept has the most measured fish, then the most
#     maturity-coded fish, a known catch, habitat, and the lowest collection id. Visits with no UTM
#     or no date are never matched. data/fdis_repeat_surveys.csv lists every other member of a
#     matching group: dropped, or kept with the reason.
#   - PLACEMENT: whse_basemapping.fwa_indexpoint in the fwapg database (PG* environment variables), with an explicit
#     tolerance (its default is 5 km). The matched FWA feature's gradient, order, edge type,
#     modelled channel width and MAD are joined province-wide, not fresh.streams (98 groups
#     locally). Placement is checked against the 50k watershed code FDIS recorded
#     (NEW_WATERSHED_CODE -> fwa_streams_20k_50k -> blue_line_keys).
#
# INPUT:  s3://fresh-bc/fdis/ -> data/fdis/ (ignored cache; synced when missing, then
#         md5-verified against MANIFEST.md5).
# OUTPUT: data/fdis/build/sites.rds    one row per site visit
#         data/fdis/build/catch.rds    site visit x species: n counted, n measured
#         data/fdis/build/fish.rds     one row per measured fish, keyed to site visit
#         data/fdis/build/reconcile.csv
#         data/fdis_repeat_surveys.csv   each dropped copy, the copy kept, and what differs
# RUN:    Rscript scripts/0230-fdis-load.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({
  library(dplyr); library(readr); library(tidyr); library(purrr); library(stringr)
  library(sf); library(DBI); library(RPostgres)
})

cache  <- "data/fdis"
build  <- file.path(cache, "build")
snap_tol_m  <- 500   # fwa_indexpoint search radius
snap_flag_m <- 100   # farther snaps are flagged here; knw_fdis_quality() drops them (#89)
# ---- no-data encodings: ONE table (measured field by field in research/fdis_export.md) ----
# Every "is this a real value" decision reads from here, so a sibling sentinel is added once.
sentinel_min     <- 9999                # counts, fishing time, fished length/width use 9999, 9999.9, 99999
# species codes: every code in the export is classified in data/fdis_species_codes.csv
# (names from whse_fish.species_cd); an unclassified code stops the run below
species_codes    <- read_csv("data/fdis_species_codes.csv", col_types = cols(.default = "c"), na = "")
zero_catch_codes <- species_codes$code[species_codes$catch_class == "zero_catch"]
nonfish_codes    <- species_codes$code[species_codes$catch_class == "not_fish"]
temp_valid       <- c(-1, 35)           # deg C
easting_valid    <- c(1e5, 9e5)         # UTM, BC
northing_valid   <- c(5.2e6, 6.8e6)
nodata <- function(x, lo = -Inf, hi = Inf) ifelse(!is.na(x) & (x < lo | x > hi), NA_real_, x)
is_sentinel <- function(x) !is.na(x) & x >= sentinel_min

# ---- sync + verify ---------------------------------------------------------
if (!file.exists(file.path(cache, "MANIFEST.md5"))) {
  message("Syncing s3://fresh-bc/fdis/ -> ", cache)
  if (identical(Sys.getenv("NO_SIGN"), "TRUE")) {
    # Without credentials the public prefix serves exact keys but cannot be listed, so a sync
    # fails: fetch the manifest aside, then the README and each key it names, and put the
    # manifest in place last, because its presence is what marks the cache complete above.
    get <- function(key, dst = file.path(cache, key)) {
      dir.create(dirname(dst), recursive = TRUE, showWarnings = FALSE)
      rc <- system2("aws", shQuote(c("s3", "cp", paste0("s3://fresh-bc/fdis/", key), dst,
                                     "--no-sign-request", "--only-show-errors")))
      if (rc != 0) stop("aws s3 cp of fdis/", key, " failed (exit ", rc, ")")
    }
    pending <- file.path(cache, "MANIFEST.md5.part")
    get("MANIFEST.md5", pending)
    get("README.md")
    for (key in sub("^\\./", "", substring(read_lines(pending), 34))) get(key)
    if (!file.rename(pending, file.path(cache, "MANIFEST.md5"))) stop("could not move ", pending, " into place")
  } else {
    # the manifest last here too: its presence is what marks the cache complete
    rc <- system2("aws", c("s3", "sync", "s3://fresh-bc/fdis/", cache, "--exclude", "MANIFEST.md5",
                           "--only-show-errors"))
    if (rc != 0) stop("aws s3 sync failed (exit ", rc, ")")
    rc <- system2("aws", c("s3", "cp", "s3://fresh-bc/fdis/MANIFEST.md5", file.path(cache, "MANIFEST.md5"),
                           "--only-show-errors"))
    if (rc != 0) stop("aws s3 cp of MANIFEST.md5 failed (exit ", rc, ")")
  }
}
# md5 -r format: 32 hex, a space, then the path (paths contain spaces)
manifest <- tibble(line = read_lines(file.path(cache, "MANIFEST.md5"))) |>
  transmute(md5 = substr(line, 1, 32), path = sub("^\\./", "", substring(line, 34)))
got <- unname(tools::md5sum(file.path(cache, manifest$path)))
bad <- manifest$path[is.na(got) | got != manifest$md5]
if (length(bad)) stop("md5 mismatch vs MANIFEST.md5: ", paste(bad, collapse = ", "))
message("Cache verified: ", nrow(manifest), " files match MANIFEST.md5")
dir.create(build, showWarnings = FALSE)

rd <- function(f) read_csv(f, col_types = cols(.default = col_character()),
                           locale = locale(encoding = "latin1"), na = c("", "NA"),
                           trim_ws = TRUE, progress = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))
site_of <- function(key) sub("^([^_]+_[^_]+_[^_]+)_.*$", "\\1", key)
mean_ok <- function(v, hi, lo_incl = FALSE) {
  v <- v[!is.na(v) & (if (lo_incl) v >= 0 else v > 0) & v < hi]
  if (length(v)) mean(v) else NA_real_
}
med <- function(v) if (all(is.na(v))) NA_real_ else stats::median(v, na.rm = TRUE)

# ---- passes -> site visits -------------------------------------------------
visits <- rd(file.path(cache, "2020-11-16/visits.csv"))
stopifnot(!anyDuplicated(visits$KEY))

passes <- visits |>
  transmute(
    KEY, site_visit = site_of(KEY), data_set = DATA_SET,
    utm_zone = as.integer(UTM_ZONE), utm_easting = num(UTM_EASTING), utm_northing = num(UTM_NORTHING),
    date = suppressWarnings(as.Date(IN_DATE)),
    flag_effort_sentinel = is_sentinel(num(FISHING_TIME)) | is_sentinel(num(FISHING_AREA_LENGTH)) |
                           is_sentinel(num(FISHING_AREA_WIDTH)),
    fishing_time_s = nodata(num(FISHING_TIME), hi = sentinel_min - 1e-9),
    area_m2 = nodata(num(FISHING_AREA_LENGTH), hi = sentinel_min - 1e-9) *
              nodata(num(FISHING_AREA_WIDTH), hi = sentinel_min - 1e-9),
    fished_length_m = nodata(num(FISHING_AREA_LENGTH), hi = sentinel_min - 1e-9),
    agency = NAME
  )

sites <- passes |>
  group_by(site_visit) |>
  summarise(
    n_pass = n(), data_set = first(data_set),
    utm_zone = first(na.omit(utm_zone)), utm_easting = first(na.omit(utm_easting)),
    utm_northing = first(na.omit(utm_northing)),
    utm_inconsistent = n_distinct(paste(utm_zone, utm_easting, utm_northing)) > 1,
    date = suppressWarnings(min(date, na.rm = TRUE)),
    fishing_time_s = if (all(is.na(fishing_time_s))) NA_real_ else sum(fishing_time_s, na.rm = TRUE),
    area_m2 = if (all(is.na(area_m2))) NA_real_ else sum(area_m2, na.rm = TRUE),
    fished_length_m = suppressWarnings(max(fished_length_m, na.rm = TRUE)),
    agency = first(agency),
    flag_effort_sentinel = any(flag_effort_sentinel),
    .groups = "drop"
  ) |>
  mutate(
    fished_length_m = ifelse(is.finite(fished_length_m), fished_length_m, NA_real_),
    date = if_else(is.finite(date), date, as.Date(NA)),
    year = as.integer(format(date, "%Y")), month = as.integer(format(date, "%m")),
    flag_no_utm    = is.na(utm_zone) | is.na(utm_easting) | is.na(utm_northing) | !utm_zone %in% 7:11 |
                     utm_easting < easting_valid[1] | utm_easting > easting_valid[2] |
                     utm_northing < northing_valid[1] | utm_northing > northing_valid[2],
    flag_junk_date = is.na(year) | year < 1950 | year > 2022,
    flag_no_area   = is.na(area_m2) | area_m2 <= 0,
    flag_no_effort = is.na(fishing_time_s) | fishing_time_s <= 0
  )

# ---- habitat, at site level ------------------------------------------------
habitat <- rd(file.path(cache, "2020-11-16/habitat.csv")) |>
  mutate(across(matches("^(GRADIENT|CHANNELWIDTH|WETTEDWIDTH)\\d+$"), num))
g1 <- c("GRADIENT11", "GRADIENT12"); g2 <- c("GRADIENT21", "GRADIENT22")
cwc <- grep("^CHANNELWIDTH\\d+$", names(habitat), value = TRUE)
wwc <- grep("^WETTEDWIDTH\\d+$", names(habitat), value = TRUE)
hab_rows <- habitat |>
  mutate(
    site_visit = site_of(KEY),
    grad_sentinel = apply(pick(all_of(c(g1, g2))), 1, \(v) any(v > 100, na.rm = TRUE)),
    cw_sentinel   = apply(pick(all_of(cwc)), 1, \(v) any(v >= 500, na.rm = TRUE)),
    # 0 % is a real reading, except on blank-form rows where every width is also 0 or empty
    form_blank    = apply(pick(all_of(c(cwc, wwc))), 1, \(v) !any(v > 0, na.rm = TRUE)),
    gradient_pct  = if_else(form_blank,
                            apply(pick(all_of(g1)), 1, mean_ok, hi = 100.0001),
                            apply(pick(all_of(g1)), 1, mean_ok, hi = 100.0001, lo_incl = TRUE)),
    gradient2_pct = if_else(form_blank,
                            apply(pick(all_of(g2)), 1, mean_ok, hi = 100.0001),
                            apply(pick(all_of(g2)), 1, mean_ok, hi = 100.0001, lo_incl = TRUE)),
    channel_width_m = apply(pick(all_of(cwc)), 1, mean_ok, hi = 500),
    wetted_width_m  = apply(pick(all_of(wwc)), 1, mean_ok, hi = 500),
    n_cw_measures   = apply(pick(all_of(cwc)), 1, \(v) sum(!is.na(v) & v > 0 & v < 500)),
    water_temp_c = nodata(num(WATER_TEMPERATURE), lo = temp_valid[1], hi = temp_valid[2])
  )
hab_site <- hab_rows |>
  group_by(site_visit) |>
  summarise(
    habitat_rows = n(),
    habitat_conflict = n_distinct(paste(round(gradient_pct, 2), round(channel_width_m, 2))) > 1,
    gradient_pct = med(gradient_pct), gradient2_pct = med(gradient2_pct),
    channel_width_m = med(channel_width_m), wetted_width_m = med(wetted_width_m),
    n_cw_measures = max(n_cw_measures), water_temp_c = med(water_temp_c),
    bed_dominant = first(na.omit(DOMINANT_BED_MATERIAL)),
    grad_sentinel = any(grad_sentinel), cw_sentinel = any(cw_sentinel),
    .groups = "drop"
  )
sites <- sites |>
  left_join(hab_site, by = "site_visit") |>
  mutate(has_habitat = !is.na(habitat_rows),
         across(c(habitat_conflict, grad_sentinel, cw_sentinel), ~ coalesce(.x, FALSE)))

# ---- catch: counts (abundance) + details (measured fish) --------------------
counts <- rd(file.path(cache, "2020-11-16/counts.csv")) |>
  transmute(KEY, site_visit = site_of(KEY), species_code = SPECIES_CODE,
            n = num(NUMBER_CAUGHT),
            min_length_mm = nodata(num(MINIMUM_LENGTH), lo = 1e-9),   # 0 = not recorded
            max_length_mm = nodata(num(MAXIMUM_LENGTH), lo = 1e-9)) |>
  mutate(flag_count_sentinel = is_sentinel(n),
         n = if_else(flag_count_sentinel, NA_real_, n))

fish_files <- list.files(file.path(cache, "2022-03-22-ef-export"), pattern = "\\.csv$", full.names = TRUE)
fish_raw <- map(fish_files, \(f) rd(f) |> mutate(source_file = basename(f))) |> list_rbind()
fish <- fish_raw |>
  transmute(
    KEY, site_visit = site_of(KEY), species_code = SPECIES_CODE,
    length_mm = num(LENGTH), weight_g = num(WEIGHT), age = AGE,
    sex_code = SEX_CODE, maturity_code = MATURITY_CODE,
    watershed_code_50k = gsub("-", "", NEW_WATERSHED_CODE), source_file,
    flag_no_length = is.na(length_mm) | length_mm <= 0,
    # the fish table also carries "no fish caught" records (139); they are not fish
    is_nfc = species_code %in% zero_catch_codes,
    flag_no_visit  = !KEY %in% passes$KEY
  )

catch <- full_join(
  counts |> filter(!species_code %in% c(zero_catch_codes, nonfish_codes)) |>
    group_by(site_visit, species_code) |>
    summarise(n_counted = if (all(is.na(n))) NA_real_ else sum(n, na.rm = TRUE),
              flag_count_sentinel = any(flag_count_sentinel),
              min_length_mm = suppressWarnings(min(min_length_mm, na.rm = TRUE)),
              max_length_mm = suppressWarnings(max(max_length_mm, na.rm = TRUE)),
              .groups = "drop"),
  fish |> filter(!is_nfc, !species_code %in% nonfish_codes) |> count(site_visit, species_code, name = "n_measured"),
  by = c("site_visit", "species_code")
) |>
  mutate(
    n_measured = coalesce(n_measured, 0L),
    across(c(min_length_mm, max_length_mm), ~ ifelse(is.finite(.x), .x, NA_real_)),
    flag_count_sentinel = coalesce(flag_count_sentinel, FALSE),
    flag_counts_lt_measured = !is.na(n_counted) & n_counted < n_measured,
    # abundance: the counted total; where counts are missing or short, the measured fish.
    # A sentinel count with nothing measured is a catch of unknown size: NA, never 0.
    n_caught = if_else(is.na(n_counted) & flag_count_sentinel & n_measured == 0, NA_real_,
                       pmax(coalesce(n_counted, 0), n_measured))
  ) |>
  # a species row recorded with 0 caught and nothing measured is not a catch
  filter(is.na(n_caught) | n_caught > 0)

# NFC is recorded per pass; a later depletion pass with no fish is not a conflict, so
# a conflict is NFC and fish recorded against the SAME pass.
fish_keys <- unique(c(counts$KEY[!counts$species_code %in% c(zero_catch_codes, nonfish_codes)],
                      fish$KEY[!fish$is_nfc & !fish$species_code %in% nonfish_codes]))
nfc <- bind_rows(counts |> filter(species_code %in% zero_catch_codes) |> distinct(KEY, site_visit),
                 fish |> filter(is_nfc) |> distinct(KEY, site_visit)) |>
  distinct(KEY, site_visit) |>
  mutate(conflict = KEY %in% fish_keys) |>
  group_by(site_visit) |>
  summarise(any_nfc = TRUE, flag_nfc_conflict = any(conflict), .groups = "drop")
site_catch <- catch |> group_by(site_visit) |>
  summarise(any_catch = TRUE,
            # unknown when every catch count at the site is a sentinel; never read as 0
            n_caught_all = if (all(is.na(n_caught))) NA_real_ else sum(n_caught, na.rm = TRUE),
            flag_count_unknown = any(is.na(n_caught)),
            blocks_absence_of = paste(sort(unique(unlist(strsplit(
              species_codes$blocks_absence_of[match(species_code, species_codes$code)], ";")))), collapse = ";"),
            n_species = n_distinct(species_code),
            species_caught = paste(sort(unique(species_code)), collapse = ";"), .groups = "drop")
sites <- sites |>
  left_join(nfc, by = "site_visit") |>
  left_join(site_catch, by = "site_visit") |>
  mutate(
    any_nfc = coalesce(any_nfc, FALSE),
    flag_nfc_conflict = coalesce(flag_nfc_conflict, FALSE),
    n_caught_all = if_else(is.na(any_catch), 0, n_caught_all),
    flag_count_unknown = coalesce(flag_count_unknown, FALSE),
    blocks_absence_of = coalesce(blocks_absence_of, ""),
    catch_status = case_when(
      coalesce(any_catch, FALSE) ~ "fish",   # presence, not a count: a sentinel count is still a catch
      any_nfc          ~ "zero",
      TRUE             ~ "unknown")
  )

# ---- repeated surveys (#35) -------------------------------------------------
# One survey loaded under several collection ids: same UTM, date, pass count, per-pass fished
# length and width, and per-species catch (an empty catch matches whether NFC was recorded or
# not). A group counts when every member has its own collection id (copies within one collection
# are separate sites) and the members share a site number or hold identical measured fish;
# otherwise they may be adjacent sites at one rounded UTM, and are kept and listed. The copy kept
# holds the most measured fish, then the most maturity-coded fish, then a known catch, then
# habitat, then the lowest collection id: in 94 of the 95 groups where one copy alone has
# measured fish, it is the higher id. A habitat value the copy kept lacks and a dropped copy holds
# moves to the kept one, and the placement check below reads the 50k watershed codes of every copy.
maturity_coded <- c("IM", "M", "MT", "SP", "ST")
pass_sig <- visits |>
  transmute(site_visit = site_of(KEY),
            method = as.integer(sub("^(?:[^_]+_){3}([^_]+)_.*$", "\\1", KEY, perl = TRUE)),
            pass = as.integer(sub("^.*_", "", KEY)),
            lw = paste(num(FISHING_AREA_LENGTH), num(FISHING_AREA_WIDTH), sep = "x")) |>
  arrange(site_visit, method, pass) |>
  group_by(site_visit) |>
  summarise(lw = paste(lw, collapse = "|"), .groups = "drop")
catch_sig <- catch |>
  arrange(site_visit, species_code) |>
  group_by(site_visit) |>
  summarise(n_measured_all = sum(n_measured), spc = paste(species_code, n_caught, sep = ":", collapse = ";"),
            .groups = "drop")
fish_sig <- fish |>
  filter(!is_nfc, !species_code %in% nonfish_codes) |>
  arrange(site_visit, species_code, length_mm, weight_g, age, sex_code, maturity_code) |>
  group_by(site_visit) |>
  summarise(n_coded = sum(maturity_code %in% maturity_coded),
            fsig = paste(species_code, length_mm, weight_g, age, sex_code, maturity_code, collapse = ";"),
            .groups = "drop")
rep_cand <- sites |>
  filter(!flag_no_utm, !is.na(date)) |>
  left_join(pass_sig, by = "site_visit") |>
  left_join(catch_sig, by = "site_visit") |>
  left_join(fish_sig, by = "site_visit") |>
  mutate(coll = as.numeric(sub("_.*$", "", site_visit)),
         site_number = sub("^[^_]+_([^_]+)_.*$", "\\1", site_visit),
         n_measured_all = coalesce(n_measured_all, 0L), n_coded = coalesce(n_coded, 0L),
         spc = coalesce(spc, ""), fsig = coalesce(fsig, ""),
         hsig = paste(has_habitat, gradient_pct, gradient2_pct, channel_width_m, wetted_width_m, water_temp_c),
         sig = paste(utm_zone, utm_easting, utm_northing, date, n_pass, lw, spc)) |>
  group_by(sig) |>
  filter(n() > 1) |>
  arrange(desc(n_measured_all), desc(n_coded), catch_status == "unknown", desc(has_habitat), coll, site_visit,
          .by_group = TRUE) |>
  mutate(kept = first(site_visit),
         status = case_when(n_distinct(coll) < n() ~ "kept_one_collection",
                            n_distinct(site_number) == 1 ~ "dropped",
                            n_distinct(fsig) == 1 & first(n_measured_all) > 0 ~ "dropped",
                            TRUE ~ "kept_site_differs"),
         fish_same = fsig == first(fsig), habitat_same = hsig == first(hsig),
         time_same = (is.na(fishing_time_s) & is.na(first(fishing_time_s))) |
           coalesce(fishing_time_s == first(fishing_time_s), FALSE),
         coded_lost = n_coded > first(n_coded)) |>
  ungroup()
repeat_map <- rep_cand |>
  filter(site_visit != kept) |>
  transmute(site_visit, kept_site_visit = kept, status, data_set, catch_status,
            kept_catch_status = rep_cand$catch_status[match(kept, rep_cand$site_visit)],
            site_number_same = site_number == rep_cand$site_number[match(kept, rep_cand$site_visit)],
            collection_offset = coll - rep_cand$coll[match(kept, rep_cand$site_visit)],
            n_measured = n_measured_all, fish_same, habitat_same, time_same) |>
  arrange(kept_site_visit, site_visit)
dropped <- repeat_map$site_visit[repeat_map$status == "dropped"]
# habitat moves value by value: a kept copy can hold a habitat record with no gradient or width
# in it. Each value missing on the kept copy is taken from the best-ranked dropped copy that has
# it (a width with its measure count); the record's flags are OR-ed in from those copies.
cols_hab_value <- list("gradient_pct", "gradient2_pct", c("channel_width_m", "n_cw_measures"), "wetted_width_m",
                       "water_temp_c", "bed_dominant")
drop_order <- rep_cand |> filter(site_visit %in% dropped) |> select(site_visit, kept)   # in keep order
i_drop <- match(drop_order$site_visit, sites$site_visit)
donors <- character()
for (cc in cols_hab_value) {
  has <- !is.na(sites[[cc[1]]][i_drop])
  d <- drop_order[has, ] |> distinct(kept, .keep_all = TRUE)
  i_k <- match(d$kept, sites$site_visit)
  fill <- is.na(sites[[cc[1]]][i_k])
  sites[i_k[fill], cc] <- sites[match(d$site_visit[fill], sites$site_visit), cc]
  donors <- union(donors, d$site_visit[fill])
}
i_dn <- match(donors, sites$site_visit)
i_kd <- match(drop_order$kept[match(donors, drop_order$site_visit)], sites$site_visit)
for (cc in c("has_habitat", "habitat_conflict", "grad_sentinel", "cw_sentinel")) {
  sites[[cc]][i_kd] <- sites[[cc]][i_kd] | sites[[cc]][i_dn]
}
sites$habitat_rows[i_kd] <- coalesce(sites$habitat_rows[i_kd], sites$habitat_rows[i_dn])
repeat_map <- repeat_map |> mutate(habitat_carried = site_visit %in% donors)
rep_groups <- rep_cand |> filter(sig %in% sig[status == "dropped"]) |> group_by(sig) |>
  summarise(fish_differs = !all(fish_same), habitat_differs = !all(habitat_same),
            time_differs = !all(time_same), coded_lost = any(coded_lost & site_visit %in% dropped),
            status_mixed = n_distinct(catch_status) > 1, .groups = "drop")
# the 50k watershed codes sit on fish rows, so a dropped copy's codes count for the copy kept
kept_of <- repeat_map$kept_site_visit[repeat_map$status == "dropped"]
fish_ws50 <- fish |> mutate(site_visit = coalesce(kept_of[match(site_visit, dropped)], site_visit))
fish_ws50_from <- unique(fish$site_visit[fish$site_visit %in% dropped & !is.na(fish$watershed_code_50k)])
# what the keep-one-copy rule gives up, for the ledger: measured fish (as a multiset of species,
# length, weight, age, sex and maturity) and count length bounds held only on a dropped copy
fish_key <- function(x) paste(x$species_code, x$length_mm, x$weight_g, x$age, x$sex_code, x$maturity_code)
# each dropped copy against the copy kept, the largest shortfall per group and key (copies of one
# survey repeat the same fish, so summing them would count a fish once per copy)
not_on_kept <- function(f, key) {
  f |> filter(!is_nfc, site_visit %in% dropped) |>
    mutate(kept = kept_of[match(site_visit, dropped)], key = key(pick(everything()))) |>
    count(site_visit, kept, key) |>
    left_join(f |> filter(!is_nfc, site_visit %in% kept_of) |> mutate(key = key(pick(everything()))) |>
                count(kept = site_visit, key, name = "n_kept"), by = c("kept", "key")) |>
    group_by(kept, key) |> summarise(lost = max(pmax(0L, n - coalesce(n_kept, 0L))), .groups = "drop") |>
    summarise(n = sum(lost)) |> pull(n)
}
n_fish_not_on_kept <- not_on_kept(fish, fish_key)
lengths_d <- catch |> filter(site_visit %in% dropped) |> mutate(kept = kept_of[match(site_visit, dropped)])
lengths_k <- catch |> filter(site_visit %in% kept_of) |> select(kept = site_visit, species_code, min_k = min_length_mm)
n_lengths_not_on_kept <- lengths_d |> left_join(lengths_k, by = c("kept", "species_code")) |>
  summarise(n = sum(!is.na(min_length_mm) & is.na(min_k))) |> pull(n)
rep_hab <- sites |> filter(site_visit %in% dropped) |>
  select(site_visit, all_of(unlist(cols_hab_value)))
coded_key <- function(x) paste(x$species_code, x$maturity_code)
n_coded_not_on_kept <- not_on_kept(fish |> filter(maturity_code %in% maturity_coded), coded_key)
n_pass_dropped  <- sum(sites$n_pass[sites$site_visit %in% dropped])
n_fish_dropped  <- sum(fish$site_visit %in% dropped)
is_counted_fish <- !counts$species_code %in% c(zero_catch_codes, nonfish_codes)
n_counted_dropped <- sum(counts$n[is_counted_fish & counts$site_visit %in% dropped], na.rm = TRUE)
n_counted_all     <- sum(counts$n[is_counted_fish], na.rm = TRUE)
sites  <- sites  |> filter(!site_visit %in% dropped)
catch  <- catch  |> filter(!site_visit %in% dropped)
fish   <- fish   |> filter(!site_visit %in% dropped)
counts <- counts |> filter(!site_visit %in% dropped)
message("Repeated surveys: ", length(dropped), " visits dropped from ", nrow(rep_groups), " groups")

# ---- place site visits on the network --------------------------------------
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres()),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))

pts <- sites |>
  filter(!flag_no_utm) |>
  group_split(utm_zone) |>
  map(\(d) st_transform(st_as_sf(d |> select(site_visit, utm_zone, utm_easting, utm_northing),
                                 coords = c("utm_easting", "utm_northing"),
                                 crs = 32600 + d$utm_zone[1]), 3005)) |>
  list_rbind() |>
  st_as_sf()

tmp <- "fdis_sites_tmp"
sf::st_write(pts |> select(site_visit), conn, layer = tmp, temporary = TRUE, quiet = TRUE)
message("Indexing ", nrow(pts), " site visits with fwa_indexpoint (tolerance ", snap_tol_m, " m)")
placed <- DBI::dbGetQuery(conn, sprintf("
  SELECT s.site_visit, i.linear_feature_id, i.blue_line_key, i.downstream_route_measure,
         i.distance_to_stream, i.gnis_name,
         st.gradient AS fwa_gradient, st.stream_order, st.edge_type, st.watershed_group_code,
         cw.channel_width AS modelled_channel_width_m, cw.channel_width_source,
         q.mad_m3s
    FROM %s s
    LEFT JOIN LATERAL whse_basemapping.fwa_indexpoint(s.geometry, %d, 1) i ON TRUE
    LEFT JOIN whse_basemapping.fwa_stream_networks_sp st ON st.linear_feature_id = i.linear_feature_id
    LEFT JOIN whse_basemapping.fwa_stream_networks_channel_width cw ON cw.linear_feature_id = i.linear_feature_id
    LEFT JOIN whse_basemapping.fwa_stream_networks_discharge q ON q.linear_feature_id = i.linear_feature_id",
  DBI::dbQuoteIdentifier(conn, tmp), snap_tol_m))
stopifnot(!anyDuplicated(placed$site_visit))

# placement check: the 50k watershed code FDIS recorded -> the 20k blue_line_keys it maps to
# a 50k code is a 3-digit basin then seven 6-digit levels; a code with every level zero names
# only a mainstem and cannot place a site on a tributary, so it is not a check
ws50 <- fish_ws50 |> filter(!is.na(watershed_code_50k), nchar(watershed_code_50k) == 45,
                       substr(watershed_code_50k, 4, 45) != strrep("0", 42)) |>
  distinct(site_visit, watershed_code_50k)
xref <- DBI::dbGetQuery(conn, "SELECT DISTINCT watershed_code_50k, blue_line_key_20k
                                 FROM whse_basemapping.fwa_streams_20k_50k
                                WHERE watershed_code_50k IS NOT NULL")
DBI::dbDisconnect(conn)
ws_check <- ws50 |>
  inner_join(placed |> select(site_visit, blue_line_key), by = "site_visit") |>
  left_join(xref |> mutate(hit = TRUE),
            by = c("watershed_code_50k", "blue_line_key" = "blue_line_key_20k")) |>
  group_by(site_visit) |>
  summarise(ws50_checked = TRUE, ws50_match = any(coalesce(hit, FALSE)),
            ws50_known = any(watershed_code_50k %in% xref$watershed_code_50k), .groups = "drop")

sites <- sites |>
  left_join(placed, by = "site_visit") |>
  left_join(ws_check, by = "site_visit") |>
  mutate(
    fwa_gradient_pct = fwa_gradient * 100,
    flag_not_placed  = is.na(blue_line_key),
    flag_far_snap    = !is.na(distance_to_stream) & distance_to_stream > snap_flag_m,
    ws50_checked     = coalesce(ws50_checked, FALSE),
    # only a code the xref knows can contradict the snap
    flag_ws50_mismatch = ws50_checked & coalesce(ws50_known, FALSE) & !coalesce(ws50_match, FALSE)
  ) |>
  select(-fwa_gradient)

# ---- reconcile -------------------------------------------------------------
n_counts_fish <- sum(counts$n[!counts$species_code %in% c(zero_catch_codes, nonfish_codes)], na.rm = TRUE)
rec <- tibble(check = character(), n = numeric())
add <- function(check, n) rec <<- bind_rows(rec, tibble(check = check, n = as.numeric(n)))
add("passes", nrow(passes)); add("site_visits", nrow(sites))
add("sites_multi_pass", sum(sites$n_pass > 1))
add("sites_with_utm", sum(!sites$flag_no_utm)); add("sites_placed", sum(!sites$flag_not_placed))
add("sites_far_snap", sum(sites$flag_far_snap))
add("sites_ws50_checked", sum(sites$ws50_checked)); add("sites_ws50_mismatch", sum(sites$flag_ws50_mismatch))
add("sites_catch_fish", sum(sites$catch_status == "fish"))
add("sites_catch_zero", sum(sites$catch_status == "zero"))
add("sites_catch_unknown", sum(sites$catch_status == "unknown"))
add("sites_nfc_conflict", sum(sites$flag_nfc_conflict))
add("sites_with_habitat", sum(sites$has_habitat)); add("sites_habitat_conflict", sum(sites$habitat_conflict))
add("sites_junk_date", sum(sites$flag_junk_date)); add("sites_no_area", sum(sites$flag_no_area))
add("fish_rows_in", nrow(fish_raw)); add("fish_rows_out", nrow(fish))
add("fish_nfc_rows", sum(fish$is_nfc)); add("fish_without_visit", sum(fish$flag_no_visit)); add("fish_no_length", sum(fish$flag_no_length))
add("sites_effort_sentinel", sum(sites$flag_effort_sentinel))
add("sites_blocking_ch_absence", sum(grepl("CH", sites$blocks_absence_of)))
add("sites_blocking_char_absence", sum(grepl("char", sites$blocks_absence_of)))
add("catch_pairs_count_unknown", sum(is.na(catch$n_caught)))
add("counts_fish_total", n_counts_fish); add("counts_sentinel_rows", sum(counts$flag_count_sentinel))
add("catch_pairs_counts_lt_measured", sum(catch$flag_counts_lt_measured))
add("repeat_groups", nrow(rep_groups)); add("repeat_visits_dropped", length(dropped))
dmap <- repeat_map[repeat_map$status == "dropped", ]
add("repeat_dropped_fish", sum(dmap$catch_status == "fish"))
add("repeat_dropped_zero", sum(dmap$catch_status == "zero"))
add("repeat_dropped_unknown", sum(dmap$catch_status == "unknown"))
add("repeat_passes_dropped", n_pass_dropped); add("repeat_fish_rows_dropped", n_fish_dropped)
add("repeat_counted_fish_dropped", n_counted_dropped)
add("repeat_groups_fish_differ", sum(rep_groups$fish_differs))
add("repeat_groups_habitat_differ", sum(rep_groups$habitat_differs))
add("repeat_groups_time_differ", sum(rep_groups$time_differs))
add("repeat_groups_zero_and_unknown", sum(rep_groups$status_mixed))
add("repeat_groups_maturity_coded_lost", sum(rep_groups$coded_lost))
add("repeat_habitat_carried_to_kept", length(unique(i_kd)))
add("repeat_coded_fish_not_on_kept", n_coded_not_on_kept)
add("repeat_ws50_codes_pooled", sum(dmap$site_visit %in% fish_ws50_from))
add("repeat_fish_rows_not_on_kept", n_fish_not_on_kept)
add("repeat_count_lengths_not_on_kept", n_lengths_not_on_kept)
add("repeat_groups_one_collection_kept", n_distinct(rep_cand$sig[rep_cand$status == "kept_one_collection"]))
add("repeat_groups_site_differs_kept", n_distinct(rep_cand$sig[rep_cand$status == "kept_site_differs"]))
print(rec, n = Inf)

unclassified <- setdiff(unique(c(counts$species_code, fish$species_code)), species_codes$code)
if (length(unclassified)) stop("species codes missing from data/fdis_species_codes.csv: ",
                               paste(unclassified, collapse = ", "))
if (nrow(fish_raw) != nrow(fish) + n_fish_dropped) stop("fish rows lost")
if (sum(sites$n_pass) + n_pass_dropped != nrow(visits)) stop("site roll-up lost passes")
if (anyDuplicated(rep_cand$sig[rep_cand$sig %in% rep_groups$sig & rep_cand$site_visit %in% sites$site_visit])) {
  stop("a repeated survey kept two copies")
}
if (!all(repeat_map$kept_site_visit %in% sites$site_visit)) stop("a repeated survey kept no copy")
# value by value: no habitat value a dropped copy held is missing from the copy kept
hab_lost <- unlist(lapply(unlist(lapply(cols_hab_value, `[`, 1)), function(cc) {
  dv <- rep_hab[[cc]][match(dmap$site_visit, rep_hab$site_visit)]
  kv <- sites[[cc]][match(dmap$kept_site_visit, sites$site_visit)]
  dmap$kept_site_visit[!is.na(dv) & is.na(kv)]
}))
if (length(hab_lost)) stop("habitat dropped with a repeated copy: ", paste(unique(hab_lost), collapse = ", "))
if (any(dmap$n_measured > rep_cand$n_measured_all[match(dmap$kept_site_visit, rep_cand$site_visit)])) {
  stop("a dropped copy holds more measured fish than the copy kept")
}
if (!isTRUE(all.equal(n_counts_fish + n_counted_dropped, n_counted_all))) stop("counted fish lost in the repeat drop")
if (sum(catch$n_measured) != sum(!fish$is_nfc & !fish$species_code %in% nonfish_codes)) stop("measured fish lost in the catch roll-up")
# rows dropped as "0 caught, nothing measured" carry n_counted 0, so the sum is unchanged
if (!isTRUE(all.equal(sum(catch$n_counted, na.rm = TRUE), n_counts_fish))) stop("counted fish lost in the catch roll-up")
if (sum(sites$catch_status == "fish") + sum(sites$catch_status == "zero") +
    sum(sites$catch_status == "unknown") != nrow(sites)) stop("catch status does not partition sites")

write_csv(rec, file.path(build, "reconcile.csv"))
write_csv(repeat_map, "data/fdis_repeat_surveys.csv", na = "")
saveRDS(sites, file.path(build, "sites.rds"))
saveRDS(catch, file.path(build, "catch.rds"))
saveRDS(fish,  file.path(build, "fish.rds"))
message("Wrote sites.rds, catch.rds, fish.rds, reconcile.csv to ", build)
