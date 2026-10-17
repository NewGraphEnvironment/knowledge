# The repo's top-level data/ holds pipeline snapshots, not package data, and is
# excluded from the build. pkgload::load_all() still treats it as package data:
# it sources every .R and loads every .rda/.RData at the top of data/. So none
# may sit there. The directory is absent from an installed or checked package,
# where the test skips.
test_that("no .R or .rda file sits at the top of the repo's data/", {
  data_dir <- testthat::test_path("..", "..", "data")
  skip_if_not(dir.exists(data_dir), "no source-tree data/ (installed package)")
  hits <- list.files(data_dir, pattern = "\\.([rR]|[rR][dD]a(ta)?)$")
  expect_identical(hits, character(0))
})
