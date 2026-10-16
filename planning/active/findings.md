# Findings — Clean up and make the repo public (#56)

## Issue context

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
- an unused `comms/` directory (README only);
- the package in `pkg/`, so it does not install or build a pkgdown site the standard way.

The FDIS electrofishing extract was held back because it came with no use terms. The Province is fine with it
being public, provided it ships with a note of when and from where it was received.

## Proposed

### 1. Clean the live files
- [ ] Database connections read the standard `PG*` environment variables; no host, port or login in code or docs
- [ ] Zotero credentials read from environment variables; no key-file path or password-manager references
- [ ] Host names in research text reworded
- [ ] Private-repository links in live files become plain words or are dropped
- [ ] The one field-project name reworded
- [ ] Delete `comms/`; remove the repo from the comms peer list (separate change where that list lives)

Left as they are: `planning/` archives, run logs (they record the machine a run used), git history, S3 paths,
public funder names in area briefs, and the literature table's cited quotes.

### 2. Package at the root, with pkgdown
- [ ] `git mv` DESCRIPTION, NAMESPACE, LICENSE, NEWS.md, `R/`, `man/`, `tests/` from `pkg/` to the root
- [ ] Root `.Rbuildignore` excludes `data`, `scripts`, `planning`, `research`, `.claude`, `.Rprofile`, `CLAUDE.md`,
      `docs`, `_pkgdown.yml`, `.github`; a standing rule that no `.R` or `.rda` file sits at the top of `data/`
- [ ] Scripts load with `pkgload::load_all()`; update the layout in CLAUDE.md and `scripts/README.md`
- [ ] Standard pkgdown site on GitHub Pages; research files linked from the home page
- [ ] `devtools::check()` clean; each script that loads the package runs from the root

### 3. FDIS on a public prefix
- [ ] Provenance note (when and from where) as the README of the published folder, and in `research/fdis_export.md`
- [ ] Raw extract (as received, with `MANIFEST.md5`) and the visit-level tables built from it, as Parquet with a
      manifest, on a public prefix of the project bucket (the bucket policy change is NewGraphEnvironment/rtj#397)
- [ ] CLAUDE.md's FDIS note updated: public, with the note

### 4. CLAUDE.md and the flip
- [ ] Rewrite the repo-specific top half of CLAUDE.md for a public reader; sync conventions in public-safe form;
      set `.claude/visibility` to `public`
- [ ] Edit the 11 issue bodies, 4 PR bodies and 1 comment that link private repositories or name machines, and
      delete each earlier revision from its edit history in the web UI (GitHub shows edit history to anyone who can
      read it, and the API cannot delete revisions)
- [ ] Final sweep: the same pattern search over the tree and over issue and PR bodies returns nothing outside the
      exemptions above
- [ ] Make the repository public
- [ ] After the flip, NewGraphEnvironment/link#346 names this repo and links #57 (it says "the evidence repo" until then)

## Follows from this
- Multi-species tuning (#57): one evidence build and one tuning run across species and life stages, as package functions
- link: a province-wide `default` run (NewGraphEnvironment/link#246); then its threshold tuning moves here and its validation reads public tables (NewGraphEnvironment/link#346)
- Bucket (NewGraphEnvironment/rtj#397): a public prefix for FDIS and tuning results

## Measured during planning (2026-10-16)

- DB literals (`host="localhost"`, `63333`, `user="newgraph"`, `postgres/postgres`, `:5432`) in 17 scripts, in
  `pkg/R/pscis.R`'s example (+ its `.Rd`), `scripts/README.md` and CLAUDE.md. Six scripts fall back from the tunnel
  DB to a local fwapg (`0162`, `0200`, `0220`).
- Zotero key path `~/.config/newgraph/zotero-api-key` in `0153` (`0270` points at it).
- Hosts: `m4`/`Dropbox (m4)` in `research/bt_spawning.md`, `research/fdis_export.md`; `M1` in `0156`.
- Private-repo links: `fish_passage_template_reporting` (14 live refs: README, `0153`, `0154`, `0156`, `0160`,
  `0200`–`0220`, `scripts/README.md`, two research files, `data/temperature_members.csv`), `logic#4` in
  `research/stream_temperature.md`; `db-newgraph` skill in `scripts/README.md`. link, fwapg, wet, cred, fresh,
  bcfishpass are public and stay.
- Project-named repos: `fish_passage_skeena_2022_planning` (`0100`), `fish_passage_skeena_2025_reporting`,
  `fish_passage_elk_2022_reporting` (`research/stream_temperature.md`).
- No consumer installs `knowledge/pkg` in code; scripts load with `pkgload::load_all("pkg")` (6 scripts).
- `pkgload::load_data()` sources only `.R`/`.rda` at the top of `data/`; none exist today.
- `s3://fresh-bc/fdis/` holds the extract, `queries/`, `fiss-database-structure/`, plus `fissr_explore.sqlite` and
  `derived/` (fdis_sites csv/gpkg, bt_use_visits, ch_rule_visits, ch_rule_walks; `ch_mad_visits` is documented as
  pushed but absent). rtj#397 plans public `fdis/` (source + docs) and `knowledge/` (our published tables); readers go
  by `manifest.json`, as `discharge/fwa/v1/` does.
- Sibling pkgdown pattern: fresh/link/drift (`_pkgdown.yml` with `url:` + bootstrap 5, `.github/workflows/pkgdown.yaml`,
  gh-pages branch).

## Errors Encountered

| Error | Resolution |
|-------|------------|
