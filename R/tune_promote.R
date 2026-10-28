#' Promote a candidate tuning run into the tracked tables
#'
#' `scripts/0320` writes a full run to `data/tune/candidate/<run>/` and
#' `scripts/0330` compares it into `data/compare/candidate/<run>/`, both
#' ignored, so iterating changes nothing tracked (#111). Promotion, on the
#' operator's word, moves the run in: every file of each promoted key (its
#' tables and the ignored grades, curve, score cache, segments and GeoPackage),
#' its Atlas-gradient sensitivity, the run's logs, its figures, and its rows of
#' the tables that hold every key (`compare.csv`, `change.csv`, `checks.csv`,
#' `floodplain.csv`). A key's files are moved, not copied (its grades and
#' GeoPackage run to gigabytes), so a promoted key leaves the run's directory;
#' the logs are copied. A tracked file of a promoted key that the run did not
#' write is removed, so no key is left half one run and half another. Every
#' file replaced or removed is first moved to `candidate/replaced_<stamp>/`
#' under the two directories, itself a candidate, so a promotion is undone by
#' promoting that (the logs it added, and files it added where none stood, then
#' stay).
#'
#' Keys can be promoted alone, but only onto the build the kept keys are on:
#' `scripts/0325` and the article bundles require one evidence build, link run,
#' gradient, reference edges, flow load, walk, link config and tuned structure
#' across every key, so a promotion that would leave two is refused before
#' anything moves, naming the field and the kept keys that would have to come
#' along. After a change upstream (a new link run or evidence build) that means
#' every fitted key moves together. Each promoted key's grades must be of its
#' recommended rule on its own evidence, and its comparison of the same rule and
#' made after its grades.
#'
#' @param run `character(1)` the candidate run's name.
#' @param keys `NULL` for every key of the run, or the keys to promote
#'   (`"CH_rear"`).
#' @param live `NULL`, or a named list of the values the promoted set must carry
#'   to pass what reads it next (`evidence_md5`: the md5s of this machine's
#'   derived tables; `walk_md5`: this tree's walk; `discharge_load`: the live
#'   flow load); `scripts/0335` passes them.
#' @param tune_dir,compare_dir the tracked directories; the candidates are their
#'   `candidate/<run>/`.
#' @param log_dir where the tracked logs live.
#' @param fig_dir where the tracked comparison figures live.
#' @param dry_run `TRUE` checks and lists, moving and writing nothing.
#' @return A list: `keys`, `written` (tracked paths written), `removed`
#'   (tracked paths removed), `archive` (the `replaced_<stamp>` run holding what
#'   was replaced, `NA` when nothing was), and `notes` (what the run did not
#'   bring and was left as it was), invisibly.
#' @export
#' @examples
#' d <- tempfile(); dir.create(c <- file.path(d, "tune", "candidate", "r1"), recursive = TRUE)
#' dir.create(file.path(d, "compare"))
#' utils::write.csv(data.frame(species_code = "KO", stage = "rear", status = "no_stream_rule"),
#'                  file.path(c, "KO_rear_summary.csv"), row.names = FALSE)
#' p <- knw_tune_promote("r1", tune_dir = file.path(d, "tune"), compare_dir = file.path(d, "compare"),
#'                       log_dir = file.path(d, "logs"), fig_dir = file.path(d, "fig"))
#' basename(p$written)
knw_tune_promote <- function(run, keys = NULL, live = NULL, tune_dir = "data/tune", compare_dir = "data/compare",
                             log_dir = "scripts/logs/habitat", fig_dir = "research/fig", dry_run = FALSE) {
  chk::chk_string(run)
  chk::chk_flag(dry_run)
  if (!is.null(live)) chk::chk_list(live)
  run_tune <- file.path(tune_dir, "candidate", run)
  run_cmp <- file.path(compare_dir, "candidate", run)
  if (!dir.exists(run_tune)) stop("no candidate run ", run_tune, call. = FALSE)
  rd <- function(f, ...) utils::read.csv(f, colClasses = "character", na.strings = "", check.names = FALSE, ...)
  summaries <- function(d) {
    f <- list.files(d, "_summary\\.csv$", full.names = TRUE)
    stats::setNames(lapply(f, rd), sub("_summary\\.csv$", "", basename(f)))
  }
  cand <- summaries(run_tune)
  if (!length(cand)) stop("no <key>_summary.csv in ", run_tune, call. = FALSE)
  if (is.null(keys)) keys <- names(cand)
  chk::chk_character(keys)
  bad <- setdiff(keys, names(cand))
  if (length(bad)) stop("not in run ", run, ": ", paste(bad, collapse = ", "), call. = FALSE)
  keys <- sort(unique(keys))
  fld <- function(x, f) if (!is.null(x) && f %in% names(x) && nrow(x)) x[[f]][1] else NA_character_
  one <- function(x, f) {
    v <- if (!is.null(x) && f %in% names(x)) unique(stats::na.omit(x[[f]])) else character()
    if (length(v) == 1) v else if (length(v)) paste(sort(v), collapse = "|") else NA_character_
  }

  # ---- each promoted key's own record ----
  for (k in keys) {
    rule <- fld(cand[[k]], "rule_recommended")
    if (is.na(rule)) next   # not fitted: a summary (and a smoke table) only, nothing graded or compared
    g <- file.path(run_tune, paste0(k, "_grades.csv"))
    if (!file.exists(g)) {
      stop(k, ": the run scored a pick but wrote no grades (", g, "): it stopped before grading", call. = FALSE)
    }
    g1 <- rd(g, nrows = 1)
    if (!identical(fld(g1, "rule"), rule)) {
      stop(k, ": graded under ", fld(g1, "rule"), ", not the recommended ", rule, call. = FALSE)
    }
    if (!identical(fld(g1, "evidence_md5"), fld(cand[[k]], "evidence_md5"))) {
      stop(k, ": the grades and the summary name different evidence builds", call. = FALSE)
    }
    cf <- file.path(run_cmp, paste0(k, "_compare.csv"))
    if (!file.exists(cf)) {
      stop(k, ": no comparison in ", run_cmp, ": run TUNE_DIR=", run_tune, " scripts/0330 first", call. = FALSE)
    }
    tr <- one(rd(cf), "tuned_rule")
    if (!identical(tr, rule)) stop(k, ": the comparison is of ", tr, ", not the recommended ", rule, call. = FALSE)
    if (file.mtime(cf) < file.mtime(g)) {
      stop(k, ": compared before it was last graded: rerun TUNE_DIR=", run_tune, " scripts/0330", call. = FALSE)
    }
  }

  # ---- the set after promotion is one build: the promoted keys and the tracked keys left as they are ----
  fields <- c("evidence_md5", "run_uid", "curve_grad", "evidence_ledger", "ref_edge", "discharge_load", "walk_md5",
              "config_sha", "tuned_structure")
  record <- function(dt, dc, k, s) {
    g <- file.path(dt, paste0(k, "_grades.csv"))
    cf <- file.path(dc, paste0(k, "_compare.csv"))
    g1 <- if (file.exists(g)) rd(g, nrows = 1) else NULL
    cmp <- if (file.exists(cf)) rd(cf) else NULL
    c(vapply(fields[1:4], function(f) fld(s, f), character(1)),
      vapply(fields[5:7], function(f) fld(g1, f), character(1)),
      vapply(fields[8:9], function(f) one(cmp, f), character(1)))
  }
  kept <- summaries(tune_dir)
  kept <- kept[setdiff(names(kept), keys)]
  recs <- c(lapply(stats::setNames(keys, keys), function(k) record(run_tune, run_cmp, k, cand[[k]])),
            lapply(stats::setNames(names(kept), names(kept)), function(k) record(tune_dir, compare_dir, k, kept[[k]])))
  # the Atlas-gradient sensitivity is read with the main tables (the methodology bundle), so it is held to their build
  fwa_cand <- summaries(file.path(run_tune, "grad_fwa"))
  fwa_kept <- summaries(file.path(tune_dir, "grad_fwa"))
  fwa_from <- c(lapply(intersect(keys, names(fwa_cand)), function(k) list(k, fwa_cand[[k]])),
                lapply(setdiff(names(fwa_kept), intersect(keys, names(fwa_cand))), function(k) list(k, fwa_kept[[k]])))
  for (x in fwa_from) {
    v <- stats::setNames(rep(NA_character_, length(fields)), fields)
    v[c("evidence_md5", "run_uid")] <- c(fld(x[[2]], "evidence_md5"), fld(x[[2]], "run_uid"))
    recs[[paste0("grad_fwa/", x[[1]])]] <- v
  }
  promoted <- c(keys, paste0("grad_fwa/", intersect(keys, names(fwa_cand))))
  for (f in fields) {
    v <- vapply(recs, `[[`, character(1), f)
    vals <- unique(stats::na.omit(v[names(v) %in% promoted]))
    if (length(vals) > 1) {
      stop("the promoted keys carry ", length(vals), " values of ", f, ": ", paste(vals, collapse = "; "),
           call. = FALSE)
    }
    if (!length(vals)) next
    off <- names(v)[!is.na(v) & v != vals & !names(v) %in% promoted]
    if (length(off)) {
      stop("promoting ", paste(keys, collapse = ", "), " (", f, " ", vals, ") would leave ",
           paste(off, collapse = ", "), " on another ", f,
           ", which 0325 and the article bundles refuse: promote them too from a run on this build, ",
           "or promote nothing", call. = FALSE)
    }
    if (!is.null(live[[f]]) && !identical(vals, live[[f]])) {
      stop("the promoted keys carry ", f, " ", vals, ", not ", live[[f]],
           " (this machine and tree), which 0325 and the ",
           "article bundles would refuse", call. = FALSE)
    }
  }

  # ---- the plan: per key, its files from the run, and the tracked files it no longer has ----
  removed <- character()
  copies <- list()
  notes <- character()
  plan_dir <- function(from, to, pat_of) {
    for (k in keys) {
      pat <- pat_of(k)
      src <- if (dir.exists(from)) list.files(from, pat, full.names = TRUE) else character()
      src <- src[!dir.exists(src)]
      old <- if (dir.exists(to)) list.files(to, pat, full.names = TRUE) else character()
      old <- old[!dir.exists(old)]
      if (!length(src)) {
        if (length(old)) {
          notes <<- c(notes, sprintf("%s: the run wrote nothing in %s; %d tracked file(s) in %s kept",
                                     k, from, length(old), to))
        }
        next
      }
      copies[[length(copies) + 1]] <<- list(from = src, to = file.path(to, basename(src)), move = TRUE)
      removed <<- c(removed, setdiff(old, file.path(to, basename(src))))
    }
  }
  esc <- function(k) gsub(".", "\\.", k, fixed = TRUE)
  by_key <- function(k) paste0("^", esc(k), "_")
  plan_dir(run_tune, tune_dir, by_key)
  plan_dir(run_cmp, compare_dir, by_key)
  if (dir.exists(file.path(run_tune, "grad_fwa"))) {
    plan_dir(file.path(run_tune, "grad_fwa"), file.path(tune_dir, "grad_fwa"), by_key)
  }
  plan_dir(file.path(run_cmp, "gpkg"), file.path(compare_dir, "gpkg"), function(k) paste0("^", esc(k), "\\.gpkg$"))
  plan_dir(file.path(run_cmp, "fig"), fig_dir, function(k) paste0("^compare_", esc(tolower(k)), "_.*\\.png$"))
  # the run's logs, beside the others; an existing log of the same name must be this one
  logs <- c(list.files(run_tune, "_tune_run.*\\.txt$", full.names = TRUE),
            list.files(run_cmp, "_compare.*\\.txt$", full.names = TRUE))
  for (f in logs) {
    to <- file.path(log_dir, basename(f))
    if (file.exists(to) && !identical(unname(tools::md5sum(to)), unname(tools::md5sum(f)))) {
      stop("a different log is already tracked as ", to, call. = FALSE)
    }
  }
  if (length(logs)) {
    copies[[length(copies) + 1]] <- list(from = logs, to = file.path(log_dir, basename(logs)), move = FALSE)
  }
  # the tables of every key: each promoted key's rows from the run, in the place its rows held
  merged <- list()
  for (w in c("compare", "change", "checks", "floodplain")) {
    f <- file.path(run_cmp, paste0(w, ".csv"))
    if (!file.exists(f)) {
      if (file.exists(file.path(compare_dir, basename(f)))) {
        notes <- c(notes, sprintf("%s: not in the run; the tracked rows kept", basename(f)))
      }
      next
    }
    merged[[file.path(compare_dir, basename(f))]] <- .knw_rows_merge(file.path(compare_dir, basename(f)), f, keys)
  }

  written <- c(unlist(lapply(copies, `[[`, "to")), names(merged))
  # what is replaced or removed goes to an archive laid out as a candidate run, logs aside (a log is never replaced)
  stamp <- base_stamp <- format(Sys.time(), "replaced_%Y%m%d_%H%M%S", tz = "UTC")
  # unique, even for an undo promoted in the same second as the promotion it undoes
  i <- 1L
  taken <- function(x) {
    x == run || dir.exists(file.path(tune_dir, "candidate", x)) || dir.exists(file.path(compare_dir, "candidate", x))
  }
  while (taken(stamp)) {
    i <- i + 1L
    stamp <- paste0(base_stamp, "_", i)
  }
  moving <- c(written[file.exists(written) & dirname(written) != log_dir], removed)
  arch_of <- function(f) {
    d <- dirname(f)
    roots <- c(tune_dir, tune_dir, compare_dir, compare_dir, compare_dir)
    places <- stats::setNames(file.path(roots, "candidate", stamp, c("", "grad_fwa", "", "gpkg", "fig")),
                              c(tune_dir, file.path(tune_dir, "grad_fwa"), compare_dir,
                                file.path(compare_dir, "gpkg"), fig_dir))
    if (!d %in% names(places)) stop("no archive place for ", f, call. = FALSE)
    sub_dir <- sub("/$", "", places[[d]])
    file.path(sub_dir, basename(f))
  }
  arch <- vapply(moving, arch_of, character(1))
  out <- list(keys = keys, written = written, removed = removed, archive = if (length(moving)) stamp else NA_character_,
              notes = notes)
  if (dry_run) return(invisible(out))
  for (d in unique(c(dirname(written), dirname(arch)))) dir.create(d, showWarnings = FALSE, recursive = TRUE)
  ok <- file.rename(moving, arch)
  if (!all(ok)) stop("could not archive ", paste(moving[!ok], collapse = ", "), call. = FALSE)
  # a key's files are moved, not copied: its grades and GeoPackage run to gigabytes, and a promoted run is spent. A move
  # that cannot rename (another filesystem) copies with the dates kept, which 0330's STAGE=maps and gpkg compare
  for (cp in copies) {
    ok <- if (cp$move) suppressWarnings(file.rename(cp$from, cp$to)) else rep(FALSE, length(cp$from))
    if (!all(ok)) {
      ok[!ok] <- file.copy(cp$from[!ok], cp$to[!ok], overwrite = TRUE, copy.date = TRUE)
      if (cp$move && all(ok)) unlink(cp$from[file.exists(cp$from) & file.exists(cp$to)])
    }
    if (!all(ok)) {
      stop("could not copy ", paste(cp$from[!ok], collapse = ", "), "; what it replaced is in ", stamp, call. = FALSE)
    }
  }
  for (f in names(merged)) writeLines(merged[[f]], f)
  invisible(out)
}

# the lines of a table that holds every key, with the promoted keys' rows taken from the run's copy: each key's rows go
# where its rows stood (kept keys untouched, byte for byte), and a key new to the table goes at the end. A header that
# differs is taken from the run only when every key the tracked table holds is promoted
.knw_rows_merge <- function(tracked, run_file, keys) {
  parse <- function(f) {
    ln <- readLines(f, warn = FALSE)
    x <- utils::read.csv(f, colClasses = "character", check.names = FALSE)
    if (length(ln) != nrow(x) + 1) stop(f, ": a field spans lines; cannot merge it by row", call. = FALSE)
    list(header = ln[1], rows = ln[-1], key = paste(x$species_code, x$stage, sep = "_"))
  }
  new <- parse(run_file)
  if (!file.exists(tracked)) return(c(new$header, new$rows[new$key %in% keys]))
  old <- parse(tracked)
  if (!identical(old$header, new$header) && !all(old$key %in% keys)) {
    stop(basename(tracked), "'s columns differ from the run's: promote every key it holds (",
         paste(unique(old$key), collapse = ", "), ")", call. = FALSE)
  }
  header <- if (all(old$key %in% keys)) new$header else old$header
  order_keys <- c(unique(old$key), setdiff(unique(new$key[new$key %in% keys]), old$key))
  rows <- unlist(lapply(order_keys, function(k) if (k %in% keys) new$rows[new$key == k] else old$rows[old$key == k]),
                 use.names = FALSE)
  c(header, rows)
}
