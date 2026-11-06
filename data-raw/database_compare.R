# data-raw/database_compare.R
# ---------------------------------------------------------------------------
# Compare a run's outputs with a reference copy, one verdict per output (#158). The same recipe run on a second
# database should give an equivalent result, not the same bytes: row order, a float summed in another order and
# the lines naming the run, the machine or the time are context. Each output gets one of three verdicts, in the
# shape crate's receipt comparison returns (NewGraphEnvironment/crate#43; knowledge#154):
#   identical   the same content: every column equal once rows are sorted on the table's key and columns
#               matched by name (bytes_match says whether the files were also byte for byte the same)
#   equivalent  the same rows and columns, every non-numeric value equal, and every numeric difference within
#               the tolerance declared for that table (max_diff and its column say how far)
#   different   anything else: rows or columns missing or added, a key on one side only, a non-numeric value
#               changed, or a numeric difference past the tolerance
# A `different` where `decision_read` is TRUE (visits placed, a pick, a grade, km drawn) is what stops a run;
# any other `different` is noted and carried past.
#
# KEYS AND TOLERANCES: the `spec` table below, one row per output family, matched on the file name. `key` is the
# columns a row is identified by (blank: sort on every column the two sides share, for small tables whose rows
# carry no float a database could sum differently); `tol` the absolute tolerance on numeric columns (0: exact);
# (walks.csv stores distances rounded to the centimetre, so a fresh walk is held to 0.005 m);
# `context` columns reported and never compared; `added` columns the current code writes and the reference predates
# (#120 added segment_fwa_gradient to visits_link after the published run), noted and never compared. A file no row
# matches is compared exactly, keyed on every column.
#
# SELF-TEST: every run first proves the comparison on fixtures whose verdicts are known (identical in another row
# order, equivalent under a tolerance, different past it, a planted 1e-6 change against a 1e-9 tolerance, a row
# missing, a column renamed, a changed label, NA against a value) and stops if any verdict is wrong.
#
# INPUT:  REF and NEW, two directories (or two files); FILES=a,b,c to compare only those names (default: every
#         .csv in REF that NEW also holds, and every one REF holds that NEW lacks, reported as missing);
#         LABEL names the step in the output (evidence, tune, compare, walks)
# OUTPUT: OUT (default scripts/logs/habitat/<date>_database_compare-<LABEL>.csv), one row per output:
#         label, output, verdict, bytes_match, rows_ref, rows_new, max_diff, column, tolerance, decision_read, note
# RUN:    REF=data/fdis/derived NEW=data/fdis/derived_second LABEL=evidence Rscript data-raw/database_compare.R
#         SELFTEST_ONLY=TRUE Rscript data-raw/database_compare.R
# ---------------------------------------------------------------------------
suppressMessages({ library(data.table) })
options(warn = 1)

# ---- what each output is keyed on, held to, and read for -------------------------------------------------------
# pattern: a regex on the file name. First match wins, so the specific rows come first.
spec <- data.table::rbindlist(list(
  # the evidence build (0310)
  list("^visits_link\\.csv$",        "site_visit",                                          0,    "",  TRUE, "segment_fwa_gradient"),
  list("^visits_species\\.csv$",     "site_visit;species_code",                             0,    "",  TRUE, ""),
  list("^walks\\.csv$",              "blue_line_key;downstream_route_measure;src;qmin",     0.005, "",  TRUE, ""),
  list("^bcfishobs_fdis_match\\.csv$", "",                                                  0,    "",  FALSE, ""),
  list("^access_check\\.csv$",       "species_code;habitat_accessible;access_gt0",          1e-6, "",  FALSE, ""),
  list("^workbook_sites\\.csv$",     "site_visit",                                          1e-6, "",  FALSE, ""),
  list("^workbook_species\\.csv$",   "",                                                    1e-6, "",  FALSE, ""),
  # the tuning (0320): the grade record's run columns are compared, its provenance is context
  list("_grades_record\\.csv$",      "species_code;stage",                                  0,
       "grades_md5;grades_bytes;tune_run;evidence_ledger;knowledge_commit;record_source;evidence_md5", TRUE, ""),
  # the grade table writes rates to 5 significant digits, so a rate near 1 is held only to 1e-5
  list("_grades\\.csv$",             "watershed_group_code;id_segment",                     1e-5, "evidence_md5", TRUE, ""),
  list("_tune\\.csv$",               "rule",                                                1e-6, "",  TRUE, ""),
  list("_summary\\.csv$",            "species_code;stage",                                  1e-6,
       "evidence_md5;tune_run;evidence_ledger;evidence_dir", TRUE, ""),
  list("_curves\\.csv$",             "curve;x",                                             1e-6, "",  FALSE, ""),
  list("_seeds\\.csv$",              "seed",                                                0,    "",  TRUE, ""),
  list("_honest\\.csv$",             "fold",                                                1e-6, "",  FALSE, ""),
  list("_smoke\\.csv$",              "check;role;rule",                                     1e-6, "",  FALSE, ""),
  list("_groups\\.csv$",             "watershed_group_code",                                0,    "",  FALSE, ""),
  list("^pick_report\\.csv$",        "species_code;stage",                                  1e-6, "",  TRUE, ""),
  # the comparison (0330): km sums take a rounding
  list("_compare\\.csv$",            "watershed_group_code;structure",                      1e-6, "",  TRUE, ""),
  list("_change\\.csv$",             "direction;reason;order;structure",                    1e-6, "",  TRUE, ""),
  list("_checks\\.csv$",             "check;rule;segment;tuned_structure",                  1e-6, "",  FALSE, "")
))
data.table::setnames(spec, c("pattern", "key", "tol", "context", "decision_read", "added"))

spec_for <- function(name) {
  hit <- which(vapply(spec$pattern, grepl, logical(1), x = name))
  if (length(hit) == 0) return(list(key = character(), tol = 0, context = character(), decision_read = NA,
                                    added = character()))
  s <- spec[hit[1]]
  split <- function(x) if (nzchar(x)) strsplit(x, ";", fixed = TRUE)[[1]] else character()
  list(key = split(s$key), tol = s$tol, context = split(s$context), decision_read = s$decision_read,
       added = split(s$added))
}

# ---- one comparison --------------------------------------------------------------------------------------------
row_out <- function(output, verdict, bytes_match, rows_ref, rows_new, max_diff = NA_real_, column = NA_character_,
                    tol = NA_real_, decision_read = NA, note = "") {
  data.table::data.table(output = output, verdict = verdict, bytes_match = bytes_match, rows_ref = rows_ref,
                         rows_new = rows_new, max_diff = max_diff, column = column, tolerance = tol,
                         decision_read = decision_read, note = note)
}

# compare two data.tables already read; `name` labels the row
compare_tables <- function(a, b, name, key = character(), tol = 0, context = character(), decision_read = NA,
                           bytes_match = NA, added = character()) {
  na <- nrow(a); nb <- nrow(b)
  notes <- character()
  ctx <- intersect(context, union(names(a), names(b)))
  if (length(ctx)) {
    moved <- ctx[vapply(ctx, function(cn) !(cn %in% names(a) && cn %in% names(b) &&
                                              identical(as.character(a[[cn]]), as.character(b[[cn]]))), logical(1))]
    if (length(moved)) notes <- c(notes, paste0("context differs: ", paste(moved, collapse = ",")))
  }
  # a column the current code adds, which the reference predates: noted, never compared
  add_new <- intersect(setdiff(added, names(a)), names(b))
  if (length(add_new)) notes <- c(notes, paste0("added by the current code: ", paste(add_new, collapse = ",")))
  b <- b[, setdiff(names(b), add_new), with = FALSE]
  a <- a[, setdiff(names(a), ctx), with = FALSE]
  b <- b[, setdiff(names(b), ctx), with = FALSE]
  only_a <- setdiff(names(a), names(b)); only_b <- setdiff(names(b), names(a))
  if (length(only_a) || length(only_b))
    return(row_out(name, "different", bytes_match, na, nb, column = paste(c(only_a, only_b), collapse = ","),
                   tol = tol, decision_read = decision_read,
                   note = paste(c(notes, sprintf("columns only in reference: %s; only in new: %s",
                                                 paste(only_a, collapse = ","), paste(only_b, collapse = ","))),
                                collapse = "; ")))
  if (na != nb)
    return(row_out(name, "different", bytes_match, na, nb, tol = tol, decision_read = decision_read,
                   note = paste(c(notes, "row counts differ"), collapse = "; ")))
  cols <- names(a)
  num <- cols[vapply(cols, function(cn) is.numeric(a[[cn]]) && is.numeric(b[[cn]]), logical(1))]
  # a key must identify rows on both sides; blank: every column that is not a non-integer number
  if (!length(key)) key <- setdiff(cols, num[vapply(num, function(cn) !is.integer(a[[cn]]) ||
                                                       !is.integer(b[[cn]]), logical(1))])
  if (!length(key)) key <- cols
  if (!all(key %in% cols))
    return(row_out(name, "different", bytes_match, na, nb, column = paste(setdiff(key, cols), collapse = ","),
                   tol = tol, decision_read = decision_read,
                   note = paste(c(notes, "key column missing"), collapse = "; ")))
  data.table::setorderv(a, key, na.last = TRUE); data.table::setorderv(b, key, na.last = TRUE)
  key_eq <- all(vapply(key, function(cn) isTRUE(all.equal(a[[cn]], b[[cn]], check.attributes = FALSE,
                                                          tolerance = 0)), logical(1)))
  if (!key_eq) {
    ka <- do.call(paste, c(lapply(key, function(cn) as.character(a[[cn]])), sep = "\r"))
    kb <- do.call(paste, c(lapply(key, function(cn) as.character(b[[cn]])), sep = "\r"))
    return(row_out(name, "different", bytes_match, na, nb, column = paste(key, collapse = ";"), tol = tol,
                   decision_read = decision_read,
                   note = paste(c(notes, sprintf("keys on one side only: %d in reference, %d in new",
                                                 length(setdiff(ka, kb)), length(setdiff(kb, ka)))),
                                collapse = "; ")))
  }
  worst <- 0; worst_col <- NA_character_; bad <- character()
  n_bad <- integer()  # rows differing per column: past the tolerance, or a value or NA that does not match
  for (cn in setdiff(cols, key)) {
    x <- a[[cn]]; y <- b[[cn]]
    nax <- is.na(x); nay <- is.na(y)
    if (any(nax != nay)) {
      bad <- c(bad, cn)
      both <- !nax & !nay
      n_bad[cn] <- sum(nax != nay) + if (cn %in% num) sum(abs(as.numeric(x[both]) - as.numeric(y[both])) > tol) else
        sum(as.character(x[both]) != as.character(y[both]))
      next
    }
    if (cn %in% num) {
      d <- abs(as.numeric(x[!nax]) - as.numeric(y[!nay]))
      m <- if (length(d)) max(d) else 0
      if (!is.finite(m)) { bad <- c(bad, cn); n_bad[cn] <- sum(!is.finite(d)); next }  # Inf against a number
      if (m > worst) { worst <- m; worst_col <- cn }
      if (m > tol) n_bad[cn] <- sum(d > tol)
    } else if (!identical(as.character(x[!nax]), as.character(y[!nay]))) {
      bad <- c(bad, cn); n_bad[cn] <- sum(as.character(x[!nax]) != as.character(y[!nay]))
    }
  }
  if (length(n_bad)) notes <- c(notes, paste0("rows differing: ", paste(names(n_bad), n_bad, sep = " ", collapse = ", ")))
  note <- paste(notes, collapse = "; ")
  if (length(bad))
    return(row_out(name, "different", bytes_match, na, nb, column = paste(bad, collapse = ","), tol = tol,
                   decision_read = decision_read,
                   note = paste(c(notes, "values differ (non-numeric, NA placement or non-finite)"), collapse = "; ")))
  if (worst == 0) return(row_out(name, "identical", bytes_match, na, nb, 0, NA_character_, tol, decision_read, note))
  if (worst <= tol) return(row_out(name, "equivalent", bytes_match, na, nb, worst, worst_col, tol, decision_read, note))
  row_out(name, "different", bytes_match, na, nb, worst, worst_col, tol, decision_read,
          paste(c(notes, "numeric difference past the tolerance"), collapse = "; "))
}

read_tbl <- function(path) data.table::fread(path, na.strings = c("", "NA"), showProgress = FALSE,
                                             integer64 = "double")

compare_files <- function(ref, new, name = basename(ref)) {
  s <- spec_for(name)
  if (!file.exists(new)) return(row_out(name, "different", FALSE, NA_integer_, NA_integer_,
                                        decision_read = s$decision_read, note = "missing from new"))
  bm <- unname(tools::md5sum(ref)) == unname(tools::md5sum(new))
  if (bm) {
    n <- if (grepl("\\.csv$", name)) nrow(read_tbl(ref)) else NA_integer_
    return(row_out(name, "identical", TRUE, n, n, 0, NA_character_, s$tol, s$decision_read, ""))
  }
  if (!grepl("\\.csv$", name)) return(row_out(name, "different", FALSE, NA_integer_, NA_integer_,
                                              decision_read = s$decision_read,
                                              note = "not a csv and the bytes differ: compare by hand"))
  compare_tables(read_tbl(ref), read_tbl(new), name, s$key, s$tol, s$context, s$decision_read, bytes_match = FALSE,
                 added = s$added)
}

# ---- self-test: the verdicts on fixtures whose answers are known -------------------------------------------------
self_test <- function() {
  ref <- function() data.table::data.table(id = 1:4, lab = c("a", "b", "c", "d"), km = c(1.5, 2.25, 3, 4.125),
                                           n = c(10L, 20L, 30L, NA))
  # each case starts from a fresh copy, so one planted change never rides into another case
  cases <- list(
    list("same rows, other order",   ref()[c(3, 1, 4, 2)],                                 0,    "identical"),
    list("float within tolerance",   ref()[, km := km + c(0, 9.5e-11, 0, 0)][],             1e-9, "equivalent"),
    list("planted 1e-6 at 1e-9",     ref()[, km := km + c(0, 0, 1e-6, 0)][],                1e-9, "different"),
    list("float past tolerance 0",   ref()[, km := km + c(0, 9.5e-11, 0, 0)][],             0,    "different"),
    list("row missing",              ref()[-2],                                            0,    "different"),
    list("column renamed",           data.table::setnames(ref(), "n", "count"),             0,    "different"),
    list("label changed",            ref()[, lab := c("a", "b", "x", "d")][],               0,    "different"),
    list("NA against a value",       ref()[, n := c(10L, 20L, 30L, 40L)][],                 0,    "different"),
    list("NA moved to another row",  ref()[, n := c(10L, 20L, NA, 30L)][],                  0,    "different"),
    list("key on one side only",     ref()[, id := c(1L, 2L, 3L, 5L)][],                    0,    "different")
  )
  got <- vapply(cases, function(k) compare_tables(ref(), data.table::copy(k[[2]]), k[[1]], key = "id",
                                                  tol = k[[3]])$verdict, character(1))
  want <- vapply(cases, `[[`, character(1), 4)
  # the unkeyed path: rows reordered with no key declared must still be identical
  got <- c(got, compare_tables(ref(), ref()[c(4, 2, 3, 1)], "unkeyed reorder")$verdict); want <- c(want, "identical")
  # context columns never fail a comparison
  a <- ref()[, run := "x"]; b <- ref()[, run := "y"]
  got <- c(got, compare_tables(a, b, "context differs", key = "id", context = "run")$verdict)
  want <- c(want, "identical")
  # a column the code adds is noted and never fails; the same column undeclared is different
  got <- c(got, compare_tables(ref(), ref()[, extra := 1], "declared added column", key = "id", added = "extra")$verdict,
           compare_tables(ref(), ref()[, extra := 1], "undeclared added column", key = "id")$verdict)
  want <- c(want, "identical", "different")
  # the file path: identical bytes, and a file missing from new
  d <- tempfile("dbc_"); dir.create(d)
  data.table::fwrite(ref(), file.path(d, "a.csv")); data.table::fwrite(ref(), file.path(d, "b.csv"))
  data.table::fwrite(ref()[c(2, 1, 3, 4)], file.path(d, "c.csv"))
  got <- c(got, compare_files(file.path(d, "a.csv"), file.path(d, "b.csv"))$verdict,
           compare_files(file.path(d, "a.csv"), file.path(d, "c.csv"), "x.csv")$verdict,
           compare_files(file.path(d, "a.csv"), file.path(d, "none.csv"))$verdict)
  want <- c(want, "identical", "identical", "different")
  unlink(d, recursive = TRUE)
  if (!identical(got, want))
    stop("self-test failed: ", paste(sprintf("%s got %s, want %s", seq_along(got), got, want)[got != want],
                                     collapse = "; "))
  cat(sprintf("Self-test: %d verdicts as expected.\n", length(got)))
  invisible(TRUE)
}

# ---- run -------------------------------------------------------------------------------------------------------
if (sys.nframe() == 0L) {
  self_test()
  if (Sys.getenv("SELFTEST_ONLY") %in% c("1", "TRUE", "true")) quit(save = "no")
  ref <- Sys.getenv("REF"); new <- Sys.getenv("NEW"); label <- Sys.getenv("LABEL", "run")
  if (!nzchar(ref) || !nzchar(new)) stop("set REF and NEW")
  if (dir.exists(ref)) {
    files <- if (nzchar(Sys.getenv("FILES"))) strsplit(Sys.getenv("FILES"), ",")[[1]] else
      sort(union(list.files(ref, "\\.csv$"), list.files(new, "\\.csv$")))
    pairs <- lapply(files, function(f) c(file.path(ref, f), file.path(new, f), f))
  } else pairs <- list(c(ref, new, basename(ref)))
  out <- data.table::rbindlist(lapply(pairs, function(p) {
    if (!file.exists(p[1])) return(row_out(p[3], "different", FALSE, NA_integer_, NA_integer_,
                                           decision_read = spec_for(p[3])$decision_read,
                                           note = "missing from reference"))
    t0 <- Sys.time(); r <- compare_files(p[1], p[2], p[3])
    cat(sprintf("%-40s %-10s bytes_match=%s rows %s/%s max_diff=%s %s (%.1f s)\n", p[3], r$verdict, r$bytes_match,
                r$rows_ref, r$rows_new, format(r$max_diff, digits = 3), r$note,
                as.numeric(difftime(Sys.time(), t0, units = "secs"))))
    r
  }))
  out <- cbind(data.table::data.table(label = label), out)
  dest <- Sys.getenv("OUT", file.path("scripts/logs/habitat",
                                      sprintf("%s_database_compare-%s.csv", format(Sys.time(), "%Y%m%d", tz = "UTC"),
                                              label)))
  data.table::fwrite(out, dest, na = "NA")
  cat(sprintf("%d outputs: %s. Written to %s\n", nrow(out),
              paste(names(table(out$verdict)), table(out$verdict), sep = " ", collapse = ", "), dest))
  stop_on <- out[verdict == "different" & decision_read %in% TRUE]
  if (nrow(stop_on)) cat(sprintf("STOP: %d decision-read outputs differ: %s\n", nrow(stop_on),
                                 paste(stop_on$output, collapse = ", ")))
}
