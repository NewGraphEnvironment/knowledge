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
- Project-named repos: three report and planning repos named for their projects (`0100`, `research/stream_temperature.md`).
- No consumer installs `knowledge/pkg` in code; scripts load with `pkgload::load_all("pkg")` (6 scripts).
- `pkgload::load_data()` sources only `.R`/`.rda` at the top of `data/`; none exist today.
- `s3://fresh-bc/fdis/` holds the extract, `queries/`, `fiss-database-structure/`, plus `fissr_explore.sqlite` and
  `derived/` (fdis_sites csv/gpkg, bt_use_visits, ch_rule_visits, ch_rule_walks; `ch_mad_visits` is documented as
  pushed but absent). rtj#397 plans public `fdis/` (source + docs) and `knowledge/` (our published tables); readers go
  by `manifest.json`, as `discharge/fwa/v1/` does.
- Sibling pkgdown pattern: fresh/link/drift (`_pkgdown.yml` with `url:` + bootstrap 5, `.github/workflows/pkgdown.yaml`,
  gh-pages branch).

## Public sweep baseline (Phase 2, 2026-10-16)

`planning/active/public_sweep.py tree` before any clean-up, after two measured false-positive fixes (`63333` inside
decimals such as `0.6333333` in data tables; `M1`-style site labels in data CSVs and the GAM objects `m1..m3` in
`0297`): db 74, host 10, internal_ref 13, key_path 4, password_manager 1, private_repo 23, project_repo 3 (128 hits).
After Phase 2, only README.md (Phase 3) and CLAUDE.md (Phase 5) hit.

## Database connections

- No `PG*` variable is set in the agent shell; with `PGHOST=localhost PGPORT=5432 PGDATABASE=fwapg PGUSER=postgres
  PGPASSWORD=postgres` set, `DBI::dbConnect(RPostgres::Postgres())` reaches fwapg (246 watershed-group polygons).
- `0200` and `0220` recorded `db_source` as `tunnel` / `local_fwapg`; they now record `current_database()`. Old rows
  in `data/<wsg>/fiss_xls_reports.csv` keep the old values. Nothing reads the column but `0220`'s informational check.
- `0260` defaulted `TEMPLATE_DIR` to a local checkout path of the private template; it is now required.

## GitHub text (Phase 5, 2026-10-16)

`public_sweep.py github` before editing: 13 issue bodies, 4 PR bodies and 4 comments carried private-repo links,
machine names, a home path or a project-named repo (the issue's count was 11 / 4 / 1; two of the comments on #56 were
posted during this work, by the bucket-policy session). PR-body `sred` cross-references are the R&D tracking exception
(feature-workflow.md) and are exempt; issue #20's `m1` is a formula term. Each was rewritten in plain words, and #4's
title ("from the M1") renamed. After the edits the GitHub sweep returns no hits.

Earlier revisions stay visible in each item's edit history until deleted in the web UI (the API cannot). The list
is measured, not recalled: `public_sweep.py history` reads every body's and comment's revisions (GraphQL
`userContentEdits`) and reports those whose text hits a pattern. On 2026-10-16 after the edits, 23 items
(code-check round 3 found #19, edited clean before this branch, missing from the first, recalled list):

- https://github.com/NewGraphEnvironment/knowledge/issues/3
- https://github.com/NewGraphEnvironment/knowledge/issues/4
- https://github.com/NewGraphEnvironment/knowledge/issues/4#issuecomment-5527643637
- https://github.com/NewGraphEnvironment/knowledge/issues/4#issuecomment-5546870197
- https://github.com/NewGraphEnvironment/knowledge/issues/5
- https://github.com/NewGraphEnvironment/knowledge/issues/16
- https://github.com/NewGraphEnvironment/knowledge/issues/17
- https://github.com/NewGraphEnvironment/knowledge/issues/18
- https://github.com/NewGraphEnvironment/knowledge/issues/19
- https://github.com/NewGraphEnvironment/knowledge/issues/25
- https://github.com/NewGraphEnvironment/knowledge/issues/33
- https://github.com/NewGraphEnvironment/knowledge/issues/38
- https://github.com/NewGraphEnvironment/knowledge/issues/47
- https://github.com/NewGraphEnvironment/knowledge/issues/51
- https://github.com/NewGraphEnvironment/knowledge/issues/56
- https://github.com/NewGraphEnvironment/knowledge/issues/56#issuecomment-6224964138
- https://github.com/NewGraphEnvironment/knowledge/issues/56#issuecomment-6225367874
- https://github.com/NewGraphEnvironment/knowledge/issues/56#issuecomment-6225458231
- https://github.com/NewGraphEnvironment/knowledge/issues/57
- https://github.com/NewGraphEnvironment/knowledge/pull/26
- https://github.com/NewGraphEnvironment/knowledge/pull/37
- https://github.com/NewGraphEnvironment/knowledge/pull/39
- https://github.com/NewGraphEnvironment/knowledge/pull/49

Branch `11-quick-read-of-the-north-thompson-fish-pa` (open PR #12) goes public with the repo, and two files that exist
only there carry a client project path and database literals (code-check round 3). Git history and `refs/pull/*` are
exempt by the issue's decision, but this is a live branch: accept it, close #12 and delete the branch, or fix the two
files before the flip. The owner's decision.

Issue #4's rename entry ("… from the M1") shows the old title and cannot be deleted (code-check round 2); the sweep now
reads rename entries and reports it. Accepting it or deleting and re-filing #4 is the owner's decision.

The generated conventions below CLAUDE.md's marker carry private-repo references, local paths and host names (39
pattern hits). They are public in the repo, though not on the site. They are synced from soul, so they are fixed at
the source (NewGraphEnvironment/soul issue, filed), and the sweep reports them without failing.

## Errors Encountered

| Error | Resolution |
|-------|------------|
| `0299` upload exit 127 on the README | `system2()` runs a shell, so `text/markdown; charset=utf-8` split at `;`; arguments are now `shQuote()`d |
| `values_differ()` passed a zero-padded `"007"` id read as 7 | numeric comparison now fails any text matching `^[-+]?0[0-9]` |
| `ch_rule_visits.hydro_zone` read as integers (`"08"` → 8) | zero-padded columns are kept as text before writing Parquet |
