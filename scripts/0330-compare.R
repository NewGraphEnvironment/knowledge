# scripts/0330-compare.R
# ---------------------------------------------------------------------------
# What a tuning changes on the ground: for each fitted species x stage, link's `default` against the
# recommended rule on link's own segments in every group the species has a habitat table in (km kept,
# lost and gained; graded km; km by grade class; change by reason), floodplain hectares beside each
# rule's habitat in the groups the floodplain catalog holds (ha, graded ha, ha by grade class), and
# maps. Issue #57, phase 4. Successor to 0298 (frozen on v2). Input from 0310 and 0320.
#
# WHY / DESIGN NOTES:
#   - BOTH RULES REGENERATED THE SAME WAY (0298): fresh's predicate behind stored access, link's
#     user-habitat overlay, fresh's connectivity pass, on scratch copies; both stages together.
#     knw_compare_rules() carries the method; the link configs come from the run's commit.
#   - FLOODPLAIN AS A UNIT OF MEASURE: the catalog's whole-network floodplain (`<wsg>_all_ff04`) is a
#     fixed input, nothing here models it; knw_floodplain_ha() joins it to the segments by position
#     (one owner per cell) and reports hectares and graded hectares under each rule. Only the groups
#     the catalog holds (23 at 2026-10-17) until whole-network floodplains are published for all
#     (NewGraphEnvironment/floodplains#123).
#   - MAPS: a static three-panel figure (rules, grade, floodplain by grade) for each catalog group and
#     the three criteria groups 0298 fixed (small-stream-heavy, interior, coastal) per species x stage,
#     in research/fig/; an interactive page per catalog group in data/compare/maps/ (ignored).
#   - Species run in parallel on socket workers, each with its own scratch schema; groups within a
#     species run in order.
#
# INPUT:  data/tune/{curves.rds,<sp>_<stage>_grades.csv} (0320), data/fdis/derived/{visits_link,visits_species}.csv
#         (0310), the link repository at LINK_REPO at the build's link_sha, the stac_floodplains_bc catalog
#         (items read from its public bucket), fwapg database (PG* env vars): fresh_default, bcfishobs, whse_basemapping
# WRITES: schemas knw_cmp_<sp> in the fwapg database (scratch; dropped)
# OUTPUT: data/compare/compare.csv     per species x stage x group and total: km by rule, graded km, km by class
#         data/compare/change.csv      km gained and lost by reason and stream order
#         data/compare/checks.csv      FDIS detection on each rule's segments; the bcfishobs lift
#         data/compare/floodplain.csv  per species x stage x catalog group: ha, graded ha, ha by class under each rule
#         research/fig/compare_<sp>_<stage>_<wsg>.png, data/compare/maps/*.html (ignored)
#         scripts/logs/habitat/<date>_compare.txt
# RUN:    Rscript scripts/0330-compare.R   (from the repo root; SPECIES=CH,BT to restrict; WORKERS=4)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)

link_repo <- Sys.getenv("LINK_REPO", "../link")
workers <- as.integer(Sys.getenv("WORKERS", "4"))
only <- Sys.getenv("SPECIES", "")
schema <- "fresh_default"
catalog_bucket <- "https://stac-floodplains-bc.s3.us-west-2.amazonaws.com"
catalog_items <- "../stac_floodplains_bc/data/stac"      # the catalog repo's item records
dir_out <- "data/compare"
dir_cat <- file.path(dir_out, "catalog")
dir_maps <- file.path(dir_out, "maps")
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_compare.txt"))
for (d in c(dir_out, dir_cat, dir_maps, "research/fig")) dir.create(d, showWarnings = FALSE, recursive = TRUE)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
pg <- function() {
  tryCatch(dbConnect(Postgres(), bigint = "numeric"),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}

# ---- inputs -----------------------------------------------------------------------------
ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]][1]
curves <- readRDS("data/tune/curves.rds")
fitted <- Filter(function(r) !is.null(r$pick), curves)
if (nzchar(only)) fitted <- fitted[vapply(fitted, function(r) r$species_code %in% strsplit(only, ",")[[1]], logical(1))]
say("Comparison, knowledge#57: %d fitted species x stage; link run %s at %s.", length(fitted), run_uid, link_sha)
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5, col_types = cols(site_visit = "c"))

# link's configs at the run's commit
link_dir <- file.path(tempdir(), paste0("link_default_", substr(link_sha, 1, 7)))
dir.create(file.path(link_dir, "overrides"), showWarnings = FALSE, recursive = TRUE)
for (p in c("parameters_habitat_thresholds.csv", "rules.yaml", "parameters_fresh.csv", "overrides/user_habitat_classification.csv")) {
  out <- file.path(link_dir, p)
  st <- system2("git", c("-C", link_repo, "show", paste0(link_sha, ":inst/extdata/configs/default/", p)), stdout = out)
  if (!identical(st, 0L) || !file.exists(out) || file.size(out) == 0) stop("could not read ", p, " at link ", link_sha, " from ", link_repo)
}
say("link configs/default at %s read from %s; fresh %s.", link_sha, link_repo, as.character(packageVersion("fresh")))

# the catalog's groups
items <- list.files(catalog_items, "_all_ff04\\.json$", full.names = TRUE)
cat_wsg <- toupper(sub("_all_ff04\\.json$", "", basename(items)))
say("Floodplain catalog: %d whole-network groups (%s).", length(cat_wsg), paste(cat_wsg, collapse = " "))
gpkg_of <- function(w) {
  f <- file.path(dir_cat, paste0(tolower(w), "_floodplain.gpkg"))
  if (!file.exists(f)) {
    h <- curl::curl_fetch_disk(sprintf("%s/%s_all_ff04/floodplain.gpkg", catalog_bucket, tolower(w)), f,
                               handle = curl::new_handle(timeout = 600, followlocation = TRUE))
    if (h$status_code != 200) { unlink(f); stop("catalog item ", w, ": HTTP ", h$status_code) }
  }
  f
}

# ---- compare, per species x stage (species in parallel) ------------------------------------
conn <- pg()
groups_sp <- function(sp) dbGetQuery(conn, sprintf("SELECT DISTINCT watershed_group_code w FROM %s.streams_habitat_%s ORDER BY 1", schema, tolower(sp)))$w
jobs <- lapply(names(fitted), function(k) {
  r <- fitted[[k]]
  list(key = k, species_code = r$species_code, stage = r$stage, pick = r$pick, groups = groups_sp(r$species_code))
})
dbDisconnect(conn)
run_one <- function(job, schema, link_dir, vl, vs) {
  pkgload::load_all(quiet = TRUE)
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  grades <- readr::read_csv(file.path("data/tune", paste0(job$key, "_grades.csv")), show_col_types = FALSE, guess_max = 1e5)
  t0 <- Sys.time()
  cmp <- knw_compare_rules(pg, schema, job$species_code, job$stage, job$pick, job$groups, link_dir, grades,
                           visits = vl, visit_species = vs, scratch = paste0("knw_cmp_", tolower(job$species_code)))
  cmp$minutes <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  cmp$key <- job$key
  cmp
}
t0 <- Sys.time()
if (workers > 1L && length(jobs) > 1L) {
  cl <- parallel::makeCluster(min(workers, length(jobs)))
  res <- tryCatch(parallel::parLapply(cl, jobs, run_one, schema = schema, link_dir = link_dir, vl = vl, vs = vs),
                  finally = parallel::stopCluster(cl))
} else {
  res <- lapply(jobs, run_one, schema = schema, link_dir = link_dir, vl = vl, vs = vs)
}
names(res) <- vapply(jobs, `[[`, character(1), "key")
say("Compared %d species x stage in %.1f min on %d workers.", length(res), as.numeric(difftime(Sys.time(), t0, units = "mins")), workers)
for (k in names(res)) {
  tot <- res[[k]]$compare |> filter(watershed_group_code == "ALL")
  say("%s: %d groups, %.1f min; default %.0f km, tuned %.0f km (%+.1f %%); graded km %.0f -> %.0f; lost %.0f, gained %.0f.",
      k, nrow(res[[k]]$compare) - 1, res[[k]]$minutes, tot$default_km, tot$tuned_km, tot$change_pct,
      tot$default_graded_km, tot$tuned_graded_km, tot$lost_km, tot$gained_km)
  log_lines <- c(log_lines, paste("  ", res[[k]]$log))
}
compare <- bind_rows(lapply(res, `[[`, "compare"))
change <- bind_rows(lapply(res, `[[`, "change"))
checks <- bind_rows(lapply(res, function(x) x$checks))
write_csv(compare |> mutate(across(where(is.numeric), ~ round(.x, 3))), file.path(dir_out, "compare.csv"), na = "")
write_csv(change |> mutate(km = round(km, 3)), file.path(dir_out, "change.csv"), na = "")
write_csv(checks |> mutate(across(where(is.numeric), ~ round(.x, 4))), file.path(dir_out, "checks.csv"), na = "")

# ---- floodplain hectares and maps -----------------------------------------------------------
conn <- pg()
water_of <- function(w) {
  sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf("
    SELECT waterbody_key, 'lake' AS kind, geom FROM whse_basemapping.fwa_lakes_poly WHERE watershed_group_code = '%1$s' AND area_ha >= 10
    UNION ALL SELECT waterbody_key, 'river', geom FROM whse_basemapping.fwa_rivers_poly WHERE watershed_group_code = '%1$s'", w)), drop = TRUE)
}
fp_rows <- list()
for (k in names(res)) {
  r <- res[[k]]
  stage <- jobs[[match(k, names(res))]]$stage
  flag <- if (stage == "rear") "rearing" else "spawning"
  sp <- jobs[[match(k, names(res))]]$species_code
  seg_all <- r$segments
  per <- r$compare |> filter(watershed_group_code != "ALL")
  # the three criteria groups (0298): most order 1-2 stream, and the two largest changes either way
  crit <- c(per$watershed_group_code[which.max(per$gained_km / pmax(per$default_km, 1))],
            per$watershed_group_code[which.max(per$lost_km / pmax(per$default_km, 1))],
            per$watershed_group_code[which.max(per$default_km)])
  map_wsg <- unique(c(intersect(per$watershed_group_code, cat_wsg), crit))
  for (w in map_wsg) {
    s <- seg_all |> filter(watershed_group_code == w)
    geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
      "SELECT id_segment, geom FROM %s.streams WHERE watershed_group_code = '%s'", schema, w)), drop = TRUE)
    geom$id_segment <- as.numeric(geom$id_segment)
    sg <- geom |> inner_join(s |> transmute(id_segment, blue_line_key, accessible, stream_order, grade, grade_class,
                                            flag_default = .data[[paste0(flag, "_default")]], flag_tuned = .data[[paste0(flag, "_tuned")]]),
                             by = "id_segment")
    fp_cells <- NULL
    if (w %in% cat_wsg) {
      fp <- tryCatch(knw_floodplain_ha(gpkg_of(w), sg, c("flag_default", "flag_tuned", "accessible")), error = function(e) { say("  %s %s floodplain: %s", k, w, conditionMessage(e)); NULL })
      if (!is.null(fp)) {
        fp_rows[[paste(k, w)]] <- fp$summary |> mutate(species_code = sp, stage = stage, watershed_group_code = w,
                                                       floodplain_ha = fp$check[["floodplain_ha"]], ties = fp$check[["ties"]],
                                                       rule = unname(c(flag_default = "default", flag_tuned = "tuned", accessible = "accessible")[fp$summary$flag]))
        # the floodplain cells by the owning segment's grade, for the map
        own <- fp$segments
        own$grade_fp <- ifelse(is.na(own$grade), NA, own$grade)
        fp_cells <- tryCatch({
          bl <- sf::st_read(gpkg_of(w), layer = "all_ff04_by_blue_line_key", quiet = TRUE)
          fpp <- sf::st_read(gpkg_of(w), layer = "all_ff04", quiet = TRUE)
          bb <- sf::st_bbox(fpp)
          tmpl <- terra::rast(xmin = floor(bb[["xmin"]] / 30) * 30, xmax = ceiling(bb[["xmax"]] / 30) * 30,
                              ymin = floor(bb[["ymin"]] / 30) * 30, ymax = ceiling(bb[["ymax"]] / 30) * 30, resolution = 30, crs = "EPSG:3005")
          valleys <- terra::rasterize(terra::vect(fpp), tmpl, field = 1L, background = 0L, touches = FALSE)
          bl$blue_line_key <- as.numeric(bl$blue_line_key)
          j <- flooded::fl_valley_join(valleys, bl, own[own$blue_line_key %in% bl$blue_line_key, ], group = "blue_line_key", cols = "accessible")
          rg <- terra::rast(valleys); terra::values(rg) <- NA
          rg[j$nearest$cell] <- own$grade_fp[own$blue_line_key %in% bl$blue_line_key][j$nearest$seg]
          rg
        }, error = function(e) { say("  %s %s floodplain raster: %s", k, w, conditionMessage(e)); NULL })
      }
    }
    title <- sprintf("%s: %s %s, default against %s", w, sp, flag, r$compare$tuned_rule[1])
    tryCatch(knw_compare_map(sg, water_of(w), title,
                             png = file.path("research/fig", sprintf("compare_%s_%s.png", tolower(k), tolower(w))),
                             html = if (w %in% cat_wsg) file.path(dir_maps, sprintf("compare_%s_%s.html", tolower(k), tolower(w))) else NULL,
                             fp_cells = fp_cells),
             error = function(e) say("  %s %s map: %s", k, w, conditionMessage(e)))
  }
  say("%s: maps for %s.", k, paste(map_wsg, collapse = " "))
}
dbDisconnect(conn)
fpt <- bind_rows(fp_rows)
if (nrow(fpt)) {
  write_csv(fpt |> mutate(across(where(is.numeric), ~ round(.x, 2))), file.path(dir_out, "floodplain.csv"), na = "")
  tot <- fpt |> group_by(species_code, stage, rule) |> summarise(ha = sum(ha), graded_ha = sum(graded_ha), groups = n(), .groups = "drop")
  for (i in seq_len(nrow(tot))) say("floodplain %s %s %s: %.0f ha, %.0f graded ha over %d groups", tot$species_code[i], tot$stage[i], tot$rule[i], tot$ha[i], tot$graded_ha[i], tot$groups[i])
}
say("Done in %.1f min.", as.numeric(difftime(Sys.time(), t0, units = "mins")))
writeLines(log_lines, path_log)
