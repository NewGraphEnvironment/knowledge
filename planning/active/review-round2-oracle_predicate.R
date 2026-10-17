suppressMessages({library(dplyr); pkgload::load_all(quiet = TRUE)})
con <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
link_dir <- "/private/tmp/claude-501/-Users-airvine-Projects-repo-knowledge/613e59da-4a81-4e58-b22c-c7646e0aa675/scratchpad/link_default"
params <- fresh::frs_params(csv = file.path(link_dir, "parameters_habitat_thresholds.csv"),
                            rules_yaml = file.path(link_dir, "rules.yaml"))
groups <- c("PARS", "BULK")
# oracle: for every fitted species and both stages, the injected predicate with the default values
# (a tuned rule equal to default) against fresh's own, counted on two groups
for (sp in c("BT", "CH", "CO", "GR", "RB", "ST", "WCT")) for (stage in c("rear", "spawn")) {
  ps <- params[[sp]]
  br <- knowledge:::.knw_fresh_branches(ps, stage)
  pd <- fresh::frs_habitat_predicates(list(species_code = sp, params_sp = ps, spawn_gradient_min = 0,
                                           spawn_gradient_max = ps$ranges$spawn$gradient[2]), "cw")
  w_def <- ps$ranges[[stage]]$channel_width[1]
  g_def <- ps$ranges[[stage]]$gradient[2]
  DBI::dbExecute(con, "DROP TABLE IF EXISTS tmp_knw_wb")
  parts <- c(
    if (br$river) "SELECT DISTINCT waterbody_key, 'R' AS t FROM whse_basemapping.fwa_rivers_poly",
    if (!is.null(br$wetland_ha_min)) sprintf("SELECT DISTINCT waterbody_key, 'W' AS t FROM whse_basemapping.fwa_wetlands_poly WHERE area_ha >= %s", br$wetland_ha_min),
    if (!is.null(br$lake_ha_min)) sprintf("SELECT DISTINCT waterbody_key, 'L' AS t FROM whse_basemapping.fwa_lakes_poly WHERE area_ha >= %1$s UNION SELECT DISTINCT waterbody_key, 'M' AS t FROM whse_basemapping.fwa_manmade_waterbodies_poly WHERE area_ha >= %1$s", br$lake_ha_min),
    "SELECT NULL::integer AS waterbody_key, 'none' AS t WHERE FALSE")
  DBI::dbExecute(con, paste("CREATE TEMPORARY TABLE tmp_knw_wb AS", paste(parts, collapse = " UNION ")))
  sb <- if (br$no_waterbody) {
    sprintf("(s.edge_type IN (%s) AND s.waterbody_key IS NULL)", paste(br$edge_stream, collapse = ", "))
  } else {
    sprintf("(s.edge_type IN (%s) AND NOT coalesce(s.waterbody_key IN (SELECT waterbody_key FROM tmp_knw_wb), FALSE))",
            paste(br$edge_stream, collapse = ", "))
  }
  mine <- sprintf("((NOT %1$s AND coalesce((%2$s), FALSE)) OR (%1$s AND coalesce(s.gradient BETWEEN 0 AND %3$s, FALSE) AND coalesce(s.channel_width BETWEEN %4$s AND 9999, FALSE)))",
                  sb, pd[[stage]], g_def, w_def)
  x <- DBI::dbGetQuery(con, sprintf("SELECT count(*) n, count(*) FILTER (WHERE coalesce((%s), FALSE) IS DISTINCT FROM (%s)) differ FROM fresh_default.streams s WHERE s.watershed_group_code IN ('%s')",
                                    pd[[stage]], mine, paste(groups, collapse = "','")))
  cat(sprintf("%-4s %-5s edges %-20s no_wb %-5s W %-4s L %-4s river %-5s : %d segments, %d differ\n", sp, stage,
              paste(br$edge_stream, collapse = ","), br$no_waterbody, if (is.null(br$wetland_ha_min)) "none" else br$wetland_ha_min, if (is.null(br$lake_ha_min)) "none" else br$lake_ha_min, br$river,
              as.integer(x$n), as.integer(x$differ)))
}
DBI::dbDisconnect(con)
