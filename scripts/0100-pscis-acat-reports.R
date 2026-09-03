# scripts/0100-pscis-acat-reports.R
# ---------------------------------------------------------------------------
# Fieldwork-prep step 1: pull PSCIS (+ ACAT) records for a watershed group and
# build (a) a `crossings` table and (b) a deduped `reports` table keyed on
# `ecocat_url` (the link to the upstream EcoCat report for that past work).
#
# WHY / DESIGN NOTES (this pipeline is new — notes live here, not a README yet):
#   - The four provincial PSCIS layers each carry an `ecocat_url` linking the
#     crossing to the report that documents the assessment / confirmation /
#     design / remediation. We harvest those URLs -> the past-reports list.
#   - The raw SVW layers have NO watershed_group_code, so we spatially intersect
#     each with whse_basemapping.fwa_watershed_groups_poly (proven pattern from
#     fish_passage_skeena_2022_planning/scripts/extract-pg.R and
#     scripts/02_reporting/0100-load-bcfishpass-data.R).
#   - `acat_report_point_pub_svw` is NOT in the newgraph DB -> pulled via bcdata.
#   - GOTCHA (skeena extract-pg.R): the ecocat_url stored in PSCIS is sometimes
#     wrong for the crossing. Treat the harvested list as leads to verify, not gospel.
#
# INPUT:  wsg_target (watershed group code). Live bcfishpass DB via SSH tunnel :63333.
# OUTPUT: data/<wsg>/crossings.csv, reports.csv, pscis_<wsg>.gpkg
#
# OPEN QUESTIONS:
#   - Do we want ALL assessments or only barriers/potential-barriers in `crossings`?
#     (kept all for now; filter downstream in the priority-table step.)
#   - bcdata ACAT pull is bbox-based; may over-select slightly (clip to poly below).
# ---------------------------------------------------------------------------

suppressMessages({
  library(DBI); library(RPostgres); library(sf); library(dplyr)
  library(stringr); library(purrr); library(readr); library(tidyr)
})
sf::sf_use_s2(FALSE)
`%||%` <- function(a, b) if (is.null(a)) b else a

# ---- params -----------------------------------------------------------------
# watershed group code: env var WSG_TARGET, else pre-set `wsg_target`, else PCEA
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else "PCEA"
wsg_lower  <- tolower(wsg_target)
out_dir    <- file.path("data", wsg_lower)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- connection -------------------------------------------------------------
# Direct DBI to the tunnel (proven). fpr::fpr_db_conn() is the ~/.Renviron-based
# equivalent used elsewhere in the template.
conn <- DBI::dbConnect(RPostgres::Postgres(),
                       host = "localhost", port = 63333,
                       dbname = "bcfishpass", user = "newgraph")

pscis_layers <- c(
  assessment   = "whse_fish.pscis_assessment_svw",
  confirmation = "whse_fish.pscis_habitat_confirmation_svw",
  design       = "whse_fish.pscis_design_proposal_svw",
  remediation  = "whse_fish.pscis_remediation_svw"
)

# ---- pull each PSCIS layer, spatially clipped to the watershed group ---------
pull_layer <- function(tbl, wsg) {
  q <- glue::glue_sql("
    SELECT p.*
    FROM {`schema`}.{`table`} p
    JOIN whse_basemapping.fwa_watershed_groups_poly w
      ON ST_Intersects(w.geom, p.geom)
    WHERE w.watershed_group_code = {wsg}",
    schema = strsplit(tbl, "\\.")[[1]][1],
    table  = strsplit(tbl, "\\.")[[1]][2],
    wsg    = wsg, .con = conn)
  out <- tryCatch(sf::st_read(conn, query = q, quiet = TRUE),
                  error = function(e) { message("  ! ", tbl, ": ", conditionMessage(e)); NULL })
  out
}

message("Pulling PSCIS layers for ", wsg_target, " ...")
layers <- imap(pscis_layers, ~{
  d <- pull_layer(.x, wsg_target)
  if (!is.null(d) && nrow(d)) d$pscis_layer <- .y
  message(sprintf("  %-12s %s rows", .y, ifelse(is.null(d), "0", nrow(d))))
  d
})
# drop layers that are NULL or empty (empty st_read results carry no CRS)
layers <- layers[!map_lgl(layers, ~ is.null(.x) || nrow(.x) == 0)]

# ---- helper: first column matching a pattern (schemas differ across layers) --
first_col <- function(df, pattern) {
  hit <- names(df)[str_detect(names(df), pattern)]
  if (length(hit)) hit[1] else NA_character_
}

# ---- reports table: distinct ecocat_url across all layers -------------------
reports <- imap_dfr(layers, ~{
  df <- sf::st_drop_geometry(.x)
  if (!"ecocat_url" %in% names(df)) return(NULL)
  date_col <- first_col(df, "_date$")
  cons_col <- first_col(df, "consultant")
  df %>%
    transmute(
      pscis_layer = .y,
      ecocat_url,
      consultant  = if (!is.na(cons_col)) .data[[cons_col]] else NA_character_,
      year        = if (!is.na(date_col)) lubridate::year(as.Date(.data[[date_col]])) else NA_integer_,
      stream_crossing_id = if ("stream_crossing_id" %in% names(df)) stream_crossing_id else NA_integer_
    ) %>%
    filter(!is.na(ecocat_url) & ecocat_url != "")
}) %>%
  group_by(pscis_layer, ecocat_url, consultant, year) %>%
  summarise(n_crossings = n_distinct(stream_crossing_id), .groups = "drop") %>%
  mutate(report_id = str_extract(ecocat_url, "reportId=([0-9]+)") %>% str_remove("reportId=")) %>%
  arrange(pscis_layer, year)

# ---- crossings table: assessments-centric, with coords ----------------------
assess <- layers[["assessment"]]
crossings <- NULL
if (!is.null(assess) && nrow(assess)) {
  xy <- assess %>% st_transform(4326) %>% st_coordinates()
  ad <- sf::st_drop_geometry(assess)
  keep <- intersect(
    c("stream_crossing_id","external_crossing_reference","pscis_crossing_id",
      "assessment_date","consultant_name","stream_name","gazetted_names","road_name",
      "current_barrier_result_code","barrier_result","habitat_value_code",
      "ecocat_url","image_view_url"),
    names(ad))
  crossings <- ad[, keep, drop = FALSE] %>%
    mutate(lon = round(xy[,1], 6), lat = round(xy[,2], 6),
           watershed_group_code = wsg_target) %>%
    # flag presence in the other three PSCIS phases
    mutate(
      has_confirmation = stream_crossing_id %in% (layers[["confirmation"]]$stream_crossing_id %||% integer()),
      has_design       = stream_crossing_id %in% (layers[["design"]]$stream_crossing_id %||% integer()),
      has_remediation  = stream_crossing_id %in% (layers[["remediation"]]$stream_crossing_id %||% integer())
    ) %>%
    arrange(stream_crossing_id)
}

# ---- write outputs ----------------------------------------------------------
readr::write_csv(reports, file.path(out_dir, "reports.csv"))
if (!is.null(crossings)) readr::write_csv(crossings, file.path(out_dir, "crossings.csv"))

gpkg <- file.path(out_dir, paste0("pscis_", wsg_lower, ".gpkg"))
iwalk(layers, ~ sf::st_write(st_transform(.x, 4326), gpkg, layer = .y,
                             delete_layer = TRUE, quiet = TRUE))

DBI::dbDisconnect(conn)

message("\n== ", wsg_target, " summary ==")
message("reports (distinct ecocat_url rows): ", nrow(reports))
message("crossings (assessments): ", ifelse(is.null(crossings), 0, nrow(crossings)))
message("outputs -> ", out_dir)
