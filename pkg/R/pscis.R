#' Provincial PSCIS layers, by phase
#'
#' The four PSCIS "spatial view" layers, named by the phase of work each records.
#' Each carries a link to the report that documents the work (`ecocat_url`, or
#' `habconf_ecocat_url` on the habitat-confirmation layer).
#'
#' @return A named `character` vector of `schema.table` names.
#' @export
#' @examples
#' knw_pscis_layers()
knw_pscis_layers <- function() {
  c(
    assessment   = "whse_fish.pscis_assessment_svw",
    confirmation = "whse_fish.pscis_habitat_confirmation_svw",
    design       = "whse_fish.pscis_design_proposal_svw",
    remediation  = "whse_fish.pscis_remediation_svw"
  )
}

#' Pull PSCIS layers clipped to a watershed group
#'
#' Each layer is intersected with `whse_basemapping.fwa_watershed_groups_poly`
#' in the database, because the raw PSCIS layers carry no watershed group code.
#' Layers with no rows in the group are dropped from the result, since an empty
#' `st_read()` carries no CRS.
#'
#' @param conn A `DBI` connection to a database holding the PSCIS layers and
#'   the FWA watershed-group polygons (PostGIS).
#' @param wsg_code `character(1)` watershed group code, e.g. `"PINE"`.
#' @param layers Named `character` of `schema.table` layers; see
#'   [knw_pscis_layers()].
#' @return A named `list` of `sf` objects, one per non-empty layer, each with a
#'   `pscis_layer` column naming the phase.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres(), host = "localhost",
#'                        port = 63333, dbname = "bcfishpass", user = "newgraph")
#' layers <- knw_pscis_pull(conn, "PINE")
#' }
knw_pscis_pull <- function(conn, wsg_code, layers = knw_pscis_layers()) {
  chk::chk_string(wsg_code)
  chk::chk_character(layers)
  chk::chk_named(layers)
  out <- lapply(names(layers), function(nm) {
    parts <- strsplit(layers[[nm]], ".", fixed = TRUE)[[1]]
    if (length(parts) != 2L) stop("Layer must be `schema.table`: ", layers[[nm]], call. = FALSE)
    q <- sprintf(
      "SELECT p.* FROM %s p
       JOIN whse_basemapping.fwa_watershed_groups_poly w ON ST_Intersects(w.geom, p.geom)
       WHERE w.watershed_group_code = %s",
      DBI::dbQuoteIdentifier(conn, DBI::Id(schema = parts[1], table = parts[2])),
      DBI::dbQuoteString(conn, wsg_code))
    d <- sf::st_read(conn, query = q, quiet = TRUE)
    if (nrow(d)) d$pscis_layer <- nm
    d
  })
  names(out) <- names(layers)
  out[vapply(out, nrow, integer(1)) > 0L]
}

#' Past reports referenced by PSCIS records
#'
#' One row per distinct (`pscis_layer`, `ecocat_url`, consultant, year), with
#' the number of crossings each report covers and the EcoCat `report_id`
#' parsed from the URL. The link column is `ecocat_url` on three layers and
#' `habconf_ecocat_url` on the habitat-confirmation layer; any column ending in
#' `ecocat_url` is used. Layers without one are skipped.
#' The stored URL is sometimes wrong for the crossing, so treat the result as
#' leads to verify rather than an inventory.
#'
#' @param layers Named `list` of `sf` or `data.frame` PSCIS layers, as returned
#'   by [knw_pscis_pull()].
#' @return A `tibble` with `pscis_layer`, `ecocat_url`, `consultant`, `year`,
#'   `n_crossings`, `report_id`.
#' @export
#' @examples
#' layers <- list(assessment = data.frame(
#'   stream_crossing_id = c(1L, 2L, 3L),
#'   ecocat_url = c("https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=100",
#'                  "https://a100.gov.bc.ca/pub/acat/public/viewReport.do?reportId=100",
#'                  NA),
#'   consultant_name = "Someone", assessment_date = as.Date("2015-08-01")))
#' knw_pscis_reports(layers)
knw_pscis_reports <- function(layers) {
  chk::chk_list(layers)
  rows <- lapply(names(layers), function(nm) {
    df <- layers[[nm]]
    if (inherits(df, "sf")) df <- sf::st_drop_geometry(df)
    url_col <- .first_col(df, "ecocat_url$")
    if (is.na(url_col)) return(NULL)
    date_col <- .first_col(df, "_date$")
    cons_col <- .first_col(df, "consultant")
    tibble::tibble(
      pscis_layer = nm,
      ecocat_url  = as.character(df[[url_col]]),
      consultant  = if (!is.na(cons_col)) as.character(df[[cons_col]]) else NA_character_,
      year        = if (!is.na(date_col)) lubridate::year(as.Date(df[[date_col]])) else NA_integer_,
      stream_crossing_id = if ("stream_crossing_id" %in% names(df)) df$stream_crossing_id else NA_integer_
    )
  })
  rows <- dplyr::bind_rows(rows)
  if (!nrow(rows)) {
    return(tibble::tibble(pscis_layer = character(), ecocat_url = character(),
                          consultant = character(), year = integer(),
                          n_crossings = integer(), report_id = character()))
  }
  rows |>
    dplyr::filter(!is.na(.data$ecocat_url), .data$ecocat_url != "") |>
    dplyr::group_by(.data$pscis_layer, .data$ecocat_url, .data$consultant, .data$year) |>
    dplyr::summarise(n_crossings = dplyr::n_distinct(.data$stream_crossing_id), .groups = "drop") |>
    dplyr::mutate(report_id = stringr::str_match(.data$ecocat_url, "reportId=([0-9]+)")[, 2]) |>
    dplyr::arrange(.data$pscis_layer, .data$year)
}

#' Crossings table from the PSCIS assessment layer
#'
#' Assessment records with WGS84 coordinates, the watershed group stamped on,
#' and flags for presence in the confirmation, design and remediation phases.
#'
#' @inheritParams knw_pscis_reports
#' @param wsg_code `character(1)` watershed group code to stamp on every row.
#' @return A `tibble`, or `NULL` when there is no non-empty assessment layer.
#' @export
#' @examples
#' pts <- sf::st_sf(
#'   stream_crossing_id = c(10L, 11L),
#'   assessment_date = as.Date(c("2015-08-01", "2016-08-01")),
#'   geometry = sf::st_sfc(sf::st_point(c(1200000, 1000000)),
#'                         sf::st_point(c(1200500, 1000500)), crs = 3005))
#' knw_pscis_crossings(list(assessment = pts,
#'                          design = data.frame(stream_crossing_id = 11L)), "PINE")
knw_pscis_crossings <- function(layers, wsg_code) {
  chk::chk_list(layers)
  chk::chk_string(wsg_code)
  assess <- layers[["assessment"]]
  if (is.null(assess) || !nrow(assess)) return(NULL)
  if (!inherits(assess, "sf")) stop("`layers$assessment` must be an sf object.", call. = FALSE)
  xy <- sf::st_coordinates(sf::st_transform(assess, 4326))
  if (nrow(xy) != nrow(assess)) {
    stop("Assessment geometry must be POINT (one coordinate per feature).", call. = FALSE)
  }
  ad <- sf::st_drop_geometry(assess)
  keep <- intersect(
    c("stream_crossing_id", "external_crossing_reference", "pscis_crossing_id",
      "assessment_date", "consultant_name", "stream_name", "gazetted_names", "road_name",
      "current_barrier_result_code", "barrier_result", "habitat_value_code",
      "ecocat_url", "image_view_url"),
    names(ad))
  ids <- function(nm) {
    d <- layers[[nm]]
    if (is.null(d) || !"stream_crossing_id" %in% names(d)) return(integer())
    d$stream_crossing_id
  }
  out <- tibble::as_tibble(ad[, keep, drop = FALSE])
  out$lon <- round(xy[, 1], 6)
  out$lat <- round(xy[, 2], 6)
  out$watershed_group_code <- wsg_code
  out$has_confirmation <- out$stream_crossing_id %in% ids("confirmation")
  out$has_design       <- out$stream_crossing_id %in% ids("design")
  out$has_remediation  <- out$stream_crossing_id %in% ids("remediation")
  dplyr::arrange(out, .data$stream_crossing_id)
}

.first_col <- function(df, pattern) {
  hit <- names(df)[stringr::str_detect(names(df), pattern)]
  if (length(hit)) hit[1] else NA_character_
}
