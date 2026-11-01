# Findings — Clean up and make the repo public: package at the root, FDIS on a public prefix (#56)

## Issue context

**Status (2026-10-16):** everything below except the flip landed in #58. This issue stays open until the owner has deleted the earlier revisions of the edited text, decided on #4's retitle entry and on the branch behind PR #12, made the repository public, enabled Pages, updated NewGraphEnvironment/link#346, and published the habitat rules article. The bucket policy is already applied: fresh-bc's `PublicReadPrefixes` statement grants `fresh-bc/fdis/*` and `fresh-bc/knowledge/*` (NewGraphEnvironment/rtj#397, closed; `aws s3api get-bucket-policy`, read 2026-11-01), so a `PUBLISH=TRUE` run of `scripts/0325-publish.R` is public on upload. That script's header (lines 16-17) still says a reader needs credentials until the policy is applied; correct it with the flip. The steps and the gate are in #58's Notes.

**If done:** the habitat evidence, the tuning method and its results are open: anyone can install the package, read
the research, and pull the FDIS evidence the thresholds rest on. Link's validation and later work can read public
tables instead of a local clone. **If never:** the work stays visible only to us, link cannot cite it, and every
species tuned later inherits the same wall.

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

## Proposed

### 1. Clean the live files
- [x] Database connections read the standard `PG*` environment variables; no host, port or login in code or docs
- [x] Zotero credentials read from environment variables; no key-file path or password-manager references
- [x] Host names in research text reworded
- [x] Private-repository links in live files become plain words or are dropped
- [x] The one field-project name reworded
- [x] Delete the messaging directory
- [ ] Remove the repo from the comms peer list (separate change where that list lives; filed there)

Left as they are: `planning/` archives, run logs (they record the machine a run used), git history, S3 paths,
public funder names in area briefs, and the literature table's cited quotes.

### 2. Package at the root, with pkgdown
- [x] `git mv` DESCRIPTION, NAMESPACE, LICENSE, NEWS.md, `R/`, `man/`, `tests/` from `pkg/` to the root
- [x] Root `.Rbuildignore` excludes `data`, `scripts`, `planning`, `research`, `.claude`, `.Rprofile`, `CLAUDE.md`,
      `docs`, `_pkgdown.yml`, `.github`; a standing rule that no `.R` or `.rda` file sits at the top of `data/`
- [x] Scripts load with `pkgload::load_all()`; update the layout in CLAUDE.md and `scripts/README.md`
- [x] Standard pkgdown site on GitHub Pages; research files linked from the home page
- [x] `devtools::check()` clean; each script that loads the package runs from the root

### 3. FDIS on a public prefix
- [x] Provenance note (when and from where) as the README of the published folder, and in `research/fdis_export.md`
- [x] Raw extract (as received, with `MANIFEST.md5`) and the visit-level tables built from it, as Parquet with a
      manifest, on a public prefix of the project bucket (readable once the bucket policy change, tracked in our
      infrastructure repo, is applied after the flip)
- [x] CLAUDE.md's FDIS note updated: public, with the note

### 4. CLAUDE.md and the flip
- [x] Rewrite the repo-specific top half of CLAUDE.md for a public reader; sync conventions in public-safe form;
      set `.claude/visibility` to `public`
- [x] Edit the issue bodies, PR bodies and comments that link private repositories or name machines (13 issue
      bodies, 4 PR bodies and 5 comments, more than the first count found)
- [ ] Delete each earlier revision of that text from its edit history in the web UI (GitHub shows edit history to
      anyone who can read it, and the API cannot delete revisions); `public_sweep.py history` in #58's archive lists them
- [x] Final sweep: the same pattern search over the tree and over issue and PR bodies returns nothing outside the
      exemptions above, except #4's retitle entry, which cannot be deleted (accept it, or delete and re-file #4)
- [x] The README brought to the readme convention (#75, PR #78), before the flip (decided 2026-10-20)
- [ ] The licences of the data tracked under `data/` settled (PSCIS settled 2026-11-01; flipped with the EcoCat and bcfishpass rows still open, on Al's word) (#76: the PSCIS layers are "Access Only" in the BC Data Catalogue; EcoCat- and bcfishpass-derived files' terms unread), before the flip
- [x] Make the repository public (2026-11-01, on Al's word: the remaining edit-history revisions, #4's retitle entry and the branch behind PR #12 accepted as they are; the PSCIS snapshots settled in #76)
- [ ] After the flip, once the pkgdown site resolves: switch the README's Learn more links (the article, the function reference) from GitHub paths to the site, and confirm DESCRIPTION `URL`, `inst/CITATION` and `CITATION.cff`, which all name the site, resolve (from #75)
- [ ] After the flip, NewGraphEnvironment/link#346 names this repo and links #57 (it says "the evidence repo" until then)
- [ ] After the flip, once the pkgdown site and source resolve: publish the article on how habitat rules are tested and carried onto the floodplain as a post on NewGraphEnvironment/new_graphiti. It says all of its packages are open and links this repo's documentation, so it cannot go up before the flip. A branch on that public repo is already public, so nothing goes there first

## Follows from this
- Multi-species tuning (#57): one evidence build and one tuning run across species and life stages, as package functions
- link: a province-wide `default` run (NewGraphEnvironment/link#246); then its threshold tuning moves here and its validation reads public tables (NewGraphEnvironment/link#346)
- Bucket (a policy change in our infrastructure repo): a public prefix for FDIS and tuning results

## State measured at plan time (2026-11-01)


knowledge went public on 2026-11-01 (`gh repo view`: PUBLIC). The pkgdown site is live: github.io answers with a
301 to `https://www.newgraphenvironment.com/knowledge/`, and the home page, both articles, the reference index and
the news page all return 200. The gh-pages deploy names 365e0c6, the tip of main. The bucket grant is live too: an
anonymous GET of `fdis/README.md` and `knowledge/fdis/v2/manifest.json` returns 200. `knowledge/thresholds/v1` and
`fdis/v3` return 403 because nobody has uploaded them yet (the bucket does not list, so a missing key reads 403).

The in-repo items #56 still has open are these:
- README "Learn more" still links GitHub source paths for the article and the function reference.
- The text that goes stale at the flip has not been updated:
  - `CLAUDE.md:11-13` says the repo "still read PRIVATE" and that the site is "not advertised".
  - `CLAUDE.md:122` says #76 is "to settle before the repo is public".
  - `scripts/0325-publish.R:16-17` says "public only once the bucket policy of #56 is applied; until then a reader
    needs credentials".
  - `research/fdis_export.md:32` says "readable without credentials once the bucket policy grants them".
- Cross-repo items: link#346 still calls this repo "a private repository" and "the evidence repo". soul#438 is
  open to remove knowledge from soul's comms peer list (`- knowledge` sits at `conventions/comms_peers.md:47` on
  soul origin/main). The new_graphiti post is now its own issue (new_graphiti#8).

## Errors Encountered

| Error | Resolution |
|-------|------------|
