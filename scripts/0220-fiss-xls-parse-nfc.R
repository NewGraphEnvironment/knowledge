# scripts/0220-fiss-xls-parse-nfc.R
# ---------------------------------------------------------------------------
# FISS .xls harvest — STEP 3 of 3 (parse -> normalize -> NFC -> spatial).
#
# Parse each fetched Fish Data Submission spreadsheet, farm the wanted columns,
# normalize the drift across template editions, flag No-Fish-Captured (NFC) sites,
# and assemble one spatial table joinable to PSCIS/bcfishpass.
#
# WHY / DESIGN NOTES:
#   - The .xls is the provincial "Fish Data Submission Spreadsheet Template"
#     (V2.0, editions 2012/2016/2018/2020; a 2009-era variant differs). Sheets we
#     use: Step 1 (Ref & Loc), Step 2 (Fish Coll. Data), Step 3 (Individual Fish Data),
#     Step 4 (Stream Site Data). Step 3 is written raw here; 0250 turns it into evidence.
#   - THE PARSER IS IN THE PACKAGE (#7): sheet matching, header detection, edition variants, the
#     column list and the Step 2 NFC roll-up are knw_fiss_* (R/fiss_parse.R, R/fiss_nfc.R), tested on
#     fixtures in inst/testdata/fiss/. This script binds the steps over a group's workbooks, reconciles,
#     places, clips and writes.
#   - HEADER IS NOT ROW 1. Title / instruction / section-header rows sit above the
#     real field labels. Robust anchor: the label row's first non-empty cell is
#     exactly "REFERENCE NUMBER". (fpr::fpr_import_hab_con is built for NGE's own
#     habitat_confirmations.xls with a row-1 header; on the gov template it yields
#     x, x_2, ... — so we detect the header ourselves.)
#   - Column list is PASSED (wanted_cols below), snake_case to match janitor::
#     clean_names(). Missing columns fill NA (don't error). Comments are pulled by
#     an explicit name AND a contains("comment") catch, so drift is never missed.
#   - NFC ENCODING: no dedicated boolean. Step 2 "Fish Summary" carries species +
#     total_number; the picklist value "No Fish Caught" is the submitter's own call.
#     nfc = any Step-2 record with species ~ "no fish" OR site total fish == 0 with
#     effort recorded. We take the determination from the sheet — we do NOT invent
#     an effort threshold. Effort + comments ride along as ATTRIBUTES so the planner
#     weighs credibility ("electrofished 1200 m, nothing" vs "brief dipnet").
#
# INPUT:  data/<wsg>/fiss_xls_fetch_log.csv (from 0210; uses parse_path), and
#         data/<wsg>/fiss_xls_manifest.csv for the reconciliation at the end.
#         WSG_TARGET has no default: unset used to run PINE silently.
#         The WSG clip polygon comes from the database the PG* environment variables
#         name (any fwapg-based one); unreachable -> stop().
# OUTPUT: data/<wsg>/fiss_xls_parse_log.csv   (one row per workbook x step: which sheet
#           matched, where the header was, rows before/after filtering, and a status
#           naming WHY a step yielded nothing — the five silent-return paths made loud)
#         data/<wsg>/fiss_xls_reconcile.csv   (manifest <-> fetch log <-> parse log <->
#           site counts; the script stop()s if any check fails, so a silent fetch or
#           parse failure cannot pass)
#         data/<wsg>/fiss_sites_<wsg>.gpkg      (spatial deliverable, clipped
#           to the WSG, placeable sites only; carries the nfc flag)
#         data/<wsg>/fiss_sites_<wsg>.csv       (mirrors the .gpkg — clipped)
#         data/<wsg>/fiss_sites_<wsg>_all.csv   (EVERY parsed site, unclipped,
#           incl. sites with missing/malformed UTM — no record dropped)
#         data/<wsg>/fiss_step2_fishcoll_<wsg>.csv (effort/fish detail, long; carries the
#           submitter's life stage as `stage`, and `stage_norm`)
#         data/<wsg>/fiss_step3_fish_<wsg>.csv  (individual fish, long, raw; issue #21)
#
# OPEN QUESTIONS (grain — revisit with Al):
#   - Site key is (report_id, reference_number): reference_number is unique only
#     within a submission, so we prefix report_id to globalize it.
#   - Step 4 assumed ~one habitat row per site; if >1 we take the first non-empty.
#   - Effort roll-up to site level = sum(ef_seconds), max(soak_time), sum(total_number).
#     Revisit if per-pass detail matters for credibility.
# ---------------------------------------------------------------------------

suppressMessages({
  library(dplyr); library(stringr); library(purrr); library(tidyr); library(readr)
  library(readxl); library(janitor); library(sf)
  library(DBI); library(RPostgres)
})
pkgload::load_all(quiet = TRUE)   # the knw_fiss_* parser (#7)
sf::sf_use_s2(FALSE)
`%||%` <- function(a, b) if (length(a) == 0 || all(is.na(a))) b else a

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else
              stop("WSG_TARGET is not set. Run as `WSG_TARGET=<code> Rscript scripts/0220-fiss-xls-parse-nfc.R` ",
                   "or set `wsg_target` in the session. There is no default group.", call. = FALSE)
wsg_lower     <- tolower(wsg_target)
out_dir       <- file.path("data", wsg_lower)
log_path      <- file.path(out_dir, "fiss_xls_fetch_log.csv")
manifest_path <- file.path(out_dir, "fiss_xls_manifest.csv")
# a reconcile table from an earlier run must not outlive an aborted one
unlink(file.path(out_dir, "fiss_xls_reconcile.csv"))

# ---- PASSED column list -------------------------------------------------------
# The columns read per step, the edition variants and the sheet patterns live in the package (knw_fiss_columns(),
# R/fiss_parse.R). To read another column, add it here and it is passed to every step.
wanted_cols <- knw_fiss_columns()$wanted
num <- function(x) suppressWarnings(as.numeric(as.character(x)))

# ---- load fetch log ---------------------------------------------------------
stopifnot("fetch log not found — run 0210 with FISS_FETCH=TRUE first" = file.exists(log_path))
# report_id as character: a double id like 100000 would become "1e+05" in site keys
flog_all <- readr::read_csv(log_path, show_col_types = FALSE,
                            col_types = readr::cols(report_id = readr::col_character(), .default = readr::col_guess()))
flog <- flog_all %>% filter(!is.na(parse_path) & parse_path != "")
message(sprintf("%s: %d parseable workbooks", wsg_target, nrow(flog)))
if (!nrow(flog)) stop("No parseable workbooks in ", log_path,
                      " (every fetch was download_failed or unreadable). Nothing to parse.", call. = FALSE)

# ---- parse each workbook, per step ------------------------------------------
# knw_fiss_parse_step() returns list(data = tibble|NULL, log = one-row tibble); every way a step yields nothing is a
# status of its own in the parse log (sheets_error, no_sheet_match, read_error, empty_sheet, no_header, no_rows,
# fish_layout; ok when rows parsed). See ?knw_fiss_parse_step.
# gather + guarantee the columns downstream code references exist, so a step whose
# sheet is absent in every workbook (0-row/0-col result) doesn't crash group_by().
gather_step <- function(step) {
  parts <- map2(flog$parse_path, flog$report_id, ~ knw_fiss_parse_step(.x, .y, step, wanted_cols))
  res   <- map_dfr(parts, "data")
  need  <- unique(c("site_key", "report_id", wanted_cols$keys, wanted_cols[[step]]))
  # zero-row fill must be CHARACTER: sheet cells arrive as character, and a logical(0)
  # column fails the later full_join on site_key and coalesce(species, "") with a vctrs
  # type error — a step absent from every workbook (Step 4 is often empty) would abort
  # the run after the parse log was written
  for (cc in setdiff(need, names(res))) res[[cc]] <- if (nrow(res)) NA_character_ else character(0)
  attr(res, "parse_log") <- map_dfr(parts, "log")
  res
}

step1 <- gather_step("step1_ref_loc")
step2 <- gather_step("step2_fish_coll")
step3 <- gather_step("step3_indiv_fish")
step4 <- gather_step("step4_site_data")
n_steps <- length(knw_fiss_columns()$step_pattern)
parse_log <- bind_rows(attr(step1, "parse_log"), attr(step2, "parse_log"),
                       attr(step3, "parse_log"), attr(step4, "parse_log"))
readr::write_csv(parse_log, file.path(out_dir, "fiss_xls_parse_log.csv"))
message(sprintf("parsed rows — step1:%d  step2:%d  step3:%d  step4:%d",
                nrow(step1), nrow(step2), nrow(step3), nrow(step4)))
# workbooks that contributed nothing at all, by name — legitimately so for tissue data
# and reach summaries, but they must be visible, not vanish (PINE: 5 of 77 did).
wb_status <- parse_log %>% group_by(report_id, path) %>%
  summarise(any_ok = any(status == "ok"), statuses = paste(unique(status), collapse = "/"), .groups = "drop")
wb_no_step <- wb_status %>% filter(!any_ok)
if (nrow(wb_no_step)) message(sprintf("  %d workbook(s) yielded no step at all:\n%s", nrow(wb_no_step),
  paste0("    ", basename(wb_no_step$path), "  [", wb_no_step$statuses, "]", collapse = "\n")))
# ---- reconcile, stage A: manifest <-> fetch log <-> parse log ---------------
# Evaluated here, before any site table is written, so a broken input cannot produce
# a fresh-looking deliverable. Stage B (site counts) joins these rows at the end.
manifest_urls <- if (file.exists(manifest_path))
  unique(readr::read_csv(manifest_path, show_col_types = FALSE)$xls_url) else character(0)
# the enumerate step's own record — the one producer the manifest/fetch-log/parse-log
# chain does not otherwise touch. A manifest stale relative to it (an aborted 0200, or
# a fallback run on the shorter local snapshot) is invisible to the other checks
# because the fetch log was built from that same manifest.
reports_path <- file.path(out_dir, "fiss_xls_reports.csv")
reports <- NULL
if (file.exists(reports_path))
  reports <- readr::read_csv(reports_path, show_col_types = FALSE,
                             col_types = readr::cols(report_id = readr::col_character(), .default = readr::col_guess()))
n_parse_wb <- dplyr::n_distinct(parse_log$path)
chk <- function(check, expected, actual, pass = expected == actual, note = "")
  tibble(check = check, expected = as.character(expected), actual = as.character(actual), pass = pass, note = note)
reconcile_a <- bind_rows(
  # by URL set when the fetch log carries xls_url (0210 since 2026-09-04); a count only
  # for a fetch log that predates the column, and the note says so
  if ("xls_url" %in% names(flog_all))
    chk("manifest_urls_vs_fetch_log_urls", length(manifest_urls), nrow(flog_all),
        pass = setequal(manifest_urls, flog_all$xls_url) && length(manifest_urls) == nrow(flog_all))
  else
    chk("manifest_urls_vs_fetch_log_rows", length(manifest_urls), nrow(flog_all),
        note = "fetch log predates the xls_url column; count only"),
  if (is.null(reports))
    chk("reports_file_present", "fiss_xls_reports.csv", "missing", pass = FALSE,
        note = "0200 predates the reports file for this group; re-run 0200")
  else bind_rows(
    chk("reports_n_xls_vs_manifest_urls", sum(reports$n_xls), length(manifest_urls)),
    chk("report_pages_fetch_failed", 0L, sum(reports$page_status == "fetch_failed"),
        note = paste(reports$report_id[reports$page_status == "fetch_failed"], collapse = "; ")),
    chk("report_pages_http_4xx", NA, sum(grepl("^http_", reports$page_status)), pass = TRUE,
        note = paste(sprintf("%s=%s", reports$report_id, reports$page_status)[grepl("^http_", reports$page_status)], collapse = "; "))),
  # the fetch log's own status column: a transient failure must fail the gate, a
  # deterministic 4xx (ACAT lists a file it does not serve) and an encrypted file
  # LibreOffice could not convert are recorded by name so the shortfall is visible
  chk("fetch_failed", 0L, sum(flog_all$status == "fetch_failed"),
      note = paste(flog_all$file_name[flog_all$status == "fetch_failed"], collapse = "; ")),
  chk("fetch_http_4xx", NA, sum(grepl("^http_", flog_all$status) | flog_all$status == "download_failed"), pass = TRUE,
      note = paste(sprintf("%s=%s", flog_all$report_id, flog_all$status)[grepl("^http_", flog_all$status) | flog_all$status == "download_failed"], collapse = "; ")),
  chk("fetch_unreadable", NA, sum(flog_all$status == "unreadable"), pass = TRUE,
      note = paste(flog_all$file_name[flog_all$status == "unreadable"], collapse = "; ")),
  if (!is.null(reports))
    chk("enumerate_db_source", NA, paste(unique(reports$db_source), collapse = "|"), pass = TRUE),
  chk("fetch_parseable_vs_parse_log_workbooks", nrow(flog), n_parse_wb),
  chk("parse_log_rows_vs_steps_per_workbook", n_steps * n_parse_wb, nrow(parse_log)),
  # a per-fish sheet Step 2 set aside must have been read by Step 3, or its fish are in neither
  chk("fish_layout_sheets_read_as_step3", sum(parse_log$status == "fish_layout"),
      nrow(inner_join(parse_log %>% filter(status == "fish_layout") %>% select(path, sheet_matched),
                      parse_log %>% filter(step == "step3_indiv_fish", status == "ok") %>% select(path, sheet_matched),
                      by = c("path", "sheet_matched")))),
  chk("workbooks_with_no_step", NA, nrow(wb_no_step), pass = TRUE,
      note = paste(basename(wb_no_step$path), collapse = "; ")),
  # the fetch log said readxl could open it; if 0220 cannot list its sheets the file
  # changed underneath us (deleted, truncated, re-encrypted) — that is a failure
  chk("workbooks_unopenable_since_fetch", 0L, sum(parse_log$status == "sheets_error") %/% n_steps,
      note = paste(unique(basename(parse_log$path[parse_log$status == "sheets_error"])), collapse = "; "))
)
if (!all(reconcile_a$pass)) {
  readr::write_csv(reconcile_a, file.path(out_dir, "fiss_xls_reconcile.csv"))
  print(as.data.frame(reconcile_a), right = FALSE)
  stop("Reconciliation FAILED for ", wsg_target, " before any site table was written: ",
       paste(reconcile_a$check[!reconcile_a$pass], collapse = ", "), call. = FALSE)
}
# UTM zone strings the numeric coercion cannot read ("10U") are a dropped-site path
zone_raw <- c(as.character(step1$utm_zone), as.character(step4$utm_zone))
n_zone_nonnum <- sum(!is.na(zone_raw) & nzchar(trimws(zone_raw)) & is.na(knw_fiss_utm_zone(zone_raw)))
if (n_zone_nonnum) message(sprintf("  %d utm_zone value(s) carry no digits and will not place: %s",
  n_zone_nonnum, paste(unique(zone_raw[!is.na(zone_raw) & is.na(knw_fiss_utm_zone(zone_raw))]), collapse = ", ")))

# ---- Step 2 effort + NFC roll-up to site ------------------------------------
# zero-catch codes from the provincial code table (NFC, ZZZ), not a literal here; the roll-up and its NFC rule are
# knw_fiss_nfc() (R/fiss_nfc.R)
species_codes <- readr::read_csv("data/fdis_species_codes.csv", col_types = readr::cols(.default = "c"), na = "")
step2_site <- knw_fiss_nfc(step2, species_codes)

# ---- Step 1 location (one row per site) -------------------------------------
step1_site <- step1 %>%
  group_by(site_key, report_id) %>%
  summarise(across(c(reference_number, reach_number, site_number,
                     gazetted_name, local_name, waterbody_id, survey_date),
                   ~ first(na.omit(.x)) %||% NA),
            utm_zone = first(na.omit(knw_fiss_utm_zone(utm_zone))) %||% NA_real_,
            utm_easting = first(na.omit(num(utm_easting))) %||% NA_real_,
            utm_northing = first(na.omit(num(utm_northing))) %||% NA_real_,
            .groups = "drop")

# ---- Step 4 habitat (first habitat row per site) ----------------------------
w_num <- c("channel_width_m","avg_channel_width_m","wetted_width_m","avg_wetted_width_m",
           "average_gradient_percent","temperature_c","conductivity_m_s_cm",
           "utm_zone","utm_easting","utm_northing")
step4_site <- step4 %>%
  mutate(utm_zone = knw_fiss_utm_zone(utm_zone)) %>%
  mutate(across(any_of(setdiff(w_num, "utm_zone")), num)) %>%
  group_by(site_key) %>%
  summarise(
    across(any_of(c("avg_channel_width_m","avg_wetted_width_m","average_gradient_percent",
                    "temperature_c","conductivity_m_s_cm")), ~ first(na.omit(.x))),
    hab_utm_zone     = first(na.omit(utm_zone)),
    hab_utm_easting  = first(na.omit(utm_easting)),
    hab_utm_northing = first(na.omit(utm_northing)),
    comments_site    = paste(unique(na.omit(as.character(comments))), collapse = " | "),
    .groups = "drop"
  )

# ---- assemble site-level table ----------------------------------------------
sites <- step1_site %>%
  full_join(step2_site, by = "site_key") %>%
  full_join(step4_site, by = "site_key") %>%
  # prefer Step-4 habitat coords, fall back to Step-1
  mutate(
    utm_zone     = coalesce(hab_utm_zone, utm_zone),
    utm_easting  = coalesce(hab_utm_easting, utm_easting),
    utm_northing = coalesce(hab_utm_northing, utm_northing),
    watershed_group_code = wsg_target,
    comments = paste(na.omit(c(NA)), collapse = "")  # placeholder replaced below
  ) %>%
  select(-hab_utm_zone, -hab_utm_easting, -hab_utm_northing)

# combine comment provenance into one field
sites$comments <- with(sites, trimws(paste(
  ifelse(!is.na(comments_fish) & comments_fish != "", paste0("[fish] ", comments_fish), ""),
  ifelse(!is.na(comments_site) & comments_site != "", paste0("[site] ", comments_site), "")
)))

# step-2 fish/effort detail (long, all submissions) — written raw for traceability. `stage`
# is the submitter's life-stage label as entered; stage_norm only folds case and spacing.
step2 <- step2 %>% mutate(stage_norm = na_if(tolower(str_squish(as.character(stage))), ""))
readr::write_csv(step2, file.path(out_dir, paste0("fiss_step2_fishcoll_", wsg_lower, ".csv")))
# step-3 individual fish (long, raw); joined to its site and event downstream (0250). The
# name keys repeat per fish and are on the site table already: dropping them took UPCE's
# 171k fish from 16 to 8 MB.
readr::write_csv(select(step3, -any_of(c("gazetted_name", "local_name", "waterbody_id",
                                          "reach_number", "site_number"))),
                 file.path(out_dir, paste0("fiss_step3_fish_", wsg_lower, ".csv")), na = "")
# full record — EVERY parsed site incl. those with missing/malformed UTM (which the
# clipped deliverable below cannot place). Nothing is dropped here.
readr::write_csv(sites, file.path(out_dir, paste0("fiss_sites_", wsg_lower, "_all.csv")))
sites_csv <- file.path(out_dir, paste0("fiss_sites_", wsg_lower, ".csv"))

# ---- spatial write (build geometry per UTM zone, combine, -> BC Albers) -----
# Plausibility window for BC (zones 8-11): easting 150-850 km, northing 5.3-6.7 Mm.
# The window is deliberately wider than one zone (about 290-710 km at 51 N): a project
# straddling a zone boundary (LNTH/UNTH sit on 120 W, the 10/11 line) commonly records
# every site in ONE zone, giving legitimate eastings near 780 km or 255 km. Those place
# correctly in the recorded zone; the WSG clip below disposes of true strays. Rows
# outside the window are malformed (dropped digit, swapped fields) — kept in the CSV
# but not placed.
geo <- sites %>%
  filter(!is.na(utm_zone) & !is.na(utm_easting) & !is.na(utm_northing) &
         utm_zone %in% 8:11 &
         utm_easting  >= 150000  & utm_easting  <= 850000 &
         utm_northing >= 5300000 & utm_northing <= 6700000)
n_withcoord <- sum(!is.na(sites$utm_easting) & !is.na(sites$utm_northing) & !is.na(sites$utm_zone))
n_badcoord  <- n_withcoord - nrow(geo)
if (n_badcoord > 0) message(sprintf("  %d site(s) had out-of-range UTM and were not placed.", n_badcoord))
n_placed <- nrow(geo); n_clipped <- 0L; n_outside_zone_swap <- NA_integer_; db_source <- NA_character_
place <- function(df) {
  df %>% group_split(utm_zone) %>%
    map(~ st_transform(st_as_sf(.x, coords = c("utm_easting", "utm_northing"),
                                crs = 32600 + .x$utm_zone[1], remove = FALSE), 3005)) %>%
    do.call(rbind, .)
}
n_geom <- 0L
if (nrow(geo)) {
  sites_sf <- place(geo)
  n_geom   <- nrow(sites_sf)
  message(sprintf("  placed sites per UTM zone: %s",
                  paste(sprintf("zone %d=%d", as.integer(names(table(geo$utm_zone))), table(geo$utm_zone)), collapse = ", ")))
  # clip to the target watershed group — a submission (.xls) can span several WSGs,
  # so the sheet carries sites well outside the linked group (same reason 0100 clips).
  # Polygon source: the database the PG* environment variables name.
  conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres()), error = function(e) NULL)
  if (!is.null(conn)) db_source <- DBI::dbGetQuery(conn, "SELECT current_database() AS d")$d
  if (!is.null(conn)) {
    wsg_poly <- sf::st_read(conn, query = glue::glue_sql(
      "SELECT watershed_group_code, geom FROM whse_basemapping.fwa_watershed_groups_poly
       WHERE watershed_group_code = {wsg_target}", wsg_target = wsg_target, .con = conn),
      quiet = TRUE) %>% st_transform(3005)
    DBI::dbDisconnect(conn)
    stopifnot("watershed group polygon not found" = nrow(wsg_poly) > 0)
    poly   <- st_union(wsg_poly)
    inside <- lengths(st_intersects(sites_sf, poly)) > 0
    n_pre  <- nrow(sites_sf)
    # Of the placed sites that fall OUTSIDE the group, how many would land inside if the
    # recorded zone were off by one? A mis-entered zone moves a site ~600 km; the clip
    # drops it silently, so count it rather than lose it. Reported, not corrected — the
    # wrong field could be either the zone or the easting.
    n_outside_zone_swap <- 0L
    if (any(!inside)) {
      out_df <- st_drop_geometry(sites_sf[!inside, ])
      for (dz in c(-1L, 1L)) {
        alt <- out_df %>% mutate(utm_zone = utm_zone + dz) %>% filter(utm_zone %in% 8:11)
        if (nrow(alt)) n_outside_zone_swap <- n_outside_zone_swap + sum(lengths(st_intersects(place(alt), poly)) > 0)
      }
    }
    sites_sf <- sites_sf[inside, ]
    n_clipped <- nrow(sites_sf)
    message(sprintf("  clipped to %s: %d of %d placed sites fall inside the group; %d of the %d outside would fall inside with the zone shifted by one.",
                    wsg_target, n_clipped, n_pre, n_outside_zone_swap, n_pre - n_clipped))
  } else {
    # Refuse to emit a WSG-named deliverable we cannot clip: a submission spans
    # multiple groups, so writing unclipped-but-<wsg>-stamped .gpkg/.csv would
    # silently mislabel cross-group sites. The full unclipped parse is already on
    # disk (fiss_sites_<wsg>_all.csv), so no work is lost.
    stop("The database (PG* environment variables) is not reachable — cannot clip to ", wsg_target,
         ". Refusing to write a mislabeled WSG deliverable. Bring it up and ",
         "re-run; the full unclipped parse is in fiss_sites_", wsg_lower, "_all.csv.")
  }
  gpkg <- file.path(out_dir, paste0("fiss_sites_", wsg_lower, ".gpkg"))
  st_write(sites_sf, gpkg, layer = "fiss_sites", delete_dsn = TRUE, quiet = TRUE)
  # CSV mirrors the clipped spatial layer (same WSG sites)
  readr::write_csv(st_drop_geometry(sites_sf), sites_csv)
  message(sprintf("Wrote %s + .gpkg (%d sites; %d NFC)",
                  sites_csv, nrow(sites_sf), sum(sites_sf$nfc, na.rm = TRUE)))
} else {
  # no .gpkg this run — and none from an earlier run may survive to be read as this one's
  unlink(file.path(out_dir, paste0("fiss_sites_", wsg_lower, ".gpkg")))
  readr::write_csv(sites, sites_csv)
  message("No placeable sites (missing/invalid UTM) — the WSG-named CSV is the UNCLIPPED table this run; GPKG skipped and any earlier one removed.")
}

message(sprintf("Done %s: %d sites total, %d flagged NFC (%d submitted, %d derived); nfc is NA on %d (no Step 2 record).",
                wsg_target, nrow(sites), sum(sites$nfc, na.rm = TRUE),
                sum(sites$nfc_source == "submitted", na.rm = TRUE),
                sum(sites$nfc_source == "derived", na.rm = TRUE),
                sum(is.na(sites$nfc))))

# ---- reconcile: manifest <-> fetch log <-> parse log <-> sites -----------------
# Every count below is derived from a DIFFERENT producer than the one it is compared
# with, so a silent failure in any step breaks an equality here. The table is written
# whether or not it passes; the stop() is what makes "row counts reconciled" a gate.
site_keys <- unique(c(step1$site_key, step2$site_key, step4$site_key))
reconcile <- bind_rows(
  reconcile_a,
  chk("utm_zone_non_numeric", NA, n_zone_nonnum, pass = TRUE),
  # Step 3 fish whose site_key has no Step 1 row carry no date or location, so 0250 cannot
  # place or date them; counted here so the loss is visible where it starts
  chk("step3_fish_without_step1_site", NA, sum(!step3$site_key %in% step1$site_key), pass = TRUE,
      note = paste(unique(step3$report_id[!step3$site_key %in% step1$site_key]), collapse = "; ")),
  chk("sites_all_rows_vs_distinct_site_keys", length(site_keys), nrow(sites)),
  # the per-zone st_as_sf/rbind must neither drop nor duplicate a row
  chk("placed_rows_vs_geometry_rows", n_placed, n_geom),
  chk("with_coords_placed_clipped", NA, sprintf("%d / %d / %d", n_withcoord, n_placed, n_clipped), pass = TRUE),
  chk("outside_group_fixable_by_zone_shift", NA, n_outside_zone_swap, pass = TRUE),
  chk("nfc_na_no_step2", NA, sum(is.na(sites$nfc)), pass = TRUE),
  chk("nfc_conflict_sites", NA, sum(sites$nfc_conflict, na.rm = TRUE), pass = TRUE,
      note = "a no-fish record beside a catch at the same site; not flagged nfc"),
  # visible, not a gate: explicit zero counts ("RB, 0") legitimately name a species at a
  # no-fish site. A gate on species_caught would restate the nfc predicate and never fire.
  chk("nfc_sites_listing_a_species", NA, sum(sites$nfc %in% TRUE & nzchar(coalesce(sites$species_list, ""))),
      pass = TRUE, note = "explicit zero counts; nfc_conflict sites are not flagged nfc"),
  chk("clip_polygon_source", NA, db_source, pass = TRUE)
)
readr::write_csv(reconcile, file.path(out_dir, "fiss_xls_reconcile.csv"))
print(as.data.frame(reconcile), right = FALSE)
if (!all(reconcile$pass)) {
  stop("Reconciliation FAILED for ", wsg_target, ": ",
       paste(reconcile$check[!reconcile$pass], collapse = ", "),
       ". See ", file.path(out_dir, "fiss_xls_reconcile.csv"), call. = FALSE)
}
message("Reconciliation passed: ", sum(reconcile$pass), " checks.")
