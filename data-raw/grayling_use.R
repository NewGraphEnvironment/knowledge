# data-raw/grayling_use.R
# ---------------------------------------------------------------------------
# Where Arctic grayling were caught: FDIS electrofishing visits by gradient, channel width and MAD class, corrected
# for sampling effort, with intervals. Issue #140, the capture half of the evidence for grayling's baseline in link's
# `default` (the literature half is data/literature_evidence.csv's GR rows; the proposal is #280). The spec was fixed
# before any fit (planning archive of #140, findings.md, "Phase 5 analysis spec"); it follows scripts/0291's model.
#
# POPULATION: the tuning's own for grayling rearing (knw_tune_run(): .tune_base() and .tune_population() with its
#   defaults): visits on the stream branch (the visit's edge type 1000, 1100, 2000 or 2300, not in a river polygon,
#   a wetland or a lake), with a fished area of 10 to 10,000 m2, in GR's range, not blocked, and with no natural
#   barrier to GR downstream. The funnel from the range to that population is logged.
# CLASSES, each its own table, on the tuning's columns: gradient `segment_gradient` (upper-inclusive classes, as
#   link's `<=` limit), channel width `cw_deploy` and MAD `mad_pick` (lower-inclusive, as link's `>=` floors); a
#   visit with no width is its own class.
# RESPONSES: U, GR caught; F, any fish caught; C, GR caught among visits that caught any fish.
# MODEL: binomial, complementary log-log link, y ~ class + log(area) + data_set + era + wsg; a nuisance term with one
#   level is dropped, and groups where the response never or always occurs are left out and counted. Under cloglog a
#   class coefficient multiplies the detection rate whatever the effort. The rate ratio is exp(coefficient) against
#   the reference class. A fit that does not converge in 100 iterations gives NA. Raw rates beside every model.
#   A class with no detection, or detections on every visit, is separated and carries no ratio.
# INTERVALS: 200 bootstrap resamples of streams (blue_line_key), seed 140, drawn in order before the socket-cluster
#   fits, so the output does not depend on the number of workers.
# POWER: `ok` with >= 30 visits and >= 10 detections of the response in the class, else `underpowered`. A response
#   with fewer than 4 groups holding both outcomes is not modelled.
# SPAWNING: summer electrofishing seldom samples spring spawning, so the log gives the months the population was
#   fished in and GR length by month (data/fdis/build/fish.rds), in 10 mm bins; no spawning table is fitted.
# SENSITIVITY (log only): logit link; river-polygon visits kept.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (scripts/0310), held to the md5s
#         data/thresholds.csv names; data/fdis/build/fish.rds, held to the run ledger's md5_fish. No database.
# OUTPUT: data/gr_use.csv   variable x response x class: visits, detections, raw rate, rate ratio and its interval
#         scripts/logs/habitat/<yyyymmdd>_grayling_use.txt   funnel, evidence md5s, commit, groups, sensitivity, lengths
# RUN:    Rscript data-raw/grayling_use.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)

dir_ev <- "data/fdis/derived"
f_ev <- file.path(dir_ev, c("visits_link.csv", "visits_species.csv", "walks.csv"))
f_fish <- "data/fdis/build/fish.rds"
path_out <- "data/gr_use.csv"
path_log <- .knw_free_path(file.path("scripts/logs/habitat",
                                     paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_grayling_use.txt")))
n_boot <- 200L
seed <- 140L
min_visits <- 30L
min_detect <- 10L
min_groups <- 4L
n_cores <- max(1L, min(8L, parallel::detectCores() - 2L))

log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

# ---- inputs, held to the published build ----------------------------------------------------------------------
pub <- unique(na.omit(read_csv("data/thresholds.csv", show_col_types = FALSE, col_types = cols(.default = "c"))$evidence_md5))
md5_here <- paste(unname(tools::md5sum(f_ev)), collapse = ";")
if (length(pub) != 1L || !identical(md5_here, pub)) {
  stop("the evidence in ", dir_ev, " (", md5_here, ") is not the build data/thresholds.csv names (",
       paste(pub, collapse = ", "), "): restore it with PULL=TRUE scripts/0336-archive.R", call. = FALSE)
}
ledger <- read_csv(knw_run_ledger("data/tune"), show_col_types = FALSE, col_types = cols(.default = "c"))
md5_fish_pub <- ledger$note[ledger$step == "md5_fish"]
md5_fish <- unname(tools::md5sum(f_fish))
if (length(md5_fish_pub) != 1L || !identical(md5_fish, md5_fish_pub)) {
  stop(f_fish, " (", md5_fish, ") is not the run ledger's md5_fish (", paste(md5_fish_pub, collapse = ", "), ")",
       call. = FALSE)
}
git_out <- function(args) {
  out <- suppressWarnings(system2("git", args, stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(args, collapse = " "), " failed", call. = FALSE)
  out
}
head_sha <- substr(git_out(c("rev-parse", "HEAD")), 1, 7)
dirty <- git_out(c("status", "--porcelain", "--untracked-files=no", "--", "data-raw/grayling_use.R", "R", "data/thresholds.csv"))
if (length(dirty)) head_sha <- paste0(head_sha, " with uncommitted changes to ", paste(trimws(dirty), collapse = ", "))

vl <- read_csv(f_ev[1], show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv(f_ev[2], show_col_types = FALSE, col_types = cols(site_visit = "c"))
say("Where grayling were caught, knowledge#140, knowledge %s. Evidence %s (md5 %s), fish.rds md5 %s.",
    head_sha, dir_ev, paste(substr(strsplit(md5_here, ";")[[1]], 1, 8), collapse = " "), substr(md5_fish, 1, 8))

# ---- population: the tuning's for GR rearing ------------------------------------------------------------------
edge_stream <- eval(formals(knw_tune_run)$edge_stream)
area_range <- eval(formals(knw_tune_run)$area_range)
gr <- vs[vs$species_code == "GR", ]
in_range <- vl$site_visit[vl$site_visit %in% gr$site_visit[gr$in_range %in% TRUE & gr$status != "blocked"]]
pop <- .tune_population(.tune_base(vl, edge_stream, area_range), vs, "GR", "rear")
d0 <- as_tibble(pop$d) |> mutate(F = as.integer(catch_status == "fish"))
dr <- inner_join(vl[vl$site_visit %in% in_range, ], gr[, c("site_visit", "present")], by = "site_visit")
k <- list(dr$edge_type %in% edge_stream, !(dr$wb_river %in% TRUE),
          !(dr$wb_wetland %in% TRUE) & !(dr$wb_lake %in% TRUE),
          !is.na(dr$area_m2) & dr$area_m2 >= area_range[1] & dr$area_m2 <= area_range[2],
          dr$barrier_dnstr_gr %in% FALSE)
keep <- Reduce(`&`, k, accumulate = TRUE)
funnel <- tibble(
  step = c("in GR's range, not blocked", "+ on a stream-branch edge type", "+ not in a river polygon",
           "+ not in a wetland or lake", "+ fished area 10-10,000 m2", "+ no natural barrier to GR downstream"),
  visits = c(nrow(dr), vapply(keep, sum, 0L)),
  gr_caught = c(sum(dr$present), vapply(keep, function(x) sum(x & dr$present), 0L)),
  groups = c(n_distinct(dr$watershed_group_code), vapply(keep, function(x) n_distinct(dr$watershed_group_code[x]), 0L)))
if (funnel$visits[6] != nrow(d0) || funnel$gr_caught[6] != sum(d0$U)) stop("the funnel does not end at the population")
block("Population funnel", funnel)
block("Visits in GR's range by FWA edge type, and those that caught GR",
      dr |> count(edge_type, name = "visits") |> left_join(dr |> filter(present) |> count(edge_type, name = "gr_caught"),
                                                           by = "edge_type"))

# ---- classes --------------------------------------------------------------------------------------------------
lab <- function(b, unit) {
  c(paste0("< ", b[2], unit), paste0(b[2:(length(b) - 2)], "-", b[3:(length(b) - 1)], unit),
    paste0(">= ", b[length(b) - 1], unit))
}
cut_lo <- function(x, b) cut(x, b, labels = FALSE, right = FALSE)   # [lower, upper)
cut_hi <- function(x, b) cut(x, b, labels = FALSE, right = TRUE)    # (lower, upper]
grad_b <- c(-Inf, 0.005, 0.01, 0.02, 0.0249, 0.0349, 0.0549, 0.08, 0.12, Inf)
grad_lab <- c("<= 0.5 %", "0.5-1 %", "1-2 %", "2-2.49 %", "2.49-3.49 %", "3.49-5.49 %", "5.49-8 %", "8-12 %", "> 12 %")
width_b <- c(-Inf, 1.5, 2, 4, 8, 15, 30, Inf)
width_lab <- c(lab(width_b, " m"), "no width")
mad_b <- c(-Inf, 0.021, 0.05, 0.2, 0.5, 1, 5, 20, Inf)
mad_lab <- lab(mad_b, " m3/s")
vars <- list(
  gradient = list(lab = grad_lab, ref = "1-2 %", f = function(d) grad_lab[cut_hi(d$segment_gradient, grad_b)]),
  channel_width = list(lab = width_lab, ref = "4-8 m",
                       f = function(d) ifelse(is.na(d$cw_deploy), "no width", width_lab[cut_lo(d$cw_deploy, width_b)])),
  mad = list(lab = mad_lab, ref = "0.2-0.5 m3/s", f = function(d) mad_lab[cut_lo(d$mad_pick, mad_b)]))
for (v in names(vars)) {
  if (!vars[[v]]$ref %in% vars[[v]]$lab) stop("reference class ", vars[[v]]$ref, " is not a ", v, " class")
  if (anyNA(vars[[v]]$f(d0))) stop("a visit has no ", v, " class")
}

# ---- model ----------------------------------------------------------------------------------------------------
nuisance <- c("data_set", "era", "wsg")
modelled <- function(d, resp) {
  keep <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
  d <- d[d$wsg %in% names(keep)[keep %in% TRUE], ]
  d$wsg <- droplevels(d$wsg)
  d
}
fit <- function(d, resp, link = "cloglog") {
  keep <- nuisance[vapply(nuisance, function(t) length(unique(d[[t]])) > 1L, logical(1))]
  f <- as.formula(paste(resp, "~", paste(c("cls", "log_area", keep), collapse = " + ")))
  suppressWarnings(glm(f, family = binomial(link = link), data = d, control = glm.control(maxit = 100)))
}
ratio <- function(m, labs) {
  if (!m$converged) return(setNames(rep(NA_real_, length(labs)), labs))
  b <- coef(m)
  vapply(labs, function(k) {
    if (k == levels(m$data$cls)[1]) return(1)
    x <- b[paste0("cls", k)]
    if (is.na(x)) NA_real_ else exp(unname(x))
  }, numeric(1))
}
with_cls <- function(d, v) {
  d$cls <- factor(vars[[v]]$f(d), levels = c(vars[[v]]$ref, setdiff(vars[[v]]$lab, vars[[v]]$ref)))
  d
}
# a class with no visit in a fit's data is dropped from its factor, so its ratio is NA there, never 1
fit_ratio <- function(d, resp, labs, link = "cloglog") {
  d$cls <- droplevels(d$cls)
  if (levels(d$cls)[1] != labs[1]) return(setNames(rep(NA_real_, length(labs)), labs))
  r <- ratio(fit(d, resp, link), labs)
  r[!labs %in% levels(d$cls)] <- NA_real_
  r
}
cl <- parallel::makeCluster(n_cores)
parallel::clusterExport(cl, c("modelled", "fit", "ratio", "fit_ratio", "nuisance"))
boot <- function(d, resp, labs, s) {
  set.seed(s)
  streams <- levels(droplevels(factor(d$blue_line_key)))
  idx <- split(seq_len(nrow(d)), droplevels(factor(d$blue_line_key)))
  picks <- lapply(seq_len(n_boot), function(i) sample(streams, length(streams), replace = TRUE))
  parallel::clusterExport(cl, c("d", "idx", "resp", "labs"), envir = environment())
  w <- parallel::parLapply(cl, picks, function(pick) {
    bd <- modelled(d[unlist(idx[pick], use.names = FALSE), ], resp)
    tryCatch(fit_ratio(bd, resp, labs), error = function(e) rep(NA_real_, length(labs)))
  })
  if (!all(vapply(w, function(x) is.numeric(x) && length(x) == length(labs), logical(1)))) stop("a bootstrap worker failed")
  do.call(rbind, w)
}

responses <- list(U = list(label = "gr_caught", y = "U", data = function(d) d),
                  F = list(label = "any_fish_caught", y = "F", data = function(d) d),
                  C = list(label = "gr_caught_given_fish", y = "U", data = function(d) d[d$F == 1L, ]))
out <- list()
sens <- list()
s <- seed
# the same population with river-polygon visits kept: their own edge types (1250, 1350) and the river flag cleared
d_river <- as_tibble(.tune_population(.tune_base(transform(vl, wb_river = FALSE), c(edge_stream, 1250L, 1350L),
                                                 area_range), vs, "GR", "rear")$d) |>
  mutate(F = as.integer(catch_status == "fish"))
say("River-polygon sensitivity population: %d visits (GR caught on %d).", nrow(d_river), sum(d_river$U))
for (v in names(vars)) for (r in names(responses)) {
  labs <- levels(with_cls(d0[0, ], v)$cls)
  d_resp <- responses[[r]]$data(with_cls(d0, v))
  y <- responses[[r]]$y
  d <- modelled(d_resp, y)
  n_both <- nlevels(d$wsg)
  rr <- if (n_both >= min_groups) fit_ratio(d, y, labs) else setNames(rep(NA_real_, length(labs)), labs)
  bw <- if (n_both >= min_groups) boot(d, y, labs, s <- s + 1L) else matrix(NA_real_, 1, length(labs))
  say("%s / %s: %d visits in %d groups modelled; %d visits in %d groups with one outcome left out%s", v,
      responses[[r]]$label, nrow(d), n_both, nrow(d_resp) - nrow(d), n_distinct(d_resp$wsg) - n_both,
      if (n_both < min_groups) " (too few groups: raw rates only)" else "")
  cnt <- d_resp |> group_by(cls, .drop = FALSE) |>
    summarise(n_visits = n(), n_detect = sum(.data[[y]]), n_groups = n_distinct(wsg), .groups = "drop")
  out[[paste(v, r)]] <- tibble(variable = v, response = responses[[r]]$label, class = labs) |>
    left_join(cnt |> mutate(class = as.character(cls)) |> select(-cls), by = "class") |>
    mutate(across(c(n_visits, n_detect, n_groups), ~ coalesce(.x, 0L)),
           raw_rate = ifelse(n_visits > 0, n_detect / n_visits, NA_real_),
           reference = class == vars[[v]]$ref,
           # a class with no detection (or every visit a detection) is separated: its fitted ratio runs to 0 (or
           # without bound) and says nothing a raw rate does not, so it carries no ratio
           sep = n_detect == 0L | n_detect == n_visits,
           rate_ratio = ifelse(sep, NA_real_, unname(rr[class])),
           ratio_lo = ifelse(sep, NA_real_, apply(bw, 2, quantile, 0.025, na.rm = TRUE, names = FALSE)),
           ratio_hi = ifelse(sep, NA_real_, apply(bw, 2, quantile, 0.975, na.rm = TRUE, names = FALSE)),
           n_boot_ok = if (n_both >= min_groups) colSums(!is.na(bw)) else 0L,
           power = if_else(n_visits >= min_visits & n_detect >= min_detect, "ok", "underpowered"))
  if (n_both >= min_groups) {
    dr <- modelled(responses[[r]]$data(with_cls(d_river, v)), y)
    sep_main <- out[[paste(v, r)]]$sep
    sep_river <- vapply(labs, function(k) { z <- dr[[y]][dr$cls == k]; !length(z) || all(z == 0L) || all(z == 1L) }, TRUE)
    sens[[paste(v, r)]] <- tibble(variable = v, response = responses[[r]]$label, class = labs,
                                  main = ifelse(sep_main, NA_real_, unname(rr)),
                                  logit_or = ifelse(sep_main, NA_real_, unname(fit_ratio(d, y, labs, "logit"))),
                                  rivers_kept = ifelse(sep_river, NA_real_, unname(fit_ratio(dr, y, labs))))
  }
}
parallel::stopCluster(cl)

res <- bind_rows(out) |>
  select(-sep) |>
  mutate(across(c(raw_rate, rate_ratio, ratio_lo, ratio_hi), ~ round(.x, 3)),
         across(c(ratio_lo, ratio_hi), ~ ifelse(is.finite(.x), .x, NA_real_)))
block("Rate ratios (also data/gr_use.csv)", res)
block("Sensitivity: the main ratio, the logit link's odds ratio, and river-polygon visits kept",
      bind_rows(sens) |> mutate(across(c(main, logit_or, rivers_kept), ~ round(.x, 3))))

# ---- spawning: when the population was fished, and what lengths were caught -----------------------------------
block("Visits by month (population), and with GR caught",
      d0 |> count(month, name = "visits") |> left_join(d0 |> filter(U == 1L) |> count(month, name = "gr_caught"),
                                                       by = "month"))
fish <- readRDS(f_fish)
fl <- fish[fish$species_code %in% "GR" & fish$site_visit %in% d0$site_visit & !is.na(fish$length_mm), ]
fl$month <- d0$month[match(fl$site_visit, d0$site_visit)]
fl$bin <- cut(fl$length_mm, c(seq(0, 300, 10), Inf), right = FALSE,
              labels = c(paste0(seq(0, 290, 10), "-", seq(10, 300, 10)), ">= 300"))
block("GR length (mm, 10 mm bins) by month, fish measured on population visits",
      as.data.frame.matrix(table(fl$bin, fl$month)) |> tibble::rownames_to_column("length_mm") |>
        filter(rowSums(across(-length_mm)) > 0))

write_csv(res, path_out, na = "")
writeLines(log_lines, path_log)
say("Wrote %s (%d rows) and %s.", path_out, nrow(res), path_log)
