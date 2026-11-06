# the receipt declarations knowledge ships (#154)

test_that("every declaration parses and names its own output", {
  files <- list.files(system.file("receipt", package = "knowledge"), "\\.yaml$")
  expect_setequal(sub("\\.yaml$", "", files), c("grade", "thresholds", "habitat_grade"))
  for (f in sub("\\.yaml$", "", files)) {
    k <- knw_receipt_keys(f)
    expect_s3_class(k, "crt_receipt_keys")
    expect_identical(k$output, f, info = f)
  }
  expect_error(knw_receipt_keys("nope"), "no receipt declaration for nope")
})

test_that("every declared config file is one the package installs", {
  for (f in c("grade", "thresholds", "habitat_grade")) {
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
}
compare_of <- function(output, ...) {
  a <- receipt_from(output, withr::local_tempdir())
  b <- receipt_from(output, withr::local_tempdir(), ...)
  crate::crt_receipt_compare(a, b, keys = knw_receipt_keys(output))$verdict
}

test_that("every override a declaration makes names a field of crate's register, outside the recipe", {
  reg <- utils::read.csv(system.file("extdata", "receipt", "register.csv", package = "crate"))
  for (f in c("grade", "thresholds", "habitat_grade")) {
    k <- knw_receipt_keys(f)
    expect_true(all(k$register$field %in% reg$field), info = f)
    expect_false(any(startsWith(k$register$field, "recipe.")), info = f)
  }
})

test_that("each declared tolerance holds a value moved within it and refuses one moved past it", {
  for (f in c("grade", "thresholds", "habitat_grade")) {
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
