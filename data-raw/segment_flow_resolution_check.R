# data-raw/segment_flow_resolution_check.R
# ---------------------------------------------------------------------------
# Is one discharge value per FWA segment accurate enough to tune on, given where fish records sit? Issue #137 (move 6).
#
# Each FWA segment carries one annual flow (wet's `pick` of the PCIC routed and water-balance sources), and link and the
# tuning join it on `linear_feature_id`, so flow changes only between segments. Physically it grows along a segment, by
# the local area draining to it. This measures that growth against the error already in the evidence.
#
# Area along a stream. A reach is the segments of one blue line that share a watershed code and a local code: the
# stretch between two tributary mouths. Every fundamental watershed with those codes drains to it (both banks), and
# fwapg's upstream area of any one of them, which counts all polygons with equal or upstream codes, is the area at the
# reach's downstream end. Between its ends the area is taken to fall linearly by measure, from that to that less the
# reach's own local area. Flow scales with area: a segment's flow at a point is its value times the area there over the
# area at the segment's downstream end (the segment's value taken as its bottom's, which bounds the change).
#   Q1. Province-wide, the share by which area-scaled flow falls from each segment's bottom to its top, by edge type and
#       by the segment's flow class. Only a blue line's own segments (blue_line_key = watershed_key) form reaches:
#       side channels share their main stem's codes.
#   Q2. At each published visit on its own line's flow: the fall in area-scaled flow from the record's point to the top
#       of its fished span (knw_fdis_span(), across segment and reach ends where the span runs past them), against the
#       fall within its segment, and against two yardsticks on the same visits: the two flow sources' disagreement and
#       the pick's error at gauges (research/modelled_discharge.md: annual mean absolute error 23.0 %).
#   Q3. The share of visits whose class at each published minimum-flow threshold (thresholds.csv's rear_mad_min, every
#       key) changes when flow is read at the record's point, or at the middle of its span, instead of the segment's
#       value; beside the share that changes when the other source replaces the pick.
#
# INPUT:  EVIDENCE_DIR/{visits_link,fdis_sites}.csv (default data/fdis/derived), held to the published tables'
#         evidence_md5 (data/thresholds.csv); data/thresholds.csv; the database (PG* env vars): whse_basemapping
#         (streams, fundamental watersheds, their upstream areas) and discharge.fwa_v1_segment_monthly, whose comment
#         (the flow load) is logged
# OUTPUT: scripts/logs/flow/<yyyymmdd>_segment_flow_resolution_check[-<n>].txt
# RUN:    EVIDENCE_DIR=<a restored published build>/data/fdis/derived Rscript data-raw/segment_flow_resolution_check.R
#         (from the repo root, on the database's host: Q1 aggregates every segment in the province)
# ---------------------------------------------------------------------------
suppressMessages({
  library(dplyr)
  library(DBI)
  library(RPostgres)
})
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

evidence_dir <- Sys.getenv("EVIDENCE_DIR", "data/fdis/derived")
path_log <- .knw_free_path(file.path("scripts/logs/flow",
                                     paste0(format(Sys.Date(), "%Y%m%d"), "_segment_flow_resolution_check.txt")))
log_lines <- character()
say <- function(...) {
  log_lines <<- c(log_lines, sprintf(...))
  message(sprintf(...))
}
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}
q <- function(x, p) unname(stats::quantile(x, p, na.rm = TRUE))

# ---- the published evidence --------------------------------------------------------------------------------------
thr <- utils::read.csv("data/thresholds.csv", colClasses = "character")
ev_md5 <- strsplit(unique(thr$evidence_md5[nzchar(thr$evidence_md5)]), ";", fixed = TRUE)[[1]]
f_visits <- file.path(evidence_dir, "visits_link.csv")
if (!identical(unname(tools::md5sum(f_visits)), ev_md5[1])) {
  stop(f_visits, " is not the published build's visits_link.csv (", ev_md5[1], "): restore it with ",
       "PULL=TRUE scripts/0336-archive.R and point EVIDENCE_DIR at it")
}
vis <- utils::read.csv(f_visits, colClasses = c(site_visit = "character"))
mad_min <- thr[thr$link_parameter == "rear_mad_min" & nzchar(thr$value), c("species_code", "stage", "value")]
mad_min$value <- as.numeric(mad_min$value)
say("Segment flow resolution check (knowledge#137, move 6), %s UTC.", format(Sys.time(), "%Y-%m-%d %H:%M", tz = "UTC"))
# the directory is named only when it is the checkout's own: a restored copy sits outside it
where_visits <- if (startsWith(normalizePath(f_visits), getwd())) .knw_path_rel(f_visits) else
  "visits_link.csv of a restored build"
say("Visits: %s (md5 %s, the published evidence); thresholds: data/thresholds.csv (link run %s).", where_visits,
    ev_md5[1], unique(thr$link_run_uid))

conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
say("Flow load: %s", knw_discharge_load(conn))
act <- DBI::dbGetQuery(conn, "SELECT count(*) AS n FROM pg_stat_activity
                               WHERE state <> 'idle' AND pid <> pg_backend_pid()")
say("Other active sessions on the database at start: %d.", act$n)

# the reaches: a blue line's own segments sharing its codes, their measures, local area and area at the bottom
sql_reach <- "
  WITH ra AS (
    SELECT p.wscode_ltree, p.localcode_ltree, sum(p.area_ha) AS local_ha, max(u.upstream_area_ha) AS up_ha
      FROM whse_basemapping.fwa_watersheds_poly p
      JOIN whse_basemapping.fwa_watersheds_upstream_area u ON u.watershed_feature_id = p.watershed_feature_id
     GROUP BY p.wscode_ltree, p.localcode_ltree),
  rs AS (
    SELECT blue_line_key, wscode_ltree, localcode_ltree, min(downstream_route_measure) AS m_bot,
           max(upstream_route_measure) AS m_top
      FROM whse_basemapping.fwa_stream_networks_sp
     WHERE blue_line_key = watershed_key AND wscode_ltree IS NOT NULL AND localcode_ltree IS NOT NULL
     GROUP BY blue_line_key, wscode_ltree, localcode_ltree)
  SELECT rs.*, ra.local_ha, ra.up_ha
    FROM rs JOIN ra ON ra.wscode_ltree = rs.wscode_ltree AND ra.localcode_ltree = rs.localcode_ltree"

# ---- Q1: within-segment change, province-wide --------------------------------------------------------------------
t0 <- Sys.time()
q1 <- DBI::dbGetQuery(conn, paste0("
  WITH r AS (", sql_reach, "),
  s AS (
    SELECT s.linear_feature_id, s.edge_type, s.length_metre, s.downstream_route_measure AS m0,
           s.upstream_route_measure AS m1, r.m_bot, r.m_top, r.local_ha, r.up_ha
      FROM whse_basemapping.fwa_stream_networks_sp s
      JOIN r ON r.blue_line_key = s.blue_line_key AND r.wscode_ltree = s.wscode_ltree
            AND r.localcode_ltree = s.localcode_ltree
     WHERE s.blue_line_key = s.watershed_key AND r.m_top > r.m_bot AND r.up_ha > 0),
  a AS (
    SELECT s.*, s.up_ha - s.local_ha * (s.m0 - s.m_bot) / (s.m_top - s.m_bot) AS a_bot,
           s.up_ha - s.local_ha * (s.m1 - s.m_bot) / (s.m_top - s.m_bot) AS a_top
      FROM s),
  f AS (
    SELECT a.*, 1 - a.a_top / NULLIF(a.a_bot, 0) AS fall, q.q_m3s
      FROM a LEFT JOIN discharge.fwa_v1_segment_monthly q
        ON q.linear_feature_id = a.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick)
  SELECT CASE WHEN edge_type IN (1000, 1050) THEN 'single-line stream'
              WHEN edge_type IN (1250, 1450) THEN 'double-line river'
              WHEN edge_type IN (1200, 1400, 1410) THEN 'lake or wetland skeleton'
              ELSE 'other' END AS edges,
         CASE WHEN q_m3s IS NULL THEN 'no flow' WHEN q_m3s < 0.1 THEN '<0.1' WHEN q_m3s < 1 THEN '0.1-1'
              WHEN q_m3s < 10 THEN '1-10' ELSE '>=10' END AS mad_class,
         count(*) AS segments, round(sum(length_metre) / 1000) AS km,
         round(percentile_cont(0.5) WITHIN GROUP (ORDER BY fall)::numeric, 4) AS fall_p50,
         round(percentile_cont(0.9) WITHIN GROUP (ORDER BY fall)::numeric, 4) AS fall_p90,
         round(avg((fall > 0.1)::int)::numeric, 4) AS share_over_10pct,
         round(avg((fall > 0.25)::int)::numeric, 4) AS share_over_25pct
    FROM f GROUP BY 1, 2 ORDER BY 1, 2"))
n_lines <- DBI::dbGetQuery(conn, "SELECT count(*) AS n, count(*) FILTER (WHERE blue_line_key = watershed_key) AS own
                                    FROM whse_basemapping.fwa_stream_networks_sp")
say("")
say("Q1 took %.1f min. Segments in the province: %s; on their own blue line (reaches): %s.",
    as.numeric(difftime(Sys.time(), t0, units = "mins")), format(n_lines$n, big.mark = ","),
    format(n_lines$own, big.mark = ","))
block(paste("Q1. Fall in area-scaled flow from a segment's bottom to its top (share of the bottom's), by edges and the",
            "segment's annual flow (m3/s, wet's pick)"), q1)

# ---- Q2: at the published visits ---------------------------------------------------------------------------------
v <- vis |>
  filter(flow_from == "own", !is.na(mad_pick), !is.na(blue_line_key)) |>
  select(site_visit, blue_line_key, downstream_route_measure, linear_feature_id, edge_type, fished_length_m,
         mad_pick, mad_routed, mad_balance)
blk <- unique(v$blue_line_key)
arr <- function(x) paste0("{", paste(format(x, scientific = FALSE, trim = TRUE), collapse = ","), "}")
reach <- DBI::dbGetQuery(conn, paste0("SELECT * FROM (", sql_reach, ") r WHERE blue_line_key = ANY($1::bigint[])"),
                         params = list(arr(blk)))
seg <- DBI::dbGetQuery(conn, "SELECT linear_feature_id, blue_line_key, downstream_route_measure AS m0,
                                     upstream_route_measure AS m1
                                FROM whse_basemapping.fwa_stream_networks_sp
                               WHERE linear_feature_id = ANY($1::bigint[])",
                       params = list(arr(unique(v$linear_feature_id))))
top <- DBI::dbGetQuery(conn, "SELECT blue_line_key, max(upstream_route_measure) AS line_top_m
                                FROM whse_basemapping.fwa_stream_networks_sp
                               WHERE blue_line_key = ANY($1::bigint[]) GROUP BY blue_line_key", params = list(arr(blk)))
DBI::dbDisconnect(conn)

# area at measure m on blue line b: the reach holding m, interpolated; NA off the line's reaches
reach <- reach[reach$m_top > reach$m_bot & reach$up_ha > 0, ]
reach <- reach[order(reach$blue_line_key, reach$m_bot, method = "radix"), ]
area_at <- function(b, m) {
  out <- rep(NA_real_, length(m))
  for (k in unique(b[!is.na(m)])) {
    i <- which(b == k & !is.na(m))
    r <- reach[reach$blue_line_key == k, ]
    if (!nrow(r)) next
    # left-closed: a measure on a reach's foot belongs to that reach (rightmost.closed would put the top reach's foot
    # in the reach below it, and a one-reach line's foot nowhere: review round 1)
    j <- findInterval(m[i], r$m_bot)
    j[j == 0 | m[i] > r$m_top[pmax(j, 1)] + 1e-3] <- NA
    out[i] <- r$up_ha[j] - r$local_ha[j] * (m[i] - r$m_bot[j]) / (r$m_top[j] - r$m_bot[j])
  }
  out
}
v$m0 <- seg$m0[match(v$linear_feature_id, seg$linear_feature_id)]
v$m1 <- seg$m1[match(v$linear_feature_id, seg$linear_feature_id)]
v$line_top_m <- top$line_top_m[match(v$blue_line_key, top$blue_line_key)]
sp <- knw_fdis_span(v$downstream_route_measure, v$fished_length_m, v$line_top_m)
v$m_span_top <- sp$upstream_route_measure
v$a_seg_bot <- area_at(v$blue_line_key, v$m0)
v$a_seg_top <- area_at(v$blue_line_key, pmax(v$m0, v$m1 - 1e-3))
v$a_point <- area_at(v$blue_line_key, v$downstream_route_measure)
v$a_span_top <- area_at(v$blue_line_key, v$m_span_top)
v$a_span_mid <- area_at(v$blue_line_key, (v$downstream_route_measure + v$m_span_top) / 2)
v$fall_segment <- 1 - v$a_seg_top / v$a_seg_bot
v$fall_span <- 1 - v$a_span_top / v$a_point
v$q_point <- v$mad_pick * v$a_point / v$a_seg_bot
v$q_mid <- v$mad_pick * v$a_span_mid / v$a_seg_bot
v$source_ratio <- abs(log(v$mad_routed / v$mad_balance))
v$edges <- ifelse(v$edge_type %in% c(1000, 1050), "single-line stream",
                  ifelse(v$edge_type %in% c(1250, 1450), "double-line river", "other"))
say("")
say(paste("Q2. Visits on their own line's flow: %s of %s; with an area along their line: %s; with a span (a fished",
          "length): %s."), format(nrow(v), big.mark = ","), format(nrow(vis), big.mark = ","),
    format(sum(!is.na(v$a_point)), big.mark = ","), format(sum(!is.na(v$a_span_top)), big.mark = ","))
block(paste("Q2. Fall in area-scaled flow over the visit's segment and over its fished span, against the two sources'",
            "disagreement (|log routed / balance|, as a factor) on the same visits"),
      v |>
        filter(!is.na(fall_span)) |>
        group_by(edges) |>
        summarise(visits = n(), segment_fall_p50 = round(q(fall_segment, 0.5), 4),
                  segment_fall_p90 = round(q(fall_segment, 0.9), 4), span_fall_p50 = round(q(fall_span, 0.5), 4),
                  span_fall_p90 = round(q(fall_span, 0.9), 4),
                  share_span_fall_over_10pct = round(mean(fall_span > 0.1), 4),
                  sources_factor_p50 = round(exp(q(source_ratio, 0.5)), 2),
                  sources_factor_p90 = round(exp(q(source_ratio, 0.9)), 2)))
say("Yardstick: wet's pick against gauges, annual mean absolute error 23.0 %% (research/modelled_discharge.md).")

# ---- Q3: flips at the published thresholds -----------------------------------------------------------------------
other <- ifelse(v$mad_pick == v$mad_routed, v$mad_balance, v$mad_routed)
flips <- do.call(rbind, lapply(seq_len(nrow(mad_min)), function(i) {
  t <- mad_min$value[i]
  ok <- !is.na(v$q_point) & !is.na(v$q_mid)
  seg_in <- v$mad_pick[ok] >= t
  data.frame(key = paste(mad_min$species_code[i], mad_min$stage[i], sep = "_"), rear_mad_min = t, visits = sum(ok),
             within_x2_of_threshold = sum(v$mad_pick[ok] >= t / 2 & v$mad_pick[ok] < t * 2),
             flip_at_point = round(mean(seg_in != (v$q_point[ok] >= t)), 4),
             flip_at_span_middle = round(mean(seg_in != (v$q_mid[ok] >= t)), 4),
             flip_other_source = round(mean(seg_in != (other[ok] >= t), na.rm = TRUE), 4))
}))
block(paste("Q3. Share of visits whose class at each key's minimum flow changes when flow is read at the record's",
            "point or the span's middle instead of the segment's value, beside the other source replacing the pick"),
      flips)

dir.create(dirname(path_log), showWarnings = FALSE, recursive = TRUE)
writeLines(log_lines, path_log)
message("Wrote ", path_log)
