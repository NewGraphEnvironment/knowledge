# The smoke run's four checks on every key under three intercept searches, from 0320's own inputs: #84's mutation
# table. 84c3c78 is a golden section of the deviance on [-30, 30]; ca78ca6 the same centred on the group's offsets;
# HEAD the root of the deviance's derivative.
# run from the repo root: SCHEMA=fresh_default_20261017 Rscript planning/active/scratch/smoke_mutation.R
# writes planning/active/scratch/smoke_mutation.csv (checks) and smoke_mutation_rules.csv (the rules' numbers)
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
ns <- asNamespace("knowledge")
now_fn <- get(".tune_group_dev", ns)
from_git <- function(sha) {
  env <- new.env()
  eval(parse(text = system2("git", c("show", paste0(sha, ":R/tune_score.R")), stdout = TRUE)), envir = env)
  fn <- get(".tune_group_dev", env)
  environment(fn) <- ns
  fn
}
versions <- list(`84c3c78` = from_git("84c3c78"), ca78ca6 = from_git("ca78ca6"), HEAD = now_fn)
stopifnot(length(unique(lapply(versions, body))) == 3L)
run_with <- function(fn, label) {
  unlockBinding(".tune_group_dev", ns); assign(".tune_group_dev", fn, envir = ns); lockBinding(".tune_group_dev", ns)
  t0 <- Sys.time()
  sm <- knw_tune_run(vl, vs, walks, thr, species = species, spawner = spawner, workers = 1L, thresholds_extra = thr_tuned,
                     previous = previous, smoke_only = TRUE)
  cat(sprintf("%s: smoke over %d keys in %.1f min\n", label, length(sm), as.numeric(difftime(Sys.time(), t0, units = "mins"))))
  list(checks = bind_rows(lapply(names(sm), function(k) if (is.null(sm[[k]]$smoke)) NULL else
    sm[[k]]$smoke$checks |> mutate(key = k, scorer = label, .before = 1))),
    rules = bind_rows(lapply(names(sm), function(k) if (is.null(sm[[k]]$smoke)) NULL else
      sm[[k]]$smoke$rules |> mutate(key = k, scorer = label, null_insample = sm[[k]]$smoke$null_insample, .before = 1))),
    lines = unlist(lapply(names(sm), function(k) if (is.null(sm[[k]]$smoke)) NULL else c(paste(label, k), sm[[k]]$smoke$lines))))
}
per_key_time <- function(fn, label) {
  unlockBinding(".tune_group_dev", ns); assign(".tune_group_dev", fn, envir = ns); lockBinding(".tune_group_dev", ns)
  bind_rows(lapply(species, function(sp) {
    t0 <- Sys.time()
    sm <- knw_tune_run(vl, vs, walks, thr, species = sp, spawner = spawner, workers = 1L, thresholds_extra = thr_tuned,
                       previous = previous, smoke_only = TRUE)
    tibble(scorer = label, species_code = sp, minutes = as.numeric(difftime(Sys.time(), t0, units = "mins")),
           keys = paste(names(sm)[!vapply(sm, function(x) is.null(x$smoke), logical(1))], collapse = ","))
  }))
}
tm_now <- per_key_time(now_fn, "HEAD")
print(as.data.frame(tm_now))
res <- lapply(names(versions), function(v) run_with(versions[[v]], v))
unlockBinding(".tune_group_dev", ns); assign(".tune_group_dev", now_fn, envir = ns); lockBinding(".tune_group_dev", ns)
write_csv(bind_rows(lapply(res, `[[`, "checks")), "planning/active/scratch/smoke_mutation.csv")
write_csv(bind_rows(lapply(res, `[[`, "rules")), "planning/active/scratch/smoke_mutation_rules.csv")
write_csv(tm_now, "planning/active/scratch/smoke_mutation_minutes.csv")
writeLines(unlist(lapply(res, function(r) c(r$lines, ""))), "planning/active/scratch/smoke_mutation_lines.txt")
cat("DONE", format(Sys.time(), tz = "UTC"), "\n")
