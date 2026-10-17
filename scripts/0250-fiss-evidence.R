# scripts/0250-fiss-evidence.R
# ---------------------------------------------------------------------------
# FISS .xls Step 3 (individual fish) and Step 2 (counts, life stage) -> size-class evidence
# in the data/fdis_evidence.csv shape. Issue #21; supplements #18 (0230/0240).
# Consumer: NewGraphEnvironment/link#284.
#
# WHY / DESIGN NOTES:
#   - The FDIS export stops at 2020/2022 and at electrofishing. Fish Data Submission
#     workbooks carry later years and every method (minnow trap, angling, gill net, boat EF),
#     which is where adult and large-river fish can appear at all.
#   - Grain is the SITE (0220's site_key = report_id:reference_number) x species x size class
#     x method. Method stays in the key because it is what this source adds; FDIS rows are
#     all "electrofishing".
#   - Classing is knw_size_class() on data/fdis_size_breaks.csv, the same breaks as 0240.
#     Spawner evidence is the 0240 rule on maturity: SP or ST at any date, M in Aug-Oct.
#   - A report spans several watershed groups and 0220 parses its workbook once per group,
#     so each report is taken from ONE group (the first, alphabetically, that parsed it).
#   - DEDUPE AGAINST FDIS: there is no shared key (FDIS keys on its own fshclctn_id). A FISS
#     site is the same survey as an FDIS site visit when they share the date and UTM zone,
#     sit within 50 m, and share at least one fish of the same species and length. FDIS is
#     electrofishing only, so at such a site only the electrofishing rows are dropped; other
#     methods at the same site are new evidence and stay.
#   - The 50 m site radius is not sensitive: from 50 m to 2 km the length-matched sites go
#     from 2,796 to 2,838 and the extra matches are mostly weak (under half the site's fish).
#   - LABEL vs CLASS: Step 2 `stage` is the submitter's call, on a row, not a fish. It is
#     compared with the length class two ways: each Step 3 fish whose site x species x method
#     carries exactly one stage, and each staged Step 2 row whose min and max length fall in
#     one class. NGE's own reporting template assigns stage from length by a fixed rule
#     (fry <= 65, parr <= 110, juvenile <= 140, adult > 140 mm). `label_eq_length_rule` marks
#     labels that rule reproduces. It is descriptive, NOT authorship: a real field call of
#     "adult" on a 300 mm char matches it too, and the harvest records no submitter.
#   - Unmeasured fish: Step 2 total minus Step 3 measured, per site x species x method,
#     floored at 0, as 0240 does with FDIS counts. A Step 2 species with no count and no
#     Step 3 fish is presence with unknown abundance (n = NA), as in 0240.
#
# INPUT:  data/<wsg>/fiss_step3_fish_<wsg>.csv, fiss_step2_fishcoll_<wsg>.csv,
#         fiss_sites_<wsg>_all.csv (from 0220, every group that has them);
#         data/fdis/build/{sites,fish}.rds (from 0230); data/fdis_size_breaks.csv;
#         data/fdis_species_codes.csv. Placement in the fwapg database (PG* environment variables).
# OUTPUT: data/fiss_evidence.csv            site x species x class x method, fdis shape plus
#                                           `source` and `method`
#         data/fiss_fdis_overlap.csv        per report: electrofished fish, fish matched in
#                                           FDIS, sites judged the same survey
#         data/fiss_stage_vs_class.csv      submitter life-stage label vs length class, per fish
#                                           and per Step 2 row, with the disagreement rate
#         data/fiss_evidence_reconcile.csv  every Step 3 fish accounted for; stop() on failure
# RUN:    Rscript scripts/0250-fiss-evidence.R   (after 0220 for each group and 0230, repo root)
# ---------------------------------------------------------------------------
suppressMessages({
  library(dplyr); library(readr); library(tidyr); library(stringr); library(purrr)
  library(sf); library(DBI); library(RPostgres)
})
sf::sf_use_s2(FALSE)
pkgload::load_all(quiet = TRUE)

snap_tol_m  <- 500   # fwa_indexpoint search radius, as 0230
snap_flag_m <- 100   # farther snaps are flagged, not dropped, as 0230
same_site_m <- 50    # FISS site vs FDIS site visit, same date and zone

na_str <- c("", "NA", "na", "n/a", "N/A", "UN", "-")
rd <- function(f) read_csv(f, col_types = cols(.default = col_character()), na = na_str,
                           show_col_types = FALSE)
num <- function(x) suppressWarnings(as.numeric(x))

# ---- inputs, one owner group per report ------------------------------------
wsgs <- sort(basename(dirname(Sys.glob("data/*/fiss_step3_fish_*.csv"))))
stopifnot("no fiss_step3_fish_<wsg>.csv found; run 0220 first" = length(wsgs) > 0)
load_part <- function(stem) map_dfr(wsgs, \(w) {
  f <- file.path("data", w, sprintf(stem, w))
  if (!file.exists(f)) stop(f, " missing: re-run 0220 for ", toupper(w), call. = FALSE)
  rd(f) |> mutate(wsg = w)
})
step3_all <- load_part("fiss_step3_fish_%s.csv")
step2_all <- load_part("fiss_step2_fishcoll_%s.csv")
sites_all <- load_part("fiss_sites_%s_all.csv")
# the owner is picked from all three tables: four reports have fish but no Step 1 sheet
owner <- bind_rows(distinct(sites_all, report_id, wsg), distinct(step2_all, report_id, wsg),
                   distinct(step3_all, report_id, wsg)) |>
  distinct(report_id, wsg) |> arrange(report_id, wsg) |>
  group_by(report_id) |> summarise(owner = first(wsg), n_groups = n(), .groups = "drop")
# a report parsed in several groups should parse to the same fish in each
fish_per_group <- step3_all |> count(report_id, wsg)
n_report_mismatch <- fish_per_group |> group_by(report_id) |>
  summarise(k = n_distinct(n), .groups = "drop") |> filter(k > 1) |> nrow()
own <- function(d) d |> inner_join(owner |> select(report_id, owner), by = "report_id") |>
  filter(wsg == owner) |> select(-owner)
step3 <- own(step3_all); step2 <- own(step2_all); sites <- own(sites_all)
stopifnot("site_key not unique after taking one group per report" = !anyDuplicated(sites$site_key))
message(sprintf("%d groups, %d reports (%d parsed in more than one group); %d Step 3 fish",
                length(wsgs), nrow(owner), sum(owner$n_groups > 1), nrow(step3)))

# ---- codes ------------------------------------------------------------------
species_codes <- read_csv("data/fdis_species_codes.csv", col_types = cols(.default = "c"), na = "")
to_code <- function(label) {
  l <- str_squish(label)
  by_code <- species_codes$code[match(toupper(l), toupper(species_codes$code))]
  by_name <- species_codes$code[match(tolower(l), tolower(species_codes$name))]
  coalesce(by_code, by_name)
}
group_of <- function(code) {
  g <- species_codes$species_group[match(code, species_codes$code)]
  if_else(is.na(g) | g == "", NA_character_, g)
}
# Step 3 maturity is free text; FDIS codes it IM / M / MT / SP / ST
maturity_code_of <- function(x) {
  m <- tolower(str_squish(x))
  case_when(m == "immature" ~ "IM", m == "mature" ~ "M", m == "maturing" ~ "MT",
            m == "spawning" ~ "SP", m == "spent" ~ "ST", TRUE ~ NA_character_)
}
# methods: long labels folded to lower case; only the codes whose meaning is certain are
# spelled out, the rest (SN, TN, RS, VO) stay as recorded
method_of <- function(x) {
  m <- str_squish(x)
  case_when(is.na(m) ~ NA_character_,
            toupper(m) == "EF" ~ "electrofishing",
            toupper(m) == "MT" ~ "minnow trapping",
            toupper(m) == "GN" ~ "gill netting",
            toupper(m) == "AG" ~ "angling",
            str_detect(m, "[a-z]") ~ tolower(m),
            TRUE ~ toupper(m))
}
is_ef <- function(method) coalesce(str_detect(method, "electrofishing"), FALSE)

# ---- sites: date, placement inputs ------------------------------------------
parse_date <- function(x) {
  serial <- num(x)
  out <- as.Date(serial, origin = "1899-12-30")   # Excel day serial, as entered
  txt <- is.na(serial) & !is.na(x)
  out[txt] <- as.Date(lubridate::parse_date_time(x[txt], c("dmy", "ymd"), quiet = TRUE))
  out
}
sites <- sites |>
  transmute(site_key, report_id, wsg, gazetted_name,
            date = parse_date(survey_date),
            utm_zone = num(utm_zone), utm_easting = num(utm_easting), utm_northing = num(utm_northing),
            gradient_pct = num(average_gradient_percent), channel_width_m = num(avg_channel_width_m)) |>
  mutate(year = as.integer(format(date, "%Y")), month = as.integer(format(date, "%m")),
         # the 0220 plausibility window for BC
         placeable = !is.na(utm_zone) & utm_zone %in% 8:11 &
           !is.na(utm_easting) & utm_easting >= 150000 & utm_easting <= 850000 &
           !is.na(utm_northing) & utm_northing >= 5300000 & utm_northing <= 6700000)
n_undated <- sum(is.na(sites$date))

# ---- fish and counts, coded -------------------------------------------------
breaks <- read_csv("data/fdis_size_breaks.csv", col_types = "cccccc") |>
  mutate(length_min_mm = as.numeric(length_min_mm), length_max_mm = as.numeric(length_max_mm))
fish <- step3 |>
  mutate(species_code = to_code(species), species_group = group_of(species_code),
         method = method_of(sampling_method), length_mm = num(length_mm),
         maturity_code = maturity_code_of(maturity)) |>
  left_join(sites |> select(site_key, month), by = "site_key")
# classed once, on the focal rows only (knw_size_class refuses a group it has no breaks for)
fish$size_class <- NA_character_
focal <- !is.na(fish$species_group)
fish$size_class[focal] <- knw_size_class(fish$species_group[focal], fish$length_mm[focal], breaks)
unmapped <- fish |> filter(is.na(species_code), !is.na(species)) |> count(species, sort = TRUE)
counts <- step2 |>
  mutate(species_code = to_code(species), species_group = group_of(species_code),
         method = method_of(sampling_method), total_number = num(total_number),
         min_length_mm = num(min_length_mm), max_length_mm = num(max_length_mm))
# 1,143 Step 3 fish record no method. Where Step 2 names exactly one method for that species
# at the site (else for the site), it is theirs; otherwise the fish stay under a blank method
# rather than a guessed one. Per species first: a site that angled BT and trapped RB still
# says how its BT were caught (50296:7), and a blank key beside an angling key double counts.
one_method <- function(d, by) d |> filter(!is.na(method)) |> distinct(across(all_of(c(by, "method")))) |>
  group_by(across(all_of(by))) |> filter(n() == 1) |> ungroup()
m_sp   <- one_method(counts, c("site_key", "species_code")) |> rename(method_sp = method)
m_site <- one_method(counts, "site_key") |> rename(method_site = method)
fish <- fish |> left_join(m_sp, by = c("site_key", "species_code")) |> left_join(m_site, by = "site_key") |>
  mutate(method_inherited = is.na(method) & !is.na(coalesce(method_sp, method_site)),
         method = coalesce(method, method_sp, method_site)) |>
  select(-method_sp, -method_site)

# ---- dedupe against FDIS ----------------------------------------------------
fd_sites <- readRDS("data/fdis/build/sites.rds") |>
  filter(!flag_no_utm, !is.na(date)) |>
  select(site_visit, date, utm_zone, utm_easting, utm_northing)
fd_fish <- readRDS("data/fdis/build/fish.rds") |>
  filter(!is.na(length_mm), length_mm > 0) |>
  count(site_visit, species_code, length_mm, name = "n_fdis")
pairs <- sites |> filter(placeable, !is.na(date)) |>
  select(site_key, date, utm_zone, utm_easting, utm_northing) |>
  inner_join(fd_sites, by = c("date", "utm_zone"), suffix = c("", "_fd"), relationship = "many-to-many") |>
  filter(sqrt((utm_easting - utm_easting_fd)^2 + (utm_northing - utm_northing_fd)^2) <= same_site_m) |>
  distinct(site_key, site_visit)
ef_lengths <- fish |> filter(is_ef(method), !is.na(species_code), !is.na(length_mm), length_mm > 0) |>
  count(site_key, species_code, length_mm, name = "n_fiss")
# multiset: an FDIS row repeated k times is k fish. Each FDIS fish is matched once: within an
# FDIS length cell, FISS sites take fish in turn until the cell is used up (the same survey
# submitted in two reports pairs one visit with two sites). A FISS cell is then capped at its
# own count, since one FISS site can pair with two FDIS visits.
matched <- pairs |>
  inner_join(ef_lengths, by = "site_key", relationship = "many-to-many") |>
  inner_join(fd_fish, by = c("site_visit", "species_code", "length_mm")) |>
  arrange(site_visit, species_code, length_mm, site_key) |>
  group_by(site_visit, species_code, length_mm) |>
  mutate(alloc = pmin(n_fiss, pmax(0, n_fdis - (cumsum(n_fiss) - n_fiss)))) |>
  group_by(site_key, species_code, length_mm) |>
  summarise(n_matched = min(first(n_fiss), sum(alloc)), .groups = "drop") |>
  filter(n_matched > 0)
# which sites ARE the FDIS survey is decided before allocation: when one survey was submitted
# in two reports, the second site's allocation is 0 but its fish are in FDIS all the same
in_fdis_sites <- pairs |>
  inner_join(ef_lengths, by = "site_key", relationship = "many-to-many") |>
  semi_join(fd_fish, by = c("site_visit", "species_code", "length_mm")) |>
  distinct(site_key) |> pull(site_key)
overlap <- fish |> filter(is_ef(method)) |>
  group_by(report_id) |>
  summarise(ef_fish = n(), ef_fish_measured = sum(!is.na(length_mm) & length_mm > 0), .groups = "drop") |>
  full_join(matched |> left_join(sites |> select(site_key, report_id), by = "site_key") |>
              group_by(report_id) |>
              summarise(fish_matched = sum(n_matched), sites_in_fdis = n_distinct(site_key), .groups = "drop"),
            by = "report_id") |>
  mutate(across(c(ef_fish, ef_fish_measured, fish_matched, sites_in_fdis), ~ coalesce(.x, 0L)),
         share_matched = round(fish_matched / pmax(ef_fish_measured, 1L), 3)) |>
  arrange(desc(fish_matched), report_id)
write_csv(overlap, "data/fiss_fdis_overlap.csv", na = "")
# at a site that is an FDIS survey, a fish with no method is taken as electrofished too
drop_fdis <- function(d) d |> mutate(in_fdis = site_key %in% in_fdis_sites & (is_ef(method) | is.na(method)))
fish <- drop_fdis(fish); counts <- drop_fdis(counts)
message(sprintf("FDIS overlap: %d sites, %d electrofished fish dropped (%d matched by length)",
                length(in_fdis_sites), sum(fish$in_fdis), sum(matched$n_matched)))

# ---- evidence ---------------------------------------------------------------
ff <- fish |>
  filter(!in_fdis, !is.na(species_group), site_key %in% sites$site_key) |>
  mutate(spawner = species_group == "char" &
           (maturity_code %in% c("SP", "ST") | (maturity_code == "M" & month %in% 8:10)))
key <- c("site_key", "species_code", "species_group", "method")
by_class <- ff |> filter(!is.na(size_class)) |> count(across(all_of(key)), size_class, name = "n")
spawners <- ff |> filter(spawner) |> count(across(all_of(key)), name = "n") |>
  mutate(size_class = "spawner_evidence")
# counts and measured fish follow 0230: n_measured is every Step 3 row for the key, with or
# without a length, and n_caught is the counted total or, where that is missing or short, the
# fish measured. NA only for a species entered with no count and no fish: presence only.
catch <- counts |>
  filter(!in_fdis, !is.na(species_group), site_key %in% sites$site_key) |>
  group_by(across(all_of(key))) |>
  summarise(n_counted = if (all(is.na(total_number))) NA_real_ else sum(total_number, na.rm = TRUE),
            min_len_s2 = suppressWarnings(min(min_length_mm, na.rm = TRUE)),
            max_len_s2 = suppressWarnings(max(coalesce(max_length_mm, min_length_mm), na.rm = TRUE)),
            .groups = "drop") |>
  mutate(across(c(min_len_s2, max_len_s2), ~ if_else(is.finite(.x), .x, NA_real_)))
measured <- ff |>
  group_by(across(all_of(key))) |>
  summarise(n_measured = n(), n_nolength = sum(is.na(size_class)),
            min_len_s3 = suppressWarnings(min(length_mm[!is.na(size_class)])),
            max_len_s3 = suppressWarnings(max(length_mm[!is.na(size_class)])), .groups = "drop") |>
  mutate(across(c(min_len_s3, max_len_s3), ~ if_else(is.finite(.x), .x, NA_real_)))
catch_all <- full_join(catch, measured, by = key) |>
  mutate(n_measured = coalesce(n_measured, 0L), n_nolength = coalesce(n_nolength, 0L),
         min_length_mm = coalesce(min_len_s3, min_len_s2),
         max_length_mm = coalesce(max_len_s3, max_len_s2),
         flag_counts_lt_measured = !is.na(n_counted) & n_counted < n_measured,
         n_caught = if_else(is.na(n_counted) & n_measured == 0, NA_real_,
                            pmax(coalesce(n_counted, 0), n_measured))) |>
  # a species recorded with 0 caught and nothing measured is not a catch (as 0230)
  filter(is.na(n_caught) | n_caught > 0)
# 0240's formula: counted fish never listed, plus listed fish with no length
unmeasured <- catch_all |>
  transmute(across(all_of(key)), size_class = "unmeasured",
            n = pmax(n_caught - n_measured, 0) + n_nolength) |>
  filter(is.na(n) | n > 0)

# ---- placement (0230's fwa_indexpoint query) --------------------------------
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres()),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
used_sites <- unique(c(by_class$site_key, unmeasured$site_key, spawners$site_key))
pts <- sites |> filter(placeable, site_key %in% used_sites) |>
  group_split(utm_zone) |>
  map(\(d) st_transform(st_as_sf(d |> select(site_key, utm_zone, utm_easting, utm_northing),
                                 coords = c("utm_easting", "utm_northing"),
                                 crs = 32600 + d$utm_zone[1]), 3005)) |>
  bind_rows() |> st_as_sf()
tmp <- "fiss_sites_tmp"
sf::st_write(pts |> select(site_key), conn, layer = tmp, temporary = TRUE, quiet = TRUE)
placed <- DBI::dbGetQuery(conn, sprintf("
  SELECT s.site_key, i.blue_line_key, i.downstream_route_measure, i.distance_to_stream,
         st.gradient AS fwa_gradient, st.watershed_group_code,
         left(st.fwa_watershed_code, 3) AS fwa_basin,
         cw.channel_width AS modelled_channel_width_m, cw.channel_width_source
    FROM %s s
    LEFT JOIN LATERAL whse_basemapping.fwa_indexpoint(s.geometry, %d, 1) i ON TRUE
    LEFT JOIN whse_basemapping.fwa_stream_networks_sp st ON st.linear_feature_id = i.linear_feature_id
    LEFT JOIN whse_basemapping.fwa_stream_networks_channel_width cw ON cw.linear_feature_id = i.linear_feature_id",
  DBI::dbQuoteIdentifier(conn, tmp), snap_tol_m))
DBI::dbDisconnect(conn)
stopifnot(!anyDuplicated(placed$site_key), nrow(placed) == nrow(pts))
site_attr <- sites |>
  left_join(placed, by = "site_key") |>
  transmute(site_key, watershed_group_code, fwa_basin, blue_line_key, downstream_route_measure,
            month, year, gradient_pct, channel_width_m, fwa_gradient_pct = fwa_gradient * 100,
            modelled_channel_width_m, channel_width_source,
            flag_far_snap = !is.na(distance_to_stream) & distance_to_stream > snap_flag_m,
            # FDIS checks placement against its 50k watershed code; FISS has none read here
            flag_ws50_mismatch = NA)

evidence <- bind_rows(by_class, unmeasured, spawners) |>
  left_join(catch_all |> select(all_of(key), n_caught, n_measured, min_length_mm, max_length_mm,
                                flag_counts_lt_measured), by = key) |>
  left_join(site_attr, by = "site_key") |>
  transmute(site_visit = site_key, species_code, species_group, size_class, n, n_caught, n_measured,
            min_length_mm, max_length_mm, flag_counts_lt_measured, watershed_group_code, fwa_basin,
            blue_line_key, downstream_route_measure, month, year, gradient_pct, channel_width_m,
            fwa_gradient_pct, modelled_channel_width_m, channel_width_source, flag_far_snap,
            flag_ws50_mismatch, source = "fiss_xls", method) |>
  arrange(site_visit, species_code, method, size_class)
fdis_cols <- names(read_csv("data/fdis_evidence.csv", n_max = 0, show_col_types = FALSE))
stopifnot("fiss_evidence columns differ from fdis_evidence" = identical(names(evidence), fdis_cols))
write_csv(evidence, "data/fiss_evidence.csv", na = "")

# ---- submitter life stage vs length class -----------------------------------
# which length classes each label is consistent with, per group; written out, not inferred.
# CH has no adult class: its top class (older_juvenile, 120 mm+) is open, so a CH adult lands there.
stage_ok <- tribble(
  ~species_group, ~stage_norm, ~size_class,
  "CH",   "alevin",   "fry",
  "CH",   "fry",      "fry",
  "CH",   "parr",     "parr",
  "CH",   "juvenile", "parr",
  "CH",   "juvenile", "older_juvenile",
  "CH",   "adult",    "older_juvenile",
  "char", "alevin",   "fry",
  "char", "fry",      "fry",
  "char", "parr",     "juvenile",
  "char", "juvenile", "juvenile",
  "char", "adult",    "subadult",
  "char", "adult",    "adult"
) |> mutate(agrees = TRUE)
template_length_rule <- function(len) cut(len, c(0, 65, 110, 140, Inf), c("fry", "parr", "juvenile", "adult"),
                              right = TRUE) |> as.character()
staged <- counts |> filter(!is.na(species_group), !is.na(stage_norm))
# fish level: the label of the one staged row set for the fish's site x species x method
one_stage <- staged |> distinct(site_key, species_code, method, stage_norm) |>
  add_count(site_key, species_code, method, name = "n_stages")
fish_lab <- fish |> filter(!is.na(size_class)) |>
  inner_join(one_stage, by = c("site_key", "species_code", "method"), relationship = "many-to-many")
n_fish_ambiguous <- n_distinct(fish_lab |> filter(n_stages > 1) |> select(site_key, species_code, method))
fish_cmp <- fish_lab |> filter(n_stages == 1) |>
  transmute(level = "fish", species_group, stage_norm, size_class,
            label_eq_length_rule = stage_norm == template_length_rule(length_mm))
# row level: a staged Step 2 row whose min and max length class the same
row_cmp <- staged |>
  mutate(lo = min_length_mm, hi = coalesce(max_length_mm, min_length_mm)) |>
  filter(!is.na(lo), lo > 0, hi >= lo) |>
  mutate(c_lo = knw_size_class(species_group, lo, breaks), c_hi = knw_size_class(species_group, hi, breaks)) |>
  filter(c_lo == c_hi) |>
  transmute(level = "step2_row", species_group, stage_norm, size_class = c_lo,
            label_eq_length_rule = stage_norm == template_length_rule(lo) & stage_norm == template_length_rule(hi))
stage_vs_class <- bind_rows(fish_cmp, row_cmp) |>
  left_join(stage_ok, by = c("species_group", "stage_norm", "size_class")) |>
  mutate(agrees = coalesce(agrees, FALSE), label_eq_length_rule = coalesce(label_eq_length_rule, FALSE)) |>
  count(level, species_group, stage_norm, size_class, agrees, label_eq_length_rule, name = "n") |>
  arrange(level, species_group, stage_norm, size_class)
write_csv(stage_vs_class, "data/fiss_stage_vs_class.csv", na = "")
disagree <- stage_vs_class |>
  group_by(level, species_group) |>
  summarise(disagree = round(sum(n[!agrees]) / sum(n), 3), n = sum(n), .groups = "drop")
print(as.data.frame(disagree))

# ---- reconcile: every Step 3 fish lands in exactly one bucket ----------------
ff_ids <- fish |>
  mutate(bucket = case_when(
    !site_key %in% sites$site_key ~ "no_step1_site",
    in_fdis                       ~ "in_fdis",
    is.na(species_code)           ~ "species_unmapped",
    is.na(species_group)          ~ "not_focal",
    !is.na(size_class)            ~ "classed",
    TRUE                          ~ "focal_no_length"))
buckets <- count(ff_ids, bucket)
b <- function(k) sum(buckets$n[buckets$bucket == k])
chk <- function(check, expected, actual, pass = expected == actual, note = "")
  tibble(check = check, expected = as.character(expected), actual = as.character(actual), pass = pass, note = note)
# expected sides come from a different path than the rows they check: the owner-group fish
# count from step3_all, and n_caught from the Step 2 totals
# (not through `owner`: a report missing from it would shrink both sides alike)
owned_fish <- fish_per_group |> arrange(report_id, wsg) |> group_by(report_id) |>
  summarise(n = first(n), .groups = "drop") |> pull(n) |> sum()
written <- bind_rows(by_class, unmeasured) |> group_by(across(all_of(key))) |>
  summarise(n_written = sum(n), .groups = "drop") |>
  inner_join(catch_all |> filter(!is.na(n_caught)) |> select(all_of(key), n_caught), by = key)
reconcile <- bind_rows(
  chk("step3_fish_in_buckets_vs_owner_groups", owned_fish, sum(buckets$n)),
  # a regression guard on the unmeasured formula, not a reconciliation: with n_caught >=
  # n_measured it holds by construction, and it fires if the round-1 double count returns
  chk("unmeasured_formula_classed_plus_unmeasured_eq_n_caught", 0L, sum(written$n_written != written$n_caught)),
  # Step 3 fish under a blank method beside a named key for the same species at the site: one
  # catch split in two (50296:7). Blank-method Step 2 rows beside named ones are not this:
  # they are separate count rows whose method cell was left empty (19089:1), and add up.
  chk("site_species_step3_fish_blank_beside_named_method", 0L,
      nrow(inner_join(catch_all |> filter(is.na(method), n_measured > 0) |> distinct(site_key, species_code),
                      catch_all |> filter(!is.na(method)) |> distinct(site_key, species_code),
                      by = c("site_key", "species_code")))),
  chk("step3_method_inherited_from_step2", NA, sum(fish$method_inherited), pass = TRUE),
  chk("step3_method_blank", NA, sum(is.na(fish$method)), pass = TRUE),
  chk("reports_parsed_differently_across_groups", 0L, n_report_mismatch),
  chk("buckets", NA, paste(sprintf("%s=%d", buckets$bucket, buckets$n), collapse = "; "), pass = TRUE),
  chk("species_labels_unmapped", NA, nrow(unmapped), pass = TRUE,
      note = paste(sprintf("%s=%d", unmapped$species, unmapped$n)[seq_len(min(15, nrow(unmapped)))], collapse = "; ")),
  chk("sites_undated", NA, n_undated, pass = TRUE),
  chk("evidence_sites_unplaced", NA, sum(is.na(evidence$blue_line_key) & evidence$site_visit %in% pts$site_key), pass = TRUE,
      note = "placeable sites fwa_indexpoint found no stream for within 500 m"),
  chk("evidence_sites_not_placeable", NA, n_distinct(evidence$site_visit[!evidence$site_visit %in% pts$site_key]), pass = TRUE),
  chk("fdis_overlap_sites", NA, length(in_fdis_sites), pass = TRUE),
  chk("stage_fish_groups_ambiguous", NA, n_fish_ambiguous, pass = TRUE,
      note = "site x species x method with more than one staged Step 2 row; its fish are not compared")
)
write_csv(reconcile, "data/fiss_evidence_reconcile.csv", na = "")
print(as.data.frame(reconcile), right = FALSE)
if (!all(reconcile$pass)) stop("Reconciliation FAILED: ", paste(reconcile$check[!reconcile$pass], collapse = ", "), call. = FALSE)

message(sprintf("fiss_evidence: %d rows over %d sites | focal fish classed %d | CH %d, char %d",
                nrow(evidence), n_distinct(evidence$site_visit), b("classed"),
                sum(by_class$n[by_class$species_group == "CH"]), sum(by_class$n[by_class$species_group == "char"])))
