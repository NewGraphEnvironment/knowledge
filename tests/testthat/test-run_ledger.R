ledger_fx <- function(named = NULL, env = parent.frame()) {
  d <- withr::local_tempdir(.local_envir = env)
  l <- file.path(d, "logs"); dir.create(l)
  for (f in c("20261020_evidence_build_ledger.csv", "20261027_evidence_build_ledger.csv")) writeLines("kind,step,n,note", file.path(l, f))
  for (i in seq_along(c("CH_rear", "BT_rear"))) {
    k <- c("CH_rear", "BT_rear")[i]
    x <- data.frame(species_code = sub("_.*", "", k), stage = "rear")
    if (!is.null(named)) x$evidence_ledger <- named[i]
    utils::write.csv(x, file.path(d, paste0(k, "_summary.csv")), row.names = FALSE, na = "")
  }
  list(d = d, l = l)
}

test_that("the ledger the summaries name is taken over a newer one (#111)", {
  fx <- ledger_fx()
  old <- file.path(fx$l, "20261020_evidence_build_ledger.csv")
  fx2 <- ledger_fx(named = c(old, NA))
  expect_identical(knw_run_ledger(fx2$d, fx2$l), old)
})

test_that("tables from before the record take the newest ledger, as every reader did", {
  fx <- ledger_fx()
  expect_identical(basename(knw_run_ledger(fx$d, fx$l)), "20261027_evidence_build_ledger.csv")
})

test_that("two ledgers, a missing one, or none at all are refused", {
  fx <- ledger_fx()
  f <- file.path(fx$l, c("20261020_evidence_build_ledger.csv", "20261027_evidence_build_ledger.csv"))
  fx2 <- ledger_fx(named = f)
  expect_error(knw_run_ledger(fx2$d, fx2$l), "2 evidence builds")
  fx3 <- ledger_fx(named = c(file.path(fx$l, "nope.csv"), NA))
  expect_error(knw_run_ledger(fx3$d, fx3$l), "not on disk")
  unlink(list.files(fx$l, full.names = TRUE))
  expect_error(knw_run_ledger(fx$d, fx$l), "no evidence build ledger")
})
