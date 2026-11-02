# knw_parent_join(): each visit's minimal-network parent on its full-network segment (#120)

parent_fx <- function() {
  data.frame(id_segment = c(10, 11, 12, 10), wsg = c("BULK", "BULK", "BULK", "SETN"),
             id_segment_minimal = c(4, 4, 5, 9), gradient_minimal = c(0.012, 0.012, 0.031, 0.002),
             length_minimal = c(900, 900, 400, 2000), overlap_m = c(120, 300, 400, 50), straddle_m = c(0, 15, 0, 0))
}

test_that("each visit takes its own group's parent, in the visits' order", {
  v <- data.frame(site_visit = c("c", "a", "b"), watershed_group_code = c("SETN", "BULK", "BULK"),
                  id_segment = c(10, 10, 12))
  j <- knw_parent_join(v, parent_fx())
  expect_identical(j$site_visit, c("c", "a", "b"))
  expect_identical(j$parent_id_segment, c(9, 4, 5))
  expect_identical(j$parent_gradient, c(0.002, 0.012, 0.031))
  expect_identical(j$parent_length_m, c(2000, 900, 400))
  expect_identical(j$parent_straddle_m, c(0, 0, 0))
  # an id_segment read as integer64 or character joins all the same
  v$id_segment <- as.character(v$id_segment)
  expect_identical(knw_parent_join(v, parent_fx())$parent_id_segment, c(9, 4, 5))
})

test_that("a visit with no parent, or a segment with two, stops the join", {
  v <- data.frame(site_visit = "x", watershed_group_code = "MORK", id_segment = 10)
  expect_error(knw_parent_join(v, parent_fx()), "1 placed visits have no parent row \\(groups MORK\\)")
  p <- rbind(parent_fx(), parent_fx()[1, ])
  expect_error(knw_parent_join(v, p), "1 full segments have two parent rows")
  expect_error(knw_parent_join(v[, 1:2], parent_fx()))
})

test_that("a parent table of another build of the same group is caught by its lengths (#120 review)", {
  # link numbers each group's segments from 1, so another build's table covers the same ids
  v <- data.frame(site_visit = c("a", "b"), watershed_group_code = "BULK", id_segment = c(10, 11),
                  segment_length_m = c(120, 315))
  expect_identical(knw_parent_join(v, parent_fx())$parent_gradient, c(0.012, 0.012))
  v$segment_length_m[2] <- 290
  expect_error(knw_parent_join(v, parent_fx()), "1 placed visits sit on a segment whose length is not its parent row's")
  # within a centimetre is the same segment
  v$segment_length_m[2] <- 315.004
  expect_identical(nrow(knw_parent_join(v, parent_fx())), 2L)
})
