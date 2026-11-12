# The chinook rearing article reads saved copies of the tuning and comparison tables
# (data-raw/vignette_chinook.R). These tests fail when a copy no longer matches the table it
# came from, so an article cannot go on quoting a run that has been superseded. The sources
# live in the source tree's data/ and scripts/logs/, absent from an installed or checked
# package, where the source-tree tests skip.

vd <- function(f) system.file("vignette-data", f, package = "knowledge")

test_that("the article's data ships with the package", {
  for (f in c("chinook_rearing.rds", "bulk_segments.rds", "bulk_water.rds", "method.rds", "cut_points.rds",
              "cut_points_places.rds")) {
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
  # the register is held by what the article prints (the test below), not by its bytes
  for (f in setdiff(names(x$meta$md5), "inst/method/settings.csv")) {
    p <- file.path(root, f)
    expect_true(file.exists(p), info = f)
    expect_identical(unname(tools::md5sum(p)), unname(x$meta$md5[[f]]),
                     info = paste(f, "changed: rerun Rscript data-raw/vignette_method.R"))
  }
})

# the article prints every register column but `where` and `note` (its step lists, its settings table and the counts
# above it), so a change to those columns stales the bundle and a change to `where` or `note` does not (#118)
test_that("the register's printed columns are the ones the methodology bundle was written from", {
  # both ship with the package, so this runs in CI too
  x <- readRDS(vd("method.rds"))
  cols <- c("key", "step", "label", "value", "unit", "source", "tested", "issue")
  now <- utils::read.csv(system.file("method", "settings.csv", package = "knowledge"), colClasses = "character",
                         na.strings = character())
  then <- as.data.frame(lapply(as.data.frame(x$settings)[cols], as.character), stringsAsFactors = FALSE)
  expect_true(all(cols %in% names(now)))
  expect_identical(now[cols], then, info = "settings.csv changed what the article prints: rerun Rscript data-raw/vignette_method.R")
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

# the cut-points article (#149) reads data-raw/vignette_cut_points.R's bundle, built from a stage on the database's host
# (data-raw/cut_points_stage.R) and logs written once, and data-raw/vignette_cut_points_places.R's places
test_that("every tracked source of the cut-points article is unchanged since its bundle was saved", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("cut_points.rds"))
  expect_gt(length(x$meta$md5), 0)
  for (f in names(x$meta$md5)) {
    p <- file.path(root, f)
    expect_true(file.exists(p), info = f)
    expect_identical(unname(tools::md5sum(p)), unname(x$meta$md5[[f]]),
                     info = paste(f, "changed: rerun Rscript data-raw/vignette_cut_points.R"))
  }
})

test_that("every staged input of the cut-points article, where present, is unchanged", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("cut_points.rds"))
  expect_gt(length(x$meta$md5_local), 0)
  here <- names(x$meta$md5_local)[file.exists(file.path(root, names(x$meta$md5_local)))]
  skip_if(length(here) == 0, "the stage (data/stage/cut_points) is not on this machine")
  for (f in here) {
    expect_identical(unname(tools::md5sum(file.path(root, f))), unname(x$meta$md5_local[[f]]),
                     info = paste(f, "changed: rerun Rscript data-raw/vignette_cut_points.R"))
  }
})

test_that("the cut-points places were measured on the bundle the article reads", {
  pl <- readRDS(vd("cut_points_places.rds"))
  x <- readRDS(vd("cut_points.rds"))
  expect_identical(pl$meta$bundle_md5, unname(tools::md5sum(vd("cut_points.rds"))))
  p <- pl$places
  expect_setequal(p$site_visit[p$place == "example"], names(x$examples))
  expect_identical(p$site_visit[p$place == "concept"], x$concept$site$site_visit)
  expect_identical(p$gnis_name[p$place == "map"], "Morkill River")
  expect_false(anyNA(p$town))
  expect_false(anyNA(p$joins))
  expect_true(all(p$town_km > 0))
})

test_that("the cut-points premise is the three segment gradient check logs' (C1)", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("cut_points.rds"))
  logs <- c(published_92 = "20261027_segment_gradient_check.txt",
            published_145 = "20261103_segment_gradient_check-derived_default_20261103.txt",
            minimal = "20261103_segment_gradient_check-derived_minimal.txt")
  pm <- x$premise
  expect_setequal(paste(pm$network, pm$catch_status), paste(rep(names(logs), each = 2), c("fish", "zero")))
  for (n in names(logs)) {
    ll <- readLines(file.path(root, "scripts", "logs", "habitat", logs[[n]]))
    for (cs in c("fish", "zero")) {
      w <- strsplit(trimws(grep(sprintf("^ +%s +[0-9]", cs), ll, value = TRUE)[1]), " +")[[1]]
      r <- pm[pm$network == n & pm$catch_status == cs, ]
      expect_identical(r$visits, as.integer(w[2]), info = paste(n, cs))
      expect_lt(abs(r$at_site_pct - as.numeric(w[3])), 0.05)
    }
  }
})

test_that("the cut-points setups, transfer and other keys are the logs' (C2)", {
  skip_if_not(has_src, "no source-tree data/ (installed package)")
  x <- readRDS(vd("cut_points.rds"))
  su <- x$setups
  expect_identical(su$setup, c("published", "minimal", "parent", "atlas"))
  expect_setequal(names(x$tune), su$setup)
  lg <- utils::read.csv(file.path(root, "scripts", "logs", "habitat", "20261105_setup_compare-ch_rear.csv"),
                        stringsAsFactors = FALSE)
  lg <- lg[match(su$setup, lg$setup), ]
  expect_identical(su$pick, lg$pick)
  expect_identical(su$tune_run, lg$tune_run)
  expect_equal(su$tuned_km, lg$tuned_km, tolerance = 1e-9)
  expect_equal(su$default_km, lg$default_km, tolerance = 1e-9)
  # each setup's pick is the one rule its tune table recommends
  for (s in su$setup) {
    t <- x$tune[[s]]
    expect_identical(t$rule[t$recommended %in% "TRUE"], su$pick[su$setup == s], info = s)
  }
  tr <- x$transfer
  expect_lt(abs(tr$minimal_km - su$tuned_km[su$setup == "minimal"]), 0.05)
  expect_lt(abs(tr$parent_km - su$tuned_km[su$setup == "parent"]), 0.05)
  # an empty cell is a key that network did not fit (rainbow trout rearing on neither build)
  pk <- utils::read.csv(file.path(root, "scripts", "logs", "habitat", "20261104_pick_network_compare.csv"),
                        stringsAsFactors = FALSE, na.strings = c("", "NA"))
  pk <- pk[!is.na(pk$rule_recommended_minimal) & !is.na(pk$rule_recommended_full), ]
  ok <- x$other_keys
  expect_equal(nrow(ok), 7)
  expect_setequal(ok$key, pk$key)
  expect_identical(ok$pick_full, pk$rule_recommended_full[match(ok$key, pk$key)])
  expect_identical(ok$pick_minimal, pk$rule_recommended_minimal[match(ok$key, pk$key)])
})

test_that("the cut-points examples meet the criteria the bundle states", {
  x <- readRDS(vd("cut_points.rds"))
  cr <- x$criteria
  st <- x$sites
  # a crossing site reads its full segment's slope and its minimal parent's on opposite sides of a tuned limit
  side <- function(g, t) g <= t
  cross <- Reduce(`|`, lapply(cr$limits, function(t) side(st$full_gradient, t) != side(st$parent_gradient, t)))
  expect_identical(st$crosses, cross)
  cand <- st[st$crosses & st$present & st$full_length_m >= cr$min_len_m, ]
  # the concept site starts its own full segment and has the largest gap of the candidates that do
  at <- cand[cand$full_offset_m >= -1 & cand$full_offset_m <= 5, ]
  expect_identical(x$concept$site$site_visit, at$site_visit[order(-at$gap, at$site_visit)][1])
  # the examples: the largest gap in each other group, from the groups with the largest gaps
  ex <- cand[cand$watershed_group_code != x$concept$site$watershed_group_code, ]
  ex <- ex[order(ex$watershed_group_code, -ex$gap, ex$site_visit), ]
  ex <- ex[!duplicated(ex$watershed_group_code), ]
  ex <- ex[order(-ex$gap, ex$watershed_group_code), ][seq_len(cr$n_examples), ]
  expect_identical(names(x$examples), ex$site_visit)
  for (e in x$examples) {
    expect_true(all(c("full", "minimal") %in% e$segments$network), info = e$site$site_visit)
    expect_equal(nrow(e$sites[e$sites$site_visit == e$site$site_visit, ]), 1, info = e$site$site_visit)
  }
})
