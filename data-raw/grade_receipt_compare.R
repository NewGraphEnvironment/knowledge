# data-raw/grade_receipt_compare.R
# ---------------------------------------------------------------------------
# Compare two grade receipts that knowledge's own writer made (knw_grade_receipt_write(), through scripts/0320) for one
# key graded on two databases (#165), and measure what the grade declaration's tolerances must cover.
#
# crate's verdict comes from the two receipts and inst/receipt/grade.yaml alone: the pick and the summaries rows,
# graded_rows, km_graded and grade_sum. Where both grade tables are present it also measures, for km_graded and
# grade_sum, how far the sum moves when the same values are added in another order (ascending, descending, reversed),
# and the bound on that move, n x machine epsilon x the sum of absolute values: a tolerance finer than the bound can
# refuse a rebuild that changed nothing but the order its rows came back in. And it says how many segments' grade or
# length differ between the two tables, keyed on watershed_group_code and id_segment.
#
# INPUT:  two run directories (data/tune/candidate/<run>/ or a copy), each holding <KEY>_grades_receipt.json, its record
#         and, for the measurement, <KEY>_grades.csv
# OUTPUT: printed; #165's run is scripts/logs/habitat/receipt_165/<date>_grade_receipt_compare.txt
# RUN:    Rscript data-raw/grade_receipt_compare.R <run dir a> <run dir b>   (from the repo root; KEY=CH_rear default)
# ---------------------------------------------------------------------------
suppressMessages({ library(data.table); pkgload::load_all(quiet = TRUE) })
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("usage: Rscript data-raw/grade_receipt_compare.R <run dir a> <run dir b>")
key <- Sys.getenv("KEY", "CH_rear")
keys <- knw_receipt_keys("grade")
rp <- file.path(args, paste0(key, "_grades_receipt.json"))
gp <- file.path(args, paste0(key, "_grades.csv"))
if (!all(file.exists(rp))) stop("no receipt at ", paste(rp[!file.exists(rp)], collapse = ", "))
ra <- crate::crt_receipt_read(rp[1]); rb <- crate::crt_receipt_read(rp[2])

cat("key", key, "\n")
cat("recipe a", ra$recipe$recipe_id, "\nrecipe b", rb$recipe$recipe_id, "\n")
cat("same recipe:", identical(ra$recipe$recipe_id, rb$recipe$recipe_id), "\n")
cat("code a", ra$recipe$code$knowledge$commit, "dirty", ra$recipe$code$knowledge$dirty,
    "\ncode b", rb$recipe$code$knowledge$commit, "dirty", rb$recipe$code$knowledge$dirty, "\n")
cat("evidence a", unlist(ra$recipe$inputs$evidence), "\nevidence b", unlist(rb$recipe$inputs$evidence), "\n")
cmp <- crate::crt_receipt_compare(ra, rb, keys = keys)
cat("verdict:", cmp$verdict, "(mode", cmp$mode, ", register", cmp$register, ")\n")
print(as.data.frame(cmp$differences), right = FALSE)

sa <- unlist(ra$result$summary); sb <- unlist(rb$result$summary)
sm <- data.frame(summary = names(sa), a = sa, b = sb[names(sa)], diff = sb[names(sa)] - sa, row.names = NULL)
cat("\nsummaries (b - a):\n"); print(format(sm, digits = 17), right = FALSE)
cat("pick a:", paste(names(ra$result$fingerprint$pick), unlist(ra$result$fingerprint$pick), collapse = " "), "\n")
cat("pick b:", paste(names(rb$result$fingerprint$pick), unlist(rb$result$fingerprint$pick), collapse = " "), "\n")
cat("table md5 a", ra$context$run$grades_md5, "\ntable md5 b", rb$context$run$grades_md5,
    "\nsame bytes:", identical(ra$context$run$grades_md5, rb$context$run$grades_md5), "\n")

if (!all(file.exists(gp))) {
  cat("\nboth grade tables are needed for the order measurement; missing:", gp[!file.exists(gp)], "\n")
  quit(save = "no")
}
cols <- c("watershed_group_code", "id_segment", "length_metre", "grade")
ta <- fread(gp[1], select = cols); tb <- fread(gp[2], select = cols)

# the same values summed in another order, against the bound on how far order can move a sum
order_move <- function(x, label) {
  s <- c(file = sum(x), ascending = sum(sort(x)), descending = sum(sort(x, decreasing = TRUE)), reversed = sum(rev(x)))
  bound <- length(x) * .Machine$double.eps * sum(abs(x))
  data.frame(summary = label, n = length(x), sum = s[["file"]], max_order_move = max(abs(s - s[["file"]])),
             bound = bound, row.names = NULL)
}
om <- rbind(order_move(ta$length_metre[!is.na(ta$grade)] / 1000, "km_graded"),
            order_move(ta$grade[!is.na(ta$grade)], "grade_sum"))
cat("\nhow far the order of summing moves each sum (table a):\n"); print(format(om, digits = 6), right = FALSE)

m <- merge(ta, tb, by = c("watershed_group_code", "id_segment"), all = TRUE, suffixes = c(".a", ".b"))
cat("\nrows a", nrow(ta), "b", nrow(tb), "matched", sum(!is.na(m$length_metre.a) & !is.na(m$length_metre.b)), "\n")
dg <- with(m, xor(is.na(grade.a), is.na(grade.b)) | (!is.na(grade.a) & !is.na(grade.b) & grade.a != grade.b))
dl <- with(m, xor(is.na(length_metre.a), is.na(length_metre.b)) |
  (!is.na(length_metre.a) & !is.na(length_metre.b) & length_metre.a != length_metre.b))
cat("segments whose grade differs:", sum(dg), " max |grade diff|:",
    suppressWarnings(max(abs(m$grade.a - m$grade.b), na.rm = TRUE)), "\n")
cat("segments whose length differs:", sum(dl), "\n")
cat("same row order:",
    identical(ta$id_segment, tb$id_segment) && identical(ta$watershed_group_code, tb$watershed_group_code), "\n")
