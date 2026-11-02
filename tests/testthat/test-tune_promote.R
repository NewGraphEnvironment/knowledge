# the record 0320 writes beside a grade table (#119), from the fixture's table as it now stands
fx_record <- function(g) {
  knw_grade_record_write(g, tune_run = "r1", evidence_ledger = "ledger.csv", knowledge_commit = "abc1234",
                         link = c(version = "0.66.0", sha = "def"), tokens = c(cut = NA, acc = NA, grad = NA, flow = NA),
                         rows = 2)
}

# a tracked tune/compare pair holding two keys (CH_rear, BT_rear) on build "e1", and a candidate run r1 of both on
# build `ev`, with CH's pick moved
set_col <- function(fx, where, k, what, col, value) {
  d <- switch(where, run_tune = file.path(fx$tune, "candidate", "r1"), run_cmp = file.path(fx$compare, "candidate", "r1"),
              tune = fx$tune, compare = fx$compare)
  f <- file.path(d, paste0(k, "_", what, ".csv"))
  x <- utils::read.csv(f, colClasses = "character")
  x[[col]] <- value
  t0 <- file.mtime(f)
  utils::write.csv(x, f, row.names = FALSE, na = "")
  Sys.setFileTime(f, t0)   # keep the grade/comparison order the fixture set
  if (what == "grades") fx_record(f)   # as 0320 writes a table and its record together
}

promote_fx <- function(ev = "e1", ch_rule = "mad>=0.5|g<=0.07|none", env = parent.frame()) {
  d <- withr::local_tempdir(.local_envir = env)
  tn <- file.path(d, "tune"); cm <- file.path(d, "compare")
  ct <- file.path(tn, "candidate", "r1"); cc <- file.path(cm, "candidate", "r1")
  for (x in c(tn, cm, ct, cc, file.path(d, "logs"), file.path(d, "fig"), file.path(cc, "fig"))) dir.create(x, recursive = TRUE)
  key_files <- function(dir_t, dir_c, k, rule, ev, tag) {
    sp <- sub("_.*", "", k); st <- sub(".*_", "", k)
    utils::write.csv(data.frame(species_code = sp, stage = st, status = "fitted", rule_recommended = rule,
                                null_heldout_curve = 100.1234, curve_prior_sd = 2.5, curve_grad = "segment_gradient",
                                grade_withheld = FALSE, evidence_md5 = ev, run_uid = "u1"),
                     file.path(dir_t, paste0(k, "_summary.csv")), row.names = FALSE)
    utils::write.csv(data.frame(rule = rule, tag = tag), file.path(dir_t, paste0(k, "_tune.csv")), row.names = FALSE)
    utils::write.csv(data.frame(segment = 1:2, species_code = sp, stage = st, rule = rule, run_uid = "u1",
                                ref_population = "stream_branch", ref_edge = "1000;1100", q_walk = "0.75", walk = "bank",
                                walk_md5 = "w0", discharge_load = "wet load", curve_prior_sd = "2.5",
                                grade_withheld = "FALSE", null_heldout_curve = "100.1234", evidence_md5 = ev,
                                curve_grad = "segment_gradient"),
                     file.path(dir_t, paste0(k, "_grades.csv")), row.names = FALSE)
    fx_record(file.path(dir_t, paste0(k, "_grades.csv")))
    saveRDS(list(tag = tag), file.path(dir_t, paste0(k, "_curve.rds")))
    for (w in c("_curves.csv", "_groups.csv", "_seeds.csv", "_honest.csv")) writeLines("x", file.path(dir_t, paste0(k, w)))
    utils::write.csv(data.frame(watershed_group_code = c("BULK", "ALL"), species_code = sp, stage = st, tuned_rule = rule,
                                km = c(1, 2), tag = tag), file.path(dir_c, paste0(k, "_compare.csv")), row.names = FALSE)
    saveRDS(list(tag = tag), file.path(dir_c, paste0(k, "_segments.rds")))
  }
  key_files(tn, cm, "CH_rear", "mad>=0.75|g<=0.09|none", "e1", "old")
  key_files(tn, cm, "BT_rear", "width>=1|g<=0.2|none", "e1", "old")
  key_files(ct, cc, "CH_rear", ch_rule, ev, "new")
  key_files(ct, cc, "BT_rear", "width>=1|g<=0.2|none", ev, "new")
  # a stale tracked file the run does not write, and a file of another key whose name starts like one
  writeLines("x", file.path(tn, "CH_rear_stale.csv"))
  writeLines("x", file.path(tn, "CH_rearing_other.csv"))
  combined <- function(dir_c, tag, order = c("BT_rear", "CH_rear")) {
    x <- do.call(rbind, lapply(order, function(k) utils::read.csv(file.path(dir_c, paste0(k, "_compare.csv")))))
    x$tag <- tag
    utils::write.csv(x, file.path(dir_c, "compare.csv"), row.names = FALSE)
  }
  combined(cm, "old", c("CH_rear", "BT_rear"))
  combined(cc, "new")
  writeLines(c("tune log", "CH_rear grades: 2 groups, ...", "BT_rear grades: 2 groups, ..."),
             file.path(ct, "20261028_tune_run-r1.txt"))
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
  expect_false(file.exists(file.path(fx$tune, "CH_rear_stale.csv")))
  expect_true(file.exists(file.path(fx$tune, "CH_rearing_other.csv")))
  expect_identical(p$removed, file.path(fx$tune, "CH_rear_stale.csv"))
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
  set_col(fx, "run_tune", "CH_rear", "grades", "rule", "other")
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
  expect_identical(p$removed, file.path(fx$tune, "CH_rear_stale.csv"))
})

test_that("promoting a copy of the tracked run changes nothing", {
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1"); cc <- file.path(fx$compare, "candidate", "r1")
  unlink(c(ct, cc), recursive = TRUE)
  dir.create(ct); dir.create(cc)
  file.copy(list.files(fx$tune, full.names = TRUE, pattern = "^(CH|BT)_rear_"), ct)
  file.copy(list.files(fx$compare, full.names = TRUE, pattern = "\\.(csv|rds)$"), cc)
  writeLines(c("CH_rear grades: 2 groups", "BT_rear grades: 2 groups"), file.path(ct, "20261027_tune_run.txt"))
  file.copy(file.path(ct, "20261027_tune_run.txt"), fx$logs)
  before <- tree_md5(fx)
  p <- promote(fx)
  expect_identical(tree_md5(fx), before)
  expect_length(p$removed, 0)
})

# set one column of one candidate or tracked table of a key

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
    # a field the grades record too moves with the fit, in the run and in the kept key
    if (cs[1] == "summary" && cs[2] %in% c("run_uid", "curve_grad")) {
      set_col(fx, where_run, "CH_rear", "grades", cs[2], "new")
      set_col(fx, where_kept, "BT_rear", "grades", cs[2], "old")
    }
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
  expect_true(file.exists(file.path(a_t, "CH_rear_stale.csv")))
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

test_that("a run whose comparison did not finish is refused; one that drew no maps keeps the tracked floodplain rows", {
  fx <- promote_fx()
  unlink(file.path(fx$compare, "candidate", "r1", "compare.csv"))
  expect_error(promote(fx), "compare.csv is not in .*: its last comparison did not finish")
  fx <- promote_fx()
  writeLines(c("species_code,stage,ha", "CH,rear,5", "BT,rear,7"), file.path(fx$compare, "floodplain.csv"))
  p <- promote(fx, dry_run = TRUE)
  expect_true(any(grepl("floodplain.csv: not in the run; the tracked rows of BT_rear, CH_rear kept", p$notes)))
})
test_that("a fitted key the run's combined table leaves out is refused, never dropped (round 1)", {
  fx <- promote_fx()
  f <- file.path(fx$compare, "candidate", "r1", "compare.csv")
  x <- utils::read.csv(f)
  utils::write.csv(x[x$species_code != "CH", ], f, row.names = FALSE)
  before <- tree_md5(fx)
  expect_error(promote(fx), "compare.csv in the run leaves out CH_rear")
  expect_identical(tree_md5(fx), before)
})

test_that("a key the run no longer fits leaves none of its last fit behind", {
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1"); cc <- file.path(fx$compare, "candidate", "r1")
  unlink(c(list.files(ct, "^CH_rear_", full.names = TRUE), list.files(cc, "^CH_rear_", full.names = TRUE),
           file.path(cc, "fig", "compare_ch_rear_bulk.png")))
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", status = "too_few_groups"),
                   file.path(ct, "CH_rear_summary.csv"), row.names = FALSE)
  x <- utils::read.csv(file.path(cc, "compare.csv"))
  utils::write.csv(x[x$species_code != "CH", ], file.path(cc, "compare.csv"), row.names = FALSE)
  writeLines("old png", file.path(fx$fig, "compare_ch_rear_bulk.png"))
  p <- promote(fx)
  expect_identical(list.files(fx$tune, "^CH_rear_"), "CH_rear_summary.csv")
  expect_length(list.files(fx$compare, "^CH_rear_"), 0)
  expect_false(file.exists(file.path(fx$fig, "compare_ch_rear_bulk.png")))
  expect_false("CH" %in% utils::read.csv(file.path(fx$compare, "compare.csv"))$species_code)
})

test_that("a log path is never written over: the next pass is numbered", {
  d <- withr::local_tempdir()
  f <- file.path(d, "20261028_compare-r1.txt")
  expect_identical(.knw_free_path(f), f)
  writeLines("1", f)
  expect_identical(.knw_free_path(f), file.path(d, "20261028_compare-r1-2.txt"))
  writeLines("2", file.path(d, "20261028_compare-r1-2.txt"))
  expect_identical(.knw_free_path(f), file.path(d, "20261028_compare-r1-3.txt"))
})

test_that("a key whose fit failed is refused, never taken for one the run does not fit (round 2)", {
  for (st in c("curve_failed", "smoke", "fitted")) {
    fx <- promote_fx()
    ct <- file.path(fx$tune, "candidate", "r1")
    unlink(list.files(ct, "^CH_rear_", full.names = TRUE))
    utils::write.csv(data.frame(species_code = "CH", stage = "rear", status = st),
                     file.path(ct, "CH_rear_summary.csv"), row.names = FALSE)
    before <- tree_md5(fx)
    expect_error(promote(fx), paste0("CH_rear: status ", st, " with no recommended rule"), info = st)
    expect_identical(tree_md5(fx), before, info = st)
  }
})

test_that("a key a later pass no longer fits takes only what that pass wrote (round 3)", {
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1")
  # the later pass: too few groups, so a summary and a curve record; the earlier pass's fit is still in the run
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", status = "too_few_groups"),
                   file.path(ct, "CH_rear_summary.csv"), row.names = FALSE)
  saveRDS(list(tag = "later"), file.path(ct, "CH_rear_curve.rds"))
  x <- utils::read.csv(file.path(fx$compare, "candidate", "r1", "compare.csv"))
  utils::write.csv(x[x$species_code != "CH", ], file.path(fx$compare, "candidate", "r1", "compare.csv"), row.names = FALSE)
  p <- promote(fx)
  expect_setequal(list.files(fx$tune, "^CH_rear_"), c("CH_rear_summary.csv", "CH_rear_curve.rds"))
  expect_identical(readRDS(file.path(fx$tune, "CH_rear_curve.rds"))$tag, "later")
  expect_length(list.files(fx$compare, "^CH_rear_"), 0)
  expect_true(any(grepl("CH_rear: left in the run.*CH_rear_tune.csv", p$notes)))
})

test_that("an unfitted key keeps no rows in the tables of every key, whatever the run's hold (round 4)", {
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1")
  utils::write.csv(data.frame(species_code = "CH", stage = "rear", status = "too_few_groups"),
                   file.path(ct, "CH_rear_summary.csv"), row.names = FALSE)
  writeLines(c("species_code,stage,ha", "CH,rear,5", "BT,rear,7"), file.path(fx$compare, "floodplain.csv"))
  # the run's compare.csv still holds CH's rows from an earlier fit
  p <- promote(fx)
  expect_false("CH" %in% utils::read.csv(file.path(fx$compare, "compare.csv"))$species_code)
  expect_identical(readLines(file.path(fx$compare, "floodplain.csv")), c("species_code,stage,ha", "BT,rear,7"))
  expect_false(file.exists(file.path(fx$tune, "CH_rear_smoke.csv")))
})

test_that("grades another fit made are refused on every field of the keep-check the summary carries (round 4)", {
  for (cs in list(c("grade_withheld", "TRUE"), c("curve_prior_sd", "1"), c("null_heldout_curve", "99"),
                  c("run_uid", "u2"), c("curve_grad", "fwa_gradient"))) {
    fx <- promote_fx()
    set_col(fx, "run_tune", "CH_rear", "grades", cs[1], cs[2])
    expect_error(promote(fx), paste0("CH_rear: the grades carry ", cs[1]), info = cs[1])
  }
  fx <- promote_fx()
  set_col(fx, "run_tune", "CH_rear", "grades", "null_heldout_curve", "100.12340")
  expect_silent(promote(fx, dry_run = TRUE))
})

test_that("an undo restores what was replaced whatever the files' ages (round 4)", {
  fx <- promote_fx()
  writeLines("tracked png", f <- file.path(fx$fig, "compare_ch_rear_bulk.png"))
  Sys.setFileTime(f, Sys.time() - 86400)   # a checkout older than everything the run wrote
  p <- promote(fx)
  expect_identical(readLines(f), "png")
  Sys.setFileTime(file.path(fx$compare, "candidate", p$archive, "fig", "compare_ch_rear_bulk.png"), Sys.time() - 86400)
  q <- knw_tune_promote(p$archive, tune_dir = fx$tune, compare_dir = fx$compare, log_dir = fx$logs, fig_dir = fx$fig)
  expect_identical(readLines(f), "tracked png")
})
test_that("a fitted key no log of the run says it graded is refused", {
  fx <- promote_fx()
  writeLines(c("tune log", "BT_rear grades: 2 groups, ...", "CH_rear: grades already written under x, kept."),
             file.path(fx$tune, "candidate", "r1", "20261028_tune_run-r1.txt"))
  expect_error(promote(fx), "CH_rear: no log of run r1 says it graded the key")
})

test_that("a drawing still in progress is never promoted, and a key the run did not draw keeps its floodplain rows (round 5)", {
  fx <- promote_fx()
  cc <- file.path(fx$compare, "candidate", "r1")
  dir.create(file.path(cc, "gpkg")); dir.create(file.path(fx$compare, "gpkg"))
  writeLines("partial", file.path(cc, "gpkg", "CH_rear.part.gpkg"))
  writeLines("tracked", file.path(fx$compare, "gpkg", "CH_rear.gpkg"))
  dir.create(file.path(cc, "fig", ".part_ch_rear"))
  writeLines("partial", file.path(cc, "fig", ".part_ch_rear", "compare_ch_rear_morr.png"))
  writeLines(c("species_code,stage,ha", "CH,rear,5", "BT,rear,7"), file.path(fx$compare, "floodplain.csv"))
  writeLines(c("species_code,stage,ha", "BT,rear,8"), file.path(cc, "floodplain.csv"))
  p <- promote(fx)
  expect_identical(readLines(file.path(fx$compare, "gpkg", "CH_rear.gpkg")), "tracked")
  expect_false(file.exists(file.path(fx$compare, "gpkg", "CH_rear.part.gpkg")))
  expect_false(file.exists(file.path(fx$fig, "compare_ch_rear_morr.png")))
  expect_identical(readLines(file.path(fx$compare, "floodplain.csv")), c("species_code,stage,ha", "CH,rear,5", "BT,rear,8"))
  expect_true(any(grepl("floodplain.csv: CH_rear not drawn by the run", p$notes)))
})

test_that("a fitted key missing a file its pass writes is refused, and a part file is never taken (round 5)", {
  fx <- promote_fx()
  unlink(file.path(fx$tune, "candidate", "r1", "CH_rear_curve.rds"))
  expect_error(promote(fx), "CH_rear: the run holds no CH_rear_curve.rds")
  fx <- promote_fx()
  writeLines("half", file.path(fx$tune, "candidate", "r1", ".part_CH_rear_grades.csv"))
  p <- promote(fx, dry_run = TRUE)
  expect_false(any(grepl("\\.part_", p$written)))
})

test_that(".knw_write_whole leaves the target only when the writer finished", {
  d <- withr::local_tempdir()
  f <- file.path(d, "CH_rear_grades.csv")
  writeLines("old", f)
  expect_error(.knw_write_whole(f, function(p) { writeLines("half", p); stop("killed") }), "killed")
  expect_identical(readLines(f), "old")
  .knw_write_whole(f, function(p) writeLines("new", p))
  expect_identical(readLines(f), "new")
  expect_identical(list.files(d, all.files = TRUE, no.. = TRUE), c(".part_CH_rear_grades.csv", "CH_rear_grades.csv")[2])
})

test_that("a grade table travels with its record: none, or one of another table, is refused (#119)", {
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1")
  unlink(file.path(ct, "CH_rear_grades_record.csv"))
  expect_error(promote(fx), "CH_rear: the run wrote no record of its grades")
  fx <- promote_fx()
  ct <- file.path(fx$tune, "candidate", "r1")
  # a regraded table whose record was not rewritten: same size, another md5
  g <- file.path(ct, "CH_rear_grades.csv")
  x <- readLines(g)
  x[2] <- sub("^1,", "3,", x[2])
  writeLines(x, g)
  expect_error(promote(fx), "CH_rear: .*CH_rear_grades.csv has md5 .*not the table the record describes")
  fx <- promote_fx()
  p <- promote(fx)
  expect_true(file.path(fx$tune, "CH_rear_grades_record.csv") %in% p$written)
  expect_identical(knw_grade_record_read(file.path(fx$tune, "CH_rear_grades_record.csv"))$grades_md5,
                   unname(tools::md5sum(file.path(fx$tune, "CH_rear_grades.csv"))))
})

test_that("a kept key is held to the set by its record where its grade table is absent (#119)", {
  fx <- promote_fx()
  set_col(fx, "run_tune", "CH_rear", "grades", "walk_md5", "w1")
  set_col(fx, "run_tune", "BT_rear", "grades", "walk_md5", "w1")
  set_col(fx, "tune", "BT_rear", "grades", "walk_md5", "w0")
  unlink(file.path(fx$tune, "BT_rear_grades.csv"))   # a machine with the tracked tables only
  expect_error(promote(fx, keys = "CH_rear"), "would leave BT_rear on another walk_md5")
})

test_that("a key scored under other floors than the tuning's is a test, never promoted (#120)", {
  fx <- promote_fx(ch_rule = "mad>=0.5|g<=0.07|none")
  set_col(fx, "run_tune", "CH_rear", "summary", "folds", "4")
  before <- tree_md5(fx)
  expect_error(promote(fx), "CH_rear: scored with folds = 4, not the tuning's 5: a test run, never promoted")
  expect_identical(tree_md5(fx), before)
  fx <- promote_fx()
  set_col(fx, "run_tune", "BT_rear", "summary", "min_wsg", "4")
  expect_error(promote(fx, keys = "BT_rear"), "BT_rear: scored with min_wsg = 4")
  # the tuning's floors written out, and a summary from before the record, both promote
  fx <- promote_fx()
  set_col(fx, "run_tune", "CH_rear", "summary", "folds", "5")
  set_col(fx, "run_tune", "CH_rear", "summary", "min_wsg", "5")
  expect_silent(promote(fx, keys = "CH_rear", dry_run = TRUE))
})
