# scripts/0291-bt-use-curve.R
# ---------------------------------------------------------------------------
# BT rearing use by gradient class, corrected for sampling effort, from the FDIS visits that
# scripts/0290 placed on link's segmentation. Issue #28.
#
# ANALYSIS SPEC, fixed before the first fit (plan review O1, planning/active/review-plan.md):
#   - POPULATION: visits on BT-accessible segments (access_bt 1 or 2, set in 0290), on stream
#     and canal edges or river polygons (edge_type 1000 1050 1100 1150 2000 2100 2300, 1250
#     1350; step 5 used the same), with a fished area of 10 to 10,000 m2 (declared trim:
#     smaller is a point, larger is a lake or river reach).
#   - CLASSES (link's ladder): core = rearing under link `default` (gradient <= 0.1049),
#     split 0-2, 2-5, 5-8, 8-10.49 %; `not rearing <= 10.49` = accessible, gradient within the
#     cutoff, but not rearing (no spawning connection); then 10.49-12.49, 12.49-13.49,
#     13.49-14.49 and > 14.49 %, the stream each looser cutoff could add.
#   - THREE RESPONSES, so that range and habitat are not read as one thing (review G1):
#       U  BT caught on the visit;
#       F  any fish caught (a fishless visit is above the fish limit, or the gear failed);
#       C  BT caught, among visits that caught any fish.
#   - MODEL: binomial, complementary log-log link, with log(area) as a covariate, plus data_set
#     (FDS / FDIS), era (to 1994, 1995-2004, 2005 on) and WSG. Under cloglog a class coefficient
#     multiplies the detection rate whatever the effort, as a per-km weight must not depend on
#     effort. WSGs where the response never or always occurs are left out (they inform no class
#     contrast and only diverge) and counted. A fit that does not converge in 100 iterations
#     gives no weight (NA), never a number.
#   - CHANGE 1, after the first fit and before any weight was read: the spec first had
#     offset(log(area)), i.e. detection proportional to area. The F and C fits did not converge
#     (coefficients to 1e14), the bootstrap gave intervals of 0 to Inf, and with log(area) free
#     its coefficient is 0.07 (F) to 0.19 (U, C), far from the 1 the offset imposed. Area is
#     now a covariate, and the WSG filter needs both outcomes.
#   - WEIGHT = exp(class coefficient) / reference, where the reference is the core classes'
#     exp(coefficient) averaged with their visit counts as weights. Core weights average 1.
#   - INTERVALS: 200 bootstrap resamples of streams (blue_line_key), because repeat visits to
#     one place are not independent (review G3). Seed fixed and resamples drawn before the
#     parallel fits, so a re-run reproduces the files on any number of workers.
#   - POWER: a class weight is reported as `ok` only with >= 30 visits and >= 10 detections of
#     the response; otherwise `underpowered`, and the weight is kept but not used downstream.
#   - ELEVATION earns a place in the weight only if adding the elevation third to U improves the
#     held-out log-likelihood by more than 2 (one per added parameter). Shape coefficients are
#     fitted on calibration WSGs and held fixed as an offset; held-out WSG intercepts are
#     re-estimated, because baselines differ about threefold (review G6).
#   - MONOTONICITY is not imposed here. Phase 4 decides what a candidate weight does with a
#     non-monotone estimate, and says so.
#   - Raw rates are reported beside every model; `n` columns count visits.
#   - SENSITIVITY (log only): logit link; fishing time as the effort covariate;
#     no river polygons; no non-pooled WSGs; channel width; MAD; measured site gradient;
#     score284 vs fresh_default segmentation on the four in-sample pilots; step-5 classes on the
#     held-out WSGs; month.
#
# INPUT:  data/fdis/derived/bt_use_visits.csv (scripts/0290), data/fdis_evidence.csv (0240)
# OUTPUT: data/bt_rear_use_curve.csv   aggregates only: role x response x class
#         scripts/logs/habitat/<date>_bt_use_curve.txt   hold-out, sensitivity, size checks
# RUN:    Rscript scripts/0291-bt-use-curve.R   (after 0290, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(tidyr) })

edge_ok <- c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350)
edge_river <- c(1250, 1350)
area_range <- c(10, 10000)
classes <- c("core 0-2", "core 2-5", "core 5-8", "core 8-10.49", "not rearing <=10.49",
             "10.49-12.49", "12.49-13.49", "13.49-14.49", ">14.49")
core <- classes[1:4]
n_boot <- 200
n_cores <- max(1L, min(6L, parallel::detectCores() - 2L))
min_visits <- 30
min_detect <- 10
path_out <- "data/bt_rear_use_curve.csv"
path_log <- file.path("scripts/logs/habitat",
                      paste0(format(Sys.Date(), "%Y%m%d"), "_bt_use_curve.txt"))

classify <- function(g, rearing) {
  factor(case_when(
    is.na(g) ~ NA_character_,
    rearing & g <= 0.02 ~ "core 0-2",
    rearing & g <= 0.05 ~ "core 2-5",
    rearing & g <= 0.08 ~ "core 5-8",
    rearing & g <= 0.1049 ~ "core 8-10.49",
    g <= 0.1049 ~ "not rearing <=10.49",
    g <= 0.1249 ~ "10.49-12.49",
    g <= 0.1349 ~ "12.49-13.49",
    g <= 0.1449 ~ "13.49-14.49",
    TRUE ~ ">14.49"), classes)
}

all_visits <- read_csv("data/fdis/derived/bt_use_visits.csv", show_col_types = FALSE,
                       col_types = cols(site_visit = "c"))
v0 <- all_visits |>
  filter(segment_edge_type %in% edge_ok) |>
  mutate(cls = classify(segment_gradient, coalesce(rearing, FALSE)),
         era = factor(cut(year, c(-Inf, 1994, 2004, Inf), labels = c("to1994", "1995-2004",
                                                                      "2005on"))),
         data_set = factor(data_set),
         wsg = factor(watershed_group_code),
         stream = factor(blue_line_key),
         elev_class = factor(elev_class, c("low", "mid", "high")),
         U = as.integer(bt_present),
         F = as.integer(catch_status == "fish"))
if (anyNA(v0$cls) || anyNA(v0$elev_class)) stop("visits without a class or an elevation class")
v <- v0 |> filter(!is.na(area_m2), area_m2 >= area_range[1], area_m2 <= area_range[2]) |>
  mutate(log_area = log(area_m2))

log_lines <- character()
say <- function(...) log_lines <<- c(log_lines, sprintf(...))
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title),
                  capture.output(print(as.data.frame(x), row.names = FALSE)))
}
say("BT rearing use curve, knowledge#28. Visits in 0290's table: %d.", nrow(all_visits))
say("On stream, canal or river-polygon edges: %d. With a fished area of %g-%g m2: %d (BT on %d).",
    nrow(v0), area_range[1], area_range[2], nrow(v), sum(v$U))

# ---- model ---------------------------------------------------------------------
nuisance <- c("data_set", "era", "wsg")
# a nuisance term with one level in the data at hand (a one-data-set subset) is dropped
form <- function(d, resp, extra = NULL, effort = "log_area") {
  keep <- nuisance[vapply(nuisance, function(t) length(unique(d[[t]])) > 1L, logical(1))]
  as.formula(paste(resp, "~", paste(c("cls", extra, effort, keep), collapse = " + ")))
}
modelled <- function(d, resp) {
  keep <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
  d <- d[d$wsg %in% names(keep)[keep %in% TRUE], ]
  d$wsg <- droplevels(d$wsg)
  d
}
fit <- function(d, resp, extra = NULL, link = "cloglog", effort = "log_area") {
  suppressWarnings(glm(form(d, resp, extra, effort), family = binomial(link = link), data = d,
                       control = glm.control(maxit = 100)))
}
# rate-ratio weight per class against the count-weighted core (see header)
class_weight <- function(m, d) {
  if (!m$converged) return(setNames(rep(NA_real_, length(classes)), classes))
  b <- coef(m)
  rr <- vapply(classes, function(k) {
    if (k == classes[1]) return(1)
    x <- b[paste0("cls", k)]
    if (is.na(x)) NA_real_ else exp(unname(x))
  }, numeric(1))
  n <- table(d$cls)[core]
  rr / (sum(rr[core] * n) / sum(n))
}
# resamples are drawn in order from the seed, then fitted on socket workers (forked workers
# segfault in glm.fit under macOS's Accelerate BLAS), so the result does not depend on the
# number of workers
cl <- parallel::makeCluster(n_cores)
invisible(parallel::clusterEvalQ(cl, suppressMessages(library(dplyr))))
boot <- function(d, resp, seed) {
  set.seed(seed)
  streams <- levels(droplevels(d$stream))
  idx <- split(seq_len(nrow(d)), droplevels(d$stream))
  picks <- lapply(seq_len(n_boot), function(i) sample(streams, length(streams), replace = TRUE))
  parallel::clusterExport(cl, c("d", "idx", "resp"), envir = environment())
  parallel::clusterExport(cl, c("modelled", "fit", "form", "class_weight", "classes", "core",
                                "nuisance"), envir = globalenv())
  w <- parallel::parLapply(cl, picks, function(pick) {
    bd <- modelled(d[unlist(idx[pick], use.names = FALSE), ], resp)
    w <- tryCatch(class_weight(fit(bd, resp), bd), error = function(e) rep(NA_real_, 9))
    w[!classes %in% unique(bd$cls)] <- NA_real_
    w
  })
  if (!all(vapply(w, function(x) is.numeric(x) && length(x) == length(classes), logical(1)))) {
    stop("a bootstrap worker failed")
  }
  do.call(rbind, w)
}
counts <- function(d, resp) {
  d |> group_by(cls, .drop = FALSE) |>
    summarise(n_visits = n(), n_detect = sum(.data[[resp]]), .groups = "drop") |>
    mutate(raw_rate = ifelse(n_visits > 0, n_detect / n_visits, NA_real_))
}

responses <- list(U = list(data = function(d) d, label = "bt_caught"),
                  F = list(data = function(d) d, label = "any_fish_caught"),
                  C = list(data = function(d) d[d$F == 1L, ], label = "bt_caught_given_fish"))
roles <- list(all = v, calibration = v[v$role == "calibration", ],
              held_out = v[v$role == "held_out", ])
out <- list()
seed <- 28L
for (r in names(roles)) for (resp in names(responses)) {
  d_resp <- responses[[resp]]$data(roles[[r]])
  y <- if (resp == "C") "U" else resp
  d <- modelled(d_resp, y)
  m <- fit(d, y)
  w <- class_weight(m, d)
  bw <- boot(d, y, seed <- seed + 1L)
  say("%s / %s: %d visits in %d WSGs modelled; %d visits in %d WSGs with one outcome only left out",
      r, responses[[resp]]$label, nrow(d), nlevels(d$wsg), nrow(d_resp) - nrow(d),
      length(unique(d_resp$wsg)) - nlevels(d$wsg))
  out[[paste(r, resp)]] <- counts(d_resp, y) |>
    mutate(role = r, response = responses[[resp]]$label, weight = unname(w),
           weight_lo = apply(bw, 2, quantile, 0.025, na.rm = TRUE),
           weight_hi = apply(bw, 2, quantile, 0.975, na.rm = TRUE),
           n_boot_ok = colSums(!is.na(bw)),
           power = if_else(n_visits >= min_visits & n_detect >= min_detect, "ok",
                           "underpowered"))
}
curve <- bind_rows(out) |>
  mutate(class = as.character(cls),
         across(c(raw_rate, weight, weight_lo, weight_hi), ~ round(.x, 3))) |>
  select(role, response, class, n_visits, n_detect, raw_rate, weight, weight_lo, weight_hi,
         n_boot_ok, power) |>
  arrange(factor(role, names(roles)),
          factor(response, vapply(responses, `[[`, "", "label")), factor(class, classes))
write_csv(curve, path_out, na = "")
block("weights (also data/bt_rear_use_curve.csv)", curve)

# ---- elevation: held-out test ---------------------------------------------------
cal <- modelled(roles$calibration, "U")
ho <- modelled(roles$held_out, "U")
heldout_ll <- function(extra) {
  m <- fit(cal, "U", extra)
  b <- coef(m)
  if (!m$converged) stop("calibration fit did not converge")
  shape <- grep("^(cls|elev_class|data_set|era|log_area)", names(b), value = TRUE)
  X <- model.matrix(as.formula(paste("~", paste(c("cls", extra, "log_area + data_set + era"),
                                                collapse = " + "))), ho)
  shape <- intersect(shape, colnames(X))
  off <- drop(X[, shape, drop = FALSE] %*% ifelse(is.na(b[shape]), 0, b[shape]))
  m_ho <- suppressWarnings(glm(U ~ 0 + wsg, offset = off, family = binomial(link = "cloglog"),
                               data = ho))
  as.numeric(logLik(m_ho))
}
ll0 <- heldout_ll(NULL)
ll1 <- heldout_ll("elev_class")
say("")
say("Elevation, held out (calibration shape, held-out intercepts): log-lik %.1f without, %.1f with; gain %.1f (needs > 2)",
    ll0, ll1, ll1 - ll0)
m_e <- fit(modelled(v, "U"), "U", "elev_class")
block("elevation-third rate ratios, U, all WSGs (low = 1)",
      tibble(term = c("mid", "high"),
             rate_ratio = round(exp(coef(m_e)[c("elev_classmid", "elev_classhigh")]), 3)))
block("class weights with the elevation third in the model, U, all WSGs",
      tibble(class = classes, weight = round(class_weight(m_e, modelled(v, "U")), 3)))
block("visits by class and elevation third (all)", as.data.frame.matrix(table(v$cls, v$elev_class)) |>
        tibble::rownames_to_column("class"))

# ---- sensitivity ---------------------------------------------------------------
dU <- modelled(v, "U")
base <- round(class_weight(fit(dU, "U"), dU), 3)
sens <- tibble(class = classes, base = base)
add_sens <- function(name, d, ...) {
  d <- modelled(d, "U")
  sens[[name]] <<- round(class_weight(fit(d, "U", ...), d), 3)
}
m_logit <- fit(dU, "U", link = "logit")
sens$logit_odds_ratio <- round(class_weight(m_logit, dU), 3)
add_sens("time_effort", v0 |> filter(fishing_time_s > 0) |>
           mutate(log_time = log(fishing_time_s)), effort = "log_time")
add_sens("no_river_polygons", v |> filter(!segment_edge_type %in% edge_river))
add_sens("pooled_wsgs_only", v |> filter(pooling == "BT+DV"))
add_sens("fds_only", v |> filter(data_set == "FDS"))
add_sens("fdis_only", v |> filter(data_set == "FDIS"))
dw <- v |> filter(!is.na(segment_channel_width), segment_channel_width > 0) |>
  mutate(log_width = log(segment_channel_width))
add_sens("width_subset", dw)
add_sens("width_subset_with_width", dw, "log_width")
dm <- v |> filter(!is.na(mad_m3s), mad_m3s > 0) |> mutate(log_mad = log(mad_m3s))
if (nrow(dm) > 0) {
  add_sens("mad_subset", dm)
  add_sens("mad_subset_with_mad", dm, "log_mad")
}
add_sens("with_month", v |> mutate(month_f = factor(month)), "month_f")
block("U weights under each sensitivity (columns); `base` is the reported model", sens)
block("null shares of channel-size variables (population)",
      v |> summarise(n = n(), segment_width_null = round(mean(is.na(segment_channel_width)), 3),
                     measured_width_null = round(mean(is.na(channel_width_m)), 3),
                     mad_null = round(mean(is.na(mad_m3s)), 3)))
mw <- fit(modelled(dw, "U"), "U", "log_width")
say("log(segment width) coefficient in U: %.3f (se %.3f)",
    coef(summary(mw))["log_width", 1], coef(summary(mw))["log_width", 2])

# measured site gradient
mg <- v |> filter(!is.na(gradient_pct)) |>
  mutate(site_cls = classify(gradient_pct / 100, coalesce(rearing, FALSE)))
block("visits by segment class (rows) and the class the measured site gradient gives (columns)",
      as.data.frame.matrix(table(mg$cls, mg$site_cls)) |> tibble::rownames_to_column("class"))
block("raw rates by measured-site class", mg |> group_by(site_cls, .drop = FALSE) |>
        summarise(n_visits = n(), bt = sum(U), fish = sum(F), .groups = "drop") |>
        mutate(bt_rate = round(bt / n_visits, 3), bt_given_fish = round(bt / fish, 3)))

# segmentation: the same visits on score284's segments (in-sample pilots)
sg <- v |> filter(!is.na(segment_gradient_score284)) |>
  mutate(cls_score284 = classify(segment_gradient_score284, coalesce(rearing_score284, FALSE)))
say("")
say("Segmentation (in-sample pilots, %d visits): class agrees on %.1f %%", nrow(sg),
    100 * mean(sg$cls == sg$cls_score284))
block("class on fresh_default (rows) vs score284_default (columns), in-sample pilots",
      as.data.frame.matrix(table(sg$cls, sg$cls_score284)) |> tibble::rownames_to_column("class"))

# step-5 classes on the held-out WSGs, to set beside link's taper.csv
block("held-out raw rates by link#284 step-5 class",
      v |> filter(role == "held_out") |> group_by(step5_class) |>
        summarise(n_visits = n(), bt = sum(U), fish = sum(F), .groups = "drop") |>
        mutate(bt_rate = round(bt / n_visits, 3), bt_given_fish = round(bt / fish, 3)))

# elevation on core rearing, by role: per-visit rates, to set beside step 5's per-km taper
block("core rearing visits by role and elevation third (raw)",
      v |> filter(grepl("^core", cls)) |> group_by(role, elev_class) |>
        summarise(n_visits = n(), bt_rate = round(mean(U), 3), fish_rate = round(mean(F), 3),
                  .groups = "drop"))

# access code mix by class. CIRCULAR: code 2 is built largely from these visits' own BT catches,
# so these tables are not evidence about where BT live; never a covariate.
block("raw BT rate by access code, steep (> 10.49 %) vs not [circular: code 2 is built from these catches]",
      v |> mutate(steep = segment_gradient > 0.1049) |> group_by(steep, access_bt) |>
        summarise(n_visits = n(), bt_rate = round(mean(U), 3), .groups = "drop"))
block("share of visits on access_bt = 2 (BT observed upstream), by class [circular]",
      v |> group_by(cls) |> summarise(n_visits = n(), share_code2 = round(mean(access_bt == 2), 3),
                                      bt_rate_code1 = round(mean(U[access_bt == 1]), 3),
                                      bt_rate_code2 = round(mean(U[access_bt == 2]), 3)))

# ---- size classes: are steep-water BT juveniles? ---------------------------------
bt_dv_codes <- c("BT", "DV", "BT/DV", "DV/BT", "DVxBT")
ev <- read_csv("data/fdis_evidence.csv", show_col_types = FALSE,
               col_types = cols(site_visit = "c")) |>
  inner_join(v |> filter(U == 1L) |> select(site_visit, cls, pooling), by = "site_visit") |>
  filter(species_code == "BT" | (pooling == "BT+DV" & species_code %in% bt_dv_codes))
size <- ev |> filter(size_class %in% c("fry", "juvenile", "subadult", "adult")) |>
  group_by(cls, size_class) |> summarise(fish = sum(n), .groups = "drop") |>
  pivot_wider(names_from = size_class, values_from = fish, values_fill = 0) |>
  mutate(measured = fry + juvenile + subadult + adult,
         share_fry_juvenile = round((fry + juvenile) / measured, 3))
vis <- ev |> group_by(cls, site_visit) |>
  summarise(young = any(size_class %in% c("fry", "juvenile")),
            measured = any(size_class %in% c("fry", "juvenile", "subadult", "adult")),
            spawner = any(size_class == "spawner_evidence"), .groups = "drop") |>
  group_by(cls) |>
  summarise(visits_with_bt = n(), visits_measured = sum(measured),
            share_with_fry_or_juvenile = round(sum(young & measured) / sum(measured), 3),
            visits_spawner_evidence = sum(spawner), .groups = "drop")
block("measured BT by size class and class (fish)", size)
block("BT visits with fry or juveniles, by class", vis)

parallel::stopCluster(cl)
writeLines(log_lines, path_log)
cat(log_lines, sep = "\n")
