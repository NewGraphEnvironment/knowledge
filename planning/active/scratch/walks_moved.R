# How the visits' walked distances moved from the v3 build (#57, centreline, flows of 2026-10-17; the local Parquet
# 0299 built on 2026-10-17) to the #73 rebuild (bank, gaps counted, flows of 2026-10-19), by cause.
suppressMessages({ library(dplyr); library(arrow) })
setwd("/Users/airvine/Projects/repo/knowledge")
old <- read_parquet("data/fdis/publish/walks.parquet") |> filter(src == "pick") |>
  select(blue_line_key, downstream_route_measure, qmin, status_old = status, dist_old = dist_m)
new <- readr::read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE) |> filter(src == "pick") |>
  select(blue_line_key, downstream_route_measure, qmin, status, dist_m, dist_centre_m, bank_m, max_entry_gap_m)
j <- inner_join(old, new, by = c("blue_line_key", "downstream_route_measure", "qmin"))
cat(sprintf("rows joined %d of old %d / new %d (pick)\n", nrow(j), nrow(old), nrow(new)))
both <- j |> filter(status_old == "found", status == "found") |>
  mutate(d_total = dist_m - dist_old, d_gap_or_flow = dist_centre_m - dist_old, d_bank = -bank_m)
cat("status changes:\n"); print(table(old = j$status_old, new = j$status))
for (q in c(1, 3, 10, 50)) {
  b <- both |> filter(qmin == q)
  cat(sprintf("Q%g: %d both found; total change median %.1f m (p10 %.1f, p90 %.1f); bank -median %.1f; centreline-with-gaps minus old median %.1f (p90 %.1f); |change| > 100 m on %.1f %%; crossing 1 km: %d down, %d up; crossing 2 km: %d down, %d up\n",
              q, nrow(b), median(b$d_total), quantile(b$d_total, .1), quantile(b$d_total, .9), median(b$bank_m),
              median(b$d_gap_or_flow), quantile(b$d_gap_or_flow, .9), 100 * mean(abs(b$d_total) > 100),
              sum(b$dist_old > 1000 & b$dist_m <= 1000), sum(b$dist_old <= 1000 & b$dist_m > 1000),
              sum(b$dist_old > 2000 & b$dist_m <= 2000), sum(b$dist_old <= 2000 & b$dist_m > 2000)))
}
