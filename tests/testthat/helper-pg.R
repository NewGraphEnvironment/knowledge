# Skip a live test unless a Postgres connection can actually be opened: an env var
# set with the server down would otherwise error instead of skipping. The connection
# is cached for the file.
pg_conn <- local({
  conn <- NULL
  tried <- FALSE
  function() {
    if (!tried) {
      tried <<- TRUE
      conn <<- tryCatch(
        withr::with_envvar(c(PGCONNECT_TIMEOUT = "5"), DBI::dbConnect(RPostgres::Postgres())),
        error = function(e) NULL
      )
    }
    conn
  }
})
skip_if_no_pg <- function(schema = NULL) {
  conn <- pg_conn()
  if (is.null(conn)) testthat::skip("no Postgres connection (PG* environment variables)")
  if (!is.null(schema)) {
    has <- DBI::dbGetQuery(conn, "SELECT count(*) AS n FROM information_schema.schemata WHERE schema_name = $1",
                           params = list(schema))$n
    if (as.integer(has) == 0L) testthat::skip(paste("schema", schema, "not in the database"))
  }
  conn
}
