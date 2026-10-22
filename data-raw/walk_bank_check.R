# data-raw/walk_bank_check.R
# ---------------------------------------------------------------------------
# The walk ends at the river's bank (#73): knw_link_walks() against fresh 0.42.0's frs_near_river()
# on one watershed group, fresh's own check (fresh's data-raw/near_river_check.R, which took this
# repo's centreline walk as its reference) turned round. fresh is the walk link applies, so the gate
# is that the bank rule here is fresh's: the `bank` class below must hold 0 starts.
#
# METHOD: the group is segmented with frs_network_segment() into a scratch schema and mad_m3s set
# to wet's pick (0 read as no value), as fresh's check does. frs_near_river() walks every segment
# below Q at D_FAR; its walk SQL is run again with the bank rule off for the centreline distance.
# Origins: a seeded sample of main-flow segments below Q with a local code, plus those fresh places
# within 200 m of a river, where the bank rule matters most. knw_link_walks() walks each origin
# from its downstream end (fresh's start), at Q on `pick`. Each origin is classed, first match:
#   agree        both find no river, or the bank distances agree within 1 m
#   bank         the centreline distances agree within 1 m and the bank distances do not, and this walk
#                reached the river's line without a jump (the subtraction is connector rows only): the
#                two bank rules differ. Expected 0.
#   bank_jump    as `bank`, but this walk jumped onto the river's line (a gap of over 1 m): the
#                subtraction includes the jump's crossing of the bank, which depends on the row each
#                walk lands on (fresh: the row FWA_Downstream() orders first; here: the nearest), so a
#                difference of a few metres on a jump of tens or hundreds is the landing point, not
#                the rule. Reported with the jump's length.
#   path         the centreline distances differ by more than 1 m: the two walks took different
#                paths (fresh enters a parent line where the local code puts the confluence; this
#                walk enters at the nearest point; both count the jump), fresh's `entry` and
#                `nested_code` classes. Not the bank rule's. The bank residual is reported for
#                these too, split by whether the origin's own line ends at a side-line connector
#                (FWA drew the connector as a separate line, so the walk jumps from the bank to the
#                centreline): the plan review's case, where a walk that subtracted a jump it never
#                counted would read short while its centreline distance agreed.
#   beyond       fresh found no river within D_FAR; this walk, uncapped, found one further
#   truncation   fresh found no river; this walk's river lies in another watershed group
#   ref_none     this walk found no river where fresh did
#   unexplained  anything else
# INPUT:  fwapg database (PG* env vars): whse_basemapping, discharge; fresh >= 0.42.0
# WRITES: schema knw_walk_bank_check (scratch; dropped)
# OUTPUT: scripts/logs/habitat/<date>_walk_bank_check.txt   the summary
#         scripts/logs/habitat/<date>_walk_bank_check.csv   one row per origin
# RUN:    Rscript data-raw/walk_bank_check.R [WSG] [Q] [D_FAR]      (from the repo root; BULK 3 20000)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")
if (packageVersion("fresh") < "0.42.0") stop("needs fresh >= 0.42.0 (frs_near_river with measure)")

args <- commandArgs(trailingOnly = TRUE)
wsg <- if (length(args) >= 1) toupper(args[1]) else "BULK"
q <- if (length(args) >= 2) as.numeric(args[2]) else 3
d_far <- if (length(args) >= 3) as.numeric(args[3]) else 20000
stopifnot(grepl("^[A-Z]{4}$", wsg), is.finite(q), q > 0, is.finite(d_far), d_far > 0)
n_random <- 2000L
n_near <- 500L
seed <- 73L
stamp <- format(Sys.Date(), "%Y%m%d")
path_txt <- file.path("scripts/logs/habitat", paste0(stamp, "_walk_bank_check.txt"))
path_csv <- file.path("scripts/logs/habitat", paste0(stamp, "_walk_bank_check.csv"))
dir.create("scripts/logs/habitat", showWarnings = FALSE, recursive = TRUE)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }

pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")   # qualified: the walk workers have no DBI attached
conn <- pg()
schema <- "knw_walk_bank_check"
tbl <- paste0(schema, ".streams")
near <- paste0(schema, ".near")

main <- function() {
  say("walk_bank_check %s Q=%g D_FAR=%g; fresh %s, knowledge %s", wsg, q, d_far,
      as.character(packageVersion("fresh")), substr(system2("git", c("rev-parse", "HEAD"), stdout = TRUE), 1, 7))
  dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", schema))
  dbExecute(conn, sprintf("CREATE SCHEMA %s", schema))
  t0 <- Sys.time()
  fresh::frs_network_segment(conn, aoi = wsg, to = tbl, verbose = FALSE)
  dbExecute(conn, sprintf(
    "UPDATE %s s SET mad_m3s = (SELECT nullif(q.q_m3s, 0) FROM discharge.fwa_v1_segment_monthly q
       WHERE q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick)", tbl))
  n <- dbGetQuery(conn, sprintf(
    "SELECT count(*)::int AS segments, count(mad_m3s)::int AS with_mad,
            count(*) FILTER (WHERE mad_m3s >= %g)::int AS at_or_above_q FROM %s", q, tbl))
  say("segmented %s in %.1f min: %d segments, %d with flow, %d at or above Q", wsg,
      as.numeric(difftime(Sys.time(), t0, units = "mins")), n$segments, n$with_mad, n$at_or_above_q)

  # fresh's bank walk, then its centreline walk (the same SQL with the bank rule off)
  t0 <- Sys.time()
  fresh::frs_near_river(conn, tbl, near, threshold = q, distance_max = d_far, measure = "discharge", verbose = FALSE)
  say("frs_near_river at %g within %g m: %.1f s", q, d_far, as.numeric(difftime(Sys.time(), t0, units = "secs")))
  walk_sql <- utils::getFromNamespace(".frs_near_river_walk_sql", "fresh")
  dbExecute(conn, "DROP TABLE IF EXISTS pg_temp.frs_near_river_walk")
  dbExecute(conn, walk_sql(tbl, "pg_temp.frs_near_river_walk", q, d_far, conn_max = 0, entry_max = 0, bank = FALSE))
  fresh_tbl <- dbGetQuery(conn, sprintf(
    "SELECT o.id_segment, o.blue_line_key, o.downstream_route_measure, n.dist_m AS fresh_bank, c.dist_m AS fresh_centre
       FROM %s o
       LEFT JOIN %s n ON n.id_segment = o.id_segment
       LEFT JOIN pg_temp.frs_near_river_walk c ON c.origin_id = o.id_segment
      WHERE o.blue_line_key = o.watershed_key AND o.localcode_ltree IS NOT NULL
        AND (o.mad_m3s IS NULL OR o.mad_m3s < %g)", tbl, near, q))
  # origins whose own line ends at a side-line connector (a 1450 row of another blue line keyed to this watershed)
  side <- dbGetQuery(conn, "SELECT DISTINCT watershed_key FROM whse_basemapping.fwa_stream_networks_sp
                             WHERE edge_type IN (1400, 1450) AND blue_line_key <> watershed_key AND watershed_group_code = $1",
                     params = list(wsg))$watershed_key
  fresh_tbl$side_connector <- fresh_tbl$blue_line_key %in% as.numeric(side)
  say("origins whose line ends at a side-line connector: %d of %d", sum(fresh_tbl$side_connector), nrow(fresh_tbl))
  say("fresh: %d origins (main flow, local code, below Q); %d found a river within %g m, %d within 200 m",
      nrow(fresh_tbl), sum(!is.na(fresh_tbl$fresh_bank)), d_far, sum(fresh_tbl$fresh_bank <= 200, na.rm = TRUE))

  # origins: a seeded sample plus the near ones
  set.seed(seed)
  pick_random <- fresh_tbl[sample.int(nrow(fresh_tbl), min(n_random, nrow(fresh_tbl))), ]
  near_ids <- fresh_tbl[!is.na(fresh_tbl$fresh_bank) & fresh_tbl$fresh_bank <= 200, ]
  pick_near <- near_ids[sample.int(nrow(near_ids), min(n_near, nrow(near_ids))), ]
  origins <- bind_rows(mutate(pick_random, sampled = "random"), mutate(pick_near, sampled = "near")) |>
    distinct(id_segment, .keep_all = TRUE)
  say("origins walked: %d (%d random, %d within 200 m, after dedup)", nrow(origins), nrow(pick_random), nrow(pick_near))

  # this repo's walk from each origin's downstream end
  t0 <- Sys.time()
  w <- knw_link_walks(pg, origins[, c("blue_line_key", "downstream_route_measure")], q_grid = q, sources = "pick", workers = 4L)
  say("knw_link_walks: %d starts in %.1f s", nrow(w), as.numeric(difftime(Sys.time(), t0, units = "secs")))
  tg <- dbGetQuery(conn, "SELECT linear_feature_id AS large_lfid, watershed_group_code AS target_wsg
                            FROM whse_basemapping.fwa_stream_networks_sp WHERE linear_feature_id = ANY($1::bigint[])",
                   params = list(paste0("{", paste(unique(na.omit(w$large_lfid)), collapse = ","), "}")))
  cmp <- origins |>
    inner_join(w |> left_join(tg, by = "large_lfid"), by = c("blue_line_key", "downstream_route_measure")) |>
    mutate(ours_found = status == "found",
           ours_bank = ifelse(ours_found, dist_m, NA_real_),
           ours_centre = ifelse(ours_found, dist_centre_m, NA_real_),
           resid_bank = fresh_bank - ours_bank,
           resid_centre = fresh_centre - ours_centre,
           class = case_when(
             is.na(fresh_bank) & !ours_found ~ "agree",
             !is.na(fresh_bank) & ours_found & abs(resid_bank) <= 1 ~ "agree",
             !is.na(fresh_bank) & ours_found & abs(resid_centre) <= 1 & max_entry_gap_m > 1 ~ "bank_jump",
             !is.na(fresh_bank) & ours_found & abs(resid_centre) <= 1 ~ "bank",
             !is.na(fresh_bank) & ours_found & abs(resid_centre) > 1 ~ "path",
             is.na(fresh_bank) & ours_found & ours_bank > d_far ~ "beyond",
             is.na(fresh_bank) & ours_found & !is.na(target_wsg) & target_wsg != wsg ~ "truncation",
             !is.na(fresh_bank) & !ours_found ~ "ref_none",
             TRUE ~ "unexplained"))
  tab <- cmp |> count(class) |> mutate(share = sprintf("%.1f %%", 100 * n / sum(n)))
  say("classes:\n%s", paste(capture.output(print(as.data.frame(tab), row.names = FALSE)), collapse = "\n"))
  bank_rows <- cmp |> filter(class == "bank")
  if (nrow(bank_rows)) {
    say("BANK CLASS NOT EMPTY (%d): fresh took off %s m where this walk took off %s m (first 10, fresh - ours)",
        nrow(bank_rows),
        paste(round(bank_rows$fresh_centre[1:min(10, nrow(bank_rows))] - bank_rows$fresh_bank[1:min(10, nrow(bank_rows))], 1), collapse = ", "),
        paste(round(bank_rows$bank_m[1:min(10, nrow(bank_rows))], 1), collapse = ", "))
  } else {
    say("bank class: 0 starts. The bank rule here is fresh's.")
  }
  bj <- cmp |> filter(class == "bank_jump")
  if (nrow(bj)) {
    say("bank_jump class (%d): bank residual (fresh - ours) median %.2f m, largest |%.2f| m, on jumps of %.0f to %.0f m (median %.0f); %d distinct rivers",
        nrow(bj), median(bj$resid_bank), max(abs(bj$resid_bank)), min(bj$max_entry_gap_m), max(bj$max_entry_gap_m),
        median(bj$max_entry_gap_m), n_distinct(bj$large_waterbody_key))
  }
  f <- cmp |> filter(ours_found)
  say("this walk's bank_m over %d found starts: %d with bank_m > 0 (%.1f %%); median %.1f m, 90th percentile %.1f m, max %.1f m",
      nrow(f), sum(f$bank_m > 0), 100 * mean(f$bank_m > 0), median(f$bank_m[f$bank_m > 0]),
      quantile(f$bank_m[f$bank_m > 0], 0.9), max(f$bank_m))
  both <- cmp |> filter(class %in% c("agree", "bank", "path"), !is.na(fresh_bank), !is.na(fresh_centre), ours_found)
  say("fresh's subtraction (centre - bank) against ours on %d starts both found with both of fresh's walks: identical within 0.01 m on %d (%.1f %%); within 1 m on %d",
      nrow(both), sum(abs((both$fresh_centre - both$fresh_bank) - both$bank_m) <= 0.01),
      100 * mean(abs((both$fresh_centre - both$fresh_bank) - both$bank_m) <= 0.01),
      sum(abs((both$fresh_centre - both$fresh_bank) - both$bank_m) <= 1))
  path_rows <- cmp |> filter(class == "path")
  if (nrow(path_rows)) {
    say("path class residuals (fresh - ours, centreline): median %.1f m, 5th %.1f, 95th %.1f; largest gap this walk hopped, median %.1f m",
        median(path_rows$resid_centre), quantile(path_rows$resid_centre, 0.05), quantile(path_rows$resid_centre, 0.95),
        median(path_rows$max_entry_gap_m))
  }
  # the bank residual by class and by the side-line-connector flag: a double discount (a jump subtracted but never
  # counted) shows as a negative bank residual on side-connector origins whose centreline distances agree
  qtab <- cmp |> filter(!is.na(fresh_bank), ours_found) |> group_by(class, side_connector) |>
    summarise(n = n(), bank_med = median(resid_bank), bank_p10 = quantile(resid_bank, 0.1), bank_p90 = quantile(resid_bank, 0.9),
              centre_med = median(resid_centre), .groups = "drop")
  say("bank residual (fresh - ours, m) by class and side-line connector:\n%s",
      paste(capture.output(print(as.data.frame(qtab), row.names = FALSE, digits = 4)), collapse = "\n"))
  sc <- cmp |> filter(class %in% c("agree", "bank"), side_connector, ours_found, !is.na(fresh_bank))
  say("side-connector origins both found with agreeing paths: %d; bank residual median %.2f m, 90th percentile of |residual| %.2f m",
      nrow(sc), if (nrow(sc)) median(sc$resid_bank) else NA, if (nrow(sc)) quantile(abs(sc$resid_bank), 0.9) else NA)
  un <- cmp |> filter(class == "unexplained")
  if (nrow(un)) say("UNEXPLAINED (%d): id_segment %s", nrow(un), paste(head(un$id_segment, 20), collapse = ", "))
  readr::write_csv(cmp |> select(id_segment, sampled, side_connector, blue_line_key, downstream_route_measure, fresh_bank, fresh_centre,
                                 ours_bank, ours_centre, bank_m, max_entry_gap_m, n_hops, status, large_lfid, large_edge,
                                 large_waterbody_key, target_wsg, resid_bank, resid_centre, class),
                   path_csv, na = "")
  invisible(cmp)
}

tryCatch(main(), finally = {
  try(dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", schema)), silent = TRUE)
  dbDisconnect(conn)
  writeLines(log_lines, path_txt)
  message("log -> ", path_txt)
})
