# Does knw_link_flow()'s parent flow, and knw_link_regulated()'s dam snap, come out the same on two databases holding
# one build (#161)? Run once per database and per code version, then once to compare.
#
#   MODE=read: source FLOW_R and REG_R (a link_flow.R and a link_regulated.R, so an older version can run beside the
#   current one without touching a checkout), read every line whose flow is taken from a parent (each line of
#   fresh_default.streams with no picked flow of its own or no watershed codes, plus the lines in LINES, a csv with a
#   linear_feature_id column), and the regulating dams; write OUT_DIR/<LABEL>_flow.csv and <LABEL>_dams.csv at full
#   precision, <LABEL>_tied.csv (each line whose two nearest eligible parents are within 1e-6 m) and <LABEL>_meta.csv
#   (the flow load, row counts, md5s, and the wall time of two calls of each function, the first warming the cache).
#   MODE=compare: read OUT_DIR's runs named in LABELS (comma separated, db-code), write LOG, one row per pair compared.
#
#   MODE=read FLOW_R=R/link_flow.R REG_R=R/link_regulated.R LINES=lines.csv OUT_DIR=<dir> LABEL=second-new \
#     Rscript data-raw/link_flow_tie_check.R
#   MODE=compare OUT_DIR=<dir> LABELS=host-old,host-new,second-old,second-new LOG=<csv> Rscript data-raw/link_flow_tie_check.R
#
# The database comes from the PG* variables or PGSERVICE, as everywhere in this repo.

env <- function(x, default = NULL) {
  v <- Sys.getenv(x)
  if (nzchar(v)) v else if (is.null(default)) stop(x, " is not set", call. = FALSE) else default
}
mode <- env("MODE")
out_dir <- env("OUT_DIR")
num17 <- function(d) {
  for (n in names(d)) if (is.numeric(d[[n]])) d[[n]] <- ifelse(is.na(d[[n]]), NA, sprintf("%.17g", d[[n]]))
  d
}

if (mode == "read") {
  label <- env("LABEL")
  fn <- new.env()
  sys.source(env("FLOW_R"), envir = fn)
  sys.source(env("REG_R"), envir = fn)
  conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  load <- DBI::dbGetQuery(conn, "SELECT obj_description('discharge.fwa_v1_segment_monthly'::regclass) AS c")$c
  own <- DBI::dbGetQuery(conn, "
    SELECT DISTINCT s.linear_feature_id
    FROM fresh_default.streams s
    JOIN whse_basemapping.fwa_stream_networks_sp f ON f.linear_feature_id = s.linear_feature_id
    LEFT JOIN discharge.fwa_v1_segment_monthly q
      ON q.linear_feature_id = s.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick
    WHERE q.linear_feature_id IS NULL OR f.wscode_ltree IS NULL OR f.localcode_ltree IS NULL")$linear_feature_id
  extra <- utils::read.csv(env("LINES"))$linear_feature_id
  lines <- sort(unique(as.numeric(c(own, extra))))
  t_flow <- numeric()
  for (k in 1:2) t_flow[k] <- system.time(fl <- fn$knw_link_flow(conn, lines))[["elapsed"]]
  pts <- data.frame(blue_line_key = numeric(), downstream_route_measure = numeric(), wscode = character(),
                    localcode = character())
  t_dam <- numeric()
  for (k in 1:2) t_dam[k] <- system.time(dm <- fn$knw_link_regulated(conn, pts)$dams)[["elapsed"]]
  dm <- dm[order(dm$cabd_id), , drop = FALSE]
  # the lines a tie can reach: those whose parent lookup runs (a flow or a code taken from a parent), where the two
  # nearest parents the lookup may take are within 1e-6 m of each other
  par <- fl$linear_feature_id[fl$flow_from %in% "parent" | fl$code_from_parent %in% TRUE]
  DBI::dbWriteTable(conn, "tmp_knw_tie_lines", data.frame(linear_feature_id = par), temporary = TRUE,
                    overwrite = TRUE)
  tied <- DBI::dbGetQuery(conn, "
    SELECT t.linear_feature_id, x.d[1] AS d1, x.d[2] AS d2
    FROM tmp_knw_tie_lines t
    JOIN whse_basemapping.fwa_stream_networks_sp s ON s.linear_feature_id = t.linear_feature_id
    CROSS JOIN LATERAL (
      SELECT array_agg(d ORDER BY d) AS d FROM (
        SELECT ST_Distance(p.geom, s.geom) AS d
        FROM whse_basemapping.fwa_stream_networks_sp p
        JOIN discharge.fwa_v1_segment_monthly q
          ON q.linear_feature_id = p.linear_feature_id AND q.scenario = 'historical' AND q.month = 0 AND q.pick
        WHERE p.blue_line_key IN (s.watershed_key, s.blue_line_key)
          AND p.wscode_ltree IS NOT NULL AND p.localcode_ltree IS NOT NULL
          AND p.edge_type NOT IN (1100, 1150, 1300, 1350, 2300)
        ORDER BY p.geom <-> s.geom LIMIT 2) n) x
    WHERE x.d[2] - x.d[1] < 1e-6
    ORDER BY t.linear_feature_id")
  DBI::dbDisconnect(conn)
  f <- function(x) file.path(out_dir, paste0(label, "_", x, ".csv"))
  utils::write.csv(num17(as.data.frame(fl)), f("flow"), row.names = FALSE, na = "")
  utils::write.csv(num17(as.data.frame(dm)), f("dams"), row.names = FALSE, na = "")
  utils::write.csv(num17(tied), f("tied"), row.names = FALSE, na = "")
  utils::write.csv(data.frame(
    label = label, flow_load = load, n_lines = length(lines), n_flow_rows = nrow(fl), n_parent = length(par),
    n_dams = nrow(dm),
    n_tied = nrow(tied), n_tied_exact = sum(tied$d1 == tied$d2),
    flow_md5 = unname(tools::md5sum(f("flow"))), dams_md5 = unname(tools::md5sum(f("dams"))),
    flow_s_1 = t_flow[1], flow_s_2 = t_flow[2], dams_s_1 = t_dam[1], dams_s_2 = t_dam[2]
  ), f("meta"), row.names = FALSE)
  message("wrote ", label, ": ", length(lines), " lines, ", nrow(dm), " dams, ", nrow(tied), " tied lines")
} else if (mode == "compare") {
  labels <- strsplit(env("LABELS"), ",", fixed = TRUE)[[1]]
  rd <- function(l, x) utils::read.csv(file.path(out_dir, paste0(l, "_", x, ".csv")), colClasses = "character")
  meta <- do.call(rbind, lapply(labels, rd, x = "meta"))
  # a tie can move only a line whose parent lookup ran (runs before the tie query was limited to those lines listed
  # every line, so the limit is applied here too)
  par <- unique(unlist(lapply(labels, function(l) {
    f <- rd(l, "flow")
    f$linear_feature_id[f$flow_from %in% "parent" | f$code_from_parent %in% "TRUE"]
  })))
  tied <- intersect(unique(unlist(lapply(labels, function(l) rd(l, "tied")$linear_feature_id))), par)
  meta$n_parent_lines <- length(par)
  meta$n_tied_parent_lines <- length(tied)
  # rows that differ between two runs, by key, over every column
  diff_keys <- function(a, b, key) {
    stopifnot(identical(a[[key]], b[[key]]), identical(names(a), names(b)))
    a[[key]][apply(a != b | is.na(a) != is.na(b), 1, function(r) any(r %in% TRUE))]
  }
  pairs <- utils::combn(labels, 2, simplify = FALSE)
  out <- do.call(rbind, lapply(pairs, function(p) {
    dfl <- diff_keys(rd(p[1], "flow"), rd(p[2], "flow"), "linear_feature_id")
    ddm <- diff_keys(rd(p[1], "dams"), rd(p[2], "dams"), "cabd_id")
    data.frame(a = p[1], b = p[2], flow_rows_differ = length(dfl), flow_differ_all_tied = all(dfl %in% tied),
               flow_lines_differ = paste(dfl, collapse = ";"), dam_rows_differ = length(ddm),
               dams_differ = paste(ddm, collapse = ";"))
  }))
  utils::write.csv(out, env("LOG"), row.names = FALSE)
  utils::write.csv(meta, sub("\\.csv$", "-meta.csv", env("LOG")), row.names = FALSE)
  print(out[, c("a", "b", "flow_rows_differ", "flow_differ_all_tied", "dam_rows_differ")])
  print(meta[, c("label", "n_lines", "n_parent_lines", "n_tied_parent_lines", "flow_md5", "flow_s_1", "flow_s_2", "dams_s_1",
                 "dams_s_2")])
} else {
  stop("MODE must be read or compare", call. = FALSE)
}
