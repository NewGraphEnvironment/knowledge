# data-raw/segment_gradient_check.R
# ---------------------------------------------------------------------------
# Before the tuning scores visits on link's segment gradient (#92), what is that segment at a visit, and does link cut
# its streams at `default`'s own gradient cut-offs? Issue #92, steps 1 and 3.
#
# STEP 1, the segment at a visit. link breaks streams at bcfishobs observations, and an FDIS visit that caught a
# modelled species is one, so its segment starts at the visit (0310's `segment_starts_in_window`: the segment's
# downstream end lies 1 m below to 5 m above the visit). Measured on the tuning's stream-branch population
# (knw_tune_run()'s `edge_stream` and `area_range`): how many visits sit on such a segment, by catch and by each
# species' outcome; the segment lengths; and how far the segment's gradient lies from the Atlas line's, by length.
# STEP 3, link's breaks. `default` cuts gradients only at its access classes; this measures whether segment gradients
# bunch at a cut-off: the segments (count and length) in the half-point band below each of `default`'s rearing and
# spawning gradient maxima and each access class, against the band above, over every stream-branch segment of SCHEMA.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species}.csv (0310); the newest evidence build ledger; link's repo at
#         LINK_REPO (default ../link) for `default`'s thresholds at the build's link_sha; the database (PG* env vars):
#         SCHEMA (default fresh_default), checked against the ledger's run with knw_build_record()
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_segment_gradient_check.txt
# RUN:    SCHEMA=fresh_default_20261017 Rscript data-raw/segment_gradient_check.R   (from the repo root)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr); library(DBI); library(RPostgres) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

link_repo <- Sys.getenv("LINK_REPO", "../link")
schema <- Sys.getenv("SCHEMA", "fresh_default")
band_w <- 0.005                          # the half-point band either side of a cut-off
len_breaks <- c(0, 10, 25, 50, 100, 250, 500, Inf)
access_classes <- c(0.15, 0.20, 0.25, 0.30)   # link's default gradient_classes (lnk_pipeline_prepare.R)
path_log <- file.path("scripts/logs/habitat", paste0(format(Sys.Date(), "%Y%m%d"), "_segment_gradient_check.txt"))
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}

ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE),
                    decreasing = TRUE)[1]
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- strsplit(led$note[led$step == "run_link_sha"], ";", fixed = TRUE)[[1]][1]
say("Segment gradient check, knowledge#92. Evidence %s (link run %s, link %s); schema %s.", ledger_path, run_uid,
    link_sha, schema)

thr_file <- tempfile(fileext = ".csv")
st <- system2("git", c("-C", link_repo, "show",
                       sprintf("%s:inst/extdata/configs/default/parameters_habitat_thresholds.csv", link_sha)),
              stdout = thr_file)
if (!identical(st, 0L) || file.size(thr_file) == 0) stop("could not read link's default thresholds at ", link_sha)
thr <- read.csv(thr_file, stringsAsFactors = FALSE)
cuts <- sort(unique(na.omit(c(thr$rear_gradient_max, thr$spawn_gradient_max))))

# ---- step 1: the segment at a visit ------------------------------------------------------
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
area_range <- eval(fm$area_range)
vl <- read_csv("data/fdis/derived/visits_link.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- read_csv("data/fdis/derived/visits_species.csv", show_col_types = FALSE, guess_max = 1e5,
               col_types = cols(site_visit = "c"))
v <- vl |>
  filter(edge_type %in% edge_stream, !(wb_river %in% TRUE), !(wb_wetland %in% TRUE), !(wb_lake %in% TRUE),
         !is.na(area_m2), area_m2 >= area_range[1], area_m2 <= area_range[2]) |>
  mutate(at_visit = segment_start_offset_m >= -1 & segment_start_offset_m <= 5,
         gap = segment_gradient - fwa_gradient)
say("Visits placed: %d; on the tuning's stream branch (edge types %s, fished area %g-%g m2): %d.", nrow(vl),
    paste(edge_stream, collapse = ","), area_range[1], area_range[2], nrow(v))
say("On a segment that starts at the visit: %d of %d placed visits; %d of %d on the stream branch.",
    sum(vl$segment_start_offset_m >= -1 & vl$segment_start_offset_m <= 5), nrow(vl), sum(v$at_visit), nrow(v))
say("Same Atlas line as the segment: %.1f %% of stream-branch visits.",
    100 * mean(v$linear_feature_id == v$segment_linear_feature_id, na.rm = TRUE))

summ <- function(x) {
  summarise(x, visits = n(), at_visit_pct = round(100 * mean(at_visit), 1),
            len_median_m = round(median(segment_length_m), 0),
            gap_abs_median = round(median(abs(gap), na.rm = TRUE), 4),
            gap_sd = round(sd(gap, na.rm = TRUE), 4), .groups = "drop")
}
block("by catch (stream branch)", v |> group_by(catch_status) |> summ())
sp_out <- vs |>
  filter(in_range, status %in% c("present", "absent")) |>
  select(site_visit, species_code, present) |>
  inner_join(v, by = "site_visit") |>
  group_by(species_code, present) |> summ()
block("by species outcome (stream branch, in link's range, present or absent)", sp_out)
block("by segment length (stream branch)",
      v |> mutate(length_m = cut(segment_length_m, len_breaks, dig.lab = 4)) |> group_by(length_m) |>
        summarise(visits = n(), at_visit_pct = round(100 * mean(at_visit), 1),
                  gap_abs_median = round(median(abs(gap)), 4), gap_abs_p90 = round(quantile(abs(gap), 0.9), 4),
                  seg_zero_pct = round(100 * mean(segment_gradient == 0), 1),
                  seg_over30_pct = round(100 * mean(segment_gradient > 0.3), 1), .groups = "drop"))
block("class flips at each of default's cut-offs and the access classes (stream branch)",
      tibble(cut = c(cuts, access_classes),
             flips_pct = vapply(c(cuts, access_classes), function(t) {
               round(100 * mean((v$fwa_gradient <= t) != (v$segment_gradient <= t)), 2)
             }, numeric(1))))

# ---- step 3: does link cut at default's cut-offs? -------------------------------------------
conn <- tryCatch(DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric"),
                 error = function(e) stop("database unreachable (PG* environment variables): ", conditionMessage(e)))
rec <- knw_build_record(conn, schema, run_uid = run_uid)
say("%s", rec$line)
all_cuts <- c(cuts, access_classes)
sel <- paste(vapply(seq_along(all_cuts), function(i) {
  t <- all_cuts[i]
  sprintf(paste("count(*) FILTER (WHERE gradient > %1$.6f AND gradient <= %2$.6f) AS below_n_%3$d,",
                "count(*) FILTER (WHERE gradient > %2$.6f AND gradient <= %4$.6f) AS above_n_%3$d,",
                "sum(length_metre) FILTER (WHERE gradient > %1$.6f AND gradient <= %2$.6f) AS below_m_%3$d,",
                "sum(length_metre) FILTER (WHERE gradient > %2$.6f AND gradient <= %4$.6f) AS above_m_%3$d"),
          t - band_w, t, i, t + band_w)
}, character(1)), collapse = ",\n  ")
q <- sprintf("SELECT count(*) AS segments,\n  %s\nFROM %s.streams WHERE edge_type IN (%s)", sel, schema,
             paste(edge_stream, collapse = ", "))
x <- DBI::dbGetQuery(conn, q)
DBI::dbDisconnect(conn)
say("Stream-branch segments in %s: %s.", schema, format(as.numeric(x$segments), big.mark = ","))
val <- function(prefix, scale = 1) {
  vapply(seq_along(all_cuts), function(i) as.numeric(x[[paste0(prefix, i)]]) / scale, numeric(1))
}
kind <- c(rep("default rear/spawn max", length(cuts)), rep("access class", length(access_classes)))
block(sprintf("segments in the %g-point band below and above each cut-off (%s's stream branch)", 100 * band_w, schema),
      tibble(cut = all_cuts, kind = kind, below_n = val("below_n_"), above_n = val("above_n_"),
             below_km = round(val("below_m_", 1000)), above_km = round(val("above_m_", 1000))) |>
        mutate(ratio_n = round(below_n / above_n, 3)))
writeLines(log_lines, path_log)
message("Written ", path_log)
