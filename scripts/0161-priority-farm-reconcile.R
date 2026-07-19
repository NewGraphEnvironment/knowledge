# scripts/04_planning/0161-priority-farm-reconcile.R
# ---------------------------------------------------------------------------
# Reconcile priority-table rows farmed from inventory PDFs (by the
# wf_farm_priority workflow) to PSCIS crossings, then write a per-group
# priority CSV for field use.
#
# WHY / DESIGN NOTES:
#   - Inventory/planning reports carry their OWN crossing ids (e.g. "103",
#     "BOWRON_2008_44", "TT1124"). PSCIS stores that id verbatim in
#     external_crossing_reference (same pattern as Guppy 2006.NNN). So the join
#     is EXACT, no spatial snap — mirrors 0140/0160.
#   - Some reports (Masse 52620) also print the PSCIS stream_crossing_id
#     directly -> prefer that when present.
#   - Join ladder per farmed row, first hit wins:
#       1. farmed pscis_crossing_id      == PSCIS stream_crossing_id
#       2. farmed report_crossing_id     == PSCIS external_crossing_reference
#       3. farmed report_crossing_id     == PSCIS stream_crossing_id  (report used PSCIS ids)
#     reconcile_method records which matched (or "unmatched").
#
# INPUT:  FARM_JSON (env) -> the wf_farm_priority task output (.output json)
#         data/planning/<wsg>/crossings.csv  (from 0100)
# OUTPUT: data/planning/<wsg>/priority_farmed.csv  (one per group present)
# ---------------------------------------------------------------------------
suppressMessages({library(jsonlite); library(dplyr); library(stringr); library(purrr); library(readr); library(tidyr)})
`%||%` <- function(a,b) if (is.null(a)) b else a

# FARM_JSON may be a single path or a comma-separated list (to combine >1 farming run).
farm_json <- Sys.getenv("FARM_JSON")
stopifnot("FARM_JSON must point at wf_farm_priority output(s)" = nzchar(farm_json))
files <- trimws(strsplit(farm_json, ",")[[1]])
files <- files[file.exists(files)]
stopifnot("no FARM_JSON files found" = length(files) > 0)

extracts <- unlist(lapply(files, function(f) {
  j <- fromJSON(f, simplifyVector = FALSE)
  j$result$extracts %||% j$extracts
}), recursive = FALSE)
stopifnot("no extracts found in FARM_JSON" = !is.null(extracts) && length(extracts) > 0)
message("combined ", length(files), " farming run(s) -> ", length(extracts), " report extracts")

norm <- function(x) str_trim(tolower(ifelse(is.null(x) || is.na(x), "", as.character(x))))

# flatten farmed rows -> long df
rows <- map_dfr(extracts, function(e) {
  if (is.null(e$rows) || !length(e$rows)) return(NULL)
  map_dfr(e$rows, function(r) tibble(
    code               = e$code %||% NA_character_,
    report_id          = e$report_id %||% NA_character_,
    table_source       = e$table_source %||% NA_character_,
    report_crossing_id = r$report_crossing_id %||% "",
    pscis_crossing_id  = r$pscis_crossing_id %||% "",
    stream_name        = r$stream_name %||% "",
    priority           = r$priority %||% "",
    barrier            = r$barrier %||% "",
    fish_barrier_score = r$fish_barrier_score %||% "",
    habitat_value      = r$habitat_value %||% "",
    coords             = r$coords %||% "",
    upstream_fish      = r$upstream_fish %||% "",
    recommendation     = r$recommendation %||% "",
    notes              = r$notes %||% ""
  ))
})
message("farmed rows: ", nrow(rows), " across ", length(unique(rows$code)), " groups")

# normalized id key: alpha-prefix + LAST number run, e.g. "BOWRON - 44" -> "bowron_44",
# "BOWRON_2008_44" -> "bowron_44". NA when no alpha-prefix (bare numbers) so we never
# false-match a report's crossing "16" to PSCIS BOWRON_2008_16 (different surveys).
norm_key <- function(x) {
  x   <- as.character(x)
  pre <- str_to_lower(str_extract(x, "^[A-Za-z]+"))
  num <- vapply(str_extract_all(x, "[0-9]+"), function(v) if (length(v)) v[length(v)] else NA_character_, character(1))
  ifelse(is.na(pre) | is.na(num), NA_character_, paste0(pre, "_", num))
}

recon_one <- function(df_group, wsg) {
  cf <- file.path("data","planning", tolower(wsg), "crossings.csv")
  if (!file.exists(cf)) { message("  ! no crossings.csv for ", wsg); return(df_group %>% mutate(reconcile_method="no-crossings-file")) }
  cx <- read_csv(cf, show_col_types = FALSE) %>%
    mutate(scid = as.character(stream_crossing_id), ext = as.character(external_crossing_reference), nk = norm_key(external_crossing_reference))
  by_ext  <- cx %>% distinct(ext,  .keep_all = TRUE)
  by_scid <- cx %>% distinct(scid, .keep_all = TRUE)
  by_nk   <- cx %>% filter(!is.na(nk)) %>% distinct(nk, .keep_all = TRUE)
  pull <- function(key, tbl, keycol) {
    m <- tbl[match(key, tbl[[keycol]]), c("stream_crossing_id","current_barrier_result_code","habitat_value_code","lon","lat","has_confirmation","has_design","has_remediation")]
    as_tibble(m)
  }
  out <- df_group %>% rowwise() %>% mutate(
    .m1 = list(if (nzchar(pscis_crossing_id))  pull(pscis_crossing_id,  by_scid, "scid") else pull(NA,by_scid,"scid")),
    .m2 = list(pull(report_crossing_id, by_ext,  "ext")),
    .mn = list(pull(norm_key(report_crossing_id), by_nk, "nk")),
    .m3 = list(pull(report_crossing_id, by_scid, "scid"))
  ) %>% ungroup()
  pick <- function(m1,m2,mn,m3) {
    if (!is.na(m1$stream_crossing_id)) return(c(list(method="pscis-id"),          as.list(m1)))
    if (!is.na(m2$stream_crossing_id)) return(c(list(method="external-ref"),      as.list(m2)))
    if (!is.na(mn$stream_crossing_id)) return(c(list(method="normalized-ref"),    as.list(mn)))
    if (!is.na(m3$stream_crossing_id)) return(c(list(method="report-id-as-pscis"),as.list(m3)))
    list(method="unmatched", stream_crossing_id=NA, current_barrier_result_code=NA, habitat_value_code=NA, lon=NA, lat=NA, has_confirmation=NA, has_design=NA, has_remediation=NA)
  }
  picked <- pmap(list(out$.m1, out$.m2, out$.mn, out$.m3), pick)
  out %>% mutate(
    reconcile_method       = map_chr(picked, "method"),
    pscis_stream_crossing_id = map_chr(picked, ~as.character(.x$stream_crossing_id)),
    pscis_barrier_result   = map_chr(picked, ~as.character(.x$current_barrier_result_code)),
    pscis_habitat_value    = map_chr(picked, ~as.character(.x$habitat_value_code)),
    pscis_lon              = map_chr(picked, ~as.character(.x$lon)),
    pscis_lat              = map_chr(picked, ~as.character(.x$lat)),
    pscis_has_confirmation = map_chr(picked, ~as.character(.x$has_confirmation))
  ) %>% select(-.m1,-.m2,-.mn,-.m3)
}

for (wsg in unique(rows$code)) {
  g <- recon_one(filter(rows, code == wsg), wsg)
  outf <- file.path("data","planning", tolower(wsg), "priority_farmed.csv")
  write_csv(g, outf)
  tab <- g %>% count(reconcile_method) %>% arrange(desc(n))
  message(sprintf("\n== %s -> %s (%d rows) ==", wsg, outf, nrow(g)))
  print(as.data.frame(tab), row.names = FALSE)
}
