# The chinook rearing article reads saved copies of the tuning and comparison tables
# (data-raw/vignette_chinook.R). These tests fail when a copy no longer matches the table it
# came from, so an article cannot go on quoting a run that has been superseded. The sources
# live in the source tree's data/ and scripts/logs/, absent from an installed or checked
# package, where the source-tree tests skip.

vd <- function(f) system.file("vignette-data", f, package = "knowledge")

test_that("the article's data ships with the package", {
  for (f in c("chinook_rearing.rds", "bulk_segments.rds", "bulk_water.rds", "method.rds")) {
    expect_true(nzchar(vd(f)), info = f)
  }
})

root <- testthat::test_path("..", "..")
has_src <- dir.exists(file.path(root, "data"))

test_that("every source the article's tables came from is unchanged since they were saved", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("chinook_rearing.rds"))
  expect_gt(length(x$meta$md5), 0)
  for (f in names(x$meta$md5)) {
    p <- file.path(root, f)
    expect_true(file.exists(p), info = f)
    expect_identical(unname(tools::md5sum(p)), unname(x$meta$md5[[f]]),
                     info = paste(f, "changed: rerun Rscript data-raw/vignette_chinook.R"))
  }
})

test_that("the CH rearing rows of the table that holds every species are unchanged since they were saved", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("chinook_rearing.rds"))
  expect_length(x$meta$md5_rows, 1)
  for (f in names(x$meta$md5_rows)) {
    expect_identical(.knw_rows_md5(file.path(root, f), "CH", "rear"), unname(x$meta$md5_rows[[f]]),
                     info = paste(f, "CH rearing rows changed: rerun Rscript data-raw/vignette_chinook.R"))
  }
})

test_that("the saved recommended rule is the thresholds table's CH_rear_v1 rule", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("chinook_rearing.rds"))
  thr <- utils::read.csv(file.path(root, "data", "thresholds.csv"), stringsAsFactors = FALSE)
  rule <- unique(thr$rule[thr$rule_id == "CH_rear_v1"])
  expect_length(rule, 1)
  expect_identical(x$tune$rule[x$tune$recommended %in% TRUE], rule)
})

test_that("the map's segments carry the comparison's km for their group", {
  x <- readRDS(vd("chinook_rearing.rds"))
  seg <- readRDS(vd("bulk_segments.rds"))
  row <- x$compare[x$compare$watershed_group_code == x$meta$map_group, ]
  expect_equal(nrow(row), 1)
  expect_true(all(seg$accessible))
  km <- function(f) sum(seg$length_metre[seg[[f]] %in% TRUE]) / 1000
  expect_equal(km("flag_default"), row$default_km, tolerance = 1e-9)
  expect_equal(km("flag_tuned"), row$tuned_km, tolerance = 1e-9)
  expect_equal(sum(seg$length_metre) / 1000, row$accessible_km, tolerance = 1e-9)
})

test_that("every species' tune table is saved, and replays to its recommended rule at one SE (#79)", {
  x <- readRDS(vd("chinook_rearing.rds"))
  ta <- x$tune_all
  keys <- unique(paste(ta$species_code, ta$stage))
  expect_length(keys, 7)   # rainbow trout rearing is not modelled on #145's build
  expect_true("CH rear" %in% keys)
  for (k in keys) {
    t <- ta[paste(ta$species_code, ta$stage) == k, ]
    expect_equal(sum(t$is_default), 1, info = k)
    expect_identical(knw_tune_repick(t)$rule, t$rule[t$recommended %in% TRUE], info = k)
  }
  # the CH rows are the CH table the rest of the article reads
  ch <- ta[ta$species_code == "CH" & ta$stage == "rear", ]
  expect_identical(ch$rule, x$tune$rule)
  expect_equal(ch$ddev_best, x$tune$ddev_best)
})

test_that("the wetland figure, the run's versions and each map segment's water are saved (#79)", {
  x <- readRDS(vd("chinook_rearing.rds"))
  w <- x$wetland
  # one row per structure the comparison ran (#73), and the one reported as tuned flagged
  expect_gte(nrow(w), 1)
  expect_equal(sum(w$as_tuned), 1)
  expect_true(all(is.finite(c(w$km_default, w$km_tuned, w$km_both, w$grade_median_tuned))))
  expect_true(all(w$km_both <= pmin(w$km_default, w$km_tuned) + 1e-9))
  expect_identical(w$structure[w$as_tuned], x$meta$tuned_structure)
  # nzchar(NA) is TRUE, so NA needs its own check
  expect_false(anyNA(unlist(x$meta$versions)))
  expect_true(all(nzchar(unlist(x$meta$versions))))
  expect_setequal(names(x$meta$versions), c("link", "link_sha", "fresh", "fresh_sha", "fwapg_sha", "wet"))
  seg <- readRDS(vd("bulk_segments.rds"))
  expect_true(all(seg$water %in% c("stream", "river", "wetland", "lake")))
  expect_identical(seg$water == "stream", !seg$in_waterbody)
})

# the methodology article (#93) reads data-raw/vignette_method.R's bundle
test_that("every tracked source of the methodology article is unchanged since its bundle was saved", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("method.rds"))
  expect_gt(length(x$meta$md5), 0)
  for (f in names(x$meta$md5)) {
    p <- file.path(root, f)
    expect_true(file.exists(p), info = f)
    expect_identical(unname(tools::md5sum(p)), unname(x$meta$md5[[f]]),
                     info = paste(f, "changed: rerun Rscript data-raw/vignette_method.R"))
  }
})

test_that("every ignored source of the methodology article, where present, is unchanged", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("method.rds"))
  here <- names(x$meta$md5_local)[file.exists(file.path(root, names(x$meta$md5_local)))]
  skip_if(length(here) == 0, "the ignored FDIS build is not on this machine")
  for (f in here) {
    expect_identical(unname(tools::md5sum(file.path(root, f))), unname(x$meta$md5_local[[f]]),
                     info = paste(f, "changed: rerun Rscript data-raw/vignette_method.R"))
  }
})

# a grade table's record is tracked and the bundles pin it (#119); the ignored table it describes is checked against it
# where present. Opt-in: the published tables are up to 26 GB to md5
test_that("every grade table present is the one its tracked record describes", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  skip_if_not(identical(Sys.getenv("KNW_CHECK_GRADES"), "TRUE"), "KNW_CHECK_GRADES=TRUE md5s the grade tables")
  recs <- list.files(file.path(root, "data", "tune"), "_grades_record\\.csv$", full.names = TRUE)
  expect_gt(length(recs), 0)
  for (r in recs) {
    g <- sub("_grades_record\\.csv$", "_grades.csv", r)
    if (file.exists(g)) expect_true(knw_grade_record_check(knw_grade_record_read(r), g), info = basename(g))
  }
})

test_that("the methodology bundle's funnel adds up and every register row was resolved", {
  x <- readRDS(vd("method.rds"))
  f <- x$funnel
  expect_true(all(diff(f$n) <= 0))
  expect_identical(f$n[1], 51587)
  expect_setequal(unique(x$resolved$key), x$settings$key)
})

test_that("the methodology bundle's site-gradient check covers every published gradient limit (#121)", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("method.rds"))
  thr <- utils::read.csv(file.path(root, "data", "thresholds.csv"), stringsAsFactors = FALSE)
  g <- thr[thr$component == "gradient" & !is.na(thr$value), ]
  expect_setequal(x$site_gradient$limits$key, paste(g$species_code, g$stage, sep = "_"))
  expect_true(all(x$site_gradient$limits$against == "segment_gradient"))
  expect_lt(x$site_gradient$segment$spearman, x$site_gradient$yardstick$spearman)
})
