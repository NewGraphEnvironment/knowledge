# data-raw/segment_window_flow.R
# ---------------------------------------------------------------------------
# #42, first piece: the mean flow in each life-stage window of data/life_history_timing.csv on every FWA segment of
# the window's watershed group, from both of wet's sources, on the daily basis, with the monthly basis beside it.
#
# WHY / DESIGN NOTES:
#   - EVERY COMPLETE WINDOW. A timing row with one end (BULK coho migration, #31) has no window and is listed as
#     skipped. A window crossing 1 January is one window (wet::wet_flow_window() reads start > end that way).
#   - BOTH SOURCES, ONE BUILD. wet publishes routed PCIC and its own water balance on each segment. Both bases are
#     read from wet's published parts (wet::wet_segment_daily(), wet::wet_segment_monthly() with no connection), so
#     the daily and monthly flows are one build, which the run record names. A database's load can be an older
#     build. The readers return no `pick` (NewGraphEnvironment/wet#177), so the table keeps both sources and the
#     summary reads each source on its own rather than mixing in an older build's pick.
#   - DAILY, WITH MONTHLY BESIDE IT. The daily basis is the mean of the window's own days of the year; the monthly
#     basis gives each day its month's mean, the approximation the monthly table carries.
#   - NO 7-DAY MINIMUM. A 7-day minimum over 30-year mean days is not a dry-year low flow, and wet publishes no
#     per-year daily flow per segment; that and dry-year departures are their own issue.
#
# INPUT:  data/life_history_timing.csv; a database holding whse_basemapping (PG* or PGSERVICE), for each group's
#         segments; wet's published parts over HTTPS.
# OUTPUT: data/flow_window/segment_windows.parquet and segment_windows_run.csv (ignored), and the summary by group,
#         window and source printed to the log.
# RUN:    Rscript data-raw/segment_window_flow.R 2>&1 | tee scripts/logs/flow_window/<yyyymmdd>_segment_window_flow.txt
#         (repo root; WSG=BULK,MORR for some)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!requireNamespace("arrow", quietly = TRUE)) stop("install arrow", call. = FALSE)

out_dir <- "data/flow_window"
dirty <- system2("git", c("status", "--porcelain", "--", "data-raw/segment_window_flow.R", "R",
                          "data/life_history_timing.csv"), stdout = TRUE)
if (!is.null(attr(dirty, "status"))) stop("git status failed", call. = FALSE)
if (length(dirty)) {
  stop("commit first, so the run record's commit reproduces the run: ", paste(dirty, collapse = "; "), call. = FALSE)
}
timing <- knw_timing_read("data/life_history_timing.csv")
groups <- if (nzchar(Sys.getenv("WSG"))) strsplit(Sys.getenv("WSG"), ",")[[1]] else sort(unique(timing$wsg_code))
cat("started:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n")

wet_build <- attr(wet::wet_catalog(), "built")
if (is.null(wet_build) || !nzchar(wet_build)) stop("wet's catalogue names no build", call. = FALSE)
cat("wet build:", wet_build, "(", as.character(utils::packageVersion("wet")), ")\n\n")
conn <- DBI::dbConnect(RPostgres::Postgres())

res <- list()
for (g in groups) {
  tg <- timing[timing$wsg_code == g, , drop = FALSE]
  half <- is.na(tg$start) | is.na(tg$end)
  if (any(half)) {
    cat(g, ": skipped (one end only):", paste(tg$species_code[half], tg$life_stage[half], collapse = ", "), "\n")
  }
  tg <- tg[!half, , drop = FALSE]
  if (!nrow(tg)) next
  win <- data.frame(window = paste(tg$species_code, tg$life_stage, tg$start, tg$end, sep = "|"),
                    start = tg$start, end = tg$end)
  if (anyDuplicated(win$window)) stop(g, ": two timing rows give one window", call. = FALSE)
  t0 <- Sys.time()
  seg <- sort(as.numeric(DBI::dbGetQuery(conn, "SELECT linear_feature_id FROM whse_basemapping.fwa_stream_networks_sp
    WHERE watershed_group_code = $1", params = list(g))$linear_feature_id))
  mon <- wet::wet_segment_monthly(NULL, seg, groups = g)
  dly <- wet::wet_segment_daily(NULL, seg, groups = g)
  has <- unique(mon$linear_feature_id[!is.na(mon$q_m3s)])
  seg <- seg[seg %in% has]
  mon <- mon[mon$linear_feature_id %in% seg, , drop = FALSE]
  dly <- dly[dly$linear_feature_id %in% seg, , drop = FALSE]
  wm <- wet::wet_flow_window(mon, win)
  wd <- wet::wet_flow_window(dly, win)
  out <- merge(stats::setNames(wd[, c("linear_feature_id", "source", "window", "q_m3s")],
                               c("linear_feature_id", "source", "window", "q_daily")),
               stats::setNames(wm[, c("linear_feature_id", "source", "window", "q_m3s")],
                               c("linear_feature_id", "source", "window", "q_monthly")),
               by = c("linear_feature_id", "source", "window"), all = TRUE)
  parts <- do.call(rbind, strsplit(out$window, "|", fixed = TRUE))
  out <- data.frame(watershed_group_code = g, linear_feature_id = out$linear_feature_id,
                    species_code = parts[, 1], life_stage = parts[, 2], start = parts[, 3], end = parts[, 4],
                    source = out$source, q_daily = out$q_daily, q_monthly = out$q_monthly)
  expect_rows <- length(seg) * nrow(win) * 2L
  if (nrow(out) != expect_rows) {
    stop(g, ": ", nrow(out), " rows, expected segments x windows x 2 = ", expect_rows, call. = FALSE)
  }
  res[[g]] <- out
  cat(sprintf("%s: %d segments with flow x %d windows x 2 sources = %d rows in %.0f s\n", g, length(seg),
              nrow(win), nrow(out), as.numeric(difftime(Sys.time(), t0, units = "secs"))))
}
DBI::dbDisconnect(conn)
all <- do.call(rbind, res)
if (sum(vapply(res, nrow, 1L)) != nrow(all)) stop("rows lost binding the groups", call. = FALSE)

# the summary, each source on its own: the median window flow, and how far the monthly basis sits from the daily
ok <- !is.na(all$q_daily) & !is.na(all$q_monthly) & all$q_daily > 0
all_ok <- all[ok, , drop = FALSE]
all_ok$gap <- all_ok$q_monthly / all_ok$q_daily - 1
keys <- c("watershed_group_code", "species_code", "life_stage", "start", "end", "source")
summ <- do.call(rbind, lapply(split(all_ok, all_ok[keys], drop = TRUE), function(x) {
  data.frame(x[1, keys], segments = nrow(x), median_q_daily = stats::median(x$q_daily),
             median_gap = stats::median(x$gap), p90_abs_gap = stats::quantile(abs(x$gap), 0.9, names = FALSE))
}))
summ <- summ[order(summ$watershed_group_code, summ$species_code, summ$start, summ$source), , drop = FALSE]
cat("\nmonthly basis against daily (gap = monthly / daily - 1), by group, window and source:\n")
print(summ, row.names = FALSE, digits = 3)

# where the two sources part: the share of segments whose window flows differ more than twofold
w <- stats::reshape(all[, c("watershed_group_code", "linear_feature_id", "species_code", "life_stage", "source",
                            "q_daily")],
                    idvar = c("watershed_group_code", "linear_feature_id", "species_code", "life_stage"),
                    timevar = "source", direction = "wide")
both <- !is.na(w$q_daily.pcic_routed) & !is.na(w$q_daily.wet_balance) & w$q_daily.pcic_routed > 0 &
  w$q_daily.wet_balance > 0
w <- w[both, , drop = FALSE]
w$ratio <- pmax(w$q_daily.pcic_routed, w$q_daily.wet_balance) / pmin(w$q_daily.pcic_routed, w$q_daily.wet_balance)
src <- stats::aggregate(ratio ~ watershed_group_code + species_code + life_stage, data = w,
                        FUN = function(x) round(100 * mean(x > 2), 1))
names(src)[names(src) == "ratio"] <- "pct_segments_sources_differ_2x"
cat("\nsegments with both sources, the share whose daily window flows differ more than twofold:\n")
print(src, row.names = FALSE)

dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
arrow::write_parquet(all, file.path(out_dir, "segment_windows.parquet"))
utils::write.csv(data.frame(groups = paste(names(res), collapse = ";"), rows = nrow(all), wet_build = wet_build,
                            wet_version = as.character(utils::packageVersion("wet")),
                            knowledge_commit = system2("git", c("rev-parse", "HEAD"), stdout = TRUE)),
                 file.path(out_dir, "segment_windows_run.csv"), row.names = FALSE, na = "")
cat("\nwrote", file.path(out_dir, "segment_windows.parquet"), nrow(all), "rows\nfinished:",
    format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n")
