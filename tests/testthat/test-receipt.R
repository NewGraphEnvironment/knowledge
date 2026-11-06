# the receipt declarations knowledge ships (#154)

test_that("every declaration parses and names its own output", {
  files <- list.files(system.file("receipt", package = "knowledge"), "\\.yaml$")
  expect_setequal(sub("\\.yaml$", "", files), c("grade", "thresholds", "habitat_grade"))
  for (f in sub("\\.yaml$", "", files)) {
    k <- knw_receipt_keys(f)
    expect_s3_class(k, "crt_receipt_keys")
    expect_identical(k$output, f, info = f)
  }
  expect_error(knw_receipt_keys("nope"), "no receipt declaration for nope")
})

test_that("every declared config file is one the package installs", {
  for (f in c("grade", "thresholds", "habitat_grade")) {
    k <- knw_receipt_keys(f)
    for (cf in k$config_files) {
      expect_true(startsWith(cf, "inst/"), info = cf)
      expect_true(nzchar(system.file(sub("^inst/", "", cf), package = "knowledge")), info = cf)
    }
  }
})

test_that("the commit state is a full sha and a flag", {
  skip_if_not(dir.exists(file.path(rprojroot::find_package_root_file(), ".git")) ||
                file.exists(file.path(rprojroot::find_package_root_file(), ".git")), "not a checkout")
  s <- .knw_git_state(rprojroot::find_package_root_file())
  expect_match(s$commit, "^[0-9a-f]{40}$")
  expect_type(s$dirty, "logical")
  expect_error(.knw_git_state(withr::local_tempdir()), "not a git checkout")
  expect_error(.knw_receipt_code(list(commit = "a")), "names commit and dirty")
})
