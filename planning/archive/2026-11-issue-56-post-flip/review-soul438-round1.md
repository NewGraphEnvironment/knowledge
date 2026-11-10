## Checklist read

- code-check-python.md: in full (index and full text).
- code-check.md: index read; prose of all 14 H3s under `## Mechanisms` read (tables skipped); also "Documentation Staleness" in full. The other 26 headings (Rules that stand alone, Security, Spreadsheets and PDFs) not read in full: none names a tool, shape or pattern this markdown-only diff uses.
- code-check-r.md: index read (115 headings); 0 sections read in full, because the diff touches no R.
- code-check-shell.md: index read (70 headings); 0 sections read in full, because the diff touches no shell.

## Clean

No issues found.

What was checked (soul worktree `soul-438`, staged diff removes `- knowledge` from `conventions/comms_peers.md:47`):

- **Consumers of the peer list.** `grep -rn comms_peers` across soul outside `planning/archive/` finds only prose consumers: `conventions/comms.md:8,13` (scan "each peer in `comms_peers.md`"), `comms/README.md:57`, `skills/comms-init/SKILL.md:66,78`, `skills/claude-md-init/SKILL.md:46,539`, `README.md:228`, and the generated `CLAUDE.md`. No script or test parses the `## Peers` list. `skills/_shared/filter_conventions.sh` and `test_filter_conventions.sh` handle `comms_peers` only as a convention name (the internal floor, the `applies_when` gate, the collation order of `comms.md`/`comms_peers.md`), never the list's members or a count of them.
- **Other copies of the list.** Line 22's prose list of coordination peers (`soul`, `rtj`, `kdot`, `compost`, `logic`, `rfp`, `fish_passage_template_reporting`) never named knowledge, so it agrees with the edited list. The only other copy is the generated `CLAUDE.md:1599`, which the issue leaves to propagate after merge (expected).
- **Threads addressed to knowledge.** `soul/comms/` holds `fish_passage_template_reporting/`, `neexdzii_kwa_benthic_2025/` and `rtj/`; there is no `comms/knowledge/` and no thread names knowledge, so no mail is orphaned.
- **Tests with knowledge in them.** `skills/_shared/test_umbrella.sh:69-81` sets knowledge as PRIVATE, but in a synthetic fixture (`$FX/vis`, `$FX/private`), not read from the live repo or from `comms_peers.md`, so the edit does not affect it.
- **Premise.** `gh repo view NewGraphEnvironment/knowledge` reports `PUBLIC` (2026-11-01), so the removal follows the "peers must be private" rule.

Out of scope (the diff did not cause this, noted for the caller): `README.md:48` still shows knowledge as `private`. That table is rendered from `ecosystem.yml` plus the live `gh repo list` visibility (`scripts/ecosystem/ecosystem_registry.py:155,533`), so the README is now stale and the daily `ecosystem-check` workflow should report the drift until it is re-rendered. `ecosystem.yml:98` also files knowledge under `kind: coordination`, which soul's CLAUDE.md describes as private coordination. Neither is part of an internal issue's scope.
