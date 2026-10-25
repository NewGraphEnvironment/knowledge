# Score every rule of each key on the main fold seed alone, with one fit, into its own cache directory: the dense
# reference for #83 (FIT=dense on 8a20461, before the fit changed) and the group-absorbing fit's reproduction of it
# (FIT=fe), compared by compare_fit.R. Smoke off: the reference is about the fit, and the gates refuse GR, RB, ST, WCT.
# EXTRA=1 keeps the bootstrap, nested selection and extra seeds (the full run's cost, for timing rainbow against the
# 8.1 h of 2026-10-23) and writes under ref_<fit>_extra.
# run from the repo root: SCHEMA=fresh_default_20261017 FIT=dense SPECIES=CH,CO,BT,GR,ST,WCT WORKERS=6 Rscript planning/active/scratch/ref_fit.R
fit <- Sys.getenv("FIT", "dense")
extra <- Sys.getenv("EXTRA", "") %in% c("1", "TRUE", "true")
Sys.setenv(SPECIES = Sys.getenv("SPECIES", "CH,CO,BT,GR,ST,WCT"))
source("planning/active/scratch/intercept_probe_head.R")
dir_out <- file.path("data/tune", paste0("ref_", fit, if (extra) "_extra" else ""))
dir.create(dir_out, showWarnings = FALSE, recursive = TRUE)
cat("loaded inputs", format(Sys.time(), tz = "UTC"), "fit", fit, "workers", workers, "\n")
args <- list(vl, vs, walks, thr, spawner = spawner, workers = workers, thresholds_extra = thr_tuned, cache_dir = dir_out,
             smoke = FALSE, extra = extra)
if ("fit" %in% names(formals(knw_tune_run))) args$fit <- fit else stopifnot(fit == "dense")
rows <- list()
for (sp in species) {
  t0 <- Sys.time()
  out <- do.call(knw_tune_run, c(args, list(species = sp)))
  for (k in names(out)) {
    r <- out[[k]]
    if (is.null(r$score)) next
    rows[[k]] <- tibble(key = k, fit = fit, extra = extra, workers = workers, minutes = as.numeric(difftime(Sys.time(), t0, units = "mins")),
                        patterns = r$score$population[["patterns"]], not_converged = r$score$population[["not_converged"]],
                        rule_recommended = r$pick$rule, dev_null = r$score$rules$dev_heldout[1] - r$score$rules$ddev_null[1],
                        dev_best = min(r$score$rules$dev_heldout), curve_heldout = if (is.null(r$curve)) NA_real_ else r$curve$heldout)
    cat(sprintf("%s: %s, %.1f min, %d patterns, %d not converged, recommended %s, curve %.1f\n", k, fit,
                rows[[k]]$minutes, rows[[k]]$patterns, rows[[k]]$not_converged, r$pick$rule, rows[[k]]$curve_heldout))
  }
}
write_csv(bind_rows(rows), file.path(dir_out, "timing.csv"))
cat("DONE", format(Sys.time(), tz = "UTC"), "\n")
