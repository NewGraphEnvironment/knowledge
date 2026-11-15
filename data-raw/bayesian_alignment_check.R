# data-raw/bayesian_alignment_check.R
# ---------------------------------------------------------------------------
# Does research/bayesian_alignment.md quote its books truly, and does it give every step, setting and unkeyed choice
# of the method one verdict? Issue #185. And does vignettes/tuning-bayesian-practice.Rmd, the article that states the
# review's findings (#204), quote them truly? (MD=vignettes/tuning-bayesian-practice.Rmd: its quotes only.)
#
# QUOTES. A quoted passage is checked when it is written
#   "<passage>" (<citekey>, p. N)       or  (<citekey>, pp. N–M) for one that runs onto the next page
# or, in the article, pandoc's form "<passage>" [@<citekey>, p. N] (one key, its brackets matched),
# on a blockquote line of its own (`> ` before it) or inline in a sentence (it may wrap across lines), and is looked for on printed page N (to M) of that book's PDF, the group library's own attachment. A printed page is
# the PDF page less the book's front matter (`offset`), and the page's running head or foot must carry N, so a wrong
# offset fails rather than reading a neighbouring page. Passage and page are compared as token sequences, as
# scripts/0280 compares them: ligatures spelled out, words and numbers as written ("2" is not "25"), symbols dropped
# (the PDFs set formulae as glyphs pdftotext cannot keep), a line-end hyphen joined in one reading and kept in the
# other. An ellipsis (… or ...) splits a passage into fragments that must appear in order, each of at least
# `frag_min` tokens, and a passage with no word in it fails. Then every checked passage is blanked out (its quote marks
# and words, not its citation) and every page citation in the file is enumerated ("p.", "pp", "pg", "page", a pandoc
# `[@`, with any space after it): a quote mark left within `near` characters of a citation, before or after it, fails.
# A quote mark is a straight or curly double quote, a curly single one, or a straight single quote that is not an
# apostrophe inside a word. So a quote with no checked form of its own, sharing a checked quote's citation or placed
# after its citation, fails; straight quotes say nothing of which one opens, so no pairing of quote marks is trusted.
# And the number of checked quotes must be `n_quotes`, so a quote that slips out of the form, or a reflow that breaks
# one, fails. A page cited without a quote is not checked here: the meaning audit re-reads it.
# COVERAGE. Three tables, each found by its `##` heading: "The steps" (first cell the step number, every step of
# inst/method/pipeline.csv), "The settings" (first cell the key in backticks, every key of inst/method/settings.csv)
# and "Choices with no settings key" (first cell the id in backticks, every id of `choices` below; its second cell,
# `file:line`, must name the anchor's file and the line it stands on, and the anchor must occur once in that file).
# Each row's last cell is exactly one verdict; a missing, duplicate or stale row fails.
#
# ARTICLE. An .Rmd's front matter and fenced chunks are blanked before anything is read, so a chunk's code or a table's
# text is neither a quote nor a quote mark near a citation, and the coverage tables, which are the research file's,
# are not looked for. Each file holds its own count of checked quotes (`n_quotes`).
#
# INPUT:  research/bayesian_alignment.md, or the article (MD=); inst/method/{pipeline,settings}.csv; R/;
#         the two PDFs under ZOTERO_DIR/storage (default ~/Zotero), by the attachment keys below (group library
#         4733734, resolved 2026-11-11 from a guarded copy of zotero.sqlite)
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_bayesian_alignment_check.txt (the research file, no MD= set) or
#         <yyyymmdd>_bayesian_alignment_check-tuning-bayesian-practice.txt (the article); none for any other MD=;
#         exits 1 on any failure
# RUN:    Rscript data-raw/bayesian_alignment_check.R   (from the repo root; needs pdftotext), then again with the
#         article as MD (vignettes/tuning-bayesian-practice.Rmd)
# ---------------------------------------------------------------------------
options(warn = 1)

books <- list(
  mcelreath2020StatisticalRethinking = list(
    file = "PVGNFJC9/McElreath - 2020 - Statistical Rethinking - A Bayesian Course with Ex.pdf", offset = 16L),
  gelman_etal2013Bayesiandata = list(file = "JP3BM8T9/BDA3.pdf", offset = 10L)
)
verdicts <- c("aligned", "differs", "should change", "no bearing")
frag_min <- 4L
near <- 200L      # characters either side of a page citation in which a quote mark makes the page a quote's
# the quotes each file checks; change a count with its file
n_quotes <- c(bayesian_alignment.md = 23L, `tuning-bayesian-practice.Rmd` = 5L)
article <- "vignettes/tuning-bayesian-practice.Rmd"
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
  curve_group_effect   = c("R/tune_curve.R", "fit <- mgcv::gam(stats::as.formula(paste(resp, \"~\", smooths(nuis), \"+ s(wsg, bs = 're')\"))"),
  curve_unseen_mode    = c("R/tune_curve.R", "lv[!lv %in% levels(tr[[t]])] <- names(which.max(table(tr[[t]])))"),
  curve_reference      = c("R/tune_curve.R", "ref <- list(log_area = stats::median(dd$log_area),"),
  grade_gate           = c("R/tune_run.R", "cv$heldout >= rec$null_heldout_curve"),
  grade_average_group  = c("R/grade.R", "exclude = \"s(wsg)\"")
)

md_path <- Sys.getenv("MD", "research/bayesian_alignment.md")
zot <- path.expand(Sys.getenv("ZOTERO_DIR", "~/Zotero"))
if (!nzchar(Sys.which("pdftotext"))) stop("pdftotext is needed", call. = FALSE)
md <- readLines(md_path, warn = FALSE, encoding = "UTF-8")
is_rmd <- grepl("\\.Rmd$", md_path)
if (is_rmd) {
  # front matter and fenced chunks blanked line for line, so line numbers still name the file's lines
  fm <- which(md == "---")
  if (length(fm) >= 2L && fm[1] == 1L) md[fm[1]:fm[2]] <- ""
  fence <- grepl("^\\s*```", md)
  inside <- (cumsum(fence) %% 2L == 1L) | fence
  if (sum(fence) %% 2L) stop("an unclosed code fence in ", md_path, call. = FALSE)
  md[inside] <- ""
}
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
  txt <- gsub("\f", "", txt, fixed = TRUE)   # the page break pdftotext ends a page with
  # the folio, in the running head or at the foot, past BDA3's one-line notice of its free electronic edition
  lines <- grep("electronic edition", txt[nzchar(trimws(txt))], value = TRUE, invert = TRUE)
  ends <- trimws(c(utils::head(lines, 1), utils::tail(lines, 1)))
  list(txt = txt, folio = any(grepl(paste0("(^|\\s)", p, "(\\s|$)"), ends)))
}

# ---- quotes
# the file as one string, line breaks as spaces, so a quote wrapped across lines is one match; `line_at` maps a
# position back to its line
txt <- paste(md, collapse = " ")
ends <- cumsum(nchar(md) + 1L)
line_at <- function(pos) findInterval(pos - 1L, c(0L, ends)) 
sp_rx <- "[\\s\\x{00A0}]"   # a space, a no-break space included, which PCRE's \\s alone does not match
# the citation opens "(" or, in pandoc's form, "[@", and closes to match (checked below)
rx <- paste0('"([^"]+)"', sp_rx, '*(\\(|\\[@)([A-Za-z0-9_]+),', sp_rx, '*pp?\\.', sp_rx, '*([0-9]+)(?:', sp_rx,
             '*[-\u2013]', sp_rx, '*([0-9]+))?(\\)|\\])')
sm <- gregexpr(rx, txt, perl = TRUE)[[1]]
strict <- if (sm[1] > 0) data.frame(start = as.integer(sm), end = as.integer(sm) + attr(sm, "match.length") - 1L,
                                    p_start = attr(sm, "capture.start")[, 1] - 1L,
                                    p_end = attr(sm, "capture.start")[, 1] + attr(sm, "capture.length")[, 1]) else
  data.frame(start = integer(), end = integer(), p_start = integer(), p_end = integer())
# each checked passage blanked out with its two quote marks, character for character; its citation stays, so a quote
# that leans on that citation without being checked still meets it below
masked <- txt
for (k in seq_len(nrow(strict))) {
  substr(masked, strict$p_start[k], strict$p_end[k]) <- strrep(" ", strict$p_end[k] - strict$p_start[k] + 1L)
}
# inline code is code, not a quotation: its quote marks (`bs = "re"`) are blanked too, with letters, so an apostrophe
# after it (`link`'s) still follows a word
cm <- gregexpr("`[^`]*`", masked)[[1]]
for (k in seq_along(cm)) if (cm[k] > 0) substr(masked, cm[k], cm[k] + attr(cm, "match.length")[k] - 1L) <-
  strrep("x", attr(cm, "match.length")[k])
# a straight single quote counts where it opens a word (`'like this`), never after a letter or digit: an apostrophe
# (`BDA3's`, `folds'`, `*k*'s`) is not a quote mark. Marks are found once over the whole text, so a window's edge
# cannot cut an apostrophe from the letter before it
mark_rx <- "[\"\u201C\u201D\u2018]|(?<![[:alnum:]*_])'(?=[[:alnum:]])"
marks <- gregexpr(mark_rx, masked, perl = TRUE)[[1]]
marks <- if (marks[1] > 0) as.integer(marks) else integer()
pg <- gregexpr(paste0("\\b(pp?|pg|pages?)\\.?", sp_rx, "*[0-9]|\\[@"), masked, perl = TRUE)[[1]]
for (st in if (pg[1] > 0) as.integer(pg) else integer()) {
  hit <- marks[abs(marks - st) <= near]
  if (length(hit)) {
    bad("line ", line_at(st), ": a quote mark within ", near, " characters of a page citation, outside the checked form ",
        "(\"...\" (<citekey>, p. N)), at: ", substr(masked, max(1L, hit[1] - 30L), hit[1] + 30L))
  }
}
ms <- regmatches(txt, list(sm))[[1]]
for (k in seq_along(ms)) {
  i <- line_at(strict$start[k])
  m <- regmatches(ms[k], regexec(rx, ms[k], perl = TRUE))[[1]]
  if ((m[3] == "(") != (m[7] == ")")) {
    bad("line ", i, ": the citation opens with ", m[3], " and closes with ", m[7])
    next
  }
  key <- m[4]
  p1 <- as.integer(m[5])
  p2 <- if (nzchar(m[6])) as.integer(m[6]) else p1
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
  frags <- lapply(strsplit(clean(m[2]), "\u2026|\\.\\.\\.")[[1]], tokens)
  frags <- frags[lengths(frags) > 0L]
  empty <- !length(frags)
  short <- any(lengths(frags) < frag_min)
  found <- !empty && any(vapply(hay, function(h) {
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
           if (empty) "the passage has no word in it",
           if (short) paste0("a fragment under ", frag_min, " words"),
           if (!found && !empty) "passage not on the page")
  if (ok) say("ok   line ", i, " ", key, " p. ", p1, if (p2 != p1) paste0("-", p2))
  else bad("line ", i, " ", key, " p. ", p1, if (p2 != p1) paste0("-", p2), ": ", paste(why, collapse = "; "))
}
say("quotes: ", length(ms), " checked in ", md_path)
want <- n_quotes[basename(md_path)]
if (!is.na(want) && length(ms) != want) {
  bad(length(ms), " quotes checked where ", want, " are expected: a quote left the checked form, or one was added ",
      "without changing `n_quotes`")
}
if (!is_rmd) {

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
    invisible(stats::setNames(rows, ids))
  }
  unbacktick <- function(x) sub("^`([^`]+)`$", "\\1", x)
  pipe <- utils::read.csv("inst/method/pipeline.csv", stringsAsFactors = FALSE)
  sets <- utils::read.csv("inst/method/settings.csv", stringsAsFactors = FALSE)
  check_table("The steps", as.character(pipe$step), identity)
  check_table("The settings", sets$key, function(x) if (grepl("^`[^`]+`$", x)) unbacktick(x) else x)
  crows <- check_table("Choices with no settings key", names(choices), function(x) if (grepl("^`[^`]+`$", x)) unbacktick(x) else x)
  for (k in names(choices)) {
    src <- readLines(choices[[k]][1], warn = FALSE)
    at <- which(grepl(choices[[k]][2], src, fixed = TRUE))
    if (length(at) != 1L) {
      bad("choice ", k, ": its anchor occurs ", length(at), " times in ", choices[[k]][1], ", not once")
      next
    }
    if (is.null(crows[[k]])) next
    w <- regmatches(crows[[k]][2], regexec("^`?([^`:]+):([0-9]+)(?:-[0-9]+)?`?$", crows[[k]][2]))[[1]]
    if (!length(w)) {
      bad("choice ", k, ": its second cell is not `file:line`")
    } else if (w[2] != choices[[k]][1] || as.integer(w[3]) != at) {
      bad("choice ", k, ": cites ", w[2], ":", w[3], " but its anchor is at ", choices[[k]][1], ":", at)
    }
  }
}
say(if (fail) paste0("FAILED: ", fail, " problems") else "PASS")

stem <- if (!nzchar(Sys.getenv("MD"))) "" else if (identical(md_path, article)) "-tuning-bayesian-practice" else NA
if (!is.na(stem)) {
  day <- format(Sys.time(), "%Y%m%d", tz = "UTC")
  out <- file.path("scripts", "logs", "habitat", paste0(day, "_bayesian_alignment_check", stem, ".txt"))
  dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
  writeLines(log, out)
}
if (fail) quit(status = 1L)
