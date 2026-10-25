Sys.setenv(SPECIES = "CH", WORKERS = "1")
source("planning/active/scratch/intercept_probe_head.R")
small <- list(grid_grad = c(0.0549, 0.13), grid_q = 3, grid_d = 1000)
ns <- asNamespace("knowledge")
orig <- get(".tune_glm_fe", ns)
cnt <- c(calls = 0L, fallback = 0L, iter = 0L)
wrap <- function(...) { m <- orig(...); cnt[["calls"]] <<- cnt[["calls"]] + 1L; cnt[["iter"]] <<- cnt[["iter"]] + m$iter
  if (m$fallback) cnt[["fallback"]] <<- cnt[["fallback"]] + 1L; m }
assignInNamespace(".tune_glm_fe", wrap, "knowledge")
args <- list(vl, vs, walks, thr, spawner = spawner, workers = 1L, thresholds_extra = thr_tuned, smoke = FALSE, extra = FALSE,
             species = "CH", stages = "rear", grid_args = small)
for (fit in c("dense", "fe", "dense", "fe")) {
  cnt[] <- 0L
  t0 <- Sys.time()
  if (fit == "fe") Rprof(file.path(Sys.getenv("S"), "fe.prof"), interval = 0.01)
  out <- do.call(knw_tune_run, c(args, list(fit = fit)))
  if (fit == "fe") Rprof(NULL)
  r <- out$CH_rear
  cat(sprintf("%s: %.1f s, %d patterns, %d not converged, fe calls %d, fallbacks %d, mean iter %.1f\n", fit,
              as.numeric(difftime(Sys.time(), t0, units = "secs")), r$score$population[["patterns"]],
              r$score$population[["not_converged"]], cnt[["calls"]], cnt[["fallback"]], cnt[["iter"]] / max(1, cnt[["calls"]])))
}
p <- summaryRprof(file.path(Sys.getenv("S"), "fe.prof"))
print(head(p$by.total, 25))
print(head(p$by.self, 15))
