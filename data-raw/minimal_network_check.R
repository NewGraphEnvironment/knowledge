# data-raw/minimal_network_check.R
# ---------------------------------------------------------------------------
# Before tuning on link's minimal network (#120): does a build on it place the same visits as a build on the full
# network of the same groups, with only the segment differing? Four checks on two evidence builds 0310 wrote, and a
# fifth on the database:
#   1. PLACEMENT: the same visits placed on both, at one blue line and measure and on one Atlas line; which segment
#      columns, access codes and habitat flags differ, and on how many visits.
#   2. WALKS: walks.csv the same rows on both (the walk reads FWA and the flows, never link's segments), and
#      visits_species.csv the same (species, outcome and range do not read the segments either).
#   3. ACCESS: access_check.csv per species x group x cell beside each other, where the km differ.
#   4. PARENT: on the full build (0310's PARENT_DIR), each visit's minimal parent against the minimal build's own
#      segment at that visit: the same segment and the same gradient, and the visits on a full segment that straddles
#      a minimal break, which read the other minimal segment's gradient on part of their segment.
#   5. STORED (STORED=TRUE, reads the database): link's stored rearing and spawning km per species x group on the two
#      schemas the ledgers name.
#
# INPUT:  FULL_DIR and MIN_DIR (0310's EVIDENCE_DIR for each build; default data/fdis/derived_zz415_default and
#         data/fdis/derived_zz415_minimal) and their ledgers (the newest each directory wrote)
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_minimal_network_check[-<n>].txt
# RUN:    [FULL_DIR=…] [MIN_DIR=…] [STORED=TRUE] Rscript data-raw/minimal_network_check.R   (from the repo root; the
#         database only with STORED=TRUE, through PG* or PGSERVICE)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)

full_dir <- Sys.getenv("FULL_DIR", "data/fdis/derived_zz415_default")
min_dir <- Sys.getenv("MIN_DIR", "data/fdis/derived_zz415_minimal")
path_log <- .knw_free_path(file.path("scripts/logs/habitat",
                                     paste0(format(Sys.Date(), "%Y%m%d"), "_minimal_network_check.txt")))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

led_of <- function(d) {
  f <- .knw_evidence_ledger(d)
  l <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
  list(path = f, schema = sub("^build: schema ([^,]+),.*$", "\\1", l$note[l$step == "build_record"]),
       record = l$note[l$step == "build_record"])
}
lf <- led_of(full_dir)
lm <- led_of(min_dir)
say("Minimal network check, knowledge#120. Full: %s (%s). Minimal: %s (%s).", .knw_path_rel(full_dir), lf$path,
    .knw_path_rel(min_dir), lm$path)
say("  %s", lf$record)
say("  %s", lm$record)

rd_vl <- function(d) {
  read_csv(file.path(d, "visits_link.csv"), show_col_types = FALSE, guess_max = 1e5,
           col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
}
vf <- rd_vl(full_dir)
vm <- rd_vl(min_dir)

# ---- 1. placement -------------------------------------------------------------------------------
only_f <- setdiff(vf$site_visit, vm$site_visit)
only_m <- setdiff(vm$site_visit, vf$site_visit)
say("1. PLACEMENT. Visits placed: full %d, minimal %d; on the full alone %d, on the minimal alone %d.",
    nrow(vf), nrow(vm), length(only_f), length(only_m))
j <- inner_join(vf, vm, by = "site_visit", suffix = c(".f", ".m"))
same_place <- j$blue_line_key.f == j$blue_line_key.m &
  abs(j$downstream_route_measure.f - j$downstream_route_measure.m) < 1e-6 &
  j$segment_linear_feature_id.f == j$segment_linear_feature_id.m
say("   On both at one blue line and measure and on one Atlas line: %d of %d.", sum(same_place, na.rm = TRUE), nrow(j))
cols_cmp <- setdiff(intersect(names(vf), names(vm)),
                    c("site_visit", grep("^parent_", names(vf), value = TRUE)))
differs <- vapply(cols_cmp, function(cl) {
  a <- j[[paste0(cl, ".f")]]
  b <- j[[paste0(cl, ".m")]]
  if (is.numeric(a) && is.numeric(b)) sum(xor(is.na(a), is.na(b)) | (!is.na(a) & !is.na(b) & abs(a - b) > 1e-9))
  else sum(xor(is.na(a), is.na(b)) | (!is.na(a) & !is.na(b) & as.character(a) != as.character(b)))
}, numeric(1))
dif <- tibble(column = names(differs), visits_differ = unname(differs)) |> filter(visits_differ > 0) |>
  arrange(desc(visits_differ))
block("columns that differ between the two builds, visits on both", dif)
say("   Columns that differ: %d of %d compared; outside the segment, access and habitat columns: %s.",
    nrow(dif), length(cols_cmp),
    paste(setdiff(dif$column, grep("^(segment_|id_segment|elevation_m|access_|[a-z]+_(accessible|spawning|rearing|lake_rearing|wetland_rearing)(_stored)?$)",
                                   dif$column, value = TRUE)), collapse = ", "))
block("segments at visits, by catch: share starting at the visit and median length",
      bind_rows(vf |> mutate(network = "full"), vm |> mutate(network = "minimal")) |>
        mutate(at_visit = segment_start_offset_m >= -1 & segment_start_offset_m <= 5) |>
        group_by(network, catch_status) |>
        summarise(visits = n(), at_visit_pct = round(100 * mean(at_visit), 1),
                  len_median_m = round(median(segment_length_m), 0), .groups = "drop"))

# ---- 2. walks and species ---------------------------------------------------------------------
md5 <- function(d, f) unname(tools::md5sum(file.path(d, f)))
for (f in c("walks.csv", "visits_species.csv")) {
  a <- read_csv(file.path(full_dir, f), show_col_types = FALSE, col_types = cols(.default = "c"))
  b <- read_csv(file.path(min_dir, f), show_col_types = FALSE, col_types = cols(.default = "c"))
  key <- function(x) do.call(paste, c(as.list(x), sep = "\t"))
  ka <- sort(key(a))
  kb <- sort(key(b))
  say("2. %s: full %d rows, minimal %d; the same rows: %s (md5 %s, %s).", f, nrow(a), nrow(b),
      identical(names(a), names(b)) && identical(ka, kb), md5(full_dir, f), md5(min_dir, f))
  if (!identical(ka, kb)) say("   rows in one alone: full %d, minimal %d.", length(setdiff(ka, kb)), length(setdiff(kb, ka)))
}

# ---- 3. access, per group -----------------------------------------------------------------------
af <- read_csv(file.path(full_dir, "access_check.csv"), show_col_types = FALSE)
am <- read_csv(file.path(min_dir, "access_check.csv"), show_col_types = FALSE)
if (!"watershed_group_code" %in% names(af) || !"watershed_group_code" %in% names(am)) {
  stop("access_check.csv has no group column: rebuild with 0310 from #120")
}
by <- c("species_code", "watershed_group_code", "habitat_accessible", "access_gt0")
ac <- full_join(af |> select(all_of(by), km_full = km), am |> select(all_of(by), km_min = km), by = by) |>
  mutate(across(c(km_full, km_min), ~ coalesce(.x, 0)), km_diff = round(km_min - km_full, 2),
         km_full = round(km_full, 1), km_min = round(km_min, 1))
say("3. ACCESS: %d species x group x cell rows; km differ by more than 0.01 on %d.", nrow(ac), sum(abs(ac$km_diff) > 0.01))
block("access km per species x group x cell where the two builds differ (minimal - full)",
      ac |> filter(abs(km_diff) > 0.01) |> arrange(species_code, watershed_group_code, desc(abs(km_diff))))
# the access codes at each visit: which pairs of codes differ, and whether any crosses zero (access > 0 is the gate)
acc_sp <- sub("^access_", "", grep("^access_", intersect(names(vf), names(vm)), value = TRUE))
acc_pairs <- bind_rows(lapply(acc_sp, function(sp) {
  a <- j[[paste0("access_", sp, ".f")]]
  b <- j[[paste0("access_", sp, ".m")]]
  d <- !is.na(a) & !is.na(b) & a != b
  if (!any(d)) return(NULL)
  tibble(species = toupper(sp), code_full = a[d], code_minimal = b[d])
}))
if (nrow(acc_pairs)) {
  block("access codes that differ at a visit, per species (full, minimal)",
        acc_pairs |> count(species, code_full, code_minimal, name = "visits"))
}
say("   Access codes differ at %d visit x species pairs; across zero at %d.", nrow(acc_pairs),
    sum((acc_pairs$code_full > 0) != (acc_pairs$code_minimal > 0)))
block("access km per species, access > 0 (both builds)",
      ac |> filter(access_gt0) |> group_by(species_code, watershed_group_code) |>
        summarise(km_full = sum(km_full), km_min = sum(km_min), .groups = "drop") |> mutate(km_diff = km_min - km_full))
# the province per species (#145): the sum of the rows above
block("access km per species, access > 0, the province",
      ac |> filter(access_gt0) |> group_by(species_code) |>
        summarise(km_full = sum(km_full), km_min = sum(km_min), .groups = "drop") |>
        mutate(km_diff = km_min - km_full, pct = round(100 * km_diff / km_full, 2)))

# ---- 4. the minimal parent at each visit -------------------------------------------------------
if (all(c("parent_id_segment", "parent_gradient") %in% names(vf))) {
  p <- inner_join(vf |> select(site_visit, catch_status, id_segment, segment_gradient, segment_length_m, parent_id_segment,
                               parent_gradient, parent_length_m, parent_straddle_m),
                  vm |> select(site_visit, min_id_segment = id_segment, min_gradient = segment_gradient,
                               min_length_m = segment_length_m), by = "site_visit") |>
    mutate(same_segment = parent_id_segment == min_id_segment, same_gradient = abs(parent_gradient - min_gradient) < 1e-9,
           straddle = parent_straddle_m > 0)
  say("4. PARENT: %d visits on both; the full segment's parent is the minimal build's segment at the visit on %d, with its gradient on %d.",
      nrow(p), sum(p$same_segment, na.rm = TRUE), sum(p$same_gradient, na.rm = TRUE))
  say("   Visits on a full segment that straddles a minimal break: %d (of them, %d where the parent is not the visit's minimal segment).",
      sum(p$straddle, na.rm = TRUE), sum(p$straddle & !p$same_segment, na.rm = TRUE))
  block("visits whose parent is not the minimal segment they sit on",
        p |> filter(!same_segment | !same_gradient) |>
          select(site_visit, catch_status, id_segment, parent_id_segment, min_id_segment, segment_gradient, parent_gradient,
                 min_gradient, parent_straddle_m, segment_length_m, min_length_m))
  block("gradient each setup reads at a visit, by catch: full segment, its parent, the minimal segment",
        p |> group_by(catch_status) |>
          summarise(visits = n(), full_vs_parent_differ = sum(abs(segment_gradient - parent_gradient) > 1e-9, na.rm = TRUE),
                    parent_vs_min_differ = sum(!same_gradient, na.rm = TRUE), .groups = "drop"))
} else {
  say("4. PARENT: the full build has no parent columns (0310 without PARENT_DIR); not checked.")
}
# ---- 5. link's stored habitat on each schema ----------------------------------------------------
# what link stored (stage 1-3 of its build, before any knowledge rule) per species x group, rearing and spawning, on
# the two schemas the ledgers name; the database is read only when STORED=TRUE (PG* or PGSERVICE)
if (Sys.getenv("STORED") %in% c("1", "TRUE", "true")) {
  conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  stored <- bind_rows(lapply(c(full = lf$schema, minimal = lm$schema), function(s) {
    hab <- DBI::dbGetQuery(conn, "SELECT table_name FROM information_schema.tables
                                  WHERE table_schema = $1 AND table_name LIKE 'streams_habitat_%'", params = list(s))$table_name
    hab <- hab[grepl("^streams_habitat_[a-z]{2,3}$", hab)]   # the species tables, not link's long view
    bind_rows(lapply(sort(hab), function(t) {
      DBI::dbGetQuery(conn, sprintf("
        SELECT %3$s AS species_code, h.watershed_group_code,
               coalesce(sum(st.length_metre) FILTER (WHERE h.rearing), 0) / 1000 AS rear_km,
               coalesce(sum(st.length_metre) FILTER (WHERE h.spawning), 0) / 1000 AS spawn_km
        FROM %1$s.%2$s h JOIN %1$s.streams st USING (id_segment, watershed_group_code)
        GROUP BY 2", s, t, DBI::dbQuoteString(conn, toupper(sub("^streams_habitat_", "", t)))))
    })) |> mutate(schema = s)
  }), .id = "network")
  DBI::dbDisconnect(conn)
  wide <- stored |> select(-schema) |>
    tidyr::pivot_wider(names_from = network, values_from = c(rear_km, spawn_km), values_fill = 0) |>
    mutate(across(where(is.numeric), ~ round(.x, 1)), rear_diff = rear_km_minimal - rear_km_full,
           spawn_diff = spawn_km_minimal - spawn_km_full) |>
    filter(rear_km_full + rear_km_minimal + spawn_km_full + spawn_km_minimal > 0) |>
    arrange(species_code, watershed_group_code)
  say("5. STORED: link's stored habitat km per species x group on %s and %s (minimal - full).", lf$schema, lm$schema)
  block("stored rearing and spawning km", wide)
  # the province per species (#145): the sum of the rows above
  block("stored rearing and spawning km, the province", wide |> group_by(species_code) |>
          summarise(across(c(rear_km_full, rear_km_minimal, spawn_km_full, spawn_km_minimal), sum), .groups = "drop") |>
          mutate(rear_pct = if_else(rear_km_full > 0, round(100 * (rear_km_minimal - rear_km_full) / rear_km_full, 2),
                                    NA_real_),
                 spawn_pct = round(100 * (spawn_km_minimal - spawn_km_full) / spawn_km_full, 2)))
}
writeLines(log_lines, path_log)
message("Written ", path_log)
