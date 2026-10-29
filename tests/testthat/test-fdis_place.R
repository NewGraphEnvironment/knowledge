# One visit per branch:
#   a  no code                          nearest, unconfirmed, 20 m
#   b  code names its nearest stream    confirmed, not moved
#   c  code names another stream        moved to it (60 m; the nearest is 10 m away)
#   d  code names a stream out of reach no hit: kept on the nearest, ws50 mismatch
#   e  no code, 150 m                   far unconfirmed at limit_near 100
#   f  code names a stream 400 m away   confirmed, far only once limit_code < 400
#   g  no stream in reach               not placed
#   h  code names two streams in reach  the nearer hit wins (80 m over 90 m)
#   i  tie between two hits at 70 m     the lower linear_feature_id wins
place_fx <- function() {
  nearest <- data.frame(
    site_visit = letters[1:9],
    blue_line_key = c(1, 2, 3, 4, 5, 6, NA, 7, 8),
    downstream_route_measure = c(10, 20, 30, 40, 50, 60, NA, 70, 80),
    linear_feature_id = c(101, 201, 301, 401, 501, 601, NA, 701, 801),
    distance_to_stream = c(20, 5, 10, 30, 150, 120, NA, 15, 25),
    stringsAsFactors = FALSE
  )
  hinted <- data.frame(
    site_visit = c("b", "c", "d", "f", "h", "h", "i", "i"),
    hint_blue_line_key = c(2, 33, 44, 66, 88, 89, 91, 92),
    blue_line_key = c(2, 33, NA, 66, 88, 89, 91, 92),
    downstream_route_measure = c(20, 333, NA, 666, 888, 899, 911, 922),
    linear_feature_id = c(201, 3301, NA, 6601, 8801, 8901, 9150, 9101),
    distance_to_stream = c(5, 60, NA, 400, 90, 80, 70, 70),
    stringsAsFactors = FALSE
  )
  list(nearest = nearest, hinted = hinted)
}

test_that("each branch picks the stream and sets the flags it should", {
  fx <- place_fx()
  p <- knw_fdis_place(fx$nearest, fx$hinted, limit_near = 100, limit_code = 500)
  expect_equal(p$site_visit, letters[1:9])
  expect_equal(p$snap_method, c("nearest", "code", "code", "nearest", "nearest", "code", NA, "code", "code"))
  expect_equal(p$snap_confirmed, c(FALSE, TRUE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, TRUE))
  expect_equal(p$snap_moved, c(FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, TRUE))
  expect_equal(p$blue_line_key, c(1, 2, 33, 4, 5, 66, NA, 89, 92))
  expect_equal(p$linear_feature_id, c(101, 201, 3301, 401, 501, 6601, NA, 8901, 9101))
  expect_equal(p$downstream_route_measure, c(10, 20, 333, 40, 50, 666, NA, 899, 922))
  expect_equal(p$distance_to_stream, c(20, 5, 60, 30, 150, 400, NA, 80, 70))
  expect_equal(p$nearest_distance_m, fx$nearest$distance_to_stream)
  expect_equal(p$ws50_checked, c(FALSE, TRUE, TRUE, TRUE, FALSE, TRUE, FALSE, TRUE, TRUE))
  expect_equal(p$flag_not_placed, c(rep(FALSE, 6), TRUE, FALSE, FALSE))
  expect_equal(p$flag_far_snap, c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_equal(p$flag_ws50_mismatch, c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE))
})

test_that("each limit flips only the rows it governs", {
  fx <- place_fx()
  base <- knw_fdis_place(fx$nearest, fx$hinted, limit_near = 100, limit_code = 500)$flag_far_snap
  # limit_near at 25: a (20 m) stays, d (30 m, unconfirmed) and e flip; confirmed picks do not move
  near <- knw_fdis_place(fx$nearest, fx$hinted, limit_near = 25, limit_code = 500)$flag_far_snap
  expect_equal(which(near != base), 4L)
  expect_equal(which(near), c(4L, 5L))
  # limit_code at 300: only f (400 m, confirmed) flips; e (150 m, unconfirmed) is untouched
  code <- knw_fdis_place(fx$nearest, fx$hinted, limit_near = 100, limit_code = 300)$flag_far_snap
  expect_equal(which(code != base), 6L)
  # limit_code at 60: c (60 m) is at the limit, not beyond it; h (80 m) and i (70 m) flip
  code60 <- knw_fdis_place(fx$nearest, fx$hinted, limit_near = 100, limit_code = 60)$flag_far_snap
  expect_equal(which(code60), c(5L, 6L, 8L, 9L))
})

test_that("a visit with no hinted rows is unconfirmed and never a ws50 mismatch", {
  fx <- place_fx()
  p <- knw_fdis_place(fx$nearest, fx$hinted[0, ], limit_near = 100, limit_code = 500)
  expect_true(all(p$snap_method[!p$flag_not_placed] == "nearest"))
  expect_false(any(p$snap_confirmed | p$snap_moved | p$ws50_checked | p$flag_ws50_mismatch))
  expect_equal(p$blue_line_key, fx$nearest$blue_line_key)
})

test_that("malformed input is refused", {
  fx <- place_fx()
  expect_error(knw_fdis_place(rbind(fx$nearest, fx$nearest[1, ]), fx$hinted), "one row per site_visit")
  h <- fx$hinted
  h$site_visit[1] <- "z"
  expect_error(knw_fdis_place(fx$nearest, h), "not in nearest")
  h <- fx$hinted
  h$blue_line_key[2] <- 34
  expect_error(knw_fdis_place(fx$nearest, h), "another stream than its hint")
  h <- fx$hinted
  h$hint_blue_line_key <- NULL
  expect_error(knw_fdis_place(fx$nearest, h), "hint_blue_line_key")
  # the refusal reads the class only, so no bit64 is needed to build one
  n <- fx$nearest
  class(n$linear_feature_id) <- "integer64"
  expect_error(knw_fdis_place(n, fx$hinted), "integer64.*linear_feature_id")
})
