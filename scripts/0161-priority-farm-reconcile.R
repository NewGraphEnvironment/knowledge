# scripts/0161-priority-farm-reconcile.R
# ---------------------------------------------------------------------------
# Reconcile priority rows farmed from report PDFs (wf_farm_priority output) to
# PSCIS crossings, and stamp the TRUE watershed_group_code per row.
#
# WHY UNIFIED (not per-group):
#   A single report can span several watershed groups (e.g. Hooft 2015 "Fish
#   Passage Assessments, Willow/Tabor/Bowron, 787 locations" = report 50797),
#   but the harvest tags a report with ONE extent. Reconciling only against the
#   tag-group's crossings loses every crossing that belongs to a sibling group
#   (Hooft's 5 Willow + 5 Tabor priority sites vanished). So we reconcile each
#   farmed row against the UNION of all watershed groups' crossings and assign
#   watershed_group_code from the crossing it actually matches.
#
# JOIN LADDER per row (first hit wins), against the union of crossings:
#   1. printed pscis_crossing_id  == stream_crossing_id      (globally unique)
#   2. report_crossing_id         == external_crossing_reference
#        - if the harvest-tag group holds that ref, prefer it (tie-break)
#        - else if exactly one group holds it, take it
#        - else first, flagged *-ambig
#   3. normalized ref (BOWRON-NN <-> BOWRON_2008_NN)
#   watershed_group_code = matched crossing's group; unmatched keeps harvest tag.
#
# INPUT:  FARM_JSON = comma-separated wf_farm_priority output file(s) OR the
#         workflow journal.jsonl file(s) (per-agent {type:result} lines) —
#         journals survive after task .output files are cleaned up.
#         data/<wsg>/crossings.csv for every group (from 0100)
# OUTPUT: data/priority_farmed_all.csv  (one combined table, all farmed
#         columns incl. notes, + watershed_group_code, pscis_*, coord fields)
# ---------------------------------------------------------------------------
suppressMessages({library(jsonlite); library(dplyr); library(stringr); library(purrr); library(readr); library(tidyr)})
`%||%` <- function(a,b) if (is.null(a)) b else a

farm_json <- Sys.getenv("FARM_JSON")
stopifnot("FARM_JSON must point at wf_farm_priority output(s)" = nzchar(farm_json))
files <- trimws(strsplit(farm_json, ",")[[1]]); files <- files[file.exists(files)]
stopifnot("no FARM_JSON files found" = length(files) > 0)

load_extracts <- function(f) {
  if (grepl("journal", f) || grepl("[.]jsonl$", f)) {
    # ndjson workflow journal: keep per-agent results that carry a `rows` array
    lines <- readLines(f, warn = FALSE)
    ex <- list()
    for (l in lines) {
      x <- tryCatch(fromJSON(l, simplifyVector = FALSE), error = function(e) NULL)
      if (!is.null(x) && identical(x$type, "result") && !is.null(x$result$rows)) ex[[length(ex)+1]] <- x$result
    }
    ex
  } else { j <- fromJSON(f, simplifyVector = FALSE); j$result$extracts %||% j$extracts }
}
extracts <- unlist(lapply(files, load_extracts), recursive = FALSE)
# dedup identical report extracts (cache replays) by (code, report_id)
seen <- character(0)
extracts <- Filter(function(e) { k <- paste(e$code, e$report_id); if (k %in% seen) FALSE else { seen[[length(seen)+1]] <<- k; TRUE } }, extracts)
stopifnot("no extracts found" = length(extracts) > 0)

# ---- flatten farmed rows (keep every field incl. notes) ---------------------
rows <- map_dfr(extracts, function(e) {
  if (is.null(e$rows) || !length(e$rows)) return(NULL)
  map_dfr(e$rows, function(r) tibble(
    code = e$code %||% NA, report_id = e$report_id %||% NA, table_source = e$table_source %||% NA,
    report_crossing_id = r$report_crossing_id %||% "", pscis_crossing_id = r$pscis_crossing_id %||% "",
    stream_name = r$stream_name %||% "", priority = r$priority %||% "", barrier = r$barrier %||% "",
    fish_barrier_score = r$fish_barrier_score %||% "", habitat_value = r$habitat_value %||% "",
    coords = r$coords %||% "", upstream_fish = r$upstream_fish %||% "",
    recommendation = r$recommendation %||% "", notes = r$notes %||% ""))
})
message("farmed rows: ", nrow(rows), " from ", length(extracts), " report extracts")

# ---- union of all crossings, keyed for lookup -------------------------------
norm_key <- function(x) { x <- as.character(x)
  pre <- str_to_lower(str_extract(x, "^[A-Za-z]+"))
  num <- vapply(str_extract_all(x, "[0-9]+"), function(v) if (length(v)) v[length(v)] else NA_character_, character(1))
  ifelse(is.na(pre) | is.na(num), NA_character_, paste0(pre, "_", num)) }

# restrict the union to the Fraser-project groups (exclude Peace pcea/pine/para etc.)
FRASER <- c("BOWR","MCGR","COTR","WILL","UFRA","TABR","FRAN","LCHL","NECR")
cross_files <- list.files("data", pattern="^crossings.csv$", recursive=TRUE, full.names=TRUE)
cross_files <- cross_files[toupper(basename(dirname(cross_files))) %in% FRASER]
allx <- map_dfr(cross_files, function(cf) {
  wsg <- toupper(basename(dirname(cf)))
  read_csv(cf, show_col_types=FALSE) %>%
    transmute(wsg = wsg, scid = as.character(stream_crossing_id), ext = as.character(external_crossing_reference),
              nk = norm_key(external_crossing_reference),
              barrier = current_barrier_result_code, habitat = habitat_value_code,
              lon, lat, has_confirmation, has_design, has_remediation)
})
by_ext  <- split(allx, allx$ext)
by_scid <- split(allx, allx$scid)
by_nk   <- split(allx[!is.na(allx$nk),], allx$nk[!is.na(allx$nk)])
message("union crossings: ", nrow(allx), " across ", n_distinct(allx$wsg), " groups")

# pick one crossing record from a candidate set.
#  - harvest-tag group holds the ref  -> use it (stays put; the common, safe case)
#  - exactly one group holds it        -> move there (unambiguous, e.g. Hooft's Willow sites)
#  - several groups hold it, none the tag group -> DON'T match. These are almost all
#    recon reach-sequence numbers (1,2,3..) colliding with small integer crossing refs
#    in big groups; moving them there is spurious. Leave the row in its harvest group, unmatched.
choose <- function(cand, code, method) {
  if (is.null(cand) || !nrow(cand)) return(NULL)
  if (!is.na(code) && code %in% cand$wsg) return(cbind(cand[cand$wsg==code,][1,], method=method))
  if (length(unique(cand$wsg)) == 1) return(cbind(cand[1,], method=method))
  NULL
}
recon_row <- function(code, rid, pid, ts) {
  # habitat/reach inventories number sites 1,2,3.. (report-local sequence) — those are
  # NOT crossing ids; matching them to external_crossing_reference is spurious. Skip:
  # keep the harvest group, place from the row's own report coords downstream.
  if (grepl("habitat-inventory", ts %||% "", ignore.case = TRUE)) return(NULL)
  if (nzchar(pid)) { h <- choose(by_scid[[pid]], code, "pscis-id"); if (!is.null(h)) return(h) }
  if (nzchar(rid)) {
    h <- choose(by_ext[[rid]], code, "external-ref"); if (!is.null(h)) return(h)
    nk <- norm_key(rid); if (!is.na(nk)) { h <- choose(by_nk[[nk]], code, "normalized-ref"); if (!is.null(h)) return(h) }
  }
  NULL
}

picked <- pmap(list(rows$code, rows$report_crossing_id, rows$pscis_crossing_id, rows$table_source), recon_row)
get <- function(col) map_chr(picked, ~ if (is.null(.x)) NA_character_ else as.character(.x[[col]]))
out <- rows %>% mutate(
  reconcile_method       = map_chr(picked, ~ if (is.null(.x)) "unmatched" else .x$method),
  watershed_group_code   = coalesce(get("wsg"), code),
  pscis_stream_crossing_id = get("scid"), pscis_barrier_result = get("barrier"),
  pscis_habitat_value    = get("habitat"), pscis_lon = get("lon"), pscis_lat = get("lat"),
  pscis_has_confirmation = get("has_confirmation")
)

out_f <- file.path("data","planning","priority_farmed_all.csv")
write_csv(out, out_f)
message("\n== wrote ", out_f, " (", nrow(out), " rows) ==")
message("by watershed_group_code:"); print(as.data.frame(count(out, watershed_group_code, sort=TRUE)), row.names=FALSE)
message("reconcile methods:"); print(as.data.frame(count(out, reconcile_method, sort=TRUE)), row.names=FALSE)
