# The archive of tuning runs and their evidence (#119): s3://fresh-bc/archive/knowledge/, private, versioned.
#   tune/<key>/<setup>/      a run's ignored files for one key: the grade table (zstd -3), its record, the curve and the
#                            comparison's segments. <setup> is link's four output-vocabulary tokens, cut.acc.grad.flow,
#                            or untokened/<tune run> for a build older than the vocabulary (link#420)
#   evidence/<manifest md5>/ one evidence build's tables and its MANIFEST, stored once however many runs read it
# data/archive_index.csv (tracked) says what is where: one row per stored object and per promotion event, with the S3
# version id, so a run is found by reading a table and restored by version even after a later run overwrote its folder.

.knw_archive_bucket <- "fresh-bc"
.knw_archive_prefix <- "archive/knowledge"

# what the archive takes of a key, where it lives in a run's directories, and how it is stored
.knw_archive_tune_files <- function(k) {
  data.frame(file = paste0(k, c("_grades.csv", "_grades_record.csv", "_curve.rds", "_segments.rds")),
             dir = c("tune", "tune", "tune", "compare"),
             compress = c(TRUE, FALSE, FALSE, FALSE), stringsAsFactors = FALSE)
}
# an evidence build: the visit tables 0310 builds and the placement tables 0230 builds that the bundles read
.knw_archive_evidence_files <- data.frame(file = c("visits_link.csv", "visits_species.csv", "walks.csv",
                                                   "fdis_sites.csv", "reconcile.csv", "sites.rds"),
                                          dir = c("derived", "derived", "derived", "derived", "build", "build"),
                                          stringsAsFactors = FALSE)

# `batch` names one archive call: a run is identified by what it holds, not by its name, which a resumed run reuses
# (round 3 of the review), so a restore or an undo finds the batch whose record is the checkout's
.knw_cols_archive_index <- c("event", "date", "batch", "key", "setup", "tune_run", "run_uid", "evidence_id", "object",
                             "source", "source_md5", "object_md5", "bytes", "version_id")

# the two external programs, one wrapper each, so tests mock them and a failure always stops
.knw_aws <- function(args) {
  out <- suppressWarnings(system2("aws", shQuote(args), stdout = TRUE, stderr = TRUE))
  st <- attr(out, "status")
  if (!is.null(st) && st != 0) stop("aws ", paste(args[1:2], collapse = " "), " failed: ", paste(out, collapse = " "),
                                    call. = FALSE)
  out
}
.knw_zstd <- function(input, output, decompress = FALSE) {
  args <- c(if (decompress) "-d" else c("-3", "-T0"), "-q", "-f", input, "-o", output)
  out <- suppressWarnings(system2("zstd", shQuote(args), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status"))) stop("zstd failed on ", input, ": ", paste(out, collapse = " "), call. = FALSE)
  invisible(output)
}

#' Where the archive keeps a run: its setup folder
#'
#' A run's ignored files are kept under `tune/<key>/<setup>/`, one folder per
#' setup compared side by side (#119). The setup is the four tokens of link's
#' output vocabulary its build logged (`cut.acc.grad.flow`, from the grade
#' record), each held to link's `vocabulary.csv` when one is given. A build
#' from before link 0.70.0 logged none and is kept under
#' `untokened/<tune run>`: its folder is never renamed when its tokens are
#' named later (link#420); the index rows gain them instead. A re-run of a
#' tokened setup overwrites its folder, and the bucket keeps the previous
#' objects as versions.
#'
#' @param record a grade record ([knw_grade_record_read()]).
#' @param vocabulary `NULL`, or link's vocabulary (`token` and `axis`
#'   columns, link's `inst/extdata/vocabulary.csv`).
#' @return `character(1)` the setup folder.
#' @export
#' @examples
#' knw_archive_setup(data.frame(token_cut = NA, token_acc = NA, token_grad = NA, token_flow = NA,
#'                              tune_run = "20261027_0000"))
#' knw_archive_setup(data.frame(token_cut = "cut-full-top", token_acc = "acc-v1", token_grad = "grad-seg",
#'                              token_flow = "q-wet-fill", tune_run = "20261101_0000"))
knw_archive_setup <- function(record, vocabulary = NULL) {
  axes <- c("cut", "acc", "grad", "flow")
  tok <- vapply(axes, function(a) as.character(record[[paste0("token_", a)]][1]), character(1))
  run <- as.character(record$tune_run[1])
  if (all(is.na(tok))) {
    if (!grepl("^[A-Za-z0-9_.-]+$", run)) stop("tune_run is not a folder name: ", run, call. = FALSE)
    return(paste0("untokened/", run))
  }
  if (anyNA(tok)) stop("the record carries tokens on some axes only: ", paste(axes[is.na(tok)], collapse = ", "),
                       call. = FALSE)
  # a setup's grades read another gradient than the build's own (#120): its grad token names that gradient, and a
  # record of the segment's own gradient never carries a setup's token
  cg <- if ("curve_grad" %in% names(record)) as.character(record$curve_grad[1]) else NA_character_
  want <- if (!is.na(cg) && cg %in% names(.knw_grade_grad_tokens)) .knw_grade_grad_tokens[[cg]] else NA_character_
  if (!is.na(want) && !identical(tok[["grad"]], want)) {
    stop("graded on ", cg, " but filed under ", tok[["grad"]], ", not ", want, call. = FALSE)
  }
  if (is.na(want) && tok[["grad"]] %in% .knw_grade_grad_tokens) {
    stop("graded on ", cg, " but filed under the setup token ", tok[["grad"]], call. = FALSE)
  }
  if (!is.null(vocabulary)) {
    for (a in axes) {
      if (!any(vocabulary$token == tok[[a]] & vocabulary$axis == a)) {
        stop("token ", tok[[a]], " is not a ", a, " token in link's vocabulary", call. = FALSE)
      }
    }
  }
  paste(tok, collapse = ".")
}

#' What the archive stores for a run, and where
#'
#' Lists every file one archive of a run sends to the bucket: per key the
#' grade table (stored compressed), its record, the curve, the
#' comparison's segments and, where the run wrote one, the grade table's
#' receipt (#154), under `tune/<key>/<setup>/`; and the evidence build
#' the grades name, with its receipt where `0310` wrote one (#160), under
#' `evidence/<id>/` with a `MANIFEST` (one line per file, its md5 and name),
#' `<id>` being the MANIFEST's md5. Each grade table
#' is checked against its record and the evidence against the grades'
#' `evidence_md5` before anything is listed, so an archive never stores a
#' table its record does not describe.
#'
#' @param keys the keys (`"CH_rear"`) to archive.
#' @param tune_dir,compare_dir the run's directories (a candidate's, or the
#'   tracked `data/tune` and `data/compare`, or a staged copy).
#' @param evidence_dir,build_dir the evidence build: `0310`'s
#'   `data/fdis/derived` and `0230`'s `data/fdis/build`.
#' @param vocabulary passed to [knw_archive_setup()].
#' @return A data frame, one row per object: `kind` (`tune`, `evidence`),
#'   `key`, `setup`, `tune_run`, `run_uid`, `evidence_id`, `source` (the local
#'   file), `target` (where a restore puts it: its path in a checkout's
#'   `data/`), `object` (the S3 key), `compress`, `source_md5`; with attribute
#'   `manifest`, the MANIFEST's text.
#' @export
knw_archive_plan <- function(keys, tune_dir, compare_dir, evidence_dir, build_dir, vocabulary = NULL) {
  chk::chk_character(keys)
  if (!length(keys)) stop("no keys to archive", call. = FALSE)
  # the evidence build: its MANIFEST names it, and the grades must be on it
  ev <- .knw_archive_evidence_files
  ev$source <- file.path(ifelse(ev$dir == "derived", evidence_dir, build_dir), ev$file)
  gone <- ev$source[!file.exists(ev$source)]
  if (length(gone)) stop("the evidence build lacks ", paste(gone, collapse = ", "), call. = FALSE)
  # the build's receipt (#160) where 0310 wrote one, last, so a build from before receipts keeps the MANIFEST, and the
  # id, it was archived under; one that does not describe the build's tables is refused
  rcp_ev <- file.path(evidence_dir, .knw_evidence_receipt_file)
  if (file.exists(rcp_ev)) {
    .knw_evidence_recipe_id(evidence_dir)
    ev <- rbind(ev, data.frame(file = .knw_evidence_receipt_file, dir = "derived", source = rcp_ev,
                               stringsAsFactors = FALSE))
  }
  ev$source_md5 <- unname(tools::md5sum(ev$source))
  manifest <- paste0(paste(ev$source_md5, ev$file, sep = "  "), collapse = "\n")
  manifest <- paste0(manifest, "\n")
  ev_id <- .knw_md5_text(manifest)
  ev_md5 <- paste(ev$source_md5[match(c("visits_link.csv", "visits_species.csv", "walks.csv"), ev$file)],
                  collapse = ";")
  rows <- list()
  for (k in keys) {
    f <- .knw_archive_tune_files(k)
    f$source <- file.path(ifelse(f$dir == "tune", tune_dir, compare_dir), f$file)
    # the grade table's receipt (#154) where the run wrote one, last, so the md5s below stay in order; a run from
    # before receipts is archived without
    rcp <- file.path(tune_dir, paste0(k, "_grades_receipt.json"))
    if (file.exists(rcp)) {
      f <- rbind(f, data.frame(file = basename(rcp), dir = "tune", compress = FALSE, source = rcp,
                               stringsAsFactors = FALSE))
    }
    gone <- f$source[!file.exists(f$source)]
    if (length(gone)) stop(k, ": the run lacks ", paste(gone, collapse = ", "), call. = FALSE)
    rec <- knw_grade_record_read(f$source[2])
    tryCatch(knw_grade_record_check(rec, f$source[1]),
             error = function(e) stop(k, ": ", conditionMessage(e), call. = FALSE))
    # a receipt stored beside the record names its table, as promotion holds it (the branch review of #154, round 2);
    # none is refused where promotion would refuse it (round 3)
    if (!file.exists(rcp)) {
      due <- .knw_receipt_due(rec)
      others <- setdiff(keys[file.exists(file.path(tune_dir, paste0(keys, "_grades_receipt.json")))], k)
      if (isTRUE(due) || (is.na(due) && length(others))) {
        why <- if (isTRUE(due)) "the code that graded them writes one" else
          paste0(paste(others, collapse = ", "), " has one")
        stop(k, ": the run holds no receipt of its grades though ", why, call. = FALSE)
      }
    } else {
      md5_rcp <- tryCatch(crate::crt_receipt_read(rcp)$context$run$grades_md5, error = function(e) NULL)
      if (!identical(md5_rcp, rec$grades_md5)) {
        stop(k, ": the grade table's receipt (", rcp, ") does not name the table its record describes", call. = FALSE)
      }
    }
    # the build directory is 0230's: its sites.rds is the one the run's evidence ledger records (round 2 of the
    # review: a BUILD_DIR left at another build's would archive a mixed evidence build)
    if (file.exists(rec$evidence_ledger)) {
      led <- utils::read.csv(rec$evidence_ledger, colClasses = "character")
      sites_md5 <- ev$source_md5[ev$file == "sites.rds"]
      if (!identical(led$note[led$step == "md5_sites"], sites_md5)) {
        stop(k, ": ", build_dir, "/sites.rds is not the one ", rec$evidence_ledger, " records", call. = FALSE)
      }
    } else {
      stop(k, ": the run's evidence ledger ", rec$evidence_ledger, " is not here to hold the evidence to",
           call. = FALSE)
    }
    if (!identical(rec$evidence_md5, ev_md5)) {
      stop(k, ": graded on evidence ", rec$evidence_md5, ", not the build in ", evidence_dir, " (", ev_md5, ")",
           call. = FALSE)
    }
    setup <- knw_archive_setup(rec, vocabulary)
    obj <- paste0(f$file, ifelse(f$compress, ".zst", ""))
    rows[[k]] <- data.frame(kind = "tune", key = k, setup = setup, tune_run = rec$tune_run, run_uid = rec$run_uid,
                            evidence_id = ev_id, source = f$source, target = file.path("data", f$dir, f$file),
                            object = paste(.knw_archive_prefix, "tune", k, setup, obj, sep = "/"),
                            compress = f$compress,
                            source_md5 = c(rec$grades_md5, unname(tools::md5sum(f$source[-1]))),
                            stringsAsFactors = FALSE)
  }
  runs <- unique(vapply(rows, function(r) r$run_uid[1], ""))
  out <- rbind(do.call(rbind, rows),
               data.frame(kind = "evidence", key = NA_character_, setup = paste0("evidence/", ev_id),
                          tune_run = NA_character_, run_uid = if (length(runs) == 1) runs else NA_character_,
                          evidence_id = ev_id, source = ev$source,
                          target = file.path("data/fdis", ev$dir, ev$file),
                          object = paste(.knw_archive_prefix, "evidence", ev_id, ev$file, sep = "/"),
                          compress = FALSE, source_md5 = ev$source_md5, stringsAsFactors = FALSE))
  rownames(out) <- NULL
  attr(out, "manifest") <- manifest
  out
}

# md5 of a string, as md5sum gives it for a file holding exactly those bytes
.knw_md5_text <- function(x) {
  f <- tempfile()
  on.exit(unlink(f))
  writeBin(charToRaw(x), f)
  unname(tools::md5sum(f))
}

#' The archive's index: what is stored where
#'
#' `data/archive_index.csv` (tracked) holds one row per stored object
#' (`event = "archived"`), with its S3 version id, and one row per key per
#' promotion event (`promoted`, `superseded`, `undone`), so a run is found by
#' reading a table and restored by version id after a later run overwrote its
#' folder.
#'
#' @param path the index.
#' @return A data frame of the index's columns (all character); zero rows
#'   when the file does not exist.
#' @export
#' @examples
#' nrow(knw_archive_index_read(tempfile()))
knw_archive_index_read <- function(path = "data/archive_index.csv") {
  if (!file.exists(path)) {
    return(as.data.frame(stats::setNames(rep(list(character()), length(.knw_cols_archive_index)),
                                         .knw_cols_archive_index), stringsAsFactors = FALSE))
  }
  x <- utils::read.csv(path, colClasses = "character", na.strings = "", check.names = FALSE)
  if (!identical(names(x), .knw_cols_archive_index)) {
    stop(path, " columns are not the index's: ", paste(names(x), collapse = ", "), call. = FALSE)
  }
  x
}

.knw_archive_index_append <- function(path, rows) {
  rows <- rows[.knw_cols_archive_index]
  x <- rbind(knw_archive_index_read(path), rows)
  .knw_write_whole(path, function(p) utils::write.csv(x, p, row.names = FALSE, na = ""))
  invisible(x)
}

# the key's published batch, replayed from the promotion events in order: `promoted` publishes a batch, `superseded`
# or `undone` of the published batch unpublishes it. NULL when none is published
.knw_archive_published <- function(index, key) {
  ev <- index[index$key %in% key & index$event %in% c("promoted", "superseded", "undone"), ]
  cur <- NULL
  for (i in seq_len(nrow(ev))) {
    if (ev$event[i] == "promoted") cur <- ev[i, c("tune_run", "setup", "batch", "run_uid")]
    else if (!is.null(cur) && identical(ev$batch[i], cur$batch)) cur <- NULL
  }
  cur
}

# the objects of the batch a checkout's files describe, each at its last row (an undo's copy keeps the batch),
# whatever runs have reused its name since (round 3). The record pins the grade table only, so batches sharing a record
# can differ in the curve or the segments (round 4): the candidates are narrowed by every file the checkout holds
# (`local`, md5s named by their path in a checkout); where they still differ, the published one is taken, else a
# `batch` must be named
.knw_archive_batch_rows <- function(index, key, record_md5, local = character(), batch = NULL) {
  r <- index[index$event == "archived" & index$key %in% key & grepl("_grades_record\\.csv$", index$source) &
               index$source_md5 %in% record_md5, ]
  if (!nrow(r)) stop(key, ": the index holds no archive whose record is this one (md5 ", record_md5, ")", call. = FALSE)
  rows_of <- function(b) {
    a <- index[index$event == "archived" & index$key %in% key & index$batch %in% b, ]
    a[!duplicated(a$object, fromLast = TRUE), ]
  }
  cands <- unique(r$batch)
  if (!is.null(batch)) {
    if (!batch %in% cands) stop(key, ": batch ", batch, " does not hold this record", call. = FALSE)
    return(rows_of(batch))
  }
  if (length(local)) {
    cands <- Filter(function(b) {
      a <- rows_of(b)
      i <- match(names(local), a$source)
      all(!is.na(i)) && all(a$source_md5[i] == local)
    }, cands)
    if (!length(cands)) {
      stop(key, ": no archive holds this record with the ", paste(basename(names(local)), collapse = ", "),
           " here", call. = FALSE)
    }
  }
  sets <- vapply(cands, function(b) {
    a <- rows_of(b)
    paste(sort(paste(a$object, a$source_md5)), collapse = "\n")
  }, character(1))
  if (length(unique(sets)) > 1) {
    pub <- .knw_archive_published(index, key)
    if (!is.null(pub) && pub$batch %in% cands) return(rows_of(pub$batch))
    stop(key, ": archives ", paste(cands, collapse = ", "), " hold this record with other files; name one (BATCH=)",
         call. = FALSE)
  }
  rows_of(utils::tail(cands, 1))
}

# the batch an undo restores: the latest one a promotion or an undo unpublished (other than the published batch, the
# one being undone) whose record is the restored record, so an undo of an undo restores the batch the first undid.
# NULL when none is
.knw_archive_undo_batch <- function(index, key, record_md5) {
  cur <- .knw_archive_published(index, key)
  sup <- rev(index$batch[index$key %in% key & index$event %in% c("superseded", "undone") &
                           !index$batch %in% cur$batch])
  for (b in unique(sup)) {
    r <- index[index$event == "archived" & index$key %in% key & index$batch %in% b &
                 grepl("_grades_record\\.csv$", index$source), ]
    if (nrow(r) && utils::tail(r$source_md5, 1) %in% record_md5) return(b)
  }
  NULL
}

# the md5s of the key's files a checkout holds besides its record, named by their path in a checkout
.knw_archive_local <- function(key, tune_dir, compare_dir) {
  # the grade receipt is tracked (#154): a checkout holding one restores the batch that stored it
  f <- c(file.path(tune_dir, paste0(key, c("_curve.rds", "_grades_receipt.json"))),
         file.path(compare_dir, paste0(key, "_segments.rds")))
  names(f) <- c(file.path("data/tune", paste0(key, c("_curve.rds", "_grades_receipt.json"))),
                file.path("data/compare", paste0(key, "_segments.rds")))
  f <- f[file.exists(f)]
  stats::setNames(unname(tools::md5sum(f)), names(f))
}

#' Store a run in the archive, and record where
#'
#' Sends each object of a [knw_archive_plan()] to the bucket (`aws s3api
#' put-object`, the grade table through `zstd -3` first) with its md5 and its
#' source's md5 as metadata, reads the version id back, and appends one
#' `archived` row per object to the index. An object whose current version
#' already carries the same md5 is not sent again: its version is recorded.
#' Refused before anything is sent: a bucket whose versioning is not enabled
#' (an overwrite would lose the last copy), and, for an unpromoted run, a
#' setup folder whose current objects are a promoted run's.
#'
#' @param plan from [knw_archive_plan()].
#' @param index the index path.
#' @param promoted `TRUE` when the run is being promoted: `promoted` events are
#'   appended for its keys, and `superseded` for the keys' runs it replaces.
#' @param dry_run `TRUE` lists the plan and sends nothing.
#' @param bucket the bucket.
#' @return The rows appended to the index, invisibly.
#' @export
knw_archive_put <- function(plan, index = "data/archive_index.csv", promoted = FALSE, dry_run = FALSE,
                            bucket = .knw_archive_bucket) {
  chk::chk_flag(promoted)
  chk::chk_flag(dry_run)
  idx <- knw_archive_index_read(index)
  # an unpromoted run never overwrites a published object with other content (the folder of a tokened setup is
  # shared): the published batch is read from the promotion events (round 1 of the review), and each object compared
  # by content, since a resumed run reuses its name (round 3)
  tune <- plan[plan$kind == "tune", ]
  if (!promoted) {
    for (k in unique(tune$key)) {
      pub <- .knw_archive_published(idx, k)
      if (is.null(pub) || !identical(pub$setup, tune$setup[tune$key == k][1])) next
      pa <- idx[idx$event == "archived" & idx$key %in% k & idx$batch %in% pub$batch, ]
      pa <- pa[!duplicated(pa$object, fromLast = TRUE), ]
      tk <- tune[tune$key == k, ]
      i <- match(tk$object, pa$object)
      hit <- !is.na(i)
      off <- tk$target[hit][tk$source_md5[hit] != pa$source_md5[i[hit]]]
      if (length(off)) {
        stop(k, ": ", pub$setup, " holds published run ", pub$tune_run, "; an unpromoted run would overwrite its ",
             paste(basename(off), collapse = ", "), call. = FALSE)
      }
    }
  }
  if (dry_run) return(invisible(plan))
  st <- .knw_aws(c("s3api", "get-bucket-versioning", "--bucket", bucket, "--query", "Status", "--output", "text"))
  if (!identical(trimws(st[length(st)]), "Enabled")) {
    stop("bucket ", bucket, " versioning is ", st[length(st)], ", not Enabled: an overwrite would lose the last copy",
         call. = FALSE)
  }
  tmp <- tempfile("archive_")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE))
  # the MANIFEST, an object of the evidence folder like its tables
  ev <- plan[plan$kind == "evidence", ][1, ]
  man <- file.path(tmp, "MANIFEST")
  writeBin(charToRaw(attr(plan, "manifest")), man)
  ev$source <- man
  ev$target <- NA_character_
  ev$object <- sub("[^/]+$", "MANIFEST", ev$object)
  ev$source_md5 <- unname(tools::md5sum(man))
  plan <- rbind(plan, ev)
  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  batch <- .knw_archive_batch_id(now, plan)
  out <- vector("list", nrow(plan))
  for (i in seq_len(nrow(plan))) {
    p <- plan[i, ]
    body <- p$source
    if (p$compress) {
      body <- .knw_zstd(p$source, file.path(tmp, basename(p$object)))
      # the stored bytes decompress to the table the record describes, or nothing is sent
      back <- .knw_zstd(body, file.path(tmp, "check"), decompress = TRUE)
      if (!identical(unname(tools::md5sum(back)), p$source_md5)) {
        stop(p$object, ": compression did not round-trip", call. = FALSE)
      }
      unlink(back)
    }
    md5 <- unname(tools::md5sum(body))
    bytes <- format(file.size(body), scientific = FALSE)
    if (file.size(body) > 5e9) stop(p$object, " is over the 5 GB a single put takes", call. = FALSE)
    head <- tryCatch(.knw_aws(c("s3api", "head-object", "--bucket", bucket, "--key", p$object, "--query",
                                "[Metadata.md5, VersionId]", "--output", "text")),
                     error = function(e) if (grepl("404|Not Found", conditionMessage(e))) NULL else stop(e))
    have <- if (length(head)) strsplit(trimws(head[length(head)]), "\t")[[1]] else character()
    if (length(have) == 2 && identical(have[1], md5)) {
      vid <- have[2]
    } else {
      vid <- .knw_aws(c("s3api", "put-object", "--bucket", bucket, "--key", p$object, "--body", body,
                        "--metadata", sprintf("md5=%s,source-md5=%s", md5, p$source_md5),
                        "--query", "VersionId", "--output", "text"))
      vid <- trimws(vid[length(vid)])
      chk <- .knw_aws(c("s3api", "head-object", "--bucket", bucket, "--key", p$object, "--version-id", vid,
                        "--query", "Metadata.md5", "--output", "text"))
      if (!identical(trimws(chk[length(chk)]), md5)) stop(p$object, ": the stored version does not carry its md5",
                                                          call. = FALSE)
    }
    if (!grepl("^[A-Za-z0-9._-]+$", vid) || identical(vid, "null")) {
      stop(p$object, ": no version id (", vid, "): is versioning on?", call. = FALSE)
    }
    if (p$compress) unlink(body)
    out[[i]] <- data.frame(event = "archived", date = now, batch = batch, key = p$key, setup = p$setup,
                           tune_run = p$tune_run,
                           run_uid = p$run_uid, evidence_id = p$evidence_id, object = p$object,
                           source = p$target,
                           source_md5 = p$source_md5, object_md5 = md5, bytes = bytes, version_id = vid,
                           stringsAsFactors = FALSE)
  }
  rows <- do.call(rbind, out)
  if (promoted) {
    runs <- unique(tune[c("key", "setup", "tune_run", "run_uid")])
    runs$batch <- batch
    recs <- tune[grepl("_grades_record\\.csv$", tune$target), ]
    runs$record_md5 <- recs$source_md5[match(runs$key, recs$key)]
    rows <- rbind(rows, .knw_archive_events(idx, runs, now))
  }
  .knw_archive_index_append(index, rows)
  invisible(rows)
}

# `promoted` for each key's new batch (its record's md5 as source_md5), and `superseded` (or `undone`, when a
# promotion is undone) for the batch it replaces where that one was published
.knw_archive_events <- function(idx, runs, now, old_event = "superseded") {
  out <- list()
  for (i in seq_len(nrow(runs))) {
    r <- runs[i, ]
    cur <- .knw_archive_published(idx, r$key)
    if (!is.null(cur) && !identical(cur$batch, r$batch)) {
      out[[length(out) + 1]] <- .knw_archive_event_row(old_event, now, cur$batch, r$key, cur$setup, cur$tune_run,
                                                       cur$run_uid, NA_character_)
    }
    out[[length(out) + 1]] <- .knw_archive_event_row("promoted", now, r$batch, r$key, r$setup, r$tune_run, r$run_uid,
                                                     r$record_md5)
  }
  do.call(rbind, out)
}
.knw_archive_event_row <- function(event, now, batch, key, setup, tune_run, run_uid, record_md5) {
  x <- as.data.frame(stats::setNames(as.list(rep(NA_character_, length(.knw_cols_archive_index))),
                                     .knw_cols_archive_index), stringsAsFactors = FALSE)
  x$event <- event
  x$date <- now
  x$batch <- batch
  x$key <- key
  x$setup <- setup
  x$tune_run <- tune_run
  x$run_uid <- run_uid
  x$source_md5 <- record_md5
  x
}

# one archive call's name: its UTC time and a digest of what it stores
.knw_archive_batch_id <- function(now, plan) {
  paste0(gsub("[-:]", "", now), "-",
         substr(.knw_md5_text(paste(c(now, plan$object, plan$source_md5), collapse = "\n")), 1, 8))
}

#' Restore a run from the archive into a tree's ignored data/
#'
#' Fetches, by version id, the objects the index lists for each key's run (the
#' run its tracked record names, so a checkout restores what its tables were
#' made from) and their evidence build, decompresses the grade table, and
#' checks every file's md5 against the index's `source_md5` (and a grade
#' table against its record). Each file is written aside and moved in once
#' checked; a file already there with the same md5 is left, and one with
#' another md5 refuses. The evidence and the bundles' ignored files come by
#' default; grade tables, gigabytes each, only with `grades = TRUE`. Grade
#' tables are restored before segments, whose mtime `scripts/0330` holds to
#' be later.
#'
#' @param keys the keys whose run to restore.
#' @param dest the tree to restore into (its `data/`).
#' @param grades `TRUE` to restore the grade tables too.
#' @param index the index path.
#' @param bucket the bucket.
#' @param batch `NULL`, or a named character vector of batch ids by key, for a
#'   record that several archives hold with other curves or segments (the
#'   checkout's own files, and then the published batch, decide otherwise).
#' @return The restored and kept files' paths, invisibly.
#' @export
knw_archive_pull <- function(keys, dest = ".", grades = FALSE, index = "data/archive_index.csv",
                             bucket = .knw_archive_bucket, batch = NULL) {
  chk::chk_character(keys)
  chk::chk_flag(grades)
  idx <- knw_archive_index_read(index)
  got <- character()
  rows <- list()
  ev_ids <- character()
  for (k in keys) {
    # the batch whose record is this checkout's, by content: a run's name can be reused by a resumed run (round 3)
    f_rec <- file.path(dest, "data", "tune", paste0(k, "_grades_record.csv"))
    knw_grade_record_read(f_rec)
    a <- .knw_archive_batch_rows(idx, k, unname(tools::md5sum(f_rec)),
                                 local = .knw_archive_local(k, file.path(dest, "data/tune"),
                                                            file.path(dest, "data/compare")),
                                 batch = if (k %in% names(batch)) batch[[k]] else NULL)
    if (!grades) a <- a[!grepl("_grades\\.csv$", a$source), ]
    # grades first, segments last (0330 refuses segments older than the grades)
    a <- a[order(!grepl("_grades\\.csv$", a$source), grepl("_segments\\.rds$", a$source)), ]
    rows[[k]] <- a
    ev_ids <- c(ev_ids, unique(a$evidence_id))
  }
  ev_ids <- unique(ev_ids)
  if (length(ev_ids) != 1) stop("the keys' runs name ", length(ev_ids), " evidence builds", call. = FALSE)
  e <- idx[idx$event == "archived" & idx$evidence_id %in% ev_ids & is.na(idx$key) & !grepl("MANIFEST$", idx$object), ]
  e <- e[!duplicated(e$object, fromLast = TRUE), ]
  if (!nrow(e)) stop("the index holds no archive of evidence build ", ev_ids, call. = FALSE)
  todo <- rbind(e, do.call(rbind, rows))
  for (i in seq_len(nrow(todo))) {
    r <- todo[i, ]
    target <- file.path(dest, r$source)
    if (file.exists(target)) {
      if (identical(unname(tools::md5sum(target)), r$source_md5)) {
        got <- c(got, target)
        next
      }
      stop(target, " is here with another md5 than the archive's: move it aside to restore", call. = FALSE)
    }
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    part <- file.path(dirname(target), paste0(".part_", basename(target)))
    fetched <- if (grepl("\\.zst$", r$object)) paste0(part, ".zst") else part
    on.exit(unlink(c(part, paste0(part, ".zst"))), add = TRUE)
    .knw_aws(c("s3api", "get-object", "--bucket", bucket, "--key", r$object, "--version-id", r$version_id, fetched))
    if (!identical(unname(tools::md5sum(fetched)), r$object_md5)) {
      stop(r$object, " (version ", r$version_id, ") arrived with another md5 than the index's", call. = FALSE)
    }
    if (fetched != part) {
      .knw_zstd(fetched, part, decompress = TRUE)
      unlink(fetched)
    }
    if (!identical(unname(tools::md5sum(part)), r$source_md5)) {
      stop(r$source, ": restored with another md5 than the archive's source", call. = FALSE)
    }
    if (!file.rename(part, target)) stop("could not move ", part, " to ", target, call. = FALSE)
    got <- c(got, target)
  }
  # a restored grade table is the one its record describes; its segments, restored or kept from an earlier pull, are
  # made later than it, since scripts/0330 refuses segments older than their grades
  for (k in keys) {
    g <- file.path(dest, "data", "tune", paste0(k, "_grades.csv"))
    sg <- file.path(dest, "data", "compare", paste0(k, "_segments.rds"))
    if (file.exists(g)) {
      knw_grade_record_check(knw_grade_record_read(file.path(dest, "data", "tune", paste0(k, "_grades_record.csv"))), g)
      if (file.exists(sg) && file.mtime(sg) <= file.mtime(g)) Sys.setFileTime(sg, file.mtime(g) + 1)
    }
  }
  invisible(got)
}

#' Record an undone promotion in the archive's index
#'
#' `scripts/0335` undoes a promotion by promoting its `replaced_<stamp>`
#' archive, which sends nothing new to the bucket. This appends, per key, an
#' `undone` event for the run that was promoted and a `promoted` event for the
#' run the restored record names, so the index says which run is published.
#' Where the run's folder is shared (a tokened setup), the promotion being
#' undone made the restored run's objects previous versions, which the
#' bucket expires; each is copied back over its key (server side, from its
#' indexed version) so it is current again, and the copy's version is
#' recorded as an `archived` row.
#'
#' @param keys the keys moved back.
#' @param tune_dir where their restored records (and curves) are.
#' @param compare_dir where their restored segments are. The batch restored is
#'   the one the undone promotion superseded whose record is the restored one;
#'   restored curves and segments that differ from it are reported, and the
#'   archive's copies are published.
#' @param batch `NULL`, or a named character vector of batch ids by key, where
#'   the index cannot name the batch.
#' @param index the index path.
#' @param bucket the bucket.
#' @return The rows appended, invisibly.
#' @export
knw_archive_undo <- function(keys, tune_dir = "data/tune", index = "data/archive_index.csv",
                             bucket = .knw_archive_bucket, compare_dir = "data/compare", batch = NULL) {
  chk::chk_character(keys)
  idx <- knw_archive_index_read(index)
  now <- format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  runs <- do.call(rbind, lapply(keys, function(k) {
    f_rec <- file.path(tune_dir, paste0(k, "_grades_record.csv"))
    rec <- knw_grade_record_read(f_rec)
    rec_md5 <- unname(tools::md5sum(f_rec))
    # the batch the undone promotion superseded, whose record is the restored one: the index names it (round 5 of the
    # review). The restored curve and segments only confirm it: a machine's ignored files can be another build's, and
    # the archive's copies are the ones published again
    b <- if (!is.null(batch) && k %in% names(batch)) batch[[k]] else .knw_archive_undo_batch(idx, k, rec_md5)
    a <- .knw_archive_batch_rows(idx, k, rec_md5, batch = b)
    loc <- .knw_archive_local(k, tune_dir, compare_dir)
    i <- match(names(loc), a$source)
    off <- names(loc)[is.na(i) | a$source_md5[i] != loc]
    if (length(off)) {
      message(k, ": the restored ", paste(basename(off), collapse = ", "),
              " are not the archived run's; the archive's ",
              "copies are published again (PULL=TRUE restores them here)")
    }
    for (i in seq_len(nrow(a))) {
      r <- a[i, ]
      head <- .knw_aws(c("s3api", "head-object", "--bucket", bucket, "--key", r$object, "--query",
                         "[Metadata.md5, VersionId]", "--output", "text"))
      have <- strsplit(trimws(head[length(head)]), "\t")[[1]]
      if (length(have) == 2 && identical(have[1], r$object_md5)) {
        # current already: a copy an earlier, interrupted undo made, which the index must point at, since the version
        # it names is now a previous one and expires (round 2 of the review)
        if (identical(have[2], r$version_id)) next
        vid <- have[2]
      } else {
        vid <- .knw_aws(c("s3api", "copy-object", "--bucket", bucket, "--key", r$object, "--copy-source",
                          sprintf("%s/%s?versionId=%s", bucket, r$object, r$version_id), "--query", "VersionId",
                          "--output", "text"))
        vid <- trimws(vid[length(vid)])
      }
      r$version_id <- vid
      r$date <- now
      # appended as made, so an undo that stops partway leaves the index pointing at every copy it made
      .knw_archive_index_append(index, r)
    }
    data.frame(key = k, setup = a$setup[1], tune_run = rec$tune_run, run_uid = rec$run_uid, batch = a$batch[1],
               record_md5 = rec_md5, stringsAsFactors = FALSE)
  }))
  rows <- .knw_archive_events(idx, runs, now, old_event = "undone")
  .knw_archive_index_append(index, rows)
  invisible(rows)
}
