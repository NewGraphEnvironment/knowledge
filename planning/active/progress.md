# Progress — Backlog move 1: evidence builds and tests (#170)

## Session 2026-11-09

- Plan-mode exploration — phases approved by user
- Created branch `170-backlog-move-1-evidence-builds-and-tests` off origin/main
- Scaffolded PWF baseline from issue #170 with approved phases
- Next: start Phase 1
- #142: `test-link_place.R` skips when the BULK query returns no row. On `PGSERVICE=fresh_local` the live test passes (5
  expectations); a scratch copy querying group `ZZZZ` reports SKIP with the reason, and the same copy without the skip
  reports an error.
- #136 (log): `minimal_network_check.R` appends as each step reports. A scratch copy reading an `access_check.csv`
  without `watershed_group_code` exits 1 with steps 1, 2 and the refusal in its log; a full run on
  `derived_zz415_default`/`derived_zz415_minimal` writes a log byte-identical to the old script's (119 lines).
- #136 (archive): tests first (20 blocks red before `sites_dir` existed). `knw_archive_plan(sites_dir =)` reads
  `fdis_sites.csv` from 0240's directory and holds it to `sites.rds` over every shared column; `knw_archive_pull`
  refuses any differing target before writing. Mutations, each red on its own test: reading from `evidence_dir`, no
  sites check, no restore pre-pass, no NA-pattern check. On the real build the check passes in 0.6 s.
- Plan review (`review-plan.md`): the blocker (restore pre-pass) and gaps G1, G2, G3, G5 and G6 are folded in, and G4
  widened the check. All-equal worry retracted: `all.equal()` drops equal elements before its mean, so it would have
  caught one changed value; the elementwise compare stays for clarity, and its comment was corrected.
- `0335`'s promotion now refuses before moving anything when `fdis_sites.csv` does not match `sites.rds` (it plans the
  archive first): a behaviour change for the PR body.
- Validation: `devtools::test()` on `PGSERVICE=fresh_local`, 400 blocks, 0 failed, 0 errors, 2 skipped. lintr on the
  six touched files, per file, linter and line against an `origin/main` worktree: no new lint after wrapping
  `plan_of`. Live: with `derived_parent/fdis_sites.csv` moved aside, `RUN=20261105_0436 EVIDENCE_DIR=data/fdis/derived_parent
  DRY=1 0336` plans evidence id `9978ec26…`, the id `data/archive_index.csv` already holds for that run (file put back).
- `/code-check branch`, 3 rounds (`review-round{1,2,3}.md`) and an enumeration (`review-enumeration.md`):
  round 1, a staged BUILD_DIR read the host's table (0336 now refuses it without SITES_DIR); round 2, the C-locale
  UTF-8 refusal (`encoding = "UTF-8"`); round 3, the remedy text inside round 1's fix and a latent Inf (remedy by build;
  Inf equal only to itself). Ended by enumerating the 7 refusals and skips the branch adds against every caller.
  Final suite: 400 blocks, 0 failed, 0 errors, 2 skipped (unrelated); lints unchanged.
