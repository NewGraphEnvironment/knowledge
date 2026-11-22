# Code-check round 3: #258, `origin/main...HEAD` (a72ffe65)

## Checklist read

- `INDEX.md`: in full (the Python and R sections from the file; the shell, spatial and `code-check.md` sections are the
  same index text the session's `CLAUDE.md` carries, read there and spot-checked against the file).
- `code-check-python.md`: in full (9 headings). The diff holds no Python; none applies.
- `code-check.md` (38 headings): the prose of all 14 H3s under `## Mechanisms` (table rows skipped), plus
  "Documentation Staleness", "A link to a repo-hosted artifact must be *tracked*, not merely present" (its corollary,
  "the DOM is not the whole document") and "An assertion that matches an interpolated value cannot see the claim around
  it". Not read: 21.
- `code-check-r.md` (130 headings): read "Moving prose into a code chunk hides it from tools that scan the document",
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "`kable()` with no `format`
  writes a pipe table, and `kable_styling()` rebuilds it without `table.attr`", "A `for` loop that builds `aes()`
  captures the loop variable lazily", "`identical()` on two reader results tests the reader, not the file", "Under
  `R CMD check`, tests run from a temp dir against the INSTALLED package", "`sort()` and `order()` collate by
  `LC_COLLATE`, so a canonical form is locale-dependent", "A library call that dispatches on a global option is not a
  pure function", "`source()`ing a config into the render environment leaks it into the next render", "`deparse()`
  re-encodes non-ASCII, so it answers about itself rather than the file" and "Cross-function consistency for
  label/string normalization". Not read: 119.
- `code-check-shell.md` (73 headings) and `code-check-spatial.md` (96 headings): none read; the diff holds no shell
  and no spatial code. (`diff` and `grep` are shell functions here, as round 1 noted; this round used `/usr/bin/diff`,
  `/usr/bin/grep`, `git grep` and Python.)

## The mechanism

One source string has several readers, and the change was verified through one projection of one of them. The edit is
a markup substitution made occurrence by occurrence in the `.Rmd`, on the assumption that markup-only edits leave
everything but the font alone, and the proof was the page's visible text. But the same characters are read by pandoc
(markdown, and its smart quotes), by knitr (a chunk option evaluated as R and written into an attribute), by kable
and kableExtra (an R string written out as raw HTML), by pkgdown (the page turned into a search index, a markdown copy
and a browser-built contents list) and by scripts that read the `.Rmd` itself. Each round 1 finding is a reader the
projection left out: the alt text (knitr's reading of `fig.cap`, an attribute, and the text comparison read text nodes
only), the HTML strings (a second syntax the markdown rule was not carried to), the second link (first mention taken
from the mentions already marked in the source, not from rendered order) and the `CLAUDE.md` paragraph (written from
the intent, not from the tree). In the checklist's terms: `code-check.md` "A proxy is not the property" (visible text
standing in for "nothing else moved"), "Verification that reads its own output" (asserting through a comparison that
normalises away what it should see) and "A fix lands in one of two callers that share a harness".

Every place that mechanism reaches in this diff, and whether it is covered. Round 3's builds were made in detached
worktrees of `HEAD` and `origin/main` in a temp directory (removed afterwards; the checkout was not touched), with the
branch's library: a pkgdown build of the home page and articles with the markdown copies, sitemap and search index, and
an `rmarkdown::render()` of the four articles, at both commits (knitr 1.52, pkgdown 2.2.0, pandoc 3.9.0.2).

| surface | how it was checked, by whom | covered |
|---|---|---|
| Visible text, both renderers | author (text nodes); round 2 (every word, no folding); round 3: a token diff of each page's whole body, every change classed, and anything that is not a `<code>` tag, a link or an apostrophe form printed. Printed: the "tuned" sentence, the two wrong opening quotes on main that are now apostrophes, and `link's` → `link’s` in the alt text of the five figures whose captions name `link` | yes |
| Text inside attributes (`alt`, `title`, `aria-label`) | round 2 (multisets); round 3: every `<img>` tag of the vignette renders is identical between the commits once apostrophe forms are folded (4, 3, 1 and 4 images, embedded image bytes included by hash); a search of all `alt`, `title` and `aria-label` values on the eight `HEAD` pages for a backtick, `paste0`, `gsub`, `<code` or `&lt;` finds none; no image lacks alt text | yes |
| Tag structure, tables | round 2 (tag sequence); round 3: the token diff above, which holds every tag with its attributes | yes |
| `<head>`: `<title>`, description and Open Graph tags | round 3: byte-identical between the commits on all eight pages | yes |
| Text built by JavaScript or held in a widget | round 3: every `<script>` block is identical between the commits, the chinook map's 4.5 MB widget data among them; the diff does not touch `map-site` | yes |
| Navbar, sidebar, footer | round 3: everything outside `<main>` is byte-identical on the four pkgdown pages; `articles/index.html` and the home page too | yes |
| The contents list | pkgdown builds it in the browser from each heading's `.text()` (read in the built `bootstrap-toc`), and the one heading that gained code font keeps `id="cuts"` in the built page; in the vignette render any contents list is part of the body the token diff covers | yes, by reading the script, not in a browser |
| Search index (`search.json`), which round 2 did not build | round 3: built at both commits, 61 entries each, every field compared. Three fields differ: the "tuned" sentence and the two corrected quotes. No backtick, tag or `paste0` in any field of the `HEAD` index outside `code` | yes |
| Markdown copies for language models (`articles/*.md`, `llms.txt`), which pkgdown 2.2 writes and the live site serves (checked: both answer 200) | round 3: `llms.txt` identical; the four `.md` compared word for word with links and backticks set aside differ only by the "tuned" sentence, the two corrected quotes and `link's` → `link’s` in five alt texts; no escaped backtick, `<code`, `&lt;`, `paste0` or `gsub` | yes; new this round |
| `sitemap.xml`, `pkgdown.yml` | round 3: both identical between the commits (the two builds ran in the same minute, the only thing `pkgdown.yml` holds that could differ) | yes |
| Link targets and anchors | round 2 (ids, hrefs, ten targets answer 200); round 3: per page and renderer, the links gained are the first-mention package links and nothing else, each package's first code-font mention in rendered order is linked and no later one is (the methodology article's four in "Software and citation" apart), and the code spans gained are package names only | yes |
| Text only one renderer produces (chinook `map-static` in the vignette; `map-site` and the "Click a stream" sentence under pkgdown) | both renderers built at both commits, rounds 2 and 3 | yes |
| Text only another data state produces | no render can see it. Read: the two `else` strings in the chinook `other-checks` chunk (lines 365 and 366) are written as the rendered ones are (`<code>link</code>’s`, in a table with `escape = FALSE`); a scan of every string literal in a chunk and every inline R expression for a package name outside code font finds none | by reading only |
| Tools that read the `.Rmd`, not the page: the bibliography | `data-raw/vignette_bib.R` takes its keys from `rbbt::bbt_detect_citations()`, which deletes fenced chunks and every `` `r…` `` span by regex before looking for `@key`, and a promotion reruns it. Round 3 ran the detector on the four sources at both commits: 11, 17, 8 and 3 keys, the same sets. No new code span begins with `r`, so none is taken for inline R (`code-check-r.md` "Moving prose into a code chunk hides it from tools that scan the document") | yes; new this round |
| the settings register's `code:` phrases | round 2; round 3 reran `test-settings-register.R` in the `HEAD` copy: 272 expectations, 0 failed, 0 errors, 0 skipped | yes |
| the Bayesian article's quote check | round 2 ran it at both commits (PASS, 5 quotes). Round 3 read why it holds: it blanks fenced chunks with their header lines, masks inline code in backtick pairs (every added backtick is paired on its line) and does not count U+2019 as a quote mark | yes |
| the pkgdown workflow's gates | read: the page allowlist, the draft check and the navbar test read file names and `_pkgdown.yml`, not article text | not reached |
| cred's claim audit | not run: it is in no workflow, and `CLAUDE.md` already records that it mismatches (#79) | no |
| Installed vignette index, tarball | round 2 (`R CMD build`, `R CMD check`) at 7b2eebff. Since then only `CLAUDE.md` and `planning/` changed, both in `.Rbuildignore`; the diff touches no YAML line, so `VignetteIndexEntry` and the titles are main's | yes, by round 2 |
| Strings R uses as keys | `<code>link</code> now` is written twice and read twice, the same string; `how[su$setup]` keys on ASCII names; no test, script or package function matches article text holding U+2019 | yes |
| Both forms of the apostrophe fix | a search of the four sources for a straight apostrophe after a code span, after `</code>` or after a linked code span finds none at `HEAD`; the same search on main's sources finds 9 and 1 (the control) | yes |
| The four copies of the hook | byte-identical (one md5) | yes |
| `CLAUDE.md`, the last commit included | the heading quote at line 77 is the heading at `vignettes/tuning-method.Rmd:407`, character for character; the only other tracked quote of it is the link text at `vignettes/tuning-stream-splits.Rmd:596`, which matches. The paragraph's claims hold of the tree: four setup chunks carry the hook, "links four again" is four (`link`, `fresh`, `wet`, `fwapg`), both apostrophe forms of the trap were reproduced by round 2, and a tag in an HTML kable without `escape = FALSE` prints as `&lt;code&gt;` (a fixture this round) | yes |
| The toolchain that publishes | the live site records pandoc 3.8.3 and pkgdown 2.2.1; every build in three rounds is pandoc 3.9.0.2 and pkgdown 2.2.0. No build here is the published one. What narrows it: on main's source the live pages and the local main build carry the same two wrong quotes and whole-caption alt text, so the two toolchains agree on the behaviour the branch touches, and the branch's typed apostrophes and `<code>` tags no longer pass through pandoc's quote logic | no; read the first deploy: each figure's `alt`, and a search for a backtick and for `‘s` |

## Clean

No issues found: nothing in the diff, in round 1's fixes or in the last commit breaks a build, a rendered page, a
published file or a statement.

## Bounds, not findings

- A backtick in an HTML kable's cell, caption or footnote also renders as code, with the default escape, under both
  `bookdown::html_vignette2` and `html_document` (a fixture with `kable_styling()` and `footnote()`, pandoc 3.9.0.2):
  pandoc reads the table's contents as markdown, which is also why its smart quotes reach them. So `CLAUDE.md`'s second
  trap describes the route the branch took, and the trap in it is only that a tag needs `escape = FALSE`. The sentence
  is true of the tree; it does not say a backtick fails there, and one would not.
- The methodology heading that gained code font is now wrapped over two lines inside its `<h2>` in the built page.
  Its id, its anchor link, its search-index title and the contents list's text are unchanged.
- Out of scope and left as they are: text inside images (plot labels, the diagrams), the bundle's text, the reference
  lists, `README.md` and `NEWS.md`, which name `link` in plain font.
