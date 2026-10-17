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
