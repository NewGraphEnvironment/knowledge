# One-time check (plan review O4): today's knw_compare_rules(), on link's configs at the run's sha, reproduces
# #65's default km per group, before the function is edited for #73. CH rearing on two groups.
suppressMessages({ library(dplyr); library(readr) })
# run from the repo root
pkgload::load_all(quiet = TRUE)
Sys.setenv(PGCONNECT_TIMEOUT = "30")
pg <- function() DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
link_repo <- "../link"
led <- read_csv(sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1],
                show_col_types = FALSE, col_types = cols(.default = "c"))
link_sha <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]][1]
link_dir <- file.path(tempdir(), paste0("link_default_", substr(link_sha, 1, 7)))
dir.create(file.path(link_dir, "overrides"), showWarnings = FALSE, recursive = TRUE)
for (p in c("parameters_habitat_thresholds.csv", "rules.yaml", "parameters_fresh.csv", "overrides/user_habitat_classification.csv")) {
  st <- system2("git", c("-C", link_repo, "show", paste0(link_sha, ":inst/extdata/configs/default/", p)), stdout = file.path(link_dir, p))
  stopifnot(identical(st, 0L))
}
cv <- readRDS("data/tune/CH_rear_curve.rds")
grades <- read_csv("data/tune/CH_rear_grades.csv", show_col_types = FALSE, guess_max = 1e5,
                   col_select = c("id_segment", "watershed_group_code", "size", "dist_m", "grade", "grade_class"))
groups <- c("ADMS", "BULK")
t0 <- Sys.time()
cmp <- knw_compare_rules(pg, "fresh_default", "CH", "rear", cv$pick, groups, link_dir, grades, scratch = "knw_cmp_o4")
cat(sprintf("compared in %.1f min; fresh %s; link configs at %s\n", as.numeric(difftime(Sys.time(), t0, units = "mins")),
            as.character(packageVersion("fresh")), link_sha))
saved <- read_csv("data/compare/CH_rear_compare.csv", show_col_types = FALSE) |> filter(watershed_group_code %in% groups)
j <- cmp$compare |> filter(watershed_group_code %in% groups) |> select(watershed_group_code, default_km, tuned_km) |>
  inner_join(saved |> select(watershed_group_code, default_km_saved = default_km, tuned_km_saved = tuned_km), by = "watershed_group_code") |>
  mutate(d_default = default_km - default_km_saved, d_tuned = tuned_km - tuned_km_saved)
print(as.data.frame(j), digits = 8)
cat(if (all(abs(j$d_default) < 1e-3) && all(abs(j$d_tuned) < 1e-3)) "O4 CHECK PASSED: default and tuned km reproduce #65's\n" else "O4 CHECK FAILED\n")
