#' Spawner evidence per visit for the char species, from maturity codes
#'
#' `scripts/0293`'s response, as `0240` fixed it: a visit carries spawner
#' evidence for bull trout when a BT fish (DV pooled where link pools it) was
#' coded `SP` or `ST` at any date, or `M` in August to October. Only visits that
#' caught the species and maturity-coded at least one of its fish can carry the
#' response; on a visit nobody coded, evidence was impossible, so those visits
#' get `NA`. Electrofishing catches no adult Pacific salmon, so this is the only
#' spawning response the export can give.
#'
#' @param fish `data.frame` with `site_visit`, `species_code`, `maturity_code`,
#'   `length_mm` (`0230`'s `fish.rds`).
#' @param visits `data.frame` with `site_visit`, `month` and `pooling`
#'   (`"BT+DV"` where DV counts as BT, from [knw_fdis_species()]).
#' @param codes `data.frame` with `code` and `species_group`.
#' @param species `character(1)` the species; `"BT"` is the only one the codes
#'   support today.
#' @param coded `character` the maturity codes that count as a coded fish.
#' @param large_mm `numeric(1)` the length at and above which a spawner is
#'   large (a migratory-adult size); the split comes back as `S_large`, `S_small`.
#' @return A `tibble`, one row per visit: `site_visit`, `species_code`,
#'   `n_coded`, `S` (0/1, `NA` where no fish was coded), `S_large`, `S_small`,
#'   `kind` (the strongest evidence kind: `SP/ST`, `M Sep-Oct`, `M Aug`,
#'   `M other months`, `adult size only`, `none`).
#' @export
#' @examples
#' fish <- data.frame(site_visit = c("v1", "v1", "v2", "v3"), species_code = c("BT", "BT", "DV", "BT"),
#'                    maturity_code = c("IM", "M", "SP", NA), length_mm = c(90, 410, 300, 500))
#' visits <- data.frame(site_visit = c("v1", "v2", "v3"), month = c(9, 6, 9), pooling = c("BT", "BT+DV", "BT"))
#' codes <- data.frame(code = c("BT", "DV"), species_group = "char")
#' knw_spawner_evidence(fish, visits, codes)
knw_spawner_evidence <- function(fish, visits, codes, species = "BT", coded = c("IM", "M", "MT", "SP", "ST"),
                                 large_mm = 350) {
  chk::chk_data(fish)
  chk::check_names(fish, c("site_visit", "species_code", "maturity_code", "length_mm"))
  chk::chk_data(visits)
  chk::check_names(visits, c("site_visit", "month", "pooling"))
  chk::chk_string(species)
  if (species != "BT") stop("spawner evidence from maturity codes is defined for BT only", call. = FALSE)
  char_codes <- codes$code[codes$species_group %in% "char"]
  bt_dv <- intersect(c("BT", "DV", "BT/DV", "DV/BT", "DVxBT"), char_codes)
  f <- merge(fish, visits[, c("site_visit", "month", "pooling")], by = "site_visit")
  f <- f[f$species_code == "BT" | (f$pooling %in% "BT+DV" & f$species_code %in% bt_dv), , drop = FALSE]
  len <- suppressWarnings(as.numeric(f$length_mm))
  mc <- f$maturity_code
  f$kind <- ifelse(mc %in% c("SP", "ST"), "SP/ST",
            ifelse(mc %in% "M" & f$month %in% 9:10, "M Sep-Oct",
            ifelse(mc %in% "M" & f$month %in% 8, "M Aug",
            ifelse(mc %in% "M", "M other months",
            ifelse((is.na(mc) | mc %in% "U") & !is.na(len) & len >= large_mm & f$month %in% 8:10, "adult size only",
                   "none")))))
  f$spawner <- f$kind %in% c("SP/ST", "M Sep-Oct", "M Aug")
  f$len <- len
  f$large <- !is.na(len) & len >= large_mm
  f$is_coded <- mc %in% coded
  kinds <- c("SP/ST", "M Sep-Oct", "M Aug", "M other months", "adult size only", "none")
  g <- split(f, f$site_visit)
  out <- do.call(rbind, lapply(g, function(x) {
    data.frame(site_visit = x$site_visit[1], n_coded = sum(x$is_coded),
               S = if (any(x$is_coded)) as.integer(any(x$spawner)) else NA_integer_,
               S_large = if (any(x$is_coded)) as.integer(any(x$spawner & x$large)) else NA_integer_,
               S_small = if (any(x$is_coded)) as.integer(any(x$spawner & !x$large & !is.na(x$len))) else NA_integer_,
               kind = kinds[min(match(x$kind, kinds))], stringsAsFactors = FALSE)
  }))
  if (is.null(out)) {
    out <- data.frame(site_visit = character(), n_coded = integer(), S = integer(), S_large = integer(),
                      S_small = integer(), kind = character(), stringsAsFactors = FALSE)
  }
  out$species_code <- species
  rownames(out) <- NULL
  tibble::as_tibble(out[, c("site_visit", "species_code", "n_coded", "S", "S_large", "S_small", "kind")])
}
