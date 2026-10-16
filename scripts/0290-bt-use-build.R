# scripts/0290-bt-use-build.R
# ---------------------------------------------------------------------------
# FDIS electrofishing site visits placed on link's segmentation, for the BT rearing use
# curve. Issue #28. Consumer: scripts/0291-bt-use-curve.R.
#
# WHY / DESIGN NOTES (results in research/habitat_weights.md):
#   - A VISIT, NOT A SIGHTING. bcfishobs records presence only, so a band with few records
#     cannot be told from a band nobody sampled. FDIS visits carry effort and zero catch
#     (scripts/0230), so detection per visit can be corrected for effort.
#   - THE SEGMENT THE MODEL TESTS. link breaks streams at every bcfishobs record, and step 5
#     of link#284 took the segment STARTING at the observation. An FDIS site's point sits at
#     or a few metres below the record's, so a visit takes the segment whose downstream end
#     lies within [measure - 1 m, measure + `start_window_m`], the lowest such start if there
#     are several (a short segment starting at the site is kept, not skipped). Only when no
#     segment starts in that window does the visit take the segment containing its point.
#     Adjacent segments overlap by up to ~1.4 mm (float rounding of route measures): at the
#     point, the segment with the greatest downstream measure wins, id_segment breaking any
#     tie, and any overlap longer than `overlap_max_m` stops the run.
#   - SCHEMAS. fresh_default holds link's 55 calibration WSGs. The 8 step-5 held-out WSGs are
#     only in score284_default (same `default` config, later link version, finer segmentation).
#     The two share 15 WSGs, read from fresh_default only. For four of those (the step-5
#     in-sample pilots) the score284 segment gradient is kept beside it, so 0291 can measure
#     what segmentation alone does to a band. Held-out visits also carry their step-5 class:
#     rearing under default, or only under the 0.1249, 0.1349 or 0.1449 variant.
#   - ELEVATION is the segment's mid Z ((zmin + zmax) / 2), and its class is the
#     length-weighted tercile of the WSG's own default BT rearing: link's construction in
#     data-raw/habitat_variants_score.R, so classes compare with its elevation.csv.
#   - POOLING follows link's tracker (lnk_species_pooling(), config `default`). Where DV is
#     pooled, every BT/DV code (BT, DV, BT/DV, DV/BT, DVxBT) is BT presence. Where it is not, only
#     BT is presence, a DV-only catch is a BT absence (as link counts it), and the ambiguous
#     codes (BT/DV, DV/BT, DVxBT) block the absence. A WSG enters only where link marks BT
#     present. Any other char code (SLV) blocks the absence everywhere.
#   - ABSENCE needs a known catch and no code that blocks char absence (fdis_species_codes.csv).
#   - EFFORT: visits with a sentinel effort, or with neither area nor time, are dropped. A visit
#     with only one of the two is kept, so 0291 can model either.
#   - access_bt is kept as 1 or 2 (link R/lnk_pipeline_access.R: 1 modelled accessible, 2 BT
#     observed upstream). Code 2 is defined from bcfishobs, mostly these same FDIS records, so it
#     must never be a covariate. BT caught on code-0 segments is counted, as barrier-model
#     evidence, before those visits are dropped.
#   - Every drop is counted in the ledger, and the drops and the kept rows partition the input.
#
# INPUT:  data/fdis/derived/fdis_sites.csv (scripts/0240), data/fdis_species_codes.csv;
#         fwapg database (PG* env vars) (fresh_default, score284_*); link >= 0.55.0 (lnk_species_pooling)
# OUTPUT: data/fdis/derived/bt_use_visits.csv  one row per kept visit (ignored;
#         published by 0299)
#         scripts/logs/habitat/<date>_bt_use_build_ledger.csv
# RUN:    Rscript scripts/0290-bt-use-build.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })

if (!requireNamespace("link", quietly = TRUE) || packageVersion("link") < "0.55.0") {
  stop("needs link >= 0.55.0 for lnk_species_pooling(): pak::pak(\"NewGraphEnvironment/link\")")
}

held_out <- c("ELKR", "BULL", "UARL", "REVL", "CLRH", "LILL", "BABL", "BABR")  # link#284 step 5
in_sample <- c("PARS", "KOTL", "BULK", "MORR")                                  # link#284 step 5
variants <- c("0p1249", "0p1349", "0p1449")             # score284_bt_rear_<v>, nearest first
start_window_m <- 5
overlap_max_m <- 0.01
codes <- read_csv("data/fdis_species_codes.csv", col_types = cols(.default = "c"), na = "")
char_codes <- codes$code[codes$species_group %in% "char"]
bt_dv_codes <- c("BT", "DV", "BT/DV", "DV/BT", "DVxBT")
if (!all(bt_dv_codes %in% char_codes)) stop("data/fdis_species_codes.csv lost a BT/DV code")
path_out <- "data/fdis/derived/bt_use_visits.csv"
path_ledger <- file.path("scripts/logs/habitat",
                         paste0(format(Sys.Date(), "%Y%m%d"), "_bt_use_build_ledger.csv"))

ledger <- tibble(kind = character(), step = character(), n = integer(), note = character())
add <- function(kind, step, n, note = "") {
  ledger <<- bind_rows(ledger, tibble(kind = kind, step = step, n = as.integer(n), note = note))
}
drop <- function(x, keep, step) {
  keep <- coalesce(keep, FALSE)
  add("drop", step, sum(!keep))
  x[keep, ]
}

sites <- read_csv("data/fdis/derived/fdis_sites.csv", show_col_types = FALSE, guess_max = 1e5,
                  col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c"))
add("in", "visits_in", nrow(sites))

v <- drop(sites, !sites$flag_not_placed, "not_placed")
v <- drop(v, !v$flag_far_snap, "far_snap")
v <- drop(v, !coalesce(v$flag_ws50_mismatch, FALSE), "ws50_mismatch")
v <- drop(v, !v$flag_junk_date, "junk_date")
v <- drop(v, !v$flag_effort_sentinel & (!v$flag_no_area | !v$flag_no_effort),
          "effort_sentinel_or_none")
v <- drop(v, v$catch_status != "unknown", "catch_unknown")

# ---- link's WSGs and pooling ------------------------------------------------
conn <- tryCatch(dbConnect(Postgres()),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
wsg_fresh <- dbGetQuery(conn, "SELECT DISTINCT watershed_group_code w FROM fresh_default.streams")$w
wsg_score <- dbGetQuery(conn, "SELECT DISTINCT watershed_group_code w FROM score284_default.streams")$w
if (!all(c(held_out, in_sample) %in% wsg_score)) stop("step-5 pilots missing from score284_default")
if (any(held_out %in% wsg_fresh)) stop("a held-out WSG is in fresh_default: it would be calibration")
wsg_link <- union(wsg_fresh, held_out)

v <- drop(v, v$watershed_group_code %in% wsg_link, "wsg_not_in_link")

cfg <- link::lnk_config("default")
loaded <- suppressWarnings(link::lnk_load_overrides(cfg))
pool <- link::lnk_species_pooling(loaded, aoi = sort(unique(v$watershed_group_code)), species = "BT")
v <- drop(v, v$watershed_group_code %in% pool$watershed_group_code, "bt_absent_from_wsg")
pooled_dv <- pool |> filter(obs_species == "DV") |> select(watershed_group_code, obs_year_max)
tracker <- system.file("extdata/configs/default/species_pooling.csv", package = "link")
add("info", "link_version", 0L, as.character(packageVersion("link")))
add("info", "species_pooling_md5", 0L, unname(tools::md5sum(tracker)))

v <- v |>
  left_join(pooled_dv |> mutate(dv_pooled = TRUE), by = "watershed_group_code") |>
  mutate(dv_pooled = coalesce(dv_pooled, FALSE) & (is.na(obs_year_max) | year <= obs_year_max),
         caught = strsplit(coalesce(species_caught, ""), ";", fixed = TRUE))
presence_codes <- function(pooled) if (pooled) bt_dv_codes else "BT"
blocking_codes <- function(pooled) {
  if (pooled) setdiff(char_codes, bt_dv_codes) else setdiff(char_codes, c("BT", "DV"))
}
v$bt_present <- vapply(seq_len(nrow(v)), function(i) {
  any(v$caught[[i]] %in% presence_codes(v$dv_pooled[i]))
}, logical(1))
v$bt_absence_blocked <- !v$bt_present & (grepl("char", v$blocks_absence_of) |
  vapply(seq_len(nrow(v)), function(i) any(v$caught[[i]] %in% blocking_codes(v$dv_pooled[i])),
         logical(1)))
v <- v |>
  mutate(pooling = if_else(dv_pooled, "BT+DV", "BT")) |>
  select(-caught, -obs_year_max)
v <- drop(v, !v$bt_absence_blocked, "bt_absence_blocked")

# ---- segments ---------------------------------------------------------------
dbWriteTable(conn, "tmp_bt_use_visits",
             v |> transmute(site_visit, watershed_group_code, blue_line_key,
                            m0 = downstream_route_measure),
             temporary = TRUE, overwrite = TRUE)
wsg_in <- function(wsgs) paste0("'", wsgs, "'", collapse = ",")
seg_sql <- function(schema, wsgs) sprintf("
  SELECT DISTINCT ON (t.site_visit) t.site_visit,
         s.downstream_route_measure - t.m0 AS segment_start_offset_m,
         s.id_segment, s.gradient AS segment_gradient,
         s.channel_width AS segment_channel_width, s.channel_width_source AS segment_cw_source,
         s.edge_type AS segment_edge_type, s.stream_order AS segment_stream_order,
         s.length_metre AS segment_length_m,
         (ST_ZMin(s.geom) + ST_ZMax(s.geom)) / 2 AS elevation_m,
         a.access_bt, h.accessible, h.spawning, h.rearing, '%1$s' AS link_schema
  FROM tmp_bt_use_visits t
  JOIN %1$s.streams s
    ON s.watershed_group_code = t.watershed_group_code
   AND s.blue_line_key = t.blue_line_key
   AND ((s.downstream_route_measure BETWEEN t.m0 - 1 AND t.m0 + %3$s)
        OR (t.m0 >= s.downstream_route_measure AND t.m0 < s.upstream_route_measure))
  LEFT JOIN %1$s.streams_access a
    ON a.id_segment = s.id_segment AND a.watershed_group_code = s.watershed_group_code
  LEFT JOIN %1$s.streams_habitat_bt h
    ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
  WHERE t.watershed_group_code IN (%2$s)
  ORDER BY t.site_visit,
           (s.downstream_route_measure BETWEEN t.m0 - 1 AND t.m0 + %3$s) DESC,
           CASE WHEN s.downstream_route_measure BETWEEN t.m0 - 1 AND t.m0 + %3$s
                THEN s.downstream_route_measure END ASC,
           s.downstream_route_measure DESC, s.id_segment",
  schema, wsg_in(wsgs), start_window_m)
# visits whose point lies in more than one segment, and by how much those segments overlap
overlap_sql <- function(schema, wsgs) sprintf("
  SELECT count(*) AS n, coalesce(max(o), 0) AS max_overlap FROM (
    SELECT t.site_visit,
           sum(s.upstream_route_measure - s.downstream_route_measure)
             - (max(s.upstream_route_measure) - min(s.downstream_route_measure)) AS o
    FROM tmp_bt_use_visits t
    JOIN %1$s.streams s
      ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
     AND t.m0 >= s.downstream_route_measure AND t.m0 < s.upstream_route_measure
    WHERE t.watershed_group_code IN (%2$s)
    GROUP BY t.site_visit HAVING count(*) > 1) x", schema, wsg_in(wsgs))
for (sch in list(list("fresh_default", wsg_fresh), list("score284_default", held_out),
                 list("score284_default", in_sample))) {
  ov <- dbGetQuery(conn, overlap_sql(sch[[1]], sch[[2]]))
  add("info", paste0("multi_match_", sch[[1]], "_", length(sch[[2]]), "wsg"), ov$n,
      sprintf("max overlap %.4f m", ov$max_overlap))
  if (ov$max_overlap > overlap_max_m) stop(sch[[1]], ": segments overlap by ", ov$max_overlap, " m")
}
seg <- bind_rows(dbGetQuery(conn, seg_sql("fresh_default", wsg_fresh)),
                 dbGetQuery(conn, seg_sql("score284_default", held_out)))
if (anyDuplicated(seg$site_visit)) stop("a visit was placed in two schemas")

# the in-sample pilots on score284's segmentation, for the segmentation check in 0291
alt <- dbGetQuery(conn, seg_sql("score284_default", in_sample)) |>
  transmute(site_visit, segment_gradient_score284 = segment_gradient,
            rearing_score284 = rearing)

# step-5 class for held-out visits: each variant re-classified score284's segments, so the
# held-out visit's id_segment reads straight across
held_seg <- seg |> filter(link_schema == "score284_default") |>
  inner_join(v |> select(site_visit, watershed_group_code), by = "site_visit") |>
  select(site_visit, watershed_group_code, id_segment)
dbWriteTable(conn, "tmp_bt_use_held", held_seg, temporary = TRUE, overwrite = TRUE)
step5 <- lapply(variants, function(vr) {
  dbGetQuery(conn, sprintf("
    SELECT t.site_visit, h.rearing FROM tmp_bt_use_held t
    LEFT JOIN score284_bt_rear_%s.streams_habitat_bt h
      ON h.id_segment = t.id_segment AND h.watershed_group_code = t.watershed_group_code", vr)) |>
    transmute(site_visit, !!paste0("rearing_", vr) := rearing)
})

# elevation terciles of each WSG's own default BT rearing, length-weighted (link's construction)
rear_sql <- function(schema, wsgs) sprintf("
  SELECT s.watershed_group_code, (ST_ZMin(s.geom) + ST_ZMax(s.geom)) / 2 AS elevation_m,
         s.length_metre
  FROM %1$s.streams s
  JOIN %1$s.streams_habitat_bt h
    ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
  WHERE h.rearing AND s.watershed_group_code IN (%2$s)", schema, wsg_in(wsgs))
wsg_v <- unique(v$watershed_group_code)
rear <- bind_rows(dbGetQuery(conn, rear_sql("fresh_default", intersect(wsg_v, wsg_fresh))),
                  dbGetQuery(conn, rear_sql("score284_default", intersect(wsg_v, held_out))))
dbDisconnect(conn)

cuts <- rear |>
  filter(!is.na(elevation_m)) |>
  arrange(watershed_group_code, elevation_m) |>
  group_by(watershed_group_code) |>
  mutate(cw = cumsum(length_metre) / sum(length_metre)) |>
  summarise(elev_cut1 = elevation_m[which(cw >= 1 / 3)[1]],
            elev_cut2 = elevation_m[which(cw >= 2 / 3)[1]], .groups = "drop")

n_before <- nrow(v)
v <- v |> inner_join(seg, by = "site_visit")
add("drop", "no_link_segment", n_before - nrow(v))
add("info", "segment_starts_in_window", sum(abs(v$segment_start_offset_m) <= start_window_m &
                                             v$segment_start_offset_m >= -1),
    sprintf("segment starts within -1 to +%s m of the site; the rest take the segment containing it",
            start_window_m))
add("info", "bt_present_on_access_bt_0", sum(v$bt_present & v$access_bt %in% 0L),
    "BT caught on a segment link models as blocked")
v <- drop(v, v$access_bt %in% c(1L, 2L), "not_bt_accessible")

v <- Reduce(function(x, y) left_join(x, y, by = "site_visit"), step5, v) |>
  left_join(alt, by = "site_visit") |>
  left_join(cuts, by = "watershed_group_code") |>
  mutate(
    elev_class = case_when(is.na(elevation_m) | is.na(elev_cut1) ~ NA_character_,
                           elevation_m <= elev_cut1 ~ "low",
                           elevation_m <= elev_cut2 ~ "mid",
                           TRUE ~ "high"),
    role = if_else(watershed_group_code %in% held_out, "held_out", "calibration"),
    step5_class = case_when(role != "held_out" ~ NA_character_,
                            coalesce(rearing, FALSE) ~ "core",
                            coalesce(rearing_0p1249, FALSE) ~ "band_0p1249",
                            coalesce(rearing_0p1349, FALSE) ~ "band_0p1349",
                            coalesce(rearing_0p1449, FALSE) ~ "band_0p1449",
                            TRUE ~ "outside")
  ) |>
  select(site_visit, watershed_group_code, role, link_schema, blue_line_key,
         downstream_route_measure, segment_start_offset_m, id_segment, data_set, agency, year, month,
         n_pass, fishing_time_s, area_m2, fished_length_m, catch_status, n_caught_all, pooling,
         bt_present, n_bt, n_dv, n_char, segment_gradient, segment_gradient_score284,
         gradient_pct, fwa_gradient_pct, segment_channel_width, segment_cw_source,
         channel_width_m, wetted_width_m, mad_m3s, segment_stream_order, segment_edge_type,
         segment_length_m, elevation_m, elev_cut1, elev_cut2, elev_class, access_bt, accessible,
         spawning, rearing, rearing_score284, step5_class)
add("kept", "visits_kept", nrow(v))

if (sum(ledger$n[ledger$kind %in% c("drop", "kept")]) != nrow(sites)) {
  stop("ledger does not partition the input")
}
write_csv(v, path_out, na = "")
write_csv(ledger, path_ledger, na = "")
print(as.data.frame(ledger))
message(sprintf("%d visits, %d with BT; %d held out", nrow(v), sum(v$bt_present),
                sum(v$role == "held_out")))
