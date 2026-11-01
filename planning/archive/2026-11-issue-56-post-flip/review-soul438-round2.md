# Review: soul#438 round 2 (comms_peers.md: remove `knowledge` from the peer list)

## Checklist read

- Indexes of code-check.md, code-check-r.md, code-check-shell.md, code-check-python.md.
- code-check.md `## Mechanisms` prose (table rows skipped); code-check-python.md read (opening rules; no Python in the diff).
- No R, shell or Python code in the diff, so no tool-specific section of -r/-shell applies.

## Scope checked

- `conventions/comms_peers.md` read whole in the worktree. The `## Peers` list (lines 41-46) now matches
  the coordination/governance peer list at line 22 (`soul, rtj, kdot, compost (pending), logic, rfp,
  fish_passage_template_reporting`), which never named knowledge. Before this diff the two lists disagreed;
  the removal makes them consistent.
- Publication-flip procedure (lines 26-37): step 1 is exactly this edit; steps 2-3 (purge `comms/`, scrub
  CLAUDE.md) are knowledge-side and stated done in the brief. The "same commit that flips repo visibility"
  wording cannot literally hold across two repos, but that is pre-existing text, not introduced or
  contradicted by this diff.
- Participants vs subjects (lines 14-18): knowledge is now public, so it becomes a subject; removing it is
  what the rule requires. No contradiction.
- Readers of the peer list: `conventions/comms.md` (scans "each peer in comms_peers.md", i.e. this file via
  the generated CLAUDE.md copy, deferred per issue), `skills/comms-init/SKILL.md` (points at this file),
  `skills/claude-md-init/SKILL.md:539` (tells the user to remove the repo from this file). None keeps a
  second copy of the list. `skills/compact-prep` walks every local checkout, not the peer list.
- soul's own `comms/` holds `fish_passage_template_reporting`, `neexdzii_kwa_benthic_2025`, `rtj`; no
  `comms/knowledge/` thread is orphaned by the removal, and no `from:/to: knowledge` file exists.

## Clean

No real issue in the diff.

Out of scope, noted only (not the peer list, not a finding): `skills/_shared/filter_conventions.sh:697`
`PUBLIC_LEAK_PRIVATE_REPOS` still names `knowledge` as private, and its test checks that list against
ecosystem.yml's PRIVATE rows. That is the same visibility bookkeeping as README.md:48 and ecosystem.yml,
which the caller has already placed outside this change; once knowledge is public, a public-render scan
would flag any mention of `knowledge` as a private-repo leak until that list and its source rows move.
