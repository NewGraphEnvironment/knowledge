# scripts/0200-fiss-xls-enumerate.R
# ---------------------------------------------------------------------------
# FISS .xls harvest — STEP 1 of 3 (enumerate). Issue NewGraphEnvironment/fish_passage_template_reporting#199.
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
# INPUT:  WSG_TARGET env var (else `wsg_target`, else PINE). Live DB via tunnel :63333.
# OUTPUT: data/<wsg>/fiss_xls_manifest.csv
#           report_id, report_url, xls_url, file_name
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
  library(xml2); library(rvest)
})
sf::sf_use_s2(FALSE)
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else "PINE"
wsg_lower  <- tolower(wsg_target)
out_dir    <- file.path("data", wsg_lower)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

fiss_layer <- "whse_fish.fiss_fish_obsrvtn_pnt_sp"

# ---- connection -------------------------------------------------------------
conn <- DBI::dbConnect(RPostgres::Postgres(),
                       host = "localhost", port = 63333,
                       dbname = "bcfishpass", user = "newgraph")
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
xls_from_report <- function(id) {
  url <- sprintf("http://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=%s", id)
  page <- tryCatch(xml2::read_html(url), error = function(e) NULL)
  if (is.null(page)) { message("  ! reportId=", id, ": page fetch failed"); return(NULL) }
  hrefs <- page %>% rvest::html_elements("a") %>% rvest::html_attr("href")
  hrefs <- hrefs[!is.na(hrefs)]
  # resolve any root-relative hrefs against the page URL so download.file gets a
  # full scheme+host (no-op for already-absolute links).
  hrefs <- xml2::url_absolute(hrefs, url)
  xls   <- hrefs[str_detect(hrefs, "(?i)/documents/.*\\.xls[x]?$")]
  if (!length(xls)) return(NULL)
  tibble(report_id = id, report_url = url, xls_url = unique(xls),
         file_name = basename(unique(xls)))
}

manifest <- map_dfr(report_ids, xls_from_report)

if (!nrow(manifest)) {
  message("No .xls attachments found for ", wsg_target, " — nothing to write.")
} else {
  readr::write_csv(manifest, file.path(out_dir, "fiss_xls_manifest.csv"))
  message(sprintf("Wrote %s: %d .xls links across %d report pages",
                  file.path(out_dir, "fiss_xls_manifest.csv"),
                  nrow(manifest), n_distinct(manifest$report_id)))
}
