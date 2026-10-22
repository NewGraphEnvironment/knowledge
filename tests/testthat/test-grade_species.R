# knw_grade_species() walks every gradable accessible segment (#65): the curve reads size and distance
# jointly, so a segment that passes the size test needs its own distance as much as one that fails it.

grade_fixture <- function() {
  set.seed(5)
  n <- 600
  d <- data.frame(wsg = factor(rep(sprintf("W%02d", 1:10), each = 60)),
                  log_area = log(stats::runif(n, 20, 400)), data_set = factor(sample(c("FDS", "FDIS"), n, TRUE)),
                  era = factor(sample(c("to1994", "1995-2004", "2005on"), n, TRUE)),
                  blue_line_key = 1, downstream_route_measure = seq_len(n),
                  edge_type = 1000, mad_pick = exp(stats::runif(n, log(0.02), log(20))),
                  cw_deploy = exp(stats::runif(n, log(0.5), log(20))), fwa_gradient = stats::runif(n, 0, 0.15))
  dist <- exp(stats::runif(n, log(20), log(40000)))
  d$U <- stats::rbinom(n, 1, stats::plogis(-2 + 0.8 * log(d$mad_pick) - 10 * d$fwa_gradient - 0.3 * log(dist)))
  w <- data.frame(blue_line_key = 1, downstream_route_measure = seq_len(n), src = "pick", qmin = 3,
                  status = ifelse(dist > 30000, "none", "found"), dist_m = ifelse(dist > 30000, NA, dist))
  pick <- data.frame(rule = "r1", size_var = "mad", size_min = 0.75, grad_max = 0.07, exc_q = 3, exc_d = 1000)
  cv <- knw_tune_curve(d, pick, knw_walk_index(w), knowledge:::.tune_fold_of_wsg(d, "U", 1, 5))
  # segments: a = accessible, size-passing stream near a river; b = accessible, failing size;
  # c = accessible, steep; d = river polygon; e = canal (2000); f = inaccessible; g = no size;
  # h = no gradient; i = zero size; j = accessible, walk finds no river (the sea first)
  seg <- data.frame(id_segment = 1:10, watershed_group_code = "W01", linear_feature_id = 1:10,
                    blue_line_key = 100 + 1:10, downstream_route_measure = 0, upstream_route_measure = 100,
                    length_metre = 100,
                    edge_type = c(1000L, 1000L, 1000L, 1250L, 2000L, 1000L, 1000L, 1000L, 1000L, 1000L),
                    stream_order = 2L, access = 1L,
                    accessible = c(TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, TRUE, TRUE, TRUE, TRUE),
                    rearing = TRUE, spawning = FALSE,
                    gradient = c(0.02, 0.02, 0.12, 0.001, 0.005, 0.02, 0.02, NA, 0.02, 0.02),
                    channel_width = 5, mad_pick = c(2, 0.3, 2, 30, 1, 2, NA, 2, 0, 2))
  list(curve = cv, pick = pick, seg = seg)
}

run_grade <- function(fx, pick = fx$pick, walks_status = function(blk) ifelse(blk == 110, "none", "found")) {
  seen <- new.env()
  fake_walks <- function(connector, starts, q_grid, sources, workers) {
    seen$starts <- starts
    seen$q_grid <- q_grid
    st <- walks_status(starts$blue_line_key)
    tibble::tibble(blue_line_key = starts$blue_line_key, downstream_route_measure = starts$downstream_route_measure,
                   src = sources, qmin = q_grid, status = st, dist_m = ifelse(st == "found", 100, NA_real_))
  }
  testthat::local_mocked_bindings(knw_link_segments = function(conn, schema, species, wsg, ...) fx$seg,
                                  knw_link_walks = fake_walks, .package = "knowledge")
  conn <- function() DBI::dbConnect(duckdb::duckdb())
  g <- knw_grade_species(conn, "s", "CH", "W01", fx$curve, pick, workers = 1L)
  list(g = g, seen = seen)
}

test_that("every gradable accessible segment is walked, and nothing else is", {
  skip_if_not_installed("mgcv")
  skip_if_not_installed("duckdb")
  fx <- grade_fixture()
  r <- run_grade(fx)
  # every accessible segment with a gradient, on any edge type and gradient, and whatever its size: the
  # exception reads the distance of a segment whose size is missing or 0 (g, i), though it is not graded
  expect_setequal(r$seen$starts$blue_line_key, 100 + c(1, 2, 3, 4, 5, 7, 9, 10))
  # the size-passing segment beside a river carries its distance, not the cap
  expect_true(101 %in% r$seen$starts$blue_line_key)
  gr <- r$g$grades
  expect_equal(gr$dist_m[gr$id_segment == 1], 100)
  expect_equal(gr$dist_status[gr$id_segment == 1], "found")
  expect_equal(gr$dist_status[gr$id_segment %in% c(6, 8)], rep("no_walk", 2))
  expect_equal(gr$dist_m[gr$id_segment %in% c(7, 9)], c(100, 100))
  expect_true(all(is.na(gr$grade[gr$id_segment %in% c(7, 9)])))
  # the walk that found no river keeps the cap and says so
  expect_true(is.na(gr$dist_m[gr$id_segment == 10]))
  expect_equal(gr$dist_status[gr$id_segment == 10], "none")
  expect_false(is.na(gr$grade[gr$id_segment == 10]))
  # an inaccessible segment is not graded
  expect_true(is.na(gr$grade[gr$id_segment == 6]))
  expect_equal(unname(r$g$counts[c("walked", "walk_found", "walk_none", "walk_other")]), c(8, 7, 1, 0))
})

test_that("the walk goes to the pick's exception river, or the curve's when the pick has none", {
  skip_if_not_installed("mgcv")
  skip_if_not_installed("duckdb")
  fx <- grade_fixture()
  expect_equal(run_grade(fx)$seen$q_grid, 3)
  expect_equal(fx$curve$q, 3)
  no_exc <- fx$pick
  no_exc$exc_q <- NA_real_
  no_exc$exc_d <- NA_real_
  fx$curve$q <- 10   # a curve fitted on a pick with no exception reads distance to q_default
  expect_equal(run_grade(fx, pick = no_exc)$seen$q_grid, 10)
  # a candidate whose exception names another river walks to its own, which the comparison reads
  other <- fx$pick
  other$exc_q <- 1
  expect_equal(run_grade(fx, pick = other)$seen$q_grid, 1)
})

test_that("a size-passing segment's distance reaches its rate: beside a river is not the cap", {
  skip_if_not_installed("mgcv")
  skip_if_not_installed("duckdb")
  fx <- grade_fixture()
  near <- run_grade(fx)$g$grades
  far <- run_grade(fx, walks_status = function(blk) rep("none", length(blk)))$g$grades
  expect_true(is.finite(near$rate[near$id_segment == 1]) && is.finite(far$rate[far$id_segment == 1]))
  expect_gt(abs(near$rate[near$id_segment == 1] - far$rate[far$id_segment == 1]), 1e-4)
})

test_that("the reference reads 1 at the stream branch's top, and off-branch segments are still graded", {
  skip_if_not_installed("mgcv")
  skip_if_not_installed("duckdb")
  fx <- grade_fixture()
  r <- run_grade(fx)$g
  gr <- r$grades
  stream <- gr$accessible & !is.na(gr$rate) & gr$edge_type %in% c(1000L, 1100L, 2000L, 2300L)
  expect_equal(r$reference, unname(stats::quantile(gr$rate[stream], 0.95)))
  # the river polygon (d), outside the reference population, is graded against it, not left out
  expect_false(anyNA(gr$grade[gr$id_segment %in% c(4, 5)]))
  # knw_grade() alone: ref_rows narrows the reference, NULL keeps every accessible segment
  seg <- data.frame(accessible = TRUE, size = c(0.5, 2, 30), gradient = 0.02, dist_m = c(5000, 100, 0))
  all <- knw_grade(fx$curve, seg, cols = c(size = "size", grad = "gradient", dist = "dist_m"))
  one <- knw_grade(fx$curve, seg, cols = c(size = "size", grad = "gradient", dist = "dist_m"),
                   ref_rows = c(TRUE, TRUE, FALSE))
  expect_equal(one$reference, unname(stats::quantile(all$grades$rate[1:2], 0.95)))
  expect_error(knw_grade(fx$curve, seg, cols = c(size = "size", grad = "gradient", dist = "dist_m"),
                         ref_rows = TRUE), "one value per segment")
})

test_that("the grade records how it was made: the curve's edge types, the river size and the walk (#72)", {
  skip_if_not_installed("mgcv")
  skip_if_not_installed("duckdb")
  fx <- grade_fixture()
  r <- run_grade(fx)$g
  # a curve with no edge_stream recorded takes knw_tune_run()'s default
  expect_identical(r$ref_edge, c(1000L, 1100L, 2000L, 2300L))
  expect_identical(r$q, 3)
  expect_identical(r$walk, "bank")
  expect_true("target_in_group" %in% names(r$grades))
  expect_true(all(is.na(r$grades$target_in_group)))   # the mock walk names no river segment
  # a curve that records its edge types is graded against them
  fx$curve$edge_stream <- c(1000L, 2000L)
  r2 <- run_grade(fx)$g
  expect_identical(r2$ref_edge, c(1000L, 2000L))
  gr <- r2$grades
  stream <- gr$accessible & !is.na(gr$rate) & gr$edge_type %in% c(1000L, 2000L)
  expect_equal(r2$reference, unname(stats::quantile(gr$rate[stream], 0.95)))
})
