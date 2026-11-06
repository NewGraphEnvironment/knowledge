test_that("tables round-trip to Parquet with a manifest, codes kept as text", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("jsonlite")
  tmp <- withr::local_tempdir()
  csv <- file.path(tmp, "t.csv")
  utils::write.csv(data.frame(a = c(1.5, NA, 3), code = c("08", "09", "10"), s = c("x", "", "z")), csv,
                   row.names = FALSE, na = "")
  tables <- data.frame(table = "t", source = csv, script = "example", description = "three rows")
  m <- knw_publish(tables, file.path(tmp, "out"), id = "example/v1", note = "an example",
                   provenance = list(commit = "none", run = "r1"))
  expect_equal(m$id, "example/v1")
  expect_equal(m$files[[1]]$rows, 3)
  expect_equal(m$files[[1]]$columns, 3)
  expect_equal(m$files[[1]]$schema$code, "string")
  expect_true(file.exists(file.path(tmp, "out", "manifest.json")))
  pq <- arrow::read_parquet(file.path(tmp, "out", "t.parquet"))
  expect_equal(pq$code, c("08", "09", "10"))
  expect_true(is.na(pq$a[2]))
  j <- jsonlite::read_json(file.path(tmp, "out", "manifest.json"))
  expect_equal(j$provenance$run, "r1")
  expect_null(j$supersedes)
})

test_that("a Hive-partitioned table writes one part per key and lists them", {
  skip_if_not_installed("arrow")
  tmp <- withr::local_tempdir()
  csv <- file.path(tmp, "g.csv")
  utils::write.csv(data.frame(species_code = c("BT", "BT", "CH"), stage = "rear", grade = c(0.2, 0.9, 1)), csv,
                   row.names = FALSE)
  tables <- data.frame(table = "g", source = csv, script = "example", description = "grades")
  m <- knw_publish(tables, file.path(tmp, "out"), id = "example/v1", note = "n", hive = "g")
  parts <- m$files[[1]]$parts
  expect_equal(length(parts), 2)
  expect_equal(sum(vapply(parts, `[[`, numeric(1), "rows")), 3)
  expect_true(file.exists(file.path(tmp, "out", "g", "species_code=BT", "stage=rear", "part.parquet")))
})

test_that("a missing source is refused", {
  tables <- data.frame(table = "t", source = "/nowhere/t.csv", script = "x", description = "y")
  expect_error(knw_publish(tables, tempfile(), id = "e/v1", note = "n"), "missing input")
})

# a published set's receipt (#154): the thresholds declaration's two tables, and a recipe as 0325 builds it
thr_fx <- function(env = parent.frame()) {
  tmp <- withr::local_tempdir(.local_envir = env)
  f1 <- file.path(tmp, "thresholds.csv")
  f2 <- file.path(tmp, "thresholds_groups.csv")
  utils::write.csv(data.frame(rule_id = c("CH_rear_v1", "BT_rear_v1"), value = c("0.13", "0.2"), n = c(10, 20)), f1,
                   row.names = FALSE)
  utils::write.csv(data.frame(rule_id = "CH_rear_v1", watershed_group_code = c("BULK", "MORR"), fold = 1:2), f2,
                   row.names = FALSE)
  list(tmp = tmp, tables = data.frame(table = c("thresholds", "thresholds_groups"), source = c(f1, f2),
                                      script = "example", description = c("picks", "groups")))
}
thr_receipt <- function(fx) {
  list(output = "thresholds",
       recipe = list(code = list(knowledge = list(commit = strrep("a", 40), dirty = FALSE)),
                     config = list(files = .knw_receipt_config_files("settings"),
                                   settings = list(tune_run = "20261104_0543")),
                     inputs = list(link_build = list(version_id = "u1"), flow = list(version_id = "wet load"),
                                   evidence = list(version_id = "a;b;c"))),
       summary = list(rows = 2L))
}

test_that("a set published with a receipt writes it beside the manifest, its tables fingerprinted as text", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("jsonlite")
  fx <- thr_fx()
  out <- file.path(fx$tmp, "out")
  knw_publish(fx$tables, out, id = "knowledge/thresholds/v1", note = "n", receipt = thr_receipt(fx))
  r <- crate::crt_receipt_read(file.path(out, "receipt.json"))
  expect_identical(r$output$name, "thresholds")
  expect_null(r$context$host)
  read_txt <- function(f) utils::read.csv(f, colClasses = "character", na.strings = "", check.names = FALSE)
  expect_identical(r$result$fingerprint$thresholds$sha256, crate::crt_table_fingerprint(read_txt(fx$tables$source[1])))
  expect_identical(r$result$parts[["thresholds.parquet"]]$table, "thresholds")
  expect_identical(r$recipe$inputs$evidence$version_id, "a;b;c")
  # the same values republished are identical; a pick that moved is different
  b <- file.path(fx$tmp, "out2")
  knw_publish(fx$tables, b, id = "knowledge/thresholds/v1", note = "n", receipt = thr_receipt(fx))
  keys <- knw_receipt_keys("thresholds")
  expect_identical(crate::crt_receipt_compare(file.path(out, "receipt.json"), file.path(b, "receipt.json"),
                                              keys = keys)$verdict, "identical")
  x <- read_txt(fx$tables$source[1])
  x$value[1] <- "0.15"
  utils::write.csv(x, fx$tables$source[1], row.names = FALSE)
  knw_publish(fx$tables, b, id = "knowledge/thresholds/v1", note = "n", receipt = thr_receipt(fx))
  expect_identical(crate::crt_receipt_compare(file.path(out, "receipt.json"), file.path(b, "receipt.json"),
                                              keys = keys)$verdict, "different")
  # published again without one, no stale receipt is left behind
  knw_publish(fx$tables, b, id = "knowledge/thresholds/v1", note = "n")
  expect_false(file.exists(file.path(b, "receipt.json")))
  expect_error(knw_publish(fx$tables, b, id = "x/v1", note = "n", receipt = list(output = "thresholds")),
               "receipt names output, recipe and summary")
})

test_that("the upload sends the tables, then the receipt, then the manifest", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("jsonlite")
  fx <- thr_fx()
  sent <- character()
  aws_mock <- function(args) {
    if (identical(args[1:2], c("s3", "cp"))) sent <<- c(sent, basename(args[4]))
    character()
  }
  local_mocked_bindings(.knw_aws_ls = function(args) character(), .knw_aws = aws_mock)
  knw_publish(fx$tables, file.path(fx$tmp, "out"), id = "knowledge/thresholds/v1", note = "n", s3 = "s3://b/",
              receipt = thr_receipt(fx))
  expect_identical(sent, c("thresholds.parquet", "thresholds_groups.parquet", "receipt.json", "manifest.json"))
  # with no receipt, none is sent
  sent <- character()
  knw_publish(fx$tables, file.path(fx$tmp, "out"), id = "knowledge/thresholds/v1", note = "n", s3 = "s3://b/")
  expect_identical(sent, c("thresholds.parquet", "thresholds_groups.parquet", "manifest.json"))
})

test_that("the published visit set's receipt holds access_check's km to its rounding and every other table exact", {
  skip_if_not_installed("arrow")
  skip_if_not_installed("jsonlite")
  keys <- knw_receipt_keys("fdis")
  # one small table per declared table; access_check carries the km the evidence build writes (#160)
  fx_dir <- function(km, sites = c("a", "b")) {
    d <- withr::local_tempdir(.local_envir = parent.frame())
    for (tb in setdiff(keys$tables, "access_check")) {
      utils::write.csv(data.frame(site_visit = sites, zone = c("08", "10")), file.path(d, paste0(tb, ".csv")),
                       row.names = FALSE)
    }
    writeLines(c("species_code,km", paste0("BT,", format(km, digits = 17))), file.path(d, "access_check.csv"))
    data.frame(table = keys$tables, source = file.path(d, paste0(keys$tables, ".csv")), script = "s",
               description = "d", stringsAsFactors = FALSE)
  }
  rcp <- list(output = "fdis",
              recipe = list(code = list(knowledge = list(commit = strrep("a", 40), dirty = FALSE)),
                            config = list(settings = list(version = "v3")),
                            inputs = list(evidence = list(recipe_id = strrep("e", 64)),
                                          fdis_export = list(sha256 = strrep("f", 64)))),
              summary = list(visits = 2L))
  pub <- function(tables) {
    out <- withr::local_tempdir(.local_envir = parent.frame())
    knw_publish(tables, out, id = "knowledge/fdis/v3", note = "n", receipt = rcp)
    file.path(out, "receipt.json")
  }
  cmp <- function(a, b) crate::crt_receipt_compare(a, b, keys = keys)$verdict
  a <- pub(fx_dir(787407.1195799585))
  r <- crate::crt_receipt_read(a)
  expect_identical(r$output$name, "fdis")
  expect_identical(r$recipe$inputs$evidence$recipe_id, strrep("e", 64))
  expect_setequal(names(r$result$fingerprint), keys$tables)
  # the Parquet's bytes move with the value, and each names its table, which agrees within the rounding
  expect_identical(cmp(a, pub(fx_dir(787407.1195799585 + 1e-10))), "equivalent")
  expect_identical(cmp(a, pub(fx_dir(787407.1195799585 + 1e-3))), "different")
  # a zero-padded code is text, held exactly
  expect_identical(cmp(a, pub(fx_dir(787407.1195799585, sites = c("a", "c")))), "different")
})
