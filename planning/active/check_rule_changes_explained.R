# #65 Phase 2: every rule verdict that moved between #57's comparison (17 October, on the flows before wet#103)
# and #65's (on the republished flows) must be explained by a segment input that moved. Run from the repo root
# after 0330: Rscript planning/active/check_rule_changes_explained.R <dir of 17 October *_segments.rds> [out.csv]
# [new dir, default data/compare]
#
# Per segment and rule (default, tuned), the habitat test's own verdict (`<flag>_pre_<rule>`, before the
# hand-entered reaches and the connectivity pass) is compared, and each change is attributed:
#   size     the size the rule reads crossed its floor (tuned: knw_size against size_min; a width rule's
#            channel_width, which no flow change moves, is reported separately)
#   distance the exception's distance crossed exc_d, or appeared or vanished (tuned rules with an exception)
#   other    neither moved: unexplained, which must be zero on the stream branch
# A final verdict that moved while the habitat test's did not is the connectivity pass or the overlay cascading
# a change elsewhere (`cascade`).
suppressPackageStartupMessages(library(dplyr))
args <- commandArgs(TRUE)
old_dir <- args[1]
out_csv <- if (length(args) > 1 && nzchar(args[2])) args[2] else NA_character_
new_dir <- if (length(args) > 2) args[3] else "data/compare"
stopifnot(dir.exists(old_dir))
thr <- read.csv("data/compare/compare.csv", colClasses = "character")
keys <- sub("_segments\\.rds$", "", list.files(old_dir, "_segments\\.rds$"))
parse_rule <- function(r) {
  p <- strsplit(r, "|", fixed = TRUE)[[1]]
  size <- p[1]
  exc <- p[3]
  list(size_var = if (startsWith(size, "mad")) "mad" else "width", size_min = as.numeric(sub("^[a-z]+>=", "", size)),
       grad_max = as.numeric(sub("^g<=", "", p[2])),
       exc_q = if (exc == "none") NA_real_ else as.numeric(sub("^Q([0-9.]+)@D.*$", "\\1", exc)),
       exc_d = if (exc == "none") NA_real_ else as.numeric(sub("^Q[0-9.]+@D([0-9.]+)$", "\\1", exc)))
}
stream_edge <- c(1000, 1100, 2000, 2300)
rows <- list()
for (k in keys) {
  old <- as.data.frame(readRDS(file.path(old_dir, paste0(k, "_segments.rds"))))
  new <- as.data.frame(readRDS(file.path(new_dir, paste0(k, "_segments.rds"))))
  flag <- if (grepl("_spawn$", k)) "spawning" else "rearing"
  tuned_rule <- unique(thr$tuned_rule[paste(thr$species_code, thr$stage, sep = "_") == k])
  stopifnot(length(tuned_rule) == 1)
  r <- parse_rule(tuned_rule)
  cols <- c("id_segment", "watershed_group_code", "length_metre", "edge_type", "gradient", "channel_width", "knw_size",
            "knw_dist", paste0(flag, c("_default", "_pre_default", "_tuned", "_pre_tuned")))
  j <- inner_join(old[, cols], new[, cols], by = c("id_segment", "watershed_group_code"), suffix = c("_o", "_n"))
  if (nrow(j) != nrow(old) || nrow(j) != nrow(new)) stop(k, ": the two comparisons hold different segments")
  km <- j$length_metre_n / 1000
  size_ok <- function(s, w) if (r$size_var == "mad") !is.na(s) & s >= r$size_min else !is.na(w) & w >= r$size_min & w <= 9999
  ex_ok <- function(d) !is.na(r$exc_q) & !is.na(d) & d <= r$exc_d
  for (rule in c("default", "tuned")) {
    pre_o <- j[[paste0(flag, "_pre_", rule, "_o")]] %in% TRUE
    pre_n <- j[[paste0(flag, "_pre_", rule, "_n")]] %in% TRUE
    fin_o <- j[[paste0(flag, "_", rule, "_o")]] %in% TRUE
    fin_n <- j[[paste0(flag, "_", rule, "_n")]] %in% TRUE
    pre_moved <- pre_o != pre_n
    if (rule == "tuned") {
      sz <- size_ok(j$knw_size_o, j$channel_width_o) != size_ok(j$knw_size_n, j$channel_width_n)
      ds <- ex_ok(j$knw_dist_o) != ex_ok(j$knw_dist_n)
    } else {
      # default's test reads width, gradient and fresh's other branches; none of these come from the grade table
      a <- j$channel_width_o
      b <- j$channel_width_n
      sz <- (is.na(a) != is.na(b)) | (!is.na(a) & !is.na(b) & a != b)
      ds <- rep(FALSE, nrow(j))
    }
    cause <- ifelse(!pre_moved, ifelse(fin_o != fin_n, "cascade", "none"),
             ifelse(sz, "size", ifelse(ds, "distance", "other")))
    stream <- j$edge_type_n %in% stream_edge
    t <- tibble(key = k, rule = rule, cause = cause, stream = stream, direction = ifelse(fin_n & !fin_o, "gained", ifelse(fin_o & !fin_n, "lost", "")), km = km) |>
      filter(cause != "none") |>
      group_by(key, rule, cause, stream, direction) |>
      summarise(n = n(), km = sum(km), .groups = "drop")
    rows[[paste(k, rule)]] <- t
    cat(sprintf("%-9s %-7s km %9.1f -> %9.1f (%+.1f) | moved: %s\n", k, rule, sum(km[fin_o]), sum(km[fin_n]),
                sum(km[fin_n]) - sum(km[fin_o]),
                if (nrow(t)) paste(sprintf("%s%s %d (%.1f km)", t$cause, ifelse(t$stream, "", "/off-branch"), t$n, t$km), collapse = "; ") else "nothing"))
  }
}
res <- bind_rows(rows)
if (!is.na(out_csv)) write.csv(res, out_csv, row.names = FALSE)
bad <- res[res$cause == "other" & res$stream, ]
if (nrow(bad)) {
  cat("\nFAIL: stream-branch verdicts moved with neither size nor distance moving:\n")
  print(as.data.frame(bad))
  quit(status = 1)
}
cat("\nPASS: every stream-branch verdict that moved is explained by its size or its exception distance, or cascades\n")
