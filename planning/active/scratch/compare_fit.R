# The group-absorbing fit against the dense reference (#83): every rule's held-out deviance, convergence flag, pick
# and recommended rule per key, from the two ref_fit.R runs' caches, and their timings side by side.
# run from the repo root: Rscript planning/active/scratch/compare_fit.R
suppressMessages({ library(dplyr); library(readr) })
keys <- sub("_score\\.rds$", "", basename(list.files("data/tune/ref_dense", "_score\\.rds$")))
rows <- lapply(keys, function(k) {
  fe_path <- file.path("data/tune/ref_fe", paste0(k, "_score.rds"))
  if (!file.exists(fe_path)) return(NULL)
  a <- readRDS(file.path("data/tune/ref_dense", paste0(k, "_score.rds")))
  b <- readRDS(fe_path)
  stopifnot(identical(a$rules$rule, b$rules$rule))
  dd <- abs(b$rules$dev_heldout - a$rules$dev_heldout)
  tibble(key = k, rules = nrow(a$rules), patterns = a$population[["patterns"]],
         max_abs_ddev = max(dd), max_rel_ddev = max(dd / pmax(a$rules$dev_heldout, 1)),
         rules_over_1e6 = sum(dd > 1e-6),
         converged_same = identical(a$rules$converged, b$rules$converged),
         not_converged_dense = sum(!a$rules$converged), not_converged_fe = sum(!b$rules$converged),
         region_same = identical(a$rules$in_region, b$rules$in_region),
         pick_same = identical(a$rules$pick, b$rules$pick), recommended_same = identical(a$rules$recommended, b$rules$recommended),
         recommended_dense = a$rules$rule[a$rules$recommended], recommended_fe = b$rules$rule[b$rules$recommended],
         folds_same = identical(a$folds, b$folds))
})
cmp <- bind_rows(rows)
tm <- bind_rows(read_csv("data/tune/ref_dense/timing.csv", show_col_types = FALSE),
                read_csv("data/tune/ref_fe/timing.csv", show_col_types = FALSE)) |>
  select(key, fit, workers, minutes, curve_heldout) |>
  tidyr::pivot_wider(names_from = fit, values_from = c(workers, minutes, curve_heldout))
out <- cmp |> left_join(tm, by = "key")
write_csv(out, "planning/active/scratch/fit_compare.csv")
print(as.data.frame(out), digits = 4, right = FALSE)
