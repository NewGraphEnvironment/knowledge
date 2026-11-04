# data-raw/tune_anchor_check.R
# ---------------------------------------------------------------------------
# How much did each starting point choose its key's pick? Issue #141, first in #139's baseline review. The pick is the
# one-SE region's rule nearest link's `default` (or its flow version, #80), so where the data cannot rank several rules
# apart, the start chooses. This reads every key's saved tuning table and sets the pick from each start beside the
# best-scoring rule (knw_tune_anchor()): each one's distance behind the best in deviance and SE, and the parts (size
# test, gradient, exception) that separate them. No retune: the scores are in the tables.
#
# Keys are listed in the order a baseline review would take them: the parts the default pick moved from the best rule a
# pick may be (the best itself unless its exception is under d_floor or it did not converge), then its distance
# behind the best in SEs, then whether the two starts disagree. The pick and the best are read at knw_tune_score()'s
# d_floor, the tuning's (the tables do not record it).
#
# INPUT:  TUNE_DIR/<key>_tune.csv and <key>_summary.csv (default data/tune, the published tables; not recursed). No
#         database.
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_tune_anchor_check-<label>.csv (one row per key, with its table's md5) and
#         .txt (the knowledge commit, the tables' run and the same rows; a second run of the day numbered)
# RUN:    TUNE_DIR=<dir> LABEL=<label> Rscript data-raw/tune_anchor_check.R   (from the repo root; LABEL defaults to
#         `published` for data/tune, else the directory's name)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)

tune_dir <- sub("/+$", "", Sys.getenv("TUNE_DIR", "data/tune"))
label <- Sys.getenv("LABEL", if (tune_dir == "data/tune") "published" else basename(tune_dir))
if (!grepl("^[A-Za-z0-9_.-]+$", label)) stop("LABEL must be letters, digits, '_', '.' or '-': ", label, call. = FALSE)
files <- list.files(tune_dir, "_tune\\.csv$", full.names = TRUE)
if (!length(files)) stop("no <key>_tune.csv in ", tune_dir, call. = FALSE)
stem <- file.path("scripts/logs/habitat",
                  paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_tune_anchor_check-", label))
path_csv <- .knw_free_path(paste0(stem, ".csv"))
path_txt <- sub("\\.csv$", ".txt", path_csv)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

rows <- bind_rows(lapply(files, function(f) {
  key <- sub("_tune\\.csv$", "", basename(f))
  tune <- read_csv(f, show_col_types = FALSE, col_types = cols(.default = "c"))
  fs <- file.path(tune_dir, paste0(key, "_summary.csv"))
  s <- if (file.exists(fs)) read_csv(fs, show_col_types = FALSE, col_types = cols(.default = "c")) else NULL
  run <- function(col) if (!is.null(s) && col %in% names(s)) s[[col]][1] else NA_character_
  tibble(key = key, status = tune$status[1], n_visits = as.numeric(tune$n_visits[1]),
         region_n = sum(tune$in_region %in% "TRUE"), knw_tune_anchor(tune),
         run_uid = run("run_uid"), tune_run = run("tune_run"), evidence_md5 = run("evidence_md5"),
         curve_grad = run("curve_grad"), tune_md5 = unname(tools::md5sum(f)))
}))
rows <- rows |>
  mutate(rec_se_behind = if_else(recommended_se > 0, recommended_ddev / recommended_se, 0),
         flow_se_behind = if_else(recommended_flow_se > 0, recommended_flow_ddev / recommended_flow_se, 0)) |>
  arrange(desc(rec_moved_allowed), desc(rec_se_behind), starts_agree %in% TRUE) |>
  relocate(rec_se_behind, .after = recommended_se) |>
  relocate(flow_se_behind, .after = recommended_flow_se)

# dirty when the code that computes the numbers differs from the commit (as 0320's stamp), not when a log does
dirty <- length(system2("git", c("status", "--porcelain", "--untracked-files=no", "--", "R", "data-raw", "inst",
                                 "DESCRIPTION"), stdout = TRUE)) > 0
say("Anchoring check (#141) on %s (%s): %d keys, at knowledge %s%s.", tune_dir, label, nrow(rows),
    system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE), if (dirty) " (uncommitted changes)" else "")
runs <- distinct(rows, run_uid, tune_run, evidence_md5, curve_grad)
for (i in seq_len(nrow(runs))) {
  say("  link run %s, tuning run %s, evidence %s, gradient %s", runs$run_uid[i], runs$tune_run[i],
      runs$evidence_md5[i], runs$curve_grad[i])
}
say("Picks at the best from default: %d of %d; from the flow start: %d of %d with one; the two starts agree on %d.",
    sum(rows$rec_is_best), nrow(rows), sum(rows$flow_is_best %in% TRUE), sum(!is.na(rows$flow_is_best)),
    sum(rows$starts_agree %in% TRUE))
say("Keys whose best is not a rule a pick may be (an exception under d_floor, or not converged): %s.",
    if (any(!rows$best_is_allowed)) paste(rows$key[!rows$best_is_allowed], collapse = ", ") else "none")
block("each start's pick beside the best", rows |>
        select(key, rule_recommended, recommended_ddev, recommended_se, rec_moved, rec_moved_parts, rule_best, best_n))
block("beside the best a pick may be (d_floor)", rows |>
        select(key, best_is_allowed, rule_best_allowed, best_allowed_ddev, rec_moved_allowed, rec_moved_allowed_parts,
               flow_moved_allowed, flow_moved_allowed_parts))
block("the flow start", rows |>
        select(key, rule_recommended_flow, recommended_flow_ddev, recommended_flow_se, flow_moved, flow_moved_parts,
               starts_apart, starts_apart_parts))
block("the tables read", rows |> select(key, tune_md5))
write_csv(rows |> mutate(across(where(is.double), ~ round(.x, 4))), path_csv, na = "")
writeLines(log_lines, path_txt)
message("Wrote ", path_csv, " and ", path_txt)
