# scripts/0260-timing-seed.R
# ---------------------------------------------------------------------------
# Seed data/life_history_timing.csv from the reporting template's Gantt CSV. Issue #25.
#
# WHY / DESIGN NOTES:
#   - The template CSV is wide (one start/end pair per area), on a dummy 1900 year, with
#     citations over six columns. This reshapes it long: one row per wsg_code x species_code
#     x life_stage x window, start/end as MM-DD, start > end meaning the window crosses 1 Jan.
#   - Areas map to groups: bulkley_* -> BULK, morice_* -> MORR.
#   - Citations are positional: citation_1 belongs to Bulkley, citation_2 to Morice (true of
#     every dated row but one). Where an area has dates and no citation while the other area
#     has a citation and no dates, the citation is taken across with a note; the log names
#     every row that happened to. citation_3..6 are empty and asserted so.
#   - The template encodes a window crossing 1 January three ways: split into a ..12-31 and
#     a 01-01.. row, an end date in 1901, and the 1901 row repeated because its sibling row
#     exists only to split the other area's window. Here: 1901 ends become start > end,
#     exact repeats within a group are dropped, and a split pair is merged into one row
#     (exactly one of each half, or it stops).
#   - Stages map to knw_timing_stages(). "Upstream fry migration" -> fry_migration.
#     "Downstream displacement" has no dates anywhere and is asserted to stay that way.
#   - A window with one end keeps the other NA and says so in `note`. A row with no source
#     says "no source in template; to confirm with knowledge holders".
#   - INVARIANTS, checked before writing: per group x species x stage, the days-of-year
#     covered before and after are the same set, and each day is covered at most once
#     (a doubled or unmerged window cannot pass knw_timing_read(), which refuses both);
#     half windows come through unchanged; every citation cell in the source either lands,
#     as a whole token, in the source of the group x species x stage it belongs to, or is
#     logged as having no dated window to attach to. Cells are trimmed and blanks read as NA
#     with the same rule as knw_timing_read(), so a whitespace cell is not a citation.
#   - The input is another repo's working tree, which no other script here reads. The log
#     records its commit SHA and whether the file was modified, and the committed log is
#     the record of which input produced the table.
#
# INPUT:  $TEMPLATE_DIR/data/inputs_raw/fish_species_life_history_gantt.csv
#         (TEMPLATE_DIR defaults to ~/Projects/repo/fish_passage_template_reporting)
# OUTPUT: data/life_history_timing.csv
# RUN:    Rscript scripts/0260-timing-seed.R 2>&1 | tee scripts/logs/timing/<yyyymmdd>_timing_seed.log
#         (repo root)
# ---------------------------------------------------------------------------

pkgload::load_all(quiet = TRUE)

template_dir <- Sys.getenv("TEMPLATE_DIR", path.expand("~/Projects/repo/fish_passage_template_reporting"))
rel <- "data/inputs_raw/fish_species_life_history_gantt.csv"
src_path <- file.path(template_dir, rel)
if (!file.exists(src_path)) stop("template CSV not found: ", src_path, call. = FALSE)
out_path <- "data/life_history_timing.csv"

git <- function(...) {
  out <- suppressWarnings(system2("git", c("-C", shQuote(template_dir), ...), stdout = TRUE))
  if (!is.null(attr(out, "status"))) stop("git failed in ", template_dir, call. = FALSE)
  out
}
cat("source:  ", src_path, "\n")
cat("commit:  ", git("rev-parse", "HEAD"), "\n")
dirty <- git("status", "--porcelain", "--", rel)
cat("modified:", if (length(dirty)) "YES (working tree differs from commit)" else "no", "\n\n")

src <- utils::read.csv(src_path, colClasses = "character", na.strings = "", check.names = FALSE,
                       fileEncoding = "UTF-8-BOM")
src[] <- lapply(src, function(v) {  # the same blank rule as knw_timing_read()
  v <- trimws(v, whitespace = "[\\h\\v]")
  v[!is.na(v) & !nzchar(v)] <- NA
  v
})
src$row <- seq_len(nrow(src))
cat("source rows:", nrow(src), "\n")

species_map <- c("Chinook" = "CH", "Coho" = "CO", "Steelhead" = "ST", "Sockeye" = "SK",
                 "Bull Trout" = "BT", "Cutthroat Trout" = "CT", "Pacific Lamprey" = "PL")
stage_map <- c("Migration" = "migration", "Spawning" = "spawning", "Incubation" = "incubation",
               "Emergence" = "emergence", "Upstream fry migration" = "fry_migration",
               "Rearing" = "rearing", "Overwintering" = "overwintering",
               "Outmigration" = "outmigration", "Downstream displacement" = NA)
areas <- list(BULK = c("bulkley_start1", "bulkley_end1", "citation_1"),
              MORR = c("morice_start2", "morice_end2", "citation_2"))

stopifnot(
  all(src$Species %in% names(species_map)),
  all(src$life_stage %in% names(stage_map)),
  all(stage_map[names(stage_map)] %in% c(knw_timing_stages(), NA)),
  all(is.na(unlist(src[paste0("citation_", 3:6)])))
)
undated_stage <- src$life_stage == "Downstream displacement"
if (any(!is.na(unlist(src[undated_stage, unlist(lapply(areas, `[`, 1:2))])))) {
  stop("Downstream displacement now has dates; map it to a stage", call. = FALSE)
}

# ---- long, one row per source row x area ----------------------------------
long <- do.call(rbind, lapply(names(areas), function(w) {
  a <- areas[[w]]
  other <- areas[[setdiff(names(areas), w)]]
  data.frame(row = src$row, wsg_code = w,
             species_code = unname(species_map[src$Species]),
             life_stage = unname(stage_map[src$life_stage]),
             start_raw = src[[a[1]]], end_raw = src[[a[2]]],
             cite = src[[a[3]]], cite_other = src[[other[3]]],
             other_dated = !is.na(src[[other[1]]]) | !is.na(src[[other[2]]]),
             note = src$notes)
}))
long$dated <- !is.na(long$start_raw) | !is.na(long$end_raw)
long$other_wsg <- ifelse(long$wsg_code == "BULK", "MORR", "BULK")

# Where every citation cell should end up, decided before any row is dropped: its own
# group's row when that area is dated; the other group's row when only the other area is
# dated and has no citation of its own (taken across, below); otherwise nowhere, logged.
has_cite <- !is.na(long$cite)
dest <- ifelse(long$dated, long$wsg_code,
               ifelse(long$other_dated & is.na(long$cite_other), long$other_wsg, NA))
before_cite <- unique(do.call(rbind, lapply(which(has_cite & !is.na(dest)), function(i) {
  data.frame(key = paste(dest[i], long$species_code[i], long$life_stage[i]),
             cite = trimws(strsplit(long$cite[i], ";")[[1]]))
})))
lost <- unique(long[has_cite & is.na(dest), c("row", "wsg_code", "cite")])
if (nrow(lost)) {
  cat("\ncitations with no dated window to attach to (not carried):\n")
  print(merge(lost, src[c("row", "Species", "life_stage")]), row.names = FALSE)
}

long <- long[long$dated, ]

# cross-area citation: this area dated and uncited, the other undated and cited
across <- is.na(long$cite) & !is.na(long$cite_other) & !long$other_dated
if (any(across)) {
  cat("\ncitation taken from the other area's column:\n")
  print(long[across, c("row", "wsg_code", "species_code", "life_stage", "cite_other")],
        row.names = FALSE)
  long$cite[across] <- long$cite_other[across]
  long$note[across] <- paste(c("citation listed under the other area in the template"),
                             ifelse(is.na(long$note[across]), "", paste0("; ", long$note[across])),
                             sep = "")
}

# ---- years -> MM-DD ---------------------------------------------------------
yr <- function(d) substr(d, 1, 4)
md <- function(d) ifelse(is.na(d), NA_character_, substr(d, 6, 10))
stopifnot(all(grepl("^\\d{4}-\\d{2}-\\d{2}$", c(stats::na.omit(long$start_raw), stats::na.omit(long$end_raw)))))
bad_year <- (!is.na(long$start_raw) & yr(long$start_raw) != "1900") |
  (!is.na(long$end_raw) & !(yr(long$end_raw) == "1900" |
     (yr(long$end_raw) == "1901" & !is.na(long$start_raw) &
        md(long$end_raw) < md(long$start_raw))))
if (any(bad_year)) {
  print(long[bad_year, c("row", "wsg_code", "start_raw", "end_raw")], row.names = FALSE)
  stop("dates outside 1900, or a 1901 end that does not cross the year", call. = FALSE)
}
backwards <- !is.na(long$start_raw) & !is.na(long$end_raw) & yr(long$end_raw) == "1900" &
  md(long$end_raw) < md(long$start_raw)
if (any(backwards)) stop("a 1900 window ends before it starts, source row ",
                         long$row[backwards][1], call. = FALSE)
long$start <- md(long$start_raw)
long$end <- md(long$end_raw)

# ---- drop exact repeats within a group --------------------------------------
kcols <- c("wsg_code", "species_code", "life_stage", "start", "end")
rep_row <- duplicated(long[kcols])
if (any(rep_row)) {
  cat("\nrepeated windows dropped:\n")
  print(long[rep_row, c("row", kcols)], row.names = FALSE)
  # a dropped repeat must not take a citation with it
  kept <- long[!rep_row, ]
  for (i in which(rep_row)) {
    j <- which(!rep_row & do.call(paste, long[kcols]) == do.call(paste, long[i, kcols]))[1]
    long$cite[j] <- paste(stats::na.omit(unique(c(long$cite[j], long$cite[i]))), collapse = "; ")
    if (!nzchar(long$cite[j])) long$cite[j] <- NA
    long$note[j] <- paste(stats::na.omit(unique(c(long$note[j], long$note[i]))), collapse = "; ")
    if (!nzchar(long$note[j])) long$note[j] <- NA
  }
  long <- long[!rep_row, ]
}

# ---- day sets, one calendar for both sides -----------------------------------
doy <- function(d) as.integer(format(as.Date(paste0("2000-", d)), "%j"))
days_of <- function(df) {
  full <- df[!is.na(df$start) & !is.na(df$end), ]
  key <- paste(full$wsg_code, full$species_code, full$life_stage)
  split(unlist(Map(function(s, e) {
    a <- doy(s); b <- doy(e); if (a <= b) a:b else c(a:366, 1:b)
  }, full$start, full$end), use.names = FALSE),
  rep(key, ifelse(doy(full$start) <= doy(full$end),
                  doy(full$end) - doy(full$start) + 1,
                  366 - doy(full$start) + 1 + doy(full$end))))
}
before_days <- lapply(days_of(long), function(x) sort(unique(x)))
before_half <- long[is.na(long$start) | is.na(long$end), kcols]

# ---- merge windows split at 1 January -----------------------------------------
key <- paste(long$wsg_code, long$species_code, long$life_stage)
merged <- list()
drop <- integer(0)
for (k in unique(key)) {
  i <- which(key == k)
  tail_i <- i[!is.na(long$end[i]) & long$end[i] == "12-31"]
  head_i <- i[!is.na(long$start[i]) & long$start[i] == "01-01"]
  head_i <- setdiff(head_i, tail_i)  # a 01-01..12-31 row is a whole year, not half a split
  tail_i <- setdiff(tail_i, i[!is.na(long$start[i]) & long$start[i] == "01-01"])
  if (!length(tail_i) && !length(head_i)) next
  if (length(tail_i) != 1 || length(head_i) != 1) {
    stop("cannot pair a split window for ", k, ": ", length(tail_i), " ending 12-31, ",
         length(head_i), " starting 01-01", call. = FALSE)
  }
  m <- long[tail_i, ]
  m$end <- long$end[head_i]
  m$cite <- paste(stats::na.omit(unique(c(long$cite[tail_i], long$cite[head_i]))), collapse = "; ")
  m$note <- paste(stats::na.omit(unique(c(long$note[tail_i], long$note[head_i]))), collapse = "; ")
  merged[[k]] <- m
  drop <- c(drop, tail_i, head_i)
  cat("merged split window:", k, long$start[tail_i], "..", long$end[head_i], "\n")
}
long <- rbind(long[-drop, , drop = FALSE], do.call(rbind, merged))
long$cite[!is.na(long$cite) & !nzchar(long$cite)] <- NA
long$note[!is.na(long$note) & !nzchar(long$note)] <- NA

# ---- notes and output ----------------------------------------------------------
add_note <- function(note, add, when) {
  ifelse(when, ifelse(is.na(note), add, paste0(note, "; ", add)), note)
}
long$note <- add_note(long$note, "end missing in template", is.na(long$end))
long$note <- add_note(long$note, "start missing in template", is.na(long$start))
long$note <- add_note(long$note, "no source in template; to confirm with knowledge holders",
                      is.na(long$cite))

out <- data.frame(wsg_code = long$wsg_code, species_code = long$species_code,
                  life_stage = long$life_stage, start = long$start, end = long$end,
                  source = long$cite, note = long$note)
out <- out[order(out$wsg_code, match(out$species_code, species_map),
                 match(out$life_stage, knw_timing_stages()), out$start), ]

# ---- invariants ------------------------------------------------------------------
after_days <- lapply(days_of(out), function(x) sort(unique(x)))
raw_after <- days_of(out)
stopifnot(
  identical(names(before_days)[order(names(before_days))], names(after_days)[order(names(after_days))]),
  all(vapply(names(before_days), function(k) identical(before_days[[k]], after_days[[k]]), logical(1))),
  all(!vapply(raw_after, anyDuplicated, integer(1)))
)
after_half <- out[is.na(out$start) | is.na(out$end), kcols]
stopifnot(identical(do.call(paste, before_half[order(do.call(paste, before_half)), ]),
                    do.call(paste, after_half[order(do.call(paste, after_half)), ])))
out_key <- paste(out$wsg_code, out$species_code, out$life_stage)
cite_ok <- mapply(function(k, c) {
  c %in% trimws(unlist(strsplit(out$source[out_key == k & !is.na(out$source)], ";")))
}, before_cite$key, before_cite$cite)
if (!all(cite_ok)) stop("citation lost: ", before_cite$key[!cite_ok][1], call. = FALSE)
cat("\ninvariants: day sets equal for", length(before_days), "keys; no day covered twice;",
    nrow(after_half), "half window(s) unchanged;", nrow(before_cite), "citation(s) carried\n")

utils::write.csv(out, out_path, row.names = FALSE, na = "")
back <- knw_timing_read(out_path)
stopifnot(nrow(back) == nrow(out))

cat("\nwrote", out_path, ":", nrow(out), "rows\n\n")
cat("rows per group x species:\n")
print(table(out$species_code, out$wsg_code)[unique(out$species_code), ])
cat("\nunsourced rows:\n")
print(out[is.na(out$source), c("wsg_code", "species_code", "life_stage", "start", "end")],
      row.names = FALSE)
cat("\nwindows crossing 1 January:\n")
print(out[!is.na(out$start) & !is.na(out$end) & out$start > out$end,
          c("wsg_code", "species_code", "life_stage", "start", "end")], row.names = FALSE)
