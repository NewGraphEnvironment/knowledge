## Checklist read

- Indexes: index_code-check.md, index_code-check-r.md, index_code-check-shell.md, index_code-check-spatial.md, index_code-check-python.md.
- code-check-python.md in full (no Python changed in the diff).
- code-check.md: the prose of every H3 under `## Mechanisms` (evidence tables skipped), "Documentation Staleness", and `"Public bucket" ≠ listable: GetObject vs ListBucket` (the diff's bucket claims).
- code-check-r.md / -shell.md / -spatial.md: index only; the diff changes R script header comments and no code, so no tool-specific section applies beyond the S3 one above.

## What was verified

- Every URL the diff adds or names answers 200 with `curl -L`: the site root, `news/index.html`, `articles/chinook_rearing.html`, `articles/habitat_thresholds.html` (its h1 is the README's link text), `reference/index.html`. `newgraphenvironment.github.io/knowledge/` answers 301 to `https://www.newgraphenvironment.com/knowledge/`, as CLAUDE.md:11-12 now says.
- `gh repo view` reads PUBLIC (2026-11-01).
- Bucket policy (`PublicReadPrefixes`) grants `s3:GetObject` on `fresh-bc/fdis/*` and `fresh-bc/knowledge/*`, no ListBucket: matches research/fdis_export.md:32-34, scripts/0325-publish.R:16-17 and the README.
- Anonymous reads (curl, no credentials): `fdis/README.md` 200, `fdis/MANIFEST.md5` 200, `knowledge/fdis/v2/manifest.json` 200, `knowledge/fdis/v1/manifest.json` 200; `rag/log.json` 403 (CLAUDE.md:95 "not public" holds); bucket root 403 (no listing).
- 0299's `NO_SIGN` path: `aws s3 cp --no-sign-request` of the v2 manifest and of `fdis_sites.parquet`, with AWS env unset, both exit 0 and write the files, so the PULL path the comment at scripts/0299-fdis-publish.R:35 describes works anonymously (for v2; v3 is unpublished and 403s, which the header already says).
- knw_publish (R/publish.R) uploads with plain `aws s3 cp`, no ACL; the bucket policy makes each object readable on upload, as the 0325 comment says. thresholds/v1 and habitat_grade/v1 are not yet published (403, absent under `knowledge/`), consistent with the comment's conditional wording.
- research/fdis_export.md "Where it lives" re-verified 2026-11-01: `fdis/MANIFEST.md5` has 26 lines and no sqlite line; `archive/fdis/` holds `fissr_explore.sqlite`, `derived/` and the original manifest; `knowledge/fdis/` holds v1 and v2; v2's manifest carries `supersedes: knowledge/fdis/v1`.
- `public_sweep.py tree` over the tracked tree: only the known false positives (`m1`/`M4` in test-tune_score.R and PNG bytes) and the generated conventions below the CLAUDE.md marker; nothing from this diff.
- planning/ diff: no home paths, no client or project names.

## Findings

**[severity: fragile]** CLAUDE.md:119-121 — The diff records the PSCIS decision as settled ("their snapshots stay tracked as incidental working copies (Al, 2026-11-01)"). The sentence before it says `inst/NOTICE.md` "lists each source with its files". But inst/NOTICE.md on this branch, and on main, still lists PSCIS under "Terms not yet settled": "open in #76, and this notice does not cover them". So the spec and the shipped notice disagree. #76's body (edited this session) also says "`inst/NOTICE.md` calls them incidental working copies", which is not yet true on main. The NOTICE change exists only in open PR #133 (branch `76-pscis-notice`). That PR edits the same two CLAUDE.md hunks as this branch, with different text:
- the site line keeps `newgraphenvironment.github.io/knowledge/`;
- the licence sentence keeps "to settle before the repo is public", which is stale after the flip and is exactly what this branch removes.

So whichever PR merges second conflicts on both hunks, and a resolution that takes #133's side brings back the pre-flip wording. If this PR merges first, main's CLAUDE.md contradicts its NOTICE until #133 lands. Two ways to fix it:
1. Merge #133 first, then rebase its CLAUDE.md hunks onto this branch's wording (drop "to settle before the repo is public" there).
2. Or drop the PSCIS sentence from this diff and leave it to #133, with #133's CLAUDE.md hunks rewritten to this branch's text.

**Rule:** code-check.md, "Documentation Staleness"
