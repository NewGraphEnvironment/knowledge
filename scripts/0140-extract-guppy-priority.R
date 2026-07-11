# scripts/04_planning/0140-extract-guppy-priority.R
# ---------------------------------------------------------------------------
# Farm the priority table out of an inventory PDF and reconcile the report's own
# crossing IDs back to PSCIS. Worked example: Guppy's "Peace River Stream Crossing
# Structure Inventory 2006" (EcoCat reportId 11786) — the source inventory for ALL
# 307 PINE PSCIS crossings (funding_project "2006-07 Peace River Assessments").
#
# WHY / DESIGN NOTES:
#   - This is the payoff the reporting struggled with: reports carry their own
#     crossing IDs (Guppy uses `2006.NNN`). Here that ID == PSCIS
#     `external_crossing_reference` VERBATIM, so the join is exact — no spatial
#     snap needed. (Other reports may need the spatial fallback; see plan.)
#   - Guppy "Table 8. Priority 1 Sites" is his own highest-priority barrier list —
#     the field-prep gold. We lift those IDs and attach current PSCIS id + coords.
#   - Parsing is specific to THIS report's pdftotext -layout output (Table 8 rows
#     start with `2006.NNN`; section ends at "APPENDIX 1. STREAM CROSSING ...").
#     Treat as a per-report extractor, not a generic one.
#
# INPUT:  PDF_PATH (env; the Guppy inventory PDF, from Zotero/EcoCat 11786)
#         data/planning/<wsg>/crossings.csv (from 0100)
# OUTPUT: data/planning/<wsg>/priority_guppy_p1.csv
# ---------------------------------------------------------------------------

suppressMessages({library(dplyr); library(stringr)})

wsg      <- tolower(if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else "PINE")
pdf_path <- Sys.getenv("PDF_PATH")
stopifnot("set PDF_PATH to the Guppy inventory PDF" = nzchar(pdf_path), file.exists(pdf_path))
txt_path <- tempfile(fileext = ".txt")
system2("pdftotext", c("-layout", shQuote(pdf_path), shQuote(txt_path)))
txt <- readLines(txt_path, warn = FALSE)

# --- isolate Table 8 (Priority 1 Sites) --------------------------------------
start <- grep("Table 8. Priority 1 Sites", txt, fixed = TRUE)
start <- start[length(start)]                                   # body header
end   <- grep("APPENDIX 1. STREAM CROSSING ASSESSMENT", txt, fixed = TRUE)
end   <- end[end > start][1]
sec   <- txt[start:(end - 1)]
p1_ids <- unique(na.omit(str_match(sec, "^\\s*(2006\\.[0-9]+)")[, 2]))
message("Guppy Priority-1 site IDs in Table 8: ", length(p1_ids))

# --- join to PSCIS crossings on external_crossing_reference (== Guppy id) -----
cr <- readr::read_csv(file.path("data/planning", wsg, "crossings.csv"), show_col_types = FALSE) |>
  mutate(external_crossing_reference = as.character(external_crossing_reference))

pri <- cr |>
  filter(external_crossing_reference %in% p1_ids) |>
  transmute(stream_crossing_id, guppy_id = external_crossing_reference, stream_name,
            barrier = current_barrier_result_code, road_name, lon, lat,
            followup_priority = "high (Guppy P1)",
            source = "Guppy 2006 inventory (EcoCat 11786), Table 8") |>
  arrange(stream_crossing_id)

readr::write_csv(pri, file.path("data/planning", wsg, "priority_guppy_p1.csv"))
message(nrow(pri), " of ", length(p1_ids), " Guppy Priority-1 sites fall inside ", toupper(wsg))
print(as.data.frame(pri[, c("stream_crossing_id","guppy_id","stream_name","barrier")]))
