# scripts/04_planning/0210-fiss-xls-fetch.R
# ---------------------------------------------------------------------------
# FISS .xls harvest — STEP 2 of 3 (fetch). Issue #199.
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
#   - Raw downloads live under data/planning/<wsg>/fiss_xls/ and are gitignored
#     (bulky, reproducible from the manifest) — see .gitignore entry.
#
# INPUT:  data/planning/<wsg>/fiss_xls_manifest.csv (from 0200).
# ENABLE: set env FISS_FETCH=TRUE (else the script reports the count and stops).
# OUTPUT: data/planning/<wsg>/fiss_xls/<report_id>__<file_name>   (raw)
#         data/planning/<wsg>/fiss_xls/converted/<...>.xlsx        (encrypted -> xlsx)
#         data/planning/<wsg>/fiss_xls_fetch_log.csv               (status per file)
#
# NEXT:   0220-fiss-xls-parse-nfc.R
# ---------------------------------------------------------------------------

suppressMessages({
  library(dplyr); library(stringr); library(purrr); library(readr); library(readxl)
})

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else "PINE"
wsg_lower  <- tolower(wsg_target)
out_dir    <- file.path("data/planning", wsg_lower)
raw_dir    <- file.path(out_dir, "fiss_xls")
conv_dir   <- file.path(raw_dir, "converted")
manifest_path <- file.path(out_dir, "fiss_xls_manifest.csv")

soffice <- Sys.getenv("SOFFICE_BIN",
                      unset = if (nzchar(Sys.which("soffice"))) Sys.which("soffice") else "soffice")

stopifnot("manifest not found — run 0200 first" = file.exists(manifest_path))
manifest <- readr::read_csv(manifest_path, show_col_types = FALSE) %>%
  # one row per distinct attachment URL, with a stable index so sanitized names
  # that collide across attachments still map to unique local files (no overwrite).
  distinct(xls_url, .keep_all = TRUE) %>%
  mutate(idx = dplyr::row_number())

# ---- opt-in guard -----------------------------------------------------------
if (!identical(toupper(Sys.getenv("FISS_FETCH")), "TRUE")) {
  message(sprintf(
    "OPT-IN STEP. Manifest lists %d .xls files across %d report pages for %s.\n%s",
    nrow(manifest), dplyr::n_distinct(manifest$report_id), wsg_target,
    "Re-run with FISS_FETCH=TRUE to download (e.g. `FISS_FETCH=TRUE Rscript scripts/04_planning/0210-fiss-xls-fetch.R`)."))
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
  res <- suppressWarnings(system2(soffice,
    c("--headless", "--convert-to", "xlsx", "--outdir", shQuote(conv_dir), shQuote(path)),
    stdout = TRUE, stderr = TRUE))
  out <- file.path(conv_dir, paste0(tools::file_path_sans_ext(basename(path)), ".xlsx"))
  if (file.exists(out)) out else NA_character_
}

# ---- download + verify + fallback -------------------------------------------
fetch_one <- function(report_id, idx, xls_url, file_name) {
  dest <- local_name(report_id, idx, file_name)
  ok <- tryCatch({
    utils::download.file(xls_url, dest, mode = "wb", quiet = TRUE, method = "libcurl")
    file.exists(dest) && file.info(dest)$size > 0
  }, error = function(e) FALSE)
  if (!ok) return(tibble(report_id, file_name, path = NA, parse_path = NA,
                         status = "download_failed", converted = FALSE))
  if (readxl_ok(dest))
    return(tibble(report_id, file_name, path = dest, parse_path = dest,
                  status = "ok", converted = FALSE))
  # unreadable -> try LibreOffice conversion
  conv <- convert_xlsx(dest)
  if (!is.na(conv) && readxl_ok(conv))
    return(tibble(report_id, file_name, path = dest, parse_path = conv,
                  status = "converted", converted = TRUE))
  tibble(report_id, file_name, path = dest, parse_path = NA,
         status = "unreadable", converted = FALSE)
}

message(sprintf("Fetching %d files for %s ...", nrow(manifest), wsg_target))
log_tbl <- pmap_dfr(list(manifest$report_id, manifest$idx, manifest$xls_url, manifest$file_name), fetch_one)

readr::write_csv(log_tbl, file.path(out_dir, "fiss_xls_fetch_log.csv"))
message("Status counts:")
print(dplyr::count(log_tbl, status))
message("Wrote ", file.path(out_dir, "fiss_xls_fetch_log.csv"))
