# the receipt declarations knowledge ships (#154, #160)

outputs <- c("grade", "evidence", "thresholds", "habitat_grade", "fdis")

test_that("every declaration parses and names its own output", {
  files <- list.files(system.file("receipt", package = "knowledge"), "\\.yaml$")
  expect_setequal(sub("\\.yaml$", "", files), outputs)
  for (f in sub("\\.yaml$", "", files)) {
    k <- knw_receipt_keys(f)
    expect_s3_class(k, "crt_receipt_keys")
    expect_identical(k$output, f, info = f)
  }
  expect_error(knw_receipt_keys("nope"), "no receipt declaration for nope")
})

test_that("every declared config file is one the package installs", {
  for (f in outputs) {
    k <- knw_receipt_keys(f)
    for (cf in k$config_files) {
      expect_true(startsWith(cf, "inst/"), info = cf)
      expect_true(nzchar(system.file(sub("^inst/", "", cf), package = "knowledge")), info = cf)
    }
  }
})

test_that("the commit state is a full sha and a flag", {
  # the source tree, two levels above this file; under R CMD check the tests run from an installed copy with no .git
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
  skip_if_not(file.exists(file.path(root, ".git")), "not a checkout")
  s <- .knw_git_state(root)
  expect_match(s$commit, "^[0-9a-f]{40}$")
  expect_type(s$dirty, "logical")
  expect_error(.knw_git_state(withr::local_tempdir()), "not a git checkout")
  expect_error(.knw_receipt_code(list(commit = "a")), "names commit and dirty")
})

# A receipt built from a declaration alone: every declared input, setting, config file, table and summary, with the
# values given (summary values, and each table's tolerance columns) and one part, `out.csv`, holding `part`
receipt_from <- function(output, dir, summary = list(), table_value = 1.5, part = "a") {
  k <- knw_receipt_keys(output)
  writeLines(part, file.path(dir, "out.csv"))
  cfg <- stats::setNames(vapply(k$config_files, function(f) system.file(sub("^inst/", "", f), package = "knowledge"),
                                character(1)), k$config_files)
  tables <- lapply(stats::setNames(k$tables, k$tables), function(tb) {
    cols <- names(k$tolerance$tables[[tb]])
    x <- data.frame(id = "a")
    for (cl in cols) x[[cl]] <- table_value
    x
  })
  sm <- stats::setNames(lapply(k$summary, function(nm) if (nm %in% names(summary)) summary[[nm]] else 100), k$summary)
  settings <- stats::setNames(as.list(rep("s", length(k$settings))), k$settings)
  recipe <- list(code = list(knowledge = list(commit = strrep("a", 40), dirty = FALSE)),
                 config = list(files = cfg, settings = settings),
                 inputs = stats::setNames(lapply(k$inputs, function(i) list(version_id = "v")), k$inputs),
                 seed = if (k$seed) 54L else NULL)
  crate::crt_receipt_write(dir, output = list(name = output), recipe = recipe,
                           result = list(tables = tables, parts = "out.csv", summary = sm),
                           keys = k, lockfile = NULL, publish = TRUE)
  file.path(dir, "receipt.json")
}
compare_of <- function(output, ...) {
  a <- receipt_from(output, withr::local_tempdir())
  b <- receipt_from(output, withr::local_tempdir(), ...)
  crate::crt_receipt_compare(a, b, keys = knw_receipt_keys(output))$verdict
}

test_that("every override a declaration makes names a field of crate's register, outside the recipe", {
  # crate 0.15.0 versions the register on its own path (crate#58): read the one a comparison is judged under
  a <- receipt_from(outputs[1], withr::local_tempdir())
  b <- receipt_from(outputs[1], withr::local_tempdir())
  ver <- crate::crt_receipt_compare(a, b, keys = knw_receipt_keys(outputs[1]))$register
  path <- system.file("extdata", "receipt", "register", paste0("v", ver), "register.csv", package = "crate")
  if (length(ver) != 1 || !nzchar(path)) stop("crate installs no register for version ", toString(ver))
  reg <- utils::read.csv(path)
  for (f in outputs) {
    k <- knw_receipt_keys(f)
    expect_true(all(k$register$field %in% reg$field), info = f)
    expect_false(any(startsWith(k$register$field, "recipe.")), info = f)
  }
})

test_that("each declared tolerance holds a value moved within it and refuses one moved past it", {
  for (f in outputs) {
    k <- knw_receipt_keys(f)
    expect_identical(compare_of(f), "identical", info = f)
    for (nm in k$summary) {
      tol <- k$tolerance$summary[[nm]]
      if (is.null(tol)) {
        # an undeclared rounding is exact
        expect_identical(compare_of(f, summary = stats::setNames(list(101), nm)), "different", info = paste(f, nm))
        next
      }
      expect_identical(compare_of(f, summary = stats::setNames(list(100 + tol / 2), nm)), "equivalent",
                       info = paste(f, nm))
      expect_identical(compare_of(f, summary = stats::setNames(list(100 + tol * 3), nm)), "different",
                       info = paste(f, nm))
    }
    for (tb in names(k$tolerance$tables)) {
      tol <- unlist(k$tolerance$tables[[tb]])[1]
      expect_true(compare_of(f, table_value = 1.5 + tol / 4) %in% c("identical", "equivalent"), info = paste(f, tb))
      expect_identical(compare_of(f, table_value = 1.5 + tol * 3), "different", info = paste(f, tb))
    }
  }
})

test_that("a grade's moved bytes are listed, not refused, where its declaration says so", {
  for (f in c("grade", "habitat_grade")) {
    a <- receipt_from(f, withr::local_tempdir())
    b <- receipt_from(f, withr::local_tempdir(), part = "b")
    cmp <- crate::crt_receipt_compare(a, b, keys = knw_receipt_keys(f))
    expect_false(identical(cmp$verdict, "different"), info = f)
    expect_true(all(c("warn") %in% cmp$differences$action[startsWith(cmp$differences$field, "result.parts")]),
                info = f)
  }
  # the thresholds declare no override, so crate's default holds: a part that names no table and moves is refused
  expect_identical(compare_of("thresholds", part = "b"), "different")
})

test_that("the declared tolerances are the ones written down, so changing one changes this test (#158 revises them)", {
  tol <- function(f) {
    k <- knw_receipt_keys(f)
    c(unlist(k$tolerance$summary), unlist(lapply(k$tolerance$tables, unlist)))
  }
  expect_equal(tol("grade"), c(km_graded = 1e-3, grade_sum = 1e-3, pick.null_heldout_curve = 1e-4))
  expect_equal(tol("habitat_grade"), c(km_graded = 1e-3, grade_sum = 1e-3))
  expect_null(tol("thresholds"))
  expect_identical(knw_receipt_keys("thresholds")$tables, c("thresholds", "thresholds_groups"))
  # the evidence build (#160): every table exact but access_check's km, at 1 mm
  expect_equal(tol("evidence"), c(access_km = 1e-3, access_check.km = 1e-6))
  expect_identical(knw_receipt_keys("evidence")$tables,
                   c("visits_link", "visits_species", "walks", "bcfishobs_fdis_match", "access_check",
                     "workbook_sites", "workbook_species"))
  expect_equal(tol("fdis"), c(access_check.km = 1e-6))
  expect_length(knw_receipt_keys("fdis")$tables, 11L)
  # a grade names the evidence build as one input (#160)
  expect_identical(knw_receipt_keys("grade")$inputs, c("link_build", "flow", "evidence"))
})

test_that("a receipt's tables are read as text, with only a rounded column read as a number", {
  d <- withr::local_tempdir()
  utils::write.csv(data.frame(code = c("08", "10"), km = c("787407.1195799585", ""), n = c("1", "NA")),
                   file.path(d, "access_check.csv"), row.names = FALSE)
  keys <- list(tables = "access_check", tolerance = list(tables = list(access_check = list(km = 1e-6))))
  x <- .knw_receipt_csv_tables(c(access_check = file.path(d, "access_check.csv")), keys)$access_check
  expect_identical(x$code, c("08", "10"))
  expect_identical(x$n, c("1", "NA"))
  expect_identical(x$km, c(787407.1195799585, NA))
  expect_error(.knw_receipt_csv_tables(c(other = file.path(d, "access_check.csv")), keys), "no source CSV")
  utils::write.csv(data.frame(km = c("1.5", "x")), file.path(d, "bad.csv"), row.names = FALSE)
  expect_error(.knw_receipt_csv_tables(c(access_check = file.path(d, "bad.csv")), keys), "not numbers \\(x\\)")
  utils::write.csv(data.frame(m = "1"), file.path(d, "nokm.csv"), row.names = FALSE)
  expect_error(.knw_receipt_csv_tables(c(access_check = file.path(d, "nokm.csv")), keys), "has no column km")
})

test_that("a failed git call stops, rather than reading as a clean tree", {
  expect_error(.knw_git(withr::local_tempdir(), "status", "--porcelain"), "git status --porcelain failed")
})

test_that("a crate that cannot name a receipt's file is refused before anything is written", {
  local_mocked_bindings(crt_receipt_write = function(dir, output, recipe) NULL, .package = "crate")
  expect_error(.knw_receipt_crate_check(), "cannot name a receipt's file")
})

test_that("whether a record's table owes a receipt is asked of the commit that graded it", {
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
  skip_if_not(file.exists(file.path(root, ".git")), "not a checkout")
  first <- .knw_git(root, "log", "--diff-filter=A", "--format=%H", "--", "R/grade_receipt.R")
  skip_if_not(length(first) == 1L, "R/grade_receipt.R has no single adding commit here")
  before <- .knw_git(root, "rev-parse", paste0(first, "^"))
  expect_true(.knw_receipt_due(list(knowledge_commit = substr(first, 1, 7)), root))
  expect_true(.knw_receipt_due(list(knowledge_commit = paste0(substr(first, 1, 7), "+dirty")), root))
  expect_false(.knw_receipt_due(list(knowledge_commit = substr(before, 1, 7)), root))
  expect_true(is.na(.knw_receipt_due(list(knowledge_commit = "0000000"), root)))
  expect_true(is.na(.knw_receipt_due(list(knowledge_commit = NA_character_), root)))
})
