#' An evidence build's provenance receipt
#'
#' Writes `evidence_receipt.json` into an evidence directory, beside the tables
#' `scripts/0310` builds there, in crate's shared receipt shape
#' ([crate::crt_receipt_write()], #160): how the build was made (knowledge's
#' commit, the method register and the walk's SQL, the build's settings, link's
#' build, wet's flow load, the FDIS extract and its load, and the tracked tables
#' it reads) and what came out (every table, fingerprinted, the placed visits
#' and `access_check`'s km). The declaration ([knw_receipt_keys()]`("evidence")`)
#' holds every table exact but `access_check`'s km, which a database summing in
#' another order moves in the last place, so a rebuild compared with this
#' receipt ([crate::crt_receipt_compare()]) answers identical, equivalent, or
#' different. A grade graded on the build names it by this receipt's
#' `recipe_id` ([knw_grade_receipt_write()]), so an equivalent rebuild of the
#' evidence is the same input to every grade. The receipt carries no host,
#' because the evidence it describes is public.
#'
#' The tables are read back from their CSVs as text, as a reader gets them,
#' with `access_check`'s km read as a number.
#'
#' @param evidence_dir `character(1)` the evidence directory, holding the
#'   seven tables the declaration fingerprints.
#' @param settings a named list of the build's settings the declaration lists:
#'   `species`, `q_grid`, `sources`, `snap_limit_m`, `snap_limit_code_m`,
#'   `parent`.
#' @param inputs a named list of the inputs the declaration lists, each in
#'   crate's form (`list(version_id = )`, `list(sha256 = )`, `list(none = )`).
#' @param knowledge `list(commit, dirty)`: knowledge's full commit and whether
#'   its tracked package files or scripts differed from it, read at the build's
#'   start (`.knw_git_state()`).
#' @param context a named list carried into the receipt's context (the run's
#'   identifiers, link's version and commit); never part of its identity.
#' @return The receipt, as a list, invisibly.
#' @export
#' @examples
#' ev <- tempfile(); dir.create(ev)
#' tbl <- c("visits_link", "visits_species", "walks", "bcfishobs_fdis_match", "workbook_sites", "workbook_species")
#' for (f in tbl) utils::write.csv(data.frame(site_visit = c("a", "b")), file.path(ev, paste0(f, ".csv")),
#'                                 row.names = FALSE)
#' utils::write.csv(data.frame(species_code = "BT", km = 787407.1195799585), file.path(ev, "access_check.csv"),
#'                  row.names = FALSE)
#' inputs <- lapply(stats::setNames(nm = knw_receipt_keys("evidence")$inputs), function(i) list(version_id = "x"))
#' settings <- list(species = c("BT", "CH"), q_grid = c(1, 3), sources = "pick", snap_limit_m = 100,
#'                  snap_limit_code_m = 150, parent = "none")
#' r <- knw_evidence_receipt_write(ev, settings, inputs, knowledge = list(commit = strrep("a", 40), dirty = FALSE))
#' r$result$summary$visits
#' r$recipe$recipe_id
knw_evidence_receipt_write <- function(evidence_dir, settings, inputs, knowledge, context = list()) {
  .knw_receipt_crate_check()
  chk::chk_dir(evidence_dir)
  chk::chk_list(settings)
  chk::chk_list(inputs)
  chk::chk_list(context)
  keys <- knw_receipt_keys("evidence")
  f <- stats::setNames(file.path(evidence_dir, paste0(keys$tables, ".csv")), keys$tables)
  if (!all(file.exists(f))) {
    stop(evidence_dir, " lacks ", paste(basename(f[!file.exists(f)]), collapse = ", "), call. = FALSE)
  }
  tables <- .knw_receipt_csv_tables(f, keys)
  # a vector setting stays an array however long it is, so one species is not written as a scalar
  arrays <- c("species", "q_grid", "sources")
  settings <- lapply(stats::setNames(names(settings), names(settings)), function(nm) {
    v <- .knw_receipt_setting(settings[[nm]])
    if (nm %in% arrays) I(v) else v
  })
  crate::crt_receipt_write(
    evidence_dir,
    output = list(name = "evidence"),
    recipe = list(code = .knw_receipt_code(knowledge),
                  config = list(files = .knw_receipt_config_files(c("settings", "walk")), settings = settings),
                  inputs = inputs, seed = NULL),
    result = list(tables = tables, parts = stats::setNames(basename(f), keys$tables),
                  summary = list(visits = nrow(tables$visits_link),
                                 access_km = sum(tables$access_check$km, na.rm = TRUE))),
    context = context,
    keys = keys, lockfile = NULL, publish = TRUE, file = .knw_evidence_receipt_file
  )
}

# The evidence receipt's name in its directory: 0310 writes it, 0320's grade receipts and 0299 name the build by its
# recipe_id, and the archive stores it with the build
.knw_evidence_receipt_file <- "evidence_receipt.json"

# The sha256 of several files as one input (#160: the FISS workbooks 0310 reads, link's default configs): the sha256
# of a manifest, one line per file, its sha256 and its path relative to `root`, in that path's order, so the same files
# at the same relative paths give the same value wherever they sit (a package's library path is not the configs)
.knw_sha256_files <- function(paths, root = NULL) {
  if (!length(paths) || !all(file.exists(paths))) {
    stop("no files, or a file missing, to hash: ", paste(paths[!file.exists(paths)], collapse = ", "), call. = FALSE)
  }
  rel <- if (is.null(root)) paths else {
    pre <- paste0(sub("/+$", "", root), "/")
    if (!all(startsWith(paths, pre))) stop("a file to hash is not under ", root, call. = FALSE)
    substring(paths, nchar(pre) + 1L)
  }
  o <- order(rel, method = "radix")
  man <- tempfile(fileext = ".txt")
  on.exit(unlink(man))
  writeLines(paste(vapply(paths[o], .knw_sha256, character(1)), rel[o], sep = "  "), man, useBytes = TRUE)
  .knw_sha256(man)
}

# An evidence build's recipe_id, from the receipt 0310 wrote in its directory, or NULL where there is none (a build
# from before #160). A receipt that does not describe the tables in the directory is refused, never passed over for the
# md5 fallback: it is another build's, or the tables were replaced after it was written. `tables` are the ones the
# caller reads: a grade the three visit tables, 0299 every evidence table it publishes
.knw_evidence_recipe_id <- function(evidence_dir, tables = c("visits_link", "visits_species", "walks")) {
  path <- file.path(evidence_dir, .knw_evidence_receipt_file)
  if (!file.exists(path)) return(NULL)
  r <- crate::crt_receipt_read(path)
  if (!identical(r$output$name, "evidence")) stop(path, " is not an evidence build's receipt", call. = FALSE)
  for (tb in tables) {
    f <- paste0(tb, ".csv")
    held <- r$result$parts[[f]]$sha256
    if (is.null(held) || !identical(held, .knw_sha256(file.path(evidence_dir, f)))) {
      stop(path, " does not describe ", file.path(evidence_dir, f), ": either the receipt is another build's (left ",
           "beside tables restored or copied in: move it aside) or the table was replaced after it (rebuild the ",
           "evidence, scripts/0310)", call. = FALSE)
    }
  }
  if (!is.character(r$recipe$recipe_id) || !grepl("^[0-9a-f]{64}$", r$recipe$recipe_id)) {
    stop(path, " names no recipe_id", call. = FALSE)
  }
  r$recipe$recipe_id
}
