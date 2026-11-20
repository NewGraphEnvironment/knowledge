fx <- function(name) {
  f <- system.file("testdata", "fiss", name, package = "knowledge")
  if (!nzchar(f)) stop("fixture ", name, " is not installed")
  f
}
steps <- c("step1_ref_loc", "step2_fish_coll", "step3_indiv_fish", "step4_site_data")

test_that("knw_fiss_columns() carries the pre-2012 edition's names and a pattern per step", {
  cols <- knw_fiss_columns()
  expect_identical(names(cols), c("wanted", "variants", "step_pattern"))
  expect_identical(names(cols$step_pattern), steps)
  expect_identical(names(cols$wanted), c("keys", steps))
  expect_identical(unname(cols$variants[c("species_code", "method", "haul_or_pass", "date_yyyy_mm_day")]),
                   c("species", "sampling_method", "haul_pass", "survey_date"))
  expect_true("average_gradient_percent" %in% cols$wanted$step4_site_data)
})

test_that("knw_fiss_match_sheet() finds each edition's sheet names and refuses an unknown step", {
  v2 <- readxl::excel_sheets(fx("template_v2.xls"))
  expect_identical(vapply(steps, function(s) knw_fiss_match_sheet(v2, s), ""),
                   c(step1_ref_loc = "Step 1 (Ref. and Loc. Info)", step2_fish_coll = "Step 2 (Fish Coll. Data)",
                     step3_indiv_fish = "Step 3 (Individual Fish Data)",
                     step4_site_data = "Step 4 (Stream Site Data)"))
  expect_identical(knw_fiss_match_sheet(c("Step 1 (Locational Info)", "Step 4 (Site Card Data)"), "step1_ref_loc"),
                   "Step 1 (Locational Info)")
  expect_identical(knw_fiss_match_sheet(c("Reference", "Fish collection"), "step2_fish_coll"), "Fish collection")
  expect_identical(knw_fiss_match_sheet(c("Reference", "Fish collection"), "step1_ref_loc"), NA_character_)
  expect_identical(knw_fiss_match_sheet("Tissue", "step4_site_data"), NA_character_)
  expect_error(knw_fiss_match_sheet("Tissue", "step5"))
})

test_that("knw_fiss_utm_zone() keeps the leading digits of a zone entered with its band", {
  expect_identical(knw_fiss_utm_zone(c("10", "11U", "10 U", "zone 11", "", NA, "U")),
                   c(10, 11, 10, 11, NA, NA, NA))
  expect_identical(knw_fiss_utm_zone(c(9, 10)), c(9, 10))
})

test_that("knw_fiss_read_step() finds the header row of each layout and reads the banner", {
  v2 <- fx("template_v2.xls")
  hdr <- vapply(c("Step 1 (Ref. and Loc. Info)", "Step 2 (Fish Coll. Data)", "Step 3 (Individual Fish Data)",
                  "Step 4 (Stream Site Data)"), function(s) knw_fiss_read_step(v2, s)$header_row, 1L)
  expect_identical(unname(hdr), c(31L, 23L, 18L, 20L))
  s1 <- knw_fiss_read_step(v2, "Step 1 (Ref. and Loc. Info)")
  expect_identical(s1$banner, "Fish Data Submission Spreadsheet Template -V 2.0, April 27, 2012")
  expect_identical(knw_fiss_read_step(v2, "Step 2 (Fish Coll. Data)")$banner,
                   "Fish  Data Submission Spreadsheet Template V. 2.0, April 27, 2012")
  # five rows under the header, two of them the template's blank entry rows
  expect_identical(s1$rows_raw, 5L)
  expect_identical(nrow(s1$data), 5L)
  old <- knw_fiss_read_step(fx("pre2012_step_banner.xls"), "Step 1 (Ref. and Loc. Info)")
  expect_identical(old$header_row, 26L)
  expect_identical(old$banner, "Step 1  Reference and Locational Information")
  expect_identical(knw_fiss_read_step(fx("pre2012_header17.xlsx"), "Step 1 (Locational Info)")$header_row, 17L)
  expect_identical(knw_fiss_read_step(fx("individual_fish.xls"), "Fish collection")$header_row, 4L)
})

test_that("knw_fiss_read_step() renames an edition's variant only when the canonical name is absent", {
  old <- knw_fiss_read_step(fx("pre2012_step_banner.xls"), "Step 2 (Fish Coll. Data)")$data
  expect_true(all(c("species", "sampling_method", "haul_pass") %in% names(old)))
  expect_false(any(c("species_code", "haul_or_pass") %in% names(old)))
  expect_identical(old$species, c("NFC", "NFC", "RB", "RB"))
  # Step 2 here names both `Species` and `Species Code`: both survive, each under its own name
  both <- knw_fiss_read_step(fx("pre2012_header17.xlsx"), "Step 2 (Fish Coll. Data)")$data
  expect_identical(sum(names(both) == "species"), 1L)
  expect_identical(both$species, "Bull Trout")
  expect_identical(both$species_code, "BT")
  s1 <- knw_fiss_read_step(fx("pre2012_step_banner.xls"), "Step 1 (Ref. and Loc. Info)")$data
  expect_identical(s1$survey_date, c("2008/07/21", "2008/07/22", "2008/07/22"))
})

test_that("knw_fiss_select() drops the template's key-only rows and fills missing columns", {
  df <- data.frame(reference_number = c("1", "2", "3"), gazetted_name = "Test Creek",
                   utm_zone = c("10", NA, ""), utm_easting = c("612000", NA, "NA"), extra = "x",
                   site_comments = c(NA, NA, "dry"))
  out <- knw_fiss_select(df, "step1_ref_loc")
  # row 2 carries only keys; row 3 only a comment, which counts as a filled cell
  expect_identical(out$reference_number, c("1", "3"))
  expect_false("extra" %in% names(out))
  expect_true(all(c("survey_date", "utm_northing", "site_comments") %in% names(out)))
  expect_true(all(is.na(out$utm_northing)))
})

test_that("knw_fiss_parse_step() names why each step of each layout yields what it does", {
  f <- c("template_v2.xls", "pre2012_step_banner.xls", "pre2012_header17.xlsx", "individual_fish.xls",
         "tissue.xls")
  got <- do.call(rbind, lapply(f, function(w) do.call(rbind, lapply(steps, function(s) {
    lg <- knw_fiss_parse_step(fx(w), "77", s)$log
    data.frame(file = w, step = s, status = lg$status, header_row = lg$header_row, kept = lg$rows_after_filter)
  }))))
  want <- data.frame(
    file = rep(f, each = 4), step = rep(steps, 5),
    status = c("ok", "ok", "ok", "ok",
               "ok", "ok", "ok", "no_rows",
               "ok", "ok", "no_header", "empty_sheet",
               "no_sheet_match", "fish_layout", "ok", "no_sheet_match",
               rep("no_sheet_match", 4)),
    header_row = c(31L, 23L, 18L, 20L, 26L, 6L, 6L, 6L, 17L, 6L, NA, NA, NA, 4L, 4L, NA, rep(NA_integer_, 4)),
    kept = c(3L, 4L, 2L, 2L, 3L, 4L, 2L, 0L, 1L, 1L, 0L, 0L, 0L, 0L, 3L, 0L, rep(0L, 4)))
  expect_identical(got, want)
})

test_that("knw_fiss_parse_step() keys rows by report and reference number and reads per-fish sheets as Step 3", {
  s2 <- knw_fiss_parse_step(fx("template_v2.xls"), "17491", "step2_fish_coll")
  expect_identical(names(s2$data)[1:2], c("report_id", "site_key"))
  expect_identical(s2$data$site_key, c("17491:1", "17491:1", "17491:2", "17491:3"))
  expect_identical(s2$data$species, c("Rainbow Trout", "Rainbow Trout", "No Fish Caught", "Rainbow Trout"))
  expect_identical(s2$log$n_sheet_hits, 1L)
  s3 <- knw_fiss_parse_step(fx("individual_fish.xls"), "16389", "step3_indiv_fish")
  expect_identical(s3$log$sheet_matched, "Fish collection")
  expect_identical(s3$data$site_key, c("16389:1", "16389:1", "16389:2"))
  expect_identical(s3$data$species, c("RB", "RB", "BT"))
  expect_identical(as.numeric(s3$data$length_mm), c(95, 120, 180))
  s4 <- knw_fiss_parse_step(fx("template_v2.xls"), "17491", "step4_site_data")
  # the template's percent-formatted cell stores 2.5 % as 0.025
  expect_equal(as.numeric(s4$data$average_gradient_percent), c(0.025, 0.08))
})

test_that("knw_fiss_parse_step() reports an unreadable workbook as sheets_error", {
  f <- withr::local_tempfile(fileext = ".xls")
  writeLines("not a workbook", f)
  lg <- knw_fiss_parse_step(f, "1", "step1_ref_loc")$log
  expect_identical(lg$status, "sheets_error")
  expect_null(knw_fiss_parse_step(f, "1", "step1_ref_loc")$data)
})

test_that("knw_fiss_parse_step() reaches no_rows by either filter", {
  # rows with every cell but REFERENCE NUMBER: the reference-number filter keeps none
  lg <- knw_fiss_parse_step(fx("no_reference.xlsx"), "1", "step1_ref_loc")$log
  expect_identical(c(lg$status, lg$rows_raw, lg$rows_after_filter), c("no_rows", "2", "0"))
  # rows with only keys: the reference number survives, the payload filter keeps none
  lg <- knw_fiss_parse_step(fx("pre2012_step_banner.xls"), "1", "step4_site_data")$log
  expect_identical(c(lg$status, lg$rows_raw, lg$rows_after_filter), c("no_rows", "3", "0"))
})

test_that("cols reads a column the default does not, and is checked", {
  cols <- knw_fiss_columns()$wanted
  cols$step1_ref_loc <- c(cols$step1_ref_loc, "utm_method")
  s1 <- knw_fiss_parse_step(fx("template_v2.xls"), "1", "step1_ref_loc", cols = cols)$data
  expect_true("utm_method" %in% names(s1))
  expect_false("utm_method" %in% names(knw_fiss_parse_step(fx("template_v2.xls"), "1", "step1_ref_loc")$data))
  expect_error(knw_fiss_select(s1, "step1_ref_loc", cols = list(keys = "gazetted_name", step1_ref_loc = "x")),
               "reference_number")
  expect_error(knw_fiss_select(s1, "step1_ref_loc", cols = list(keys = "reference_number")), "step1_ref_loc")
})

test_that("janitor turns each layout's labels into the names the column list reads", {
  nm <- function(file, sheet) names(knw_fiss_read_step(fx(file), sheet)$data)
  s4 <- nm("template_v2.xls", "Step 4 (Stream Site Data)")
  expect_true(all(c("average_gradient_percent", "avg_channel_width_m", "channel_width_m_7", "wetted_width_m_2",
                    "temperature_c", "conductivity_m_s_cm", "utm_zone") %in% s4))
  s2 <- nm("template_v2.xls", "Step 2 (Fish Coll. Data)")
  # the V2.0 template has no plain `Width (m)`; the pre-2012 edition does (below)
  expect_identical(setdiff(knw_fiss_columns()$wanted$step2_fish_coll, s2), "width_m")
  s1 <- nm("template_v2.xls", "Step 1 (Ref. and Loc. Info)")
  expect_true(all(c(knw_fiss_columns()$wanted$keys, knw_fiss_columns()$wanted$step1_ref_loc) %in% s1))
  old <- nm("pre2012_step_banner.xls", "Step 2 (Fish Coll. Data)")
  expect_true(all(c("sampling_method", "haul_pass", "species", "total_number", "soak_time", "length_m",
                    "width_m") %in% old))
})

test_that("a number under a text label reads to 17 digits from .xls and to as.numeric() exactly", {
  # libxls renders a double in a text column at full precision; numeric asserts go through as.numeric()
  s4 <- knw_fiss_read_step(fx("template_v2.xls"), "Step 4 (Stream Site Data)")$data
  expect_identical(s4$average_gradient_percent[1], "0.025000000000000001")
  expect_identical(as.numeric(s4$average_gradient_percent[1]), 0.025)
})
