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
# The pull and the two table builders live in pkg/R/pscis.R (knw_pscis_*).
#
# OPEN QUESTIONS:
#   - Do we want ALL assessments or only barriers/potential-barriers in `crossings`?
#     (kept all for now; filter downstream in the priority-table step.)
#   - bcdata ACAT pull is bbox-based; may over-select slightly (clip to poly below).
# ---------------------------------------------------------------------------

suppressMessages({ library(DBI); library(RPostgres); library(sf) })
sf::sf_use_s2(FALSE)

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

# ---- pull + derive, through the package -------------------------------------
# knw_pscis_pull() intersects each PSCIS layer with the FWA watershed-group
# polygon in the database; the two table builders are pure and tested in pkg/.
pkgload::load_all(quiet = TRUE)
message("Pulling PSCIS layers for ", wsg_target, " ...")
layers <- knw_pscis_pull(conn, wsg_target)
for (nm in names(layers)) message(sprintf("  %-12s %s rows", nm, nrow(layers[[nm]])))
reports   <- knw_pscis_reports(layers)
crossings <- knw_pscis_crossings(layers, wsg_target)

# ---- write outputs ----------------------------------------------------------
readr::write_csv(reports, file.path(out_dir, "reports.csv"))
if (!is.null(crossings)) readr::write_csv(crossings, file.path(out_dir, "crossings.csv"))

gpkg <- file.path(out_dir, paste0("pscis_", wsg_lower, ".gpkg"))
purrr::iwalk(layers, ~ sf::st_write(st_transform(.x, 4326), gpkg, layer = .y,
                             delete_layer = TRUE, quiet = TRUE))

DBI::dbDisconnect(conn)

message("\n== ", wsg_target, " summary ==")
message("reports (distinct ecocat_url rows): ", nrow(reports))
message("crossings (assessments): ", ifelse(is.null(crossings), 0, nrow(crossings)))
message("outputs -> ", out_dir)
