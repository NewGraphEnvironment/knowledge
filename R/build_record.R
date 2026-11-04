#' The database build a run reads, and the check that it is the evidence's
#'
#' A grade or a comparison reads four things from the database besides the
#' FWA tables: link's persist schema, the run that built it
#' (`<schema>.log_recompute`'s `run_uid`), wet's flow load (the table comment,
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
#'   vocabulary, `c(cut =, acc =, grad =, flow =)`, read from every row of
#'   `<schema>.log`, where link writes them; each `NA` where that log predates
#'   link 0.70.0 and carries none), `log_run_uid` (the runs whose `log` rows
#'   were read, `;`-joined) and `line`, the record as one line for a log. A
#'   schema whose log holds two values on one axis, or rows with a token beside
#'   rows without one, is refused: it is not one build. The tokens are read over
#'   the `log` rows of the runs `log_recompute` names, because a provincial run
#'   leaves the previous run's `log` rows in place (#145), and over every `log`
#'   row where none of those runs is in `log`, because a build's `log` and its
#'   recompute's `log_recompute` can carry different run ids (link's four-group
#'   proofs). The line names any run whose rows were set aside.
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
  # link's output vocabulary (link 0.70.0): one token per axis on every row of the run log `<schema>.log`, which
  # link writes per pipeline call and group; `log_recompute` carries none. A build before 0.70.0 has no columns.
  axes <- c("cut", "acc", "grad", "flow")
  tokens <- stats::setNames(rep(NA_character_, length(axes)), axes)
  sql_tok <- sprintf("SELECT column_name FROM information_schema.columns
                       WHERE table_schema = $1 AND table_name = 'log' AND column_name IN (%s)",
                     paste0("'token_", axes, "'", collapse = ", "))
  has_tok <- DBI::dbGetQuery(conn, sql_tok, params = list(schema))$column_name
  lr <- .knw_build_log_runs(conn, schema)
  for (a in intersect(axes, sub("^token_", "", has_tok))) {
    tk <- DBI::dbGetQuery(conn, sprintf("SELECT count(*)::int AS n, count(token_%s)::int AS n_val,
                                           string_agg(DISTINCT token_%s, ';' ORDER BY token_%s) AS v
                                         FROM %s.log%s", a, a, a, schema, lr$where), params = lr$params)
    if (tk$n_val == 0) next
    if (tk$n_val < tk$n) {
      stop("schema ", schema, ": ", tk$n - tk$n_val, " of ", tk$n, " log rows carry no ", a,
           " token: not one build", call. = FALSE)
    }
    v <- strsplit(tk$v, ";", fixed = TRUE)[[1]]
    if (length(v) > 1) {
      stop("schema ", schema, " logged ", length(v), " ", a, " tokens (", paste(v, collapse = ", "),
           "): not one build", call. = FALSE)
    }
    tokens[[a]] <- v
  }
  rec <- list(schema = schema, run_uid = runs, discharge_load = knw_discharge_load(conn), walk_md5 = knw_walk_md5(),
              fresh_version = fresh_v, tokens = tokens, log_run_uid = paste(lr$runs, collapse = ";"))
  rec$line <- sprintf("build: schema %s, run %s; flows %s; walk %s; fresh %s; tokens %s%s", schema, runs,
                      rec$discharge_load, rec$walk_md5, fresh_v,
                      if (all(is.na(tokens))) "none (before link 0.70.0)" else paste(tokens, collapse = "."),
                      if (length(lr$aside)) sprintf("; log rows of run %s set aside (not in log_recompute)",
                                                    paste(lr$aside, collapse = ", ")) else "")
  if (!is.null(run_uid) && !identical(runs, run_uid)) {
    stop("schema ", schema, " was built by run ", runs, ", not the evidence's ", run_uid,
         ": point SCHEMA at the schema the evidence was built on", call. = FALSE)
  }
  rec
}

#' Which rows of link's run log describe a schema's build
#'
#' `<schema>.log` gains a row per pipeline call and group on every run, and a
#' provincial run leaves the previous run's rows in place, while
#' `log_recompute` holds the run that built the schema (#145). The build's rows
#' are those of the runs `log_recompute` names; where none of those runs is in
#' `log` (link's four-group proofs log their build and recompute under
#' different run ids), every row is.
#'
#' @param conn a `DBI` connection.
#' @param schema `character(1)` link's persist schema, already checked.
#' @return A list: `runs` (the runs whose rows are read), `aside` (the runs
#'   whose rows are not), and `where` and `params`, the clause and parameters
#'   that select those rows (`""` and `NULL` when every row is read).
#' @noRd
.knw_build_log_runs <- function(conn, schema) {
  rec <- DBI::dbGetQuery(conn, sprintf("SELECT DISTINCT run_uid FROM %s.log_recompute ORDER BY run_uid",
                                       schema))$run_uid
  lg <- DBI::dbGetQuery(conn, sprintf("SELECT run_uid, count(*)::int AS n FROM %s.log
                                       GROUP BY run_uid ORDER BY run_uid", schema))$run_uid
  keep <- intersect(lg, rec)
  if (!length(keep)) return(list(runs = lg, aside = character(), where = "", params = NULL))
  # the runs go into a text-array literal: refuse anything but a run id's characters rather than quote it
  bad <- keep[is.na(keep) | !grepl("^[A-Za-z0-9_.:-]+$", keep)]
  if (length(bad)) stop("schema ", schema, ": log_recompute names ", bad[1], ", not a run id", call. = FALSE)
  aside <- setdiff(lg, keep)
  list(runs = keep, aside = ifelse(is.na(aside), "NA", aside), where = " WHERE run_uid = ANY($1::text[])",
       params = list(paste0("{", paste(keep, collapse = ","), "}")))
}
