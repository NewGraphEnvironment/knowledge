#' Catch, presence and absence per FDIS site visit and species
#'
#' One row per visit and species in `species`: how many were caught (summed
#' over the codes that count as that species), how many of them were measured
#' into each size class of `breaks`, whether the species is present, and whether
#' an absence claim is blocked by a code that could hide it.
#'
#' Presence follows `scripts/0290`'s pooling rule for bull trout and the code
#' table for everything else:
#' - a species is present when a code that counts as it was caught. For `BT` the
#'   codes are `BT` alone, or every char code except `SLV` (`BT`, `DV`, `BT/DV`,
#'   `DV/BT`, `DVxBT`) where link pools Dolly Varden records into bull trout for
#'   that watershed group and year (`pooled`);
#' - an absence is blocked when the visit caught a code whose
#'   `blocks_absence_of` names the species or its species group (`char` for BT),
#'   or, for `BT`, any other char code (`DV` counts as a BT absence where DV is
#'   not pooled, as link counts it);
#' - a visit whose `catch_status` is `unknown` carries no absence.
#'
#' `n_caught` is `NA` where every counting code's count was a sentinel (caught,
#' abundance unknown). Size-class counts exist only for the species groups
#' `breaks` tiles (a measured fish of another species has a length and no
#' class); `n_unmeasured` is the counted fish with no usable length.
#'
#' @param sites `data.frame` with `site_visit`, `watershed_group_code`, `year`
#'   and `catch_status`.
#' @param catch `data.frame` with `site_visit`, `species_code`, `n_caught` and
#'   `n_measured` (`0230`'s `catch.rds`).
#' @param fish `data.frame` with `site_visit`, `species_code` and `length_mm`
#'   (`0230`'s `fish.rds`).
#' @param codes `data.frame` with `code`, `catch_class`, `species_group` and
#'   `blocks_absence_of` (`data/fdis_species_codes.csv`, read as character).
#' @param breaks size-class breaks, as [knw_size_class()] takes them.
#' @param species `character` species codes to keep rows for.
#' @param pooled `NULL`, or a `data.frame` with `watershed_group_code` and
#'   `obs_year_max` naming the groups where DV records are pooled into BT, up to
#'   that year (`NA` for no limit), as `link::lnk_species_pooling()` reports them.
#' @return A `tibble` with `site_visit`, `species_code`, `n_caught`,
#'   `n_measured`, one `n_<size_class>` column per class in `breaks`,
#'   `n_unmeasured`, `pooling` (`"BT+DV"` or `"BT"` for BT, `NA` otherwise),
#'   `present`, `absence_blocked` and `status` (`present`, `absent`, `blocked`,
#'   `unknown`).
#' @export
#' @examples
#' sites <- data.frame(site_visit = c("v1", "v2"), watershed_group_code = "BULK",
#'                     year = 2010L, catch_status = c("fish", "zero"))
#' catch <- data.frame(site_visit = c("v1", "v1"), species_code = c("DV", "CH"),
#'                     n_caught = c(3, 2), n_measured = c(2, 0))
#' fish <- data.frame(site_visit = "v1", species_code = c("DV", "DV"), length_mm = c(55, 120))
#' codes <- data.frame(code = c("DV", "CH", "BT"), catch_class = "fish",
#'                     species_group = c("char", "CH", "char"), blocks_absence_of = "")
#' breaks <- data.frame(species_group = c("char", "char"), size_class = c("fry", "juvenile"),
#'                      length_min_mm = c(0, 80), length_max_mm = c(80, Inf))
#' # DV is a BT absence unless pooled; pooling makes v1 a BT visit with 3 fish
#' knw_fdis_species(sites, catch, fish, codes, breaks, species = c("BT", "CH"))
#' knw_fdis_species(sites, catch, fish, codes, breaks, species = "BT",
#'                  pooled = data.frame(watershed_group_code = "BULK", obs_year_max = NA))
knw_fdis_species <- function(sites, catch, fish, codes, breaks, species = knw_species(), pooled = NULL) {
  chk::chk_data(sites)
  chk::check_names(sites, c("site_visit", "watershed_group_code", "year", "catch_status"))
  chk::chk_data(catch)
  chk::check_names(catch, c("site_visit", "species_code", "n_caught", "n_measured"))
  chk::chk_data(fish)
  chk::check_names(fish, c("site_visit", "species_code", "length_mm"))
  chk::chk_data(codes)
  chk::check_names(codes, c("code", "catch_class", "species_group", "blocks_absence_of"))
  chk::chk_character(species)
  chk::chk_not_any_na(species)
  chk::chk_null_or(pooled, vld = chk::vld_data)
  if (!is.null(pooled)) chk::check_names(pooled, c("watershed_group_code", "obs_year_max"))
  if (anyDuplicated(sites$site_visit)) stop("a site_visit appears twice in sites", call. = FALSE)
  if (anyDuplicated(codes$code)) stop("a code appears twice in codes", call. = FALSE)

  group_of <- function(code) {
    g <- codes$species_group[match(code, codes$code)]
    g[!is.na(g) & !nzchar(g)] <- NA
    g
  }
  char_codes <- codes$code[codes$species_group %in% "char"]
  bt_dv_codes <- intersect(c("BT", "DV", "BT/DV", "DV/BT", "DVxBT"), char_codes)
  blocks <- strsplit(ifelse(is.na(codes$blocks_absence_of), "", codes$blocks_absence_of), ";", fixed = TRUE)
  names(blocks) <- codes$code
  fish_codes <- codes$code[codes$catch_class %in% "fish"]

  # the codes caught on each visit, fish only (zero-catch and not-fish rows carry no species)
  caught <- catch[catch$species_code %in% fish_codes, c("site_visit", "species_code", "n_caught", "n_measured")]
  caught_by <- split(caught$species_code, factor(caught$site_visit, levels = sites$site_visit))

  # DV pooled into BT per group, up to obs_year_max
  dv_pooled <- rep(FALSE, nrow(sites))
  if (!is.null(pooled)) {
    i <- match(sites$watershed_group_code, pooled$watershed_group_code)
    ymax <- pooled$obs_year_max[i]
    dv_pooled <- !is.na(i) & (is.na(ymax) | sites$year <= ymax)
  }

  # size classes per measured fish, for the species groups the breaks tile; other groups' fish keep
  # their count and length but no class
  fish <- fish[fish$species_code %in% fish_codes, c("site_visit", "species_code", "length_mm")]
  fish$length_mm <- suppressWarnings(as.numeric(fish$length_mm))
  grp_f <- group_of(fish$species_code)
  tiled <- !is.na(grp_f) & grp_f %in% breaks$species_group
  fish$size_class <- rep(NA_character_, nrow(fish))
  fish$size_class[tiled] <- knw_size_class(grp_f[tiled], fish$length_mm[tiled], breaks)
  classes <- unique(breaks$size_class)

  rows <- lapply(species, function(sp) {
    grp <- group_of(sp)
    counts_as <- function(pool) if (sp == "BT" && pool) bt_dv_codes else sp
    blocks_sp <- function(code, pool) {
      b <- blocks[[code]]
      (!is.null(b) && (sp %in% b || (!is.na(grp) && grp %in% b))) ||
        (sp == "BT" && code %in% setdiff(char_codes, c(counts_as(pool), if (!pool) "DV")))
    }
    present <- logical(nrow(sites))
    blocked <- logical(nrow(sites))
    for (k in seq_len(nrow(sites))) {
      cc <- caught_by[[k]]
      present[k] <- any(cc %in% counts_as(dv_pooled[k]))
      blocked[k] <- !present[k] && any(vapply(cc, blocks_sp, logical(1), pool = dv_pooled[k]))
    }
    # counts over the codes that count as sp on each visit
    in_sp <- caught$species_code == sp |
      (sp == "BT" & caught$species_code %in% bt_dv_codes &
         dv_pooled[match(caught$site_visit, sites$site_visit)])
    cs <- caught[in_sp, , drop = FALSE]
    n_caught <- tapply(cs$n_caught, factor(cs$site_visit, levels = sites$site_visit),
                       function(x) if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE))
    n_measured <- tapply(cs$n_measured, factor(cs$site_visit, levels = sites$site_visit), sum)
    fsp <- fish[fish$species_code == sp |
                  (sp == "BT" & fish$species_code %in% bt_dv_codes &
                     dv_pooled[match(fish$site_visit, sites$site_visit)]), , drop = FALSE]
    fsp <- fsp[fsp$site_visit %in% sites$site_visit, , drop = FALSE]
    by_class <- table(factor(fsp$site_visit, levels = sites$site_visit),
                      factor(fsp$size_class, levels = classes))
    n_nolength <- tapply(is.na(fsp$length_mm) | fsp$length_mm <= 0, factor(fsp$site_visit, levels = sites$site_visit), sum)
    # no counting code caught: 0 where the visit's catch is known, NA where it is unknown
    n_caught <- as.numeric(n_caught)
    none <- !present & sites$catch_status != "unknown"
    n_caught[none] <- 0
    n_caught[!present & sites$catch_status == "unknown"] <- NA_real_
    out <- tibble::tibble(
      site_visit = sites$site_visit, species_code = sp,
      n_caught = n_caught, n_measured = as.numeric(ifelse(is.na(n_measured), 0, n_measured))
    )
    for (cl in classes) out[[paste0("n_", cl)]] <- as.integer(by_class[, cl])
    out$n_unmeasured <- as.numeric(pmax(ifelse(is.na(out$n_caught), 0, out$n_caught) - out$n_measured, 0) +
                                     ifelse(is.na(n_nolength), 0, n_nolength))
    out$pooling <- if (sp == "BT") ifelse(dv_pooled, "BT+DV", "BT") else NA_character_
    out$present <- present
    out$absence_blocked <- blocked
    out$status <- ifelse(present, "present",
                         ifelse(sites$catch_status == "unknown", "unknown",
                                ifelse(blocked, "blocked", "absent")))
    out
  })
  out <- do.call(rbind, rows)
  out[order(out$site_visit, out$species_code), , drop = FALSE]
}
