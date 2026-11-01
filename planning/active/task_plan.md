# Task: Clean up and make the repo public: package at the root, FDIS on a public prefix (#56)

## Problem

The repo is private, but almost nothing in it needs to be. A measured pass (2026-10-16) found:
- no secrets anywhere in history (gitleaks, all commits);
- no client planning or proposals; one field-project name in one file;
- machine-setup details (database connections, a local key-file path, host names) in 25 live files;
- links to private repositories or machine names in 14 live files, 11 issue bodies, 4 PR bodies and 1 comment;
- an unused cross-repo messaging directory (README only);
- the package in `pkg/`, so it does not install or build a pkgdown site the standard way.

The FDIS electrofishing extract was held back because it came with no use terms. The Province is fine with it
being public, provided it ships with a note of when and from where it was received.

This branch is the post-flip remainder: the repo went public on 2026-11-01 and the pkgdown site and the bucket grant are live.

## Decided at the gate (Al, 2026-11-01)

- **This PR closes #56.** Each item it leaves open moves to its own home:
  - the licences go to #76;
  - the post goes to new_graphiti#8;
  - the peer list goes to soul#438;
  - the edit-history revisions, #4's retitle entry and the PR #12 branch were already accepted at the flip.
- **soul#438 gets its own soul PR from this run.** Al merges it.
- Mechanism (no question needed):
  - DESCRIPTION `URL` and `_pkgdown.yml` keep the github.io form, which is what link and fresh use and which
    redirects.
  - README links use the `www.newgraphenvironment.com/<pkg>/` form that the README's Ecosystem table already uses.

## Phase 1: README points at the public site
- [x] Learn more: change the chinook article link to `https://www.newgraphenvironment.com/knowledge/articles/chinook_rearing.html`,
      and the function reference link to `.../knowledge/reference/index.html`
- [x] Learn more: add the methodology article (`.../articles/habitat_thresholds.html`, "Choosing habitat thresholds
      from where fish were caught"), which the site now carries and the chinook article links
- [x] Change the NEWS link (README:30) to the site's `news/index.html`. Keep `scripts/README.md`, `research/README.md`,
      `LICENSE` and `inst/NOTICE.md` on GitHub, because the site does not render them
- [x] Confirm that DESCRIPTION `URL`, `inst/CITATION` (`citation("knowledge")` takes the first URL) and `CITATION.cff`
      `url` resolve (curl -L, 200). No edit unless one fails

## Phase 2: clear the pre-flip wording
- [x] `CLAUDE.md:11-13`: the repo is public (2026-11-01, #56), with the site at its URL, and the stale
      "PRIVATE"/"not advertised" clause removed
- [x] `CLAUDE.md:122`: the flip went ahead with #76's EcoCat and bcfishpass rows still open (Al, 2026-11-01), and #76
      is still where they settle
- [x] `scripts/0325-publish.R:16-17`: the prefix is public, so `PUBLISH=TRUE` makes a version readable by anyone on
      upload (fresh-bc's `PublicReadPrefixes` grants `knowledge/*`)
- [x] `research/fdis_export.md:32`: both prefixes are readable without credentials (anonymous GET 200, measured
      2026-11-01), and the bucket still does not list. Update the file's Verified line
- [x] `scripts/0299-fdis-publish.R:35`: `NO_SIGN=TRUE` reads without credentials, the prefix is public (found by the plan review)
- [x] Re-run the grep for flip wording over the tree, outside `planning/archive/` and `scripts/logs/`, and expect
      nothing that describes knowledge as private or not yet public

## Phase 3: cross-repo bodies and soul#438
- [ ] link#346 body: replace "a private repository" with `NewGraphEnvironment/knowledge`, linked to its #57.
      "That evidence repository is moving to public" becomes "is public (2026-11-01)". Part 2's heading drops
      "(once the evidence repo is public)"
- [ ] #76 body: its last task becomes "flipped with EcoCat and bcfishpass open, on Al's word (2026-11-01)". The
      task is no longer a gate before the flip
- [ ] soul: a branch from origin/main that removes `- knowledge` from `conventions/comms_peers.md`.
      Run `/code-check` (convention edit, through its issue) and open a PR that closes soul#438.
      The PR text and the commits name no private detail. No merge
- [ ] #56 body: tick what landed. Each item it leaves open names its home:
  - the peer list → the soul PR;
  - the licences → #76;
  - the post → new_graphiti#8;
  - the revisions and the retitle entry → accepted 2026-11-01.

## Owed at the end (reported, done after merge)

- [ ] After this PR merges, confirm that the site's home page (built from README) carries the new Learn more links
      by fetching the page, not by reading the run status
- [ ] soul PR for #438 merged (Al)

## Validation

- [ ] Tests pass: `devtools::test()`. Most test files do not read README or CLAUDE.md, but the test count still
      checks the tree
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive` on completion, then `/gh-pr-push` with `Fixes #56` and the SRED cross-reference

Verification:
- Every link changed in README is fetched with `curl -L` and returns 200.
- The flip-wording grep returns nothing that describes knowledge as pre-flip.
- `gh issue view` re-reads each edited body (link#346, #76, #56) after the edit.
- The soul PR's diff is one line.
- `public_sweep.py` from #58's archive runs over the tree and the edited bodies before the PR.
