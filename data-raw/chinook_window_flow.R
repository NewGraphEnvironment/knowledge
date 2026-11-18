# data-raw/chinook_window_flow.R
# ---------------------------------------------------------------------------
# #105 Phase 1: does flow in a seasonal window change which visits the chinook rearing rule takes in, compared with
# MAD? research/chinook_window_flow.md sets the question, the readings and the stop rule; this counts the flips.
#
# WHY / DESIGN NOTES:
#   - THE RULE COMES FIRST. The script refuses unless research/chinook_window_flow.md, the script and R/ are committed
#     and clean, and logs the commit it read, so the stop rule is on record before any flip is counted and the run
#     record's HEAD reproduces the run.
#   - THE PUBLISHED RUN, AS IT WAS SCORED. The visits are the tuning's own (.tune_population() then
#     .tune_modelled(), knw_tune_run()'s defaults) on the evidence the grade record names, and the MAD reading goes
#     through knw_rule_in() and the evidence's walks. It must give the published rule's n_in and n_detect_in, and
#     the flow load must be the grade record's, or the script stops.
#   - WINDOW FLOW ON THE SEGMENT MAD CAME FROM. Each visit's window flow is read on its own segment, or on the
#     parent knw_link_flow() took its MAD from (parent_lfid), on that segment's pick source, from
#     discharge.fwa_v1_segment_monthly through the connection, so MAD and the window share one load and one source.
#     The recomputed MAD must equal the evidence's mad_pick at every visit.
#   - THE RIVER READING from the walk's ladder: for each visit, the nearest found river on the pick ladder whose
#     spawning window flow reaches the scaled threshold. A river below the lowest rung is not seen (stated in the
#     research file).
#   - A DAILY CHECK on the river reading: wet's published daily flow (wet::wet_segment_daily(), read from the parts
#     over HTTPS, so wet's current build, recorded) for the same rivers. It is a check on the monthly basis, not the
#     result, because the parts need not be the load the database holds.
#
# INPUT:  data/fdis/derived/{visits_link,visits_species,walks}.csv (PULL=TRUE KEYS=CH_rear scripts/0336-archive.R),
#         data/tune/CH_rear_{summary,tune,grades_record}.csv, a database holding the published build and wet's load
#         (PG* or PGSERVICE), research/chinook_window_flow.md committed.
# OUTPUT: data/tune/flow_window/ch_rear_{run,flips,flips_by_group,ratio_by_group}.csv
# RUN:    Rscript data-raw/chinook_window_flow.R 2>&1 | tee scripts/logs/flow_window/<yyyymmdd>_chinook_window_flow.txt
#         (repo root, on the database's host; DAILY=FALSE skips the daily check)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1)

rule_file <- "research/chinook_window_flow.md"
out_dir <- "data/tune/flow_window"
ev_dir <- "data/fdis/derived"
daily <- !Sys.getenv("DAILY") %in% c("0", "FALSE", "false")
windows <- data.frame(window = c("rear", "spawn"), start = c("08-01", "08-15"), end = c("09-30", "09-15"))

git <- function(...) {
  out <- suppressWarnings(system2("git", c(...), stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git ", paste(c(...), collapse = " "), " failed", call. = FALSE)
  out
}
dirty <- git("status", "--porcelain", "--", rule_file, "data-raw/chinook_window_flow.R", "R")
if (length(dirty)) {
  stop("commit first, so the run record's HEAD reproduces the run: ", paste(dirty, collapse = "; "), call. = FALSE)
}
rule_commit <- git("log", "-1", "--format=%H", "--", rule_file)
if (!length(rule_commit)) stop(rule_file, " is not committed", call. = FALSE)
head_sha <- git("rev-parse", "HEAD")
cat("stop rule:", rule_file, "at", rule_commit, "\nHEAD:     ", head_sha, "\n")
cat("started:  ", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n\n")

# ---- the published run's record, and its evidence ----
summ <- utils::read.csv("data/tune/CH_rear_summary.csv", stringsAsFactors = FALSE)
rec <- utils::read.csv("data/tune/CH_rear_grades_record.csv", stringsAsFactors = FALSE)
tune <- utils::read.csv("data/tune/CH_rear_tune.csv", stringsAsFactors = FALSE)
f_ev <- file.path(ev_dir, c("visits_link.csv", "visits_species.csv", "walks.csv"))
md5 <- paste(unname(tools::md5sum(f_ev)), collapse = ";")
if (!identical(md5, summ$evidence_md5)) stop("the evidence in ", ev_dir, " is not the run's: ", md5, call. = FALSE)
pub <- tune[tune$rule == summ$rule_recommended, , drop = FALSE]
if (nrow(pub) != 1L) stop("the recommended rule is not one row of CH_rear_tune.csv", call. = FALSE)
cat("published rule:", pub$rule, "(run", summ$tune_run, ")\n")

conn <- DBI::dbConnect(RPostgres::Postgres())
lat <- knw_db_latency_check(conn)
load <- knw_discharge_load(conn)
if (!identical(load, rec$discharge_load)) stop("the database's flow load is not the grade record's:\n  ", load, call. = FALSE)
cat("flow load:     ", load, "\n\n")

vl <- readr::read_csv(f_ev[1], guess_max = 1e5, show_col_types = FALSE, progress = FALSE,
                      col_types = readr::cols(site_visit = "c", species_caught = "c", blocks_absence_of = "c",
                                              hydro_zone = "c"))
vs <- readr::read_csv(f_ev[2], show_col_types = FALSE, progress = FALSE, col_types = readr::cols(site_visit = "c"))
walks <- readr::read_csv(f_ev[3], show_col_types = FALSE, progress = FALSE)

# ---- the population the tuning scored ----
fm <- formals(knw_tune_run)
edge_stream <- eval(fm$edge_stream)
pop <- .tune_population(.tune_base(vl, edge_stream, eval(fm$area_range)), vs, "CH", "rear")
n_pop <- c(nrow(pop$d), sum(pop$d$U), nlevels(pop$d$wsg))
if (!identical(n_pop, c(as.integer(summ$visits_in), as.integer(summ$detections), as.integer(summ$groups)))) {
  stop("the rebuilt population is not the summary's: ", paste(n_pop, collapse = " / "), call. = FALSE)
}
d <- .tune_modelled(pop$d, "U")
n_mod <- c(nrow(d), sum(d$U), nlevels(d$wsg))
if (!identical(n_mod, c(as.integer(pub$n_visits), as.integer(pub$n_detect), as.integer(pub$n_wsg)))) {
  stop("the modelled visits are not the tune table's: ", paste(n_mod, collapse = " / "), call. = FALSE)
}
cat("population:", paste(n_pop, collapse = " / "), "-> scored:", paste(n_mod, collapse = " / "),
    "(visits / with CH / groups)\n")

rule <- pub[, c("size_var", "size_min", "grad_max", "exc_q", "exc_d")]
wi <- knw_walk_index(walks)
in_mad <- knw_rule_in(d, rule, walks = wi, edge_stream = edge_stream)
if (sum(in_mad) != pub$n_in || sum(in_mad & d$U == 1L) != pub$n_detect_in) {
  stop("the MAD reading gives ", sum(in_mad), " in (", sum(in_mad & d$U == 1L), " with CH); the tune table ",
       pub$n_in, " (", pub$n_detect_in, ")", call. = FALSE)
}
cat("MAD reading:", sum(in_mad), "in,", sum(in_mad & d$U == 1L), "with CH (the tune table's)\n\n")

# ---- the segment each visit's MAD came from ----
tmp <- "tmp_knw_window_seg"
DBI::dbWriteTable(conn, tmp, data.frame(linear_feature_id = unique(d$linear_feature_id)), temporary = TRUE,
                  overwrite = TRUE)
seg <- DBI::dbGetQuery(conn, .knw_link_flow_sql(tmp))
invisible(DBI::dbExecute(conn, paste("DROP TABLE", tmp)))
if (anyDuplicated(seg$linear_feature_id)) stop("a segment matched twice", call. = FALSE)
# bigint columns arrive as integer64, and base ifelse() copies their bits into a double: read every id as numeric
seg$linear_feature_id <- as.numeric(seg$linear_feature_id)
seg$parent_lfid <- as.numeric(seg$parent_lfid)
seg$src_lfid <- ifelse(!is.na(seg$own_mad), seg$linear_feature_id, seg$parent_lfid)
seg$mad <- ifelse(!is.na(seg$own_mad), as.numeric(seg$own_mad), as.numeric(seg$parent_mad))
m <- match(d$linear_feature_id, seg$linear_feature_id)
d$src_lfid <- seg$src_lfid[m]
mad_re <- seg$mad[m]
same <- (is.na(mad_re) & is.na(d$mad_pick)) | (!is.na(mad_re) & !is.na(d$mad_pick) & abs(mad_re - d$mad_pick) < 1e-9)
if (!all(same)) stop(sum(!same), " visits' MAD, read again, is not the evidence's mad_pick", call. = FALSE)
cat("flow from a parent segment:", sum(!is.na(seg$parent_lfid[m]) & is.na(seg$own_mad[m])), "visits;",
    "no flow:", sum(is.na(d$mad_pick)), "\n")

# ---- the rivers the walk found on the pick ladder, for these visits ----
pt <- paste(d$blue_line_key, d$downstream_route_measure)
wk <- walks[walks$src == "pick" & walks$status == "found" &
              paste(walks$blue_line_key, walks$downstream_route_measure) %in% pt, , drop = FALSE]
wk$pt <- paste(wk$blue_line_key, wk$downstream_route_measure)

# ---- monthly flow on pick for every segment read ----
lfids <- unique(stats::na.omit(c(d$src_lfid, wk$large_lfid)))
mon <- DBI::dbGetQuery(conn, "
  SELECT linear_feature_id, source, month, q_m3s FROM discharge.fwa_v1_segment_monthly
  WHERE scenario = 'historical' AND pick AND linear_feature_id = ANY($1::bigint[])",
  params = list(paste0("{", paste(format(lfids, scientific = FALSE, trim = TRUE), collapse = ","), "}")))
mon$linear_feature_id <- as.numeric(mon$linear_feature_id)
n_mon <- table(factor(mon$linear_feature_id, levels = lfids))
if (any(n_mon != 13L)) {
  stop(sum(n_mon != 13L), " of the ", length(lfids), " segments read do not have 13 months on one pick source",
       call. = FALSE)
}
mad0 <- mon[mon$month == 0L, c("linear_feature_id", "q_m3s")]
wf <- wet::wet_flow_window(mon, windows)
win <- function(w, ids) wf$q_m3s[wf$window == w][match(ids, wf$linear_feature_id[wf$window == w])]
river_mad <- function(ids) mad0$q_m3s[match(ids, mad0$linear_feature_id)]
if (any(abs(river_mad(wk$large_lfid) - wk$large_mad) > 1e-9, na.rm = TRUE)) {
  stop("a river's MAD in the database is not the walk's large_mad", call. = FALSE)
}

# ---- the readings ----
d$win_rear <- win("rear", d$src_lfid)
ratio_v <- d$win_rear / d$mad_pick
med_v <- stats::median(ratio_v[is.finite(ratio_v)])
riv3 <- unique(wk$large_lfid[wk$qmin == pub$exc_q])
ratio_r3 <- win("spawn", riv3) / river_mad(riv3)
med_r <- stats::median(ratio_r3[is.finite(ratio_r3)])
thr_stream <- pub$size_min * med_v
thr_river <- pub$exc_q * med_r
cat(sprintf("median window / MAD: rearing at visits %.4f, spawning at the %d rivers found at %g m3/s %.4f\n",
            med_v, length(riv3), pub$exc_q, med_r))
cat(sprintf("matched thresholds: stream %.4f m3/s (for %.2f), river %.4f m3/s (for %g)\n\n",
            thr_stream, pub$size_min, thr_river, pub$exc_q))

# the nearest ladder river whose spawning window reaches the threshold, as a walk index entry
river_index <- function(q_river, thr) {
  ok <- !is.na(q_river) & q_river >= thr
  dist <- tapply(ifelse(ok, wk$dist_m, Inf), wk$pt, min)
  list(pt = pt, dist = unname(ifelse(is.na(dist[pt]), Inf, dist[pt])), lake = rep(FALSE, length(pt)),
       reg = rep(FALSE, length(pt)))
}
wi_win <- c(wi, list(`pick|win` = river_index(win("spawn", wk$large_lfid), thr_river)))
rule_stream <- transform(rule, size_min = thr_stream)
rule_river <- transform(rule, exc_q = "win")
rule_both <- transform(rule, size_min = thr_stream, exc_q = "win")
cols_win <- c(grad = "segment_gradient", width = "cw_deploy", mad = "win_rear")
reading <- list(
  stream = knw_rule_in(d, rule_stream, walks = wi, cols = cols_win, edge_stream = edge_stream),
  river = knw_rule_in(d, rule_river, walks = wi_win, edge_stream = edge_stream),
  both = knw_rule_in(d, rule_both, walks = wi_win, cols = cols_win, edge_stream = edge_stream)
)

flips <- do.call(rbind, lapply(names(reading), function(r) {
  f <- reading[[r]] != in_mad
  data.frame(reading = r, basis = "monthly", visits = nrow(d), visits_in = sum(reading[[r]]),
             flips = sum(f), flips_in = sum(f & reading[[r]]), flips_out = sum(f & !reading[[r]]),
             flips_pct = round(100 * mean(f), 2), ch = sum(d$U), ch_flips = sum(f & d$U == 1L),
             ch_flips_pct = round(100 * sum(f & d$U == 1L) / sum(d$U), 2))
}))
by_group <- do.call(rbind, lapply(names(reading), function(r) {
  f <- reading[[r]] != in_mad
  g <- split(seq_len(nrow(d)), d$watershed_group_code)
  do.call(rbind, lapply(names(g), function(k) {
    i <- g[[k]]
    data.frame(reading = r, watershed_group_code = k, visits = length(i), flips = sum(f[i]),
               ch = sum(d$U[i]), ch_flips = sum(f[i] & d$U[i] == 1L))
  }))
}))

# window / MAD by group: at visits (rearing) and at each visit's river at the exception's rung (spawning)
w3 <- wk[wk$qmin == pub$exc_q, , drop = FALSE]
w3 <- w3[!duplicated(w3$pt), , drop = FALSE]
r_riv <- (win("spawn", w3$large_lfid) / river_mad(w3$large_lfid))[match(pt, w3$pt)]
qs <- function(x) {
  x <- x[is.finite(x)]
  if (!length(x)) return(c(n = 0, q10 = NA, q50 = NA, q90 = NA))
  c(n = length(x), stats::quantile(x, c(0.1, 0.5, 0.9), names = FALSE)) |> stats::setNames(c("n", "q10", "q50", "q90"))
}
ratio_by_group <- do.call(rbind, lapply(split(seq_len(nrow(d)), d$watershed_group_code), function(i) {
  a <- qs(ratio_v[i])
  b <- qs(r_riv[i])
  data.frame(watershed_group_code = d$watershed_group_code[i[1]], visits = length(i),
             rear_n = a[["n"]], rear_q10 = a[["q10"]], rear_q50 = a[["q50"]], rear_q90 = a[["q90"]],
             spawn_river_n = b[["n"]], spawn_river_q10 = b[["q10"]], spawn_river_q50 = b[["q50"]],
             spawn_river_q90 = b[["q90"]])
}))

# ---- the daily check on the river reading ----
# wet's published parts (wet's current build, which need not be the database's load): the river reading on their
# monthly basis and on their daily basis, each scaled by its own median window / MAD at the exception's rivers, so the
# change of build and the change of basis are told apart. Each river reads the source the database's load picks.
daily_build <- NA_character_
if (daily) {
  riv <- unique(wk$large_lfid)
  grp <- DBI::dbGetQuery(conn, "SELECT linear_feature_id, watershed_group_code
    FROM whse_basemapping.fwa_stream_networks_sp WHERE linear_feature_id = ANY($1::bigint[])",
    params = list(paste0("{", paste(format(riv, scientific = FALSE, trim = TRUE), collapse = ","), "}")))
  grp$linear_feature_id <- as.numeric(grp$linear_feature_id)
  if (!setequal(grp$linear_feature_id, riv)) stop("a river has no watershed group", call. = FALSE)
  src_riv <- paste(mon$linear_feature_id, mon$source)[mon$month == 0L]
  groups <- sort(unique(grp$watershed_group_code))
  daily_build <- attr(wet::wet_catalog(), "built")
  if (is.null(daily_build)) stop("wet's catalogue names no build", call. = FALSE)
  t0 <- Sys.time()
  first <- wet::wet_segment_daily(NULL, grp$linear_feature_id[grp$watershed_group_code == groups[1]],
                                  groups = groups[1])
  cat(sprintf("parts (wet build %s): one group (%s) read in %.1f s; %d groups to read\n", daily_build, groups[1],
              as.numeric(difftime(Sys.time(), t0, units = "secs")), length(groups)))
  dly <- rbind(first, wet::wet_segment_daily(NULL, grp$linear_feature_id[grp$watershed_group_code != groups[1]],
                                             groups = groups[-1]))
  pmon <- wet::wet_segment_monthly(NULL, riv, groups = groups)
  dly <- dly[paste(dly$linear_feature_id, dly$source) %in% src_riv, , drop = FALSE]
  pmon <- pmon[paste(pmon$linear_feature_id, pmon$source) %in% src_riv, , drop = FALSE]
  p_mad <- pmon$q_m3s[pmon$month == 0L][match(riv, pmon$linear_feature_id[pmon$month == 0L])]
  names(p_mad) <- riv
  spawn <- windows[windows$window == "spawn", ]
  river_reading <- function(wf_x, label) {
    q <- wf_x$q_m3s[match(wk$large_lfid, wf_x$linear_feature_id)]
    r3 <- wf_x$q_m3s[match(riv3, wf_x$linear_feature_id)] / p_mad[as.character(riv3)]
    med <- stats::median(r3[is.finite(r3)])
    r <- knw_rule_in(d, rule_river, walks = c(wi, list(`pick|win` = river_index(q, pub$exc_q * med))),
                     edge_stream = edge_stream)
    f <- r != in_mad
    cat(sprintf("%s: median spawning window / MAD at the rivers %.4f; %d rivers with no value; %d visits read apart from the database's monthly river reading\n",
                label, med, sum(is.na(wf_x$q_m3s[match(riv, wf_x$linear_feature_id)])), sum(r != reading$river)))
    data.frame(reading = "river", basis = label, visits = nrow(d), visits_in = sum(r), flips = sum(f),
               flips_in = sum(f & r), flips_out = sum(f & !r), flips_pct = round(100 * mean(f), 2), ch = sum(d$U),
               ch_flips = sum(f & d$U == 1L), ch_flips_pct = round(100 * sum(f & d$U == 1L) / sum(d$U), 2))
  }
  flips <- rbind(flips,
                 river_reading(wet::wet_flow_window(pmon, spawn), "monthly, published parts"),
                 river_reading(wet::wet_flow_window(dly, spawn), "daily, published parts"))
  cat("\n")
}
DBI::dbDisconnect(conn)

# ---- the verdict against the rule set before the run ----
main <- flips[flips$basis == "monthly", , drop = FALSE]  # the database's load: the result; the parts are a check
go <- any(main$flips >= 0.05 * nrow(d) | main$ch_flips >= 0.05 * sum(d$U))
print(flips, row.names = FALSE)
cat("\nverdict:", if (go) "CONTINUE: a reading reaches 5 % of visits or of visits with CH; file Phase 2" else
  "STOP: every reading flips under 5 % of visits and under 5 % of visits with CH", "\n")

run <- data.frame(rule_file = rule_file, rule_commit = rule_commit, head = head_sha, tune_run = summ$tune_run,
                  evidence_md5 = md5, discharge_load = load, rule = pub$rule, visits = nrow(d), ch = sum(d$U),
                  groups = nlevels(d$wsg), med_rear_visit = med_v, med_spawn_river = med_r,
                  thr_stream = thr_stream, thr_river = thr_river, rivers_at_exc = length(riv3),
                  daily_build = daily_build, verdict = if (go) "continue" else "stop")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)
utils::write.csv(run, file.path(out_dir, "ch_rear_run.csv"), row.names = FALSE, na = "")
utils::write.csv(flips, file.path(out_dir, "ch_rear_flips.csv"), row.names = FALSE, na = "")
utils::write.csv(by_group, file.path(out_dir, "ch_rear_flips_by_group.csv"), row.names = FALSE, na = "")
utils::write.csv(ratio_by_group, file.path(out_dir, "ch_rear_ratio_by_group.csv"), row.names = FALSE, na = "")
cat("wrote", out_dir, "\nfinished:", format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"), "\n")
