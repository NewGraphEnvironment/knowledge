# evidence bands per key from the curve object's modelled visits: size (the curve's own size, exp(log_size)) and the
# unclamped FWA gradient the rules read
suppressPackageStartupMessages(library(dplyr))
keys <- strsplit(Sys.getenv("KEYS"), ",")[[1]]
for (k in keys) {
  x <- readRDS(file.path("data/tune", paste0(k, "_curve.rds"))); d <- x$curve$data
  d$size <- exp(d$log_size); g <- d$fwa_gradient
  cat("\n=====", k, "size_var", x$curve$size_var, "q", x$curve$q, " n", nrow(d), " det", sum(d$present), " groups", n_distinct(d$wsg),
      " groups both", sum(tapply(d$present, d$wsg, function(v) any(v) && !all(v))), "\n")
  cat("dropped:", paste(names(x$curve$dropped), x$curve$dropped), " capped:", paste(names(x$curve$capped), x$curve$capped), "\n")
  cat("fwa_gradient range", range(g), " size quantiles:", round(quantile(d$size, c(.25, .5, .75)), 3), "\n")
  sb <- if (x$curve$size_var == "mad") c(0, 0.02, 0.03, 0.05, 0.1, 0.2, 0.35, 0.5, 0.75, 1, 3, 10, Inf) else c(0, 1, 1.5, 2, 3, 4, 5, 7.5, 10, 15, 20, Inf)
  print(as.data.frame(d |> mutate(b = cut(size, sb, right = FALSE)) |> group_by(b) |> summarise(n = n(), det = sum(present), rate = round(100 * mean(present), 1))))
  gb <- c(0, 0.01, 0.02, 0.03, 0.0349, 0.04, 0.05, 0.0549, 0.07, 0.0849, 0.09, 0.1049, 0.13, 0.15, 0.2, 0.25, 0.3, Inf)
  print(as.data.frame(d |> mutate(b = cut(g, gb, right = TRUE, include.lowest = TRUE)) |> group_by(b) |> summarise(n = n(), det = sum(present), rate = round(100 * mean(present), 1))))
  cat("dist (log_dist) quantiles m:", round(quantile(exp(d$log_dist), c(.1, .25, .5, .75, .9))), "\n")
}
