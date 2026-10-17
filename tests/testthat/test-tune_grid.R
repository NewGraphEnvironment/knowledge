thr <- function(sp = "CH", g = 0.0549, w = 1.5, m = 0.28) {
  data.frame(species_code = sp, rear_gradient_max = g, rear_channel_width_min = w, rear_mad_min = m,
             spawn_gradient_max = 0.0449, spawn_channel_width_min = 4, spawn_mad_min = 0.46)
}

test_that("CH rearing gives 0297's 2,795 rules with one default of zero departures", {
  g <- knw_tune_grid(thr(), "rear")
  expect_equal(nrow(g), 2795)
  expect_equal(sum(g$is_default), 1)
  d <- g[g$is_default, ]
  expect_equal(d$rule, "width>=1.5|g<=0.0549|none")
  expect_equal(d$departures, 0L)
  expect_equal(g$departures[g$rule == "mad>=0.75|g<=0.07|Q3@D1000"], 3L)
  expect_equal(g$departures[g$rule == "mad>=0.28|g<=0.0549|none"], 1L)
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
  expect_named(g, c("rule", "size_var", "size_min", "grad_max", "exc_q", "exc_d", "departures", "is_default"))
})

test_that("spawning reads the spawn columns", {
  g <- knw_tune_grid(thr(), "spawn")
  expect_equal(g$rule[g$is_default], "width>=4|g<=0.0449|none")
})

test_that("two rows or a missing column are refused", {
  expect_error(knw_tune_grid(rbind(thr(), thr()), "rear"), "one species")
  expect_error(knw_tune_grid(thr()[, -2], "rear"), "rear_gradient_max")
})
