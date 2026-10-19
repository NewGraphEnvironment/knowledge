# data-raw/vignette_chinook.R
# ---------------------------------------------------------------------------
# The data `vignettes/chinook_rearing.Rmd` reads, so the article builds with no database: the chinook
# rearing tuning's saved tables, its stability checks, the fitted flow-by-distance surface, the
# comparison's tables, and one group (BULK, the Bulkley) on link's segments for the map. Issue #62.
#
# WHY / DESIGN NOTES:
#   - THE TABLES ARE COPIED, NOT RECOMPUTED. Every number the article prints comes from a table 0320 or
#     0330 wrote; this script selects the CH rearing rows and saves them in one list. `meta$md5` records
#     each tracked source's md5 at write time (for thresholds.csv, which holds every species, the md5 of
#     its CH rearing rows), and tests/testthat/test-vignette-data.R fails when a source
#     has moved on, so a rerun of 0320 or 0330 cannot leave the article quoting the run before it.
#   - SEEDS AND FOLDS. 0320 writes <key>_{seeds,honest}.csv from #62 on; this run predates that, so they
#     come from the ignored score.rds when the csv is absent, and either way must print exactly as the
#     tuning log's "more seeds" and "nested selection" blocks.
#   - THE MAP is 0330's rules panel for BULK, rebuilt from the same inputs: the saved segments joined to
#     fresh_default.streams geometry, and lakes >= 10 ha and rivers from whse_basemapping. Geometry is
#     simplified at 10 m (a 4 in panel at 150 dpi is about 250 m a pixel at the group's extent, and the
#     zoomed window is 12 km); lengths stay the segments' own. Each segment also carries what the two rules
#     read (edge type, link's segment gradient and channel width, wet's MAD and the walk distance to the
#     pick's river, measured only on accessible stream-edge segments inside the gradient maximum that fail the
#     size test, as knw_grade_species() walks them, wetland lines included), each rule's verdict from the
#     habitat test alone (before the hand-entered reaches and the connectivity pass), and whether the segment
#     lies in any waterbody, for the labelled examples. The floodplain is not in the article (#62's
#     second draft); it is in research/habitat_thresholds_tuned.md.
#
# INPUT:  data/tune/CH_rear_{tune,summary,curves,groups}.csv, data/tune/grad_ext/CH_rear_{by_grad,summary,seeds}.csv
#         (0322, #67), data/tune/CH_rear_{seeds,honest}.csv or
#         data/tune/CH_rear_score.rds (ignored), data/thresholds.csv,
#         data/compare/CH_rear_{compare,change,checks}.csv, data/compare/CH_rear_segments.rds (ignored;
#         0330), data/tune/CH_rear_curve.rds (ignored; 0320), the tuning log and the evidence build ledger in
#         scripts/logs/habitat/, fwapg database (PG* env vars): fresh_default.streams,
#         whse_basemapping.fwa_{lakes,rivers}_poly.
# OUTPUT: inst/vignette-data/chinook_rearing.rds   the tables and `meta`, one named list
#         inst/vignette-data/bulk_segments.rds     BULK accessible CH segments, sf, EPSG:3005
#         inst/vignette-data/bulk_water.rds        BULK lakes >= 10 ha and rivers, sf, EPSG:3005
# RUN:    Rscript data-raw/vignette_chinook.R   (from the repo root, after any 0320, 0322 or 0330 rerun)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

key <- "CH_rear"
wsg <- "BULK"
dir_out <- "inst/vignette-data"
path_log <- "scripts/logs/habitat/20261017_tune_run-bt_ch_co_st.txt"
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
rd <- function(f, ...) read_csv(f, show_col_types = FALSE, guess_max = 1e5, ...)

# ---- the saved tables -------------------------------------------------------------------------
src <- c(tune = sprintf("data/tune/%s_tune.csv", key), summary = sprintf("data/tune/%s_summary.csv", key),
         curves = sprintf("data/tune/%s_curves.csv", key), groups = sprintf("data/tune/%s_groups.csv", key),
         thresholds = "data/thresholds.csv", compare = sprintf("data/compare/%s_compare.csv", key),
         change = sprintf("data/compare/%s_change.csv", key), checks = sprintf("data/compare/%s_checks.csv", key),
         log = path_log)
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
  checks = rd(src[["checks"]])
)
if (nrow(out$tune) == 0 || nrow(out$summary) != 1 || nrow(out$thresholds) == 0) stop("CH rearing rows missing")
if (!"ALL" %in% out$compare$watershed_group_code || !wsg %in% out$compare$watershed_group_code) stop("compare lacks ALL or ", wsg)
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

# the CH rearing ladder extended to 30 % (#67, scripts/0322): the best rule per gradient maximum, and that run's
# summary; the published rule stays CH_rear_v1, so these sit beside the main reading, never in place of it
f_ge <- c(grad_ext = sprintf("data/tune/grad_ext/%s_by_grad.csv", key),
          grad_ext_summary = sprintf("data/tune/grad_ext/%s_summary.csv", key),
          grad_ext_seeds = sprintf("data/tune/grad_ext/%s_seeds.csv", key))
if (!all(file.exists(f_ge))) stop("missing ", paste(f_ge[!file.exists(f_ge)], collapse = ", "), ": run scripts/0322")
out$grad_ext <- rd(f_ge[["grad_ext"]]) |> select(-species_code, -stage)
out$grad_ext_summary <- rd(f_ge[["grad_ext_summary"]])
out$grad_ext_seeds <- rd(f_ge[["grad_ext_seeds"]]) |> select(-species_code, -stage)
if (!identical(sort(as.integer(out$grad_ext_seeds$seed)), sort(as.integer(out$seeds$seed)))) stop("the extended run's seeds differ from the main run's")
if (!all(sort(unique(out$tune$grad_max)) %in% out$grad_ext$grad_max)) stop("the extended ladder lacks a gradient the main one has")
# the same population as the main reading, and one run's two tables
pop <- c("visits_in", "detections", "groups", "groups_both")
if (!isTRUE(all.equal(unlist(out$grad_ext_summary[pop]), unlist(out$summary[pop])))) stop("the extended run scored another population")
if (!identical(out$grad_ext$best_rule[out$grad_ext$ddev_best == 0], out$grad_ext_summary$rule_best)) {
  stop("the per-gradient table and the summary are not one run's")
}
src <- c(src, f_ge)

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
  # whole files, except thresholds.csv, which holds every species and is hashed on its CH rearing rows
  md5 = tools::md5sum(unname(src[names(src) != "thresholds"])) |> stats::setNames(unname(src[names(src) != "thresholds"])),
  md5_rows = vapply(unname(src["thresholds"]), .knw_rows_md5, character(1), species_code = "CH", stage = "rear")
)
if (!identical(led$note[led$step == "link_run_uid"], sub("^.*on link run (\\S+) .*$", "\\1", log1))) {
  stop("the evidence ledger's link run differs from the tuning log's")
}
if (!identical(out$meta$grade$groups, nrow(out$compare) - 1)) {
  stop("the grade's groups (", out$meta$grade$groups, ") differ from compare's (", nrow(out$compare) - 1, ")")
}

# ---- the fitted surface: the chance of a catch by flow and distance together --------------------------
# the curves table holds one variable at a time with the others at reference values (distance at the 50 km
# cap); the surface shows how flow and distance act together, at the curves' reference gradient
f_curve <- sprintf("data/tune/%s_curve.rds", key)
cr <- readRDS(f_curve)$curve
rec_row <- out$tune[out$tune$recommended %in% TRUE, ]
if (any(c(0.1, 0.3, 0.75, 2) >= cr$q)) stop("the surface's flows must stay below the river size ", cr$q)
grad_ref <- min(rec_row$grad_max, 0.2) / 2   # knw_tune_curve()'s reference gradient
# flows below the river size only: a stream of q m³/s or more is itself the river, at 0 m, so a row above q
# would read the surface where no visit lies (#62 draft 2, review round 3)
grid <- expand.grid(size = c(0.1, 0.3, 0.75, 2), dist_m = c(100, 300, 1000, 3000, 10000, cr$dist_cap_m))
grid$gradient <- grad_ref
grid$accessible <- TRUE
gr <- knw_grade(cr, grid, cols = c(size = "size", grad = "gradient", dist = "dist_m"))
out$surface <- tibble::as_tibble(grid[c("size", "dist_m", "gradient")]) |> mutate(rate = gr$grades$rate)
if (anyNA(out$surface$rate)) stop("the surface has missing rates")
out$meta$curve_ref <- list(gradient = grad_ref, dist_cap_m = cr$dist_cap_m, size = rec_row$size_min,
                           q = cr$q, log_area = cr$ref$log_area, data_set = cr$ref$data_set, era = cr$ref$era)

# ---- BULK on link's segments -----------------------------------------------------------------
seg_all <- readRDS(sprintf("data/compare/%s_segments.rds", key))
s <- seg_all |> filter(watershed_group_code == wsg)
rm(seg_all)
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
geom <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
  "SELECT id_segment, waterbody_key, geom FROM fresh_default.streams WHERE watershed_group_code = '%s'", wsg)),
  drop = TRUE)
geom$id_segment <- as.numeric(geom$id_segment)
water <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf("
  SELECT waterbody_key, 'lake' AS kind, geom FROM whse_basemapping.fwa_lakes_poly WHERE watershed_group_code = '%1$s' AND area_ha >= 10
  UNION ALL SELECT waterbody_key, 'river', geom FROM whse_basemapping.fwa_rivers_poly WHERE watershed_group_code = '%1$s'", wsg)), drop = TRUE)
DBI::dbDisconnect(conn)
# as 0330 builds `sg`
sg <- geom |> inner_join(s |> transmute(id_segment, blue_line_key, accessible, stream_order, grade, grade_class,
                                        length_metre, flag_default = rearing_default, flag_tuned = rearing_tuned,
                                        edge_type, gradient, channel_width, mad = knw_size, dist_m = knw_dist,
                                        pre_default = rearing_pre_default, pre_tuned = rearing_pre_tuned),
                         by = "id_segment")
sg$in_waterbody <- !is.na(sg$waterbody_key)
if (nrow(sg) != nrow(s)) stop(nrow(s) - nrow(sg), " saved segments have no geometry in fresh_default.streams")

src_local <- c(segments = sprintf("data/compare/%s_segments.rds", key), curve = f_curve)
if (stab_from != "csv") src_local <- c(src_local, score = f_score)
out$meta$md5_local <- tools::md5sum(unname(src_local)) |> stats::setNames(unname(src_local))

# ---- write -------------------------------------------------------------------------------------
seg_out <- sg |>
  filter(accessible %in% TRUE) |>
  select(id_segment, blue_line_key, stream_order, accessible, grade, grade_class, flag_default, flag_tuned, length_metre,
         edge_type, gradient, channel_width, mad, dist_m, pre_default, pre_tuned, in_waterbody) |>
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
unlink(file.path(dir_out, "bulk_fp_grade.tif"))   # the first draft's floodplain raster
for (f in list.files(dir_out, full.names = TRUE)) message(sprintf("%-45s %8.2f MB", f, file.size(f) / 1e6))
message(sprintf("%s: %.2f MB in all.", dir_out, sum(file.size(list.files(dir_out, full.names = TRUE))) / 1e6))
