# The constant columns `scripts/0320` writes on every row of a grade table: the run's record (#72, #73, #92). One list,
# read by the record writer and written by 0320, so the two cannot drift
.knw_cols_grade_record <- c("species_code", "stage", "rule", "run_uid", "ref_population", "ref_edge", "q_walk", "walk",
                            "walk_md5", "discharge_load", "curve_prior_sd", "grade_withheld", "null_heldout_curve",
                            "evidence_md5", "curve_grad")

# what the record adds to them: the table it describes, the run and evidence ledger that made it, the code, and link's
# build (version, commit and output-vocabulary tokens, NA before link 0.70.0)
.knw_cols_grade_record_extra <- c("grades_md5", "grades_bytes", "grades_rows", "tune_run", "evidence_ledger",
                                  "knowledge_commit", "link_version", "link_sha", "token_cut", "token_acc",
                                  "token_grad", "token_flow", "record_source")

# data/tune/<key>_grades.csv -> data/tune/<key>_grades_record.csv
.knw_grade_record_path <- function(grades_path) {
  if (!grepl("_grades\\.csv$", grades_path)) stop("not a grade table: ", grades_path, call. = FALSE)
  sub("_grades\\.csv$", "_grades_record.csv", grades_path)
}

#' A grade table's record: what the run made, in one tracked row
#'
#' A grade table (`data/tune/<key>_grades.csv`, written by `scripts/0320`) is
#' one row per stream segment, 0.3 to 2.5 GB, and ignored. Every reader that
#' checks which run made it reads only its first row, where the run's record
#' sits in the constant columns. The record is that row's constant columns
#' with the table's md5, size and row count, the run, the evidence ledger, the
#' knowledge commit and link's build beside it, written once beside the table
#' as `<key>_grades_record.csv` and tracked, so a machine without the table
#' still knows which run it was and an article bundle pins the record rather
#' than the table (#119). The archive (`scripts/0336`) stores the table and
#' restores it against the record's md5.
#'
#' @param grades_path `character(1)` the grade table.
#' @param tune_run `character(1)` the tuning run that made it (`0320`'s `RUN`),
#'   or the name a backfill gives a run that predates the record.
#' @param evidence_ledger `character(1)` the evidence build ledger the run read.
#' @param knowledge_commit `character(1)` the knowledge commit the run ran at,
#'   or `NA` where it is not known.
#' @param link `named character`: `version` and `sha` of the link that built
#'   the network (the ledger's `run_link_version` and `run_link_sha`).
#' @param tokens `named character` `c(cut =, acc =, grad =, flow =)` from
#'   [knw_build_record()]; `NA` where the build predates link's vocabulary.
#' @param rows `numeric(1)` the table's row count, or `NA`: counting a 2.5 GB
#'   table to write its record costs more than the record is worth, so the
#'   writer passes what it knows and the check never reads it.
#' @param record_source `character(1)` `"0320"` (written with the table) or
#'   `"backfill"` (written later from a table that predates the record).
#' @return `knw_grade_record_write()`: the record (a one-row data frame),
#'   invisibly, after writing it beside the table. `knw_grade_record_read()`:
#'   the record. `knw_grade_record_check()`: `TRUE`, invisibly, or an error
#'   naming what differs.
#' @export
#' @examples
#' d <- tempfile(); dir.create(d)
#' g <- file.path(d, "CH_rear_grades.csv")
#' utils::write.csv(data.frame(id_segment = 1:2, grade = c(0.1, 0.2), species_code = "CH", stage = "rear",
#'                             rule = "r1", run_uid = "u1", ref_population = "stream_branch", ref_edge = "1000",
#'                             q_walk = 0.75, walk = "bank", walk_md5 = "w", discharge_load = "wet load",
#'                             curve_prior_sd = 1, grade_withheld = FALSE, null_heldout_curve = 1.5,
#'                             evidence_md5 = "a;b;c", curve_grad = "segment_gradient"),
#'                  g, row.names = FALSE)
#' knw_grade_record_write(g, tune_run = "20261027_0000", evidence_ledger = "ledger.csv",
#'                        knowledge_commit = NA, link = c(version = "0.66.0", sha = "abc"),
#'                        tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), rows = 2)
#' r <- knw_grade_record_read(file.path(d, "CH_rear_grades_record.csv"))
#' r$rule
#' knw_grade_record_check(r, g)
knw_grade_record_write <- function(grades_path, tune_run, evidence_ledger, knowledge_commit, link, tokens,
                                   rows = NA, record_source = c("0320", "backfill")) {
  chk::chk_file(grades_path)
  chk::chk_string(tune_run)
  chk::chk_string(evidence_ledger)
  record_source <- match.arg(record_source)
  if (!all(c("version", "sha") %in% names(link))) stop("link names version and sha", call. = FALSE)
  if (!setequal(names(tokens), c("cut", "acc", "grad", "flow"))) {
    stop("tokens names cut, acc, grad and flow", call. = FALSE)
  }
  head1 <- utils::read.csv(grades_path, nrows = 1, colClasses = "character", na.strings = "", check.names = FALSE)
  miss <- setdiff(.knw_cols_grade_record, names(head1))
  if (length(miss)) {
    stop(grades_path, " predates the record's columns (", paste(miss, collapse = ", "), "): regrade it with 0320",
         call. = FALSE)
  }
  rec <- head1[1, .knw_cols_grade_record, drop = FALSE]
  extra <- list(grades_md5 = unname(tools::md5sum(grades_path)),
                grades_bytes = format(file.size(grades_path), scientific = FALSE),
                grades_rows = if (is.na(rows)) NA_character_ else format(rows, scientific = FALSE),
                tune_run = tune_run, evidence_ledger = evidence_ledger,
                knowledge_commit = as.character(knowledge_commit), link_version = unname(link[["version"]]),
                link_sha = unname(link[["sha"]]), token_cut = unname(tokens[["cut"]]), token_acc = unname(tokens[["acc"]]),
                token_grad = unname(tokens[["grad"]]), token_flow = unname(tokens[["flow"]]),
                record_source = record_source)
  rec <- cbind(rec, as.data.frame(lapply(extra, as.character), stringsAsFactors = FALSE))
  path <- .knw_grade_record_path(grades_path)
  .knw_write_whole(path, function(p) utils::write.csv(rec, p, row.names = FALSE, na = ""))
  invisible(rec)
}

#' @rdname knw_grade_record_write
#' @param path `character(1)` a `<key>_grades_record.csv`.
#' @export
knw_grade_record_read <- function(path) {
  chk::chk_file(path)
  rec <- utils::read.csv(path, colClasses = "character", na.strings = "", check.names = FALSE)
  miss <- setdiff(c(.knw_cols_grade_record, .knw_cols_grade_record_extra), names(rec))
  if (length(miss)) stop(path, " lacks ", paste(miss, collapse = ", "), call. = FALSE)
  if (nrow(rec) != 1) stop(path, " holds ", nrow(rec), " rows, not one", call. = FALSE)
  if (!grepl("^[0-9a-f]{32}$", rec$grades_md5)) stop(path, " carries no md5 of its table", call. = FALSE)
  tibble::as_tibble(rec)
}

#' @rdname knw_grade_record_write
#' @param record a record from `knw_grade_record_read()`.
#' @export
knw_grade_record_check <- function(record, grades_path) {
  chk::chk_file(grades_path)
  # size first: it is free, and a different size settles it without reading the table
  if (!identical(format(file.size(grades_path), scientific = FALSE), record$grades_bytes)) {
    stop(grades_path, " is ", file.size(grades_path), " bytes, its record's table ", record$grades_bytes,
         ": not the table the record describes", call. = FALSE)
  }
  md5 <- unname(tools::md5sum(grades_path))
  if (!identical(md5, record$grades_md5)) {
    stop(grades_path, " has md5 ", md5, ", its record's table ", record$grades_md5,
         ": not the table the record describes", call. = FALSE)
  }
  invisible(TRUE)
}
