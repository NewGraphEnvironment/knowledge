# a grade table's record (#119): written beside the table, read back, and checked against it

rec_fx <- function(env = parent.frame()) {
  d <- withr::local_tempdir(.local_envir = env)
  g <- file.path(d, "CH_rear_grades.csv")
  utils::write.csv(data.frame(id_segment = 1:3, grade = c(0.1, NA, 0.3), species_code = "CH", stage = "rear",
                              rule = "mad>=0.5|g<=0.07|none", run_uid = "u1", ref_population = "stream_branch",
                              ref_edge = "1000;1100", q_walk = "0.75", walk = "bank", walk_md5 = "w0",
                              discharge_load = "wet load", curve_prior_sd = "2.5", grade_withheld = "FALSE",
                              null_heldout_curve = "100.1000", evidence_md5 = "a;b;c", curve_grad = "segment_gradient"),
                   g, row.names = FALSE, na = "")
  g
}
write_fx <- function(g, ...) {
  knw_grade_record_write(g, tune_run = "20261027_0000", evidence_ledger = "scripts/logs/habitat/x_ledger.csv",
                         knowledge_commit = "abc1234", link = c(version = "0.66.0", sha = "def"),
                         tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), rows = 3, ...)
}

test_that("the record is the table's run columns as written, with its md5 and size beside them", {
  g <- rec_fx()
  write_fx(g)
  r <- knw_grade_record_read(sub("_grades\\.csv$", "_grades_record.csv", g))
  head1 <- utils::read.csv(g, nrows = 1, colClasses = "character", na.strings = "")
  # every constant column exactly as the table holds it, so a reader of the record sees what a reader of the table saw
  for (f in .knw_cols_grade_record) expect_identical(r[[f]], head1[[f]], info = f)
  expect_identical(r$null_heldout_curve, "100.1000")
  expect_identical(r$grades_md5, unname(tools::md5sum(g)))
  expect_identical(r$grades_bytes, as.character(file.size(g)))
  expect_identical(r$grades_rows, "3")
  expect_identical(r$record_source, "0320")
  expect_true(is.na(r$token_cut))
  expect_true(.knw_grade_grad_ok(r))
  expect_true(knw_grade_record_check(r, g))
})

test_that("a table that is not the record's is refused, by size and by md5", {
  g <- rec_fx()
  write_fx(g)
  r <- knw_grade_record_read(sub("_grades\\.csv$", "_grades_record.csv", g))
  cat("4,0.4,CH,rear\n", file = g, append = TRUE)
  expect_error(knw_grade_record_check(r, g), "bytes, its record's table .*not the table the record describes")
  g <- rec_fx()
  write_fx(g)
  r <- knw_grade_record_read(sub("_grades\\.csv$", "_grades_record.csv", g))
  # same size, another table
  x <- readLines(g)
  x[2] <- sub("^1,", "7,", x[2])
  writeLines(x, g)
  expect_error(knw_grade_record_check(r, g), "has md5 .*not the table the record describes")
})

test_that("a table from before the record's columns, a malformed record and a wrong path are refused", {
  d <- withr::local_tempdir()
  g <- file.path(d, "CH_rear_grades.csv")
  utils::write.csv(data.frame(id_segment = 1, rule = "r", run_uid = "u1"), g, row.names = FALSE)
  expect_error(write_fx(g), "predates the record's columns \\(species_code, stage, ref_population")
  g <- rec_fx()
  write_fx(g, record_source = "backfill")
  p <- sub("_grades\\.csv$", "_grades_record.csv", g)
  expect_identical(knw_grade_record_read(p)$record_source, "backfill")
  x <- utils::read.csv(p, colClasses = "character")
  utils::write.csv(rbind(x, x), p, row.names = FALSE)
  expect_error(knw_grade_record_read(p), "holds 2 rows, not one")
  utils::write.csv(x[setdiff(names(x), "grades_md5")], p, row.names = FALSE)
  expect_error(knw_grade_record_read(p), "lacks grades_md5")
  expect_error(.knw_grade_record_path("data/tune/CH_rear_summary.csv"), "not a grade table")
})
