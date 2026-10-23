#' Tune every species and stage the evidence can speak to, in one run
#'
#' For each species in `species` and each stage in `stages`: the scoring
#' population is cut, the rule grid built around link's own thresholds, every
#' rule scored on held-out groups ([knw_tune_score()]), and the curve fitted at
#' the pick ([knw_tune_curve()]).
#'
#' The population follows `scripts/0297`: visits on the stream branch (FWA edge
#' types `edge_stream`, not in a river polygon, a wetland of at least 1 ha or a
#' lake of at least 100 ha), with a fished area in `area_range`, in groups where
#' link's presence rule marks the species present, with no code blocking the
#' species' absence, and no natural barrier to the species downstream before
#' observation overrides (`barrier_dnstr_<sp>` is `FALSE`). Rearing's response is
#' detection (`U`, the species caught); spawning's is spawner evidence (`S`) from
#' `spawner`, which the export carries for char only, so a species × stage with no
#' response, no stream rule in `default`, or fewer than `min_wsg` groups with both
#' outcomes gets a one-row record saying so and is not fitted. A species × stage
#' with fewer than `power_wsg` groups is fitted and labelled `underpowered`.
#'
#' Before any grid is scored, every species × stage that would be fitted gets
#' the smoke run ([knw_tune_smoke()]; #84): a handful of rules on the main fold
#' seed, and four checks on the scorer. One failed check on any key stops the
#' run, with every key's report printed, so a scorer defect costs minutes, not
#' the hours of the full grid. `smoke_only = TRUE` returns after the smoke run
#' (each record carries `smoke`, and none is scored), which is how
#' `scripts/0320` writes the reports before it decides to score.
#'
#' @param visits the build's `visits_link` table.
#' @param species_tbl the build's `visits_species` table.
#' @param walks the build's walks, as [knw_link_walks()] returns them.
#' @param thresholds link's `parameters_habitat_thresholds.csv`.
#' @param species,stages which to run.
#' @param spawner `NULL`, or [knw_spawner_evidence()]'s table.
#' @param edge_stream,area_range the population's constants.
#' @param seed,folds,n_boot,seeds_more,workers,d_floor,fit passed to [knw_tune_score()] (and `fit` to
#'   [knw_tune_smoke()]).
#' @param min_wsg,power_wsg `integer(1)` the floors described above.
#' @param src `character(1)` the flow source the exception reads.
#' @param thresholds_extra `NULL`, or another bundle's
#'   `parameters_habitat_thresholds.csv` (link's `default_tuned`): each species'
#'   row joins its grid as the `is_link_tuned` candidate ([knw_tune_grid()]).
#' @param grid_args `list` of arguments passed to [knw_tune_grid()] for every
#'   species × stage (for example `list(grid_grad = c(0.03, 0.09, 0.15))`); empty
#'   for its defaults.
#' @param cache_dir `NULL`, or a directory where each species × stage's scored
#'   grid is saved as `<sp>_<stage>_score.rds` and read back on a rerun when the
#'   population has the same number of visits and the grid the same rows, in
#'   the same order (every [knw_tune_grid()] column, so a moved `default`
#'   counts). The other scoring arguments (`seed`, `folds`, `n_boot`,
#'   `seeds_more`, `d_floor`, `extra`) are not checked: give a run with different
#'   ones its own directory.
#' @param previous `NULL`, or a named `character` vector of the previous pick's
#'   rule string per `"<sp>_<stage>"`, which the smoke run scores where present.
#' @param smoke `logical(1)` run the smoke run and its checks first.
#' @param smoke_only `logical(1)` return after the smoke run, scoring nothing.
#' @param smoke_args `list` of arguments passed to [knw_tune_smoke()]
#'   (`tol_null`, `coef_max`).
#' @param extra `logical(1)` passed to [knw_tune_score()]: the bootstrap, the
#'   nested selection and the extra fold seeds. `FALSE` is the development
#'   setting, which proves a scorer change on every species in a fraction of the
#'   time; a run that publishes keeps `TRUE`.
#' @return A list with one element per species × stage (`"<sp>_<stage>"`): a
#'   list with `species_code`, `stage`, `response`, `status` (`fitted`,
#'   `underpowered`, `no_stream_rule`, `no_response`, `too_few_groups`,
#'   `curve_failed`; `smoke` with `smoke_only`), `population`, and when scored
#'   `smoke` ([knw_tune_smoke()]'s result, with `smoke`), `score`
#'   ([knw_tune_score()]'s result), `pick` (the recommended rule row) and `curve`
#'   ([knw_tune_curve()]'s; `NULL` with `curve_error` when its fit failed).
#' @export
#' @examples
#' \dontrun{
#' thr <- read.csv("parameters_habitat_thresholds.csv")
#' out <- knw_tune_run(visits, species_tbl, walks, thr, species = c("CH", "BT"), workers = 6)
#' out$CH_rear$pick
#' }
knw_tune_run <- function(visits, species_tbl, walks, thresholds, species = knw_species(),
                         stages = c("rear", "spawn"), spawner = NULL,
                         edge_stream = c(1000L, 1100L, 2000L, 2300L), area_range = c(10, 10000),
                         seed = 54L, folds = 5L, n_boot = 200L, seeds_more = 55:58, workers = 1L, d_floor = 200,
                         min_wsg = 5L, power_wsg = 10L, src = "pick", grid_args = list(), cache_dir = NULL,
                         thresholds_extra = NULL, previous = NULL, smoke = TRUE, smoke_only = FALSE,
                         smoke_args = list(), extra = TRUE, fit = c("fe", "dense")) {
  fit <- match.arg(fit)
  chk::chk_data(visits)
  chk::chk_list(grid_args)
  chk::chk_list(smoke_args)
  chk::chk_flag(smoke)
  chk::chk_flag(smoke_only)
  chk::chk_flag(extra)
  chk::chk_null_or(previous, vld = chk::vld_character)
  if (!is.null(previous) && is.null(names(previous))) stop("previous must be named by species_stage", call. = FALSE)
  if (!is.null(thresholds_extra)) chk::chk_data(thresholds_extra)
  chk::check_names(visits, c("site_visit", "watershed_group_code", "blue_line_key", "downstream_route_measure",
                             "edge_type", "wb_river", "wb_wetland", "wb_lake", "area_m2", "year", "data_set",
                             "fwa_gradient", "cw_deploy", "mad_pick"))
  chk::chk_data(species_tbl)
  chk::check_names(species_tbl, c("site_visit", "species_code", "present", "status", "in_range"))
  chk::chk_data(thresholds)
  chk::chk_subset(stages, c("rear", "spawn"))
  wi <- knw_walk_index(walks)
  base <- visits[visits$edge_type %in% edge_stream & !(visits$wb_river %in% TRUE) & !(visits$wb_wetland %in% TRUE) &
                   !(visits$wb_lake %in% TRUE) & !is.na(visits$area_m2) & visits$area_m2 >= area_range[1] &
                   visits$area_m2 <= area_range[2], , drop = FALSE]
  base$log_area <- log(base$area_m2)
  eras <- c("to1994", "1995-2004", "2005on")
  base$era <- factor(as.character(cut(base$year, c(-Inf, 1994, 2004, Inf), labels = eras)), levels = eras)
  base$data_set <- factor(base$data_set)
  base$wsg <- factor(base$watershed_group_code)
  rule_in <- function(dd, r) knw_rule_in(dd, r, walks = wi, src = src, edge_stream = edge_stream)

  # ---- every key's population and grid, and why a key is not fitted ----
  out <- list()
  prep <- list()
  for (sp in species) {
    thr <- thresholds[thresholds$species_code == sp, , drop = FALSE]
    thx <- NULL
    if (!is.null(thresholds_extra)) thx <- thresholds_extra[thresholds_extra$species_code == sp, , drop = FALSE]
    if (!is.null(thx) && nrow(thx) != 1L) thx <- NULL
    st <- species_tbl[species_tbl$species_code == sp, c("site_visit", "present", "status", "in_range")]
    bcol <- paste0("barrier_dnstr_", tolower(sp))
    for (stage in stages) {
      key <- paste(sp, stage, sep = "_")
      rec <- list(species_code = sp, stage = stage, response = if (stage == "rear") "U" else "S")
      tune_grid <- function(t) do.call(knw_tune_grid, c(list(t, stage, extra = thx), grid_args))
      grid <- if (nrow(thr) == 1L) tune_grid(thr) else tune_grid(thr[0, ])[0, ]
      if (nrow(thr) != 1L || !nrow(grid)) {
        rec$status <- "no_stream_rule"
        rec$population <- c(visits_in = 0L)
        out[[key]] <- rec
        next
      }
      d <- merge(base, st, by = "site_visit")
      d <- d[d$in_range %in% TRUE & d$status != "blocked", , drop = FALSE]
      if (bcol %in% names(d)) d <- d[d[[bcol]] %in% FALSE, , drop = FALSE]
      if (stage == "rear") {
        d$U <- as.integer(d$present)
        resp <- "U"
      } else {
        if (is.null(spawner) || !any(spawner$species_code == sp)) {
          rec$status <- "no_response"
          rec$population <- c(visits_in = nrow(d))
          out[[key]] <- rec
          next
        }
        sv <- spawner[spawner$species_code == sp, c("site_visit", "S")]
        d <- merge(d, sv, by = "site_visit")
        d <- d[!is.na(d$S), , drop = FALSE]
        resp <- "S"
      }
      d$wsg <- droplevels(d$wsg)
      both <- tapply(d[[resp]], d$wsg, function(x) any(x == 1L) && any(x == 0L))
      n_both <- sum(both %in% TRUE)
      rec$population <- c(visits_in = nrow(d), detections = sum(d[[resp]]), groups = nlevels(d$wsg),
                          groups_both = n_both)
      if (n_both < max(min_wsg, folds)) {
        rec$status <- "too_few_groups"
        out[[key]] <- rec
        next
      }
      out[[key]] <- rec
      prep[[key]] <- list(d = d, grid = grid, resp = resp, n_both = n_both)
    }
  }

  # ---- the smoke run on every key that would be fitted, before any grid is scored (#84) ----
  if (smoke || smoke_only) {
    failed <- character()
    for (key in names(prep)) {
      p <- prep[[key]]
      prev <- if (!is.null(previous) && key %in% names(previous)) unname(previous[[key]]) else NULL
      sm <- do.call(knw_tune_smoke, c(list(p$d, rule_in, p$grid, p$resp, previous = prev, seed = seed, folds = folds,
                                           fit = fit), smoke_args))
      out[[key]]$smoke <- sm
      message(key, " ", paste(sm$lines, collapse = "\n  "))
      if (!sm$pass) failed <- c(failed, key)
    }
    if (smoke_only) {
      for (key in names(prep)) out[[key]]$status <- "smoke"
      return(out)
    }
    if (length(failed)) {
      stop("the smoke run failed on ", paste(vapply(failed, function(k) {
        ck <- out[[k]]$smoke$checks
        paste0(k, " (", paste(ck$check[!ck$pass], collapse = ", "), ")")
      }, ""), collapse = ", "), ". Nothing was scored.", call. = FALSE)
    }
  }

  # ---- score, pick and curve ----
  for (key in names(prep)) {
    p <- prep[[key]]
    d <- p$d
    grid <- p$grid
    resp <- p$resp
    rec <- out[[key]]
    # a scored grid is hours of work: keep it beside the run so a later failure does not cost it
    cache <- if (is.null(cache_dir)) NULL else file.path(cache_dir, paste0(key, "_score.rds"))
    sc <- NULL
    if (!is.null(cache) && file.exists(cache)) {
      sc <- readRDS(cache)
      # a cache scored on another grid would be read back as this one's result; the rule strings alone do not
      # carry which rule is `default` (it moves with link's thresholds), so every grid column is compared
      # a cache from before a grid column existed (#80's departures_flow, is_link_tuned) is another grid too
      if (!identical(sc$population[["visits_in"]], nrow(d)) || !all(names(grid) %in% names(sc$rules)) ||
            !identical(as.list(sc$rules[names(grid)]), as.list(grid))) sc <- NULL
    }
    if (is.null(sc)) {
      sc <- knw_tune_score(d, rule_in, grid, resp, seed = seed, folds = folds, n_boot = n_boot,
                           seeds_more = seeds_more, d_floor = d_floor, workers = workers, extra = extra, fit = fit)
      if (!is.null(cache)) saveRDS(sc, cache)
    }
    pick <- sc$rules[sc$rules$recommended, , drop = FALSE]
    pick_flow <- sc$rules[sc$rules$recommended_flow %in% TRUE, , drop = FALSE]
    cv <- tryCatch(knw_tune_curve(d, pick, wi, sc$folds, resp = resp, src = src, edge_stream = edge_stream),
                   error = function(e) structure(list(message = conditionMessage(e)), class = "knw_curve_failed"))
    rec$status <- if (inherits(cv, "knw_curve_failed")) "curve_failed" else
      if (p$n_both < power_wsg) "underpowered" else "fitted"
    rec$score <- sc
    rec$pick <- pick
    rec$pick_flow <- if (nrow(pick_flow)) pick_flow else NULL
    rec$curve <- if (inherits(cv, "knw_curve_failed")) NULL else cv
    rec$curve_error <- if (inherits(cv, "knw_curve_failed")) cv$message else NULL
    out[[key]] <- rec
  }
  out
}
