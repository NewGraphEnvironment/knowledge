# data-raw/vignette_method.R
# ---------------------------------------------------------------------------
# The data `vignettes/_tuning_method.Rmd` reads, so the methodology article builds with no database and cannot
# quote a count the run did not make. Issue #93.
#
# WHY / DESIGN NOTES:
#   - THE REGISTERS ARE THE SPINE. inst/method/pipeline.csv names the steps and settings.csv every number that
#     shapes a result. Each settings `where` is resolved here against the code and the run: `fn:`, `script:` and
#     `code:` through the package's own resolver (tests/testthat/test-settings-register.R holds the same three);
#     `ext:` in the sibling repo at the commit the run used (link's configs at the comparison's `config_sha`, wet at
#     the flow build the database held, from the grade tables' `discharge_load`); `record:` from every fitted key's
#     saved summary. A value that does not hold stops the script, so the article cannot print a register the run
#     contradicts.
#   - THE FUNNEL IS RECOMPUTED, THEN CHECKED. The evidence ledger counts the drops before link's segment, in the
#     order they ran; data/fdis/build/reconcile.csv splits "not placed" into no usable point and no stream in reach.
#     The tuning's population filters (stream branch, fished area, range, blocked, barrier) are not ledgered, so they
#     are applied here step by step to the run's own visit tables, and each rearing key's last count must equal its
#     summary's `visits_in` and its default rule's scored visits, or the script stops. The visit tables are the run's:
#     their md5s must equal the grade tables' `evidence_md5`.
#   - THE DIAGRAMS ARE STATIC SVG, written by Graphviz (DiagrammeR, DiagrammeRsvg) and saved as text, so the article
#     needs neither package: package is shown by box colour; the hex stickers were tried beside the legend and dropped,
#     because at a legible chart width they are identical black hexes whose names cannot be read (#93's decision:
#     clarity first).
#   - THE WORKED EXAMPLES: one Bulkley visit kept and one dropped for its snap distance, each with the streams within
#     the search radius (the database's fwa_stream_networks_sp); and the Bulkley segments of the chinook article's
#     bundle, counted by what each stage of the comparison did to them (fresh's predicate, then link's user-habitat
#     overlay and the connectivity pass together, which the saved flags cannot separate).
#
# INPUT:  inst/method/{pipeline,settings}.csv; scripts/logs/habitat/<date>_evidence_build_ledger.csv (the newest);
#         data/fdis/build/reconcile.csv and data/fdis/derived/{visits_link,visits_species,walks,fdis_sites}.csv
#         (ignored; 0230, 0310); data/tune/<key>_{summary,tune,grades}.csv; data/compare/<key>_compare.csv;
#         inst/vignette-data/bulk_segments.rds; ../link and ../wet checkouts holding the run's commits; the fwapg
#         database (PG* environment variables) for the snap example.
# OUTPUT: inst/vignette-data/method.rds   one named list: pipeline, settings (with each where's resolved value),
#         funnel, funnel_species, steps, examples, svg (flow, lineage), meta (md5 of every source, written date, commit)
# RUN:    Rscript data-raw/vignette_method.R   (from the repo root, after any rerun of 0230, 0310, 0320 or 0330, and
#         after any change to the registers)
# ---------------------------------------------------------------------------
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
})
pkgload::load_all(quiet = TRUE)

dir_out <- "inst/vignette-data"
f_pipeline <- "inst/method/pipeline.csv"
f_settings <- "inst/method/settings.csv"
ledger <- sort(list.files("scripts/logs/habitat", "_evidence_build_ledger\\.csv$", full.names = TRUE),
               decreasing = TRUE)[1]
f_reconcile <- "data/fdis/build/reconcile.csv"
derived <- c(visits_link = "data/fdis/derived/visits_link.csv", visits_species = "data/fdis/derived/visits_species.csv",
             walks = "data/fdis/derived/walks.csv")
f_sites <- "data/fdis/derived/fdis_sites.csv"
link_repo <- Sys.getenv("LINK_REPO", "../link")
wet_repo <- Sys.getenv("WET_REPO", "../wet")
example_wsg <- "BULK"
rd <- function(f, ...) read_csv(f, show_col_types = FALSE, progress = FALSE, ...)

# ---- the run: fitted keys, their evidence and flow build -------------------------------------------
summ <- bind_rows(lapply(sort(list.files("data/tune", "_summary\\.csv$", full.names = TRUE)),
                         rd, col_types = cols(.default = "c")))
fitted <- summ |> filter(status == "fitted")
keys <- paste(fitted$species_code, fitted$stage, sep = "_")
f_tune <- file.path("data/tune", paste0(keys, "_tune.csv"))
f_grades <- file.path("data/tune", paste0(keys, "_grades.csv"))
f_compare <- sort(list.files("data/compare", "_compare\\.csv$", full.names = TRUE))
g1 <- lapply(f_grades, rd, n_max = 1, col_types = cols(.default = "c"))
ev <- unique(vapply(g1, function(g) g$evidence_md5, ""))
if (length(ev) != 1) stop("the grade tables were made on ", length(ev), " evidence builds")
if (!identical(ev, paste(unname(tools::md5sum(derived)), collapse = ";"))) {
  stop("data/fdis/derived is not the evidence the grades were made on: rerun 0310 or restore its tables")
}
loads <- unique(vapply(g1, function(g) g$discharge_load, ""))
if (length(loads) != 1) stop("the grade tables were made on ", length(loads), " flow loads")
wet_sha <- regmatches(loads, regexpr("(?<=wet )[0-9a-f]{7,40}", loads, perl = TRUE))
if (length(wet_sha) != 1) stop("no wet commit in the flow load: ", loads)
cfg_sha <- unique(unlist(lapply(f_compare, function(f) rd(f, col_types = cols(.default = "c"))$config_sha)))
if (length(cfg_sha) != 1) stop("the comparison read ", length(cfg_sha), " link config commits")

# ---- the registers, each value resolved -------------------------------------------------------------
pipeline <- rd(f_pipeline, col_types = cols(.default = "c", step = "i"))
settings <- rd(f_settings, col_types = cols(.default = "c", step = "i"), na = character())
git_show <- function(repo, sha, path) {
  out <- suppressWarnings(system2("git", c("-C", repo, "show", paste0(sha, ":", path)), stdout = TRUE, stderr = TRUE))
  if (!is.null(attr(out, "status"))) stop("git show ", sha, ":", path, " in ", repo, " failed: ", out[1])
  out
}
ext_value <- function(w) {
  repo <- c(link = link_repo, wet = wet_repo)[[w$parts[1]]]
  sha <- c(link = cfg_sha, wet = wet_sha)[[w$parts[1]]]
  txt <- git_show(repo, sha, w$parts[2])
  if (grepl("\\.csv$", w$parts[2])) {
    v <- utils::read.csv(text = txt, colClasses = "character")[[w$parts[3]]]
    if (is.null(v)) stop(w$parts[2], " has no column ", w$parts[3])
    v <- unique(v[!is.na(v) & nzchar(v) & v != "NA"])
    return(list(value = .knw_setting_parse(paste(v, collapse = ";")), sha = sha))
  }
  if (grepl("\\.ya?ml$", w$parts[2])) {
    y <- yaml::yaml.load(paste(txt, collapse = "\n"))
    for (k in strsplit(w$parts[3], ".", fixed = TRUE)[[1]]) y <- if (is.list(y)) y[[k]] else NULL
    return(list(value = if (is.null(y)) "unset" else as.character(y), sha = sha))
  }
  tf <- tempfile(fileext = ".R")
  on.exit(unlink(tf))
  writeLines(txt, tf)
  list(value = .knw_where_value(paste0("script:", basename(tf), ":", w$parts[3]), dirname(tf)), sha = sha)
}
record_value <- function(w) {
  tbl <- sub("\\$.*$", "", w$parts[1])
  col <- sub("^.*\\$", "", w$parts[1])
  if (tbl != "summary") stop("record: reads the summaries only, not ", tbl)
  v <- unique(fitted[[col]])
  v <- v[!is.na(v) & nzchar(v)]
  .knw_setting_parse(paste(v, collapse = ";"))
}
resolved <- list()
for (i in seq_len(nrow(settings))) {
  want <- .knw_setting_parse(settings$value[i])
  for (where in strsplit(settings$where[i], ";", fixed = TRUE)[[1]]) {
    w <- .knw_where_parse(where)
    sha <- NA_character_
    if (w$kind == "ext") {
      e <- ext_value(w)
      sha <- e$sha
      got <- e$value
    } else {
      got <- switch(w$kind,
                    fn = .knw_where_value(where),
                    script = .knw_where_value(where, "."),
                    code = if (.knw_where_count(where, settings$value[i], ".") >= 1) want else "absent",
                    record = record_value(w))
    }
    if (!identical(got, want)) {
      stop(settings$key[i], ": ", where, " holds ", paste(got, collapse = ";"), ", the register ", settings$value[i])
    }
    resolved[[length(resolved) + 1L]] <- tibble(key = settings$key[i], where = where, kind = w$kind, sha = sha)
  }
}
resolved <- bind_rows(resolved)

# ---- the funnel: every visit to the scored populations ----------------------------------------------
led <- rd(ledger, col_types = cols(.default = "c"))
ln <- function(step) as.numeric(led$n[led$step == step])
rec <- rd(f_reconcile, col_types = cols(.default = "c"))
rn <- function(metric) as.numeric(rec[[2]][rec[[1]] == metric])
n_in <- ln("fdis_sites_in")
n_utm <- rn("sites_with_utm")
n_placed <- rn("sites_placed")
if (n_in - n_placed != ln("not_placed")) stop("the reconcile's placed count does not match the ledger's not_placed")
drops <- c("far_snap", "ws50_mismatch", "junk_date", "effort_sentinel_or_none", "catch_unknown", "no_link_segment")
why <- c(far_snap = "snapped more than 100 m from its stream",
         ws50_mismatch = "on a stream outside the 1:50k tributary code FDIS recorded",
         junk_date = "no usable date", effort_sentinel_or_none = "no fished area or time",
         catch_unknown = "catch neither fish nor an explicit zero",
         no_link_segment = "no link segment at the visit's measure")
funnel <- tibble(stage = c("FDIS visits", "with a usable point", "placed on the Atlas"),
                 n = c(n_in, n_utm, n_placed),
                 reason = c(NA, "no usable UTM point", "no stream within 500 m"))
n <- n_placed
for (d in drops) {
  n <- n - ln(d)
  funnel <- bind_rows(funnel, tibble(stage = d, n = n, reason = why[[d]]))
}
vl <- rd(derived[["visits_link"]], guess_max = 1e5,
         col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c", hydro_zone = "c"))
vs <- rd(derived[["visits_species"]], col_types = cols(site_visit = "c"))
if (nrow(vl) != n) stop("visits_link holds ", nrow(vl), " visits; the ledger leaves ", n)
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
area_range <- eval(fm$area_range)
stream <- vl$edge_type %in% edge_stream & !(vl$wb_river %in% TRUE) & !(vl$wb_wetland %in% TRUE) &
  !(vl$wb_lake %in% TRUE)
area_ok <- !is.na(vl$area_m2) & vl$area_m2 >= area_range[1] & vl$area_m2 <= area_range[2]
funnel_species <- list()
for (k in keys[fitted$stage == "rear"]) {
  sp <- sub("_rear$", "", k)
  s_row <- fitted[fitted$species_code == sp & fitted$stage == "rear", ]
  st <- vs[vs$species_code == sp, c("site_visit", "status", "in_range")]
  d <- vl[stream & area_ok, ]
  steps <- c(kept = nrow(vl), stream_branch = sum(stream), fished_area = nrow(d))
  d <- merge(d, st, by = "site_visit")
  d <- d[d$in_range %in% TRUE, ]
  steps["in_range"] <- nrow(d)
  d <- d[d$status != "blocked", ]
  steps["not_blocked"] <- nrow(d)
  bcol <- paste0("barrier_dnstr_", tolower(sp))
  d <- d[d[[bcol]] %in% FALSE, ]
  steps["no_barrier"] <- nrow(d)
  tn <- rd(file.path("data/tune", paste0(k, "_tune.csv")), col_types = cols(.default = "c"))
  steps["scored"] <- as.numeric(tn$n_visits[tn$is_default == "TRUE"])
  if (steps[["no_barrier"]] != as.numeric(s_row$visits_in)) {
    stop(k, ": the recomputed population is ", steps[["no_barrier"]], ", the run's visits_in ", s_row$visits_in)
  }
  funnel_species[[k]] <- tibble(species_code = sp, stage = names(steps), n = unname(steps),
                                groups_both = as.numeric(s_row$groups_both))
}
funnel_species <- bind_rows(funnel_species)

# ---- step blocks: counts in and out -------------------------------------------------------------------
steps <- list(
  `1` = c(visits = n_in),
  `2` = c(placed = n_placed, kept_after_snap = n_placed - ln("far_snap") - ln("ws50_mismatch"),
          ws50_checked = rn("sites_ws50_checked"), ws50_mismatch_all = rn("sites_ws50_mismatch")),
  `5` = c(kept = nrow(vl), routed = sum(vl$pick_source == "pcic_routed", na.rm = TRUE),
          balance = sum(vl$pick_source == "wet_balance", na.rm = TRUE)),
  `6` = vapply(f_tune, function(f) as.numeric(nrow(rd(f, col_types = cols(.default = "c")))), 0) |>
    stats::setNames(keys),
  `7` = stats::setNames(as.numeric(fitted$region_n), keys)
)

# ---- worked examples ----------------------------------------------------------------------------------
sites <- rd(f_sites, guess_max = 1e5,
            col_types = cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c"))
conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
near <- function(s) {
  DBI::dbGetQuery(conn, sprintf("
    WITH p AS (SELECT ST_Transform(ST_SetSRID(ST_MakePoint(%.3f, %.3f), %d), 3005) AS g)
    SELECT s.blue_line_key, s.gnis_name, round(min(ST_Distance(s.geom, p.g))::numeric, 1) AS distance_m
      FROM whse_basemapping.fwa_stream_networks_sp s, p
     WHERE ST_DWithin(s.geom, p.g, 500)
     GROUP BY s.blue_line_key, s.gnis_name
     ORDER BY 3, 1", s$utm_easting, s$utm_northing, 32600L + as.integer(s$utm_zone)))
}
pick_example <- function(cand) {
  for (i in seq_len(nrow(cand))) {
    nb <- near(cand[i, ])
    if (nrow(nb) >= 3) return(list(site = cand[i, ], near = nb))
  }
  stop("no ", example_wsg, " visit with three streams in reach")
}
bulk <- sites[sites$watershed_group_code %in% example_wsg & !sites$flag_not_placed, ]
bulk <- bulk[order(bulk$site_visit), ]
ws50_ok <- bulk$ws50_checked %in% TRUE & !(bulk$flag_ws50_mismatch %in% TRUE)
ex_kept <- pick_example(bulk[!bulk$flag_far_snap & ws50_ok, ])
ex_far <- pick_example(bulk[bulk$flag_far_snap, ])
DBI::dbDisconnect(conn)
for (ex in list(ex_kept, ex_far)) {
  if (ex$near$blue_line_key[1] != ex$site$blue_line_key) {
    stop(ex$site$site_visit, ": the nearest stream is not the one placed")
  }
}
seg <- readRDS(file.path(dir_out, "bulk_segments.rds")) |> sf::st_drop_geometry()
# the drops and additions first: summarise() evaluates in order, so a later argument would see the summed flags
stages <- seg |>
  summarise(dropped_default = sum(pre_default %in% TRUE & !(flag_default %in% TRUE)),
            added_default = sum(!(pre_default %in% TRUE) & flag_default %in% TRUE),
            dropped_tuned = sum(pre_tuned %in% TRUE & !(flag_tuned %in% TRUE)),
            added_tuned = sum(!(pre_tuned %in% TRUE) & flag_tuned %in% TRUE),
            segments = n(),
            across(c(pre_default, flag_default, pre_tuned, flag_tuned), ~ sum(.x %in% TRUE)))
adds_up <- function(r) {
  stages[[paste0("pre_", r)]] - stages[[paste0("dropped_", r)]] + stages[[paste0("added_", r)]] ==
    stages[[paste0("flag_", r)]]
}
if (!adds_up("default") || !adds_up("tuned")) stop("the stage counts do not add up")

# ---- diagrams -------------------------------------------------------------------------------------------
pal <- c(knowledge = "#0072B2", fwapg = "#009E73", link = "#D55E00", wet = "#56B4E9", fresh = "#E69F00",
         source = "#DDDDDD")
ink <- c(knowledge = "#FFFFFF", fwapg = "#FFFFFF", link = "#FFFFFF", wet = "#000000", fresh = "#000000",
         source = "#000000")
lab <- function(x, w = 24) {
  gsub("'", "\u2019", vapply(x, function(s) paste(strwrap(s, w), collapse = "\\n"), ""), fixed = TRUE)
}
node <- function(id, label, pkg, shape = "box", w = 24) {
  sprintf('%s [label="%s", fillcolor="%s", fontcolor="%s", shape=%s]', id, lab(label, w), pal[pkg], ink[pkg], shape)
}
legend <- function(pkgs) {
  paste0('subgraph cluster_leg { label=""; margin=10; color="#BBBBBB"; style="rounded"; ',
         "node [fontsize=10, width=0.95, height=0.3]\n{ rank=same; ",
         paste(sprintf('l_%s [label="%s", fillcolor="%s", fontcolor="%s"]', pkgs, pkgs, pal[pkgs], ink[pkgs]),
               collapse = "; "), " } }")
}
head_dot <- paste0('graph [rankdir=TB, nodesep=0.3, ranksep=0.25, fontname="Helvetica", bgcolor="transparent"]\n',
                   'node [shape=box, style="rounded,filled", fontname="Helvetica", fontsize=12, width=2.8, ',
                   'height=0.5, color="#FFFFFF00"]\nedge [color="#777777", arrowsize=0.6]')
pkgs_flow <- c("knowledge", "fwapg", "link", "wet", "fresh")
dot_flow <- paste0("digraph pipeline {\n", head_dot, "\n", legend(pkgs_flow), "\n",
                   paste(node(paste0("s", pipeline$step), paste0(pipeline$step, "  ", pipeline$label),
                              pipeline$package), collapse = "\n"), "\n",
                   paste(sprintf("s%d -> s%d", pipeline$step[-nrow(pipeline)], pipeline$step[-1]), collapse = "\n"),
                   sprintf("\nl_%s -> s1 [style=invis]\n}", pkgs_flow[ceiling(length(pkgs_flow) / 2)]))
lin <- tribble(
  ~id, ~label, ~pkg, ~shape,
  "fdis", "FDIS electrofishing export (Province of BC)", "source", "ellipse",
  "fwa", "BC Freshwater Atlas", "source", "ellipse",
  "pcic", "PCIC VIC-GL runoff, routed by Raven", "source", "ellipse",
  "hydat", "HYDAT gauges and climate normals", "source", "ellipse",
  "obs", "bcfishobs fish observations", "source", "ellipse",
  "cfg", "link's default configuration", "source", "ellipse",
  "atlas", "Atlas streams in Postgres", "fwapg", "box",
  "cross", "PCIC crosswalk (the fwapg fork)", "fwapg", "box",
  "sites", "placed FDIS visits", "knowledge", "box",
  "segs", "link's segments, access and default flags", "link", "box",
  "flow", "segment flows (wet's pick)", "wet", "box",
  "evid", "evidence tables", "knowledge", "box",
  "tune", "scores, curves and grades", "knowledge", "box",
  "cmp", "comparison on link's segments", "fresh", "box",
  "pub", "thresholds and grades published", "knowledge", "box"
)
lin_edges <- c("fwa -> atlas", "fdis -> sites", "atlas -> sites", "atlas -> segs", "cfg -> segs", "obs -> segs",
               "pcic -> cross", "atlas -> cross", "cross -> flow", "hydat -> flow", "sites -> evid", "segs -> evid",
               "flow -> evid", "evid -> tune", "tune -> cmp", "segs -> cmp", "cfg -> cmp", "tune -> pub",
               "cmp -> pub")
dot_lin <- paste0("digraph lineage {\n", head_dot, "\nnode [width=1.5, fontsize=11]\ngraph [nodesep=0.15]\n",
                  legend(c("source", pkgs_flow)), "\n",
                  paste(node(lin$id, lin$label, lin$pkg, lin$shape, w = 18), collapse = "\n"), "\n",
                  paste(lin_edges, collapse = "\n"), "\nl_wet -> fdis [style=invis]\n}")
svg_of <- function(dot) DiagrammeRsvg::export_svg(DiagrammeR::grViz(dot))
svg <- list(flow = svg_of(dot_flow), lineage = svg_of(dot_lin))

# ---- write ------------------------------------------------------------------------------------------------
tracked <- c(f_pipeline, f_settings, ledger, f_tune, f_grades, f_compare,
             file.path("data/tune", paste0(keys, "_summary.csv")), file.path(dir_out, "bulk_segments.rds"))
local <- c(f_reconcile, unname(derived), f_sites)
out <- list(
  pipeline = pipeline, settings = settings, resolved = resolved, funnel = funnel, funnel_species = funnel_species,
  steps = steps, examples = list(kept = ex_kept, far = ex_far, wsg = example_wsg, stages = stages),
  svg = svg,
  meta = list(written = format(Sys.Date()),
              commit = system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE),
              ledger = ledger, flow_load = loads, wet_sha = wet_sha, link_config_sha = cfg_sha,
              md5 = tools::md5sum(tracked) |> stats::setNames(tracked),
              md5_local = tools::md5sum(local) |> stats::setNames(local))
)
saveRDS(out, file.path(dir_out, "method.rds"), compress = "xz")
message(sprintf("%s: %.2f MB", file.path(dir_out, "method.rds"), file.size(file.path(dir_out, "method.rds")) / 1e6))
