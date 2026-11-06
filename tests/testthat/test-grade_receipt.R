# a grade table's provenance receipt (#154): written beside the table and its record, read back, and compared

tables_ev <- c("visits_link", "visits_species", "walks")

# a grade table, its evidence and its record, in one temp directory; `km` and `grade` set the grades
receipt_fx <- function(env = parent.frame(), km = c(0.12, 0.3, 0.08), grade = c(0.1, 0.5, NA)) {
  d <- withr::local_tempdir(.local_envir = env)
  ev <- file.path(d, "evidence")
  dir.create(ev)
  for (f in tables_ev) writeLines(paste("evidence", f), file.path(ev, paste0(f, ".csv")))
  ev_md5 <- paste(unname(tools::md5sum(file.path(ev, paste0(tables_ev, ".csv")))), collapse = ";")
  grades <- data.frame(id_segment = seq_along(km), length_metre = km * 1000, grade = grade)
  g <- file.path(d, "CH_rear_grades.csv")
  utils::write.csv(cbind(grades, species_code = "CH", stage = "rear", rule = "mad>=0.75|g<=0.13|Q3@D1000",
                         run_uid = "20261103_163715-269b585a", ref_population = "stream_branch",
                         ref_edge = "1000;1100", q_walk = "3", walk = "bank", walk_md5 = knw_walk_md5(),
                         discharge_load = "wet load", curve_prior_sd = "2.5", grade_withheld = "FALSE",
                         null_heldout_curve = "1502.6105", evidence_md5 = ev_md5, curve_grad = "segment_gradient"),
                   g, row.names = FALSE, na = "")
  knw_grade_record_write(g, tune_run = "20261105_0000", evidence_ledger = "scripts/logs/habitat/x_ledger.csv",
                         knowledge_commit = "abc1234", link = c(version = "0.78.2", sha = strrep("b", 40)),
                         tokens = c(cut = "cut-full-top", acc = "acc-v5", grad = "grad-seg", flow = "q-fwapg"),
                         rows = nrow(grades))
  list(g = g, ev = ev, grades = grades)
}
spec_fx <- list(fit = "gam", prior_sd = 2.5, seed = 54L, folds = 5L, d_floor = 200, extra = TRUE,
                grad = "segment_gradient")
git_fx <- list(commit = strrep("a", 40), dirty = FALSE)
write_receipt <- function(fx, spec = spec_fx, knowledge = git_fx, grades = fx$grades, ...) {
  knw_grade_receipt_write(fx$g, grades, spec, min_wsg = 5L, evidence_dir = fx$ev, knowledge = knowledge, ...)
}
path_receipt <- function(fx) sub("_grades\\.csv$", "_grades_receipt.json", fx$g)

test_that("the receipt is written beside the table and its record, and validates", {
  skip_if_not_installed("jsonvalidate")
  fx <- receipt_fx()
  r <- write_receipt(fx)
  expect_true(file.exists(path_receipt(fx)))
  expect_identical(list.files(dirname(fx$g), "\\.(csv|json)$"),
                   c("CH_rear_grades.csv", "CH_rear_grades_receipt.json", "CH_rear_grades_record.csv"))
  back <- crate::crt_receipt_read(path_receipt(fx))
  expect_true(crate::crt_receipt_validate(back))
  expect_identical(back$output$name, "grade")
  expect_identical(back$output$scope, "CH_rear")
  # published in a public repository: no host
  expect_null(back$context$host)
  expect_identical(back$recipe$seed, 54L)
  expect_identical(back$recipe$inputs$link_build$version_id, "20261103_163715-269b585a")
  expect_identical(back$recipe$inputs$flow$version_id, "wet load")
  for (f in tables_ev) {
    expect_identical(back$recipe$inputs[[f]]$sha256, .knw_sha256(file.path(fx$ev, paste0(f, ".csv"))), info = f)
  }
  expect_identical(back$recipe$code$knowledge$commit, strrep("a", 40))
  expect_setequal(names(back$recipe$config$files), c("inst/method/settings.csv", "inst/sql/ch_dist_profile.sql"))
  expect_identical(back$result$summary$rows, 3L)
  expect_identical(back$result$summary$graded_rows, 2L)
  expect_equal(back$result$summary$km_graded, 0.42)
  expect_equal(back$result$summary$grade_sum, 0.6)
  expect_identical(names(back$result$parts), "CH_rear_grades.csv")
  expect_identical(back$result$parts[["CH_rear_grades.csv"]]$sha256, .knw_sha256(fx$g))
  expect_identical(back$context$run$tune_run, "20261105_0000")
  expect_identical(back$context$run$grades_md5, unname(tools::md5sum(fx$g)))
})

test_that("a rebuild's receipt is identical, equivalent within the declared roundings, or different past them", {
  keys <- knw_receipt_keys("grade")
  fx <- receipt_fx()
  a <- write_receipt(fx)
  b <- write_receipt(fx)
  expect_identical(crate::crt_receipt_compare(a, b, keys = keys)$verdict, "identical")

  # the database summed in another order: the km moves under its rounding (1e-3 km), the table's bytes move with it
  fx2 <- receipt_fx(km = c(0.12 + 4e-4, 0.3, 0.08))
  e <- write_receipt(fx2)
  cmp <- crate::crt_receipt_compare(a, e, keys = keys)
  expect_identical(cmp$verdict, "equivalent")
  expect_true(all(cmp$differences$action %in% c("within", "warn", "record")))
  expect_true(any(cmp$differences$action == "warn"))

  # past the rounding, or a grade that changed, is different
  fx3 <- receipt_fx(km = c(0.12 + 2e-3, 0.3, 0.08))
  expect_identical(crate::crt_receipt_compare(a, write_receipt(fx3), keys = keys)$verdict, "different")
  fx4 <- receipt_fx(grade = c(0.1, 0.6, NA))
  expect_identical(crate::crt_receipt_compare(a, write_receipt(fx4), keys = keys)$verdict, "different")

  # another seed, another commit or a dirty tree is another recipe
  expect_identical(crate::crt_receipt_compare(a, write_receipt(fx, spec = utils::modifyList(spec_fx, list(seed = 55L))),
                                              keys = keys)$verdict, "different")
  expect_identical(crate::crt_receipt_compare(a, write_receipt(fx, knowledge = list(commit = strrep("c", 40),
                                                                                   dirty = FALSE)),
                                              keys = keys)$verdict, "different")
})

test_that("it refuses a table, evidence or walk that is not the record's", {
  fx <- receipt_fx()
  # the evidence moved after the run
  writeLines("rebuilt", file.path(fx$ev, "walks.csv"))
  expect_error(write_receipt(fx), "not the build the run read")

  fx <- receipt_fx()
  # the table rewritten after its record
  cat("extra\n", file = fx$g, append = TRUE)
  expect_error(write_receipt(fx), "not the table its record describes")

  fx <- receipt_fx()
  expect_error(write_receipt(fx, grades = fx$grades[1:2, ]), "rows, the record's table")
  expect_error(write_receipt(fx, spec = utils::modifyList(spec_fx, list(grad = "parent_gradient"))),
               "not the curve's")
  expect_error(write_receipt(fx, grades = fx$grades[, c("id_segment", "grade")]), "length_metre and grade")
  expect_error(write_receipt(fx, spec = spec_fx[c("fit", "seed")]), "spec names")
  expect_false(file.exists(path_receipt(fx)))
})

test_that("it refuses a record walked by another walk than this package's", {
  fx <- receipt_fx()
  rp <- sub("_grades\\.csv$", "_grades_record.csv", fx$g)
  r <- utils::read.csv(rp, colClasses = "character", na.strings = "")
  r$walk_md5 <- "0123"
  utils::write.csv(r, rp, row.names = FALSE, na = "")
  expect_error(write_receipt(fx), "another walk")
})

test_that("an Inf curve prior is written as a setting JSON can hold", {
  fx <- receipt_fx()
  r <- write_receipt(fx, spec = utils::modifyList(spec_fx, list(prior_sd = Inf)))
  expect_identical(crate::crt_receipt_read(path_receipt(fx))$recipe$config$settings$prior_sd, "Inf")
})
