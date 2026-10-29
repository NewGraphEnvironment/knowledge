#' Drop the FDIS site visits that cannot carry evidence, and count every drop
#'
#' The quality drops `scripts/0290` and `0294` applied to `0230`'s site table,
#' in that order: a visit not placed on the FWA network, a pick beyond its
#' placement limit (see [knw_fdis_place()]), an FDIS 1:50k watershed code that
#' names no stream within the snap search, a junk date, a sentinel effort or no effort at all (a visit with
#' only one of area and time is kept, so a model can use either), and a catch
#' whose status is unknown (neither fish nor an explicit zero). Each drop is one
#' ledger row, and the drops and the kept rows partition the input, which the
#' function asserts.
#'
#' @param sites `data.frame` of site visits as `0230` builds them, with the flag
#'   columns `flag_not_placed`, `flag_far_snap`, `flag_ws50_mismatch`,
#'   `flag_junk_date`, `flag_effort_sentinel`, `flag_no_area`, `flag_no_effort`
#'   and `catch_status`.
#' @return A list: `kept`, the visits that pass, and `ledger`, a `tibble` with
#'   columns `kind` (`in`, `drop`, `kept`, `info`), `step`, `n` and `note`.
#'   Where `sites` carries `0230`'s `snap_confirmed` and `snap_moved`, two
#'   `info` rows count the kept visits confirmed by their 1:50k code and those
#'   moved to a named stream that is not the nearest; they are not part of the
#'   partition.
#' @export
#' @examples
#' sites <- data.frame(
#'   site_visit = c("a", "b", "c"),
#'   flag_not_placed = c(FALSE, TRUE, FALSE), flag_far_snap = FALSE,
#'   flag_ws50_mismatch = c(FALSE, FALSE, NA), flag_junk_date = FALSE,
#'   flag_effort_sentinel = FALSE, flag_no_area = c(FALSE, FALSE, TRUE),
#'   flag_no_effort = c(FALSE, FALSE, TRUE), catch_status = "fish"
#' )
#' q <- knw_fdis_quality(sites)
#' q$kept$site_visit
#' q$ledger
knw_fdis_quality <- function(sites) {
  chk::chk_data(sites)
  chk::check_names(sites, c("site_visit", "flag_not_placed", "flag_far_snap", "flag_ws50_mismatch",
                            "flag_junk_date", "flag_effort_sentinel", "flag_no_area", "flag_no_effort",
                            "catch_status"))
  ledger <- tibble::tibble(kind = "in", step = "visits_in", n = nrow(sites), note = "")
  keep_step <- function(x, keep, step, note = "") {
    keep <- !is.na(keep) & keep
    ledger <<- rbind(ledger, tibble::tibble(kind = "drop", step = step, n = sum(!keep), note = note))
    x[keep, , drop = FALSE]
  }
  v <- keep_step(sites, !sites$flag_not_placed, "not_placed", "not placed on the FWA network")
  v <- keep_step(v, !v$flag_far_snap, "far_snap",
                 "snapped beyond the placement limit (one limit for a pick the 1:50k code confirms, one for the rest)")
  v <- keep_step(v, !(v$flag_ws50_mismatch %in% TRUE), "ws50_mismatch",
                 "FDIS 1:50k watershed code names no stream within the snap search")
  v <- keep_step(v, !v$flag_junk_date, "junk_date", "")
  v <- keep_step(v, !v$flag_effort_sentinel & (!v$flag_no_area | !v$flag_no_effort),
                 "effort_sentinel_or_none", "sentinel effort, or neither fished area nor time")
  v <- keep_step(v, v$catch_status != "unknown", "catch_unknown", "catch neither fish nor an explicit zero")
  ledger <- rbind(ledger, tibble::tibble(kind = "kept", step = "visits_kept", n = nrow(v), note = ""))
  if (sum(ledger$n[ledger$kind %in% c("drop", "kept")]) != nrow(sites)) {
    stop("ledger does not partition the input", call. = FALSE)
  }
  # how the kept visits reached their stream, where 0230's placement says (#91)
  if (all(c("snap_confirmed", "snap_moved") %in% names(v))) {
    info <- tibble::tibble(
      kind = "info", step = c("kept_snap_confirmed", "kept_snap_moved"),
      n = c(sum(v$snap_confirmed %in% TRUE), sum(v$snap_moved %in% TRUE)),
      note = c("kept on a stream the visit's 1:50k code names",
               "kept on a named stream that is not the nearest one (moved there)")
    )
    ledger <- rbind(ledger, info)
  }
  list(kept = v, ledger = ledger)
}
