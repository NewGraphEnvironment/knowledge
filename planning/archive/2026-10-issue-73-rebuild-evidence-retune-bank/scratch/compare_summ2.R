suppressPackageStartupMessages(library(dplyr))
keys <- strsplit(Sys.getenv("KEYS", "CO_rear"), ",")[[1]]
options(width = 200)
for (k in keys) {
  cat("\n=========", k, "\n")
  cmp <- readr::read_csv(file.path("data/compare", paste0(k, "_compare.csv")), show_col_types = FALSE, guess_max = 1e5)
  chg <- readr::read_csv(file.path("data/compare", paste0(k, "_change.csv")), show_col_types = FALSE, guess_max = 1e5)
  f <- file.path("data/compare", paste0(k, "_checks.csv"))
  chk <- if (file.exists(f)) readr::read_csv(f, show_col_types = FALSE) else NULL
  cat("config_sha:", unique(cmp$config_sha), " default:", unique(cmp$default_rule), " tuned:", unique(cmp$tuned_rule), " tuned_structure:", unique(cmp$tuned_structure), "\n")
  cat("groups:", n_distinct(cmp$watershed_group_code) - 1, "\n")
  all <- cmp |> filter(watershed_group_code == "ALL")
  cat("-- totals by structure\n")
  print(as.data.frame(all |> select(structure, accessible_km, access_gate_differ_km, stored_km, default_km, stored_vs_default_differ_km, tuned_km, change_pct, gained_km, lost_km, kept_km, gained_exception_km, gained_exception_other_group_km, default_graded_km, tuned_graded_km, graded_na_km)))
  cat("-- km by class, by structure\n")
  print(as.data.frame(all |> select(structure, matches("_km_0"))))
  cat("-- change reasons (km) by structure and direction\n")
  print(as.data.frame(chg |> group_by(structure, direction, reason) |> summarise(km = round(sum(km), 1), n = sum(n_segments), km_o1 = round(sum(km[order == 1]), 1), .groups = "drop") |> arrange(structure, direction, desc(km))))
  cat("-- gained km by stream order, by structure\n")
  print(as.data.frame(chg |> filter(direction == "gained") |> group_by(structure, order) |> summarise(km = round(sum(km), 1), .groups = "drop") |> tidyr::pivot_wider(names_from = order, values_from = km)))
  cat("-- per-group change_pct spread (tuned structure)\n")
  per <- cmp |> filter(watershed_group_code != "ALL", structure == tuned_structure)
  print(summary(per$change_pct))
  cat("groups gaining:", sum(per$tuned_km > per$default_km), " losing:", sum(per$tuned_km < per$default_km), " default 0 km:", sum(per$default_km == 0), " tuned 0 km:", sum(per$tuned_km == 0), "\n")
  cat("largest gains / losses (km):\n")
  print(as.data.frame(per |> mutate(d = tuned_km - default_km) |> arrange(d) |> select(watershed_group_code, default_km, tuned_km, d, change_pct) |> slice(c(1:5, (n() - 4):n()))))
  if (!is.null(chk)) { cat("-- checks\n"); print(as.data.frame(chk)) }
}
