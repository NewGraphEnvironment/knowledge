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
#' @param visits the build's `visits_link` table.
#' @param species_tbl the build's `visits_species` table.
#' @param walks the build's walks, as [knw_link_walks()] returns them.
#' @param thresholds link's `parameters_habitat_thresholds.csv`.
#' @param species,stages which to run.
#' @param spawner `NULL`, or [knw_spawner_evidence()]'s table.
#' @param edge_stream,area_range the population's constants.
#' @param seed,folds,n_boot,seeds_more,workers,d_floor passed to [knw_tune_score()].
#' @param min_wsg,power_wsg `integer(1)` the floors described above.
#' @param src `character(1)` the flow source the exception reads.
#' @return A list with one element per species × stage (`"<sp>_<stage>"`): a
#'   list with `species_code`, `stage`, `response`, `status` (`fitted`,
#'   `underpowered`, `no_stream_rule`, `no_response`, `too_few_groups`),
#'   `population`, and when fitted `score` ([knw_tune_score()]'s result),
#'   `pick` (the recommended rule row) and `curve` ([knw_tune_curve()]'s).
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
                         min_wsg = 5L, power_wsg = 10L, src = "pick") {
  chk::chk_data(visits)
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

  out <- list()
  for (sp in species) {
    thr <- thresholds[thresholds$species_code == sp, , drop = FALSE]
    st <- species_tbl[species_tbl$species_code == sp, c("site_visit", "present", "status", "in_range")]
    bcol <- paste0("barrier_dnstr_", tolower(sp))
    for (stage in stages) {
      key <- paste(sp, stage, sep = "_")
      rec <- list(species_code = sp, stage = stage, response = if (stage == "rear") "U" else "S")
      grid <- if (nrow(thr) == 1L) knw_tune_grid(thr, stage) else knw_tune_grid(thr[0, ], stage)[0, ]
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
      rule_in <- function(dd, r) knw_rule_in(dd, r, walks = wi, src = src, edge_stream = edge_stream)
      sc <- knw_tune_score(d, rule_in, grid, resp, seed = seed, folds = folds, n_boot = n_boot,
                           seeds_more = seeds_more, d_floor = d_floor, workers = workers, extra = TRUE)
      pick <- sc$rules[sc$rules$recommended, , drop = FALSE]
      cv <- knw_tune_curve(d, pick, wi, sc$folds, resp = resp, src = src)
      rec$status <- if (n_both < power_wsg) "underpowered" else "fitted"
      rec$score <- sc
      rec$pick <- pick
      rec$curve <- cv
      out[[key]] <- rec
    }
  }
  out
}
