# knw_link_walks() walks the live network, so its contract is pinned on one start in the database
# (skipped without one). The bank rule itself (#73) is proved by data-raw/walk_bank_check.R against
# fresh's frs_near_river() on a whole watershed group, which no fixture can stand in for: the walk
# reads whse_basemapping and discharge by name.

test_that("the walk returns the bank distance beside the centreline distance, and never stops on a connector", {
  conn <- skip_if_no_pg("discharge")
  pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
  # the roxygen example's start, a Bulkley tributary found on its own line, and a start at the mouth of a
  # Bulkley line that must hop to its parent (the plan review's probe: a hop is where the walk's path
  # rules run, and where the first draft failed)
  w <- knw_link_walks(pg, data.frame(blue_line_key = c(360886335, 360873822), downstream_route_measure = c(1520, 0)),
                      q_grid = c(3, 10), sources = "pick", workers = 1L)
  expect_identical(nrow(w), 4L)
  expect_true(any(w$n_hops > 0 & w$status == "found"))
  expect_true(all(c("dist_m", "dist_centre_m", "bank_m", "large_edge") %in% names(w)))
  f <- w[w$status == "found", ]
  expect_gt(nrow(f), 0)
  expect_true(all(f$bank_m >= 0))
  expect_equal(f$dist_m, pmax(f$dist_centre_m - f$bank_m, 0))
  expect_false(any(f$large_edge %in% c(1400L, 1450L)))
  nf <- w[w$status != "found", ]
  expect_true(all(is.na(nf$dist_centre_m)) && all(is.na(nf$bank_m)))
})
