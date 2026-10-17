#' The species the habitat evidence is built for
#'
#' link's `default` configuration models these eleven species, so the evidence
#' build keeps a presence, absence and catch record per visit for each of them.
#' `char` is not a species: it is the species group the FDIS code table pools
#' bull trout, Dolly Varden and their ambiguous codes into, and a code that
#' blocks a `char` absence blocks a BT absence.
#'
#' @return `character` species codes.
#' @export
#' @examples
#' knw_species()
knw_species <- function() {
  c("BT", "CH", "CM", "CO", "GR", "KO", "PK", "RB", "SK", "ST", "WCT")
}
