# data-raw/bayesian_alignment_check.R
# ---------------------------------------------------------------------------
# Does research/bayesian_alignment.md quote its books truly, and does it give every step, setting and unkeyed choice
# of the method one verdict? Issue #185.
#
# QUOTES. Every quoted passage stands on its own blockquote line as
#   > "<passage>" (<citekey>, p. N)       or  (<citekey>, pp. N–M) for one that runs onto the next page
# and is looked for on printed page N (to M) of that book's PDF, the group library's own attachment. A printed page is
# the PDF page less the book's front matter (`offset`), and the page's running head or foot must carry N, so a wrong
# offset fails rather than reading a neighbouring page. Passage and page are compared as token sequences, as
# scripts/0280 compares them: ligatures spelled out, words and numbers as written ("2" is not "25"), symbols dropped
# (the PDFs set formulae as glyphs pdftotext cannot keep), a line-end hyphen joined in one reading and kept in the
# other. An ellipsis (… or ...) splits a passage into fragments that must appear in order, each of at least
# `frag_min` tokens. A quote with a citekey anywhere but a blockquote line fails, so none escapes the check. A page
# cited without a quote is not checked here: the meaning audit re-reads it.
# COVERAGE. Three tables, each found by its `##` heading: "The steps" (first cell the step number, every step of
# inst/method/pipeline.csv), "The settings" (first cell the key in backticks, every key of inst/method/settings.csv)
# and "Choices with no settings key" (first cell the id in backticks, every id of `choices` below, whose code anchor
# must still be in its file). Each row's last cell is exactly one verdict; a missing, duplicate or stale row fails.
#
# INPUT:  research/bayesian_alignment.md (MD=); inst/method/{pipeline,settings}.csv; R/; the two PDFs under
#         ZOTERO_DIR/storage (default ~/Zotero), by the attachment keys below (group library 4733734, resolved
#         2026-11-11 from a guarded copy of zotero.sqlite)
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_bayesian_alignment_check.txt (not with MD= set); exits 1 on any failure
# RUN:    Rscript data-raw/bayesian_alignment_check.R   (from the repo root; needs pdftotext)
# ---------------------------------------------------------------------------
options(warn = 1)

books <- list(
  mcelreath2020StatisticalRethinking = list(
    file = "PVGNFJC9/McElreath - 2020 - Statistical Rethinking - A Bayesian Course with Ex.pdf", offset = 16L),
  gelman_etal2013Bayesiandata = list(file = "JP3BM8T9/BDA3.pdf", offset = 10L)
)
verdicts <- c("aligned", "differs", "should change", "no bearing")
frag_min <- 4L
# method choices no setting names, each with a line of the code that makes it
choices <- list(
  response_presence    = c("R/tune_run.R", "d$U <- as.integer(d$present)"),
  population_gate      = c("R/tune_run.R", "d[d$in_range %in% TRUE & d$status != \"blocked\", , drop = FALSE]"),
  cloglog_link         = c("R/tune_score.R", "fam <- stats::binomial(link = \"cloglog\")"),
  log_area_free        = c("R/tune_score.R", "nuis <- c(\"log_area\", \"data_set\", \"era\")"),
  one_outcome_groups   = c("R/tune_score.R", "any(x == 1L) && any(x == 0L)"),
  stratified_folds     = c("R/tune_score.R", "w <- names(cnt)[order(-cnt, stats::runif(length(cnt)))]"),
  heldout_intercept    = c("R/tune_score.R", "b <- stats::uniroot(slope, c(-max(eta) - 30, -min(eta) + 30)"),
  prob_clamp           = c("R/tune_score.R", "pmin(pmax(fam$linkinv(eta + b), 1e-12), 1 - 1e-12)"),
  fallback_no_prior    = c("R/tune_score.R", "if (is.null(m) || m$fallback) {"),
  unseen_reference     = c("R/tune_score.R", "cols <- intersect(colnames(Xh), colnames(X))"),
  se_formula           = c("R/tune_score.R", "se <- sqrt(length(ix)) * apply(M - M[, best], 2, stats::sd)"),
  pick_nearest_default = c("R/tune_score.R", "rr <- rr[order(dep[rr], s$tot[col[rr]])]"),
  honest_nesting       = c("R/tune_score.R", "pk_k <- .tune_pick(.tune_sel(sw$Sw, out_k)"),
  boot_no_refit        = c("R/tune_score.R", "s <- .tune_sel(sw$Sw, sample.int(nw, nw, replace = TRUE))"),
  curve_group_effect   = c("R/tune_curve.R", "\"+ s(wsg, bs = 're')\""),
  curve_unseen_mode    = c("R/tune_curve.R", "lv[!lv %in% levels(tr[[t]])] <- names(which.max(table(tr[[t]])))"),
  curve_reference      = c("R/tune_curve.R", "ref <- list(log_area = stats::median(dd$log_area),"),
  grade_gate           = c("R/tune_run.R", "cv$heldout >= rec$null_heldout_curve"),
  grade_average_group  = c("R/grade.R", "exclude = \"s(wsg)\"")
)

md_path <- Sys.getenv("MD", "research/bayesian_alignment.md")
zot <- path.expand(Sys.getenv("ZOTERO_DIR", "~/Zotero"))
if (!nzchar(Sys.which("pdftotext"))) stop("pdftotext is needed", call. = FALSE)
md <- readLines(md_path, warn = FALSE, encoding = "UTF-8")
log <- character()
say <- function(...) {
  x <- paste0(...)
  cat(x, "\n", sep = "")
  log <<- c(log, x)
}
fail <- 0L
bad <- function(...) {
  say("FAIL ", ...)
  fail <<- fail + 1L
}

# ---- text, as scripts/0280 cleans it
clean <- function(x) {
  x <- chartr("‘’‚′`“”„″", "''''\"\"\"\"\"", x)
  x <- gsub("[‐-―−]", "-", x)
  x <- gsub("[­​-‍﻿]", "", x)
  x <- gsub("ﬀ", "ff", x); x <- gsub("ﬁ", "fi", x); x <- gsub("ﬂ", "fl", x)
  x <- gsub("ﬃ", "ffi", x); x <- gsub("ﬄ", "ffl", x)
  tolower(x)
}
tokens <- function(x) regmatches(x, gregexpr("[0-9]+(?:[.,][0-9]+)*|[[:alpha:]]+", x, perl = TRUE))[[1]]
# the page's tokens in two readings: line-end hyphens between letters joined, and kept
page_tokens <- function(txt) {
  x <- clean(paste(txt, collapse = "\n"))
  list(tokens(gsub("([[:alpha:]])-[ \t]*\n[ \t]*([[:alpha:]])", "\\1\\2", x, perl = TRUE)), tokens(x))
}
# where `q` sits contiguous in `p` at or after position `from`, or NA
seq_at <- function(q, p, from = 1L) {
  n <- length(q)
  if (!n || length(p) < n) return(NA_integer_)
  for (i in which(p == q[1])) {
    if (i < from || i + n - 1L > length(p)) next
    if (identical(p[i:(i + n - 1L)], q)) return(i)
  }
  NA_integer_
}
page_text <- function(key, p) {
  b <- books[[key]]
  pdf <- file.path(zot, "storage", b$file)
  if (!file.exists(pdf)) stop("no PDF for ", key, " under ZOTERO_DIR/storage", call. = FALSE)
  pp <- p + b$offset
  txt <- system2("pdftotext", c("-layout", "-enc", "UTF-8", "-f", pp, "-l", pp, shQuote(pdf), "-"), stdout = TRUE)
  if (!is.null(attr(txt, "status"))) stop("pdftotext failed on ", key, " page ", p, call. = FALSE)
  # the folio, in the running head or at the foot, past BDA3's one-line notice of its free electronic edition
  lines <- grep("electronic edition", txt[nzchar(trimws(txt))], value = TRUE, invert = TRUE)
  ends <- trimws(c(utils::head(lines, 1), utils::tail(lines, 1)))
  list(txt = txt, folio = any(grepl(paste0("(^|\\s)", p, "(\\s|$)"), ends)))
}

# ---- quotes
keys_rx <- paste(names(books), collapse = "|")
anyq <- grep(paste0('"[^"]{3,}"\\s*\\((', keys_rx, '|[A-Za-z]+[0-9]{4}[A-Za-z_]*),\\s*pp?\\.'), md, perl = TRUE)
for (i in setdiff(anyq, grep("^>", md))) bad("line ", i, ": a quote outside a blockquote line, which nothing checks")
rx <- '^>\\s*"(.+)"\\s*\\(([A-Za-z0-9_]+),\\s*pp?\\.\\s*([0-9]+)(?:\\s*[-–]\\s*([0-9]+))?\\)\\s*$'
ql <- grep('^>\\s*"', md, perl = TRUE)
say("quotes: ", length(ql), " blockquote lines in ", md_path)
for (i in ql) {
  m <- regmatches(md[i], regexec(rx, md[i], perl = TRUE))[[1]]
  if (!length(m)) {
    bad("line ", i, ": a quote not in the form > \"...\" (<citekey>, p. N)")
    next
  }
  key <- m[3]
  p1 <- as.integer(m[4])
  p2 <- if (nzchar(m[5])) as.integer(m[5]) else p1
  if (!key %in% names(books)) {
    bad("line ", i, ": ", key, " is not a book this check holds")
    next
  }
  if (p2 < p1 || p2 > p1 + 1L) {
    bad("line ", i, ": pages ", p1, "-", p2, " are not one page or two running on")
    next
  }
  pgs <- lapply(seq(p1, p2), function(p) page_text(key, p))
  folio <- all(vapply(pgs, `[[`, logical(1), "folio"))
  hay <- page_tokens(unlist(lapply(pgs, `[[`, "txt")))
  frags <- lapply(strsplit(clean(m[2]), "…|\\.\\.\\.")[[1]], tokens)
  frags <- frags[lengths(frags) > 0L]
  short <- any(lengths(frags) < frag_min)
  found <- any(vapply(hay, function(h) {
    at <- 1L
    for (f in frags) {
      j <- seq_at(f, h, at)
      if (is.na(j)) return(FALSE)
      at <- j + length(f)
    }
    TRUE
  }, logical(1)))
  ok <- found && folio && !short
  why <- c(if (!folio) "the page's head or foot does not carry its number",
           if (short) paste0("a fragment under ", frag_min, " words"),
           if (!found) "passage not on the page")
  if (ok) say("ok   line ", i, " ", key, " p. ", p1, if (p2 != p1) paste0("-", p2))
  else bad("line ", i, " ", key, " p. ", p1, if (p2 != p1) paste0("-", p2), ": ", paste(why, collapse = "; "))
}

# ---- coverage
# the table rows under one `##` heading, as cells, the header and separator rows left out
table_rows <- function(heading) {
  h <- which(md == paste("##", heading))
  if (length(h) != 1L) {
    bad("the heading \"## ", heading, "\" appears ", length(h), " times")
    return(list())
  }
  nxt <- grep("^## ", md)
  end <- c(nxt[nxt > h], length(md) + 1L)[1] - 1L
  r <- grep("^\\|", md[seq.int(h + 1L, end)], value = TRUE)
  r <- r[!grepl("^\\|[\\s:|-]+\\|?\\s*$", r, perl = TRUE)]
  lapply(r[-1], function(x) trimws(strsplit(sub("^\\|", "", sub("\\|\\s*$", "", x)), "|", fixed = TRUE)[[1]]))
}
check_table <- function(heading, want, id_of) {
  rows <- table_rows(heading)
  ids <- vapply(rows, function(x) id_of(x[1]), character(1))
  vd <- vapply(rows, function(x) gsub("\\*", "", tolower(x[length(x)])), character(1))
  for (k in want[!want %in% ids]) bad(heading, ": no row for ", k)
  for (k in unique(ids[duplicated(ids)])) bad(heading, ": ", k, " has more than one row")
  for (k in setdiff(ids, want)) bad(heading, ": ", k, " is not one of the method's")
  for (j in which(!vd %in% verdicts)) bad(heading, ": ", ids[j], "'s last cell is not one verdict")
  say(heading, ": ", length(rows), " rows for ", length(want), "; ", paste(names(table(vd)), table(vd), sep = " ", collapse = ", "))
}
unbacktick <- function(x) sub("^`([^`]+)`$", "\\1", x)
pipe <- utils::read.csv("inst/method/pipeline.csv", stringsAsFactors = FALSE)
sets <- utils::read.csv("inst/method/settings.csv", stringsAsFactors = FALSE)
check_table("The steps", as.character(pipe$step), identity)
check_table("The settings", sets$key, function(x) if (grepl("^`[^`]+`$", x)) unbacktick(x) else x)
check_table("Choices with no settings key", names(choices), function(x) if (grepl("^`[^`]+`$", x)) unbacktick(x) else x)
for (k in names(choices)) {
  src <- readLines(choices[[k]][1], warn = FALSE)
  if (!any(grepl(choices[[k]][2], src, fixed = TRUE))) bad("choice ", k, ": its anchor is no longer in ", choices[[k]][1])
}
say(if (fail) paste0("FAILED: ", fail, " problems") else "PASS")

if (!nzchar(Sys.getenv("MD"))) {
  out <- file.path("scripts", "logs", "habitat", paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_bayesian_alignment_check.txt"))
  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  writeLines(log, out)
}
if (fail) quit(status = 1L)
