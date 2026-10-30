# data-raw/site_gradient_check.R
# ---------------------------------------------------------------------------
# How closely does the gradient every habitat rule reads follow the gradient crews measured at the same sites? Issue
# #121. The tuning reads link's segment gradient (`segment_gradient`, #92) and has the whole Atlas line's
# (`fwa_gradient`) as its sensitivity; both are Freshwater Atlas averages. FDIS crews measured gradient at the site
# (the RISC site card's "Gradient %", two readings per row, each row with its own method, which the export does not
# carry): `gradient_pct` is the first row's mean, `gradient2_pct` the second's (0230). A point measure over a surveyed
# site and a segment average are different quantities, so this measures how far apart they are; nothing here changes
# the gradient a rule reads.
#
# METHOD: measured gradient in percent is divided by 100, the scale the rules read. Agreement, as the width comparison
# in research/fdis_export.md reports it: Spearman rank correlation over every pair; over pairs where both are above 0,
# the correlation of the logs and the measured/modelled ratio's p10, p50 and p90. The two readings at one site
# (`gradient2_pct` against `gradient_pct`) are the yardstick: a model cannot be expected to agree with a reading better
# than two readings agree with each other. Populations: every visit with a measured gradient, and the tuning's stream
# branch (knw_tune_run()'s `edge_stream` and `area_range`, no river, wetland or lake), which is what the rules score;
# each tuned key's own population is that branch in the species' range, not blocked and with no barrier downstream
# (knw_tune_run()), in the groups that hold both outcomes (knw_tune_score()), held to the key's tracked `n_visits`
# for rearing (a spawning key's population also needs the spawner evidence, which is not read here, so its counts are
# before that filter and before the groups filter). Flips: a visit flips at a limit when
# its measured and modelled gradients lie on opposite sides of it; counted at every gradient limit with a value in
# data/thresholds.csv (fitted or underpowered), over the key's population and within the band of modelled gradients one step either side of
# the limit on the key's own ladder (the gradient maxima of its tracked tune table: the fixed ladder plus its
# defaults). Negative segment gradients: knw_rule_in() tests `0 <= gradient <= grad_max`, so a negative one fails
# every rule's gradient test; each rule in a key's tracked tune table is tested at those visits as they are and with
# the gradient set to 0, where the key's population holds any.
#
# INPUT:  EVIDENCE_DIR/{visits_link,visits_species,walks}.csv (default data/fdis/derived; 0310's tables), held to the
#         md5s data/thresholds.csv names unless EVIDENCE_CHECK=FALSE; TUNE_DIR/<key>_tune.csv (default data/tune, the
#         tracked tables); data/thresholds.csv. No database.
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_site_gradient_check.txt (a second run of the day numbered; …_refused.txt
#         when the evidence is not the published build's)
# RUN:    EVIDENCE_DIR=<dir> Rscript data-raw/site_gradient_check.R   (from the repo root; EVIDENCE_CHECK=FALSE on
#         another build, as #120 reruns it on link's minimal network)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)

evidence_dir <- Sys.getenv("EVIDENCE_DIR", "data/fdis/derived")
tune_dir <- Sys.getenv("TUNE_DIR", "data/tune")
evidence_check <- !Sys.getenv("EVIDENCE_CHECK") %in% c("0", "FALSE", "false")
len_breaks <- c(0, 10, 25, 50, 100, 250, 500, Inf)        # segment_gradient_check.R's
ladder <- eval(formals(knw_tune_grid)$grid_grad)            # the tuning's gradient ladder
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
area_range <- eval(fm$area_range)
path_txt <- .knw_free_path(file.path("scripts/logs/habitat", paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"),
                                                                    "_site_gradient_check.txt")))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}
home_rel <- function(x) sub(path.expand("~"), "~", x, fixed = TRUE)

# ---- the evidence: the published build, unless told otherwise ------------------------------------------------------
thr <- read_csv("data/thresholds.csv", show_col_types = FALSE, col_types = cols(.default = "c"))
pub_md5 <- unique(na.omit(thr$evidence_md5))
md5_here <- unname(tools::md5sum(file.path(evidence_dir, c("visits_link.csv", "visits_species.csv", "walks.csv"))))
here <- paste(md5_here, collapse = ";")
# the stamp names a commit only when the code and tracked inputs that ran are that commit's; a git that fails stops
# the run rather than reading as clean (system2() only warns)
git_out <- function(args) {
  out <- suppressWarnings(system2("git", args, stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(args, collapse = " "), " failed", call. = FALSE)
  out
}
head_sha <- substr(git_out(c("rev-parse", "HEAD")), 1, 7)
# the tune tables are stamped only where they are the tracked ones; elsewhere (outside the repo, or an ignored
# candidate run) the log names the directory and says the stamp does not cover it
tune_tracked <- identical(normalizePath(tune_dir, mustWork = TRUE), normalizePath("data/tune", mustWork = TRUE))
dirty <- git_out(c("status", "--porcelain", "--", "data-raw/site_gradient_check.R", "R", "data/thresholds.csv",
                   if (tune_tracked) "data/tune"))
if (length(dirty)) head_sha <- paste0(head_sha, " with uncommitted changes to ", paste(trimws(dirty), collapse = ", "))
if (!tune_tracked) head_sha <- paste0(head_sha, " (tune tables outside the tracked data/tune, not covered by it)")
say(paste("Site gradient check, knowledge#121, knowledge %s. Evidence %s (visits_link, visits_species, walks md5 %s);",
          "tune tables %s."),
    head_sha, home_rel(evidence_dir), paste(substr(md5_here, 1, 8), collapse = " "), home_rel(tune_dir))
published <- length(pub_md5) == 1L && identical(here, pub_md5)
if (!published) {
  say("NOT the published build: data/thresholds.csv names %s.", paste(substr(pub_md5, 1, 8), collapse = ", "))
  if (evidence_check) {
    writeLines(log_lines, .knw_free_path(sub("\\.txt$", "_refused.txt", path_txt)))
    stop("evidence is not the published build; set EVIDENCE_DIR to it, or EVIDENCE_CHECK=FALSE to run on this one",
         call. = FALSE)
  }
  say("EVIDENCE_CHECK=FALSE: run on this build anyway; the key populations are not held to the tracked tables.")
} else {
  say("The evidence is the build data/thresholds.csv names (%s; not uploaded, so held on the machines that built it).",
      paste(unique(na.omit(thr$evidence_version)), collapse = ", "))
}

vl <- read_csv(file.path(evidence_dir, "visits_link.csv"), show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv(file.path(evidence_dir, "visits_species.csv"), show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c"))
walks <- read_csv(file.path(evidence_dir, "walks.csv"), show_col_types = FALSE)
stopifnot(!anyDuplicated(vl$site_visit))
# the measured gradient on the rules' scale, and the tuning's stream branch (knw_site_gradient_visits(), which the
# methodology bundle reads through too)
v_all <- knw_site_gradient_visits(vl)
v <- filter(v_all, !is.na(meas))
sb <- filter(v, stream_branch)
say(paste("Visits placed: %d. With a measured gradient: %d (a second reading: %d; both: %d). On the tuning's stream",
          "branch (edge types %s, fished area %g-%g m2): %d placed, %d with a measured gradient."),
    nrow(v_all), nrow(v), sum(!is.na(v_all$meas2)), sum(!is.na(v_all$meas) & !is.na(v_all$meas2)),
    paste(edge_stream, collapse = ","), area_range[1], area_range[2], sum(v_all$stream_branch), nrow(sb))
say("Missing modelled gradient among them: segment %d, Atlas line %d.", sum(is.na(v$segment_gradient)),
    sum(is.na(v$fwa_gradient)))

# ---- agreement -------------------------------------------------------------------------------------------------------
agree <- knw_gradient_agree
both_ways <- function(x, grp = NULL) {
  f <- function(d) bind_rows(segment = agree(d$meas, d$segment_gradient), atlas_line = agree(d$meas, d$fwa_gradient),
                             .id = "against")
  if (is.null(grp)) return(f(x))
  x |> group_by(across(all_of(grp))) |> group_modify(~ f(.x)) |> ungroup()
}
two <- filter(v_all, !is.na(meas), !is.na(meas2))
block("yardstick: the first reading against the second, at the same site (every visit with both; ratio first/second)",
      agree(two$meas, two$meas2) |> rename(second_higher_pct = model_higher_pct))
block("measured (first reading) against the modelled gradients, every visit with a measured gradient", both_ways(v))
block("the same, on the tuning's stream branch", both_ways(sb))
block("the second reading against the modelled gradients, on the tuning's stream branch",
      bind_rows(segment = agree(sb$meas2, sb$segment_gradient), atlas_line = agree(sb$meas2, sb$fwa_gradient),
                .id = "against"))
block("stream branch, by segment length (m)",
      both_ways(mutate(sb, length_m = cut(segment_length_m, len_breaks, dig.lab = 4)), "length_m"))
block("stream branch, by the segment's stream order", both_ways(sb, "segment_stream_order"))
block("stream branch, by the measured gradient's step on the tuning's ladder",
      both_ways(mutate(sb, measured = cut(meas, c(-Inf, 0, ladder, Inf), right = TRUE, dig.lab = 4)), "measured"))
block("stream branch, by whether the segment starts at the visit (link cut it there; -1 to 5 m)",
      both_ways(sb, "at_visit"))
block("stream branch, by catch", both_ways(sb, "catch_status"))
# sites with fish sit on gentler and shorter segments, so catch is compared within the measured gradient's class and
# the segment's length as well
compact <- function(x, grp) {
  x |> group_by(across(all_of(grp))) |>
    group_modify(~ agree(.x$meas, .x$segment_gradient) |> select(pairs, spearman, ratio_p10, ratio_p90, absdiff_p50)) |>
    ungroup()
}
block("stream branch, by catch within the measured gradient's class, against the segment gradient",
      compact(mutate(sb, measured = cut(meas, c(-Inf, 0.03, 0.07, 0.13, Inf), dig.lab = 4)), c("measured", "catch_status")))
block("stream branch, by catch within the segment's length class (m), against the segment gradient",
      compact(mutate(sb, length_m = cut(segment_length_m, c(0, 50, 250, Inf), dig.lab = 4)), c("length_m", "catch_status")))
block("every visit with a measured gradient, by where it sits (the stream branch, or a river, wetland or lake segment)",
      both_ways(mutate(v, sits = case_when(stream_branch ~ "stream branch", wb_river %in% TRUE ~ "river",
                                           wb_lake %in% TRUE ~ "lake", wb_wetland %in% TRUE ~ "wetland",
                                           TRUE ~ "other (edge type or fished area)")), "sits"))

# ---- the keys and their published limits ---------------------------------------------------------------------------
lim <- thr |>
  filter(component == "gradient", !is.na(value)) |>   # every gradient limit the table publishes, whatever its status
  transmute(species_code, stage, key = paste(species_code, stage, sep = "_"), limit = as.numeric(value),
            n_visits = as.integer(n_visits))
# knw_tune_score() scores the groups that hold both outcomes (knw_site_gradient_population())
pop <- function(sp, stage) knw_site_gradient_population(v_all, vs, sp, stage)
pops <- lapply(setNames(seq_len(nrow(lim)), lim$key), function(i) pop(lim$species_code[i], lim$stage[i]))
lim$population <- vapply(pops, nrow, integer(1))
lim$with_measured <- vapply(pops, function(d) sum(!is.na(d$meas)), integer(1))
rear_mismatch <- lim$stage == "rear" & lim$population != lim$n_visits
if (published && any(rear_mismatch)) {
  block("rearing populations against the tracked n_visits", lim[rear_mismatch, ])
  writeLines(log_lines, .knw_free_path(sub("\\.txt$", "_refused.txt", path_txt)))
  stop("a rearing key's population is not the tuning's: ", paste(lim$key[rear_mismatch], collapse = ", "),
       call. = FALSE)
}
block(paste("the published gradient limits and each key's population (rearing held to the tracked n_visits; a",
            "spawning key's is before the spawner and groups filters)"), lim)

tunes <- lapply(setNames(lim$key, lim$key), function(k) {
  read_csv(file.path(tune_dir, paste0(k, "_tune.csv")), show_col_types = FALSE)
})
# a key's ladder is the gradient maxima its grid held: the fixed ladder plus its own defaults (knw_tune_grid())
flip_tbl <- knw_gradient_flips
flips <- bind_rows(lapply(seq_len(nrow(lim)), function(i) {
  d <- pops[[i]]
  lad <- sort(unique(tunes[[i]]$grad_max))
  bind_rows(flip_tbl(d, lim$limit[i], "segment_gradient", lad), flip_tbl(d, lim$limit[i], "fwa_gradient", lad)) |>
    mutate(key = lim$key[i], limit = lim$limit[i], .before = 1)
}))
block(paste("flips at each key's published limit, over the key's population (a reading on the limit is in, as the",
            "rule's <= has it; band: modelled gradient one step of the key's own ladder either side, mirrored at its top;",
            "meas_band: the same window on the measured gradient)"), flips)

# rearing keys only: a spawning key's outcome is spawner evidence, which is not read here
by_outcome <- bind_rows(lapply(which(lim$stage == "rear"), function(i) {
  d <- pops[[i]]
  bind_rows(lapply(c(TRUE, FALSE), function(p) {
    dd <- d[d$present %in% p, , drop = FALSE]
    cbind(tibble(key = lim$key[i], present = p),
          agree(dd$meas, dd$segment_gradient) |> select(pairs, spearman, log_r, ratio_p10, ratio_p50, ratio_p90),
          flip_tbl(dd, lim$limit[i], "segment_gradient", sort(unique(tunes[[i]]$grad_max))) |>
            select(flips_pct, band_visits, band_flips_pct))
  }))
}))
block("by the species' outcome (caught or not), against the segment gradient (each rearing key's population)",
      by_outcome)

# ---- negative segment gradients --------------------------------------------------------------------------------------
neg <- filter(v_all, segment_gradient < 0)
say("")
say(paste("Negative segment gradients: %d placed visits (%d on the stream branch, %d with a measured gradient);",
          "values %s; segment lengths (m) %s; Atlas-line gradient at them %s; on the same Atlas line as the visit: %d."),
    nrow(neg), sum(neg$stream_branch), sum(!is.na(neg$meas)),
    paste(signif(range(neg$segment_gradient), 3), collapse = " to "),
    paste(round(quantile(neg$segment_length_m, c(0, 0.5, 1), names = FALSE), 1), collapse = "/"),
    paste(signif(quantile(neg$fwa_gradient, c(0, 0.5, 1), names = FALSE), 3), collapse = "/"),
    sum(neg$linear_feature_id == neg$segment_linear_feature_id, na.rm = TRUE))
block("negative segment gradients by edge type and waterbody",
      count(neg, edge_type, stream_branch, wb_river = wb_river %in% TRUE, wb_wetland = wb_wetland %in% TRUE,
            wb_lake = wb_lake %in% TRUE))
wi <- knw_walk_index(walks)
neg_keys <- bind_rows(lapply(seq_len(nrow(lim)), function(i) {
  d <- pops[[i]]
  dn <- d[(d$segment_gradient < 0) %in% TRUE, , drop = FALSE]   # a missing gradient is not a negative one
  tune <- tunes[[i]]
  if (!nrow(dn)) {
    return(tibble(key = lim$key[i], negative_visits = 0L, present = 0L, rules = nrow(tune), rules_moved = NA_integer_,
                  in_region_moved = NA_integer_, recommended_moved_visits = NA_integer_, most_moved_visits = NA_integer_))
  }
  rule_flips <- vapply(seq_len(nrow(tune)), function(j) {
    r <- as.data.frame(tune[j, c("size_var", "size_min", "grad_max", "exc_q", "exc_d")])
    a <- knw_rule_in(dn, r, walks = wi)
    z <- dn
    z$segment_gradient <- 0
    sum(a != knw_rule_in(z, r, walks = wi))
  }, integer(1))
  rec <- which(tune$recommended %in% TRUE)
  tibble(key = lim$key[i], negative_visits = nrow(dn), present = sum(dn$present %in% TRUE),
         rules = nrow(tune), rules_moved = sum(rule_flips > 0),
         in_region_moved = sum(rule_flips > 0 & tune$in_region %in% TRUE),
         recommended_moved_visits = if (length(rec)) rule_flips[rec[1]] else NA_integer_,
         most_moved_visits = max(c(0L, rule_flips)))
}))
block(paste("negative segment gradients in each key's population: rules in the tracked tune table whose in/out at",
            "those visits changes when the gradient is 0 (NA: no negative in the population, so nothing to test)"),
      neg_keys)

writeLines(log_lines, path_txt)
message("Written ", path_txt)
