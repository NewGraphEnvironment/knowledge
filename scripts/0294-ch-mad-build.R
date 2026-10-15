# scripts/0294-ch-mad-build.R
# ---------------------------------------------------------------------------
# FDIS electrofishing site visits with wet's published annual flow (MAD) on their FWA segment,
# the network distance downstream to the first large river, and flags for the places where a
# visit's MAD cannot be read as its stream size. Issue #52. Consumer: scripts/0295-ch-mad-use.R.
#
# WHY / DESIGN NOTES (results in research/chinook_stream_size.md; plan review in the #52
# planning archive, review-plan.md, ids B1-B4, A2-A8 below):
#   - A VISIT, NOT A SIGHTING, as in #28 (scripts/0290): FDIS visits carry effort and zero catch.
#     CH in FDIS is juveniles only (EF caught 2 CH >= 150 mm in the whole export).
#   - FWA SEGMENTS, NOT LINK'S. wet publishes flow per FWA linear_feature_id, which 0230 placed
#     each visit on, so link's segmentation and its access codes are never read.
#   - QUALITY DROPS are 0290's (not placed, far snap, ws50 mismatch, junk date, effort sentinel
#     or no effort, catch unknown), plus a drop where a code blocks CH absence and CH was not
#     caught (data/fdis_species_codes.csv).
#   - POPULATION (A2): WSGs where bcfishobs holds at least 5 CH records dated 1990 or later,
#     link's own presence rule for CH (parameters_fresh.csv: observation_threshold 5,
#     observation_date_min 1990-01-01). A range filter at WSG scale only.
#   - DUPLICATES (#35, A8): visits with the same UTM, date, area and catch, after the drops, are
#     KEPT and flagged (`dup_of` = the lowest site_visit of the group, NA on that one).
#   - FLOW is month 0 (the annual mean) of discharge/fwa/v1/segment_monthly, scenario historical,
#     as wet::wet_db_load() loaded it into local fwapg; `pick` marks wet's default source per
#     segment, both sources' values are kept, and the picked counts are checked against the
#     manifest this was written for. A segment with no picked flow (B2: side channels and
#     connectors with no watershed lut row, where CH are caught at four times the overall rate)
#     is NOT dropped: it takes the picked flow of the nearest primary-flow segment on its main
#     line (watershed_key) or its own line, and `flow_from` says which (`own`, `parent`). Such a
#     segment often has no watershed code either; it takes that segment's codes too.
#   - REGULATED (B1): a visit downstream of a CABD dam with a reservoir or a degree of regulation
#     of 10 % or more. wet's flow is natural flow, so on a regulated river it is not the flow the
#     fish meet (Kenney Dam regulates 621 %, the Nechako; Terzaghi the lower Bridge). Dams are
#     placed on the nearest main-flow FWA segment within `dam_snap_m`.
#   - DISTANCE (B4), for visits whose MAD is below `small_max`: scripts/sql/ch_dist_large.sql
#     walks the path on route measures to the first primary-flow segment with picked MAD of at
#     least `large_min`, and records that segment's edge type and waterbody (a lake is not a
#     river) and the largest gap where a mouth projects onto its parent line. fwa_downstreamtrace()
#     is not used: it returns side channels off the path and drops segments with no lut row.
#   - AMBIGUOUS PLACEMENT (B3), for the same small-stream visits: the visit's UTM point lies
#     within its snap distance plus `ambig_pad_m` of a segment with picked MAD >= `large_min` on
#     another blue line, so it may have been sampled in the large river and snapped to a
#     tributary mouth. `side_channel` marks a visit on a line that is not its own main line.
#   - ACCESS (A3, A4), a sensitivity only, where link's fresh_default covers the WSG: a natural CH
#     barrier downstream, from fresh_default.barriers, which is from before observation
#     overrides (barriers_ch_access drops the overridden ones, and those overrides come from
#     observations, mostly these visits). Kept with and without USER_DEFINITE.
#   - SEGMENT ATTRIBUTES for sensitivities: FWA gradient (G6), and whether the segment is in a
#     lake or river polygon (G3, A5).
#   - Every drop is counted in the ledger, and the drops and the kept rows partition the input.
#
# INPUT:  data/fdis/derived/fdis_sites.csv (scripts/0240), data/fdis_species_codes.csv,
#         scripts/sql/ch_dist_large.sql; local fwapg :5432 (discharge.fwa_v1_segment_monthly,
#         bcfishobs.observations, cabd.dams, fresh_default.barriers, whse_basemapping)
# OUTPUT: data/fdis/derived/ch_mad_visits.csv  one row per kept visit (ignored, private;
#         aws s3 cp to s3://fresh-bc/fdis/derived/)
#         scripts/logs/habitat/<date>_ch_mad_build_ledger.csv
# RUN:    Rscript scripts/0294-ch-mad-build.R   (from the repo root; ~10 min, 4 socket workers)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })

small_max <- 0.5     # m3/s: a visit below this gets a distance and the placement check
large_min <- 10      # m3/s: the first segment downstream at or above this is the large river
ambig_pad_m <- 20    # m added to the snap distance in the placement check
dam_snap_m <- 500
obs_min <- 5         # link's CH observation_threshold
obs_date_min <- "1990-01-01"
n_workers <- 4
picked_expected <- c(pcic_routed = 3152838, wet_balance = 1380005)  # manifest built 2026-10-15
natural <- c("GRADIENT", "FALLS", "SUBSURFACE_FLOW", "USER_DEFINITE")
path_sql <- "scripts/sql/ch_dist_large.sql"
path_out <- "data/fdis/derived/ch_mad_visits.csv"
path_ledger <- file.path("scripts/logs/habitat",
                         paste0(format(Sys.Date(), "%Y%m%d"), "_ch_mad_build_ledger.csv"))

ledger <- tibble(kind = character(), step = character(), n = integer(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.integer(n), note = note))
}
drop <- function(x, keep, step) {
  keep <- coalesce(keep, FALSE)
  add("drop", step, sum(!keep), sprintf("CH caught on %d", sum(x$present_CH[!keep])))
  x[keep, ]
}
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 5432, dbname = "fwapg",
                          user = "postgres", password = "postgres", bigint = "numeric"),
           error = function(e) stop("local fwapg :5432 unreachable: ", conditionMessage(e)))
}

sites <- read_csv("data/fdis/derived/fdis_sites.csv", show_col_types = FALSE, guess_max = 1e5,
                  col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c"))
add("in", "visits_in", nrow(sites))

v <- drop(sites, !sites$flag_not_placed, "not_placed")
v <- drop(v, !v$flag_far_snap, "far_snap")
v <- drop(v, !coalesce(v$flag_ws50_mismatch, FALSE), "ws50_mismatch")
v <- drop(v, !v$flag_junk_date, "junk_date")
v <- drop(v, !v$flag_effort_sentinel & (!v$flag_no_area | !v$flag_no_effort),
          "effort_sentinel_or_none")
v <- drop(v, v$catch_status != "unknown", "catch_unknown")
v <- drop(v, v$present_CH | !grepl("CH", coalesce(v$blocks_absence_of, "")), "ch_absence_blocked")

conn <- pg()
ch_wsg <- dbGetQuery(conn, sprintf("
  SELECT watershed_group_code w FROM bcfishobs.observations
  WHERE species_code = 'CH' AND watershed_group_code IS NOT NULL AND observation_date >= '%s'
  GROUP BY 1 HAVING count(*) >= %d", obs_date_min, obs_min))$w
add("info", "population_wsgs", length(ch_wsg),
    sprintf(">= %d bcfishobs CH records since %s", obs_min, obs_date_min))
v <- drop(v, v$watershed_group_code %in% ch_wsg, "wsg_outside_ch_range")

# ---- duplicates (#35) -------------------------------------------------------
v <- v |>
  group_by(utm_zone, utm_easting, utm_northing, date, area_m2,
           species_caught = coalesce(species_caught, ""), n_caught_all) |>
  mutate(dup_of = if (n() > 1) min(site_visit) else NA_character_) |>
  ungroup() |>
  mutate(dup_of = if_else(dup_of == site_visit, NA_character_, dup_of))
add("info", "duplicate_flagged", sum(!is.na(v$dup_of)), "kept, flagged in dup_of")

# ---- flow -------------------------------------------------------------------
picked <- dbGetQuery(conn, "SELECT source, count(*)::integer n FROM discharge.fwa_v1_segment_monthly
                            WHERE scenario = 'historical' AND month = 0 AND pick GROUP BY 1")
got <- setNames(picked$n, picked$source)[names(picked_expected)]
if (!identical(as.numeric(got), as.numeric(picked_expected))) {
  stop("discharge.fwa_v1_segment_monthly picked counts ", paste(names(got), got, collapse = ", "),
       " differ from the manifest this was written for; reload with wet::wet_db_load()")
}

dbWriteTable(conn, "tmp_ch_mad_lf", tibble(linear_feature_id = unique(v$linear_feature_id)),
             temporary = TRUE, overwrite = TRUE)
seg <- dbGetQuery(conn, "
  SELECT t.linear_feature_id,
         s.blue_line_key <> s.watershed_key AS side_channel,
         s.gradient AS fwa_gradient,
         coalesce(s.wscode_ltree, par.wscode)::text AS wscode,
         coalesce(s.localcode_ltree, par.localcode)::text AS localcode,
         (s.wscode_ltree IS NULL OR s.localcode_ltree IS NULL) AS code_from_parent, s.waterbody_key,
         own.mad_pick AS own_mad, own.pick_source AS own_source,
         own.mad_routed, own.mad_balance,
         par.q_m3s AS parent_mad, par.source AS parent_source, par.d AS parent_dist_m
  FROM tmp_ch_mad_lf t
  JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
  LEFT JOIN LATERAL (
    SELECT max(q.q_m3s) FILTER (WHERE q.pick) AS mad_pick,
           max(q.source) FILTER (WHERE q.pick) AS pick_source,
           max(q.q_m3s) FILTER (WHERE q.source = 'pcic_routed') AS mad_routed,
           max(q.q_m3s) FILTER (WHERE q.source = 'wet_balance') AS mad_balance
    FROM discharge.fwa_v1_segment_monthly q
    WHERE q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0
  ) own ON true
  LEFT JOIN LATERAL (
    SELECT q.q_m3s, q.source, ST_Distance(p.geom, s.geom) AS d,
           p.wscode_ltree AS wscode, p.localcode_ltree AS localcode
    FROM whse_basemapping.fwa_stream_networks_sp p
    JOIN discharge.fwa_v1_segment_monthly q
      ON q.linear_feature_id = p.linear_feature_id AND q.scenario = 'historical'
     AND q.month = 0 AND q.pick
    WHERE (own.mad_pick IS NULL OR s.wscode_ltree IS NULL OR s.localcode_ltree IS NULL)
      AND p.blue_line_key IN (s.watershed_key, s.blue_line_key)
      AND p.wscode_ltree IS NOT NULL AND p.localcode_ltree IS NOT NULL
      AND p.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
    ORDER BY p.geom <-> s.geom
    LIMIT 1
  ) par ON true")
if (anyDuplicated(seg$linear_feature_id)) stop("a segment matched twice")
lake_keys <- dbGetQuery(conn, "SELECT DISTINCT waterbody_key FROM whse_basemapping.fwa_lakes_poly")$waterbody_key
river_keys <- dbGetQuery(conn, "SELECT DISTINCT waterbody_key FROM whse_basemapping.fwa_rivers_poly")$waterbody_key
seg <- seg |> mutate(in_lake = waterbody_key %in% lake_keys, in_river_poly = waterbody_key %in% river_keys)
v <- v |>
  left_join(seg, by = "linear_feature_id") |>
  mutate(flow_from = case_when(!is.na(own_mad) ~ "own", !is.na(parent_mad) ~ "parent"),
         parent_mad = if_else(is.na(own_mad), parent_mad, NA_real_),
         mad_pick = coalesce(own_mad, parent_mad),
         pick_source = coalesce(own_source, parent_source))
add("info", "flow_from_parent", sum(v$flow_from %in% "parent"),
    sprintf("CH caught on %d; parent segment up to %.0f m away", sum(v$present_CH & v$flow_from %in% "parent"),
            max(c(0, v$parent_dist_m[v$flow_from %in% "parent"]))))
v <- drop(v, !is.na(v$mad_pick), "no_flow")
add("info", "code_from_parent", sum(v$code_from_parent %in% TRUE),
    "segment with no watershed code takes its parent segment's, for the downstream tests")
v <- drop(v, !is.na(v$wscode) & !is.na(v$localcode), "no_watershed_code")

# ---- regulated reaches ------------------------------------------------------
dams <- dbGetQuery(conn, sprintf("
  SELECT d.cabd_id, d.dam_name_en, d.degree_of_regulation_pc, d.reservoir_present,
         s.blue_line_key, s.wscode_ltree::text AS wscode, s.localcode_ltree::text AS localcode,
         s.downstream_route_measure + ST_LineLocatePoint(ST_Force2D(s.geom), ST_Force2D(p.pt))
           * (s.upstream_route_measure - s.downstream_route_measure) AS measure,
         ST_Distance(s.geom, p.pt) AS snap_m
  FROM cabd.dams d
  CROSS JOIN LATERAL (SELECT ST_Transform(d.geom, 3005) AS pt) p
  CROSS JOIN LATERAL (
    SELECT * FROM whse_basemapping.fwa_stream_networks_sp s
    WHERE s.blue_line_key = s.watershed_key AND s.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
    ORDER BY s.geom <-> p.pt LIMIT 1) s
  WHERE (d.reservoir_present OR d.degree_of_regulation_pc >= 10)
    AND ST_Distance(s.geom, p.pt) <= %d", dam_snap_m))
add("info", "regulating_dams_placed", nrow(dams), sprintf("within %d m of a main-flow segment", dam_snap_m))
dbWriteTable(conn, "tmp_ch_mad_dams", dams, temporary = TRUE, overwrite = TRUE)
pts <- v |> distinct(linear_feature_id, blue_line_key, downstream_route_measure, wscode, localcode)
dbWriteTable(conn, "tmp_ch_mad_pts", pts, temporary = TRUE, overwrite = TRUE)
down_of <- function(tbl, where = "TRUE", wscode_b = "b.wscode::ltree", localcode_b = "b.localcode::ltree",
                    measure_b = "b.measure") sprintf("
  SELECT t.blue_line_key, t.downstream_route_measure,
         EXISTS (SELECT 1 FROM %1$s b
                 WHERE %3$s @> t.wscode::ltree AND %2$s
                   AND fwa_downstream(t.blue_line_key::integer, t.downstream_route_measure,
                                      t.wscode::ltree, t.localcode::ltree,
                                      b.blue_line_key::integer, %5$s, %3$s, %4$s)) AS hit
  FROM tmp_ch_mad_pts t", tbl, where, wscode_b, localcode_b, measure_b)
# a dam is upstream of the visit when the visit is downstream of the dam: swap the roles
reg <- dbGetQuery(conn, "
  SELECT t.blue_line_key, t.downstream_route_measure,
         EXISTS (SELECT 1 FROM tmp_ch_mad_dams d
                 WHERE t.wscode::ltree @> d.wscode::ltree
                   AND fwa_downstream(d.blue_line_key::integer, d.measure, d.wscode::ltree, d.localcode::ltree,
                                      t.blue_line_key::integer, t.downstream_route_measure,
                                      t.wscode::ltree, t.localcode::ltree)) AS regulated
  FROM tmp_ch_mad_pts t")
v <- v |> left_join(reg, by = c("blue_line_key", "downstream_route_measure"))
add("info", "regulated", sum(v$regulated), sprintf("CH caught on %d", sum(v$present_CH & v$regulated)))

# ---- natural CH barrier downstream (sensitivity; fresh_default WSGs only) ----
wsg_fd <- dbGetQuery(conn, "SELECT DISTINCT watershed_group_code w FROM fresh_default.streams")$w
bar_where <- function(src) sprintf("b.barrier_source IN (%s) AND 'CH' = ANY(b.blocks_species)",
                                   paste0("'", src, "'", collapse = ","))
bar_q <- function(src) down_of("fresh_default.barriers", bar_where(src), "b.wscode_ltree",
                               "b.localcode_ltree", "b.downstream_route_measure")
acc <- dbGetQuery(conn, bar_q(natural)) |> rename(ch_barrier_dnstr = hit) |>
  left_join(dbGetQuery(conn, bar_q(setdiff(natural, "USER_DEFINITE"))) |>
              rename(ch_barrier_dnstr_no_user = hit),
            by = c("blue_line_key", "downstream_route_measure"))
v <- v |>
  mutate(access_covered = watershed_group_code %in% wsg_fd) |>
  left_join(acc, by = c("blue_line_key", "downstream_route_measure")) |>
  mutate(across(c(ch_barrier_dnstr, ch_barrier_dnstr_no_user), ~ if_else(access_covered, .x, NA)))
add("info", "access_covered", sum(v$access_covered), sprintf("%d fresh_default WSGs", length(wsg_fd)))
add("info", "ch_barrier_dnstr", sum(v$ch_barrier_dnstr %in% TRUE),
    sprintf("CH caught on %d", sum(v$present_CH & v$ch_barrier_dnstr %in% TRUE)))

# ---- small streams: ambiguous placement -------------------------------------
sm <- v |> filter(mad_pick < small_max) |>
  distinct(site_visit, blue_line_key, utm_zone, utm_easting, utm_northing, distance_to_stream)
dbWriteTable(conn, "tmp_ch_mad_small", sm, temporary = TRUE, overwrite = TRUE)
amb <- dbGetQuery(conn, sprintf("
  WITH p AS (
    SELECT site_visit, blue_line_key, coalesce(distance_to_stream, 0) + %1$s AS r,
           ST_Transform(ST_SetSRID(ST_MakePoint(utm_easting, utm_northing), 26900 + utm_zone::int), 3005) AS pt
    FROM tmp_ch_mad_small
    WHERE utm_zone BETWEEN 7 AND 11 AND utm_easting IS NOT NULL AND utm_northing IS NOT NULL)
  SELECT p.site_visit,
         EXISTS (SELECT 1 FROM whse_basemapping.fwa_stream_networks_sp s
                 JOIN discharge.fwa_v1_segment_monthly q
                   ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical'
                  AND q.month = 0 AND q.pick AND q.q_m3s >= %2$s
                 WHERE ST_DWithin(s.geom, p.pt, p.r) AND s.blue_line_key <> p.blue_line_key) AS ambiguous
  FROM p", ambig_pad_m, large_min))
v <- v |> left_join(amb, by = "site_visit")
add("info", "small_visits", nrow(sm), sprintf("picked MAD < %g", small_max))
add("info", "ambiguous_placement", sum(v$ambiguous %in% TRUE),
    sprintf("CH caught on %d", sum(v$present_CH & v$ambiguous %in% TRUE)))
dbDisconnect(conn)

# ---- small streams: distance downstream to the first large river -------------
starts <- v |> filter(mad_pick < small_max) |> distinct(blue_line_key, downstream_route_measure)
fn_sql <- paste(readLines(path_sql), collapse = "\n")
walk_chunk <- function(chunk, fn_sql, large_min, pg) {
  conn <- pg()
  on.exit(DBI::dbDisconnect(conn))
  DBI::dbExecute(conn, fn_sql)
  out <- lapply(seq_len(nrow(chunk)), function(i) {
    r <- DBI::dbGetQuery(conn, "SELECT * FROM pg_temp.ch_dist_large($1::integer, $2, $3)",
                         params = list(chunk$blue_line_key[i], chunk$downstream_route_measure[i], large_min))
    cbind(chunk[i, ], r)
  })
  do.call(rbind, out)
}
t0 <- Sys.time()
chunks <- split(starts, rep_len(seq_len(n_workers * 8), nrow(starts)))
cl <- parallel::makeCluster(n_workers)
tr <- tryCatch(parallel::parLapply(cl, chunks, walk_chunk, fn_sql = fn_sql, large_min = large_min, pg = pg),
               finally = parallel::stopCluster(cl))
tr <- bind_rows(tr)
if (nrow(tr) != nrow(starts)) stop("walks returned ", nrow(tr), " rows for ", nrow(starts), " starts")
add("info", "walk_starts", nrow(starts),
    sprintf("%.1f min on %d workers", as.numeric(difftime(Sys.time(), t0, units = "mins")), n_workers))
for (s in sort(unique(tr$status))) add("info", paste0("walk_", s), sum(tr$status == s))
v <- v |>
  left_join(tr |> select(blue_line_key, downstream_route_measure, walk_status = status,
                         dist_large_m = dist_m, large_mad, large_lfid, large_edge,
                         large_waterbody_key, walk_hops = n_hops, walk_entry_gap_m = max_entry_gap_m),
            by = c("blue_line_key", "downstream_route_measure"))
v <- v |> mutate(large_is_lake = !is.na(large_waterbody_key) & large_waterbody_key %in% lake_keys)
add("info", "large_is_lake", sum(v$large_is_lake))

v <- v |>
  select(site_visit, dup_of, watershed_group_code, blue_line_key, downstream_route_measure,
         linear_feature_id, distance_to_stream, data_set, agency, year, month, n_pass,
         fishing_time_s, area_m2, fished_length_m, wetted_width_m, edge_type, stream_order,
         fwa_gradient, side_channel, in_lake, in_river_poly, catch_status, n_caught_all,
         present_CH, n_ch, flow_from, mad_pick, pick_source, mad_routed, mad_balance,
         mad_fwapg = mad_m3s, regulated, access_covered, ch_barrier_dnstr, ch_barrier_dnstr_no_user,
         ambiguous, walk_status, dist_large_m, large_mad, large_lfid, large_edge,
         large_waterbody_key, large_is_lake, walk_hops, walk_entry_gap_m)
add("kept", "visits_kept", nrow(v))
add("info", "ch_present_kept", sum(v$present_CH))

ins <- sum(ledger$n[ledger$kind == "in"])
out <- sum(ledger$n[ledger$kind %in% c("drop", "kept")])
if (ins != out) stop("ledger does not partition the input: ", ins, " in, ", out, " out")
write_csv(v, path_out, na = "")
write_csv(ledger, path_ledger, na = "")
print(ledger, n = Inf)
