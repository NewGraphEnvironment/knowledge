# scripts/0293-bt-spawn-evidence.R
# ---------------------------------------------------------------------------
# BT spawner evidence on link's segments, by gradient and channel size. Issue #33.
# Evidence rates, NOT habitat weights: nothing here proposes a link threshold.
#
# ANALYSIS SPEC, fixed before the first fit. The raw class rates were seen beforehand, in the
# #28 side table and in the plan review's prototype, so this spec is not blind to them
# (planning/archive/.../review-plan.md for #33):
#   - POPULATION: 0290's visits on stream, canal and river-polygon edges, fished area 10-10,000 m2
#     (0291's filter). The visit table is read as it stands (md5 logged), never rebuilt here.
#   - FISH: per-fish maturity (data/fdis/build/fish.rds) and visit month, BT codes pooled per
#     visit as 0290 pools them.
#   - KINDS, strongest first: SP/ST > M Sep-Oct > M Aug > M other months > adult size only
#     (>= 350 mm, Aug-Oct, no maturity code). Spawner evidence = SP/ST or M Aug-Oct, the 0240
#     rule; the script stops if it does not reproduce 0240's spawner rows on these visits.
#   - SIZE: every response split by spawner size, large (>= 350 mm, a migratory-adult size per
#     data/fdis_size_breaks.csv) or small (< 350 mm). Small mature fish are consistent with
#     resident spawning in place; large ones with migrants, in place or passing through.
#   - RESPONSE (S): spawner evidence, among Aug-Oct visits that caught BT and maturity-coded at
#     least one BT. On visits nobody maturity-coded, evidence was impossible (review B2).
#   - MODEL: binomial cloglog, S ~ class + log(area) + log(n coded BT) + month + data_set + era
#     + WSG. WSGs with one outcome only are left out and counted; a one-level nuisance term is
#     dropped. Rate ratio per class against the count-weighted <= 5.49 % classes. 200 stream
#     bootstrap resamples on socket workers, seed fixed. Non-converged fits give NA.
#   - CLASSES: segment gradient <= 2, 2-4, 4-5.49, 5.49-8, 8-10.49, > 10.49 %; channel width
#     < 2, 2-5, 5-10, > 10 m (raw rates, by width source).
#   - POWER: a cell is `ok` with >= 30 visits and >= 10 detections, else `underpowered`.
#   - ALSO: BT caught (U) refitted on this ladder (0291's model); August vs Sep-Oct; agency and
#     measured-site-gradient sensitivities.
#   - LARGE SPAWNERS ON STEEP SEGMENTS, descriptive only: for each, how many access-independent
#     patches lie anywhere upstream in the network within the WSG (>= 200 m of contiguous
#     segments at <= 0.0549, modelled or measured width >= 2 m, stream or canal edge; no
#     distance limit), and the distance to the nearest along the same blue line if within 10 km,
#     censored otherwise. No inference: too few visits to test "passing through" against
#     "spawning in place".
#   - POWER labels count all visits in a cell; the estimate beside them uses the modelled
#     subset (WSGs with both outcomes).
#   - REPEATED SURVEYS: about 2.8 % of visits match another on UTM, date, area, total catch and
#     species caught (#35). Most are one survey loaded under two or three collection ids, though
#     for zero-catch visits the match rests on UTM, date and area alone. They are kept here, as
#     0290 keeps them, and a sensitivity keeps only the lowest-id copy.
#   - ADDED AFTER CODE-CHECK ROUND 1 (not part of the spec fixed before the first fit): the
#     repeated-survey flag and sensitivity, the power-label note, and the no-WSG, WSG-only and
#     coding-and-month-only sensitivities. An upper interval of Inf means sparse resamples
#     separated; it is written as `Inf`.
#
# INPUT:  data/fdis/derived/bt_use_visits.csv (0290), data/fdis/build/{fish,sites}.rds (0230),
#         data/fdis_evidence.csv (0240), data/fiss_evidence.csv (0250); local fwapg :5432
# OUTPUT: data/bt_spawn_evidence.csv   aggregates: response x class (rates, rate ratios, power)
#         scripts/logs/habitat/<date>_bt_spawn_evidence.txt
# RUN:    Rscript scripts/0293-bt-spawn-evidence.R   (from the repo root; ~10 min)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(tidyr); library(DBI); library(RPostgres) })

path_visits <- "data/fdis/derived/bt_use_visits.csv"
edge_ok <- c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350)
edge_stream <- c(1000, 1050, 1100, 1150, 2000, 2100, 2300)
area_range <- c(10, 10000)
bt_dv_codes <- c("BT", "DV", "BT/DV", "DV/BT", "DVxBT")
coded <- c("IM", "M", "MT", "SP", "ST")
large_mm <- 350
spawn_max <- 0.0549
patch_min_m <- 200
patch_width_min <- 2
search_km <- 10
classes <- c("0-2", "2-4", "4-5.49", "5.49-8", "8-10.49", ">10.49")
ref <- classes[1:3]
n_boot <- 200
n_cores <- max(1L, min(6L, parallel::detectCores() - 2L))
min_visits <- 30
min_detect <- 10
path_out <- "data/bt_spawn_evidence.csv"
path_log <- file.path("scripts/logs/habitat",
                      paste0(format(Sys.Date(), "%Y%m%d"), "_bt_spawn_evidence.txt"))

log_lines <- character()
say <- function(...) log_lines <<- c(log_lines, sprintf(...))
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title),
                  capture.output(print(as.data.frame(x), row.names = FALSE)))
}
classify <- function(g) {
  factor(cut(g, c(-Inf, 0.02, 0.04, spawn_max, 0.08, 0.1049, Inf), labels = classes), classes)
}

say("BT spawner evidence, knowledge#33. Visit table md5 %s.", unname(tools::md5sum(path_visits)))

# ---- visits and fish ------------------------------------------------------------
v <- read_csv(path_visits, show_col_types = FALSE, col_types = cols(site_visit = "c")) |>
  filter(segment_edge_type %in% edge_ok, !is.na(area_m2), area_m2 >= area_range[1],
         area_m2 <= area_range[2]) |>
  mutate(cls = classify(segment_gradient), log_area = log(area_m2),
         era = factor(cut(year, c(-Inf, 1994, 2004, Inf), labels = c("to1994", "1995-2004", "2005on"))),
         data_set = factor(data_set), wsg = factor(watershed_group_code),
         stream = factor(blue_line_key), month_f = factor(month), U = as.integer(bt_present))
if (anyNA(v$cls)) stop("visits without a gradient class")
sig <- read_csv("data/fdis/derived/fdis_sites.csv", show_col_types = FALSE, guess_max = 1e5,
                col_types = cols(site_visit = "c", species_caught = "c")) |>
  filter(site_visit %in% v$site_visit) |>
  transmute(site_visit, sig = paste(utm_easting, utm_northing, date, area_m2, n_caught_all,
                                    species_caught),
            coll = as.numeric(sub("_.*", "", site_visit)))
first_copy <- sig |> group_by(sig) |> slice_min(coll, n = 1, with_ties = FALSE) |> ungroup()
v <- v |> mutate(first_copy = site_visit %in% first_copy$site_visit)
say("Repeated surveys (#35): %d of %d visits are a second copy of another visit.",
    sum(!v$first_copy), nrow(v))

fish <- readRDS("data/fdis/build/fish.rds") |>
  filter(site_visit %in% v$site_visit) |>
  inner_join(v |> select(site_visit, pooling, month), by = "site_visit") |>
  filter(species_code == "BT" | (pooling == "BT+DV" & species_code %in% bt_dv_codes)) |>
  mutate(kind = case_when(maturity_code %in% c("SP", "ST") ~ "SP/ST",
                          maturity_code == "M" & month %in% 9:10 ~ "M Sep-Oct",
                          maturity_code == "M" & month == 8 ~ "M Aug",
                          maturity_code == "M" ~ "M other months",
                          (is.na(maturity_code) | maturity_code == "U") & !is.na(length_mm) &
                            length_mm >= large_mm & month %in% 8:10 ~ "adult size only",
                          TRUE ~ "none"),
         spawner = kind %in% c("SP/ST", "M Sep-Oct", "M Aug"),
         large = !is.na(length_mm) & length_mm >= large_mm)
kinds <- c("SP/ST", "M Sep-Oct", "M Aug", "M other months", "adult size only", "none")
per_visit <- fish |>
  group_by(site_visit) |>
  summarise(kind = kinds[min(match(kind, kinds))],
            n_coded = sum(maturity_code %in% coded),
            S = as.integer(any(spawner)),
            S_large = as.integer(any(spawner & large)),
            S_small = as.integer(any(spawner & !large & !is.na(length_mm))),
            S_sepoct = as.integer(any(kind %in% c("SP/ST", "M Sep-Oct"))),
            .groups = "drop")
block("BT fish by kind (pooled per visit)", fish |> count(kind))
block("visits by strongest kind", per_visit |> count(kind))

# A4: the per-visit flag must reproduce 0240's spawner rows on the same visits and codes
ev <- read_csv("data/fdis_evidence.csv", show_col_types = FALSE, col_types = cols(site_visit = "c")) |>
  filter(size_class == "spawner_evidence", site_visit %in% v$site_visit) |>
  inner_join(v |> select(site_visit, pooling), by = "site_visit") |>
  filter(species_code == "BT" | (pooling == "BT+DV" & species_code %in% bt_dv_codes))
mine <- per_visit$site_visit[per_visit$S == 1L]
if (!setequal(mine, unique(ev$site_visit))) {
  stop("spawner flag does not reproduce 0240: ", length(setdiff(mine, ev$site_visit)), " extra, ",
       length(setdiff(ev$site_visit, mine)), " missing")
}
say("Spawner flag reproduces 0240's spawner rows on %d visits.", length(mine))

vb <- v |> filter(U == 1L) |> left_join(per_visit, by = "site_visit") |>
  mutate(across(c(n_coded, S, S_large, S_small, S_sepoct), ~ coalesce(.x, 0L)),
         kind = coalesce(kind, "none"))
pop <- vb |> filter(month %in% 8:10, n_coded >= 1) |> mutate(log_coded = log(n_coded))
say("BT visits: %d. Aug-Oct with >= 1 maturity-coded BT (the S population): %d.", nrow(vb), nrow(pop))
block("coding: share of BT visits with any maturity-coded BT, by class",
      vb |> group_by(cls, .drop = FALSE) |>
        summarise(bt_visits = n(), coded = sum(n_coded >= 1),
                  share = round(mean(n_coded >= 1), 3), .groups = "drop"))

# ---- model helpers (0291's pattern) -----------------------------------------------
nuisance <- c("data_set", "era", "wsg")
form <- function(d, resp, extra = NULL) {
  keep <- nuisance[vapply(nuisance, function(t) length(unique(d[[t]])) > 1L, logical(1))]
  as.formula(paste(resp, "~", paste(c("cls", extra, "log_area", keep), collapse = " + ")))
}
modelled <- function(d, resp) {
  k <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
  d <- d[d$wsg %in% names(k)[k %in% TRUE], ]
  d$wsg <- droplevels(d$wsg)
  d
}
fit <- function(d, resp, extra = NULL) {
  suppressWarnings(glm(form(d, resp, extra), family = binomial(link = "cloglog"), data = d,
                       control = glm.control(maxit = 100)))
}
rate_ratio <- function(m, d) {
  if (!m$converged) return(setNames(rep(NA_real_, length(classes)), classes))
  b <- coef(m)
  rr <- vapply(classes, function(k) {
    if (k == classes[1]) return(1)
    x <- b[paste0("cls", k)]
    if (is.na(x)) NA_real_ else exp(unname(x))
  }, numeric(1))
  n <- table(d$cls)[ref]
  rr / (sum(rr[ref] * n) / sum(n))
}
cl <- parallel::makeCluster(n_cores)
invisible(parallel::clusterEvalQ(cl, suppressMessages(library(dplyr))))
boot <- function(d, resp, extra, seed) {
  set.seed(seed)
  streams <- levels(droplevels(d$stream))
  idx <- split(seq_len(nrow(d)), droplevels(d$stream))
  picks <- lapply(seq_len(n_boot), function(i) sample(streams, length(streams), replace = TRUE))
  parallel::clusterExport(cl, c("d", "idx", "resp", "extra"), envir = environment())
  parallel::clusterExport(cl, c("modelled", "fit", "form", "rate_ratio", "classes", "ref",
                                "nuisance"), envir = globalenv())
  w <- parallel::parLapply(cl, picks, function(pick) {
    bd <- modelled(d[unlist(idx[pick], use.names = FALSE), ], resp)
    w <- tryCatch(rate_ratio(fit(bd, resp, extra), bd), error = function(e) rep(NA_real_, 6))
    w[!classes %in% unique(bd$cls)] <- NA_real_
    w
  })
  if (!all(vapply(w, function(x) is.numeric(x) && length(x) == length(classes), logical(1)))) {
    stop("a bootstrap worker failed")
  }
  do.call(rbind, w)
}
curve <- function(d, resp, extra, label, seed) {
  dm <- modelled(d, resp)
  m <- fit(dm, resp, extra)
  bw <- boot(dm, resp, extra, seed)
  say("%s: %d visits in %d WSGs modelled; %d visits in %d WSGs with one outcome only left out",
      label, nrow(dm), nlevels(dm$wsg), nrow(d) - nrow(dm),
      length(unique(d$wsg)) - nlevels(dm$wsg))
  d |> group_by(cls, .drop = FALSE) |>
    summarise(n_visits = n(), n_detect = sum(.data[[resp]]), .groups = "drop") |>
    mutate(response = label, raw_rate = ifelse(n_visits > 0, n_detect / n_visits, NA_real_),
           rate_ratio = unname(rate_ratio(m, dm)),
           rr_lo = apply(bw, 2, quantile, 0.025, na.rm = TRUE),
           rr_hi = apply(bw, 2, quantile, 0.975, na.rm = TRUE),
           n_boot_ok = colSums(!is.na(bw)),
           power = if_else(n_visits >= min_visits & n_detect >= min_detect, "ok", "underpowered"))
}

# ---- curves ------------------------------------------------------------------------
pop_sep <- pop |> filter(month %in% 9:10)
out <- list(
  curve(v, "U", NULL, "bt_caught", 331L),
  curve(pop, "S", c("log_coded", "month_f"), "spawner_given_bt_coded_augoct", 332L),
  curve(pop, "S_large", c("log_coded", "month_f"), "large_spawner_given_bt_coded_augoct", 333L),
  curve(pop, "S_small", c("log_coded", "month_f"), "small_spawner_given_bt_coded_augoct", 334L),
  curve(pop_sep, "S_sepoct", c("log_coded", "month_f"), "spawner_given_bt_coded_sepoct", 335L)
)
res <- bind_rows(out) |>
  mutate(class = as.character(cls),
         across(c(raw_rate, rate_ratio, rr_lo, rr_hi), ~ round(.x, 3))) |>
  select(response, class, n_visits, n_detect, raw_rate, rate_ratio, rr_lo, rr_hi, n_boot_ok, power)
write_csv(res, path_out, na = "")
block("evidence rates and rate ratios (also data/bt_spawn_evidence.csv)", res)

# ---- sensitivities (point estimates) -------------------------------------------------
sens <- tibble(class = classes)
add_sens <- function(name, d, extra = c("log_coded", "month_f"), nuis = c("data_set", "era", "wsg")) {
  dm <- modelled(d, "S")
  old <- nuisance; nuisance <<- nuis
  sens[[name]] <<- round(unname(rate_ratio(fit(dm, "S", extra), dm)), 3)
  nuisance <<- old
}
add_sens("base", pop)
top_agency <- names(sort(table(pop$agency[pop$S == 1L]), decreasing = TRUE))[1:2]
add_sens("without_top_two_agencies", pop |> filter(!agency %in% top_agency))
add_sens("august_only", pop |> filter(month == 8), "log_coded")
add_sens("no_river_polygons", pop |> filter(segment_edge_type %in% edge_stream))
add_sens("no_wsg_term", pop, nuis = c("data_set", "era"))
add_sens("wsg_term_only", pop, extra = NULL, nuis = "wsg")
add_sens("coding_and_month_only", pop, nuis = character(0))
add_sens("first_copy_only_35", pop |> filter(first_copy))
add_sens("site_gradient_class", pop |> filter(!is.na(gradient_pct)) |>
           mutate(cls = classify(gradient_pct / 100)))
block(sprintf("S rate ratios under each sensitivity, point estimates only (top two agencies by evidence visits removed: %s)",
              paste(top_agency, collapse = "; ")), sens)
block("raw S in the modelled S population (WSGs with both outcomes)",
      modelled(pop, "S") |> group_by(cls, .drop = FALSE) |>
        summarise(n_visits = n(), n_detect = sum(S), raw_rate = round(mean(S), 3), .groups = "drop"))
block("evidence visits by agency (top five)",
      pop |> filter(S == 1L) |> count(agency, sort = TRUE) |> head(5))

# ---- channel width, raw, by width source -----------------------------------------------
block("S raw rates by segment channel width class and width source",
      pop |> mutate(width = cut(segment_channel_width, c(-Inf, 2, 5, 10, Inf),
                                labels = c("<2", "2-5", "5-10", ">10"))) |>
        group_by(segment_cw_source, width) |>
        summarise(n_visits = n(), n_detect = sum(S), raw_rate = round(mean(S), 3),
                  .groups = "drop"))

block("spawner-evidence visits in narrow (< 2 m) and steep (> 5.49 %) segments, by size and kind",
      pop |> filter(S == 1L) |>
        mutate(narrow = !is.na(segment_channel_width) & segment_channel_width < 2,
               steep = segment_gradient > spawn_max,
               size = if_else(S_large == 1L, "large", "small"),
               month_kind = if_else(month == 8, "Aug", "Sep-Oct")) |>
        count(narrow, steep, size, month_kind))

# ---- large spawners on steep segments: upstream patches (descriptive) -----------------------
steep_large <- pop |> filter(S_large == 1L, segment_gradient > spawn_max)
say("")
say("Large-spawner visits on segments > %.4f: %d.", spawn_max, nrow(steep_large))
if (nrow(steep_large) > 0) {
  conn <- dbConnect(Postgres(), host = "localhost", port = 5432, dbname = "fwapg",
                    user = "postgres", password = "postgres")
  dbWriteTable(conn, "tmp_bt_spawn_steep", steep_large |>
                 transmute(site_visit, watershed_group_code, link_schema, id_segment),
               temporary = TRUE, overwrite = TRUE)
  patch <- bind_rows(lapply(unique(steep_large$link_schema), function(sch) {
    dbGetQuery(conn, sprintf("
      WITH v AS (
        SELECT t.site_visit, s.blue_line_key, s.downstream_route_measure, s.wscode_ltree,
               s.localcode_ltree, s.watershed_group_code
        FROM tmp_bt_spawn_steep t JOIN %1$s.streams s
          ON s.id_segment = t.id_segment AND s.watershed_group_code = t.watershed_group_code
        WHERE t.link_schema = '%1$s'),
      ok AS (
        SELECT v.site_visit, s.blue_line_key, s.downstream_route_measure AS drm,
               s.upstream_route_measure AS urm, s.length_metre
        FROM v JOIN %1$s.streams s ON s.watershed_group_code = v.watershed_group_code
        WHERE s.gradient <= %2$f AND s.edge_type IN (%3$s)
          AND coalesce(s.channel_width, 0) >= %4$f
          AND whse_basemapping.fwa_upstream(v.blue_line_key, v.downstream_route_measure,
                v.wscode_ltree, v.localcode_ltree, s.blue_line_key, s.downstream_route_measure,
                s.wscode_ltree, s.localcode_ltree, false, 1)),
      runs AS (
        SELECT site_visit, blue_line_key, drm, urm, length_metre,
               sum(CASE WHEN drm > prev_urm + 1 OR prev_urm IS NULL THEN 1 ELSE 0 END)
                 OVER (PARTITION BY site_visit, blue_line_key ORDER BY drm) AS run
        FROM (SELECT *, lag(urm) OVER (PARTITION BY site_visit, blue_line_key ORDER BY drm) AS prev_urm
              FROM ok) x)
      SELECT site_visit, blue_line_key, min(drm) AS run_drm, sum(length_metre) AS run_m
      FROM runs GROUP BY site_visit, blue_line_key, run
      HAVING sum(length_metre) >= %5$f",
      sch, spawn_max, paste(edge_stream, collapse = ","), patch_width_min, patch_min_m))
  }))
  dbDisconnect(conn)
  desc <- steep_large |>
    select(site_visit, watershed_group_code, cls, blue_line_key, downstream_route_measure,
           segment_gradient, first_copy) |>
    left_join(patch |> rename(patch_blk = blue_line_key), by = "site_visit", relationship = "many-to-many") |>
    group_by(site_visit, watershed_group_code, cls, segment_gradient, first_copy) |>
    summarise(patches_upstream = sum(!is.na(run_m)),
              same_blue_line_m = suppressWarnings(min(
                (run_drm - downstream_route_measure)[!is.na(patch_blk) & patch_blk == blue_line_key &
                                                       run_drm >= downstream_route_measure &
                                                       run_drm - downstream_route_measure <= search_km * 1000])),
              .groups = "drop") |>
    mutate(same_blue_line_m = ifelse(is.finite(same_blue_line_m), round(same_blue_line_m),
                                     NA_real_),
           censored = is.na(same_blue_line_m))
  block(sprintf(paste("large spawners on steep segments: patches upstream (>= %g m at <= %.4f,",
                      "width >= %g m, stream edges); same-blue-line distance within %g km,",
                      "NA = censored. Descriptive only."),
                patch_min_m, spawn_max, patch_width_min, search_km), desc)
}

# ---- FISS workbook spawner rows (reported, not modelled) -----------------------------------
fiss <- read_csv("data/fiss_evidence.csv", show_col_types = FALSE, col_types = cols(site_visit = "c")) |>
  filter(species_group == "char", size_class == "spawner_evidence")
block("FISS workbook char spawner-evidence rows (site gradient_pct is a fraction, #34; fwa_gradient_pct is percent)",
      fiss |> select(site_visit, species_code, n, watershed_group_code, month, year,
                     gradient_pct, fwa_gradient_pct, method))

parallel::stopCluster(cl)
writeLines(log_lines, path_log)
cat(log_lines, sep = "\n")
