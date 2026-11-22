# Code-check round 2: #258, `origin/main...HEAD` (7b2eebff)

## Checklist read

- `INDEX.md`: every heading. The first sentences were read from the file for the Python and R sections down to
  "`readBin(size = 4)` returns NA for exactly 2^31", and for the remaining R, shell, spatial and `code-check.md`
  headings from the same index text as the session's `CLAUDE.md` carries it.
- `code-check-python.md`: in full (9 headings). The diff holds no Python; none applies.
- `code-check.md` (38 headings): the prose of all 14 H3s under `## Mechanisms` (table rows skipped), plus
  "Percent-encode a URL at construction, not at consumption", "Documentation Staleness" and "An assertion that matches
  an interpolated value cannot see the claim around it". Not read: 21.
- `code-check-r.md` (130 headings): read "Moving prose into a code chunk hides it from tools that scan the document",
  "A duplicate knitr chunk label fails the build, and reading the diff will not find it", "`kable()` with no `format`
  writes a pipe table, and `kable_styling()` rebuilds it without `table.attr`", "A `for` loop that builds `aes()`
  captures the loop variable lazily", "`deparse()` re-encodes non-ASCII, so it answers about itself rather than the
  file", "`source()`ing a config into the render environment leaks it into the next render" and "Cross-function
  consistency for label/string normalization". Not read: 123.
- `code-check-shell.md` (73 headings) and `code-check-spatial.md` (96 headings): none read; the diff holds no shell
  and no spatial code.

## Clean

No issues found: nothing in the diff, and nothing inside round 1's four fixes, breaks a build, a rendered page or a
statement. What was measured is below, so the verdict can be checked rather than taken.

## How it was checked

Everything ran in detached worktrees of `HEAD` and of `origin/main` (removed afterwards), with the branch's library;
the checkout was not touched. Builds: `rmarkdown::render()` of the four articles at both commits, a pkgdown
`build_articles()` at both commits (so the control shares the toolchain, which the live site's pages do not), a third
build of the Bayesian article with the hook taken out, `R CMD build` of `HEAD`, and `R CMD check --no-tests
--no-examples --no-manual` on that tarball. knitr 1.52, rmarkdown 2.32, pkgdown 2.2.0, bookdown 0.48, kableExtra
1.4.0, pandoc 3.9.0.2.

The comparison was my own, because the author's scripts normalise what they compare (`attrdiff.py` strips backticks
and folds `’` to `'` before comparing; the text scripts read text nodes only). Mine compares, main against `HEAD` and
per renderer: every word of visible text exactly (no folding of quotes), the sequence of every tag with its class and
id other than `<code>` and `<a>`, and the multisets of `alt`, `title`, `aria-label`, `id`, `href`, `class`, `style`,
`width`, `height` and `role`.

- **Words.** The only differences in either renderer are the "tuned" sentence and two wrong opening quotes on main
  that are now apostrophes (the Bayesian glossary's "Full network. link‘s", stream-splits' "wet‘s"). Positive control:
  a count of `‘s` in text nodes is 1 and 1 on main's two pages and 0 on all eight `HEAD` pages.
- **Structure.** Zero differing tags in all eight comparisons, so the hook did not move any figure onto another knitr
  code path: every captioned figure was already on knitr's `<div class="figure">` path at main (bookdown's format in
  the vignette, `out.width` from `fig.retina` under pkgdown).
- **Attributes.** `id`: none differ (the `#cuts` heading keeps its id with code font in it). `href`: only the
  first-mention links are new, and pkgdown's `external-link` class on them. `alt` and `aria-label`: differ only by
  `link's` becoming `link’s` in the five captions that name `link`; no backtick, `<code`, `paste0` or `gsub` reaches an
  attribute. So "alt is identical" holds up to that apostrophe, which is the caption's own.
- **R CMD build and check.** "creating vignettes ... OK"; check Status OK, with "checking package vignettes" and
  "re-building of vignette outputs" OK. The tarball's `inst/doc` pages carry the same alt text as the renders.

## The round 1 fixes, one by one

**The `fig.cap` hook (`bquote()`).** Sound for every figure chunk, in both renderers.

| article | chunk | caption given as | own `fig.alt` | notes | alt at `HEAD` |
|---|---|---|---|---|---|
| bayesian-practice | `prior` | `paste0()` | no | no code span; `*…*` stays in alt as on main | full caption |
| bayesian-practice | `groups`, `publishing` | string | no | | full caption |
| bayesian-practice | `cuts` | string with `` `link`’s `` | no | | full caption, no backtick |
| chinook-rearing | `map-static` | `paste0()` | no | `eval = !on_site`, `out.width = "80%"`: drawn in the vignette, not evaluated under pkgdown | full caption in the vignette; no figure and no stray text under pkgdown |
| chinook-rearing | `map-site` | none | no | `eval = on_site`, an htmlwidget: no `fig.cap`, so the hook never runs | none, as on main |
| chinook-rearing | `river`, `profile` | `paste0()` | no | read objects from `load` | full caption |
| method | `funnel` | string | no | `out.width = "100%"`; the hook is new here and changes nothing: alt is the same string as on main | unchanged |
| stream-splits | `map`, `profile`, `strip`, `premise` | `paste0()` | no | captions read objects made in earlier chunks (`mrow`, `cc`, `half`, `crit`, `pm`); one image each | full caption |

- Why it holds: `fig.cap` and `fig.alt` are both in knitr's `eval.after`, the option hooks run before the chunk
  (`call_block()`), and `eng_r()` evaluates the `eval.after` options in the chunk's environment after it, so the call
  the hook hands over is evaluated exactly when the caption is. With `eval = FALSE` neither is evaluated and no plot
  hook reads them.
- A fixture of the shapes the articles do not all have, run under `bookdown::html_vignette2` and under
  `html_document(fig_retina = 2)` with `IN_PKGDOWN=true`: a `paste0()` caption reading an object made inside its own
  chunk; a literal; a caption given as a variable; a two-caption vector over two plots (`fig.show = "asis"`); one
  caption over two plots; a chunk with its own `fig.alt` (kept); `eval = FALSE` with a caption naming an object that
  does not exist (no error); a caption that evaluates to `NULL`; `fig.cap = NA`; no caption. Every image was drawn and
  every alt was the evaluated caption without backticks. The two degenerate ones (`NULL` after evaluation, `NA`) give an
  image with no `alt` attribute; no article has either.
- Nothing else is displaced: `knitr::opts_hooks$get()` is empty when the setup chunk runs, under both renderers
  (printed from a build), so the hook replaces no other; `rmarkdown::render()` restores option hooks on exit, so it
  does not leak between vignettes; the four hook blocks are byte-identical. The only readers of `fig.alt` in knitr,
  rmarkdown, bookdown, pkgdown and downlit are knitr's plot hooks. `aria-label` appears only in the vignette render,
  where it mirrors `alt`.
- Is the hook needed: yes. With it removed the Bayesian `cuts` figure's alt reads ``on `link`’s full network`` in
  both renderers, so `CLAUDE.md`'s "knitr gives a figure's alt text the caption's source, backticks and all" is true.
- A bound, not a finding: the hook relies on `fig.alt` being in `eval.after` (knitr's default). An article that set
  `eval.after` without it would print the call's pieces. None does.

**Apostrophes after `</code>`.** None left: no straight apostrophe follows a code span, a linked code span or
`</code>` in the four sources (pattern search, and the exact word comparison above would show any that rendered
wrong). The trap is real for both forms: on pandoc 3.9, `` `link`'s … species' `` and `<code>link</code>'s … species'`
inside a table cell both render `‘s … species’`. The diff adds 83 U+2019 and no other non-ASCII character; each sits
after a backtick, a `)` closing a linked code span, or `</code>`.

- Not misread by R: the two `st[["<code>link</code> now"]]` reads and the `how[su$setup]` lookup key on ASCII names.
  The one U+2019 in a name is the methodology `picks` table's column, used only as a header.
- Not misread by the checks that read the articles: `data-raw/bayesian_alignment_check.R` run with
  `MD=vignettes/tuning-bayesian-practice.Rmd` at main and at `HEAD` (it had only been read in round 1): 5 quotes
  checked, PASS, both times; its `mark_rx` counts `‘`, not `’`. `tests/testthat/test-settings-register.R` at `HEAD`:
  272 expectations pass, so the register's three `code:` phrases in the chinook article are whole.
  `test-pkgdown-navbar.R`: 10 pass. No test, package function or receipt reads an `.Rmd`.
- A bound, not a finding: in a non-UTF-8 locale (`LC_ALL=C`) the `picks` header and caption print
  `link<U+2019>s`, because an argument name is converted to the native encoding. Main already prints
  `m<U+00B3>/s` eight times in that article under the same locale, so no build that worked before breaks.

**One link per package.** In rendered order, in both renderers, every package's first code-font mention carries a
link and no later one does: Bayesian `link` 1 of 16, `knowledge` 1 of 1; chinook `link` 1 of 35 (33 under pkgdown),
`bcfishpass` 1 of 4, `wet` 1 of 2, `fwapg` 1 of 2, `fresh`, `bcfishobs` 1 of 1; stream-splits `link` 1 of 24, `fresh`
1 of 2, `knowledge` 1 of 2, `wet`, `fwapg`, `bcfishpass`, `bcfishobs` 1 of 1; the methodology article the same, plus
the second links to `link`, `fresh`, `wet` and `fwapg` in "Software and citation" (four, as `CLAUDE.md` says). The
stream-splits link whose text is the `#cuts` heading holds a code span and points at the article, not the package.
The ordered list of citations with their locators is identical to main's in all four sources (18, 12, 25 and 8 keys).
The ten link targets answer 200.

**The `CLAUDE.md` paragraph.** Each claim holds: all four setup chunks carry the hook; "links four again" is four;
both apostrophe forms of the trap reproduce; the `paste0()` reason for the call is what knitr does; and "The chinook
article reads" restores the subject the insert had displaced.

## What round 1 did not look at

- **Headings, anchors, the table of contents.** One heading holds code font (`## Does where `link` cuts a stream …
  {#cuts}`). Its id is `cuts` in both renderers, pkgdown's anchor link is in place, and pkgdown's contents list is
  built in the browser from the heading's text (`bootstrap-toc` reads `.text()`), so it shows the plain words. The
  link to it from the stream-splits article renders as one link with a code span inside.
- **pkgdown's auto-linking.** downlit links calls, not bare names: in the `HEAD` site no `<code>link</code>`,
  `wet`, `fresh` or `knowledge` holds an `<a>`; the only code spans with a link inside are the `knw_*()` calls the
  methodology bundle prints, as on main.
- **Mentions that are not the package.** Every one of the code-font `link`, `wet`, `fresh` and `knowledge` mentions
  was read in context: all name the package (no "link function", "wet", "fresh water"); the one English "links" in
  the methodology article is left plain. What stays outside code font in the built pages is the bundle's text, the
  diagrams, the reference lists and pkgdown's navbar, all out of scope.
- **Search index, sitemap, vignette index.** Titles, `VignetteIndexEntry` and `_pkgdown.yml` are untouched, and the
  pages' structure is unchanged, so nothing these are built from moved. The search index was not built.
- **Non-ASCII in the vignettes.** Main already carried `³` and one `’`; the files declare UTF-8; `R CMD build` and
  the vignette steps of `R CMD check` pass.

Outside the diff, for whoever next edits the line: `CLAUDE.md` quotes the methodology heading as "Does where link cuts
a stream change the rules?", and the heading has read "… change the habitat definitions?" since before this branch.
