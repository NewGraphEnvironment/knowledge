suppressPackageStartupMessages(library(dplyr)); options(width = 200)
for (k in strsplit(Sys.getenv("KEYS"), ",")[[1]]) {
  cv <- readr::read_csv(file.path("data/tune", paste0(k, "_curves.csv")), show_col_types = FALSE)
  cat("\n=====", k, unique(cv$rule), "\n")
  print(as.data.frame(cv |> group_by(curve) |> slice(unique(round(seq(1, n(), length.out = 16)))) |> select(curve, x, rate, rel_rate, rel_lo, rel_hi, threshold) |> ungroup()))
}
