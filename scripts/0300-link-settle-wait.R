# scripts/0300-link-settle-wait.R
# ---------------------------------------------------------------------------
# Waits until link's province-wide `default` run has settled in `fresh_default`, then releases.
# Issue #57, phase 0. The evidence build (0310) reads `streams_access`, which the run recomputes
# last, so nothing downstream starts until all three hold on the same poll:
#   1. every group in fresh_default.streams has a log_recompute row with date_end set;
#   2. the summed inserts, updates and deletes over every fresh_default table
#      (pg_stat_user_tables) are unchanged across three polls `poll_min` apart;
#   3. no non-idle session's query names fresh_default (this session excluded).
# Each poll is one row of the log. On release the record carries the run_uid, the log_recompute
# count, the churn value and the release time, and the link, fresh and fwapg SHAs from
# fresh_default.log. After `max_hours` without a release it stops with status `timeout` and a
# non-zero exit, so a waiter on this process reads the file, not the exit alone.
#
# INPUT:  fwapg database (PG* env vars): fresh_default.{streams,log_recompute,log},
#         pg_stat_user_tables, pg_stat_activity
# OUTPUT: scripts/logs/habitat/<date>_link_settle.csv   one row per poll, the last row the verdict
# RUN:    Rscript scripts/0300-link-settle-wait.R   (from the repo root; blocks until released)
# ---------------------------------------------------------------------------
suppressMessages({ library(DBI); library(RPostgres) })

poll_min <- 10
polls_stable <- 3
max_hours <- 24
schema <- "fresh_default"
path_log <- file.path("scripts/logs/habitat",
                      paste0(format(Sys.Date(), "%Y%m%d"), "_link_settle.csv"))

pg <- function() {
  tryCatch(dbConnect(Postgres()),
           error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
}
poll <- function() {
  conn <- pg()
  on.exit(dbDisconnect(conn))
  cov <- dbGetQuery(conn, sprintf("
    SELECT count(DISTINCT s.watershed_group_code) AS n_wsg,
           count(DISTINCT l.watershed_group_code) AS n_ended
    FROM %1$s.streams s
    LEFT JOIN %1$s.log_recompute l
      ON l.watershed_group_code = s.watershed_group_code AND l.date_end IS NOT NULL", schema))
  lr <- dbGetQuery(conn, sprintf(
    "SELECT count(*) AS n_rows, count(DISTINCT run_uid) AS n_runs, max(run_uid) AS run_uid,
            max(date_end) AS last_end FROM %s.log_recompute", schema))
  churn <- dbGetQuery(conn, "
    SELECT coalesce(sum(n_tup_ins + n_tup_upd + n_tup_del), 0)::numeric AS churn, count(*) AS n_tables
    FROM pg_stat_user_tables WHERE schemaname = $1", params = list(schema))
  act <- dbGetQuery(conn, "
    SELECT count(*) AS n_active FROM pg_stat_activity
    WHERE state <> 'idle' AND pid <> pg_backend_pid() AND query ILIKE $1",
    params = list(paste0("%", schema, "%")))
  # counts come back as integer64 / numeric, so each is made a plain integer before formatting
  data.frame(at_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
             n_wsg = as.integer(cov$n_wsg), n_ended = as.integer(cov$n_ended),
             n_recompute_rows = as.integer(lr$n_rows), n_runs = as.integer(lr$n_runs),
             run_uid = lr$run_uid, last_end = format(lr$last_end, "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
             churn = format(as.numeric(churn$churn), scientific = FALSE), n_tables = as.integer(churn$n_tables),
             n_active = as.integer(act$n_active), status = "polling", stringsAsFactors = FALSE)
}
shas <- function() {
  conn <- pg()
  on.exit(dbDisconnect(conn))
  dbGetQuery(conn, sprintf("
    SELECT string_agg(DISTINCT run_uid, ';') AS log_run_uid, string_agg(DISTINCT link_version, ';') AS link_version,
           string_agg(DISTINCT link_sha, ';') AS link_sha, string_agg(DISTINCT fresh_version, ';') AS fresh_version,
           string_agg(DISTINCT fresh_sha, ';') AS fresh_sha, string_agg(DISTINCT fwapg_sha, ';') AS fwapg_sha,
           string_agg(DISTINCT config_hash, ';') AS config_hash, count(*) AS n_log_rows
    FROM %s.log", schema))
}

dir.create(dirname(path_log), showWarnings = FALSE, recursive = TRUE)
t0 <- Sys.time()
rows <- list()
# the release row carries the SHA columns the polling rows lack, so bind on the union of columns
write_log <- function() {
  cols <- unique(unlist(lapply(rows, names)))
  filled <- lapply(rows, function(r) { r[setdiff(cols, names(r))] <- NA; r[cols] })
  utils::write.csv(do.call(rbind, filled), path_log, row.names = FALSE, na = "")
}
repeat {
  r <- poll()
  rows[[length(rows) + 1]] <- r
  n <- length(rows)
  complete <- r$n_ended == r$n_wsg && r$n_wsg > 0
  quiet <- r$n_active == 0
  stable <- n >= polls_stable &&
    length(unique(vapply(rows[(n - polls_stable + 1):n], `[[`, character(1), "churn"))) == 1
  message(sprintf("%s  ended %d/%d  runs %d  churn %s  active %d  stable %s",
                  r$at_utc, r$n_ended, r$n_wsg, r$n_runs, r$churn, r$n_active, stable))
  if (complete && quiet && stable) {
    s <- shas()
    rows[[n]]$status <- "released"
    rows[[n]] <- cbind(rows[[n]], s)
    write_log()
    message("RELEASED ", r$at_utc, ": run_uid ", r$run_uid, ", ", r$n_recompute_rows,
            " log_recompute rows, churn ", r$churn, "; link ", s$link_version, " ", s$link_sha,
            "; fresh ", s$fresh_version, " ", s$fresh_sha, "; fwapg ", s$fwapg_sha)
    quit(status = 0)
  }
  if (as.numeric(difftime(Sys.time(), t0, units = "hours")) >= max_hours) {
    rows[[n]]$status <- "timeout"
    write_log()
    message("TIMEOUT after ", max_hours, " h: conditions not met; nothing started")
    quit(status = 2)
  }
  write_log()
  Sys.sleep(poll_min * 60)
}
