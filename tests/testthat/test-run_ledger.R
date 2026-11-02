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

test_that("a build's ledger is named by its evidence directory, and found by it (#120)", {
  l <- withr::local_tempdir()
  # the default directory keeps the plain name the readers since #57 take; another directory is tagged outside it
  expect_identical(.knw_ledger_path("data/fdis/derived", "20261102", l), file.path(l, "20261102_evidence_build_ledger.csv"))
  expect_identical(.knw_ledger_path("./data/fdis/derived/", "20261102", l), file.path(l, "20261102_evidence_build_ledger.csv"))
  expect_identical(.knw_ledger_path(file.path(getwd(), "data/fdis/derived"), "20261102", l),
                   file.path(l, "20261102_evidence_build_ledger.csv"))
  expect_identical(basename(.knw_ledger_path("data/fdis/derived_zz415_minimal", "20261102", l)),
                   "20261102_evidence_build_ledger-derived_zz415_minimal.csv")
  expect_identical(basename(.knw_ledger_path("data/fdis/derived_zz415_minimal", "20261102", l, refused = TRUE)),
                   "20261102_evidence_build_refused-derived_zz415_minimal.csv")
  expect_error(.knw_ledger_path("data/fdis/derived zz", "20261102", l), "letters, digits")
  # two ledgers one day, tagged and plain, and an older plain one: each directory finds its own
  w <- function(f, dir) utils::write.csv(data.frame(kind = "info", step = "evidence_dir", n = 0, note = dir),
                                         file.path(l, f), row.names = FALSE)
  writeLines("kind,step,n,note", file.path(l, "20261027_evidence_build_ledger.csv"))   # before #120: no evidence_dir row
  w("20261102_evidence_build_ledger.csv", "data/fdis/derived")
  w("20261102_evidence_build_ledger-derived_zz415_minimal.csv", "data/fdis/derived_zz415_minimal")
  expect_identical(basename(.knw_evidence_ledger("data/fdis/derived", l)), "20261102_evidence_build_ledger.csv")
  expect_identical(basename(.knw_evidence_ledger("data/fdis/derived_zz415_minimal", l)),
                   "20261102_evidence_build_ledger-derived_zz415_minimal.csv")
  # the tagged ledger is outside the pattern knw_run_ledger() falls back to
  d <- withr::local_tempdir()
  expect_identical(basename(knw_run_ledger(d, l)), "20261102_evidence_build_ledger.csv")
  expect_error(.knw_evidence_ledger("data/fdis/derived_zz415_default", l), "no evidence build ledger for")
  # another directory of the same base name is refused
  expect_error(.knw_evidence_ledger("elsewhere/derived_zz415_minimal", l), "share a base name")
  unlink(file.path(l, "20261102_evidence_build_ledger.csv"))
  expect_identical(basename(.knw_evidence_ledger("data/fdis/derived", l)), "20261027_evidence_build_ledger.csv")
})
