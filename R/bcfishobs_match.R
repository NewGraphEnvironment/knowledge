#' Match bcfishobs records to the FDIS site visits they came from
#'
#' About half of the province's fish observation records carry
#' `FDIS Database: fshclctn_id <n>` in `source`: the collection id the FDIS
#' export keys on (issue #23). A record is matched to a visit when the visit's
#' collection (the first field of `site_visit`), species and date agree. One
#' collection holds several sites and dates, so a record can match several visits
#' of one collection on the same date: those are kept, one row per pair, and
#' flagged `many`. A record whose collection is in the export but whose species
#' and date match no visit is `collection_only`; one whose collection is not in
#' the export is `unmatched`; a record with no FDIS key is `not_fdis`.
#'
#' Codes that the export records differently from bcfishobs (DV pooled into BT,
#' hybrid codes) are matched as written: a bcfishobs `DV` matches a visit's `DV`.
#'
#' @param conn a `DBI` connection to a database holding `bcfishobs.observations`.
#' @param visits `data.frame` with `site_visit` and `date` (`Date`), one row per
#'   visit, and the per-visit species table `species` below.
#' @param species `data.frame` with `site_visit` and `species_code`, one row per
#'   visit and species caught (any code), as `0230`'s `catch.rds` has them.
#' @param species_codes `character` the bcfishobs species to read.
#' @return A list: `matched`, a `tibble` with one row per bcfishobs record and
#'   matched visit (`observation_key`, `fish_observation_point_id`,
#'   `species_code`, `observation_date`, `fshclctn_id`, `site_visit`,
#'   `match`); `summary`, counts per species and `match` class.
#' @export
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(RPostgres::Postgres())
#' sites <- readRDS("data/fdis/build/sites.rds")
#' catch <- readRDS("data/fdis/build/catch.rds")
#' knw_bcfishobs_match(conn, sites, catch, c("BT", "CH"))$summary
#' }
knw_bcfishobs_match <- function(conn, visits, species, species_codes = knw_species()) {
  chk::chk_data(visits)
  chk::check_names(visits, c("site_visit", "date"))
  chk::chk_data(species)
  chk::check_names(species, c("site_visit", "species_code"))
  chk::chk_character(species_codes)
  if (anyDuplicated(visits$site_visit)) stop("a site_visit appears twice in visits", call. = FALSE)
  obs <- DBI::dbGetQuery(conn, "
    SELECT observation_key, fish_observation_point_id, species_code, observation_date, source,
           watershed_group_code, blue_line_key, downstream_route_measure, match_type
    FROM bcfishobs.observations WHERE species_code = ANY($1::text[])",
    params = list(paste0("{", paste(species_codes, collapse = ","), "}")))
  obs$fshclctn_id <- suppressWarnings(as.integer(sub("^.*fshclctn_id[^0-9]*([0-9]+).*$", "\\1",
                                                     ifelse(grepl("fshclctn_id", obs$source), obs$source, NA))))
  visits$coll <- suppressWarnings(as.integer(sub("_.*$", "", visits$site_visit)))
  visits$date <- as.Date(visits$date)
  sp <- merge(species[, c("site_visit", "species_code")], visits[, c("site_visit", "coll", "date")],
              by = "site_visit")
  key_obs <- paste(obs$fshclctn_id, obs$species_code, as.character(as.Date(obs$observation_date)))
  key_sp <- paste(sp$coll, sp$species_code, as.character(sp$date))
  hits <- split(sp$site_visit, factor(key_sp, levels = unique(key_sp)))
  m <- hits[key_obs]
  n_hit <- lengths(m)
  n_hit[is.na(names(m))] <- 0L
  n_hit[is.na(obs$fshclctn_id)] <- 0L
  cls <- ifelse(is.na(obs$fshclctn_id), "not_fdis",
                ifelse(n_hit > 1L, "many", ifelse(n_hit == 1L, "one",
                                                  ifelse(obs$fshclctn_id %in% visits$coll, "collection_only",
                                                         "unmatched"))))
  rows <- lapply(seq_len(nrow(obs)), function(i) {
    sv <- if (n_hit[i] > 0L) m[[i]] else NA_character_
    data.frame(i = i, site_visit = sv, stringsAsFactors = FALSE)
  })
  rows <- do.call(rbind, rows)
  matched <- tibble::tibble(
    observation_key = obs$observation_key[rows$i],
    fish_observation_point_id = as.numeric(obs$fish_observation_point_id[rows$i]),
    species_code = obs$species_code[rows$i],
    observation_date = as.Date(obs$observation_date[rows$i]),
    watershed_group_code = obs$watershed_group_code[rows$i],
    blue_line_key = as.numeric(obs$blue_line_key[rows$i]),
    downstream_route_measure = as.numeric(obs$downstream_route_measure[rows$i]),
    match_type = obs$match_type[rows$i],
    fshclctn_id = obs$fshclctn_id[rows$i], site_visit = rows$site_visit, match = cls[rows$i]
  )
  summary <- as.data.frame(table(species_code = obs$species_code, match = cls), responseName = "n_records",
                           stringsAsFactors = FALSE)
  summary <- summary[summary$n_records > 0, , drop = FALSE]
  rownames(summary) <- NULL
  list(matched = matched, summary = tibble::as_tibble(summary))
}
