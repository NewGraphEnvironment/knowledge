# knw_link_segments(gradient =): where a segment's gradient comes from (#120)

test_that("each gradient source reads its own column, and an unknown one is refused", {
  expect_identical(.knw_seg_grad("segment", "fresh_default"), list(col = "s.gradient", join = ""))
  p <- .knw_seg_grad("parent", "fresh_default")
  expect_identical(p$col, "kp.gradient_minimal")
  expect_match(p$join, "LEFT JOIN fresh_default.streams_parent kp ON kp.id_segment = s.id_segment", fixed = TRUE)
  expect_match(p$join, "kp.watershed_group_code = s.watershed_group_code", fixed = TRUE)
  f <- .knw_seg_grad("fwa", "fresh_default")
  expect_identical(f$col, "kf.gradient")
  expect_match(f$join, "fwa_stream_networks_sp kf ON kf.linear_feature_id = s.linear_feature_id", fixed = TRUE)
  expect_error(.knw_seg_grad("whole_line", "fresh_default"), "gradient must be segment, parent or fwa")
})

test_that("a source missing a gradient the segment has is refused, and the parent table is checked first", {
  n_missing <- 0L
  asked <- character()
  local_mocked_bindings(dbGetQuery = function(conn, sql, ...) {
    asked <<- c(asked, sql)
    data.frame(n = n_missing)
  }, .package = "DBI")
  read <- 0L
  local_mocked_bindings(knw_parent_read = function(...) {
    read <<- read + 1L
    data.frame()
  })
  expect_invisible(.knw_seg_grad_check(NULL, "segment", "fresh_default", "BULK"))
  expect_length(asked, 0)
  expect_invisible(.knw_seg_grad_check(NULL, "fwa", "fresh_default", "BULK"))
  expect_match(asked[1], "kf.gradient IS NULL", fixed = TRUE)
  expect_identical(read, 0L)
  expect_invisible(.knw_seg_grad_check(NULL, "parent", "fresh_default", "BULK"))
  expect_identical(read, 1L)
  n_missing <- 3L
  expect_error(.knw_seg_grad_check(NULL, "fwa", "fresh_default", "BULK"),
               "3 segments of fresh_default have a gradient of their own and none from the fwa source")
  expect_error(.knw_seg_grad_check(NULL, "parent", "fresh_default", "BULK"), "none from the parent source")
})
