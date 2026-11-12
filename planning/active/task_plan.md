# Task: Backlog move 2: Public articles: a tuning series, one vocabulary, a build that cannot stall (#171)

**If we do it:** the site's articles read as a method and its case studies, say "fish habitat definition" as the website and README do, cite upstream fwapg at a commit upstream holds, and a build that stalls fetching tiles fails fast. **If we never do:** the series stays titled by its first species and by `link`, the README and articles drift from the website's words, and a stalled build holds a runner to its timeout (twice so far).

## Context

The site's three articles are titled by their first species and by `link`, say "rule" where the website and README
now say "fish habitat definition", and one upstream citation pins a commit only New Graph's fork holds. Move 2
carries #118 (rename as a method and case studies), #107 (fwapg citation, folded into #118), #156 (vocabulary,
life history first) and #159 (post-merge CI stalls). One PR, branch `171-backlog-move-2-public-articles-a-tuning`.

What exploration changed:
- **#143 (closed 2026-11-04) already did #118's #64 piece**: the chinook article runs in #64's order and the
  one-SE and cross-validation citations sit in the method article's `#se` section. The chinook article already has
  "Software and citation". #118's remaining prose work is titles, openings and the vocabulary, which #156 shares.
- **No bundle pins an article file.** Only `method.rds` pins `inst/method/settings.csv` whole, so the narrowed
  register check (Phase 1) is the only test change the rename needs, and no bundle is rebuilt.
- **#159's stalls were not the tile fetch.** All three stalled runs hung in `r-lib/actions/setup-r` (or the step
  after it) before any article rendered: run 42149377267 (pkgdown, setup-r 19 min then setup-r-dependencies to the
  30-min cap), 42149415347 (citation, setup-r 15 min to its cap), and 2026-11-11's 43033711487 / 43033712021 (PR #190:
  setup-r to 30 and 45 min). The job-level `timeout-minutes: 30` already exists in `pkgdown.yaml`.
- **The old URLs are in use**: the website's Open Source page and the 2026-10-30 floodplains email drafts link
  `articles/habitat_thresholds.html` and `articles/chinook_rearing.html`, so #118's "no redirects" premise is stale.
- fly#108 is still open, so #156's fly row cannot land here.

## Decided at the gate (Al, 2026-11-12)

- Method article: **"Tuning fish habitat definitions with fish sampling records"**, `vignettes/tuning-method.Rmd`.
- Case study: **"Tuning habitat: chinook rearing"**, `vignettes/tuning-chinook-rearing.Rmd`.
- Stream splits: **`vignettes/tuning-stream-splits.Rmd`**, title kept, in a third menu group "Checks on the method".
- fwapg (#107): "if it uses the flows we pull in on our fork we should cite the fork; otherwise upstream 2024 is
  fine." Upstream `fwapg` is cited with no version; an article whose numbers read the fork's routed flows cites the
  fork entry, which keeps its commit.
- Old URLs **redirect** (pkgdown `redirects:`), and the website's two links are updated after the merge.
- (mine) The fly row is split into its own issue, blocked by fly#108, its body naming move 2 as where it was split
  from, and left out of `planning/backlog.md`; #156 closes with this PR.
- (mine) The map legend's labels in `R/compare_map.R` drop "rules" too ("kept (both)", legend title "Habitat
  definition"), so the README figure is regenerated.

## Phase 1: Narrow the register check (#118)
- [x] `tests/testthat/test-vignette-data.R`: hold `settings.csv`'s printed columns (all but `where` and `note`; findings) to the bundle's
      `x$settings`, and skip `inst/method/settings.csv` in the methodology bundle's whole-file md5 loop
- [x] Prove it fires, in a scratch copy: a changed value fails, a new row fails, a changed `where` or note passes
- [x] `CLAUDE.md`, methodology-article bullet: what now stales the bundle

## Phase 2: Rename into the series (#118)
- [x] `git mv` the three `.Rmd` and three `.bib` to `tuning-method`, `tuning-chinook-rearing`, `tuning-stream-splits`;
      `inst/vignette-data/` names stay
- [x] Update every reference: `data-raw/vignette_{bib,chinook,method}.R`, `data-raw/README.md`,
      `inst/method/settings.csv` (three `where` paths), `CLAUDE.md`, `README.md` (Articles list), `research/`
      (README, `chinook_rearing_tuned.md`, `habitat_thresholds_tuned.md`, `minimal_network_tuning.md`, any other a
      grep finds), the articles' cross-links (`habitat_thresholds.html` → `tuning-method.html`, anchors kept).
      NEWS history entries stay as written
- [x] `_pkgdown.yml`: `articles:` with "How the tuning works" (method), "Case studies" (chinook rearing), "Checks on
      the method" (stream splits); `redirects:` from the three old article URLs
- [x] `devtools::test()` passes (settings register resolves the new paths)

## Phase 3: Titles, openings and one vocabulary (#118, #156)
- [x] Read soul's `conventions/writing.md` in full; word counts of the three articles and README before
- [x] Retitle the method and chinook articles (title and `VignetteIndexEntry`)
- [x] Openings lead with life history, then the records tuning the values where they allow, tested where sampling
      caught the species and where it did not; `link`'s first mention in code font, linked, said what it is; no
      company name in an opening
- [x] Vocabulary in the three articles' prose and captions: "fish habitat definition" at first mention, "habitat
      definition" after, never "definition" alone; "threshold" stays for one cut-off; code identifiers, link's own
      config wording and comments untouched. Includes `#cuts`'s heading and the stream-splits leftovers #156 lists
- [x] README: opening leads with life history; map caption, alt text and Example say "habitat definition"
- [x] `R/compare_map.R` legend labels and default title; its test; regenerate `man/figures/readme-bulk.png`
      (`data-raw/readme_figure.R`) and check it at its published width
- [x] Each inline `stopifnot()` stays with the number it guards; the register's `code:` phrases stay whole on one
      line; word counts after, against before

## Phase 4: Bibliographies (#107)
- [ ] `data-raw/vignette_bib.R`: upstream `fwapg` carries no version; the fork entry keeps its commit; check which
      articles read the fork's routed flows and that each cites the fork entry
- [ ] Regenerate the three `.bib` with Zotero running (`../wet` at the bundle's `wet_sha`); check every key the old
      and new files share keeps its title, year and DOI

## Phase 5: A stall fails fast (#159)
- [x] Read the stalled `setup-r` steps' logs (the four runs above, and v0.4.29's if retained) for the last line
      before the cancel
- [x] `.github/workflows/pkgdown.yaml` (this repo's own): step-level `timeout-minutes` on `setup-r` and
      `setup-r-dependencies`, so a stall fails in minutes with the step named
- [x] File a flows issue for the same step timeouts in the shared `r-cmd-check` and `r-citation-cff` workflows (flows#3 already held it: knowledge's evidence added to its body)
- [ ] Record in #159 that no stall reached the article render, so the tile fetch is not the cause seen

## Phase 6: Site build and checks
- [ ] Install the branch, `pkgdown::build_site()` locally: `docs/articles/` holds the three `tuning-*` pages, the
      old names are redirect pages only, every internal `articles/*.html` link resolves, no footnote markers
- [ ] `devtools::test()`, `lintr::lint_package()` per file against main, `pkgdown::check_pkgdown()`
- [ ] Offer the rendered articles in a form that opens on a phone

## Phase 7: Bookkeeping
- [x] File the bundle-text issue: `pipeline.csv` step labels, five `settings.csv` labels and the two SVGs say "rule"; they ride the next methodology bundle rebuild (review B1): #201
- [x] File the fly-row issue (blocked by fly#108; split from move 2): #200; #156's and #171's bodies point to it
- [ ] `/code-check branch` (three-round floor)
- [ ] `/planning-archive`, `/gh-pr-push` (Fixes #118, #107, #156, #159; relates #171)

## Owed at the end (reported, done after merge)

- [ ] GitHub About: the ecosystem tagline the README and DESCRIPTION now carry (`gh repo edit --description`), once main holds them

- [ ] Website repo: point the Open Source page's two knowledge links at `tuning-method.html` and
      `tuning-chinook-rearing.html` (a PR there, after the deploy serves the new pages)

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: Phase 1's mutation table (the check fails on a value or new row, passes on a `where` edit);
`test-settings-register.R` resolving the renamed paths; a grep for `habitat_thresholds|chinook_rearing|stream_splits`
outside archives, logs, NEWS history and bundle names returning nothing; a grep of the rendered articles' text for
`\brules?\b` outside code; the local site build's page and link checks; the regenerated `.bib` key comparison; the
deployed site after merge serving the new pages and the redirects.

