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
#'   [knw_grade_receipt_write()]), `"thresholds"` or `"habitat_grade"` (the
#'   published sets, [knw_publish()]).
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

# The checkout's full commit and whether a tracked file of the package or a script differs from it: the rule 0320's
# `knowledge_commit` writes as "+dirty", read once at a run's start so the receipt and the record name one state.
.knw_git_state <- function(root = ".") {
  git <- function(...) suppressWarnings(system2("git", c("-C", root, ...), stdout = TRUE, stderr = FALSE))
  commit <- git("rev-parse", "HEAD")
  if (!length(commit) || !grepl("^[0-9a-f]{40}$", commit[1])) stop(root, " is not a git checkout", call. = FALSE)
  list(commit = commit[1],
       dirty = length(git("status", "--porcelain", "--untracked-files=no", "--", "R", "scripts", "inst")) > 0)
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

# The evidence a build read, as receipt inputs: each derived table's sha256, after its md5 is checked against the
# md5s the run recorded (`evidence_md5`, `;`-joined in this order), so a receipt never names another build's evidence
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
  stats::setNames(lapply(f, function(p) list(sha256 = .knw_sha256(p))), tbl)
}
