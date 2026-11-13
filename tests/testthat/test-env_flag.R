test_that(".knw_env_flag reads unset as the default and TRUE or FALSE as given", {
  withr::local_envvar(KNW_TEST_FLAG = NA)
  expect_false(.knw_env_flag("KNW_TEST_FLAG"))
  expect_true(.knw_env_flag("KNW_TEST_FLAG", default = TRUE))
  for (v in c("TRUE", "true", "1")) {
    withr::local_envvar(KNW_TEST_FLAG = v)
    expect_true(.knw_env_flag("KNW_TEST_FLAG"))
  }
  for (v in c("FALSE", "false", "0")) {
    withr::local_envvar(KNW_TEST_FLAG = v)
    expect_false(.knw_env_flag("KNW_TEST_FLAG", default = TRUE))
  }
  withr::local_envvar(KNW_TEST_FLAG = "")
  expect_false(.knw_env_flag("KNW_TEST_FLAG"))
})

test_that(".knw_env_flag refuses anything else", {
  for (v in c("yes", "T", "on", "TRUEE")) {
    withr::local_envvar(KNW_TEST_FLAG = v)
    expect_error(.knw_env_flag("KNW_TEST_FLAG"), "must be TRUE or FALSE")
  }
})

test_that("0330 reads GPKG through .knw_env_flag, off unless asked (#173)", {
  src <- testthat::test_path("..", "..", "scripts", "0330-compare.R")
  skip_if_not(file.exists(src), "scripts/ is not in the installed package")
  code <- readLines(src)
  expect_true(any(grepl('^gpkg <- \\.knw_env_flag\\("GPKG"\\)$', code)))
})

test_that("0330 builds the GeoPackage styles before it connects or compares anything (#173, review round 1)", {
  src <- testthat::test_path("..", "..", "scripts", "0330-compare.R")
  skip_if_not(file.exists(src), "scripts/ is not in the installed package")
  code <- readLines(src)
  styles <- grep("^gpkg_styles <- if \\(gpkg \\|\\| identical\\(stage_only, \"gpkg\"\\)\\) \\.compare_qgis_styles\\(\\)", code)
  first_conn <- grep("pg\\(\\)", code)
  expect_length(styles, 1)
  expect_lt(styles, min(first_conn))
  expect_false(any(grepl("styles = \\.compare_qgis_styles\\(\\)", code)))
})
