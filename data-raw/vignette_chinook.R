# data-raw/vignette_chinook.R
# ---------------------------------------------------------------------------
# The data `vignettes/chinook_rearing.Rmd` reads, so the article builds with no database: the chinook
# rearing tuning's saved tables, its stability checks, the comparison's tables, and one group (BULK,
# the Bulkley) drawn on link's segments with its floodplain shaded by grade. Issue #62.
#
# WHY / DESIGN NOTES:
#   - THE TABLES ARE COPIED, NOT RECOMPUTED. Every number the article prints comes from a table 0320 or
#     0330 wrote; this script selects the CH rearing rows and saves them in one list. `meta$md5` records
#     each tracked source's md5 at write time (for thresholds.csv and floodplain.csv, which hold every
#     species, the md5 of their CH rearing rows), and tests/testthat/test-vignette-data.R fails when a source
#     has moved on, so a rerun of 0320 or 0330 cannot leave the article quoting the run before it.
#   - SEEDS AND FOLDS. 0320 writes <key>_{seeds,honest}.csv from #62 on; this run predates that, so they
#     come from the ignored score.rds when the csv is absent, and either way must print exactly as the
#     tuning log's "more seeds" and "nested selection" blocks.
#   - THE MAP is 0330's three panels for BULK, rebuilt from the same inputs: the saved segments joined to
#     fresh_default.streams geometry, lakes >= 10 ha and rivers from whse_basemapping, and the floodplain
#     cells shaded by the owning segment's grade (0330's fp_cells, built the same way). Geometry is
#     simplified at 10 m (a 4 in panel at 150 dpi is about 250 m a pixel); lengths stay the segments' own.
#     The raster is stored as grade x 100 in INT1U with 255 as nodata, so the article divides by 100.
#
# INPUT:  data/tune/CH_rear_{tune,summary,curves,groups}.csv, data/tune/CH_rear_{seeds,honest}.csv or
#         data/tune/CH_rear_score.rds (ignored), data/thresholds.csv,
#         data/compare/CH_rear_{compare,change,checks}.csv, data/compare/floodplain.csv,
#         data/compare/CH_rear_segments.rds (ignored; 0330), the tuning log and the evidence build ledger
#         in scripts/logs/habitat/, the catalog's bulk floodplain.gpkg (data/compare/catalog/, fetched
#         from the public bucket when absent, as 0330 does), fwapg database (PG* env vars):
#         fresh_default.streams, whse_basemapping.fwa_{lakes,rivers}_poly. Needs flooded with #89.
# OUTPUT: inst/vignette-data/chinook_rearing.rds   the tables and `meta`, one named list
#         inst/vignette-data/bulk_segments.rds     BULK accessible CH segments, sf, EPSG:3005
#         inst/vignette-data/bulk_water.rds        BULK lakes >= 10 ha and rivers, sf, EPSG:3005
#         inst/vignette-data/bulk_fp_grade.tif     BULK floodplain cells by the owning segment's grade x 100
# RUN:    Rscript data-raw/vignette_chinook.R   (from the repo root, after any 0320 or 0330 rerun)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

key <- "CH_rear"
wsg <- "BULK"
dir_out <- "inst/vignette-data"
catalog_bucket <- "https://stac-floodplains-bc.s3.us-west-2.amazonaws.com"
dir_cat <- "data/compare/catalog"
path_log <- "scripts/logs/habitat/20261017_tune_run-bt_ch_co_st.txt"
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
dir.create(dir_cat, showWarnings = FALSE, recursive = TRUE)
rd <- function(f, ...) read_csv(f, show_col_types = FALSE, guess_max = 1e5, ...)

# ---- the saved tables -------------------------------------------------------------------------
src <- c(tune = sprintf("data/tune/%s_tune.csv", key), summary = sprintf("data/tune/%s_summary.csv", key),
         curves = sprintf("data/tune/%s_curves.csv", key), groups = sprintf("data/tune/%s_groups.csv", key),
         thresholds = "data/thresholds.csv", compare = sprintf("data/compare/%s_compare.csv", key),
         change = sprintf("data/compare/%s_change.csv", key), checks = sprintf("data/compare/%s_checks.csv", key),
         floodplain = "data/compare/floodplain.csv", log = path_log)
# the evidence build the tuning ran on is the one its log names on its first line, not the newest on disk
log1 <- readLines(path_log, n = 1)
ledger <- sub("^.*Evidence build (\\S+) on link run.*$", "\\1", log1)
if (identical(ledger, log1) || !file.exists(ledger)) stop("the tuning log's first line names no evidence ledger on disk: ", log1)
src <- c(src, ledger = ledger)
missing <- src[!file.exists(src)]
if (length(missing)) stop("missing inputs: ", paste(missing, collapse = ", "))

out <- list(
  tune = rd(src[["tune"]]),
  summary = rd(src[["summary"]]),
  curves = rd(src[["curves"]]),
  groups = rd(src[["groups"]]),
  thresholds = rd(src[["thresholds"]]) |> filter(species_code == "CH", stage == "rear"),
  compare = rd(src[["compare"]], col_types = cols(watershed_group_code = "c", species_code = "c", stage = "c",
                                                  default_rule = "c", tuned_rule = "c", .default = "d")),
  change = rd(src[["change"]]),
  checks = rd(src[["checks"]]),
  floodplain = rd(src[["floodplain"]]) |> filter(species_code == "CH", stage == "rear")
)
if (nrow(out$tune) == 0 || nrow(out$summary) != 1 || nrow(out$thresholds) == 0) stop("CH rearing rows missing")
if (!"ALL" %in% out$compare$watershed_group_code || !wsg %in% out$compare$watershed_group_code) stop("compare lacks ALL or ", wsg)
if (!wsg %in% out$floodplain$watershed_group_code) stop("floodplain.csv has no CH rearing rows for ", wsg)
rec <- out$tune$rule[out$tune$recommended %in% TRUE]
if (length(rec) != 1 || !identical(rec, unique(out$thresholds$rule))) {
  stop("the tune table's recommended rule is not the thresholds table's CH_rear rule")
}

# seeds and folds: the csv 0320 writes from #62, or the score object this run left
f_seeds <- sprintf("data/tune/%s_seeds.csv", key)
f_honest <- sprintf("data/tune/%s_honest.csv", key)
f_score <- sprintf("data/tune/%s_score.rds", key)
if (file.exists(f_seeds) && file.exists(f_honest)) {
  out$seeds <- rd(f_seeds) |> select(-species_code, -stage)
  out$honest <- rd(f_honest) |> select(-species_code, -stage)
  src <- c(src, seeds = f_seeds, honest = f_honest)
  stab_from <- "csv"
} else if (file.exists(f_score)) {
  sc <- readRDS(f_score)
  out$seeds <- as_tibble(sc$seeds)
  out$honest <- as_tibble(sc$honest)
  stab_from <- f_score
} else {
  stop("neither ", f_seeds, " and ", f_honest, " nor ", f_score, ": rerun scripts/0320")
}
# must print as the tuning log's blocks do (0320's block(): print(as.data.frame(x), row.names = FALSE))
log_txt <- readLines(src[["log"]])
in_log <- function(title, x) {
  at <- which(log_txt == paste("##", title))
  if (length(at) != 1) stop("the tuning log has ", length(at), " '", title, "' blocks")
  want <- capture.output(print(as.data.frame(x), row.names = FALSE))
  identical(log_txt[at + seq_along(want)], want)
}
if (!in_log(paste(key, "more seeds"), out$seeds)) stop("the seeds table differs from the tuning log's")
if (!in_log(paste(key, "nested selection"), out$honest)) stop("the nested-selection table differs from the tuning log's")

# ---- meta: provenance and the scoring's constants -------------------------------------------------
led <- rd(ledger, col_types = cols(.default = "c"))
gl <- grep(sprintf("^%s grades:", key), log_txt, value = TRUE)
if (length(gl) != 1) stop("the tuning log has ", length(gl), " '", key, " grades' lines")
num_of <- function(pat) as.numeric(sub(pat, "\\1", regmatches(gl, regexpr(pat, gl))))
fm <- formals(knw_tune_run)
fr <- formals(knw_rule_in)
out$meta <- list(
  written = format(Sys.Date()),
  link_run_uid = led$note[led$step == "link_run_uid"],
  link_sha = strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]][1],
  evidence_version = unique(out$thresholds$evidence_version),
  grade = list(groups = num_of("grades: ([0-9]+) groups"), segments = num_of("segments=([0-9]+)"),
               accessible = num_of("accessible=([0-9]+)"), graded = num_of("graded=([0-9]+)"),
               no_size = num_of("no_size=([0-9]+)"), reference_rate = num_of("reference rate ([0-9.]+)"),
               log = path_log),
  spec = list(cols = eval(fr$cols), src = eval(fm$src), edge_stream = eval(fm$edge_stream),
              area_range = eval(fm$area_range), seed = eval(fm$seed), folds = eval(fm$folds),
              seeds_more = eval(fm$seeds_more), n_boot = eval(fm$n_boot), d_floor = eval(fm$d_floor),
              min_wsg = eval(fm$min_wsg), power_wsg = eval(fm$power_wsg)),
  stability_from = stab_from,
  map_group = wsg,
  # whole files, except the two that hold every species, which are hashed on their CH rearing rows
  md5 = tools::md5sum(unname(src[!names(src) %in% c("thresholds", "floodplain")])) |>
    stats::setNames(unname(src[!names(src) %in% c("thresholds", "floodplain")])),
  md5_rows = vapply(unname(src[c("thresholds", "floodplain")]), .knw_rows_md5, character(1),
                    species_code = "CH", stage = "rear")
)
if (!identical(led$note[led$step == "link_run_uid"], sub("^.*on link run (\\S+) .*$", "\\1", log1))) {
  stop("the evidence ledger's link run differs from the tuning log's")
}
if (!identical(out$meta$grade$groups, nrow(out$compare) - 1)) {
  stop("the grade's groups (", out$meta$grade$groups, ") differ from compare's (", nrow(out$compare) - 1, ")")
}

# ---- BULK on link's segments -----------------------------------------------------------------
seg_all <- readRDS(sprintf("data/compare/%s_segments.rds", key))
s <- seg_all |> filter(watershed_group_code == wsg)
rm(seg_all)
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
  "SELECT id_segment, geom FROM fresh_default.streams WHERE watershed_group_code = '%s'", wsg)), drop = TRUE)
geom$id_segment <- as.numeric(geom$id_segment)
water <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf("
  SELECT waterbody_key, 'lake' AS kind, geom FROM whse_basemapping.fwa_lakes_poly WHERE watershed_group_code = '%1$s' AND area_ha >= 10
  UNION ALL SELECT waterbody_key, 'river', geom FROM whse_basemapping.fwa_rivers_poly WHERE watershed_group_code = '%1$s'", wsg)), drop = TRUE)
DBI::dbDisconnect(conn)
# as 0330 builds `sg`: every segment of the group, because the floodplain join needs them all
sg <- geom |> inner_join(s |> transmute(id_segment, blue_line_key, accessible, stream_order, grade, grade_class,
                                        length_metre, flag_default = rearing_default, flag_tuned = rearing_tuned),
                         by = "id_segment")
if (nrow(sg) != nrow(s)) stop(nrow(s) - nrow(sg), " saved segments have no geometry in fresh_default.streams")

# the floodplain: the catalog item, cached as 0330 caches it
gpkg <- file.path(dir_cat, paste0(tolower(wsg), "_floodplain.gpkg"))
if (file.exists(gpkg) && file.size(gpkg) == 0) unlink(gpkg)
if (!file.exists(gpkg)) {
  part <- paste0(gpkg, ".part")
  h <- curl::curl_fetch_disk(sprintf("%s/%s_all_ff04/floodplain.gpkg", catalog_bucket, tolower(wsg)), part,
                             handle = curl::new_handle(timeout = 600, followlocation = TRUE))
  if (h$status_code != 200) { unlink(part); stop("catalog item ", wsg, ": HTTP ", h$status_code) }
  if (!file.rename(part, gpkg)) stop("could not move the download of ", wsg, " into place")
}
src_local <- c(segments = sprintf("data/compare/%s_segments.rds", key), floodplain_gpkg = gpkg)
if (stab_from != "csv") src_local <- c(src_local, score = f_score)
out$meta$md5_local <- tools::md5sum(unname(src_local)) |> stats::setNames(unname(src_local))

fp <- knw_floodplain_ha(gpkg, sg, c("flag_default", "flag_tuned", "accessible"))
want <- out$floodplain |> filter(watershed_group_code == wsg)
got <- fp$summary |> mutate(rule = unname(c(flag_default = "default", flag_tuned = "tuned", accessible = "accessible")[flag]))
cmp <- inner_join(want, got, by = "rule", suffix = c("_csv", "_now"))
if (nrow(cmp) != 3 || any(abs(cmp$ha_csv - cmp$ha_now) > 0.01) || any(abs(cmp$graded_ha_csv - cmp$graded_ha_now) > 0.01)) {
  stop("the floodplain join no longer reproduces floodplain.csv's ", wsg, " rows")
}
# the cells by the owning segment's grade, as 0330 builds fp_cells
own <- fp$segments
bl <- sf::st_read(gpkg, layer = "all_ff04_by_blue_line_key", quiet = TRUE)
fpp <- sf::st_read(gpkg, layer = "all_ff04", quiet = TRUE)
bb <- sf::st_bbox(fpp)
tmpl <- terra::rast(xmin = floor(bb[["xmin"]] / 30) * 30, xmax = ceiling(bb[["xmax"]] / 30) * 30,
                    ymin = floor(bb[["ymin"]] / 30) * 30, ymax = ceiling(bb[["ymax"]] / 30) * 30,
                    resolution = 30, crs = "EPSG:3005")
valleys <- terra::rasterize(terra::vect(fpp), tmpl, field = 1L, background = 0L, touches = FALSE)
bl$blue_line_key <- as.numeric(bl$blue_line_key)
claim <- own$blue_line_key %in% bl$blue_line_key
j <- flooded::fl_valley_join(valleys, bl, own[claim, ], group = "blue_line_key", cols = "accessible")
rg <- terra::rast(valleys)
terra::values(rg) <- NA
rg[j$nearest$cell] <- round(own$grade[claim][j$nearest$seg] * 100)
graded_ha <- sum(!is.na(terra::values(rg, mat = FALSE))) * 0.09
acc <- want |> filter(rule == "accessible")
if (abs(graded_ha - (acc$ha - acc$ha_grade_na)) > 1) {
  stop(sprintf("graded floodplain cells give %.1f ha, floodplain.csv's accessible less ungraded %.1f", graded_ha,
               acc$ha - acc$ha_grade_na))
}

# ---- write -------------------------------------------------------------------------------------
seg_out <- sg |>
  filter(accessible %in% TRUE) |>
  select(id_segment, blue_line_key, stream_order, accessible, grade, grade_class, flag_default, flag_tuned, length_metre) |>
  sf::st_simplify(preserveTopology = TRUE, dTolerance = 10)
cmp_w <- out$compare |> filter(watershed_group_code == wsg)
km <- function(f) sum(seg_out$length_metre[seg_out[[f]] %in% TRUE]) / 1000
if (abs(km("flag_default") - cmp_w$default_km) > 0.01 || abs(km("flag_tuned") - cmp_w$tuned_km) > 0.01) {
  stop("the saved segments' km by rule differ from compare's ", wsg, " row")
}
water_out <- water |> select(waterbody_key, kind) |> sf::st_simplify(preserveTopology = TRUE, dTolerance = 10)
water_out <- water_out[!sf::st_is_empty(water_out), ]

saveRDS(out, file.path(dir_out, "chinook_rearing.rds"), compress = "xz")
saveRDS(seg_out, file.path(dir_out, "bulk_segments.rds"), compress = "xz")
saveRDS(water_out, file.path(dir_out, "bulk_water.rds"), compress = "xz")
names(rg) <- "grade_x100"
terra::varnames(rg) <- "grade_x100"
terra::longnames(rg) <- "floodplain cell grade x 100"
terra::writeRaster(rg, file.path(dir_out, "bulk_fp_grade.tif"), datatype = "INT1U", NAflag = 255,
                   gdal = c("COMPRESS=DEFLATE"), overwrite = TRUE)
for (f in list.files(dir_out, full.names = TRUE)) message(sprintf("%-45s %8.2f MB", f, file.size(f) / 1e6))
message(sprintf("%s: %.2f MB in all.", dir_out, sum(file.size(list.files(dir_out, full.names = TRUE))) / 1e6))
