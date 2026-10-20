# Run from the repo root: Rscript planning/archive/2026-10-issue-65-grade-walks-every-segment/check_connector_share.R > planning/archive/2026-10-issue-65-grade-walks-every-segment/check_connector_share.txt
# How much of a fit site's walked distance is the tributary's connector across the target river's polygon
# A site ending on a double-line river whose river line is not an ancestor of the site's line gets no connector
# length; n_double_line - n_measured counts them. Of the measured, n_connector have an edge-1450 connector on the
# tributary's line (the rest end on another edge, often across a gap the walk bridges without counting it: gap_med_m
# is the median max_entry_gap_m, the largest gap over all of a walk's hops, of those; no_conn_nogap_pct is the share
# of them whose every hop gap is under 1 m, which join the river where it is single-line); the connector medians are
# over n_connector, flips_exc over n_measured.
options(width = 250)
suppressMessages(library(dplyr))
walks <- readr::read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE) |> filter(src == "pick")
c <- DBI::dbConnect(RPostgres::Postgres())
out <- list()
for (k in c("BT_rear", "BT_spawn", "CH_rear", "CO_rear", "GR_rear", "RB_rear", "ST_rear", "WCT_rear")) {
  cv <- readRDS(sprintf("data/tune/%s_curve.rds", k)); cv <- if (!is.null(cv$curve)) cv$curve else cv
  st <- distinct(cv$data, blue_line_key, downstream_route_measure)
  w <- walks |> filter(qmin == cv$q) |> semi_join(st, by = c("blue_line_key", "downstream_route_measure")) |>
    distinct(blue_line_key, downstream_route_measure, .keep_all = TRUE)
  DBI::dbWriteTable(c, "tmp_w", w |> filter(status == "found") |>
                      select(blk = blue_line_key, drm = downstream_route_measure, dist_m, large_lfid, large_edge),
                    temporary = TRUE, overwrite = TRUE)
  conn_len <- DBI::dbGetQuery(c, "
    WITH v AS (
      SELECT w.*, (SELECT s.wscode_ltree FROM whse_basemapping.fwa_stream_networks_sp s
                    WHERE s.blue_line_key = w.blk::int AND s.wscode_ltree IS NOT NULL LIMIT 1) vws,
             r.wscode_ltree rws
        FROM tmp_w w JOIN whse_basemapping.fwa_stream_networks_sp r ON r.linear_feature_id = w.large_lfid::bigint
       WHERE w.large_edge = 1250),
    t AS (SELECT v.*, subpath(vws, 0, nlevel(rws) + 1) tws FROM v WHERE rws @> vws AND nlevel(vws) > nlevel(rws))
    SELECT t.blk, t.drm, coalesce((
      SELECT sum(s.length_metre) FROM whse_basemapping.fwa_stream_networks_sp s
       WHERE s.edge_type = 1450 AND s.blue_line_key = s.watershed_key
         AND s.blue_line_key = (SELECT m.blue_line_key FROM whse_basemapping.fwa_stream_networks_sp m
                                 WHERE m.wscode_ltree = t.tws AND m.blue_line_key = m.watershed_key LIMIT 1)
         AND (s.blue_line_key <> t.blk::int OR s.downstream_route_measure < t.drm)), 0) conn_m
      FROM t")
  w <- w |> left_join(conn_len |> rename(blue_line_key = blk, downstream_route_measure = drm),
                      by = c("blue_line_key", "downstream_route_measure"))
  f <- w |> filter(status == "found")
  dl <- f |> filter(large_edge == 1250, !is.na(conn_m))
  ed <- if (k == "CH_rear") 1000 else if (k == "BT_spawn") 2000 else NA
  out[[k]] <- tibble(key = k, q = cv$q, sites = nrow(w), found = nrow(f),
    end_double_line_pct = round(100 * mean(f$large_edge == 1250)),
    end_double_line_of_all_pct = round(100 * sum(f$large_edge == 1250) / nrow(w)),
    n_double_line = sum(f$large_edge == 1250), n_measured = nrow(dl),
    end_connector_pct = round(100 * mean(f$large_edge == 1450)),
    end_lake_pct = round(100 * mean(f$large_edge == 1200)),
    n_connector = sum(dl$conn_m > 0), connector_pct = round(100 * mean(dl$conn_m > 0)),
    conn_med_m = round(median(dl$conn_m[dl$conn_m > 0])), conn_p90_m = round(quantile(dl$conn_m[dl$conn_m > 0], 0.9)),
    share_of_dist_med_pct = round(100 * median(dl$conn_m[dl$conn_m > 0] / pmax(dl$dist_m[dl$conn_m > 0], 1))),
    gap_med_m = round(median(dl$max_entry_gap_m[dl$conn_m == 0])),
    n_no_connector = sum(dl$conn_m == 0),
    no_conn_nogap_pct = round(100 * mean(dl$max_entry_gap_m[dl$conn_m == 0] < 1)),
    within_1km = sum(f$dist_m <= 1000),
    within_1km_conn_over_100m = sum(dl$dist_m <= 1000 & dl$conn_m > 100),
    flips_exc = if (is.na(ed)) NA_integer_ else sum(dl$dist_m > ed & dl$dist_m - dl$conn_m <= ed))
}
print(as.data.frame(bind_rows(out)))
