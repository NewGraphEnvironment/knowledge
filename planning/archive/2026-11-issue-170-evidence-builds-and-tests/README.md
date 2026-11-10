## Outcome

Backlog move 1 (#170), its two members in one PR. #136: the archive (`knw_archive_plan()`, `scripts/0336`) reads
`fdis_sites.csv` from where `0240` writes it (`data/fdis/derived`, the new `sites_dir`/`SITES_DIR`) whatever
`EVIDENCE_DIR` is, so a tagged build archives with no hand-copied file. The table is held to the run's `sites.rds`,
which nothing tied it to before: one row per site and every column the two files share. `knw_archive_pull()` refuses
any target holding other bytes before it writes anything. Before this, it had restored the visit tables first. A staged
`BUILD_DIR` refuses without `SITES_DIR`, and `minimal_network_check.R` writes its log as each step reports. #142: the
live placement test skips, with the reason, when `fresh_default` lacks its tables or holds no BULK bull trout rearing
segment. What was learned: the archive and its checks had been rebuilding `0240`'s output contract from their own side.
That contract is fixed paths, UTF-8 and readr's `na = ""`. Each of the three review rounds found one more place where
this broke: a staged build paired with the host's table, a C locale, and a remedy naming a script that cannot reach a
staged build. `research/run_archive.md` holds the durable account. Promotion (`0335`) now refuses a stale
`fdis_sites.csv` before moving anything, because it plans the archive first.

## Measurement

- The real build (2026-11-09): `sites.rds` and `fdis_sites.csv` have 51,587 sites each and 55 shared columns, all
  equal under the check. That holds in the default locale and under `LC_ALL=C`, which needed `encoding = "UTF-8"`:
  without it, 44 accented `gnis_name` values refused. The check takes 0.6 s.
- Archived evidence ids do not move. Every archived build stores `fdis_sites.csv` with md5 `2de46c60…`, the md5 that
  `derived/`, `derived_parent/` and `derived_minimal/` hold. A dry run of candidate `20261105_0436` on
  `derived_parent`, with its hand copy moved aside, plans evidence id `9978ec26…`, the id the index already holds for
  that run.
- `minimal_network_check.R`: a full run writes a log byte-identical to the old script's (119 lines). A refusal at step 3
  leaves steps 1 and 2 in the log.
- Mutation table: nine guards, each red on its own test when removed, none red on the tree. They are: reading from
  `evidence_dir`; the sites check; the restore pre-pass; the NA pattern; the encoding; Inf held to itself; the remedy
  by build; the two live-test skips.
- A wrong turn, kept: I first claimed `all.equal()` would pass one changed value among thousands. It does not, because
  it drops equal elements before taking the mean. The mutant that relied on the claim survived, which disproved it.
  The comment was corrected.
- Suite: 400 blocks, 0 failed, 0 errors, 2 skipped (unrelated), on `PGSERVICE=fresh_local`.

## Evidence

`review-*.md` in this directory: the plan review, three code-check rounds and the enumeration that ended them (7
refusals and skips against every caller).

Closed by: PR for branch `170-backlog-move-1-evidence-builds-and-tests` (Fixes #136, #142; #170)
