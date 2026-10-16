# scripts/0298-ch-rule-compare.R
# ---------------------------------------------------------------------------
# Sets 0297's recommended CH rearing rule beside link's `default` on link's own segments, in the
# groups where fresh_default classified CH: rearing km, segments gained and lost, FDIS detection
# on each, bcfishobs records FDIS does not hold, and maps. Issue #54. Nothing changes in link.
#
# WHY / DESIGN NOTES (planning archive for #54: findings.md, review-plan.md B1, G7-G9):
#   - BOTH RULES REGENERATED THE SAME WAY. Stored CH rearing comes from link runs of unknown
#     vintage, and it is the predicate gated by access, then the user-habitat overlay, then
#     fresh's connectivity pass (rearing clusters connected to spawning, and the lake and wetland
#     buckets' spawning test). Here both rules go through those same steps on scratch copies,
#     with stored access and spawning: the rule's predicate in SQL (0297's rule_in, written over
#     segments), fresh::frs_habitat_overlay() with link's CH overlay rows, and
#     fresh's .frs_run_connectivity() with link's `default` params, the call
#     lnk_pipeline_connect() makes. Regenerated `default` is reported against the stored flags.
#   - CHECK: the SQL predicate for `default` equals the one fresh::frs_habitat_predicates()
#     builds from link's configs/default, on every segment (stops otherwise).
#   - THREE RULES: `default` as it runs (every group on `cw`: width >= 1.5 m); `default_mad`,
#     the same bundle's MAD bounds (0.28-100 m3/s, bcfishpass's), as fresh's `mad` model builds
#     them for a group moved to `mad` (the river-polygon branch then takes the MAD range too); and
#     the tuned rule. default_mad reads wet's `pick`, the flow the tuned rule reads, so the two
#     differ by rule alone; link main still reads fwapg's old MAD until link#331.
#   - THE TUNED RULE changes the gradient on the stream and river branches, as a threshold in
#     link's CSV would, and keeps default's river test (a non-NULL width); the scoring in 0297 saw
#     the stream branch only. A segment's exception distance is walked from its downstream end
#     (scripts/sql/ch_dist_profile.sql on `pick`); 0296 walked from the visit's own point.
#   - LINK INPUTS come from a pinned commit of the link repository (`link_sha`), read with
#     git show, so the run does not depend on the installed link or a moving checkout.
#   - FDIS DETECTION: 0296's visits on link segments (0290's placement) in 0295's population; the
#     raw CH rate on segments that rear CH under each rule against those that do not.
#   - OUTSIDE CHECK, by lnk_habitat_validate()'s conventions: bcfishobs CH records not from FDIS,
#     match types A/B, one per blue line x metre, spawn-staged-only locations out (link's stage
#     regexes), locations inside a CH rearing overlay reach out (captured by construction). Placed
#     on the segment starting within 1 m, else the one containing the point. Criterion fixed
#     before the run: lift = (share of locations on rearing) / (rearing km / accessible km), with a
#     200-resample bootstrap of locations for each rule and for tuned minus each other rule. Both
#     shares are on stream edges (revised after the first run, round-1 review: the location share
#     had counted river, lake and wetland locations against a stream-only km share).
#   - MAPS, groups chosen by criteria fixed before drawing: small-stream-heavy, the group with
#     the largest share of accessible stream km on order 1-2; interior, the group with the largest
#     share of its FDIS visits in hydrologic zones 15, 17, 23 or 24 (where wet's balance is
#     weakest); coastal, the group with the largest share of its visits whose 10 m3/s walk reaches
#     the sea. Each map shows accessible stream segments by rule and FDIS visits that caught CH.
#
# INPUT:  data/ch_rule_tune.csv (scripts/0297), data/fdis/derived/ch_rule_visits.csv and
#         ch_rule_walks.csv (scripts/0296), scripts/sql/ch_dist_profile.sql; local fwapg :5432
#         (fresh_default, bcfishobs, discharge, whse_basemapping); the link repository at
#         `link_repo`, commit `link_sha`
# WRITES: schema ch_rule_scratch in local fwapg (scratch copies; never fresh_default)
# OUTPUT: data/ch_rule_compare.csv   one row per group and a total: km and segments by rule
#         data/ch_rule_checks.csv    FDIS detection and the outside check, by rule
#         data/ch_rule_change.csv    km and segments gained and lost (tuned against default), by
#                                    reason and stream order
#         research/fig/chinook_rearing_tuned_<wsg>.png
#         scripts/logs/habitat/<date>_ch_rule_compare.txt
# RUN:    Rscript scripts/0298-ch-rule-compare.R   (after 0297, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
options(warn = 1)

link_repo <- Sys.getenv("LINK_REPO", file.path(Sys.getenv("HOME"), "Projects/repo/link"))
link_sha <- "62fae0bb8667779b9abd0533e9c45b206616b544"    # link main, 2026-10-15
scratch <- "ch_rule_scratch"
edge_stream <- c(1000, 1100, 2000, 2300)
edge_wetland <- c(1000, 1100, 1050, 1150)
edge_lake <- c(1000, 1100, 1200, 1250, 1300, 1350, 1400, 1450, 1475)
wetland_ha_min <- 1
lake_ha_min <- 100
interior_zones <- c("15", "17", "23", "24")
n_workers <- 4
n_boot <- 200
seed_boot <- 542L
path_tune <- "data/ch_rule_tune.csv"
path_sql <- "scripts/sql/ch_dist_profile.sql"
path_out <- "data/ch_rule_compare.csv"
path_checks <- "data/ch_rule_checks.csv"
path_change <- "data/ch_rule_change.csv"
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_ch_rule_compare.txt"))

log_lines <- character()
say <- function(...) log_lines <<- c(log_lines, sprintf(...))
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title),
                  capture.output(print(as.data.frame(x), row.names = FALSE)))
}
pg <- function() {
  tryCatch(DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 5432, dbname = "fwapg",
                          user = "postgres", password = "postgres", bigint = "numeric"),
           error = function(e) stop("local fwapg :5432 unreachable: ", conditionMessage(e)))
}

# ---- link inputs at a pinned commit ------------------------------------------------
link_dir <- tempfile("link_default")
dir.create(link_dir)
link_file <- function(path) {
  out <- file.path(link_dir, basename(path))
  st <- system2("git", c("-C", link_repo, "show", paste0(link_sha, ":", path)), stdout = out)
  if (!identical(st, 0L) || !file.exists(out) || file.size(out) == 0) {
    stop("could not read ", path, " at link ", link_sha, " from ", link_repo)
  }
  out
}
cfg <- "inst/extdata/configs/default"
f_thr <- link_file(file.path(cfg, "parameters_habitat_thresholds.csv"))
f_rules <- link_file(file.path(cfg, "rules.yaml"))
f_fresh <- link_file(file.path(cfg, "parameters_fresh.csv"))
f_uhc <- link_file(file.path(cfg, "overrides/user_habitat_classification.csv"))
params <- fresh::frs_params(csv = f_thr, rules_yaml = f_rules)
params_fresh <- read.csv(f_fresh, stringsAsFactors = FALSE)
uhc <- read_csv(f_uhc, show_col_types = FALSE) |> filter(species_code == "CH")
say("CH rule compare, knowledge#54. link %s; fresh %s; CH overlay rows %d.", link_sha,
    as.character(packageVersion("fresh")), nrow(uhc))

tune <- read_csv(path_tune, show_col_types = FALSE)
rec <- tune |> filter(analysis == "main", recommended)
dflt <- tune |> filter(analysis == "main", is_default)
stopifnot(nrow(rec) == 1, nrow(dflt) == 1)
say("Tuned rule: %s. Default: %s.", rec$rule, dflt$rule)

# ---- the predicate in SQL ----------------------------------------------------------
in_list <- function(x) paste(x, collapse = ", ")
wb_sql <- sprintf("
  CREATE TEMPORARY TABLE tmp_wb AS
  SELECT DISTINCT waterbody_key, 'R' AS t FROM whse_basemapping.fwa_rivers_poly
  UNION SELECT DISTINCT waterbody_key, 'W' FROM whse_basemapping.fwa_wetlands_poly WHERE area_ha >= %1$s
  UNION SELECT DISTINCT waterbody_key, 'L' FROM whse_basemapping.fwa_lakes_poly WHERE area_ha >= %2$s
  UNION SELECT DISTINCT waterbody_key, 'M' FROM whse_basemapping.fwa_manmade_waterbodies_poly WHERE area_ha >= %2$s",
  wetland_ha_min, lake_ha_min)
rule_sql <- function(r, a = "s") {
  size <- if (r$size_var == "width") sprintf("%1$s.channel_width BETWEEN %2$s AND 9999", a, r$size_min) else
    sprintf("%s.mad >= %s", a, r$size_min)
  river_size <- sprintf("%s.channel_width BETWEEN 0 AND 9999", a)   # default's river test, every rule (0297)
  ex <- if (is.na(r$exc_q)) "FALSE" else sprintf("coalesce(%s.exc_dist <= %s, FALSE)", a, r$exc_d)
  g <- sprintf("%s.gradient BETWEEN 0 AND %s", a, r$grad_max)
  sprintf("coalesce((%1$s.edge_type IN (%2$s) AND %3$s AND (%4$s OR %5$s))
     OR (%1$s.waterbody_key IN (SELECT waterbody_key FROM tmp_wb WHERE t = 'R') AND %3$s AND %6$s)
     OR (%1$s.edge_type IN (%7$s) AND %1$s.waterbody_key IN (SELECT waterbody_key FROM tmp_wb WHERE t = 'W'))
     OR (%1$s.edge_type IN (%8$s) AND %1$s.waterbody_key IN (SELECT waterbody_key FROM tmp_wb WHERE t IN ('L', 'M'))), FALSE)",
    a, in_list(edge_stream), g, size, ex, river_size, in_list(edge_wetland), in_list(edge_lake))
}

conn <- pg()
dbExecute(conn, wb_sql)
wsgs <- sort(dbGetQuery(conn, "SELECT DISTINCT watershed_group_code w FROM fresh_default.streams_habitat_ch")$w)
wsg_in <- paste0("'", wsgs, "'", collapse = ",")
say("Groups where fresh_default classified CH: %d.", length(wsgs))

# check: the SQL default equals fresh's own predicate on every segment
fp <- fresh::frs_habitat_predicates(list(species_code = "CH", params_sp = params$CH, spawn_gradient_min = 0,
                                         spawn_gradient_max = params$CH$ranges$spawn$gradient[2]), "cw")
chk <- dbGetQuery(conn, sprintf("
  SELECT count(*) AS n,
         count(*) FILTER (WHERE (%1$s) IS DISTINCT FROM coalesce((%2$s), FALSE)) AS differ
  FROM (SELECT s.*, NULL::float8 AS mad, NULL::float8 AS exc_dist FROM fresh_default.streams s
        WHERE s.watershed_group_code IN (%3$s)) s",
  rule_sql(dflt), fp$rear, wsg_in))
say("Check: SQL default against fresh::frs_habitat_predicates() on %d segments: %d differ.", chk$n, chk$differ)
if (chk$differ > 0) stop("the SQL default predicate differs from fresh's on ", chk$differ, " segments")
fp_mad <- fresh::frs_habitat_predicates(list(species_code = "CH", params_sp = params$CH, spawn_gradient_min = 0,
                                             spawn_gradient_max = params$CH$ranges$spawn$gradient[2]), "mad")
log_lines <- c(log_lines, "default_mad: fresh's `mad` rear predicate, on wet's pick as mad_m3s:", fp_mad$rear)

# ---- exception walks for segments only the exception can admit ----------------------
dbExecute(conn, sprintf("
  CREATE TEMPORARY TABLE tmp_seg AS
  SELECT s.id_segment, s.watershed_group_code, s.linear_feature_id, s.blue_line_key,
         s.downstream_route_measure, s.edge_type, s.gradient, s.channel_width, s.waterbody_key,
         s.stream_order, s.length_metre, h.accessible, h.spawning, h.rearing AS rearing_stored,
         h.lake_rearing AS lake_rearing_stored, h.wetland_rearing AS wetland_rearing_stored,
         q.q_m3s AS mad, q.q_m3s AS mad_m3s, NULL::float8 AS exc_dist
  FROM fresh_default.streams s
  JOIN fresh_default.streams_habitat_ch h
    ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
  LEFT JOIN discharge.fwa_v1_segment_monthly q
    ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick
  WHERE s.watershed_group_code IN (%s)", wsg_in))
dbExecute(conn, "CREATE INDEX ON tmp_seg (id_segment, watershed_group_code)")
if (!is.na(rec$exc_q)) {
  no_ex <- rec; no_ex$exc_q <- NA
  starts <- dbGetQuery(conn, sprintf("
    SELECT DISTINCT blue_line_key, downstream_route_measure FROM tmp_seg s
    WHERE s.accessible AND s.edge_type IN (%s) AND s.gradient BETWEEN 0 AND %s AND NOT (%s)",
    in_list(edge_stream), rec$grad_max, rule_sql(no_ex)))
  fn_sql <- paste(readLines(path_sql), collapse = "\n")
  walk_chunk <- function(chunk, fn_sql, q, pg) {
    conn <- pg()
    on.exit(DBI::dbDisconnect(conn))
    DBI::dbExecute(conn, fn_sql)
    do.call(rbind, lapply(seq_len(nrow(chunk)), function(i) {
      r <- DBI::dbGetQuery(conn, "SELECT dist_m, status FROM pg_temp.ch_dist_profile($1::integer, $2, $3::float8[], 'pick')",
                           params = list(chunk$blue_line_key[i], chunk$downstream_route_measure[i], paste0("{", q, "}")))
      cbind(chunk[i, ], r)
    }))
  }
  t0 <- Sys.time()
  cl <- parallel::makeCluster(n_workers)
  wk <- tryCatch(parallel::parLapply(cl, split(starts, rep_len(seq_len(n_workers * 8), nrow(starts))),
                                     walk_chunk, fn_sql = fn_sql, q = rec$exc_q, pg = pg),
                 finally = parallel::stopCluster(cl))
  wk <- bind_rows(wk)
  if (nrow(wk) != nrow(starts)) stop("segment walks returned ", nrow(wk), " rows for ", nrow(starts))
  say("Exception walks: %d segment starts at Q %g on pick, %.1f min on %d workers; found %d.",
      nrow(starts), rec$exc_q, as.numeric(difftime(Sys.time(), t0, units = "mins")), n_workers,
      sum(wk$status == "found"))
  dbWriteTable(conn, "tmp_walk", wk |> filter(status == "found") |> select(blue_line_key, downstream_route_measure, dist_m),
               temporary = TRUE, overwrite = TRUE)
  dbExecute(conn, "UPDATE tmp_seg s SET exc_dist = w.dist_m FROM tmp_walk w
                   WHERE w.blue_line_key = s.blue_line_key AND w.downstream_route_measure = s.downstream_route_measure")
}

# ---- classify, overlay and connect each rule, group by group ----------------------
dbExecute(conn, sprintf("CREATE SCHEMA IF NOT EXISTS %s", scratch))
dbWriteTable(conn, Id(schema = scratch, table = "uhc"), uhc, overwrite = TRUE)
run_conn <- getFromNamespace(".frs_run_connectivity", "fresh")
rule_preds <- list(default = rule_sql(dflt), default_mad = sprintf("coalesce((%s), FALSE)", fp_mad$rear),
                   tuned = rule_sql(rec))
flags <- list()
t0 <- Sys.time()
for (w in wsgs) {
  dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s.streams", scratch))
  dbExecute(conn, sprintf("CREATE TABLE %s.streams AS SELECT * FROM fresh_default.streams
                           WHERE watershed_group_code = '%s'", scratch, w))
  dbExecute(conn, sprintf("CREATE INDEX ON %s.streams (id_segment)", scratch))
  dbExecute(conn, sprintf("CREATE INDEX ON %s.streams USING gist (geom)", scratch))
  dbExecute(conn, sprintf("CREATE INDEX ON %s.streams USING gist (wscode_ltree)", scratch))
  dbExecute(conn, sprintf("CREATE INDEX ON %s.streams USING gist (localcode_ltree)", scratch))
  dbExecute(conn, sprintf("CREATE INDEX ON %s.streams (blue_line_key, downstream_route_measure)", scratch))
  for (k in names(rule_preds)) {
    h <- paste0(scratch, ".habitat_", k)
    dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s", h))
    dbExecute(conn, sprintf("CREATE TABLE %1$s AS
      SELECT s.id_segment, s.watershed_group_code, 'CH'::text AS species_code, s.accessible, s.spawning,
             s.accessible AND %2$s AS rearing,
             s.accessible AND coalesce(s.waterbody_key IN (SELECT waterbody_key FROM tmp_wb WHERE t = 'L'), FALSE) AS lake_rearing,
             s.accessible AND coalesce(s.waterbody_key IN (SELECT waterbody_key FROM tmp_wb WHERE t = 'W'), FALSE) AS wetland_rearing,
             FALSE AS rearing_pre_connect
      FROM tmp_seg s WHERE s.watershed_group_code = '%3$s'", h, rule_preds[[k]], w))
    dbExecute(conn, sprintf("UPDATE %s SET rearing_pre_connect = rearing", h))
    dbExecute(conn, sprintf("CREATE INDEX ON %s (id_segment)", h))
    fresh::frs_habitat_overlay(conn, from = paste0(scratch, ".uhc"), to = h, bridge = paste0(scratch, ".streams"),
                               species = "CH", habitat_types = "rearing", verbose = FALSE)
    run_conn(conn, table = paste0(scratch, ".streams"), habitat = h, species = "CH", params = params,
             params_fresh = params_fresh, verbose = FALSE)
    flags[[paste(w, k)]] <- dbGetQuery(conn, sprintf(
      "SELECT id_segment, watershed_group_code, '%s' AS rule, rearing, lake_rearing, wetland_rearing, rearing_pre_connect
       FROM %s", k, h))
  }
}
say("Classify, overlay and connect: %d groups x %d rules, %.1f min.", length(wsgs), length(rule_preds),
    as.numeric(difftime(Sys.time(), t0, units = "mins")))
seg <- dbGetQuery(conn, "SELECT id_segment, watershed_group_code, linear_feature_id, blue_line_key,
                                downstream_route_measure, edge_type, stream_order, length_metre, accessible,
                                gradient, channel_width, mad, exc_dist,
                                rearing_stored, lake_rearing_stored, wetland_rearing_stored
                         FROM tmp_seg")
fl <- bind_rows(flags) |>
  tidyr::pivot_wider(id_cols = c(id_segment, watershed_group_code), names_from = rule,
                     values_from = c(rearing, lake_rearing, wetland_rearing, rearing_pre_connect))
seg <- seg |> left_join(fl, by = c("id_segment", "watershed_group_code"))
if (anyNA(seg$rearing_default) || anyNA(seg$rearing_default_mad) || anyNA(seg$rearing_tuned)) {
  stop("a segment has no regenerated flag")
}

# ---- per group --------------------------------------------------------------------
km <- function(x, len) sum(len[x %in% TRUE]) / 1000
per <- seg |>
  group_by(watershed_group_code) |>
  summarise(accessible_km = km(accessible, length_metre),
            accessible_stream_km = km(accessible & edge_type %in% edge_stream, length_metre),
            stored_rear_km = km(rearing_stored, length_metre),
            default_rear_km = km(rearing_default, length_metre),
            default_mad_rear_km = km(rearing_default_mad, length_metre),
            tuned_rear_km = km(rearing_tuned, length_metre),
            stored_vs_default_differ_km = km(rearing_stored != rearing_default, length_metre),
            gained_n = sum(rearing_tuned & !rearing_default), gained_km = km(rearing_tuned & !rearing_default, length_metre),
            lost_n = sum(!rearing_tuned & rearing_default), lost_km = km(!rearing_tuned & rearing_default, length_metre),
            vs_mad_gained_km = km(rearing_tuned & !rearing_default_mad, length_metre),
            vs_mad_lost_km = km(!rearing_tuned & rearing_default_mad, length_metre),
            lake_rear_km = km(lake_rearing_tuned, length_metre), wetland_rear_km = km(wetland_rearing_tuned, length_metre),
            lake_wetland_same = all(lake_rearing_tuned == lake_rearing_default & wetland_rearing_tuned == wetland_rearing_default),
            order12_share = km(accessible & edge_type %in% edge_stream & stream_order <= 2, length_metre) /
              km(accessible & edge_type %in% edge_stream, length_metre),
            .groups = "drop") |>
  mutate(change_pct = 100 * (tuned_rear_km - default_rear_km) / default_rear_km,
         mad_change_pct = 100 * (default_mad_rear_km - default_rear_km) / default_rear_km)
tot <- per |> summarise(watershed_group_code = "ALL", across(where(is.numeric) & !c(order12_share, change_pct), sum),
                        lake_wetland_same = all(lake_wetland_same)) |>
  mutate(change_pct = 100 * (tuned_rear_km - default_rear_km) / default_rear_km,
         mad_change_pct = 100 * (default_mad_rear_km - default_rear_km) / default_rear_km)
compare <- bind_rows(per, tot) |> mutate(default_rule = dflt$rule, tuned_rule = rec$rule)
block("rearing km by group", compare |> mutate(across(where(is.numeric), ~ round(.x, 1))))

# ---- why segments change between default and tuned ------------------------------------
# reason from the predicate's parts where the predicates differ; where both predicates hold
# (or both fail), the difference came from the overlay or the connectivity pass
ex_on <- !is.na(rec$exc_q)
chg <- seg |>
  filter(rearing_default != rearing_tuned) |>
  mutate(direction = if_else(rearing_tuned, "gained", "lost"),
         stream = edge_type %in% edge_stream,
         g_def = coalesce(gradient >= 0 & gradient <= dflt$grad_max, FALSE),
         g_tun = coalesce(gradient >= 0 & gradient <= rec$grad_max, FALSE),
         w_ok = coalesce(channel_width >= dflt$size_min & channel_width <= 9999, FALSE),
         size_tun = if (rec$size_var == "mad") coalesce(mad >= rec$size_min, FALSE) else
           coalesce(channel_width >= rec$size_min & channel_width <= 9999, FALSE),
         ex_ok = ex_on & coalesce(exc_dist <= rec$exc_d, FALSE),
         reason = case_when(
           rearing_pre_connect_default == rearing_pre_connect_tuned ~ "connectivity or overlay",
           direction == "gained" & stream & g_tun & !size_tun & ex_ok ~ "exception (size fails, river within D)",
           direction == "gained" & stream & size_tun & g_tun & w_ok & !g_def ~ "gradient between the two maxima",
           direction == "gained" & stream & size_tun & g_tun & !w_ok ~ "size: tuned passes, width fails or NULL",
           direction == "lost" & stream & w_ok & g_def & !size_tun & !ex_ok ~ "size: width passes, tuned fails, no exception",
           TRUE ~ "other (river-polygon branch or mixed)"),
         order = case_when(stream_order <= 1 ~ "1", stream_order == 2 ~ "2", stream_order == 3 ~ "3", TRUE ~ "4+"))
change <- chg |>
  group_by(direction, reason, order) |>
  summarise(n_segments = n(), km = sum(length_metre) / 1000, .groups = "drop") |>
  mutate(default_rule = dflt$rule, tuned_rule = rec$rule)
block("km gained and lost, tuned against default, by reason",
      change |> group_by(direction, reason) |> summarise(n_segments = sum(n_segments), km = round(sum(km), 1), .groups = "drop"))
block("km gained and lost, tuned against default, by stream order",
      change |> group_by(direction, order) |> summarise(km = round(sum(km), 1), .groups = "drop"))

# ---- FDIS detection on each rule's segments ------------------------------------------
vis <- read_csv("data/fdis/derived/ch_rule_visits.csv", show_col_types = FALSE, guess_max = 1e5,
                col_types = cols(site_visit = "c", dup_of = "c", hydro_zone = "c")) |>
  filter(edge_type %in% c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350), !is.na(area_m2),
         area_m2 >= 10, area_m2 <= 10000, is.na(dup_of), !is.na(link_id_segment))
vd <- vis |> inner_join(seg |> select(link_id_segment = id_segment, watershed_group_code, accessible,
                                      rearing_default, rearing_default_mad, rearing_tuned),
                        by = c("link_id_segment", "watershed_group_code"))
det <- bind_rows(lapply(names(rule_preds), function(k) {
  r <- vd[[paste0("rearing_", k)]]
  tibble(check = "fdis_visits", rule = k, segment = c("rearing", "accessible_not_rearing"),
         n = c(sum(r), sum(vd$accessible & !r)), n_ch = c(sum(vd$present_CH[r]), sum(vd$present_CH[vd$accessible & !r])))
})) |> mutate(rate = n_ch / n)
block("FDIS visits on link segments: raw CH rate", det)

# ---- outside check: bcfishobs records FDIS does not hold ------------------------------
obs <- dbGetQuery(conn, sprintf("
  SELECT o.observation_key, o.watershed_group_code, o.blue_line_key, o.downstream_route_measure,
         o.activity_code, o.activity, o.life_stage, o.match_type, o.observation_date
  FROM bcfishobs.observations o
  WHERE o.species_code = 'CH' AND coalesce(o.source, '') !~ '^FDIS' AND o.watershed_group_code IN (%s)", wsg_in))
n0 <- nrow(obs)
obs <- obs |> filter(substr(match_type, 1, 1) %in% c("A", "B"))
yr <- as.integer(format(as.Date(obs$observation_date), "%Y"))
act <- paste(obs$activity_code, obs$activity)
obs <- obs |> mutate(is_spawn = grepl("\\bSPL\\b|\\bSPM\\b|\\bS\\b|Spawning", act),
                     is_rear = grepl("\\bR\\b|\\bREA\\b|Rearing", act) | grepl("Fry|Parr|Juvenile", coalesce(life_stage, "")),
                     m = round(downstream_route_measure))
loc <- obs |> group_by(watershed_group_code, blue_line_key, m) |>
  summarise(spawn = any(is_spawn), rear = any(is_rear), n_records = n(), .groups = "drop") |>
  filter(!(spawn & !rear))
dbWriteTable(conn, "tmp_loc", loc |> mutate(loc_id = row_number()), temporary = TRUE, overwrite = TRUE)
pl <- dbGetQuery(conn, sprintf("
  SELECT DISTINCT ON (t.loc_id) t.loc_id, s.id_segment,
         EXISTS (SELECT 1 FROM %s.uhc u WHERE u.blue_line_key = t.blue_line_key AND u.rearing = 1
                   AND t.m BETWEEN u.downstream_route_measure AND u.upstream_route_measure) AS in_uhc
  FROM tmp_loc t
  JOIN tmp_seg s ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
   AND ((s.downstream_route_measure BETWEEN t.m - 1 AND t.m + 1)
        OR (t.m >= s.downstream_route_measure AND t.m < s.downstream_route_measure + s.length_metre))
  ORDER BY t.loc_id, (s.downstream_route_measure BETWEEN t.m - 1 AND t.m + 1) DESC,
           s.downstream_route_measure DESC, s.id_segment", scratch))
rk <- names(rule_preds)
loc <- loc |> mutate(loc_id = row_number()) |> inner_join(pl, by = "loc_id") |> filter(!in_uhc) |>
  inner_join(seg |> select(id_segment, watershed_group_code, edge_type, accessible,
                           all_of(paste0("rearing_", rk))),
             by = c("id_segment", "watershed_group_code"))
# lift compares a share of locations with a share of km, so both are taken on stream edges: the
# km share is stream-edge rearing km over accessible stream-edge km
loc_s <- loc |> filter(edge_type %in% edge_stream)
say("")
say("Outside check: %d non-FDIS CH records in these groups; %d match A/B (years %d-%d, %d undated); %d locations not spawn-only, placed, outside the overlay; %d of them on stream edges (lift is on these).",
    n0, nrow(obs), min(yr, na.rm = TRUE), max(yr, na.rm = TRUE), sum(is.na(yr)), nrow(loc), nrow(loc_s))
acc_km <- km(seg$accessible & seg$edge_type %in% edge_stream, seg$length_metre)
ks <- function(k) km(seg[[paste0("rearing_", k)]] & seg$edge_type %in% edge_stream, seg$length_metre) / acc_km
lift <- function(l, k, idx = seq_len(nrow(l))) mean(l[[paste0("rearing_", k)]][idx]) / ks(k)
set.seed(seed_boot)
bs <- t(vapply(seq_len(n_boot), function(b) {
  i <- sample.int(nrow(loc_s), nrow(loc_s), replace = TRUE)
  vapply(rk, function(k) lift(loc_s, k, i), numeric(1))
}, numeric(length(rk))))
q <- function(x, p) unname(quantile(x, p))
on <- function(l, k) l[[paste0("rearing_", k)]]
vs <- function(k) c(n_gained = sum(on(loc_s, "tuned") & !on(loc_s, k)), n_lost = sum(!on(loc_s, "tuned") & on(loc_s, k)))
outside <- bind_rows(
  tibble(check = "bcfishobs_outside", rule = rk, n = nrow(loc_s),
         n_on_rearing = vapply(rk, function(k) sum(on(loc_s, k)), numeric(1)),
         km_share = vapply(rk, ks, numeric(1)),
         lift = vapply(rk, function(k) lift(loc_s, k), numeric(1)),
         lift_lo = apply(bs, 2, q, 0.025), lift_hi = apply(bs, 2, q, 0.975),
         n_all = nrow(loc), n_all_on_rearing = vapply(rk, function(k) sum(on(loc, k)), numeric(1))),
  tibble(check = "bcfishobs_outside", rule = c("tuned_minus_default", "tuned_minus_default_mad"), n = nrow(loc_s),
         lift = c(lift(loc_s, "tuned") - lift(loc_s, "default"), lift(loc_s, "tuned") - lift(loc_s, "default_mad")),
         lift_lo = c(q(bs[, "tuned"] - bs[, "default"], 0.025), q(bs[, "tuned"] - bs[, "default_mad"], 0.025)),
         lift_hi = c(q(bs[, "tuned"] - bs[, "default"], 0.975), q(bs[, "tuned"] - bs[, "default_mad"], 0.975)),
         n_gained = c(vs("default")[["n_gained"]], vs("default_mad")[["n_gained"]]),
         n_lost = c(vs("default")[["n_lost"]], vs("default_mad")[["n_lost"]]))) |>
  mutate(capture_share = n_on_rearing / n)
block("outside check, stream-edge locations (km share: stream-edge rearing km / accessible stream-edge km)", outside)

# ---- maps ----------------------------------------------------------------------------------
zone_share <- vis |> group_by(watershed_group_code) |> summarise(interior = mean(hydro_zone %in% interior_zones))
wk_all <- read_csv("data/fdis/derived/ch_rule_walks.csv", show_col_types = FALSE) |>
  filter(src == "pick", qmin == 10)
sea_share <- vis |> left_join(wk_all |> select(blue_line_key, downstream_route_measure, status),
                              by = c("blue_line_key", "downstream_route_measure")) |>
  group_by(watershed_group_code) |> summarise(sea = mean(status == "none", na.rm = TRUE))
cand <- per |> select(watershed_group_code, order12_share) |>
  left_join(zone_share, by = "watershed_group_code") |> left_join(sea_share, by = "watershed_group_code")
picks <- c(small_stream = cand$watershed_group_code[which.max(cand$order12_share)],
           interior = cand$watershed_group_code[which.max(coalesce(cand$interior, 0))],
           coastal = cand$watershed_group_code[which.max(coalesce(cand$sea, 0))])
block("map groups (criteria in the header)", cand |> filter(watershed_group_code %in% picks) |>
        mutate(role = names(picks)[match(watershed_group_code, picks)]))
suppressMessages(library(ggplot2))
for (role in names(picks)) {
  w <- picks[[role]]
  g <- sf::st_read(conn, query = sprintf("SELECT id_segment, geom FROM fresh_default.streams
                                          WHERE watershed_group_code = '%s'", w), quiet = TRUE) |>
    inner_join(seg |> filter(watershed_group_code == w, accessible, edge_type %in% c(edge_stream, 1250, 1350)) |>
                 transmute(id_segment, cls = case_when(rearing_default & rearing_tuned ~ "both",
                                                       rearing_default ~ "default only",
                                                       rearing_tuned ~ "tuned only",
                                                       TRUE ~ "accessible, neither")),
               by = "id_segment")
  pts <- vis |> filter(watershed_group_code == w, present_CH) |> select(linear_feature_id)
  pg_pts <- if (nrow(pts) > 0) sf::st_read(conn, query = sprintf(
    "SELECT linear_feature_id, ST_LineInterpolatePoint(ST_Force2D(geom), 0.5) AS geom
     FROM whse_basemapping.fwa_stream_networks_sp WHERE linear_feature_id IN (%s)",
    paste(unique(pts$linear_feature_id), collapse = ",")), quiet = TRUE) else NULL
  p <- ggplot() +
    geom_sf(data = g, aes(colour = cls), linewidth = 0.3) +
    scale_colour_manual(values = c("both" = "#1b6ca8", "default only" = "#d95f02", "tuned only" = "#1b9e77",
                                   "accessible, neither" = "grey85"), name = NULL) +
    labs(title = sprintf("%s (%s): CH rearing, default against %s", w, gsub("_", " ", role), rec$rule),
         subtitle = "accessible stream and river segments; points: FDIS visits that caught CH") +
    theme_void(base_size = 9)
  if (!is.null(pg_pts)) p <- p + geom_sf(data = pg_pts, shape = 21, fill = "black", size = 0.8)
  ggsave(sprintf("research/fig/chinook_rearing_tuned_%s.png", tolower(w)), p, width = 7, height = 7,
         dpi = 150, bg = "white")
}

dbExecute(conn, sprintf("DROP SCHEMA %s CASCADE", scratch))
dbDisconnect(conn)
write_csv(compare |> mutate(across(where(is.numeric), ~ round(.x, 3))), path_out, na = "")
write_csv(bind_rows(det, outside) |> mutate(across(where(is.numeric), ~ round(.x, 4))), path_checks, na = "")
write_csv(change |> mutate(km = round(km, 3)), path_change, na = "")
writeLines(log_lines, path_log)
cat(log_lines, sep = "\n")
