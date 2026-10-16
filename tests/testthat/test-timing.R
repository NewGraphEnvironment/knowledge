timing_fixture <- function() {
  data.frame(
    wsg_code     = c("MORR", "MORR", "BULK", "BULK"),
    species_code = c("CH", "BT", "CH", "CO"),
    life_stage   = c("spawning", "incubation", "migration", "migration"),
    start        = c("09-01", "08-23", "05-01", "08-15"),
    end          = c("10-07", "04-30", "08-01", NA),
    source       = c("key_a", "key_b", "key_a; key_c", NA),
    note         = c(NA, NA, NA, "end missing in source")
  )
}

write_fixture <- function(x = timing_fixture()) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(x, path, row.names = FALSE, na = "")
  path
}

test_that("with no filter every row comes back, typed as character", {
  out <- knw_timing_read(write_fixture())
  expect_equal(nrow(out), 4)
  expect_named(out, c("wsg_code", "species_code", "life_stage", "start", "end", "source", "note"))
  expect_true(all(vapply(out, is.character, logical(1))))
})

test_that("rows filter by group and by species, each taking several codes", {
  p <- write_fixture()
  expect_equal(knw_timing_read(p, wsg_code = "MORR")$species_code, c("CH", "BT"))
  expect_equal(knw_timing_read(p, species_code = "CH")$wsg_code, c("MORR", "BULK"))
  expect_equal(nrow(knw_timing_read(p, wsg_code = c("MORR", "BULK"), species_code = c("CH", "CO"))), 3)
})

test_that("a window crossing 1 January and a half window are both read", {
  out <- knw_timing_read(write_fixture())
  expect_equal(out$end[out$species_code == "BT"], "04-30")
  expect_true(is.na(out$end[out$species_code == "CO"]))
})

test_that("a filter matching nothing returns the empty table, not NULL", {
  out <- suppressWarnings(knw_timing_read(write_fixture(), wsg_code = "NONE"))
  expect_equal(nrow(out), 0)
  expect_named(out, c("wsg_code", "species_code", "life_stage", "start", "end", "source", "note"))
})

test_that("a life stage outside the vocabulary is refused", {
  x <- timing_fixture()
  x$life_stage[2] <- "Incubation"
  expect_error(knw_timing_read(write_fixture(x)), "life_stage.*Incubation")
})

test_that("a date not written MM-DD is refused", {
  x <- timing_fixture()
  x$start[1] <- "1900-09-01"
  expect_error(knw_timing_read(write_fixture(x)), "MM-DD.*1900-09-01")
})

test_that("a date that does not exist is refused, and 29 February is allowed", {
  x <- timing_fixture()
  x$end[1] <- "02-30"
  expect_error(knw_timing_read(write_fixture(x)), "MM-DD.*02-30")
  x$end[1] <- "02-29"
  expect_no_error(knw_timing_read(write_fixture(x)))
})

test_that("a row with neither start nor end is refused", {
  x <- timing_fixture()
  x$start[4] <- NA
  expect_error(knw_timing_read(write_fixture(x)), "neither")
})

test_that("a missing column is refused", {
  x <- timing_fixture()
  x$source <- NULL
  expect_error(knw_timing_read(write_fixture(x)), "source")
})

test_that("the vocabulary is the one documented", {
  expect_setequal(knw_timing_stages(), c("migration", "spawning", "incubation", "emergence",
                                         "fry_migration", "rearing", "overwintering",
                                         "outmigration"))
})

test_that("overlapping or doubled windows in one group, species and stage are refused", {
  x <- timing_fixture()
  x <- rbind(x, x[2, ])
  expect_error(knw_timing_read(write_fixture(x)), "overlapping windows for MORR BT incubation")
  x <- timing_fixture()
  x <- rbind(x, x[1, ])
  x$start[5] <- "10-07"
  x$end[5] <- "10-20"
  expect_error(knw_timing_read(write_fixture(x)), "overlapping windows for MORR CH spawning")
})

test_that("two windows for one stage are fine when they do not touch", {
  x <- timing_fixture()
  x <- rbind(x, x[1, ])
  x$start[5] <- "11-01"
  x$end[5] <- "11-15"
  expect_equal(nrow(knw_timing_read(write_fixture(x), wsg_code = "MORR", species_code = "CH")), 2)
})

test_that("a window split at 1 January is refused", {
  x <- timing_fixture()
  x <- rbind(x, x[2, ])
  x$end[2] <- "12-31"
  x$start[5] <- "01-01"
  expect_error(knw_timing_read(write_fixture(x)), "split at 1 January for MORR BT incubation")
})

test_that("start equal to end is refused", {
  x <- timing_fixture()
  x$end[1] <- "09-01"
  expect_error(knw_timing_read(write_fixture(x)), "start equals end")
})

test_that("a requested code absent from the table warns", {
  expect_warning(out <- knw_timing_read(write_fixture(), wsg_code = "MOR"), "wsg_code not in.*MOR")
  expect_equal(nrow(out), 0)
})

test_that("a byte-order mark does not mangle the first column name", {
  p <- write_fixture()
  writeBin(c(as.raw(c(0xef, 0xbb, 0xbf)), readBin(p, "raw", file.size(p))), p)
  expect_equal(nrow(knw_timing_read(p)), 4)
})

test_that("one row covering the whole year is not read as a split window", {
  x <- timing_fixture()
  x$start[2] <- "01-01"
  x$end[2] <- "12-31"
  expect_equal(knw_timing_read(write_fixture(x), species_code = "BT")$end, "12-31")
})

test_that("a row with no group or species is refused", {
  x <- timing_fixture()
  x$wsg_code[3] <- NA
  expect_error(knw_timing_read(write_fixture(x)), "no wsg_code or species_code")
  x <- timing_fixture()
  x$species_code[3] <- ""
  expect_error(knw_timing_read(write_fixture(x)), "no wsg_code or species_code")
})

test_that("a split window is refused when one half is open", {
  x <- timing_fixture()
  x <- rbind(x, x[2, ])
  x$end[2] <- "12-31"
  x$start[5] <- "01-01"
  x$end[5] <- NA
  expect_error(knw_timing_read(write_fixture(x)), "split at 1 January for MORR BT incubation")
  x$start[2] <- NA
  x$end[5] <- "03-01"
  expect_error(knw_timing_read(write_fixture(x)), "split at 1 January for MORR BT incubation")
})

test_that("a whitespace-only code counts as blank", {
  x <- timing_fixture()
  x$species_code[3] <- " "
  expect_error(knw_timing_read(write_fixture(x)), "no wsg_code or species_code")
})

test_that("a half window's known day counts toward overlap", {
  x <- timing_fixture()
  x <- rbind(x, x[4, ])
  expect_error(knw_timing_read(write_fixture(x)), "overlapping windows for BULK CO migration")
  x <- timing_fixture()
  x <- rbind(x, x[1, ])
  x$start[5] <- NA
  x$end[5] <- "09-10"
  expect_error(knw_timing_read(write_fixture(x)), "overlapping windows for MORR CH spawning")
})

test_that("a whole-year row beside a half window is an overlap, not a split", {
  x <- timing_fixture()
  x <- rbind(x, x[2, ])
  x$start[2] <- "01-01"
  x$end[2] <- "12-31"
  x$start[5] <- NA
  x$end[5] <- "12-31"
  expect_error(knw_timing_read(write_fixture(x)), "overlapping windows for MORR BT incubation")
})

test_that("an empty filter is refused rather than read as no data", {
  expect_error(knw_timing_read(write_fixture(), wsg_code = character(0)), "empty filter")
  expect_error(knw_timing_read(write_fixture(), species_code = character(0)), "empty filter")
})

test_that("a no-break space counts as blank", {
  x <- timing_fixture()
  x$species_code[3] <- " "
  p <- tempfile(fileext = ".csv")
  utils::write.csv(x, p, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  expect_error(knw_timing_read(p), "no wsg_code or species_code")
})

test_that("a file that is not UTF-8 is refused, not read as a truncated table", {
  p <- write_fixture()
  lines <- readLines(p)
  lines[3] <- sub("key_b", "key_b \xb0", lines[3], useBytes = TRUE)
  writeLines(lines, p, useBytes = TRUE)
  expect_error(knw_timing_read(p), "not valid UTF-8")
})
