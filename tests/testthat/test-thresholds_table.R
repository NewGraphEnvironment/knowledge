tune_dir_fx <- function() {
  d <- withr::local_tempdir(.local_envir = parent.frame())
  summ <- data.frame(
    species_code = c("CH", "KO"), stage = "rear", response = "U", status = c("fitted", "no_stream_rule"),
    visits_in = c(3000, 0), detections = c(150, NA), groups = c(30, NA), groups_both = c(20, NA),
    seeds_n = c(4, NA), seeds_rec_in_region = c(3, NA)
  )
  utils::write.csv(summ[1, ], file.path(d, "CH_rear_summary.csv"), row.names = FALSE, na = "")
  utils::write.csv(summ[2, ], file.path(d, "KO_rear_summary.csv"), row.names = FALSE, na = "")
  tune <- data.frame(
    rule = c("width>=1.5|g<=0.0549|none", "mad>=0.75|g<=0.07|Q3@D1000", "mad>=0.5|g<=0.09|Q3@D2000", "mad>=0.5|g<=0.07|Q3@D1000"),
    size_var = c("width", "mad", "mad", "mad"), size_min = c(1.5, 0.75, 0.5, 0.5), grad_max = c(0.0549, 0.07, 0.09, 0.07),
    exc_q = c(NA, 3, 3, 3), exc_d = c(NA, 1000, 2000, 1000), departures = c(0L, 3L, 3L, 3L),
    is_default = c(TRUE, FALSE, FALSE, FALSE), in_region = c(FALSE, TRUE, TRUE, TRUE),
    recommended = c(FALSE, TRUE, FALSE, FALSE), pick = c(FALSE, TRUE, FALSE, FALSE),
    n_visits = 3000, n_detect = 150, n_wsg = 20, dev_heldout = c(1100, 950, 960, 955), ddev_best = c(150, 0, 10, 5),
    se_diff = c(60, 0, 15, 12)
  )
  utils::write.csv(tune, file.path(d, "CH_rear_tune.csv"), row.names = FALSE, na = "")
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", watershed_group_code = c("BULK", "MORR"), fold = c(1L, 2L)),
                   file.path(d, "CH_rear_groups.csv"), row.names = FALSE)
  d
}

test_that("one row per component of the pick, in link's parameter names, with the region's range", {
  d <- tune_dir_fx()
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234")
  ch <- t$thresholds[t$thresholds$species_code == "CH", ]
  expect_equal(ch$component, c("size", "gradient", "exception_q", "exception_d"))
  expect_equal(ch$link_parameter, c("rear_mad_min", "rear_gradient_max", NA, NA))
  expect_equal(ch$model, rep("mad", 4))
  expect_equal(ch$value, c(0.75, 0.07, 3, 1000))
  expect_equal(ch$unit, c("m3/s", "fraction", "m3/s", "m"))
  expect_equal(ch$range_lo, c(0.5, 0.07, 3, 1000))
  expect_equal(ch$range_hi, c(0.75, 0.09, 3, 2000))
  expect_equal(unique(ch$readings_in), 4L)
  expect_equal(unique(ch$readings), 5L)
  expect_equal(ch$default_value, c(NA, 0.0549, NA, NA))   # default sizes by width, the pick by MAD
  expect_false(any(ch$default_in_region))
  expect_equal(unique(ch$rule_id), "CH_rear_v1")
  expect_equal(unique(ch$evidence_version), "knowledge/fdis/v3")
  expect_equal(unique(ch$link_run_uid), "run1")
  expect_equal(nrow(t$groups), 2)
  expect_equal(unique(t$groups$rule_id), "CH_rear_v1")
})

test_that("a species x stage that was not fitted gets one row that says why", {
  d <- tune_dir_fx()
  t <- knw_thresholds_table(d, "v", "r", "s")
  ko <- t$thresholds[t$thresholds$species_code == "KO", ]
  expect_equal(nrow(ko), 1)
  expect_equal(ko$status, "no_stream_rule")
  expect_true(is.na(ko$value))
  expect_equal(ko$power, "no_stream_rule")
})
