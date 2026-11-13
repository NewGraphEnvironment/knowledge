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
