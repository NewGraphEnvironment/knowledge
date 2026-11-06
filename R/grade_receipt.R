#' A grade table's provenance receipt
#'
#' Writes `<key>_grades_receipt.json` beside a grade table and its record
#' ([knw_grade_record_write()]), in crate's shared receipt shape
#' ([crate::crt_receipt_write()], #154): how the table was made (knowledge's
#' commit, the method register and the walk's SQL, the run's resolved
#' settings and fold seed, link's build, wet's flow load and the evidence
#' tables' sha256) and what came out (the pick, fingerprinted, and the table's
#' rows, graded rows, graded km and grade sum). A rebuild's receipt compared
#' with this one ([crate::crt_receipt_compare()], with
#' [knw_receipt_keys()]`("grade")`) answers identical, equivalent within the
#' declared tolerances, or different. The table's bytes are recorded, not
#' judged: a rebuild that sums in another order moves them and nothing a reader
#' decides on. The receipt carries no host, because it is tracked in a public
#' repository.
#'
#' The record is written first and read here, so the two describe one table:
#' the receipt refuses a table whose size is not the record's, evidence whose
#' md5s are not the record's, and a walk other than the one the record names,
#' and carries the record's `grades_md5` in its context, which is how 0320's
#' keep-check and promotion tie a receipt to a checked table without hashing
#' it again.
#'
#' @param grades_path `character(1)` the grade table, `<key>_grades.csv`.
#' @param grades a data frame of the table's `length_metre` and `grade`: the
#'   grades in hand when 0320 writes them, or those two columns read back.
#' @param spec the run's score settings for the key (`knw_tune_score()`'s
#'   `spec`: `fit`, `prior_sd`, `seed`, `folds`, `d_floor`, `extra`, `grad`).
#' @param min_wsg `integer(1)` the run's floor on groups with both outcomes.
#' @param evidence_dir `character(1)` the evidence directory the run read.
#' @param knowledge `list(commit, dirty)`: knowledge's full commit and whether
#'   its tracked package files or scripts differed from it, read at the run's
#'   start.
#' @return The receipt, as a list, invisibly.
#' @export
#' @examples
#' d <- tempfile(); dir.create(d)
#' ev <- file.path(d, "evidence"); dir.create(ev)
#' for (f in c("visits_link", "visits_species", "walks")) writeLines("x", file.path(ev, paste0(f, ".csv")))
#' ev_md5 <- paste(unname(tools::md5sum(file.path(ev, paste0(c("visits_link", "visits_species", "walks"),
#'                                                          ".csv")))), collapse = ";")
#' grades <- data.frame(id_segment = 1:3, length_metre = c(120, 300, 80), grade = c(0.1, 0.5, NA))
#' g <- file.path(d, "CH_rear_grades.csv")
#' utils::write.csv(cbind(grades, species_code = "CH", stage = "rear", rule = "r1", run_uid = "u1",
#'                        ref_population = "stream_branch", ref_edge = "1000", q_walk = 3, walk = "bank",
#'                        walk_md5 = knw_walk_md5(), discharge_load = "wet load", curve_prior_sd = 2.5,
#'                        grade_withheld = FALSE, null_heldout_curve = 1.5, evidence_md5 = ev_md5,
#'                        curve_grad = "segment_gradient"),
#'                  g, row.names = FALSE)
#' knw_grade_record_write(g, tune_run = "20261105_0000", evidence_ledger = "ledger.csv",
#'                        knowledge_commit = NA, link = c(version = "0.78.2", sha = strrep("b", 40)),
#'                        tokens = c(cut = NA, acc = NA, grad = NA, flow = NA), rows = 3)
#' spec <- list(fit = "gam", prior_sd = 2.5, seed = 54L, folds = 5L, d_floor = 200, extra = TRUE,
#'              grad = "segment_gradient")
#' r <- knw_grade_receipt_write(g, grades, spec, min_wsg = 5L, evidence_dir = ev,
#'                              knowledge = list(commit = strrep("a", 40), dirty = FALSE))
#' r$result$summary$km_graded
knw_grade_receipt_write <- function(grades_path, grades, spec, min_wsg, evidence_dir, knowledge) {
  chk::chk_file(grades_path)
  chk::chk_data(grades)
  chk::chk_whole_number(min_wsg)
  chk::chk_dir(evidence_dir)
  if (!all(c("length_metre", "grade") %in% names(grades))) stop("grades needs length_metre and grade", call. = FALSE)
  if (!is.list(spec) || !all(c("fit", "prior_sd", "seed", "folds", "d_floor", "extra", "grad") %in% names(spec))) {
    stop("spec names fit, prior_sd, seed, folds, d_floor, extra and grad (knw_tune_score()'s spec)", call. = FALSE)
  }
  rec <- knw_grade_record_read(.knw_grade_record_path(grades_path))
  # the record describes this table: its size is free to check, and the md5 the record holds is the table's
  if (!identical(format(file.size(grades_path), scientific = FALSE), rec$grades_bytes)) {
    stop(grades_path, " is not the table its record describes (size): write the record first", call. = FALSE)
  }
  if (!is.na(rec$grades_rows) && !identical(format(nrow(grades), scientific = FALSE), rec$grades_rows)) {
    stop("grades holds ", nrow(grades), " rows, the record's table ", rec$grades_rows, call. = FALSE)
  }
  if (!identical(spec$grad, rec$curve_grad)) {
    stop("the spec's gradient (", spec$grad, ") is not the curve's the table was graded with (", rec$curve_grad, ")",
         call. = FALSE)
  }
  # the walk is hashed as config from the installed SQL: the record's walk must be that one
  if (!identical(knw_walk_md5(), rec$walk_md5)) {
    stop("the table was walked by another walk (", rec$walk_md5, ") than this package's (", knw_walk_md5(), ")",
         call. = FALSE)
  }

  graded <- !is.na(grades$grade)
  pick <- data.frame(rule = rec$rule, ref_edge = rec$ref_edge, q_walk = as.numeric(rec$q_walk),
                     grade_withheld = rec$grade_withheld, null_heldout_curve = as.numeric(rec$null_heldout_curve),
                     stringsAsFactors = FALSE)
  settings <- lapply(list(species_code = rec$species_code, stage = rec$stage, fit = spec$fit, prior_sd = spec$prior_sd,
                          folds = spec$folds, min_wsg = min_wsg, d_floor = spec$d_floor, extra = spec$extra,
                          gradient = spec$grad), .knw_receipt_setting)
  inputs <- c(list(link_build = list(version_id = rec$run_uid), flow = list(version_id = rec$discharge_load)),
              .knw_receipt_evidence(evidence_dir, rec$evidence_md5))
  crate::crt_receipt_write(
    dirname(grades_path),
    output = list(name = "grade", scope = paste(rec$species_code, rec$stage, sep = "_")),
    recipe = list(code = .knw_receipt_code(knowledge),
                  config = list(files = .knw_receipt_config_files(c("settings", "walk")), settings = settings),
                  inputs = inputs, seed = spec$seed),
    result = list(tables = list(pick = pick), parts = basename(grades_path),
                  summary = list(rows = nrow(grades), graded_rows = sum(graded),
                                 km_graded = sum(grades$length_metre[graded]) / 1000,
                                 grade_sum = sum(grades$grade[graded]))),
    context = list(run = list(tune_run = rec$tune_run, run_uid = rec$run_uid, record_source = rec$record_source,
                              grades_md5 = rec$grades_md5),
                   inputs = list(link = list(version = rec$link_version, commit = rec$link_sha),
                                 evidence_md5 = rec$evidence_md5)),
    keys = knw_receipt_keys("grade"), lockfile = NULL, publish = TRUE,
    file = .knw_grade_receipt_name(grades_path)
  )
}

# data/tune/<key>_grades.csv -> <key>_grades_receipt.json, the receipt's file name in the table's directory
.knw_grade_receipt_name <- function(grades_path) {
  if (!grepl("_grades\\.csv$", grades_path)) stop("not a grade table: ", grades_path, call. = FALSE)
  sub("_grades\\.csv$", "_grades_receipt.json", basename(grades_path))
}
