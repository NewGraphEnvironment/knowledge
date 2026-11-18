# knw_nuseds_fetch() and knw_nuseds_records() (#108). The fetcher's network calls are mocked: both stop by default,
# and a test that needs one re-mocks it, so no test reaches the portal.
local_nuseds_offline <- function(env = parent.frame()) {
  testthat::local_mocked_bindings(
    .knw_nuseds_resources = function(...) stop("network: resources not mocked"),
    .knw_nuseds_download = function(...) stop("network: download not mocked"),
    .env = env
  )
}

# a zip at `dest` holding the files named in `files`
write_zip <- function(dest, files) {
  testthat::skip_if_not(nzchar(Sys.which("zip")))
  d <- tempfile("nuseds_zip")
  dir.create(d)
  for (f in files) writeLines("AREA,WATERBODY", file.path(d, f))
  withr::with_dir(d, utils::zip(dest, files, flags = "-q"))
  invisible(dest)
}

resources <- function(rel = c("20260601", "20251103")) {
  data.frame(name = c(paste0("All Areas NuSEDS_", rel, ".zip"), "Data Dictionary NuSEDS_EN.csv"),
             url = c(paste0("https://example.invalid/", rel, ".zip"), "https://example.invalid/dd.csv"))
}

test_that("the fetcher downloads the newest release once, then returns it held", {
  dir <- withr::local_tempdir()
  local_nuseds_offline()
  got <- character()
  local_mocked_bindings(
    .knw_nuseds_resources = function(...) resources(),
    .knw_nuseds_download = function(src, dest) {
      got <<- c(got, src)
      write_zip(dest, "All Areas NuSEDS_20260601.csv")
    }
  )
  a <- knw_nuseds_fetch(dir)
  expect_identical(a$release, "20260601")
  expect_true(a$downloaded)
  expect_true(file.exists(a$path))
  expect_identical(a$md5, unname(tools::md5sum(a$path)))
  b <- knw_nuseds_fetch(dir)
  expect_false(b$downloaded)
  expect_identical(b$md5, a$md5)
  expect_identical(got, "https://example.invalid/20260601.zip")
})

test_that("a named release already held is returned without asking the portal", {
  dir <- withr::local_tempdir()
  local_nuseds_offline()
  dest <- file.path(dir, "20251103", "nuseds_all_areas_20251103.zip")
  dir.create(dirname(dest))
  write_zip(dest, "x.csv")
  x <- knw_nuseds_fetch(dir, release = "20251103")
  expect_false(x$downloaded)
  expect_identical(x$path, dest)
})

test_that("a release the record does not list, or a malformed one, is refused", {
  dir <- withr::local_tempdir()
  local_nuseds_offline()
  local_mocked_bindings(.knw_nuseds_resources = function(...) resources())
  expect_error(knw_nuseds_fetch(dir, release = "20200101"), "not on the NuSEDS record")
  expect_error(knw_nuseds_fetch(dir, release = "2026-06-01"), "YYYYMMDD")
  local_mocked_bindings(.knw_nuseds_resources = function(...) resources()[3, ])
  expect_error(knw_nuseds_fetch(dir), "lists no All Areas")
})

test_that("a download that is not one CSV in a zip is refused and nothing is kept", {
  dir <- withr::local_tempdir()
  local_nuseds_offline()
  local_mocked_bindings(
    .knw_nuseds_resources = function(...) resources(),
    .knw_nuseds_download = function(src, dest) write_zip(dest, c("a.csv", "b.csv"))
  )
  expect_error(knw_nuseds_fetch(dir), "not one CSV")
  expect_false(dir.exists(file.path(dir, "20260601")))
  local_mocked_bindings(.knw_nuseds_download = function(src, dest) writeLines("<html>", dest))
  expect_error(knw_nuseds_fetch(dir), "not a zip")
})

test_that("evidence_kind follows its precedence", {
  x <- data.frame(
    adult_presence = c("PRESENT", "PRESENT", "PRESENT", "PRESENT", "PRESENT", "NONE OBSERVED", "NOT INSPECTED",
                       "UNKNOWN", NA, "PRESENT"),
    natural_adult_spawners = c(NA, 12, NA, NA, NA, 0, NA, NA, NA, 0),
    total_return_to_river = c(50, NA, NA, NA, NA, NA, NA, NA, NA, NA),
    enumeration_methods = c("Walk", NA, NA, "Helicopter", NA, NA, NA, NA, NA, NA),
    no_inspections_used = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, 2),
    estimate_method = c("Unknown Estimate Method", "Expert Opinion", "Expert Opinion", "Unknown Estimate Method",
                        "Unknown Estimate Method", "Expert Opinion", "Not Applicable", NA, NA, "Expert Opinion"),
    stringsAsFactors = FALSE
  )
  want <- c("count", "count_expert", "presence_expert", "presence_survey", "presence_unrecorded", "none_observed",
            "not_inspected", "unknown", "unknown", "presence_survey")
  expect_identical(.knw_nuseds_kind(x), want)
  expect_true(all(.knw_nuseds_kind(x) %in% knw_nuseds_kinds()))
})

nuseds_fixture <- function() {
  f <- system.file("extdata/examples/dfo/nuseds_all_areas_2026-06-01.csv", package = "crate")
  # a failure, not a skip: knw_nuseds_records() cannot read anything on a crate without it, and a skip would keep
  # CI green on an install that is broken
  if (!nzchar(f)) testthat::fail("the installed crate has no dfo/nuseds_all_areas registration (crate#74)")
  f
}

test_that("Maxan Creek chinook's records carry the evidence #108 measured", {
  x <- knw_nuseds_records(nuseds_fixture())
  m <- x[x$waterbody == "MAXAN CREEK", ]
  kind <- stats::setNames(m$evidence_kind, m$analysis_yr)
  expect_identical(unname(kind[c("1988", "1993", "2003", "2008", "1986", "2007")]),
                   c("count", "count", "presence_survey", "presence_expert", "none_observed", "none_observed"))
  expect_true(all(kind[!names(kind) %in% c("1986", "1988", "1993", "2003", "2007", "2008")] == "not_inspected"))
  expect_identical(m$total_return_to_river[m$analysis_yr == 1988L], 50)
})

test_that("a repeated estimate is refused", {
  f <- nuseds_fixture()
  dup <- withr::local_tempfile(fileext = ".csv")
  raw <- readLines(f, encoding = "latin1")
  writeLines(c(raw, raw[2]), dup, useBytes = TRUE)
  expect_error(knw_nuseds_records(dup), "act_id values repeat")
})
