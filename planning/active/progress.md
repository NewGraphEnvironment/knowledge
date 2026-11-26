# Progress — Grayling: rebuild link's default from the literature and where grayling were caught (#140)

## Session 2026-11-26

- Plan-mode exploration — phases approved by user (scope split at the gate: steps 1-2 here, 3-5 to a new member)
- Created branch `140-grayling-rebuild-link-s-default-from-the` off origin/main
- Scaffolded PWF baseline from issue #140 with approved phases
- Next: start Phase 1

## Phase 1, 2026-11-26
- Split the issue at the gate: #280 (proposal, register, retune), then #281 (FISS workbook records) at the plan
  review; #140's body, title and #139's members updated.
- Commits: ad16fc98 (plan review folded in)

## Phases 2-4, 2026-11-26
- Store queried (hybrid hits only); two drafters (`rows`, `life`) from `drafter-brief.md`; 65 rows and a 136-quote
  life history.
- Al chose to source the originals in this PR: 14 sourced, 12 PDFs, filed by `0270`; `bull_trout_grayling` rebuilt on
  m1 (208 documents) and pushed; verified pull md5 matches the manifest.
- Rows re-quoted from originals and extended to 115 (data rows 1190-1304); meaning audit 14, 9, 6, 4 findings.
- Life history to 245 quotes; meaning audit 32, 29, 6 findings.
- Found #282 (42 older OCR rows broken since #217's scan replacement) and filed it.
- Commits: e4f43538 .. f3f84fb0

## Phases 5-6, 2026-11-26
- Spec fixed before any fit (1ce26c68, change 1 b1a5495b); `data-raw/grayling_use.R` on the tuning's own GR rearing
  population (1,580 visits, 229 with GR); reruns byte-identical.
- `data-raw/grayling_segments.R` on Hagen et al.'s 85 segments (EcoCat layer ignored, aggregates only).
- `research/grayling_habitat.md`, README rows, NOTICE, CLAUDE.md and data-raw README entries.
- Code-check rounds 1-3 fixed 5, 2 and 5 findings (one mechanism: a summary over rows that are not its units);
  round 4 enumerates.

## Close, 2026-11-26
- Code-check five rounds (5, 2, 5, 3, 1 findings), ended by enumeration; verdict `review-verdict.md`.
- Write-up meaning audit three rounds (17, 18, 10); final gate logs committed (all 115 GR rows and 415 research
  quotes verify; 42 older rows fail, #282).
- Next: `/planning-archive`, then the PR.
