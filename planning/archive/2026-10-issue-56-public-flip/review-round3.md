# Code review, round 3: branch 56-clean-up-and-make-the-repo-public-packag (HEAD 2b3a042)

I read the diff, the round 1 and round 2 files, and these in full: 0299, 0230, public_sweep.py, the pkgdown workflow,
0260, and the relevant parts of 0200, 0210, 0220 and 0240. Probes were read-only: `gh api` GET and GraphQL queries,
`aws s3 ls`, and `aws s3 cp` from the bucket into the scratchpad. Their helper scripts are in the scratchpad.
Nothing was written to S3, a database or GitHub. The only repo file written is this one.

## Mechanism

Every guard on this branch that decides "done" or "clean" reads a list or a marker the author wrote down from what
they already knew. Nothing ties that list to the population the claim is about. These pairs happened to agree when
each guard was written:
- the sweep's surfaces and patterns, against what actually becomes public. They missed non-UTF-8 files, rename
  events and CLAUDE.md below its marker. Below they also miss edit histories and project slugs that are not repo
  names.
- a marker file's presence, against the set of files a step wrote. MANIFEST.md5 arrived before the files it lists.
- a version label, against the bytes published under it (the v1 overwrite).
- "public", against "listable" (`aws s3 sync`).
- a declaration that was added, against the one already there (`const A`).

The fix each time was to measure the real set. The same shape holds wherever a list was derived from the current
state, not from the full population. Two cases remain:
- The revision-deletion list was built from the items this session edited, not from the items whose history holds a
  hit.
- The `project_repo` pattern was built from repo names, not from the class "client or project identifiers".

## Enumeration

### What becomes public at the flip, against what the sweep reads

| Surface | Verdict | Evidence |
|---|---|---|
| Tracked tree at HEAD, including binary files | **Does not hold for project identifiers** | The tree sweep is clean, but `data/context_bowron_mcgregor.md:3` names the QGIS project `<client project slug>`. That is the `<client>_<region>_<year>` form. `project_repo` matches only `…_\d{4}_(reporting\|planning)` and `fish_passage_x_yyyy`, so it cannot see it. This is the issue's own "one field-project name in one file". Its checkbox is still open in findings.md:30, and Phase 2 of task_plan.md replaced it with the repo-name items. No other `[a-z]+_[a-z]+_20xx` slug sits outside the exemptions. The host exemption for every `.csv` hides only site labels M1/M4 in `priority_farmed_all.csv`. There is no Dropbox, cypher or tailnet text in any csv, and 0297 has no host hits. Email addresses: only `al@newgraphenvironment.com` (DESCRIPTION, Rd). No `/home/` or IP literals. |
| CLAUDE.md below the marker | Reported, not failed (accepted) | `generated()` counts it. |
| `planning/`, `scripts/logs/` | Exempt by decision, **but CLAUDE.md says the opposite** | 98 of 313 tracked files there carry 2,671 pattern hits (2,372 of them `local_path`). It also holds the slugs `<client project slug>` and `<a second slug>`. See the third finding. |
| Issue and PR titles and bodies, conversation comments, review comments, review bodies | Holds | Current text is swept. First-match masking was checked in round 2. |
| Rename events | Holds | Swept since round 2. The only hit is #4 (known). |
| **Edit histories of bodies and comments** | **Does not hold** | The sweep does not read them. The deletion list in findings.md:111-136 is the items this session edited. Measured with GraphQL `userContentEdits` across all 57 items: 35 bodies and 5 comments have histories, and old revisions carry hits on 23 items. Every one is on the list except #19, #20, #43, #45, #50 and #53. #20 is the `m1` formula term. #43, #45, #50 and #53 are the allowed `sred` reference. **#19 is a real miss:** its 2026-09-26T05:53Z and 2026-09-29T04:20Z revisions name `fish_passage_template_reporting`. They were edited out on 2026-09-30, before this branch, so its current body is clean and the list never saw it. |
| This branch's commit messages | Holds | `origin/main..HEAD`. A stale `origin/main` widens the range, so it fails toward fail. The branch is not pushed yet: the API lists only `main` and the #11 branch. |
| Other live branch `11-quick-read-of-the-north-thompson-fish-pa` (open PR #12) | Exempt as history / `refs/pull/*` by decision. **Owner should confirm** | It holds 9 unmerged commits. Its tip tree carries 117 pattern hits, mostly old CLAUDE.md, pkg/R/pscis.R, 0100 and scripts/README.md, which the forward fix supersedes on main. Two of those files exist only on that branch, so main's clean-up never reaches them. `scripts/0106-reports-sites-geojson.R` has the tunnel/63333 and postgres/postgres literals. `scripts/0107-report-sites-crossings-join.R:25` has `<home>/<gis dir>/<client project slug>/…`, a client project slug inside a home path. The open PR's "Files changed" tab shows both. Deleting the branch does not remove `refs/pull/12/head`. |
| Actions runs and artifacts | Holds | 0 runs, 0 artifacts. Runs after merge build only public content. |
| `gh-pages` branch, created by the deploy after merge | Holds | Build output only, behind the page check below. Pages is not enabled (404), so nothing is served before the flip. |
| Wiki, discussions, releases, tags, milestones, commit comments, labels, environments, deployments, description, topics, homepage | Holds | Wiki has no pages, discussions are off, 0/0/0/0, labels are the defaults, 0 environments, 0 deployments. The description is generic, topics are empty and homepage is null. |
| `s3://fresh-bc/fdis/` and `knowledge/`, public once rtj#397's policy is applied | Holds | 28 + 6 objects. `fdis/README.md` is byte-identical to the tracked `data/fdis_README.md`. The sqlite and `derived/` are gone from `fdis/`. manifest.json's provenance and `source_csv` paths are clean. The Parquet text columns have no pattern hits except one `site_visit` id, which is data. One caveat: `published_from_commit` is `f2e17aa`, which is not on GitHub until this branch is pushed. A merge-commit merge keeps it reachable. A squash or rebase would orphan it, and 0299 does not check that HEAD is pushed. |

### A file's or object's presence taken as proof that a step completed

| Place | Verdict | Evidence |
|---|---|---|
| 0230, `NO_SIGN=TRUE` | Holds | The manifest goes to `.part`, then the keys, then a rename into place. The md5 check over every listed path runs on every start, so presence only gates the fetch. |
| 0230, credentialed `aws s3 sync` | **Does not hold (recoverability)** | See the second finding. The round-2 fix covered one of the two branches that share the marker. |
| 0230 outputs (`build/*.rds`, `reconcile.csv`) | Holds | All are written at 0230:369-372, after every reconciliation `stop()`. |
| 0240 reading 0230's outputs | Holds | It reads all three in one generation, and 0230 writes them together. |
| 0299 publish | Holds | Parquet first, manifest last. The schema guard was checked in round 2. A failure mid-upload leaves new Parquet under the old manifest, and PULL's sha256 check then fails loudly. |
| 0299 guard probe | Holds | Exit ≠ 0 with empty output means "not published" (round 2). |
| **0299 `PULL=TRUE` output** | **Does not hold** | See the third finding. |
| 0299 clean-tree check | Holds | It covers tracked files. The ignored input CSVs are recorded by sha256 and mtime instead. |
| 0260 | Holds | It requires `TEMPLATE_DIR` and `file.exists(src)`. The output is tracked, so an overwrite of the hand edits shows as a git diff and can be reverted. |
| 0200 outputs | Holds | `fiss_xls_reports.csv` is written first. On `fetch_failed`, or with no links, the old manifest is deleted before the stop (0200:141-151). |
| 0210 | Holds | It fetches per run, needs a 200, a size > 0 and `readxl_ok`, and asserts the log rows equal the manifest rows. |
| 0220 | Holds | Reconcile A compares the reports' `n_xls` total with the manifest URLs, and the manifest URL set with the fetch log's, then stops before any site table is written. With no connection the clip block stops before writing the WSG deliverable. `db_source` starts as NA. |
| pkgdown page check | Holds | It is an allowlist over `docs/*.html` and `docs/*.md`, so it fails on anything not listed. `build_site_github_pages()` writes to `docs`, the same folder the deploy step reads. CLAUDE.md is removed before the build. Root `.md` files are now README, NEWS and CLAUDE. |
| `test-data-dir.R` | Holds | It skips when `data/` is absent (round 1). |
| `wf_*.js` `harvest_dir` | Pre-existing, not in this diff | Only `wf_peace_report_harvest.js` throws when it is missing. `wf_report_harvest.js`, `wf_bowr_mcgr_harvest.js` and `wf_keyword_backfill.js` use `A.harvest_dir` unguarded, and `wf_farm_priority.js` builds `undefined/<code>__<id>.pdf`. A missing argument becomes a prompt to download "into undefined". This is the same fix landing in one of several callers. Noted only. |

## Findings

- **[security] data/context_bowron_mcgregor.md:3**: `` `<client project slug>` QGIS project `` is a client project
  identifier. It will be public in the tree at the flip.
  - It is the "one field-project name in one file" the issue lists (findings.md:14, 30). That checkbox was never
    carried into task_plan.md, which substituted the repo-name items.
  - `public_sweep.py`'s `project_repo` pattern (line 26) matches only repo-shaped names, so the "final sweep clean"
    in Phase 5 did not and could not check it.
  - Fix: reword the line, for example "now in one QGIS field project". Widen `project_repo` with
    `\b[a-z]+_[a-z]+_20\d{2}\b`. In the tree outside the exemptions, that pattern matches only this one line.

- **[fragile] scripts/0230-fdis-load.R:63, 80-83. INSIDE ROUND-2 FIX.** The round-2 fix moved `MANIFEST.md5` last
  only in the `NO_SIGN` branch. The credentialed branch still runs `aws s3 sync`, which writes keys in arbitrary
  order, and line 63 still treats `MANIFEST.md5`'s presence as "cache complete".
  - A sync that fails after the manifest has landed leaves the cache unrecoverable by re-running. Every later run
    skips the sync and stops at line 90 with `md5 mismatch`, and nothing tells the operator to delete the manifest.
  - It fails loudly and loses no data.
  - Fix, since sync is idempotent: on an md5 mismatch in the credentialed branch, sync again before stopping. Or
    gate the fetch on the md5 check rather than on the file's presence.

- **[fragile] scripts/0299-fdis-publish.R:88-90**: `PULL=TRUE` writes each CSV in place with `write_csv_arrow(…, out)`
  and never checks it afterwards.
  - An interrupted write leaves a truncated `data/fdis/derived/<table>.csv`. Its presence then does two things:
    1. It blocks a re-run (line 89: "exists; move it aside").
    2. It is read as complete by 0291-0298, which only read the file.
  - The manifest carries `rows`, so the check is available.
  - Fix: write to `paste0(out, ".part")`, check that the read-back row count equals `f$rows`, then
    `file.rename()`. The 0230 `.part` pattern does the same.

- **[security, low] GitHub edit histories: issue #19 is missing from the revision-deletion list**
  (findings.md:111-136).
  - Two earlier revisions of #19's body, 2026-09-26T05:53Z and 2026-09-29T04:20Z, name
    `fish_passage_template_reporting`.
  - The list was built from items whose current text this session edited. #19's current body was already clean,
    edited on 2026-09-30, before this branch.
  - The sweep does not read `userContentEdits`, so it cannot catch this, and "After merge" step 1 would leave it.
  - Measured over all 57 items: no other revision hit falls outside the list and its stated exceptions.
  - Fix: add #19 to the list. Consider a `history` mode in the sweep that runs the patterns over every
    `userContentEdits.diff` on issues, PRs, comments and reviews (GraphQL). It would make the list derived rather
    than recalled.

- **[fragile] CLAUDE.md:57-63** states two things the guard does not support:
  - "Nothing tracked here … carries client or project identifiers, host or machine names … That includes
    `planning/`". In fact `planning/` and `scripts/logs/` are exempt by decision and carry 2,671 hits in 98 files,
    including `<client project slug>`.
  - `public_sweep.py` "searches … for all of the above". It skips those directories and has no general
    project-identifier pattern.

  A later session will trust both claims. It will take a planning note or a log to be swept and safe to write
  anything into, or take the sweep's exit 0 as covering "client or project identifiers". Fix: state the rule as
  forward-only for `planning/` ("new planning text carries none; the archives before #56 do and are left as they
  are"), and say what the sweep exempts.

- **[security, low; owner decision] branch `11-quick-read-of-the-north-thompson-fish-pa` / open PR #12**: this
  becomes public with the repo. Its tip tree is browsable on the branch selector and in the PR's Files tab. Two
  scripts exist only on that branch, so main's clean-up never reaches them:
  - `scripts/0107-report-sites-crossings-join.R:25` holds `<home>/<gis dir>/<client project slug>/…`, a
    client project slug inside a home path.
  - `scripts/0106-reports-sites-geojson.R:16,34-41` holds the tunnel/63333 and postgres/postgres literals.

  The history and `refs/pull/*` exemption may already cover this. It is listed because it is a live branch with an
  open PR, not past history, and because it carries a client identifier, which the exemption's examples (hosts,
  ports) do not include. The options are:
  - accept it;
  - close PR #12 and delete the branch, which still leaves `refs/pull/12/head`;
  - fix the two files on that branch before the flip.

planning/active/review-round3.md
