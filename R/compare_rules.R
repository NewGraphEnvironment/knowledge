#' Set a tuned rule beside link's `default` on link's own segments
#'
#' `scripts/0298`'s comparison for any species and stage. Each rule goes through
#' the three stages that make link's stored flags, on scratch copies of each
#' group: the predicate gated by access (the habitat table's `accessible` and
#' `streams_access.access_<sp> > 0` together, the one gate [knw_link_place()],
#' [knw_link_segments()] and the grades use; the km the gate removes from the
#' habitat table's `accessible` is reported as `access_gate_differ_km`),
#' `fresh::frs_habitat_overlay()`
#' with link's user-habitat rows for the species, and fresh's connectivity pass
#' (`.frs_run_connectivity()` with link's `default` parameters), rearing and
#' spawning together, because the connectivity pass reads spawning. Regenerated
#' `default` is reported against the stored flags, never compared to them.
#'
#' `default`'s predicate is `fresh::frs_habitat_predicates()` on the `configs/default`
#' in `link_dir`, under each group's size model (`parameters_habitat_method.csv`;
#' `cw` where a group is not listed). Since link 0.67.0 a rule can carry a
#' near-river pair (a river of at least some size within some distance
#' downstream, fresh#263), so where the species' rules resolve to one, the pairs
#' are walked on the scratch copy with `fresh::frs_near_river()` first, exactly
#' as `frs_habitat_classify()` walks them, and the predicate reads that table.
#'
#' A tuned rule is the same predicate with its gradient maximum and, under a
#' width rule, its width floor substituted, and with two branches replaced by the
#' rule's own tests, in one of three **structures** (#73, link#364):
#' - on the **stream branch** (a stream edge in no river polygon, wetland of at
#'   least 1 ha or lake of at least 100 ha), a segment is in when its gradient is
#'   inside the maximum and either the size test holds (width, or MAD at least
#'   the floor) or the exception does: a river of the rule's `exc_q` lies within
#'   `exc_d` m downstream (`dist_m`, walked from the segment's downstream end to
#'   the river's bank by [knw_grade_species()]), on a segment with a local
#'   watershed code, the only segments link's own walk measures;
#' - on **through-wetland lines** (FWA edge types 1050 and 1150) the structures
#'   differ: `free` keeps the free pass link's `default` gave them before 0.67.0
#'   (in, with no test, inside a wetland of at least 1 ha); `door` puts them
#'   through the stream branch's door, size or exception (link's
#'   `rear_near_river = both`); `door_wetland` puts them through the door with the
#'   exception while the stream branch keeps the size test alone (link's
#'   `wetland_flow`, `default`'s choice for chinook).
#' The river, wetland-polygon and lake branches stay fresh's. A species whose
#' `default` has no through-wetland rule (grayling) is compared under `door` alone,
#' with those lines out as `default` has them; one whose tuned rule carries no
#' exception under `free` and `door`, since `door_wetland` would equal `door`;
#' otherwise under all three. The structure named `tuned_as` is also reported as
#' `tuned`, the name the maps and the article read. When a tuned rule under `door`
#' equals `default` and `default` resolves no pair, the injected form must equal
#' fresh's own predicate on every segment, which the call asserts.
#'
#' @param connector a function returning a `DBI` connection.
#' @param schema `character(1)` link persist schema.
#' @param species `character(1)` species code.
#' @param stage `"rear"` or `"spawn"`: the stage the tuned rule changes.
#' @param tuned one row of the scored grid (the recommended rule).
#' @param groups `character` watershed groups to compare.
#' @param link_dir `character(1)` a directory holding link's `configs/default`
#'   files: `parameters_habitat_thresholds.csv`, `rules.yaml`,
#'   `parameters_fresh.csv`, `overrides/user_habitat_classification.csv`, and,
#'   read when present, `parameters_habitat_method.csv` and `dimensions.csv`.
#' @param grades the species × stage grade table [knw_grade_species()] wrote
#'   (`id_segment`, `watershed_group_code`, `size`, `dist_m`, `grade`,
#'   `grade_class`, and `target_in_group` when the table carries it), for the
#'   MAD with parent fallback, the exception distance and the graded km.
#' @param visits,visit_species the build's `visits_link` and `visits_species`
#'   tables, for the FDIS detection check (`NULL` to skip).
#' @param scratch `character(1)` the scratch schema (dropped at the end).
#' @param n_boot,seed_boot the bcfishobs lift's bootstrap.
#' @param structures `NULL` (chosen as above) or a subset of `c("free", "door",
#'   "door_wetland")`.
#' @param tuned_as `character(1)` the structure reported as `tuned`.
#' @param config_sha `character(1)` the link commit `link_dir` was read at,
#'   carried on every output row (`NA` when unknown).
#' @param workers `integer(1)` socket workers for the groups (#87). The groups
#'   are split into `workers` bins balanced by segment count, largest first;
#'   each bin runs on its own connection in its own scratch schema
#'   (`<scratch>_w<i>`, dropped when it ends), reading the grades and the
#'   user-habitat rows this call writes once to `scratch`. A group's error
#'   stops its bin and is raised naming the group. `1` runs the one bin in this
#'   process. `connector` and its environment travel to every worker, so build
#'   it where it holds nothing large.
#' @return A list of `tibble`s: `compare` (per structure, group and total: km by
#'   rule, graded km, km by grade class, gained and lost, and the km gained by an
#'   exception whose river lies in another watershed group), `change` (km gained
#'   and lost by structure, reason and stream order), `checks` (FDIS detection on
#'   each rule's segments and the bcfishobs lift, per structure), `segments` (the
#'   per-segment flags under `default` and each structure, with `tuned` the
#'   `tuned_as` structure, and the `default` branch each segment lies on), `log`
#'   lines, one of them per stage with its minutes, `timing`, the minutes of
#'   each stage by name (#110), and `stage_minutes`, a data frame of the
#'   worker-minutes each rule's classify, overlay, connect and read took, summed
#'   over the groups, beside the steps the rules share (the scratch copy, the
#'   near-river walk and the default check), with each one's share (#101).
#' @export
#' @examples
#' \dontrun{
#' pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
#' cmp <- knw_compare_rules(pg, "fresh_default", "CH", "rear", pick, c("BULK", "MORR"),
#'                          link_dir, grades)
#' cmp$compare[cmp$compare$watershed_group_code == "ALL", ]
#' }
knw_compare_rules <- function(connector, schema, species, stage, tuned, groups, link_dir, grades,
                              visits = NULL, visit_species = NULL, scratch = "knw_compare_scratch",
                              n_boot = 200L, seed_boot = 542L, structures = NULL, tuned_as = "door",
                              config_sha = NA_character_, workers = 1L) {
  chk::chk_function(connector)
  chk::chk_string(schema)
  chk::chk_string(species)
  stage <- match.arg(stage, c("rear", "spawn"))
  chk::check_names(tuned, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d"))
  chk::chk_character(groups)
  chk::chk_dir(link_dir)
  chk::chk_data(grades)
  chk::check_names(grades, c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class"))
  chk::chk_string(tuned_as)
  chk::chk_whole_number(workers)
  chk::chk_gt(workers, 0)
  if (!requireNamespace("fresh", quietly = TRUE)) stop("fresh is needed", call. = FALSE)
  sp <- toupper(species)
  s <- tolower(species)
  log <- character()
  say <- function(...) log <<- c(log, sprintf(...))

  f_thr <- file.path(link_dir, "parameters_habitat_thresholds.csv")
  f_rules <- file.path(link_dir, "rules.yaml")
  f_fresh <- file.path(link_dir, "parameters_fresh.csv")
  f_uhc <- file.path(link_dir, "overrides", "user_habitat_classification.csv")
  f_method <- file.path(link_dir, "parameters_habitat_method.csv")
  f_dims <- file.path(link_dir, "dimensions.csv")
  for (f in c(f_thr, f_rules, f_fresh, f_uhc)) if (!file.exists(f)) stop("missing ", f, call. = FALSE)
  params <- fresh::frs_params(csv = f_thr, rules_yaml = f_rules)
  if (is.null(params[[sp]])) stop("link's default has no parameters for ", sp, call. = FALSE)
  params_fresh <- utils::read.csv(f_fresh, stringsAsFactors = FALSE)
  uhc <- utils::read.csv(f_uhc, stringsAsFactors = FALSE)
  uhc <- uhc[uhc$species_code == sp, , drop = FALSE]
  method <- if (file.exists(f_method)) utils::read.csv(f_method, stringsAsFactors = FALSE) else NULL
  model_of <- function(w) {
    m <- if (is.null(method)) character() else method$model[method$watershed_group_code == w]
    if (length(m) == 1L && m %in% c("cw", "mad")) m else "cw"
  }
  dims <- if (file.exists(f_dims)) utils::read.csv(f_dims, stringsAsFactors = FALSE) else NULL
  # the species' own branches, from fresh's rule list: the stream rule's edge types, and the river, wetland
  # and lake rules' polygons and area floors (a species without a rule of a type has no such branch)
  br <- .knw_fresh_branches(params[[sp]], stage)
  edge_stream <- br$edge_stream
  flag <- if (stage == "rear") "rearing" else "spawning"
  other <- if (stage == "rear") "spawn" else "rear"
  structures <- .knw_compare_structures(br, tuned, structures)
  if (!tuned_as %in% structures) stop("tuned_as must be one of the structures run: ", paste(structures, collapse = ", "), call. = FALSE)

  # the near-river pairs default's rules resolve to under each model (fresh's own resolver, so the walk is the
  # one frs_habitat_classify() would make), and the pairs' table on the scratch copy
  specs_of <- utils::getFromNamespace(".frs_near_river_specs", "fresh")
  specs <- list(cw = specs_of(params, sp, "cw"), mad = specs_of(params, sp, "mad"))
  pred_of <- function(ps, model, near_tbl) {
    fresh::frs_habitat_predicates(list(species_code = sp, params_sp = ps, spawn_gradient_min = 0,
                                       spawn_gradient_max = ps$ranges$spawn$gradient[2]), model,
                                  near_river_table = if (nrow(specs[[model]])) near_tbl else NULL)
  }
  # the tuned rule's base: fresh's predicate with the tuned gradient (and width), and the through-wetland rule
  # taken out, because every structure writes that branch itself
  ps_t <- params[[sp]]
  ps_t$ranges[[stage]]$gradient[2] <- tuned$grad_max
  if (tuned$size_var == "width") ps_t$ranges[[stage]]$channel_width <- c(tuned$size_min, 9999)
  ps_t$rules[[stage]] <- Filter(function(r) !.knw_is_wetland_line_rule(r), ps_t$rules[[stage]])
  preds_for <- function(model, near_tbl) {
    p_default <- pred_of(params[[sp]], model, near_tbl)
    p_tuned_base <- pred_of(ps_t, model, near_tbl)
    size_ok <- if (tuned$size_var == "width") {
      sprintf("coalesce(s.channel_width BETWEEN %s AND 9999, FALSE)", tuned$size_min)
    } else {
      sprintf("coalesce(s.knw_size >= %s, FALSE)", tuned$size_min)
    }
    # the exception applies where link's own walk would measure a distance: a segment with a local code
    ex <- if (is.na(tuned$exc_q)) "FALSE" else {
      sprintf("(coalesce(s.knw_dist <= %s, FALSE) AND s.localcode_ltree IS NOT NULL)", tuned$exc_d)
    }
    grad_ok <- sprintf("coalesce(s.gradient BETWEEN 0 AND %s, FALSE)", tuned$grad_max)
    door_ex <- sprintf("(%s AND (%s OR %s))", grad_ok, size_ok, ex)
    door_noex <- sprintf("(%s AND %s)", grad_ok, size_ok)
    free_wl <- "coalesce(s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb WHERE t = 'W'), FALSE)"
    arms <- list(
      free = c(stream = door_ex, wetland = if (br$wetland_line) free_wl else "FALSE"),
      door = c(stream = door_ex, wetland = if (br$wetland_line) door_ex else "FALSE"),
      door_wetland = c(stream = door_noex, wetland = if (br$wetland_line) door_ex else "FALSE"))
    out <- list(default = sprintf("coalesce((%s), FALSE)", p_default[[stage]]),
                other = sprintf("coalesce((%s), FALSE)", p_default[[other]]))
    for (st in structures) {
      out[[st]] <- sprintf("(CASE WHEN %1$s THEN %2$s WHEN s.edge_type IN (1050, 1150) THEN %3$s ELSE coalesce((%4$s), FALSE) END)",
                           .knw_stream_branch_sql(br, edge_stream), arms[[st]][["stream"]], arms[[st]][["wetland"]],
                           p_tuned_base[[stage]])
    }
    out
  }
  wb_sql <- .knw_wb_sql(br)
  rng <- params[[sp]]$ranges[[stage]]
  is_default_rule <- tuned$size_var == "width" && isTRUE(all.equal(tuned$size_min, rng$channel_width[1])) &&
    isTRUE(all.equal(tuned$grad_max, rng$gradient[2])) && is.na(tuned$exc_q)
  default_rule <- .knw_default_rule_label(rng, specs, dims, sp, stage)

  # one timing line per stage, after the local reads (#110): what a remote link costs each stage
  tm <- .knw_timer()
  conn <- connector()
  on.exit(try(DBI::dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", scratch)), silent = TRUE), add = TRUE)
  on.exit(try(DBI::dbDisconnect(conn), silent = TRUE), add = TRUE)
  DBI::dbExecute(conn, wb_sql)
  DBI::dbExecute(conn, sprintf("CREATE SCHEMA IF NOT EXISTS %s", scratch))
  DBI::dbWriteTable(conn, DBI::Id(schema = scratch, table = "uhc"), uhc, overwrite = TRUE)
  g_cols <- intersect(c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class", "target_in_group"),
                      names(grades))
  g_sp <- grades[grades$watershed_group_code %in% groups, g_cols]
  if (!"target_in_group" %in% names(g_sp)) g_sp$target_in_group <- NA
  DBI::dbWriteTable(conn, DBI::Id(schema = scratch, table = "grades"), as.data.frame(g_sp), overwrite = TRUE)
  DBI::dbExecute(conn, sprintf("CREATE INDEX ON %s.grades (id_segment, watershed_group_code)", scratch))
  say("%s %s: %d groups; link configs at %s; default %s; tuned %s under %s (reported as tuned: %s).", sp, stage,
      length(groups), config_sha, default_rule, tuned$rule, paste(structures, collapse = ", "), tuned_as)
  say("Scratch setup (waterbodies, user habitat, grades written): %.1f min.", tm$tick("scratch_setup"))

  rule_names <- c("default", structures)
  # the groups in bins balanced by segment count, one bin per worker, each with its own scratch schema and
  # predicates that read that schema's near-river table
  n_sql <- paste("SELECT watershed_group_code AS w, count(*)::int AS n FROM %s.streams_habitat_%s",
                 "WHERE watershed_group_code IN (%s) GROUP BY 1")
  n_seg <- DBI::dbGetQuery(conn, sprintf(n_sql, schema, s, paste0("'", groups, "'", collapse = ",")))
  bins <- .knw_bin_groups(stats::setNames(n_seg$n[match(groups, n_seg$w)], groups), workers)
  models <- vapply(groups, model_of, character(1))
  jobs <- lapply(seq_along(bins), function(i) {
    ws <- sprintf("%s_w%d", scratch, i)
    near_tbl <- paste0(ws, ".near_river")
    list(groups = bins[[i]], scratch_w = ws,
         preds = lapply(c(cw = "cw", mad = "mad"), preds_for, near_tbl = near_tbl))
  })
  bin_args <- list(connector = connector, schema = schema, s = s, sp = sp, stage = stage, scratch = scratch,
                   models = models, specs = specs, wb_sql = wb_sql, rule_names = rule_names,
                   assert_default = is_default_rule && "door" %in% structures,
                   uhc_types = if (nrow(uhc)) intersect(names(uhc), c("spawning", "rearing", "lake_rearing",
                                                                      "wetland_rearing")) else character(),
                   params = params, params_fresh = params_fresh)
  # self-contained: it runs on a socket worker, where this package's names resolve to the installed copy or none.
  # Both functions get the global environment, so serialising them ships neither this package's namespace nor
  # this call's frame (which holds the whole grade table) to every worker
  bin_fun <- .knw_compare_bin
  environment(bin_fun) <- globalenv()
  run_job <- function(job, bin_fun, bin_args) do.call(bin_fun, c(job, bin_args))
  environment(run_job) <- globalenv()
  res <- if (length(jobs) > 1L) {
    cl <- parallel::makeCluster(length(jobs))
    tryCatch(parallel::parLapplyLB(cl, jobs, run_job, bin_fun = bin_fun, bin_args = bin_args),
             finally = parallel::stopCluster(cl))
  } else {
    lapply(jobs, run_job, bin_fun = bin_fun, bin_args = bin_args)
  }
  err <- Filter(function(r) !is.null(r$error), res)
  if (length(err)) stop(err[[1]]$error, call. = FALSE)
  flags <- unlist(lapply(res, `[[`, "flags"), recursive = FALSE)
  walk_s <- sum(vapply(res, `[[`, numeric(1), "walk_s"))
  say(paste("Classify, overlay and connect: %d groups x %d rules on %d worker%s, %.1f min",
            "(near-river walks %.1f min summed over workers)."),
      length(groups), length(rule_names), length(jobs), if (length(jobs) == 1L) "" else "s",
      tm$tick("classify_overlay_connect"), walk_s / 60)
  # each rule's own steps and the shared ones, in worker-minutes summed over the groups (#101, #112): the stage's wall
  # minutes above are these over the workers, plus the setup no step times
  stage_minutes <- .knw_stage_minutes(lapply(res, `[[`, "secs"))
  for (k in unique(stage_minutes$rule)) {
    x <- stage_minutes[stage_minutes$rule == k, ]
    say("Stage minutes, %s: %s worker-min, %.1f in all (%.1f%% of the %.1f worker-min timed).", k,
        paste(sprintf("%s %.1f", x$step, x$minutes), collapse = ", "), sum(x$minutes), 100 * sum(x$share),
        sum(stage_minutes$minutes))
  }
  # which rules' predicates read the near-river table, so whether a rule's flags kept from a run would spare the walk
  near_rules <- unique(unlist(lapply(jobs[[1]]$preds, function(p) {
    names(p)[vapply(p, function(x) grepl(".near_river", x, fixed = TRUE), logical(1))]
  })))
  say("Rules whose predicate reads the near-river table: %s.",
      if (length(near_rules)) paste(near_rules, collapse = ", ") else "none")
  wsg_in <- paste0("'", groups, "'", collapse = ",")
  # the default branch each segment lies on, as link's rules name them, and whether a user-habitat reach covers it
  in_uhc_seg <- if (nrow(uhc) && flag %in% names(uhc)) {
    sprintf("EXISTS (SELECT 1 FROM %s.uhc u WHERE u.blue_line_key = s.blue_line_key AND u.%s = 1
                    AND s.downstream_route_measure < u.upstream_route_measure
                    AND s.upstream_route_measure > u.downstream_route_measure)",
            scratch, flag)
  } else {
    "FALSE"
  }
  seg <- DBI::dbGetQuery(conn, sprintf("
    SELECT s.id_segment, s.watershed_group_code, s.linear_feature_id, s.blue_line_key, s.downstream_route_measure,
           s.upstream_route_measure, s.edge_type, s.stream_order, s.length_metre, s.gradient, s.channel_width,
           (h.accessible AND coalesce(a.access_%2$s > 0, FALSE)) AS accessible, h.accessible AS accessible_stored,
           h.rearing AS rearing_stored, h.spawning AS spawning_stored,
           g.size AS knw_size, g.dist_m AS knw_dist, g.grade, g.grade_class, g.target_in_group,
           s.localcode_ltree IS NOT NULL AS localcode_present,
           CASE WHEN s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb WHERE t = 'R') THEN 'river polygon'
                WHEN s.edge_type IN (1050, 1150) THEN 'through wetland'
                WHEN s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb WHERE t = 'W') THEN 'wetland polygon'
                WHEN s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb WHERE t IN ('L', 'M')) THEN 'lake'
                WHEN s.edge_type IN (%5$s) THEN 'stream line'
                ELSE 'other' END AS link_branch,
           %6$s AS user_habitat
    FROM %1$s.streams s
    JOIN %1$s.streams_habitat_%2$s h ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
    LEFT JOIN %1$s.streams_access a ON a.id_segment = s.id_segment AND a.watershed_group_code = s.watershed_group_code
    LEFT JOIN %3$s.grades g ON g.id_segment = s.id_segment AND g.watershed_group_code = s.watershed_group_code
    WHERE s.watershed_group_code IN (%4$s)",
    schema, s, scratch, wsg_in, paste(edge_stream, collapse = ", "), in_uhc_seg))
  say("Segment read: %d segments, %.1f min.", nrow(seg), tm$tick("segment_read"))
  fl <- do.call(rbind, flags)
  for (k in rule_names) {
    fk <- fl[fl$rule == k, ]
    i <- match(paste(seg$id_segment, seg$watershed_group_code), paste(fk$id_segment, fk$watershed_group_code))
    seg[[paste0(flag, "_", k)]] <- fk[[flag]][i]
    seg[[paste0(flag, "_pre_", k)]] <- fk[[paste0(flag, "_pre_connect")]][i]
    if (anyNA(seg[[paste0(flag, "_", k)]])) stop("a segment has no regenerated flag under ", k, call. = FALSE)
  }
  seg[[paste0(flag, "_tuned")]] <- seg[[paste0(flag, "_", tuned_as)]]
  seg[[paste0(flag, "_pre_tuned")]] <- seg[[paste0(flag, "_pre_", tuned_as)]]
  seg <- tibble::as_tibble(seg)
  num_cols <- c("id_segment", "linear_feature_id", "blue_line_key", "downstream_route_measure",
                "upstream_route_measure", "length_metre", "gradient", "channel_width", "knw_size", "knw_dist", "grade")
  for (col in num_cols) {
    seg[[col]] <- as.numeric(seg[[col]])
  }
  seg$tuned_structure <- tuned_as
  fd <- seg[[paste0(flag, "_default")]]
  km <- function(x, len) sum(len[x %in% TRUE]) / 1000
  classes <- c("0-0.2", "0.2-0.4", "0.4-0.6", "0.6-0.8", "0.8-1")
  # the tuned rule's own tests per segment, for the change reasons and the other-group count
  g_def <- !is.na(seg$gradient) & seg$gradient >= 0 & seg$gradient <= rng$gradient[2]
  g_tun <- !is.na(seg$gradient) & seg$gradient >= 0 & seg$gradient <= tuned$grad_max
  w_ok <- !is.na(seg$channel_width) & seg$channel_width >= rng$channel_width[1] & seg$channel_width <= 9999
  size_tun <- if (tuned$size_var == "mad") !is.na(seg$knw_size) & seg$knw_size >= tuned$size_min else
    !is.na(seg$channel_width) & seg$channel_width >= tuned$size_min & seg$channel_width <= 9999
  ex_ok <- !is.na(tuned$exc_q) & !is.na(seg$knw_dist) & seg$knw_dist <= tuned$exc_d & seg$localcode_present %in% TRUE
  stream <- seg$edge_type %in% edge_stream
  # a key whose grades were withheld (0320, #73) has none: its graded km are NA, not 0
  graded <- any(!is.na(seg$grade))
  per_group <- function(st, idx, name) {
    ft <- seg[[paste0(flag, "_", st)]]
    fd_i <- fd[idx]
    ft_i <- ft[idx]
    len <- seg$length_metre[idx]
    graded_km <- function(f) {
      if (graded) sum((len * ifelse(is.na(seg$grade[idx]), 0, seg$grade[idx]))[f]) / 1000 else NA_real_
    }
    out <- tibble::tibble(
      watershed_group_code = name, species_code = sp, stage = stage, structure = st,
      accessible_km = km(seg$accessible[idx], len),
      access_gate_differ_km = km(seg$accessible[idx] != (seg$accessible_stored[idx] %in% TRUE), len),
      stored_km = km(seg[[paste0(flag, "_stored")]][idx], len),
      default_km = km(fd_i, len), tuned_km = km(ft_i, len),
      stored_vs_default_differ_km = km(seg[[paste0(flag, "_stored")]][idx] != fd_i, len),
      gained_km = km(ft_i & !fd_i, len), lost_km = km(!ft_i & fd_i, len), kept_km = km(ft_i & fd_i, len),
      gained_n = sum(ft_i & !fd_i), lost_n = sum(!ft_i & fd_i),
      # gained by the exception alone (the size test fails) through a river in another watershed group, which
      # link's own walk, one group's table at a time, would not find
      gained_exception_km = km(ft_i & !fd_i & !size_tun[idx] & ex_ok[idx], len),
      gained_exception_other_group_km = km(ft_i & !fd_i & !size_tun[idx] & ex_ok[idx] &
                                             seg$target_in_group[idx] %in% FALSE, len),
      default_graded_km = graded_km(fd_i), tuned_graded_km = graded_km(ft_i),
      graded_na_km = km(is.na(seg$grade[idx]) & seg$accessible[idx], len)
    )
    for (cl in classes) {
      out[[paste0("default_km_", cl)]] <- if (graded) km(fd_i & seg$grade_class[idx] %in% cl, len) else NA_real_
      out[[paste0("tuned_km_", cl)]] <- if (graded) km(ft_i & seg$grade_class[idx] %in% cl, len) else NA_real_
    }
    out$change_pct <- 100 * (out$tuned_km - out$default_km) / out$default_km
    out
  }
  compare <- do.call(rbind, lapply(structures, function(st) {
    rbind(do.call(rbind, lapply(groups, function(w) per_group(st, seg$watershed_group_code == w, w))),
          per_group(st, rep(TRUE, nrow(seg)), "ALL"))
  }))
  compare$default_rule <- default_rule
  compare$tuned_rule <- tuned$rule
  compare$tuned_structure <- tuned_as
  compare$config_sha <- config_sha

  # why segments change: from the predicates' parts where the predicates differ; else connectivity or overlay
  change <- do.call(rbind, lapply(structures, function(st) {
    ft <- seg[[paste0(flag, "_", st)]]
    ix <- which(fd != ft)
    chg <- seg[ix, , drop = FALSE]
    pre_d <- chg[[paste0(flag, "_pre_default")]]
    pre_t <- chg[[paste0(flag, "_pre_", st)]]
    gained <- ft[ix]
    wl <- chg$edge_type %in% c(1050L, 1150L)
    st_ <- stream[ix]
    gt <- g_tun[ix]
    gd <- g_def[ix]
    sz <- size_tun[ix]
    wo <- w_ok[ix]
    ex <- ex_ok[ix]
    direction <- ifelse(gained, "gained", "lost")
    reason <- rep("other (river-polygon branch or mixed)", length(ix))
    reason[!gained & st_ & wo & gd & !gt] <- "gradient: tuned maximum lower"
    reason[!gained & st_ & wo & gd & !sz & !ex] <- "size: width passes, tuned fails, no exception"
    reason[gained & st_ & sz & gt & !wo] <- "size: tuned passes, width fails or NULL"
    reason[gained & st_ & sz & gt & wo & !gd] <- "gradient between the two maxima"
    reason[gained & st_ & gt & !sz & ex] <- "exception (size fails, river within D)"
    reason[wl & !gained] <- "through-wetland line: tuned structure drops"
    reason[wl & gained] <- "through-wetland line: tuned structure admits"
    reason[pre_d == pre_t] <- "connectivity or overlay"
    ord <- ifelse(chg$stream_order <= 1, "1",
           ifelse(chg$stream_order == 2, "2", ifelse(chg$stream_order == 3, "3", "4+")))
    out <- if (nrow(chg)) {
      tibble::as_tibble(stats::aggregate(cbind(n_segments = 1, km = chg$length_metre / 1000),
                                         by = list(direction = direction, reason = reason, order = ord), FUN = sum))
    } else {
      tibble::tibble(direction = character(), reason = character(), order = character(), n_segments = numeric(),
                     km = numeric())
    }
    out$structure <- st
    out
  }))
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
    for (k in rule_names) {
      r <- seg[[paste0(flag, "_", k)]][i]
      acc <- seg$accessible[i]
      checks[[k]] <- tibble::tibble(check = "fdis_visits", species_code = sp, stage = stage, rule = k,
                                    segment = c("rearing", "accessible_not_rearing"),
                                    n = c(sum(r), sum(acc & !r)),
                                    n_detect = c(sum(vv$present[r]), sum(vv$present[acc & !r])))
    }
  }
  say("Summaries (km by rule, change by reason, FDIS visits): %.1f min.", tm$tick("summaries"))
  # outside check: bcfishobs records not from FDIS, by lnk_habitat_validate()'s conventions (0298)
  obs <- DBI::dbGetQuery(conn, sprintf("
    SELECT o.observation_key, o.watershed_group_code, o.blue_line_key, o.downstream_route_measure, o.activity_code,
           o.activity, o.life_stage, o.match_type
    FROM bcfishobs.observations o
    WHERE o.species_code = '%s' AND coalesce(o.source, '') !~ '^FDIS' AND o.watershed_group_code IN (%s)", sp, wsg_in))
  n0 <- nrow(obs)
  obs <- obs[substr(obs$match_type, 1, 1) %in% c("A", "B"), , drop = FALSE]
  if (nrow(obs) > 1L) {
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
    # 0298: a location inside a user-habitat overlay reach for the stage is captured by construction and left out
    in_uhc <- if (nrow(uhc) && flag %in% names(uhc)) {
      sprintf("EXISTS (SELECT 1 FROM %s.uhc u WHERE u.blue_line_key = t.blue_line_key AND u.%s = 1
                      AND t.m BETWEEN u.downstream_route_measure AND u.upstream_route_measure)", scratch, flag)
    } else {
      "FALSE"
    }
    pl <- DBI::dbGetQuery(conn, sprintf("
      SELECT DISTINCT ON (t.loc_id) t.loc_id, s.id_segment, s.watershed_group_code, %3$s AS in_uhc
      FROM tmp_knw_loc t
      JOIN %1$s.streams s ON s.watershed_group_code = t.watershed_group_code AND s.blue_line_key = t.blue_line_key
       AND ((s.downstream_route_measure BETWEEN t.m - 1 AND t.m + 1)
            OR (t.m >= s.downstream_route_measure AND t.m < s.upstream_route_measure))
      WHERE s.watershed_group_code IN (%2$s)
      ORDER BY t.loc_id, (s.downstream_route_measure BETWEEN t.m - 1 AND t.m + 1) DESC,
               s.downstream_route_measure DESC, s.id_segment",
      schema, wsg_in, in_uhc))
    n_uhc <- sum(pl$in_uhc %in% TRUE)
    pl <- pl[!(pl$in_uhc %in% TRUE), , drop = FALSE]
    i <- match(paste(pl$id_segment, pl$watershed_group_code), paste(seg$id_segment, seg$watershed_group_code))
    on_stream <- seg$edge_type[i] %in% edge_stream & seg$accessible[i]
    ls <- i[on_stream]
    acc_km <- km(seg$accessible & seg$edge_type %in% edge_stream, seg$length_metre)
    ks <- function(k) km(seg[[paste0(flag, "_", k)]] & seg$edge_type %in% edge_stream, seg$length_metre) / acc_km
    lift <- function(k, idx = seq_along(ls)) mean(seg[[paste0(flag, "_", k)]][ls[idx]]) / ks(k)
    set.seed(seed_boot)
    bs <- t(vapply(seq_len(n_boot), function(b) {
      idx <- sample.int(length(ls), length(ls), replace = TRUE)
      vapply(rule_names, function(k) lift(k, idx), numeric(1))
    }, numeric(length(rule_names))))
    colnames(bs) <- rule_names
    q <- function(x, p) unname(stats::quantile(x, p))
    row_of <- function(k) {
      tibble::tibble(check = "bcfishobs_outside", species_code = sp, stage = stage, rule = k, segment = NA_character_,
                     n = length(ls), n_detect = sum(seg[[paste0(flag, "_", k)]][ls]), km_share = ks(k), lift = lift(k),
                     lift_lo = q(bs[, k], 0.025), lift_hi = q(bs[, k], 0.975))
    }
    diff_of <- function(st) {
      d <- bs[, st] - bs[, "default"]
      tibble::tibble(check = "bcfishobs_outside", species_code = sp, stage = stage, rule = paste0(st, "_minus_default"),
                     segment = NA_character_, n = length(ls), n_detect = NA_integer_, km_share = NA_real_,
                     lift = lift(st) - lift("default"), lift_lo = q(d, 0.025), lift_hi = q(d, 0.975))
    }
    checks$outside <- do.call(rbind, c(lapply(rule_names, row_of), lapply(structures, diff_of)))
    say(paste("Outside check: %d non-FDIS %s records; %d locations placed (%d inside an overlay reach left out),",
              "%d on accessible stream edges."), n0, sp, nrow(pl) + n_uhc, n_uhc, length(ls))
  }
  say("Outside check (bcfishobs records): %.1f min.", tm$tick("outside_check"))
  DBI::dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", scratch))
  say("Scratch drop: %.1f min.", tm$tick("scratch_drop"))
  checks <- do.call(rbind, lapply(checks, function(x) {
    for (c in c("km_share", "lift", "lift_lo", "lift_hi")) if (!c %in% names(x)) x[[c]] <- NA_real_
    x
  }))
  if (!is.null(checks)) checks$tuned_structure <- tuned_as
  list(compare = compare, change = change, checks = checks, segments = seg, log = log, timing = tm$ticks(),
       stage_minutes = stage_minutes)
}

# The bins' step seconds (.knw_compare_bin()'s `secs`, named `<rule>|<step>`) summed into one row per rule and step:
# worker-minutes and the share of every timed minute. Every step a bin names keeps its row, at zero if it never ran,
# in the order the first bin names them
.knw_stage_minutes <- function(secs) {
  secs <- Filter(Negate(is.null), secs)
  if (!length(secs)) stop("no bin returned its step times", call. = FALSE)
  steps <- unique(unlist(lapply(secs, names)))
  tot <- vapply(steps, function(k) sum(vapply(secs, function(x) if (k %in% names(x)) x[[k]] else 0, numeric(1))),
                numeric(1))
  m <- unname(tot) / 60
  parts <- strsplit(steps, "|", fixed = TRUE)
  data.frame(rule = vapply(parts, `[`, character(1), 1L), step = vapply(parts, `[`, character(1), 2L),
             minutes = m, share = if (sum(m) > 0) m / sum(m) else rep(0, length(m)), stringsAsFactors = FALSE)
}

# A stage timer: tick(label) returns the minutes since the last tick (or the start) and records them under label;
# ticks() returns them in order, named, and total() the minutes from the start to the last tick
.knw_timer <- function() {
  t0 <- Sys.time()
  last <- t0
  ticks <- numeric()
  tick <- function(label) {
    now <- Sys.time()
    m <- as.numeric(difftime(now, last, units = "mins"))
    ticks[[label]] <<- m
    last <<- now
    m
  }
  list(tick = tick, ticks = function() ticks, total = function() as.numeric(difftime(last, t0, units = "mins")))
}

# One bin of groups (#87): its own connection and scratch schema `scratch_w`, each group regenerated through the
# three stages exactly as knw_compare_rules() describes, reading the grades and user-habitat rows the caller wrote to
# `scratch`. Returns the flags per group and rule, the near-river walk time, the seconds of each step summed over the
# bin's groups (`secs`, named `<rule>|<step>`, the shared steps under `shared`; #101), and the first group's error with
# its name (the bin stops there). Self-contained: every value is an argument and every call is qualified, because it
# runs on a socket worker.
.knw_compare_bin <- function(groups, scratch_w, preds, connector, schema, s, sp, stage, scratch, models, specs, wb_sql,
                             rule_names, assert_default, uhc_types, params, params_fresh) {
  conn <- connector()
  on.exit(try(DBI::dbDisconnect(conn), silent = TRUE), add = TRUE)
  on.exit(try(DBI::dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", scratch_w)), silent = TRUE),
          add = TRUE, after = FALSE)
  run_conn <- utils::getFromNamespace(".frs_run_connectivity", "fresh")
  DBI::dbExecute(conn, wb_sql)
  DBI::dbExecute(conn, sprintf("DROP SCHEMA IF EXISTS %s CASCADE", scratch_w))
  DBI::dbExecute(conn, sprintf("CREATE SCHEMA %s", scratch_w))
  near_tbl <- paste0(scratch_w, ".near_river")
  flags <- list()
  walk_s <- 0
  # every step's seconds, summed over the groups: the scratch copy with its indexes, the near-river walk and the
  # default check are shared by the rules; each rule's classify (its habitat table), overlay, connect and read are
  # its own
  steps <- c("shared|copy", "shared|walk", "shared|check",
             paste(rep(rule_names, each = 4L), c("classify", "overlay", "connect", "read"), sep = "|"))
  secs <- stats::setNames(numeric(length(steps)), steps)
  lap <- function(step, t1) secs[[step]] <<- secs[[step]] + as.numeric(difftime(Sys.time(), t1, units = "secs"))
  for (w in groups) {
    err <- tryCatch({
      model <- models[[w]]
      pr <- preds[[model]]
      t1 <- Sys.time()
      DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s.streams", scratch_w))
      # wet's pick joins as mad_m3s, the column link's prepare gives the working table and a discharge pair walks on
      DBI::dbExecute(conn, sprintf("
        CREATE TABLE %1$s.streams AS
        SELECT s.*, (h.accessible AND coalesce(a.access_%3$s > 0, FALSE)) AS accessible,
               h.accessible AS accessible_stored, g.size AS knw_size, g.dist_m AS knw_dist, g.target_in_group,
               nullif(q.q_m3s, 0) AS mad_m3s
        FROM %2$s.streams s
        JOIN %2$s.streams_habitat_%3$s h
          ON h.id_segment = s.id_segment AND h.watershed_group_code = s.watershed_group_code
        LEFT JOIN %2$s.streams_access a
          ON a.id_segment = s.id_segment AND a.watershed_group_code = s.watershed_group_code
        LEFT JOIN %5$s.grades g ON g.id_segment = s.id_segment AND g.watershed_group_code = s.watershed_group_code
        LEFT JOIN discharge.fwa_v1_segment_monthly q
          ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick
        WHERE s.watershed_group_code = '%4$s'", scratch_w, schema, s, w, scratch))
      # link stores one-part MultiLineStrings with Z and M; fresh's walk locates points along a LineString, and
      # nothing here reads Z or M, so the copy is merged and flattened (a segment of more than one part would refuse
      # the cast, which is the right failure)
      DBI::dbExecute(conn, sprintf(paste("ALTER TABLE %s.streams ALTER COLUMN geom TYPE geometry(LineString, 3005)",
                                         "USING ST_Force2D(ST_LineMerge(geom))"), scratch_w))
      for (ix in c("(id_segment)", "USING gist (geom)", "USING gist (wscode_ltree)", "USING gist (localcode_ltree)",
                   "(blue_line_key, downstream_route_measure)")) {
        DBI::dbExecute(conn, sprintf("CREATE INDEX ON %s.streams %s", scratch_w, ix))
      }
      lap("shared|copy", t1)
      if (nrow(specs[[model]])) {
        t1 <- Sys.time()
        sx <- specs[[model]]
        fresh::frs_near_river(conn, paste0(scratch_w, ".streams"), near_tbl, threshold = sx$threshold,
                              distance_max = sx$distance_max, measure = sx$measure, verbose = FALSE)
        walk_s <- walk_s + as.numeric(difftime(Sys.time(), t1, units = "secs"))
        lap("shared|walk", t1)
      }
      if (assert_default && !nrow(specs[[model]])) {
        t1 <- Sys.time()
        dif <- DBI::dbGetQuery(conn, sprintf(
          "SELECT count(*) FILTER (WHERE (%s) IS DISTINCT FROM (%s)) AS n FROM %s.streams s",
          pr$default, pr$door, scratch_w))$n
        if (as.integer(dif) > 0L) {
          stop("the injected tuned predicate (door) differs from fresh's default on ", dif, " segments", call. = FALSE)
        }
        lap("shared|check", t1)
      }
      for (k in rule_names) {
        h <- paste0(scratch_w, ".habitat_", k)
        t1 <- Sys.time()
        DBI::dbExecute(conn, sprintf("DROP TABLE IF EXISTS %s", h))
        rear_sql <- if (stage == "rear") pr[[k]] else pr$other
        spawn_sql <- if (stage == "spawn") pr[[k]] else pr$other
        DBI::dbExecute(conn, sprintf("
          CREATE TABLE %1$s AS
          SELECT s.id_segment, s.watershed_group_code, '%2$s'::text AS species_code, s.accessible,
                 s.accessible AND %3$s AS spawning, s.accessible AND %4$s AS rearing,
                 s.accessible AND coalesce(s.waterbody_key IN
                   (SELECT waterbody_key FROM tmp_knw_wb WHERE t IN ('L','M')), FALSE) AS lake_rearing,
                 s.accessible AND coalesce(s.waterbody_key IN
                   (SELECT waterbody_key FROM tmp_knw_wb WHERE t = 'W'), FALSE) AS wetland_rearing,
                 FALSE AS rearing_pre_connect, FALSE AS spawning_pre_connect
          FROM %5$s.streams s", h, sp, spawn_sql, rear_sql, scratch_w))
        DBI::dbExecute(conn, sprintf("UPDATE %s SET rearing_pre_connect = rearing, spawning_pre_connect = spawning", h))
        DBI::dbExecute(conn, sprintf("CREATE INDEX ON %s (id_segment)", h))
        lap(paste0(k, "|classify"), t1)
        t1 <- Sys.time()
        if (length(uhc_types)) {
          # link's user-habitat table carries spawning and rearing; the overlay takes the types it holds
          fresh::frs_habitat_overlay(conn, from = paste0(scratch, ".uhc"), to = h,
                                     bridge = paste0(scratch_w, ".streams"), species = sp, verbose = FALSE,
                                     habitat_types = uhc_types)
        }
        lap(paste0(k, "|overlay"), t1)
        t1 <- Sys.time()
        run_conn(conn, table = paste0(scratch_w, ".streams"), habitat = h, species = sp, params = params,
                 params_fresh = params_fresh, verbose = FALSE)
        lap(paste0(k, "|connect"), t1)
        t1 <- Sys.time()
        flags[[paste(w, k)]] <- DBI::dbGetQuery(conn, sprintf(
          "SELECT id_segment, watershed_group_code, '%s' AS rule, rearing, spawning, lake_rearing, wetland_rearing,
                  rearing_pre_connect, spawning_pre_connect FROM %s", k, h))
        lap(paste0(k, "|read"), t1)
      }
      NULL
    }, error = function(e) sprintf("group %s: %s", w, conditionMessage(e)))
    if (!is.null(err)) return(list(flags = NULL, walk_s = walk_s, secs = secs, error = err))
  }
  list(flags = flags, walk_s = walk_s, secs = secs, error = NULL)
}

# groups into at most `workers` bins balanced by segment count: largest first, each to the lightest bin (ties to the
# lowest bin), so the result depends only on the counts
.knw_bin_groups <- function(n, workers) {
  n[is.na(n)] <- 0
  k <- min(as.integer(workers), length(n))
  bins <- vector("list", k)
  load <- numeric(k)
  for (g in names(n)[order(-n, names(n))]) {
    i <- which.min(load)
    bins[[i]] <- c(bins[[i]], g)
    load[i] <- load[i] + n[[g]]
  }
  bins
}

# A species' branches under one stage of fresh's rules: the stream rule (the rule with no waterbody_type
# that carries thresholds and is not the through-wetland rule), its edge types and whether it requires the
# segment to lie in no waterbody (`in_waterbody: false`, fresh's `waterbody_key IS NULL`); whether a
# river-polygon rule exists; whether a through-wetland rule (edge types 1050/1150 alone, no waterbody type)
# exists, free (`thresholds: false`, link before 0.67.0) or the door (link 0.67.0); and the wetland and lake
# area floors, 0 where the rule names none (any wetland, any lake) and NULL where the species has no such rule.
.knw_fresh_branches <- function(ps, stage) {
  rules <- ps$rules[[stage]]
  edge_stream <- c(1000L, 1100L, 2000L, 2300L)
  no_waterbody <- FALSE
  river <- FALSE
  wetland <- NULL
  lake <- NULL
  stream_seen <- FALSE
  wetland_line <- FALSE
  wetland_line_free <- FALSE
  for (r in rules) {
    wt <- r[["waterbody_type"]]
    if (.knw_is_wetland_line_rule(r)) {
      wetland_line <- TRUE
      wetland_line_free <- isFALSE(r[["thresholds"]])
      next
    }
    if (is.null(wt)) {
      if (isFALSE(r[["thresholds"]]) || stream_seen) next
      stream_seen <- TRUE
      if (!is.null(r[["edge_types_explicit"]])) edge_stream <- as.integer(r[["edge_types_explicit"]])
      if (!is.null(r[["edge_types"]])) {
        cats <- trimws(strsplit(r[["edge_types"]], ",")[[1]])
        edge_stream <- as.integer(unlist(lapply(cats, function(ct) fresh::frs_edge_types(category = ct)$edge_type)))
      }
      no_waterbody <- isFALSE(r[["in_waterbody"]])
    } else if (wt == "R") {
      river <- TRUE
    } else if (wt == "W") {
      if (is.null(r[["edge_types_explicit"]]) || !all(as.integer(r[["edge_types_explicit"]]) %in% c(1050L, 1150L))) {
        wetland <- min(c(wetland, if (is.null(r[["wetland_ha_min"]])) 0 else r[["wetland_ha_min"]]))
      } else {
        # link before 0.67.0: the through-wetland free pass typed W with a 1 ha floor
        wetland_line <- TRUE
        wetland_line_free <- TRUE
        wetland <- min(c(wetland, if (is.null(r[["wetland_ha_min"]])) 0 else r[["wetland_ha_min"]]))
      }
    } else if (wt == "L") {
      lake <- min(c(lake, if (is.null(r[["lake_ha_min"]])) 0 else r[["lake_ha_min"]]))
    }
  }
  list(edge_stream = edge_stream, no_waterbody = no_waterbody, river = river, wetland_ha_min = wetland,
       lake_ha_min = lake, wetland_line = wetland_line, wetland_line_free = wetland_line_free)
}

# a rule that names the through-wetland lines alone (FWA 1050 and 1150) with no waterbody type: link 0.67.0's door
# (inherits thresholds), or the earlier free pass when untyped
.knw_is_wetland_line_rule <- function(r) {
  is.null(r[["waterbody_type"]]) && !is.null(r[["edge_types_explicit"]]) &&
    setequal(as.integer(r[["edge_types_explicit"]]), c(1050L, 1150L))
}

# which structures a species x rule is compared under (see knw_compare_rules())
.knw_compare_structures <- function(br, tuned, structures = NULL) {
  all <- c("free", "door", "door_wetland")
  pick <- if (!br$wetland_line) "door" else if (is.na(tuned$exc_q)) c("free", "door") else all
  if (is.null(structures)) return(pick)
  chk::chk_subset(structures, all)
  structures
}

# the stream-branch test: a stream edge in no polygon of the species' river, wetland or lake branches
.knw_stream_branch_sql <- function(br, edge_stream) {
  if (br$no_waterbody) {
    sprintf("(s.edge_type IN (%s) AND s.waterbody_key IS NULL)", paste(edge_stream, collapse = ", "))
  } else {
    sprintf(paste("(s.edge_type IN (%s) AND NOT coalesce(s.waterbody_key IN",
                  "(SELECT waterbody_key FROM tmp_knw_wb), FALSE))"),
            paste(edge_stream, collapse = ", "))
  }
}

# the session's table of the species' branch polygons: river polygons, wetlands at the rule's floor, lakes and
# man-made waterbodies at the rule's floor
.knw_wb_sql <- function(br) {
  wb_parts <- c(
    if (br$river) "SELECT DISTINCT waterbody_key, 'R' AS t FROM whse_basemapping.fwa_rivers_poly",
    if (!is.null(br$wetland_ha_min)) {
      sprintf("SELECT DISTINCT waterbody_key, 'W' AS t FROM whse_basemapping.fwa_wetlands_poly WHERE area_ha >= %s",
              br$wetland_ha_min)
    },
    if (!is.null(br$lake_ha_min)) {
      sprintf("SELECT DISTINCT waterbody_key, 'L' AS t FROM whse_basemapping.fwa_lakes_poly WHERE area_ha >= %1$s
               UNION SELECT DISTINCT waterbody_key, 'M' AS t FROM whse_basemapping.fwa_manmade_waterbodies_poly
               WHERE area_ha >= %1$s", br$lake_ha_min)
    },
    "SELECT NULL::integer AS waterbody_key, 'none' AS t WHERE FALSE")
  paste("CREATE TEMPORARY TABLE IF NOT EXISTS tmp_knw_wb AS", paste(wb_parts, collapse = "\n    UNION "))
}

# default's rule as a label: its width floor and gradient maximum, and the near-river pair it resolves to under
# each model with the scope dimensions.csv gives it
.knw_default_rule_label <- function(rng, specs, dims, sp, stage) {
  base <- paste0("width>=", rng$channel_width[1], "|g<=", rng$gradient[2])
  pairs <- unlist(lapply(c("cw", "mad"), function(m) {
    sx <- specs[[m]]
    if (!nrow(sx)) return(NULL)
    sprintf("%s %s>=%g@D%g", m, sx$measure, sx$threshold, sx$distance_max)
  }))
  if (is.null(pairs)) return(paste0(base, "|none"))
  scope_col <- paste0(stage, "_near_river")
  scope <- NA_character_
  if (!is.null(dims) && scope_col %in% names(dims) && any(dims$species == sp)) {
    scope <- dims[[scope_col]][dims$species == sp][1]
  }
  paste0(base, "|", paste(pairs, collapse = "; "), if (!is.na(scope)) paste0(" on ", scope) else "")
}
