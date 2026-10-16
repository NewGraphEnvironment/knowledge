# scripts/0200-fiss-xls-enumerate.R
# ---------------------------------------------------------------------------
# FISS .xls harvest — STEP 1 of 3 (enumerate).
#
# Per watershed group, build a manifest of the data-only `.xls`/`.xlsx` fish
# data submissions that the FISS layers link to (NOT the narrative PDFs). These
# spreadsheets carry site-level effort + survey comments, incl. the negative
# results ("electrofished, caught nothing") we use to flag No-Fish-Captured (NFC)
# reaches during barrier prioritization.
#
# WHY / DESIGN NOTES (pipeline is new — notes live here, not a README yet):
#   - Source layer (confirmed w/ Al): whse_fish.fiss_fish_obsrvtn_pnt_sp, field
#     `acat_report_url`. That URL is a viewReport.do?reportId=N *page*, not a file
#     — the .xls submissions are ATTACHMENTS on the page:
#       https://a100.gov.bc.ca/pub/acat/documents/rN/<file>.xls[x]
#   - So: distinct reportIds clipped to the WSG -> fetch each report page ->
#     scrape the .xls[x] attachment links -> manifest.
#   - The layer has no watershed_group_code, so spatially intersect against
#     whse_basemapping.fwa_watershed_groups_poly (same pattern as 0100).
#   - GOTCHA (carried from 0100 / skeena): the acat_report_url stored in the
#     provincial layer is sometimes wrong for the point. Treat as leads to verify.
#
# INPUT:  WSG_TARGET env var (else `wsg_target` in the session; no default — an unset
#         variable used to run PINE silently and overwrite its outputs). The FISS layer and
#         the WSG polygons from the database the standard PG* environment variables name.
#         Prefer a bcfishpass database: its FISS snapshot was a superset of a plain fwapg
#         load (measured 2026-09-04: 5 report ids across COTR/UNTH/UPCE only in bcfishpass).
# OUTPUT: data/<wsg>/fiss_xls_manifest.csv
#           report_id, report_url, xls_url, file_name
#         data/<wsg>/fiss_xls_reports.csv  — one row per report page: n_xls, page_status,
#           db_source (the database name). This is what makes a failed page fetch distinguishable from a page
#           with no attachments; the script stops if any page still fails after a retry.
#
# NEXT:   0210-fiss-xls-fetch.R (opt-in download), then 0220-fiss-xls-parse-nfc.R.
#
# OPEN QUESTIONS:
#   - Only fiss_fish_obsrvtn_pnt_sp for now. fiss_stream_sample_sites_sp /
#     fiss_obstacles_pnt_sp also carry acat_report_url — add later if the obs
#     layer misses submissions.
# ---------------------------------------------------------------------------

suppressMessages({
  library(DBI); library(RPostgres); library(sf)
  library(dplyr); library(stringr); library(purrr); library(readr)
  library(xml2); library(rvest); library(curl)
})
sf::sf_use_s2(FALSE)
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else
              stop("WSG_TARGET is not set. Run as `WSG_TARGET=<code> Rscript scripts/0200-fiss-xls-enumerate.R` ",
                   "or set `wsg_target` in the session. There is no default group.", call. = FALSE)
wsg_lower  <- tolower(wsg_target)
out_dir    <- file.path("data", wsg_lower)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

fiss_layer <- "whse_fish.fiss_fish_obsrvtn_pnt_sp"

# ---- connection ---------------------------------------------------------------
# libpq reads PGHOST, PGPORT, PGDATABASE, PGUSER and PGPASSWORD. The database must carry
# fiss_fish_obsrvtn_pnt_sp (with acat_report_url) and the WSG polygons. Its name goes into
# fiss_xls_reports.csv (db_source), so a short manifest is explainable by its snapshot.
conn <- DBI::dbConnect(RPostgres::Postgres())
db_source <- DBI::dbGetQuery(conn, "SELECT current_database() AS d")$d
# on.exit() does NOT fire at a script's top level (see CLAUDE.md) — it would leave
# this connection open. reg.finalizer(onexit = TRUE) fires on both a clean exit and stop().
reg.finalizer(environment(),
              function(e) try(DBI::dbDisconnect(conn), silent = TRUE),
              onexit = TRUE)

# ---- distinct report pages linked from the FISS layer, clipped to the WSG ----
sch <- strsplit(fiss_layer, "\\.")[[1]][1]
tbl <- strsplit(fiss_layer, "\\.")[[1]][2]
q <- glue::glue_sql("
  SELECT DISTINCT p.acat_report_url
  FROM {`sch`}.{`tbl`} p
  JOIN whse_basemapping.fwa_watershed_groups_poly w
    ON ST_Intersects(w.geom, p.geom)
  WHERE w.watershed_group_code = {wsg_target}
    AND p.acat_report_url ~ 'reportId='",
  sch = sch, tbl = tbl, wsg_target = wsg_target, .con = conn)

report_urls <- DBI::dbGetQuery(conn, q)$acat_report_url
report_ids  <- sort(unique(str_extract(report_urls, "(?<=reportId=)[0-9]+")))
message(sprintf("%s: %d distinct FISS report pages", wsg_target, length(report_ids)))

# ---- scrape each report page for .xls[x] attachment links -------------------
# viewReport.do lists document attachments as absolute /pub/acat/documents/rN/... links.
# Returns list(links = tibble|NULL, status). Status is one of:
#   ok            page loaded, .xls links found
#   no_xls        page loaded, no .xls attachments
#   http_4xx      the server answered and refused (403 Forbidden is common — ACAT hides
#                 restricted reports; COTR has 3 of 47) or has no such report (404).
#                 Deterministic, so recorded and NOT retried, and does not stop the run.
#   fetch_failed  transport failure, a 5xx, or a 408/429 (timeout / rate limit — the
#                 two 4xx that are NOT deterministic) after one retry. The page may
#                 exist and we could not read it, so the script stops below rather
#                 than emit a silently short manifest.
xls_from_report <- function(id) {
  url <- sprintf("https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=%s", id)
  h <- curl::new_handle(followlocation = TRUE, timeout = 60)
  resp <- NULL
  for (attempt in 1:2) {
    resp <- tryCatch(curl::curl_fetch_memory(url, handle = h), error = function(e) NULL)
    if (!is.null(resp) && resp$status_code < 500 && !resp$status_code %in% c(408L, 429L)) break
    resp <- NULL
    Sys.sleep(2)
  }
  if (is.null(resp)) { message("  ! reportId=", id, ": page fetch failed twice"); return(list(links = NULL, status = "fetch_failed")) }
  if (resp$status_code != 200) {
    message("  ! reportId=", id, ": HTTP ", resp$status_code)
    return(list(links = NULL, status = paste0("http_", resp$status_code)))
  }
  page  <- xml2::read_html(resp$content)
  hrefs <- page %>% rvest::html_elements("a") %>% rvest::html_attr("href")
  hrefs <- hrefs[!is.na(hrefs)]
  # resolve any root-relative hrefs against the page URL so download.file gets a
  # full scheme+host (no-op for already-absolute links).
  hrefs <- xml2::url_absolute(hrefs, url)
  xls   <- hrefs[str_detect(hrefs, "(?i)/documents/.*\\.xls[x]?$")]
  if (!length(xls)) return(list(links = NULL, status = "no_xls"))
  list(links = tibble(report_id = id, report_url = url, xls_url = unique(xls),
                      file_name = basename(unique(xls))),
       status = "ok")
}

pages    <- map(report_ids, xls_from_report)
manifest <- map_dfr(pages, "links")
reports  <- tibble(report_id = report_ids,
                   page_status = map_chr(pages, "status"),
                   n_xls = map_int(pages, ~ if (is.null(.x$links)) 0L else nrow(.x$links)),
                   db_source = db_source)
readr::write_csv(reports, file.path(out_dir, "fiss_xls_reports.csv"))
message(sprintf("Wrote %s: %d pages — %s", file.path(out_dir, "fiss_xls_reports.csv"), nrow(reports),
                paste(sprintf("%s=%d", names(table(reports$page_status)), table(reports$page_status)), collapse = ", ")))
if (any(reports$page_status == "fetch_failed")) {
  # an earlier run's manifest must not survive beside a reports file saying fetch_failed
  unlink(file.path(out_dir, "fiss_xls_manifest.csv"))
  stop("Report page fetch failed after retry for reportId ",
       paste(reports$report_id[reports$page_status == "fetch_failed"], collapse = ", "),
       ". The manifest below would be silently short; re-run when ACAT is reachable.", call. = FALSE)
}

if (!nrow(manifest)) {
  # remove any manifest from an earlier run: a stale one beside a reports file saying
  # n_xls = 0 would keep feeding 0210/0220, and their reconciliation cannot see it
  unlink(file.path(out_dir, "fiss_xls_manifest.csv"))
  message("No .xls attachments found for ", wsg_target, " — no manifest written (any earlier one removed).")
} else {
  readr::write_csv(manifest, file.path(out_dir, "fiss_xls_manifest.csv"))
  message(sprintf("Wrote %s: %d .xls links across %d report pages",
                  file.path(out_dir, "fiss_xls_manifest.csv"),
                  nrow(manifest), n_distinct(manifest$report_id)))
}
