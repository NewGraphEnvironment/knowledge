# data-raw/grade_tolerance_try.R
# ---------------------------------------------------------------------------
# Try inst/receipt/grade.yaml's tolerances on two real grade receipts (#165): crate's verdict as measured, then with
# each summary moved by half its tolerance (equivalent) and by three times it (different), and each count moved by one
# (different). The moves are made on the receipts as read, in memory; nothing is written.
#
# INPUT:  two run directories, each holding CH_rear_grades_receipt.json
# OUTPUT: printed; #165's run is scripts/logs/habitat/receipt_165/20261112_grade_tolerance_try.txt
# RUN:    Rscript data-raw/grade_tolerance_try.R <run dir a> <run dir b>   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages(pkgload::load_all(quiet = TRUE))
args <- commandArgs(trailingOnly = TRUE)
keys <- knw_receipt_keys("grade")
ra <- crate::crt_receipt_read(file.path(args[1], "CH_rear_grades_receipt.json"))
rb <- crate::crt_receipt_read(file.path(args[2], "CH_rear_grades_receipt.json"))
cat("declared:", paste(names(unlist(keys$tolerance$summary)), unlist(keys$tolerance$summary), collapse = " "), "\n")
td <- unlist(ra$result$tolerance$summary)
cat("receipts declare:", paste(names(td), td, collapse = " "), "\n")
cat("as measured:", crate::crt_receipt_compare(ra, rb, keys = keys)$verdict, "\n")
for (nm in names(keys$tolerance$summary)) {
  tol <- keys$tolerance$summary[[nm]]
  for (f in c(0.5, 3)) {
    b <- rb; b$result$summary[[nm]] <- b$result$summary[[nm]] + f * tol
    cat(sprintf("%-10s moved by %g x %g: %s\n", nm, f, tol, crate::crt_receipt_compare(ra, b, keys = keys)$verdict))
  }
}
for (nm in c("rows", "graded_rows")) {
  b <- rb; b$result$summary[[nm]] <- b$result$summary[[nm]] + 1L
  cat(sprintf("%-10s moved by 1: %s\n", nm, crate::crt_receipt_compare(ra, b, keys = keys)$verdict))
}
