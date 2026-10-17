vis <- function() {
  data.frame(edge_type = c(1000, 1000, 1000, 1250, 1000), blue_line_key = 1, downstream_route_measure = 1:5,
             fwa_gradient = c(0.02, 0.02, 0.08, 0.01, NA), cw_deploy = c(2, 1, 2, 50, 3),
             mad_pick = c(0.3, 0.1, 1, 40, 0.5))
}
rule <- function(size_var = "width", size_min = 1.5, grad_max = 0.0549, exc_q = NA, exc_d = NA) {
  data.frame(size_var = size_var, size_min = size_min, grad_max = grad_max, exc_q = exc_q, exc_d = exc_d)
}

test_that("width and MAD size tests, the gradient test, and NA failing", {
  expect_equal(knw_rule_in(vis(), rule()), c(TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_equal(knw_rule_in(vis(), rule("mad", 0.28)), c(TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_equal(knw_rule_in(vis(), rule("mad", 0.28, grad_max = 0.09)), c(TRUE, FALSE, TRUE, FALSE, FALSE))
})

test_that("the exception admits a small stream near a river, by source and size", {
  w <- data.frame(blue_line_key = 1, downstream_route_measure = rep(1:5, 2), src = rep(c("pick", "wet_balance"), each = 5),
                  qmin = 3, status = c("found", "found", "none", "found", "found", rep("found", 5)),
                  dist_m = c(5000, 400, NA, 10, 100, 5000, 5000, 5000, 5000, 5000),
                  target_lake = c(FALSE, FALSE, FALSE, FALSE, TRUE, rep(FALSE, 5)))
  ix <- knw_walk_index(w)
  expect_named(ix, c("pick|3", "wet_balance|3"))
  expect_equal(ix[["pick|3"]]$dist[3], Inf)
  r <- rule("mad", 0.28, exc_q = 3, exc_d = 500)
  expect_equal(knw_rule_in(vis(), r, ix), c(TRUE, TRUE, FALSE, FALSE, FALSE))
  expect_equal(knw_rule_in(vis(), r, ix, src = "wet_balance"), c(TRUE, FALSE, FALSE, FALSE, FALSE))
  # a stricter floor: visit 1 (0.3 m3/s, river 5 km away) is out, visit 2 stays in through the exception,
  # and a visit with a gradient of NA stays out whatever the walk says
  expect_equal(knw_rule_in(vis(), rule("mad", 1, exc_q = 3, exc_d = 500), ix),
               c(FALSE, TRUE, FALSE, FALSE, FALSE))
  # a lake target can be refused
  expect_equal(knw_rule_in(vis(), rule("mad", 1, exc_q = 3, exc_d = 500), ix, no_lake_target = TRUE),
               c(FALSE, TRUE, FALSE, FALSE, FALSE))
  expect_error(knw_rule_in(vis(), rule(exc_q = 10, exc_d = 500), ix), "no walks on pick at 10")
  expect_error(knw_rule_in(vis(), rule(exc_q = 3, exc_d = 500)), "no walks were given")
})

test_that("a visit missing from the walks is an error, not a silent out", {
  w <- data.frame(blue_line_key = 1, downstream_route_measure = 1:4, src = "pick", qmin = 3,
                  status = "found", dist_m = 100)
  expect_error(knw_rule_in(vis(), rule(exc_q = 3, exc_d = 500), knw_walk_index(w)), "1 visits have no walk")
})
