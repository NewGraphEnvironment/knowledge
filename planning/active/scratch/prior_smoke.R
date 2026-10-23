# The smoke run's four checks and each rule's largest coefficient on every key under a normal prior on the data_set
# and era coefficients (option A, Al 2026-10-23): none (Inf), SD 5, 2.5 (the default) and 1.5, from 0320's own
# inputs on the main seed. The measurement the prior is adopted on.
# run from the repo root: SCHEMA=fresh_default_20261017 Rscript planning/active/scratch/prior_smoke.R
# writes planning/active/scratch/prior_smoke.csv (checks), prior_smoke_rules.csv (the rules) and prior_smoke_lines.txt
Sys.setenv(SPECIES = "CH,CO,BT,GR,RB,ST,WCT")
source("planning/active/scratch/intercept_probe_head.R")
cat("loaded inputs", format(Sys.time(), tz = "UTC"), "\n")
previous <- character()
for (f in list.files("data/tune", "_tune\\.csv$", full.names = TRUE)) {
  r <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
  if ("recommended" %in% names(r) && sum(r$recommended == "TRUE") == 1L) {
    previous[sub("_tune\\.csv$", "", basename(f))] <- r$rule[r$recommended == "TRUE"]
  }
}
priors <- c(Inf, 5, 2.5, 1.5)
res <- lapply(priors, function(sd) {
  label <- if (is.finite(sd)) sprintf("sd%g", sd) else "none"
  t0 <- Sys.time()
  sm <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = 1L, thresholds_extra = thr_tuned,
                     previous = previous, smoke_only = TRUE, prior_sd = sd)
  cat(sprintf("%s: smoke over %d keys in %.1f min\n", label, length(sm), as.numeric(difftime(Sys.time(), t0, units = "mins"))))
  has <- names(sm)[!vapply(sm, function(x) is.null(x$smoke), logical(1))]
  list(checks = bind_rows(lapply(has, function(k) sm[[k]]$smoke$checks |> mutate(key = k, prior = label, prior_sd = sd, .before = 1))),
       rules = bind_rows(lapply(has, function(k) sm[[k]]$smoke$rules |>
                                  mutate(key = k, prior = label, prior_sd = sd, null_insample = sm[[k]]$smoke$null_insample, .before = 1))),
       lines = unlist(lapply(has, function(k) c(paste(label, k), sm[[k]]$smoke$lines))))
})
checks <- bind_rows(lapply(res, `[[`, "checks"))
rules <- bind_rows(lapply(res, `[[`, "rules"))
write_csv(checks, "planning/active/scratch/prior_smoke.csv")
write_csv(rules, "planning/active/scratch/prior_smoke_rules.csv")
writeLines(unlist(lapply(res, function(r) c(r$lines, ""))), "planning/active/scratch/prior_smoke_lines.txt")
print(checks |> group_by(key, prior) |> summarise(failed = paste(check[!pass], collapse = ","), pass = all(pass),
                                                   coef = value[check == "coef"], ratio = value[check == "null_ratio"], .groups = "drop") |>
        arrange(key, match(prior, c("none", "sd5", "sd2.5", "sd1.5"))) |> as.data.frame(), digits = 4)
print(rules |> filter(role == "previous" | (role == "default" & key %in% c("BT_spawn", "GR_rear"))) |>
        select(key, prior, role, rule, dev_heldout, ddev_null, coef_max, coef_max_term, coef_max_fold) |>
        arrange(key, match(prior, c("none", "sd5", "sd2.5", "sd1.5"))) |> as.data.frame(), digits = 5)
cat("DONE", format(Sys.time(), tz = "UTC"), "\n")
