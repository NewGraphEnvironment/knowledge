# data-raw/coho_upper_fraser_records.R
# ---------------------------------------------------------------------------
# Every coho record in the Fraser drainage upstream of the Quesnel River's mouth, one row per record, so that each can
# be judged by its source (#284, research/coho_upper_fraser.md). The judgement is written there, keyed by this
# table's record_id; this script judges nothing.
#
# WHY / DESIGN NOTES:
#   - WHERE "UPPER FRASER" STARTS. A record counts when its watershed code lies on a Fraser tributary entering
#     upstream of the Quesnel River (the code's second part above Quesnel's 458399), or on the Fraser mainstem above
#     the Quesnel's mouth. The Quesnel system itself is left out: it is part of the coho range nobody doubts. #284's
#     body took "north of about Quesnel's latitude", which no single latitude reproduces (its 36 bcfishobs records sit
#     between the counts above 52.7 and 52.8 degrees, printed below), so the population is set by the network.
#   - THREE RECORD SETS.
#       obs     bcfishobs (the Province's Known BC Fish Observations matched to the Freshwater Atlas), one row per
#               observation. The row carries the Province's own fields (date, life stage, activity, agency, source,
#               source reference), so its terms are the Province's.
#       fdis    the published FDIS evidence (EVIDENCE_DIR, default data/fdis/derived): each electrofishing visit in
#               the population that caught coho, one row per visit.
#       nuseds  knowledge/nuseds/<VERSION> over HTTPS: one row per coho population whose stream lies in the
#               population, its estimates by year in one field.
#     link's coho range is not written here: its presence table is sourced from bcfishpass (inst/NOTICE.md, #76).
#   - IT CHECKS ITS OWN COUNTS. The script stops unless it finds 24 bcfishobs records in 10 groups, the coho visit
#     in FDIS and five NuSEDS populations, the counts it was written against (2026-11-26; #284's body named three, missing
#     the Nazko River's and the Swift River's, whose one record was not inspected). A change in any of the
#     three inputs then shows as a stop, not as a quietly different table.
#
# INPUT:  a database holding bcfishobs.observations and whse_basemapping.fwa_stream_networks_sp (PG*);
#         EVIDENCE_DIR/visits_link.csv and visits_species.csv; knowledge/nuseds/<VERSION> over HTTPS
# OUTPUT: printed counts; with OUT= the records as a CSV (record_id, record_set, watershed_group_code, waterbody,
#         date, life_stage, activity, agency, source, source_ref, count, detail)
# RUN:    d=$(date -u +%Y%m%d); t=${TMPDIR:-/tmp}/${d}_coho_upper_fraser_records
#         (set -o pipefail; OUT=${t}.csv Rscript data-raw/coho_upper_fraser_records.R 2>&1 | tee ${t}.txt) &&
#           mkdir -p scripts/logs/coho && cp ${t}.txt ${t}.csv scripts/logs/coho/   (repo root)
#         Written outside the repo and copied in after a run that succeeded, as timing_nuseds.R's log is.
#         VERSION=v1 before Rscript   (the NuSEDS set, else v1)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1, width = 200)
source("data-raw/nuseds_dates_read.R")

evidence_dir <- Sys.getenv("EVIDENCE_DIR", "data/fdis/derived")
version <- Sys.getenv("VERSION", "v1")
out <- Sys.getenv("OUT")
quesnel <- 458399L   # the Quesnel River's place on the Fraser (watershed code 100.458399)

con <- DBI::dbConnect(RPostgres::Postgres())

# ---- the Quesnel's mouth on the Fraser mainstem ----
mouth_m <- DBI::dbGetQuery(con, "
  SELECT min(downstream_route_measure) AS m FROM whse_basemapping.fwa_stream_networks_sp
  WHERE wscode_ltree = '100' AND localcode_ltree = '100.458399'")$m
stopifnot(length(mouth_m) == 1L, is.finite(mouth_m))
cat(sprintf("Quesnel River mouth: Fraser mainstem measure %.1f m\n", mouth_m))

# upstream(): a code as ltree text ("100.567134.123") or a FWA dashed code ("100-567134-000000-..."), and the
# measure along it, upstream of the Quesnel's mouth?
upstream <- function(code, measure = NA_real_) {
  parts <- strsplit(gsub("-", ".", code), ".", fixed = TRUE)
  vapply(seq_along(parts), function(i) {
    p <- parts[[i]]
    p <- p[!grepl("^0+$", p)]          # a dashed code pads with zero fields
    if (length(p) == 0L || is.na(p[1]) || p[1] != "100") return(FALSE)
    if (length(p) == 1L) return(!is.na(measure[i]) && measure[i] > mouth_m)
    as.integer(p[2]) > quesnel
  }, logical(1))
}
stopifnot(upstream("100.567134"), !upstream("100.458399.1"), upstream("100-594120-000000"),
          !upstream("100-000000-000000"), upstream("100", mouth_m + 1), !upstream("100", mouth_m - 1))

# ---- obs: bcfishobs ----
obs <- DBI::dbGetQuery(con, "
  SELECT observation_key, fish_observation_point_id, watershed_group_code, wscode::text AS wscode,
         downstream_route_measure, observation_date, point_type_code, gazetted_name, waterbody_type, life_stage,
         activity, agency_name, source, source_ref
  FROM bcfishobs.observations
  WHERE species_code = 'CO' AND wscode <@ '100'::ltree
  ORDER BY watershed_group_code, observation_date, observation_key")
lat <- DBI::dbGetQuery(con, "
  SELECT sum((st_y(st_transform(geom, 4326)) > 52.7)::int)::int AS n527,
         sum((st_y(st_transform(geom, 4326)) > 52.8)::int)::int AS n528
  FROM bcfishobs.observations WHERE species_code = 'CO' AND wscode <@ '100'::ltree")
DBI::dbDisconnect(con)
cat(sprintf("bcfishobs coho in the Fraser drainage: %d; north of 52.7 deg %d, of 52.8 deg %d (#284's body: 36)\n",
            nrow(obs), lat$n527, lat$n528))
obs <- obs[upstream(obs$wscode, obs$downstream_route_measure), , drop = FALSE]
cat(sprintf("bcfishobs coho upstream of the Quesnel's mouth: %d in %d groups (%s)\n", nrow(obs),
            length(unique(obs$watershed_group_code)), paste(sort(unique(obs$watershed_group_code)), collapse = ", ")))
if (nrow(obs) != 24L || length(unique(obs$watershed_group_code)) != 10L) {
  stop("expected 24 bcfishobs records in 10 groups (2026-11-26): the observations or the cut have moved", call. = FALSE)
}
rec_obs <- data.frame(
  record_id = paste0("obs:", obs$observation_key),
  record_set = "obs",
  watershed_group_code = obs$watershed_group_code,
  waterbody = ifelse(is.na(obs$gazetted_name), paste0("(unnamed ", tolower(obs$waterbody_type), ")"), obs$gazetted_name),
  date = format(obs$observation_date),
  life_stage = obs$life_stage,
  activity = obs$activity,
  agency = obs$agency_name,
  source = obs$source,
  source_ref = obs$source_ref,
  count = NA_character_,
  detail = paste0("fish_observation_point_id ", obs$fish_observation_point_id, "; point type ", obs$point_type_code),
  stringsAsFactors = FALSE
)

# ---- fdis: the published electrofishing evidence ----
vl <- readr::read_csv(file.path(evidence_dir, "visits_link.csv"), show_col_types = FALSE, progress = FALSE,
                      col_select = c("site_visit", "watershed_group_code", "wscode", "downstream_route_measure",
                                     "date", "agency", "gnis_name", "data_set"),
                      col_types = readr::cols(.default = readr::col_character()))
vs <- readr::read_csv(file.path(evidence_dir, "visits_species.csv"), show_col_types = FALSE, progress = FALSE,
                      col_types = readr::cols(.default = readr::col_character()))
vl <- vl[!is.na(vl$wscode) & upstream(vl$wscode, as.numeric(vl$downstream_route_measure)), , drop = FALSE]
co <- vs[vs$species_code == "CO" & vs$site_visit %in% vl$site_visit &
           !is.na(vs$n_caught) & as.integer(vs$n_caught) > 0L, , drop = FALSE]
cat(sprintf("FDIS visits upstream of the Quesnel's mouth: %d in %d groups; %d caught coho\n", nrow(vl),
            length(unique(vl$watershed_group_code)), nrow(co)))
if (nrow(co) != 1L) stop("expected one FDIS visit with coho (2026-11-26): the evidence has moved", call. = FALSE)
v <- vl[match(co$site_visit, vl$site_visit), , drop = FALSE]
rec_fdis <- data.frame(
  record_id = paste0("fdis:", v$site_visit),
  record_set = "fdis",
  watershed_group_code = v$watershed_group_code,
  waterbody = v$gnis_name,
  date = v$date,
  life_stage = NA_character_,
  activity = "electrofishing",
  agency = v$agency,
  source = paste("FDIS electrofishing extract,", v$data_set),
  source_ref = NA_character_,
  count = co$n_caught,
  detail = paste0("measured ", co$n_measured, "; fry ", co$n_fry, ", juvenile ", co$n_juvenile, ", unmeasured ",
                  co$n_unmeasured),
  stringsAsFactors = FALSE
)

# ---- nuseds: populations ----
x <- nuseds_read(version, c("pop_id", "gfe_id", "waterbody", "species", "analysis_yr", "natural_adult_spawners",
                            "adult_presence", "fwa_watershed_cde", "estimate_method"))
x <- x[x$species == "Coho" & !is.na(x$fwa_watershed_cde), , drop = FALSE]
x <- x[upstream(x$fwa_watershed_cde), , drop = FALSE]
x <- x[order(x$pop_id, x$analysis_yr), , drop = FALSE]
cat(sprintf("NuSEDS coho records upstream of the Quesnel's mouth: %d, in %d populations\n", nrow(x),
            length(unique(x$pop_id))))
if (length(unique(x$pop_id)) != 5L) stop("expected five NuSEDS coho populations (2026-11-26)", call. = FALSE)
# Both the estimate and DFO's presence flag: a 0 estimate can sit beside adults recorded present.
yr_str <- function(d) paste0(d$analysis_yr, ": ",
                             ifelse(is.na(d$natural_adult_spawners), tolower(d$adult_presence),
                                    paste0(d$natural_adult_spawners, " spawners, ", tolower(d$adult_presence))),
                             collapse = "; ")
pops <- split(x, x$pop_id)
rec_nuseds <- do.call(rbind, lapply(pops, function(d) data.frame(
  record_id = paste0("nuseds:", d$pop_id[1]),
  record_set = "nuseds",
  watershed_group_code = NA_character_,   # placed by data/nuseds_reach_groups.csv where a review places its reach
  waterbody = d$waterbody[1],
  date = paste(range(d$analysis_yr), collapse = "-"),
  life_stage = "adult",
  activity = "escapement",
  agency = "Fisheries and Oceans Canada",
  source = paste0("NuSEDS knowledge/nuseds/", version),
  source_ref = paste0("gfe_id ", d$gfe_id[1], "; ", d$fwa_watershed_cde[1]),
  count = NA_character_,
  detail = paste0(yr_str(d), " (", paste(unique(stats::na.omit(d$estimate_method)), collapse = "; "), ")"),
  stringsAsFactors = FALSE
)))

recs <- rbind(rec_obs, rec_fdis, rec_nuseds)
rownames(recs) <- NULL
stopifnot(!anyDuplicated(recs$record_id))
print(recs[, c("record_id", "watershed_group_code", "waterbody", "date", "source")], right = FALSE)
if (nzchar(out)) {
  readr::write_csv(recs, out, na = "")
  cat("wrote", nrow(recs), "records to", basename(out), "\n")
}
