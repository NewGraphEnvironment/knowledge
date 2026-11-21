# Progress — statistics store: rebuild under ragnar 0.4.0 so Hedger et al. 2013 joins (#223)

## Session 2026-11-21

- Plan-mode exploration — phases approved by user
- Created branch `223-statistics-store-rebuild-under-ragnar-0` off origin/main
- Scaffolded PWF baseline from issue #223 with approved phases
- Next: start Phase 1

## Phase 1, 2026-11-21

- m1 checked (cred 0.8.0, ragnar 0.4.0, Ollama, Hedger's PDF); the bucket's statistics pulled (31 documents) with the
  before query logged; expected file written; Plan review folded (`review-plan.md`): the build and push run from a
  worktree of this branch on m1 so the manifest names this branch.
- Zotero quit on m1, `-wal` 0 bytes at 2026-11-21T19:22Z.
- Commits: 6678dab9
- Next: Phase 2, the rebuild (launched 2026-11-21T19:23Z on m1, `~/knw223/wt`)

## Phases 2 and 3, 2026-11-21

- Rebuilt on m1 from the branch worktree, 19:23Z to 19:31Z: 32 documents, 1 added (Hedger), 0 dropped, nothing skipped.
- After-query returns Hedger; Zotero reopened on m1; pushed at 19:55Z and read back from the bucket; issue body ticked
  with the cred deferral stated; the m1 worktree and its local branch removed.
- Commits: fa08310e, this commit
- Next: archive, PR
