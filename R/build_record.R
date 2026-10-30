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
#'   `discharge_load`, `walk_md5`, `fresh_version`, `tokens` (link's output
#'   vocabulary, `c(cut =, acc =, grad =, flow =)`, each `NA` where the schema's
#'   run log predates link 0.70.0 and carries none), and `line`, the record as
#'   one line for a log. A schema whose runs logged two values on one axis is
#'   refused.
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
  # link's output vocabulary (link 0.70.0): one token per axis in the run log, absent from a build before it
  axes <- c("cut", "acc", "grad", "flow")
  tokens <- stats::setNames(rep(NA_character_, length(axes)), axes)
  sql_tok <- sprintf("SELECT column_name FROM information_schema.columns
                       WHERE table_schema = $1 AND table_name = 'log_recompute' AND column_name IN (%s)",
                     paste0("'token_", axes, "'", collapse = ", "))
  has_tok <- DBI::dbGetQuery(conn, sql_tok, params = list(schema))$column_name
  for (a in intersect(axes, sub("^token_", "", has_tok))) {
    v <- DBI::dbGetQuery(conn, sprintf("SELECT DISTINCT token_%s AS v FROM %s.log_recompute WHERE token_%s IS NOT NULL
                                         ORDER BY 1", a, schema, a))$v
    if (length(v) > 1) {
      stop("schema ", schema, " logged ", length(v), " ", a, " tokens (", paste(v, collapse = ", "),
           "): not one build", call. = FALSE)
    }
    if (length(v)) tokens[[a]] <- v
  }
  rec <- list(schema = schema, run_uid = runs, discharge_load = knw_discharge_load(conn), walk_md5 = knw_walk_md5(),
              fresh_version = fresh_v, tokens = tokens)
  rec$line <- sprintf("build: schema %s, run %s; flows %s; walk %s; fresh %s; tokens %s", schema, runs,
                      rec$discharge_load, rec$walk_md5, fresh_v,
                      if (all(is.na(tokens))) "none (before link 0.70.0)" else paste(tokens, collapse = "."))
  if (!is.null(run_uid) && !identical(runs, run_uid)) {
    stop("schema ", schema, " was built by run ", runs, ", not the evidence's ", run_uid,
         ": point SCHEMA at the schema the evidence was built on", call. = FALSE)
  }
  rec
}
