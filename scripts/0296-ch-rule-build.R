# scripts/0296-ch-rule-build.R
# ---------------------------------------------------------------------------
# What a CH rearing rule needs at each FDIS visit from 0294: the downstream distance to the
# first river of each size on each wet flow source, link's channel width and its source, the
# waterbody tests in link's CH rear predicate, link's own segment and its stored CH flags where
# fresh_default classified CH, and the visit's hydrologic zone. Issue #54. Consumer:
# scripts/0297-ch-rule-tune.R.
#
# WHY / DESIGN NOTES (planning/active for #54 until archived; results in
# research/chinook_rearing_tuned.md):
#   - SAME VISITS AS #52. Every row of 0294's ch_mad_visits.csv is kept: 0297 applies 0295's
#     analysis filters, so this script drops nothing and its ledger only counts.
#   - WALKS: scripts/sql/ch_dist_profile.sql, the path of #52's ch_dist_large.sql for an array of
#     river sizes `q_grid`, on `pick` (wet's default source per segment) and on each source alone.
#     Every visit is walked, not only small ones: a width floor can fail a visit of any MAD. At
#     10 m3/s on `pick` the walk must reproduce 0294's on every 0294 start (stops otherwise).
#     Each found target records whether it lies in a lake, and whether it is on a regulated reach
#     (0294's CABD rule: below a dam with a reservoir or >= 10 % regulation).
#   - CHANNEL WIDTH is link's: lnk_pipeline_prepare() joins
#     whse_basemapping.fwa_stream_networks_channel_width by linear_feature_id, province-wide.
#     Its FIELD_MEASURMENT rows are FDIS sites (CLAUDE.md), so at a visit the width can be that
#     visit's own measurement; the source is kept so 0297 can split on it.
#   - WATERBODY TESTS of link's CH rear predicate (fresh::frs_habitat_predicates() on link's
#     configs/default): river polygon, wetland >= `wetland_ha_min`, lake or man-made waterbody
#     >= `lake_ha_min`, read from the FWA polygons by the visit segment's waterbody_key.
#   - LINK SEGMENT, where fresh_default classified CH: 0290's placement (the segment starting
#     within [measure - 1 m, measure + `start_window_m`], else the one containing the point; the
#     greatest downstream measure and then id_segment break an overlap; an overlap over
#     `overlap_max_m` stops the run). Its gradient, width and stored CH flags are kept. Access is
#     kept for the side by side only: link's CH access drops barriers that observations override,
#     mostly these visits, so it is never a covariate (CLAUDE.md, access_bt = 2).
#   - HYDROLOGIC ZONE: the Extended BC Hydrologic Zones, as wet adjusts its balance by them, read
#     from the BC catalogue zip and placed by the midpoint of the visit's FWA segment (0294 carries
#     no UTM; the segment is where the visit's flow is read).
#
# INPUT:  data/fdis/derived/ch_mad_visits.csv (scripts/0294), scripts/sql/ch_dist_profile.sql;
#         local fwapg :5432 (discharge.fwa_v1_segment_monthly, whse_basemapping, cabd.dams,
#         fresh_default); the BC Hydrologic Zones zip (catalogue.data.gov.bc.ca)
# OUTPUT: data/fdis/derived/ch_rule_visits.csv  one row per 0294 visit (ignored, private)
#         data/fdis/derived/ch_rule_walks.csv   one row per start x source x river size (same)
#         both: aws s3 cp to s3://fresh-bc/fdis/derived/
#         scripts/logs/habitat/<date>_ch_rule_build_ledger.csv
# RUN:    Rscript scripts/0296-ch-rule-build.R   (after 0294, from the repo root; 4 socket workers)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
options(warn = 1)

q_grid <- c(1, 3, 5, 10, 20, 30, 50)              # m3/s: river sizes walked to
sources <- c("pick", "pcic_routed", "wet_balance")
dam_snap_m <- 500                                 # 0294's
wetland_ha_min <- 1                               # link configs/default rules.yaml, CH rear W
lake_ha_min <- 100                                # same, CH rear L
start_window_m <- 5                               # 0290's
overlap_max_m <- 0.01                             # 0290's
n_workers <- 4
hz_url <- paste0("https://catalogue.data.gov.bc.ca/dataset/f1f86c41-ae83-49d5-92e1-526897b99fa2/",
                 "resource/fc209bd0-26ab-4f8b-9415-8f34081a3c0e/download/bc_hydrologic_zones.zip")
path_in <- "data/fdis/derived/ch_mad_visits.csv"
path_sql <- "scripts/sql/ch_dist_profile.sql"
path_out <- "data/fdis/derived/ch_rule_visits.csv"
path_walks <- "data/fdis/derived/ch_rule_walks.csv"
path_ledger <- file.path("scripts/logs/habitat",
                         paste0(format(Sys.Date(), "%Y%m%d"), "_ch_rule_build_ledger.csv"))

ledger <- tibble(kind = character(), step = character(), n = integer(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.integer(n), note = note))
}
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 5432, dbname = "fwapg",
                          user = "postgres", password = "postgres", bigint = "numeric"),
           error = function(e) stop("local fwapg :5432 unreachable: ", conditionMessage(e)))
}

v <- read_csv(path_in, show_col_types = FALSE, guess_max = 1e5,
              col_types = cols(site_visit = "c", dup_of = "c"))
add("in", "visits_in", nrow(v), "0294's kept visits")
if (anyDuplicated(v$site_visit)) stop("a visit appears twice in ", path_in)

# ---- walks --------------------------------------------------------------------
starts <- v |> distinct(blue_line_key, downstream_route_measure)
fn_sql <- paste(readLines(path_sql), collapse = "\n")
walk_chunk <- function(chunk, fn_sql, q_grid, sources, pg) {
  conn <- pg()
  on.exit(DBI::dbDisconnect(conn))
  DBI::dbExecute(conn, fn_sql)
  qs <- paste0("{", paste(q_grid, collapse = ","), "}")
  out <- lapply(seq_len(nrow(chunk)), function(i) {
    do.call(rbind, lapply(sources, function(src) {
      r <- DBI::dbGetQuery(conn, "SELECT * FROM pg_temp.ch_dist_profile($1::integer, $2, $3::float8[], $4)",
                           params = list(chunk$blue_line_key[i], chunk$downstream_route_measure[i], qs, src))
      cbind(chunk[i, ], src = src, r)
    }))
  })
  do.call(rbind, out)
}
t0 <- Sys.time()
chunks <- split(starts, rep_len(seq_len(n_workers * 8), nrow(starts)))
cl <- parallel::makeCluster(n_workers)
w <- tryCatch(parallel::parLapply(cl, chunks, walk_chunk, fn_sql = fn_sql, q_grid = q_grid,
                                  sources = sources, pg = pg),
              finally = parallel::stopCluster(cl))
w <- bind_rows(w) |> as_tibble()
n_expect <- nrow(starts) * length(sources) * length(q_grid)
if (nrow(w) != n_expect) stop("walks returned ", nrow(w), " rows, expected ", n_expect)
add("info", "walk_starts", nrow(starts),
    sprintf("x %d sources x %d sizes; %.1f min on %d workers", length(sources), length(q_grid),
            as.numeric(difftime(Sys.time(), t0, units = "mins")), n_workers))
for (s in sources) for (st in sort(unique(w$status))) {
  add("info", sprintf("walk_%s_%s", s, st), sum(w$src == s & w$status == st), "rows, all sizes")
}

# positive control: #52's walk at 10 m3/s on pick, on every start 0294 walked
ref <- v |> filter(!is.na(walk_status)) |>
  distinct(blue_line_key, downstream_route_measure, walk_status, dist_large_m, large_lfid)
chk <- ref |> inner_join(w |> filter(src == "pick", qmin == 10),
                         by = c("blue_line_key", "downstream_route_measure"))
bad <- chk$status != chk$walk_status |
  !((is.na(chk$large_lfid.x) & is.na(chk$large_lfid.y)) | chk$large_lfid.x %in% chk$large_lfid.y) |
  is.na(chk$dist_m) != is.na(chk$dist_large_m) |
  coalesce(abs(chk$dist_m - chk$dist_large_m) > 1e-6, FALSE)
if (nrow(chk) != nrow(ref) || any(bad)) {
  stop("ch_dist_profile at 10 m3/s on pick differs from 0294's walk on ", sum(bad), " of ", nrow(ref),
       " starts (", nrow(ref) - nrow(chk), " unmatched)")
}
add("info", "walk_control_0294", nrow(ref), "identical to 0294's ch_dist_large at 10 m3/s on pick")

conn <- pg()
lake_keys <- dbGetQuery(conn, sprintf("
  SELECT waterbody_key FROM whse_basemapping.fwa_lakes_poly WHERE area_ha >= %1$s
  UNION SELECT waterbody_key FROM whse_basemapping.fwa_manmade_waterbodies_poly WHERE area_ha >= %1$s",
  lake_ha_min))$waterbody_key
any_lake_keys <- dbGetQuery(conn, "SELECT DISTINCT waterbody_key FROM whse_basemapping.fwa_lakes_poly")$waterbody_key
wetland_keys <- dbGetQuery(conn, sprintf(
  "SELECT DISTINCT waterbody_key FROM whse_basemapping.fwa_wetlands_poly WHERE area_ha >= %s",
  wetland_ha_min))$waterbody_key
river_keys <- dbGetQuery(conn, "SELECT DISTINCT waterbody_key FROM whse_basemapping.fwa_rivers_poly")$waterbody_key

# targets on regulated reaches (0294's dam placement, then target downstream of a dam)
tg <- w |> filter(status == "found") |> distinct(large_lfid)
dbWriteTable(conn, "tmp_ch_rule_tg", tg, temporary = TRUE, overwrite = TRUE)
dbExecute(conn, sprintf("
  CREATE TEMPORARY TABLE tmp_ch_rule_dams AS
  SELECT s.blue_line_key, s.wscode_ltree AS wscode, s.localcode_ltree AS localcode,
         s.downstream_route_measure + ST_LineLocatePoint(ST_Force2D(s.geom), ST_Force2D(p.pt))
           * (s.upstream_route_measure - s.downstream_route_measure) AS measure
  FROM cabd.dams d
  CROSS JOIN LATERAL (SELECT ST_Transform(d.geom, 3005) AS pt) p
  CROSS JOIN LATERAL (
    SELECT * FROM whse_basemapping.fwa_stream_networks_sp s
    WHERE s.blue_line_key = s.watershed_key AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
    ORDER BY s.geom <-> p.pt LIMIT 1) s
  WHERE (d.reservoir_present OR d.degree_of_regulation_pc >= 10)
    AND ST_Distance(s.geom, p.pt) <= %d", dam_snap_m))
tg_reg <- dbGetQuery(conn, "
  SELECT t.large_lfid,
         EXISTS (SELECT 1 FROM tmp_ch_rule_dams d
                 WHERE s.wscode_ltree @> d.wscode
                   AND fwa_downstream(d.blue_line_key::integer, d.measure, d.wscode, d.localcode,
                                      s.blue_line_key::integer, s.downstream_route_measure,
                                      s.wscode_ltree, s.localcode_ltree)) AS target_regulated
  FROM tmp_ch_rule_tg t
  JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.large_lfid")
if (nrow(tg_reg) != nrow(tg)) stop("a walk target is not in the FWA stream network")
w <- w |>
  left_join(tg_reg, by = "large_lfid") |>
  mutate(target_lake = !is.na(large_waterbody_key) & large_waterbody_key %in% any_lake_keys,
         target_regulated = coalesce(target_regulated, FALSE)) |>
  select(blue_line_key, downstream_route_measure, src, qmin, status, dist_m, large_mad, large_lfid,
         large_edge, target_lake, target_regulated, n_hops, max_entry_gap_m)
add("info", "walk_targets", nrow(tg), sprintf("%d on regulated reaches", sum(tg_reg$target_regulated)))

# ---- width and waterbody tests at the visit's FWA segment ---------------------
dbWriteTable(conn, "tmp_ch_rule_lf", tibble(linear_feature_id = unique(v$linear_feature_id)),
             temporary = TRUE, overwrite = TRUE)
fs <- dbGetQuery(conn, "
  SELECT t.linear_feature_id, s.waterbody_key, cw.channel_width, cw.channel_width_source
  FROM tmp_ch_rule_lf t
  JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
  LEFT JOIN whse_basemapping.fwa_stream_networks_channel_width cw
    ON cw.linear_feature_id = t.linear_feature_id")
if (anyDuplicated(fs$linear_feature_id)) stop("a segment has two channel widths")
fs <- fs |> mutate(wb_river = waterbody_key %in% river_keys, wb_wetland = waterbody_key %in% wetland_keys,
                   wb_lake = waterbody_key %in% lake_keys)
v <- v |> left_join(fs |> rename(fwa_waterbody_key = waterbody_key, fwa_channel_width = channel_width,
                                 fwa_cw_source = channel_width_source),
                    by = "linear_feature_id")
add("info", "width_missing", sum(is.na(v$fwa_channel_width)), "no row or NULL in fwa_stream_networks_channel_width")
for (s in sort(unique(na.omit(v$fwa_cw_source)))) add("info", paste0("width_source_", s), sum(v$fwa_cw_source %in% s))

# ---- link's segment where fresh_default classified CH --------------------------
wsg_ch <- dbGetQuery(conn, "SELECT DISTINCT watershed_group_code w FROM fresh_default.streams_habitat_ch")$w
vc <- v |> filter(watershed_group_code %in% wsg_ch)
dbWriteTable(conn, "tmp_ch_rule_v", vc |> transmute(site_visit, watershed_group_code, blue_line_key,
                                                    m0 = downstream_route_measure),
             temporary = TRUE, overwrite = TRUE)
ov <- dbGetQuery(conn, "
  SELECT count(*) AS n, coalesce(max(o), 0) AS max_overlap FROM (
    SELECT t.site_visit,
           sum(s.upstream_route_measure - s.downstream_route_measure)
             - (max(s.upstream_route_measure) - min(s.downstream_route_measure)) AS o
    FROM tmp_ch_rule_v t
    JOIN fresh_default.streams s
      ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
     AND t.m0 >= s.downstream_route_measure AND t.m0 < s.upstream_route_measure
    GROUP BY t.site_visit HAVING count(*) > 1) x")
add("info", "link_multi_match", ov$n, sprintf("max overlap %.4f m", ov$max_overlap))
if (ov$max_overlap > overlap_max_m) stop("fresh_default segments overlap by ", ov$max_overlap, " m")
seg <- dbGetQuery(conn, sprintf("
  SELECT DISTINCT ON (t.site_visit) t.site_visit,
         s.id_segment AS link_id_segment, s.downstream_route_measure - t.m0 AS link_start_offset_m,
         s.gradient AS link_gradient, s.channel_width AS link_channel_width,
         s.channel_width_source AS link_cw_source, s.edge_type AS link_edge_type,
         s.length_metre AS link_length_m,
         h.accessible AS link_accessible, h.spawning AS link_spawning, h.rearing AS link_rearing,
         h.lake_rearing AS link_lake_rearing, h.wetland_rearing AS link_wetland_rearing
  FROM tmp_ch_rule_v t
  JOIN fresh_default.streams s
    ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
   AND ((s.downstream_route_measure BETWEEN t.m0 - 1 AND t.m0 + %1$s)
        OR (t.m0 >= s.downstream_route_measure AND t.m0 < s.upstream_route_measure))
  JOIN fresh_default.streams_habitat_ch h
    ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
  ORDER BY t.site_visit,
           (s.downstream_route_measure BETWEEN t.m0 - 1 AND t.m0 + %1$s) DESC,
           CASE WHEN s.downstream_route_measure BETWEEN t.m0 - 1 AND t.m0 + %1$s
                THEN s.downstream_route_measure END ASC,
           s.downstream_route_measure DESC, s.id_segment", start_window_m))
dbDisconnect(conn)
v <- v |> mutate(link_ch_classified = watershed_group_code %in% wsg_ch) |>
  left_join(seg, by = "site_visit")
add("info", "link_ch_wsgs", length(wsg_ch), "WSGs with fresh_default.streams_habitat_ch rows")
add("info", "link_ch_visits", nrow(vc), sprintf("placed on a link segment: %d", sum(!is.na(v$link_id_segment))))

# ---- hydrologic zone ------------------------------------------------------------
hz_zip <- tempfile(fileext = ".zip")
h <- curl::curl_fetch_disk(hz_url, hz_zip, handle = curl::new_handle(timeout = 300, followlocation = TRUE))
if (h$status_code != 200) stop("hydrologic zones download returned HTTP ", h$status_code)
hz_dir <- tempfile("hydz")
utils::unzip(hz_zip, exdir = hz_dir)
hz_shp <- list.files(hz_dir, "\\.shp$", full.names = TRUE, recursive = TRUE)
if (length(hz_shp) != 1) stop("expected one shapefile in the hydrologic zones zip, found ", length(hz_shp))
# transform the points, not the zones: the layer's CRS is BC Albers in WKT, and a transform of it
# to EPSG:3005 corrupts 7 of its 43 features (st_is_valid NA), which then fail st_join
hz <- sf::st_read(hz_shp, quiet = TRUE) |>
  transmute(hydro_zone = sprintf("%02d", as.integer(HYDZN_NO)))
if (!all(sf::st_is_valid(hz))) stop("a hydrologic zone geometry is invalid as read")
pt_sql <- v |> select(site_visit, linear_feature_id)
conn <- pg()
dbWriteTable(conn, "tmp_ch_rule_pt", pt_sql, temporary = TRUE, overwrite = TRUE)
# the visit's own FWA segment midpoint: 0294 does not carry UTM, and the segment is where its flow is read
mid <- dbGetQuery(conn, "
  SELECT t.site_visit, ST_X(p) AS x, ST_Y(p) AS y
  FROM tmp_ch_rule_pt t
  JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
  CROSS JOIN LATERAL (SELECT ST_LineInterpolatePoint(ST_Force2D(s.geom), 0.5) AS p) q")
dbDisconnect(conn)
mid_sf <- sf::st_as_sf(mid, coords = c("x", "y"), crs = 3005) |> sf::st_transform(sf::st_crs(hz))
zj <- sf::st_join(mid_sf, hz, join = sf::st_intersects) |> sf::st_drop_geometry()
zj <- zj |> group_by(site_visit) |> summarise(n_zone = n_distinct(hydro_zone, na.rm = TRUE),
                                              hydro_zone = min(hydro_zone), .groups = "drop")
if (any(zj$n_zone > 1)) stop(sum(zj$n_zone > 1), " visits fall in two hydrologic zones")
v <- v |> left_join(zj |> select(site_visit, hydro_zone), by = "site_visit")
add("info", "zone_unmatched", sum(is.na(v$hydro_zone)), "segment midpoint in no hydrologic zone")

add("kept", "visits_kept", nrow(v))
ins <- sum(ledger$n[ledger$kind == "in"])
out <- sum(ledger$n[ledger$kind %in% c("drop", "kept")])
if (ins != out) stop("ledger does not partition the input: ", ins, " in, ", out, " out")
write_csv(v, path_out, na = "")
write_csv(w, path_walks, na = "")
write_csv(ledger, path_ledger, na = "")
print(ledger, n = Inf)
