# Task: Clean up and make the repo public: package at the root, FDIS on a public prefix (#56)

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

## Decisions taken at plan approval

- **DB:** every script connects with `DBI::dbConnect(RPostgres::Postgres())` (libpq reads `PG*`), keeping only
  non-identity args such as `bigint = "numeric"`. The tunnel-to-local fallback goes: the operator points `PG*` at the
  database the script needs, and each header names the schemas it needs instead of a host/port.
- **FDIS publish:** the raw extract and its docs stay as received under `fdis/`; `fissr_explore.sqlite` and
  `fdis/derived/` move to `s3://fresh-bc/archive/fdis/` (never under `fdis/`, which becomes public whole). The
  visit-level tables (`fdis_sites`, `bt_use_visits`, `ch_mad_visits` if rebuilt, `ch_rule_visits`, `ch_rule_walks`)
  go to `s3://fresh-bc/knowledge/fdis/` as Parquet with a `manifest.json`, written by one new script.
- **The flip itself is after the merge**, on your word: merge, revision deletion in the web UI (yours; the API cannot),
  make public, enable Pages, link#346 edit, rtj#397 apply. This run ends at the open PR.

## Phase 1: Package at the root
- [x] `git mv pkg/{DESCRIPTION,NAMESPACE,LICENSE,NEWS.md,R,man,tests} .`; merge `pkg/.Rbuildignore` into a root one
      excluding `^data$`, `^scripts$`, `^planning$`, `^research$`, `^\.claude$`, `^\.Rprofile$`, `^CLAUDE\.md$`,
      `^docs$`, `^_pkgdown\.yml$`, `^\.github$`, `^\.git$`, `^\.DS_Store$`; remove `pkg/`
- [x] DESCRIPTION gains `URL` (site + repo) and `BugReports`
- [x] Test pinning the standing rule: no `.R`/`.rda`/`.RData` at the top of `data/` (skips when `data/` is absent,
      i.e. under `R CMD check`); restore-the-bug check that it fires
- [x] Scripts load with `pkgload::load_all(quiet = TRUE)` from the root (0100, 0110, 0240, 0250, 0260, 0280); comments
      saying "pkg/" reworded
- [x] `devtools::document()`, `devtools::test()`, `devtools::check()` clean

## Phase 2: Clean the live files
- [x] Sweep script `planning/active/public_sweep.sh`: one pattern list (DB literals, key path, password-manager names,
      host names, private repos, project-named repos, the comms/skill refs) run over the tree minus exemptions
      (`planning/archive/`, `scripts/logs/`, literature quotes) and over issue/PR bodies and comments; baseline its
      output into findings.md
- [x] DB connections → `PG*` in all 17 scripts and `knw_pscis_pull()`'s example; headers name required schemas;
      fallback blocks removed; `scripts/README.md` "Database access" text rewritten
- [x] `0153`: key from `ZOTERO_API_KEY` only (exit with a clear message if unset); `0270`'s docstring follows
- [x] Host names reworded (`research/bt_spawning.md`, `research/fdis_export.md`, `0156`)
- [x] Private-repo links → plain words or dropped (README, scripts, research, `data/temperature_members.csv` note text,
      `scripts/README.md`'s `db-newgraph` pointer)
- [x] Project-named repos reworded (`0100`, `research/stream_temperature.md`)
- [x] `git rm -r comms/`; filed NewGraphEnvironment/soul#438 to drop knowledge from `conventions/comms_peers.md`
- [x] Sweep over the tree returns only exempt hits (left: README, rewritten in Phase 3; CLAUDE.md, Phase 5)

## Phase 3: pkgdown site
- [x] `_pkgdown.yml` (url `https://newgraphenvironment.github.io/knowledge/`, bootstrap 5, reference index grouping
      the `knw_*` readers/builders) and `.github/workflows/pkgdown.yaml` copied from fresh
- [x] Root README rewritten as the public home page: what the repo is, install
      (`pak::pak("NewGraphEnvironment/knowledge")`), layout, the three tracks, and links to `research/README.md` and
      each research file (GitHub URLs, since `research/` is not in the build)
- [x] `pkgdown::build_site()` locally builds with no warnings; `docs/` ignored

## Phase 4: FDIS on a public prefix
- [x] `s3://fresh-bc/fdis/README.md` rewritten with the provenance note (received from the Province of BC, FDIS,
      exports dated 2020-11-16 and 2022-03-22, supplied for the 2021–22 channel-width and fish-density work; published
      with the Province's agreement, 2026-10-16); a tracked copy at `data/fdis_README.md` is the source
- [x] Move `fdis/fissr_explore.sqlite` and `fdis/derived/` to `s3://fresh-bc/archive/fdis/`; `MANIFEST.md5` rewritten without
      the sqlite line (original kept beside it in the archive); a fresh sync verifies 26/0
- [x] New `scripts/0299-fdis-publish.R`: reads `data/fdis/derived/*` visit tables, writes Parquet + `manifest.json`
      (id, built, knowledge commit, per-file rows/bytes/sha256, producing script, source note) to
      `s3://fresh-bc/knowledge/fdis/v1/` (review G6); `PULL=TRUE` restores the CSVs (G4); `scripts/README.md`'s per-script `aws s3 cp … fdis/derived/` lines replaced by it;
      `0230`'s sync excludes nothing new (derived no longer under `fdis/`)
- [x] Run it; read back each Parquet and compare values with an all-character read of the CSV (review G11)
- [x] `research/fdis_export.md` Provenance and CLAUDE.md's FDIS note: public, with the note, and where each part lives

## Phase 5: CLAUDE.md, visibility, GitHub text
- [x] Rewrite CLAUDE.md's repo-specific top half for a public reader (Database access → `PG*`; Zotero → env vars, no
      1Password/cyclops; no host names; layout at root; "One discipline" restated without "private repo")
- [ ] `.claude/visibility` → `public`; `/claude-md-init --public-clean`; grep that internal-only conventions are gone
- [ ] Edit the issue bodies, PR bodies and the comment the sweep lists (11 / 4 / 1 per the issue) via `gh`;
      list each URL whose earlier revisions you must delete in the web UI
- [ ] Final sweep (tree + GitHub text) returns nothing outside the exemptions; output saved to findings.md

## Validation
- [ ] Tests pass; `devtools::check()` clean
- [ ] Each script that loads the package starts from the root; 0280 runs end to end (read-only gate); writers whose
      inputs are available reproduce their tracked outputs (`git diff --stat data/` empty)
- [ ] `/code-check branch` clean (three-round floor)
- [ ] PWF checkboxes match landed work
- [ ] `/planning-archive`, then `/gh-pr-push`

## After merge (not in this run; each on your word)
1. Delete earlier revisions of the edited issue/PR bodies in the web UI (list provided in the PR).
2. Make the repo public; enable Pages on gh-pages.
3. rtj#397: apply the bucket policy for `fdis/` and `knowledge/`.
4. link#346: name this repo and link #57.
5. Drop the `fdis-public-release` memory.

## Risks
- S3 moves/uploads to `fresh-bc` may be refused in auto mode as a production write; if so I hand you bare commands.
- The DB change means a script now fails loudly where it used to fall back; that is the intended behaviour.
