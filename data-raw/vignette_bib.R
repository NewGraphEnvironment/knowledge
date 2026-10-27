# data-raw/vignette_bib.R
# ---------------------------------------------------------------------------
# The references of `vignettes/chinook_rearing.Rmd` and `vignettes/habitat_thresholds.Rmd` (#93), written from Zotero so
# each article builds where Zotero is not
# (pkgdown in CI). Issue #79.
#
# WHY / DESIGN NOTES:
#   - THE KEYS ARE THE ARTICLE'S. rbbt reads the citation keys out of the Rmd (code chunks and inline R skipped) and
#     Better BibTeX exports exactly those from the group library (Zotero's local library 9, group 4733734). A key
#     Zotero does not return stops the script, so the article cannot build with a reference missing.
#   - VERSIONS COME FROM THE RUN, NOT FROM ZOTERO. One Zotero item serves every report that cites the tool, so it
#     carries no version; the article's copy gets the version the tuning ran on, from the evidence build ledger as
#     data-raw/vignette_chinook.R saved it (`meta$versions`); a tool whose version the run did not record is given
#     none rather than a borrowed one.
#   - A VERSIONED ENTRY IS @misc. pandoc's default style prints a @software entry's version as "V. 0.66.0. Released.",
#     a @misc's as "Version 0.66.0." (measured with pandoc 3.9.0.2), and drops `note` in both. A version that is more
#     than one token ("0.66.0 (commit a17e917)", "not recorded") prints as "Versions ...", so each is one token: the
#     release, or for fwapg (no release) the commit, or for wet the flow set it published. bcfishpass and bcfishobs,
#     whose versions the run did not record, carry none. Titles are braced so the style does not capitalise a name.
#   - ONLY WHAT A READER NEEDS. Better BibTeX writes each attachment's local path (`file`, a home directory), and the
#     abstract, keywords, access and original dates; the committed file keeps none of them. A timestamp date
#     (`2024-01-01T12:42:29Z`) is cut to its day.
#
# INPUT:  the two articles, inst/vignette-data/chinook_rearing.rds (meta$versions), and Zotero running
#         with Better BibTeX, synced with the group library
# OUTPUT: vignettes/chinook_rearing.bib, vignettes/habitat_thresholds.bib
# RUN:    Rscript data-raw/vignette_bib.R   (from the repo root, after any change to the article's citations)
# ---------------------------------------------------------------------------
library_id <- 9   # Zotero's local id of the NewGraphEnvironment group library (group 4733734)

bib_write <- function(rmd, out, all_tools) {

  keys <- sort(unique(rbbt::bbt_detect_citations(rmd)))
  if (!length(keys)) stop("no citation in ", rmd)
  if (any(grepl("^TODOKEY", keys))) stop("placeholder keys in ", rmd, ": ", paste(grep("^TODOKEY", keys, value = TRUE), collapse = ", "))
  bib <- paste(rbbt::bbt_bib(keys, translator = "biblatex", library_id = library_id), collapse = "\n")
  entries <- regmatches(bib, gregexpr("(?s)@[a-zA-Z]+\\{[^,]+,.*?\\n\\}", bib, perl = TRUE))[[1]]
  got <- sub("^@[a-zA-Z]+\\{([^,]+),.*$", "\\1", sub("\n.*", "", entries))
  if (!setequal(got, keys)) {
    stop("Zotero returned ", paste(setdiff(got, keys), collapse = ", "), " and not ", paste(setdiff(keys, got), collapse = ", "))
  }
  names(entries) <- got
  entries <- gsub("\n  (file|abstract|keywords|urldate|origdate) = \\{[^\n]*\\},?(?=\n)", "", entries, perl = TRUE)
  entries <- gsub("(\n  date = \\{[0-9-]{4,10})T[^}]*\\}", "\\1}", entries, perl = TRUE)
  # an organisation is one name: braced, "Environment and Climate Change Canada" does not print as two publishers
  entries <- gsub("\n  organization = \\{([^{}\n]*)\\}(,?)(?=\n)", "\n  organization = {{\\1}}\\2", entries, perl = TRUE)
  # any field whose value starts with / is a local path (urls and dois are https)
  if (any(grepl("file = |= \\{/", entries))) stop("a local path is left in an entry")

  # ---- versions from the run ------------------------------------------------------------------------
  short_sha <- function(s) substr(strsplit(s, ";", fixed = TRUE)[[1]][1], 1, 7)
  # the article's key for each tool, read from the Rmd's own keys by the title Zotero holds
  title_of <- function(e) sub("(?s)^.*?\\n  title = \\{(.*?)\\},\\n.*$", "\\1", e, perl = TRUE)
  key_for <- function(pattern, required = TRUE) {
    k <- got[grepl(pattern, vapply(entries, title_of, ""), ignore.case = TRUE)]
    if (!length(k) && !required) return(NA_character_)
    if (length(k) != 1) stop(rmd, ": expected one cited entry titled like '", pattern, "', found ", length(k))
    k
  }
  ver <- list(
    list(key = key_for("^(smnorris/)?fwapg", required = all_tools), title = "fwapg", version = short_sha(v$fwapg_sha)),
    # the fork's crosswalk built the routed flows the evidence read: wet's data/checks/pcic_routed_compare_20260717.txt at
    # the loaded build (94deeb5) names the fwapg commit that built pcic.discharge_monthly (#89)
    list(key = key_for("^\\{*NewGraphEnvironment\\}*/fwapg", required = FALSE), title = "fwapg, New Graph Environment's fork", version = "7c30f58"),
    list(key = key_for("^(smnorris/)?bcfishpass", required = all_tools), title = "bcfishpass", version = NULL),
    list(key = key_for("^(smnorris/)?bcfishobs", required = all_tools), title = "bcfishobs", version = NULL),
    list(key = key_for("^\\{*link\\}*:", required = all_tools), title = "link", version = v$link),
    list(key = key_for("^\\{*fresh\\}*:", required = all_tools), title = "fresh", version = v$fresh),
    list(key = key_for("^\\{*wet\\}*:", required = all_tools), title = "wet", version = sub(" .*$", "", v$wet))
  )
  for (x in Filter(function(x) !is.na(x$key), ver)) {
    e <- entries[[x$key]]
    e <- sub("^@[a-zA-Z]+\\{", "@misc{", e)
    e <- sub("\\n  version = \\{[^\\n]*\\},", "", e)
    # the package's own name, lower case and braced; a subtitle Zotero holds ("Link: {{Develop}} ...") is kept after it
    t <- title_of(e)
    t <- if (grepl("^[^:]+: ", t) && !grepl("/", t)) sub("^[^:]+: ", paste0("{", x$title, "}: "), t) else paste0("{", x$title, "}")
    if (!is.null(x$version) && grepl("\\s", x$version)) stop(x$key, ": a version with a space prints as 'Versions'")
    new <- if (is.null(x$version)) sprintf("\n  title = {%s},", t) else sprintf("\n  title = {%s},\n  version = {%s},", t, x$version)
    # spliced by position: as a sub() replacement the new text would lose its backslashes (a title's \\& or \\_)
    at <- regexpr("\\n  title = \\{[^\\n]*\\},(?=\\n)", e, perl = TRUE)
    if (at < 0) stop(x$key, ": no title line")
    e <- paste0(substr(e, 1, at - 1), new, substr(e, at + attr(at, "match.length"), nchar(e)))
    entries[[x$key]] <- e
  }

  writeLines(c(paste0("% written by data-raw/vignette_bib.R from Zotero (group library) for ", rmd, "; do not edit"),
               "", paste0(entries[sort(names(entries))], "\n")), out)
  message(sprintf("%s: %d entries (%s)", out, length(entries), paste(sort(names(entries)), collapse = ", ")))
}

v <- readRDS("inst/vignette-data/chinook_rearing.rds")$meta$versions   # both articles describe this run
# all_tools: the article must cite fwapg, bcfishpass, bcfishobs, link, fresh and wet (the chinook article does)
bib_write("vignettes/chinook_rearing.Rmd", "vignettes/chinook_rearing.bib", all_tools = TRUE)
bib_write("vignettes/habitat_thresholds.Rmd", "vignettes/habitat_thresholds.bib", all_tools = FALSE)
