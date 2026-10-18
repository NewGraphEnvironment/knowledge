# The chinook rearing article reads saved copies of the tuning and comparison tables
# (data-raw/vignette_chinook.R). These tests fail when a copy no longer matches the table it
# came from, so an article cannot go on quoting a run that has been superseded. The sources
# live in the source tree's data/ and scripts/logs/, absent from an installed or checked
# package, where the source-tree tests skip.

vd <- function(f) system.file("vignette-data", f, package = "knowledge")

test_that("the article's data ships with the package", {
  for (f in c("chinook_rearing.rds", "bulk_segments.rds", "bulk_water.rds", "bulk_fp_grade.tif")) {
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

test_that("the CH rearing rows of the tables that hold every species are unchanged since they were saved", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("chinook_rearing.rds"))
  expect_length(x$meta$md5_rows, 2)
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

test_that("the floodplain raster's graded cells are the group's graded accessible floodplain", {
  skip_if_not_installed("terra")
  x <- readRDS(vd("chinook_rearing.rds"))
  r <- terra::rast(vd("bulk_fp_grade.tif"))
  v <- terra::values(r, mat = FALSE)
  expect_true(all(v[!is.na(v)] >= 0 & v[!is.na(v)] <= 100))
  fp <- x$floodplain[x$floodplain$watershed_group_code == x$meta$map_group & x$floodplain$rule == "accessible", ]
  expect_equal(nrow(fp), 1)
  expect_lt(abs(sum(!is.na(v)) * 0.09 - (fp$ha - fp$ha_grade_na)), 1)
})
