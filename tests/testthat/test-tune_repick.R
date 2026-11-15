repick_fx <- function() {
  data.frame(
    rule = c("width>=1.5|g<=0.0549|none", "mad>=0.75|g<=0.09|Q3@D1000", "mad>=0.75|g<=0.0549|none",
             "mad>=0.5|g<=0.09|Q3@D100", "mad>=0.5|g<=0.0549|none"),
    departures = c(0L, 3L, 1L, 3L, 1L), exc_d = c(NA, 1000, NA, 100, NA), converged = c(TRUE, TRUE, TRUE, TRUE, FALSE),
    dev_heldout = c(1150, 1000, 1040, 1005, 1010), ddev_best = c(150, 0, 40, 5, 10), se_diff = c(60, 0, 25, 30, 50)
  )
}

test_that("the region widens with se_mult and the pick moves to the fewest departures inside it", {
  t <- repick_fx()
  a <- knw_tune_repick(t)
  expect_identical(a$rule, "mad>=0.75|g<=0.09|Q3@D1000")
  expect_identical(a$n_region, 2L)
  b <- knw_tune_repick(t, se_mult = 1.96)
  expect_identical(b$rule, "mad>=0.75|g<=0.0549|none")
  expect_identical(b$n_region, 3L)
  expect_identical(knw_tune_repick(t, se_mult = 3)$rule, "width>=1.5|g<=0.0549|none")
})

test_that("a rule that did not converge never joins the region", {
  t <- repick_fx()
  # the unconverged row is 10 behind with an SE of 50, so in at 1 SE if convergence were ignored, and a one-departure
  # rule that would then be picked
  expect_false(knw_tune_repick(t)$rule == "mad>=0.5|g<=0.0549|none")
  expect_identical(knw_tune_repick(t, se_mult = 1)$n_region, 2L)
})

test_that("ties in departures go to the lower score, and an exception under d_floor is moved off", {
  t <- repick_fx()
  t$converged <- TRUE
  t$departures <- c(0L, 3L, 3L, 3L, 3L)
  t$ddev_best[1] <- 1e6
  # the 100 m exception scores 1005, second to the 1,000 m one; make it the best to put the floor to work
  t$dev_heldout[4] <- 990
  expect_identical(knw_tune_repick(t, se_mult = 10)$rule, "mad>=0.75|g<=0.09|Q3@D1000")
  expect_identical(knw_tune_repick(t, se_mult = 10, d_floor = 50)$rule, "mad>=0.5|g<=0.09|Q3@D100")
})

test_that("start = 'flow' counts departures from the flow version, and is refused without the column (#80)", {
  t <- repick_fx()
  expect_error(knw_tune_repick(t, start = "flow"), "departures_flow")
  t$departures_flow <- c(1L, 2L, 1L, 2L, 0L)
  # at 1 SE the region is the two exception rules; from the flow start the 1000 m one is still nearest (2 vs 2, lower score)
  expect_identical(knw_tune_repick(t, start = "flow")$rule, "mad>=0.75|g<=0.09|Q3@D1000")
  # at 1.96 SE the no-exception MAD rule joins and is one departure from the flow start (its gradient), as from the width start
  expect_identical(knw_tune_repick(t, se_mult = 1.96, start = "flow")$rule, "mad>=0.75|g<=0.0549|none")
  t$departures_flow <- NA_integer_
  expect_error(knw_tune_repick(t, start = "flow"), "no flow start")
})

test_that("an empty region is an error, not a silent NA row", {
  t <- repick_fx()
  t$converged <- FALSE
  expect_error(knw_tune_repick(t), "no converged rule")
})

root <- testthat::test_path("..", "..")
tune_files <- Sys.glob(file.path(root, "data", "tune", "*_tune.csv"))

test_that("at 1 SE the replay is every saved table's recommended rule", {
  skip_if_not(length(tune_files) > 0, "no source-tree data/tune (installed package)")
  expect_length(tune_files, 7)
  for (f in tune_files) {
    t <- utils::read.csv(f, stringsAsFactors = FALSE)
    expect_identical(t$in_region, t$converged & t$ddev_best <= t$se_diff, info = basename(f))
    expect_identical(knw_tune_repick(t)$rule, t$rule[t$recommended %in% TRUE], info = basename(f))
  }
})

test_that("at 1.96 SE the replay gives the table research/habitat_thresholds_tuned.md prints (#79, on the minimal network run 20261103_0838, #120)", {
  skip_if_not(length(tune_files) > 0, "no source-tree data/tune (installed package)")
  want <- c(BT_rear = "mad>=0.1|g<=0.1049|none", BT_spawn = "width>=2|g<=0.0549|none",
            CH_rear = "mad>=1|g<=0.0549|Q3@D1000", CO_rear = "width>=1.5|g<=0.0549|Q1@D500",
            GR_rear = "width>=1.5|g<=0.0349|none", ST_rear = "width>=1.5|g<=0.0849|none",
            WCT_rear = "width>=1.5|g<=0.0849|none")
  got <- vapply(tune_files, function(f) knw_tune_repick(utils::read.csv(f, stringsAsFactors = FALSE), 1.96)$rule, "")
  names(got) <- sub("_tune\\.csv$", "", basename(tune_files))
  expect_identical(got[names(want)], want)
})
