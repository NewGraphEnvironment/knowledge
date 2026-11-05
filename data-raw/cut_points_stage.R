# data-raw/cut_points_stage.R
# ---------------------------------------------------------------------------
# The inputs of the cut-points article (#149), copied and queried into one ignored directory on the database's host,
# with a manifest of md5s, so data-raw/vignette_cut_points.R builds the article's bundle with no database and no
# other ignored file.
#
# WHAT IT STAGES:
#   - the evidence of the three networks the article compares: #92's (link 0.66.0, data/fdis/derived_published_20261017),
#     #145's (link 0.78.2, data/fdis/derived), the minimal network's (data/fdis/derived_minimal), and the parent and
#     Atlas setups' (data/fdis/derived_parent, #145's visits with each segment's minimal parent and Atlas-line gradient);
#     visits_link.csv and visits_species.csv of each, each held to the md5 its tune run's grade record names;
#   - the tune and comparison tables of the four chinook rearing setups (#120: published 20261104_0543, minimal
#     20261103_0838, parent 20261105_0436, Atlas line 20261105_0437) and, for the article's one sentence on the other
#     keys, the minimal run's tables for every key it fitted; the published run's tables are tracked and read in place;
#   - data/compare/setups/CH_rear_setups.gpkg (every full-network segment any setup draws, with each setup's verdict;
#     data-raw/setup_compare.R);
#   - from the database, on every blue line holding a chinook site with fish whose gradient lies on opposite sides of a
#     tuned limit (9, 11 or 13 %) between any two setups: the full and minimal networks' segments and the Atlas lines
#     within WINDOW_M of each such site, with their elevations (Z) and measures (M), and every chinook site of the
#     tuning's population on those lines, placed on its Atlas line at its measure; and the lakes (10 ha or more) and
#     river polygons near those lines and in the map's group (setup_compare.R's criterion: the most km where the
#     setups' verdicts differ). The bundle chooses its examples from these lines and refuses one outside them.
#
# The population is the tuning's before its model filters (knw_tune_run()'s visits_in for CH rearing): stream branch,
# fished area in range, chinook in range, absence not blocked, no barrier to chinook downstream.
#
# Refuses unless the database holds the builds the grade records name (knw_build_record() on both schemas, and
# knw_parent_read()'s provenance), and on a connection off the database's host (knw_db_latency_check()).
#
# INPUT:  the files above; the database holding the full and minimal builds (PGSERVICE)
# OUTPUT: data/stage/cut_points/ (ignored): MANIFEST.csv (path, source, md5, bytes, rows) and the staged files;
#         scripts/logs/habitat/<yyyymmdd>_cut_points_stage.txt
# RUN:    PGSERVICE=<entry> Rscript data-raw/cut_points_stage.R   (from the repo root; WINDOW_M=3000)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

key <- "CH_rear"
schema <- "fresh_default"
schema_min <- "fresh_default_minimal"
window_m <- as.numeric(Sys.getenv("WINDOW_M", "3000"))
limits <- c(0.09, 0.11, 0.13)   # the tuned chinook rearing limits: minimal and parent, #92's, #145's (and its region)
dir_out <- "data/stage/cut_points"
# the setups' runs, as data-raw/setup_compare.R names them
runs <- c(published = "", minimal = "20261103_0838", parent = "20261105_0436", atlas = "20261105_0437")
dir_t <- function(r) if (nzchar(r)) file.path("data/tune/candidate", r) else "data/tune"
dir_c <- function(r) if (nzchar(r)) file.path("data/compare/candidate", r) else "data/compare"
# each evidence directory and the run whose grade record names its md5s
evidence <- tibble(
  name = c("published_92", "published_145", "minimal", "parent"),
  dir = c("data/fdis/derived_published_20261017", "data/fdis/derived", "data/fdis/derived_minimal",
          "data/fdis/derived_parent"),
  record = c(NA, file.path(dir_t(runs[["published"]]), paste0(key, "_grades_record.csv")),
             file.path(dir_t(runs[["minimal"]]), paste0(key, "_grades_record.csv")),
             file.path(dir_t(runs[["parent"]]), paste0(key, "_grades_record.csv"))))
# #92's grades are no longer tracked (#145 replaced them); its evidence md5s are the ones its tune tables carried
md5_92 <- c(visits_link = "1bd35829d07ca92f0b0faa565db65280", visits_species = "009698d73afd855c3e8db1235ad96c05")

stamp <- format(Sys.time(), "%Y%m%d", tz = "UTC")
path_log <- .knw_free_path(file.path("scripts/logs/habitat", sprintf("%s_cut_points_stage.txt", stamp)))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
dirty <- length(system2("git", c("status", "--porcelain", "--", "R", "data-raw/cut_points_stage.R"), stdout = TRUE)) > 0
commit <- system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE)
say("Cut-points staging (#149), at knowledge %s%s; window %g m either side of a site.", commit,
    if (dirty) " (uncommitted changes)" else "", window_m)

# ---- the runs' records, and the evidence held to them -------------------------------------------------------
recs <- lapply(stats::setNames(names(runs), names(runs)), function(s) {
  knw_grade_record_read(file.path(dir_t(runs[[s]]), paste0(key, "_grades_record.csv")))
})
md5_of <- function(f) unname(tools::md5sum(f))
for (i in seq_len(nrow(evidence))) {
  want <- if (is.na(evidence$record[i])) md5_92 else {
    m <- strsplit(knw_grade_record_read(evidence$record[i])$evidence_md5, ";", fixed = TRUE)[[1]]
    c(visits_link = m[1], visits_species = m[2])
  }
  for (f in names(want)) {
    p <- file.path(evidence$dir[i], paste0(f, ".csv"))
    if (!file.exists(p)) stop("missing: ", p)
    if (!identical(md5_of(p), unname(want[[f]]))) {
      stop(p, " is not the evidence its run names (md5 ", md5_of(p), ", want ", want[[f]], ")")
    }
  }
}
say("Evidence held to its runs: #92's to its tune tables' md5s, the others to their grade records.")

# ---- the database holds the builds the records name -----------------------------------------------------
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
                 error = function(e) stop("database unreachable (PGSERVICE or PG*): ", conditionMessage(e)))
lat <- knw_db_latency_check(conn)
say("%s", lat$line)
run_full <- unique(vapply(recs[c("published", "parent", "atlas")], function(r) as.character(r$run_uid), character(1)))
if (length(run_full) != 1) stop("the full-network setups name link runs ", paste(run_full, collapse = ", "))
say("%s", knw_build_record(conn, schema, run_uid = run_full)$line)
say("%s", knw_build_record(conn, schema_min, run_uid = as.character(recs$minimal$run_uid))$line)
par0 <- knw_parent_read(conn, schema, schema_min, keys = data.frame(watershed_group_code = "BULK", id_segment = 1))
pv <- attr(par0, "provenance")
if (!identical(pv$run_uid_full, run_full) || !identical(pv$run_uid_minimal, as.character(recs$minimal$run_uid))) {
  stop("streams_parent joins runs ", pv$run_uid_full, " and ", pv$run_uid_minimal, ", not the setups' ", run_full,
       " and ", recs$minimal$run_uid)
}
say("streams_parent joins full run %s and minimal run %s (built %s).", pv$run_uid_full, pv$run_uid_minimal,
    format(pv$built_at))

# ---- which lines to stage -------------------------------------------------------------------------------------
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
area_range <- eval(fm$area_range)
ct <- cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c")
vl <- read_csv("data/fdis/derived_parent/visits_link.csv", show_col_types = FALSE, guess_max = 1e5, col_types = ct)
vm <- read_csv("data/fdis/derived_minimal/visits_link.csv", show_col_types = FALSE, guess_max = 1e5, col_types = ct)
vs <- read_csv("data/fdis/derived_parent/visits_species.csv", show_col_types = FALSE, col_types = cols(site_visit = "c"))
ch <- vs |> filter(species_code == "CH", in_range %in% TRUE, status != "blocked") |> select(site_visit, present)
pop <- vl |>
  filter(edge_type %in% edge_stream, !(wb_river %in% TRUE), !(wb_wetland %in% TRUE), !(wb_lake %in% TRUE),
         !is.na(area_m2), area_m2 >= area_range[1], area_m2 <= area_range[2], barrier_dnstr_ch %in% FALSE) |>
  inner_join(ch, by = "site_visit") |>
  left_join(select(vm, site_visit, minimal_gradient = segment_gradient), by = "site_visit")
g <- as.matrix(pop[, c("segment_gradient", "minimal_gradient", "parent_gradient", "segment_fwa_gradient")])
if (anyNA(g)) stop(sum(!stats::complete.cases(g)), " population sites lack a gradient on some setup")
crosses <- Reduce(`|`, lapply(limits, function(t) apply(g <= t, 1, function(x) length(unique(x)) > 1)))
hit <- pop[crosses & pop$present %in% TRUE, ]
lines_staged <- sort(unique(hit$blue_line_key))
say("Population: %d chinook sites, %d with fish; %d sites cross a limit (%s) between two setups, %d of them with fish,",
    nrow(pop), sum(pop$present), sum(crosses), paste(limits, collapse = ", "), nrow(hit))
say("  on %d blue lines in %d groups: those lines are staged.", length(lines_staged),
    n_distinct(hit$watershed_group_code))
# the window on each line: the measures within window_m of any crossing site with fish on it
win <- hit |> group_by(blue_line_key) |>
  summarise(lo = pmax(0, min(downstream_route_measure) - window_m), hi = max(downstream_route_measure) + window_m,
            .groups = "drop")
win_sql <- paste(sprintf("(%d, %.3f, %.3f)", as.integer(win$blue_line_key), win$lo, win$hi), collapse = ", ")
q_seg <- function(s) sprintf("
  WITH w(blue_line_key, lo, hi) AS (VALUES %s)
  SELECT s.id_segment, s.watershed_group_code, s.blue_line_key, s.linear_feature_id, s.edge_type, s.gnis_name,
         s.stream_order, s.gradient, s.downstream_route_measure, s.upstream_route_measure, s.length_metre, s.geom
  FROM %s.streams s JOIN w ON s.blue_line_key = w.blue_line_key
  WHERE s.upstream_route_measure > w.lo AND s.downstream_route_measure < w.hi
  ORDER BY s.blue_line_key, s.downstream_route_measure, s.id_segment", win_sql, s)
seg_full <- sf::st_read(conn, query = q_seg(schema), quiet = TRUE)
seg_min <- sf::st_read(conn, query = q_seg(schema_min), quiet = TRUE)
par <- knw_parent_read(conn, schema, schema_min, keys = sf::st_drop_geometry(seg_full)[, c("watershed_group_code", "id_segment")])
i <- match(paste(seg_full$watershed_group_code, seg_full$id_segment), paste(par$wsg, par$id_segment))
if (anyNA(i)) stop(sum(is.na(i)), " staged full segments have no parent row")
seg_full$id_segment_minimal <- par$id_segment_minimal[i]
seg_full$parent_gradient <- par$gradient_minimal[i]
fwa <- sf::st_read(conn, quiet = TRUE, query = sprintf("
  WITH w(blue_line_key, lo, hi) AS (VALUES %s)
  SELECT f.linear_feature_id, f.watershed_group_code, f.blue_line_key, f.edge_type, f.gnis_name, f.stream_order,
         f.gradient, f.downstream_route_measure, f.upstream_route_measure, f.length_metre, f.geom
  FROM whse_basemapping.fwa_stream_networks_sp f JOIN w ON f.blue_line_key = w.blue_line_key
  WHERE f.upstream_route_measure > w.lo AND f.downstream_route_measure < w.hi
  ORDER BY f.blue_line_key, f.downstream_route_measure", win_sql))
# every population site on the staged lines, placed on its Atlas line at its measure
on_lines <- pop[pop$blue_line_key %in% lines_staged, ]
pts_sql <- paste(sprintf("('%s', %d, %.3f)", on_lines$site_visit, as.integer(on_lines$blue_line_key),
                         on_lines$downstream_route_measure), collapse = ", ")
sites <- sf::st_read(conn, quiet = TRUE, query = sprintf("
  WITH v(site_visit, blue_line_key, measure) AS (VALUES %s)
  SELECT v.site_visit, v.blue_line_key, v.measure, whse_basemapping.fwa_locatealong(v.blue_line_key, v.measure) AS geom
  FROM v ORDER BY v.site_visit", pts_sql))
# the map's group, by setup_compare.R's criterion (the most km where the four setups' verdicts are not the same), read
# from its GeoPackage
f_setups <- "data/compare/setups/CH_rear_setups.gpkg"
wsg_map <- sf::st_read(f_setups, quiet = TRUE, query = "
  SELECT watershed_group_code, sum(length_metre) AS m FROM segments WHERE pattern NOT IN ('every setup', 'none')
  GROUP BY watershed_group_code ORDER BY m DESC, watershed_group_code LIMIT 1")$watershed_group_code
# lakes of 10 ha or more and river polygons for the maps: within 2 km of each staged line's window, and the map's group
ext <- lapply(split(fwa, fwa$blue_line_key), function(x) sf::st_bbox(sf::st_buffer(sf::st_union(x), 2000)))
env <- paste(vapply(ext, function(b) sprintf("ST_MakeEnvelope(%.1f, %.1f, %.1f, %.1f, 3005)", b[["xmin"]], b[["ymin"]],
                                             b[["xmax"]], b[["ymax"]]), ""), collapse = ", ")
q_water <- function(tbl, extra) sprintf("
  SELECT '%1$s' AS kind, waterbody_key, area_ha, geom FROM whse_basemapping.%1$s
  WHERE (geom && ANY(ARRAY[%2$s]) OR watershed_group_code = '%3$s')%4$s", tbl, env, wsg_map, extra)
water <- sf::st_read(conn, quiet = TRUE, query = paste(q_water("fwa_lakes_poly", " AND area_ha >= 10"), "UNION ALL",
                                                       q_water("fwa_rivers_poly", ""), "ORDER BY 1, 2"))
water$kind <- sub("^fwa_(lakes|rivers)_poly$", "\\1", water$kind)
say("Map group (most km where the setups disagree, from %s): %s; %d lake and river polygons staged.", f_setups, wsg_map,
    nrow(water))
DBI::dbDisconnect(conn)
if (nrow(sites) != nrow(on_lines) || any(sf::st_is_empty(sites))) stop("not every site on the staged lines was placed")
say("Staged lines: %d full segments, %d minimal, %d Atlas lines, %d sites.", nrow(seg_full), nrow(seg_min), nrow(fwa),
    nrow(sites))

# ---- write ----------------------------------------------------------------------------------------------------
dir_part <- paste0(dir_out, ".part")
unlink(dir_part, recursive = TRUE)
dir.create(dir_part, recursive = TRUE)
put <- function(from, to) {
  dir.create(dirname(file.path(dir_part, to)), showWarnings = FALSE, recursive = TRUE)
  if (!file.copy(from, file.path(dir_part, to))) stop("could not copy ", from)
  tibble(path = to, source = from)
}
staged <- list()
for (i in seq_len(nrow(evidence))) {
  for (f in c("visits_link.csv", "visits_species.csv")) {
    staged[[length(staged) + 1]] <- put(file.path(evidence$dir[i], f), file.path("evidence", evidence$name[i], f))
  }
}
for (s in names(runs)[nzchar(runs)]) {
  keys_s <- if (s == "minimal") sub("_tune\\.csv$", "", list.files(dir_t(runs[[s]]), "_tune\\.csv$")) else key
  for (k in keys_s) {
    for (f in c(file.path(dir_t(runs[[s]]), paste0(k, c("_tune.csv", "_grades_record.csv"))),
                file.path(dir_c(runs[[s]]), paste0(k, "_compare.csv")))) {
      if (file.exists(f)) staged[[length(staged) + 1]] <- put(f, file.path("runs", runs[[s]], basename(f)))
    }
  }
}
staged[[length(staged) + 1]] <- put(f_setups, "setups/CH_rear_setups.gpkg")
f_lines <- file.path(dir_part, "lines.gpkg")
sf::st_write(seg_full, f_lines, layer = "full_segments", quiet = TRUE)
sf::st_write(seg_min, f_lines, layer = "minimal_segments", quiet = TRUE, append = TRUE)
sf::st_write(fwa, f_lines, layer = "fwa_lines", quiet = TRUE, append = TRUE)
sf::st_write(sites, f_lines, layer = "sites", quiet = TRUE, append = TRUE)
sf::st_write(water, f_lines, layer = "water", quiet = TRUE, append = TRUE)
staged[[length(staged) + 1]] <- tibble(path = "lines.gpkg", source = sprintf("database: %s, %s, whse_basemapping", schema, schema_min))
man <- bind_rows(staged)
man$md5 <- unname(tools::md5sum(file.path(dir_part, man$path)))
man$bytes <- file.size(file.path(dir_part, man$path))
man$commit <- commit
man$link_run_full <- run_full
man$link_run_minimal <- as.character(recs$minimal$run_uid)
write_csv(man, file.path(dir_part, "MANIFEST.csv"), na = "")
unlink(dir_out, recursive = TRUE)
if (!file.rename(dir_part, dir_out)) stop("could not move ", dir_part, " to ", dir_out)
say("")
say("Staged %d files in %s (%.0f MB):", nrow(man), dir_out, sum(man$bytes) / 1e6)
for (i in seq_len(nrow(man))) say("  %s %s <- %s", man$md5[i], man$path[i], man$source[i])
writeLines(log_lines, path_log)
message("Wrote ", path_log)
