# data-raw/fiss_fixtures.R
# ---------------------------------------------------------------------------
# Small Fish Data Submission workbooks for the knw_fiss_* tests and examples (#7), written to inst/testdata/fiss/.
#
# One workbook per layout measured over the five groups' parse logs (planning/archive/ for #176, findings):
#   template_v2.xls          the V2.0 template, every banner from 2012 to 2022: Step 1/2/3/4 headers at rows
#                            31/23/18/20; Step 4's gradient cells are percent-formatted, as the template's are
#   pre2012_step_banner.xls  the pre-2012 edition, row 1 the step name: Step 1 at row 26, the others at row 6;
#                            `Species Code`, `Haul or Pass`, `Date (yyyy/mm/day)`; Step 4 holds only the
#                            template's blank entry rows (no_rows)
#   pre2012_header17.xlsx    the pre-2012 layout two LNTH workbooks use: Step 1 "(Locational Info)" at row 17;
#                            Step 2 names both `Species` and `Species Code`; Step 3 has no REFERENCE NUMBER label
#                            (no_header); Step 4 is empty (empty_sheet). Left as .xlsx, the form 0210 converts
#                            encrypted workbooks to
#   individual_fish.xls      a per-fish workbook: "Reference" and "Fish collection" (header row 4), which Step 2
#                            sets aside (fish_layout) and Step 3 reads
#   no_reference.xlsx        a V2.0 Step 1 whose rows fill every cell but REFERENCE NUMBER (no_rows by the
#                            reference-number filter, where pre2012_step_banner's Step 4 is no_rows by the key-only one)
#   tissue.xls               a tissue-results workbook: no sheet matches any step
#
# What is copied from the provincial template is only what the parser keys on: the column labels and the edition
# banner line. Its instructions, pick lists and formatting are not copied, and every value is made up. The
# template's download page carries no licence and the province's copyright page reserves all rights (#76).
#
# RUN: Rscript data-raw/fiss_fixtures.R   (repo root; needs openxlsx and LibreOffice's soffice on the PATH)
# ---------------------------------------------------------------------------
stopifnot("run from the repo root" = file.exists("DESCRIPTION"))
stopifnot("openxlsx is needed" = requireNamespace("openxlsx", quietly = TRUE))
soffice <- Sys.which("soffice")
stopifnot("LibreOffice's soffice is not on the PATH" = nzchar(soffice))
out_dir <- file.path("inst", "testdata", "fiss")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
work <- tempfile("fiss_fixtures_")
dir.create(work)

banner_v2   <- "Fish Data Submission Spreadsheet Template -V 2.0, April 27, 2012"
banner_v2_2 <- "Fish  Data Submission Spreadsheet Template V. 2.0, April 27, 2012"   # Step 2's spelling

# A workbook names its author: openxlsx writes the login (USER) unless told otherwise, and LibreOffice carries it into
# the converted .xls. These files are tracked and ship with the package, so the author is fixed (#176 code-check).
new_workbook <- function() openxlsx::createWorkbook(creator = "knowledge")

# one row of cells from `col` on; NULL leaves the row empty
put <- function(wb, sheet, row, values, col = 1L) {
  if (is.null(values)) return(invisible())
  df <- as.data.frame(as.list(values), stringsAsFactors = FALSE, optional = TRUE)
  openxlsx::writeData(wb, sheet, df, startRow = row, startCol = col, colNames = FALSE)
}

# a step sheet: banner in row 1, the step title in row 3, labels at `header`, then `rows` (a list of named
# lists, matched to the labels by position name `c<i>`)
step_sheet <- function(wb, sheet, banner, title, header, labels, rows = list()) {
  openxlsx::addWorksheet(wb, sheet)
  put(wb, sheet, 1, banner)
  if (!is.null(title) && header > 3) put(wb, sheet, 3, title)
  put(wb, sheet, header, labels)
  for (i in seq_along(rows)) {
    r <- rows[[i]]
    for (nm in names(r)) {
      j <- match(nm, labels)
      if (is.na(j)) stop("no label ", nm, " on ", sheet)
      openxlsx::writeData(wb, sheet, r[[nm]], startRow = header + i, startCol = j, colNames = FALSE)
    }
  }
  invisible(header + length(rows))
}

save_as <- function(wb, name) {
  ext <- tools::file_ext(name)
  xlsx <- file.path(work, paste0(tools::file_path_sans_ext(name), ".xlsx"))
  openxlsx::saveWorkbook(wb, xlsx, overwrite = TRUE)
  if (ext == "xlsx") {
    file.copy(xlsx, file.path(out_dir, name), overwrite = TRUE)
  } else {
    # a fresh profile: LibreOffice adds no author of its own, and a running instance's lock is not met
    profile <- paste0("-env:UserInstallation=file://", file.path(work, "lo_profile"))
    st <- system2(soffice, c(profile, "--headless", "--convert-to", "xls", "--outdir", shQuote(work), shQuote(xlsx)),
                  stdout = TRUE, stderr = TRUE)
    got <- file.path(work, name)
    if (!file.exists(got)) stop("soffice did not write ", name, ":\n", paste(st, collapse = "\n"))
    file.copy(got, file.path(out_dir, name), overwrite = TRUE)
  }
  message("wrote ", file.path(out_dir, name))
}

# ---- the V2.0 template ------------------------------------------------------------------------------------------
lab_v2_s1 <- c("REFERENCE NUMBER", "Gazetted Name", "Alias (Local Name)", "Waterbody Type",
               "Waterbody (ID) Identifier", "Watershed Code (45 Digit)", "TWC#", "Reach #", "Site #", "Survey Date",
               "UTM Method", "UTM Zone", "UTM Easting", "UTM Northing", "No Visible Channel",
               "Dewatered-Dry/Int Channel")
lab_v2_s2 <- c("REFERENCE NUMBER", "Gazetted Name", "Local Name", "Waterbody ID", "Reach #", "Site #",
               "Temperature (˚C)", "Conductivity (µS/cm)", "Turbidity", "Sampling Method", "Method Number",
               "Haul # /Pass #", "EF Seconds", "EF Length (m)", "EF Width (m)", "Enclosure", "Voltage", "Frequency",
               "Pulse", "Make", "Model", "Gill Net type", "Length (m)", "Depth (m)", "Mesh Size", "Set", "Date In",
               "Time In", "Date Out", "Time Out", "Soak Time", "Habitat", "Species", "Stage", "Age", "Total Number",
               "Min. Length (mm)", "Max. Length (mm)", "Fish Activity", "Comments")
lab_v2_s3 <- c("REFERENCE NUMBER", "Gazetted Names", "Local Name", "Waterbody ID", "Reach #", "Site #",
               "Sampling Method", "Method Number", "Haul#/Pass#", "Species", "Length (mm)", "Weight (g)", "Sex",
               "Maturity", "Age Structure", "Age Sample #", "Age", "Genetic Structure", "Genetic Sample #",
               "Comments")
lab_v2_s4 <- c("REFERENCE NUMBER", "Gazetted Names", "Local Name", "Waterbody ID", "Reach #", "Site #",
               rep("Channel Width (m)", 7), "Avg. Channel Width (m)", rep("Wetted Width (m)", 7),
               "Avg. Wetted Width (m)", "Gradient  #1 (%)", "Gradient  #2 (%)", "Gradient", "Gradient  #4 (%)",
               "Average Gradient (%)", "Temperature (˚C)", "Conductivity (µS/cm)", "UTM Zone",
               "UTM Easting", "UTM Northing", "Comments")
keys <- function(ref, name = "Test Creek") list("REFERENCE NUMBER" = ref, "Gazetted Name" = name)
keys_s <- function(ref, name = "Test Creek") list("REFERENCE NUMBER" = ref, "Gazetted Names" = name)

wb <- new_workbook()
openxlsx::addWorksheet(wb, "INSTRUCTIONS")
put(wb, "INSTRUCTIONS", 1, "Synthetic test workbook in the V2.0 template's layout; every value is made up.")
step_sheet(wb, "Step 1 (Ref. and Loc. Info)", banner_v2, "Step 1  Referencing and Locational Information", 31,
           lab_v2_s1, list(
             c(keys(1), list("Reach #" = 1, "Site #" = 1, "Survey Date" = "2019-08-14", "UTM Zone" = 10,
                             "UTM Easting" = 612000, "UTM Northing" = 5980000)),
             c(keys(2), list("Reach #" = 1, "Site #" = 2, "Survey Date" = "2019-08-14", "UTM Zone" = "11U",
                             "UTM Easting" = 312000, "UTM Northing" = 5700000)),
             c(keys(3), list("Reach #" = 2, "Site #" = 1, "Survey Date" = "2019-08-15", "UTM Zone" = 10,
                             "UTM Easting" = 613500, "UTM Northing" = 5981200)),
             # the template's blank entry rows: a reference number and nothing else
             list("REFERENCE NUMBER" = 4), list("REFERENCE NUMBER" = 5)))
step_sheet(wb, "Step 2 (Fish Coll. Data)", banner_v2_2, "Step 2  Fisheries Collection Form Data", 23, lab_v2_s2,
           list(
             c(keys(1), list("Sampling Method" = "EF", "Method Number" = 1, "Haul # /Pass #" = 1,
                             "EF Seconds" = 300, "EF Length (m)" = 50, "EF Width (m)" = 3,
                             "Species" = "Rainbow Trout", "Stage" = "Fry", "Total Number" = 4,
                             "Min. Length (mm)" = 40, "Max. Length (mm)" = 62)),
             c(keys(1), list("Sampling Method" = "EF", "Method Number" = 1, "Haul # /Pass #" = 2,
                             "EF Seconds" = 250, "Species" = "Rainbow Trout", "Total Number" = 2)),
             c(keys(2), list("Sampling Method" = "EF", "Method Number" = 1, "Haul # /Pass #" = 1,
                             "EF Seconds" = 450, "Species" = "No Fish Caught", "Comments" = "fished 120 m")),
             # an explicit zero count with effort: no fish, derived
             c(keys(3), list("Sampling Method" = "EF", "Method Number" = 1, "Haul # /Pass #" = 1,
                             "EF Seconds" = 600, "Species" = "Rainbow Trout", "Total Number" = 0)),
             keys(4), keys(5)))
step_sheet(wb, "Step 3 (Individual Fish Data)", banner_v2, "Step 3  Individual Fish Data", 18, lab_v2_s3, list(
  c(keys_s(1), list("Sampling Method" = "EF", "Method Number" = 1, "Haul#/Pass#" = 1, "Species" = "Rainbow Trout",
                    "Length (mm)" = 45, "Weight (g)" = 1.1)),
  c(keys_s(1), list("Sampling Method" = "EF", "Method Number" = 1, "Haul#/Pass#" = 1, "Species" = "Rainbow Trout",
                    "Length (mm)" = 62, "Weight (g)" = 2.9)),
  keys_s(4)))
s4 <- "Step 4 (Stream Site Data)"
step_sheet(wb, s4, banner_v2, "Step 4  Site Collection Form Data", 20, lab_v2_s4, list(
  c(keys_s(1), list("Avg. Channel Width (m)" = 3.4, "Avg. Wetted Width (m)" = 2.6, "Average Gradient (%)" = 0.025,
                    "UTM Zone" = 10, "UTM Easting" = 612050, "UTM Northing" = 5980020)),
  c(keys_s(3), list("Average Gradient (%)" = 0.08)),
  keys_s(4)))
openxlsx::addStyle(wb, s4, openxlsx::createStyle(numFmt = "0.0%"), rows = 21:23,
                   cols = match("Average Gradient (%)", lab_v2_s4))
openxlsx::addWorksheet(wb, "Species by Common Name")
put(wb, "Species by Common Name", 1, c("Common Name", "Code"))
save_as(wb, "template_v2.xls")

# ---- the pre-2012 edition, row 1 the step name ------------------------------------------------------------------
lab_old_s1 <- c("REFERENCE NUMBER", "Gazetted Name", "Local Name", "Watershed Code (45 Digits)", "ILP",
                "ILP Mapsheet", "Reach #", "Site #", "Date (yyyy/mm/day)", "UTM Method", "UTM Zone", "UTM Easting",
                "UTM Northing")
lab_old_s2 <- c("REFERENCE NUMBER", "Gazetted Name", "Local Name", "Reach #", "Site #", "Sampling Method",
                "Method Number", "Temperature (˚C)", "Conductivity (µS/cm)", "Turbidity", "Haul or Pass",
                "EF Seconds", "Length (m)", "Width (m)", "Enclosure", "Voltage", "Frequency", "Pulse", "Make",
                "Model", "Net type", "Length (m)", "Depth (m)", "Mesh Size", "Set", "Soak Time", "Habitat",
                "Species Code", "Stage", "Age", "Total Number", "Min. Length (mm)", "Max. Length (mm)",
                "Fish Activity", "Comments")
lab_old_s3 <- c("REFERENCE NUMBER", "Gazetted Names", "Local Name", "Reach #", "Site #", "Method", "Method Number",
                "Haul or Pass", "Species Code", "Length (mm)", "Weight (g)", "Sex", "Maturity", "Age Structure",
                "Age Sample #", "Age", "Genetic Structure", "Genetic Sample #", "Comments")
lab_old_s4 <- c("REFERENCE NUMBER", "Gazetted Names", "Local Name", "Reach #", "Site #", "Avg. Channel Width (m)",
                "Avg. Wetted Width (m)", "Average Gradient (%)", "UTM Zone", "UTM Easting", "UTM Northing",
                "Comments")

wb <- new_workbook()
openxlsx::addWorksheet(wb, "INSTRUCTIONS")
put(wb, "INSTRUCTIONS", 1, "Synthetic test workbook in the pre-2012 edition's layout; every value is made up.")
step_sheet(wb, "Step 1 (Ref. and Loc. Info)", "Step 1  Reference and Locational Information", NULL, 26,
           lab_old_s1, list(
             c(keys(1, "Old Creek"), list("Date (yyyy/mm/day)" = "2008/07/21", "UTM Zone" = "10 U",
                                          "UTM Easting" = 650100, "UTM Northing" = 6010300)),
             c(keys(2, "Old Creek"), list("Date (yyyy/mm/day)" = "2008/07/22", "UTM Zone" = 10,
                                          "UTM Easting" = 651800, "UTM Northing" = 6011900)),
             c(keys(3, "Old Creek"), list("Date (yyyy/mm/day)" = "2008/07/22", "UTM Zone" = 10,
                                          "UTM Easting" = 652400, "UTM Northing" = 6012600))))
step_sheet(wb, "Step 2 (Fish Coll. Data)", "Step 2  Fisheries Collection Form Data", NULL, 6, lab_old_s2, list(
  c(keys(1, "Old Creek"), list("Sampling Method" = "EF", "Method Number" = 1, "Haul or Pass" = 1,
                               "EF Seconds" = 300, "Species Code" = "NFC")),
  # an empty trap beside a full one: not a no-fish site
  c(keys(2, "Old Creek"), list("Sampling Method" = "MT", "Method Number" = 1, "Haul or Pass" = 1,
                               "Soak Time" = 24, "Species Code" = "NFC")),
  c(keys(2, "Old Creek"), list("Sampling Method" = "MT", "Method Number" = 1, "Haul or Pass" = 2,
                               "Soak Time" = 24, "Species Code" = "RB", "Total Number" = 3)),
  # a species named with no count: caught, number unknown
  c(keys(3, "Old Creek"), list("Sampling Method" = "EF", "Method Number" = 1, "Haul or Pass" = 1,
                               "EF Seconds" = 200, "Species Code" = "RB"))))
step_sheet(wb, "Step 3 (Individual Fish Data)", "Step 3  Individual Fish Data", NULL, 6, lab_old_s3, list(
  c(keys_s(2, "Old Creek"), list("Method" = "MT", "Method Number" = 1, "Haul or Pass" = 2, "Species Code" = "RB",
                                 "Length (mm)" = 88)),
  c(keys_s(2, "Old Creek"), list("Method" = "MT", "Method Number" = 1, "Haul or Pass" = 2, "Species Code" = "RB",
                                 "Length (mm)" = 102))))
step_sheet(wb, "Step 4 (Site Card Data)", "Step 4  Site Collection Form Data", NULL, 6, lab_old_s4, list(
  keys_s(1, "Old Creek"), keys_s(2, "Old Creek"), keys_s(3, "Old Creek")))
save_as(wb, "pre2012_step_banner.xls")

# ---- the pre-2012 layout with Step 1 at row 17 ------------------------------------------------------------------
lab_17_s1 <- c("REFERENCE NUMBER", "Gazetted Name", "Local Name", "Watershed Code (45 Digits)", "ILP", "ILP Mapsheet",
               "Reach #", "Site #", "Date (yyyy/mm/day)", "UTM Zone", "UTM Easting", "UTM Northing")
lab_17_s2 <- c("REFERENCE NUMBER", "Gazetted Name", "Local Name", "Reach #", "Site #", "Method", "Method Number",
               "Haul or Pass", "EF Seconds", "Length (m)", "Width (m)", "Species", "Species Code", "Stage",
               "Total Number", "Comments")
lab_17_s3 <- c("Ref. No.", "Gazetted Names", "Local Name", "Species Code", "Length (mm)", "Comments")

wb <- new_workbook()
step_sheet(wb, "Step 1 (Locational Info)", "Step 1  Locational and Reference Information", NULL, 17, lab_17_s1, list(
  c(keys(7, "North Creek"), list("Date (yyyy/mm/day)" = "2005/09/03", "UTM Zone" = 11, "UTM Easting" = 300400,
                                 "UTM Northing" = 5690800))))
# both `Species` and `Species Code`: the code is not renamed onto the name, so the step keeps one `species`
step_sheet(wb, "Step 2 (Fish Coll. Data)", "Step 2  Fisheries Collection Form Data", NULL, 6, lab_17_s2, list(
  c(keys(7, "North Creek"), list("Method" = "EF", "Method Number" = 1, "Haul or Pass" = 1, "EF Seconds" = 410,
                                 "Length (m)" = 80, "Width (m)" = 4, "Species" = "Bull Trout",
                                 "Species Code" = "BT", "Total Number" = 1))))
step_sheet(wb, "Step 3 (Individual Fish Data)", "Step 3  Individual Fish Data", NULL, 6, lab_17_s3, list(
  list("Ref. No." = 7, "Species Code" = "BT", "Length (mm)" = 140)))
openxlsx::addWorksheet(wb, "Step 4 (Site Card Data)")
save_as(wb, "pre2012_header17.xlsx")

# ---- a per-fish workbook ----------------------------------------------------------------------------------------
lab_ref <- c("Reference Number", "Gazetted Name", "Local Name", "Watershed Code (45 Digits)", "Reach #", "Site #",
             "Date (yyyy/mm/day)", "UTM Zone", "UTM Easting", "UTM Northing", "Sampling Method", "EF Seconds",
             "Species Code", "Total Number")
lab_fish <- c("REFERENCE NUMBER", "Species Code", "Length (mm)", "Weight (g)", "Sex", "Maturity", "Age Structure",
              "Age Sample #", "Age", "Genetic Structure", "Genetic Sample #", "Comments")
wb <- new_workbook()
step_sheet(wb, "Reference", "Reference Information Section", NULL, 22, lab_ref, list(
  list("Reference Number" = 1, "Gazetted Name" = "Fish Creek", "Date (yyyy/mm/day)" = "2004/08/10",
       "UTM Zone" = 11, "UTM Easting" = 290100, "UTM Northing" = 5720400, "Sampling Method" = "EF",
       "EF Seconds" = 520, "Species Code" = "RB", "Total Number" = 2)))
step_sheet(wb, "Fish collection", "Individual Fish Data", "Fish Measurement Data", 4, lab_fish, list(
  list("REFERENCE NUMBER" = 1, "Species Code" = "RB", "Length (mm)" = 95, "Weight (g)" = 9.5),
  list("REFERENCE NUMBER" = 1, "Species Code" = "RB", "Length (mm)" = 120, "Weight (g)" = 18.2),
  list("REFERENCE NUMBER" = 2, "Species Code" = "BT", "Length (mm)" = 180)))
openxlsx::addWorksheet(wb, "Sheet3")
save_as(wb, "individual_fish.xls")

# ---- a step whose rows carry no reference number ----------------------------------------------------------------
# filled cells under the header but none in REFERENCE NUMBER: the reference-number filter keeps nothing (no_rows)
wb <- new_workbook()
step_sheet(wb, "Step 1 (Ref. and Loc. Info)", banner_v2, "Step 1  Referencing and Locational Information", 31,
           lab_v2_s1, list(
             list("Gazetted Name" = "Test Creek", "UTM Zone" = 10, "UTM Easting" = 612000, "UTM Northing" = 5980000),
             list("Gazetted Name" = "Test Creek", "Survey Date" = "2019-08-14")))
save_as(wb, "no_reference.xlsx")

# ---- a tissue-results workbook ----------------------------------------------------------------------------------
wb <- new_workbook()
openxlsx::addWorksheet(wb, "Tissue")
put(wb, "Tissue", 1, c("Sample ID", "Species", "Tissue", "Hg (mg/kg)"))
put(wb, "Tissue", 2, list("T-01", "Rainbow Trout", "muscle", 0.04))
save_as(wb, "tissue.xls")

unlink(work, recursive = TRUE)
