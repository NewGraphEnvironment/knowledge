#' Whether a natural barrier to a species lies downstream of each point
#'
#' `scripts/0296`'s access test, per species. link applies a habitat rule behind
#' its access gate, and the gate's observation overrides come mostly from these
#' same electrofishing records, so a rule scored on them must use the barriers
#' as they stood *before* overrides: `GRADIENT`, `FALLS`, `SUBSURFACE_FLOW` and
#' `USER_DEFINITE` rows of the schema's `barriers` table that block the species
#' (`blocks_species`), tested with `fwa_downstream()` from the point.
#'
#' @param conn a `DBI` connection to a database holding `schema`.
#' @param pts `data.frame` with `blue_line_key`, `downstream_route_measure`,
#'   `wscode` and `localcode` (ltree text). A point with no codes gets `NA`.
#' @param species `character` species codes, each tested on its own.
#' @param schema `character(1)` link persist schema.
#' @param natural `character` the barrier sources that count as natural.
#' @return A `tibble` of the distinct `pts` keys with one logical column
#'   `barrier_dnstr_<sp>` per species (lower case).
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' pts <- data.frame(blue_line_key = 360886335, downstream_route_measure = 1520,
#'                   wscode = "400.431358.785328", localcode = "400.431358.785328.000001")
#' knw_link_barrier_dnstr(conn, pts, c("BT", "CH"), "fresh_default")
#' }
knw_link_barrier_dnstr <- function(conn, pts, species, schema,
                                   natural = c("GRADIENT", "FALLS", "SUBSURFACE_FLOW", "USER_DEFINITE")) {
  chk::chk_data(pts)
  chk::check_names(pts, c("blue_line_key", "downstream_route_measure", "wscode", "localcode"))
  chk::chk_character(species)
  chk::chk_string(schema)
  chk::chk_character(natural)
  keys <- unique(pts[, c("blue_line_key", "downstream_route_measure", "wscode", "localcode")])
  ok <- !is.na(keys$wscode) & !is.na(keys$localcode)
  tmp <- "tmp_knw_barrier_pts"
  DBI::dbWriteTable(conn, tmp, keys[ok, , drop = FALSE], temporary = TRUE, overwrite = TRUE)
  on.exit(try(DBI::dbExecute(conn, paste("DROP TABLE IF EXISTS", tmp)), silent = TRUE), add = TRUE)
  out <- tibble::as_tibble(keys[, c("blue_line_key", "downstream_route_measure")])
  out$blue_line_key <- as.numeric(out$blue_line_key)
  src <- paste0("'", natural, "'", collapse = ",")
  for (sp in species) {
    hit <- DBI::dbGetQuery(conn, sprintf("
      SELECT t.blue_line_key, t.downstream_route_measure,
             EXISTS (SELECT 1 FROM %1$s.barriers b
                     WHERE b.wscode_ltree @> t.wscode::ltree
                       AND b.barrier_source IN (%2$s) AND $1 = ANY(b.blocks_species)
                       AND fwa_downstream(t.blue_line_key::integer, t.downstream_route_measure,
                                          t.wscode::ltree, t.localcode::ltree,
                                          b.blue_line_key::integer, b.downstream_route_measure,
                                          b.wscode_ltree, b.localcode_ltree)) AS hit
      FROM %3$s t", schema, src, tmp), params = list(sp))
    m <- match(paste(out$blue_line_key, out$downstream_route_measure),
               paste(as.numeric(hit$blue_line_key), hit$downstream_route_measure))
    out[[paste0("barrier_dnstr_", tolower(sp))]] <- hit$hit[m]
  }
  out
}
