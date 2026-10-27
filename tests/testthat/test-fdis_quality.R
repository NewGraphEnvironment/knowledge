sites_fx <- function() {
  data.frame(
    site_visit = paste0("v", 1:8),
    flag_not_placed = c(TRUE, rep(FALSE, 7)),
    flag_far_snap = c(FALSE, TRUE, rep(FALSE, 6)),
    flag_ws50_mismatch = c(FALSE, FALSE, TRUE, NA, rep(FALSE, 4)),
    flag_junk_date = c(rep(FALSE, 4), TRUE, FALSE, FALSE, FALSE),
    flag_effort_sentinel = c(rep(FALSE, 5), TRUE, FALSE, FALSE),
    flag_no_area = c(rep(FALSE, 6), TRUE, TRUE),
    flag_no_effort = c(rep(FALSE, 6), TRUE, FALSE),
    catch_status = c(rep("fish", 7), "unknown"),
    stringsAsFactors = FALSE
  )
}

test_that("each drop is one ledger row and the ledger partitions the input", {
  q <- knw_fdis_quality(sites_fx())
  expect_equal(q$kept$site_visit, "v4")
  expect_equal(q$ledger$kind, c("in", rep("drop", 6), "kept"))
  expect_equal(q$ledger$step, c("visits_in", "not_placed", "far_snap", "ws50_mismatch", "junk_date",
                                "effort_sentinel_or_none", "catch_unknown", "visits_kept"))
  expect_equal(q$ledger$n, c(8, 1, 1, 1, 1, 2, 1, 1))
  expect_equal(sum(q$ledger$n[q$ledger$kind %in% c("drop", "kept")]), 8)
})

test_that("an NA ws50 flag is not a mismatch, and one of area or time is enough effort", {
  s <- sites_fx()[c(4, 7, 8), ]
  s$catch_status <- "zero"
  q <- knw_fdis_quality(s)
  expect_equal(q$kept$site_visit, c("v4", "v8"))
  expect_equal(q$ledger$n[q$ledger$step == "effort_sentinel_or_none"], 1)
})

test_that("a missing flag column is refused", {
  s <- sites_fx()
  s$flag_junk_date <- NULL
  expect_error(knw_fdis_quality(s), "flag_junk_date")
})

test_that("the snap columns, where present, add info rows outside the partition", {
  s <- sites_fx()
  s$catch_status <- "fish"
  s$snap_confirmed <- c(TRUE, TRUE, FALSE, TRUE, FALSE, FALSE, TRUE, NA)
  s$snap_moved <- c(TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, NA)
  q <- knw_fdis_quality(s)
  expect_equal(q$kept$site_visit, c("v4", "v8"))
  info <- q$ledger[q$ledger$kind == "info", ]
  expect_equal(info$step, c("kept_snap_confirmed", "kept_snap_moved"))
  # v4 is confirmed and moved; v8's NA counts as neither
  expect_equal(info$n, c(1, 1))
  expect_equal(sum(q$ledger$n[q$ledger$kind %in% c("drop", "kept")]), 8)
  expect_false(any(knw_fdis_quality(sites_fx())$ledger$kind == "info"))
})
