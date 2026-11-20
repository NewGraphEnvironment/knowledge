test_that("the span runs up the fished length from the downstream point, capped at the blue line's top", {
  s <- knw_fdis_span(downstream_route_measure = c(100, 900, 50, 50, 50, NA),
                     fished_length_m = c(200, 300, NA, 0, 9999, 100),
                     line_top_m = c(5000, 1000, 5000, 5000, 5000, 5000))
  expect_identical(s$upstream_route_measure, c(300, 1000, NA, NA, NA, NA))
  expect_identical(s$flag_span_capped, c(FALSE, TRUE, FALSE, FALSE, FALSE, FALSE))
})

test_that("a point beyond its line's top, or a line with no top, gives no span", {
  s <- knw_fdis_span(c(1200, 10), c(50, 50), c(1000, NA))
  expect_true(all(is.na(s$upstream_route_measure)))
  expect_false(any(s$flag_span_capped))
})

test_that("arguments of unequal length refuse", {
  expect_error(knw_fdis_span(1:2, 1, 1:2), "same length")
})
