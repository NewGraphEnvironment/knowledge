#' How link's two access columns disagree, per species
#'
#' In a link `default` build, `streams_habitat_<sp>.accessible` and
#' `streams_access.access_<sp>` disagree (link#349; cause not established), and
#' rearing and spawning are set on segments `streams_access` blocks. The
#' evidence build gates on `streams_access`, and writes this cross-tabulation to
#' its ledger on every run so a change between link runs shows.
#'
#' @param conn a `DBI` connection to a database holding `schema`.
#' @param schema `character(1)` link persist schema.
#' @param species `character` species with a habitat table and an access column
#'   in the schema; a species lacking either is skipped and named in `skipped`.
#' @param by_group `logical(1)`: one row per watershed group as well, so two
#'   builds of the same groups (link's full and minimal networks, #120) can be
#'   set beside each other where their km differ.
#' @return A list: `check`, a `tibble` with one row per species and cell
#'   (`habitat_accessible`, `access_gt0`, `n_segments`, `n_rearing`,
#'   `n_spawning`, `km`; with `by_group`, per `watershed_group_code` too), and
#'   `skipped`, the species not checked.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' knw_link_access_check(conn, "fresh_default", c("BT", "CH", "RB", "KO"))$check
#' }
knw_link_access_check <- function(conn, schema, species = knw_species(), by_group = FALSE) {
  chk::chk_string(schema)
  chk::chk_character(species)
  chk::chk_flag(by_group)
  grp <- if (by_group) "h.watershed_group_code, " else ""
  cols <- DBI::dbGetQuery(conn, "
    SELECT table_name, column_name FROM information_schema.columns
    WHERE table_schema = $1 AND (table_name = 'streams_access' OR table_name LIKE 'streams_habitat_%')",
    params = list(schema))
  have_access <- paste0("access_", tolower(species)) %in% cols$column_name[cols$table_name == "streams_access"]
  have_hab <- paste0("streams_habitat_", tolower(species)) %in% cols$table_name
  keep <- have_access & have_hab
  rows <- lapply(species[keep], function(sp) {
    s <- tolower(sp)
    x <- DBI::dbGetQuery(conn, sprintf("
      SELECT %3$sh.accessible AS habitat_accessible, coalesce(a.access_%1$s > 0, FALSE) AS access_gt0,
             count(*) AS n_segments, count(*) FILTER (WHERE h.rearing) AS n_rearing,
             count(*) FILTER (WHERE h.spawning) AS n_spawning, sum(st.length_metre) / 1000 AS km
      FROM %2$s.streams_habitat_%1$s h
      JOIN %2$s.streams st ON st.id_segment = h.id_segment AND st.watershed_group_code = h.watershed_group_code
      LEFT JOIN %2$s.streams_access a ON a.id_segment = h.id_segment AND a.watershed_group_code = h.watershed_group_code
      GROUP BY %4$s ORDER BY %4$s", s, schema, grp, if (by_group) "1, 2, 3" else "1, 2"))
    out <- tibble::tibble(species_code = sp, habitat_accessible = x$habitat_accessible, access_gt0 = x$access_gt0,
                          n_segments = as.numeric(x$n_segments), n_rearing = as.numeric(x$n_rearing),
                          n_spawning = as.numeric(x$n_spawning), km = as.numeric(x$km))
    if (by_group) out <- tibble::add_column(out, watershed_group_code = x$watershed_group_code, .after = 1)
    out
  })
  empty <- tibble::tibble(species_code = character(), habitat_accessible = logical(), access_gt0 = logical(),
                          n_segments = numeric(), n_rearing = numeric(), n_spawning = numeric(), km = numeric())
  if (by_group) empty <- tibble::add_column(empty, watershed_group_code = character(), .after = 1)
  list(check = do.call(rbind, c(rows, list(empty))), skipped = species[!keep])
}
