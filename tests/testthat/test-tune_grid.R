thr <- function(sp = "CH", g = 0.0549, w = 1.5, m = 0.28) {
  data.frame(species_code = sp, rear_gradient_max = g, rear_channel_width_min = w, rear_mad_min = m,
             spawn_gradient_max = 0.0449, spawn_channel_width_min = 4, spawn_mad_min = 0.46)
}

test_that("CH rearing gives 6,149 rules on the 30 % ladder (#68) with one default of zero departures", {
  g <- knw_tune_grid(thr(), "rear")
  expect_equal(nrow(g), 6149)   # 559 per gradient maximum, 11 maxima (0297's five and #67's six)
  expect_equal(sum(g$is_default), 1)
  d <- g[g$is_default, ]
  expect_equal(d$rule, "width>=1.5|g<=0.0549|none")
  expect_equal(d$departures, 0L)
  expect_equal(g$departures[g$rule == "mad>=0.75|g<=0.07|Q3@D1000"], 3L)
  expect_equal(g$departures[g$rule == "mad>=0.28|g<=0.0549|none"], 1L)
  expect_equal(max(g$grad_max), 0.30)
  expect_false(any(g$is_link_tuned))
})

test_that("0297's ladder is still the grid when asked for (2,795 rules)", {
  g <- knw_tune_grid(thr(), "rear", grid_grad = c(0.03, 0.04, 0.0549, 0.07, 0.09))
  expect_equal(nrow(g), 2795)
})

test_that("departures_flow counts from link's flow version of default (#80)", {
  g <- knw_tune_grid(thr(), "rear")
  expect_equal(g$departures_flow[g$rule == "mad>=0.28|g<=0.0549|none"], 0L)
  expect_equal(g$departures_flow[g$rule == "width>=1.5|g<=0.0549|none"], 1L)
  expect_equal(g$departures_flow[g$rule == "mad>=0.75|g<=0.07|Q3@D1000"], 3L)
  expect_equal(g$departures_flow[g$rule == "mad>=0.28|g<=0.09|none"], 1L)
  # a species whose default has no MAD floor has no flow start
  g2 <- knw_tune_grid(thr("GR", g = 0.0349, w = 1.5, m = NA), "rear")
  expect_true(all(is.na(g2$departures_flow)))
  expect_equal(sum(g2$is_default), 1)
})

test_that("extra adds another bundle's rule to the grid, flagged is_link_tuned", {
  x <- thr("BT", g = 0.1349, w = 1.5, m = 0.043)
  g <- knw_tune_grid(thr("BT", g = 0.1049, w = 1.5, m = 0.021), "rear", extra = x)
  expect_equal(sum(g$is_link_tuned), 1)
  expect_equal(g$rule[g$is_link_tuned], "mad>=0.043|g<=0.1349|none")
  expect_true(0.1349 %in% g$grad_max && 0.043 %in% g$size_min)
  expect_equal(g$departures[g$is_link_tuned], 2L)
  # a row with no MAD floor for the stage adds nothing
  g0 <- knw_tune_grid(thr("BT", g = 0.1049, w = 1.5, m = 0.021), "rear", extra = thr("BT", g = 0.1349, w = 1.5, m = NA))
  expect_false(any(g0$is_link_tuned))
  expect_equal(nrow(g0), nrow(knw_tune_grid(thr("BT", g = 0.1049, w = 1.5, m = 0.021), "rear")))
  expect_error(knw_tune_grid(thr("BT", g = 0.1049, w = 1.5, m = 0.021), "rear", extra = x[0, ]), "one species")
  expect_error(knw_tune_grid(thr("BT", g = 0.1049, w = 1.5, m = 0.021), "rear", extra = thr("CH")), "another species")
})

test_that("a species' own default values join the ladder when absent from it", {
  g <- knw_tune_grid(thr("BT", g = 0.1049, w = 1.5, m = 0.021), "rear")
  expect_true(0.1049 %in% g$grad_max)
  expect_true(0.021 %in% g$size_min[g$size_var == "mad"])
  expect_equal(sum(g$is_default), 1)
  expect_equal(g$rule[g$is_default], "width>=1.5|g<=0.1049|none")
})

test_that("a stage with no stream rule gives an empty grid", {
  g <- knw_tune_grid(thr("KO", g = NA, w = 1.5, m = NA), "rear")
  expect_equal(nrow(g), 0)
  expect_named(g, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d", "departures", "departures_flow",
                    "is_default", "is_link_tuned"))
})

test_that("spawning reads the spawn columns", {
  g <- knw_tune_grid(thr(), "spawn")
  expect_equal(g$rule[g$is_default], "width>=4|g<=0.0449|none")
})

test_that("two rows or a missing column are refused", {
  expect_error(knw_tune_grid(rbind(thr(), thr()), "rear"), "one species")
  expect_error(knw_tune_grid(thr()[, -2], "rear"), "rear_gradient_max")
})
