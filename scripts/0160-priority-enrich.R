# scripts/0160-priority-enrich.R
# ---------------------------------------------------------------------------
# Enrich the Pine priority table (Guppy Table 8, from 0140) and export for the field:
#   - Guppy's per-site NoPass issue + recommendation text (farmed from the PDF)
#   - bcfishpass bull-trout habitat km (grayling is NOT modelled by bcfishpass)
#   - XREF: confirmations / designs / remediations already done on the same crossing
#           (queried live by stream_crossing_id)
#   - GPKG + KML for QGIS / Mergin field navigation
#
# NOTE (xref result for PINE, 2026-07-11): 0/307 crossings have any habitat
# confirmation, design, or remediation — Guppy's 137 barriers are all un-followed-up.
#
# NOTE (2026-07-14): 0140 now carries Guppy priority sites that have NO PSCIS record
# (stream_crossing_id is NA — e.g. 2006.071, the Hwy 97 oxbow with structure type
# "None"). bcfishpass is keyed on stream_crossing_id, so it has nothing to say about
# them: habitat km and the confirmation/design/remediation xref are left NA/FALSE.
# Only query the DB for the rows that actually have an id.
#
# INPUT:  data/pine/priority_guppy_p1.csv, PDF_PATH (Guppy inventory), a bcfishpass database (PG* env vars)
# OUTPUT: data/pine/priority_pine_enriched.csv + .gpkg + .kml
# ---------------------------------------------------------------------------
suppressMessages({library(DBI); library(RPostgres); library(sf); library(dplyr); library(stringr)})
sf::sf_use_s2(FALSE)

# read guppy_id AS CHARACTER — type-guessing makes it a double and "2006.500" -> "2006.5",
# which silently breaks the notes join and corrupts the id in the outputs.
pri <- readr::read_csv("data/pine/priority_guppy_p1.csv", show_col_types = FALSE,
                       col_types = readr::cols(guppy_id = readr::col_character()))

# ---- Guppy Table 8 per-site notes (issue + recommendation) ------------------
pdf_path <- Sys.getenv("PDF_PATH")
stopifnot("set PDF_PATH to the Guppy inventory PDF" = nzchar(pdf_path), file.exists(pdf_path))
txt_path <- tempfile(fileext = ".txt")
system2("pdftotext", c("-layout", shQuote(pdf_path), shQuote(txt_path)))
txt <- readLines(txt_path, warn = FALSE)
s <- grep("Table 8. Priority 1 Sites", txt, fixed = TRUE); s <- s[length(s)]
e <- grep("APPENDIX 1. STREAM CROSSING ASSESSMENT", txt, fixed = TRUE); e <- e[e > s][1]
sec <- txt[s:(e - 1)]
# Bound the table's END too (same as 0140). Without this the LAST site's block runs to
# APPENDIX 1 and swallows ~330 lines of report prose (3.1.1 Remediation Recommendations
# onward) into its guppy_notes — which then ships into the gpkg/kml for field nav.
bare <- gsub("\f", "", sec)
hdr  <- grep("^\\s*[0-9]+(\\.[0-9]+)+\\.?\\s+[A-Z]", bare)
hdr  <- hdr[!grepl("^\\s*2006\\.", bare[hdr])]
if (length(hdr)) sec <- sec[1:(hdr[1] - 1)]
starts <- grep("^\\s*2006\\.[0-9]+", sec)
notes <- lapply(seq_along(starts), function(i) {
  block <- sec[starts[i]:(if (i < length(starts)) starts[i + 1] - 1 else length(sec))]
  id <- str_match(block[1], "(2006\\.[0-9]+)")[, 2]
  list(guppy_id = id, guppy_notes = str_squish(paste(block, collapse = " ")))
})
notes <- bind_rows(notes)
pri <- pri |> left_join(notes, by = "guppy_id")

# ---- bcfishpass bull-trout habitat + xref confirmations/designs/remediations -
# bcfishpass is keyed on stream_crossing_id -> only the PSCIS-matched rows can be enriched
ids <- paste(na.omit(pri$stream_crossing_id), collapse = ",")
# a watershed group whose priority sites are ALL un-entered would give "IN ()" -> SQL error
if (nzchar(ids)) {
  conn <- DBI::dbConnect(RPostgres::Postgres())   # libpq reads the PG* environment variables
  hab <- DBI::dbGetQuery(conn, sprintf("
    SELECT stream_crossing_id, aggregated_crossings_id,
           bt_spawningrearing_km, bt_spawningrearing_belowupstrbarriers_km
    FROM bcfishpass.crossings_vw WHERE stream_crossing_id IN (%s)", ids))
  xref <- function(tbl) DBI::dbGetQuery(conn, sprintf(
    "SELECT DISTINCT stream_crossing_id FROM whse_fish.%s WHERE stream_crossing_id IN (%s)", tbl, ids))$stream_crossing_id
  conf <- xref("pscis_habitat_confirmation_svw"); des <- xref("pscis_design_proposal_svw"); rem <- xref("pscis_remediation_svw")
  DBI::dbDisconnect(conn)
} else {
  message("no priority site has a PSCIS id — skipping bcfishpass enrichment")
  hab <- data.frame(stream_crossing_id = numeric(), aggregated_crossings_id = numeric(),
                    bt_spawningrearing_km = numeric(), bt_spawningrearing_belowupstrbarriers_km = numeric())
  conf <- des <- rem <- numeric()
}

out <- pri |>
  left_join(hab, by = "stream_crossing_id") |>
  mutate(
    # NA (not 0) where bcfishpass has no row — an un-entered site is "unknown", not "no habitat"
    bt_hab_km        = round(bt_spawningrearing_belowupstrbarriers_km, 2),
    grayling_modelled = FALSE,                        # bcfishpass has no grayling model
    has_confirmation = stream_crossing_id %in% conf,
    has_design       = stream_crossing_id %in% des,
    has_remediation  = stream_crossing_id %in% rem
  ) |>
  select(stream_crossing_id, guppy_id, stream_name, barrier, road_name, structure_type,
         lon, lat, pscis_matched, coord_source,
         followup_priority, bt_hab_km, grayling_modelled,
         has_confirmation, has_design, has_remediation, aggregated_crossings_id, guppy_notes) |>
  arrange(!is.na(stream_crossing_id), stream_crossing_id, guppy_id)

readr::write_csv(out, "data/pine/priority_pine_enriched.csv")

# ---- spatial exports for field nav ------------------------------------------
sfpts <- st_as_sf(out, coords = c("lon", "lat"), crs = 4326, remove = FALSE)
st_write(sfpts, "data/pine/priority_pine.gpkg", "priority_guppy_p1", delete_dsn = TRUE, quiet = TRUE)
st_write(sfpts, "data/pine/priority_pine.kml", delete_dsn = TRUE, quiet = TRUE)

message(nrow(out), " priority sites enriched. confirmations/designs/remediations on any: ",
        sum(out$has_confirmation | out$has_design | out$has_remediation))
message("bt habitat km present at: ", sum(out$bt_hab_km > 0, na.rm = TRUE), " sites (grayling not modelled)")
message("no PSCIS record (report coords only, no bcfishpass): ", sum(!out$pscis_matched))
print(as.data.frame(out[, c("stream_crossing_id","guppy_id","stream_name","structure_type",
                            "barrier","bt_hab_km","pscis_matched")]))
