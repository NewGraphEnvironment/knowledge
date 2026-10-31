# measured against modelled gradient (#121): one code path for the check script and the methodology bundle

test_that("agreement reads ranks over every pair and logs and ratios over pairs both above 0", {
  a <- knw_gradient_agree(c(0, 0.01, 0.02, 0.05, NA), c(0.01, 0.012, 0.03, 0.04, 0.2))
  expect_identical(a$pairs, 4L)
  expect_identical(a$zero_pairs, 1L)
  expect_equal(a$spearman, 1)
  expect_equal(a$ratio_p50, round(stats::quantile(c(0.01 / 0.012, 0.02 / 0.03, 0.05 / 0.04), 0.5, names = FALSE), 2))
  expect_equal(a$model_higher_pct, 75)
})

test_that("a flip is a site on the other side of the limit, a reading on it counting as in", {
  lad <- c(0.07, 0.09, 0.11, 0.13, 0.15)
  d <- data.frame(meas = c(0.11, 0.12, 0.05, 0.10), segment_gradient = c(0.12, 0.10, 0.06, 0.10))
  f <- knw_gradient_flips(d, 0.11, "segment_gradient", lad)
  expect_identical(f$visits, 4L)
  expect_equal(f$flips_pct, 50)            # 0.11 in vs 0.12 out; 0.12 out vs 0.10 in
  expect_identical(f$band, "(0.09, 0.13]")
  expect_identical(f$band_visits, 3L)      # modelled 0.12, 0.10, 0.10
  expect_identical(f$meas_on_limit, 1L)
  expect_identical(f$meas_above_model_below, 1L)
  expect_identical(f$meas_below_model_above, 1L)
  # the ladder's top mirrors its last step; a limit off the ladder is refused
  expect_identical(knw_gradient_flips(d, 0.15, "segment_gradient", lad)$band, "(0.13, 0.17]")
  expect_identical(knw_gradient_flips(d, 0.07, "segment_gradient", lad)$band, "(0.05, 0.09]")
  expect_error(knw_gradient_flips(d, 0.10, "segment_gradient", lad), "not on its key's ladder")
})

test_that("the stream branch is the tuning's edge types and fished area with no river, wetland or lake", {
  fm <- formals(knw_tune_run)
  e <- eval(fm$edge_stream)[1]
  a <- mean(eval(fm$area_range))
  vl <- data.frame(gradient_pct = c(5, 5, 5, 5), gradient2_pct = NA, segment_start_offset_m = c(0, 10, 0, 0),
                   edge_type = c(e, e, e, 9999), wb_river = c(FALSE, TRUE, NA, FALSE), wb_wetland = FALSE,
                   wb_lake = FALSE, area_m2 = c(a, a, a, a))
  v <- knw_site_gradient_visits(vl)
  expect_equal(v$meas, rep(0.05, 4))
  expect_identical(v$stream_branch, c(TRUE, FALSE, TRUE, FALSE))
  expect_identical(v$at_visit, c(TRUE, FALSE, TRUE, TRUE))
})
