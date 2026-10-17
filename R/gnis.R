#' Which GNIS stream names collide across watershed groups?
#'
#' GNIS names repeat across BC, so a report search by stream name drags in
#' reports about a same-named stream elsewhere. This reports, for each seed
#' name, how many watershed groups carry it. Names in one group only are safe
#' to search by name; the rest need a geographic qualifier and a coordinate
#' check on every hit.
#'
#' @param conn A `DBI` connection.
#' @param stream_names `character` seed stream names, as they appear in `gnis_name`.
#' @param wsg_code `character(1)` the watershed group being worked.
#' @param table `character(1)` a table carrying both `gnis_name` and
#'   `watershed_group_code`. Default `"bcfishpass.streams"`.
#' @param pattern `character(1)` regular expression a seed name must match to
#'   be checked; the default keeps rivers, creeks and lakes. `NULL` checks all.
#' @return A `tibble` with one row per seed name found: `gnis_name`, `n_wsg`,
#'   `wsgs` (comma-joined, sorted) and `wsg_only` (`TRUE` when the name occurs
#'   in `wsg_code` and nowhere else). Names absent from `table` are returned in
#'   attribute `"not_found"`.
#' @export
#' @examples
#' if (requireNamespace("duckdb", quietly = TRUE)) {
#' con <- DBI::dbConnect(duckdb::duckdb())
#' DBI::dbWriteTable(con, "streams", data.frame(
#'   gnis_name = c("Boulder Creek", "Boulder Creek", "Wildmare Creek"),
#'   watershed_group_code = c("PINE", "LNTH", "PINE")))
#' knw_gnis_collisions(con, c("Boulder Creek", "Wildmare Creek", "Ghost Creek"),
#'                     "PINE", table = "streams")
#' DBI::dbDisconnect(con, shutdown = TRUE)
#' }
knw_gnis_collisions <- function(conn, stream_names, wsg_code, table = "bcfishpass.streams",
                                pattern = "River|Creek|Lake") {
  chk::chk_character(stream_names)
  chk::chk_string(wsg_code)
  chk::chk_string(table)
  seed <- unique(stream_names[!is.na(stream_names) & nzchar(stream_names)])
  if (!is.null(pattern)) seed <- seed[grepl(pattern, seed)]
  empty <- tibble::tibble(gnis_name = character(), n_wsg = integer(),
                          wsgs = character(), wsg_only = logical())
  if (!length(seed)) return(structure(empty, not_found = character()))
  # Distinct pairs, aggregated in R: portable across Postgres and DuckDB and
  # deterministic in the order of `wsgs`.
  q <- sprintf(
    "SELECT DISTINCT gnis_name, watershed_group_code FROM %s WHERE gnis_name IN (%s)",
    table, paste(DBI::dbQuoteString(conn, seed), collapse = ", "))
  pairs <- tibble::as_tibble(DBI::dbGetQuery(conn, q))
  # A NULL group code is not a group: the original SQL aggregates ignored it.
  pairs <- dplyr::filter(pairs, !is.na(.data$watershed_group_code))
  if (!nrow(pairs)) return(structure(empty, not_found = seed))
  out <- pairs |>
    dplyr::group_by(.data$gnis_name) |>
    dplyr::summarise(
      n_wsg = dplyr::n_distinct(.data$watershed_group_code),
      wsgs  = paste(sort(unique(.data$watershed_group_code)), collapse = ","),
      .groups = "drop") |>
    dplyr::mutate(wsg_only = .data$wsgs == wsg_code) |>
    dplyr::arrange(dplyr::desc(.data$n_wsg), .data$gnis_name)
  structure(out, not_found = setdiff(seed, out$gnis_name))
}
