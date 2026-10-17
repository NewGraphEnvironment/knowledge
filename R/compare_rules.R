#' Set a tuned rule beside link's `default` on link's own segments
#'
#' `scripts/0298`'s comparison for any species and stage. Each rule goes through
#' the three stages that make link's stored flags, on scratch copies of each
#' group: the predicate gated by stored access, `fresh::frs_habitat_overlay()`
#' with link's user-habitat rows for the species, and fresh's connectivity pass
#' (`.frs_run_connectivity()` with link's `default` parameters), rearing and
#' spawning together, because the connectivity pass reads spawning. Regenerated
#' `default` is reported against the stored flags, never compared to them.
#'
#' `default`'s predicate is `fresh::frs_habitat_predicates()` on link's
#' `configs/default`. A tuned rule is the same predicate with its gradient maximum
#' and, under a width rule, its width floor substituted, and with the stream
#' branch's size test replaced: a stream-branch segment (a stream edge in no river
#' polygon, wetland of at least 1 ha or lake of at least 100 ha) is in when its
#' gradient is inside the maximum and either the size test holds (width, or MAD at
#' least the floor) or a river of the rule's `exc_q` lies within `exc_d` m
#' downstream (`dist_m`, walked from the segment's downstream end by
#' [knw_grade_species()]). The river, wetland and lake branches stay fresh's. When
#' a tuned rule equals `default` the injected form must equal fresh's own
#' predicate on every segment, which the call asserts.
#'
#' @param connector a function returning a `DBI` connection.
#' @param schema `character(1)` link persist schema.
#' @param species `character(1)` species code.
#' @param stage `"rear"` or `"spawn"`: the stage the tuned rule changes.
#' @param tuned one row of the scored grid (the recommended rule).
#' @param groups `character` watershed groups to compare.
#' @param link_dir `character(1)` a directory holding link's `configs/default`
#'   files at the run's commit: `parameters_habitat_thresholds.csv`,
#'   `rules.yaml`, `parameters_fresh.csv`, `overrides/user_habitat_classification.csv`.
#' @param grades the species × stage grade table [knw_grade_species()] wrote
#'   (`id_segment`, `watershed_group_code`, `size`, `dist_m`, `grade`,
#'   `grade_class`), for the MAD with parent fallback, the exception distance
#'   and the graded km.
#' @param visits,visit_species the build's `visits_link` and `visits_species`
#'   tables, for the FDIS detection check (`NULL` to skip).
#' @param scratch `character(1)` the scratch schema (dropped at the end).
#' @param n_boot,seed_boot the bcfishobs lift's bootstrap.
#' @return A list of `tibble`s: `compare` (per group and total: km by rule,
#'   graded km, km by grade class, gained and lost), `change` (km gained and lost
#'   by reason and stream order), `checks` (FDIS detection on each rule's
#'   segments and the bcfishobs lift), `segments` (the per-segment flags under
#'   each rule, for maps), and `log` lines.
#' @export
#' @examples
#' \dontrun{
#' pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' cmp <- knw_compare_rules(pg, "fresh_default", "CH", "rear", pick, c("BULK", "MORR"),
#'                          link_dir, grades)
#' cmp$compare
#' }
knw_compare_rules <- function(connector, schema, species, stage, tuned, groups, link_dir, grades,
                              visits = NULL, visit_species = NULL, scratch = "knw_compare_scratch",
                              n_boot = 200L, seed_boot = 542L) {
  chk::chk_function(connector)
  chk::chk_string(schema)
  chk::chk_string(species)
  stage <- match.arg(stage, c("rear", "spawn"))
  chk::check_names(tuned, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d"))
  chk::chk_character(groups)
  chk::chk_dir(link_dir)
  chk::chk_data(grades)
  chk::check_names(grades, c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class"))
  if (!requireNamespace("fresh", quietly = TRUE)) stop("fresh is needed", call. = FALSE)
  sp <- toupper(species)
  s <- tolower(species)
  log <- character()
  say <- function(...) log <<- c(log, sprintf(...))

  f_thr <- file.path(link_dir, "parameters_habitat_thresholds.csv")
  f_rules <- file.path(link_dir, "rules.yaml")
  f_fresh <- file.path(link_dir, "parameters_fresh.csv")
  f_uhc <- file.path(link_dir, "overrides", "user_habitat_classification.csv")
  for (f in c(f_thr, f_rules, f_fresh, f_uhc)) if (!file.exists(f)) stop("missing ", f, call. = FALSE)
  params <- fresh::frs_params(csv = f_thr, rules_yaml = f_rules)
  if (is.null(params[[sp]])) stop("link's default has no parameters for ", sp, call. = FALSE)
  params_fresh <- utils::read.csv(f_fresh, stringsAsFactors = FALSE)
  uhc <- utils::read.csv(f_uhc, stringsAsFactors = FALSE)
  uhc <- uhc[uhc$species_code == sp, , drop = FALSE]
  thr <- utils::read.csv(f_thr, stringsAsFactors = FALSE)
  thr <- thr[thr$species_code == sp, , drop = FALSE]
  edge_stream <- fresh::frs_edge_types(category = "stream")$edge_type
  if (nrow(thr) == 1L && !is.na(thr[[paste0(stage, "_edge_types")]]) && nzchar(thr[[paste0(stage, "_edge_types")]])) {
    cats <- trimws(strsplit(thr[[paste0(stage, "_edge_types")]], ",")[[1]])
    edge_stream <- unlist(lapply(cats, function(ct) fresh::frs_edge_types(category = ct)$edge_type))
  }
  flag <- if (stage == "rear") "rearing" else "spawning"
  pred_of <- function(ps, model = "cw") {
    fresh::frs_habitat_predicates(list(species_code = sp, params_sp = ps, spawn_gradient_min = 0,
                                       spawn_gradient_max = ps$ranges$spawn$gradient[2]), model)
  }
  p_default <- pred_of(params[[sp]])
  # the tuned rule: fresh's predicate with the gradient and, for a width rule, the width substituted
  # and the stream branch opened to any measured width, then the stream-branch size test injected
  ps_t <- params[[sp]]
  ps_t$ranges[[stage]]$gradient[2] <- tuned$grad_max
  ps_t$ranges[[stage]]$channel_width <- c(0, 9999)
  p_tuned_base <- pred_of(ps_t)
  wb_sql <- "
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_knw_wb AS
    SELECT DISTINCT waterbody_key, 'R' AS t FROM whse_basemapping.fwa_rivers_poly
    UNION SELECT DISTINCT waterbody_key, 'W' FROM whse_basemapping.fwa_wetlands_poly WHERE area_ha >= 1
    UNION SELECT DISTINCT waterbody_key, 'L' FROM whse_basemapping.fwa_lakes_poly WHERE area_ha >= 100
    UNION SELECT DISTINCT waterbody_key, 'M' FROM whse_basemapping.fwa_manmade_waterbodies_poly WHERE area_ha >= 100"
  sb <- sprintf(paste("(s.edge_type IN (%s) AND NOT coalesce(s.waterbody_key IN",
                      "(SELECT waterbody_key FROM tmp_knw_wb), FALSE))"),
                paste(edge_stream, collapse = ", "))
  size_ok <- if (tuned$size_var == "width") {
    sprintf("coalesce(s.channel_width BETWEEN %s AND 9999, FALSE)", tuned$size_min)
  } else {
    sprintf("coalesce(s.knw_size >= %s, FALSE)", tuned$size_min)
  }
  ex <- if (is.na(tuned$exc_q)) "FALSE" else sprintf("coalesce(s.knw_dist <= %s, FALSE)", tuned$exc_d)
  grad_ok <- sprintf("coalesce(s.gradient BETWEEN 0 AND %s, FALSE)", tuned$grad_max)
  tuned_sql <- sprintf("((coalesce((%1$s), FALSE) AND (NOT %2$s OR %3$s OR %4$s))
     OR (%2$s AND s.channel_width IS NULL AND %5$s AND (%3$s OR %4$s)))",
                       p_tuned_base[[stage]], sb, size_ok, ex, grad_ok)
  preds <- list(default = sprintf("coalesce((%s), FALSE)", p_default[[stage]]), tuned = tuned_sql)
  other <- if (stage == "rear") "spawn" else "rear"
  pred_other <- sprintf("coalesce((%s), FALSE)", p_default[[other]])
  rng <- params[[sp]]$ranges[[stage]]
  is_default_rule <- tuned$size_var == "width" && isTRUE(all.equal(tuned$size_min, rng$channel_width[1])) &&
    isTRUE(all.equal(tuned$grad_max, rng$gradient[2])) && is.na(tuned$exc_q)

  conn <- connector()
  on.exit(try(DBI::dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", scratch)), silent = TRUE), add = TRUE)
  on.exit(try(DBI::dbDisconnect(conn), silent = TRUE), add = TRUE)
  DBI::dbExecute(conn, wb_sql)
  DBI::dbExecute(conn, sprintf("CREATE SCHEMA IF NOT EXISTS %s", scratch))
  DBI::dbWriteTable(conn, DBI::Id(schema = scratch, table = "uhc"), uhc, overwrite = TRUE)
  run_conn <- utils::getFromNamespace(".frs_run_connectivity", "fresh")
  g_sp <- grades[grades$watershed_group_code %in% groups,
                 c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class")]
  DBI::dbWriteTable(conn, DBI::Id(schema = scratch, table = "grades"), as.data.frame(g_sp), overwrite = TRUE)
  DBI::dbExecute(conn, sprintf("CREATE INDEX ON %s.grades (id_segment, watershed_group_code)", scratch))
  say("%s %s: %d groups; default %s; tuned %s.", sp, stage, length(groups), p_default[[stage]], tuned$rule)

  flags <- list()
  t0 <- Sys.time()
  for (w in groups) {
    DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s.streams", scratch))
    DBI::dbExecute(conn, sprintf("
      CREATE TABLE %1$s.streams AS
      SELECT s.*, h.accessible, g.size AS knw_size, g.dist_m AS knw_dist
      FROM %2$s.streams s
      JOIN %2$s.streams_habitat_%3$s h
        ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
      LEFT JOIN %1$s.grades g ON g.id_segment = s.id_segment AND g.watershed_group_code = s.watershed_group_code
      WHERE s.watershed_group_code = '%4$s'", scratch, schema, s, w))
    for (ix in c("(id_segment)", "USING gist (geom)", "USING gist (wscode_ltree)", "USING gist (localcode_ltree)",
                 "(blue_line_key, downstream_route_measure)")) {
      DBI::dbExecute(conn, sprintf("CREATE INDEX ON %s.streams %s", scratch, ix))
    }
    if (is_default_rule) {
      dif <- DBI::dbGetQuery(conn, sprintf(
        "SELECT count(*) FILTER (WHERE (%s) IS DISTINCT FROM (%s)) AS n FROM %s.streams s",
        preds$default, preds$tuned, scratch))$n
      if (as.integer(dif) > 0L) {
        stop("the injected tuned predicate differs from fresh's default on ", dif, " segments in ", w, call. = FALSE)
      }
    }
    for (k in names(preds)) {
      h <- paste0(scratch, ".habitat_", k)
      DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s", h))
      rear_sql <- if (stage == "rear") preds[[k]] else pred_other
      spawn_sql <- if (stage == "spawn") preds[[k]] else pred_other
      DBI::dbExecute(conn, sprintf("
        CREATE TABLE %1$s AS
        SELECT s.id_segment, s.watershed_group_code, '%2$s'::text AS species_code, s.accessible,
               s.accessible AND %3$s AS spawning, s.accessible AND %4$s AS rearing,
               s.accessible AND coalesce(s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb WHERE t = 'L'), FALSE)
                 AS lake_rearing,
               s.accessible AND coalesce(s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb WHERE t = 'W'), FALSE)
                 AS wetland_rearing,
               FALSE AS rearing_pre_connect, FALSE AS spawning_pre_connect
        FROM %5$s.streams s", h, sp, spawn_sql, rear_sql, scratch))
      DBI::dbExecute(conn, sprintf("UPDATE %s SET rearing_pre_connect = rearing, spawning_pre_connect = spawning", h))
      DBI::dbExecute(conn, sprintf("CREATE INDEX ON %s (id_segment)", h))
      if (nrow(uhc)) {
        fresh::frs_habitat_overlay(conn, from = paste0(scratch, ".uhc"), to = h, bridge = paste0(scratch, ".streams"),
                                   species = sp, verbose = FALSE)
      }
      run_conn(conn, table = paste0(scratch, ".streams"), habitat = h, species = sp, params = params,
               params_fresh = params_fresh, verbose = FALSE)
      flags[[paste(w, k)]] <- DBI::dbGetQuery(conn, sprintf(
        "SELECT id_segment, watershed_group_code, '%s' AS rule, rearing, spawning, lake_rearing, wetland_rearing,
                rearing_pre_connect, spawning_pre_connect FROM %s", k, h))
    }
  }
  say("Classify, overlay and connect: %d groups x 2 rules, %.1f min.", length(groups),
      as.numeric(difftime(Sys.time(), t0, units = "mins")))
  wsg_in <- paste0("'", groups, "'", collapse = ",")
  seg <- DBI::dbGetQuery(conn, sprintf("
    SELECT s.id_segment, s.watershed_group_code, s.linear_feature_id, s.blue_line_key, s.downstream_route_measure,
           s.upstream_route_measure, s.edge_type, s.stream_order, s.length_metre, s.gradient, s.channel_width,
           h.accessible, h.rearing AS rearing_stored, h.spawning AS spawning_stored,
           g.size AS knw_size, g.dist_m AS knw_dist, g.grade, g.grade_class
    FROM %1$s.streams s
    JOIN %1$s.streams_habitat_%2$s h ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
    LEFT JOIN %3$s.grades g ON g.id_segment = s.id_segment AND g.watershed_group_code = s.watershed_group_code
    WHERE s.watershed_group_code IN (%4$s)", schema, s, scratch, wsg_in))
  fl <- do.call(rbind, flags)
  for (k in names(preds)) {
    fk <- fl[fl$rule == k, ]
    i <- match(paste(seg$id_segment, seg$watershed_group_code), paste(fk$id_segment, fk$watershed_group_code))
    seg[[paste0(flag, "_", k)]] <- fk[[flag]][i]
    seg[[paste0(flag, "_pre_", k)]] <- fk[[paste0(flag, "_pre_connect")]][i]
  }
  if (anyNA(seg[[paste0(flag, "_default")]]) || anyNA(seg[[paste0(flag, "_tuned")]])) {
    stop("a segment has no regenerated flag", call. = FALSE)
  }
  seg <- tibble::as_tibble(seg)
  num_cols <- c("id_segment", "linear_feature_id", "blue_line_key", "downstream_route_measure",
                "upstream_route_measure", "length_metre", "gradient", "channel_width", "knw_size", "knw_dist", "grade")
  for (col in num_cols) {
    seg[[col]] <- as.numeric(seg[[col]])
  }
  fd <- seg[[paste0(flag, "_default")]]
  ft <- seg[[paste0(flag, "_tuned")]]
  km <- function(x, len) sum(len[x %in% TRUE]) / 1000
  gkm <- function(x) sum((seg$length_metre * ifelse(is.na(seg$grade), 0, seg$grade))[x %in% TRUE]) / 1000
  classes <- c("0-0.2", "0.2-0.4", "0.4-0.6", "0.6-0.8", "0.8-1")
  per_group <- function(idx, name) {
    fd_i <- fd[idx]
    ft_i <- ft[idx]
    len <- seg$length_metre[idx]
    out <- tibble::tibble(
      watershed_group_code = name, species_code = sp, stage = stage,
      accessible_km = km(seg$accessible[idx], len),
      stored_km = km(seg[[paste0(flag, "_stored")]][idx], len),
      default_km = km(fd_i, len), tuned_km = km(ft_i, len),
      stored_vs_default_differ_km = km(seg[[paste0(flag, "_stored")]][idx] != fd_i, len),
      gained_km = km(ft_i & !fd_i, len), lost_km = km(!ft_i & fd_i, len), kept_km = km(ft_i & fd_i, len),
      gained_n = sum(ft_i & !fd_i), lost_n = sum(!ft_i & fd_i),
      default_graded_km = sum((len * ifelse(is.na(seg$grade[idx]), 0, seg$grade[idx]))[fd_i]) / 1000,
      tuned_graded_km = sum((len * ifelse(is.na(seg$grade[idx]), 0, seg$grade[idx]))[ft_i]) / 1000,
      graded_na_km = km(is.na(seg$grade[idx]) & seg$accessible[idx], len)
    )
    for (cl in classes) {
      out[[paste0("default_km_", cl)]] <- km(fd_i & seg$grade_class[idx] %in% cl, len)
      out[[paste0("tuned_km_", cl)]] <- km(ft_i & seg$grade_class[idx] %in% cl, len)
    }
    out$change_pct <- 100 * (out$tuned_km - out$default_km) / out$default_km
    out
  }
  per <- do.call(rbind, lapply(groups, function(w) per_group(seg$watershed_group_code == w, w)))
  tot <- per_group(rep(TRUE, nrow(seg)), "ALL")
  compare <- rbind(per, tot)
  compare$default_rule <- paste0("width>=", rng$channel_width[1], "|g<=", rng$gradient[2], "|none")
  compare$tuned_rule <- tuned$rule

  # why segments change: from the predicates' parts where the predicates differ; else connectivity or overlay
  chg <- seg[fd != ft, , drop = FALSE]
  pre_d <- chg[[paste0(flag, "_pre_default")]]
  pre_t <- chg[[paste0(flag, "_pre_tuned")]]
  g_def <- !is.na(chg$gradient) & chg$gradient >= 0 & chg$gradient <= rng$gradient[2]
  g_tun <- !is.na(chg$gradient) & chg$gradient >= 0 & chg$gradient <= tuned$grad_max
  w_ok <- !is.na(chg$channel_width) & chg$channel_width >= rng$channel_width[1] & chg$channel_width <= 9999
  size_tun <- if (tuned$size_var == "mad") !is.na(chg$knw_size) & chg$knw_size >= tuned$size_min else
    !is.na(chg$channel_width) & chg$channel_width >= tuned$size_min & chg$channel_width <= 9999
  ex_ok <- !is.na(tuned$exc_q) & !is.na(chg$knw_dist) & chg$knw_dist <= tuned$exc_d
  stream <- chg$edge_type %in% edge_stream
  direction <- ifelse(chg[[paste0(flag, "_tuned")]], "gained", "lost")
  reason <- ifelse(pre_d == pre_t, "connectivity or overlay",
            ifelse(direction == "gained" & stream & g_tun & !size_tun & ex_ok, "exception (size fails, river within D)",
            ifelse(direction == "gained" & stream & size_tun & g_tun & w_ok & !g_def, "gradient between the two maxima",
            ifelse(direction == "gained" & stream & size_tun & g_tun & !w_ok, "size: tuned passes, width fails or NULL",
            ifelse(direction == "lost" & stream & w_ok & g_def & !size_tun & !ex_ok,
                   "size: width passes, tuned fails, no exception",
            ifelse(direction == "lost" & stream & w_ok & g_def & !g_tun, "gradient: tuned maximum lower",
                   "other (river-polygon branch or mixed)"))))))
  ord <- ifelse(chg$stream_order <= 1, "1",
         ifelse(chg$stream_order == 2, "2", ifelse(chg$stream_order == 3, "3", "4+")))
  change <- stats::aggregate(cbind(n_segments = 1, km = chg$length_metre / 1000),
                             by = list(direction = direction, reason = reason, order = ord), FUN = sum)
  change <- tibble::as_tibble(change)
  change$species_code <- sp
  change$stage <- stage
  change$tuned_rule <- tuned$rule

  # FDIS detection on each rule's segments
  checks <- list()
  if (!is.null(visits) && !is.null(visit_species) && stage == "rear") {
    vs <- visit_species[visit_species$species_code == sp & visit_species$status %in% c("present", "absent"),
                        c("site_visit", "present")]
    vv <- merge(visits[, c("site_visit", "watershed_group_code", "id_segment", "edge_type", "area_m2")], vs,
                by = "site_visit")
    vv <- vv[vv$edge_type %in% c(1000, 1050, 1100, 1150, 2000, 2100, 2300, 1250, 1350) & !is.na(vv$area_m2) &
               vv$area_m2 >= 10 & vv$area_m2 <= 10000, , drop = FALSE]
    i <- match(paste(vv$id_segment, vv$watershed_group_code), paste(seg$id_segment, seg$watershed_group_code))
    vv <- vv[!is.na(i), , drop = FALSE]
    i <- i[!is.na(i)]
    for (k in names(preds)) {
      r <- seg[[paste0(flag, "_", k)]][i]
      acc <- seg$accessible[i]
      checks[[k]] <- tibble::tibble(check = "fdis_visits", species_code = sp, stage = stage, rule = k,
                                    segment = c("rearing", "accessible_not_rearing"),
                                    n = c(sum(r), sum(acc & !r)),
                                    n_detect = c(sum(vv$present[r]), sum(vv$present[acc & !r])))
    }
  }
  # outside check: bcfishobs records not from FDIS, by lnk_habitat_validate()'s conventions (0298)
  obs <- DBI::dbGetQuery(conn, sprintf("
    SELECT o.observation_key, o.watershed_group_code, o.blue_line_key, o.downstream_route_measure, o.activity_code,
           o.activity, o.life_stage, o.match_type
    FROM bcfishobs.observations o
    WHERE o.species_code = '%s' AND coalesce(o.source, '') !~ '^FDIS' AND o.watershed_group_code IN (%s)", sp, wsg_in))
  n0 <- nrow(obs)
  obs <- obs[substr(obs$match_type, 1, 1) %in% c("A", "B"), , drop = FALSE]
  if (nrow(obs)) {
    act <- paste(obs$activity_code, obs$activity)
    obs$is_spawn <- grepl("\\bSPL\\b|\\bSPM\\b|\\bS\\b|Spawning", act)
    obs$is_rear <- grepl("\\bR\\b|\\bREA\\b|Rearing", act) |
      grepl("Fry|Parr|Juvenile", ifelse(is.na(obs$life_stage), "", obs$life_stage))
    obs$m <- round(as.numeric(obs$downstream_route_measure))
    loc <- stats::aggregate(cbind(spawn = obs$is_spawn, rear = obs$is_rear, n_records = 1),
                            by = list(watershed_group_code = obs$watershed_group_code,
                                      blue_line_key = as.numeric(obs$blue_line_key), m = obs$m),
                            FUN = function(x) if (is.logical(x)) any(x) else sum(x))
    loc$spawn <- loc$spawn > 0
    loc$rear <- loc$rear > 0
    loc <- if (stage == "rear") {
      loc[!(loc$spawn & !loc$rear), , drop = FALSE]
    } else {
      loc[loc$spawn | !loc$rear, , drop = FALSE]
    }
    loc$loc_id <- seq_len(nrow(loc))
    DBI::dbWriteTable(conn, "tmp_knw_loc", loc, temporary = TRUE, overwrite = TRUE)
    pl <- DBI::dbGetQuery(conn, sprintf("
      SELECT DISTINCT ON (t.loc_id) t.loc_id, s.id_segment, s.watershed_group_code
      FROM tmp_knw_loc t
      JOIN %1$s.streams s ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
       AND ((s.downstream_route_measure BETWEEN t.m - 1 AND t.m + 1)
            OR (t.m >= s.downstream_route_measure AND t.m < s.upstream_route_measure))
      WHERE s.watershed_group_code IN (%2$s)
      ORDER BY t.loc_id, (s.downstream_route_measure BETWEEN t.m - 1 AND t.m + 1) DESC,
               s.downstream_route_measure DESC, s.id_segment",
      schema, wsg_in))
    i <- match(paste(pl$id_segment, pl$watershed_group_code), paste(seg$id_segment, seg$watershed_group_code))
    on_stream <- seg$edge_type[i] %in% edge_stream & seg$accessible[i]
    ls <- i[on_stream]
    acc_km <- km(seg$accessible & seg$edge_type %in% edge_stream, seg$length_metre)
    ks <- function(k) km(seg[[paste0(flag, "_", k)]] & seg$edge_type %in% edge_stream, seg$length_metre) / acc_km
    lift <- function(k, idx = seq_along(ls)) mean(seg[[paste0(flag, "_", k)]][ls[idx]]) / ks(k)
    set.seed(seed_boot)
    bs <- t(vapply(seq_len(n_boot), function(b) {
      idx <- sample.int(length(ls), length(ls), replace = TRUE)
      c(default = lift("default", idx), tuned = lift("tuned", idx))
    }, numeric(2)))
    q <- function(x, p) unname(stats::quantile(x, p))
    checks$outside <- tibble::tibble(
      check = "bcfishobs_outside", species_code = sp, stage = stage,
      rule = c("default", "tuned", "tuned_minus_default"),
      segment = NA_character_, n = length(ls),
      n_detect = c(sum(seg[[paste0(flag, "_default")]][ls]), sum(seg[[paste0(flag, "_tuned")]][ls]), NA),
      km_share = c(ks("default"), ks("tuned"), NA),
      lift = c(lift("default"), lift("tuned"), lift("tuned") - lift("default")),
      lift_lo = c(q(bs[, "default"], 0.025), q(bs[, "tuned"], 0.025), q(bs[, "tuned"] - bs[, "default"], 0.025)),
      lift_hi = c(q(bs[, "default"], 0.975), q(bs[, "tuned"], 0.975), q(bs[, "tuned"] - bs[, "default"], 0.975)))
    say("Outside check: %d non-FDIS %s records; %d locations placed, %d on accessible stream edges.",
        n0, sp, nrow(pl), length(ls))
  }
  DBI::dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", scratch))
  list(compare = compare, change = change, checks = do.call(rbind, lapply(checks, function(x) {
    for (c in c("km_share", "lift", "lift_lo", "lift_hi")) if (!c %in% names(x)) x[[c]] <- NA_real_
    x
  })), segments = seg, log = log)
}
