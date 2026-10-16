# scripts/0297-ch-rule-tune.R
# ---------------------------------------------------------------------------
# Tunes a CH rearing rule on FDIS electrofishing visits: link's `default` CH rear predicate with
# its stream size test, its gradient test and a new exception for small streams near a large
# river, scored on held-out watershed groups. Issue #54. Input from 0296; the recommended rule is
# applied to link's segments by 0298.
#
# ANALYSIS SPEC, fixed and committed before the first fit. It was revised once, before any fit,
# after the plan review (planning archive for #54, review-plan.md: B2, B3, G1-G11).
#   - THE RULE is fresh::frs_habitat_predicates() on link's configs/default CH rear rules with
#     three things changed (findings for #54). A segment is in when any branch holds:
#       stream  edge 1000/1100/2000/2300, 0 <= gradient <= g, and (size test OR exception);
#       river   in a river polygon, 0 <= gradient <= g, and the river size test;
#       wetland edge 1000/1100/1050/1150 in a wetland >= 1 ha;
#       lake    lake edges in a lake or man-made waterbody >= 100 ha.
#     The size test is either width w <= width <= 9999 (river test: a non-NULL width), or MAD
#     m <= MAD with no maximum. Under fresh's `mad` model the floor sets the river test too, and
#     default's 100 m3/s maximum never acts while every group is on `cw`. A NULL width fails
#     (fwapg models no order-1 stream, so `default` never rears CH on an unmeasured order-1
#     stream). The exception holds where a segment of flow >= Q, of any kind (a lake segment
#     counts, as a rule in link would), lies within D m downstream on the same flow source
#     (0296's walks). A walk that reaches the sea first fails it.
#   - POPULATION: 0295's MAD analysis (0294's visits on 0291's edges, fished area 10-10,000 m2,
#     duplicates (#35) out), restricted to where the rule can change anything and link would
#     apply it:
#       stream branch  stream edges, not in a river polygon, a wetland >= 1 ha or a lake
#                      >= 100 ha (B2: elsewhere every rule is constant, and 702 of the 978 CH sit
#                      on river-polygon edges, where they would set the in-rate);
#       accessible     no natural CH barrier downstream before observation overrides, where 0296
#                      knows it (B3: link applies the rule behind its access gate, and a rule
#                      scored on blocked visits learns barriers).
#     Models use the WSGs where the response occurs and does not.
#   - INPUTS: gradient is the FWA segment's. Width is `cw_deploy`, the width link reads on a
#     stream nobody measured (0296: fwapg's model where the stored width is a field measurement
#     of the visit itself). MAD is wet's `pick`.
#   - GRID: size MAD m in {0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1} m3/s, or width w in
#     {1, 1.5, 2, 3, 4} m; g in {3, 4, 5.49, 7, 9} %; the exception none, or Q in
#     {1, 3, 5, 10, 20, 30, 50} m3/s with D in {100, 250, 500, 1000, 2000, 5000} m, which makes
#     2,795 rules. `default` is (width 1.5, 5.49 %, none). The model with no rule term is the
#     "all in" baseline.
#   - SCORE: binomial, cloglog link, rule (in/out) + log(area) + data set + era (0295's) + WSG.
#     The modelled WSGs go into 5 folds, stratified: WSGs are ranked by detections and dealt in
#     shuffled blocks of 5, with a fixed seed. Each fold is scored from a fit on the other four:
#     the held-out visits take that fit's rule, area, data-set and era coefficients, and each
#     held-out WSG refits only its own intercept, on its own visits (one parameter per WSG for every
#     rule). A level unseen in training takes the reference and is counted. The score is the summed
#     binomial deviance of the held-out visits. Rules with the same in/out on every visit are one
#     fit. Each rule reports the WSGs in which it varies.
#   - OPTIMUM: the best rule has the lowest score. A rule is in the region when its score is within
#     one SE of the best, the SE being sqrt(n) x sd of the per-WSG differences from the best (the
#     WSG is the unit). The PICK is the region rule with the fewest departures from `default`
#     (a size test that differs in variable or value: 1; a gradient that differs: 1; an exception:
#     1), ties to the lower score. If the pick's D is under 200 m, where mainstem catches snapped to
#     a tributary mouth cannot be told apart, `recommended` is the pick among region rules with
#     D >= 250 m or no exception; otherwise it is the pick. Each component is reported as a
#     profile: for each of its values, the best score over all other components.
#   - DECISION, fixed now: if `default` is in the region, the headline is that the data cannot
#     tell the tuned rule from `default`. Otherwise it is the recommended rule.
#   - HONEST SCORE: nested selection. For each fold, the pick is chosen on the other folds'
#     held-out deviance and scored on that fold, against `default` and against "all in". The
#     other folds' scores came from fits that saw this fold, so this removes the optimism of
#     choosing among 2,795 rules but is not a full inner cross-validation.
#   - STABILITY: (a) 200 bootstrap resamples of WSGs (the SE's unit) of the per-WSG held-out
#     deviance, fixed seed, with best, SE, region and recommended rule recomputed in each:
#     reported as each rule's share in the region and the share of resamples recommending each
#     component value. (b) The main grid on 4 more fold seeds, with each seed's pick and
#     recommended rule reported.
#   - CURVES (mgcv, REML) on the population: U ~ s(log MAD) + s(gradient), and separately
#     s(log width) + s(gradient), each with log(area) + data set + era + s(WSG, re). On visits
#     failing the recommended size floor, s(log(distance + 10 m)) to the recommended Q, with
#     `none` walks left out and counted. Each threshold is reported with the share of the smooth's
#     rise (over its 5-95 % range of x) reached at it, and the x of the steepest slope.
#   - SECOND READING, link's inputs: on the visits placed on a link segment, the grid with link's
#     segment gradient, beside the same visits with the FWA gradient.
#   - FLOW SOURCES: the grid on routed flow alone and on the balance alone (sizes and walks each on
#     that source) where both exist, beside pick on the same visits. Then fwapg's old MAD (size
#     only, walks on pick), beside pick on those visits. At the recommended rule, the visits whose
#     in/out differs from pick are counted by hydrologic zone and MAD class.
#   - SENSITIVITIES (region and pick only): every stream-branch visit, barrier status unknown or
#     blocked kept; the stored width (field measurements included); lake targets out (the
#     exception fails where its target is a lake); regulated visits and regulated targets out;
#     ambiguous placements out (0294's flag, set at 10 m3/s on visits under 0.5); CHES and NECR
#     out; C (CH among visits that caught any fish) for U.
#
# INPUT:  data/fdis/derived/ch_rule_visits.csv, data/fdis/derived/ch_rule_walks.csv (scripts/0296)
# OUTPUT: data/ch_rule_tune.csv    one row per rule and analysis: the full grid for `main`; the
#                                  region, default, best, pick and recommended for the others;
#                                  `main_profile_*` rows for the component profiles
#         data/ch_rule_curves.csv  the smooths
#         data/ch_rule_flips.csv   in/out flips between flow sources, by zone and MAD class
#         research/fig/chinook_rearing_tuned_curves.png
#         scripts/logs/habitat/<date>_ch_rule_tune.txt
# RUN:    Rscript scripts/0297-ch-rule-tune.R   (after 0296, from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
options(warn = 1)

edge_ok <- c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350)   # 0295's
area_range <- c(10, 10000)
edge_stream <- c(1000, 1100, 2000, 2300)       # link default CH rear: stream branch
edge_wetland <- c(1000, 1100, 1050, 1150)      #   wetland branches
edge_lake <- c(1000, 1100, 1200, 1250, 1300, 1350, 1400, 1450, 1475)  # lake branch
grid_mad <- c(0.1, 0.15, 0.2, 0.28, 0.35, 0.5, 0.75, 1)
grid_width <- c(1, 1.5, 2, 3, 4)
grid_grad <- c(0.03, 0.04, 0.0549, 0.07, 0.09)
grid_q <- c(1, 3, 5, 10, 20, 30, 50)
grid_d <- c(100, 250, 500, 1000, 2000, 5000)
d_floor <- 200
n_folds <- 5
n_boot <- 200
seed_folds <- 54L
seeds_more <- 55:58
seed_boot <- 541L
n_cores <- max(1L, min(6L, parallel::detectCores() - 2L))
path_out <- "data/ch_rule_tune.csv"
path_curves <- "data/ch_rule_curves.csv"
path_flips <- "data/ch_rule_flips.csv"
path_fig <- "research/fig/chinook_rearing_tuned_curves.png"
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_ch_rule_tune.txt"))
mad_breaks <- c(0, 0.1, 0.28, 0.5, 1, 3, 10, 30, 100, Inf)          # 0295's classes
mad_labels <- c("<0.1", "0.1-0.28", "0.28-0.5", "0.5-1", "1-3", "3-10", "10-30", "30-100", ">=100")

log_lines <- character()
say <- function(...) log_lines <<- c(log_lines, sprintf(...))
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title),
                  capture.output(print(as.data.frame(x), row.names = FALSE)))
}

# ---- data ------------------------------------------------------------------------
all_visits <- read_csv("data/fdis/derived/ch_rule_visits.csv", show_col_types = FALSE, guess_max = 1e5,
                       col_types = cols(site_visit = "c", dup_of = "c", hydro_zone = "c"))
walks <- read_csv("data/fdis/derived/ch_rule_walks.csv", show_col_types = FALSE)
base <- all_visits |>
  filter(edge_type %in% edge_ok, !is.na(area_m2), area_m2 >= area_range[1], area_m2 <= area_range[2],
         is.na(dup_of)) |>
  mutate(log_area = log(area_m2),
         era = factor(cut(year, c(-Inf, 1994, 2004, Inf), labels = c("to1994", "1995-2004", "2005on"))),
         data_set = factor(data_set),
         wsg = factor(watershed_group_code),
         stream = blue_line_key,
         U = as.integer(present_CH),
         F = as.integer(catch_status == "fish"),
         mad_class = factor(as.character(cut(mad_pick, mad_breaks, mad_labels, right = FALSE)), mad_labels),
         across(c(wb_river, wb_wetland, wb_lake, regulated, ambiguous), ~ coalesce(.x, FALSE)))
sb_all <- base |> filter(edge_type %in% edge_stream, !wb_river, !wb_wetland, !wb_lake)
v <- sb_all |> filter(natural_barrier_dnstr %in% FALSE)
say("CH rearing rule, knowledge#54. 0296 visits: %d. 0295's population: %d visits (%d CH) in %d WSGs.",
    nrow(all_visits), nrow(base), sum(base$U), n_distinct(base$wsg))
say("Stream branch: %d (%d CH). Barrier status known: %d (%d CH); natural CH barrier downstream: %d (%d CH).",
    nrow(sb_all), sum(sb_all$U), sum(!is.na(sb_all$natural_barrier_dnstr)),
    sum(sb_all$U[!is.na(sb_all$natural_barrier_dnstr)]), sum(sb_all$natural_barrier_dnstr %in% TRUE),
    sum(sb_all$U[sb_all$natural_barrier_dnstr %in% TRUE]))
say("POPULATION (stream branch, no natural barrier downstream): %d visits (%d CH) in %d WSGs.",
    nrow(v), sum(v$U), n_distinct(v$wsg))
block("population: width source and cw_deploy",
      v |> count(fwa_cw_source, deploy_null = is.na(cw_deploy)) |> mutate(across(everything(), as.character)))

# exception distance per (source, Q), keyed by start, with the target's lake and regulated flags
wk <- walks |> mutate(key = paste(src, qmin, sep = "|"), pt = paste(blue_line_key, downstream_route_measure))
exc <- lapply(split(wk, wk$key), function(x) {
  list(pt = x$pt, dist = ifelse(x$status == "found", x$dist_m, Inf),
       lake = coalesce(x$target_lake, FALSE), reg = coalesce(x$target_regulated, FALSE))
})

# ---- the rule ----------------------------------------------------------------------
grid <- bind_rows(
  expand.grid(size_var = "mad", size_min = grid_mad, grad_max = grid_grad, stringsAsFactors = FALSE),
  expand.grid(size_var = "width", size_min = grid_width, grad_max = grid_grad, stringsAsFactors = FALSE)) |>
  tidyr::crossing(bind_rows(tibble(exc_q = NA_real_, exc_d = NA_real_),
                            expand.grid(exc_q = grid_q, exc_d = grid_d))) |>
  mutate(rule = sprintf("%s>=%g|g<=%g|%s", size_var, size_min, grad_max,
                        ifelse(is.na(exc_q), "none", sprintf("Q%g@D%g", exc_q, exc_d))),
         departures = (size_var != "width" | size_min != 1.5) + (grad_max != 0.0549) + !is.na(exc_q))
default_ix <- which(grid$size_var == "width" & grid$size_min == 1.5 & grid$grad_max == 0.0549 & is.na(grid$exc_q))
stopifnot(nrow(grid) == 2795, length(default_ix) == 1, grid$departures[default_ix] == 0)

inputs <- function(grad = "fwa_gradient", width = "cw_deploy", mad = "mad_pick", src = "pick",
                   no_lake_target = FALSE, no_reg_target = FALSE) {
  list(grad = grad, width = width, mad = mad, src = src, no_lake_target = no_lake_target,
       no_reg_target = no_reg_target)
}
rule_in <- function(d, r, inp) {
  g <- d[[inp$grad]]
  grad_ok <- coalesce(g >= 0 & g <= r$grad_max, FALSE)
  if (r$size_var == "width") {
    wd <- d[[inp$width]]
    size_ok <- coalesce(wd >= r$size_min & wd <= 9999, FALSE)
    river_size <- coalesce(wd >= 0 & wd <= 9999, FALSE)
  } else {
    size_ok <- coalesce(d[[inp$mad]] >= r$size_min, FALSE)
    river_size <- size_ok
  }
  ex <- FALSE
  if (!is.na(r$exc_q)) {
    e <- exc[[paste(inp$src, r$exc_q, sep = "|")]]
    m <- match(paste(d$blue_line_key, d$downstream_route_measure), e$pt)
    if (anyNA(m)) stop("a visit has no walk on ", inp$src, " at ", r$exc_q)
    ok <- e$dist[m] <= r$exc_d
    if (inp$no_lake_target) ok <- ok & !e$lake[m]
    if (inp$no_reg_target) ok <- ok & !e$reg[m]
    ex <- ok
  }
  (d$edge_type %in% edge_stream & grad_ok & (size_ok | ex)) |
    (d$wb_river & grad_ok & river_size) |
    (d$edge_type %in% edge_wetland & d$wb_wetland) |
    (d$edge_type %in% edge_lake & d$wb_lake)
}

# ---- held-out scoring -----------------------------------------------------------------
modelled <- function(d, resp) {
  keep <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
  d <- d[d$wsg %in% names(keep)[keep %in% TRUE], ]
  d$wsg <- droplevels(d$wsg)
  d
}
fold_of_wsg <- function(d, resp, seed) {
  set.seed(seed)
  cnt <- tapply(d[[resp]], d$wsg, sum)
  w <- names(cnt)[order(-cnt, runif(length(cnt)))]
  blk <- ceiling(seq_along(w) / n_folds)
  f <- unlist(lapply(split(seq_along(w), blk), function(i) sample(seq_len(n_folds))[seq_along(i)]))
  setNames(f, w)
}
fold_setup <- function(d, resp, fold_of) {
  f <- unname(fold_of[as.character(d$wsg)])
  lapply(seq_len(n_folds), function(k) {
    tr <- which(f != k); ho <- which(f == k)
    dtr <- d[tr, ]; dtr$wsg <- droplevels(dtr$wsg)
    nuis <- c("log_area", "data_set", "era")
    nuis <- nuis[vapply(nuis, function(t) length(unique(dtr[[t]])) > 1L, logical(1))]
    X <- model.matrix(as.formula(paste("~", paste(c(nuis, "wsg"), collapse = " + "))), dtr)
    # every factor level is kept, so a held-out level absent from training has a column that is
    # not in the fit and contributes 0 (the reference)
    Xh <- model.matrix(as.formula(paste("~ 0 +", paste(nuis, collapse = " + "))), d[ho, ])
    cols <- intersect(colnames(Xh), colnames(X))
    unseen <- sum(!(d$data_set[ho] %in% dtr$data_set) | !(d$era[ho] %in% dtr$era))
    list(tr = tr, ho = ho, X = X, y = d[[resp]][tr], Xh = Xh[, cols, drop = FALSE], cols = cols,
         yh = d[[resp]][ho], wh = droplevels(d$wsg[ho]), unseen = unseen)
  })
}
score_one <- function(x, folds) {
  fam <- binomial(link = "cloglog")
  n <- sum(vapply(folds, function(f) length(f$ho), integer(1)))
  dv <- rep(NA_real_, n)
  ok <- TRUE
  for (f in folds) {
    m <- suppressWarnings(glm.fit(cbind(f$X, rule = as.numeric(x[f$tr])), f$y, family = fam,
                                  control = glm.control(maxit = 100)))
    if (!m$converged) ok <- FALSE
    b <- m$coefficients
    br <- if (is.na(b[["rule"]])) 0 else b[["rule"]]
    bn <- b[f$cols]; bn[is.na(bn)] <- 0
    eta <- drop(f$Xh %*% bn) + br * as.numeric(x[f$ho])
    p <- numeric(length(f$ho))
    for (w in levels(f$wh)) {
      i <- which(f$wh == w)
      a <- suppressWarnings(glm.fit(matrix(1, length(i), 1), f$yh[i], family = fam, offset = eta[i],
                                    control = glm.control(maxit = 100)))
      if (!a$converged) ok <- FALSE
      p[i] <- a$fitted.values
    }
    p <- pmin(pmax(p, 1e-12), 1 - 1e-12)
    dv[f$ho] <- -2 * (f$yh * log(p) + (1 - f$yh) * log(1 - p))
  }
  if (anyNA(dv)) stop("a visit was in no held-out fold")
  list(dev = dv, ok = ok)
}
# workers hold `folds` in their global environment; score_pat is top level so that parLapply
# does not serialize a caller's frame with it
score_pat <- function(x) score_one(x, folds)
cl <- parallel::makeCluster(n_cores)
parallel::clusterExport(cl, c("score_one", "score_pat"), envir = globalenv())

# per-WSG held-out deviance for every distinct pattern, plus the "all in" model
score_wsg <- function(d, y, pats, seed) {
  folds <- fold_setup(d, y, fold_of_wsg(d, y, seed))
  parallel::clusterExport(cl, "folds", envir = environment())
  sc <- parallel::parLapply(cl, pats, score_pat)
  devm <- vapply(sc, `[[`, numeric(nrow(d)), "dev")
  list(Sw = rowsum(devm, d$wsg), conv = vapply(sc, `[[`, logical(1), "ok"),
       null = rowsum(score_one(rep(FALSE, nrow(d)), folds)$dev, d$wsg)[, 1],
       unseen = sum(vapply(folds, `[[`, numeric(1), "unseen")),
       fold = fold_of_wsg(d, y, seed)[rownames(rowsum(devm[, 1], d$wsg))])
}
sel <- function(Sw, ix) {
  M <- Sw[ix, , drop = FALSE]
  tot <- colSums(M)
  best <- which.min(tot)
  se <- sqrt(length(ix)) * apply(M - M[, best], 2, sd)
  list(tot = tot, best = best, se = se, region = tot - tot[best] <= se)
}
# grid indices of the pick and the recommended rule, given a selection on pattern columns
pick_of <- function(s, col, conv) {
  rr <- which(s$region[col] & conv[col])
  rr <- rr[order(grid$departures[rr], s$tot[col[rr]])]
  p <- rr[1]
  ok_d <- rr[is.na(grid$exc_d[rr]) | grid$exc_d[rr] >= d_floor]
  c(pick = p, recommended = if (!is.na(grid$exc_d[p]) && grid$exc_d[p] < d_floor) ok_d[1] else p)
}

run_grid <- function(name, d, resp = "U", inp = inputs(), keep_all = FALSE, extra = FALSE) {
  if (resp == "C") { d <- d[d$F == 1L, ]; y <- "U" } else y <- resp
  d <- modelled(d, y)
  X <- vapply(seq_len(nrow(grid)), function(i) rule_in(d, grid[i, ], inp), logical(nrow(d)))
  key <- apply(X, 2, function(x) paste(packBits(c(x, logical((8 - length(x) %% 8) %% 8))), collapse = ""))
  u <- !duplicated(key)
  pats <- lapply(which(u), function(i) X[, i])
  col <- match(key, key[u])
  sw <- score_wsg(d, y, pats, seed_folds)
  s0 <- sel(sw$Sw, seq_len(nrow(sw$Sw)))
  pk <- pick_of(s0, col, sw$conv)
  R <- rowsum(X * 1, d$wsg); N <- as.vector(table(d$wsg)[rownames(R)])
  res <- grid |>
    mutate(analysis = name, response = resp, n_visits = nrow(d), n_detect = sum(d[[y]]),
           n_wsg = nlevels(d$wsg), unseen_level_visits = sw$unseen, n_wsg_varies = colSums(R > 0 & R < N),
           converged = sw$conv[col], dev_heldout = s0$tot[col], ddev_best = s0$tot[col] - s0$tot[s0$best],
           se_diff = s0$se[col], ddev_null = s0$tot[col] - sum(sw$null),
           in_region = s0$region[col] & sw$conv[col],
           n_in = colSums(X), n_detect_in = colSums(X * d[[y]]),
           raw_rate_in = n_detect_in / n_in, raw_rate_out = (sum(d[[y]]) - n_detect_in) / (nrow(d) - n_in),
           pick = seq_len(nrow(grid)) == pk[["pick"]],
           recommended = seq_len(nrow(grid)) == pk[["recommended"]],
           is_default = seq_len(nrow(grid)) == default_ix)
  say("%s / %s: %d visits (%d detections) in %d WSGs; %d distinct in/out patterns; %d not converged; region %d rules; default in region: %s; recommended %s",
      name, resp, nrow(d), sum(d[[y]]), nlevels(d$wsg), sum(u), sum(!sw$conv), sum(res$in_region),
      res$in_region[default_ix], grid$rule[pk[["recommended"]]])
  if (extra) {
    # (a) WSG bootstrap
    set.seed(seed_boot)
    nw <- nrow(sw$Sw)
    reg_n <- numeric(ncol(sw$Sw)); recs <- integer(n_boot)
    for (b in seq_len(n_boot)) {
      s <- sel(sw$Sw, sample.int(nw, nw, replace = TRUE))
      reg_n <- reg_n + (s$region & sw$conv)
      recs[b] <- pick_of(s, col, sw$conv)[["recommended"]]
    }
    res <- res |> mutate(boot_region_share = reg_n[col] / n_boot,
                         boot_rec_share = tabulate(recs, nrow(grid)) / n_boot)
    attr(res, "boot_recs") <- grid[recs, ]
    # honest score by nested selection
    hon <- lapply(seq_len(n_folds), function(k) {
      out_k <- which(sw$fold != k); in_k <- which(sw$fold == k)
      pk_k <- pick_of(sel(sw$Sw, out_k), col, sw$conv)
      tibble(fold = k, rule = grid$rule[pk_k[["recommended"]]], n_wsg = length(in_k),
             dev_rec = sum(sw$Sw[in_k, col[pk_k[["recommended"]]]]),
             dev_default = sum(sw$Sw[in_k, col[default_ix]]), dev_null = sum(sw$null[in_k]))
    })
    attr(res, "honest") <- bind_rows(hon)
    # (b) more fold seeds
    attr(res, "seeds") <- bind_rows(lapply(seeds_more, function(sd_) {
      s2 <- score_wsg(d, y, pats, sd_)
      ss <- sel(s2$Sw, seq_len(nrow(s2$Sw)))
      p2 <- pick_of(ss, col, s2$conv)
      tibble(seed = sd_, best = grid$rule[which(col == ss$best)[1]], pick = grid$rule[p2[["pick"]]],
             recommended = grid$rule[p2[["recommended"]]], default_in_region = ss$region[col[default_ix]],
             region_n = sum(ss$region[col] & s2$conv[col]))
    }))
  }
  if (!keep_all) res <- res |> filter(in_region | is_default | ddev_best == 0 | pick | recommended)
  res
}

res <- list()
t0 <- Sys.time()
res$main <- run_grid("main", v, keep_all = TRUE, extra = TRUE)
say("main grid, bootstrap, nested selection and 4 more seeds: %.1f min on %d workers",
    as.numeric(difftime(Sys.time(), t0, units = "mins")), n_cores)
main <- res$main
rec <- main |> filter(recommended)
pick <- main |> filter(pick)
dflt <- main |> filter(is_default)
say("")
say("PICK: %s (departures %d). RECOMMENDED: %s.", pick$rule, pick$departures, rec$rule)
say("DECISION: %s", if (dflt$in_region) {
  "default is inside the region: the data cannot tell the tuned rule from default."
} else sprintf("default is outside the region (%.1f deviance above the best, SE %.1f): the recommended rule.",
               dflt$ddev_best, dflt$se_diff))
block("main: region", main |> filter(in_region) |> arrange(ddev_best) |>
        select(rule, departures, ddev_best, se_diff, n_wsg_varies, n_in, n_detect_in, raw_rate_in,
               raw_rate_out, boot_region_share))
block("main: default, best, pick, recommended",
      main |> filter(is_default | ddev_best == 0 | pick | recommended) |>
        select(rule, departures, dev_heldout, ddev_best, se_diff, ddev_null, n_wsg_varies, n_in,
               n_detect_in, raw_rate_in, raw_rate_out))
hon <- attr(main, "honest")
block("main: nested selection, per fold", hon)
say("Nested selection: the recommended rule's held-out deviance is %.1f against default's %.1f and all-in's %.1f (lower is better).",
    sum(hon$dev_rec), sum(hon$dev_default), sum(hon$dev_null))
block("main: 4 more fold seeds", attr(main, "seeds"))
br <- attr(main, "boot_recs")
for (comp in c("size_var", "size_min", "grad_max", "exc_q", "exc_d")) {
  block(sprintf("WSG bootstrap: recommended %s", comp), count(br, .data[[comp]]) |> mutate(share = n / n_boot))
}
# component profiles: for each value, the best score over all other components, against the
# overall best and that rule's SE
prof <- function(comp, lab) {
  main |> mutate(value = lab) |> group_by(value) |> slice_min(ddev_best, n = 1, with_ties = FALSE) |>
    ungroup() |> mutate(analysis = paste0("main_profile_", comp))
}
profiles <- bind_rows(
  prof("size", sprintf("%s>=%g", main$size_var, main$size_min)),
  prof("gradient", sprintf("g<=%g", main$grad_max)),
  prof("exception_q", ifelse(is.na(main$exc_q), "none", sprintf("Q%g", main$exc_q))),
  prof("exception_d", ifelse(is.na(main$exc_d), "none", sprintf("D%g", main$exc_d))))
block("main: component profiles", profiles |>
        select(analysis, value, best_rule = rule, ddev_best, se_diff, in_region))

# ---- second reading, sensitivities, flow sources ------------------------------------
lk <- v |> filter(!is.na(link_id_segment))
res$link_inputs <- run_grid("link_gradient", lk, inp = inputs(grad = "link_gradient"))
res$link_inputs_fwa <- run_grid("link_visits_fwa_gradient", lk)
res$all_sb <- run_grid("sens_all_stream_branch", sb_all)
res$stored_width <- run_grid("sens_stored_width", v, inp = inputs(width = "fwa_channel_width"))
res$lake_targets_out <- run_grid("sens_lake_targets_out", v, inp = inputs(no_lake_target = TRUE))
res$regulated_out <- run_grid("sens_regulated_out", v |> filter(!regulated), inp = inputs(no_reg_target = TRUE))
res$ambiguous_out <- run_grid("sens_ambiguous_out", v |> filter(!ambiguous))
res$ches_necr_out <- run_grid("sens_ches_necr_out", v |> filter(!watershed_group_code %in% c("CHES", "NECR")))
res$C <- run_grid("sens_ch_given_fish", v, resp = "C")
both <- v |> filter(!is.na(mad_routed), !is.na(mad_balance))
res$src_pick <- run_grid("src_pick_where_both", both)
res$src_routed <- run_grid("src_routed", both, inp = inputs(mad = "mad_routed", src = "pcic_routed"))
res$src_balance <- run_grid("src_balance", both, inp = inputs(mad = "mad_balance", src = "wet_balance"))
old <- v |> filter(!is.na(mad_fwapg))
res$src_fwapg_pick <- run_grid("src_pick_where_fwapg", old)
res$src_fwapg <- run_grid("src_fwapg_old_mad", old, inp = inputs(mad = "mad_fwapg"))
parallel::stopCluster(cl)

tune <- bind_rows(c(res, list(profiles)))
block("pick and recommended in each analysis",
      tune |> filter(pick | recommended) |>
        select(analysis, response, rule, pick, recommended, departures, n_visits, n_detect, n_wsg, ddev_best))
block("default in each analysis", tune |> filter(is_default, !grepl("profile", analysis)) |>
        select(analysis, ddev_best, se_diff, in_region))

# ---- flips between sources at the recommended rule ---------------------------------
rr <- grid[grid$rule == rec$rule, ]
in_pick <- rule_in(both, rr, inputs())
in_routed <- rule_in(both, rr, inputs(mad = "mad_routed", src = "pcic_routed"))
in_balance <- rule_in(both, rr, inputs(mad = "mad_balance", src = "wet_balance"))
flips <- both |>
  mutate(in_pick = in_pick, flip_routed = in_routed != in_pick, flip_balance = in_balance != in_pick) |>
  group_by(hydro_zone, mad_class) |>
  summarise(n_visits = n(), n_ch = sum(U), n_in_pick = sum(in_pick),
            n_flip_routed = sum(flip_routed), n_flip_balance = sum(flip_balance),
            n_ch_flip_routed = sum(U * flip_routed), n_ch_flip_balance = sum(U * flip_balance),
            .groups = "drop") |>
  mutate(rule = rec$rule)
block("flips by hydrologic zone (all MAD classes)", flips |> group_by(hydro_zone) |>
        summarise(across(c(n_visits, n_ch, n_flip_routed, n_flip_balance), sum)) |>
        mutate(share_routed = round(n_flip_routed / n_visits, 3), share_balance = round(n_flip_balance / n_visits, 3)))
block("flips by MAD class (all zones)", flips |> group_by(mad_class) |>
        summarise(across(c(n_visits, n_ch, n_flip_routed, n_flip_balance), sum)))

# ---- curves -------------------------------------------------------------------------
cv <- v |> mutate(grad = pmin(pmax(fwa_gradient, 0), 0.2))
gam_fit <- function(d, f) {
  mgcv::gam(as.formula(paste("U ~", f, "+ log_area + data_set + era + s(wsg, bs = 're')")),
            family = binomial(link = "cloglog"), data = d, method = "REML")
}
curve_of <- function(m, d, var, xs, label, thr, x_log = TRUE) {
  nd <- d[rep(1, length(xs)), ]
  nd[[var]] <- xs
  tm <- predict(m, nd, type = "terms", se.fit = TRUE)
  term <- grep(paste0("s\\(", var, "\\)"), colnames(tm$fit), value = TRUE)
  s <- tm$fit[, term]; se <- tm$se.fit[, term]
  q <- quantile(d[[var]], c(0.05, 0.95), na.rm = TRUE)
  inr <- xs >= q[1] & xs <= q[2]
  lo <- min(s[inr]); hi <- max(s[inr])
  at <- approx(xs, s, thr)$y
  xm <- (xs[-1] + xs[-length(xs)]) / 2
  sl <- diff(s) / diff(xs)
  inm <- xm >= q[1] & xm <= q[2]
  tibble(curve = label, x = xs, rel_rate = exp(s - at), rel_lo = exp(s - 1.96 * se - at),
         rel_hi = exp(s + 1.96 * se - at), threshold = thr, rise_share_at_threshold = (at - lo) / (hi - lo),
         x_steepest = xm[inm][which.max(abs(sl[inm]))], x_log = x_log)
}
curves <- list()
d1 <- modelled(cv |> filter(mad_pick > 0) |> mutate(log_mad = log(mad_pick)), "U")
m1 <- gam_fit(d1, "s(log_mad, k = 8) + s(grad, k = 6)")
thr_mad <- if (rec$size_var == "mad") rec$size_min else 0.28
curves$mad <- curve_of(m1, d1, "log_mad", seq(log(0.01), log(50), length.out = 120), "mad_m3s", log(thr_mad)) |>
  mutate(x = exp(x), threshold = exp(threshold), x_steepest = exp(x_steepest))
curves$grad <- curve_of(m1, d1, "grad", seq(0, 0.2, length.out = 120), "gradient", rec$grad_max, x_log = FALSE)
d2 <- modelled(cv |> filter(cw_deploy > 0) |> mutate(log_width = log(cw_deploy)), "U")
m2 <- gam_fit(d2, "s(log_width, k = 8) + s(grad, k = 6)")
thr_w <- if (rec$size_var == "width") rec$size_min else 1.5
curves$width <- curve_of(m2, d2, "log_width", seq(log(0.3), log(30), length.out = 120), "width_m", log(thr_w)) |>
  mutate(x = exp(x), threshold = exp(threshold), x_steepest = exp(x_steepest))
qd <- if (is.na(rec$exc_q)) 10 else rec$exc_q
e <- exc[[paste("pick", qd, sep = "|")]]
fails <- if (rec$size_var == "mad") !coalesce(cv$mad_pick >= rec$size_min, FALSE) else
  !coalesce(cv$cw_deploy >= rec$size_min, FALSE)
sd_ <- cv |> mutate(dist = e$dist[match(paste(blue_line_key, downstream_route_measure), e$pt)]) |> filter(fails)
say("")
say("Distance curve: %d visits fail the recommended size floor; %d of them have no >= %g m3/s target (left out).",
    nrow(sd_), sum(!is.finite(sd_$dist)), qd)
d3 <- modelled(sd_ |> filter(is.finite(dist)) |> mutate(log_dist = log(dist + 10)), "U")
m3 <- gam_fit(d3, "s(log_dist, k = 6)")
thr_d <- if (is.na(rec$exc_d)) 500 else rec$exc_d
curves$dist <- curve_of(m3, d3, "log_dist", seq(log(20), log(50010), length.out = 120),
                        sprintf("dist_to_Q%g_m", qd), log(thr_d + 10)) |>
  mutate(x = exp(x) - 10, threshold = exp(threshold) - 10, x_steepest = exp(x_steepest) - 10)
curves <- bind_rows(curves) |> mutate(rule = rec$rule)
block("curves: threshold position", curves |> distinct(curve, threshold, rise_share_at_threshold, x_steepest))
for (m in list(m1, m2, m3)) log_lines <- c(log_lines, "", capture.output(summary(m)))

suppressMessages(library(ggplot2))
dir.create(dirname(path_fig), showWarnings = FALSE, recursive = TRUE)
panel <- function(k) {
  cd <- curves |> filter(curve == k)
  p <- ggplot(cd, aes(x, rel_rate)) +
    geom_ribbon(aes(ymin = rel_lo, ymax = rel_hi), fill = "grey80") +
    geom_line() +
    geom_vline(xintercept = cd$threshold[1], linetype = 2) +
    scale_y_log10() +
    labs(x = k, y = "relative to threshold") +
    theme_minimal(base_size = 10)
  if (cd$x_log[1]) p + scale_x_log10() else p
}
fig <- patchwork::wrap_plots(lapply(unique(curves$curve), panel), ncol = 2) +
  patchwork::plot_annotation(title = sprintf("CH detection (cloglog GAM, 95 %%), %d stream-branch FDIS visits", nrow(v)),
                              subtitle = sprintf("dashed: the recommended rule's thresholds (%s)", rec$rule))
ggsave(path_fig, fig, width = 8, height = 6, dpi = 150, bg = "white")

# ---- write ----------------------------------------------------------------------------
num <- c("dev_heldout", "ddev_best", "se_diff", "ddev_null", "raw_rate_in", "raw_rate_out",
         "boot_region_share", "boot_rec_share")
write_csv(tune |> mutate(across(any_of(num), ~ round(.x, 4))) |>
            select(analysis, any_of("value"), response, rule, size_var, size_min, grad_max, exc_q, exc_d,
                   departures, is_default, pick, recommended, in_region, converged, n_visits, n_detect, n_wsg,
                   n_wsg_varies, unseen_level_visits, dev_heldout, ddev_best, se_diff, ddev_null, n_in,
                   n_detect_in, raw_rate_in, raw_rate_out, any_of(c("boot_region_share", "boot_rec_share"))),
          path_out, na = "")
write_csv(curves |> select(-x_log) |>
            mutate(across(c(x, rel_rate, rel_lo, rel_hi, threshold, rise_share_at_threshold, x_steepest),
                          ~ signif(.x, 4))), path_curves, na = "")
write_csv(flips, path_flips, na = "")
writeLines(log_lines, path_log)
cat(log_lines, sep = "\n")
