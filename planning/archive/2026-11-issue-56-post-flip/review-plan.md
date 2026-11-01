# Plan review (Plan agent, 2026-11-01)

- **Gap:** `scripts/0299-fdis-publish.R:35` "NO_SIGN=TRUE reads without AWS credentials once the prefix is public":
  confirmed, fixed in Phase 2 (and an unsigned `aws s3 cp --no-sign-request` of the v2 manifest succeeded).
- **Gap:** `research/fdis_export.md:3` Verified line is per section: updated as "Where it lives: 2026-11-01". Done.
- **Assumption (wrong):** the chinook article does not link the methodology article (the methodology article links
  the chinook one). Confirmed; recorded in findings, kept out of the PR and #56 text.
- **Acceptance:** no test reads README, CLAUDE.md, 0325 or fdis_export.md; `devtools::test()` stays as a check.
  Grep widened with "once the prefix", "once the bucket", "until then", "go public": only 0299:35 was new.
  Correct as they are: CLAUDE.md:96 (rag not public), research/run_archive.md:17, research/stream_temperature.md,
  scripts/0260:35, .github/workflows/pkgdown.yaml:46, credential mentions in CLAUDE.md and scripts/README.md.
- **Scope:** vignettes keep the github.io form, which matches DESCRIPTION; `_pkgdown.yml` has no home links. No
  change. The README chinook link text differs from the article title (pre-existing); left.
- **Ordering:** untracked `pkgdown/favicon/` is left out of this PR (not this work). CLAUDE.md edited before #76's
  body, so the wording matches.
- **Blocker:** none.
