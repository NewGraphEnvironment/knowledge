#' The database build a run reads, and the check that it is the evidence's
#'
#' A grade or a comparison reads four things from the database besides the
#' FWA tables: link's persist schema, the run that built it
#' (`<schema>.log_recompute`), wet's flow load (the table comment,
#' [knw_discharge_load()]) and the walk installed from this package
#' ([knw_walk_md5()]); fresh's version decides the comparison's regeneration.
#' `0320` and `0330` read this record at connect and refuse a schema whose run
#' is not the evidence ledger's, before any work, so the same command runs on
#' any machine whose database holds the build and stops on one that does not
#' (#87). A provincial run in link renames `fresh_default` and builds a new one
#' in its place (link#361), which is the case the check catches.
#'
#' @param conn a `DBI` connection.
#' @param schema `character(1)` link's persist schema.
#' @param run_uid `character(1)` or `NULL`: the run the evidence was built on
#'   (the ledger's `link_run_uid`). Given, a schema built by another run, or by
#'   several, is refused.
#' @return A list: `schema`, `run_uid` (the schema's runs, `;`-joined),
#'   `discharge_load`, `walk_md5`, `fresh_version`, and `line`, the record as one
#'   line for a log.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_build_record(conn, "fresh_default_20261017", run_uid = "20261017_004619-3f4c713b")$line
#' }
knw_build_record <- function(conn, schema, run_uid = NULL) {
  chk::chk_string(schema)
  if (!grepl("^[a-z_][a-z0-9_]*$", schema)) stop("schema must be a lower-case identifier", call. = FALSE)
  has <- DBI::dbGetQuery(conn, "SELECT to_regclass($1) IS NOT NULL AS ok",
                         params = list(paste0(schema, ".log_recompute")))$ok
  if (!isTRUE(has)) stop("schema ", schema, " has no log_recompute table: not a link persist schema", call. = FALSE)
  runs_sql <- "SELECT string_agg(DISTINCT run_uid, ';' ORDER BY run_uid) AS u FROM %s.log_recompute"
  runs <- DBI::dbGetQuery(conn, sprintf(runs_sql, schema))$u
  fresh_v <- NA_character_
  if (requireNamespace("fresh", quietly = TRUE)) fresh_v <- as.character(utils::packageVersion("fresh"))
  rec <- list(schema = schema, run_uid = runs, discharge_load = knw_discharge_load(conn), walk_md5 = knw_walk_md5(),
              fresh_version = fresh_v)
  rec$line <- sprintf("build: schema %s, run %s; flows %s; walk %s; fresh %s", schema, runs, rec$discharge_load,
                      rec$walk_md5, fresh_v)
  if (!is.null(run_uid) && !identical(runs, run_uid)) {
    stop("schema ", schema, " was built by run ", runs, ", not the evidence's ", run_uid,
         ": point SCHEMA at the schema the evidence was built on", call. = FALSE)
  }
  rec
}
