# data-raw/nuseds_dates_check.R
# ---------------------------------------------------------------------------
# What a NuSEDS spawning date is made of (#256): every dated record of the published set classified by how its dates
# were written and what survey stands behind them, and three candidate rules for a record that could bound the start
# or end of a spawning window, each measured as the records and groups it admits. data-raw/timing_nuseds.R builds the
# windows; this script says what those windows can claim.
#
# WHY / DESIGN NOTES:
#   - A DATE'S FORM. A start, peak or end is a ten-day bin where DFO gives both _from and _to and they differ, else a
#     single date: on the five-day grid (the 1st, 5th, 10th, 15th, 20th, 25th, 30th or 31st) or on another day. Dates
#     on the grid read as estimates of the season, not days a spawner was seen.
#     Bins are classed by width, and a bin that runs backwards is counted.
#   - THE SURVEY. start_dtt and end_dtt are the survey's first and last days, and no_inspections_used the number of
#     visits. A start recorded before the survey began, or an end after it ended, was not seen. A survey brackets an
#     edge where it began before the earliest start, or ended after the latest end; the two edges are counted apart.
#     NuSEDS keeps no count per visit, so nothing says a visit outside the window found no spawners: a bracket is
#     consistent with an edge, never proof of one. A survey date more than a year from the record's year, or a survey
#     ending before it starts, is a slip and is not compared; a record that ends before it starts joins no rule.
#   - YEARS. Every DD-MON-YY date takes the century that puts it nearest the record's analysis year, so a coho end in
#     January falls in the next year and is compared with a survey that ended in December.
#   - THE CANDIDATE RULES for a record that could bound an edge: (a) its survey brackets both edges with at least N
#     visits (N from 2 to 5), or the start alone (a3s) or the end alone (a3e) with 3; (b) a fence or fixed-site census
#     (estimate_method "Fixed Site Census" or a Fence among enumeration_methods), which counts fish as they pass and
#     so dates arrival (its records' arrival is set beside their start); (c) its start and end are single dates off
#     the five-day grid; (d) estimate_method "Area Under the Curve", which needs repeated counts. Each admits only
#     records whose adults were present, and is counted province-wide by species, then as the pooled groups it leaves
#     with any record (and with five) per species, then as the chinook windows its records alone give in five groups.
#   - THE TEST, set before it was run (planning/active/task_plan.md, #256): a rule fails if dated NONE OBSERVED records
#     meet its conditions at half or more of the rate present records do (its dates would be written whatever was
#     seen), or if over half the records it admits put a start or end on the five-day grid. Printed overall and within
#     each era, since NONE OBSERVED records are mostly from before visits were recorded.
#   - THE GROUPS READ RECORD BY RECORD: BULK, MORR and KISP (#241, with the Bulkley's reaches and the Morice that sit
#     apart on codes crossing several groups) and UFRA and COTR (#96's windows), chinook, population by population;
#     the Morice and Nanika by period, as #241 read the upper Bulkley; and the upper Bulkley (pop_id 47859, the
#     mainstem, and 49223, Buck Creek) record by record, the worked example #241 read first. The script stops unless
#     it reproduces #241's counts of those records.
#   - NONE OBSERVED AND NOT INSPECTED. Records with these adult presences that carry spawning dates are counted, with
#     whether their survey fell inside the window they give: a window on a stream where no spawner was seen is the
#     stream's expected timing, not an observation.
#
# INPUT:  https://fresh-bc.s3.us-west-2.amazonaws.com/knowledge/nuseds/<VERSION>/ (manifest.json,
#         nuseds_records.parquet), data/nuseds_reach_groups.csv, a database holding whse_basemapping (PG*)
# OUTPUT: printed
# RUN:    d=$(date -u +%Y%m%d); t=${TMPDIR:-/tmp}/${d}_nuseds_dates_check.txt
#         (set -o pipefail; Rscript data-raw/nuseds_dates_check.R 2>&1 | tee ${t}) && cp ${t} scripts/logs/timing/
#         (repo root; written outside the repo and copied in after a run that succeeded, as timing_nuseds.R's log is)
#         VERSION=v1 before Rscript   (the published set, else v1)
# ---------------------------------------------------------------------------
pkgload::load_all(quiet = TRUE)
options(warn = 1, width = 200)
source("data-raw/nuseds_dates_read.R")

x <- nuseds_read(Sys.getenv("VERSION", "v1"))
x$species_code <- unname(nuseds_species[x$species])
x <- x[!is.na(x$species_code), , drop = FALSE]
x$end_one <- ifelse(is.na(x$end_spawn_dt_to), x$end_spawn_dt_from, x$end_spawn_dt_to)
x <- x[!is.na(x$start_spawn_dt_from) | !is.na(x$end_one), , drop = FALSE]
x$yr <- as.integer(x$analysis_yr)
x$era <- as.character(cut(x$yr, c(0, 1970, 1980, 1990, 2000, 2010, 3000), right = FALSE,
                          labels = c("to 1969", "1970s", "1980s", "1990s", "2000s", "2010 on")))
cat(nrow(x), "dated records (a spawning start or end) of the six species\n")

# ---- each date's form ----
grid <- c(1L, 5L, 10L, 15L, 20L, 25L, 30L, 31L)
form <- function(from, to) {
  one <- ifelse(is.na(from), to, from)
  bin <- !is.na(from) & !is.na(to) & from != to
  ifelse(is.na(one), NA_character_,
         ifelse(bin, "bin", ifelse(as.integer(substr(one, 1, 2)) %in% grid, "grid day", "other day")))
}
x$start_form <- form(x$start_spawn_dt_from, x$start_spawn_dt_to)
x$peak_form <- form(x$peak_spawn_dt_from, x$peak_spawn_dt_to)
x$end_form <- form(x$end_spawn_dt_from, x$end_spawn_dt_to)
lvl <- c("grid day", "other day", "bin")
tab <- function(...) print(stats::addmargins(table(..., useNA = "ifany")))
cat("\n==== the start of spawning, by era and form (counts)\n")
tab(era = factor(x$era, unique(x$era[order(x$yr)])), start = factor(x$start_form, lvl))
cat("\n==== the end of spawning, by era and form\n")
tab(era = factor(x$era, unique(x$era[order(x$yr)])), end = factor(x$end_form, lvl))
cat("\n==== the peak, by era and form (NA: no peak given)\n")
tab(era = factor(x$era, unique(x$era[order(x$yr)])), peak = factor(x$peak_form, lvl))
# a bin's width in days, from and to inclusive; 0 or less is a bin that runs backwards
width <- function(from, to) {
  i <- !is.na(from) & !is.na(to) & from != to
  out <- rep(NA_integer_, length(from))
  out[i] <- as.integer(nuseds_date(to[i], x$yr[i]) - nuseds_date(from[i], x$yr[i])) + 1L
  out
}
cls <- function(w) cut(w, c(-Inf, 0, 9, 11, 31, Inf), labels = c("reversed", "2-9 days", "10-11 days",
                                                                  "12-31 days", "over 31 days"))
bins <- data.frame(start = cls(width(x$start_spawn_dt_from, x$start_spawn_dt_to)),
                   peak = cls(width(x$peak_spawn_dt_from, x$peak_spawn_dt_to)),
                   end = cls(width(x$end_spawn_dt_from, x$end_spawn_dt_to)))
cat("\n==== bins by width (from and to both given and different)\n")
print(sapply(bins, table))
cat("end given only as end_spawn_dt_to (no _from):", sum(is.na(x$end_spawn_dt_from) & !is.na(x$end_spawn_dt_to)),
    "\n")
b <- x$start_form %in% "bin"
bin_from <- as.integer(substr(x$start_spawn_dt_from[b], 1, 2))
cat("start bins opening on the 1st, 11th or 21st:", sum(bin_from %in% c(1L, 11L, 21L)), "of", sum(b), "\n")
cat("day of month of single start dates (the ten most common):\n")
print(utils::head(sort(table(as.integer(substr(x$start_spawn_dt_from[!b & !is.na(x$start_spawn_dt_from)], 1, 2))),
                       decreasing = TRUE), 10))

# ---- full dates: the window's earliest and latest, and the survey (nuseds_survey(), shared with timing_nuseds.R) ----
x <- nuseds_survey(x)
dt <- function(v) nuseds_date(v, x$yr)
cat("\n", sum(x$survey_slip), "records give survey dates more than a year from their own year, or ending before",
    "they start (the upper Bulkley's 2020 record: 20-OCT-08 to 20-SEP-30): not compared\n")
cat(sum(x$backwards), "records end before they start on these dates: kept out of every rule\n")
x$start_before_survey <- !is.na(x$start_hi) & !is.na(x$s0) & x$start_hi < x$s0
x$end_after_survey <- !is.na(x$end_lo) & !is.na(x$s1) & x$end_lo > x$s1
x$survey_dated <- !is.na(x$s0) & !is.na(x$s1)

cat("\n==== the survey beside the window, by era (records)\n")
sv <- do.call(rbind, lapply(split(x, factor(x$era, unique(x$era[order(x$yr)]))), function(d) data.frame(
  records = nrow(d), survey_dated = sum(d$survey_dated), visits_given = sum(!is.na(d$visits)),
  visits_median = if (any(!is.na(d$visits))) stats::median(d$visits, na.rm = TRUE) else NA,
  start_before_survey = sum(d$start_before_survey), end_after_survey = sum(d$end_after_survey),
  brackets_start = sum(d$brackets_start), brackets_end = sum(d$brackets_end),
  brackets_both = sum(d$brackets_start & d$brackets_end))))
print(sv)
cat("\nestimate_method on dated records:\n")
print(sort(table(x$estimate_method), decreasing = TRUE))

# ---- NONE OBSERVED and NOT INSPECTED ----
for (pr in c("NONE OBSERVED", "NOT INSPECTED")) {
  no <- x[x$adult_presence %in% pr, , drop = FALSE]
  inside <- no$survey_dated & no$s0 <= no$end_hi & no$s1 >= no$start_lo
  cat("\n====", nrow(no), "dated records say", pr, "; by species and era:\n")
  tab(species = no$species_code, era = factor(no$era, unique(no$era[order(no$yr)])))
  cat(sum(no$survey_dated), "give survey dates;", sum(inside, na.rm = TRUE),
      "were surveyed inside the spawning window they give;", sum(!is.na(no$peak_lo)), "give a peak;",
      sum(no$natural_adult_spawners > 0 | no$total_return_to_river > 0, na.rm = TRUE), "give a spawner count above 0\n")
}

# ---- the candidate rules ----
# each rule's conditions, whatever the adult presence; a rule admits only present records with a start and an end
x$fence <- x$estimate_method %in% "Fixed Site Census" | grepl("Fence", x$enumeration_methods, fixed = TRUE)
x$exact <- x$start_form %in% "other day" & x$end_form %in% "other day"
x$auc <- x$estimate_method %in% "Area Under the Curve"
x$bracket <- x$brackets_start & x$brackets_end
x$whole <- !is.na(x$start_lo) & !is.na(x$end_hi) & !x$backwards
conds <- function(x) list(
  "a2: survey brackets both edges, 2+ visits" = x$bracket & x$visits0 >= 2L,
  "a3: survey brackets both edges, 3+ visits" = x$bracket & x$visits0 >= 3L,
  "a4: survey brackets both edges, 4+ visits" = x$bracket & x$visits0 >= 4L,
  "a5: survey brackets both edges, 5+ visits" = x$bracket & x$visits0 >= 5L,
  "a3s: survey brackets the start, 3+ visits" = x$brackets_start & x$visits0 >= 3L,
  "a3e: survey brackets the end, 3+ visits" = x$brackets_end & x$visits0 >= 3L,
  "b: fence or fixed-site census" = x$fence,
  "c: start and end off the five-day grid" = x$exact,
  "d: area under the curve" = x$auc,
  "a3 and c" = x$bracket & x$visits0 >= 3L & x$exact)
cs <- conds(x)
cat("\n==== records each candidate rule admits, by species (present, with a start and an end)\n")
print(do.call(rbind, lapply(names(cs), function(r) {
  t <- table(factor(x$species_code[cs[[r]] & x$present & x$whole], nuseds_species))
  data.frame(rule = r, as.list(t), all = sum(t), check.names = FALSE)
})), row.names = FALSE)

# the test set before the results (task_plan.md): a rule fails if dated NONE OBSERVED records meet its conditions
# at half or more of the rate present records do, or if over half its admitted records put a start or end on the
# five-day grid
none <- x$adult_presence %in% "NONE OBSERVED" & x$whole
pres <- x$present & x$whole
grid_edge <- x$start_form %in% "grid day" | x$end_form %in% "grid day"
cat("\n==== does each rule separate dates someone saw from dates written regardless?\n")
sep <- do.call(rbind, lapply(names(cs), function(r) {
  rp <- mean(cs[[r]][pres])
  rn <- mean(cs[[r]][none])
  adm <- cs[[r]] & pres
  g <- if (any(adm)) mean(grid_edge[adm]) else NA_real_
  data.frame(rule = r, present_rate = round(rp, 4), none_observed_rate = round(rn, 4),
             none_over_present = round(rn / rp, 2), admitted = sum(adm), grid_share = round(g, 2),
             bin_share = if (any(adm)) round(mean((x$start_form %in% "bin" | x$end_form %in% "bin")[adm]), 2) else NA,
             passes = rn < rp / 2 & !is.na(g) & g <= 0.5)
}))
print(sep, row.names = FALSE)
cat("\nthe same rates within each era (NONE OBSERVED records are mostly before 1990, when visits were seldom recorded):\n")
print(do.call(rbind, lapply(unique(x$era[order(x$yr)]), function(e) {
  i <- x$era == e
  data.frame(era = e, present_n = sum(pres & i), none_observed_n = sum(none & i),
             t(vapply(cs, function(v) sprintf("%.3f / %.3f", mean(v[pres & i]), mean(v[none & i])), "")),
             check.names = FALSE)
})), row.names = FALSE)

# a fence counts fish as they pass, which dates arrival: its records' arrival beside their start of spawning
fz <- x[x$fence & pres & !is.na(x$stream_arrival_dt_from), , drop = FALSE]
fa <- as.integer(fz$start_lo - dt(x$stream_arrival_dt_from)[x$fence & pres & !is.na(x$stream_arrival_dt_from)])
cat("\nfence and fixed-site records with an arrival date:", nrow(fz), "; days from arrival to the recorded start,",
    "quartiles:", paste(stats::quantile(fa, c(0.25, 0.5, 0.75), na.rm = TRUE), collapse = ", "), "\n")

# ---- placed in watershed groups ----
cat("\n", sum(is.na(x$fwa_watershed_cde)), "dated records carry no FWA watershed code\n")
x <- nuseds_place(x[!is.na(x$fwa_watershed_cde), , drop = FALSE])
x$ok <- x$present & x$whole
rules <- c(list("all dated, present" = x$ok), lapply(conds(x), function(r) r & x$ok))
cat("\n==== pooled groups (a population on a code in one group, or a named reach) with records each rule admits\n")
pg <- !is.na(x$wsg)
print(do.call(rbind, lapply(names(rules), function(r) {
  do.call(rbind, lapply(nuseds_species, function(sp) {
    k <- table(x$wsg[rules[[r]] & pg & x$species_code == sp])
    data.frame(rule = substr(r, 1, 4), species = sp, groups_1 = sum(k >= 1), groups_5 = sum(k >= 5),
               records = sum(k))
  }))
})), row.names = FALSE)

# ---- chinook windows on each rule's records, five groups ----
focus <- c("BULK", "MORR", "KISP", "UFRA", "COTR")
# a bin's midpoint (a single date is itself), as a day of the chinook season year
day <- function(lo, hi) {
  m <- lo + as.integer(hi - lo) %/% 2L
  nuseds_season(nuseds_doy(ifelse(is.na(m), NA_character_, format(m, "%m-%d")), "mmdd"), "CH")
}
x$start_mid <- day(x$start_lo, x$start_hi)
x$end_mid <- day(x$end_lo, x$end_hi)
x$peak_mid <- day(x$peak_lo, x$peak_hi)
med <- function(v) if (all(is.na(v))) NA_character_ else nuseds_day_str(stats::median(v, na.rm = TRUE))
cat("\n==== chinook windows (medians, bins as midpoints) on each rule's records, pooled groups\n")
print(do.call(rbind, lapply(focus, function(w) do.call(rbind, lapply(names(rules), function(r) {
  d <- x[rules[[r]] & pg & x$wsg %in% w & x$species_code == "CH", , drop = FALSE]
  data.frame(wsg = w, rule = substr(r, 1, 4), records = nrow(d), start = med(d$start_mid), peak = med(d$peak_mid),
             end = med(d$end_mid))
})))), row.names = FALSE)

# ---- chinook population by population, five groups and the populations apart on them ----
crosses <- function(g) vapply(strsplit(x$groups, ","), function(v) any(v %in% g), logical(1))
ch <- x[x$species_code == "CH" & (x$wsg %in% focus | (is.na(x$wsg) & crosses(focus))), , drop = FALSE]
cat("\n==== chinook populations in BULK, MORR, KISP, UFRA and COTR, and apart on codes crossing them\n")
pops <- do.call(rbind, lapply(split(ch, ch$pop_id), function(d) data.frame(
  pop_id = d$pop_id[1], waterbody = paste(sort(unique(d$waterbody)), collapse = "; "),
  wsg = if (is.na(d$wsg[1])) paste("apart:", d$groups[1]) else d$wsg[1], records = nrow(d),
  years = paste(min(d$yr), max(d$yr), sep = "-"), start_grid = sum(d$start_form %in% "grid day"),
  start_other = sum(d$start_form %in% "other day"), start_bin = sum(d$start_form %in% "bin"),
  visits_given = sum(!is.na(d$visits)), visits_median = if (any(!is.na(d$visits))) stats::median(d$visits, na.rm = TRUE)
  else NA, survey_dated = sum(d$survey_dated), start_before_survey = sum(d$start_before_survey),
  end_after_survey = sum(d$end_after_survey), brackets_both = sum(d$brackets_start & d$brackets_end),
  a3 = sum(d$bracket & d$visits0 >= 3L & d$ok), fence = sum(d$fence), auc = sum(d$auc),
  method = names(sort(table(d$estimate_method), decreasing = TRUE))[1])))
print(pops[order(pops$wsg, -pops$records), ], row.names = FALSE)

# ---- the Morice and Nanika, by period, as #241 read the upper Bulkley ----
cat("\n==== the Morice (pop_id 49188) and Nanika (49213) chinook, before and after 1992\n")
mn <- x[x$pop_id %in% c(49188, 49213) & x$species_code == "CH", , drop = FALSE]
print(do.call(rbind, lapply(split(mn, list(mn$waterbody, ifelse(mn$yr < 1992, "to 1991", "1992 on")), drop = TRUE),
  function(d) data.frame(waterbody = d$waterbody[1], period = if (d$yr[1] < 1992) "to 1991" else "1992 on",
    records = nrow(d), years = paste(min(d$yr), max(d$yr), sep = "-"), start_grid = sum(d$start_form %in% "grid day"),
    start_bin = sum(d$start_form %in% "bin"), visits_median = if (any(!is.na(d$visits))) stats::median(d$visits,
    na.rm = TRUE) else NA, survey_dated = sum(d$survey_dated), start_before_survey = sum(d$start_before_survey),
    end_after_survey = sum(d$end_after_survey), a3s = sum(d$brackets_start & d$visits0 >= 3L & d$ok),
    a3e = sum(d$brackets_end & d$visits0 >= 3L & d$ok), none_observed = sum(d$adult_presence %in% "NONE OBSERVED"),
    method = names(sort(table(d$estimate_method), decreasing = TRUE))[1]))), row.names = FALSE)

# ---- the worked example: the upper Bulkley, record by record ----
ub <- x[x$pop_id %in% c(47859, 49223) & x$species_code == "CH", , drop = FALSE]
ub <- ub[order(ub$pop_id, ub$yr), , drop = FALSE]
cat("\n==== the upper Bulkley chinook (pop_id 47859, 49223), record by record\n")
print(ub[, c("pop_id", "waterbody", "analysis_yr", "start_spawn_dt_from", "start_spawn_dt_to", "peak_spawn_dt_from",
             "peak_spawn_dt_to", "end_spawn_dt_from", "end_spawn_dt_to", "start_dtt", "end_dtt", "no_inspections_used",
             "estimate_method", "adult_presence")], row.names = FALSE)
n_old <- sum(ub$yr >= 1953 & ub$yr <= 1991)
n_new <- sum(ub$yr >= 2008 & ub$yr <= 2020)
if (nrow(ub) != 40L || n_old != 27L || n_new != 13L) {
  stop("upper Bulkley: ", nrow(ub), " dated records, ", n_old, " 1953-1991 and ", n_new,
       " 2008-2020; #241 read 40, 27 and 13", call. = FALSE)
}
pre <- ub[ub$yr %in% c(2009L, 2016L, 2017L), , drop = FALSE]
if (!all(pre$start_before_survey)) stop("upper Bulkley: 2009, 2016 and 2017 do not all start before their survey",
                                         call. = FALSE)
cat("check: the upper Bulkley holds 40 dated records, 27 from 1953-1991 and 13 from 2008-2020, and its 2009, 2016",
    "and 2017 starts precede their surveys, as #241 read them\n")
