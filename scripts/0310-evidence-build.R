# scripts/0310-evidence-build.R
# ---------------------------------------------------------------------------
# One evidence build for every species: FDIS electrofishing site visits placed on link's segments
# province-wide, with each species' catch, presence and absence, link's access and habitat flags,
# wet's flow by source, the width link reads on an unmeasured stream, regulated reaches, the
# natural barriers downstream per species, the walks to rivers of each size on each flow source,
# the hydrologic zone, and the bcfishobs records these visits produced. Issue #57, phase 1.
# Replaces the builds 0290, 0294 and 0296 did one species at a time (those scripts now write
# their tables from this one). Consumers: 0320 (tuning), 0330 (comparison), 0299 (publish).
#
# WHY / DESIGN NOTES (the package functions carry the method; this script carries the order,
# the gates and the ledger):
#   - GATE: runs only after 0300 released (the settle log's last row is `released`; SETTLE=<path> names a log other
#     than the newest fresh_default one, and the log's schema is ledgered as a record, #120), and records
#     that run's run_uid and SHAs. The link commit the configs are read from later is that run's
#     link_sha. knw_build_record() refuses a SCHEMA built by another run than the released one, and
#     its line (schema, run, flow load, walk md5, fresh) is ledgered (#91).
#   - ONE SCHEMA, named by SCHEMA as 0320 and 0330 take it (default fresh_default): one retune names
#     the schema its evidence was built on. It holds every modelable group, so there is no held-out
#     schema and no step-5 class; #28's fixed split is not carried (decided 2026-10-17).
#   - ACCESS gates on streams_access (access_<sp> > 0); the habitat flags are re-gated on it and
#     the stored flags kept beside them; knw_link_access_check() writes the disagreement per
#     species on every run (link#349). access_<sp> = 2 stays in the population and is never a
#     covariate.
#   - SPECIES RANGE: a visit's species row scores only in groups where link's presence rule
#     (lnk_species_pooling() on the default bundle) marks the species present; DV pools into BT
#     where the tracker says so, up to obs_year_max.
#   - FLOW: wet's pick with the parent fallback. The live wet manifest's build stamp, the build
#     the table holds (its comment, written by wet_db_load(); the live manifest can be newer, #89)
#     and the loaded picked counts per source are ledgered (wet_db_load() filters the manifest's
#     rows on load, so a row count cannot be compared here).
#   - WALKS from every placed visit's own point (not the segment start), all sizes in q_grid on
#     every source, to the river's bank with every hop's gap counted (#73; fresh 0.42.0's convention, checked
#     against its walk by data-raw/walk_bank_check.R); the positive control against 0294's one-size walk is a
#     test, not repeated here.
#   - HYDROLOGIC ZONE from the BC catalogue zip, placed by the visit's FWA segment midpoint
#     (0296's method, unchanged).
#   - Every drop is a ledger row, and the drops and kept rows partition the input.
#   - ROUND TRIP: knw_db_latency_check() at connect stops a run off the database's host (over 20 ms) unless
#     REMOTE=TRUE; the round trip and the override are ledgered, and a refused run's ledger is
#     <date>_evidence_build_refused.csv (#110).
#
# INPUT:  data/fdis/build/{sites,catch,fish}.rds (0230), data/fdis_species_codes.csv, data/fiss_evidence.csv (0250),
#         data/<wsg>/fiss_step2_fishcoll_<wsg>.csv (0220),
#         data/fdis_size_breaks.csv, scripts/logs/habitat/<date>_link_settle.csv (0300);
#         fwapg database (PG* env vars): SCHEMA (link's persist schema), discharge, cabd, bcfishobs,
#         whse_basemapping, knw.walk_cache (the walk cache, shared with 0320's grade);
#         link >= 0.78.1 (lnk_species_pooling; the minimal build's tokens); the BC Hydrologic Zones zip;
#         PARENT_DIR (optional, #120): link's parent_<wsg>.csv.gz, each full segment's minimal parent
# OUTPUT: under EVIDENCE_DIR (default data/fdis/derived; all ignored; 0299 publishes the default's):
#         visits_link.csv     one row per placed visit
#         visits_species.csv  one row per placed visit x species
#         walks.csv           one row per start x source x river size
#         bcfishobs_fdis_match.csv
#         access_check.csv    per species x group (#120)
#         workbook_{sites,species}.csv  the FISS workbook sites placed on link's segments
#         scripts/logs/habitat/<date>_evidence_build_ledger.csv, or <date>_evidence_build_ledger-<base name>.csv for
#         another EVIDENCE_DIR (#120); its first row names the directory
# RUN:    [SCHEMA=fresh_default_20261017] [EVIDENCE_DIR=data/fdis/derived_<name>] [SETTLE=<settle log>] [PARENT_DIR=<dir>]
#         [REMOTE=TRUE] Rscript scripts/0310-evidence-build.R   (from the repo root; 4 socket
#         workers; the visit walks are cached from #91, so the first run walks them cold (6.4 min of walks and 16 min
#         in all from a remote link, 2026-10-27) and a rerun on the same flow load reads them back (0.7 min of walks))
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

schema <- Sys.getenv("SCHEMA", "fresh_default")
remote <- Sys.getenv("REMOTE") %in% c("1", "TRUE", "true")   # run off the database's host anyway
walk_cache <- "knw.walk_cache"
q_grid <- c(1, 3, 5, 10, 20, 30, 50)
sources <- c("pick", "pcic_routed", "wet_balance")
n_workers <- 4L
link_min <- "0.78.1"   # the minimal build's species_modelled.csv and its tokens (#120); lnk_species_pooling since 0.66.0
cw_agree_min <- 0.9    # 0296 measured 96.2 % province-wide; a two-group sample gave 88 %. The control
                       # is for a formula or input change, which collapses agreement, not for regional drift.
hz_url <- paste0("https://catalogue.data.gov.bc.ca/dataset/f1f86c41-ae83-49d5-92e1-526897b99fa2/",
                 "resource/fc209bd0-26ab-4f8b-9415-8f34081a3c0e/download/bc_hydrologic_zones.zip")
# the build's directory (#120): the default is the one every reader takes; another directory (a test build on another
# schema) tags its ledger with the directory's base name, outside the pattern the default readers match, so it never
# becomes their build. A build on another settle log than fresh_default's (SETTLE=, or a log naming another schema) is
# refused the default directory below. 0320 and the checks take the same EVIDENCE_DIR and find this ledger by it; 0330
# reads the directory and the ledger its summaries name
dir_out <- Sys.getenv("EVIDENCE_DIR", .knw_evidence_dir_default)
stamp <- format(Sys.Date(), "%Y%m%d")
path_ledger <- .knw_ledger_path(dir_out, stamp)
species <- knw_species()

if (!requireNamespace("link", quietly = TRUE) || packageVersion("link") < link_min) {
  stop("needs link >= ", link_min, ": pak::pak(\"NewGraphEnvironment/link\")")
}
ledger <- tibble(kind = character(), step = character(), n = numeric(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.numeric(n), note = note))
}
add("info", "evidence_dir", 0, .knw_path_rel(dir_out))
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
# whether dir_out IS the default directory, asked of the filesystem, not of the spelling: on a case-insensitive disk
# data/fdis/DERIVED, and through a symlink or `..` any other name, is the same directory. A sentinel written into one
# shows in the other
is_default_dir <- local({
  s <- tempfile("knw_dir_probe_", tmpdir = dir_out)
  file.create(s)
  on.exit(unlink(s))
  file.exists(file.path(.knw_evidence_dir_default, basename(s)))
})
# the ledger is named by the spelling, so a default directory reached by another name would write the default tables
# under a tagged ledger: refused
if (is_default_dir && nzchar(.knw_evidence_tag(dir_out))) {
  stop("EVIDENCE_DIR=", dir_out, " is the default directory by another name: write it as ", .knw_evidence_dir_default)
}
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}

# ---- gate: 0300 released on this schema -----------------------------------------
# SETTLE=<path> names the settle log (#120; default the newest <date>_link_settle.csv, fresh_default's): a test build
# on another schema has its own, <date>_link_settle-<schema>.csv. The gate is the log's run_uid, which
# knw_build_record() holds the schema to below, never the schema the log names: a provincial schema is renamed after
# its run (#73), so the published build ran SCHEMA=fresh_default_20261017 on fresh_default's settle log
settle_given <- nzchar(Sys.getenv("SETTLE"))
settle <- if (settle_given) Sys.getenv("SETTLE") else
  sort(list.files("scripts/logs/habitat", "_link_settle\\.csv$", full.names = TRUE), decreasing = TRUE)
if (!length(settle) || !file.exists(settle[1])) stop("no settle log", if (settle_given) paste0(" at ", settle), ": run scripts/0300-link-settle-wait.R first")
st <- read_csv(settle[1], show_col_types = FALSE, col_types = cols(.default = "c"))
st <- st[nrow(st), ]
if (!identical(st$status, "released")) stop(settle[1], " did not release (status ", st$status, ")")
add("info", "settle_log", 0, .knw_path_rel(settle[1]))
add("info", "settle_override", as.integer(settle_given), if (settle_given) "SETTLE= named the log" else "the newest default log")
# a log from before #120 carries no schema column: 0300 watched fresh_default alone then
settle_schema <- if ("schema" %in% names(st)) st$schema else "fresh_default"
add("info", "settle_schema", 0, settle_schema)
# a test build never writes the default directory, whose ledger name every default reader takes: the schema it was
# settled on, or a log named by hand, is not fresh_default's provincial run
if ((settle_given || !identical(settle_schema, "fresh_default")) && is_default_dir) {
  stop("a build settled on ", settle_schema, if (settle_given) paste0(" (SETTLE=", settle[1], ")") else "",
       " writes its own EVIDENCE_DIR (data/fdis/derived_<name>), never the default ", dir_out)
}
add("info", "link_run_uid", 0, st$run_uid)
for (k in c("link_version", "link_sha", "fresh_version", "fresh_sha", "fwapg_sha", "config_hash")) {
  add("info", paste0("run_", k), 0, st[[k]])
}
conn <- pg()
# The visit walks are bound by the database: refuse a connection off its host unless REMOTE=TRUE (#110). A refused
# run's ledger goes to its own file, outside the names 0320 (by its evidence directory, .knw_evidence_ledger()) and
# 0325 and 0330 (the ledger the summaries name, else the newest <date>_evidence_build_ledger.csv) read.
lat <- tryCatch(knw_db_latency_check(conn, remote = remote), error = function(e) {
  add("info", "db_round_trip_ms", NA, conditionMessage(e))
  add("info", "db_remote_override", 0)
  path_refused <- .knw_ledger_path(dir_out, stamp, refused = TRUE)
  write_csv(ledger, path_refused, na = "")
  stop(conditionMessage(e), " (ledger ", path_refused, ")", call. = FALSE)
})
add("info", "db_round_trip_ms", lat$ms, lat$line)
add("info", "db_remote_override", as.integer(lat$over && lat$remote))
message(lat$line)
rec <- knw_build_record(conn, schema, run_uid = st$run_uid)
add("info", "build_record", 0, rec$line)
# the species the schema's run modelled, per group (link writes them on its log), beside the ones this build carries
if ("species" %in% dbGetQuery(conn, "SELECT column_name FROM information_schema.columns
                                     WHERE table_schema = $1 AND table_name = 'log'", params = list(schema))$column_name) {
  sp_log <- dbGetQuery(conn, sprintf("SELECT watershed_group_code AS w, array_to_string(species, ';') AS s FROM %s.log
                                      ORDER BY 1, 2", schema))
  sp_all <- sort(unique(unlist(strsplit(sp_log$s, ";", fixed = TRUE))))
  add("info", "schema_species", length(sp_all), sprintf("the run modelled %s; this build carries %s; per group %s",
      paste(sp_all, collapse = ";"), paste(species, collapse = ";"),
      paste(unique(paste0(sp_log$w, "=", sp_log$s)), collapse = " ")))
}

# ---- visits: quality, species -----------------------------------------------------
build <- "data/fdis/build"
sites <- readRDS(file.path(build, "sites.rds"))
catch <- readRDS(file.path(build, "catch.rds"))
fish <- readRDS(file.path(build, "fish.rds"))
# 0230 keeps the FWA ids as integer64; the package functions return doubles, and dplyr will not join the two
sites <- sites |> mutate(across(where(~ inherits(.x, "integer64")), as.numeric))
codes <- read_csv("data/fdis_species_codes.csv", col_types = cols(.default = "c"), na = "")
breaks <- read_csv("data/fdis_size_breaks.csv", col_types = cols(.default = "c")) |>
  mutate(across(c(length_min_mm, length_max_mm), as.numeric))
for (f in c("sites", "catch", "fish")) add("info", paste0("md5_", f), 0, unname(tools::md5sum(file.path(build, paste0(f, ".rds")))))
add("info", "fdis_sites_in", nrow(sites))
# the snap limits 0230 placed with (#91): an environment override leaves no other trace, so readers compare these
rec0230 <- read_csv(file.path(build, "reconcile.csv"), show_col_types = FALSE)
for (k in c("snap_limit_m", "snap_limit_code_m")) {
  if (sum(rec0230$check == k) != 1L) stop(build, "/reconcile.csv has no ", k, ": rerun scripts/0230")
  add("info", k, rec0230$n[rec0230$check == k], "the limit 0230 placed with (its reconcile.csv)")
}

q <- knw_fdis_quality(sites)
ledger <- bind_rows(ledger, q$ledger |> filter(kind %in% c("drop", "info")) |> mutate(n = as.numeric(n)))
v <- q$kept

# species range and pooling from link's default bundle
cfg <- link::lnk_config("default")
loaded <- suppressWarnings(link::lnk_load_overrides(cfg))
aoi <- sort(unique(v$watershed_group_code))
pool <- bind_rows(lapply(species, function(sp) {
  tryCatch(link::lnk_species_pooling(loaded, aoi = aoi, species = sp),
           error = function(e) { add("info", paste0("pooling_error_", sp), 0, conditionMessage(e)); NULL })
}))
range_sp <- pool |> distinct(species_code, watershed_group_code)
pooled_bt <- pool |> filter(species_code == "BT", obs_species == "DV") |>
  distinct(watershed_group_code, obs_year_max)
add("info", "link_version", 0, as.character(packageVersion("link")))
add("info", "species_pooling_md5", 0,
    unname(tools::md5sum(system.file("extdata/configs/default/species_pooling.csv", package = "link"))))
add("info", "bt_dv_pooled_wsgs", nrow(pooled_bt))

vs <- knw_fdis_species(v |> select(site_visit, watershed_group_code, year, catch_status), catch, fish, codes,
                       breaks, species = species, pooled = pooled_bt)
vs <- vs |>
  left_join(v |> select(site_visit, watershed_group_code), by = "site_visit") |>
  mutate(in_range = paste(species_code, watershed_group_code) %in% paste(range_sp$species_code, range_sp$watershed_group_code)) |>
  select(-watershed_group_code)
for (sp in species) {
  x <- vs[vs$species_code == sp, ]
  add("info", paste0("species_", sp), sum(x$present),
      sprintf("present on %d visits; absent %d; blocked %d; unknown %d; in link's range %d",
              sum(x$present), sum(x$status == "absent"), sum(x$status == "blocked"), sum(x$status == "unknown"),
              sum(x$in_range)))
}

# ---- place on link's segments ----------------------------------------------------
pl <- knw_link_place(conn, v |> select(site_visit, watershed_group_code, blue_line_key, downstream_route_measure),
                     schema)
add("info", "link_multi_match", pl$overlap$n, sprintf("max overlap %.4f m", pl$overlap$max_overlap))
add("info", "species_with_access", length(pl$species_access), paste(pl$species_access, collapse = ";"))
add("info", "species_with_habitat", length(pl$species_habitat), paste(pl$species_habitat, collapse = ";"))
n0 <- nrow(v)
v <- v |> inner_join(pl$placed, by = "site_visit")
add("drop", "no_link_segment", n0 - nrow(v), sprintf("no %s segment on the visit's blue line at its measure", schema))
add("info", "segment_starts_in_window", sum(v$segment_start_offset_m >= -1 & v$segment_start_offset_m <= 5))
# the minimal parent of each full segment (#120): PARENT_DIR holds link's parent_<wsg>.csv.gz (link#415's proof, later
# link#444's export); each placed visit gains its parent's gradient, length and straddle, and one with no parent stops
# the build. Without PARENT_DIR the columns are absent, and 0320 refuses GRADIENT=parent_gradient
parent_dir <- Sys.getenv("PARENT_DIR")
if (nzchar(parent_dir)) {
  pf <- list.files(parent_dir, "^parent_[a-z]{4}\\.csv(\\.gz)?$", full.names = TRUE)
  if (!length(pf)) stop("PARENT_DIR=", parent_dir, " holds no parent_<wsg>.csv.gz")
  parent <- bind_rows(lapply(pf, read_csv, show_col_types = FALSE, col_types = cols(wsg = "c", .default = "d")))
  v <- knw_parent_join(v, parent)
  add("info", "parent_dir", length(pf), sprintf("%s: %s; md5 %s", .knw_path_rel(parent_dir), paste(basename(pf), collapse = ";"),
                                                paste(unname(tools::md5sum(pf)), collapse = ";")))
  add("info", "parent_joined", nrow(v), sprintf("of %d full segments in the parent tables", nrow(parent)))
  add("info", "parent_straddle", sum(v$parent_straddle_m > 0),
      "visits on a full segment that straddles a minimal break: part of it lies on another minimal segment")
  add("info", "parent_gradient_differs", sum(abs(v$parent_gradient - v$segment_gradient) > 1e-9, na.rm = TRUE),
      "visits whose parent's gradient is not their own segment's")
}
vs <- vs |> filter(site_visit %in% v$site_visit)

# ---- flow, width, regulated, barriers ---------------------------------------------
cat_wet <- wet::wet_catalog()
add("info", "wet_manifest", 0, paste(attr(cat_wet, "id"), "built", attr(cat_wet, "built"), "at", attr(cat_wet, "manifest")))
wet_load <- knw_discharge_load(conn)
add("info", "wet_loaded_build", 0, wet_load)
picked <- dbGetQuery(conn, "SELECT source, count(*) FILTER (WHERE pick) AS picked, count(*) AS n_segments
                            FROM discharge.fwa_v1_segment_monthly WHERE scenario = 'historical' AND month = 0 GROUP BY 1")
for (i in seq_len(nrow(picked))) {
  add("info", paste0("wet_loaded_", picked$source[i]), picked$picked[i],
      sprintf("picked annual rows; %s segments loaded (wet_db_load() filters the manifest's rows on load)", picked$n_segments[i]))
}
fl <- knw_link_flow(conn, unique(v$linear_feature_id))
v <- v |> left_join(fl, by = "linear_feature_id")
add("info", "flow_from_parent", sum(v$flow_from %in% "parent"))
add("info", "flow_missing", sum(is.na(v$mad_pick)), "no picked flow on the segment or a parent")
add("info", "code_from_parent", sum(v$code_from_parent %in% TRUE))

wd <- knw_link_width(conn, unique(v$linear_feature_id), agree_min = cw_agree_min)
v <- v |> left_join(wd$widths, by = "linear_feature_id")
add("info", "cw_model_control", wd$control$n_modelled,
    sprintf("recomputed model within 5 %% of the stored MODELLED width on %.1f %%; median ratio %.3f",
            100 * wd$control$agree_share, wd$control$median_ratio))
for (s in sort(unique(na.omit(v$fwa_cw_source)))) add("info", paste0("width_source_", s), sum(v$fwa_cw_source %in% s))
add("info", "cw_deploy_null", sum(is.na(v$cw_deploy)))

pts <- v |> distinct(blue_line_key, downstream_route_measure, wscode, localcode)
rg <- knw_link_regulated(conn, pts)
v <- v |> left_join(rg$regulated, by = c("blue_line_key", "downstream_route_measure"))
add("info", "regulating_dams_placed", nrow(rg$dams))
add("info", "regulated", sum(v$regulated %in% TRUE))

bd <- knw_link_barrier_dnstr(conn, pts, species, schema)
v <- v |> left_join(bd, by = c("blue_line_key", "downstream_route_measure"))
for (sp in species) add("info", paste0("barrier_dnstr_", sp), sum(v[[paste0("barrier_dnstr_", tolower(sp))]] %in% TRUE))
add("info", "barrier_unknown_codes", sum(is.na(v$wscode) | is.na(v$localcode)), "no watershed code even from a parent")

# ---- access check (link#349) -------------------------------------------------------
# per group (#120), so two builds of the same groups can be set beside each other; the ledger sums each species
ac <- knw_link_access_check(conn, schema, species, by_group = TRUE)
add("info", "access_check_skipped", length(ac$skipped), paste(ac$skipped, collapse = ";"))
dis <- ac$check |> filter(habitat_accessible, !access_gt0) |> group_by(species_code) |>
  summarise(across(c(n_segments, n_rearing, n_spawning, km), sum), .groups = "drop")
for (i in seq_len(nrow(dis))) {
  add("info", paste0("access_disagree_", dis$species_code[i]), dis$n_segments[i],
      sprintf("habitat accessible, access = 0: %d rearing, %d spawning, %.0f km", dis$n_rearing[i], dis$n_spawning[i], dis$km[i]))
}
dbDisconnect(conn)

# ---- walks ------------------------------------------------------------------------
starts <- v |> distinct(blue_line_key, downstream_route_measure)
t0 <- Sys.time()
w <- knw_link_walks(pg, starts, q_grid = q_grid, sources = sources, workers = n_workers, cache = walk_cache)
add("info", "walk_starts", nrow(starts),
    sprintf("x %d sources x %d sizes; %.1f min on %d workers", length(sources), length(q_grid),
            as.numeric(difftime(Sys.time(), t0, units = "mins")), n_workers))
wc <- attr(w, "cache")
add("info", "walk_cache_hit", wc[["hit"]], sprintf("start-and-source pairs read from %s", walk_cache))
add("info", "walk_cache_miss", wc[["miss"]], sprintf("start-and-source pairs walked and kept in %s", walk_cache))
# the walk's convention (#73): to the river's bank, every hop's gap counted; bank_m is what the bank rule took off
add("info", "walk_convention", 0, "bank: the distance ends at the river's bank and counts every hop's gap (fresh 0.42.0's rule, #73)")
add("info", "walk_bank_m_positive", sum(w$status == "found" & w$bank_m > 0),
    sprintf("of %d found rows; median %.1f m, 90th percentile %.1f m", sum(w$status == "found"),
            median(w$bank_m[w$status == "found" & w$bank_m > 0]), quantile(w$bank_m[w$status == "found" & w$bank_m > 0], 0.9)))
for (s in sources) for (st_ in sort(unique(w$status))) {
  add("info", sprintf("walk_%s_%s", s, st_), sum(w$src == s & w$status == st_), "rows, all sizes")
}
# target flags: a lake target, and a target on a regulated reach
conn <- pg()
tg <- w |> filter(status == "found") |> distinct(large_lfid)
tgw <- knw_link_width(conn, tg$large_lfid, agree_min = 0)$widths |> select(large_lfid = linear_feature_id, target_lake = wb_any_lake)
tgp <- dbGetQuery(conn, "SELECT linear_feature_id AS large_lfid, blue_line_key, downstream_route_measure,
                                wscode_ltree::text AS wscode, localcode_ltree::text AS localcode
                         FROM whse_basemapping.fwa_stream_networks_sp WHERE linear_feature_id = ANY($1::bigint[])",
                  params = list(paste0("{", paste(tg$large_lfid, collapse = ","), "}")))
if (nrow(tgp) != nrow(tg)) stop("a walk target is not in the FWA stream network")
tgr <- knw_link_regulated(conn, tgp)$regulated |> rename(target_regulated = regulated)
tgp <- tgp |> left_join(tgr, by = c("blue_line_key", "downstream_route_measure")) |> select(large_lfid, target_regulated)
w <- w |> left_join(tgw, by = "large_lfid") |> left_join(tgp, by = "large_lfid") |>
  mutate(target_lake = coalesce(target_lake, FALSE), target_regulated = coalesce(target_regulated, FALSE))
add("info", "walk_targets", nrow(tg), sprintf("%d on regulated reaches, %d in lakes", sum(tgp$target_regulated), sum(tgw$target_lake)))

# ---- hydrologic zone (0296's method) --------------------------------------------------
hz_zip <- tempfile(fileext = ".zip")
h <- curl::curl_fetch_disk(hz_url, hz_zip, handle = curl::new_handle(timeout = 300, followlocation = TRUE))
if (h$status_code != 200) stop("hydrologic zones download returned HTTP ", h$status_code)
add("info", "zone_zip", file.size(hz_zip), paste("md5", unname(tools::md5sum(hz_zip)), hz_url))
hz_dir <- tempfile("hydz")
utils::unzip(hz_zip, exdir = hz_dir)
hz_shp <- list.files(hz_dir, "\\.shp$", full.names = TRUE, recursive = TRUE)
if (length(hz_shp) != 1) stop("expected one shapefile in the hydrologic zones zip, found ", length(hz_shp))
hz <- sf::st_read(hz_shp, quiet = TRUE) |> transmute(hydro_zone = sprintf("%02d", as.integer(HYDZN_NO)))
if (!all(sf::st_is_valid(hz))) stop("a hydrologic zone geometry is invalid as read")
dbWriteTable(conn, "tmp_knw_pt", v |> select(site_visit, linear_feature_id), temporary = TRUE, overwrite = TRUE)
mid <- dbGetQuery(conn, "
  SELECT t.site_visit, ST_X(p) AS x, ST_Y(p) AS y
  FROM tmp_knw_pt t
  JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
  CROSS JOIN LATERAL (SELECT ST_LineInterpolatePoint(ST_Force2D(s.geom), 0.5) AS p) q")
mid_sf <- sf::st_as_sf(mid, coords = c("x", "y"), crs = 3005) |> sf::st_transform(sf::st_crs(hz))
zj <- sf::st_join(mid_sf, hz, join = sf::st_intersects) |> sf::st_drop_geometry() |>
  group_by(site_visit) |> summarise(n_zone = n_distinct(hydro_zone, na.rm = TRUE), hydro_zone = min(hydro_zone), .groups = "drop")
if (any(zj$n_zone > 1)) stop(sum(zj$n_zone > 1), " visits fall in two hydrologic zones")
v <- v |> left_join(zj |> select(site_visit, hydro_zone), by = "site_visit")
add("info", "zone_unmatched", sum(is.na(v$hydro_zone)))

# ---- workbook sites (#23's second source) ---------------------------------------------
# 0250's FISS evidence, deduped against FDIS; effort from the step-2 collection forms the groups hold.
# A site scores only with an electrofishing effort; the rest are presence-only. They are placed on
# link's segments and written beside the FDIS visits, keyed by site_key and flagged by data_set.
ev <- read_csv("data/fiss_evidence.csv", show_col_types = FALSE, col_types = cols(site_visit = "c"), guess_max = 1e5)
s2_files <- list.files("data", "^fiss_step2_fishcoll_.*\\.csv$", recursive = TRUE, full.names = TRUE)
s2 <- if (length(s2_files)) bind_rows(lapply(s2_files, read_csv, show_col_types = FALSE, col_types = cols(.default = "c"))) else NULL
fw <- knw_fiss_visits(ev, s2)
add("info", "workbook_species_rows", nrow(fw), sprintf("%d sites; %d rows score (electrofishing with effort)",
                                                       n_distinct(fw$site_visit), sum(fw$scores)))
# one row per site: the electrofishing effort where the site has one (other methods carry none)
fw_sites <- fw |>
  group_by(site_visit, watershed_group_code, blue_line_key, downstream_route_measure, year, month, data_set) |>
  summarise(across(c(fishing_time_s, area_m2, fished_length_m), ~ if (all(is.na(.x))) NA_real_ else max(.x, na.rm = TRUE)),
            .groups = "drop") |>
  filter(!is.na(blue_line_key), !is.na(downstream_route_measure))
if (anyDuplicated(fw_sites$site_visit)) stop("a workbook site has two placements or dates")
fw_pl <- knw_link_place(conn, fw_sites |> select(site_visit, watershed_group_code, blue_line_key, downstream_route_measure), schema)
fw_sites <- fw_sites |> inner_join(fw_pl$placed, by = "site_visit")
add("info", "workbook_sites_placed", nrow(fw_sites), sprintf("of %d with a placement", n_distinct(fw$site_visit)))
if (nrow(fw_sites)) {
  fw_fl <- knw_link_flow(conn, unique(fw_sites$linear_feature_id <- fw_sites$segment_linear_feature_id))
  fw_sites <- fw_sites |> left_join(fw_fl, by = "linear_feature_id")
}
write_csv(fw |> inner_join(fw_sites |> select(site_visit, id_segment), by = "site_visit"),
          file.path(dir_out, "workbook_species.csv"), na = "")
write_csv(fw_sites, file.path(dir_out, "workbook_sites.csv"), na = "")

# ---- bcfishobs records from these visits ---------------------------------------------
bm <- knw_bcfishobs_match(conn, sites |> select(site_visit, date), catch |> select(site_visit, species_code), species)
dbDisconnect(conn)
for (i in seq_len(nrow(bm$summary))) {
  add("info", paste0("bcfishobs_", bm$summary$species_code[i], "_", bm$summary$match[i]), bm$summary$n_records[i])
}

# ---- write ---------------------------------------------------------------------------
add("kept", "visits_kept", nrow(v))
out <- sum(ledger$n[ledger$kind %in% c("drop", "kept")])
if (nrow(sites) != out) stop("ledger does not partition the input: ", nrow(sites), " in, ", out, " out")
v <- v |> select(-any_of(c("geom")))
write_csv(v, file.path(dir_out, "visits_link.csv"), na = "")
write_csv(vs, file.path(dir_out, "visits_species.csv"), na = "")
write_csv(w, file.path(dir_out, "walks.csv"), na = "")
write_csv(bm$matched, file.path(dir_out, "bcfishobs_fdis_match.csv"), na = "")
write_csv(ac$check |> mutate(run_uid = st$run_uid), file.path(dir_out, "access_check.csv"), na = "")
write_csv(ledger, path_ledger, na = "")
print(ledger, n = Inf)
message(sprintf("%d visits placed; %d walk rows; ledger %s", nrow(v), nrow(w), path_ledger))
