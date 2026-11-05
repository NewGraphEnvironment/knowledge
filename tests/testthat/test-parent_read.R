# knw_parent_read(): link's streams_parent, held to the full and minimal builds it joins (#120, link#444)

# a database whose answers each test edits: the table's minimal builds, each schema's runs, the run ids with no log
# row, the coverage counts and the rows
parent_db <- function(env) {
  testthat::local_mocked_bindings(dbGetQuery = function(conn, sql, params = NULL, ...) {
    if (grepl("to_regclass", sql)) return(data.frame(ok = env$has_table))
    if (grepl("SELECT DISTINCT schema_minimal", sql)) return(env$builds)
    if (grepl("log_recompute", sql)) {
      s <- regmatches(sql, regexpr("[a-z0-9_]+(?=\\.log_recompute)", sql, perl = TRUE))
      return(data.frame(run_uid = env$runs[[s]]))
    }
    if (grepl("NOT EXISTS", sql)) {
      side <- if (grepl("run_id_full", sql)) "full" else "minimal"
      return(data.frame(n = env$orphans[[side]]))
    }
    if (grepl("FILTER \\(WHERE p.n IS NULL\\)", sql)) return(env$cover)
    env$rows
  }, dbWriteTable = function(...) invisible(TRUE), dbExecute = function(...) 0L, .package = "DBI",
  .env = parent.frame())
}

parent_env <- function() {
  env <- new.env()
  env$has_table <- TRUE
  env$builds <- data.frame(schema_minimal = "fresh_default_minimal", run_uid_minimal = "m1",
                           link_sha_minimal = "abc", config_hash_minimal = "sha256:x")
  env$runs <- list(fresh_default = "f1", fresh_default_minimal = "m1")
  env$orphans <- list(full = 0L, minimal = 0L)
  env$cover <- data.frame(missing = 0L, doubled = 0L, off = 0L, rows = 3L, built_at = "2026-11-03 23:06:01+00")
  env$rows <- data.frame(id_segment = c(1L, 2L), wsg = "BULK", id_segment_minimal = c(1L, 1L),
                         gradient_minimal = 0.01, length_minimal = 300, overlap_m = c(100, 200), straddle_m = 0)
  env
}

test_that("a table of the two builds in the database reads in knw_parent_join()'s shape", {
  env <- parent_env()
  parent_db(env)
  p <- knw_parent_read(NULL, "fresh_default", "fresh_default_minimal")
  expect_identical(names(p), c("id_segment", "wsg", "id_segment_minimal", "gradient_minimal", "length_minimal",
                               "overlap_m", "straddle_m"))
  expect_type(p$id_segment, "double")
  pr <- attr(p, "provenance")
  expect_identical(pr$run_uid_full, "f1")
  expect_identical(pr$run_uid_minimal, "m1")
  expect_identical(pr$rows, 3L)
  # the minimal schema defaults to the one the table names
  expect_identical(attr(knw_parent_read(NULL, "fresh_default"), "provenance")$minimal_schema, "fresh_default_minimal")
  # keys narrow the rows read, not the checks
  k <- data.frame(watershed_group_code = "BULK", id_segment = 1)
  expect_identical(nrow(knw_parent_read(NULL, "fresh_default", keys = k)), 2L)
  v <- data.frame(site_visit = "a", watershed_group_code = "BULK", id_segment = 2, segment_length_m = 200)
  expect_identical(knw_parent_join(v, p)$parent_gradient, 0.01)
})

test_that("a table of another build, or a stale one, is refused", {
  env <- parent_env()
  parent_db(env)
  expect_error(knw_parent_read(NULL, "Fresh-default"), "lower-case identifier")
  env$has_table <- FALSE
  expect_error(knw_parent_read(NULL, "fresh_default"), "has no streams_parent table")
  env$has_table <- TRUE
  # joined to another minimal schema than the one asked for
  expect_error(knw_parent_read(NULL, "fresh_default", "zz415_minimal"), "joined to fresh_default_minimal, not zz415")
  # two minimal builds in one table
  env$builds <- rbind(env$builds, transform(env$builds, run_uid_minimal = "m0"))
  expect_error(knw_parent_read(NULL, "fresh_default"), "names 2 minimal builds")
  env$builds <- env$builds[1, ]
  # the minimal schema rebuilt since the join
  env$runs$fresh_default_minimal <- "m2"
  expect_error(knw_parent_read(NULL, "fresh_default"), "now holds run m2: rebuild the parent table")
  env$runs$fresh_default_minimal <- "m1"
  # a group's run id from another run of either build
  env$orphans$full <- 2L
  expect_error(knw_parent_read(NULL, "fresh_default"), "2 groups of fresh_default.streams_parent carry a run_id_full")
  env$orphans$full <- 0L
  env$orphans$minimal <- 1L
  expect_error(knw_parent_read(NULL, "fresh_default"),
               "carry a run_id_minimal that is no fresh_default_minimal.log row")
  env$orphans$minimal <- 0L
  # a segment of the full build with no row, two rows, or a row of another length
  for (f in c("missing", "doubled", "off")) {
    env$cover[[f]] <- 1L
    expect_error(knw_parent_read(NULL, "fresh_default"), "the table is stale", info = f)
    env$cover[[f]] <- 0L
  }
  expect_no_error(knw_parent_read(NULL, "fresh_default"))
})

test_that("a parent table other than the one the evidence recorded is refused at grade and compare time (#120)", {
  pv <- data.frame(schema = "fresh_default", minimal_schema = "fresh_default_minimal", run_uid_full = "f1",
                   run_uid_minimal = "m1", link_sha_minimal = "abc", config_hash_minimal = "sha256:x",
                   built_at = "2026-11-03 23:06:01+00", rows = 3L)
  local_mocked_bindings(knw_parent_read = function(...) structure(data.frame(), provenance = pv))
  led <- data.frame(step = c("evidence_dir", "parent_table"),
                    note = c("data/fdis/derived_parent", .knw_parent_note(pv)))
  expect_match(.knw_parent_note(pv), "^fresh_default.streams_parent: built 2026-11-03 23:06:01\\+00; full run f1, ")
  expect_identical(.knw_parent_held(NULL, "fresh_default", led), .knw_parent_note(pv))
  # the minimal network rebuilt and the table with it, the full build unchanged
  pv$run_uid_minimal <- "m2"
  expect_error(.knw_parent_held(NULL, "fresh_default", led), "not the evidence's .*rebuild the evidence")
  expect_error(.knw_parent_held(NULL, "fresh_default", led[1, ]), "records no parent table")
})
