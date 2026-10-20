# #65: every comparison figure the research files quote, #57's (origin/main) against #65's (working tree).
# Run from the repo root after 0330: Rscript planning/archive/2026-10-issue-65-grade-walks-every-segment/compare_before_after.R
suppressPackageStartupMessages({ library(dplyr); library(readr) })
rd_main <- function(f) read_csv(I(paste(system2("git", c("show", paste0("origin/main:", f)), stdout = TRUE), collapse = "\n")),
                                show_col_types = FALSE)
rd_now <- function(f) read_csv(f, show_col_types = FALSE)
f0 <- function(x) format(round(x), big.mark = ",")
both <- function(f, fun) list(old = fun(rd_main(f)), new = fun(rd_now(f)))

cat("== km by rule, all groups (compare.csv ALL rows)\n")
cmp <- both("data/compare/compare.csv", function(d) d[d$watershed_group_code == "ALL", ])
k <- paste(cmp$new$species_code, cmp$new$stage)
for (i in seq_len(nrow(cmp$new))) {
  o <- cmp$old[i, ]; n <- cmp$new[i, ]
  stopifnot(o$species_code == n$species_code, o$stage == n$stage)
  cat(sprintf("%-9s default %s | tuned %s -> %s | change %.1f -> %.1f %% | lost %s -> %s | gained %s -> %s | graded %s -> %s  =>  %s -> %s\n",
              k[i], f0(n$default_km), f0(o$tuned_km), f0(n$tuned_km), o$change_pct, n$change_pct, f0(o$lost_km), f0(n$lost_km),
              f0(o$gained_km), f0(n$gained_km), f0(o$default_graded_km), f0(o$tuned_graded_km), f0(n$default_graded_km),
              f0(n$tuned_graded_km)))
}

cat("\n== change by reason (km), old -> new\n")
ch <- both("data/compare/change.csv", function(d) d |> group_by(species_code, stage, direction, reason) |>
             summarise(km1 = sum(km[order == "1"]), km = sum(km), .groups = "drop"))
j <- full_join(ch$old, ch$new, by = c("species_code", "stage", "direction", "reason"), suffix = c("_o", "_n"))
for (i in seq_len(nrow(j))) cat(sprintf("%-3s %-5s %-6s %-45s %9s -> %9s (order 1: %s -> %s)\n", j$species_code[i], j$stage[i],
                                        j$direction[i], j$reason[i], f0(j$km_o[i]), f0(j$km_n[i]), f0(j$km1_o[i]), f0(j$km1_n[i])))

cat("\n== checks: FDIS detection share on / off each rule's segments, and the bcfishobs outside lift\n")
chk <- both("data/compare/checks.csv", function(d) d)
for (w in c("old", "new")) {
  d <- chk[[w]]
  fd <- d[d$check == "fdis_visits", ] |> mutate(rate = n_detect / n) |>
    select(species_code, stage, rule, segment, rate) |>
    tidyr::pivot_wider(names_from = c(rule, segment), values_from = rate)
  bo <- d[d$check == "bcfishobs_outside" & d$rule %in% c("default", "tuned"), c("species_code", "stage", "rule", "lift")] |>
    tidyr::pivot_wider(names_from = rule, values_from = lift, names_prefix = "lift_")
  cat(w, "\n")
  print(as.data.frame(left_join(fd, bo, by = c("species_code", "stage"))), digits = 3)
}

cat("\n== floodplain (catalog groups): ha and graded ha beside each rule's habitat, summed over groups\n")
fp <- both("data/compare/floodplain.csv", function(d) d |> group_by(species_code, stage, rule) |>
             summarise(groups = n_distinct(watershed_group_code), ha = sum(ha), graded_ha = sum(graded_ha), .groups = "drop"))
j <- full_join(fp$old, fp$new, by = c("species_code", "stage", "rule"), suffix = c("_o", "_n"))
for (i in seq_len(nrow(j))) cat(sprintf("%-3s %-5s %-10s groups %d | ha %s -> %s | graded ha %s -> %s\n", j$species_code[i], j$stage[i],
                                        j$rule[i], j$groups_n[i], f0(j$ha_o[i]), f0(j$ha_n[i]), f0(j$graded_ha_o[i]), f0(j$graded_ha_n[i])))
