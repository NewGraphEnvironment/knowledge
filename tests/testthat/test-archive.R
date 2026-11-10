# the archive of tuning runs (#119): a mock versioned bucket stands in for S3, and zstd for an identity copy

# a versioned bucket in memory: each key a list of versions (file copy, md5 metadata, version id)
mock_bucket <- function(env = parent.frame(), versioning = "Enabled") {
  store <- new.env()
  store$objects <- list()
  store$puts <- 0L
  store$dir <- withr::local_tempdir(.local_envir = env)
  arg <- function(args, flag) args[which(args == flag) + 1]
  aws <- function(args) {
    op <- args[2]
    key <- arg(args, "--key")
    if (op == "get-bucket-versioning") return(versioning)
    if (op == "put-object") {
      store$puts <- store$puts + 1L
      vid <- sprintf("v%03d", store$puts)
      copy <- file.path(store$dir, vid)
      file.copy(arg(args, "--body"), copy)
      md5 <- sub("^md5=([0-9a-f]+),.*$", "\\1", arg(args, "--metadata"))
      store$objects[[key]] <- c(store$objects[[key]], list(list(vid = vid, path = copy, md5 = md5)))
      return(vid)
    }
    vs <- store$objects[[key]]
    if (op == "head-object") {
      if (!length(vs)) stop("aws s3api head-object failed: An error occurred (404) when calling the HeadObject ",
                            "operation: Not Found")
      v <- if (length(vid <- arg(args, "--version-id"))) Filter(function(x) x$vid == vid, vs)[[1]] else vs[[length(vs)]]
      return(if (grepl("VersionId", arg(args, "--query"))) paste(v$md5, v$vid, sep = "\t") else v$md5)
    }
    if (op == "copy-object") {
      src <- arg(args, "--copy-source")
      from <- Filter(function(x) x$vid == sub("^.*versionId=", "", src), vs)[[1]]
      store$puts <- store$puts + 1L
      vid <- sprintf("v%03d", store$puts)
      copy <- file.path(store$dir, vid)
      file.copy(from$path, copy)
      store$objects[[key]] <- c(vs, list(list(vid = vid, path = copy, md5 = from$md5)))
      return(vid)
    }
    if (op == "get-object") {
      v <- Filter(function(x) x$vid == arg(args, "--version-id"), vs)[[1]]
      file.copy(v$path, args[length(args)], overwrite = TRUE)
      return("{}")
    }
    stop("unmocked aws ", op)
  }
  zstd <- function(input, output, decompress = FALSE) {
    file.copy(input, output, overwrite = TRUE)
    invisible(output)
  }
  testthat::local_mocked_bindings(.knw_aws = aws, .knw_zstd = zstd, .env = env)
  store
}

# a run of one key (CH_rear) and its evidence build, laid out as a checkout's data/
run_fx <- function(root, run = "20261027_0000", tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), grade = 0.1) {
  d <- function(...) {
    p <- file.path(root, ...)
    dir.create(p, recursive = TRUE, showWarnings = FALSE)
    p
  }
  dv <- d("data", "fdis", "derived")
  db <- d("data", "fdis", "build")
  for (f in c("visits_link.csv", "visits_species.csv", "walks.csv")) writeLines(f, file.path(dv, f))
  writeLines("reconcile", file.path(db, "reconcile.csv"))
  # 0230's sites and 0240's table of them, which the plan holds to each other (#136)
  sites <- data.frame(site_visit = c("s1", "s2"), flag_far_snap = c(FALSE, TRUE), flag_ws50_mismatch = c(FALSE, NA),
                      snap_confirmed = c(TRUE, FALSE), snap_moved = c(FALSE, TRUE), blue_line_key = c(356L, 357L),
                      downstream_route_measure = c(10.5, 123456.789), date = as.Date(c("2020-08-01", NA)),
                      blocks_absence_of = c(NA, "BT"), gnis_name = c("Rivi\u00e8re Bleue", NA))
  saveRDS(sites, file.path(db, "sites.rds"))
  utils::write.csv(cbind(sites, n_bt = 1:2), file.path(dv, "fdis_sites.csv"), row.names = FALSE, na = "",
                   fileEncoding = "UTF-8")
  ev <- paste(unname(tools::md5sum(file.path(dv, c("visits_link.csv", "visits_species.csv", "walks.csv")))),
              collapse = ";")
  tn <- d("data", "tune")
  cm <- d("data", "compare")
  g <- file.path(tn, "CH_rear_grades.csv")
  utils::write.csv(data.frame(id_segment = 1:2, grade = grade, species_code = "CH", stage = "rear", rule = "r1",
                              run_uid = "u1", ref_population = "stream_branch", ref_edge = "1000", q_walk = "0.75",
                              walk = "bank", walk_md5 = "w", discharge_load = "wet load", curve_prior_sd = "2.5",
                              grade_withheld = "FALSE", null_heldout_curve = "100.1", evidence_md5 = ev,
                              curve_grad = "segment_gradient"), g, row.names = FALSE)
  # the run's evidence ledger records the build's sites.rds, which the plan holds the build directory to
  ledger <- file.path(root, "ledger.csv")
  utils::write.csv(data.frame(kind = "info", step = "md5_sites", n = 0,
                              note = unname(tools::md5sum(file.path(db, "sites.rds")))), ledger, row.names = FALSE)
  knw_grade_record_write(g, tune_run = run, evidence_ledger = ledger, knowledge_commit = "abc",
                         link = c(version = "0.66.0", sha = "def"), tokens = tokens, rows = 2)
  saveRDS(list(curve = run), file.path(tn, "CH_rear_curve.rds"))
  saveRDS(list(segments = run), file.path(cm, "CH_rear_segments.rds"))
  list(tune = tn, compare = cm, evidence = dv, build = db, sites = dv)
}
plan_of <- function(x, ...) {
  knw_archive_plan("CH_rear", x$tune, x$compare, x$evidence, x$build, sites_dir = x$sites, ...)
}

test_that("a run's setup is its build's four tokens, or untokened/<run> before link's vocabulary", {
  r <- data.frame(token_cut = NA, token_acc = NA, token_grad = NA, token_flow = NA, tune_run = "20261027_0000")
  expect_identical(knw_archive_setup(r), "untokened/20261027_0000")
  r[c("token_cut", "token_acc", "token_grad", "token_flow")] <- list("cut-full-top", "acc-v1", "grad-seg", "q-wet-fill")
  expect_identical(knw_archive_setup(r), "cut-full-top.acc-v1.grad-seg.q-wet-fill")
  voc <- data.frame(token = c("cut-full-top", "acc-v1", "grad-seg", "q-fwapg"), axis = c("cut", "acc", "grad", "flow"))
  expect_error(knw_archive_setup(r, voc), "token q-wet-fill is not a flow token")
  r$token_acc <- NA
  expect_error(knw_archive_setup(r), "tokens on some axes only: acc")
  r[c("token_cut", "token_grad", "token_flow")] <- NA
  r$tune_run <- "../x"
  expect_error(knw_archive_setup(r), "not a folder name")
})

test_that("a setup's record is filed under the grad token of the gradient it was graded on (#120)", {
  r <- data.frame(token_cut = "cut-full-top", token_acc = "acc-v5", token_grad = "grad-parent", token_flow = "q-fwapg",
                  tune_run = "20261105_0400", curve_grad = "parent_gradient")
  expect_identical(knw_archive_setup(r), "cut-full-top.acc-v5.grad-parent.q-fwapg")
  voc <- data.frame(token = c("cut-full-top", "acc-v5", "grad-seg", "grad-parent", "q-fwapg"),
                    axis = c("cut", "acc", "grad", "grad", "flow"))
  expect_identical(knw_archive_setup(r, voc), "cut-full-top.acc-v5.grad-parent.q-fwapg")
  # the Atlas setup waits for link to mint its token
  r[c("token_grad", "curve_grad")] <- list("grad-fwa", "segment_fwa_gradient")
  expect_error(knw_archive_setup(r, voc), "token grad-fwa is not a grad token")
  # a token that does not name the gradient graded on, either way
  r$token_grad <- "grad-seg"
  expect_error(knw_archive_setup(r), "graded on segment_fwa_gradient but filed under grad-seg, not grad-fwa")
  r[c("token_grad", "curve_grad")] <- list("grad-parent", "segment_gradient")
  expect_error(knw_archive_setup(r), "graded on segment_gradient but filed under the setup token grad-parent")
  r$token_grad <- "grad-seg"
  expect_identical(knw_archive_setup(r), "cut-full-top.acc-v5.grad-seg.q-fwapg")
})

test_that("the plan names every object, holds the grades to their record and the evidence to the grades", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  p <- plan_of(x)
  expect_identical(sum(p$kind == "tune"), 4L)
  expect_identical(sum(p$kind == "evidence"), 6L)
  expect_identical(p$object[p$kind == "tune"][1],
                   "archive/knowledge/tune/CH_rear/untokened/20261027_0000/CH_rear_grades.csv.zst")
  expect_identical(p$target[p$kind == "tune"],
                   c("data/tune/CH_rear_grades.csv", "data/tune/CH_rear_grades_record.csv",
                     "data/tune/CH_rear_curve.rds", "data/compare/CH_rear_segments.rds"))
  # the evidence folder is named by its MANIFEST's md5, which lists every file's md5
  m <- attr(p, "manifest")
  expect_identical(p$evidence_id[1], .knw_md5_text(m))
  expect_match(m, "  sites.rds\n$")
  expect_identical(unique(p$setup[p$kind == "evidence"]), paste0("evidence/", p$evidence_id[1]))
  cat("3,0.1\n", file = file.path(x$tune, "CH_rear_grades.csv"), append = TRUE)
  expect_error(plan_of(x), "CH_rear: .*not the table the record describes")
  x <- run_fx(root)
  writeLines("another build", file.path(x$evidence, "walks.csv"))
  expect_error(plan_of(x), "CH_rear: graded on evidence .*, not the build in")
  unlink(file.path(x$build, "sites.rds"))
  expect_error(plan_of(x), "the evidence build lacks .*sites.rds")
})

test_that("an archive stores every object once with its version id, and refuses an unversioned bucket", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket(versioning = "Suspended")
  expect_error(knw_archive_put(plan_of(x), idx), "versioning is Suspended, not Enabled")
  expect_false(file.exists(idx))
  b <- mock_bucket()
  rows <- knw_archive_put(plan_of(x), idx)
  expect_identical(nrow(rows), 11L)   # four tune objects, six evidence files and the MANIFEST
  expect_identical(b$puts, 11L)
  expect_true(all(grepl("^v[0-9]{3}$", rows$version_id)))
  expect_identical(rows$source[1], "data/tune/CH_rear_grades.csv")
  expect_identical(knw_archive_index_read(idx)$version_id, rows$version_id)
  # nothing changed: nothing is sent again, and the versions are recorded as they stand
  rows2 <- knw_archive_put(plan_of(x), idx)
  expect_identical(b$puts, 11L)
  expect_identical(rows2$version_id, rows$version_id)
})

test_that("an unpromoted run never overwrites the published run's setup, and promotion events supersede", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  i <- knw_archive_index_read(idx)
  expect_identical(i$event[i$event != "archived"], "promoted")
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2)
  expect_error(knw_archive_put(plan_of(x), idx),
               "holds published run 20261101_0000; an unpromoted run would overwrite it")
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  i <- knw_archive_index_read(idx)
  ev <- i[i$event != "archived", c("event", "tune_run")]
  expect_identical(ev$event, c("promoted", "superseded", "promoted"))
  expect_identical(ev$tune_run, c("20261101_0000", "20261101_0000", "20261102_0000"))
  # undone: the run its restored record names is promoted again, the undone one marked
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_undo("CH_rear", x$tune, idx)
  i <- knw_archive_index_read(idx)
  expect_identical(utils::tail(i$event, 2), c("undone", "promoted"))
  expect_identical(utils::tail(i$tune_run, 2), c("20261102_0000", "20261101_0000"))
})

test_that("a grade table's receipt is archived after its other files where the run wrote one, and restored (#154)", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  x <- run_fx(root, run = "20261106_0000", tokens = tok)
  g <- file.path(x$tune, "CH_rear_grades.csv")
  crate::crt_receipt_write(x$tune, output = list(name = "grade"),
                           recipe = list(code = list(knowledge = list(commit = strrep("a", 40), dirty = FALSE))),
                           result = list(parts = basename(g)), lockfile = NULL, publish = TRUE,
                           context = list(run = list(grades_md5 = unname(tools::md5sum(g)))),
                           file = "CH_rear_grades_receipt.json")
  p <- plan_of(x)
  tune <- p[p$kind == "tune", ]
  expect_identical(tune$target[5], "data/tune/CH_rear_grades_receipt.json")
  # the md5s stay with their files: the grades' is its record's, every other its own
  expect_identical(tune$source_md5[1], knw_grade_record_read(file.path(x$tune, "CH_rear_grades_record.csv"))$grades_md5)
  expect_identical(tune$source_md5[-1], unname(tools::md5sum(tune$source[-1])))
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(p, idx, promoted = TRUE)
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  knw_archive_pull("CH_rear", dest, index = idx)
  expect_identical(unname(tools::md5sum(file.path(dest, "data", "tune", "CH_rear_grades_receipt.json"))),
                   tune$source_md5[5])
  # one naming another table is refused
  rcp <- file.path(x$tune, "CH_rear_grades_receipt.json")
  crate::crt_receipt_write(x$tune, output = list(name = "grade"),
                           recipe = list(code = list(knowledge = list(commit = strrep("a", 40), dirty = FALSE))),
                           result = list(parts = basename(g)), lockfile = NULL, publish = TRUE,
                           context = list(run = list(grades_md5 = strrep("0", 32))), file = basename(rcp))
  expect_error(plan_of(x), "CH_rear: the grade table's receipt .* does not name the table its record describes")
  # a run from before receipts is archived with four files, as before
  unlink(rcp)
  expect_identical(sum(plan_of(x)$kind == "tune"), 4L)
  # but a record graded by code that writes receipts, with none beside it, is a pass that stopped: refused
  root <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
  if (file.exists(file.path(root, ".git"))) {
    head7 <- substr(.knw_git(root, "rev-parse", "HEAD"), 1, 7)
    rp <- file.path(x$tune, "CH_rear_grades_record.csv")
    r <- utils::read.csv(rp, colClasses = "character", na.strings = "")
    r$knowledge_commit <- head7
    utils::write.csv(r, rp, row.names = FALSE, na = "")
    withr::with_dir(root, expect_error(plan_of(x), "CH_rear: the run holds no receipt of its grades though the code"))
    r$knowledge_commit <- "abc"
    utils::write.csv(r, rp, row.names = FALSE, na = "")
  }
  expect_identical(sum(plan_of(x)$kind == "tune"), 4L)
})

test_that("a restore fetches the record's run by version, checks every md5, and leaves grade tables unless asked", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  rec1 <- readLines(file.path(x$tune, "CH_rear_grades_record.csv"))
  g1 <- unname(tools::md5sum(file.path(x$tune, "CH_rear_grades.csv")))
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  # a later run of the same setup overwrites the folder's current objects
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  # a checkout whose tracked record is the first run's restores the first run, by version id
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  writeLines(rec1, file.path(dest, "data", "tune", "CH_rear_grades_record.csv"))
  got <- knw_archive_pull("CH_rear", dest, index = idx)
  expect_false(file.exists(file.path(dest, "data", "tune", "CH_rear_grades.csv")))
  expect_identical(readRDS(file.path(dest, "data", "tune", "CH_rear_curve.rds"))$curve, "20261101_0000")
  expect_identical(readRDS(file.path(dest, "data", "compare", "CH_rear_segments.rds"))$segments, "20261101_0000")
  expect_true(file.exists(file.path(dest, "data", "fdis", "build", "sites.rds")))
  expect_false(file.exists(file.path(dest, "data", "fdis", "derived", "MANIFEST")))
  knw_archive_pull("CH_rear", dest, grades = TRUE, index = idx)
  expect_identical(unname(tools::md5sum(file.path(dest, "data", "tune", "CH_rear_grades.csv"))), g1)
  expect_false(any(grepl("^\\.part_", list.files(dest, recursive = TRUE, all.files = TRUE))))
  # a file present with another md5 is never written over
  writeLines("local edit", file.path(dest, "data", "fdis", "derived", "walks.csv"))
  expect_error(knw_archive_pull("CH_rear", dest, index = idx), "walks.csv is here with another md5")
})

test_that("a restored object whose bytes are not the index's is refused and leaves nothing", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx)
  # the stored curve corrupted after it was archived
  v <- b$objects[["archive/knowledge/tune/CH_rear/untokened/20261027_0000/CH_rear_curve.rds"]][[1]]
  writeLines("corrupt", v$path)
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  expect_error(knw_archive_pull("CH_rear", dest, index = idx),
               "CH_rear_curve.rds \\(version v[0-9]+\\) arrived with another md5")
  expect_false(file.exists(file.path(dest, "data", "tune", "CH_rear_curve.rds")))
  expect_false(any(grepl("^\\.part_", list.files(dest, recursive = TRUE, all.files = TRUE))))
})

test_that("an undo makes the published run current in a shared folder, and no unpromoted run then overwrites it", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  curve_obj <- "archive/knowledge/tune/CH_rear/cut-full-top.acc-v1.grad-seg.q-wet-fill/CH_rear_curve.rds"
  x1_md5 <- utils::tail(b$objects[[curve_obj]], 1)[[1]]$md5
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  expect_false(identical(utils::tail(b$objects[[curve_obj]], 1)[[1]]$md5, x1_md5))
  # undone: the first run's record is back, and its objects are made current again
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_undo("CH_rear", x$tune, idx)
  expect_identical(utils::tail(b$objects[[curve_obj]], 1)[[1]]$md5, x1_md5)
  i <- knw_archive_index_read(idx)
  expect_identical(utils::tail(i$event, 2), c("undone", "promoted"))
  # a candidate in the same setup is refused over the published run, whichever run was archived last
  x <- run_fx(root, run = "20261103_0000", tokens = tok, grade = 0.3)
  expect_error(knw_archive_put(plan_of(x), idx), "holds published run 20261101_0000")
})

test_that("a restore in two steps leaves the segments later than their grade table", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx)
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  knw_archive_pull("CH_rear", dest, index = idx)
  Sys.setFileTime(file.path(dest, "data", "compare", "CH_rear_segments.rds"), Sys.time() - 3600)
  knw_archive_pull("CH_rear", dest, grades = TRUE, index = idx)
  expect_gt(file.mtime(file.path(dest, "data", "compare", "CH_rear_segments.rds")),
            file.mtime(file.path(dest, "data", "tune", "CH_rear_grades.csv")))
})

test_that("a build directory that is not the run's ledger's is refused", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  saveRDS(list(sites = "another build"), file.path(x$build, "sites.rds"))
  expect_error(plan_of(x), "sites.rds is not the one .*ledger.csv records")
})

test_that("an undo that stops partway leaves the index pointing at every copy it made", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  # the second copy fails, then the undo is rerun
  real <- .knw_aws
  n <- 0L
  local_mocked_bindings(.knw_aws = function(args) {
    if (args[2] == "copy-object" && (n <<- n + 1L) == 2L) stop("aws s3api copy-object failed: network")
    real(args)
  })
  expect_error(knw_archive_undo("CH_rear", x$tune, idx), "network")
  knw_archive_undo("CH_rear", x$tune, idx)
  i <- knw_archive_index_read(idx)
  a <- i[i$event == "archived" & i$tune_run %in% "20261101_0000", ]
  a <- a[!duplicated(a$object, fromLast = TRUE), ]
  current <- vapply(a$object, function(o) utils::tail(b$objects[[o]], 1)[[1]]$vid, "")
  expect_identical(unname(current), a$version_id)
})

test_that("a copy an undo made but did not record is recorded on the rerun", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  # the first copy lands in the bucket, and the index write after it fails
  real <- .knw_archive_index_append
  local_mocked_bindings(.knw_archive_index_append = function(path, rows) stop("disk full"))
  expect_error(knw_archive_undo("CH_rear", x$tune, idx), "disk full")
  local_mocked_bindings(.knw_archive_index_append = real)
  knw_archive_undo("CH_rear", x$tune, idx)
  i <- knw_archive_index_read(idx)
  a <- i[i$event == "archived" & i$tune_run %in% "20261101_0000", ]
  a <- a[!duplicated(a$object, fromLast = TRUE), ]
  current <- vapply(a$object, function(o) utils::tail(b$objects[[o]], 1)[[1]]$vid, "")
  expect_identical(unname(current), a$version_id)
})

test_that("a run's name reused with new content is refused over the published run, and pull and undo find it by content", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  rec1 <- readLines(file.path(x$tune, "CH_rear_grades_record.csv"))
  g1 <- unname(tools::md5sum(file.path(x$tune, "CH_rear_grades.csv")))
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  # the same run resumed and regraded: same name, other content
  x <- run_fx(root, run = "20261101_0000", tokens = tok, grade = 0.4)
  expect_error(knw_archive_put(plan_of(x), idx), "holds published run 20261101_0000; an unpromoted run would overwrite")
  # promoted again under the same name, then undone: the first content is published and current again
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  grades_obj <- "archive/knowledge/tune/CH_rear/cut-full-top.acc-v1.grad-seg.q-wet-fill/CH_rear_grades.csv.zst"
  writeLines(rec1, file.path(x$tune, "CH_rear_grades_record.csv"))
  knw_archive_undo("CH_rear", x$tune, idx)
  i <- knw_archive_index_read(idx)
  first <- i$batch[i$event == "archived"][1]
  expect_identical(.knw_archive_published(i, "CH_rear")$batch, first)
  cur <- utils::tail(b$objects[[grades_obj]], 1)[[1]]
  expect_identical(cur$md5, i$object_md5[i$batch == first & i$object == grades_obj][1])
  # a checkout whose record is the first content restores the first content
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  writeLines(rec1, file.path(dest, "data", "tune", "CH_rear_grades_record.csv"))
  knw_archive_pull("CH_rear", dest, grades = TRUE, index = idx)
  expect_identical(unname(tools::md5sum(file.path(dest, "data", "tune", "CH_rear_grades.csv"))), g1)
  # a record no archive holds is refused
  writeLines(c(rec1[1], sub("20261101_0000", "20261199_0000", rec1[2])), file.path(dest, "data", "tune", "CH_rear_grades_record.csv"))
  expect_error(knw_archive_pull("CH_rear", dest, index = idx), "no archive whose record is this one")
})

test_that("batches sharing a record but not its curve or segments are told apart by the files here, then by publication", {
  root <- withr::local_tempdir()
  # untokened: one folder per run, so a superseded run's folder takes an unpromoted copy of it (a tokened folder's
  # published run refuses one)
  tok <- c(cut = NA, acc = NA, grad = NA, flow = NA)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  seg_obj <- "archive/knowledge/tune/CH_rear/untokened/20261101_0000/CH_rear_segments.rds"
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  rec1 <- readLines(file.path(x$tune, "CH_rear_grades_record.csv"))
  s1 <- unname(tools::md5sum(file.path(x$compare, "CH_rear_segments.rds")))
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  x <- run_fx(root, run = "20261102_0000", tokens = tok, grade = 0.2)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  # the first run again, with other segments, archived unpromoted (the published batch is now the second's)
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  saveRDS(list(segments = "s0"), file.path(x$compare, "CH_rear_segments.rds"))
  knw_archive_put(plan_of(x), idx)
  i <- knw_archive_index_read(idx)
  b1 <- i$batch[i$event == "archived"][1]
  # undo of the second promotion, with the first run's own segments back on disk, restores and publishes the first batch
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_undo("CH_rear", x$tune, idx, compare_dir = x$compare)
  i <- knw_archive_index_read(idx)
  expect_identical(.knw_archive_published(i, "CH_rear")$batch, b1)
  expect_identical(utils::tail(b$objects[[seg_obj]], 1)[[1]]$md5,
                   i$object_md5[i$batch == b1 & i$object == seg_obj][1])
  # a checkout with the record only: two archives hold it with other segments, and the published one is restored
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  writeLines(rec1, file.path(dest, "data", "tune", "CH_rear_grades_record.csv"))
  knw_archive_pull("CH_rear", dest, index = idx)
  expect_identical(unname(tools::md5sum(file.path(dest, "data", "compare", "CH_rear_segments.rds"))), s1)
  # with neither published, the restore asks for a batch by name
  i2 <- i[!i$event %in% c("promoted", "superseded", "undone"), ]
  utils::write.csv(i2, idx2 <- file.path(root, "index2.csv"), row.names = FALSE, na = "")
  dest2 <- withr::local_tempdir()
  dir.create(file.path(dest2, "data", "tune"), recursive = TRUE)
  writeLines(rec1, file.path(dest2, "data", "tune", "CH_rear_grades_record.csv"))
  expect_error(knw_archive_pull("CH_rear", dest2, index = idx2), "hold this record with other files; name one")
  knw_archive_pull("CH_rear", dest2, index = idx2, batch = c(CH_rear = b1))
  expect_identical(unname(tools::md5sum(file.path(dest2, "data", "compare", "CH_rear_segments.rds"))), s1)
})

test_that("an undo restores the batch the undone promotion superseded, whatever the files restored here", {
  root <- withr::local_tempdir()
  tok <- c(cut = "cut-full-top", acc = "acc-v1", grad = "grad-seg", flow = "q-wet-fill")
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  curve_obj <- "archive/knowledge/tune/CH_rear/cut-full-top.acc-v1.grad-seg.q-wet-fill/CH_rear_curve.rds"
  x <- run_fx(root, run = "20261101_0000", tokens = tok)
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  b1 <- knw_archive_index_read(idx)$batch[1]
  # the same record promoted again with another curve (a byte-identical regrade at one commit)
  saveRDS(list(curve = "refit"), file.path(x$tune, "CH_rear_curve.rds"))
  knw_archive_put(plan_of(x), idx, promoted = TRUE)
  # undone with this machine's curve and segments from another build
  saveRDS(list(curve = "stale"), file.path(x$tune, "CH_rear_curve.rds"))
  saveRDS(list(segments = "stale"), file.path(x$compare, "CH_rear_segments.rds"))
  expect_message(knw_archive_undo("CH_rear", x$tune, idx, compare_dir = x$compare),
                 "are not the archived run's; the archive's copies are published again")
  i <- knw_archive_index_read(idx)
  expect_identical(.knw_archive_published(i, "CH_rear")$batch, b1)
  expect_identical(utils::tail(i$event, 2), c("undone", "promoted"))
  expect_identical(utils::tail(b$objects[[curve_obj]], 1)[[1]]$md5,
                   i$object_md5[i$batch == b1 & i$object == curve_obj][1])
  # the undo undone (the second promotion's tables moved back): the second batch is published and current again
  b2 <- i$batch[i$event == "promoted"][2]
  saveRDS(list(curve = "refit"), file.path(x$tune, "CH_rear_curve.rds"))
  knw_archive_undo("CH_rear", x$tune, idx, compare_dir = x$compare)
  i <- knw_archive_index_read(idx)
  expect_identical(.knw_archive_published(i, "CH_rear")$batch, b2)
  expect_identical(utils::tail(b$objects[[curve_obj]], 1)[[1]]$md5,
                   i$object_md5[i$batch == b2 & i$object == curve_obj][1])
})

test_that("a batch named for another key leaves this key's choice to its files", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx)
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  expect_no_error(knw_archive_pull("CH_rear", dest, index = idx, batch = c(BT_rear = "x")))
})

# the rest of an evidence build beside the fixture's tables, and the receipt 0310 writes for it (#160)
evidence_receipt_of <- function(ev) {
  for (f in c("bcfishobs_fdis_match", "workbook_sites", "workbook_species")) {
    writeLines("site_visit", file.path(ev, paste0(f, ".csv")))
  }
  writeLines(c("species_code,km", "BT,1.5"), file.path(ev, "access_check.csv"))
  inputs <- lapply(stats::setNames(nm = knw_receipt_keys("evidence")$inputs), function(i) list(version_id = "v"))
  knw_evidence_receipt_write(ev, list(species = "BT", q_grid = 1, sources = "pick", snap_limit_m = 100,
                                      snap_limit_code_m = 150, parent = "none"),
                             inputs, knowledge = list(commit = strrep("a", 40), dirty = FALSE))
}

test_that("the evidence build's receipt is archived with it and restored, and a build without one keeps its id", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  id_before <- plan_of(x)$evidence_id[1]
  evidence_receipt_of(x$evidence)
  p <- plan_of(x)
  expect_identical(sum(p$kind == "evidence"), 7L)
  # stored in the build's folder, outside its MANIFEST: the id is the tables', and a receipt rewritten over the same
  # tables (its write time moves its bytes) keeps it
  expect_false(grepl("evidence_receipt", attr(p, "manifest")))
  expect_identical(p$evidence_id[1], id_before)
  expect_identical(p$object[p$kind == "evidence"][7],
                   paste("archive/knowledge/evidence", id_before, "evidence_receipt.json", sep = "/"))
  Sys.sleep(1.1)
  evidence_receipt_of(x$evidence)
  expect_identical(plan_of(x)$evidence_id[1], id_before)
  expect_identical(p$target[p$kind == "evidence"][7], "data/fdis/derived/evidence_receipt.json")
  # the receipt is the one beside these tables, or the archive refuses
  other <- withr::local_tempdir()
  for (f in c("visits_link", "visits_species", "walks")) {
    writeLines(paste("another", f), file.path(other, paste0(f, ".csv")))
  }
  evidence_receipt_of(other)
  file.copy(file.path(other, "evidence_receipt.json"), x$evidence, overwrite = TRUE)
  expect_error(plan_of(x), "does not describe")
  # archived and restored as the build's other files are
  evidence_receipt_of(x$evidence)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  rows <- knw_archive_put(plan_of(x), idx)
  expect_identical(nrow(rows), 12L)   # four tune objects, six evidence files, the receipt and the MANIFEST
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  knw_archive_pull("CH_rear", dest, index = idx)
  expect_identical(unname(tools::md5sum(file.path(dest, "data", "fdis", "derived", "evidence_receipt.json"))),
                   unname(tools::md5sum(file.path(x$evidence, "evidence_receipt.json"))))
  # without its receipt the build is the one archived before, under its id
  unlink(file.path(x$evidence, "evidence_receipt.json"))
  expect_identical(plan_of(x)$evidence_id[1], id_before)
})

test_that("a restore of a build archived without a receipt refuses a receipt already in the target", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx)
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  dir.create(file.path(dest, "data", "fdis", "derived"), recursive = TRUE)
  writeLines("{}", file.path(dest, "data", "fdis", "derived", "evidence_receipt.json"))
  expect_error(knw_archive_pull("CH_rear", dest, index = idx), "archived evidence build has no receipt")
  expect_false(file.exists(file.path(dest, "data", "fdis", "derived", "walks.csv")))
  unlink(file.path(dest, "data", "fdis", "derived", "evidence_receipt.json"))
  expect_no_error(knw_archive_pull("CH_rear", dest, index = idx))
})

test_that("a tagged evidence build is archived with fdis_sites.csv from 0240's directory, under the same id (#136)", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  p0 <- plan_of(x)
  # a build under a tagged EVIDENCE_DIR holds 0310's tables alone
  tag <- file.path(root, "data", "fdis", "derived_tag")
  dir.create(tag)
  file.copy(file.path(x$evidence, c("visits_link.csv", "visits_species.csv", "walks.csv")), tag)
  p <- knw_archive_plan("CH_rear", x$tune, x$compare, tag, x$build, sites_dir = x$sites)
  expect_identical(attr(p, "manifest"), attr(p0, "manifest"))
  expect_identical(p$evidence_id[1], p0$evidence_id[1])
  s <- p[p$kind == "evidence" & basename(p$source) == "fdis_sites.csv", ]
  expect_identical(s$source, file.path(x$sites, "fdis_sites.csv"))
  expect_identical(s$target, "data/fdis/derived/fdis_sites.csv")
  expect_identical(p$source[p$kind == "evidence" & basename(p$source) == "walks.csv"], file.path(tag, "walks.csv"))
  # a copy beside the tagged build is not read
  writeLines("a stale hand copy", file.path(tag, "fdis_sites.csv"))
  expect_identical(knw_archive_plan("CH_rear", x$tune, x$compare, tag, x$build, sites_dir = x$sites)$evidence_id[1],
                   p0$evidence_id[1])
})

test_that("fdis_sites.csv is held to the build's sites.rds: one row per site and every column they share (#136)", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  f <- file.path(x$sites, "fdis_sites.csv")
  good <- utils::read.csv(f, colClasses = "character", na.strings = "", encoding = "UTF-8")
  put <- function(d) utils::write.csv(d, f, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  put(good[1, ])
  expect_error(plan_of(x), "fdis_sites.csv .*not the sites of .*sites.rds .*: rerun scripts/0240")
  put(good[c(1, 2, 2), ])
  expect_error(plan_of(x), "fdis_sites.csv .*not the sites of .*sites.rds .*: rerun scripts/0240")
  d <- good
  d$site_visit[2] <- "s3"
  put(d)
  expect_error(plan_of(x), "fdis_sites.csv .*not the sites of .*sites.rds .*: rerun scripts/0240")
  # one value changed in any shared column, a double by one part in a million, a missing value filled
  bad <- list(flag_far_snap = "FALSE", flag_ws50_mismatch = "TRUE", snap_confirmed = "TRUE", snap_moved = "FALSE",
              blue_line_key = "999", downstream_route_measure = "123456.912", date = "2020-08-02",
              blocks_absence_of = "CH")
  for (cl in names(bad)) {
    d <- good
    d[[cl]][2] <- bad[[cl]]
    put(d)
    expect_error(plan_of(x), paste0("fdis_sites.csv's ", cl, " is not .*sites.rds's: rerun scripts/0240"))
  }
  # a small value moved by 5e-6 of itself
  d <- good
  d$downstream_route_measure[1] <- "10.50005"
  put(d)
  expect_error(plan_of(x), "fdis_sites.csv's downstream_route_measure is not")
  d$downstream_route_measure[1] <- NA
  put(d)
  expect_error(plan_of(x), "fdis_sites.csv's downstream_route_measure is not")
  d <- good
  d$blocks_absence_of[2] <- NA
  put(d)
  expect_error(plan_of(x), "fdis_sites.csv's blocks_absence_of is not")
  # the rows in another order, a double as written to 1e-9, an empty string read as NA, and the columns 0240 adds pass
  d <- good[2:1, ]
  d$n_bt <- 9
  d$downstream_route_measure[1] <- "123456.7890000001"
  put(d)
  expect_no_error(plan_of(x))
  # 0230 can hold an empty string where 0240 writes nothing (blocks_absence_of on the 2026-11 build)
  rds <- withr::local_tempfile(fileext = ".rds")
  saveRDS(transform(readRDS(file.path(x$build, "sites.rds")), blocks_absence_of = c("", "BT")), rds)
  expect_no_error(.knw_archive_sites_check(f, rds))
  # a stream name with an accent, under a C locale, is the same name (round 2 of the branch review)
  put(good)
  withr::with_locale(c(LC_CTYPE = "C"), expect_no_error(plan_of(x)))
  unlink(f)
  expect_error(plan_of(x), "the evidence build lacks .*fdis_sites.csv")
})

test_that("a restore refuses an fdis_sites.csv of other bytes before it writes anything (#136)", {
  root <- withr::local_tempdir()
  x <- run_fx(root)
  idx <- file.path(root, "index.csv")
  b <- mock_bucket()
  knw_archive_put(plan_of(x), idx)
  dest <- withr::local_tempdir()
  dir.create(file.path(dest, "data", "tune"), recursive = TRUE)
  file.copy(file.path(x$tune, "CH_rear_grades_record.csv"), file.path(dest, "data", "tune"))
  dir.create(file.path(dest, "data", "fdis", "derived"), recursive = TRUE)
  writeLines("another table", file.path(dest, "data", "fdis", "derived", "fdis_sites.csv"))
  expect_error(knw_archive_pull("CH_rear", dest, index = idx), "fdis_sites.csv is here with another md5")
  expect_identical(list.files(file.path(dest, "data"), recursive = TRUE, all.files = TRUE),
                   c("fdis/derived/fdis_sites.csv", "tune/CH_rear_grades_record.csv"))
  file.copy(file.path(x$sites, "fdis_sites.csv"), file.path(dest, "data", "fdis", "derived"), overwrite = TRUE)
  expect_no_error(knw_archive_pull("CH_rear", dest, index = idx))
  expect_true(file.exists(file.path(dest, "data", "fdis", "derived", "walks.csv")))
})
