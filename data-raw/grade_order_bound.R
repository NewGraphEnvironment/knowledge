# data-raw/grade_order_bound.R
# ---------------------------------------------------------------------------
# How far the order of summing can move a grade receipt's km_graded and grade_sum (#165), for every grade table in a
# directory and for their union (the published grade set's summaries). A database can return a key's segments in
# another order, and a float sum taken in another order lands elsewhere: for each sum this gives the largest move
# seen over four orders (as written, ascending, descending, reversed) and the bound on any order's move,
# n x machine epsilon x the sum of absolute values. inst/receipt/grade.yaml and habitat_grade.yaml set their
# tolerances above the bound of the largest key and of the set. Read-only.
#
# INPUT:  a directory of <key>_grades.csv (the published tables: data/tune/ on a checkout holding them)
# OUTPUT: printed; #165's run is scripts/logs/habitat/receipt_165/20261112_grade_order_bound.txt
# RUN:    Rscript data-raw/grade_order_bound.R data/tune   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages(library(data.table))
fs <- sort(list.files(commandArgs(trailingOnly = TRUE)[1], "_grades\\.csv$", full.names = TRUE))
one <- function(x, label, key) {
  s <- c(file = sum(x), asc = sum(sort(x)), desc = sum(sort(x, decreasing = TRUE)), rev = sum(rev(x)))
  data.table(output = key, summary = label, n = length(x), sum = s[["file"]],
             max_order_move = max(abs(s - s[["file"]])), bound = length(x) * .Machine$double.eps * sum(abs(x)))
}
km_all <- c(); g_all <- c(); out <- list()
for (f in fs) {
  k <- sub("_grades\\.csv$", "", basename(f))
  t <- fread(f, select = c("length_metre", "grade"))
  g <- !is.na(t$grade)
  km <- t$length_metre[g] / 1000; gr <- t$grade[g]
  out[[length(out) + 1]] <- one(km, "km_graded", k); out[[length(out) + 1]] <- one(gr, "grade_sum", k)
  km_all <- c(km_all, km); g_all <- c(g_all, gr)
  cat(k, "rows", nrow(t), "graded", sum(g), "\n")
}
out[[length(out) + 1]] <- one(km_all, "km_graded", "published set")
out[[length(out) + 1]] <- one(g_all, "grade_sum", "published set")
r <- rbindlist(out)
print(format(r, digits = 6), right = FALSE)
