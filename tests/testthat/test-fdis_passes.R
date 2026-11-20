fx_passes <- function() {
  passes <- data.frame(
    KEY = c("1_1_1_1_1", "1_1_1_1_2", "1_1_1_2_1", "1_1_2_1_1", "1_1_3_1_1", "1_1_4_1_1", "9_9_9_1_1"),
    site_visit = c("1_1_1", "1_1_1", "1_1_1", "1_1_2", "1_1_3", "1_1_4", "9_9_9"),
    method_number = c(1L, 1L, 2L, 1L, 1L, 1L, 1L),
    haul_or_pass = c(1L, 2L, 1L, 1L, 1L, 1L, 1L),
    date = as.Date("2005-08-01") + c(0, 0, 1, 0, 0, 0, 0),
    fishing_time_s = c(300, 250, 100, 400, NA, 200, 500),
    fished_length_m = c(50, 50, 20, 100, 80, 60, 70),
    fished_width_m = c(4, 4, 3, 5, 2, 3, 2),
    area_m2 = c(200, 200, 60, 500, 160, 180, 140),
    flag_effort_sentinel = c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  # KEY order shuffled, so the pass index cannot come from row order
  passes <- passes[c(3, 1, 2, 4, 5, 6, 7), ]
  counts <- data.frame(
    KEY = c("1_1_1_1_1", "1_1_1_1_1", "1_1_1_1_1", "1_1_1_1_2", "1_1_1_2_1", "1_1_2_1_1", "1_1_4_1_1",
            "1_1_4_1_1", "9_9_9_1_1", "1_1_1_1_9"),
    site_visit = c("1_1_1", "1_1_1", "1_1_1", "1_1_1", "1_1_1", "1_1_2", "1_1_4", "1_1_4", "9_9_9", "1_1_1"),
    # two age rows of BT on pass 1; a sentinel CO count on pass 2; NFC alone on 1_1_2;
    # NFC beside a fish on 1_1_4; a not-fish code; a KEY with no pass row
    species_code = c("BT", "BT", "CH", "CO", "TP", "NFC", "NFC", "RB", "BT", "BT"),
    n = c(3, 2, 1, NA, 5, 0, 0, 1, 7, 4),
    flag_count_sentinel = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  fish <- data.frame(
    KEY = c(rep("1_1_1_1_1", 7), "1_1_1_2_1"),
    site_visit = "1_1_1",
    # seven measured BT on pass 1 against a count of 5: the measured fish win; one CH measured on method 2
    species_code = c(rep("BT", 7), "CH"),
    is_nfc = FALSE,
    stringsAsFactors = FALSE
  )
  codes <- data.frame(code = c("BT", "CH", "CO", "RB", "NFC", "TP"),
                      catch_class = c("fish", "fish", "fish", "fish", "zero_catch", "not_fish"),
                      stringsAsFactors = FALSE)
  list(passes = passes, counts = counts, fish = fish, codes = codes,
       keep = c("1_1_1", "1_1_2", "1_1_3", "1_1_4"))
}

test_that("one row per kept pass, indexed by method then haul, a dropped visit absent", {
  x <- fx_passes()
  r <- knw_fdis_passes(x$passes, x$counts, x$fish, x$keep, x$codes)
  p <- r$passes
  expect_identical(nrow(p), 6L)
  expect_false("9_9_9" %in% p$site_visit)
  v1 <- p[p$site_visit == "1_1_1", ]
  expect_identical(v1$KEY, c("1_1_1_1_1", "1_1_1_1_2", "1_1_1_2_1"))
  expect_identical(v1$pass_index, 1:3)
  expect_true(all(p$n_pass[p$site_visit == "1_1_1"] == 3L))
  expect_identical(p$fished_width_m[p$KEY == "1_1_1_2_1"], 3)
  expect_true(p$flag_effort_sentinel[p$KEY == "1_1_3_1_1"])
})

test_that("pass status tells fish, NFC alone and no record apart", {
  x <- fx_passes()
  p <- knw_fdis_passes(x$passes, x$counts, x$fish, x$keep, x$codes)$passes
  st <- stats::setNames(p$pass_status, p$KEY)
  expect_identical(unname(st["1_1_1_1_1"]), "fish")
  expect_identical(unname(st["1_1_1_1_2"]), "fish")      # a sentinel count is a catch of unknown size
  expect_identical(unname(st["1_1_1_2_1"]), "fish")      # the measured CH; TP is not a fish
  expect_identical(unname(st["1_1_2_1_1"]), "nfc")
  expect_identical(unname(st["1_1_3_1_1"]), "no_record")
  expect_identical(unname(st["1_1_4_1_1"]), "fish")
  expect_identical(p$flag_nfc_conflict, p$KEY == "1_1_4_1_1")
})

test_that("catch per pass sums age rows, takes measured fish when counts are short, and keeps a sentinel unknown", {
  x <- fx_passes()
  pc <- knw_fdis_passes(x$passes, x$counts, x$fish, x$keep, x$codes)$pass_catch
  bt <- pc[pc$KEY == "1_1_1_1_1" & pc$species_code == "BT", ]
  expect_identical(nrow(bt), 1L)
  expect_identical(bt$n_counted, 5)
  expect_identical(bt$n_measured, 7L)
  expect_true(bt$flag_counts_lt_measured)
  expect_identical(bt$n_caught, 7)
  co <- pc[pc$KEY == "1_1_1_1_2" & pc$species_code == "CO", ]
  expect_true(is.na(co$n_caught))
  expect_true(co$flag_count_sentinel)
  ch2 <- pc[pc$KEY == "1_1_1_2_1", ]
  expect_identical(ch2$species_code, "CH")              # TP (not a fish) is not a catch row
  expect_identical(ch2$n_caught, 1)
  expect_false(any(pc$species_code %in% c("NFC", "TP")))
  expect_false("1_1_1_1_9" %in% pc$KEY)                 # its pass has no visits row
  expect_false("9_9_9_1_1" %in% pc$KEY)                 # its visit was dropped
  expect_identical(sort(unique(pc$site_visit)), c("1_1_1", "1_1_4"))
})

test_that("a zero count with nothing measured is not a catch row", {
  x <- fx_passes()
  x$counts$n[x$counts$species_code == "RB"] <- 0
  r <- knw_fdis_passes(x$passes, x$counts, x$fish, x$keep, x$codes)
  expect_false(any(r$pass_catch$species_code == "RB"))
  expect_identical(r$passes$pass_status[r$passes$KEY == "1_1_4_1_1"], "nfc")
})

test_that("an unclassified species code refuses", {
  x <- fx_passes()
  x$counts$species_code[1] <- "ZZQ"
  expect_error(knw_fdis_passes(x$passes, x$counts, x$fish, x$keep, x$codes), "ZZQ")
})
