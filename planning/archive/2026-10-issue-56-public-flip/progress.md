# Progress — Clean up and make the repo public (#56)

## Session 2026-10-16

- Plan-mode exploration — phases approved by user
- Created branch `56-clean-up-and-make-the-repo-public-packag` off main
- Scaffolded PWF baseline from issue #56 with approved phases
- Next: start Phase 1
- Phase 1: package at the root (`git mv`), root `.Rbuildignore`, `URL`/`BugReports`, scripts `load_all()` from the
  root, `test-data-dir.R` (planted `data/zz_probe.R` and `.rda` each fail it; clean tree passes). `devtools::check()`:
  0 errors, 0 warnings, 1 note (`comms` at top level, removed in Phase 2).
- Phase 2: sweep script; DB connections through `PG*` in 17 scripts and `knw_pscis_pull()`'s example (fallbacks
  removed; `db_source` is the database name); Zotero key from `ZOTERO_API_KEY` only; host names, private-repo links and
  project-named repos reworded; `comms/` removed; an internal issue filed for the peer list. All scripts parse.
- Phase 3: `_pkgdown.yml` (reference grouped by topic), `.github/workflows/pkgdown.yaml` from fresh (drops CLAUDE.md
  before the build, fails on unexpected top-level pages), README rewritten as the home page with research links.
  `pkgdown::build_site()` (CLAUDE.md held aside, as CI does): finished, no problems reported, no internal pages.
- Phase 4: `data/fdis_README.md` (provenance), `scripts/0299-fdis-publish.R` (Parquet read back equal to the CSV as
  read; manifest with rows, sha256, producing script, commit). Local `ch_mad_visits.csv` was never pushed to S3; its
  21,862 rows match the #52 run log. Other local derived CSVs are byte-identical to the S3 copies. Moved
  `fdis/fissr_explore.sqlite` and `fdis/derived/` to `s3://fresh-bc/archive/fdis/`.
- Plan review (`review-plan.md`) arrived during Phase 4; dispositions recorded there. Reproduced B1 (`~/.Renviron`
  replaces shell `PG*`; `PGSERVICE` wins) and B2 (`MANIFEST.md5` listed the archived sqlite). The value-level read-back
  it asked for caught `ch_rule_visits.hydro_zone` read as integers; fixed before the v1 publish.
- Published `s3://fresh-bc/knowledge/fdis/v1/` (5 Parquet + manifest at 2b14507) and `fdis/README.md`; removed the
  earlier unversioned upload. `PULL=TRUE` into a scratch checkout restores all five CSVs equal as `readr` reads them within 1e-12 (code-check round 1: `readr` parses 17-digit
  text to within an ulp, while the Parquet holds arrow's exact parse; types are identical).
- Phase 5: CLAUDE.md top half rewritten; tree sweep clean.
- Phase 5: `/claude-md-init --public-clean` from soul origin/main@7360fe9 (5 internal headings checked, none present;
  992d65f). GitHub text: 13 issues, 4 PRs, 4 comments edited and #4 retitled; sweep of tree, GitHub text and branch
  commits returns no hits. Revision-deletion list in findings.md.
- Validation: `devtools::test()` 105 passed; `devtools::check()` clean. 0240 and 0250 reproduced every tracked output;
  0280 passed with its log in scratch; 0100/0110 stop at the remote server's connection timeout (unreachable here).
- `/code-check branch` round 1 (`review-round1.md`): 4 findings, all reproduced and fixed: a duplicate `const A` in
  `wf_peace_report_harvest.js` (`node --check` now passes); `0230`'s `NO_SIGN` sync needs ListBucket, which the public
  grant omits (now fetches `MANIFEST.md5`, `README.md` and each listed key; the key-by-key fetch verifies 26/0);
  nothing stopped an overwrite of `v1` (manifest now records schemas; `PUBLISH` refuses a changed table set or
  schema); the sweep skipped non-UTF-8 files (now reads their printable runs; a planted gpkg string is caught).
- Round 2 (`review-round2.md`): 3 findings, all reproduced. Inside round-1 fix 2: `0230`'s `NO_SIGN` fetch wrote
  `MANIFEST.md5` first, so a partial fetch looked complete (now fetched aside and moved in last; a simulated mid-fetch
  failure leaves only `.part` and the re-run verifies 26/0). The sweep missed retitle entries (now read; #4's "from the
  M1" is the one hit, owner's decision) and the generated conventions below CLAUDE.md's marker (39 hits; reported, not
  failed; an internal issue filed). A third bucket-policy comment on #56 was edited.
- Round 3 (`review-round3.md`) named the mechanism: guards that decide "clean" or "done" from a list or marker written
  from what was known, not from the population. 6 findings, all reproduced: the issue's one project name
  (`data/context_bowron_mcgregor.md`, never carried into the plan) and the same slug in #17's body, both reworded, with
  the slug class added to the sweep; inside round-2's fix, `0230`'s credentialed sync could also land the manifest
  before the rest (now synced with `--exclude MANIFEST.md5` and the manifest copied last; a fresh sync verifies
  26/0); `PULL` wrote CSVs in place (now `.part`, row-checked, renamed); #19's revisions were missing from the recalled
  deletion list (a `history` sweep mode now measures it: 23 items); CLAUDE.md overstated what `planning/` and the sweep
  cover (reworded). Owner decisions left: #4's retitle entry, and the issue branch behind open PR #12.
- Round 4 (`review-round4.md`, an enumeration round): its enumeration held on every surface and every completion marker
  except four findings, three inside round-3 fixes, all reproduced and fixed: the slug class took only underscores
  (a hyphenated client slug sits in the generated conventions; pattern now `[-_]`, an internal issue updated); this branch's
  PWF quoted client slugs and home paths (scrubbed, and `planning/active/` is now swept for those two classes); the
  flip followed a revision list frozen at PR time (now gated on `history` and `all` run on the day); `history()` read
  one page of comments with no check and no PR reviews (every connection's `totalCount` is now checked, a lowered
  limit stops the run, and reviews and review comments are read; same 23 items).
- Loop ended by enumeration rather than a fifth reviewer: the slug class matches only exempt areas (old archives, a
  literature citation key) and the generated text in an internal issue; `all` returns only #4's retitle; `history` returns the
  23 recorded items; each CLAUDE.md sentence about the sweep was checked against its code.
