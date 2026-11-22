# Code-check round 1: #258, `origin/main...HEAD` (7812e07d)

## Checklist read

- `INDEX.md`: in full.
- `code-check-python.md`: in full (9 headings). The diff holds no Python; none applies.
- `code-check.md` (38 headings): the prose of all 14 H3s under `## Mechanisms` (table rows skipped), plus
  "Documentation Staleness" and "An assertion that matches an interpolated value cannot see the claim around it".
  Not read: 22 (12 standalone rules, Security, Spreadsheets and PDFs).
- `code-check-r.md` (130 headings): read "Moving prose into a code chunk hides it from tools that scan the document",
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "`kable()` with no `format`
  writes a pipe table, and `kable_styling()` rebuilds it without `table.attr`", "A library call that dispatches on a
  global option is not a pure function", "`sub()` takes one replacement, not one per element". Not read: 125.
- `code-check-shell.md` (73 headings): read "A verification command can be shadowed by a shell function or alias"
  (`diff` and `grep` are functions in this shell; the comparisons below use `/usr/bin/diff` and Python). Not read: 72.
- `code-check-spatial.md` (96 headings): none read; the diff touches no spatial code.

## Findings

- **[severity: bug]** `vignettes/tuning-chinook-rearing.Rmd:26-29`, `vignettes/tuning-bayesian-practice.Rmd:27-30`,
  `vignettes/tuning-stream-splits.Rmd:26-29` — the `fig.cap` hook sets the alt text of every figure whose caption is
  built by `paste0()` to the word `paste0`.
  - Measured in the branch's own renders: `alt="paste0"` on 7 figures of the pkgdown build (chinook `river`,
    `profile`; Bayesian `prior`; stream-splits `map`, `profile`, `strip`, `premise`) and on an 8th in the package
    vignette (chinook `map-static`, with `aria-label="paste0"` beside it). On the live site, built from `origin/main`,
    each of these carries its whole caption. Only a caption written as a string literal comes out right (Bayesian
    `groups`, `publishing`, `cuts`; the methodology article's `funnel`, which has no hook). Four of the eight had no
    backtick to strip.
  - Why: `knitr::opts_knit$get("eval.after")` is `fig.cap, fig.scap, fig.alt, fig.note` (knitr 1.52), so when
    `call_block()` runs the option hooks `options$fig.cap` is still the unevaluated call. `gsub()` coerces a call with
    `as.character()`: `gsub("`", "", quote(paste0("a ", y)), fixed = TRUE)` is `c("paste0", "a ", "y")`. That character
    vector is no longer a language object, so knitr never evaluates it and prints its first element. A caption given
    as a variable name would print the variable's name the same way.
  - Why the before/after comparison passed: `textdiff.py`, `worddiff.py` and `leftover.py` read only text nodes
    (`handle_data`) and never an attribute, so "the visible text is unchanged" holds (rerun: it does) and says nothing
    about `alt`.
  - A remedy that was run, not only reasoned: keep the hook and hand knitr an expression to evaluate after the chunk,
    `options$fig.alt <- bquote(gsub("`", "", .(options$fig.cap), fixed = TRUE))`. On a five-chunk fixture under
    `bookdown::html_vignette2` (a `paste0()` caption, a literal one, a chunk with its own `fig.alt`, a caption that
    reads an object made inside its chunk, no caption) and on the Bayesian and chinook articles rendered in a detached
    worktree with this branch's library, every alt was the full caption without backticks, and a chunk's own `fig.alt`
    was kept.
  - **Rule:** code-check.md "A proxy is not the property"

- **[severity: fragile]** `vignettes/tuning-chinook-rearing.Rmd:214, 219, 220, 340, 343, 345, 358, 359, 364, 365` and
  `vignettes/tuning-stream-splits.Rmd:527, 529` — the possessive after `<code>link</code>` in the HTML-kable strings
  is still a straight apostrophe, and the trap the branch fixes in markdown applies to them too.
  - Pandoc reads an HTML kable's contents as markdown and runs its smart quotes over them (all 12 come out as `’` in
    the renders, though the source has `'`). Measured on a fixture: a cell, caption or footnote holding
    `<code>link</code>'s rule and the crews' readings` renders `‘s … crews’`, the same wrong opening quote the branch
    removed from the Bayesian glossary and the stream-splits flows sentence. Today none of the 12 strings has a later
    apostrophe that is not followed by a letter or digit, so all render right; the first plural possessive or quoted
    word added to one of those cells, captions or footnotes turns its `'s` into `‘s`. `CLAUDE.md`'s rule ("write the
    possessive with the apostrophe itself") was applied to the markdown and not to these.
  - **Rule:** code-check.md "A fix lands in one of two callers that share a harness"

- **[severity: fragile]** `vignettes/tuning-bayesian-practice.Rmd:153` and `:159`,
  `vignettes/tuning-chinook-rearing.Rmd:163` and `:164` — `link` is linked at its first mention and again at its
  second.
  - The branch linked the true first mention (line 153; line 163) and left the link on what used to be the first
    marked mention, one sentence or paragraph later (line 159; line 164, where two `[`link`](…)` to the same page sit
    in consecutive sentences). The built pages show it: mentions 1 and 2 of `link` both carry the href. The issue and
    `CLAUDE.md` both say the link is at the first mention only. The citation staying at the second mention is the
    accepted tradeoff; the second link is not part of it. (The methodology article's "Software and citation" section,
    lines 484-488, also re-links `fwapg`, `link`, `wet` and `fresh`; it predates the branch and reads as a deliberate
    list, but it is a third place the `CLAUDE.md` sentence does not hold.)
  - **Rule:** none

- **[severity: fragile]** `CLAUDE.md:27-32` — two statements in the new paragraph are not true of the diff, and one
  pronoun now points at the wrong article.
  - "each article's setup chunk strips them with a `fig.cap` hook": three of the four have it;
    `vignettes/tuning-method.Rmd` has none. And the hook does not strip the backticks from a `paste0()` caption, it
    replaces the alt text (first finding): of the five captions that carry a code span, it gets one right (the
    Bayesian article's `cuts`, a string literal).
  - "linked at its first only": not so in the three places the previous finding lists.
  - "Text the methodology article prints from its bundle is #201's. It reads `inst/vignette-data/`, which
    `data-raw/vignette_chinook.R` writes": before the insert "It" followed the sentence on the articles' prose and
    read as the bullet's subject, the chinook article; it now follows a sentence whose subject is the methodology
    article.
  - **Rule:** code-check.md "A guard's scope, escape hatches, and remedies"

## Checked and found sound

- **Rendered text.** `textdiff.py` and `worddiff.py` rerun on `before`/`after` and on the live site against the branch
  build: the only visible differences are the "tuned" sentence and the two `‘s` that became `’s`. No literal backtick,
  `&lt;code` or `<code` reaches a text node or an `alt`, `title` or `aria-label` in any of the eight branch renders.
- **What the text comparison cannot see.** Heading ids and text are the same on all four articles apart from the code
  font in the methodology article's `#cuts` heading; the sets of `id`, `href` and `title` attributes differ from the
  live site only by the new first-mention links (the favicon, `blob/HEAD` and downlit reference links are the local
  build's); every `<table>` is the same once `<code>` tags and apostrophe forms are set aside, bar the new links in the
  chinook "How was it tested?" table; figure and table counts and bookdown's `fig:` and `tab:` ids are unchanged.
- **`escape = FALSE`** (chinook `changes`, its footnote, the `strict` footnote, `other-checks`; stream-splits
  `setups`): every cell, header, caption and footnote is built from fixed text and from `cell_size()`, `cell_near()`,
  `km_d()`, `grad()`, `lim()`, `pc()`, `n0()`, `yn()` and `nrow()`/`sum()` counts, none of which can produce `<`, `>`
  or `&` for any value of the data. The stream-splits footnote keeps the default escape and holds no tag.
- **The renamed column.** `<code>link</code> now` is written once in `chg` and once in `st`, and both `st[["…"]]`
  reads use the same string.
- **Typographic apostrophes.** All 71 added (on 64 lines) are in prose or in strings that are rendered (captions, cells, a quoted
  column name with `check.names = FALSE`); none is where R needs a quote. No straight apostrophe is left after a
  markdown code span or a linked one. `data-raw/bayesian_alignment_check.R` counts `‘` and not `’` as a quote mark
  (`mark_rx`), so the Bayesian article's new apostrophes near page citations do not trip it (read, not run: it needs
  the books' PDFs).
- **Missed mentions.** A scan of the four sources (prose, chunk headers and string literals; code spans, URLs,
  citation keys and `repo#N` set aside) finds no plain mention; in the built pages the only ones outside code font are
  the bundle's text, the diagrams and the reference lists, which are out of scope.
- **First mentions and URLs.** Each package's first mention in each article is linked, and the nine link targets
  checked (the seven the branch adds or reuses and the two `www` forms already there) answer 200. No citation was added, moved or dropped; no chunk label, YAML, anchor or inline R expression was
  touched; no chunk label is duplicated; the settings register's three `code:` phrases in the chinook article are
  still whole on one line.
- **The "tuned" sentence.** True of the method as coded: `knw_tune_grid()` counts `departures` from `link`'s current
  definition and holds exactly one rule at zero, and `.tune_pick()` takes, among the converged rules within one
  standard error of the best, the one with the fewest departures, then the best score. So a key whose current
  definition is a close call keeps it, and a value moves only when the current definition is outside the close calls.
- **Issue numbers.** #258 and #201 resolve to this work and to the bundle-text issue.
