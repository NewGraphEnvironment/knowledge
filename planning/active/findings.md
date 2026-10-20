# Findings — README: bring it to the readme convention and describe the habitat-threshold work (#75)

## Issue context

**If done:** a stranger landing on the repo (or on the website's copy, which follows the README) learns what knowledge is, why it matters for link's habitat model, and how to read its tuned thresholds, from text that matches the code. **If never:** when #56 makes the repo public, its front page describes the repo as it stood in mid-October: an inventory of folders, an evidence version two behind, and none of the province-wide tuning.

## Problem

The README was last rewritten before #57. It is close to correct on the report corpus and the fish records, but out of date on the habitat thresholds, which are now most of the work, and it predates `conventions/readme.md` (NewGraphEnvironment/soul#416's README wave).

## Decided (2026-10-20)

- **Figure:** the Bulkley chinook rearing map the article already draws.
- **Hex sticker:** make one (soul's `templates/make_hexsticker.R` into `data-raw/`).
- **Order:** this lands before #56 makes the repo public.

## Findings

Audited 2026-10-20 against `main` @ `1500a9f` (v0.4.6). Verify each against the code before acting.

**Stale**
- The Data section names `knowledge/fdis/v2/`; `0299` publishes `knowledge/fdis/v3`.
- The "Three tracks" table gives the habitat-threshold scripts as `0260`–`0298`; the province-wide run is `0300`–`0330` (wait for link's run, evidence build, tuning, publish, compare).
- "What is known" lists 8 topics and leaves out `research/habitat_thresholds_tuned.md` (every species and stage in one run) and the six per-species files (bull trout, coho, grayling, rainbow, steelhead, westslope cutthroat).
- DESCRIPTION `Description` names crossing layers, past-report tables and GNIS only, and the GitHub About says "report corpus, FISS data, priority farming". Neither mentions thresholds, though two of the seven `_pkgdown.yml` reference groups ("Tuning", "Published results and comparison") are that work.
- The article link points at the pkgdown site, which answers 404 while the repo is private (#56).

**Against `conventions/readme.md`**
- The opening is an inventory ("Three things live here together") and does not say what decision the work informs (link's habitat thresholds, and through them restoration planning).
- No hex sticker, no lifecycle badge or pin line, no figure, an example with no output, no Learn more (the chinook rearing article, then the grouped function reference), no Ecosystem, no Data and methods (FDIS from the Province, FISS, EcoCat, fwapg, bcfishpass, link), and no Citation (no `CITATION.cff` or `inst/CITATION`).

**Leave out until shipped**
- `thresholds/v1` and `habitat_grade/v1` are built but not uploaded (`PUBLISH=TRUE` still open). `data/thresholds.csv` is tracked and can be described; the Parquet sets are named once uploaded.

## Tasks

- [ ] Hex sticker: `data-raw/make_hexsticker.R` from soul's template writes `man/figures/logo.png`, on the title line at the convention's size.
- [ ] Opening: one to three sentences on what knowledge is, the data it works on, and the decision it informs; written together with the tagline, DESCRIPTION `Title`/`Description` (then `devtools::document()`) and the GitHub About (`gh repo edit --description`).
- [ ] Figure: `data-raw/readme_*.R` writes `man/figures/readme-*.png`, the Bulkley chinook rearing map from the article's data, styled through gq, checked at its published width, with alt text and a caption saying what it shows.
- [ ] Lifecycle badge and the pin-a-release line after the install command.
- [ ] Example: a few lines reading the tuned thresholds from `data/thresholds.csv`, with the output it really prints.
- [ ] Fix the stale facts above (fdis/v3, the `0300`–`0330` run, the research list).
- [ ] Learn more: the article and the reference groups, linked where the site resolves (GitHub paths while #56 is open).
- [ ] Ecosystem with the membership and wording decided in NewGraphEnvironment/soul#416; Data and methods naming each source, linked to its own site.
- [ ] Citation and License (`/citation-cff`; New Graph is the publisher, never an author). A NOTICE only if the read of what `scripts/` loads finds redistributed data beyond the FDIS extract, whose provenance note exists.
- [ ] Review: every claim against the code path a run takes, every function named is exported, every link resolves.
- [ ] Amend `conventions/readme.md` with what this README teaches (Relates to NewGraphEnvironment/soul#416).

## Context

Models: link PR #340, wet PR #96 (wet#75), fly PR #105. The README today is 680 words; link's is 595 and wet's 582.


## Errors Encountered

| Error | Resolution |
|-------|------------|
