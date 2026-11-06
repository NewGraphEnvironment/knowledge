# an evidence build's receipt (#160)

tables_all <- c("visits_link", "visits_species", "walks", "bcfishobs_fdis_match", "access_check", "workbook_sites",
                "workbook_species")

# an evidence directory holding every declared table: access_check's km is `km`, everything else two text rows
evidence_fixture <- function(km = c(787407.1195799585, 222.20912987511943), visits = c("a", "b")) {
  ev <- withr::local_tempdir(.local_envir = parent.frame())
  for (f in setdiff(tables_all, "access_check")) {
    utils::write.csv(data.frame(site_visit = visits, code = c("08", "10")), file.path(ev, paste0(f, ".csv")),
                     row.names = FALSE)
  }
  utils::write.csv(data.frame(species_code = c("BT", "CH"), km = format(km, digits = 17)),
                   file.path(ev, "access_check.csv"), row.names = FALSE, quote = FALSE)
  ev
}
inputs_all <- function() {
  i <- lapply(stats::setNames(nm = knw_receipt_keys("evidence")$inputs), function(i) list(version_id = "v"))
  i$bcfishobs <- list(none = "read live from the database")
  i
}
settings_all <- list(species = "BT", q_grid = c(1, 3, 5), sources = c("pick", "wet_balance"), snap_limit_m = 100,
                     snap_limit_code_m = 150, parent = "none")
write_ev <- function(ev, ...) {
  knw_evidence_receipt_write(ev, settings_all, inputs_all(), knowledge = list(commit = strrep("a", 40), dirty = FALSE),
                             ...)
}

test_that("the receipt records the build's recipe and every table, and reads back", {
  ev <- evidence_fixture()
  r <- write_ev(ev, context = list(run = list(run_uid = "20261103_163715-269b585a")))
  path <- file.path(ev, "evidence_receipt.json")
  expect_true(file.exists(path))
  back <- crate::crt_receipt_read(path)
  expect_identical(back$output$name, "evidence")
  expect_identical(back$recipe$recipe_id, r$recipe$recipe_id)
  expect_setequal(names(back$result$fingerprint), tables_all)
  expect_identical(back$recipe$inputs$bcfishobs$none, "read live from the database")
  # one species is still a list of species, not a scalar
  expect_match(paste(readLines(path), collapse = ""), '"species":\\s*\\[\\s*"BT"\\s*\\]')
  expect_identical(r$result$summary$visits, 2L)
  expect_equal(r$result$summary$access_km, 787407.1195799585 + 222.20912987511943)
  expect_null(back$context$host)
})

test_that("a missing table is refused, and so is a build that names no number in access_check's km", {
  ev <- evidence_fixture()
  unlink(file.path(ev, "walks.csv"))
  expect_error(write_ev(ev), "lacks walks.csv")
  ev <- evidence_fixture()
  writeLines(c("species_code,km", "BT,x"), file.path(ev, "access_check.csv"))
  expect_error(write_ev(ev), "not numbers")
  ev <- evidence_fixture()
  expect_error(knw_evidence_receipt_write(ev, settings_all, inputs_all()[-1],
                                          knowledge = list(commit = strrep("a", 40), dirty = FALSE)))
})

test_that("access_check's km moved in the last place is equivalent, and moved by a metre is different", {
  keys <- knw_receipt_keys("evidence")
  km <- c(787407.1195799585, 222.20912987511943)
  cmp <- function(km_b, visits_b = c("a", "b")) {
    a <- evidence_fixture(km)
    b <- evidence_fixture(km_b, visits_b)
    ra <- write_ev(a)
    rb <- write_ev(b)
    f <- function(d) stats::setNames(file.path(d, paste0(keys$tables, ".csv")), keys$tables)
    crate::crt_receipt_compare(ra, rb, keys = keys,
                               tables = list(a = .knw_receipt_csv_tables(f(a), keys),
                                             b = .knw_receipt_csv_tables(f(b), keys)))$verdict
  }
  expect_identical(cmp(km), "identical")
  expect_true(cmp(km + c(9.5e-11, -6e-11)) %in% c("identical", "equivalent"))
  expect_identical(cmp(km + c(1e-3, 0)), "different")
  # a visit table is exact: one value changed is a different build
  expect_identical(cmp(km, visits_b = c("a", "c")), "different")
})

test_that("several files hash as one input, in path order", {
  d <- withr::local_tempdir()
  writeLines("one", file.path(d, "a.csv"))
  writeLines("two", file.path(d, "b.csv"))
  h <- .knw_sha256_files(file.path(d, c("a.csv", "b.csv")))
  expect_match(h, "^[0-9a-f]{64}$")
  expect_identical(.knw_sha256_files(file.path(d, c("b.csv", "a.csv"))), h)
  writeLines("three", file.path(d, "b.csv"))
  expect_false(identical(.knw_sha256_files(file.path(d, c("a.csv", "b.csv"))), h))
  expect_error(.knw_sha256_files(file.path(d, "nope.csv")), "missing")
  expect_error(.knw_sha256_files(character()), "no files")
})

test_that("the recipe_id is read only from a receipt describing every table the caller reads", {
  ev <- evidence_fixture()
  r <- write_ev(ev)
  expect_null(.knw_evidence_recipe_id(withr::local_tempdir()))
  expect_identical(.knw_evidence_recipe_id(ev), r$recipe$recipe_id)
  # access_check rewritten after the receipt: a grade, which reads the visit tables, still names the build; a
  # publisher of access_check does not
  writeLines(c("species_code,km", "BT,1"), file.path(ev, "access_check.csv"))
  expect_identical(.knw_evidence_recipe_id(ev), r$recipe$recipe_id)
  expect_error(.knw_evidence_recipe_id(ev, tables = c("visits_link", "access_check")),
               "does not describe .*access_check")
})

test_that("files hashed under a root give the same value wherever the root sits", {
  one <- withr::local_tempdir()
  two <- withr::local_tempdir()
  for (d in c(one, two)) {
    dir.create(file.path(d, "overrides"))
    writeLines("a", file.path(d, "rules.yaml"))
    writeLines("b", file.path(d, "overrides", "x.csv"))
  }
  h <- function(d) .knw_sha256_files(list.files(d, recursive = TRUE, full.names = TRUE), root = d)
  expect_identical(h(one), h(two))
  writeLines("c", file.path(two, "overrides", "x.csv"))
  expect_false(identical(h(one), h(two)))
  # without a root the paths themselves are hashed, so the two places differ
  expect_false(identical(.knw_sha256_files(file.path(one, "rules.yaml")),
                         .knw_sha256_files(file.path(two, "rules.yaml"))))
  expect_error(.knw_sha256_files(file.path(one, "rules.yaml"), root = two), "not under")
})
