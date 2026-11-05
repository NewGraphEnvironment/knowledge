# data-raw/setup_compare.R
# ---------------------------------------------------------------------------
# One key on every setup (#120): the published run on link's full network reading each segment's own gradient, the
# minimal network's run, and two setups on the full network (0320 SETUP=1) reading each segment's minimal parent's
# gradient and its Freshwater Atlas segment's. All four share the flow load and the species range, so the network
# and the gradient are the only differences, which this script checks before reading anything else.
#
# Per setup: its pick, how far it sits behind its own best, the km link would draw under `default` and under the pick
# and the graded km (each setup's own comparison, regenerated on its gradient). Per pair: whether one setup's pick lies
# in the other's one-SE region, and how far behind the other's best it sits, in the other's units. The transfer: the
# minimal network's verdicts carried onto the full network's segments through link's parent table, against the
# parent-gradient setup's verdicts on those segments (the km a rule tuned on the minimal network draws differently
# when link applies it on the full one, reading the parent's gradient).
#
# Then the map: every full-network segment with its tuned verdict under each setup, written to a GeoPackage for QGIS
# (data/compare/setups/<key>_setups.gpkg, ignored), and one figure of the group with the most km where the setups'
# verdicts disagree (a criterion fixed here, before drawing), coloured by which setups draw the segment.
#
# INPUT:  each setup's tune and comparison directory: the published data/tune and data/compare; MINIMAL_RUN
#         (default 20261103_0838), PARENT_RUN and ATLAS_RUN under data/{tune,compare}/candidate/<run>/: <key>_tune.csv,
#         <key>_grades_record.csv, <key>_compare.csv, <key>_segments.rds; the database holding the full build (link's
#         streams_parent and geometry; PGSERVICE).
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_setup_compare-<key>.{csv,txt} (per setup; the txt adds the pairs, the
#         transfer, the inputs' md5s and the commit), data/compare/setups/<key>_setups.gpkg (ignored),
#         research/fig/setups_<key>_<wsg>.png
# RUN:    PARENT_RUN=<run> ATLAS_RUN=<run> PGSERVICE=<entry> Rscript data-raw/setup_compare.R   (from the repo root;
#         KEY=CH_rear; GPKG=FALSE skips the GeoPackage)
# ---------------------------------------------------------------------------
suppressMessages({ library(dplyr); library(readr) })
pkgload::load_all(quiet = TRUE)
options(warn = 1)
sf::sf_use_s2(FALSE)
if (!nzchar(Sys.getenv("PGCONNECT_TIMEOUT"))) Sys.setenv(PGCONNECT_TIMEOUT = "30")

key <- Sys.getenv("KEY", "CH_rear")
schema <- Sys.getenv("SCHEMA", "fresh_default")
schema_min <- Sys.getenv("SCHEMA_MINIMAL", "fresh_default_minimal")
gpkg <- !identical(Sys.getenv("GPKG"), "FALSE")
runs <- c(published = "", minimal = Sys.getenv("MINIMAL_RUN", "20261103_0838"), parent = Sys.getenv("PARENT_RUN"),
          atlas = Sys.getenv("ATLAS_RUN"))
if (!nzchar(runs[["parent"]]) || !nzchar(runs[["atlas"]])) stop("give PARENT_RUN and ATLAS_RUN (0320 SETUP=1 runs)")
# what each setup is, by its record: the gradient its curve read and the tokens its grades are filed under
expect <- tibble(setup = names(runs),
                 label = c("full network, its own gradient (published)", "minimal network, its own gradient",
                           "full network, its minimal parent's gradient",
                           "full network, the Atlas gradient of its segment's line"),
                 curve_grad = c("segment_gradient", "segment_gradient", "parent_gradient", "segment_fwa_gradient"),
                 token_cut = c("cut-full-top", "cut-min", "cut-full-top", "cut-full-top"),
                 token_grad = c("grad-seg", "grad-seg", "grad-parent", "grad-fwa"))
dir_t <- function(r) if (nzchar(r)) file.path("data/tune/candidate", r) else "data/tune"
dir_c <- function(r) if (nzchar(r)) file.path("data/compare/candidate", r) else "data/compare"
f_in <- unlist(lapply(names(runs), function(s) {
  c(file.path(dir_t(runs[[s]]), paste0(key, c("_tune.csv", "_grades_record.csv"))),
    file.path(dir_c(runs[[s]]), paste0(key, c("_compare.csv", "_segments.rds"))))
}))
miss <- f_in[!file.exists(f_in)]
if (length(miss)) stop("missing: ", paste(miss, collapse = ", "))
stamp <- format(Sys.time(), "%Y%m%d", tz = "UTC")
path_csv <- .knw_free_path(file.path("scripts/logs/habitat", sprintf("%s_setup_compare-%s.csv", stamp, tolower(key))))
path_txt <- sub("\\.csv$", ".txt", path_csv)
log_lines <- character()
say <- function(...) { log_lines <<- c(log_lines, sprintf(...)); message(sprintf(...)) }
block <- function(title, x) {
  log_lines <<- c(log_lines, "", paste("##", title), capture.output(print(as.data.frame(x), row.names = FALSE)))
}
# untracked files count: this script is code the numbers depend on
dirty <- length(system2("git", c("status", "--porcelain", "--", "R", "data-raw/setup_compare.R"), stdout = TRUE)) > 0
say("%s on every setup (#120), at knowledge %s%s.", key, system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE),
    if (dirty) " (uncommitted changes)" else "")

# ---- each setup is what it says, and all four share the flows and the visits ----------------------------
recs <- lapply(stats::setNames(names(runs), names(runs)), function(s) {
  knw_grade_record_read(file.path(dir_t(runs[[s]]), paste0(key, "_grades_record.csv")))
})
for (i in seq_len(nrow(expect))) {
  r <- recs[[expect$setup[i]]]
  got <- c(curve_grad = r$curve_grad, token_cut = r$token_cut, token_grad = r$token_grad)
  want <- unlist(expect[i, names(got)])
  if (!identical(unname(got), unname(want))) {
    stop(expect$setup[i], ": its record reads ", paste(names(got), got, sep = " = ", collapse = ", "), ", not ",
         paste(names(want), want, sep = " = ", collapse = ", "))
  }
}
one_of <- function(f) unique(vapply(recs, function(r) as.character(r[[f]]), character(1)))
if (length(one_of("discharge_load")) != 1) stop("the setups read different flow loads: ", paste(one_of("discharge_load"), collapse = " | "))
if (length(one_of("token_flow")) != 1 || length(one_of("token_acc")) != 1) stop("the setups differ in flow or access tokens")
# the evidence: visits_species and walks (each visit's species, outcome, range and walks) are one build's; only
# visits_link, which carries the segments, differs between the networks and gains the parent's columns
ev <- vapply(recs, function(r) paste(strsplit(r$evidence_md5, ";", fixed = TRUE)[[1]][2:3], collapse = ";"), character(1))
if (length(unique(ev)) != 1) stop("the setups' visits_species or walks differ: ", paste(names(ev), ev, collapse = "; "))
say("One flow load (%s), one access and flow token (%s, %s), one visit and walk build (visits_species;walks md5 %s).",
    one_of("discharge_load"), one_of("token_acc"), one_of("token_flow"), unique(ev))
for (s in names(runs)) {
  r <- recs[[s]]
  say("  %s: %s; tune run %s, link run %s; tokens %s.%s.%s.%s; curve on %s.", s, expect$label[expect$setup == s],
      r$tune_run, r$run_uid, r$token_cut, r$token_acc, r$token_grad, r$token_flow, r$curve_grad)
}

# ---- picks, regions, km ------------------------------------------------------------------------------
tune <- lapply(stats::setNames(names(runs), names(runs)), function(s) {
  read_csv(file.path(dir_t(runs[[s]]), paste0(key, "_tune.csv")), show_col_types = FALSE, col_types = cols(.default = "c"))
})
cmp <- lapply(stats::setNames(names(runs), names(runs)), function(s) {
  x <- read_csv(file.path(dir_c(runs[[s]]), paste0(key, "_compare.csv")), show_col_types = FALSE)
  x[x$watershed_group_code == "ALL" & x$structure == x$tuned_structure, , drop = FALSE]
})
per_setup <- bind_rows(lapply(names(runs), function(s) {
  t <- tune[[s]]
  rec <- t$recommended %in% "TRUE"
  a <- cmp[[s]]
  if (nrow(a) != 1 || !identical(a$tuned_rule, t$rule[rec])) stop(s, ": the comparison is not of the pick")
  tibble(setup = s, label = expect$label[expect$setup == s], tune_run = recs[[s]]$tune_run,
         pick = t$rule[rec], grad_max = as.numeric(t$grad_max[rec]), n_visits = as.integer(t$n_visits[rec]),
         rules_in_region = sum(t$in_region %in% "TRUE"),
         pick_behind_best = as.numeric(t$ddev_best[rec]), pick_se = as.numeric(t$se_diff[rec]),
         default_km = a$default_km, tuned_km = a$tuned_km, change_pct = a$change_pct,
         default_graded_km = a$default_graded_km, tuned_graded_km = a$tuned_graded_km,
         stored_vs_default_differ_km = a$stored_vs_default_differ_km)
}))
pairs <- bind_rows(lapply(names(runs), function(a) bind_rows(lapply(setdiff(names(runs), a), function(b) {
  p <- knw_tune_pick_report(tune[[a]], tune[[b]])
  tibble(scored_in = a, pick_of = b, pick = p$rule_published, same_pick = p$same_pick,
         in_region = p$published_in_region, behind_best = p$published_ddev, se = p$published_se)
}))))

# ---- the verdicts on the full network's segments, the minimal network's carried through the parent -------
segs <- lapply(stats::setNames(names(runs), names(runs)), function(s) {
  readRDS(file.path(dir_c(runs[[s]]), paste0(key, "_segments.rds")))
})
flag <- paste0(if (grepl("_rear$", key)) "rearing" else "spawning", "_tuned")
flag_default <- sub("_tuned$", "_default", flag)
k_of <- function(x) paste(x$watershed_group_code, x$id_segment)
full <- segs$published |>
  transmute(watershed_group_code, id_segment, length_metre, stream_order, accessible, grade_class,
            default = .data[[flag_default]], published = .data[[flag]])
for (s in c("parent", "atlas")) {
  if (!setequal(k_of(segs[[s]]), k_of(full))) stop(s, ": its segments are not the published run's")
  full[[s]] <- segs[[s]][[flag]][match(k_of(full), k_of(segs[[s]]))]
}
conn <- DBI::dbConnect(RPostgres::Postgres(), bigint = "numeric")
par <- knw_parent_read(conn, schema, schema_min, keys = full[, c("watershed_group_code", "id_segment")])
say("Parent table: %s", paste(names(attr(par, "provenance")), attr(par, "provenance"), sep = " ", collapse = "; "))
if (!identical(attr(par, "provenance")$run_uid_minimal, recs$minimal$run_uid)) {
  stop("the parent table joins minimal run ", attr(par, "provenance")$run_uid_minimal, ", not the minimal setup's ",
       recs$minimal$run_uid)
}
i <- match(k_of(full), paste(par$wsg, par$id_segment))
if (anyNA(i)) stop(sum(is.na(i)), " full segments have no parent row")
mk <- paste(full$watershed_group_code, par$id_segment_minimal[i])
j <- match(mk, k_of(segs$minimal))
# a parent the minimal comparison did not hold is a minimal segment outside the species' habitat table: not drawn
full$minimal <- segs$minimal[[flag]][j] %in% TRUE
full$straddle_m <- par$straddle_m[i]
v <- c("published", "minimal", "parent", "atlas")
full$pattern <- apply(as.matrix(full[, v]), 1, function(x) {
  x <- x %in% TRUE
  if (all(x)) "every setup" else if (!any(x)) "none" else paste(v[x], collapse = " + ")
})
km <- function(x) sum(x) / 1000
transfer <- full |>
  summarise(minimal_km_on_full = km(length_metre[minimal]), parent_km = km(length_metre[parent %in% TRUE]),
            minimal_only_km = km(length_metre[minimal & !parent %in% TRUE]),
            parent_only_km = km(length_metre[parent %in% TRUE & !minimal]),
            straddle_segments = sum(straddle_m > 0))
by_pattern <- full |> filter(pattern != "none") |> group_by(pattern) |>
  summarise(km = km(length_metre), segments = n(), .groups = "drop") |> arrange(desc(km))
by_group <- full |> group_by(watershed_group_code) |>
  summarise(default_km = km(length_metre[default %in% TRUE]),
            disagree_km = km(length_metre[!pattern %in% c("every setup", "none")]), .groups = "drop") |>
  arrange(desc(disagree_km))
# the figure's group, fixed before drawing: the most km where the four setups' verdicts are not the same
wsg_fig <- by_group$watershed_group_code[1]

say("")
say("Each setup's pick, its standing in its own tuning, and the km it draws on its own network and gradient:")
block("per setup", per_setup)
block("each setup's pick scored in each other setup's tuning (TRUE = in its one-SE region; deviance and SE behind its best)",
      pairs)
say("")
say("The transfer: the minimal network's verdicts carried onto the full network's %d segments through %s.streams_parent,",
    nrow(full), schema)
say("against the parent-gradient setup's verdicts on them (km), and %d segments straddling a minimal break (by at most 1 m).",
    transfer$straddle_segments)
block("transfer", transfer)
block("km by which setups draw a segment (full network's segments)", by_pattern)
block("groups by km where the setups disagree (top 10)", head(by_group, 10))
say("Figure group (most km where the verdicts disagree): %s.", wsg_fig)
say("")
say("Inputs (md5):")
for (f in f_in) say("  %s %s", unname(tools::md5sum(f)), f)
write_csv(per_setup, path_csv, na = "")
writeLines(log_lines, path_txt)

# ---- the GeoPackage and the figure -------------------------------------------------------------------
geom_of <- function(w) {
  g <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf(
    "SELECT id_segment, geom FROM %s.streams WHERE watershed_group_code = '%s'", schema, w)), drop = TRUE)
  g$id_segment <- as.numeric(g$id_segment)
  g
}
drawn <- full |> filter(pattern != "none" | default %in% TRUE)
if (gpkg) {
  dir.create("data/compare/setups", showWarnings = FALSE, recursive = TRUE)
  f <- file.path("data/compare/setups", paste0(key, "_setups.gpkg"))
  f_part <- sub("\\.gpkg$", ".part.gpkg", f)
  unlink(f_part)
  for (w in sort(unique(drawn$watershed_group_code))) {
    sg <- inner_join(geom_of(w), drawn[drawn$watershed_group_code == w, ], by = "id_segment")
    sf::st_write(sg, f_part, layer = "segments", append = file.exists(f_part), quiet = TRUE)
  }
  unlink(f)
  if (!file.rename(f_part, f)) stop("could not move ", f_part, " to ", f)
  message("Wrote ", f, " (", nrow(drawn), " segments drawn by default or a setup)")
}
# the classes: each disagreement the province holds over 100 km of, by which setups draw the segment (revised after the
# first figure, which had fixed them before seeing the patterns and put the two largest into "other"); agreement is
# drawn muted and thin, so the differences carry the figure
cls <- function(p) {
  dplyr::case_when(p == "every setup" ~ "Every setup",
                   p == "published + minimal + parent" ~ "Every setup but the Atlas line",
                   p == "published + atlas" ~ "Full network's own and Atlas gradients only",
                   p == "minimal" ~ "Minimal network only (lost in the transfer)",
                   p == "published" ~ "Published only",
                   p == "minimal + parent + atlas" ~ "Every setup but the published",
                   p == "atlas" ~ "Atlas line only",
                   TRUE ~ "Other combinations")
}
cols_cls <- c("Every setup" = "#c6dbef", "Every setup but the Atlas line" = "#3182bd",
              "Full network's own and Atlas gradients only" = "#e6550d",
              "Minimal network only (lost in the transfer)" = "#31a354", "Published only" = "#fdae6b",
              "Every setup but the published" = "#756bb1", "Atlas line only" = "#bcbddc", "Other combinations" = "#636363")
sg <- inner_join(geom_of(wsg_fig), full[full$watershed_group_code == wsg_fig & full$accessible %in% TRUE, ],
                 by = "id_segment")
sg$class <- factor(ifelse(sg$pattern == "none", NA, cls(sg$pattern)), levels = names(cols_cls))
sg$lwd <- pmin(pmax(as.numeric(sg$stream_order), 1), 6) / 3
water <- sf::st_zm(sf::st_read(conn, quiet = TRUE, query = sprintf("
  SELECT waterbody_key, geom FROM whse_basemapping.fwa_lakes_poly WHERE watershed_group_code = '%1$s' AND area_ha >= 10
  UNION ALL SELECT waterbody_key, geom FROM whse_basemapping.fwa_rivers_poly WHERE watershed_group_code = '%1$s'",
  wsg_fig)), drop = TRUE)
DBI::dbDisconnect(conn)
reg <- gq::gq_reg_main()
agree <- sg[sg$class %in% "Every setup", ]
differ <- sg[!is.na(sg$class) & !sg$class %in% "Every setup", ]
differ$lwd <- differ$lwd + 1.2
m <- tmap::tm_shape(sg) + tmap::tm_lines(col = "grey88", lwd = 0.3) +
  tmap::tm_shape(water) + do.call(tmap::tm_polygons, gq::gq_tmap_style(reg$layers$lake)) +
  tmap::tm_shape(agree) + tmap::tm_lines(col = cols_cls[["Every setup"]], lwd = "lwd",
                                         lwd.scale = tmap::tm_scale_continuous(values.scale = 1),
                                         lwd.legend = tmap::tm_legend_hide()) +
  tmap::tm_shape(differ) +
  tmap::tm_lines(col = "class", col.scale = tmap::tm_scale_categorical(values = cols_cls, levels.drop = FALSE),
                 col.legend = tmap::tm_legend(title = "Chinook rearing drawn by"),
                 lwd = "lwd", lwd.scale = tmap::tm_scale_continuous(values.scale = 1.6), lwd.legend = tmap::tm_legend_hide()) +
  tmap::tm_scalebar(position = tmap::tm_pos_in("right", "bottom")) +
  tmap::tm_layout(frame = FALSE, inner.margins = 0, legend.position = tmap::tm_pos_in("left", "bottom"))
f_fig <- file.path("research/fig", sprintf("setups_%s_%s.png", tolower(key), tolower(wsg_fig)))
tmap::tmap_save(m, f_fig, width = 7, height = 7, dpi = 150)
message("Wrote ", path_csv, ", ", path_txt, " and ", f_fig)
