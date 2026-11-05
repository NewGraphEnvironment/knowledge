#' Read link's parent table, held to the two builds it joins
#'
#' link#444 writes `<schema>.streams_parent`: one row per segment of the full
#' network, naming the minimal-network segment it lies in (`cut-min`), with
#' that parent's gradient and length and how much of the full segment lies on
#' another minimal segment (`straddle_m`). This reads it for
#' [knw_parent_join()] (#120), after checking that it describes the two builds
#' in the database now, because a re-model of either network leaves the table
#' behind:
#' - the table names one minimal build, `minimal_schema`'s, by schema and run
#'   (`schema_minimal`, `run_uid_minimal`);
#' - each group's `run_id_full` is a row of `<schema>.log` for that group from a
#'   run `<schema>.log_recompute` names, and each `run_id_minimal` a row of
#'   `<minimal_schema>.log` from the minimal build's run;
#' - every segment of `<schema>.streams` has exactly one parent row, and each
#'   row's `overlap_m + straddle_m` is its segment's length within 1 cm.
#'
#' @param conn a `DBI` connection.
#' @param schema `character(1)` the full network's persist schema, which holds
#'   `streams_parent`.
#' @param minimal_schema `character(1)` or `NULL`: the minimal network's
#'   schema. `NULL` takes the one the table names, which must be one.
#' @param keys `NULL`, or a `data.frame` with `watershed_group_code` and
#'   `id_segment`: read only those segments' rows (the checks still cover the
#'   whole table).
#' @return A `data.frame` with `knw_parent_join()`'s columns (`id_segment`,
#'   `wsg`, `id_segment_minimal`, `gradient_minimal`, `length_minimal`,
#'   `overlap_m`, `straddle_m`), and attribute `provenance`: a one-row
#'   `data.frame` with `schema`, `minimal_schema`, `run_uid_full`,
#'   `run_uid_minimal`, `link_sha_minimal`, `config_hash_minimal`, `built_at`
#'   (the latest) and `rows` (the table's).
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' p <- knw_parent_read(conn, "fresh_default", "fresh_default_minimal",
#'                      keys = data.frame(watershed_group_code = "BULK", id_segment = 1:10))
#' attr(p, "provenance")
#' }
knw_parent_read <- function(conn, schema, minimal_schema = NULL, keys = NULL) {
  chk::chk_string(schema)
  if (!is.null(minimal_schema)) chk::chk_string(minimal_schema)
  for (s in c(schema, minimal_schema)) {
    if (!grepl("^[a-z_][a-z0-9_]*$", s)) stop("schema must be a lower-case identifier: ", s, call. = FALSE)
  }
  q <- function(sql, ...) DBI::dbGetQuery(conn, sql, ...)
  tbl <- paste0(schema, ".streams_parent")
  if (!isTRUE(q("SELECT to_regclass($1) IS NOT NULL AS ok", params = list(tbl))$ok)) {
    stop(schema, " has no streams_parent table (link#444's lnk_streams_parent() builds it)", call. = FALSE)
  }
  # the one minimal build the table names
  mb <- q(sprintf("SELECT DISTINCT schema_minimal, run_uid_minimal, link_sha_minimal, config_hash_minimal
                   FROM %s ORDER BY 1, 2, 3, 4", tbl))
  if (nrow(mb) != 1L) {
    stop(tbl, " names ", nrow(mb), " minimal builds (schema, run, link commit, config): one parent table, one build",
         call. = FALSE)
  }
  if (is.null(minimal_schema)) minimal_schema <- mb$schema_minimal
  if (!identical(mb$schema_minimal, minimal_schema)) {
    stop(tbl, " was joined to ", mb$schema_minimal, ", not ", minimal_schema, call. = FALSE)
  }
  runs_of <- function(s) q(sprintf("SELECT DISTINCT run_uid FROM %s.log_recompute ORDER BY run_uid", s))$run_uid
  run_min <- runs_of(minimal_schema)
  if (!identical(run_min, mb$run_uid_minimal)) {
    stop(tbl, " was joined to ", minimal_schema, "'s run ", mb$run_uid_minimal, ", but ", minimal_schema,
         " now holds run ", paste(run_min, collapse = ";"), ": rebuild the parent table", call. = FALSE)
  }
  run_full <- runs_of(schema)
  # each group's run ids against the log rows of the builds' runs (one per group and host)
  orphan_sql <- "SELECT count(*)::int AS n FROM (SELECT DISTINCT watershed_group_code, %1$s FROM %2$s) p
                 WHERE NOT EXISTS (SELECT 1 FROM %3$s.log l WHERE l.watershed_group_code = p.watershed_group_code
                                   AND l.run_id = p.%1$s AND l.run_uid = ANY($1::text[]))"
  arr <- function(x) paste0("{", paste(x, collapse = ","), "}")
  for (side in list(list(col = "run_id_full", s = schema, runs = run_full),
                    list(col = "run_id_minimal", s = minimal_schema, runs = run_min))) {
    n <- q(sprintf(orphan_sql, side$col, tbl, side$s), params = list(arr(side$runs)))$n
    if (n > 0L) {
      stop(n, " groups of ", tbl, " carry a ", side$col, " that is no ", side$s, ".log row of run ",
           paste(side$runs, collapse = ";"), " for that group: the table predates the build", call. = FALSE)
    }
  }
  # one row per segment of the full build, each as long as its segment
  cov <- q(sprintf("SELECT count(*) FILTER (WHERE p.n IS NULL)::int AS missing,
                           count(*) FILTER (WHERE p.n > 1)::int AS doubled,
                           count(*) FILTER (WHERE p.n = 1 AND NOT abs(p.len - s.length_metre) <= 0.01)::int AS off,
                           (SELECT count(*) FROM %2$s)::int AS rows,
                           (SELECT max(built_at) FROM %2$s)::text AS built_at
                    FROM %1$s.streams s
                    LEFT JOIN (SELECT watershed_group_code, id_segment, count(*) AS n,
                                      max(overlap_m + straddle_m) AS len
                               FROM %2$s GROUP BY 1, 2) p
                      ON p.watershed_group_code = s.watershed_group_code AND p.id_segment = s.id_segment", schema, tbl))
  if (cov$missing > 0L || cov$doubled > 0L || cov$off > 0L) {
    stop(tbl, ": ", cov$missing, " segments of ", schema, ".streams have no parent row, ", cov$doubled,
         " have two, and ", cov$off, " are not as long as their row's overlap and straddle: the table is stale, ",
         "rebuild it", call. = FALSE)
  }
  cols <- "p.id_segment, p.watershed_group_code AS wsg, p.id_segment_minimal, p.gradient_minimal, p.length_minimal,
           p.overlap_m, p.straddle_m"
  if (is.null(keys)) {
    out <- q(sprintf("SELECT %s FROM %s p ORDER BY 2, 1", cols, tbl))
  } else {
    chk::check_names(keys, c("watershed_group_code", "id_segment"))
    k <- unique(data.frame(watershed_group_code = as.character(keys$watershed_group_code),
                           id_segment = as.integer(as.numeric(keys$id_segment))))
    DBI::dbWriteTable(conn, "tmp_knw_parent_keys", k, temporary = TRUE, overwrite = TRUE)
    on.exit(try(DBI::dbExecute(conn, "DROP TABLE IF EXISTS tmp_knw_parent_keys"), silent = TRUE), add = TRUE)
    out <- q(sprintf("SELECT %s FROM %s p JOIN tmp_knw_parent_keys k
                        ON k.watershed_group_code = p.watershed_group_code AND k.id_segment = p.id_segment
                      ORDER BY 2, 1", cols, tbl))
  }
  out$id_segment <- as.numeric(out$id_segment)
  out$id_segment_minimal <- as.numeric(out$id_segment_minimal)
  attr(out, "provenance") <- data.frame(schema = schema, minimal_schema = minimal_schema,
                                        run_uid_full = paste(run_full, collapse = ";"), run_uid_minimal = run_min,
                                        link_sha_minimal = mb$link_sha_minimal,
                                        config_hash_minimal = mb$config_hash_minimal, built_at = cov$built_at,
                                        rows = cov$rows, stringsAsFactors = FALSE)
  out
}
