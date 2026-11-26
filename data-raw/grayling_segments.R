# data-raw/grayling_segments.R
# ---------------------------------------------------------------------------
# What stream sizes and gradients the Williston grayling critical-habitat segments span, by life stage. Issue #140.
# FWCP's 2026 Upper Peace Arctic grayling synthesis (Hagen et al. 2026, `hagen_etal2026futureArctic`) maps 85
# critical-habitat segments in six Williston core areas, each with the life stages seen there (`LH_Stage`, or the
# 2026 layers `Arctic_Grayling_Streams_Adult` and `_Juvenile`) and the habitat it is critical for (`CRITICAL_H`).
# Its layer is published on EcoCat with the report. This reads each segment against the Freshwater Atlas lines it
# follows and reports, per life-stage group, the km and the length-weighted spread of gradient, MAD and channel
# width on those lines. Each line is counted once per group, however many of the group's segments overlap it (the
# layer's segments overlap: two of its life-stage layers redraw reaches the 2021 layer already holds).
#
# METHOD: an FWA line (`whse_basemapping.fwa_stream_networks_sp`) belongs to a segment when at least half its length
# lies within `buffer_m` of the segment. Each line's gradient is the whole Atlas line's (`fwa_gradient`, the tuning's
# gradient sensitivity; link's rules read their own segment's gradient), its MAD (`mad_pick`) comes from
# knw_link_flow() and its width (`cw_deploy`, the width link reads where nobody measured) from knw_link_width(), as
# the evidence build reads them. Connector lines (edge types 1400-1450), which carry their tributary's flow, and lines
# in a lake (`wb_any_lake`) or a reservoir of 100 ha or more (`wb_lake`) are counted and left out: the
# Williston Lake segment and lake reaches carry no stream gradient. Groups: a segment counts in every group its stage
# names (`Adult+Fry` in both adult and fry); "spawning" is a `CRITICAL_H` that names spawning without "possibly".
# Terms: the layer is an EcoCat download whose terms are not settled (inst/NOTICE.md, "Terms not yet settled"), so it
# stays in the ignored data/hagen_segments/ and only aggregates reach the log.
#
# INPUT:  data/hagen_segments/AG_Segments_merged.shp (unzipped from EcoCat r65150's
#         AG_Segments_merged_1784660602388_5C8FC7930F.zip; the script fetches it when absent); a database with
#         `whse_basemapping` and wet's `discharge` (PG* env vars or PGSERVICE)
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_grayling_segments.txt
# RUN:    PGSERVICE=<entry> Rscript data-raw/grayling_segments.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(sf) })
pkgload::load_all(quiet = TRUE)
sf::sf_use_s2(FALSE)

dir_seg <- "data/hagen_segments"
f_shp <- file.path(dir_seg, "AG_Segments_merged.shp")
url_zip <- "https://a100.gov.bc.ca/pub/acat/documents/r65150/AG_Segments_merged_1784660602388_5C8FC7930F.zip"
buffer_m <- 25
path_log <- .knw_free_path(file.path("scripts/logs/habitat",
                                     paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_grayling_segments.txt")))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

if (!file.exists(f_shp)) {
  dir.create(dir_seg, showWarnings = FALSE, recursive = TRUE)
  zf <- file.path(dir_seg, "AG_Segments.zip")
  r <- curl::curl_fetch_disk(url_zip, zf)
  if (r$status_code != 200L) stop("EcoCat answered ", r$status_code, " for ", url_zip, call. = FALSE)
  utils::unzip(zf, exdir = dir_seg)
}
seg <- st_read(f_shp, quiet = TRUE)
if (is.na(st_crs(seg)$epsg) || st_crs(seg)$epsg != 3005L) stop("the layer is not in BC Albers (EPSG:3005)")
seg <- seg |>
  transmute(seg_id = row_number(), core_area = CORE_AREA, layer,
            stage = coalesce(LH_Stage, Life_Stage), critical = CRITICAL_H) |>
  st_zm()
md5_shp <- unname(tools::md5sum(f_shp))
git_out <- function(args) {
  out <- suppressWarnings(system2("git", args, stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(args, collapse = " "), " failed", call. = FALSE)
  out
}
head_sha <- substr(git_out(c("rev-parse", "HEAD")), 1, 7)
dirty <- git_out(c("status", "--porcelain", "--untracked-files=no", "--", "data-raw/grayling_segments.R", "R"))
if (length(dirty)) head_sha <- paste0(head_sha, " with uncommitted changes to ", paste(trimws(dirty), collapse = ", "))
say("Grayling critical-habitat segments (Hagen et al. 2026), knowledge#140, knowledge %s. Layer md5 %s: %d segments, %.0f km.",
    head_sha, substr(md5_shp, 1, 8), nrow(seg), sum(as.numeric(st_length(seg))) / 1000)
block("Segments by stage as recorded", seg |> st_drop_geometry() |> count(layer, stage))

if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")
con <- DBI::dbConnect(RPostgres::Postgres())
tmp <- "tmp_grayling_segments"
DBI::dbWriteTable(con, tmp, data.frame(seg_id = seg$seg_id, wkt = st_as_text(st_geometry(seg))), temporary = TRUE,
                  overwrite = TRUE)
hits <- DBI::dbGetQuery(con, sprintf("
  WITH s AS (SELECT seg_id, ST_SetSRID(ST_GeomFromText(wkt), 3005) AS geom FROM %s),
  b AS (SELECT seg_id, ST_Buffer(geom, %f) AS geom FROM s)
  SELECT b.seg_id, f.linear_feature_id, f.edge_type, f.length_metre
  FROM b JOIN whse_basemapping.fwa_stream_networks_sp f ON ST_Intersects(f.geom, b.geom)
  WHERE ST_Length(ST_Intersection(ST_Force2D(f.geom), b.geom)) >= 0.5 * ST_Length(ST_Force2D(f.geom))
  ORDER BY b.seg_id, f.linear_feature_id", tmp, buffer_m))
hits$linear_feature_id <- as.numeric(hits$linear_feature_id)
say("FWA lines matched (at least half within %g m of a segment): %d lines on %d of %d segments (%.0f km, each line once).",
    buffer_m, n_distinct(hits$linear_feature_id), n_distinct(hits$seg_id), nrow(seg),
    sum(distinct(hits, linear_feature_id, length_metre)$length_metre) / 1000)

ids <- unique(hits$linear_feature_id)
fl <- knw_link_flow(con, ids)
wd <- knw_link_width(con, ids)
block("Width model control (knw_link_width)", wd$control)
lines <- hits |>
  left_join(fl |> select(linear_feature_id, fwa_gradient, mad_pick), by = "linear_feature_id") |>
  left_join(wd$widths |> select(linear_feature_id, cw_deploy, wb_lake, wb_any_lake, wb_river), by = "linear_feature_id") |>
  left_join(st_drop_geometry(seg), by = "seg_id")
# connectors (edge types 1400-1450) join a tributary to the river it enters and carry the tributary's flow: they lie
# along the segment without being the river it maps (code-check round 3)
conn <- lines$edge_type >= 1400 & lines$edge_type < 1500
ck <- distinct(lines[conn, ], linear_feature_id, length_metre)
say("Connector lines left out: %d lines, %.0f km.", nrow(ck), sum(ck$length_metre) / 1000)
lines <- lines[!conn, ]
in_lake <- lines$wb_lake %in% TRUE | lines$wb_any_lake %in% TRUE
lk <- distinct(lines[in_lake, ], linear_feature_id, length_metre)
say("Lines in a lake or reservoir polygon left out: %d lines, %.0f km.", nrow(lk), sum(lk$length_metre) / 1000)
lines <- lines[!in_lake, ]

groups <- list(
  fry = grepl("fry", lines$stage, ignore.case = TRUE),
  juvenile = grepl("juvenile", lines$stage, ignore.case = TRUE),
  adult = grepl("adult", lines$stage, ignore.case = TRUE),
  spawning = grepl("spawning", lines$critical, ignore.case = TRUE) & !grepl("possibly spawning", lines$critical, ignore.case = TRUE),
  possibly_spawning = grepl("possibly spawning", lines$critical, ignore.case = TRUE),
  all = rep(TRUE, nrow(lines)))
wq <- function(x, w, p) {
  ok <- !is.na(x)
  if (!any(ok)) return(NA_real_)
  x <- x[ok]; w <- w[ok]; o <- order(x); cw <- cumsum(w[o]) / sum(w)
  x[o][which(cw >= p)[1]]
}
share <- function(ok, w) round(100 * sum(w[ok %in% TRUE]) / sum(w), 1)
summ <- bind_rows(lapply(names(groups), function(g) {
  n_seg <- n_distinct(lines$seg_id[groups[[g]]])   # before the dedupe, which keeps one segment per line
  d <- distinct(lines[groups[[g]], ], linear_feature_id, .keep_all = TRUE)   # a line once per group
  w <- d$length_metre
  tibble(group = g, segments = n_seg, km = round(sum(w) / 1000),
         grad_p50 = round(100 * wq(d$fwa_gradient, w, 0.5), 2), grad_p90 = round(100 * wq(d$fwa_gradient, w, 0.9), 2),
         pct_km_grad_le_2.49 = share(d$fwa_gradient <= 0.0249, w), pct_km_grad_le_3.49 = share(d$fwa_gradient <= 0.0349, w),
         pct_km_grad_le_5.49 = share(d$fwa_gradient <= 0.0549, w),
         mad_p10 = signif(wq(d$mad_pick, w, 0.1), 2), mad_p50 = signif(wq(d$mad_pick, w, 0.5), 2),
         pct_km_mad_ge_0.021 = share(d$mad_pick >= 0.021, w), pct_km_mad_ge_0.2 = share(d$mad_pick >= 0.2, w),
         width_p10 = round(wq(d$cw_deploy, w, 0.1), 1), width_p50 = round(wq(d$cw_deploy, w, 0.5), 1),
         pct_km_width_ge_1.5 = share(d$cw_deploy >= 1.5, w), pct_km_width_ge_4 = share(d$cw_deploy >= 4, w),
         pct_km_no_width = share(is.na(d$cw_deploy), w), pct_km_river_polygon = share(d$wb_river, w))
}))
block(paste("By life-stage group, length-weighted over the FWA lines each group's segments follow (gradient in %,",
            "MAD in m3/s, width in m)"), summ)
DBI::dbDisconnect(con)
writeLines(log_lines, path_log)
say("Wrote %s.", path_log)
