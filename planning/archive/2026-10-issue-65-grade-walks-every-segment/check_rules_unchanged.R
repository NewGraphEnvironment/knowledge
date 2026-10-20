# #65 Phase 2: the regrade may move only grade-derived columns. Run from the repo root after 0330.
# Compares every tracked data/compare table against origin/main's copy.
suppressPackageStartupMessages(library(readr))
rd_main <- function(f) {
  txt <- system2("git", c("show", paste0("origin/main:", f)), stdout = TRUE)
  read_csv(I(paste(txt, collapse = "\n")), show_col_types = FALSE, col_types = cols(.default = "c"))
}
rd_now <- function(f) read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
files <- system2("git", c("ls-files", "data/compare"), stdout = TRUE)
files <- files[grepl("\\.csv$", files) & !grepl("/grad_ext/", files)]
grade_col <- function(n) grepl("graded|grade_na|_km_[0-9]|^ha_[0-9]", n)
bad <- character()
for (f in files) {
  a <- rd_main(f)
  b <- rd_now(f)
  if (!identical(names(a), names(b))) { bad <- c(bad, paste(f, "columns differ")); next }
  if (nrow(a) != nrow(b)) { bad <- c(bad, paste(f, "rows", nrow(a), "->", nrow(b))); next }
  keep <- names(a)[!grade_col(names(a))]
  for (k in keep) if (!identical(a[[k]], b[[k]])) bad <- c(bad, sprintf("%s: %s moved (%d cells)", f, k, sum(a[[k]] != b[[k]], na.rm = TRUE)))
  moved <- names(a)[grade_col(names(a))]
  moved <- moved[vapply(moved, function(k) !identical(a[[k]], b[[k]]), logical(1))]
  cat(sprintf("%-40s rule columns %s; grade columns moved: %d of %d\n", f,
              if (any(startsWith(bad, f))) "MOVED" else "same", length(moved), sum(grade_col(names(a)))))
}
if (length(bad)) { cat("\nFAIL\n", paste(bad, collapse = "\n"), "\n"); quit(status = 1) }
cat("\nPASS: every non-grade column of every tracked compare table equals origin/main's\n")
