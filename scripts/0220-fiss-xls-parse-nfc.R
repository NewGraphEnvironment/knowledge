# scripts/0220-fiss-xls-parse-nfc.R
# ---------------------------------------------------------------------------
# FISS .xls harvest — STEP 3 of 3 (parse -> normalize -> NFC -> spatial). Issue NewGraphEnvironment/fish_passage_template_reporting#199.
#
# Parse each fetched Fish Data Submission spreadsheet, farm the wanted columns,
# normalize the drift across template editions, flag No-Fish-Captured (NFC) sites,
# and assemble one spatial table joinable to PSCIS/bcfishpass.
#
# WHY / DESIGN NOTES:
#   - The .xls is the provincial "Fish Data Submission Spreadsheet Template"
#     (V2.0, editions 2012/2016/2018/2020; a 2009-era variant differs). Sheets we
#     use: Step 1 (Ref & Loc), Step 2 (Fish Coll. Data), Step 4 (Stream Site Data).
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
# INPUT:  data/<wsg>/fiss_xls_fetch_log.csv (from 0210; uses parse_path).
# OUTPUT: data/<wsg>/fiss_sites_<wsg>.gpkg      (spatial deliverable, clipped
#           to the WSG, placeable sites only; carries the nfc flag)
#         data/<wsg>/fiss_sites_<wsg>.csv       (mirrors the .gpkg — clipped)
#         data/<wsg>/fiss_sites_<wsg>_all.csv   (EVERY parsed site, unclipped,
#           incl. sites with missing/malformed UTM — no record dropped)
#         data/<wsg>/fiss_step2_fishcoll_<wsg>.csv (effort/fish detail, long)
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
sf::sf_use_s2(FALSE)
`%||%` <- function(a, b) if (length(a) == 0 || all(is.na(a))) b else a

# ---- params -----------------------------------------------------------------
wsg_target <- if (nzchar(Sys.getenv("WSG_TARGET"))) Sys.getenv("WSG_TARGET") else
              if (exists("wsg_target")) wsg_target else "PINE"
wsg_lower  <- tolower(wsg_target)
out_dir    <- file.path("data", wsg_lower)
log_path   <- file.path(out_dir, "fiss_xls_fetch_log.csv")

# ---- PASSED column list (edit here) -----------------------------------------
# snake_case, post janitor::clean_names(). Absent-per-sheet names fill NA.
wanted_cols <- list(
  keys = c("reference_number", "reach_number", "site_number",
           "gazetted_name", "local_name", "waterbody_id"),
  step1_ref_loc = c("survey_date", "utm_zone", "utm_easting", "utm_northing"),
  step2_fish_coll = c(
    "sampling_method", "method_number",
    "ef_seconds", "ef_length_m", "ef_width_m",
    "soak_time", "date_in", "date_out", "time_in", "time_out",
    "length_m", "width_m",
    "temperature_c", "conductivity_m_s_cm", "turbidity",
    "species", "total_number", "comments"),
  step4_site_data = c(
    "utm_zone", "utm_easting", "utm_northing",
    "channel_width_m", "channel_width_m_2", "channel_width_m_3", "channel_width_m_4",
    "channel_width_m_5", "channel_width_m_6", "channel_width_m_7", "avg_channel_width_m",
    "wetted_width_m", "wetted_width_m_2", "wetted_width_m_3", "wetted_width_m_4",
    "wetted_width_m_5", "wetted_width_m_6", "wetted_width_m_7", "avg_wetted_width_m",
    "average_gradient_percent",
    "temperature_c", "conductivity_m_s_cm", "comments")
)

# name variants across template editions -> canonical
variant_map <- c(
  gazetted_names         = "gazetted_name",
  alias_local_name       = "local_name",
  waterbody_id_identifier = "waterbody_id"
)

# ---- sheet + header helpers -------------------------------------------------
# which sheet in this workbook is the requested step? (names drift; spaces/parens)
match_sheet <- function(sheets, step) {
  pat <- switch(step,
    step1_ref_loc   = "step.?1|ref.*loc|location",
    step2_fish_coll = "step.?2|fish.?coll|collection.?form",
    step4_site_data = "step.?4|stream.?site|site.?data|site.?card|site.?coll")
  hit <- sheets[str_detect(tolower(sheets), pat)]
  if (length(hit)) hit[1] else NA_character_
}

first_nonempty <- function(v) {
  v <- v[!is.na(v) & nchar(trimws(v)) > 0]
  if (length(v)) trimws(v[1]) else NA_character_
}

# read a sheet, detect the REFERENCE NUMBER header row, return clean-named tibble
read_step <- function(path, sheet) {
  raw <- as.data.frame(suppressWarnings(suppressMessages(
    read_excel(path, sheet = sheet, col_names = FALSE, .name_repair = "minimal"))))
  if (!nrow(raw)) return(NULL)
  hdr <- NA_integer_
  for (r in seq_len(min(nrow(raw), 40L))) {
    fc <- first_nonempty(as.character(unlist(raw[r, ])))
    if (!is.na(fc) && str_detect(tolower(fc), "^reference number")) { hdr <- r; break }
  }
  if (is.na(hdr) || hdr >= nrow(raw)) return(NULL)
  nm <- janitor::make_clean_names(ifelse(is.na(as.character(unlist(raw[hdr, ]))), "",
                                          as.character(unlist(raw[hdr, ]))))
  dat <- raw[(hdr + 1L):nrow(raw), , drop = FALSE]
  names(dat) <- nm
  dat <- dat[, nm != "" & !str_detect(nm, "^x(_[0-9]+)?$"), drop = FALSE]
  # reconcile edition variants -> canonical, but only when the canonical name is
  # NOT already present (a sheet carrying both forms would otherwise produce a
  # duplicate column name and, via as_tibble()'s uniqueness check, silently drop
  # the whole workbook-step through the caller's tryCatch).
  for (v in names(variant_map)) {
    canon <- variant_map[[v]]
    if (v %in% names(dat) && !(canon %in% names(dat))) names(dat)[names(dat) == v] <- canon
  }
  # a real data row must carry the reference_number key — this also drops the
  # hundreds of pre-formatted blank entry rows the template ships (stray non-empty
  # cells in those rows defeat a plain all-empty filter).
  if ("reference_number" %in% names(dat)) {
    rn <- trimws(as.character(dat$reference_number))
    dat <- dat[!is.na(rn) & rn != "" & tolower(rn) != "na", , drop = FALSE]
  } else {
    dat <- dat[rowSums(!is.na(dat) & dat != "") > 0, , drop = FALSE]
  }
  as_tibble(dat)
}

# select wanted (keys + step) + any comment column; add missing as NA.
# Drop rows that carry ONLY key/index values (the template pre-fills the reference
# number + names on hundreds of blank entry rows) — a real row has >=1 populated
# non-key payload cell (coords, date, a measurement, species, ...).
select_wanted <- function(df, step) {
  want <- unique(c(wanted_cols$keys, wanted_cols[[step]]))
  present   <- intersect(want, names(df))
  comment_c <- setdiff(names(df)[str_detect(names(df), "comment")], present)
  out <- df[, c(present, comment_c), drop = FALSE]
  for (m in setdiff(want, present)) out[[m]] <- NA
  payload <- setdiff(names(out), wanted_cols$keys)
  if (length(payload) && nrow(out)) {
    mat <- sapply(out[payload], function(c) {
      v <- trimws(as.character(c)); !is.na(v) & v != "" & tolower(v) != "na"
    })
    if (is.null(dim(mat))) mat <- matrix(mat, nrow = nrow(out))
    out <- out[rowSums(mat) > 0, , drop = FALSE]
  }
  out
}

num <- function(x) suppressWarnings(as.numeric(as.character(x)))

# ---- load fetch log ---------------------------------------------------------
stopifnot("fetch log not found — run 0210 with FISS_FETCH=TRUE first" = file.exists(log_path))
flog <- readr::read_csv(log_path, show_col_types = FALSE) %>%
  filter(!is.na(parse_path) & parse_path != "")
message(sprintf("%s: %d parseable workbooks", wsg_target, nrow(flog)))

# ---- parse each workbook, per step ------------------------------------------
parse_step <- function(path, report_id, step) {
  sheets <- tryCatch(excel_sheets(path), error = function(e) NULL)
  if (is.null(sheets)) return(NULL)
  sh <- match_sheet(sheets, step)
  if (is.na(sh)) return(NULL)
  df <- tryCatch(read_step(path, sh), error = function(e) NULL)
  if (is.null(df) || !nrow(df)) return(NULL)
  select_wanted(df, step) %>%
    mutate(report_id = as.character(report_id),
           site_key  = paste(report_id, reference_number, sep = ":"), .before = 1)
}

# gather + guarantee the columns downstream code references exist, so a step whose
# sheet is absent in every workbook (0-row/0-col result) doesn't crash group_by().
gather_step <- function(step) {
  res  <- map2_dfr(flog$parse_path, flog$report_id, ~ parse_step(.x, .y, step))
  need <- unique(c("site_key", "report_id", wanted_cols$keys, wanted_cols[[step]]))
  for (cc in setdiff(need, names(res))) res[[cc]] <- if (nrow(res)) NA else logical(0)
  res
}

step1 <- gather_step("step1_ref_loc")
step2 <- gather_step("step2_fish_coll")
step4 <- gather_step("step4_site_data")
message(sprintf("parsed rows — step1:%d  step2:%d  step4:%d",
                nrow(step1), nrow(step2), nrow(step4)))

# ---- Step 2 effort + NFC roll-up to site ------------------------------------
step2_site <- step2 %>%
  mutate(
    total_number = num(total_number),
    ef_seconds   = num(ef_seconds),
    ef_length_m  = num(ef_length_m),
    soak_time    = num(soak_time),
    is_no_fish   = str_detect(tolower(coalesce(species, "")), "no fish")
  ) %>%
  group_by(site_key) %>%
  summarise(
    methods_used   = paste(sort(unique(na.omit(sampling_method))), collapse = "; "),
    n_records      = n(),
    total_ef_secs  = sum(ef_seconds, na.rm = TRUE),
    total_ef_len_m = sum(ef_length_m, na.rm = TRUE),
    max_soak_time  = suppressWarnings(max(soak_time, na.rm = TRUE)),
    total_fish     = sum(total_number, na.rm = TRUE),
    fish_counted   = any(!is.na(total_number)),  # was a count actually entered?
    species_list   = paste(sort(unique(na.omit(species[!is_no_fish]))), collapse = "; "),
    any_no_fish    = any(is_no_fish, na.rm = TRUE),
    effort_recorded = any(!is.na(ef_seconds) | !is.na(soak_time) | !is.na(ef_length_m)),
    comments_fish  = paste(unique(na.omit(as.character(comments))), collapse = " | "),
    .groups = "drop"
  ) %>%
  mutate(
    max_soak_time = ifelse(is.infinite(max_soak_time), NA_real_, max_soak_time),
    # NFC = submitter said "No Fish Caught", OR a real zero count with effort recorded.
    # The derived branch REQUIRES fish_counted so all-blank count columns (nothing
    # recorded) are NOT mistaken for a genuine zero catch.
    nfc = any_no_fish | (fish_counted & total_fish == 0 & effort_recorded),
    nfc_source = ifelse(any_no_fish, "submitted", ifelse(nfc, "derived", NA_character_))
  )

# ---- Step 1 location (one row per site) -------------------------------------
step1_site <- step1 %>%
  group_by(site_key, report_id) %>%
  summarise(across(c(reference_number, reach_number, site_number,
                     gazetted_name, local_name, waterbody_id, survey_date),
                   ~ first(na.omit(.x)) %||% NA),
            utm_zone = first(na.omit(num(utm_zone))) %||% NA_real_,
            utm_easting = first(na.omit(num(utm_easting))) %||% NA_real_,
            utm_northing = first(na.omit(num(utm_northing))) %||% NA_real_,
            .groups = "drop")

# ---- Step 4 habitat (first habitat row per site) ----------------------------
w_num <- c("channel_width_m","avg_channel_width_m","wetted_width_m","avg_wetted_width_m",
           "average_gradient_percent","temperature_c","conductivity_m_s_cm",
           "utm_zone","utm_easting","utm_northing")
step4_site <- step4 %>%
  mutate(across(any_of(w_num), num)) %>%
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

# step-2 fish/effort detail (long, all submissions) — written raw for traceability
readr::write_csv(step2, file.path(out_dir, paste0("fiss_step2_fishcoll_", wsg_lower, ".csv")))
# full record — EVERY parsed site incl. those with missing/malformed UTM (which the
# clipped deliverable below cannot place). Nothing is dropped here.
readr::write_csv(sites, file.path(out_dir, paste0("fiss_sites_", wsg_lower, "_all.csv")))
sites_csv <- file.path(out_dir, paste0("fiss_sites_", wsg_lower, ".csv"))

# ---- spatial write (build geometry per UTM zone, combine, -> BC Albers) -----
# valid UTM bands for BC (zones 8-11): easting 280-720 km, northing 5.3-6.7 Mm.
# rows outside are malformed (dropped digit, swapped fields) — kept in the CSV but
# not placed spatially.
geo <- sites %>%
  filter(!is.na(utm_zone) & !is.na(utm_easting) & !is.na(utm_northing) &
         utm_zone %in% 8:11 &
         utm_easting  >= 280000  & utm_easting  <= 720000 &
         utm_northing >= 5300000 & utm_northing <= 6700000)
n_badcoord <- sum(!is.na(sites$utm_easting)) - nrow(geo)
if (n_badcoord > 0) message(sprintf("  %d site(s) had out-of-range UTM and were not placed.", n_badcoord))
if (nrow(geo)) {
  parts <- geo %>%
    group_split(utm_zone) %>%
    map(~ st_transform(
          st_as_sf(.x, coords = c("utm_easting", "utm_northing"),
                   crs = 32600 + .x$utm_zone[1], remove = FALSE), 3005))
  sites_sf <- do.call(rbind, parts)
  # clip to the target watershed group — a submission (.xls) can span several WSGs,
  # so the sheet carries sites well outside the linked group (same reason 0100 clips).
  conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), host = "localhost",
                                  port = 63333, dbname = "bcfishpass", user = "newgraph"),
                   error = function(e) NULL)
  if (!is.null(conn)) {
    wsg_poly <- sf::st_read(conn, query = glue::glue_sql(
      "SELECT watershed_group_code, geom FROM whse_basemapping.fwa_watershed_groups_poly
       WHERE watershed_group_code = {wsg_target}", wsg_target = wsg_target, .con = conn),
      quiet = TRUE) %>% st_transform(3005)
    DBI::dbDisconnect(conn)
    n_pre <- nrow(sites_sf)
    sites_sf <- sites_sf[st_union(wsg_poly), ]
    message(sprintf("  clipped to %s: %d of %d placed sites fall inside the group.",
                    wsg_target, nrow(sites_sf), n_pre))
  } else {
    # Refuse to emit a WSG-named deliverable we cannot clip: a submission spans
    # multiple groups, so writing unclipped-but-<wsg>-stamped .gpkg/.csv would
    # silently mislabel cross-group sites. The full unclipped parse is already on
    # disk (fiss_sites_<wsg>_all.csv), so no work is lost.
    stop("DB tunnel :63333 unavailable — cannot clip to ", wsg_target,
         ". Refusing to write a mislabeled WSG deliverable. Bring up the tunnel and ",
         "re-run; the full unclipped parse is in fiss_sites_", wsg_lower, "_all.csv.")
  }
  gpkg <- file.path(out_dir, paste0("fiss_sites_", wsg_lower, ".gpkg"))
  st_write(sites_sf, gpkg, layer = "fiss_sites", delete_dsn = TRUE, quiet = TRUE)
  # CSV mirrors the clipped spatial layer (same WSG sites)
  readr::write_csv(st_drop_geometry(sites_sf), sites_csv)
  message(sprintf("Wrote %s + .gpkg (%d sites; %d NFC)",
                  sites_csv, nrow(sites_sf), sum(sites_sf$nfc, na.rm = TRUE)))
} else {
  readr::write_csv(sites, sites_csv)
  message("No placeable sites (missing/invalid UTM) — full CSV written, GPKG skipped.")
}

message(sprintf("Done %s: %d sites total, %d flagged NFC (%d submitted, %d derived).",
                wsg_target, nrow(sites), sum(sites$nfc, na.rm = TRUE),
                sum(sites$nfc_source == "submitted", na.rm = TRUE),
                sum(sites$nfc_source == "derived", na.rm = TRUE)))
