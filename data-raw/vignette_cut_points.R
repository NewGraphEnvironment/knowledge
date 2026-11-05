# data-raw/vignette_cut_points.R
# ---------------------------------------------------------------------------
# The data the cut-points article (#149) reads, so it builds with no database: how where link cuts a stream changes
# the slope a rule reads at a fish site, and how far chinook rearing's tuned rule moved with it.
#
# WHY / DESIGN NOTES:
#   - IT READS ONLY THE STAGE AND TRACKED LOGS. data-raw/cut_points_stage.R copied every ignored input into
#     data/stage/cut_points/ on the database's host, each held to its run, with a manifest; this script refuses a staged
#     file whose md5 is not the manifest's. The tracked inputs are logs written once (the segment gradient checks,
#     setup_compare.R's and pick_network_compare.R's), so a promotion moves none of them and the article stays a
#     snapshot of the runs they describe.
#   - EVERY STAGED NUMBER IS HELD TO THE LOG THAT PUBLISHED IT. The premise (fish sites starting a segment of their own)
#     is recomputed on #92's, #145's and the minimal network's evidence and must equal the three segment gradient
#     check logs; each setup's pick and km must equal setup_compare.R's csv; the transfer, recomputed from the setups'
#     GeoPackage, must equal the minimal and parent setups' km in that csv.
#   - THE EXAMPLES ARE CHOSEN HERE, BY RULES FIXED BEFORE DRAWING. The population is the tuning's before its model
#     filters (knw_tune_run()'s visits_in for chinook rearing). A "crossing" site reads its full segment's gradient and
#     its minimal parent's on opposite sides of a tuned limit: 9 % (the minimal and parent setups' pick) or 13 %
#     (#145's). Only full segments of at least min_len_m count, so a sliver of a few metres, whose gradient is noise,
#     is never the example.
#       concept: among crossing sites with chinook caught that start their own full segment (its downstream end 1 m
#         below to 5 m above the site, segment_gradient_check.R's window), the largest gap between the two gradients;
#       examples: among the other crossing sites with chinook caught, the largest gap in each group, the n_examples
#         groups with the largest such gaps;
#       map group: setup_compare.R's (the most km where the four setups' verdicts differ), as the stage recorded it.
#   - GEOMETRY. Maps are simplified at 5 m (the example windows) and 10 m (the map group); lengths stay the segments'
#     own. The concept profile keeps each segment's end elevations and the Atlas line's vertices (measure, elevation),
#     so a segment's drawn slope is its own gradient. No modelled flow is carried (NOTICE, #76).
#
# INPUT:  STAGE_DIR (default data/stage/cut_points; data-raw/cut_points_stage.R) and its MANIFEST.csv;
#         scripts/logs/habitat/{20261027_segment_gradient_check.txt,
#         20261103_segment_gradient_check-derived_default_20261103.txt, 20261103_segment_gradient_check-derived_minimal.txt,
#         20261105_setup_compare-ch_rear.csv, 20261104_pick_network_compare.csv}
# OUTPUT: inst/vignette-data/cut_points.rds   one named list (sf tables in EPSG:3005)
# RUN:    Rscript data-raw/vignette_cut_points.R   (from the repo root, on a machine holding the stage)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)

stage <- Sys.getenv("STAGE_DIR", "data/stage/cut_points")
dir_out <- "inst/vignette-data"
limits <- c(minimal = 0.09, published = 0.13)   # the tuned limits a crossing is read against
min_len_m <- 50                                 # the shortest full segment an example may sit on
n_examples <- 3
win_m <- 1500                                   # an example's window either side of its site
logs <- c(premise_92 = "scripts/logs/habitat/20261027_segment_gradient_check.txt",
          premise_145 = "scripts/logs/habitat/20261103_segment_gradient_check-derived_default_20261103.txt",
          premise_minimal = "scripts/logs/habitat/20261103_segment_gradient_check-derived_minimal.txt",
          setups = "scripts/logs/habitat/20261105_setup_compare-ch_rear.csv",
          picks = "scripts/logs/habitat/20261104_pick_network_compare.csv")

git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed: ", out[1])
  out
}
dirty <- git("status", "--porcelain", "--", "data-raw/vignette_cut_points.R", "R", unname(logs))
if (length(dirty)) stop("commit these first, so the bundle's commit is the code it ran: ", paste(dirty, collapse = "; "))

# ---- the stage, held to its manifest -------------------------------------------------------------------------
man <- read_csv(file.path(stage, "MANIFEST.csv"), show_col_types = FALSE, col_types = cols(.default = "c"))
got <- unname(tools::md5sum(file.path(stage, man$path)))
bad <- man$path[is.na(got) | got != man$md5]
if (length(bad)) stop("staged files not as the manifest records them: ", paste(bad, collapse = ", "))
sp <- function(...) file.path(stage, ...)
ct <- cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c")
rd_vl <- function(f) read_csv(f, show_col_types = FALSE, guess_max = 1e5, col_types = ct)
rd_c <- function(f) read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
area_range <- eval(fm$area_range)
stream_branch <- function(v) {
  filter(v, edge_type %in% edge_stream, !(wb_river %in% TRUE), !(wb_wetland %in% TRUE), !(wb_lake %in% TRUE),
         !is.na(area_m2), area_m2 >= area_range[1], area_m2 <= area_range[2])
}
at_site <- function(off) off >= -1 & off <= 5

# ---- the premise: fish sites starting a segment of their own, on three networks -----------------------------
nets <- c(published_92 = "premise_92", published_145 = "premise_145", minimal = "premise_minimal")
premise <- bind_rows(lapply(names(nets), function(n) {
  stream_branch(rd_vl(sp("evidence", n, "visits_link.csv"))) |>
    group_by(catch_status) |>
    summarise(visits = n(), at_site_pct = 100 * mean(at_site(segment_start_offset_m)),
              len_median_m = median(segment_length_m), .groups = "drop") |>
    mutate(network = n, .before = 1)
}))
# each row as its segment gradient check logged it
for (n in names(nets)) {
  ll <- readLines(logs[[nets[[n]]]])
  for (cs in c("fish", "zero")) {
    w <- strsplit(trimws(grep(sprintf("^ +%s +[0-9]", cs), ll, value = TRUE)[1]), " +")[[1]]
    r <- premise[premise$network == n & premise$catch_status == cs, ]
    if (!identical(r$visits, as.integer(w[2])) || abs(r$at_site_pct - as.numeric(w[3])) > 0.05 ||
        abs(r$len_median_m - as.numeric(w[4])) > 0.5) {
      stop(n, " ", cs, ": ", r$visits, " visits, ", round(r$at_site_pct, 1), " %, ", round(r$len_median_m),
           " m; ", logs[[nets[[n]]]], " logged ", paste(w[2:4], collapse = ", "))
    }
  }
}
premise$link <- c(published_92 = "0.66.0", published_145 = "0.78.2", minimal = "0.78.1")[premise$network]

# ---- the four chinook rearing setups --------------------------------------------------------------------------
setup_names <- c("published", "minimal", "parent", "atlas")
recs <- lapply(stats::setNames(setup_names, setup_names), function(s) {
  knw_grade_record_read(sp("runs", s, "CH_rear_grades_record.csv"))
})
cols_tune <- c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d", "departures", "is_default", "n_visits",
               "ddev_best", "se_diff", "in_region", "recommended")
tune <- lapply(stats::setNames(setup_names, setup_names), function(s) rd_c(sp("runs", s, "CH_rear_tune.csv"))[, cols_tune])
setups <- bind_rows(lapply(setup_names, function(s) {
  t <- tune[[s]]
  rec <- t$recommended %in% "TRUE"
  a <- read_csv(sp("runs", s, "CH_rear_compare.csv"), show_col_types = FALSE)
  a <- a[a$watershed_group_code == "ALL" & a$structure == a$tuned_structure, ]
  r <- recs[[s]]
  tibble(setup = s, tune_run = r$tune_run, link_run = r$run_uid, token_cut = r$token_cut, token_grad = r$token_grad,
         curve_grad = r$curve_grad, pick = t$rule[rec], grad_max = as.numeric(t$grad_max[rec]),
         n_visits = as.integer(t$n_visits[rec]), rules_in_region = sum(t$in_region %in% "TRUE"),
         default_km = a$default_km, tuned_km = a$tuned_km, change_pct = a$change_pct)
}))
logged <- read_csv(logs[["setups"]], show_col_types = FALSE)
chk_setups <- inner_join(setups, logged, by = "setup", suffix = c("", "_log"))
if (nrow(chk_setups) != 4 || !identical(chk_setups$pick, chk_setups$pick_log) ||
    !identical(chk_setups$tune_run, chk_setups$tune_run_log) ||
    any(abs(chk_setups$tuned_km - chk_setups$tuned_km_log) > 1e-6) ||
    any(abs(chk_setups$default_km - chk_setups$default_km_log) > 1e-6) ||
    !identical(chk_setups$rules_in_region, as.integer(chk_setups$rules_in_region_log))) {
  stop("the staged setups are not the ones ", logs[["setups"]], " logged")
}

# ---- the setups' verdicts on the full network: km by pattern and the transfer --------------------------------
f_set <- sp("setups", "CH_rear_setups.gpkg")
verd <- sf::st_read(f_set, quiet = TRUE, query = "
  SELECT watershed_group_code, id_segment, length_metre, stream_order, \"default\", published, minimal, parent, atlas,
         pattern FROM segments")
verd <- sf::st_drop_geometry(verd)
km <- function(x) sum(x) / 1000
yes <- function(x) as.logical(x) %in% TRUE   # a GeoPackage boolean reads back as logical or as 0/1
by_pattern <- verd |> filter(pattern != "none") |> group_by(pattern) |>
  summarise(km = km(length_metre), segments = n(), .groups = "drop") |> arrange(desc(km))
transfer <- verd |>
  summarise(minimal_km = km(length_metre[yes(minimal)]), parent_km = km(length_metre[yes(parent)]),
            minimal_only_km = km(length_metre[yes(minimal) & !yes(parent)]),
            parent_only_km = km(length_metre[yes(parent) & !yes(minimal)]))
for (s in c("minimal", "parent")) {
  if (abs(transfer[[paste0(s, "_km")]] - setups$tuned_km[setups$setup == s]) > 0.05) {
    stop("the GeoPackage's ", s, " km (", transfer[[paste0(s, "_km")]], ") is not its comparison's")
  }
}

# ---- the other keys, on the full and minimal networks (#145's DEV tuning, the issue's four of seven) ----------
pk <- rd_c(logs[["picks"]])
other_keys <- tibble(key = pk$key, pick_minimal = pk$rule_recommended_minimal, pick_full = pk$rule_recommended_full,
                     network_moved = pk$network_moved,
                     minimal_in_full_region = pk$minimal_pick_in_full_region == "TRUE",
                     full_in_minimal_region = pk$full_pick_in_minimal_region == "TRUE")
if (nrow(other_keys) != 7 || sum(other_keys$network_moved != "none") != 4 ||
    sum(!other_keys$minimal_in_full_region | !other_keys$full_in_minimal_region) != 3) {
  stop(logs[["picks"]], " no longer reads four of seven keys moved, three outside the other's region")
}

# ---- the population and its crossing sites --------------------------------------------------------------------
vl <- rd_vl(sp("evidence", "parent", "visits_link.csv"))
vm <- rd_vl(sp("evidence", "minimal", "visits_link.csv"))
vs <- read_csv(sp("evidence", "parent", "visits_species.csv"), show_col_types = FALSE, col_types = cols(site_visit = "c"))
ch <- vs |> filter(species_code == "CH", in_range %in% TRUE, status != "blocked") |> select(site_visit, present)
sites <- stream_branch(vl) |>
  filter(barrier_dnstr_ch %in% FALSE) |>
  inner_join(ch, by = "site_visit") |>
  left_join(select(vm, site_visit, minimal_gradient = segment_gradient, minimal_length_m = segment_length_m,
                   minimal_offset_m = segment_start_offset_m), by = "site_visit") |>
  transmute(site_visit, watershed_group_code, blue_line_key, measure = downstream_route_measure, present,
            full_gradient = segment_gradient, full_length_m = segment_length_m, full_offset_m = segment_start_offset_m,
            parent_gradient, parent_length_m, minimal_gradient, minimal_length_m, minimal_offset_m,
            atlas_gradient = segment_fwa_gradient)
if (anyNA(sites[, c("full_gradient", "parent_gradient", "minimal_gradient", "atlas_gradient")])) {
  stop("a population site lacks a gradient on some setup")
}
side <- function(g, t) g <= t
sites$crosses <- Reduce(`|`, lapply(limits, function(t) side(sites$full_gradient, t) != side(sites$parent_gradient, t)))
sites$gap <- abs(sites$full_gradient - sites$parent_gradient)
cand <- sites |> filter(crosses, present, full_length_m >= min_len_m)
concept_site <- cand |> filter(at_site(full_offset_m)) |> arrange(desc(gap), site_visit) |> slice(1)
ex_sites <- cand |> filter(watershed_group_code != concept_site$watershed_group_code) |>
  group_by(watershed_group_code) |> arrange(desc(gap), site_visit, .by_group = TRUE) |> slice(1) |> ungroup() |>
  arrange(desc(gap), watershed_group_code) |> slice_head(n = n_examples)
if (nrow(concept_site) != 1 || nrow(ex_sites) != n_examples) stop("the criteria found no concept site or too few examples")

# ---- geometry from the stage ----------------------------------------------------------------------------------
f_lines <- sp("lines.gpkg")
lyr <- function(l) sf::st_read(f_lines, l, quiet = TRUE)
full_seg <- lyr("full_segments")
min_seg <- lyr("minimal_segments")
fwa <- lyr("fwa_lines")
site_pts <- sf::st_zm(lyr("sites"), drop = TRUE)
water <- lyr("water")
staged_lines <- unique(full_seg$blue_line_key)
if (!all(c(concept_site$blue_line_key, ex_sites$blue_line_key) %in% staged_lines)) {
  stop("an example's line is not staged: rerun data-raw/cut_points_stage.R")
}
# the concept stream's profile: each network's segments as (measure, elevation) at their ends, and the Atlas line's
# vertices
prof_seg <- function(x, net) {
  sf::st_drop_geometry(x[x$blue_line_key == concept_site$blue_line_key, ]) |>
    transmute(network = net, id_segment, from_m = downstream_route_measure, to_m = upstream_route_measure,
              length_metre, gradient, z_dn, z_up)
}
xyzm <- sf::st_coordinates(fwa[fwa$blue_line_key == concept_site$blue_line_key, ])
concept <- list(
  site = concept_site,
  segments = bind_rows(prof_seg(full_seg, "full"), prof_seg(min_seg, "minimal"), prof_seg(fwa, "atlas")),
  atlas_profile = tibble(measure = xyzm[, "M"], z = xyzm[, "Z"]) |> distinct() |> arrange(measure),
  sites = sites |> filter(blue_line_key == concept_site$blue_line_key) |>
    select(site_visit, measure, present, full_gradient, parent_gradient, atlas_gradient),
  gnis_name = unique(na.omit(fwa$gnis_name[fwa$blue_line_key == concept_site$blue_line_key]))
)
# each example's window: both networks' segments on its line within win_m of the site, its sites, and the water
simp <- function(x, tol) sf::st_simplify(sf::st_zm(x, drop = TRUE), dTolerance = tol, preserveTopology = TRUE)
examples <- lapply(seq_len(nrow(ex_sites)), function(i) {
  e <- ex_sites[i, ]
  pick <- function(x) x[x$blue_line_key == e$blue_line_key & x$upstream_route_measure > e$measure - win_m &
                          x$downstream_route_measure < e$measure + win_m, ]
  keep <- c("id_segment", "gradient", "downstream_route_measure", "length_metre")
  segs <- rbind(
    mutate(simp(pick(full_seg), 5)[, c(keep, "parent_gradient")], network = "full"),
    mutate(simp(pick(min_seg), 5)[, keep], parent_gradient = NA_real_, network = "minimal"))
  bb <- sf::st_as_sfc(sf::st_bbox(sf::st_buffer(sf::st_union(segs), 500)))
  w <- simp(water[lengths(sf::st_intersects(water, bb)) > 0, ], 5)
  list(site = e, segments = segs, water = sf::st_collection_extract(suppressWarnings(sf::st_intersection(w, bb)), "POLYGON"),
       sites = site_pts[site_pts$blue_line_key == e$blue_line_key, ] |>
         inner_join(select(sites, site_visit, present), by = "site_visit") |>
         filter(abs(measure - e$measure) <= win_m),
       gnis_name = unique(na.omit(fwa$gnis_name[fwa$blue_line_key == e$blue_line_key])))
})
names(examples) <- ex_sites$site_visit
# the map group: its accessible segments, which of them each setup draws, and its water
wsg_map <- verd |> group_by(watershed_group_code) |>
  summarise(m = sum(length_metre[!pattern %in% c("every setup", "none")]), .groups = "drop") |>
  arrange(desc(m), watershed_group_code) |> slice(1) |> pull(watershed_group_code)
map_bg <- simp(lyr("map_segments"), 10)
if (!all(map_bg$watershed_group_code == wsg_map)) stop("the stage's map group is not ", wsg_map)
map_drawn <- sf::st_read(f_set, quiet = TRUE, query = sprintf(
  "SELECT * FROM segments WHERE watershed_group_code = '%s' AND pattern != 'none'", wsg_map))
map_drawn <- simp(map_drawn, 10)[, c("id_segment", "length_metre", "stream_order", "pattern", "default", "published",
                                     "minimal", "parent", "atlas")]
map_water <- simp(water[sf::st_intersects(water, sf::st_as_sfc(sf::st_bbox(map_bg)), sparse = FALSE)[, 1], ], 10)
map <- list(wsg = wsg_map, background = map_bg[, c("id_segment", "stream_order")], drawn = map_drawn,
            water = map_water,
            km = verd |> filter(watershed_group_code == wsg_map) |>
              summarise(default_km = km(length_metre[yes(`default`)]),
                        disagree_km = km(length_metre[!pattern %in% c("every setup", "none")])))

# ---- write ----------------------------------------------------------------------------------------------------
tracked <- unname(logs)
out <- list(
  premise = premise, setups = setups, tune = tune, by_pattern = by_pattern, transfer = transfer,
  other_keys = other_keys, sites = sites,
  criteria = list(limits = limits, min_len_m = min_len_m, n_examples = n_examples, win_m = win_m),
  concept = concept, examples = examples, map = map,
  meta = list(written = format(Sys.Date()), commit = git("rev-parse", "--short", "HEAD"),
              link_run_full = unique(man$link_run_full), link_run_minimal = unique(man$link_run_minimal),
              stage_commit = unique(man$commit),
              md5 = tools::md5sum(tracked) |> stats::setNames(tracked),
              md5_local = stats::setNames(man$md5, file.path(.knw_path_rel(stage), man$path)))
)
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
f_out <- file.path(dir_out, "cut_points.rds")
saveRDS(out, f_out, compress = "xz")
message(sprintf("%s: %.2f MB; concept %s (%s), examples %s; map %s", f_out, file.size(f_out) / 1e6,
                concept_site$site_visit, concept_site$watershed_group_code,
                paste(ex_sites$site_visit, ex_sites$watershed_group_code, collapse = "; "), wsg_map))
