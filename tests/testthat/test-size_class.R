breaks_fixture <- function() {
  data.frame(
    species_group = c("char", "char", "CH", "CH"),
    size_class    = c("fry", "juvenile", "fry", "parr"),
    length_min_mm = c(0, 80, 0, 70),
    length_max_mm = c(80, Inf, 70, Inf)
  )
}

test_that("a fish on a break takes the upper class", {
  expect_equal(knw_size_class(c("char", "char", "char"), c(79.9, 80, 81), breaks_fixture()),
               c("fry", "juvenile", "juvenile"))
  expect_equal(knw_size_class("CH", 70, breaks_fixture()), "parr")
})

test_that("groups are classed by their own breaks", {
  expect_equal(knw_size_class(c("CH", "char"), c(75, 75), breaks_fixture()), c("parr", "fry"))
})

test_that("NA, zero and negative lengths are unmeasured, not an error", {
  expect_equal(knw_size_class(rep("CH", 3), c(NA, 0, -5), breaks_fixture()),
               rep(NA_character_, 3))
})

test_that("an empty input returns an empty character", {
  expect_identical(knw_size_class(character(0), numeric(0), breaks_fixture()), character(0))
})

test_that("overlapping breaks are an error", {
  b <- breaks_fixture()
  b$length_max_mm[1] <- 90
  expect_error(knw_size_class("char", 85, b), "overlap or leave gaps")
})

test_that("a gap in the breaks is an error", {
  b <- breaks_fixture()
  b$length_min_mm[2] <- 90
  expect_error(knw_size_class("char", 85, b), "overlap or leave gaps")
})

test_that("a measured fish of a group with no breaks is an error", {
  expect_error(knw_size_class("RB", 100, breaks_fixture()), "first: RB at 100 mm")
})

test_that("mismatched lengths are refused", {
  expect_error(knw_size_class(c("CH", "CH"), 50, breaks_fixture()))
})
