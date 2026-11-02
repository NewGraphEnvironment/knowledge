#' The evidence ledger a set of tuning tables was scored on
#'
#' `scripts/0310` writes one ledger per evidence build into
#' `scripts/logs/habitat/`, so a build checked but not promoted (#111) leaves a
#' newer ledger than the published tables'. Since #111 each summary names the
#' ledger its run read (`evidence_ledger`); this returns it, so `scripts/0325`,
#' `scripts/0330` and the methodology bundle read the published run's build,
#' not the newest on disk. Tables from before the record fall back to the
#' newest ledger, which is what every reader took until then.
#'
#' @param tune_dir the directory of `<key>_summary.csv` tables (not recursed).
#' @param log_dir where the ledgers live.
#' @return `character(1)` the ledger's path.
#' @export
#' @examples
#' d <- tempfile(); dir.create(d); dir.create(l <- file.path(d, "logs"))
#' for (f in c("20261020", "20261027")) {
#'   writeLines("kind,step,n,note", file.path(l, paste0(f, "_evidence_build_ledger.csv")))
#' }
#' utils::write.csv(data.frame(species_code = "CH", stage = "rear",
#'                             evidence_ledger = file.path(l, "20261020_evidence_build_ledger.csv")),
#'                  file.path(d, "CH_rear_summary.csv"), row.names = FALSE)
#' basename(knw_run_ledger(d, l))   # the run's, not the newest
knw_run_ledger <- function(tune_dir, log_dir = "scripts/logs/habitat") {
  chk::chk_dir(tune_dir)
  files <- list.files(tune_dir, "_summary\\.csv$", full.names = TRUE)
  named <- unlist(lapply(files, function(f) {
    x <- utils::read.csv(f, colClasses = "character", na.strings = "")
    if ("evidence_ledger" %in% names(x)) x$evidence_ledger else NA_character_
  }))
  named <- unique(stats::na.omit(named))
  if (length(named) > 1) stop(tune_dir, "'s tables were scored on ", length(named), " evidence builds: ",
                              paste(named, collapse = ", "), call. = FALSE)
  if (length(named) == 1) {
    if (!file.exists(named)) stop("the ledger ", named, " the tables name is not on disk", call. = FALSE)
    return(named)
  }
  newest <- sort(list.files(log_dir, "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
  if (is.na(newest)) stop("no evidence build ledger in ", log_dir, ": run scripts/0310 first", call. = FALSE)
  newest
}

# ---- a build's evidence directory and its ledger (#120) -------------------------------------------------------------
# scripts/0310 writes one evidence build into EVIDENCE_DIR (default data/fdis/derived). The default directory's ledger
# keeps the plain name every reader since #57 takes (<date>_evidence_build_ledger.csv, knw_run_ledger()'s fallback); any
# other directory tags its ledger with the directory's base name (<date>_evidence_build_ledger-<base>.csv), outside
# that pattern, as a refused run's <date>_evidence_build_refused.csv is, so a test build never becomes the ledger a
# default reader takes. The ledger names its directory in an `evidence_dir` info row, which the finder holds it to.
.knw_evidence_dir_default <- "data/fdis/derived"

# a directory as an absolute path with no `.`, doubled or trailing separators, without resolving links, so the default
# given as `data/fdis/derived`, `./data/fdis/derived/` or its absolute path is one directory
.knw_path_key <- function(x) {
  x <- path.expand(x)
  if (!startsWith(x, "/")) x <- file.path(getwd(), x)
  x <- gsub("/+", "/", x)
  while (grepl("/\\./", x)) x <- gsub("/\\./", "/", x)
  sub("(.)/(\\.)?$", "\\1", x)
}

# a path as it is written into a ledger, a summary or a log, all of which become tracked files: relative to the working
# directory (the repo root) when it lies inside it, else with the home directory as `~`, so no home path is published
.knw_path_rel <- function(x) {
  k <- .knw_path_key(x)
  root <- paste0(.knw_path_key(getwd()), "/")
  if (startsWith(k, root)) return(substring(k, nchar(root) + 1L))
  home <- .knw_path_key(path.expand("~"))
  if (identical(k, home) || startsWith(k, paste0(home, "/"))) return(paste0("~", substring(k, nchar(home) + 1L)))
  k
}

# "" for the default directory, else "-<base name>"
.knw_evidence_tag <- function(evidence_dir) {
  chk::chk_string(evidence_dir)
  if (identical(.knw_path_key(evidence_dir), .knw_path_key(.knw_evidence_dir_default))) return("")
  tag <- basename(evidence_dir)
  if (!grepl("^[A-Za-z0-9][A-Za-z0-9_.]*$", tag)) {
    stop("an evidence directory's base name tags its ledger, so it takes letters, digits, `_` and `.` only: ",
         evidence_dir, call. = FALSE)
  }
  paste0("-", tag)
}

# the ledger 0310 writes for a directory on a day, or its refused twin
.knw_ledger_path <- function(evidence_dir, stamp, log_dir = "scripts/logs/habitat", refused = FALSE) {
  file.path(log_dir, paste0(stamp, if (refused) "_evidence_build_refused" else "_evidence_build_ledger",
                            .knw_evidence_tag(evidence_dir), ".csv"))
}

# the newest ledger written for a directory: what 0320 and the checks read when they score a build
.knw_evidence_ledger <- function(evidence_dir = .knw_evidence_dir_default, log_dir = "scripts/logs/habitat") {
  tag <- .knw_evidence_tag(evidence_dir)
  pat <- paste0("^[0-9]{8}_evidence_build_ledger", gsub(".", "\\.", tag, fixed = TRUE), "\\.csv$")
  f <- sort(list.files(log_dir, pat, full.names = TRUE), decreasing = TRUE)[1]
  if (is.na(f)) {
    stop("no evidence build ledger for ", evidence_dir, " in ", log_dir, ": run EVIDENCE_DIR=", evidence_dir,
         " scripts/0310 first", call. = FALSE)
  }
  led <- utils::read.csv(f, colClasses = "character", na.strings = "")
  named <- led$note[led$step %in% "evidence_dir"]
  # a ledger from before #120 names no directory: it was the default's
  if (length(named) > 1 || (length(named) == 1 && !identical(.knw_path_key(named), .knw_path_key(evidence_dir)))) {
    stop("the ledger ", f, " was written for ", paste(named, collapse = ", "), ", not ", evidence_dir,
         ": two evidence directories share a base name", call. = FALSE)
  }
  f
}
