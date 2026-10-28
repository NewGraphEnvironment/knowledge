# a tracked tune/compare pair holding two keys (CH_rear, BT_rear) on build "e1", and a candidate run r1 of both on
# build `ev`, with CH's pick moved
promote_fx <- function(ev = "e1", ch_rule = "mad>=0.5|g<=0.07|none", env = parent.frame()) {
  d <- withr::local_tempdir(.local_envir = env)
  tn <- file.path(d, "tune"); cm <- file.path(d, "compare")
  ct <- file.path(tn, "candidate", "r1"); cc <- file.path(cm, "candidate", "r1")
  for (x in c(tn, cm, ct, cc, file.path(d, "logs"), file.path(d, "fig"), file.path(cc, "fig"))) dir.create(x, recursive = TRUE)
  key_files <- function(dir_t, dir_c, k, rule, ev, tag) {
    sp <- sub("_.*", "", k); st <- sub(".*_", "", k)
    utils::write.csv(data.frame(species_code = sp, stage = st, status = "fitted", rule_recommended = rule,
                                curve_grad = "segment_gradient", evidence_md5 = ev, run_uid = "u1"),
                     file.path(dir_t, paste0(k, "_summary.csv")), row.names = FALSE)
    utils::write.csv(data.frame(rule = rule, tag = tag), file.path(dir_t, paste0(k, "_tune.csv")), row.names = FALSE)
    utils::write.csv(data.frame(segment = 1:2, rule = rule, evidence_md5 = ev), file.path(dir_t, paste0(k, "_grades.csv")),
                     row.names = FALSE)
    saveRDS(list(tag = tag), file.path(dir_t, paste0(k, "_curve.rds")))
    utils::write.csv(data.frame(watershed_group_code = c("BULK", "ALL"), species_code = sp, stage = st, tuned_rule = rule,
                                km = c(1, 2), tag = tag), file.path(dir_c, paste0(k, "_compare.csv")), row.names = FALSE)
  }
  key_files(tn, cm, "CH_rear", "mad>=0.75|g<=0.09|none", "e1", "old")
  key_files(tn, cm, "BT_rear", "width>=1|g<=0.2|none", "e1", "old")
  key_files(ct, cc, "CH_rear", ch_rule, ev, "new")
  key_files(ct, cc, "BT_rear", "width>=1|g<=0.2|none", ev, "new")
  # a stale tracked file the run does not write, and a file of another key whose name starts like one
  writeLines("x", file.path(tn, "CH_rear_honest.csv"))
  writeLines("x", file.path(tn, "CH_rearing_other.csv"))
  combined <- function(dir_c, tag, order = c("BT_rear", "CH_rear")) {
    x <- do.call(rbind, lapply(order, function(k) utils::read.csv(file.path(dir_c, paste0(k, "_compare.csv")))))
    x$tag <- tag
    utils::write.csv(x, file.path(dir_c, "compare.csv"), row.names = FALSE)
  }
  combined(cm, "old", c("CH_rear", "BT_rear"))
  combined(cc, "new")
  writeLines("tune log", file.path(ct, "20261028_tune_run-r1.txt"))
  writeLines("compare log", file.path(cc, "20261028_compare-r1.txt"))
  writeLines("png", file.path(cc, "fig", "compare_ch_rear_bulk.png"))
  writeLines("png", file.path(cc, "fig", "compare_bt_rear_bulk.png"))
  list(d = d, tune = tn, compare = cm, logs = file.path(d, "logs"), fig = file.path(d, "fig"))
}
promote <- function(fx, ...) {
  knw_tune_promote("r1", ..., tune_dir = fx$tune, compare_dir = fx$compare, log_dir = fx$logs, fig_dir = fx$fig)
}
tree_md5 <- function(fx) {
  f <- list.files(fx$d, recursive = TRUE, full.names = TRUE)
  f <- f[!grepl("/candidate/", f)]
  stats::setNames(unname(tools::md5sum(f)), f)
}

test_that("a whole run replaces every key's files, keeps no stale one, and brings its logs and figures", {
  fx <- promote_fx()
  p <- promote(fx)
  expect_identical(p$keys, c("BT_rear", "CH_rear"))
  expect_identical(utils::read.csv(file.path(fx$tune, "CH_rear_tune.csv"))$tag, "new")
  expect_identical(readRDS(file.path(fx$tune, "CH_rear_curve.rds"))$tag, "new")
  expect_identical(unique(utils::read.csv(file.path(fx$compare, "CH_rear_compare.csv"))$tag), "new")
  expect_false(file.exists(file.path(fx$tune, "CH_rear_honest.csv")))
  expect_true(file.exists(file.path(fx$tune, "CH_rearing_other.csv")))
  expect_identical(p$removed, file.path(fx$tune, "CH_rear_honest.csv"))
  expect_true(all(file.exists(file.path(fx$logs, c("20261028_tune_run-r1.txt", "20261028_compare-r1.txt")))))
  expect_true(all(file.exists(file.path(fx$fig, c("compare_ch_rear_bulk.png", "compare_bt_rear_bulk.png")))))
  # the combined table is the run's rows, each key where its rows stood in the tracked one
  cmp <- utils::read.csv(file.path(fx$compare, "compare.csv"))
  expect_identical(unique(cmp$tag), "new")
  expect_identical(unique(paste(cmp$species_code, cmp$stage)), c("CH rear", "BT rear"))
  expect_true(all(file.exists(p$written)))
  # a promoted key's files leave the run (moved, not copied); its logs stay with it
  expect_length(list.files(file.path(fx$tune, "candidate", "r1"), "^CH_rear_"), 0)
  expect_true(file.exists(file.path(fx$tune, "candidate", "r1", "20261028_tune_run-r1.txt")))
})

test_that("one key moves alone: the other key's files and rows are untouched, byte for byte", {
  fx <- promote_fx()
  before <- tree_md5(fx)
  old_lines <- readLines(file.path(fx$compare, "compare.csv"))
  p <- promote(fx, keys = "CH_rear")
  after <- tree_md5(fx)
  bt <- grep("BT_rear", names(before), value = TRUE)
  expect_identical(after[bt], before[bt])
  expect_identical(utils::read.csv(file.path(fx$tune, "CH_rear_tune.csv"))$tag, "new")
  new_lines <- readLines(file.path(fx$compare, "compare.csv"))
  expect_identical(new_lines[c(1, 4, 5)], old_lines[c(1, 4, 5)])   # the header and BT's rows, in place
  expect_match(new_lines[2:3], "new")
  expect_false(file.exists(file.path(fx$fig, "compare_bt_rear_bulk.png")))
})

test_that("a by-key promotion that would leave a kept key on another build is refused, and writes nothing", {
  fx <- promote_fx(ev = "e2")
  before <- tree_md5(fx)
  expect_error(promote(fx, keys = "CH_rear"), "would leave BT_rear on another evidence_md5")
  expect_identical(tree_md5(fx), before)
  # the whole run moves both keys onto e2 together
  promote(fx)
  expect_identical(utils::read.csv(file.path(fx$tune, "BT_rear_summary.csv"))$evidence_md5, "e2")
})

test_that("a key with no comparison, or grades or a comparison of another rule, is refused", {
  fx <- promote_fx()
  unlink(file.path(fx$compare, "candidate", "r1", "CH_rear_compare.csv"))
  expect_error(promote(fx), "CH_rear: no comparison")
  fx <- promote_fx()
  utils::write.csv(data.frame(segment = 1, rule = "other", evidence_md5 = "e1"),
                   file.path(fx$tune, "candidate", "r1", "CH_rear_grades.csv"), row.names = FALSE)
  expect_error(promote(fx), "CH_rear: graded under other")
  fx <- promote_fx()
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", tuned_rule = "other"),
                   file.path(fx$compare, "candidate", "r1", "CH_rear_compare.csv"), row.names = FALSE)
  expect_error(promote(fx), "CH_rear: the comparison is of other")
  fx <- promote_fx()
  unlink(file.path(fx$tune, "candidate", "r1", "CH_rear_grades.csv"))
  expect_error(promote(fx), "wrote no grades")
})

test_that("a key not in the run, and a different log under the run's log name, are refused", {
  fx <- promote_fx()
  expect_error(promote(fx, keys = "CO_rear"), "not in run r1: CO_rear")
  writeLines("another", file.path(fx$logs, "20261028_tune_run-r1.txt"))
  before <- tree_md5(fx)
  expect_error(promote(fx), "a different log is already tracked")
  expect_identical(tree_md5(fx), before)
})

test_that("a combined table whose columns changed moves only with every key it holds", {
  fx <- promote_fx()
  f <- file.path(fx$compare, "candidate", "r1", "compare.csv")
  x <- utils::read.csv(f); x$extra <- 1
  utils::write.csv(x, f, row.names = FALSE)
  expect_error(promote(fx, keys = "CH_rear"), "columns differ")
  promote(fx)
  expect_true("extra" %in% names(utils::read.csv(file.path(fx$compare, "compare.csv"))))
})

test_that("dry_run lists the plan and writes nothing", {
  fx <- promote_fx()
  before <- tree_md5(fx)
  p <- promote(fx, dry_run = TRUE)
  expect_identical(tree_md5(fx), before)
  expect_true(file.path(fx$tune, "CH_rear_tune.csv") %in% p$written)
  expect_identical(p$removed, file.path(fx$tune, "CH_rear_honest.csv"))
})

test_that("promoting a copy of the tracked run changes nothing", {
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1"); cc <- file.path(fx$compare, "candidate", "r1")
  unlink(c(ct, cc), recursive = TRUE)
  dir.create(ct); dir.create(cc)
  file.copy(list.files(fx$tune, full.names = TRUE, pattern = "^(CH|BT)_rear_"), ct)
  file.copy(list.files(fx$compare, full.names = TRUE, pattern = "\\.csv$"), cc)
  before <- tree_md5(fx)
  p <- promote(fx)
  expect_identical(tree_md5(fx), before)
  expect_length(p$removed, 0)
})

# set one column of one candidate or tracked table of a key
set_col <- function(fx, where, k, what, col, value) {
  d <- switch(where, run_tune = file.path(fx$tune, "candidate", "r1"), run_cmp = file.path(fx$compare, "candidate", "r1"),
              tune = fx$tune, compare = fx$compare)
  f <- file.path(d, paste0(k, "_", what, ".csv"))
  x <- utils::read.csv(f, colClasses = "character")
  x[[col]] <- value
  t0 <- file.mtime(f)
  utils::write.csv(x, f, row.names = FALSE, na = "")
  Sys.setFileTime(f, t0)   # keep the grade/comparison order the fixture set
}

test_that("every field 0325 and the bundles hold the set to refuses a by-key mix (#111 review)", {
  cases <- list(c("summary", "run_uid"), c("summary", "curve_grad"), c("summary", "evidence_ledger"),
                c("grades", "ref_edge"), c("grades", "discharge_load"), c("grades", "walk_md5"),
                c("compare", "config_sha"), c("compare", "tuned_structure"))
  for (cs in cases) {
    fx <- promote_fx()
    where_run <- if (cs[1] == "compare") "run_cmp" else "run_tune"
    where_kept <- if (cs[1] == "compare") "compare" else "tune"
    set_col(fx, where_run, "CH_rear", cs[1], cs[2], "new")
    set_col(fx, where_kept, "BT_rear", cs[1], cs[2], "old")
    before <- tree_md5(fx)
    expect_error(promote(fx, keys = "CH_rear"), paste("would leave BT_rear on another", cs[2]), info = cs[2])
    expect_identical(tree_md5(fx), before, info = cs[2])
    # the same field on the kept key, or no record of it there (a table from before it), passes
    set_col(fx, where_kept, "BT_rear", cs[1], cs[2], NA)
    expect_silent(promote(fx, keys = "CH_rear", dry_run = TRUE))
  }
})

test_that("the promoted keys must agree with each other and with the live values passed", {
  fx <- promote_fx()
  set_col(fx, "run_tune", "CH_rear", "grades", "walk_md5", "w1")
  set_col(fx, "run_tune", "BT_rear", "grades", "walk_md5", "w2")
  expect_error(promote(fx), "carry 2 values of walk_md5")
  fx <- promote_fx()
  expect_error(promote(fx, live = list(evidence_md5 = "e9")), "carry evidence_md5 e1, not e9")
  expect_silent(promote(fx, live = list(evidence_md5 = "e1"), dry_run = TRUE))
})

test_that("the Atlas-gradient sensitivity is held to the same build as the main tables", {
  fx <- promote_fx(ev = "e2")
  dir.create(file.path(fx$tune, "grad_fwa"))
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", evidence_md5 = "e1", run_uid = "u1"),
                   file.path(fx$tune, "grad_fwa", "CH_rear_summary.csv"), row.names = FALSE)
  # the whole run moves both main keys to e2 but brings no sensitivity: the tracked one is on e1
  expect_error(promote(fx), "would leave grad_fwa/CH_rear on another evidence_md5")
  dir.create(g <- file.path(fx$tune, "candidate", "r1", "grad_fwa"))
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", evidence_md5 = "e2", run_uid = "u1"),
                   file.path(g, "CH_rear_summary.csv"), row.names = FALSE)
  p <- promote(fx)
  expect_identical(utils::read.csv(file.path(fx$tune, "grad_fwa", "CH_rear_summary.csv"))$evidence_md5, "e2")
})

test_that("a comparison older than its key's grades is refused", {
  fx <- promote_fx()
  Sys.setFileTime(file.path(fx$compare, "candidate", "r1", "CH_rear_compare.csv"), Sys.time() - 3600)
  expect_error(promote(fx), "CH_rear: compared before it was last graded")
})

test_that("what a promotion replaces is archived as a candidate, and promoting the archive undoes it", {
  fx <- promote_fx()
  dir.create(file.path(fx$compare, "gpkg"))
  writeLines("old gpkg", file.path(fx$compare, "gpkg", "CH_rear.gpkg"))
  dir.create(file.path(fx$compare, "candidate", "r1", "gpkg"))
  writeLines("new gpkg", file.path(fx$compare, "candidate", "r1", "gpkg", "CH_rear.gpkg"))
  writeLines("old png", file.path(fx$fig, "compare_ch_rear_morr.png"))
  before <- tree_md5(fx)
  p <- promote(fx)
  expect_match(p$archive, "^replaced_[0-9]{8}_[0-9]{6}(_[0-9]+)?$")
  expect_identical(readLines(file.path(fx$compare, "gpkg", "CH_rear.gpkg")), "new gpkg")
  # a figure of a promoted key the run did not draw is removed, and archived with the rest
  expect_false(file.exists(file.path(fx$fig, "compare_ch_rear_morr.png")))
  a_t <- file.path(fx$tune, "candidate", p$archive); a_c <- file.path(fx$compare, "candidate", p$archive)
  expect_identical(utils::read.csv(file.path(a_t, "CH_rear_tune.csv"))$tag, "old")
  expect_true(file.exists(file.path(a_t, "CH_rear_honest.csv")))
  expect_identical(readLines(file.path(a_c, "gpkg", "CH_rear.gpkg")), "old gpkg")
  expect_true(file.exists(file.path(a_c, "fig", "compare_ch_rear_morr.png")))
  expect_identical(unique(utils::read.csv(file.path(a_c, "compare.csv"))$tag), "old")
  # undone by promoting the archive; what the promotion added where nothing stood (its logs, BT's new figure) stays
  q <- knw_tune_promote(p$archive, tune_dir = fx$tune, compare_dir = fx$compare, log_dir = fx$logs, fig_dir = fx$fig)
  expect_false(identical(q$archive, p$archive))
  after <- tree_md5(fx)
  expect_identical(after[names(before)], before)
  expect_setequal(setdiff(names(after), names(before)),
                  file.path(c(fx$logs, fx$logs, fx$fig), c("20261028_tune_run-r1.txt", "20261028_compare-r1.txt",
                                                           "compare_bt_rear_bulk.png")))
})

test_that("what the run did not bring is kept and noted", {
  fx <- promote_fx()
  unlink(file.path(fx$compare, "candidate", "r1", "compare.csv"))
  writeLines("x", file.path(fx$compare, "floodplain.csv"))
  p <- promote(fx, dry_run = TRUE)
  expect_true(any(grepl("compare.csv: not in the run", p$notes)))
  expect_true(any(grepl("floodplain.csv: not in the run", p$notes)))
})
