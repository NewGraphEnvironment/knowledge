#' A receipt declaration knowledge ships
#'
#' Each output knowledge writes a provenance receipt for (#154) declares, as
#' data beside its writer, what only knowledge knows about it: which inputs,
#' run settings and config files are its recipe, which tables are fingerprinted
#' and with what tolerance, which summary values it reports, and which
#' differences only a record. crate reads the declaration
#' ([crate::crt_receipt_keys()]); knowledge never re-implements the hashing.
#' The declarations are `inst/receipt/<output>.yaml`.
#'
#' @param output `character(1)`: `"grade"` (a grade table,
#'   [knw_grade_receipt_write()]), `"evidence"` (an evidence build,
#'   [knw_evidence_receipt_write()], #160), `"thresholds"`, `"habitat_grade"`
#'   or `"fdis"` (the published sets, [knw_publish()]).
#' @return A `crt_receipt_keys` list, as [crate::crt_receipt_keys()] returns.
#' @export
#' @examples
#' k <- knw_receipt_keys("grade")
#' k$inputs
#' k$tolerance$summary
knw_receipt_keys <- function(output) {
  chk::chk_string(output)
  path <- system.file("receipt", paste0(output, ".yaml"), package = "knowledge")
  if (!nzchar(path)) {
    known <- sub("\\.yaml$", "", list.files(system.file("receipt", package = "knowledge"), "\\.yaml$"))
    stop("no receipt declaration for ", output, "; knowledge declares ", paste(known, collapse = ", "), call. = FALSE)
  }
  crate::crt_receipt_keys(path)
}

# git's output, or an error when git exits non-zero: system2(stdout = TRUE) only warns on a failure and returns what
# was printed, so an empty `git status` from a failed call would read as a clean tree
.knw_git <- function(root, ...) {
  out <- suppressWarnings(system2("git", c("-C", root, ...), stdout = TRUE, stderr = FALSE))
  if (!is.null(attr(out, "status"))) {
    stop("git ", paste(c(...), collapse = " "), " failed in ", root, " (exit ", attr(out, "status"), ")", call. = FALSE)
  }
  out
}

# The checkout's full commit and whether a tracked file of the package or a script differs from it: the rule 0320's
# `knowledge_commit` writes as "+dirty", read once at a run's start so the receipt and the record name one state.
.knw_git_state <- function(root = ".") {
  commit <- tryCatch(.knw_git(root, "rev-parse", "HEAD"), error = function(e) character())
  if (!length(commit) || !grepl("^[0-9a-f]{40}$", commit[1])) stop(root, " is not a git checkout", call. = FALSE)
  list(commit = commit[1],
       dirty = length(.knw_git(root, "status", "--porcelain", "--untracked-files=no", "--", "R", "scripts",
                               "inst")) > 0)
}

# recipe$code for a receipt: knowledge only. link takes part through its build, an input identified by the run that
# built it (`link_build`), whose code that run fixed; its version and commit go in the receipt's context.
.knw_receipt_code <- function(knowledge) {
  if (!is.list(knowledge) || !setequal(names(knowledge), c("commit", "dirty"))) {
    stop("knowledge names commit and dirty (.knw_git_state())", call. = FALSE)
  }
  list(knowledge = list(commit = knowledge$commit, version = as.character(utils::packageVersion("knowledge")),
                        dirty = knowledge$dirty))
}

# Was a grade record's table graded by code that writes receipts (#154)? Its commit answers where this checkout holds
# it: TRUE when R/grade_receipt.R is in that commit, FALSE when the commit is here without it, NA when the record names
# no commit or one this checkout does not hold, and the caller decides from the rest of the run. A missing receipt is
# then a pass that stopped (refused), never read as a run from before receipts by the file's absence alone.
.knw_receipt_due <- function(record, root = ".") {
  kc <- sub("\\+dirty$", "", record$knowledge_commit)
  if (length(kc) != 1L || is.na(kc) || !grepl("^[0-9a-f]{7,40}$", kc)) return(NA)
  has <- function(obj) {
    isTRUE(tryCatch(length(.knw_git(root, "cat-file", "-e", obj)) >= 0L, error = function(e) FALSE))
  }
  if (has(paste0(kc, ":R/grade_receipt.R"))) return(TRUE)
  if (has(paste0(kc, "^{commit}"))) FALSE else NA
}

# crate writes a receipt under a name of knowledge's choosing only from the release that added `file =` (crate#47);
# asked of the function, not its version, since a crate from its main branch can carry the floor's version without it
.knw_receipt_crate_check <- function() {
  if (!"file" %in% names(formals(crate::crt_receipt_write))) {
    stop("crate ", utils::packageVersion("crate"), " cannot name a receipt's file (crt_receipt_write(file =), ",
         "NewGraphEnvironment/crate#47): install a crate that can", call. = FALSE)
  }
  invisible(TRUE)
}

# The config files every receipt hashes, keyed by their path in the source tree so the key is the same wherever the
# package is installed
.knw_receipt_config_files <- function(which) {
  rel <- c(settings = "method/settings.csv", walk = "sql/ch_dist_profile.sql")[which]
  stats::setNames(vapply(rel, function(r) system.file(r, package = "knowledge", mustWork = TRUE), character(1)),
                  paste0("inst/", rel))
}

# A run setting as the receipt writes it: canonical JSON has no Inf or NaN, so a non-finite number is written as R
# prints it (a curve prior of Inf is "no prior")
.knw_receipt_setting <- function(x) {
  if (is.numeric(x) && any(!is.finite(x) & !is.na(x))) format(x) else x
}

# The evidence a build read, as the receipt input `evidence`, after the visit tables' md5s are checked against the md5s
# the run recorded (`evidence_md5`, `;`-joined in this order), so a receipt never names another build's evidence: the
# build's receipt's recipe_id where 0310 wrote one (#160), so an evidence rebuild that came out equivalent is the same
# input, else the md5s as a version id, as 0325 names it, for a build from before evidence receipts
.knw_receipt_evidence <- function(evidence_dir, evidence_md5) {
  tbl <- c("visits_link", "visits_species", "walks")
  f <- file.path(evidence_dir, paste0(tbl, ".csv"))
  if (!all(file.exists(f))) {
    stop(evidence_dir, " lacks ", paste(basename(f[!file.exists(f)]), collapse = ", "), call. = FALSE)
  }
  md5 <- paste(unname(tools::md5sum(f)), collapse = ";")
  if (!identical(md5, evidence_md5)) {
    stop("the evidence in ", evidence_dir, " is not the build the run read (md5 ", md5, ", recorded ",
         evidence_md5, ")", call. = FALSE)
  }
  id <- .knw_evidence_recipe_id(evidence_dir)
  list(evidence = if (is.null(id)) list(version_id = evidence_md5) else list(recipe_id = id))
}

# The tables a receipt fingerprints, read from their CSVs as text, so each value is held as written: a column the
# declaration gives a tolerance is read as a number, which is how crate rounds it (#160: access_check's km). An empty
# cell is NA either way, and "NA" in a tolerance column too; a cell there that is not a number is refused rather than
# fingerprinted as NA
.knw_receipt_csv_tables <- function(sources, keys) {
  if (is.null(names(sources)) || !all(keys$tables %in% names(sources))) {
    stop("the receipt fingerprints ", paste(setdiff(keys$tables, names(sources)), collapse = ", "),
         ", with no source CSV", call. = FALSE)
  }
  lapply(stats::setNames(keys$tables, keys$tables), function(tb) {
    x <- utils::read.csv(sources[[tb]], colClasses = "character", na.strings = "", check.names = FALSE)
    for (cl in names(keys$tolerance$tables[[tb]])) {
      if (!cl %in% names(x)) stop(sources[[tb]], " has no column ", cl, ", which the declaration rounds", call. = FALSE)
      a <- x[[cl]]
      a[a %in% "NA"] <- NA
      v <- suppressWarnings(as.numeric(a))
      bad <- !is.na(a) & is.na(v)
      if (any(bad)) stop(sources[[tb]], ": ", cl, " holds ", sum(bad), " values that are not numbers (",
                         a[bad][1], ")", call. = FALSE)
      x[[cl]] <- v
    }
    x
  })
}
