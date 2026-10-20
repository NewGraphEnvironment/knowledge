# scripts/0325-publish.R
# ---------------------------------------------------------------------------
# Publish the tuning run's results: the thresholds table (one row per species x stage x component of
# the joint pick, in link's parameter names), the groups each rule was scored on, and the grade
# table (one row per segment x species x stage). Issue #57, phase 3. Input from 0320; consumers
# link (link#346) and 0330.
#
# WHY / DESIGN NOTES:
#   - Two datasets, versioned like discharge/fwa/v1 and knowledge/fdis/v3: knowledge/thresholds/v1
#     and knowledge/habitat_grade/v1. A change of columns or meaning is a new version.
#   - The grade table is Hive-partitioned by species_code and stage (link#308's layout), one part
#     per combination, so a consumer reads one species without the rest.
#   - Every row carries the evidence version (the fdis v3 manifest), the link run_uid and link_sha
#     the segments and configs came from, and the config name.
#   - Built locally on every run. PUBLISH=TRUE uploads, and refuses to overwrite a published
#     version whose tables, schemas or contents differ (knw_publish()). The prefix is public only once
#     the bucket policy of #56 is applied; until then a reader needs credentials.
#
# INPUT:  data/tune/ (0320), the evidence build ledger (0310), data/fdis/publish/manifest.json (0299, v3)
#         and the fwapg database (PG* env vars): the discharge load's comment, for the grade's provenance
# OUTPUT: data/publish/thresholds_v1/{thresholds,thresholds_groups}.parquet + manifest.json (ignored)
#         data/publish/habitat_grade_v1/habitat_grade/species_code=<sp>/stage=<stage>/part.parquet + manifest.json
#         data/thresholds.csv, data/thresholds_groups.csv   (tracked copies of the small tables)
#         with PUBLISH=TRUE also: s3://fresh-bc/knowledge/thresholds/v1/ and s3://fresh-bc/knowledge/habitat_grade/v1/
# RUN:    Rscript scripts/0325-publish.R              (from the repo root; local only)
#         PUBLISH=TRUE Rscript scripts/0325-publish.R  (uploads; clean tree)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)

publish <- identical(Sys.getenv("PUBLISH"), "TRUE")
republish <- identical(Sys.getenv("REPUBLISH"), "TRUE")
tune_dir <- "data/tune"
s3 <- "s3://fresh-bc/"
evidence_version <- "knowledge/fdis/v3"

ledger_path <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE), decreasing = TRUE)[1]
led <- read_csv(ledger_path, show_col_types = FALSE, col_types = cols(.default = "c"))
run_uid <- led$note[led$step == "link_run_uid"]
link_sha <- led$note[led$step == "run_link_sha"]
git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed", call. = FALSE)
  out
}
dirty <- git("status", "--porcelain", "--untracked-files=no")
if (length(dirty) && publish) stop("working tree has uncommitted changes; commit before PUBLISH=TRUE", call. = FALSE)
commit <- git("rev-parse", "--short=7", "HEAD")
prov <- list(published_from_commit = commit, repository = "https://github.com/NewGraphEnvironment/knowledge",
             evidence_version = evidence_version, link_run_uid = run_uid, link_sha = link_sha, config = "default",
             tune_logs = sort(list.files("scripts/logs/habitat", "_tune_run.*\\.txt$")))
# the database's discharge load when this publishes, which wet republished on 2026-10-19 (wet#103), after #57 tuned
# the thresholds on the load before it (#65). The grade tables do not record the load they read, so this is the
# load at publish time, named so; it equals the graded load only if wet has not reloaded since 0320 ran (#72).
pgc <- DBI::dbConnect(RPostgres::Postgres())
discharge_load <- DBI::dbGetQuery(pgc, "SELECT obj_description('discharge.fwa_v1_segment_monthly'::regclass) AS d")$d
DBI::dbDisconnect(pgc)
if (length(discharge_load) != 1 || is.na(discharge_load) || !nzchar(discharge_load)) {
  stop("discharge.fwa_v1_segment_monthly carries no load comment; cannot say which flows the grade read")
}
prov_grade <- c(prov, list(discharge_load_at_publish = discharge_load))

# ---- thresholds -------------------------------------------------------------------------
tt <- knw_thresholds_table(tune_dir, evidence_version, run_uid, link_sha)
write_csv(tt$thresholds, "data/thresholds.csv", na = "")
write_csv(tt$groups, "data/thresholds_groups.csv", na = "")
message(sprintf("thresholds: %d rows (%d species x stage fitted), groups: %d rows", nrow(tt$thresholds),
                n_distinct(tt$thresholds$rule_id[tt$thresholds$status %in% c("fitted", "underpowered")]), nrow(tt$groups)))
tables_thr <- data.frame(
  table = c("thresholds", "thresholds_groups"),
  source = c("data/thresholds.csv", "data/thresholds_groups.csv"),
  script = "scripts/0325-publish.R",
  description = c(
    "One row per species x stage x component (size, gradient, exception_q, exception_d) of the rule recommended by the tuning run (knowledge#57): the value in link's parameter name and unit, the one-SE range on the main reading, the readings the rule holds in, default's value and whether default is inside the region, the visits, detections and groups scored, the power label, and the evidence version and link run the rule was scored on. The grade is expected use, not habitat quality.",
    "The watershed groups each rule_id was scored on (groups with both outcomes), with the fold each held out in."),
  stringsAsFactors = FALSE)
man_thr <- knw_publish(tables_thr, "data/publish/thresholds_v1", id = "knowledge/thresholds/v1",
                  note = "First tuned thresholds for every species and stage the electrofishing evidence can speak to, on link's province-wide default run (knowledge#57).",
                  provenance = prov, s3 = if (publish) s3 else NULL, republish = republish)

# ---- grades ----------------------------------------------------------------------------
gfiles <- list.files(tune_dir, "_grades\\.csv$", full.names = TRUE)
if (!length(gfiles)) stop("no grade tables in ", tune_dir)
# the description below says how the grades were made (#65): refuse a table 0320 wrote before that
stale <- gfiles[!vapply(gfiles, function(f) {
  h <- read_csv(f, n_max = 1, show_col_types = FALSE, col_types = cols(.default = "c"))
  "ref_population" %in% names(h) && identical(h$ref_population, "stream_branch")
}, logical(1))]
if (length(stale)) stop("grade tables made before #65 (no ref_population = stream_branch); rerun 0320: ",
                        paste(basename(stale), collapse = ", "))
grades <- bind_rows(lapply(gfiles, read_csv, show_col_types = FALSE, guess_max = 1e5)) |>
  transmute(blue_line_key, downstream_route_measure, upstream_route_measure, linear_feature_id, watershed_group_code,
            length_metre, access, species_code, stage, grade, grade_class,
            rule_id = paste(species_code, stage, "v1", sep = "_"), config = "default", link_run_uid = run_uid,
            evidence_version = evidence_version)
dir.create("data/publish", showWarnings = FALSE, recursive = TRUE)
gpath <- "data/publish/habitat_grade.csv"
write_csv(grades, gpath, na = "")
message(sprintf("grades: %d segment rows, %d species x stage", nrow(grades), n_distinct(paste(grades$species_code, grades$stage))))
tables_gr <- data.frame(
  table = "habitat_grade", source = gpath, script = "scripts/0325-publish.R",
  description = "One row per link default segment x species x stage: the segment's FWA position key, its link access code, and its grade (expected use per standard electrofishing visit, read at the segment's own walked distance to the first river of the rule's exception flow, or of 10 m3/s where the rule has none, relative to the 95th percentile of accessible stream-branch segments (FWA edge types 1000, 1100, 2000, 2300), 0-1, NA where inaccessible or the size or gradient is missing) in fifths, with the rule_id it was graded under and the link run and evidence version (knowledge#57, knowledge#65).",
  stringsAsFactors = FALSE)
man_grade <- knw_publish(tables_gr, "data/publish/habitat_grade_v1", id = "knowledge/habitat_grade/v1",
                  note = "Expected-use grades for every segment of each tuned species' groups on link's province-wide default run (knowledge#57). Hive-partitioned by species_code and stage.",
                  provenance = prov_grade, s3 = if (publish) s3 else NULL, republish = republish, hive = "habitat_grade")
message("wrote data/publish/{thresholds_v1,habitat_grade_v1} at ", commit, if (!publish) " (PUBLISH is not TRUE: nothing uploaded)")
