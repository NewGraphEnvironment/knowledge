# scripts/0105-reports-resolve-fetch.R
# ---------------------------------------------------------------------------
# The QUICK path from PSCIS links to readable report text, for one watershed group,
# with no Zotero, no rag store and no LLM harvest agents. Issue NewGraphEnvironment/knowledge#11.
#
#   1. resolve   the `ecocat_url`s in data/<wsg>/reports.csv (from 0100). Most are not
#                report pages but `advancedSearch.do?keywords=[PSCISnn]` searches; each is
#                fetched and its `viewReport.do?reportId=N` hits parsed, keeping the hits
#                whose title carries that [PSCISnn] tag.
#   2. search    a handful of thematic EcoCat keyword queries, GEO-FILTERED by a title
#                regex (EcoCat matches province-wide), every hit and its verdict recorded.
#   3. fetch     for each report id, the report page's PDF documents; the MAIN report is
#                chosen by 0153's rule (a filename saying report/final, else the first PDF
#                that is not an appendix/attachment/map/plate); curl'd to
#                data/<wsg>/reports_pdf/<id>.pdf (gitignored: **/*.pdf) with the HTTP status
#                read explicitly; text extracted beside it with pdftotext -layout.
#   4. reconcile every resolved id has a manifest row; fetch failures stop the script.
#
# INPUT:  WSG_TARGET (required), data/<wsg>/reports.csv, env REGION_REGEX (optional; the
#         geo-filter for keyword hits — default is the North Thompson), env
#         KEYWORD_QUERIES (optional; '|'-separated).
# OUTPUT: data/<wsg>/reports_resolved.csv     pscis_layer, pscis_tag, report_id, title, n_crossings, source
#         data/<wsg>/reports_search_hits.csv  every keyword hit with its keep/drop verdict
#         data/<wsg>/reports_fetch.csv        report_id, title, source, pdf_url, http, bytes, is_pdf, n_docs, txt_chars
#         data/<wsg>/reports_pdf/<id>.{pdf,txt}
# ---------------------------------------------------------------------------

suppressMessages({
  library(dplyr); library(stringr); library(purrr); library(readr); library(curl); library(tidyr)
})
`%||%` <- function(a, b) if (length(a) == 0 || all(is.na(a))) b else a

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else
              stop("WSG_TARGET is not set. Run as `WSG_TARGET=<code> Rscript scripts/0105-reports-resolve-fetch.R`.", call. = FALSE)
wsg_lower <- tolower(wsg_target)
out_dir   <- file.path("data", wsg_lower)
pdf_dir   <- file.path(out_dir, "reports_pdf")
dir.create(pdf_dir, recursive = TRUE, showWarnings = FALSE)
reports_path <- file.path(out_dir, "reports.csv")
stopifnot("reports.csv not found — run 0100 first" = file.exists(reports_path))

region_regex <- Sys.getenv("REGION_REGEX",
  unset = "thompson|clearwater|barri[eè]re|kamloops|avola|blue river|mahood|wells gray|TFL ?18|\\bLNT\\b|\\bUNT\\b|louis creek|raft river|mad river|lemieux|chu chua|heffley|vavenby")
# titles that match the region regex but belong elsewhere — a "Clearwater Lake" sits in the
# Peace Arm (PCEA) and EcoCat titles often carry the FWA code of the group they are in
exclude_regex <- Sys.getenv("EXCLUDE_REGEX",
  unset = "\\b[0-9]{5}(PCEA|PARA|PINE|UPCE|BOWR|FRAN|NECR|WILL)\\b|peace arm|williston")
keyword_queries <- strsplit(Sys.getenv("KEYWORD_QUERIES",
  unset = "fish passage north thompson|fish passage thompson|habitat confirmation north thompson|culvert north thompson|PSCIS north thompson|fish passage clearwater|fish passage barriere"), "|", fixed = TRUE)[[1]]

ACAT   <- "https://a100.gov.bc.ca/pub/acat/public/"
handle <- function() curl::new_handle(followlocation = TRUE, timeout = 90, useragent = "Mozilla/5.0")
pdftotext <- Sys.which("pdftotext")
stopifnot("pdftotext not on PATH (poppler)" = nzchar(pdftotext))

# fetch a page; returns list(status, text) — status NA on a transport failure, retried once
get_page <- function(url) {
  for (attempt in 1:2) {
    r <- tryCatch(curl::curl_fetch_memory(url, handle = handle()), error = function(e) NULL)
    if (!is.null(r) && r$status_code < 500) return(list(status = r$status_code, text = rawToChar(r$content)))
    Sys.sleep(2)
  }
  list(status = NA_integer_, text = "")
}

# parse `viewReport.do?reportId=N">title</a>` hits out of a search page
parse_hits <- function(html) {
  m <- str_match_all(html, '(?is)viewReport\\.do\\?reportId=([0-9]+)"[^>]*>\\s*([^<]*?)\\s*</a>')[[1]]
  if (!nrow(m)) return(tibble(report_id = character(), title = character()))
  tibble(report_id = m[, 2], title = str_squish(m[, 3])) %>% distinct(report_id, .keep_all = TRUE)
}

# ---- 1. resolve the PSCIS links ---------------------------------------------
reports <- readr::read_csv(reports_path, show_col_types = FALSE,
                           col_types = readr::cols(report_id = readr::col_character(), .default = readr::col_guess()))
links <- reports %>%
  mutate(pscis_tag = str_match(ecocat_url, "keywords=(\\[PSCIS[0-9]+\\])")[, 2]) %>%
  group_by(ecocat_url, pscis_tag, report_id) %>%
  summarise(pscis_layer = paste(sort(unique(pscis_layer)), collapse = ";"),
            n_crossings = sum(n_crossings), .groups = "drop")
message(sprintf("%s: %d distinct PSCIS links (%d with a report id, %d [PSCIS] searches)",
                wsg_target, nrow(links), sum(!is.na(links$report_id)), sum(!is.na(links$pscis_tag))))

resolve_one <- function(ecocat_url, pscis_tag, report_id, pscis_layer, n_crossings) {
  base <- tibble(pscis_layer, pscis_tag, n_crossings, source = "pscis")
  if (!is.na(report_id)) return(mutate(base, report_id = report_id, title = NA_character_, resolve = "direct"))
  if (is.na(pscis_tag))  return(mutate(base, report_id = NA_character_, title = NA_character_, resolve = "unrecognised_url"))
  pg <- get_page(paste0(ACAT, "advancedSearch.do?keywords=", utils::URLencode(pscis_tag, reserved = TRUE), "&searchKeyType=searchAll&sortColumn=title"))
  if (is.na(pg$status) || pg$status != 200) return(mutate(base, report_id = NA_character_, title = NA_character_, resolve = paste0("search_http_", pg$status)))
  hits <- parse_hits(pg$text)
  tagged <- hits %>% filter(str_detect(title, fixed(pscis_tag)))
  if (nrow(tagged)) return(tidyr::crossing(base, tagged) %>% mutate(resolve = "tag_in_title"))
  if (nrow(hits))   return(tidyr::crossing(base, hits)   %>% mutate(resolve = "search_hits_untagged"))
  mutate(base, report_id = NA_character_, title = NA_character_, resolve = "no_hits")
}
resolved <- pmap_dfr(links[c("ecocat_url", "pscis_tag", "report_id", "pscis_layer", "n_crossings")], resolve_one)
unres <- resolved %>% filter(is.na(report_id))
message(sprintf("  resolved to %d report ids across %d links; %d link(s) unresolved%s",
                n_distinct(na.omit(resolved$report_id)), n_distinct(resolved$pscis_tag),
                nrow(unres), if (nrow(unres)) paste0(": ", paste(unres$pscis_tag, unres$resolve, collapse = ", ")) else ""))

# ---- 2. thematic keyword search, geo-filtered -------------------------------
search_hits <- map_dfr(keyword_queries, function(q) {
  pg <- get_page(paste0(ACAT, "advancedSearch.do?keywords=", utils::URLencode(q, reserved = TRUE), "&searchKeyType=searchAll&sortColumn=title"))
  if (is.na(pg$status) || pg$status != 200) { message("  ! search failed: ", q, " (", pg$status, ")"); return(NULL) }
  parse_hits(pg$text) %>% mutate(query = q, .before = 1)
}) %>%
  mutate(in_region  = str_detect(title, regex(region_regex, ignore_case = TRUE)),
         excluded   = str_detect(title, regex(exclude_regex, ignore_case = TRUE)),
         already    = report_id %in% resolved$report_id,
         nge_own    = str_detect(title, regex("new graph", ignore_case = TRUE)),
         verdict    = case_when(already ~ "already_resolved", nge_own ~ "nge_own_skip",
                                excluded ~ "excluded_other_group",
                                in_region ~ "keep", TRUE ~ "off_region"))
readr::write_csv(search_hits, file.path(out_dir, "reports_search_hits.csv"))
new_hits <- search_hits %>% filter(verdict == "keep") %>% distinct(report_id, .keep_all = TRUE)
message(sprintf("  keyword search: %d hits over %d queries; %d in region and new, %d off region, %d already resolved",
                nrow(search_hits), length(keyword_queries), nrow(new_hits),
                sum(search_hits$verdict == "off_region"), sum(search_hits$verdict == "already_resolved")))

all_reports <- bind_rows(
  resolved %>% filter(!is.na(report_id)) %>%
    group_by(report_id) %>%
    summarise(title = first(na.omit(title)) %||% NA_character_, source = "pscis",
              pscis_layer = paste(sort(unique(unlist(strsplit(pscis_layer, ";")))), collapse = ";"),
              pscis_tag = paste(sort(unique(pscis_tag)), collapse = ";"),
              n_crossings = sum(n_crossings), .groups = "drop"),
  new_hits %>% transmute(report_id, title, source = "ecocat_search", pscis_layer = NA_character_,
                         pscis_tag = NA_character_, n_crossings = NA_integer_)
)
readr::write_csv(bind_rows(resolved, new_hits %>% transmute(pscis_layer = NA, pscis_tag = NA, n_crossings = NA,
                                                             source = "ecocat_search", report_id, title, resolve = "keyword")),
                 file.path(out_dir, "reports_resolved.csv"))

# ---- 3. fetch the main PDF per report + text ----------------------------------
SUPPORTING <- regex("appendix|attach|map|plate|figure|photo|overview", ignore_case = TRUE)
pick_main <- function(pdfs) {
  base <- basename(pdfs)
  main <- pdfs[str_detect(base, regex("report|final", ignore_case = TRUE)) & !str_detect(base, SUPPORTING)]
  if (!length(main)) main <- pdfs[!str_detect(base, SUPPORTING)]
  if (!length(main)) main <- pdfs
  main[1]
}
fetch_one <- function(report_id, title, source) {
  row <- function(...) tibble(report_id, title, source, ...)
  pg <- get_page(paste0(ACAT, "viewReport.do?reportId=", report_id))
  if (is.na(pg$status) || pg$status != 200)
    return(row(pdf_url = NA_character_, http = pg$status, bytes = NA_integer_, is_pdf = FALSE, n_docs = NA_integer_, txt_chars = NA_integer_, status = paste0("page_http_", pg$status)))
  if (is.na(title)) title <- str_squish(str_match(pg$text, "(?is)<title>(.*?)</title>")[, 2]) %||% title
  docs <- unique(str_match_all(pg$text, "(?i)(/pub/acat/documents/r[0-9]+/[^\"']+?\\.pdf)")[[1]][, 2])
  if (!length(docs))
    return(row(pdf_url = NA_character_, http = pg$status, bytes = NA_integer_, is_pdf = FALSE, n_docs = 0L, txt_chars = NA_integer_, status = "no_pdf_document"))
  pdf_url <- paste0("https://a100.gov.bc.ca", pick_main(docs))
  dest <- file.path(pdf_dir, paste0(report_id, ".pdf")); txt <- sub("\\.pdf$", ".txt", dest)
  http <- NA_integer_
  if (!(file.exists(dest) && file.info(dest)$size > 0 && identical(readBin(dest, "raw", 4), charToRaw("%PDF")))) {
    for (attempt in 1:2) {
      r <- tryCatch(curl::curl_fetch_disk(pdf_url, dest, handle = handle()), error = function(e) NULL)
      http <- if (is.null(r)) NA_integer_ else r$status_code
      if (!is.na(http) && http == 200L) break
      unlink(dest); Sys.sleep(2)
    }
  } else http <- 200L
  is_pdf <- file.exists(dest) && file.info(dest)$size > 4 && identical(readBin(dest, "raw", 4), charToRaw("%PDF"))
  if (!is_pdf) { unlink(dest); return(row(pdf_url, http, bytes = NA_integer_, is_pdf = FALSE, n_docs = length(docs), txt_chars = NA_integer_, status = "pdf_fetch_failed")) }
  if (!file.exists(txt) || file.info(txt)$size == 0) system2(pdftotext, c("-layout", shQuote(dest), shQuote(txt)), stdout = FALSE, stderr = FALSE)
  txt_chars <- if (file.exists(txt)) file.info(txt)$size else 0L
  row(pdf_url, http, bytes = file.info(dest)$size, is_pdf = TRUE, n_docs = length(docs), txt_chars = as.integer(txt_chars),
      # a scanned PDF with no text layer yields a few dozen characters of page furniture
      status = if (txt_chars >= 500) "ok" else "no_text")
}
message(sprintf("Fetching %d reports for %s ...", nrow(all_reports), wsg_target))
fetched <- pmap_dfr(all_reports[c("report_id", "title", "source")], fetch_one) %>%
  left_join(all_reports %>% select(report_id, pscis_layer, pscis_tag, n_crossings), by = "report_id")
readr::write_csv(fetched, file.path(out_dir, "reports_fetch.csv"))
print(count(fetched, status))

# ---- 4. reconcile --------------------------------------------------------------
stopifnot("every resolved report has a manifest row" = setequal(fetched$report_id, all_reports$report_id))
bad <- fetched %>% filter(status %in% c("pdf_fetch_failed") | str_detect(status, "^page_http_"))
named <- fetched %>% filter(status %in% c("no_pdf_document", "no_text"))
if (nrow(named)) message("  reports with no readable PDF (recorded, not fatal): ",
                         paste(sprintf("%s [%s]", named$report_id, named$status), collapse = ", "))
if (nrow(bad)) stop("Fetch failed for report(s) ", paste(bad$report_id, collapse = ", "),
                    " — see ", file.path(out_dir, "reports_fetch.csv"), call. = FALSE)
message(sprintf("Done %s: %d reports, %d with text (%d from PSCIS links, %d from keyword search). -> %s",
                wsg_target, nrow(fetched), sum(fetched$status == "ok"),
                sum(fetched$source == "pscis"), sum(fetched$source == "ecocat_search"), pdf_dir))
