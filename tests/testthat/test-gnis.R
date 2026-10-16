test_that("collisions count groups per name and flag the single-group ones", {
  skip_if_not_installed("duckdb")
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  DBI::dbWriteTable(con, "streams", data.frame(
    gnis_name = c("Boulder Creek", "Boulder Creek", "Boulder Creek", "Wildmare Creek", "Other Creek", "Wildmare Creek"),
    watershed_group_code = c("PINE", "LNTH", "ADMS", "PINE", "LNTH", NA)))
  seed <- c("Boulder Creek", "Wildmare Creek", "Other Creek", "Ghost Creek", "Not A Stream")
  out <- knw_gnis_collisions(con, seed, "PINE", table = "streams")
  expect_equal(out$gnis_name, c("Boulder Creek", "Other Creek", "Wildmare Creek"))
  expect_equal(out$n_wsg, c(3L, 1L, 1L))
  expect_equal(out$wsgs[1], "ADMS,LNTH,PINE")
  expect_equal(out$wsg_only, c(FALSE, FALSE, TRUE))   # the NULL-coded Wildmare row is not a group
  expect_equal(attr(out, "not_found"), "Ghost Creek")   # "Not A Stream" fails the pattern
})

test_that("an empty seed and a seed with no hits both return a typed empty result", {
  skip_if_not_installed("duckdb")
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  DBI::dbWriteTable(con, "streams", data.frame(gnis_name = "X Creek", watershed_group_code = "PINE"))
  e1 <- knw_gnis_collisions(con, character(), "PINE", table = "streams")
  e2 <- knw_gnis_collisions(con, "Ghost Creek", "PINE", table = "streams")
  expect_equal(nrow(e1), 0L); expect_equal(nrow(e2), 0L)
  expect_equal(attr(e2, "not_found"), "Ghost Creek")
})

test_that("a quote in a seed name is escaped, not injected", {
  skip_if_not_installed("duckdb")
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  DBI::dbWriteTable(con, "streams", data.frame(gnis_name = "O'Brien Creek", watershed_group_code = "PINE"))
  out <- knw_gnis_collisions(con, "O'Brien Creek", "PINE", table = "streams")
  expect_equal(out$wsg_only, TRUE)
})
