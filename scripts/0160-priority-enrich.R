# scripts/04_planning/0160-priority-enrich.R
# ---------------------------------------------------------------------------
# Enrich the Pine priority table (Guppy Table 8, from 0140) and export for the field:
#   - Guppy's per-site NoPass issue + recommendation text (farmed from the PDF)
#   - bcfishpass bull-trout habitat km (grayling is NOT modelled -> see #192)
#   - XREF: confirmations / designs / remediations already done on the same crossing
#           (queried live by stream_crossing_id)
#   - GPKG + KML for QGIS / Mergin field navigation
#
# NOTE (xref result for PINE, 2026-07-11): 0/307 crossings have any habitat
# confirmation, design, or remediation — Guppy's 137 barriers are all un-followed-up.
#
# INPUT:  data/planning/pine/priority_guppy_p1.csv, PDF_PATH (Guppy inventory), DB :63333
# OUTPUT: data/planning/pine/priority_pine_enriched.csv + .gpkg + .kml
# ---------------------------------------------------------------------------
suppressMessages({library(DBI); library(RPostgres); library(sf); library(dplyr); library(stringr)})
sf::sf_use_s2(FALSE)

pri <- readr::read_csv("data/planning/pine/priority_guppy_p1.csv", show_col_types = FALSE) |>
  mutate(guppy_id = as.character(guppy_id))

# ---- Guppy Table 8 per-site notes (issue + recommendation) ------------------
pdf_path <- Sys.getenv("PDF_PATH")
stopifnot("set PDF_PATH to the Guppy inventory PDF" = nzchar(pdf_path), file.exists(pdf_path))
txt_path <- tempfile(fileext = ".txt")
system2("pdftotext", c("-layout", shQuote(pdf_path), shQuote(txt_path)))
txt <- readLines(txt_path, warn = FALSE)
s <- grep("Table 8. Priority 1 Sites", txt, fixed = TRUE); s <- s[length(s)]
e <- grep("APPENDIX 1. STREAM CROSSING ASSESSMENT", txt, fixed = TRUE); e <- e[e > s][1]
sec <- txt[s:(e - 1)]
starts <- grep("^\\s*2006\\.[0-9]+", sec)
notes <- lapply(seq_along(starts), function(i) {
  block <- sec[starts[i]:(if (i < length(starts)) starts[i + 1] - 1 else length(sec))]
  id <- str_match(block[1], "(2006\\.[0-9]+)")[, 2]
  list(guppy_id = id, guppy_notes = str_squish(paste(block, collapse = " ")))
})
notes <- bind_rows(notes)
pri <- pri |> left_join(notes, by = "guppy_id")

# ---- bcfishpass bull-trout habitat + xref confirmations/designs/remediations -
conn <- DBI::dbConnect(RPostgres::Postgres(), host = "localhost", port = 63333, dbname = "bcfishpass", user = "newgraph")
ids <- paste(pri$stream_crossing_id, collapse = ",")
hab <- DBI::dbGetQuery(conn, sprintf("
  SELECT stream_crossing_id, aggregated_crossings_id,
         bt_spawningrearing_km, bt_spawningrearing_belowupstrbarriers_km
  FROM bcfishpass.crossings_vw WHERE stream_crossing_id IN (%s)", ids))
xref <- function(tbl) DBI::dbGetQuery(conn, sprintf(
  "SELECT DISTINCT stream_crossing_id FROM whse_fish.%s WHERE stream_crossing_id IN (%s)", tbl, ids))$stream_crossing_id
conf <- xref("pscis_habitat_confirmation_svw"); des <- xref("pscis_design_proposal_svw"); rem <- xref("pscis_remediation_svw")
DBI::dbDisconnect(conn)

out <- pri |>
  left_join(hab, by = "stream_crossing_id") |>
  mutate(
    bt_hab_km        = round(coalesce(bt_spawningrearing_belowupstrbarriers_km, 0), 2),
    grayling_modelled = FALSE,                        # bcfishpass has no grayling model (#192)
    has_confirmation = stream_crossing_id %in% conf,
    has_design       = stream_crossing_id %in% des,
    has_remediation  = stream_crossing_id %in% rem
  ) |>
  select(stream_crossing_id, guppy_id, stream_name, barrier, road_name, lon, lat,
         followup_priority, bt_hab_km, grayling_modelled,
         has_confirmation, has_design, has_remediation, aggregated_crossings_id, guppy_notes) |>
  arrange(stream_crossing_id)

readr::write_csv(out, "data/planning/pine/priority_pine_enriched.csv")

# ---- spatial exports for field nav ------------------------------------------
sfpts <- st_as_sf(out, coords = c("lon", "lat"), crs = 4326, remove = FALSE)
st_write(sfpts, "data/planning/pine/priority_pine.gpkg", "priority_guppy_p1", delete_dsn = TRUE, quiet = TRUE)
st_write(sfpts, "data/planning/pine/priority_pine.kml", delete_dsn = TRUE, quiet = TRUE)

message(nrow(out), " priority sites enriched. confirmations/designs/remediations on any: ",
        sum(out$has_confirmation | out$has_design | out$has_remediation))
message("bt habitat km present at: ", sum(out$bt_hab_km > 0), " sites (grayling not modelled)")
print(as.data.frame(out[, c("stream_crossing_id","guppy_id","stream_name","barrier","bt_hab_km",
                            "has_confirmation","has_remediation")]))
