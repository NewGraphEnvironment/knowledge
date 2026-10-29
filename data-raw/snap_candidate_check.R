# data-raw/snap_candidate_check.R
# ---------------------------------------------------------------------------
# How FDIS site visits reach the network today, and what fresh's snap with the 1:50k code would change (#91).
#
# Today `scripts/0230` snaps each visit with fwapg's `fwa_indexpoint()` (nearest stream, 500 m) and
# `knw_fdis_quality()` drops a snap beyond 100 m or one whose FDIS 1:50k watershed code names other
# streams. The candidate route is `fresh::frs_point_snap()`: a nearest snap, plus one snap per stream
# the visit's code names (`col_blk`, "a point with a hint snaps only to that stream").
#
# METHOD
#   - The old snap is the placement `0230` stored in data/fdis/build/sites.rds (fwa_indexpoint at
#     500 m), not a rerun, so the counts below are the evidence the tracked tune tables rest on.
#   - The new nearest snap is frs_point_snap() at the same 500 m, run twice: with no edge type
#     excluded (to count where the nearest line is subsurface flow, 1425, or a connector, 6010) and
#     with `EXCLUDE` (default 1425 and 6010), the set the plan proposes.
#   - Every visit with coordinates gets one class, first match:
#       neither         no snap either way
#       old_only        fwa_indexpoint places it, fresh has no candidate within 500 m
#       new_only        fresh places it, fwa_indexpoint did not
#       same_segment    both on one linear_feature_id
#       same_stream     both on one blue_line_key, different segments
#       old_placeholder the old pick is a placeholder line (wscode under 999), which fresh refuses
#       old_unmapped    the old pick has no local code, which fresh refuses
#       old_subsurface  the old pick is edge type 1425
#       old_excluded    the old pick is another edge type in EXCLUDE
#       tie             the two picks lie within 1 mm of the same distance
#       other           anything else (reported, expected 0)
#   - link placement: `knw_link_place()` on SCHEMA (default fresh_default_20261017, the build the
#     tracked tables rest on) for every placed visit under each snap, so each class says what link
#     already drops; and `knw_fdis_quality()` on today's sites, then link, which must reproduce the
#     2026-10-22 evidence ledger's `no_link_segment` (1,491).
#   - The hint route: each visit's checkable codes (as 0230: 45 characters, not all zero below the
#     basin) are taken from fish.rds, which holds the kept copy's fish only, so the codes 0230 pooled
#     from dropped repeat copies (#35; 373 visits in the 2026-10-17 load) are missing here; the count
#     of visits checked is reported beside 0230's. Each code maps to its 20k blue_line_keys through
#     fwa_streams_20k_50k, one hinted row per visit and key. The pick is the nearest hinted hit
#     ("confirmed": on a stream the code names, which is today's check), else the nearest snap
#     ("unconfirmed"); a known code with no hit is a drop (`no_hit`). `moved` is a confirmed pick on
#     another stream than the nearest.
#
# OUTPUT: scripts/logs/fdis/<yyyymmdd>_snap_candidate_check.txt   the summary tables
#         scripts/logs/fdis/<yyyymmdd>_snap_candidate_check.csv.gz   one row per visit with coordinates (distances
#                                                                   to the cm)
# RUN:    Rscript data-raw/snap_candidate_check.R   (from the repo root; PG* point at the fwapg database)
# ---------------------------------------------------------------------------
suppressMessages({
  library(dplyr); library(readr); library(tidyr); library(sf); library(DBI); library(RPostgres)
})
pkgload::load_all(quiet = TRUE)
if (!requireNamespace("fresh", quietly = TRUE) || packageVersion("fresh") < "0.40.0") {
  stop("needs fresh >= 0.40.0 (frs_point_snap() on a dataset, col_blk): pak::pak(\"NewGraphEnvironment/fresh\")")
}
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

schema  <- Sys.getenv("SCHEMA", "fresh_default_20261017")
tol     <- 500
exclude <- as.integer(strsplit(Sys.getenv("EXCLUDE", "1425,6010"), ",")[[1]])
bands   <- c(0, 25, 50, 100, 200, 500)
no_link_expected <- 1491   # scripts/logs/habitat/20261022_evidence_build_ledger.csv
stamp   <- format(Sys.Date(), "%Y%m%d")
out_txt <- file.path("scripts/logs/fdis", paste0(stamp, "_snap_candidate_check.txt"))
out_csv <- file.path("scripts/logs/fdis", paste0(stamp, "_snap_candidate_check.csv.gz"))

band <- function(d) cut(d, bands, right = FALSE, include.lowest = TRUE, dig.lab = 4)
t0 <- Sys.time()

# ---- inputs ----------------------------------------------------------------------
sites <- readRDS("data/fdis/build/sites.rds") |>
  mutate(across(where(~ inherits(.x, "integer64")), as.numeric))
# the old snap is fwa_indexpoint()'s stored placement; from #91 0230 writes fresh's (with snap_method), against which
# this probe would compare the new snap with itself. Restore the 2026-10-17 build (md5 98d4d6dd…) to rerun it.
if ("snap_method" %in% names(sites)) stop("data/fdis/build/sites.rds is #91's placement, not fwa_indexpoint()'s")
fish <- readRDS("data/fdis/build/fish.rds")
pts <- sites |>
  filter(!flag_no_utm) |>
  group_split(utm_zone) |>
  lapply(\(d) st_transform(st_as_sf(d |> select(site_visit, utm_zone, utm_easting, utm_northing),
                                    coords = c("utm_easting", "utm_northing"),
                                    crs = 32600 + d$utm_zone[1]), 3005)) |>
  bind_rows() |>
  select(site_visit)
stopifnot(!anyDuplicated(pts$site_visit))

conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))

# FWA attributes of a set of segments: whether fresh refuses it, and its edge type
fwa_attr <- function(lfid) {
  lfid <- unique(lfid[!is.na(lfid)])
  DBI::dbWriteTable(conn, "tmp_snap_lfid", data.frame(linear_feature_id = lfid), temporary = TRUE, overwrite = TRUE)
  DBI::dbGetQuery(conn, "
    SELECT s.linear_feature_id, s.edge_type, s.localcode_ltree IS NULL AS unmapped,
           coalesce(s.wscode_ltree <@ '999', FALSE) AS placeholder
      FROM tmp_snap_lfid t JOIN whse_basemapping.fwa_stream_networks_sp s USING (linear_feature_id)")
}

# ---- the old snap (stored) and the new nearest snaps --------------------------------
old <- sites |>
  filter(!flag_no_utm, !flag_not_placed) |>
  select(site_visit, old_blk = blue_line_key, old_lfid = linear_feature_id, old_m = downstream_route_measure,
         old_dist = distance_to_stream, old_wsg = watershed_group_code)
old <- old |> left_join(fwa_attr(old$old_lfid) |> rename_with(~ paste0("old_", .x)), by = c("old_lfid" = "old_linear_feature_id"))

snap <- function(p, ...) {
  s <- fresh::frs_point_snap(conn, p, tolerance = tol, ...)
  sf::st_drop_geometry(s) |> mutate(across(where(~ inherits(.x, "integer64")), as.numeric))
}
t1 <- Sys.time()
nn_all <- snap(pts, col_id = "site_visit", exclude_edge_types = NULL)
t_nn_all <- difftime(Sys.time(), t1, units = "secs")
t1 <- Sys.time()
nn <- snap(pts, col_id = "site_visit", exclude_edge_types = exclude)
t_nn <- difftime(Sys.time(), t1, units = "secs")
stopifnot(!anyDuplicated(nn$site_visit), !anyDuplicated(nn_all$site_visit))
nn_all <- nn_all |> select(site_visit, any_lfid = linear_feature_id, any_dist = distance_to_stream) |>
  left_join(fwa_attr(nn_all$linear_feature_id) |> select(linear_feature_id, any_edge_type = edge_type),
            by = c("any_lfid" = "linear_feature_id"))
nn <- nn |> select(site_visit, new_blk = blue_line_key, new_lfid = linear_feature_id, new_m = downstream_route_measure,
                   new_dist = distance_to_stream, new_wsg = watershed_group_code) |>
  left_join(fwa_attr(nn$linear_feature_id) |> select(linear_feature_id, new_edge_type = edge_type),
            by = c("new_lfid" = "linear_feature_id"))

v <- pts |> st_drop_geometry() |>
  left_join(old, by = "site_visit") |>
  left_join(nn, by = "site_visit") |>
  left_join(nn_all, by = "site_visit") |>
  mutate(class = case_when(
    is.na(old_blk) & is.na(new_blk) ~ "neither",
    is.na(new_blk) ~ "old_only",
    is.na(old_blk) ~ "new_only",
    old_lfid == new_lfid ~ "same_segment",
    old_blk == new_blk ~ "same_stream",
    old_placeholder ~ "old_placeholder",
    old_unmapped ~ "old_unmapped",
    old_edge_type == 1425 ~ "old_subsurface",
    old_edge_type %in% exclude ~ "old_excluded",
    abs(old_dist - new_dist) < 0.001 ~ "tie",
    TRUE ~ "other"))
stopifnot(nrow(v) == nrow(pts), !anyNA(v$class))

# ---- link placement under each snap ------------------------------------------------
place <- function(x) {
  x <- x |> filter(!is.na(blue_line_key))
  knw_link_place(conn, x, schema)$placed$site_visit
}
t1 <- Sys.time()
link_old <- place(v |> transmute(site_visit, watershed_group_code = old_wsg, blue_line_key = old_blk,
                                 downstream_route_measure = old_m))
link_new <- place(v |> transmute(site_visit, watershed_group_code = new_wsg, blue_line_key = new_blk,
                                 downstream_route_measure = new_m))
t_link <- difftime(Sys.time(), t1, units = "secs")
v <- v |> mutate(link_old = site_visit %in% link_old, link_new = site_visit %in% link_new)

# today's evidence path: quality drops, then link on the stored placement
q <- knw_fdis_quality(sites)
kept_old <- q$kept
no_link_today <- nrow(kept_old) - sum(kept_old$site_visit %in% link_old)

# ---- the hint route ----------------------------------------------------------------
ws50 <- fish |>
  filter(!is.na(watershed_code_50k), nchar(watershed_code_50k) == 45,
         substr(watershed_code_50k, 4, 45) != strrep("0", 42)) |>
  distinct(site_visit, watershed_code_50k) |>
  filter(site_visit %in% v$site_visit)
xref <- DBI::dbGetQuery(conn, "SELECT DISTINCT watershed_code_50k, blue_line_key_20k AS blk
                                 FROM whse_basemapping.fwa_streams_20k_50k
                                WHERE watershed_code_50k IS NOT NULL") |>
  mutate(blk = as.numeric(blk))
keys_per_code <- xref |> count(watershed_code_50k, name = "n_keys")
codes <- ws50 |> left_join(keys_per_code, by = "watershed_code_50k") |> mutate(n_keys = coalesce(n_keys, 0L))
hint <- ws50 |> inner_join(xref, by = "watershed_code_50k", relationship = "many-to-many") |>
  distinct(site_visit, blk)
visit_codes <- codes |> group_by(site_visit) |>
  summarise(n_codes = n(), n_codes_known = sum(n_keys > 0), .groups = "drop") |>
  left_join(hint |> count(site_visit, name = "n_keys_visit"), by = "site_visit") |>
  mutate(n_keys_visit = coalesce(n_keys_visit, 0L))

hp <- pts |> inner_join(hint, by = "site_visit") |> mutate(hid = paste(site_visit, blk, sep = "|"))
t1 <- Sys.time()
hits <- snap(hp |> select(hid, blk), col_id = "hid", col_blk = "blk", exclude_edge_types = exclude)
t_hint <- difftime(Sys.time(), t1, units = "secs")
hits <- hits |> mutate(site_visit = sub("\\|[^|]*$", "", hid))
stopifnot(all(hits$blue_line_key == as.numeric(sub("^.*\\|", "", hits$hid))))
best_hit <- hits |> arrange(site_visit, distance_to_stream, linear_feature_id) |>
  distinct(site_visit, .keep_all = TRUE) |>
  select(site_visit, hit_blk = blue_line_key, hit_lfid = linear_feature_id, hit_dist = distance_to_stream)

v <- v |>
  left_join(visit_codes, by = "site_visit") |>
  left_join(best_hit, by = "site_visit") |>
  mutate(
    n_codes = coalesce(n_codes, 0L), n_codes_known = coalesce(n_codes_known, 0L),
    n_keys_visit = coalesce(n_keys_visit, 0L),
    checkable = n_codes_known > 0,
    route = case_when(
      !is.na(hit_blk) ~ "confirmed",
      checkable ~ "no_hit",
      !is.na(new_blk) ~ "unconfirmed",
      TRUE ~ "not_placed"),
    pick_dist = case_when(route == "confirmed" ~ hit_dist, route == "unconfirmed" ~ new_dist),
    moved = route == "confirmed" & hit_blk != new_blk,
    # the issue's check on the nearest snap: does the nearest lie on a stream the code names?
    nearest_agrees = if_else(checkable & !is.na(new_blk),
                             paste(site_visit, new_blk) %in% paste(hint$site_visit, hint$blk), NA))

# ---- summary -----------------------------------------------------------------------
dir.create(dirname(out_txt), showWarnings = FALSE, recursive = TRUE)
sink(out_txt)
cat("# FDIS placement probe (#91), data-raw/snap_candidate_check.R\n")
cat("run:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), " fresh", as.character(packageVersion("fresh")),
    " schema", schema, " tolerance", tol, "m  exclude", paste(exclude, collapse = ","), "\n")
cat("md5 sites.rds", unname(tools::md5sum("data/fdis/build/sites.rds")),
    " fish.rds", unname(tools::md5sum("data/fdis/build/fish.rds")), "\n")
cat(sprintf("timing (s): nearest, no exclusion %.1f; nearest %.1f; hinted (%d rows) %.1f; link placement x2 %.1f\n\n",
            t_nn_all, t_nn, nrow(hp), t_hint, t_link))

cat("## Visits with coordinates:", nrow(v), "\n")
cat("old snap places", sum(!is.na(v$old_blk)), "(sites_placed in 0230's reconcile: 50,024); new nearest places",
    sum(!is.na(v$new_blk)), "\n\n")

cat("## Where the nearest line is subsurface (1425) or a connector (6010) with no edge type excluded\n")
print(v |> filter(!is.na(any_lfid)) |>
        mutate(any_class = case_when(any_edge_type == 1425 ~ "1425 subsurface", any_edge_type == 6010 ~ "6010 connector",
                                     TRUE ~ "other edge type")) |>
        count(any_class, wt = NULL) |> as.data.frame())
cat("\n")

cat("## Classes (first match; they partition the visits with coordinates), and link placement under each snap\n")
cls <- v |> group_by(class) |>
  summarise(n = n(), link_old = sum(link_old), link_new = sum(link_new),
            med_old_dist = round(median(old_dist, na.rm = TRUE), 1),
            med_new_dist = round(median(new_dist, na.rm = TRUE), 1), .groups = "drop") |>
  arrange(desc(n))
print(as.data.frame(cls))
cat("total", sum(cls$n), "\n")
same <- v |> filter(class == "same_segment")
cat(sprintf("same_segment measure difference: max %.3f m, share under 1 m %.4f\n\n",
            max(abs(same$old_m - same$new_m)), mean(abs(same$old_m - same$new_m) < 1)))

cat("## Old-snap visits that link cannot place, by the old pick's kind\n")
print(v |> filter(!is.na(old_blk)) |>
        mutate(kind = case_when(old_placeholder ~ "placeholder", old_unmapped ~ "unmapped",
                                old_edge_type == 1425 ~ "subsurface 1425", TRUE ~ "other")) |>
        group_by(kind) |> summarise(n = n(), link_placed = sum(link_old), not_link = sum(!link_old), .groups = "drop") |>
        as.data.frame())
cat(sprintf("\nToday's path (knw_fdis_quality() then link): %d kept, no_link_segment %d (expected %d: %s)\n\n",
            nrow(kept_old), no_link_today, no_link_expected,
            if (no_link_today == no_link_expected) "reproduced" else "NOT reproduced"))

cat("## The hint route\n")
cat("visits with a checkable code:", sum(v$n_codes > 0), "; with a code fwa_streams_20k_50k knows:", sum(v$checkable),
    "(0230's sites_ws50_checked 12,285 counts placed visits with a code, pooled from repeat copies)\n")
cat("checkable visits that the old snap placed:", sum(v$n_codes > 0 & !is.na(v$old_blk)), "\n")
cat("checkable codes per visit:\n"); print(table(pmin(v$n_codes[v$n_codes > 0], 3), dnn = "codes (3 = 3+)"))
cat("keys per code (codes on these visits):\n")
print(table(cut(codes$n_keys, c(-Inf, 0, 1, 2, 5, 20, Inf), labels = c("0", "1", "2", "3-5", "6-20", ">20")), dnn = "keys"))
cat("hinted rows:", nrow(hp), "; hits:", nrow(hits), "\n\n")
cat("routes (partition of visits with coordinates):\n")
print(as.data.frame(v |> count(route)))
cat("\nconfirmed picks, by the visit's keys (union over its codes) and moved:\n")
print(as.data.frame(v |> filter(route == "confirmed") |>
  mutate(keys = cut(n_keys_visit, c(0, 1, 2, 5, Inf), labels = c("1", "2", "3-5", ">5"))) |>
  count(keys, moved)))
cat("\nmoved picks: pick distance band x nearest distance band\n")
print(with(v |> filter(moved), table(pick = band(hit_dist), nearest = band(new_dist))))
cat("\npick distance by route (confirmed and unconfirmed):\n")
print(with(v |> filter(route %in% c("confirmed", "unconfirmed")), table(band(pick_dist), route)))
cat("\nno_hit visits by the nearest snap's distance (a known code, no named stream within 500 m):\n")
print(table(band(v$new_dist[v$route == "no_hit"]), useNA = "ifany"))
cat("\nthe issue's check under the new nearest snap: disagreement by nearest distance (checkable, placed)\n")
print(as.data.frame(v |> filter(!is.na(nearest_agrees)) |> group_by(band = band(new_dist)) |>
  summarise(n = n(), disagree = sum(!nearest_agrees), share = round(mean(!nearest_agrees), 3), .groups = "drop")))

cat("\n## Preview at the gate's provisional limits (unconfirmed 100 m, confirmed 500 m), then today's other drops\n")
prev <- sites |>
  left_join(v |> select(site_visit, route, pick_dist), by = "site_visit") |>
  mutate(flag_not_placed = is.na(route) | route == "not_placed",
         flag_far_snap = route == "unconfirmed" & pick_dist > 100 | route == "confirmed" & pick_dist > 500,
         flag_ws50_mismatch = route %in% "no_hit")
qp <- knw_fdis_quality(prev)
print(as.data.frame(bind_rows(q$ledger |> mutate(snap = "today"), qp$ledger |> mutate(snap = "hint route")) |>
  select(snap, step, n) |> pivot_wider(names_from = snap, values_from = n)))
cat(sprintf("\nelapsed %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
sink()

write_csv(v |> select(site_visit, class, route, moved, checkable, n_codes, n_keys_visit, old_blk, old_lfid, old_dist,
                      old_edge_type, old_unmapped, old_placeholder, new_blk, new_lfid, new_dist, new_edge_type,
                      any_lfid, any_dist, any_edge_type, hit_blk, hit_lfid, hit_dist, nearest_agrees,
                      link_old, link_new) |>
            mutate(across(ends_with("_dist"), ~ round(.x, 2))),
          out_csv, na = "")
DBI::dbDisconnect(conn)
message("wrote ", out_txt, " and ", out_csv)
cat(readLines(out_txt), sep = "\n")
