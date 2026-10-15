# scripts/0295-ch-mad-use.R
# ---------------------------------------------------------------------------
# CH detection by stream size (wet's MAD) on FDIS electrofishing visits, corrected for effort,
# and on small streams by network distance to a large river. Issue #52. Input from 0294.
#
# ANALYSIS SPEC, fixed before the first fit and revised once, before any fit, after the plan
# review (planning archive for #52, review-plan.md). The reviewer had tabulated detections by
# class from the raw export before this spec was final; that table is what B1 and A6 cite.
#   - POPULATION: 0294's visits (link's CH range rule, quality drops), duplicates (#35) left out,
#     on stream, canal and river-polygon edges (0291's set; lake construction lines are not in
#     it), with a fished area of 10 to 10,000 m2. Raw rates are reported on the same visits the
#     model uses (WSGs with both outcomes), and on all population visits beside them.
#   - MAD CLASSES (m3/s, [lo, hi)): <0.1, 0.1-0.28, 0.28-0.5, 0.5-1, 1-3, 3-10, 10-30, 30-100,
#     >=100. These are literature and model breaks (link's CH rear_mad_min 0.28 and rear_mad_max
#     100, Woll 2015's 0.5, #52's 0.5 and 10), not breaks chosen from the data as #52 suggested,
#     so no break follows a look at the detections. wet's two sources agree on the class less
#     often between 0.1 and 1 m3/s than above it (logged); a merged 0.1-0.5 class is a sensitivity.
#     Juvenile EF data cannot test spawning bounds, so link's spawn_mad_min is not compared.
#   - RESPONSES (as 0291): U = CH caught; F = any fish caught; C = CH caught among visits that
#     caught any fish. Half the visits are under 0.1 m3/s, where FDS surveys look for the upper
#     fish limit, so U alone would read fishless headwaters as CH avoiding small streams.
#   - MODEL: binomial, cloglog link, class + log(area) + data_set + era (to 1994, 1995-2004,
#     2005 on) + WSG. WSGs where the response never or always occurs are left out and counted.
#     A fit that does not converge in 100 iterations gives NA.
#   - RELATIVE RATE per MAD class = exp(class coefficient) divided by the visit-weighted mean of
#     all classes' exp(coefficient): 1 is the average class after effort, data set, era and WSG.
#     For DISTANCE it is the rate ratio against > 500 m. CHANGE 1, after the first run and before
#     any result was written up: distance was first normalised like MAD, and the small `none`
#     class (11 detections) blew up in some resamples and dragged the other classes' lower bounds
#     to 0; a fixed reference has no such dependence.
#   - INTERVALS: 200 bootstrap resamples of streams (blue_line_key), seed fixed and resamples
#     drawn before the parallel fits. One stream (the Nechako, one 2010 survey) holds about a third
#     of all detections, so each class also reports the share of its detections from its largest
#     project (data set, agency, year, stream) and its share of visits on regulated reaches.
#   - POWER: `ok` at >= 30 visits and >= 10 detections in the class, else `underpowered`.
#   - DISTANCE, visits with picked MAD < 0.5, not on a side channel and not ambiguously placed
#     (0294): to the first primary-flow segment with picked MAD >= 10, classes <= 500 m, > 500 m,
#     and `none`. A walk that ended other than found or none is left out and counted.
#   - SENSITIVITY (rows in the csv without intervals; U unless named):
#       regulated reaches out; the largest project out; CHES and NECR out; the parent-flow visits
#       out; each wet source alone where both exist; the old fwapg MAD; duplicates kept; no river
#       polygons; FWA gradient class as a covariate; season as a covariate; merged 0.1-0.5;
#       a natural CH barrier downstream out (fresh_default WSGs, against the same WSGs
#       unfiltered; with and without USER_DEFINITE); distance with ambiguous placements kept,
#       with lake targets out, and with an entry gap over 200 m out.
#   - CROSS-CHECK: picked MAD class of bcfishobs CH records that are not FDIS (presence only,
#     every method and life stage), against the class mix of FDIS visits that caught CH.
#
# INPUT:  data/fdis/derived/ch_mad_visits.csv (scripts/0294); local fwapg :5432 (cross-check)
# OUTPUT: data/ch_mad_use.csv   aggregates only: analysis x response x class
#         scripts/logs/habitat/<date>_ch_mad_use.txt
# RUN:    Rscript scripts/0295-ch-mad-use.R   (after 0294, from the repo root; ~5 min)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })

edge_ok <- c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350)
edge_river <- c(1250, 1350)
area_range <- c(10, 10000)
mad_breaks <- c(0, 0.1, 0.28, 0.5, 1, 3, 10, 30, 100, Inf)
mad_labels <- c("<0.1", "0.1-0.28", "0.28-0.5", "0.5-1", "1-3", "3-10", "10-30", "30-100", ">=100")
small_max <- 0.5
dist_labels <- c(">500 m", "<=500 m", "none")   # the first is the reference
entry_gap_max <- 200
n_boot <- 200
n_cores <- max(1L, min(6L, parallel::detectCores() - 2L))
min_visits <- 30
min_detect <- 10
wsg_min_detect <- 20
path_out <- "data/ch_mad_use.csv"
path_log <- file.path("scripts/logs/habitat",
                      paste0(format(Sys.Date(), "%Y%m%d"), "_ch_mad_use.txt"))

mad_class <- function(q, breaks = mad_breaks, labels = mad_labels) {
  factor(as.character(cut(q, breaks, labels, right = FALSE)), labels)
}
dist_class <- function(status, d) {
  factor(case_when(status == "none" ~ "none",
                   status != "found" ~ NA_character_,
                   d <= 500 ~ "<=500 m",
                   TRUE ~ ">500 m"), dist_labels)
}

all_visits <- read_csv("data/fdis/derived/ch_mad_visits.csv", show_col_types = FALSE,
                       col_types = cols(site_visit = "c", dup_of = "c"))
prep <- function(d) {
  d |>
    filter(edge_type %in% edge_ok, !is.na(area_m2), area_m2 >= area_range[1],
           area_m2 <= area_range[2]) |>
    mutate(log_area = log(area_m2),
           era = factor(cut(year, c(-Inf, 1994, 2004, Inf),
                            labels = c("to1994", "1995-2004", "2005on"))),
           season = factor(case_when(month %in% 4:6 ~ "Apr-Jun", month %in% 7:8 ~ "Jul-Aug",
                                     month %in% 9:11 ~ "Sep-Nov", TRUE ~ "Dec-Mar")),
           grad_class = factor(cut(fwa_gradient, c(-Inf, 0.02, 0.05, 0.1, Inf),
                                   c("0-2", "2-5", "5-10", ">10"))),
           data_set = factor(data_set),
           wsg = factor(watershed_group_code),
           stream = factor(blue_line_key),
           project = paste(data_set, agency, year, blue_line_key, sep = "|"),
           U = as.integer(present_CH),
           F = as.integer(catch_status == "fish"))
}
v_dup <- prep(all_visits)
v <- v_dup |> filter(is.na(dup_of))
if (any(v$U == 1L & v$F == 0L)) stop("a visit caught CH but no fish")

log_lines <- character()
say <- function(...) log_lines <<- c(log_lines, sprintf(...))
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title),
                  capture.output(print(as.data.frame(x), row.names = FALSE)))
}
say("CH detection by stream size, knowledge#52. Visits in 0294's table: %d (CH on %d).",
    nrow(all_visits), sum(all_visits$present_CH))
say("On 0291's edges with a fished area of %g-%g m2: %d; duplicates left out: %d; analysed: %d (CH on %d) in %d WSGs.",
    area_range[1], area_range[2], nrow(v_dup), nrow(v_dup) - nrow(v), nrow(v), sum(v$U),
    length(unique(v$wsg)))
say("Of these, in a lake polygon: %d (CH %d); in a river polygon: %d (CH %d); flow from the parent line: %d (CH %d); regulated: %d (CH %d).",
    sum(v$in_lake), sum(v$U[v$in_lake]), sum(v$in_river_poly), sum(v$U[v$in_river_poly]),
    sum(v$flow_from == "parent"), sum(v$U[v$flow_from == "parent"]),
    sum(v$regulated), sum(v$U[v$regulated]))

# ---- model ---------------------------------------------------------------------
nuisance <- c("data_set", "era", "wsg")
form <- function(d, resp, extra) {
  keep <- nuisance[vapply(nuisance, function(t) length(unique(d[[t]])) > 1L, logical(1))]
  extra <- extra[vapply(extra, function(t) length(unique(d[[t]])) > 1L, logical(1))]
  as.formula(paste(resp, "~", paste(c("cls", "log_area", extra, keep), collapse = " + ")))
}
modelled <- function(d, resp) {
  keep <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
  d <- d[d$wsg %in% names(keep)[keep %in% TRUE], ]
  d$wsg <- droplevels(d$wsg)
  d
}
fit <- function(d, resp, extra) {
  suppressWarnings(glm(form(d, resp, extra), family = binomial(link = "cloglog"), data = d,
                       control = glm.control(maxit = 100)))
}
# relative rate per class against the visit-weighted mean of all classes (see header);
# `d$cls` has had its empty levels dropped, so the first level is the glm reference
rel_rate <- function(m, d, norm = TRUE) {
  lv <- levels(d$cls)
  if (!m$converged) return(setNames(rep(NA_real_, length(lv)), lv))
  b <- coef(m)
  rr <- vapply(lv, function(k) {
    if (k == lv[1]) return(1)
    x <- b[paste0("cls", k)]
    if (is.na(x)) NA_real_ else exp(unname(x))
  }, numeric(1))
  if (!norm) return(rr)
  n <- as.numeric(table(d$cls)[lv])
  ok <- !is.na(rr)
  rr / (sum(rr[ok] * n[ok]) / sum(n[ok]))
}
point <- function(d, resp, extra, norm) {
  lv <- levels(d$cls)
  dm <- modelled(d, resp)                # keeps every class level, for the bootstrap
  df <- dm
  df$cls <- droplevels(df$cls)
  r <- rel_rate(fit(df, resp, extra), df, norm)
  list(dm = dm, rr = setNames(unname(r[lv]), lv))
}

# resamples are drawn in order from the seed, then fitted on socket workers (forked workers
# segfault in glm.fit under macOS's Accelerate BLAS)
cl <- parallel::makeCluster(n_cores)
boot <- function(d, resp, extra, norm, seed) {
  lv <- levels(d$cls)
  set.seed(seed)
  streams <- levels(droplevels(d$stream))
  idx <- split(seq_len(nrow(d)), droplevels(d$stream))
  picks <- lapply(seq_len(n_boot), function(i) sample(streams, length(streams), replace = TRUE))
  parallel::clusterExport(cl, c("d", "idx", "lv", "resp", "extra", "norm"), envir = environment())
  parallel::clusterExport(cl, c("modelled", "fit", "form", "rel_rate", "nuisance"),
                          envir = globalenv())
  w <- parallel::parLapply(cl, picks, function(pick) {
    bd <- modelled(d[unlist(idx[pick], use.names = FALSE), ], resp)
    bd$cls <- droplevels(bd$cls)
    r <- tryCatch(rel_rate(fit(bd, resp, extra), bd, norm),
                  error = function(e) setNames(rep(NA_real_, length(lv)), lv))
    unname(r[lv])
  })
  if (!all(vapply(w, function(x) is.numeric(x) && length(x) == length(lv), logical(1)))) {
    stop("a bootstrap worker failed")
  }
  do.call(rbind, w)
}

describe <- function(d, resp, prefix) {
  d |> group_by(cls, .drop = FALSE) |>
    summarise(n_visits = n(), n_detect = sum(.data[[resp]]),
              top_project_share = if (n_detect > 0) {
                max(tapply(.data[[resp]], project, sum)) / n_detect } else NA_real_,
              regulated_share = if (n() > 0) mean(regulated) else NA_real_,
              .groups = "drop") |>
    mutate(raw_rate = ifelse(n_visits > 0, n_detect / n_visits, NA_real_)) |>
    rename_with(~ paste0(prefix, .x), -cls)
}

analyse <- function(name, d, resp = "U", extra = character(), seed = NULL, norm = TRUE) {
  if (resp == "C") { d <- d[d$F == 1L, ]; y <- "U" } else y <- resp
  p <- point(d, y, extra, norm)
  out <- describe(p$dm, y, "") |>
    left_join(describe(d, y, "all_") |> select(cls, all_n_visits, all_n_detect, all_raw_rate), by = "cls") |>
    mutate(analysis = name, response = c(U = "ch_caught", F = "any_fish", C = "ch_given_fish")[[resp]],
           rel_rate = unname(p$rr[as.character(cls)]),
           power = if_else(n_visits >= min_visits & n_detect >= min_detect, "ok", "underpowered"))
  if (!is.null(seed)) {
    bw <- boot(p$dm, y, extra, norm, seed)
    lv <- levels(d$cls)
    q <- function(pr) setNames(apply(bw, 2, quantile, pr, na.rm = TRUE), lv)
    lo <- q(0.025); hi <- q(0.975); ok <- setNames(colSums(!is.na(bw)), lv)
    out <- out |> mutate(rel_lo = unname(lo[as.character(cls)]), rel_hi = unname(hi[as.character(cls)]),
                         n_boot_ok = unname(ok[as.character(cls)]))
  }
  say("%s / %s: %d visits (%d detections) in %d WSGs modelled; %d visits in %d WSGs with one outcome only left out",
      name, out$response[1], nrow(p$dm), sum(p$dm[[y]]), nlevels(p$dm$wsg), nrow(d) - nrow(p$dm),
      length(unique(d$wsg)) - nlevels(p$dm$wsg))
  out
}
with_cls <- function(d, cls) { d$cls <- cls; d[!is.na(d$cls), ] }

res <- list()
d_mad <- with_cls(v, mad_class(v$mad_pick))
seed <- 52L
for (r in c("U", "F", "C")) res[[paste0("mad_", r)]] <- analyse("mad_pick", d_mad, r, seed = (seed <- seed + 1L))

small <- v |> filter(mad_pick < small_max)
say("")
say("Small streams (picked MAD < %g): %d visits (CH %d). Side channels: %d (CH %d). Ambiguous placement: %d (CH %d).",
    small_max, nrow(small), sum(small$U), sum(small$side_channel), sum(small$U[small$side_channel]),
    sum(small$ambiguous %in% TRUE), sum(small$U[small$ambiguous %in% TRUE]))
block("small streams: walk status", count(small, walk_status))
d_dist_all <- with_cls(small |> filter(!side_channel), dist_class(small$walk_status[!small$side_channel],
                                                                   small$dist_large_m[!small$side_channel]))
d_dist <- d_dist_all |> filter(!ambiguous %in% TRUE)
res$dist <- analyse("distance_small", d_dist, seed = (seed <- seed + 1L), norm = FALSE)
res$dist_amb <- analyse("sens_distance_ambiguous_kept", d_dist_all, norm = FALSE)
res$dist_nolake <- analyse("sens_distance_lake_targets_out", d_dist |> filter(!large_is_lake), norm = FALSE)
res$dist_gap <- analyse("sens_distance_entry_gap_out",
                        d_dist |> filter(is.na(walk_entry_gap_m) | walk_entry_gap_m <= entry_gap_max),
                        norm = FALSE)
sc <- small |> filter(side_channel)
block("small-stream side channels (raw)", tibble(n_visits = nrow(sc), n_ch = sum(sc$U),
                                                 raw_rate = round(mean(sc$U), 3)))

# ---- per-WSG raw rates ------------------------------------------------------------
big <- d_mad |> group_by(wsg) |> summarise(det = sum(U)) |> filter(det >= wsg_min_detect)
per_wsg <- d_mad |> filter(wsg %in% big$wsg) |>
  group_by(watershed_group_code, cls, .drop = FALSE) |>
  summarise(n_visits = n(), n_detect = sum(U), .groups = "drop") |>
  filter(n_visits > 0)
block(sprintf("raw CH detections / visits by MAD class, WSGs with >= %d CH detections", wsg_min_detect),
      tidyr::pivot_wider(per_wsg |> mutate(x = sprintf("%d/%d", n_detect, n_visits)) |>
                           select(watershed_group_code, cls, x),
                         names_from = cls, values_from = x, values_fill = ""))

# ---- sensitivity ---------------------------------------------------------------
both <- v |> filter(!is.na(mad_routed), !is.na(mad_balance))
cr <- mad_class(both$mad_routed); cb <- mad_class(both$mad_balance)
say("")
say("Both sources on %d visits: class differs on %d (%.1f %%), by more than one class on %d (%.1f %%).",
    nrow(both), sum(cr != cb), 100 * mean(cr != cb),
    sum(abs(as.integer(cr) - as.integer(cb)) > 1), 100 * mean(abs(as.integer(cr) - as.integer(cb)) > 1))
block("source agreement on the class, by the picked class",
      tibble(cls = mad_class(both$mad_pick), agree = cr == cb) |> filter(!is.na(cls)) |>
        group_by(cls, .drop = FALSE) |> summarise(n = n(), agree = round(mean(agree), 3), .groups = "drop"))
block("picked source of analysed visits", count(v, pick_source))

top_project <- d_mad |> filter(U == 1L) |> count(project, sort = TRUE) |> slice(1)
say("Largest project by CH detections: %s (%d of %d).", top_project$project, top_project$n, sum(d_mad$U))
res$reg <- analyse("sens_regulated_out", d_mad |> filter(!regulated))
res$topproj <- analyse("sens_largest_project_out", d_mad |> filter(project != top_project$project))
res$noches <- analyse("sens_ches_necr_out", d_mad |> filter(!watershed_group_code %in% c("CHES", "NECR")))
res$own <- analyse("sens_parent_flow_out", d_mad |> filter(flow_from == "own"))
res$routed <- analyse("sens_pcic_routed_where_both", with_cls(both, cr))
res$balance <- analyse("sens_wet_balance_where_both", with_cls(both, cb))
old <- v |> filter(!is.na(mad_fwapg))
res$old <- analyse("sens_fwapg_old_mad", with_cls(old, mad_class(old$mad_fwapg)))
res$dup <- analyse("sens_duplicates_kept", with_cls(v_dup, mad_class(v_dup$mad_pick)))
res$noriver <- analyse("sens_no_river_polygons", d_mad |> filter(!edge_type %in% edge_river, !in_river_poly))
res$grad <- analyse("sens_gradient_covariate", d_mad |> filter(!is.na(grad_class)), extra = "grad_class")
res$season <- analyse("sens_season_covariate", d_mad, extra = "season")
merged_b <- c(0, 0.1, 0.5, 1, 3, 10, 30, 100, Inf)
merged_l <- c("<0.1", "0.1-0.5", "0.5-1", "1-3", "3-10", "10-30", "30-100", ">=100")
res$merged <- analyse("sens_merged_0.1-0.5", with_cls(v, mad_class(v$mad_pick, merged_b, merged_l)))
covd <- d_mad |> filter(access_covered)
res$cov <- analyse("sens_access_wsgs_unfiltered", covd)
res$acc <- analyse("sens_access_no_natural_barrier", covd |> filter(!ch_barrier_dnstr %in% TRUE))
res$acc_nu <- analyse("sens_access_no_natural_barrier_no_user_definite",
                      covd |> filter(!ch_barrier_dnstr_no_user %in% TRUE))
say("Natural CH barrier downstream: %d of %d visits in fresh_default WSGs; CH caught on %d of them.",
    sum(covd$ch_barrier_dnstr %in% TRUE), nrow(covd), sum(covd$U[covd$ch_barrier_dnstr %in% TRUE]))
parallel::stopCluster(cl)

# ---- cross-check: bcfishobs CH records that are not FDIS --------------------------
conn <- dbConnect(Postgres(), host = "localhost", port = 5432, dbname = "fwapg",
                  user = "postgres", password = "postgres", bigint = "numeric")
obs <- dbGetQuery(conn, "
  SELECT o.observation_key, o.life_stage, o.source, q.q_m3s
  FROM bcfishobs.observations o
  LEFT JOIN discharge.fwa_v1_segment_monthly q
    ON q.linear_feature_id = o.linear_feature_id AND q.scenario = 'historical'
   AND q.month = 0 AND q.pick
  WHERE o.species_code = 'CH'")
dbDisconnect(conn)
obs_nf <- obs |> filter(!grepl("^FDIS", coalesce(source, "")))
say("")
say("bcfishobs CH records: %d; not FDIS: %d; of those with picked flow: %d.",
    nrow(obs), nrow(obs_nf), sum(!is.na(obs_nf$q_m3s)))
block("bcfishobs non-FDIS CH records by life stage", count(obs_nf, life_stage, sort = TRUE) |> head(10))
xc <- bind_rows(
  tibble(source = "bcfishobs_non_fdis", cls = mad_class(obs_nf$q_m3s[!is.na(obs_nf$q_m3s)])),
  tibble(source = "fdis_ch_visits", cls = d_mad$cls[d_mad$U == 1L])) |>
  count(source, cls, .drop = FALSE) |>
  group_by(source) |> mutate(share = round(n / sum(n), 3)) |> ungroup()
block("class mix of CH presence: non-FDIS bcfishobs records vs FDIS visits that caught CH",
      tidyr::pivot_wider(xc |> select(-n), names_from = source, values_from = share))
res$xc <- xc |> transmute(analysis = paste0("presence_mix_", source), response = "presence",
                          cls, n_visits = n, raw_rate = share)

# ---- write ----------------------------------------------------------------------
use <- bind_rows(res) |>
  mutate(class = as.character(cls),
         across(any_of(c("raw_rate", "all_raw_rate", "rel_rate", "rel_lo", "rel_hi",
                         "top_project_share", "regulated_share")), ~ round(.x, 3))) |>
  select(analysis, response, class, n_visits, n_detect, raw_rate, rel_rate,
         any_of(c("rel_lo", "rel_hi", "n_boot_ok")), power, top_project_share, regulated_share,
         all_n_visits, all_n_detect, all_raw_rate)
write_csv(use, path_out, na = "")
block("all analyses (also data/ch_mad_use.csv)", use |> select(analysis, response, class, n_visits, n_detect,
                                                              raw_rate, rel_rate, any_of(c("rel_lo", "rel_hi")),
                                                              power, top_project_share, regulated_share))
writeLines(log_lines, path_log)
cat(log_lines, sep = "\n")
