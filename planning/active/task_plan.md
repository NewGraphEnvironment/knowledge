# Task: README: bring it to the readme convention and describe the habitat-threshold work (#75)

## Problem

The README was last rewritten before #57. It is close to correct on the report corpus and the fish records, but out of date on the habitat thresholds, which are now most of the work, and it predates `conventions/readme.md` (NewGraphEnvironment/soul#416's README wave).

## Decided at the gate

- From the issue (Al, 2026-10-20): figure is the Bulkley chinook rearing map the article draws; make a
  hex sticker; this lands before #56.
- Proposed in plan mode and approved by Al, 2026-10-20:
  1. **Figure = the article's whole-group "rules" panel only** (kept / lost / gained), drawn by
     `knw_compare_map(seg, water, panels = "rules")` from `inst/vignette-data/bulk_{segments,water}.rds`.
     The 12 km window and its numbered markers stay in the article: they belong to a table the README
     does not carry, and copying the window search would derive one fact twice.
  2. **Research list → one Learn more line** to `research/README.md` (which already lists all 18 topic files), plus the
     article and the reference groups. No per-file list in the README (convention: leave out what another
     file keeps). Layout, Three tracks and Conventions sections go too: `scripts/README.md` and
     `CLAUDE.md` keep them.
  3. **Ecosystem = soul#416's nine decided rows** (fly's as softened in fly PR #105), each linked to
     `https://www.newgraphenvironment.com/<repo>/`, plus a bold **knowledge** row worded as the tagline.
     knowledge is not in the decided membership: say so in the soul amendment.
  4. **Example reads `data/thresholds.csv` from a clone** with base R (no exported reader exists; `data/`
     is not in the build), output pasted from a real run.
  5. **Published data** (`fdis/`, `knowledge/fdis/`; v3 is not uploaded, see findings) goes under Installation, as "how to reach what it
     publishes". `thresholds/v1` and `habitat_grade/v1` are not named (not uploaded).

## Phase 1: Hex sticker
- [x] Copy soul's `templates/make_hexsticker.R` to `data-raw/make_hexsticker.R`; run it to write `man/figures/logo.png` (and the small one if the template writes it); `data-raw/nge-icon_white.png` committed as link does
- [x] Read the PNG: name inside the hexagon, opaque (corners transparent, as in every hex sticker)

## Phase 2: Opening and the texts that travel with it
- [x] README: title line with sticker (`height="139"`), lifecycle badge block, tagline, opening of 1–3 plain sentences: what knowledge is (fish records, past reports and cited literature per watershed group), and the decision it informs (the thresholds link's habitat model uses to say where fish can spawn and rear, which restoration planning reads)
- [x] DESCRIPTION `Title` and `Description` rewritten in step (thresholds included; "Under active development."); `Authors@R` to the `/citation-cff` block (firm `cph`, `fnd`); `devtools::document()` for `man/knowledge-package.Rd`
- [x] GitHub About: `gh repo edit NewGraphEnvironment/knowledge --description "<tagline>"`, read back with `gh repo view --json description`

## Phase 3: Figure
- [x] `data-raw/readme_figure.R`: reads the two bundled `.rds` (via `system.file()` after `pkgload::load_all()`), calls `knw_compare_map(..., panels = "rules")`, writes `man/figures/readme-bulk.png`, opaque
- [x] Self-review per `cartography.md` (all 12 checks), checked at ~830 px published width; set `width` in the `<img>` so a portrait panel is not blown up
- [x] Alt text and a plain caption (what kept / lost / gained mean, in words); caption numbers, if any, computed from the same data

## Phase 4: Installation, example, stale facts
- [x] Installation: `pak::pak(...)`, the pin line with `@vX.Y.Z` placeholder and NEWS link, the clone (`pkgload::load_all()`), what runs need (PG* env vars, fwapg / bcfishpass, `ZOTERO_API_KEY`, AWS for `rag/`); published data on `fresh-bc`: `fdis/` and `knowledge/fdis/`
- [x] Example: a few lines reading `data/thresholds.csv` (e.g. CH rearing's components, value and range, `default_value`), run for real, output pasted verbatim
- [x] Stale facts gone or fixed: no FDIS version in prose (v3 is not uploaded, v2 is; see findings); no `0260`–`0298` claim (point at `scripts/README.md`); research covered by the index line

## Phase 5: Learn more, Ecosystem, Data and methods
- [x] Learn more: the chinook rearing article (GitHub path `vignettes/chinook_rearing.Rmd` while #56 is open), the research index, and the grouped reference (`_pkgdown.yml` groups, by `man/` or GitHub while the site is down)
- [x] Ecosystem table per decision 3
- [x] Data and methods: FDIS (Province of BC, with the `fdis/README.md` provenance note), FISS data submissions and the public FISS layers, EcoCat, PSCIS, fwapg, bcfishpass, link's `default` run, wet's flows, Zotero group library; each linked to its own site
- [x] Re-check each `_pkgdown.yml` group `desc:` covers every function listed under it (claim set includes them)

## Phase 6: Citation, License, NOTICE
- [x] `/citation-cff`: `CITATION.cff`, `inst/CITATION`, `.github/workflows/update-citation-cff.yaml`; `Date:` already set
- [x] Enumerate every external read in `scripts/` and `R/` whose output is tracked under `data/` (PSCIS, FISS, FDIS, GNIS, link/fwapg-derived tables …), each with its licence; write `NOTICE.md` by source if any is redistributed beyond the FDIS extract, as `inst/NOTICE.md` (installs with the package; the pkgdown allowlist stays unchanged). A source with an unconfirmed licence → a filed issue, not the NOTICE
- [x] README Citation (`citation("knowledge")`) and License sections

## Phase 7: Review
- [ ] Every function the README names is in `NAMESPACE`; every link resolves (`curl -sIL` each, GitHub ones via `gh api`, noting which wait on #56)
- [ ] Every claim (README, tagline, Title, Description, About, caption, alt text, group `desc:`) enumerated against the code path a run takes
- [ ] `pkgdown::check_pkgdown()`, `devtools::test()`, `lintr` on any R touched; word count before (680) and after, with what set the floor
- [ ] `/code-check branch`, three-round floor, ending on the enumeration

## Phase 8: soul convention
- [ ] soul branch + PR amending `conventions/readme.md` with what this README teaches (a data repo that both installs and publishes; a figure taken as one panel of an article's composite; knowledge's Ecosystem membership as an open question), `Relates to NewGraphEnvironment/soul#416`

## Owed at the end (reported, done after merge)

- [ ] Add knowledge to soul#416's Wave list as done once the PR merges
- [ ] Learn-more links switch from GitHub paths to the pkgdown site when #56 makes it resolve (note on #56)
- [ ] DESCRIPTION `URL`, `inst/CITATION`'s url and `CITATION.cff`'s url name the pkgdown site, which answers 404 until #56; confirm it resolves after the flip
- [ ] #76 (PSCIS Access Only, EcoCat terms) settled before #56's flip; then update `inst/NOTICE.md`
- [ ] #77 scale bar and keymap on `knw_compare_map()`, then rerun `data-raw/readme_figure.R`

## Validation

- [ ] Tests pass
- [ ] `/code-check` clean (once over the branch with `/code-check branch`)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion

Verification: the README example rerun from a clean session prints the pasted output byte for byte; the
figure regenerates identically from `data-raw/readme_figure.R`; `R CMD build` tarball contains
`man/figures/` and no `data-raw/`; the pkgdown workflow's page allowlist passes locally against a
`pkgdown::build_site()` output; `gh repo view --json description` matches the tagline.

