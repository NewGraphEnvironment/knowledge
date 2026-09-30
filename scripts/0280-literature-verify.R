# scripts/0280-literature-verify.R
# ---------------------------------------------------------------------------
# Gate for data/literature_evidence.csv: every cited value is checked against
# the PDF it cites, in the NGE group library.
#
#   Rscript scripts/0280-literature-verify.R          (from the repo root)
#   EVIDENCE=<csv> LOG=<csv> to check a draft table without touching the committed log
#
# WHY: the table is hand-built, much of it ported from another review, and a
# quote that is not in its source is worse than no quote. A row passes only when:
#   - it reads through knw_literature_read() (schema and vocabularies);
#   - its citation key names exactly one live item in the group library, with a
#     PDF on disk. The key is resolved HERE, inside the group, rather than through
#     cred::crd_zot_src_lookup(): that takes the newest attachment for a key from
#     any library, and one citation key names different papers in two libraries;
#   - its quote is found in that PDF's text. How depends on `quote_source`:
#       text  - the quote, normalized, occurs in the text (fragments split at an
#               ellipsis or a [bracketed insert] must occur in order);
#       table - every number in the quote occurs on one PDF page (a transcribed
#               table cell has no running text to match);
#       ocr   - as `text`, against an OCR of the PDF (a scan with no text layer),
#               falling back to a 10 % fuzzy match that is reported as such.
# It also checks that the timing table's `source` keys resolve in the group,
# and that every species x model parameter in COVERAGE has at least one row
# (a value, or a `none` row saying what was searched).
#
# Normalization, applied to quote and PDF text alike: NFKC (ligatures, no-break
# space), curly quotes and primes to straight, every dash and the minus sign to
# "-", soft hyphens and zero-width characters dropped, line-end hyphenation both
# joined and kept, whitespace collapsed, spaces beside punctuation dropped,
# lower case. pdftotext runs in reading order, not -layout, which interleaves
# two-column pages.
#
# INPUT   data/literature_evidence.csv, data/life_history_timing.csv,
#         ~/Zotero/zotero.sqlite (a checked copy; Zotero locks the live file)
# OUTPUT  scripts/logs/habitat/<yyyymmdd>_literature_verify.csv, one row per
#         evidence row (status, PDF file, PDF page); a summary on stdout.
#         OCR text is cached in data/rag/ocr/ (gitignored), keyed by PDF md5.
#         Exits non-zero when any row, timing source or coverage cell fails.
# ---------------------------------------------------------------------------
pkgload::load_all("pkg", quiet = TRUE)   # the source tree, not an installed copy

group_id <- Sys.getenv("GROUP_ID", "4733734")
evidence_path <- Sys.getenv("EVIDENCE", "data/literature_evidence.csv")
ocr_dir <- file.path("data", "rag", "ocr")
COVERAGE <- list(
  species = c("CH", "BT"),
  parameter = c("spawn_gradient_max", "spawn_gradient_min", "spawn_channel_width_min",
                "spawn_mad_min", "rear_gradient_max", "rear_channel_width_min", "rear_mad_min",
                "rear_lake_ha_min", "rear_wetland_ha_min", "access_gradient_max",
                "cluster_bridge_gradient", "cluster_bridge_distance"))

ev <- knw_literature_read(evidence_path)

# --- Zotero: a whole copy of the database -----------------------------------
# Keep a copy only when nothing wrote to the live file meanwhile: mtime and size are
# unchanged across the copy, no transaction is open (rollback journal absent or its
# header zeroed, before and after), and the copy passes quick_check. Zotero runs in
# exclusive locking mode, where SQLite does not bump the header change counter per
# commit, so that counter is no guard (same rule as 0270's db()).
snapshot <- function(tries = 6, wait = 15) {
  live <- path.expand("~/Zotero/zotero.sqlite")
  journal <- paste0(live, "-journal")
  snap <- tempfile(fileext = ".sqlite")
  state <- function() {
    info <- file.info(live)
    open_txn <- file.exists(journal) && file.size(journal) >= 8 &&
      any(readBin(journal, "raw", 8) != as.raw(0))
    list(mtime = as.numeric(info$mtime), size = info$size, open_txn = open_txn)
  }
  for (i in seq_len(tries)) {
    before <- state()
    file.copy(live, snap, overwrite = TRUE)
    if (!identical(state(), before) || before$open_txn) {
      Sys.sleep(wait)
      next
    }
    con <- DBI::dbConnect(RSQLite::SQLite(), snap)
    ok <- tryCatch(DBI::dbGetQuery(con, "PRAGMA quick_check")[[1]][1] == "ok",
                   error = function(e) FALSE)
    if (ok) return(con)
    DBI::dbDisconnect(con)
    Sys.sleep(wait)
  }
  stop("no consistent copy of zotero.sqlite after ", tries, " tries; is Zotero mid-sync?")
}
con <- snapshot()
lib <- DBI::dbGetQuery(con, "SELECT libraryID FROM groups WHERE groupID = ?",
                       params = list(as.integer(group_id)))$libraryID
stopifnot("group not in this Zotero database" = length(lib) == 1)
group_items <- DBI::dbGetQuery(con, "
  SELECT idv.value AS citation_key, i.itemID
  FROM items i
  JOIN itemData id ON id.itemID = i.itemID JOIN itemDataValues idv ON idv.valueID = id.valueID
  JOIN fields f ON f.fieldID = id.fieldID
  LEFT JOIN deletedItems d ON d.itemID = i.itemID
  WHERE f.fieldName = 'citationKey' AND i.libraryID = ? AND d.itemID IS NULL",
  params = list(lib))
group_pdfs <- DBI::dbGetQuery(con, "
  SELECT ia.parentItemID AS itemID, a.key AS att_key, ia.path
  FROM itemAttachments ia JOIN items a ON a.itemID = ia.itemID
  LEFT JOIN deletedItems d ON d.itemID = a.itemID
  WHERE a.libraryID = ? AND d.itemID IS NULL AND ia.contentType = 'application/pdf'
    AND ia.linkMode IN (0, 1) AND ia.path LIKE 'storage:%'", params = list(lib))
group_pdfs$file <- file.path(path.expand("~/Zotero/storage"), group_pdfs$att_key,
                             sub("^storage:", "", group_pdfs$path))
group_pdfs <- group_pdfs[file.exists(group_pdfs$file), ]
DBI::dbDisconnect(con)

resolve <- function(key) {
  ids <- group_items$itemID[group_items$citation_key == key]
  if (length(ids) == 0) return(list(status = "key_not_in_group"))
  if (length(ids) > 1) return(list(status = "key_ambiguous_in_group"))
  files <- group_pdfs$file[group_pdfs$itemID == ids]
  if (length(files) == 0) return(list(status = "no_pdf_in_group"))
  list(status = "ok", files = sort(files))
}

# --- text ---------------------------------------------------------------------
norm <- function(x) {
  x <- stringi::stri_trans_nfkc(x)
  x <- gsub("[‘’‚′`]", "'", x)
  x <- gsub("[“”„″]", "\"", x)
  x <- gsub("[‐-―−]", "-", x)
  x <- gsub("[­​-‍﻿]", "", x)
  x <- gsub("[º˚]", "°", x)
  x <- gsub("\\s+", " ", tolower(x))
  x <- gsub(" ?([-%,.;:()/]) ?", "\\1", x)
  trimws(x)
}

# Pages of a PDF, each as two normalized variants: a line-end hyphen between two
# letters joined ("habi-\ntat" -> "habitat"), and every line-end hyphen kept
# ("spawning-\nrearing", and "2-\n4 %" -> "2-4%": digits are never joined).
pdf_pages <- local({
  cache <- new.env()
  function(file, ocr = FALSE, layout = FALSE) {
    id <- paste0(if (ocr) "ocr:" else if (layout) "layout:" else "", file)
    if (!is.null(cache[[id]])) return(cache[[id]])
    raw <- if (ocr) ocr_text(file) else
      paste(system2("pdftotext", c("-q", "-enc", "UTF-8", if (layout) "-layout", shQuote(file), "-"),
                    stdout = TRUE, stderr = FALSE), collapse = "\n")
    Encoding(raw) <- "UTF-8"
    pages <- strsplit(raw, "\f", fixed = TRUE)[[1]]
    out <- list(joined = norm(gsub("([[:alpha:]])-[ \t]*\n[ \t]*([[:alpha:]])", "\\1\\2", pages,
                                   perl = TRUE)),
                kept = norm(gsub("-[ \t]*\n[ \t]*", "-", pages)))
    cache[[id]] <- out
    out
  }
})

ocr_text <- function(file) {
  dir.create(ocr_dir, recursive = TRUE, showWarnings = FALSE)
  side <- file.path(ocr_dir, paste0(unname(tools::md5sum(file)), ".txt"))
  if (!file.exists(side)) {
    # ocrmypdf and tesseract work in TMPDIR. Use a directory inside the (gitignored) OCR
    # cache: R's tempdir() is under /tmp, which tesseract could not read in a sandboxed
    # shell, and the OCR failed there.
    work <- file.path(ocr_dir, "work")
    dir.create(work, showWarnings = FALSE)
    on.exit(unlink(work, recursive = TRUE), add = TRUE)
    tmp_pdf <- file.path(work, "out.pdf")
    rc <- system2("ocrmypdf", c("-q", "--force-ocr", "--sidecar", shQuote(side), shQuote(file),
                                shQuote(tmp_pdf)), stdout = FALSE, stderr = FALSE,
                  env = paste0("TMPDIR=", shQuote(normalizePath(work))))
    if (rc != 0 || !file.exists(side)) stop("ocrmypdf failed on ", file)
  }
  paste(readLines(side, encoding = "UTF-8", warn = FALSE), collapse = "\n")
}

MIN_FRAG <- 12      # normalized characters in every fragment of a text quote
MAX_GAP <- 2000     # characters allowed between consecutive fragments
NUMBER_WORDS <- c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
                  "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth",
                  "ninth", "tenth")

# A fragment as a regex: literal text, and a number at either edge may not continue
# into more digits ("13" must not match "13.2").
frag_pattern <- function(f) {
  p <- gsub("([][{}()*+?.\\\\^$|])", "\\\\\\1", f)
  # A dot blocks only as a decimal point: normalization closes "interest. 25%" up to
  # "interest.25%", and that 25 is a whole number.
  if (grepl("^[0-9]", f)) p <- paste0("(?<![0-9])(?<![0-9]\\.)", p)
  if (grepl("[0-9]$", f)) p <- paste0(p, "(?![0-9]|\\.[0-9])")
  p
}

# Fragments of a quote, split at an ellipsis or a [bracketed insert]. NULL when the
# quote has no fragment or one too short to mean anything on its own.
fragments <- function(quote) {
  f <- strsplit(quote, "\\s*(\\.\\.\\.|\u2026|\\[[^]]*\\])\\s*")[[1]]
  f <- norm(f[nzchar(trimws(f))])
  if (!length(f) || any(nchar(f) < MIN_FRAG)) return(NULL)
  f
}

# Every PDF page on which the whole quote starts: the fragments in order, each within
# MAX_GAP of the one before, searched in the page-joined text so a quote may cross a
# page break. integer(0) when there is no such place.
find_quote <- function(frags, pages) {
  found <- integer(0)
  pats <- vapply(frags, frag_pattern, "")
  for (v in c("joined", "kept")) {
    txt <- pages[[v]]
    starts <- cumsum(c(1, nchar(txt) + 1))[seq_along(txt)]
    all_text <- paste(txt, collapse = " ")
    first <- gregexpr(pats[1], all_text, perl = TRUE)[[1]]
    if (first[1] < 0) next
    for (i in seq_along(first)) {
      at <- first[i] + attr(first, "match.length")[i]
      ok <- TRUE
      for (p in pats[-1]) {
        window <- substring(all_text, at, min(nchar(all_text), at + MAX_GAP + 500))
        m <- regexpr(p, window, perl = TRUE)
        if (m < 0 || m - 1 > MAX_GAP) { ok <- FALSE; break }
        at <- at + m - 1 + attr(m, "match.length")
      }
      if (ok) found <- c(found, max(which(starts <= first[i])))
    }
  }
  sort(unique(found))
}

numbers_in <- function(x) regmatches(x, gregexpr("[0-9]+(\\.[0-9]+)?", x))[[1]]
words_in <- function(x) {
  w <- regmatches(x, gregexpr("[[:alpha:]]{3,}", x))[[1]]
  unique(w)
}

# A table row has no running text to match. `pdftotext -layout` keeps a table row on
# one line (reading order often emits a table column by column), so a row's tokens
# (whole numbers, and words of two letters or more) must occur in the quote's order,
# each within TABLE_GAP characters of the one before, on one page of the layout text.
# A bag of tokens is not enough: "High", "Substrate" and small numbers occur on most
# pages of a habitat report, and a fabricated cell built from them passed.
TABLE_GAP <- 80
table_pages <- function(quote, pages) {
  q <- norm(quote)
  toks <- regmatches(q, gregexpr("[0-9]+(\\.[0-9]+)?|[[:alpha:]]{2,}", q))[[1]]
  if (!any(grepl("^[0-9]", toks)) || !any(grepl("^[[:alpha:]]", toks)) || length(toks) < 3) {
    return(NULL)
  }
  pats <- vapply(toks, frag_pattern, "")
  in_order <- function(pg) {
    first <- gregexpr(pats[1], pg, perl = TRUE)[[1]]
    if (first[1] < 0) return(FALSE)
    for (i in seq_along(first)) {
      at <- first[i] + attr(first, "match.length")[i]
      ok <- TRUE
      for (p in pats[-1]) {
        m <- regexpr(p, substring(pg, at, min(nchar(pg), at + TABLE_GAP + 50)), perl = TRUE)
        if (m < 0 || m - 1 > TABLE_GAP) { ok <- FALSE; break }
        at <- at + m - 1 + attr(m, "match.length")
      }
      if (ok) return(TRUE)
    }
    FALSE
  }
  which(vapply(seq_along(pages$kept), function(i) in_order(pages$joined[i]) || in_order(pages$kept[i]),
               TRUE))
}

# The fuzzy OCR tier forgives recognition noise in letters, never in what a row cites:
# every number and number word of the quote must still occur exactly on the page.
fuzzy_pages <- function(quote, pages) {
  q <- norm(quote)
  nums <- numbers_in(q)
  nw <- intersect(words_in(q), NUMBER_WORDS)
  which(vapply(pages$joined, function(p) {
    agrepl(q, p, max.distance = 0.1, fixed = TRUE) && all(nums %in% numbers_in(p)) &&
      all(nw %in% words_in(p))
  }, TRUE))
}

# Each value must be in its own quote: a number in it, or that number rescaled by a
# power of ten (proportion vs percent, cm vs mm, km vs m), or an ordinal written as a
# word (stream order). A timing value's month must be named in the quote.
value_in_quote <- function(r) {
  vals <- c(r$value_min, r$value_max)
  vals <- vals[!is.na(vals)]
  if (!length(vals)) return(TRUE)
  q <- norm(r$quote)
  if (r$variable == "timing") {
    m <- as.integer(substr(vals, 1, 2))
    return(all(vapply(m, function(k) grepl(tolower(month.abb[k]), q, fixed = TRUE), TRUE)))
  }
  have <- as.numeric(numbers_in(q))
  # number words anywhere in a word: text layers fuse them ("fourthorder")
  words <- which(vapply(NUMBER_WORDS, grepl, TRUE, q, fixed = TRUE))
  have <- c(have, ((words - 1) %% 10) + 1)
  ok_set <- unique(c(outer(have, 10^(-3:3))))
  all(vapply(as.numeric(vals), function(v) any(abs(ok_set - v) < 1e-9 * max(1, abs(v))), TRUE))
}

check_row <- function(r) {
  fail <- function(status, file = NA) list(status = status, file = file, pages = NA)
  if (r$kind == "none") return(fail("none_row"))
  res <- resolve(r$citation_key)
  if (res$status != "ok") return(fail(res$status))
  if (r$quote_source != "table" && is.null(fragments(r$quote))) return(fail("quote_fragment_too_short"))
  if (!value_in_quote(r)) return(fail("value_not_in_quote"))
  for (f in res$files) {
    pages <- pdf_pages(f, ocr = r$quote_source == "ocr", layout = r$quote_source == "table")
    pg <- if (r$quote_source == "table") table_pages(r$quote, pages) else
      find_quote(fragments(r$quote), pages)
    if (is.null(pg)) return(fail("table_quote_needs_numbers_and_words"))  # and 3+ tokens
    status <- paste0("verified_", r$quote_source)
    if (!length(pg) && r$quote_source == "ocr") {
      pg <- fuzzy_pages(r$quote, pages)
      status <- "verified_ocr_fuzzy"
    }
    if (length(pg)) return(list(status = status, file = basename(f), pages = paste(pg, collapse = ";")))
  }
  fail("quote_not_found", paste(basename(res$files), collapse = "; "))
}

res <- lapply(seq_len(nrow(ev)), function(i) check_row(ev[i, ]))
out <- data.frame(
  data_row = seq_len(nrow(ev)), species_code = ev$species_code, parameter = ev$parameter,
  variable = ev$variable, citation_key = ev$citation_key, quote_source = ev$quote_source,
  status = vapply(res, `[[`, "", "status"),
  pdf_file = vapply(res, function(x) as.character(x$file), ""),
  pdf_pages = vapply(res, function(x) as.character(x$pages), ""))
pass <- out$status %in% c("none_row", "verified_text", "verified_table", "verified_ocr",
                          "verified_ocr_fuzzy")

# --- timing sources and coverage ---------------------------------------------
timing <- knw_timing_read("data/life_history_timing.csv")
t_keys <- unique(trimws(unlist(strsplit(timing$source[!is.na(timing$source)], ";"))))
t_bad <- t_keys[!t_keys %in% group_items$citation_key]
cov <- expand.grid(species_code = COVERAGE$species, parameter = COVERAGE$parameter,
                   stringsAsFactors = FALSE)
cov$rows <- mapply(function(s, p) sum(ev$species_code == s & ev$parameter %in% p),
                   cov$species_code, cov$parameter)

log_csv <- Sys.getenv("LOG", file.path("scripts", "logs", "habitat",
                                      paste0(format(Sys.Date(), "%Y%m%d"), "_literature_verify.csv")))
dir.create(dirname(log_csv), recursive = TRUE, showWarnings = FALSE)
utils::write.csv(out, log_csv, row.names = FALSE, na = "")

cat(sprintf("%d rows | %s\n", nrow(out),
            paste(names(table(out$status)), table(out$status), sep = " ", collapse = " | ")))
if (any(!pass)) print(out[!pass, c("data_row", "citation_key", "quote_source", "status", "pdf_file")],
                      row.names = FALSE)
cat(sprintf("timing sources: %d keys, %d unresolved in the group%s\n", length(t_keys), length(t_bad),
            if (length(t_bad)) paste0(": ", paste(t_bad, collapse = ", ")) else ""))
cat(sprintf("coverage: %d of %d species x parameter cells have a row\n", sum(cov$rows > 0), nrow(cov)))
if (any(cov$rows == 0)) print(cov[cov$rows == 0, c("species_code", "parameter")], row.names = FALSE)
cat("wrote", log_csv, "\n")
if (any(!pass) || length(t_bad) || any(cov$rows == 0)) quit(status = 1)
