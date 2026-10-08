# scripts/0280-literature-verify.R
# ---------------------------------------------------------------------------
# Gate for data/literature_evidence.csv: every cited value is checked against
# the PDF it cites, in the NGE group library.
#
#   Rscript scripts/0280-literature-verify.R          (from the repo root)
#   EVIDENCE=<csv> REGISTRY=<csv> LOG=<csv> to check draft tables without touching
#   the committed logs (the registry log is LOG with "_ip_registry" before ".csv")
#
# WHY: the table is hand-built, much of it ported from another review, and a
# quote that is not in its source is worse than no quote. A row passes only when:
#   - it reads through knw_literature_read() (schema and vocabularies);
#   - its citation key names exactly one live item in the group library, with a
#     PDF on disk. The key is resolved HERE, inside the group, rather than through
#     cred::crd_zot_src_lookup(): that takes the newest attachment for a key from
#     any library, and one citation key names different papers in two libraries;
#   - its quote is found in that PDF, compared token by token (see "text" below).
#     How depends on `quote_source`:
#       text  - the quote's tokens occur contiguously in the text (fragments split
#               at an ellipsis or a [bracketed insert] must occur in order, close
#               together), and it does not stop inside a number or a range;
#       table - on the -layout text, the row's tokens in order and close together,
#               within a few lines of one page (reading order emits tables by column);
#       ocr   - as `text`, against an OCR of the PDF (a scan with no text layer).
#               There is no fuzzy tier: a garbled word is quoted around with "...".
#   - every value is stated by the quote itself (see value_in_quote()).
# It also checks that the timing table's `source` keys resolve in the group,
# and that every species x model parameter in COVERAGE has at least one row
# (a value, or a `none` row saying what was searched). THERMAL is the same check
# for temperature limits and degree-day totals, by species x cell (see below), and
# FLOW for flow needs and the depth and velocity a fish meets.
#
# The intrinsic-potential model registry (data/ip_model_registry.csv, read with
# knw_ip_read()) is gated the same way: each row's flow quote, and its validation
# quote when it claims one, must be in the cited PDF. The registry holds no
# numbers; a model's thresholds are evidence rows carrying its model_id. So the
# link is checked both ways, on model_id x species x life stage x life-history
# form (blank matching blank): every tagged
# evidence row names a registry row, and every registry row has at least one
# tagged evidence row (a model whose thresholds were never written is not
# registered, it is unread).
#
# INPUT   data/literature_evidence.csv, data/ip_model_registry.csv,
#         data/life_history_timing.csv,
#         ~/Zotero/zotero.sqlite (a checked copy; Zotero locks the live file)
# OUTPUT  scripts/logs/habitat/<yyyymmdd>_literature_verify.csv, one row per
#         evidence row (status, PDF file, every PDF page the quote matches), and
#         <yyyymmdd>_literature_verify_ip_registry.csv, one row per registry quote;
#         a summary on stdout.
#         OCR text is cached in data/rag/ocr/ (gitignored), keyed by PDF md5.
#         Exits non-zero when any row, registry quote, model link, timing source,
#         coverage cell, thermal cell or flow cell fails.
# ---------------------------------------------------------------------------
pkgload::load_all("pkg", quiet = TRUE)   # the source tree, not an installed copy

group_id <- Sys.getenv("GROUP_ID", "4733734")
evidence_path <- Sys.getenv("EVIDENCE", "data/literature_evidence.csv")
registry_path <- Sys.getenv("REGISTRY", "data/ip_model_registry.csv")
ocr_dir <- file.path("data", "rag", "ocr")
COVERAGE <- list(
  species = c("CH", "BT", "CO", "ST"),
  parameter = c("spawn_gradient_max", "spawn_gradient_min", "spawn_channel_width_min",
                "spawn_mad_min", "rear_gradient_max", "rear_channel_width_min", "rear_mad_min",
                "rear_lake_ha_min", "rear_wetland_ha_min", "access_gradient_max",
                "cluster_bridge_gradient", "cluster_bridge_distance"))

# A cell is a water-temperature limit or a degree-day total for one life stage. A valued
# row meets an upper cell with bound max or range and a lower cell with min or range;
# an optimum is not a limit. A degree-day cell is met by a valued row whose window is
# one the cell names. A `none` row meets a cell by the same bound (or window): the
# search was made and found nothing. air_temperature never meets a cell, and neither
# does a qualitative row, which has no value.
THERMAL <- list(
  species = c("BT", "WCT", "CH", "CO", "ST"),
  cells = data.frame(
    variable = c(rep("temperature", 6), rep("degree_days", 4)),
    life_stage = c("spawning", "spawning", "incubation", "incubation", "rearing", "rearing",
                   "incubation", "emergence", "rearing", "overwintering"),
    side = c("upper", "lower", "upper", "lower", "upper", "lower", NA, NA, NA, NA),
    window = c(rep(NA, 6), "to_hatch", "to_emergence", "growing_season", "growing_season"),
    stringsAsFactors = FALSE))

# A flow cell is a flow need, or the depth or velocity a fish meets, for one life stage.
# An instream_flow need is met by a valued row with bound min, range or optimum: a
# minimum flow, a span, or an optimum (a PHABSIM peak, a percent of MAD) all answer
# "how much water does this stage need". Depth is a lower limit (min or range) and
# velocity an upper one (max or range); a bankfull depth is stream size and never meets
# a cell. A `none` row meets a cell by the same bound. SK rears in lakes, so it has no
# flow-need cell for rearing or overwintering and no rearing velocity cell.
FLOW <- list(
  species = c("CH", "CO", "SK", "BT", "GR", "WCT", "ST"),
  cells = data.frame(
    variable = c(rep("instream_flow", 5), "depth", "depth", "velocity", "velocity"),
    life_stage = c("spawning", "incubation", "rearing", "overwintering", "migration",
                   "spawning", "migration", "spawning", "rearing"),
    side = c(rep("need", 5), "lower", "lower", "upper", "upper"),
    stringsAsFactors = FALSE),
  skip = data.frame(species_code = "SK", variable = c("instream_flow", "instream_flow", "velocity"),
                    life_stage = c("rearing", "overwintering", "rearing"), stringsAsFactors = FALSE),
  bounds = list(need = c("min", "range", "optimum"), lower = c("min", "range"),
                upper = c("max", "range")))

ev <- knw_literature_read(evidence_path)
reg <- knw_ip_read(registry_path)

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
# Quote and page are compared as TOKEN SEQUENCES, not as normalized strings. The
# gate's earlier string form passed fabrications twice over (code-check rounds 1-2
# on #19), always by one mechanism: a lossy version of the claim was looked for in a
# lossy version of the page. Normalization that merged "1. 5" into "1.5", dropped
# "<" and ">", read "13" inside "13.2" or "one" inside "none" each widened what
# counted as a match. So here nothing is dropped or merged:
#   - light cleaning only: ligatures spelled out, curly quotes and primes straight,
#     every dash and the minus sign to "-", soft hyphens and zero-width characters
#     removed, no-break spaces to spaces, lower case. No NFKC (it turns "1½" into
#     "11⁄2" and a superscript "³" into "3").
#   - tokens: a number as written ("20,653", "13,2" and "1.5" are three different
#     tokens), a word, or any other single non-space character ("<", "≥", "%", "°").
#   - a match is the quote's tokens contiguous in the page's tokens. A quote may not
#     stop inside a number or a range: when its last token is a number the page must
#     not continue with "-", "." or "," and a digit, and likewise before a first number.
clean <- function(x) {
  x <- chartr("‘’‚′`“”„″", "''''\"\"\"\"\"", x)
  x <- gsub("[‐-―−]", "-", x)
  x <- gsub("[­​-‍﻿]", "", x)
  x <- gsub("[  -  ]", " ", x)
  x <- gsub("ﬀ", "ff", x); x <- gsub("ﬁ", "fi", x); x <- gsub("ﬂ", "fl", x)
  x <- gsub("ﬃ", "ffi", x); x <- gsub("ﬄ", "ffl", x)
  x <- gsub("[º˚]", "°", x)
  tolower(x)
}
TOKEN <- "[0-9]+(?:[.,][0-9]+)*|[[:alpha:]]+|[^[:space:][:alnum:]]"
tokens <- function(x) regmatches(x, gregexpr(TOKEN, x, perl = TRUE))[[1]]
is_num <- function(t) grepl("^[0-9]", t)

# Pages of a PDF as token streams, in two variants: a line-end hyphen between two
# letters joined ("habi-\ntat" -> "habitat") and every hyphen kept. Each token carries
# its page and, for layout text, its line.
pdf_pages <- local({
  cache <- new.env()
  function(file, ocr = FALSE, layout = FALSE) {
    id <- paste0(if (ocr) "ocr:" else if (layout) "layout:" else "", file)
    if (!is.null(cache[[id]])) return(cache[[id]])
    raw <- if (ocr) ocr_text(file) else
      paste(system2("pdftotext", c("-q", "-enc", "UTF-8", if (layout) "-layout", shQuote(file), "-"),
                    stdout = TRUE, stderr = FALSE), collapse = "\n")
    Encoding(raw) <- "UTF-8"
    pages <- strsplit(clean(raw), "\f", fixed = TRUE)[[1]]
    stream <- function(pages) {
      tok <- page <- line <- vector("list", length(pages))
      for (i in seq_along(pages)) {
        lines <- strsplit(pages[i], "\n", fixed = TRUE)[[1]]
        lt <- lapply(lines, tokens)
        tok[[i]] <- as.character(unlist(lt))   # NULL would delete the element
        page[[i]] <- rep(i, length(tok[[i]]))
        line[[i]] <- rep(seq_along(lt), lengths(lt))
      }
      list(tok = unlist(tok), page = unlist(page), line = unlist(line))
    }
    joined <- gsub("([[:alpha:]])-[ \t]*\n[ \t]*([[:alpha:]])", "\\1\\2", pages, perl = TRUE)
    out <- list(joined = stream(joined), kept = stream(pages))
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
    # A directory per run, so two runs OCR-ing at once do not delete each other's files.
    work <- tempfile("work_", tmpdir = ocr_dir)
    dir.create(work, showWarnings = FALSE)
    on.exit(unlink(work, recursive = TRUE), add = TRUE)
    tmp_pdf <- file.path(work, "out.pdf")
    # The sidecar is written in the work dir and renamed into the cache only once
    # complete, so a killed or concurrent run never leaves a truncated cache entry.
    tmp_side <- file.path(work, "sidecar.txt")
    # A signed PDF (govinfo signs its scans) is refused unless told the signature may be
    # invalidated; only the throwaway OCR copy in `work` is altered, never the stored PDF.
    rc <- system2("ocrmypdf", c("-q", "--force-ocr", "--invalidate-digital-signatures", "--sidecar",
                                shQuote(tmp_side), shQuote(file), shQuote(tmp_pdf)),
                  stdout = FALSE, stderr = FALSE,
                  env = paste0("TMPDIR=", shQuote(normalizePath(work))))
    if (rc != 0 || !file.exists(tmp_side) || !file.rename(tmp_side, side)) {
      stop("ocrmypdf failed on ", file)
    }
  }
  paste(readLines(side, encoding = "UTF-8", warn = FALSE), collapse = "\n")
}

MIN_FRAG <- 3       # tokens in every fragment of a text quote
MAX_GAP <- 200      # tokens allowed between consecutive fragments (committed rows need < 150)
TABLE_HOP <- 0      # tokens a table row may skip: none (skipping let a fabricated row collect real cells)
TABLE_LINES <- 3    # layout lines a table row may span

# Fragments of a quote as token vectors, split at an ellipsis or a [bracketed
# insert]. NULL when there is none, or one has fewer than MIN_FRAG tokens.
fragments <- function(quote) {
  f <- strsplit(clean(quote), "\\s*(\\.\\.\\.|…|\\[[^]]*\\])\\s*", perl = TRUE)[[1]]
  f <- lapply(f[nzchar(trimws(f))], tokens)
  if (!length(f) || any(lengths(f) < MIN_FRAG)) return(NULL)
  f
}

# Positions where `frag` occurs contiguously in `tok`, not cut inside a number or range.
occurs <- function(frag, tok, from = 1, to = length(tok)) {
  n <- length(frag)
  if (to - from + 1 < n) return(integer(0))
  cand <- from - 1 + which(tok[from:(to - n + 1)] == frag[1])
  keep <- vapply(cand, function(i) {
    if (!all(tok[i:(i + n - 1)] == frag)) return(FALSE)
    after <- i + n
    if (is_num(frag[n]) && after + 1 <= length(tok) && tok[after] %in% c("-", ".", ",") &&
        is_num(tok[after + 1])) return(FALSE)
    if (is_num(frag[1]) && i - 2 >= 1 && tok[i - 1] %in% c("-", ".", ",") && is_num(tok[i - 2]))
      return(FALSE)
    TRUE
  }, TRUE)
  cand[keep]
}

# Every PDF page on which the whole quote starts: its fragments in order, each within
# MAX_GAP tokens of the one before. integer(0) when there is no such place.
find_quote <- function(frags, pages) {
  found <- integer(0)
  for (v in c("joined", "kept")) {
    s <- pages[[v]]
    for (i in occurs(frags[[1]], s$tok)) {
      at <- i + length(frags[[1]])
      ok <- TRUE
      for (f in frags[-1]) {
        j <- occurs(f, s$tok, at, min(length(s$tok), at + MAX_GAP + length(f)))
        if (!length(j)) { ok <- FALSE; break }
        at <- j[1] + length(f)
      }
      if (ok) found <- c(found, s$page[i])
    }
  }
  sort(unique(found))
}

# A table row, on the -layout text: its tokens (symbols such as "<" and "≥" included)
# adjacent and in order, all on one page and within TABLE_LINES consecutive layout
# lines. A multi-line cell or a label printed beside its cells spans lines; nothing
# spans a page. Letting the match skip tokens (12 were allowed once) let a fabricated
# row "BF < 3.7 m High High High" collect "High"s from the next rows of the table.
table_pages <- function(quote, pages) {
  q <- tokens(clean(quote))
  if (length(q) < 3 || !any(is_num(q)) || !any(grepl("^[[:alpha:]]", q))) return(NULL)
  found <- integer(0)
  for (v in c("joined", "kept")) {
    s <- pages[[v]]
    for (i in which(s$tok == q[1])) {
      at <- i
      ok <- TRUE
      for (t in q[-1]) {
        win <- (at + 1):min(length(s$tok), at + 1 + TABLE_HOP)
        j <- win[s$tok[win] == t & s$page[win] == s$page[i]]
        if (!length(j)) { ok <- FALSE; break }
        at <- j[1]
      }
      if (ok && s$line[at] - s$line[i] < TABLE_LINES) found <- c(found, s$page[i])
    }
  }
  sort(unique(found))
}

# Each value must be stated by the quote itself. Numbers are read from the quote's
# own fragments (a [bracketed insert] is the editor's, not the source's), as whole
# tokens; a number after a "-" that does not follow a number may be read with either
# sign; number words must be whole words. The only rescalings are the ones a unit
# can carry: percent (and percent MAD) from a proportion (x100), mm from cm (x10), and m and km
# for a bridge distance (x1000; applied to no other variable, see value_in_quote()). Depth and velocity are kept in the unit the source wrote
# (knw_literature_vocab()), so cm/s has no rescale to m/s.
NUMBER_WORDS <- c(one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8,
                  nine = 9, ten = 10, first = 1, second = 2, third = 3, fourth = 4, fifth = 5,
                  sixth = 6, seventh = 7, eighth = 8, ninth = 9, tenth = 10)
# A unit with no entry here is read at scale 1: a new unit fails closed rather than inheriting a
# rescale from its spelling (a "^m" fallback once gave m3/s and wetted widths a x1000).
SCALE <- list(percent = c(1, 100), "percent MAD" = c(1, 100), mm = c(1, 10), km = c(1, 1e-3),
              m = c(1, 1e3), "m/s" = 1, "m3/s" = 1, "m bankfull" = 1, "m wetted" = 1, mi2 = 1)
MONTHS <- c("january", "february", "march", "april", "may", "june", "july", "august",
            "september", "october", "november", "december")

quote_numbers <- function(quote) {
  q <- gsub("\\[[^]]*\\]", " ", clean(quote))
  # a unit's exponent is not a stated value: "50 km2" states 50, not 2; "0.5 m3/s" states 0.5, not 3
  q <- gsub("(?<![[:alpha:]])(km|mi|cm|mm|m|ft)[23](?![0-9])", "\\1", q, perl = TRUE)
  tok <- tokens(q)
  out <- numeric(0)
  for (i in seq_along(tok)) {
    t <- tok[i]
    if (is_num(t)) {
      v <- if (grepl("^[0-9]{1,3}(,[0-9]{3})+$", t)) as.numeric(gsub(",", "", t)) else
        suppressWarnings(as.numeric(t))
      if (is.na(v)) next
      # after "-" the sign is ambiguous ("3.3° -13.3°" is a range): accept both signs,
      # unless the "-" follows a number directly, which makes it a range for certain
      signed <- i > 1 && tok[i - 1] == "-" && (i == 2 || !is_num(tok[i - 2]))
      out <- c(out, v, if (signed) -v)
    }
    # fused text-layer words such as "fourthorder" start with the number word
    w <- names(NUMBER_WORDS)[startsWith(t, names(NUMBER_WORDS)) &
                               (nchar(t) == nchar(names(NUMBER_WORDS)) | t %in% paste0(names(NUMBER_WORDS), "order"))]
    if (length(w)) out <- c(out, NUMBER_WORDS[w])
  }
  out
}

value_in_quote <- function(r) {
  vals <- c(r$value_min, r$value_max)
  vals <- vals[!is.na(vals)]
  if (!length(vals)) return(TRUE)
  if (r$variable == "timing") return(timing_in_quote(r))
  have <- quote_numbers(r$quote)
  # m and km rescale each other for a bridge distance only; any other value in m is read as
  # written, so a depth or width cannot verify at 1000x a number in its quote.
  sc <- if (!is.null(SCALE[[r$unit]]) && (!r$unit %in% c("m", "km") || r$variable == "bridge_distance"))
    SCALE[[r$unit]] else 1
  ok_set <- unique(c(outer(have, sc)))
  all(vapply(as.numeric(vals), function(v) any(abs(ok_set - v) < 1e-9 * max(1, abs(v))), TRUE))
}

# A timing value's month must be named as a whole word (full name, or a three-letter
# abbreviation other than "may", "mar" and "jun", which are words or prefixes of them);
# where every mention of that month gives a day ("August 23"), the day must be one of
# them; and the start's month must be named before the end's.
timing_in_quote <- function(r) {
  q <- gsub("\\[[^]]*\\]", " ", clean(r$quote))
  tok <- tokens(q)
  month_at <- function(m) {
    names <- c(MONTHS[m], if (!substr(MONTHS[m], 1, 3) %in% c("may", "mar", "jun")) substr(MONTHS[m], 1, 3))
    which(tok %in% names)
  }
  pos <- list()
  for (which_v in c("value_min", "value_max")) {
    v <- r[[which_v]]
    if (is.na(v)) next
    m <- as.integer(substr(v, 1, 2)); d <- as.integer(substr(v, 4, 5))
    at <- month_at(m)
    if (!length(at)) return(FALSE)
    days <- suppressWarnings(as.integer(tok[at + 1]))
    stated <- !is.na(days) & days >= 1 & days <= 31
    # the day binds only when every mention of the month gives one ("first week of
    # September ... September 10" names the month without a day, too)
    if (all(stated) && !d %in% days) return(FALSE)
    pos[[which_v]] <- at
  }
  if (length(pos) == 2 && min(pos$value_min) > max(pos$value_max)) return(FALSE)
  TRUE
}

check_row <- function(r) {
  fail <- function(status, file = NA) list(status = status, file = file, pages = NA)
  if (r$kind == "none") return(fail("none_row"))
  res <- resolve(r$citation_key)
  if (res$status != "ok") return(fail(res$status))
  frags <- if (r$quote_source != "table") fragments(r$quote)
  if (r$quote_source != "table" && is.null(frags)) return(fail("quote_fragment_too_short"))
  if (!value_in_quote(r)) return(fail("value_not_in_quote"))
  for (f in res$files) {
    pages <- pdf_pages(f, ocr = r$quote_source == "ocr", layout = r$quote_source == "table")
    pg <- if (r$quote_source == "table") table_pages(r$quote, pages) else find_quote(frags, pages)
    if (is.null(pg)) return(fail("table_quote_needs_numbers_and_words"))
    if (length(pg)) return(list(status = paste0("verified_", r$quote_source), file = basename(f),
                                pages = paste(pg, collapse = ";")))
  }
  fail("quote_not_found", paste(basename(res$files), collapse = "; "))
}

res <- lapply(seq_len(nrow(ev)), function(i) check_row(ev[i, ]))
out <- data.frame(
  data_row = seq_len(nrow(ev)), species_code = ev$species_code, parameter = ev$parameter,
  variable = ev$variable, metric = ev$metric, citation_key = ev$citation_key, model_id = ev$model_id,
  quote_source = ev$quote_source,
  status = vapply(res, `[[`, "", "status"),
  pdf_file = vapply(res, function(x) as.character(x$file), ""),
  pdf_pages = vapply(res, function(x) as.character(x$pages), ""))
PASS <- c("none_row", "verified_text", "verified_table", "verified_ocr")
pass <- out$status %in% PASS

# --- the IP model registry ----------------------------------------------------
# A registry quote is checked as a cited evidence row with no value: same key
# resolution, same matcher, same statuses.
quote_row <- function(key, quote, quote_source) {
  list(kind = "registry", citation_key = key, quote = quote, quote_source = quote_source,
       variable = NA, value_min = NA, value_max = NA)
}
reg_checks <- rbind(
  data.frame(data_row = seq_len(nrow(reg)), quote_of = rep("flow", nrow(reg)), key = reg$citation_key,
             quote = reg$quote, quote_source = reg$quote_source),
  data.frame(data_row = seq_len(nrow(reg)), quote_of = rep("validation", nrow(reg)),
             key = ifelse(is.na(reg$validation_citation_key), reg$citation_key,
                          reg$validation_citation_key),
             quote = reg$validation_quote, quote_source = reg$validation_quote_source)
)
reg_checks <- reg_checks[!is.na(reg_checks$quote), ]
reg_res <- lapply(seq_len(nrow(reg_checks)), function(i) {
  with(reg_checks[i, ], check_row(quote_row(key, quote, quote_source)))
})
reg_out <- data.frame(
  data_row = reg_checks$data_row, model_id = reg$model_id[reg_checks$data_row],
  species_code = reg$species_code[reg_checks$data_row],
  life_stage = reg$life_stage[reg_checks$data_row], quote_of = reg_checks$quote_of,
  citation_key = reg_checks$key, quote_source = reg_checks$quote_source,
  status = vapply(reg_res, `[[`, "", "status"),
  pdf_file = vapply(reg_res, function(x) as.character(x$file), ""),
  pdf_pages = vapply(reg_res, function(x) as.character(x$pages), ""))
reg_out <- reg_out[order(reg_out$data_row, reg_out$quote_of), ]
reg_pass <- reg_out$status %in% PASS

# The link, both ways, on model_id x species x life stage x life-history form: the form is
# part of a registry row's identity (knw_ip_read()), so a row for one form is not satisfied
# by evidence for another. A blank form matches only a blank form.
link_key <- function(x) {
  paste(x$model_id, x$species_code, x$life_stage, ifelse(is.na(x$life_history_form), "-",
                                                          x$life_history_form), sep = " / ")
}
ev_links <- unique(link_key(ev[!is.na(ev$model_id), ]))
reg_links <- unique(link_key(reg))
unregistered <- setdiff(ev_links, reg_links)   # evidence naming no registry row
unread <- setdiff(reg_links, ev_links)         # registry rows with no thresholds

# --- timing sources and coverage ---------------------------------------------
timing <- knw_timing_read("data/life_history_timing.csv")
t_keys <- unique(trimws(unlist(strsplit(timing$source[!is.na(timing$source)], ";"))))
t_bad <- t_keys[!t_keys %in% group_items$citation_key]
cov <- expand.grid(species_code = COVERAGE$species, parameter = COVERAGE$parameter,
                   stringsAsFactors = FALSE)
cov$rows <- mapply(function(s, p) sum(ev$species_code == s & ev$parameter %in% p),
                   cov$species_code, cov$parameter)

valued <- !is.na(ev$value_min) | !is.na(ev$value_max)
meets <- function(sp, cell) {
  hit <- ev$species_code == sp & ev$variable == cell$variable & ev$life_stage == cell$life_stage &
    (valued | ev$kind == "none")
  if (cell$variable == "degree_days") return(sum(hit & ev$metric %in% cell$window))
  b <- if (cell$side == "upper") "max" else "min"
  sum(hit & ev$bound %in% c(b, "range"))
}
thermal <- merge(data.frame(species_code = THERMAL$species), THERMAL$cells, by = NULL)
thermal$rows <- vapply(seq_len(nrow(thermal)), function(i) meets(thermal$species_code[i], thermal[i, ]),
                       integer(1))
meets_flow <- function(sp, cell) {
  hit <- ev$species_code == sp & ev$variable == cell$variable & ev$life_stage == cell$life_stage &
    (valued | ev$kind == "none") & !ev$unit %in% "m bankfull"
  sum(hit & ev$bound %in% FLOW$bounds[[cell$side]])
}
flow <- merge(data.frame(species_code = FLOW$species), FLOW$cells, by = NULL)
skip_key <- function(d) paste(d$species_code, d$variable, d$life_stage)
flow <- flow[!skip_key(flow) %in% skip_key(FLOW$skip), ]
flow$rows <- vapply(seq_len(nrow(flow)), function(i) meets_flow(flow$species_code[i], flow[i, ]),
                    integer(1))

log_csv <- Sys.getenv("LOG", file.path("scripts", "logs", "habitat",
                                      paste0(format(Sys.Date(), "%Y%m%d"), "_literature_verify.csv")))
dir.create(dirname(log_csv), recursive = TRUE, showWarnings = FALSE)
utils::write.csv(out, log_csv, row.names = FALSE, na = "")
reg_log <- file.path(dirname(log_csv), sub("(\\.csv)?$", "_ip_registry.csv", basename(log_csv)))
utils::write.csv(reg_out, reg_log, row.names = FALSE, na = "")

cat(sprintf("%d rows | %s\n", nrow(out),
            paste(names(table(out$status)), table(out$status), sep = " ", collapse = " | ")))
if (any(!pass)) print(out[!pass, c("data_row", "citation_key", "quote_source", "status", "pdf_file")],
                      row.names = FALSE)
cat(sprintf("registry: %d rows, %d quotes | %s\n", nrow(reg), nrow(reg_out),
            paste(names(table(reg_out$status)), table(reg_out$status), sep = " ", collapse = " | ")))
if (any(!reg_pass)) print(reg_out[!reg_pass, c("data_row", "model_id", "quote_of", "status", "pdf_file")],
                          row.names = FALSE)
cat(sprintf("model links: %d evidence rows name no registry row, %d registry rows have no evidence row\n",
            length(unregistered), length(unread)))
for (u in unregistered) cat("  unregistered:", u, "\n")
for (u in unread) cat("  unread:", u, "\n")
cat(sprintf("timing sources: %d keys, %d unresolved in the group%s\n", length(t_keys), length(t_bad),
            if (length(t_bad)) paste0(": ", paste(t_bad, collapse = ", ")) else ""))
cat(sprintf("coverage: %d of %d species x parameter cells have a row\n", sum(cov$rows > 0), nrow(cov)))
if (any(cov$rows == 0)) print(cov[cov$rows == 0, c("species_code", "parameter")], row.names = FALSE)
cat(sprintf("thermal: %d of %d species x cells have a row\n", sum(thermal$rows > 0), nrow(thermal)))
if (any(thermal$rows == 0)) {
  print(thermal[thermal$rows == 0, c("species_code", "variable", "life_stage", "side", "window")],
        row.names = FALSE)
}
cat(sprintf("flow: %d of %d species x cells have a row\n", sum(flow$rows > 0), nrow(flow)))
if (any(flow$rows == 0)) {
  print(flow[flow$rows == 0, c("species_code", "variable", "life_stage", "side")], row.names = FALSE)
}
cat("wrote", log_csv, "and", reg_log, "\n")
if (any(!pass) || any(!reg_pass) || length(unregistered) || length(unread) || length(t_bad) ||
    any(cov$rows == 0) || any(thermal$rows == 0) || any(flow$rows == 0)) quit(status = 1)
