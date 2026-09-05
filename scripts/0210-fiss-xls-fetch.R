# scripts/0210-fiss-xls-fetch.R
# ---------------------------------------------------------------------------
# FISS .xls harvest — STEP 2 of 3 (fetch). Issue NewGraphEnvironment/fish_passage_template_reporting#199.
#
# Download the .xls/.xlsx submissions listed in the manifest from 0200. This is
# a DELIBERATE, OPT-IN step — it can pull dozens-to-hundreds of files per WSG, so
# it does NOT run unless explicitly enabled (guard below). Complements, and is
# lower priority than, the report/PDF sweep.
#
# WHY / DESIGN NOTES:
#   - ENCRYPTION GOTCHA: ~30% of the legacy .xls in testing fail readxl/libxls
#     with "Unsupported encryption scheme". LibreOffice opens them fine, so we
#     convert those to .xlsx headless (`soffice --convert-to xlsx`) as a fallback.
#     The parse step (0220) prefers the converted .xlsx when present.
#   - Raw downloads live under data/<wsg>/fiss_xls/ and are gitignored
#     (bulky, reproducible from the manifest) — see .gitignore entry.
#
# INPUT:  data/<wsg>/fiss_xls_manifest.csv (from 0200).
# ENABLE: set env FISS_FETCH=TRUE (else the script reports the count and stops).
# OUTPUT: data/<wsg>/fiss_xls/<report_id>_<idx>__<file_name>   (raw)
#         data/<wsg>/fiss_xls/converted/<...>.xlsx             (encrypted -> xlsx)
#         data/<wsg>/fiss_xls_fetch_log.csv  (status per file; carries idx + xls_url so it
#           joins the manifest by key — file_name collides across attachments). status:
#             ok | converted | unreadable   the file is on disk (unreadable = readxl and
#                                           LibreOffice both fail)
#             http_4xx      ACAT lists an attachment it does not serve (404 seen twice on
#                           the North Thompson); deterministic, recorded, run continues
#             fetch_failed  transport error, 5xx, 408/429 after one retry — the script
#                           STOPS after writing the log, so a short set never parses
# WSG_TARGET has no default: unset used to run PINE silently and overwrite its outputs.
#
# NEXT:   0220-fiss-xls-parse-nfc.R
# ---------------------------------------------------------------------------

suppressMessages({
  library(dplyr); library(stringr); library(purrr); library(readr); library(readxl); library(curl)
})

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else
              stop("WSG_TARGET is not set. Run as `WSG_TARGET=<code> FISS_FETCH=TRUE Rscript scripts/0210-fiss-xls-fetch.R` ",
                   "or set `wsg_target` in the session. There is no default group.", call. = FALSE)
wsg_lower  <- tolower(wsg_target)
out_dir    <- file.path("data", wsg_lower)
raw_dir    <- file.path(out_dir, "fiss_xls")
conv_dir   <- file.path(raw_dir, "converted")
manifest_path <- file.path(out_dir, "fiss_xls_manifest.csv")

soffice <- Sys.getenv("SOFFICE_BIN",
                      unset = if (nzchar(Sys.which("soffice"))) Sys.which("soffice") else "soffice")

stopifnot("manifest not found — run 0200 first" = file.exists(manifest_path))
# report_id stays character: as a double, 100000 prints as "1e+05" in file names and keys
manifest <- readr::read_csv(manifest_path, show_col_types = FALSE,
                            col_types = readr::cols(report_id = readr::col_character(), .default = readr::col_guess())) %>%
  # one row per distinct attachment URL, with a stable index so sanitized names
  # that collide across attachments still map to unique local files (no overwrite).
  distinct(xls_url, .keep_all = TRUE) %>%
  mutate(idx = dplyr::row_number())

# ---- opt-in guard -----------------------------------------------------------
if (!identical(toupper(Sys.getenv("FISS_FETCH")), "TRUE")) {
  message(sprintf(
    "OPT-IN STEP. Manifest lists %d .xls files across %d report pages for %s.\n%s",
    nrow(manifest), dplyr::n_distinct(manifest$report_id), wsg_target,
    "Re-run with FISS_FETCH=TRUE to download (e.g. `FISS_FETCH=TRUE Rscript scripts/0210-fiss-xls-fetch.R`)."))
  quit(save = "no", status = 0)
}

dir.create(raw_dir,  recursive = TRUE, showWarnings = FALSE)
dir.create(conv_dir, recursive = TRUE, showWarnings = FALSE)

# ---- helpers ----------------------------------------------------------------
# safe local name: report id + manifest index guarantees uniqueness even when the
# sanitized file_name collides across attachments (converted .xlsx derives from this
# basename, so it inherits the uniqueness).
local_name <- function(report_id, idx, file_name) {
  file.path(raw_dir, paste0(report_id, "_", idx, "__", str_replace_all(file_name, "[^A-Za-z0-9._-]", "_")))
}

# does readxl open it? (encrypted legacy .xls raise "Unsupported encryption")
readxl_ok <- function(path) {
  isTRUE(tryCatch({ readxl::excel_sheets(path); TRUE }, error = function(e) FALSE))
}

# convert an unreadable .xls -> .xlsx via LibreOffice headless; return new path or NA
convert_xlsx <- function(path) {
  # remove any earlier conversion first: file.exists() after soffice cannot tell a fresh
  # conversion from a stale one, and a stale one can belong to a different attachment
  # if the manifest order (and so idx) ever changed
  unlink(file.path(conv_dir, paste0(tools::file_path_sans_ext(basename(path)), ".xlsx")))
  res <- suppressWarnings(system2(soffice,
    c("--headless", "--convert-to", "xlsx", "--outdir", shQuote(conv_dir), shQuote(path)),
    stdout = TRUE, stderr = TRUE))
  out <- file.path(conv_dir, paste0(tools::file_path_sans_ext(basename(path)), ".xlsx"))
  if (file.exists(out)) out else NA_character_
}

# ---- download + verify + fallback -------------------------------------------
fetch_one <- function(report_id, idx, xls_url, file_name) {
  dest <- local_name(report_id, idx, file_name)
  row  <- function(status, path = NA_character_, parse_path = NA_character_, converted = FALSE)
    tibble(report_id, idx, xls_url, file_name, path, parse_path, status, converted)
  # curl gives the HTTP status explicitly (download.file(quiet = TRUE) does not put it in
  # its error text). A 4xx other than 408/429 is deterministic and recorded; anything
  # else is retried once and then fetch_failed. curl writes an error body to dest on a
  # non-200, so dest is removed on every non-ok path.
  h <- curl::new_handle(followlocation = TRUE, timeout = 120)
  resp <- NULL
  for (attempt in 1:2) {
    resp <- tryCatch(curl::curl_fetch_disk(xls_url, dest, handle = h), error = function(e) NULL)
    if (!is.null(resp) && resp$status_code == 200L && file.exists(dest) && file.info(dest)$size > 0) break
    if (!is.null(resp) && resp$status_code >= 400L && resp$status_code < 500L && !resp$status_code %in% c(408L, 429L)) {
      unlink(dest); return(row(paste0("http_", resp$status_code)))
    }
    resp <- NULL; unlink(dest); Sys.sleep(2)
  }
  if (is.null(resp)) { unlink(dest); return(row("fetch_failed")) }
  if (readxl_ok(dest)) return(row("ok", path = dest, parse_path = dest))
  # unreadable -> try LibreOffice conversion
  conv <- convert_xlsx(dest)
  if (!is.na(conv) && readxl_ok(conv)) return(row("converted", path = dest, parse_path = conv, converted = TRUE))
  row("unreadable", path = dest)
}

message(sprintf("Fetching %d files for %s ...", nrow(manifest), wsg_target))
log_tbl <- pmap_dfr(list(manifest$report_id, manifest$idx, manifest$xls_url, manifest$file_name), fetch_one)

# one log row per manifest attachment, or the log cannot stand in for the manifest downstream
stopifnot("fetch log rows != manifest rows" = nrow(log_tbl) == nrow(manifest),
          "fetch log xls_url != manifest xls_url" = setequal(log_tbl$xls_url, manifest$xls_url))
readr::write_csv(log_tbl, file.path(out_dir, "fiss_xls_fetch_log.csv"))
message("Status counts:")
print(dplyr::count(log_tbl, status))
message("Wrote ", file.path(out_dir, "fiss_xls_fetch_log.csv"))
if (any(log_tbl$status == "fetch_failed")) {
  stop("Download failed after retry for ", sum(log_tbl$status == "fetch_failed"), " file(s): ",
       paste(log_tbl$file_name[log_tbl$status == "fetch_failed"], collapse = "; "),
       ". The log records them; 0220 refuses a fetch log carrying fetch_failed. Re-run when ACAT is reachable.",
       call. = FALSE)
}
