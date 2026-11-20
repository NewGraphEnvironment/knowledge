codes <- data.frame(code = c("RB", "BT", "NFC", "ZZZ"), catch_class = c("fish", "fish", "zero_catch", "zero_catch"))

s2_row <- function(site_key, species = NA, total_number = NA, ef_seconds = NA, soak_time = NA, comments = NA,
                   sampling_method = "EF") {
  data.frame(site_key = site_key, sampling_method = sampling_method, species = species,
             total_number = total_number, ef_seconds = ef_seconds, ef_length_m = NA, soak_time = soak_time,
             comments = comments)
}

test_that("knw_fiss_nfc() separates submitted, derived, conflicting and unknown no-fish sites", {
  s2 <- rbind(
    s2_row("a", "Rainbow Trout", "4", "300"),
    s2_row("b", "No Fish Caught", NA, "450", comments = "fished 120 m"),
    s2_row("c", "Rainbow Trout", "0", "600"),
    s2_row("d", "NFC", NA, NA, "24", sampling_method = "MT"),
    s2_row("d", "RB", "3", NA, "24", sampling_method = "MT"),
    s2_row("e", NA, NA, "500"),
    s2_row("f", "RB", NA, "200"),
    s2_row("g", NA, "0", NA)
  )
  out <- knw_fiss_nfc(s2, codes)
  expect_identical(out$site_key, letters[1:7])
  expect_identical(out$nfc, c(FALSE, TRUE, TRUE, FALSE, FALSE, FALSE, FALSE))
  expect_identical(out$nfc_source, c(NA, "submitted", "derived", NA, NA, NA, NA))
  expect_identical(out$nfc_conflict, c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE))
  # a named species with no count was caught; a blank count is never a zero
  expect_identical(out$any_caught, c(TRUE, FALSE, FALSE, TRUE, FALSE, TRUE, FALSE))
  expect_identical(out$fish_counted, c(TRUE, FALSE, TRUE, TRUE, FALSE, FALSE, TRUE))
  # an explicit zero lists the species without catching it
  expect_identical(out$species_list[3], "Rainbow Trout")
  expect_identical(out$species_caught[3], "")
  expect_identical(out$species_list[4], "RB")
  expect_identical(out$methods_used[4], "MT")
  expect_identical(out$max_soak_time, c(NA, NA, NA, 24, NA, NA, NA))
  expect_identical(out$total_ef_secs, c(300, 450, 600, 0, 500, 200, 0))
  expect_identical(out$comments_fish[2], "fished 120 m")
  # g: a zero count with no effort recorded is not a no-fish site
  expect_identical(out$effort_recorded[7], FALSE)
})

test_that("knw_fiss_nfc() reads zero-catch codes from the code table, case and space folded", {
  s2 <- rbind(s2_row("a", " zzz ", NA, "100"), s2_row("b", "nfc", NA, "100"))
  out <- knw_fiss_nfc(s2, codes)
  expect_identical(out$nfc_source, c("submitted", "submitted"))
  expect_identical(out$species_list, c("", ""))
  expect_error(knw_fiss_nfc(s2, data.frame(code = "RB", catch_class = "fish")), "no zero_catch")
})

test_that("knw_fiss_nfc() rolls up the fixture workbooks' Step 2 as 0220 would", {
  f <- system.file("testdata", "fiss", "pre2012_step_banner.xls", package = "knowledge")
  s2 <- knw_fiss_parse_step(f, "11293", "step2_fish_coll")$data
  out <- knw_fiss_nfc(s2, codes)
  expect_identical(out$site_key, c("11293:1", "11293:2", "11293:3"))
  expect_identical(out$nfc_source, c("submitted", NA, NA))
  expect_identical(out$nfc_conflict, c(FALSE, TRUE, FALSE))
  expect_identical(out$total_fish, c(0, 3, 0))
})
