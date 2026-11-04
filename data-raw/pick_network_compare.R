# data-raw/pick_network_compare.R
# ---------------------------------------------------------------------------
# Which network moved each pick? Issue #145. Three tunings of every key, each read by tune_anchor_check.R: the
# published one (link 0.66.0's full network, wet's 2026-10-19 flows, link 0.66.0's species range), #120's on link's
# minimal network, and #145's on the new full `default` build, which shares the minimal run's flow load and range. So
# the minimal network against the new full one differs in the network alone, and the new full one against the
# published one in the link build, the flows and the range, not the network's kind.
#
# Per key: each tuning's pick (the one-SE region's rule nearest `default`), how far it sits behind that tuning's best
# rule (deviance and SE), the parts (size test, gradient, exception) in which two picks differ, and the visits each
# scored. No database, no retune: the anchor-check tables carry every number.
#
# Then each pick is looked up in the other tunings' tables: whether it lies in their one-SE region and how far behind
# their best it scores, which says whether a moved pick contradicts the other network or reshuffles near-equal rules.
#
# INPUT:  PUBLISHED, MINIMAL and FULL: tune_anchor_check.R's csv for each tuning (defaults: the newest
#         scripts/logs/habitat/*_tune_anchor_check-published.csv and *-minimal-20261103_0838.csv; FULL has none);
#         TUNE_MINIMAL and TUNE_FULL: the two new tunings' <key>_tune.csv directories (default for the minimal one
#         data/tune/candidate/20261103_0838, ignored; TUNE_FULL has none). Each table read must be the one its anchor
#         csv was computed from (its tune_md5), or the script stops: an ignored directory can be rewritten by a later run
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_pick_network_compare.csv (one row per key) and .txt (the inputs' md5s, the
#         knowledge commit and the rows; a second run of the day numbered)
# RUN:    FULL=<anchor csv> TUNE_FULL=<dir> [PUBLISHED=…] [MINIMAL=…] [TUNE_MINIMAL=…]
#         Rscript data-raw/pick_network_compare.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)

# the newest by modification time: a second run of a day is numbered (-2), which sorts before the first by name
newest <- function(pattern) {
  f <- list.files("scripts/logs/habitat", pattern, full.names = TRUE)
  if (length(f)) f[which.max(file.mtime(f))] else ""
}
paths <- c(published = Sys.getenv("PUBLISHED", newest("_tune_anchor_check-published(-[0-9]+)?\\.csv$")),
           minimal = Sys.getenv("MINIMAL", newest("_tune_anchor_check-minimal-20261103_0838(-[0-9]+)?\\.csv$")),
           full = Sys.getenv("FULL"))
miss <- names(paths)[!nzchar(paths) | !file.exists(paths)]
if (length(miss)) stop("no anchor-check table for ", paste(miss, collapse = ", "), ": give its path", call. = FALSE)
dirs <- c(minimal = Sys.getenv("TUNE_MINIMAL", "data/tune/candidate/20261103_0838"), full = Sys.getenv("TUNE_FULL"))
miss <- names(dirs)[!nzchar(dirs) | !dir.exists(dirs)]
if (length(miss)) stop("no tune directory for ", paste(miss, collapse = ", "), ": give its path", call. = FALSE)
path_csv <- .knw_free_path(file.path("scripts/logs/habitat",
                                     paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_pick_network_compare.csv")))
path_txt <- sub("\\.csv$", ".txt", path_csv)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

cols_side <- c("status", "n_visits", "rule_recommended", "recommended_ddev", "recommended_se", "rule_best",
               "rec_moved_parts", "run_uid", "evidence_md5", "tune_md5")
side <- function(nm) {
  a <- read_csv(paths[[nm]], show_col_types = FALSE, col_types = cols(.default = "c"))
  stopifnot(!anyDuplicated(a$key), all(cols_side %in% names(a)))
  a <- a[, c("key", cols_side)]
  names(a)[-1] <- paste0(names(a)[-1], "_", nm)
  a
}
# the parts two rules differ in, by position: size test | gradient | exception
parts_apart <- function(x, y) {
  vapply(seq_along(x), function(i) {
    if (is.na(x[i]) || is.na(y[i])) return(NA_character_)
    a <- strsplit(x[i], "|", fixed = TRUE)[[1]]
    b <- strsplit(y[i], "|", fixed = TRUE)[[1]]
    if (length(a) != 3 || length(b) != 3) stop("not a three-part rule: ", x[i], " or ", y[i], call. = FALSE)
    d <- c("size", "gradient", "exception")[a != b]
    if (length(d)) paste(d, collapse = "+") else "same"
  }, character(1))
}
# a rule's place in another tuning's table: in its region, and its deviance behind that tuning's best (and the SE).
# The table must be the one the anchor csv for that tuning read (its md5), so picks and regions come from one run
place <- function(nm, key, rule, md5_anchor) {
  f <- file.path(dirs[[nm]], paste0(key, "_tune.csv"))
  if (is.na(rule) || is.na(md5_anchor)) return(c(in_region = NA_character_, behind = NA_character_))
  if (!file.exists(f) || !identical(unname(tools::md5sum(f)), md5_anchor)) {
    stop(f, " is not the table the ", nm, " anchor csv read (tune_md5 ", md5_anchor, "): rerun tune_anchor_check.R on ",
         dirs[[nm]], " or point TUNE_", toupper(nm), " at the run it read", call. = FALSE)
  }
  t <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
  i <- match(rule, t$rule)
  if (is.na(i)) return(c(in_region = "not in grid", behind = NA_character_))
  c(in_region = t$in_region[i], behind = sprintf("%.2f / %.2f", as.numeric(t$ddev_best[i]), as.numeric(t$se_diff[i])))
}
rows <- side("published") |>
  full_join(side("minimal"), by = "key") |>
  full_join(side("full"), by = "key") |>
  mutate(network_moved = parts_apart(rule_recommended_minimal, rule_recommended_full),
         build_moved = parts_apart(rule_recommended_full, rule_recommended_published)) |>
  arrange(key)
for (pr in list(c("minimal", "full"), c("full", "minimal"), c("published", "minimal"), c("published", "full"))) {
  pl <- t(mapply(function(k, r, m) place(pr[2], k, r, m), rows$key, rows[[paste0("rule_recommended_", pr[1])]],
                 rows[[paste0("tune_md5_", pr[2])]]))
  rows[[sprintf("%s_pick_in_%s_region", pr[1], pr[2])]] <- unname(pl[, "in_region"])
  rows[[sprintf("%s_pick_behind_%s_best", pr[1], pr[2])]] <- unname(pl[, "behind"])
}
for (nm in names(paths)) {
  u <- unique(rows[[paste0("run_uid_", nm)]])
  say("%s: %s (md5 %s), link run %s", nm, paths[[nm]], unname(tools::md5sum(paths[[nm]])),
      paste(u[!is.na(u)], collapse = ", "))
}
# untracked files count: this script itself is code the numbers depend on
dirty <- length(system2("git", c("status", "--porcelain", "--", "R", "data-raw/pick_network_compare.R"),
                        stdout = TRUE)) > 0
say("Picks per key on three tunings (#145), at knowledge %s%s.",
    system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE), if (dirty) " (uncommitted changes)" else "")
both <- !is.na(rows$network_moved)
say("Minimal against new full network (the network alone): %d of %d keys tuned on both pick the same rule.",
    sum(rows$network_moved[both] == "same"), sum(both))
both <- !is.na(rows$build_moved)
say("New full against published (link build, flows and range): %d of %d keys pick the same rule.",
    sum(rows$build_moved[both] == "same"), sum(both))
block("each tuning's pick", rows |>
        select(key, rule_recommended_published, rule_recommended_minimal, rule_recommended_full, network_moved,
               build_moved))
block("behind each tuning's best (deviance / SE)", rows |>
        transmute(key,
                  published = sprintf("%s / %s", recommended_ddev_published, recommended_se_published),
                  minimal = sprintf("%s / %s", recommended_ddev_minimal, recommended_se_minimal),
                  full = sprintf("%s / %s", recommended_ddev_full, recommended_se_full),
                  rule_best_minimal, rule_best_full))
block("each pick in the other tunings' regions (TRUE = in the one-SE region; deviance / SE behind their best)", rows |>
        select(key, minimal_pick_in_full_region, minimal_pick_behind_full_best, full_pick_in_minimal_region,
               full_pick_behind_minimal_best))
block("the published pick in the two new tunings' regions", rows |>
        select(key, published_pick_in_minimal_region, published_pick_behind_minimal_best,
               published_pick_in_full_region, published_pick_behind_full_best))
for (nm in names(dirs)) say("tune tables (%s): %s, each the table its anchor csv read (tune_md5)", nm, dirs[[nm]])
block("visits scored and status", rows |>
        select(key, n_visits_published, n_visits_minimal, n_visits_full, status_published, status_minimal, status_full))
write_csv(rows, path_csv, na = "")
writeLines(log_lines, path_txt)
message("Wrote ", path_csv, " and ", path_txt)
