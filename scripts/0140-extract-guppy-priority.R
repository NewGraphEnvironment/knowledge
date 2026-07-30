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
#
#   - DO NOT drive this off PSCIS. (Bug fixed 2026-07-14.) The first cut filtered
#     crossings.csv down to the Table-8 ids, which silently dropped every Guppy
#     priority site that has NO PSCIS record — and the highest-value site in PINE
#     is exactly that: 2006.071 is a Pine River oxbow cut off by Hwy 97 fill with
#     structure type "None". PSCIS is a *stream crossing* inventory, so a fill with
#     no crossing was never entered. Drive off the REPORT, left-join PSCIS.
#   - Coordinates for the un-entered sites come from the report's own detail sheets
#     (Appendix: one column-aligned line per site, "id  easting northing  stream
#     road  responsibility  class  type" — 686 of them, split on 2+ spaces).
#   - Geo-filter with the FWA watershed-group poly via bcdata (no DB tunnel needed).
#     Table 8's 17 P1 sites span two groups: 12 PINE, 5 MURR (Murray R., Tumbler
#     Ridge) — the MURR ones are NOT ours until we pull that group.
#
# INPUT:  PDF_PATH (env; the Guppy inventory PDF, from Zotero/EcoCat 11786)
#         data/planning/<wsg>/crossings.csv (from 0100)
# OUTPUT: data/planning/<wsg>/priority_guppy_p1.csv
#         columns `pscis_matched` + `coord_source` say whether PSCIS knows the site
#         and where the coordinates came from.
# ---------------------------------------------------------------------------

suppressMessages({library(dplyr); library(stringr); library(purrr); library(sf); library(bcdata)})
sf::sf_use_s2(FALSE)

wsg      <- toupper(if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else "PINE")
wsg_low  <- tolower(wsg)
pdf_path <- Sys.getenv("PDF_PATH")
stopifnot("set PDF_PATH to the Guppy inventory PDF" = nzchar(pdf_path), file.exists(pdf_path))
txt_path <- tempfile(fileext = ".txt")
system2("pdftotext", c("-layout", shQuote(pdf_path), shQuote(txt_path)))
txt <- readLines(txt_path, warn = FALSE)

# --- Table 8 (Priority 1 Sites): the id list --------------------------------
# Bound the section at BOTH ends. The header-to-APPENDIX-1 span overshoots the table
# by ~330 lines of report prose (3.1.1 Remediation Recommendations onward); left
# unbounded, the last site's block swallows all of it into guppy_notes. The table
# ends at the first numbered section heading that is not a site row.
start  <- grep("Table 8. Priority 1 Sites", txt, fixed = TRUE)
start  <- start[length(start)]                                  # body header, not TOC
end    <- grep("APPENDIX 1. STREAM CROSSING ASSESSMENT", txt, fixed = TRUE)
end    <- end[end > start][1]
sec    <- txt[start:(end - 1)]
bare   <- gsub("\f", "", sec)                                   # page breaks glue onto headings
hdr    <- grep("^\\s*[0-9]+(\\.[0-9]+)+\\.?\\s+[A-Z]", bare)    # e.g. "3.1.1.  Remediation Rec..."
hdr    <- hdr[!grepl("^\\s*2006\\.", bare[hdr])]                # site rows also look numeric
if (length(hdr)) sec <- sec[1:(hdr[1] - 1)]
p1_ids <- unique(na.omit(str_match(sec, "^\\s*(2006\\.[0-9]+)")[, 2]))
message("Guppy Priority-1 site IDs in Table 8: ", length(p1_ids))

# --- Detail sheets: id + UTM + names for every site in the report ------------
# One column-aligned line per site. Pull id/easting/northing with an anchored regex
# (NOT the whitespace split — on 8 lines the stream name abuts the northing with a
# single space, and splitting on 2+ spaces swallowed the northing, dropping the row).
m    <- str_match(txt, "^\\s*(2006\\.[0-9]{3})\\s+([0-9]{6})\\s+([0-9]{7})\\s+(.*)$")
keep <- !is.na(m[, 1])
# Remaining fields: <stream> <road> [<responsibility>] <class> <type>. Responsibility
# is blank on 10 lines, which shifts everything left — so index the tail FROM THE END.
f  <- str_split(str_trim(m[keep, 5]), "\\s{2,}")
at <- function(i, from_end = FALSE) map_chr(f, ~{
  k <- if (from_end) length(.x) - i + 1 else i
  if (k >= 1 && k <= length(.x)) .x[k] else NA_character_
})
det <- tibble(
  guppy_id       = m[keep, 2],
  easting        = as.numeric(m[keep, 3]),
  northing       = as.numeric(m[keep, 4]),
  stream_name    = at(1),
  road_name      = at(2),
  responsibility = map_chr(f, ~ if (length(.x) >= 5) .x[3] else NA_character_),
  stream_class   = at(2, from_end = TRUE),
  structure_type = at(1, from_end = TRUE)
) |>
  distinct(guppy_id, .keep_all = TRUE)
# fail loudly if the tail-indexing assumption breaks (class should be S1-S6 / P1-P6 / NCD)
bad <- sum(!grepl("^(S|P)[0-9]|NCD", det$stream_class))
message("sites with a detail-sheet UTM: ", nrow(det),
        if (bad) paste0("  [WARNING: ", bad, " rows have an unexpected stream_class — check field alignment]") else "")

# --- P1 sites, geo-filtered to the watershed group ---------------------------
# report UTMs are Zone 10 (as printed on the detail sheets) -> NAD83 / EPSG:26910
p1 <- det |> filter(guppy_id %in% p1_ids)
stopifnot("some Table-8 ids have no detail sheet" = nrow(p1) == length(p1_ids))

# the BC WFS intermittently returns HTTP 400 on a valid request — retry before giving up
fetch_wsg_poly <- function(code, tries = 5) {
  for (i in seq_len(tries)) {
    p <- try(bcdc_query_geodata("WHSE_BASEMAPPING.FWA_WATERSHED_GROUPS_POLY") |>
               filter(WATERSHED_GROUP_CODE == code) |> collect(), silent = TRUE)
    if (!inherits(p, "try-error") && nrow(p)) return(st_transform(p, 4326))
    message("  bcdata WFS attempt ", i, " failed; retrying")
    Sys.sleep(4)
  }
  stop("could not fetch FWA watershed-group poly for ", code, " after ", tries, " tries")
}
poly <- fetch_wsg_poly(wsg)

p1_sf <- st_as_sf(p1, coords = c("easting", "northing"), crs = 26910, remove = FALSE) |>
  st_transform(4326)
# st_intersects, not st_within: a site sitting exactly on the group boundary is still
# ours. This whole script exists to stop silently dropping priority sites.
p1_sf$in_wsg <- lengths(st_intersects(p1_sf, poly)) > 0
message(sum(p1_sf$in_wsg), " of ", nrow(p1_sf), " Guppy Priority-1 sites fall inside ", wsg,
        " (", sum(!p1_sf$in_wsg), " in other watershed groups)")

xy <- st_coordinates(p1_sf)
p1 <- p1_sf |>
  st_drop_geometry() |>
  mutate(report_lon = round(xy[, 1], 6), report_lat = round(xy[, 2], 6)) |>
  filter(in_wsg)

# --- Left-join PSCIS on external_crossing_reference (== Guppy id) ------------
# read the join key AS CHARACTER on BOTH sides. Type-guessing makes
# external_crossing_reference a double, and as.character() then drops the trailing
# zero ("2006.500" -> "2006.5"), so the join silently misses. 32 of 307 PINE refs
# round-trip wrong this way — it is not an edge case.
cr <- readr::read_csv(file.path("data/planning", wsg_low, "crossings.csv"), show_col_types = FALSE,
                      col_types = readr::cols(external_crossing_reference = readr::col_character()))

pri <- p1 |>
  left_join(
    cr |> select(external_crossing_reference, stream_crossing_id,
                 pscis_stream_name = stream_name, pscis_road_name = road_name,
                 barrier = current_barrier_result_code,
                 pscis_lon = lon, pscis_lat = lat),
    by = c("guppy_id" = "external_crossing_reference")
  ) |>
  mutate(
    pscis_matched = !is.na(stream_crossing_id),
    # PSCIS coords are authoritative when the site is in PSCIS; else fall back to
    # the report's own detail-sheet UTM (the only coords that exist for these).
    coord_source  = if_else(pscis_matched, "PSCIS", "Guppy detail sheet (UTM 10N)"),
    lon           = coalesce(pscis_lon, report_lon),
    lat           = coalesce(pscis_lat, report_lat),
    stream_name   = coalesce(pscis_stream_name, stream_name),
    road_name     = coalesce(pscis_road_name, road_name),
    followup_priority = "high (Guppy P1)",
    source        = "Guppy 2006 inventory (EcoCat 11786), Table 8"
  ) |>
  select(stream_crossing_id, guppy_id, stream_name, barrier, road_name,
         structure_type, lon, lat, pscis_matched, coord_source,
         followup_priority, source) |>
  arrange(!is.na(stream_crossing_id), stream_crossing_id, guppy_id)

readr::write_csv(pri, file.path("data/planning", wsg_low, "priority_guppy_p1.csv"))
message(nrow(pri), " priority sites written for ", wsg,
        " (", sum(!pri$pscis_matched), " have NO PSCIS record — report coords only)")
print(as.data.frame(pri[, c("stream_crossing_id","guppy_id","stream_name","structure_type",
                            "barrier","pscis_matched","coord_source")]))
