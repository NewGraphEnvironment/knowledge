# scripts/0299-fdis-publish.R
# ---------------------------------------------------------------------------
# Publish the FDIS visit-level tables as Parquet with a manifest, and the FDIS extract's
# provenance note. Issue #56.
#
# WHY / DESIGN NOTES:
#   - The Province agreed (2026-10-16) to the FDIS extract being public provided it carries a
#     note of when and from where it was received. The extract stays as received under
#     s3://fresh-bc/fdis/; data/fdis_README.md is the tracked source of its README.
#   - The tables built from it are ours, so they go under s3://fresh-bc/knowledge/fdis/v2/ (named
#     by producer, versioned like discharge/fwa/v1/ so a consumer can pin one). The bucket does
#     not list, so readers start from manifest.json. A change to a table's columns or meaning
#     is a new version, never an overwrite of the last: the manifest records each table's schema, and
#     PUBLISH=TRUE stops when the published manifest's tables or schemas differ (bump s3_id).
#     A change of meaning with the same schema is the one case it cannot see.
#   - v2 (#35): 0230 keeps one copy of a survey loaded under several collection ids, so every table
#     has fewer rows, and ch_mad_visits and ch_rule_visits lose `dup_of`. v1 stays as published.
#     v2 also carries fdis_repeat_surveys, the crosswalk from a v1 site_visit to the copy kept.
#   - v3, unpublished, also places the visits with fresh's snap and the 1:50k code (#91): fdis_sites
#     gains snap_method, snap_confirmed, snap_moved and nearest_distance_m, and its blue_line_key,
#     measure, distance and flags are the new placement's. v3 has not been published, so no bump.
#   - Republishing to a version that exists refuses when any table's sha256 or row count differs
#     from the published manifest, unless REPUBLISH=TRUE: a published version is not rewritten by
#     accident, including by a change of meaning that keeps the schema.
#   - Only fdis_sites.csv is taken of 0240's two forms: the gpkg is the same rows with a
#     geometry, and a CSV-to-Parquet copy keeps one reading of each table.
#   - knw_publish() writes the set (#160; this script carried its own copy of the code before): each
#     table is read with arrow's CSV reader and written as Parquet, then compared column by column
#     with an all-character read of the CSV (numbers within 1e-12), so a type arrow inferred wrongly
#     (an id losing leading zeros, a misread date) stops the run.
#   - v3 carries a receipt.json beside its manifest (#160), crate's provenance receipt held to
#     inst/receipt/fdis.yaml: this commit, the evidence build by the recipe_id of the receipt 0310
#     wrote beside the tables (refused where there is none, or one describing other tables), and the
#     FDIS extract by its MANIFEST.md5; every table fingerprinted as written, exact but access_check's
#     km, rounded as the evidence build's. v2 is published and frozen, and carries none.
#   - The CSVs were built by earlier runs, so the manifest records each source CSV's sha256 and
#     modification time, and the commit it was published from (`published_from_commit`), which
#     needs a clean working tree.
#   - PULL=TRUE is the way back: a machine without the CSVs (0230 no longer syncs them) fetches
#     the Parquet, checks each sha256 against the manifest, and writes data/fdis/derived/*.csv
#     for 0291-0298. NO_SIGN=TRUE reads without AWS credentials: the prefix is public.
#
# INPUT:  data/fdis/derived/{fdis_sites,bt_use_visits,ch_mad_visits,ch_rule_visits,ch_rule_walks}.csv
#         (scripts/0240, 0290, 0294, 0296), data/fdis_README.md; for v3 also 0310's tables and its
#         evidence_receipt.json, and data/fdis/MANIFEST.md5 (0230)
# OUTPUT: data/fdis/publish/ (ignored): <table>.parquet, manifest.json, and for v3 receipt.json
#         with PUBLISH=TRUE also: s3://fresh-bc/knowledge/fdis/<version>/ (the Parquet, receipt and manifest)
#         and s3://fresh-bc/fdis/README.md
#         with PULL=TRUE instead: data/fdis/derived/<table>.csv from the published Parquet
# RUN:    Rscript scripts/0299-fdis-publish.R              (from the repo root; local only; VERSION=v3)
#         PUBLISH=TRUE Rscript scripts/0299-fdis-publish.R  (uploads; needs write access to fresh-bc)
#         PUBLISH=TRUE REPUBLISH=TRUE ...                   (replace a published version's contents)
#         PULL=TRUE [VERSION=v2] [NO_SIGN=TRUE] Rscript scripts/0299-fdis-publish.R
#         VERSION names the dataset version (default v3). v2 is the pre-#57 set that 0291-0298 read;
#         v3 (#57) adds 0310's tables and rebuilds the species tables from them.
# ---------------------------------------------------------------------------
suppressMessages({ library(arrow) })
pkgload::load_all(quiet = TRUE)

publish <- identical(Sys.getenv("PUBLISH"), "TRUE")
pull <- identical(Sys.getenv("PULL"), "TRUE")
no_sign <- identical(Sys.getenv("NO_SIGN"), "TRUE")
republish <- identical(Sys.getenv("REPUBLISH"), "TRUE")
if (publish && pull) stop("PUBLISH and PULL are exclusive", call. = FALSE)
dir_in <- "data/fdis/derived"
dir_out <- "data/fdis/publish"
version <- Sys.getenv("VERSION", "v3")
if (!version %in% c("v2", "v3")) stop("VERSION must be v2 or v3", call. = FALSE)
s3_id <- paste0("knowledge/fdis/", version)
s3_supersedes <- paste0("knowledge/fdis/", c(v2 = "v1", v3 = "v2")[[version]])
s3_tables <- paste0("s3://fresh-bc/", s3_id, "/")
s3_readme <- "s3://fresh-bc/fdis/README.md"
path_readme <- "data/fdis_README.md"

tables_v2 <- data.frame(
  table = c("fdis_sites", "bt_use_visits", "ch_mad_visits", "ch_rule_visits", "ch_rule_walks",
            "fdis_repeat_surveys"),
  source = c(file.path(dir_in, c("fdis_sites", "bt_use_visits", "ch_mad_visits", "ch_rule_visits",
                                 "ch_rule_walks")), "data/fdis_repeat_surveys") |> paste0(".csv"),
  script = c("scripts/0240-fdis-evidence.R", "scripts/0290-bt-use-build.R",
             "scripts/0294-ch-mad-build.R", "scripts/0296-ch-rule-build.R",
             "scripts/0296-ch-rule-build.R", "scripts/0230-fdis-load.R"),
  description = c(
    "One row per FDIS site visit (passes rolled up): placement on the FWA network, effort, measured habitat and catch. A survey loaded under several collection ids is kept once (#35; the copies dropped are listed in the repository's data/fdis_repeat_surveys.csv).",
    "FDIS site visits placed on link's segments, with pooled BT presence and the attributes the BT rearing use curve reads (#28).",
    "FDIS site visits with the published annual flow (MAD) on their FWA segment, distance to the first large river, and placement flags (#52).",
    "FDIS site visits with the attributes the tuned CH rearing rule is scored on: flow, width, gradient, barrier status, hydrologic zone (#54).",
    "Downstream walks from each CH visit to rivers of 1-50 m3/s on each flow source, read by the CH rule tuning (#54).",
    "Every other member of a group of FDIS visits that match as one survey loaded under several collection ids, with the copy kept: `dropped` (absent from the other tables from v2), or kept because the copies share one collection or differ in site number without identical measured fish (#35). The crosswalk from a v1 site_visit."),
  stringsAsFactors = FALSE)
# v3 (#57): the one evidence build's tables, and the species tables rebuilt from it on the
# province-wide fresh_default (the step-5 and score284 columns of v2's bt_use_visits are gone)
tables_v3 <- rbind(
  tables_v2[tables_v2$table %in% c("fdis_sites", "fdis_repeat_surveys"), ],
  data.frame(
    table = c("visits_link", "visits_species", "walks", "bcfishobs_fdis_match", "access_check"),
    source = file.path(dir_in, paste0(c("visits_link", "visits_species", "walks", "bcfishobs_fdis_match",
                                        "access_check"), ".csv")),
    script = "scripts/0310-evidence-build.R",
    description = c(
      "One row per quality-passed FDIS site visit placed on a link `default` segment (province-wide `fresh_default`): the visit's effort, measured habitat and catch, the segment's attributes and elevation, link's access code per species and its habitat flags per species (re-gated on access, with the stored flag beside), wet's annual flow by source with the parent fallback, the width link reads on an unmeasured stream, regulated reach, natural barrier downstream per species, and hydrologic zone (#57).",
      "One row per placed visit and species: fish caught, measured per size class, presence, whether an absence is blocked by a code that could hide the species, DV pooling for BT, and whether the group is in link's range for the species (#57).",
      "Downstream walks from every placed visit to the first river of 1-50 m3/s on each flow source, with the target's lake and regulated flags (#57); since #73 the distance ends at the river's bank with every hop's gap counted (fresh's convention), beside the centreline distance (dist_centre_m) and what the bank rule took off (bank_m).",
      "bcfishobs records matched to the FDIS visit they came from by collection, species and date, with the match class (#57, #23).",
      "link#349's cross-tabulation of streams_habitat_<sp>.accessible against streams_access.access_<sp> per species and watershed group (#57, #120), on the build's link run."),
    stringsAsFactors = FALSE),
  tables_v2[tables_v2$table %in% c("bt_use_visits", "ch_mad_visits", "ch_rule_visits", "ch_rule_walks"), ])
tables_v3$description[tables_v3$table %in% c("bt_use_visits", "ch_mad_visits", "ch_rule_visits", "ch_rule_walks")] <-
  paste(tables_v3$description[tables_v3$table %in% c("bt_use_visits", "ch_mad_visits", "ch_rule_visits", "ch_rule_walks")],
        "From v3 written from visits_link by its script, on the province-wide link run; bt_use_visits no longer carries the held-out role, step-5 class or score284 columns (#57).")
tables <- if (version == "v2") tables_v2 else tables_v3
rownames(tables) <- NULL

stopifnot("run from the repo root" = file.exists("DESCRIPTION") && dir.exists("scripts"))

aws <- function(...) {
  args <- c(..., if (no_sign) "--no-sign-request")
  rc <- system2("aws", shQuote(args))   # system2 runs a shell; a content type carries ";"
  if (rc != 0) stop("aws ", paste(args, collapse = " "), " failed (exit ", rc, ")", call. = FALSE)
}
sha256 <- function(path) {
  out <- system2("shasum", c("-a", "256", shQuote(path)), stdout = TRUE)
  if (!is.null(attr(out, "status"))) stop("shasum failed on ", path, call. = FALSE)
  strsplit(out, " ")[[1]][1]
}

# ---- pull: published Parquet -> data/fdis/derived/*.csv ------------------------
if (pull) {
  dir.create(dir_out, recursive = TRUE, showWarnings = FALSE)
  dir.create(dir_in, recursive = TRUE, showWarnings = FALSE)
  path_manifest <- file.path(dir_out, "manifest.json")
  aws("s3", "cp", paste0(s3_tables, "manifest.json"), path_manifest, "--only-show-errors")
  man <- jsonlite::read_json(path_manifest)
  for (f in man$files) {
    dst <- file.path(dir_out, f$path)
    aws("s3", "cp", paste0(s3_tables, f$path), dst, "--only-show-errors")
    if (!identical(sha256(dst), f$sha256)) stop(f$path, ": sha256 differs from the manifest", call. = FALSE)
    out <- file.path(dir_in, paste0(f$table, ".csv"))
    if (file.exists(out)) stop(out, " exists; move it aside to pull", call. = FALSE)
    # written aside and moved in once complete, so an interrupted pull leaves no CSV that
    # 0291-0298 would read as whole
    part <- paste0(out, ".part")
    arrow::write_csv_arrow(arrow::read_parquet(dst), part)
    n <- arrow::read_csv_arrow(part, as_data_frame = FALSE)$num_rows
    if (n != f$rows) stop(part, ": ", n, " rows, the manifest says ", f$rows, call. = FALSE)
    if (!file.rename(part, out)) stop("could not move ", part, " into place", call. = FALSE)
    message(sprintf("%-15s %8d rows -> %s", f$table, f$rows, out))
  }
  quit(save = "no", status = 0)
}

missing_in <- tables$source[!file.exists(tables$source)]
if (length(missing_in)) stop("missing input: ", paste(missing_in, collapse = ", "), call. = FALSE)
if (!file.exists(path_readme)) stop("missing ", path_readme, call. = FALSE)
# v3 describes access_check per species and group (#120): a table built before that has no group column
if ("access_check" %in% tables$table &&
    !"watershed_group_code" %in% names(utils::read.csv(tables$source[tables$table == "access_check"], nrows = 1))) {
  stop(tables$source[tables$table == "access_check"], " has no watershed_group_code: it was built before #120, so ",
       "rerun scripts/0310 before publishing", call. = FALSE)
}

# a publish needs a clean tree, every tracked file (a source CSV like data/fdis_repeat_surveys.csv included); the
# receipt records the package and scripts' state, as every receipt does
dirty <- .knw_git(".", "status", "--porcelain", "--untracked-files=no")
if (length(dirty) && publish) stop("working tree has uncommitted changes; commit before PUBLISH=TRUE", call. = FALSE)
knowledge_git <- .knw_git_state()
commit <- substr(knowledge_git$commit, 1, 7)

# v3's receipt (#160), held to inst/receipt/fdis.yaml: this commit in full, the evidence build the tables are, by the
# receipt 0310 wrote beside them (refused where there is none, or where it does not describe them), and the FDIS
# extract as received. Every table fingerprinted as written but access_check's km, rounded as the evidence build's
receipt <- NULL
if (version == "v3") {
  ev_id <- .knw_evidence_recipe_id(dir_in)
  if (is.null(ev_id)) {
    stop(dir_in, " has no ", .knw_evidence_receipt_file, ": v3 names the evidence build by its receipt, so rebuild ",
         "the evidence with scripts/0310 before publishing it", call. = FALSE)
  }
  fdis_manifest <- "data/fdis/MANIFEST.md5"
  if (!file.exists(fdis_manifest)) stop("no ", fdis_manifest, ": it names the FDIS extract (rerun 0230)", call. = FALSE)
  inputs <- list(evidence = list(recipe_id = ev_id), fdis_export = list(sha256 = .knw_sha256(fdis_manifest)))
  visits <- arrow::read_csv_arrow(file.path(dir_in, "visits_link.csv"), as_data_frame = FALSE)$num_rows
  receipt <- list(output = "fdis",
                  recipe = list(code = .knw_receipt_code(knowledge_git),
                                config = list(settings = list(version = version)), inputs = inputs, seed = NULL),
                  summary = list(visits = visits))
}

# knw_publish() writes each table as Parquet, checks it column by column against an all-character read of its CSV,
# writes the manifest (each file's rows, columns, bytes, sha256 and schema, the source CSV's sha256 and modification
# time) and the receipt, and with PUBLISH=TRUE refuses a published version with other tables or schemas, or other
# contents unless REPUBLISH=TRUE, before it uploads the Parquet, then the receipt, then the manifest
manifest <- knw_publish(
  tables, dir_out, id = s3_id,
  note = if (version == "v2") {
    paste("v2 keeps one copy of an FDIS survey loaded under several collection ids (knowledge#35);",
          "fdis_repeat_surveys maps each v1 site_visit that left to the copy kept.")
  } else {
    paste("v3 is the one evidence build for every species on the province-wide link default run (knowledge#57):",
          "visits_link, visits_species, walks, bcfishobs_fdis_match and access_check are new, and the four",
          "species tables are written from visits_link. v2 stays as published for the scripts frozen on it.")
  },
  provenance = list(
    published_from_commit = commit,
    repository = "https://github.com/NewGraphEnvironment/knowledge",
    source = paste0(
      "Built from the Province of British Columbia's FDIS electrofishing extract (exports of ",
      "2020-11-16 and 2022-03-22), published as received under s3://fresh-bc/fdis/ with its ",
      "provenance note (README.md there).")),
  supersedes = s3_supersedes, s3 = if (publish) "s3://fresh-bc/" else NULL, republish = republish,
  no_sign = no_sign, receipt = receipt)
for (f in manifest$files) {
  message(sprintf("%-20s %8d rows %3d cols  %5.1f MB parquet", f$table, f$rows, f$columns, f$bytes / 1e6))
}
message("wrote ", dir_out, "/ (", nrow(tables), " tables, manifest.json", if (!is.null(receipt)) ", receipt.json",
        ") at ", commit, if (length(dirty)) " (working tree dirty: local only)")

if (!publish) {
  message("PUBLISH is not TRUE: nothing uploaded")
  quit(save = "no", status = 0)
}
# the extract's provenance note, last: the tables built from it are up
aws("s3", "cp", path_readme, s3_readme, "--content-type", "text/markdown; charset=utf-8", "--only-show-errors")
message("uploaded ", s3_readme)
