# knw_link_access_check(): link#349's cross-tabulation, per species and, with by_group, per group (#120)

access_mock <- function(env = parent.frame()) {
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    if (grepl("information_schema", sql)) {
      return(data.frame(table_name = c("streams_access", "streams_habitat_ch"), column_name = c("access_ch", "id_segment")))
    }
    by_group <- grepl("SELECT h.watershed_group_code,", sql, fixed = TRUE)
    x <- data.frame(habitat_accessible = c(TRUE, TRUE), access_gt0 = c(FALSE, TRUE), n_segments = c(2, 10),
                    n_rearing = c(1, 6), n_spawning = c(0, 3), km = c(0.5, 4))
    if (by_group) {
      x <- rbind(cbind(watershed_group_code = "BULK", x), cbind(watershed_group_code = "SETN", x[2, ]))
      stopifnot(grepl("GROUP BY 1, 2, 3", sql, fixed = TRUE))
    }
    x
  }, .package = "DBI", .env = env)
}

test_that("the cross-tabulation is per species, and per group with by_group", {
  access_mock()
  a <- knw_link_access_check(NULL, "zz415_minimal", c("CH", "KO"))
  expect_identical(a$skipped, "KO")
  expect_identical(names(a$check), c("species_code", "habitat_accessible", "access_gt0", "n_segments", "n_rearing",
                                     "n_spawning", "km"))
  expect_identical(nrow(a$check), 2L)
  g <- knw_link_access_check(NULL, "zz415_minimal", c("CH", "KO"), by_group = TRUE)
  expect_identical(names(g$check)[1:2], c("species_code", "watershed_group_code"))
  expect_identical(g$check$watershed_group_code, c("BULK", "BULK", "SETN"))
  expect_equal(sum(g$check$km), 8.5)
  # nothing to check still has the group column
  e <- knw_link_access_check(NULL, "zz415_minimal", "KO", by_group = TRUE)
  expect_identical(nrow(e$check), 0L)
  expect_true("watershed_group_code" %in% names(e$check))
  expect_error(knw_link_access_check(NULL, "zz415_minimal", "CH", by_group = NA))
})
