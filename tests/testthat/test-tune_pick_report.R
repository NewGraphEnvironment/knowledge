pick_fx <- function() {
  data.frame(rule = c("mad>=0.5|g<=0.07|none", "mad>=0.75|g<=0.09|none", "mad>=0.75|g<=0.15|none"),
             grad_max = c(0.07, 0.09, 0.15), recommended = c(FALSE, TRUE, FALSE), in_region = c(TRUE, TRUE, FALSE),
             ddev_best = c(4, 0, 30), se_diff = c(6, 0, 10), n_visits = 4858, stringsAsFactors = FALSE)
}

test_that("an unchanged pick reads as the same pick, in the region, at the published distance", {
  r <- knw_tune_pick_report(pick_fx(), pick_fx())
  expect_identical(nrow(r), 1L)
  expect_true(r$same_pick)
  expect_identical(r$rule_run, "mad>=0.75|g<=0.09|none")
  expect_equal(r$grad_max_run, 0.09)
  expect_true(r$published_in_grid)
  expect_true(r$published_in_region)
  expect_equal(c(r$published_ddev, r$published_ddev_was), c(0, 0))
})

test_that("a moved pick names both rules, and the published rule's place in the run", {
  run <- pick_fx()
  run$recommended <- c(TRUE, FALSE, FALSE)
  run$ddev_best <- c(0, 12, 30)
  run$se_diff <- c(0, 5, 10)
  run$in_region <- c(TRUE, FALSE, FALSE)
  run$n_visits <- 5000
  r <- knw_tune_pick_report(run, pick_fx())
  expect_false(r$same_pick)
  expect_identical(c(r$rule_run, r$rule_published), c("mad>=0.5|g<=0.07|none", "mad>=0.75|g<=0.09|none"))
  expect_equal(c(r$grad_max_run, r$grad_max_published), c(0.07, 0.09))
  expect_false(r$published_in_region)
  expect_equal(c(r$published_ddev, r$published_se), c(12, 5))
  expect_equal(c(r$n_visits_run, r$n_visits_published), c(5000, 4858))
})

test_that("a published rule the run did not score is out of the grid, its region unknown", {
  pub <- pick_fx()
  pub$rule[2] <- "mad>=0.75|g<=0.3|none"
  r <- knw_tune_pick_report(pick_fx(), pub)
  expect_false(r$published_in_grid)
  expect_true(is.na(r$published_in_region))
  expect_true(is.na(r$published_ddev))
})

test_that("a key with nothing published reports the run's pick alone", {
  r <- knw_tune_pick_report(pick_fx(), NULL)
  expect_identical(r$rule_run, "mad>=0.75|g<=0.09|none")
  expect_true(is.na(r$rule_published))
  expect_true(is.na(r$same_pick))
})

test_that("a table read back as text reads its logicals and numbers (the saved csv)", {
  txt <- as.data.frame(lapply(pick_fx(), as.character), stringsAsFactors = FALSE)
  r <- knw_tune_pick_report(txt, txt)
  expect_true(r$same_pick)
  expect_true(r$published_in_region)
  expect_equal(r$grad_max_published, 0.09)
})

test_that("a table without exactly one recommended rule is refused", {
  t <- pick_fx()
  t$recommended <- FALSE
  expect_error(knw_tune_pick_report(t), "0 recommended")
  expect_error(knw_tune_pick_report(pick_fx(), t), "published has 0 recommended")
})
