# data-raw/walk_batch_check.R
# ---------------------------------------------------------------------------
# A batched walk is the walk (#87): knw_link_walks() sending one query per batch of starts must return,
# for every start, exactly what the one-query-per-start walk returned. The starts are a grade's own:
# every accessible segment with a gradient in one watershed group, read with knw_link_segments() as
# knw_grade_species() reads them, for chinook at q 3 and bull trout at q 10 (the two curves' river
# sizes), on `pick`.
#
# METHOD: REF=1 walks the starts with the code as it stood before #87 (the script refuses a
# knw_link_walks() that already takes `batch`) and writes them to data/tune/ref_walks/ (ignored). The
# default mode walks the same starts with the current knw_link_walks() and refuses any difference: every
# start must come back, on every column, identical after sorting on the start. Where the walk takes a
# cache (`cache`, #87 Phase 2), it also re-walks 1,000 rows of the cache table with the cache off and
# refuses any difference, so a cached row is the walk's own.
# INPUT:  fwapg database (PG* env vars): the link schema (SCHEMA, default fresh_default_20261017),
#         whse_basemapping, discharge; for the cache check, the cache table (CACHE, default knw.walk_cache)
# OUTPUT: data/tune/ref_walks/<wsg>_<sp>_q<q>_pick.rds          REF=1, one row per start (ignored; rds, because
#                                                                  write.csv keeps 15 significant digits)
#         scripts/logs/habitat/<date>_walk_batch_check[-ref].txt   the summary, with the time per walk
# RUN:    Rscript data-raw/walk_batch_check.R            (from the repo root; REF=1 for the references,
#         WSG=BULK, WORKERS=8, BATCH=500)
# ---------------------------------------------------------------------------
suppressMessages({ library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

ref_mode <- identical(Sys.getenv("REF"), "1")
schema <- Sys.getenv("SCHEMA", "fresh_default_20261017")
wsg <- toupper(Sys.getenv("WSG", "BULK"))
workers <- as.integer(Sys.getenv("WORKERS", "8"))
batch <- as.integer(Sys.getenv("BATCH", "500"))
cache_tbl <- Sys.getenv("CACHE", "knw.walk_cache")
stopifnot(grepl("^[A-Z]{4}$", wsg), grepl("^[a-z_0-9]+$", schema), workers > 0, batch > 0)
cases <- data.frame(sp = c("CH", "BT"), q = c(3, 10))
dir_ref <- "data/tune/ref_walks"
stamp <- format(Sys.Date(), "%Y%m%d")
path_txt <- file.path("scripts/logs/habitat", paste0(stamp, "_walk_batch_check", if (ref_mode) "-ref", ".txt"))
dir.create(dir_ref, showWarnings = FALSE, recursive = TRUE)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
has_arg <- function(a) a %in% names(formals(knw_link_walks))
if (ref_mode && has_arg("batch")) stop("REF=1 needs the walk as it stood before #87; this knw_link_walks() batches")
if (!ref_mode && !has_arg("batch")) stop("this knw_link_walks() does not batch: run REF=1 for the references")

pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")   # qualified: the walk workers have no DBI attached
conn <- pg()
say("walk_batch_check %s on %s %s; %d workers%s; knowledge %s", if (ref_mode) "REF" else "CHECK", schema, wsg,
    workers, if (ref_mode) "" else sprintf(", batch %d", batch),
    substr(system2("git", c("rev-parse", "HEAD"), stdout = TRUE), 1, 7))
cols <- c("blue_line_key", "downstream_route_measure", "src", "qmin", "status", "dist_m", "large_mad", "large_lfid",
          "large_edge", "large_waterbody_key", "n_hops", "max_entry_gap_m", "dist_centre_m", "bank_m")
sorted <- function(x) {
  x <- as.data.frame(x)[, cols]
  x <- x[order(x$blue_line_key, x$downstream_route_measure, x$src, x$qmin), , drop = FALSE]
  rownames(x) <- NULL
  x
}
compare_frames <- function(a, b, label) {
  if (nrow(a) != nrow(b)) stop(label, ": ", nrow(a), " rows against ", nrow(b), " in the reference", call. = FALSE)
  key_a <- paste(format(a$blue_line_key, scientific = FALSE), sprintf("%.17g", a$downstream_route_measure))
  key_b <- paste(format(b$blue_line_key, scientific = FALSE), sprintf("%.17g", b$downstream_route_measure))
  if (!identical(key_a, key_b)) stop(label, ": the starts differ from the reference's", call. = FALSE)
  bad <- cols[!vapply(cols, function(c) identical(a[[c]], b[[c]]), logical(1))]
  if (length(bad)) {
    for (c in bad) {
      d <- which(!mapply(identical, a[[c]], b[[c]]))
      say("  %s: column %s differs on %d rows (first: %s against %s)", label, c, length(d),
          format(a[[c]][d[1]]), format(b[[c]][d[1]]))
    }
    stop(label, ": columns differ from the reference: ", paste(bad, collapse = ", "), call. = FALSE)
  }
  say("  %s: %d rows identical to the reference on all %d columns.", label, nrow(a), length(cols))
}

for (i in seq_len(nrow(cases))) {
  sp <- cases$sp[i]
  q <- cases$q[i]
  seg <- knw_link_segments(conn, schema, sp, wsg)
  starts <- unique(seg[seg$accessible %in% TRUE & !is.na(seg$gradient), c("blue_line_key", "downstream_route_measure")])
  f <- file.path(dir_ref, sprintf("%s_%s_q%g_pick.rds", tolower(wsg), tolower(sp), q))
  t0 <- Sys.time()
  w <- if (ref_mode) {
    knw_link_walks(pg, starts, q_grid = q, sources = "pick", workers = workers)
  } else {
    knw_link_walks(pg, starts, q_grid = q, sources = "pick", workers = workers, batch = batch)
  }
  secs <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
  say("%s q %g: %d starts walked in %.1f s, %.2f ms per walk per worker", sp, q, nrow(starts), secs,
      1000 * secs * workers / nrow(starts))
  w <- sorted(w)
  if (ref_mode) {
    saveRDS(w, f)
    say("  reference written: %s (%d rows; status %s)", f, nrow(w),
        paste(names(table(w$status)), table(w$status), sep = " ", collapse = ", "))
  } else {
    if (!file.exists(f)) stop("no reference at ", f, ": run REF=1 first")
    compare_frames(w, sorted(readRDS(f)), sprintf("%s q %g", sp, q))
  }
}

# the cache's rows are the walk's own: 1,000 of them re-walked with the cache off (#87 Phase 2)
if (!ref_mode && has_arg("cache")) {
  ex <- dbGetQuery(conn, "SELECT to_regclass($1) IS NOT NULL AS ok", params = list(cache_tbl))$ok
  if (!isTRUE(ex)) stop("no cache table ", cache_tbl)
  smp <- dbGetQuery(conn, sprintf(
    "SELECT * FROM %s WHERE load_md5 = $1 AND walk_md5 = $2 ORDER BY md5(blue_line_key::text || '|' || downstream_route_measure::text || '|' || src || '|' || qmin::text) LIMIT 1000",
    cache_tbl), params = list(.knw_load_md5(conn, knw_discharge_load(conn)), knw_walk_md5()))
  if (!nrow(smp)) stop("the cache ", cache_tbl, " holds no rows under this flow load and walk")
  rw <- do.call(rbind, lapply(split(smp, smp$src), function(p) {
    do.call(rbind, lapply(split(p, p$qmin), function(pq) {
      knw_link_walks(pg, unique(pq[, c("blue_line_key", "downstream_route_measure")]), q_grid = pq$qmin[1],
                     sources = pq$src[1], workers = min(workers, 4L), cache = FALSE)
    }))
  }))
  smp$blue_line_key <- as.numeric(smp$blue_line_key)
  for (c in c("qmin", "dist_m", "large_mad", "large_lfid", "large_waterbody_key", "max_entry_gap_m", "dist_centre_m",
              "bank_m")) smp[[c]] <- as.numeric(smp[[c]])
  for (c in c("large_edge", "n_hops")) smp[[c]] <- as.integer(smp[[c]])
  compare_frames(sorted(rw), sorted(smp), sprintf("cache %s, %d rows re-walked", cache_tbl, nrow(smp)))
}
dbDisconnect(conn)
writeLines(log_lines, path_txt)
say("written %s", path_txt)
