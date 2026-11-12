# data-raw/bayesian_alignment_check.R
# ---------------------------------------------------------------------------
# Does research/bayesian_alignment.md quote its books truly, and does it give every step and setting of the method a
# verdict? Issue #185.
#
# QUOTES. Every quoted passage is written on its own blockquote line as
#   > "<passage>" (<citekey>, p. N)       or  (<citekey>, pp. N–M) for one that runs onto the next page
# and is looked for on printed page N (to M) of that book's PDF, the group library's own attachment. A printed page is
# the PDF page less the book's front matter (`offset`), and the PDF page's running head must carry N, so a wrong
# offset fails rather than reading a neighbouring page. Both sides are lower-cased and cut to letters and digits
# before matching, because the PDFs' text loses most word spaces ("sothisisjustlikeaddingapredictor") and splits
# words at line ends; an ellipsis (… or ...) in a passage splits it into fragments that must appear in order.
# COVERAGE. Every step of inst/method/pipeline.csv is a row of the steps table (first cell its number) and every key
# of inst/method/settings.csv a row of the settings table (first cell the key in backticks), and each such row names
# one verdict: aligned, differs, should change, or no bearing.
#
# INPUT:  research/bayesian_alignment.md; inst/method/{pipeline,settings}.csv; the two PDFs under ZOTERO_DIR/storage
#         (default ~/Zotero), by the attachment keys below (group library 4733734, resolved 2026-11-11)
# OUTPUT: scripts/logs/habitat/<yyyymmdd>_bayesian_alignment_check.txt; exits 1 on any failure
# RUN:    Rscript data-raw/bayesian_alignment_check.R   (from the repo root; needs pdftotext)
# ---------------------------------------------------------------------------
options(warn = 1)

books <- list(
  mcelreath2020StatisticalRethinking = list(
    file = "PVGNFJC9/McElreath - 2020 - Statistical Rethinking - A Bayesian Course with Ex.pdf", offset = 16L),
  gelman_etal2013Bayesiandata = list(file = "JP3BM8T9/BDA3.pdf", offset = 10L)
)
verdicts <- c("aligned", "differs", "should change", "no bearing")
md_path <- Sys.getenv("MD", "research/bayesian_alignment.md")
zot <- path.expand(Sys.getenv("ZOTERO_DIR", "~/Zotero"))
if (!nzchar(Sys.which("pdftotext"))) stop("pdftotext is needed", call. = FALSE)

md <- readLines(md_path, warn = FALSE)
log <- character()
say <- function(...) {
  x <- paste0(...)
  cat(x, "\n", sep = "")
  log <<- c(log, x)
}
fail <- 0L

norm <- function(x) {
  x <- tolower(x)
  x <- gsub("ﬁ", "fi", x); x <- gsub("ﬂ", "fl", x); x <- gsub("ﬀ", "ff", x)
  x <- gsub("ﬃ", "ffi", x); x <- gsub("ﬄ", "ffl", x)
  gsub("[^a-z0-9]", "", x)
}

page_text <- function(key, p) {
  b <- books[[key]]
  pdf <- file.path(zot, "storage", b$file)
  if (!file.exists(pdf)) stop("no PDF for ", key, " under ZOTERO_DIR/storage", call. = FALSE)
  pp <- p + b$offset
  txt <- system2("pdftotext", c("-layout", "-enc", "UTF-8", "-f", pp, "-l", pp, shQuote(pdf), "-"), stdout = TRUE)
  if (!is.null(attr(txt, "status"))) stop("pdftotext failed on ", key, " page ", p, call. = FALSE)
  # the running head, below BDA3's one-line notice of its free electronic edition
  head <- grep("electronic edition", txt[nzchar(trimws(txt))], value = TRUE, invert = TRUE)[1]
  list(text = paste(txt, collapse = " "), head_ok = !is.na(head) && grepl(paste0("(^|\\s)", p, "(\\s|$)"), trimws(head)))
}

# ---- quotes
rx <- '^>\\s*"(.+)"\\s*\\(([A-Za-z0-9_]+),\\s*pp?\\.\\s*([0-9]+)(?:\\s*[-–]\\s*([0-9]+))?\\)\\s*$'
ql <- grep('^>\\s*"', md, perl = TRUE)
say("quotes: ", length(ql), " blockquote lines in ", md_path)
for (i in ql) {
  m <- regmatches(md[i], regexec(rx, md[i], perl = TRUE))[[1]]
  if (!length(m)) {
    say("FAIL line ", i, ": a quote not in the form > \"...\" (<citekey>, p. N)")
    fail <- fail + 1L
    next
  }
  key <- m[3]
  p1 <- as.integer(m[4])
  p2 <- if (nzchar(m[5])) as.integer(m[5]) else p1
  if (!key %in% names(books)) {
    say("FAIL line ", i, ": ", key, " is not a book this check holds")
    fail <- fail + 1L
    next
  }
  pgs <- lapply(seq(p1, p2), function(p) page_text(key, p))
  heads <- vapply(pgs, `[[`, logical(1), "head_ok")
  hay <- norm(paste(vapply(pgs, `[[`, character(1), "text"), collapse = " "))
  frags <- norm(strsplit(m[2], "…|\\.\\.\\.")[[1]])
  frags <- frags[nzchar(frags)]
  pos <- 0L
  found <- TRUE
  for (f in frags) {
    at <- regexpr(f, substring(hay, pos + 1L), fixed = TRUE)
    if (at < 0) { found <- FALSE; break }
    pos <- pos + at + nchar(f) - 1L
  }
  ok <- found && all(heads)
  if (!ok) fail <- fail + 1L
  say(if (ok) "ok   " else "FAIL ", "line ", i, " ", key, " p. ", p1, if (p2 != p1) paste0("-", p2),
      if (!all(heads)) " (running head does not carry the page)" else "",
      if (!found) " (passage not on the page)" else "")
}

# ---- coverage
rows <- grep("^\\|", md, value = TRUE)
cell1 <- trimws(sub("^\\|([^|]*)\\|.*$", "\\1", rows))
has_verdict <- function(r) {
  v <- vapply(verdicts, function(w) grepl(paste0("\\b", w, "\\b"), tolower(r)), logical(1))
  sum(v) >= 1L
}
pipe <- utils::read.csv("inst/method/pipeline.csv", stringsAsFactors = FALSE)
sets <- utils::read.csv("inst/method/settings.csv", stringsAsFactors = FALSE)
for (s in pipe$step) {
  r <- rows[cell1 == as.character(s)]
  if (length(r) != 1L || !has_verdict(r)) {
    say("FAIL step ", s, ": ", length(r), " rows", if (length(r) == 1L) ", with no verdict" else "")
    fail <- fail + 1L
  }
}
for (k in sets$key) {
  r <- rows[cell1 == paste0("`", k, "`")]
  if (length(r) != 1L || !has_verdict(r)) {
    say("FAIL setting ", k, ": ", length(r), " rows", if (length(r) == 1L) ", with no verdict" else "")
    fail <- fail + 1L
  }
}
say("coverage: ", nrow(pipe), " steps and ", nrow(sets), " settings checked")
say(if (fail) paste0("FAILED: ", fail, " problems") else "PASS")

out <- file.path("scripts", "logs", "habitat", paste0(format(Sys.time(), "%Y%m%d", tz = "UTC"), "_bayesian_alignment_check.txt"))
dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
writeLines(log, out)
if (fail) quit(status = 1L)
