# An internal issue code-check, round 3

## Checklist read

Read all four indexes, code-check-python.md in full (no Python in this diff), and the prose of every H3 under `## Mechanisms` in code-check.md. No R or shell is touched by the diff (one line removed from a markdown list), so no section of code-check-r.md or code-check-shell.md applies.

## Clean

Diff: removes `- knowledge` from `## Peers` in conventions/comms_peers.md (was line 47). The list now matches line 22's prose list of peers.

Orphaned-mail check, run from the knowledge end (read only, 2026-11-01):
- No `*/comms/knowledge/` directory exists in any local checkout (searched the 12 repos with a `comms/`: compost, fish_passage_template_reporting, kdot, logic, logic-habitat-rules, neexdzii_kwa_benthic_2025, new_graphiti, newgraphenvironment.github.io, rfp, rtj, soul, soul-backlog). No file under any `comms/` has "knowledge" in its name.
- On origin default branches, none of compost, fish_passage_template_reporting, kdot, logic, rfp, rtj, soul has `comms/knowledge` (`gh api repos/.../contents/comms`).
- knowledge itself has no `comms/` directory, tracked or on disk, so there is no outbound mail from it either.
- The 4 comms files that contain the string "knowledge" (logic/ and logic-habitat-rules/comms/soul/20260428_public_vs_internal_repo_architecture.md, compost/comms/logic/20260508_edf_caaf_outreach.md, rfp/comms/crate/20260424_boundary_punt_handoff.md) match the ordinary word ("integration knowledge", "acknowledged"), not the repo.
- Generated CLAUDE.md copies listing knowledge as a peer: compost, fish_passage_template_reporting, logic, logic-habitat-rules, rtj, soul-backlog, soul. They are propagation output (accepted, not re-flagged); none has mail addressed to knowledge.

Bound: feature branches of peer repos on origin were not checked; local checkouts and default branches were.

No thread is orphaned by the removal.
