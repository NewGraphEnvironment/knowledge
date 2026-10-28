# data-raw/snap_limit_sensitivity.R
# ---------------------------------------------------------------------------
# How far may a placed FDIS visit lie from its stream (#91)? Two limits, set by the rule decided at the
# plan gate (planning/archive/…issue-91…/task_plan.md, "Decided at the gate", 2):
#   - a code-confirmed pick (on a stream the visit's 1:50k code names) is kept to the search radius, 500 m;
#   - an unconfirmed pick is kept to the widest distance band whose code-checked disagreement stays under
#     one in three, recomputed under the new snap;
#   - if CH rearing's or BT rearing's one-SE region moves inside the chosen limit, the smaller limit wins.
#     "Moves" is fixed before the run: between two limits, a key's region moves when either limit's pick
#     lies outside the other limit's region.
#
# METHOD: the evidence built with every placed visit kept (`SNAP_LIMIT=500 SNAP_LIMIT_CODE=500` through
# 0230, then 0310), so any smaller limit is a filter on it. For unconfirmed ∈ {100, 200, 500} m ×
# confirmed ∈ {200, 500} m: the visits kept, the moved picks by move distance and the nearest's
# distance, and CH rearing's and BT rearing's pick and one-SE region on the main fold seed
# (knw_tune_run(..., smoke = FALSE, extra = FALSE, cache_dir = NULL): nothing is written under
# data/tune), with link's `default` and `default_tuned` thresholds read at the ledger's run_link_sha as
# 0320 reads them. Disagreement by band: a visit with a code the crosswalk knows, placed, whose nearest
# stream is not one its code names (not confirmed, or moved), by its nearest stream's distance.
#
# INPUT:  data/fdis/build/sites.rds and data/fdis/derived/{visits_link,visits_species,walks}.csv from the
#         500 m build; the newest scripts/logs/habitat/<date>_evidence_build_ledger.csv (that build's,
#         copied to the output's _ledger-snap500.csv so a later 0310 run cannot overwrite it); link's
#         repo at LINK_REPO (default ../link)
# OUTPUT: scripts/logs/fdis/<yyyymmdd>_snap_limit_sensitivity.{txt,csv}, _ledger-snap500.csv
# RUN:    Rscript data-raw/snap_limit_sensitivity.R   (from the repo root, after the 500 m 0230 and 0310)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(tidyr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)

link_repo <- Sys.getenv("LINK_REPO", "../link")
workers <- as.integer(Sys.getenv("WORKERS", max(1L, min(14L, parallel::detectCores() - 2L))))
lim_near <- c(100, 200, 500)
lim_code <- c(200, 500)
keys <- c("CH", "BT")
bands <- c(0, 25, 50, 100, 200, 500)
disagree_max <- 1 / 3
stamp <- format(Sys.Date(), "%Y%m%d")
out <- file.path("scripts/logs/fdis", paste0(stamp, "_snap_limit_sensitivity"))
band <- function(d) cut(d, bands, right = FALSE, include.lowest = TRUE, dig.lab = 4)

# ---- the 500 m build ---------------------------------------------------------------
sites <- readRDS("data/fdis/build/sites.rds")
if (any(sites$flag_far_snap)) stop("sites.rds was not built with SNAP_LIMIT=500 SNAP_LIMIT_CODE=500: rerun 0230 so")
ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE),
                    decreasing = TRUE)[1]
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
md5_now <- unname(tools::md5sum("data/fdis/build/sites.rds"))
if (!identical(led$note[led$step == "md5_sites"], md5_now)) {
  stop(ledger_path, " was not built from this sites.rds: rerun 0310 on the 500 m build")
}
ledger_copy <- paste0(out, "_ledger-snap500.csv")
if (!file.copy(ledger_path, ledger_copy, overwrite = TRUE)) stop("could not copy ", ledger_path)
link_sha <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]]

vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c"))
walks <- read_csv("data/fdis/derived/walks.csv", show_col_types = FALSE)
stopifnot(all(c("snap_confirmed", "snap_moved", "nearest_distance_m", "distance_to_stream") %in% names(vl)))

read_thr <- function(bundle) {
  fs <- vapply(link_sha, function(sha) {
    f <- tempfile(fileext = ".csv")
    st <- system2("git", c("-C", link_repo, "show",
                           sprintf("%s:inst/extdata/configs/%s/parameters_habitat_thresholds.csv", sha, bundle)), stdout = f)
    if (!identical(st, 0L) || file.size(f) == 0) stop("could not read link's ", bundle, " thresholds at ", sha)
    f
  }, character(1))
  if (length(unique(unname(tools::md5sum(fs)))) != 1) stop("link's ", bundle, " thresholds differ between ", link_sha)
  read.csv(fs[1], stringsAsFactors = FALSE)
}
thr <- read_thr("default")
thr_tuned <- read_thr("default_tuned")

# ---- disagreement by the nearest stream's distance ------------------------------------
placed <- sites |> filter(!flag_not_placed)
dis <- placed |>
  filter(ws50_checked) |>
  mutate(nearest_named = snap_confirmed & !snap_moved) |>
  group_by(band = band(nearest_distance_m)) |>
  summarise(n = n(), disagree = sum(!nearest_named), share = mean(!nearest_named), .groups = "drop")
ok_bands <- dis$band[cumprod(dis$share < disagree_max) == 1]
near_rule <- bands[length(ok_bands) + 1]
code_rule <- max(lim_code)
# the rule's limit is always a cell, so its region can be compared with the next one down
lim_near <- sort(unique(c(lim_near, near_rule)))

# ---- the six cells ---------------------------------------------------------------------
keep_of <- function(d, u, c) (d$snap_confirmed & d$distance_to_stream <= c) | (!d$snap_confirmed & d$distance_to_stream <= u)
cells <- expand.grid(limit_near = lim_near, limit_code = lim_code)
res <- list()
regions <- list()
t0 <- Sys.time()
for (i in seq_len(nrow(cells))) {
  u <- cells$limit_near[i]
  c <- cells$limit_code[i]
  k_sites <- keep_of(placed, u, c)
  v <- vl[keep_of(vl, u, c), ]
  s <- vs[vs$site_visit %in% v$site_visit, ]
  run <- knw_tune_run(v, s, walks, thr, species = keys, stages = "rear", thresholds_extra = thr_tuned,
                      smoke = FALSE, extra = FALSE, cache_dir = NULL, workers = workers,
                      # the Atlas line's gradient, as #91 measured it, before #92 moved the tuning to link's segments
                      cols = c(grad = "fwa_gradient", width = "cw_deploy", mad = "mad_pick"))
  for (k in paste0(keys, "_rear")) {
    r <- run[[k]]$score$rules
    regions[[paste(u, c, k)]] <- r$rule[r$in_region %in% TRUE]
    res[[length(res) + 1]] <- tibble(
      limit_near = u, limit_code = c, key = k,
      sites_kept = sum(k_sites), moved_kept = sum(k_sites & placed$snap_moved),
      evidence_visits = nrow(v), visits_in = run[[k]]$population[["visits_in"]],
      detections = run[[k]]$population[["detections"]], status = run[[k]]$status,
      pick = if (is.null(run[[k]]$pick)) NA_character_ else run[[k]]$pick$rule,
      region_n = length(regions[[paste(u, c, k)]]))
  }
  message(sprintf("cell %d/%d (%g, %g) done, %.1f min", i, nrow(cells), u, c,
                  as.numeric(difftime(Sys.time(), t0, units = "mins"))))
}
res <- bind_rows(res)

# between two limits, does either pick fall outside the other's region?
moves <- function(a, b, k) {
  at <- function(x) res$pick[res$limit_near == x[1] & res$limit_code == x[2] & res$key == k]
  !(at(a) %in% regions[[paste(b[1], b[2], k)]] && at(b) %in% regions[[paste(a[1], a[2], k)]])
}
moves_any <- function(a, b) any(vapply(paste0(keys, "_rear"), function(k) moves(a, b, k), logical(1)))
# the unconfirmed limit: the rule's, then one step down for as long as a key's region moves between the two
chosen_near <- near_rule
while (chosen_near > min(lim_near) && moves_any(c(max(lim_near[lim_near < chosen_near]), code_rule),
                                                c(chosen_near, code_rule))) {
  chosen_near <- max(lim_near[lim_near < chosen_near])
}
# the confirmed limit: the search radius, unless a key's region moves between it and the smaller one
chosen_code <- if (moves_any(c(chosen_near, min(lim_code)), c(chosen_near, code_rule))) min(lim_code) else code_rule
pairs <- bind_rows(
  lapply(seq_along(lim_near)[-1], function(j) tibble(a_near = lim_near[j - 1], a_code = code_rule,
                                                     b_near = lim_near[j], b_code = code_rule)),
  lapply(lim_near, function(u) tibble(a_near = u, a_code = min(lim_code), b_near = u, b_code = code_rule)))
for (k in paste0(keys, "_rear")) {
  pairs[[paste0("moves_", k)]] <- vapply(seq_len(nrow(pairs)), function(j) {
    moves(c(pairs$a_near[j], pairs$a_code[j]), c(pairs$b_near[j], pairs$b_code[j]), k)
  }, logical(1))
}

# ---- report ----------------------------------------------------------------------------
sink(paste0(out, ".txt"))
cat("# Snap limit sensitivity (#91), data-raw/snap_limit_sensitivity.R\n")
cat("run:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), " evidence ledger", ledger_path, "(copied to",
    ledger_copy, ")\n")
cat("link", paste(link_sha, collapse = ";"), " workers", workers, "\n")
cat("evidence md5:", paste(unname(tools::md5sum(file.path("data/fdis/derived",
                                                          c("visits_link.csv", "visits_species.csv", "walks.csv")))),
                           collapse = ";"), "\n\n")
cat("## Code-checked disagreement by the nearest stream's distance (placed visits with a known code)\n")
print(as.data.frame(dis |> mutate(share = round(share, 3))))
cat(sprintf("\nwidest band under %.3f: up to %g m\n\n", disagree_max, near_rule))
cat("## Moved picks (all placed): pick distance band x nearest distance band\n")
print(with(placed |> filter(snap_moved), table(pick = band(distance_to_stream), nearest = band(nearest_distance_m))))
cat("\n## Placed picks by route and distance band\n")
print(with(placed, table(band(distance_to_stream), ifelse(snap_confirmed, "confirmed", "unconfirmed"))))
cat("\n## Cells: kept visits and each key's pick and one-SE region on the main fold seed\n")
print(as.data.frame(res), right = FALSE)
cat("\n## Region moves between limits (either pick outside the other's region)\n")
print(as.data.frame(pairs))
cat(sprintf("\nchosen: limit_near %g m, limit_code %g m\n", chosen_near, chosen_code))
cat(sprintf("elapsed %.1f min\n", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
sink()
write_csv(res |> mutate(region = vapply(paste(limit_near, limit_code, key), function(x) paste(regions[[x]], collapse = " ; "),
                                        character(1))),
          paste0(out, ".csv"), na = "")
cat(readLines(paste0(out, ".txt")), sep = "\n")
