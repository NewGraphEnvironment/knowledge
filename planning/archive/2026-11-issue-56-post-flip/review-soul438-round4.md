# An internal issue code-check round 4

## Checklist read

All four indexes (code-check, -r, -shell, -python); code-check-python.md in full (no rule applies: no Python changed);
code-check.md's Mechanisms headings, chiefly "One fact derived twice", "Verification that reads its own output" and
"A guard's scope, escape hatches, and remedies"; code-check-shell.md's sections on patterns the touched function uses
(heredoc delimiters, `tr`-built alternations, `grep -E` word edges, BSD vs GNU).

## Clean

Checked, with what each showed:

- `public_leak_scan` (skills/_shared/filter_conventions.sh): `repos` is built with `tr -s ' \n' '||'` from the list.
  Removing one middle word leaves single spaces between words, so it still squeezes to single `|` and no empty
  alternative appears. `knowledge` was not first or last, so the ends do not change. Only `private_repo` reads the list;
  `template_name` and `host` do not use it.
- Readers of `PUBLIC_LEAK_PRIVATE_REPOS` (`git grep`): filter_conventions.sh:704 and
  skills/_shared/test_filter_conventions.sh:4738-4751. The member count there is computed (`wc -w`), not pinned. Both
  directions of the floor check hold against ecosystem.yml (knowledge stays an asset row at ecosystem.yml:98, which
  the subset direction allows) and against `gh repo list --visibility private`, which no longer returns knowledge.
- `INTERNAL_FLOOR` / internal_set names and headings key on convention file names (`comms_peers`), not on the peer
  list's contents, so dropping a peer line does not change the derived sets or the public-clean scrub needles.
- The comment above the variable: "28 of the 45 on 2026-10-20" counts private non-asset repos caught by the slug class,
  which this change does not touch; no other figure there names a member count.
- The pinned copy of claude_md_drift.sh sources its own extracted filter_conventions.sh, so copies published before
  this change still list knowledge until a new sha is pinned. That fails toward refusing (a `knowledge#N` in a public
  CLAUDE.md is flagged as a leak), not toward a leak. It goes away once the change propagates, the same as the CLAUDE.md
  copies you already accepted.
- Other lists that contain `knowledge`: scripts/cloud-queue/cloud-queue_score.py `REPOS` (all repos, public ones too;
  not a private set) and skills/_shared/test_umbrella.sh's fixture (mocked visibility, separate from GitHub). Neither is
  a copy of the floor.
- conventions/comms_peers.md: no count of peers, and the coordination list at line 22 never named knowledge.
