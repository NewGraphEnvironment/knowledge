# Summarise each data/tune/<key>_grades.csv as the research Grades table does. Args: output csv.
suppressPackageStartupMessages({library(readr); library(dplyr)})
fs <- list.files("data/tune", "_grades\\.csv$", full.names = TRUE)
out <- bind_rows(lapply(fs, function(f) {
  g <- read_csv(f, show_col_types = FALSE, col_select = any_of(c("watershed_group_code", "length_metre", "accessible", "grade", "grade_class", "dist_status")),
                col_types = cols(.default = "c", length_metre = "d", grade = "d", accessible = "l"))
  a <- g[g$accessible %in% TRUE, ]
  km <- a$length_metre / 1000
  gr <- !is.na(a$grade)
  tibble(key = sub("_grades\\.csv$", "", basename(f)), segments = nrow(g), groups = n_distinct(g$watershed_group_code),
         accessible_km = sum(km), graded_km = sum(km[gr]), weighted_km = sum(km[gr] * a$grade[gr]),
         under_0.2 = sum(km[gr & a$grade_class == "0-0.2"]) / sum(km[gr]),
         at_0.8_1 = sum(km[gr & a$grade_class == "0.8-1"]) / sum(km[gr]),
         has_dist_status = "dist_status" %in% names(g))
}))
print(as.data.frame(out), digits = 6)
write_csv(out, commandArgs(TRUE)[1])
