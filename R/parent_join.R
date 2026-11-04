#' Carry each visit's minimal-network parent onto its full-network segment
#'
#' link deploys a rule on its full network, whose segments are cut at fish
#' records, crossings and habitat end points as well as at barriers and access
#' gradients; its minimal network (`default_minimal`, link#415) is cut at the
#' last two alone. A rule tuned on the minimal network transfers to the full one
#' when each full segment carries its minimal parent's gradient (link#444). This
#' joins that parent to the visits placed on the full network, so the tuning can
#' read the parent's gradient there (`GRADIENT=parent_gradient` in
#' `scripts/0320`, #120).
#'
#' A full segment's parent is the minimal segment it overlaps most, and every
#' visit on the full segment takes that parent's gradient. Where a full segment
#' straddles a minimal break, `straddle_m` is the length that lies on another
#' minimal segment: a visit on that stretch sits on the other segment on the
#' minimal network, so there the two setups read different gradients. A placed
#' visit whose segment has no parent row is an error. link numbers each group's
#' segments from 1, so a parent table of another build covers the same ids:
#' each visit's segment must be as long as its parent row's `overlap_m +
#' straddle_m` (within 1 cm; a missing length fails), or the join stops as
#' another network's table.
#'
#' @param visits `data.frame` of placed visits with `site_visit`,
#'   `watershed_group_code`, `id_segment` and `segment_length_m` (the full
#'   network's segment, as [knw_link_place()] returns it).
#' @param parent `data.frame` with one row per full segment: `id_segment`,
#'   `wsg`, `id_segment_minimal`, `gradient_minimal`, `length_minimal`,
#'   `overlap_m` and `straddle_m`, as link's `data-raw/logs/minimal_breaks_415/parent_<wsg>.csv.gz`
#'   holds them.
#' @return `visits` with `parent_id_segment`, `parent_gradient`,
#'   `parent_length_m` and `parent_straddle_m`, in the same rows and order.
#' @export
#' @examples
#' v <- data.frame(site_visit = c("a", "b"), watershed_group_code = "BULK", id_segment = c(10, 11),
#'                 segment_length_m = c(120, 315))
#' p <- data.frame(id_segment = c(10, 11, 12), wsg = "BULK", id_segment_minimal = c(4, 4, 5),
#'                 gradient_minimal = c(0.012, 0.012, 0.031), length_minimal = c(900, 900, 400),
#'                 overlap_m = c(120, 300, 400), straddle_m = c(0, 15, 0))
#' knw_parent_join(v, p)
knw_parent_join <- function(visits, parent) {
  chk::check_names(visits, c("site_visit", "watershed_group_code", "id_segment", "segment_length_m"))
  chk::check_names(parent, c("id_segment", "wsg", "id_segment_minimal", "gradient_minimal", "length_minimal",
                             "overlap_m", "straddle_m"))
  key_p <- sprintf("%s %.0f", parent$wsg, as.numeric(parent$id_segment))
  if (anyDuplicated(key_p)) {
    stop(sum(duplicated(key_p)), " full segments have two parent rows: one parent per segment", call. = FALSE)
  }
  i <- match(sprintf("%s %.0f", visits$watershed_group_code, as.numeric(visits$id_segment)), key_p)
  if (anyNA(i)) {
    miss <- visits[is.na(i), , drop = FALSE]
    stop(nrow(miss), " placed visits have no parent row (groups ",
         paste(sort(unique(miss$watershed_group_code)), collapse = ", "),
         "): the parent table is not this network's", call. = FALSE)
  }
  # the ids alone cannot tell two builds of one group apart: their lengths can
  # a missing length on either side is a mismatch, not a pass
  ok <- abs(as.numeric(parent$overlap_m[i]) + as.numeric(parent$straddle_m[i]) -
              as.numeric(visits$segment_length_m)) <= 0.01
  off <- !(ok %in% TRUE)
  if (any(off)) {
    stop(sum(off), " placed visits sit on a segment whose length is not its parent row's overlap and ",
         "straddle: the parent table is another build's", call. = FALSE)
  }
  visits$parent_id_segment <- as.numeric(parent$id_segment_minimal[i])
  visits$parent_gradient <- as.numeric(parent$gradient_minimal[i])
  visits$parent_length_m <- as.numeric(parent$length_minimal[i])
  visits$parent_straddle_m <- as.numeric(parent$straddle_m[i])
  visits
}
