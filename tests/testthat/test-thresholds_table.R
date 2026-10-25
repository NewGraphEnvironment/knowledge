tune_dir_fx <- function(se_default = 60, edit = identity) {
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
    se_diff = c(se_default, 0, 15, 12), converged = TRUE
  )
  tune <- edit(tune)
  utils::write.csv(tune, file.path(d, "CH_rear_tune.csv"), row.names = FALSE, na = "")
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", watershed_group_code = c("BULK", "MORR"), fold = c(1L, 2L)),
                   file.path(d, "CH_rear_groups.csv"), row.names = FALSE)
  d
}

# the comparison's table for the fixture's key, with the structure 0330 reported as tuned
compare_dir_fx <- function(tuned_structure = "door", key = "CH_rear") {
  d <- withr::local_tempdir(.local_envir = parent.frame())
  cmp <- data.frame(watershed_group_code = c("BULK", "MORR", "ALL"), species_code = "CH", stage = "rear",
                    structure = tuned_structure, tuned_structure = tuned_structure, default_km = c(10, 20, 30),
                    tuned_km = c(8, 18, 26))
  utils::write.csv(cmp, file.path(d, paste0(key, "_compare.csv")), row.names = FALSE)
  d
}

test_that("one row per component of the pick, in link's parameter names, with the region's range", {
  d <- tune_dir_fx()
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234")
  ch <- t$thresholds[t$thresholds$species_code == "CH", ]
  expect_equal(ch$component, c("size", "gradient", "exception_q", "exception_d"))
  expect_equal(ch$link_parameter, c("rear_mad_min", "rear_gradient_max", "rear_river_discharge_min", "rear_river_distance_max"))
  expect_equal(ch$river_measure, c(NA, NA, "discharge", "discharge"))
  expect_true(all(is.na(ch$rule_flow)) && all(is.na(ch$rule_flow_196)))   # the fixture predates the flow start
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

test_that("rule_196 is the pick at 1.96 SE, and holds_196 says which components it keeps", {
  t <- knw_thresholds_table(tune_dir_fx(), "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  ch <- t[t$species_code == "CH", ]
  expect_identical(unique(ch$rule_196), "mad>=0.75|g<=0.07|Q3@D1000")
  expect_identical(ch$holds_196, rep(TRUE, 4))
  # default 150 behind with an SE of 80: inside 1.96 SE (156.8), so the 1.96 pick is default, and nothing holds
  t <- knw_thresholds_table(tune_dir_fx(se_default = 80), "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  ch <- t[t$species_code == "CH", ]
  expect_identical(unique(ch$rule_196), "width>=1.5|g<=0.0549|none")
  expect_identical(ch$holds_196, rep(FALSE, 4))
  ko <- t[t$species_code == "KO", ]
  expect_true(is.na(ko$rule_196) && is.na(ko$holds_196))
})

test_that("holds_196 needs the same size variable, and a missing exception holds when the 1.96 rule has none", {
  # recommended mad>=1.5 with no exception; the 1.96 pick is default, width>=1.5 at the same gradient, no exception
  t <- knw_thresholds_table(tune_dir_fx(se_default = 80, edit = function(x) {
    x$rule[2] <- "mad>=1.5|g<=0.0549|none"
    x$size_min[2] <- 1.5
    x$grad_max[2] <- 0.0549
    x$exc_q[2] <- NA
    x$exc_d[2] <- NA
    x$departures[2] <- 1L
    x
  }), "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  ch <- t[t$species_code == "CH", ]
  expect_identical(unique(ch$rule), "mad>=1.5|g<=0.0549|none")
  expect_identical(unique(ch$rule_196), "width>=1.5|g<=0.0549|none")
  expect_identical(ch$holds_196, c(FALSE, TRUE, TRUE, TRUE))
})

test_that("a tune table whose one-SE replay is not its recommended rule is refused", {
  d <- tune_dir_fx(edit = function(x) {
    x$recommended <- c(FALSE, FALSE, TRUE, FALSE)
    x
  })
  expect_error(knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234"), "does not give the recommended rule")
})

test_that("rule_flow and rule_flow_196 are the picks from the flow start where the table carries one (#80)", {
  # departures from the flow version (mad>=0.28|g<=0.0549|none, not in the fixture): default 1, the exception rules 3,
  # and the mad>=0.5 Q3@D1000 rule made nearer (2) so the flow start picks it at one SE
  t <- knw_thresholds_table(tune_dir_fx(edit = function(x) { x$departures_flow <- c(1L, 3L, 3L, 2L); x }),
                            "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  ch <- t[t$species_code == "CH", ]
  expect_identical(unique(ch$rule), "mad>=0.75|g<=0.07|Q3@D1000")
  expect_identical(unique(ch$rule_flow), "mad>=0.5|g<=0.07|Q3@D1000")
  expect_identical(unique(ch$rule_flow_196), "mad>=0.5|g<=0.07|Q3@D1000")
  ko <- t[t$species_code == "KO", ]
  expect_true(is.na(ko$rule_flow))
})

test_that("a summary whose recommended rule is not its tune table's is refused", {
  d <- tune_dir_fx()
  summ <- utils::read.csv(file.path(d, "CH_rear_summary.csv"), stringsAsFactors = FALSE)
  summ$rule_recommended <- "mad>=0.75|g<=0.07|Q3@D1000"
  utils::write.csv(summ, file.path(d, "CH_rear_summary.csv"), row.names = FALSE, na = "")
  expect_identical(unique(knw_thresholds_table(d, "v", "r", "s")$thresholds$rule[1:4]), "mad>=0.75|g<=0.07|Q3@D1000")
  summ$rule_recommended <- "mad>=0.5|g<=0.09|Q3@D2000"
  utils::write.csv(summ, file.path(d, "CH_rear_summary.csv"), row.names = FALSE, na = "")
  expect_error(knw_thresholds_table(d, "v", "r", "s"), "written by different runs")
})

test_that("evidence_md5 is the summary's, and NA on a summary written before the record", {
  d <- tune_dir_fx()
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  expect_true("evidence_md5" %in% names(t))
  expect_true(all(is.na(t$evidence_md5)))
  summ <- utils::read.csv(file.path(d, "CH_rear_summary.csv"), stringsAsFactors = FALSE)
  summ$evidence_md5 <- "a;b;c"
  utils::write.csv(summ, file.path(d, "CH_rear_summary.csv"), row.names = FALSE, na = "")
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  expect_identical(unique(t$evidence_md5[t$species_code == "CH"]), "a;b;c")
  expect_true(is.na(t$evidence_md5[t$species_code == "KO"]))
})

test_that("near_river_scope is link's scope for the structure the comparison ran the pair under", {
  d <- tune_dir_fx()
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234", compare_dir = compare_dir_fx("door"))$thresholds
  ch <- t[t$species_code == "CH", ]
  expect_identical(unique(ch$near_river_scope), "both")
  expect_true(is.na(t$near_river_scope[t$species_code == "KO"]))
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234", compare_dir = compare_dir_fx("door_wetland"))$thresholds
  expect_identical(unique(t$near_river_scope[t$species_code == "CH"]), "wetland_flow")
  # without a comparison directory the column is there and empty
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234")$thresholds
  expect_true("near_river_scope" %in% names(t))
  expect_true(all(is.na(t$near_river_scope)))
})

test_that("near_river_scope is empty where the rule has no pair, whatever the comparison ran", {
  d <- tune_dir_fx(se_default = 80, edit = function(x) {
    x$rule[2] <- "mad>=1.5|g<=0.0549|none"
    x$size_min[2] <- 1.5
    x$grad_max[2] <- 0.0549
    x$exc_q[2] <- NA
    x$exc_d[2] <- NA
    x$departures[2] <- 1L
    x
  })
  t <- knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234", compare_dir = compare_dir_fx("door"))$thresholds
  expect_true(all(is.na(t$near_river_scope[t$species_code == "CH"])))
})

test_that("a pair compared under a structure link has no scope for, or with no comparison on file, is refused", {
  d <- tune_dir_fx()
  expect_error(knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234", compare_dir = compare_dir_fx("free")),
               "no link near-river scope")
  empty <- withr::local_tempdir()
  expect_error(knw_thresholds_table(d, "knowledge/fdis/v3", "run1", "abc1234", compare_dir = empty),
               "no CH_rear_compare.csv")
})
