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
#     version whose tables, schemas or contents differ (knw_publish()). The prefix is public (fresh-bc's
#     bucket policy grants knowledge/*, #56), so an upload is readable by anyone at once.
#
# INPUT:  data/tune/ (0320), data/compare/<key>_compare.csv (0330; the tuned structure, for near_river_scope),
#         the evidence build ledger (0310), data/fdis/publish/manifest.json (0299, v3)
#         and the fwapg database (PG* env vars): the discharge load's comment, for the grade's provenance
# OUTPUT: data/publish/thresholds_v1/{thresholds,thresholds_groups}.parquet + manifest.json (ignored)
#         data/publish/habitat_grade_v1/habitat_grade/species_code=<sp>/stage=<stage>/part.parquet + manifest.json
#         each set's receipt.json beside its manifest (#154): crate's provenance receipt, held to
#         inst/receipt/{thresholds,habitat_grade}.yaml
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

# the ledger the published tables were scored on, not the newest on disk: a build checked and not promoted writes a newer
# one (#111)
ledger_path <- knw_run_ledger(tune_dir)
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
# the thresholds on the load before it (#65). Since #72 every grade table records the load it was graded on
# (discharge_load, written by 0320 from the table comment at grading); the publish refuses when the live load is
# another build, because the grade would then describe flows the segments no longer carry.
pgc <- DBI::dbConnect(RPostgres::Postgres())
discharge_load <- knw_discharge_load(pgc)
DBI::dbDisconnect(pgc)
# the walk's code (#87): a grade walked by other code than this tree's is regraded, never published
walk_md5 <- knw_walk_md5()

# ---- the thresholds table, built first because the grade checks hold each table to its row ----------------
tt <- knw_thresholds_table(tune_dir, evidence_version, run_uid, link_sha, compare_dir = "data/compare")
# ---- the grade tables' records, checked before anything is written or published ---------------
# every check that could refuse the run sits here, ahead of the thresholds write and publish, so a run that stopped
# between the picks and the grades cannot publish the picks alone (the branch review of 2026-10-25, round 5)
gfiles <- list.files(tune_dir, "_grades\\.csv$", full.names = TRUE)
if (!length(gfiles)) stop("no grade tables in ", tune_dir)
# the grade set's description says how the grades were made: each table records it from the call that made it (#72), and
# a table written before the record (#57, #65) or on another convention is refused rather than described wrongly
heads <- lapply(gfiles, function(f) read_csv(f, n_max = 1, show_col_types = FALSE, col_types = cols(.default = "c")))
names(heads) <- basename(gfiles)
stale <- names(heads)[!vapply(heads, function(h) {
  all(c("ref_population", "ref_edge", "walk", "walk_md5", "discharge_load", "grade_withheld", "null_heldout_curve",
        "evidence_md5", "rule", "run_uid") %in% names(h)) &&
    identical(h$ref_population, "stream_branch") && identical(h$walk, "bank") && identical(h$walk_md5, walk_md5) &&
    # graded from a curve fitted on link's segment gradient, the one the segments carry (#92)
    .knw_grade_grad_ok(h)
}, logical(1))]
if (length(stale)) stop("grade tables made before #73 (no record of the bank walk, the reference edge types and the flow build), walked by ",
                        "another walk than this tree's (walk_md5, #87), graded from a curve fitted on another gradient than link's segment gradient ",
                        "(no curve_grad = segment_gradient, #92), or graded ",
                        "before the gate scored no rule on the curve's own visits (no null_heldout_curve; the branch review of 2026-10-25); rerun 0320: ",
                        paste(stale, collapse = ", "))
# the grade is published under the thresholds row's rule_id, so it must have been graded under that row's rule on this
# link run, and every table on one evidence build (the branch review of 2026-10-25: nothing else compares them)
mispick <- names(heads)[!vapply(names(heads), function(f) {
  k <- sub("_grades\\.csv$", "", f)
  row <- tt$thresholds[tt$thresholds$rule_id == paste0(k, "_v1"), , drop = FALSE]
  rule <- unique(row$rule)
  ev <- unique(row$evidence_md5)
  cg <- unique(row$curve_grad)
  length(rule) == 1L && identical(heads[[f]]$rule, rule) && identical(heads[[f]]$run_uid, run_uid) &&
    length(ev) == 1L && !is.na(ev) && identical(heads[[f]]$evidence_md5, ev) &&
    length(cg) == 1L && !is.na(cg) && identical(heads[[f]]$curve_grad, cg)
}, logical(1))]
if (length(mispick)) stop("grade tables graded under another pick, link run, evidence build or gradient than the thresholds table's row (or a ",
                          "row with no evidence or gradient record); rerun 0320: ", paste(mispick, collapse = ", "))
# and every fitted row has its grade table (a withheld key's table is written too), so a run that stopped between the
# picks and the grades cannot publish the picks alone
fitted_keys <- unique(sub("_v1$", "", tt$thresholds$rule_id[tt$thresholds$status %in% c("fitted", "underpowered")]))
no_grade <- setdiff(fitted_keys, sub("_grades\\.csv$", "", names(heads)))
if (length(no_grade)) stop("fitted rules with no grade table in ", tune_dir, " (0320 stopped before grading them?): ",
                           paste(no_grade, collapse = ", "))
evidence <- unique(vapply(heads, function(h) h$evidence_md5, character(1)))
if (length(evidence) != 1) stop("the grade tables were graded on different evidence builds: ", paste(evidence, collapse = " | "))
ref_edges <- unique(vapply(heads, function(h) h$ref_edge, character(1)))
if (length(ref_edges) != 1) stop("the grade tables took their reference over different edge types: ", paste(ref_edges, collapse = " | "))
loads <- unique(vapply(heads, function(h) h$discharge_load, character(1)))
if (length(loads) != 1) stop("the grade tables were graded on different flow builds: ", paste(loads, collapse = " | "))
if (!identical(loads, discharge_load)) {
  stop("the grade tables were graded on another flow build than the live one; regrade (0320) before publishing.\n  graded: ",
       loads, "\n  live:   ", discharge_load)
}
prov_grade <- c(prov, list(discharge_load_at_grade = loads, discharge_load_at_publish = discharge_load, walk = "bank",
                           walk_md5 = walk_md5, evidence_md5 = evidence))
# each set's provenance receipt (#154), in crate's shape: this commit in full, the tuning run(s) the grade tables'
# records name, link's build, the flow load the grades were checked against and the evidence they were graded on.
# The summaries are each set's own, added where the set is built
recs <- lapply(sub("_grades\\.csv$", "_grades_record.csv", gfiles), knw_grade_record_read)
# the grade tables are ignored and the records tracked, so a machine's tables can be another promotion's: each is
# held to its record (size, then md5) before the receipt names the records' run as the tables' (the branch review of
# #154, round 2)
off <- gfiles[!mapply(function(g, r) isTRUE(tryCatch(knw_grade_record_check(r, g), error = function(e) FALSE)),
                      gfiles, recs)]
if (length(off)) stop("grade tables that are not the tables their tracked records describe: ",
                      paste(basename(off), collapse = ", "), "; restore the records' run (PULL=TRUE scripts/0336)")
names(recs) <- basename(gfiles)
# one recipe per set, each naming the tuning run(s) of the grade tables it was made from: the thresholds read every
# key, the grade set only those it publishes (a withheld key is left out of it below)
recipe_of <- function(f) {
  runs <- paste(sort(unique(vapply(recs[basename(f)], function(r) r$tune_run, character(1))), method = "radix"),
                collapse = ";")
  list(code = .knw_receipt_code(knowledge_git),
       config = list(files = .knw_receipt_config_files("settings"), settings = list(tune_run = runs)),
       inputs = list(link_build = list(version_id = run_uid), flow = list(version_id = discharge_load),
                     evidence = list(version_id = evidence)))
}
knowledge_git <- .knw_git_state()

# ---- thresholds -------------------------------------------------------------------------
write_csv(tt$thresholds, "data/thresholds.csv", na = "")
write_csv(tt$groups, "data/thresholds_groups.csv", na = "")
message(sprintf("thresholds: %d rows (%d species x stage fitted), groups: %d rows", nrow(tt$thresholds),
                n_distinct(tt$thresholds$rule_id[tt$thresholds$status %in% c("fitted", "underpowered")]), nrow(tt$groups)))
tables_thr <- data.frame(
  table = c("thresholds", "thresholds_groups"),
  source = c("data/thresholds.csv", "data/thresholds_groups.csv"),
  script = "scripts/0325-publish.R",
  description = c(
    "One row per species x stage x component (size, gradient, exception_q, exception_d) of the rule recommended by the tuning run (knowledge#57): the value in link's parameter name and unit, the range of values within one SE (a parsimony rule of thumb fixed before the run) on the main reading, the readings the rule holds in, the rule the same pick makes at 1.96 SE (rule_196) and whether it keeps the row's value (holds_196), the same picks from link's flow version of default (rule_flow, rule_flow_196), the scope link applies the near-river pair on as the comparison ran it (near_river_scope: both, or wetland_flow; empty where the rule has no pair), default's value and whether default is inside the region, the visits, detections and groups scored, the power label, the gradient the rule was scored on (curve_grad: segment_gradient, link's own segment gradient, knowledge#92), and the evidence version and link run the rule was scored on. The grade is expected use, not habitat quality.",
    "The watershed groups each rule_id was scored on (groups with both outcomes), with the fold each held out in."),
  stringsAsFactors = FALSE)
man_thr <- knw_publish(tables_thr, "data/publish/thresholds_v1", id = "knowledge/thresholds/v1",
                  note = "First tuned thresholds for every species and stage the electrofishing evidence can speak to, on link's province-wide default run (knowledge#57).",
                  provenance = prov, s3 = if (publish) s3 else NULL, republish = republish,
                  receipt = list(output = "thresholds", recipe = recipe_of(gfiles), summary = list(rows = nrow(tt$thresholds))))

# ---- grades ----------------------------------------------------------------------------
# a key whose curve was no better than no rule on held-out groups has its grades withheld (0320, #73): its table
# carries the walks 0330 reads, and no grade, so it is left out of the published set
withheld <- names(heads)[vapply(heads, function(h) identical(h$grade_withheld, "TRUE"), logical(1))]
if (length(withheld)) {
  message("grades withheld, not published: ", paste(sub("_grades\\.csv$", "", withheld), collapse = ", "))
}
gfiles <- gfiles[!basename(gfiles) %in% withheld]
if (!length(gfiles)) stop("every grade table's grades were withheld")
# the stream branch: the edge types the curves' visits were on and the reference was taken over, as the tables record
# them. Off it, on lakes, wetlands and river polygons, the grade extrapolates the curve past its visits, so the table
# says which segments those are
edge_stream <- as.integer(strsplit(ref_edges, ";", fixed = TRUE)[[1]])
grades <- bind_rows(lapply(gfiles, read_csv, show_col_types = FALSE, guess_max = 1e5)) |>
  transmute(blue_line_key, downstream_route_measure, upstream_route_measure, linear_feature_id, watershed_group_code,
            length_metre, access, species_code, stage, grade, grade_class, stream_branch = edge_type %in% edge_stream,
            rule_id = paste(species_code, stage, "v1", sep = "_"), config = "default", link_run_uid = run_uid,
            evidence_version = evidence_version)
dir.create("data/publish", showWarnings = FALSE, recursive = TRUE)
gpath <- "data/publish/habitat_grade.csv"
write_csv(grades, gpath, na = "")
message(sprintf("grades: %d segment rows, %d species x stage", nrow(grades), n_distinct(paste(grades$species_code, grades$stage))))
tables_gr <- data.frame(
  table = "habitat_grade", source = gpath, script = "scripts/0325-publish.R",
  description = paste0("One row per link default segment x species x stage: the segment's FWA position key, its link access code, and its grade (expected use per standard electrofishing visit, read at the segment's own walked distance, from its downstream end to the bank of the first river of the rule's exception flow, or of 10 m3/s where the rule has none, relative to the 95th percentile of accessible stream-branch segments, 0-1, NA where inaccessible or the size or gradient is missing) in fifths; stream_branch, TRUE on the FWA edge types the curve's visits were on (", paste(edge_stream, collapse = ", "), "), FALSE on lines through lakes, wetlands and double-line rivers and on other connectors, where the grade extrapolates the curve past the visits it was fitted on; with the rule_id it was graded under and the link run and evidence version (knowledge#57, knowledge#65, knowledge#73)."),
  stringsAsFactors = FALSE)
man_grade <- knw_publish(tables_gr, "data/publish/habitat_grade_v1", id = "knowledge/habitat_grade/v1",
                  note = "Expected-use grades for every segment of each tuned species' groups on link's province-wide default run (knowledge#57). Hive-partitioned by species_code and stage.",
                  provenance = prov_grade, s3 = if (publish) s3 else NULL, republish = republish, hive = "habitat_grade",
                  receipt = list(output = "habitat_grade", recipe = recipe_of(gfiles),
                                 summary = list(rows = nrow(grades), graded_rows = sum(!is.na(grades$grade)),
                                                km_graded = sum(grades$length_metre[!is.na(grades$grade)]) / 1000,
                                                grade_sum = sum(grades$grade, na.rm = TRUE))))
message("wrote data/publish/{thresholds_v1,habitat_grade_v1} at ", commit, if (!publish) " (PUBLISH is not TRUE: nothing uploaded)")
